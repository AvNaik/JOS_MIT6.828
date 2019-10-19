
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
f0100048:	83 3d 80 2e 21 f0 00 	cmpl   $0x0,0xf0212e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 2e 21 f0    	mov    %esi,0xf0212e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 c1 5b 00 00       	call   f0105c22 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 c0 62 10 f0       	push   $0xf01062c0
f010006d:	e8 b2 37 00 00       	call   f0103824 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 82 37 00 00       	call   f01037fe <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 61 66 10 f0 	movl   $0xf0106661,(%esp)
f0100083:	e8 9c 37 00 00       	call   f0103824 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 c9 08 00 00       	call   f010095e <monitor>
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
f01000a1:	e8 96 05 00 00       	call   f010063c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a6:	83 ec 08             	sub    $0x8,%esp
f01000a9:	68 ac 1a 00 00       	push   $0x1aac
f01000ae:	68 2c 63 10 f0       	push   $0xf010632c
f01000b3:	e8 6c 37 00 00       	call   f0103824 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000b8:	e8 b3 13 00 00       	call   f0101470 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000bd:	e8 d0 2f 00 00       	call   f0103092 <env_init>
	trap_init();
f01000c2:	e8 3b 38 00 00       	call   f0103902 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000c7:	e8 4c 58 00 00       	call   f0105918 <mp_init>
	lapic_init();
f01000cc:	e8 6c 5b 00 00       	call   f0105c3d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000d1:	e8 75 36 00 00       	call   f010374b <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d6:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000dd:	e8 ae 5d 00 00       	call   f0105e90 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e2:	83 c4 10             	add    $0x10,%esp
f01000e5:	83 3d 88 2e 21 f0 07 	cmpl   $0x7,0xf0212e88
f01000ec:	77 16                	ja     f0100104 <i386_init+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01000ee:	68 00 70 00 00       	push   $0x7000
f01000f3:	68 e4 62 10 f0       	push   $0xf01062e4
f01000f8:	6a 5b                	push   $0x5b
f01000fa:	68 47 63 10 f0       	push   $0xf0106347
f01000ff:	e8 3c ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100104:	83 ec 04             	sub    $0x4,%esp
f0100107:	b8 7e 58 10 f0       	mov    $0xf010587e,%eax
f010010c:	2d 04 58 10 f0       	sub    $0xf0105804,%eax
f0100111:	50                   	push   %eax
f0100112:	68 04 58 10 f0       	push   $0xf0105804
f0100117:	68 00 70 00 f0       	push   $0xf0007000
f010011c:	e8 2b 55 00 00       	call   f010564c <memmove>
f0100121:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100124:	bb 20 30 21 f0       	mov    $0xf0213020,%ebx
f0100129:	eb 4d                	jmp    f0100178 <i386_init+0xde>
		if (c == cpus + cpunum())  // We've started already.
f010012b:	e8 f2 5a 00 00       	call   f0105c22 <cpunum>
f0100130:	6b c0 74             	imul   $0x74,%eax,%eax
f0100133:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0100138:	39 c3                	cmp    %eax,%ebx
f010013a:	74 39                	je     f0100175 <i386_init+0xdb>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010013c:	89 d8                	mov    %ebx,%eax
f010013e:	2d 20 30 21 f0       	sub    $0xf0213020,%eax
f0100143:	c1 f8 02             	sar    $0x2,%eax
f0100146:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010014c:	c1 e0 0f             	shl    $0xf,%eax
f010014f:	05 00 c0 21 f0       	add    $0xf021c000,%eax
f0100154:	a3 84 2e 21 f0       	mov    %eax,0xf0212e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100159:	83 ec 08             	sub    $0x8,%esp
f010015c:	68 00 70 00 00       	push   $0x7000
f0100161:	0f b6 03             	movzbl (%ebx),%eax
f0100164:	50                   	push   %eax
f0100165:	e8 21 5c 00 00       	call   f0105d8b <lapic_startap>
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
f0100178:	6b 05 c4 33 21 f0 74 	imul   $0x74,0xf02133c4,%eax
f010017f:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0100184:	39 c3                	cmp    %eax,%ebx
f0100186:	72 a3                	jb     f010012b <i386_init+0x91>
	lock_kernel();
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100188:	83 ec 08             	sub    $0x8,%esp
f010018b:	6a 01                	push   $0x1
f010018d:	68 08 0c 1d f0       	push   $0xf01d0c08
f0100192:	e8 98 30 00 00       	call   f010322f <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100197:	83 c4 08             	add    $0x8,%esp
f010019a:	6a 00                	push   $0x0
f010019c:	68 40 1c 20 f0       	push   $0xf0201c40
f01001a1:	e8 89 30 00 00       	call   f010322f <env_create>
	ENV_CREATE(user_icode, ENV_TYPE_USER);

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001a6:	e8 35 04 00 00       	call   f01005e0 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001ab:	e8 8f 42 00 00       	call   f010443f <sched_yield>

f01001b0 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b0:	55                   	push   %ebp
f01001b1:	89 e5                	mov    %esp,%ebp
f01001b3:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b6:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c0:	77 12                	ja     f01001d4 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c2:	50                   	push   %eax
f01001c3:	68 08 63 10 f0       	push   $0xf0106308
f01001c8:	6a 72                	push   $0x72
f01001ca:	68 47 63 10 f0       	push   $0xf0106347
f01001cf:	e8 6c fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d4:	05 00 00 00 10       	add    $0x10000000,%eax
f01001d9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001dc:	e8 41 5a 00 00       	call   f0105c22 <cpunum>
f01001e1:	83 ec 08             	sub    $0x8,%esp
f01001e4:	50                   	push   %eax
f01001e5:	68 53 63 10 f0       	push   $0xf0106353
f01001ea:	e8 35 36 00 00       	call   f0103824 <cprintf>

	lapic_init();
f01001ef:	e8 49 5a 00 00       	call   f0105c3d <lapic_init>
	env_init_percpu();
f01001f4:	e8 69 2e 00 00       	call   f0103062 <env_init_percpu>
	trap_init_percpu();
f01001f9:	e8 3a 36 00 00       	call   f0103838 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001fe:	e8 1f 5a 00 00       	call   f0105c22 <cpunum>
f0100203:	6b d0 74             	imul   $0x74,%eax,%edx
f0100206:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100211:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100215:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021c:	e8 6f 5c 00 00       	call   f0105e90 <spin_lock>
	//
	// Your code here:

	lock_kernel();
	// Remove this after you finish Exercise 6
	sched_yield ();
f0100221:	e8 19 42 00 00       	call   f010443f <sched_yield>

f0100226 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100226:	55                   	push   %ebp
f0100227:	89 e5                	mov    %esp,%ebp
f0100229:	53                   	push   %ebx
f010022a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010022d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100230:	ff 75 0c             	pushl  0xc(%ebp)
f0100233:	ff 75 08             	pushl  0x8(%ebp)
f0100236:	68 69 63 10 f0       	push   $0xf0106369
f010023b:	e8 e4 35 00 00       	call   f0103824 <cprintf>
	vcprintf(fmt, ap);
f0100240:	83 c4 08             	add    $0x8,%esp
f0100243:	53                   	push   %ebx
f0100244:	ff 75 10             	pushl  0x10(%ebp)
f0100247:	e8 b2 35 00 00       	call   f01037fe <vcprintf>
	cprintf("\n");
f010024c:	c7 04 24 61 66 10 f0 	movl   $0xf0106661,(%esp)
f0100253:	e8 cc 35 00 00       	call   f0103824 <cprintf>
	va_end(ap);
}
f0100258:	83 c4 10             	add    $0x10,%esp
f010025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025e:	c9                   	leave  
f010025f:	c3                   	ret    

f0100260 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100260:	55                   	push   %ebp
f0100261:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100263:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100268:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100269:	a8 01                	test   $0x1,%al
f010026b:	74 0b                	je     f0100278 <serial_proc_data+0x18>
f010026d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100272:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100273:	0f b6 c0             	movzbl %al,%eax
f0100276:	eb 05                	jmp    f010027d <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010027d:	5d                   	pop    %ebp
f010027e:	c3                   	ret    

f010027f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	53                   	push   %ebx
f0100283:	83 ec 04             	sub    $0x4,%esp
f0100286:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100288:	eb 2b                	jmp    f01002b5 <cons_intr+0x36>
		if (c == 0)
f010028a:	85 c0                	test   %eax,%eax
f010028c:	74 27                	je     f01002b5 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010028e:	8b 0d 24 22 21 f0    	mov    0xf0212224,%ecx
f0100294:	8d 51 01             	lea    0x1(%ecx),%edx
f0100297:	89 15 24 22 21 f0    	mov    %edx,0xf0212224
f010029d:	88 81 20 20 21 f0    	mov    %al,-0xfdedfe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002a9:	75 0a                	jne    f01002b5 <cons_intr+0x36>
			cons.wpos = 0;
f01002ab:	c7 05 24 22 21 f0 00 	movl   $0x0,0xf0212224
f01002b2:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b5:	ff d3                	call   *%ebx
f01002b7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ba:	75 ce                	jne    f010028a <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bc:	83 c4 04             	add    $0x4,%esp
f01002bf:	5b                   	pop    %ebx
f01002c0:	5d                   	pop    %ebp
f01002c1:	c3                   	ret    

f01002c2 <kbd_proc_data>:
f01002c2:	ba 64 00 00 00       	mov    $0x64,%edx
f01002c7:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002c8:	a8 01                	test   $0x1,%al
f01002ca:	0f 84 f8 00 00 00    	je     f01003c8 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002d0:	a8 20                	test   $0x20,%al
f01002d2:	0f 85 f6 00 00 00    	jne    f01003ce <kbd_proc_data+0x10c>
f01002d8:	ba 60 00 00 00       	mov    $0x60,%edx
f01002dd:	ec                   	in     (%dx),%al
f01002de:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e0:	3c e0                	cmp    $0xe0,%al
f01002e2:	75 0d                	jne    f01002f1 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002e4:	83 0d 00 20 21 f0 40 	orl    $0x40,0xf0212000
		return 0;
f01002eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f0:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f1:	55                   	push   %ebp
f01002f2:	89 e5                	mov    %esp,%ebp
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f8:	84 c0                	test   %al,%al
f01002fa:	79 36                	jns    f0100332 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002fc:	8b 0d 00 20 21 f0    	mov    0xf0212000,%ecx
f0100302:	89 cb                	mov    %ecx,%ebx
f0100304:	83 e3 40             	and    $0x40,%ebx
f0100307:	83 e0 7f             	and    $0x7f,%eax
f010030a:	85 db                	test   %ebx,%ebx
f010030c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030f:	0f b6 d2             	movzbl %dl,%edx
f0100312:	0f b6 82 e0 64 10 f0 	movzbl -0xfef9b20(%edx),%eax
f0100319:	83 c8 40             	or     $0x40,%eax
f010031c:	0f b6 c0             	movzbl %al,%eax
f010031f:	f7 d0                	not    %eax
f0100321:	21 c8                	and    %ecx,%eax
f0100323:	a3 00 20 21 f0       	mov    %eax,0xf0212000
		return 0;
f0100328:	b8 00 00 00 00       	mov    $0x0,%eax
f010032d:	e9 a4 00 00 00       	jmp    f01003d6 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100332:	8b 0d 00 20 21 f0    	mov    0xf0212000,%ecx
f0100338:	f6 c1 40             	test   $0x40,%cl
f010033b:	74 0e                	je     f010034b <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010033d:	83 c8 80             	or     $0xffffff80,%eax
f0100340:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100342:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100345:	89 0d 00 20 21 f0    	mov    %ecx,0xf0212000
	}

	shift |= shiftcode[data];
f010034b:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010034e:	0f b6 82 e0 64 10 f0 	movzbl -0xfef9b20(%edx),%eax
f0100355:	0b 05 00 20 21 f0    	or     0xf0212000,%eax
f010035b:	0f b6 8a e0 63 10 f0 	movzbl -0xfef9c20(%edx),%ecx
f0100362:	31 c8                	xor    %ecx,%eax
f0100364:	a3 00 20 21 f0       	mov    %eax,0xf0212000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100369:	89 c1                	mov    %eax,%ecx
f010036b:	83 e1 03             	and    $0x3,%ecx
f010036e:	8b 0c 8d c0 63 10 f0 	mov    -0xfef9c40(,%ecx,4),%ecx
f0100375:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100379:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037c:	a8 08                	test   $0x8,%al
f010037e:	74 1b                	je     f010039b <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100380:	89 da                	mov    %ebx,%edx
f0100382:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100385:	83 f9 19             	cmp    $0x19,%ecx
f0100388:	77 05                	ja     f010038f <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010038a:	83 eb 20             	sub    $0x20,%ebx
f010038d:	eb 0c                	jmp    f010039b <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010038f:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100392:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100395:	83 fa 19             	cmp    $0x19,%edx
f0100398:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039b:	f7 d0                	not    %eax
f010039d:	a8 06                	test   $0x6,%al
f010039f:	75 33                	jne    f01003d4 <kbd_proc_data+0x112>
f01003a1:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a7:	75 2b                	jne    f01003d4 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003a9:	83 ec 0c             	sub    $0xc,%esp
f01003ac:	68 83 63 10 f0       	push   $0xf0106383
f01003b1:	e8 6e 34 00 00       	call   f0103824 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003bb:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c0:	ee                   	out    %al,(%dx)
f01003c1:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c4:	89 d8                	mov    %ebx,%eax
f01003c6:	eb 0e                	jmp    f01003d6 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003cd:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003d3:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d4:	89 d8                	mov    %ebx,%eax
}
f01003d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003d9:	c9                   	leave  
f01003da:	c3                   	ret    

f01003db <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003db:	55                   	push   %ebp
f01003dc:	89 e5                	mov    %esp,%ebp
f01003de:	57                   	push   %edi
f01003df:	56                   	push   %esi
f01003e0:	53                   	push   %ebx
f01003e1:	83 ec 1c             	sub    $0x1c,%esp
f01003e4:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003eb:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f5:	eb 09                	jmp    f0100400 <cons_putc+0x25>
f01003f7:	89 ca                	mov    %ecx,%edx
f01003f9:	ec                   	in     (%dx),%al
f01003fa:	ec                   	in     (%dx),%al
f01003fb:	ec                   	in     (%dx),%al
f01003fc:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003fd:	83 c3 01             	add    $0x1,%ebx
f0100400:	89 f2                	mov    %esi,%edx
f0100402:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100403:	a8 20                	test   $0x20,%al
f0100405:	75 08                	jne    f010040f <cons_putc+0x34>
f0100407:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010040d:	7e e8                	jle    f01003f7 <cons_putc+0x1c>
f010040f:	89 f8                	mov    %edi,%eax
f0100411:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100414:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100419:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041a:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041f:	be 79 03 00 00       	mov    $0x379,%esi
f0100424:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100429:	eb 09                	jmp    f0100434 <cons_putc+0x59>
f010042b:	89 ca                	mov    %ecx,%edx
f010042d:	ec                   	in     (%dx),%al
f010042e:	ec                   	in     (%dx),%al
f010042f:	ec                   	in     (%dx),%al
f0100430:	ec                   	in     (%dx),%al
f0100431:	83 c3 01             	add    $0x1,%ebx
f0100434:	89 f2                	mov    %esi,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010043d:	7f 04                	jg     f0100443 <cons_putc+0x68>
f010043f:	84 c0                	test   %al,%al
f0100441:	79 e8                	jns    f010042b <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100443:	ba 78 03 00 00       	mov    $0x378,%edx
f0100448:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044c:	ee                   	out    %al,(%dx)
f010044d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100452:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100457:	ee                   	out    %al,(%dx)
f0100458:	b8 08 00 00 00       	mov    $0x8,%eax
f010045d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010045e:	89 fa                	mov    %edi,%edx
f0100460:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100466:	89 f8                	mov    %edi,%eax
f0100468:	80 cc 07             	or     $0x7,%ah
f010046b:	85 d2                	test   %edx,%edx
f010046d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100470:	89 f8                	mov    %edi,%eax
f0100472:	0f b6 c0             	movzbl %al,%eax
f0100475:	83 f8 09             	cmp    $0x9,%eax
f0100478:	74 74                	je     f01004ee <cons_putc+0x113>
f010047a:	83 f8 09             	cmp    $0x9,%eax
f010047d:	7f 0a                	jg     f0100489 <cons_putc+0xae>
f010047f:	83 f8 08             	cmp    $0x8,%eax
f0100482:	74 14                	je     f0100498 <cons_putc+0xbd>
f0100484:	e9 99 00 00 00       	jmp    f0100522 <cons_putc+0x147>
f0100489:	83 f8 0a             	cmp    $0xa,%eax
f010048c:	74 3a                	je     f01004c8 <cons_putc+0xed>
f010048e:	83 f8 0d             	cmp    $0xd,%eax
f0100491:	74 3d                	je     f01004d0 <cons_putc+0xf5>
f0100493:	e9 8a 00 00 00       	jmp    f0100522 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100498:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f010049f:	66 85 c0             	test   %ax,%ax
f01004a2:	0f 84 e6 00 00 00    	je     f010058e <cons_putc+0x1b3>
			crt_pos--;
f01004a8:	83 e8 01             	sub    $0x1,%eax
f01004ab:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b1:	0f b7 c0             	movzwl %ax,%eax
f01004b4:	66 81 e7 00 ff       	and    $0xff00,%di
f01004b9:	83 cf 20             	or     $0x20,%edi
f01004bc:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f01004c2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c6:	eb 78                	jmp    f0100540 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004c8:	66 83 05 28 22 21 f0 	addw   $0x50,0xf0212228
f01004cf:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d0:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f01004d7:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004dd:	c1 e8 16             	shr    $0x16,%eax
f01004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e3:	c1 e0 04             	shl    $0x4,%eax
f01004e6:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228
f01004ec:	eb 52                	jmp    f0100540 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004ee:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f3:	e8 e3 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f01004f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fd:	e8 d9 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f0100502:	b8 20 00 00 00       	mov    $0x20,%eax
f0100507:	e8 cf fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f010050c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100511:	e8 c5 fe ff ff       	call   f01003db <cons_putc>
		cons_putc(' ');
f0100516:	b8 20 00 00 00       	mov    $0x20,%eax
f010051b:	e8 bb fe ff ff       	call   f01003db <cons_putc>
f0100520:	eb 1e                	jmp    f0100540 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100522:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f0100529:	8d 50 01             	lea    0x1(%eax),%edx
f010052c:	66 89 15 28 22 21 f0 	mov    %dx,0xf0212228
f0100533:	0f b7 c0             	movzwl %ax,%eax
f0100536:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f010053c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100540:	66 81 3d 28 22 21 f0 	cmpw   $0x7cf,0xf0212228
f0100547:	cf 07 
f0100549:	76 43                	jbe    f010058e <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054b:	a1 2c 22 21 f0       	mov    0xf021222c,%eax
f0100550:	83 ec 04             	sub    $0x4,%esp
f0100553:	68 00 0f 00 00       	push   $0xf00
f0100558:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010055e:	52                   	push   %edx
f010055f:	50                   	push   %eax
f0100560:	e8 e7 50 00 00       	call   f010564c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100565:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f010056b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100571:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100577:	83 c4 10             	add    $0x10,%esp
f010057a:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010057f:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100582:	39 d0                	cmp    %edx,%eax
f0100584:	75 f4                	jne    f010057a <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100586:	66 83 2d 28 22 21 f0 	subw   $0x50,0xf0212228
f010058d:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010058e:	8b 0d 30 22 21 f0    	mov    0xf0212230,%ecx
f0100594:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100599:	89 ca                	mov    %ecx,%edx
f010059b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059c:	0f b7 1d 28 22 21 f0 	movzwl 0xf0212228,%ebx
f01005a3:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a6:	89 d8                	mov    %ebx,%eax
f01005a8:	66 c1 e8 08          	shr    $0x8,%ax
f01005ac:	89 f2                	mov    %esi,%edx
f01005ae:	ee                   	out    %al,(%dx)
f01005af:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b4:	89 ca                	mov    %ecx,%edx
f01005b6:	ee                   	out    %al,(%dx)
f01005b7:	89 d8                	mov    %ebx,%eax
f01005b9:	89 f2                	mov    %esi,%edx
f01005bb:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005bf:	5b                   	pop    %ebx
f01005c0:	5e                   	pop    %esi
f01005c1:	5f                   	pop    %edi
f01005c2:	5d                   	pop    %ebp
f01005c3:	c3                   	ret    

f01005c4 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005c4:	80 3d 34 22 21 f0 00 	cmpb   $0x0,0xf0212234
f01005cb:	74 11                	je     f01005de <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005cd:	55                   	push   %ebp
f01005ce:	89 e5                	mov    %esp,%ebp
f01005d0:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005d3:	b8 60 02 10 f0       	mov    $0xf0100260,%eax
f01005d8:	e8 a2 fc ff ff       	call   f010027f <cons_intr>
}
f01005dd:	c9                   	leave  
f01005de:	f3 c3                	repz ret 

f01005e0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e0:	55                   	push   %ebp
f01005e1:	89 e5                	mov    %esp,%ebp
f01005e3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e6:	b8 c2 02 10 f0       	mov    $0xf01002c2,%eax
f01005eb:	e8 8f fc ff ff       	call   f010027f <cons_intr>
}
f01005f0:	c9                   	leave  
f01005f1:	c3                   	ret    

f01005f2 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f2:	55                   	push   %ebp
f01005f3:	89 e5                	mov    %esp,%ebp
f01005f5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005f8:	e8 c7 ff ff ff       	call   f01005c4 <serial_intr>
	kbd_intr();
f01005fd:	e8 de ff ff ff       	call   f01005e0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100602:	a1 20 22 21 f0       	mov    0xf0212220,%eax
f0100607:	3b 05 24 22 21 f0    	cmp    0xf0212224,%eax
f010060d:	74 26                	je     f0100635 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010060f:	8d 50 01             	lea    0x1(%eax),%edx
f0100612:	89 15 20 22 21 f0    	mov    %edx,0xf0212220
f0100618:	0f b6 88 20 20 21 f0 	movzbl -0xfdedfe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010061f:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100621:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100627:	75 11                	jne    f010063a <cons_getc+0x48>
			cons.rpos = 0;
f0100629:	c7 05 20 22 21 f0 00 	movl   $0x0,0xf0212220
f0100630:	00 00 00 
f0100633:	eb 05                	jmp    f010063a <cons_getc+0x48>
		return c;
	}
	return 0;
f0100635:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010063a:	c9                   	leave  
f010063b:	c3                   	ret    

f010063c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010063c:	55                   	push   %ebp
f010063d:	89 e5                	mov    %esp,%ebp
f010063f:	57                   	push   %edi
f0100640:	56                   	push   %esi
f0100641:	53                   	push   %ebx
f0100642:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100645:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100653:	5a a5 
	if (*cp != 0xA55A) {
f0100655:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100660:	74 11                	je     f0100673 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100662:	c7 05 30 22 21 f0 b4 	movl   $0x3b4,0xf0212230
f0100669:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100671:	eb 16                	jmp    f0100689 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100673:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010067a:	c7 05 30 22 21 f0 d4 	movl   $0x3d4,0xf0212230
f0100681:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100684:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100689:	8b 3d 30 22 21 f0    	mov    0xf0212230,%edi
f010068f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100694:	89 fa                	mov    %edi,%edx
f0100696:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100697:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069a:	89 da                	mov    %ebx,%edx
f010069c:	ec                   	in     (%dx),%al
f010069d:	0f b6 c8             	movzbl %al,%ecx
f01006a0:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ab:	89 da                	mov    %ebx,%edx
f01006ad:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006ae:	89 35 2c 22 21 f0    	mov    %esi,0xf021222c
	crt_pos = pos;
f01006b4:	0f b6 c0             	movzbl %al,%eax
f01006b7:	09 c8                	or     %ecx,%eax
f01006b9:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006bf:	e8 1c ff ff ff       	call   f01005e0 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c4:	83 ec 0c             	sub    $0xc,%esp
f01006c7:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006ce:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 fa 2f 00 00       	call   f01036d3 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d9:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006de:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e3:	89 f2                	mov    %esi,%edx
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006eb:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f0:	ee                   	out    %al,(%dx)
f01006f1:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f6:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fb:	89 da                	mov    %ebx,%edx
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100703:	b8 00 00 00 00       	mov    $0x0,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010070e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100713:	ee                   	out    %al,(%dx)
f0100714:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100719:	b8 00 00 00 00       	mov    $0x0,%eax
f010071e:	ee                   	out    %al,(%dx)
f010071f:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100724:	b8 01 00 00 00       	mov    $0x1,%eax
f0100729:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010072f:	ec                   	in     (%dx),%al
f0100730:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100732:	83 c4 10             	add    $0x10,%esp
f0100735:	3c ff                	cmp    $0xff,%al
f0100737:	0f 95 05 34 22 21 f0 	setne  0xf0212234
f010073e:	89 f2                	mov    %esi,%edx
f0100740:	ec                   	in     (%dx),%al
f0100741:	89 da                	mov    %ebx,%edx
f0100743:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100744:	80 f9 ff             	cmp    $0xff,%cl
f0100747:	74 21                	je     f010076a <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100749:	83 ec 0c             	sub    $0xc,%esp
f010074c:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0100753:	25 ef ff 00 00       	and    $0xffef,%eax
f0100758:	50                   	push   %eax
f0100759:	e8 75 2f 00 00       	call   f01036d3 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010075e:	83 c4 10             	add    $0x10,%esp
f0100761:	80 3d 34 22 21 f0 00 	cmpb   $0x0,0xf0212234
f0100768:	75 10                	jne    f010077a <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010076a:	83 ec 0c             	sub    $0xc,%esp
f010076d:	68 8f 63 10 f0       	push   $0xf010638f
f0100772:	e8 ad 30 00 00       	call   f0103824 <cprintf>
f0100777:	83 c4 10             	add    $0x10,%esp
}
f010077a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010077d:	5b                   	pop    %ebx
f010077e:	5e                   	pop    %esi
f010077f:	5f                   	pop    %edi
f0100780:	5d                   	pop    %ebp
f0100781:	c3                   	ret    

f0100782 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100782:	55                   	push   %ebp
f0100783:	89 e5                	mov    %esp,%ebp
f0100785:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100788:	8b 45 08             	mov    0x8(%ebp),%eax
f010078b:	e8 4b fc ff ff       	call   f01003db <cons_putc>
}
f0100790:	c9                   	leave  
f0100791:	c3                   	ret    

f0100792 <getchar>:

int
getchar(void)
{
f0100792:	55                   	push   %ebp
f0100793:	89 e5                	mov    %esp,%ebp
f0100795:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100798:	e8 55 fe ff ff       	call   f01005f2 <cons_getc>
f010079d:	85 c0                	test   %eax,%eax
f010079f:	74 f7                	je     f0100798 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a1:	c9                   	leave  
f01007a2:	c3                   	ret    

f01007a3 <iscons>:

int
iscons(int fdnum)
{
f01007a3:	55                   	push   %ebp
f01007a4:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ab:	5d                   	pop    %ebp
f01007ac:	c3                   	ret    

f01007ad <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

	   int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007ad:	55                   	push   %ebp
f01007ae:	89 e5                	mov    %esp,%ebp
f01007b0:	83 ec 0c             	sub    $0xc,%esp
	   int i;

	   for (i = 0; i < ARRAY_SIZE(commands); i++)
			 cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b3:	68 e0 65 10 f0       	push   $0xf01065e0
f01007b8:	68 fe 65 10 f0       	push   $0xf01065fe
f01007bd:	68 03 66 10 f0       	push   $0xf0106603
f01007c2:	e8 5d 30 00 00       	call   f0103824 <cprintf>
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	68 d0 66 10 f0       	push   $0xf01066d0
f01007cf:	68 0c 66 10 f0       	push   $0xf010660c
f01007d4:	68 03 66 10 f0       	push   $0xf0106603
f01007d9:	e8 46 30 00 00       	call   f0103824 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	68 15 66 10 f0       	push   $0xf0106615
f01007e6:	68 2d 66 10 f0       	push   $0xf010662d
f01007eb:	68 03 66 10 f0       	push   $0xf0106603
f01007f0:	e8 2f 30 00 00       	call   f0103824 <cprintf>
	   return 0;
}
f01007f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fa:	c9                   	leave  
f01007fb:	c3                   	ret    

f01007fc <mon_kerninfo>:

	   int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007fc:	55                   	push   %ebp
f01007fd:	89 e5                	mov    %esp,%ebp
f01007ff:	83 ec 14             	sub    $0x14,%esp
	   extern char _start[], entry[], etext[], edata[], end[];

	   cprintf("Special kernel symbols:\n");
f0100802:	68 37 66 10 f0       	push   $0xf0106637
f0100807:	e8 18 30 00 00       	call   f0103824 <cprintf>
	   cprintf("  _start                  %08x (phys)\n", _start);
f010080c:	83 c4 08             	add    $0x8,%esp
f010080f:	68 0c 00 10 00       	push   $0x10000c
f0100814:	68 f8 66 10 f0       	push   $0xf01066f8
f0100819:	e8 06 30 00 00       	call   f0103824 <cprintf>
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010081e:	83 c4 0c             	add    $0xc,%esp
f0100821:	68 0c 00 10 00       	push   $0x10000c
f0100826:	68 0c 00 10 f0       	push   $0xf010000c
f010082b:	68 20 67 10 f0       	push   $0xf0106720
f0100830:	e8 ef 2f 00 00       	call   f0103824 <cprintf>
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	68 a1 62 10 00       	push   $0x1062a1
f010083d:	68 a1 62 10 f0       	push   $0xf01062a1
f0100842:	68 44 67 10 f0       	push   $0xf0106744
f0100847:	e8 d8 2f 00 00       	call   f0103824 <cprintf>
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084c:	83 c4 0c             	add    $0xc,%esp
f010084f:	68 00 20 21 00       	push   $0x212000
f0100854:	68 00 20 21 f0       	push   $0xf0212000
f0100859:	68 68 67 10 f0       	push   $0xf0106768
f010085e:	e8 c1 2f 00 00       	call   f0103824 <cprintf>
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100863:	83 c4 0c             	add    $0xc,%esp
f0100866:	68 08 40 25 00       	push   $0x254008
f010086b:	68 08 40 25 f0       	push   $0xf0254008
f0100870:	68 8c 67 10 f0       	push   $0xf010678c
f0100875:	e8 aa 2f 00 00       	call   f0103824 <cprintf>
	   cprintf("Kernel executable memory footprint: %dKB\n",
				    ROUNDUP(end - entry, 1024) / 1024);
f010087a:	b8 07 44 25 f0       	mov    $0xf0254407,%eax
f010087f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	   cprintf("  _start                  %08x (phys)\n", _start);
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	   cprintf("Kernel executable memory footprint: %dKB\n",
f0100884:	83 c4 08             	add    $0x8,%esp
f0100887:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010088c:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100892:	85 c0                	test   %eax,%eax
f0100894:	0f 48 c2             	cmovs  %edx,%eax
f0100897:	c1 f8 0a             	sar    $0xa,%eax
f010089a:	50                   	push   %eax
f010089b:	68 b0 67 10 f0       	push   $0xf01067b0
f01008a0:	e8 7f 2f 00 00       	call   f0103824 <cprintf>
				    ROUNDUP(end - entry, 1024) / 1024);
	   return 0;
}
f01008a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008aa:	c9                   	leave  
f01008ab:	c3                   	ret    

f01008ac <mon_backtrace>:
	   int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008ac:	55                   	push   %ebp
f01008ad:	89 e5                	mov    %esp,%ebp
f01008af:	57                   	push   %edi
f01008b0:	56                   	push   %esi
f01008b1:	53                   	push   %ebx
f01008b2:	83 ec 48             	sub    $0x48,%esp
	   // Your code here.

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
f01008b5:	89 ee                	mov    %ebp,%esi
	   cprintf("Stack Backtrace: \n");
f01008b7:	68 50 66 10 f0       	push   $0xf0106650
f01008bc:	e8 63 2f 00 00       	call   f0103824 <cprintf>
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f01008c1:	83 c4 10             	add    $0x10,%esp
f01008c4:	e9 80 00 00 00       	jmp    f0100949 <mon_backtrace+0x9d>
	   {
			 ueip = *((uint32_t *)baseframe + 1);
f01008c9:	8b 46 04             	mov    0x4(%esi),%eax
f01008cc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
f01008cf:	83 ec 04             	sub    $0x4,%esp
f01008d2:	50                   	push   %eax
f01008d3:	56                   	push   %esi
f01008d4:	68 63 66 10 f0       	push   $0xf0106663
f01008d9:	e8 46 2f 00 00       	call   f0103824 <cprintf>
f01008de:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008e1:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01008e4:	83 c4 10             	add    $0x10,%esp
			 for (int i = 2; i < 7; i ++)
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
f01008e7:	83 ec 08             	sub    $0x8,%esp
f01008ea:	ff 33                	pushl  (%ebx)
f01008ec:	68 7b 66 10 f0       	push   $0xf010667b
f01008f1:	e8 2e 2f 00 00       	call   f0103824 <cprintf>
f01008f6:	83 c3 04             	add    $0x4,%ebx
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
	   {
			 ueip = *((uint32_t *)baseframe + 1);
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
			 for (int i = 2; i < 7; i ++)
f01008f9:	83 c4 10             	add    $0x10,%esp
f01008fc:	39 fb                	cmp    %edi,%ebx
f01008fe:	75 e7                	jne    f01008e7 <mon_backtrace+0x3b>
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
			 }

			 cprintf("\n");
f0100900:	83 ec 0c             	sub    $0xc,%esp
f0100903:	68 61 66 10 f0       	push   $0xf0106661
f0100908:	e8 17 2f 00 00       	call   f0103824 <cprintf>
			 struct Eipdebuginfo information;
			 debuginfo_eip (ueip, &information);
f010090d:	83 c4 08             	add    $0x8,%esp
f0100910:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100913:	50                   	push   %eax
f0100914:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100917:	53                   	push   %ebx
f0100918:	e8 c9 42 00 00       	call   f0104be6 <debuginfo_eip>
			 uintptr_t offset = ueip - information.eip_fn_addr;
f010091d:	2b 5d e0             	sub    -0x20(%ebp),%ebx
			 cprintf("\t%s:%d: ", information.eip_file, information.eip_line);
f0100920:	83 c4 0c             	add    $0xc,%esp
f0100923:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100926:	ff 75 d0             	pushl  -0x30(%ebp)
f0100929:	68 82 66 10 f0       	push   $0xf0106682
f010092e:	e8 f1 2e 00 00       	call   f0103824 <cprintf>
			 cprintf("%.*s+%d\n",information.eip_fn_namelen, information.eip_fn_name, offset);
f0100933:	53                   	push   %ebx
f0100934:	ff 75 d8             	pushl  -0x28(%ebp)
f0100937:	ff 75 dc             	pushl  -0x24(%ebp)
f010093a:	68 8b 66 10 f0       	push   $0xf010668b
f010093f:	e8 e0 2e 00 00       	call   f0103824 <cprintf>

			 baseframe = *(uint32_t *) baseframe;
f0100944:	8b 36                	mov    (%esi),%esi
f0100946:	83 c4 20             	add    $0x20,%esp

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
	   cprintf("Stack Backtrace: \n");
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f0100949:	85 f6                	test   %esi,%esi
f010094b:	0f 85 78 ff ff ff    	jne    f01008c9 <mon_backtrace+0x1d>


	   }

	   return 0;
}
f0100951:	b8 00 00 00 00       	mov    $0x0,%eax
f0100956:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100959:	5b                   	pop    %ebx
f010095a:	5e                   	pop    %esi
f010095b:	5f                   	pop    %edi
f010095c:	5d                   	pop    %ebp
f010095d:	c3                   	ret    

f010095e <monitor>:
	   return 0;
}

	   void
monitor(struct Trapframe *tf)
{
f010095e:	55                   	push   %ebp
f010095f:	89 e5                	mov    %esp,%ebp
f0100961:	57                   	push   %edi
f0100962:	56                   	push   %esi
f0100963:	53                   	push   %ebx
f0100964:	83 ec 58             	sub    $0x58,%esp
	   char *buf;

	   cprintf("Welcome to the JOS kernel monitor!\n");
f0100967:	68 dc 67 10 f0       	push   $0xf01067dc
f010096c:	e8 b3 2e 00 00       	call   f0103824 <cprintf>
	   cprintf("Type 'help' for a list of commands.\n");
f0100971:	c7 04 24 00 68 10 f0 	movl   $0xf0106800,(%esp)
f0100978:	e8 a7 2e 00 00       	call   f0103824 <cprintf>

	if (tf != NULL)
f010097d:	83 c4 10             	add    $0x10,%esp
f0100980:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100984:	74 0e                	je     f0100994 <monitor+0x36>
		print_trapframe(tf);
f0100986:	83 ec 0c             	sub    $0xc,%esp
f0100989:	ff 75 08             	pushl  0x8(%ebp)
f010098c:	e8 02 34 00 00       	call   f0103d93 <print_trapframe>
f0100991:	83 c4 10             	add    $0x10,%esp

	   while (1) {
			 buf = readline("K> ");
f0100994:	83 ec 0c             	sub    $0xc,%esp
f0100997:	68 94 66 10 f0       	push   $0xf0106694
f010099c:	e8 ef 49 00 00       	call   f0105390 <readline>
f01009a1:	89 c3                	mov    %eax,%ebx
			 if (buf != NULL)
f01009a3:	83 c4 10             	add    $0x10,%esp
f01009a6:	85 c0                	test   %eax,%eax
f01009a8:	74 ea                	je     f0100994 <monitor+0x36>
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
f01009aa:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	   int argc;
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
f01009b1:	be 00 00 00 00       	mov    $0x0,%esi
f01009b6:	eb 0a                	jmp    f01009c2 <monitor+0x64>
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
				    *buf++ = 0;
f01009b8:	c6 03 00             	movb   $0x0,(%ebx)
f01009bb:	89 f7                	mov    %esi,%edi
f01009bd:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c0:	89 fe                	mov    %edi,%esi
	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
f01009c2:	0f b6 03             	movzbl (%ebx),%eax
f01009c5:	84 c0                	test   %al,%al
f01009c7:	74 63                	je     f0100a2c <monitor+0xce>
f01009c9:	83 ec 08             	sub    $0x8,%esp
f01009cc:	0f be c0             	movsbl %al,%eax
f01009cf:	50                   	push   %eax
f01009d0:	68 98 66 10 f0       	push   $0xf0106698
f01009d5:	e8 e8 4b 00 00       	call   f01055c2 <strchr>
f01009da:	83 c4 10             	add    $0x10,%esp
f01009dd:	85 c0                	test   %eax,%eax
f01009df:	75 d7                	jne    f01009b8 <monitor+0x5a>
				    *buf++ = 0;
			 if (*buf == 0)
f01009e1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009e4:	74 46                	je     f0100a2c <monitor+0xce>
				    break;

			 // save and scan past next arg
			 if (argc == MAXARGS-1) {
f01009e6:	83 fe 0f             	cmp    $0xf,%esi
f01009e9:	75 14                	jne    f01009ff <monitor+0xa1>
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009eb:	83 ec 08             	sub    $0x8,%esp
f01009ee:	6a 10                	push   $0x10
f01009f0:	68 9d 66 10 f0       	push   $0xf010669d
f01009f5:	e8 2a 2e 00 00       	call   f0103824 <cprintf>
f01009fa:	83 c4 10             	add    $0x10,%esp
f01009fd:	eb 95                	jmp    f0100994 <monitor+0x36>
				    return 0;
			 }
			 argv[argc++] = buf;
f01009ff:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a02:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a06:	eb 03                	jmp    f0100a0b <monitor+0xad>
			 while (*buf && !strchr(WHITESPACE, *buf))
				    buf++;
f0100a08:	83 c3 01             	add    $0x1,%ebx
			 if (argc == MAXARGS-1) {
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
				    return 0;
			 }
			 argv[argc++] = buf;
			 while (*buf && !strchr(WHITESPACE, *buf))
f0100a0b:	0f b6 03             	movzbl (%ebx),%eax
f0100a0e:	84 c0                	test   %al,%al
f0100a10:	74 ae                	je     f01009c0 <monitor+0x62>
f0100a12:	83 ec 08             	sub    $0x8,%esp
f0100a15:	0f be c0             	movsbl %al,%eax
f0100a18:	50                   	push   %eax
f0100a19:	68 98 66 10 f0       	push   $0xf0106698
f0100a1e:	e8 9f 4b 00 00       	call   f01055c2 <strchr>
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	74 de                	je     f0100a08 <monitor+0xaa>
f0100a2a:	eb 94                	jmp    f01009c0 <monitor+0x62>
				    buf++;
	   }
	   argv[argc] = 0;
f0100a2c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a33:	00 

	   // Lookup and invoke the command
	   if (argc == 0)
f0100a34:	85 f6                	test   %esi,%esi
f0100a36:	0f 84 58 ff ff ff    	je     f0100994 <monitor+0x36>
f0100a3c:	bb 00 00 00 00       	mov    $0x0,%ebx
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
			 if (strcmp(argv[0], commands[i].name) == 0)
f0100a41:	83 ec 08             	sub    $0x8,%esp
f0100a44:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a47:	ff 34 85 40 68 10 f0 	pushl  -0xfef97c0(,%eax,4)
f0100a4e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a51:	e8 0e 4b 00 00       	call   f0105564 <strcmp>
f0100a56:	83 c4 10             	add    $0x10,%esp
f0100a59:	85 c0                	test   %eax,%eax
f0100a5b:	75 21                	jne    f0100a7e <monitor+0x120>
				    return commands[i].func(argc, argv, tf);
f0100a5d:	83 ec 04             	sub    $0x4,%esp
f0100a60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a63:	ff 75 08             	pushl  0x8(%ebp)
f0100a66:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a69:	52                   	push   %edx
f0100a6a:	56                   	push   %esi
f0100a6b:	ff 14 85 48 68 10 f0 	call   *-0xfef97b8(,%eax,4)
		print_trapframe(tf);

	   while (1) {
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
f0100a72:	83 c4 10             	add    $0x10,%esp
f0100a75:	85 c0                	test   %eax,%eax
f0100a77:	78 25                	js     f0100a9e <monitor+0x140>
f0100a79:	e9 16 ff ff ff       	jmp    f0100994 <monitor+0x36>
	   argv[argc] = 0;

	   // Lookup and invoke the command
	   if (argc == 0)
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a7e:	83 c3 01             	add    $0x1,%ebx
f0100a81:	83 fb 03             	cmp    $0x3,%ebx
f0100a84:	75 bb                	jne    f0100a41 <monitor+0xe3>
			 if (strcmp(argv[0], commands[i].name) == 0)
				    return commands[i].func(argc, argv, tf);
	   }
	   cprintf("Unknown command '%s'\n", argv[0]);
f0100a86:	83 ec 08             	sub    $0x8,%esp
f0100a89:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a8c:	68 ba 66 10 f0       	push   $0xf01066ba
f0100a91:	e8 8e 2d 00 00       	call   f0103824 <cprintf>
f0100a96:	83 c4 10             	add    $0x10,%esp
f0100a99:	e9 f6 fe ff ff       	jmp    f0100994 <monitor+0x36>
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
						  break;
	   }
}
f0100a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa1:	5b                   	pop    %ebx
f0100aa2:	5e                   	pop    %esi
f0100aa3:	5f                   	pop    %edi
f0100aa4:	5d                   	pop    %ebp
f0100aa5:	c3                   	ret    

f0100aa6 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

	   static int
nvram_read(int r)
{
f0100aa6:	55                   	push   %ebp
f0100aa7:	89 e5                	mov    %esp,%ebp
f0100aa9:	56                   	push   %esi
f0100aaa:	53                   	push   %ebx
f0100aab:	89 c3                	mov    %eax,%ebx
	   return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aad:	83 ec 0c             	sub    $0xc,%esp
f0100ab0:	50                   	push   %eax
f0100ab1:	e8 ef 2b 00 00       	call   f01036a5 <mc146818_read>
f0100ab6:	89 c6                	mov    %eax,%esi
f0100ab8:	83 c3 01             	add    $0x1,%ebx
f0100abb:	89 1c 24             	mov    %ebx,(%esp)
f0100abe:	e8 e2 2b 00 00       	call   f01036a5 <mc146818_read>
f0100ac3:	c1 e0 08             	shl    $0x8,%eax
f0100ac6:	09 f0                	or     %esi,%eax
}
f0100ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100acb:	5b                   	pop    %ebx
f0100acc:	5e                   	pop    %esi
f0100acd:	5d                   	pop    %ebp
f0100ace:	c3                   	ret    

f0100acf <boot_alloc>:
	   // Initialize nextfree if this is the first time.
	   // 'end' is a magic symbol automatically generated by the linker,
	   // which points to the end of the kernel's bss segment:
	   // the first virtual address that the linker did *not* assign
	   // to any kernel code or global variables.
	   if (!nextfree) {
f0100acf:	83 3d 38 22 21 f0 00 	cmpl   $0x0,0xf0212238
f0100ad6:	75 11                	jne    f0100ae9 <boot_alloc+0x1a>
			 extern char end[];
			 nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ad8:	ba 07 50 25 f0       	mov    $0xf0255007,%edx
f0100add:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ae3:	89 15 38 22 21 f0    	mov    %edx,0xf0212238
	   }

	   result = nextfree;
f0100ae9:	8b 0d 38 22 21 f0    	mov    0xf0212238,%ecx
	   // nextfree.  Make sure nextfree is kept aligned
	   // to a multiple of PGSIZE.
	   //
	   // LAB 2: Your code here.

	   nextfree = ROUNDUP ( result + n, PGSIZE);
f0100aef:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100af6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100afc:	89 15 38 22 21 f0    	mov    %edx,0xf0212238
	   if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
f0100b02:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f0100b08:	76 25                	jbe    f0100b2f <boot_alloc+0x60>

// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100b0a:	55                   	push   %ebp
f0100b0b:	89 e5                	mov    %esp,%ebp
f0100b0d:	53                   	push   %ebx
f0100b0e:	83 ec 10             	sub    $0x10,%esp
f0100b11:	89 c3                	mov    %eax,%ebx
	   // LAB 2: Your code here.

	   nextfree = ROUNDUP ( result + n, PGSIZE);
	   if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
	   {
			 cprintf("OUT OF MEMORY");
f0100b13:	68 64 68 10 f0       	push   $0xf0106864
f0100b18:	e8 07 2d 00 00       	call   f0103824 <cprintf>
			 panic ("boot alloc Failed to allocate %d bytes", n);
f0100b1d:	53                   	push   %ebx
f0100b1e:	68 e0 6b 10 f0       	push   $0xf0106be0
f0100b23:	6a 76                	push   $0x76
f0100b25:	68 72 68 10 f0       	push   $0xf0106872
f0100b2a:	e8 11 f5 ff ff       	call   f0100040 <_panic>
	   }

	   return result;
}
f0100b2f:	89 c8                	mov    %ecx,%eax
f0100b31:	c3                   	ret    

f0100b32 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	   pte_t *p;

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
f0100b32:	89 d1                	mov    %edx,%ecx
f0100b34:	c1 e9 16             	shr    $0x16,%ecx
f0100b37:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b3a:	a8 01                	test   $0x1,%al
f0100b3c:	74 52                	je     f0100b90 <check_va2pa+0x5e>
			 return ~0;
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b43:	89 c1                	mov    %eax,%ecx
f0100b45:	c1 e9 0c             	shr    $0xc,%ecx
f0100b48:	3b 0d 88 2e 21 f0    	cmp    0xf0212e88,%ecx
f0100b4e:	72 1b                	jb     f0100b6b <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

	   static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b50:	55                   	push   %ebp
f0100b51:	89 e5                	mov    %esp,%ebp
f0100b53:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b56:	50                   	push   %eax
f0100b57:	68 e4 62 10 f0       	push   $0xf01062e4
f0100b5c:	68 b2 03 00 00       	push   $0x3b2
f0100b61:	68 72 68 10 f0       	push   $0xf0106872
f0100b66:	e8 d5 f4 ff ff       	call   f0100040 <_panic>

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
			 return ~0;
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	   if (!(p[PTX(va)] & PTE_P))
f0100b6b:	c1 ea 0c             	shr    $0xc,%edx
f0100b6e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b74:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b7b:	89 c2                	mov    %eax,%edx
f0100b7d:	83 e2 01             	and    $0x1,%edx
			 return ~0;
	   return PTE_ADDR(p[PTX(va)]);
f0100b80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b85:	85 d2                	test   %edx,%edx
f0100b87:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b8c:	0f 44 c2             	cmove  %edx,%eax
f0100b8f:	c3                   	ret    
{
	   pte_t *p;

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
			 return ~0;
f0100b90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	   if (!(p[PTX(va)] & PTE_P))
			 return ~0;
	   return PTE_ADDR(p[PTX(va)]);
}
f0100b95:	c3                   	ret    

f0100b96 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
	   static void
check_page_free_list(bool only_low_memory)
{
f0100b96:	55                   	push   %ebp
f0100b97:	89 e5                	mov    %esp,%ebp
f0100b99:	57                   	push   %edi
f0100b9a:	56                   	push   %esi
f0100b9b:	53                   	push   %ebx
f0100b9c:	83 ec 2c             	sub    $0x2c,%esp

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b9f:	84 c0                	test   %al,%al
f0100ba1:	0f 85 a0 02 00 00    	jne    f0100e47 <check_page_free_list+0x2b1>
f0100ba7:	e9 ad 02 00 00       	jmp    f0100e59 <check_page_free_list+0x2c3>
	   int nfree_basemem = 0, nfree_extmem = 0;
	   char *first_free_page;

	   if (!page_free_list)
			 panic("'page_free_list' is a null pointer!");
f0100bac:	83 ec 04             	sub    $0x4,%esp
f0100baf:	68 08 6c 10 f0       	push   $0xf0106c08
f0100bb4:	68 e4 02 00 00       	push   $0x2e4
f0100bb9:	68 72 68 10 f0       	push   $0xf0106872
f0100bbe:	e8 7d f4 ff ff       	call   f0100040 <_panic>

	   if (only_low_memory) {
			 // Move pages with lower addresses first in the free
			 // list, since entry_pgdir does not map all pages.
			 struct PageInfo *pp1, *pp2;
			 struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bc3:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bc6:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bc9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bcc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			 for (pp = page_free_list; pp; pp = pp->pp_link) {
				    int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bcf:	89 c2                	mov    %eax,%edx
f0100bd1:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0100bd7:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bdd:	0f 95 c2             	setne  %dl
f0100be0:	0f b6 d2             	movzbl %dl,%edx
				    *tp[pagetype] = pp;
f0100be3:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100be7:	89 01                	mov    %eax,(%ecx)
				    tp[pagetype] = &pp->pp_link;
f0100be9:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	   if (only_low_memory) {
			 // Move pages with lower addresses first in the free
			 // list, since entry_pgdir does not map all pages.
			 struct PageInfo *pp1, *pp2;
			 struct PageInfo **tp[2] = { &pp1, &pp2 };
			 for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bed:	8b 00                	mov    (%eax),%eax
f0100bef:	85 c0                	test   %eax,%eax
f0100bf1:	75 dc                	jne    f0100bcf <check_page_free_list+0x39>
				    int pagetype = PDX(page2pa(pp)) >= pdx_limit;
				    *tp[pagetype] = pp;
				    tp[pagetype] = &pp->pp_link;
			 }
			 *tp[1] = 0;
f0100bf3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			 *tp[0] = pp2;
f0100bfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bff:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c02:	89 10                	mov    %edx,(%eax)
			 page_free_list = pp1;
f0100c04:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c07:	a3 40 22 21 f0       	mov    %eax,0xf0212240
	   static void
check_page_free_list(bool only_low_memory)
{

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c0c:	be 01 00 00 00       	mov    $0x1,%esi
			 page_free_list = pp1;
	   }

	   // if there's a page that shouldn't be on the free list,
	   // try to make sure it eventually causes trouble.
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c11:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
f0100c17:	eb 53                	jmp    f0100c6c <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c19:	89 d8                	mov    %ebx,%eax
f0100c1b:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0100c21:	c1 f8 03             	sar    $0x3,%eax
f0100c24:	c1 e0 0c             	shl    $0xc,%eax
			 if (PDX(page2pa(pp)) < pdx_limit)
f0100c27:	89 c2                	mov    %eax,%edx
f0100c29:	c1 ea 16             	shr    $0x16,%edx
f0100c2c:	39 f2                	cmp    %esi,%edx
f0100c2e:	73 3a                	jae    f0100c6a <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c30:	89 c2                	mov    %eax,%edx
f0100c32:	c1 ea 0c             	shr    $0xc,%edx
f0100c35:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0100c3b:	72 12                	jb     f0100c4f <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c3d:	50                   	push   %eax
f0100c3e:	68 e4 62 10 f0       	push   $0xf01062e4
f0100c43:	6a 58                	push   $0x58
f0100c45:	68 7e 68 10 f0       	push   $0xf010687e
f0100c4a:	e8 f1 f3 ff ff       	call   f0100040 <_panic>
				    memset(page2kva(pp), 0x97, 128);
f0100c4f:	83 ec 04             	sub    $0x4,%esp
f0100c52:	68 80 00 00 00       	push   $0x80
f0100c57:	68 97 00 00 00       	push   $0x97
f0100c5c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c61:	50                   	push   %eax
f0100c62:	e8 98 49 00 00       	call   f01055ff <memset>
f0100c67:	83 c4 10             	add    $0x10,%esp
			 page_free_list = pp1;
	   }

	   // if there's a page that shouldn't be on the free list,
	   // try to make sure it eventually causes trouble.
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c6a:	8b 1b                	mov    (%ebx),%ebx
f0100c6c:	85 db                	test   %ebx,%ebx
f0100c6e:	75 a9                	jne    f0100c19 <check_page_free_list+0x83>
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
f0100c70:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c75:	e8 55 fe ff ff       	call   f0100acf <boot_alloc>
f0100c7a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c7d:	8b 15 40 22 21 f0    	mov    0xf0212240,%edx
			 // check that we didn't corrupt the free list itself
			 assert(pp >= pages);
f0100c83:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
			 assert(pp < pages + npages);
f0100c89:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f0100c8e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c91:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			 assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c97:	89 4d d0             	mov    %ecx,-0x30(%ebp)
check_page_free_list(bool only_low_memory)
{

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	   int nfree_basemem = 0, nfree_extmem = 0;
f0100c9a:	be 00 00 00 00       	mov    $0x0,%esi
	   for (pp = page_free_list; pp; pp = pp->pp_link)
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9f:	e9 52 01 00 00       	jmp    f0100df6 <check_page_free_list+0x260>
			 // check that we didn't corrupt the free list itself
			 assert(pp >= pages);
f0100ca4:	39 ca                	cmp    %ecx,%edx
f0100ca6:	73 19                	jae    f0100cc1 <check_page_free_list+0x12b>
f0100ca8:	68 8c 68 10 f0       	push   $0xf010688c
f0100cad:	68 98 68 10 f0       	push   $0xf0106898
f0100cb2:	68 fe 02 00 00       	push   $0x2fe
f0100cb7:	68 72 68 10 f0       	push   $0xf0106872
f0100cbc:	e8 7f f3 ff ff       	call   f0100040 <_panic>
			 assert(pp < pages + npages);
f0100cc1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cc4:	72 19                	jb     f0100cdf <check_page_free_list+0x149>
f0100cc6:	68 ad 68 10 f0       	push   $0xf01068ad
f0100ccb:	68 98 68 10 f0       	push   $0xf0106898
f0100cd0:	68 ff 02 00 00       	push   $0x2ff
f0100cd5:	68 72 68 10 f0       	push   $0xf0106872
f0100cda:	e8 61 f3 ff ff       	call   f0100040 <_panic>
			 assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cdf:	89 d0                	mov    %edx,%eax
f0100ce1:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100ce4:	a8 07                	test   $0x7,%al
f0100ce6:	74 19                	je     f0100d01 <check_page_free_list+0x16b>
f0100ce8:	68 2c 6c 10 f0       	push   $0xf0106c2c
f0100ced:	68 98 68 10 f0       	push   $0xf0106898
f0100cf2:	68 00 03 00 00       	push   $0x300
f0100cf7:	68 72 68 10 f0       	push   $0xf0106872
f0100cfc:	e8 3f f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d01:	c1 f8 03             	sar    $0x3,%eax
f0100d04:	c1 e0 0c             	shl    $0xc,%eax

			 // check a few pages that shouldn't be on the free list
			 assert(page2pa(pp) != 0);
f0100d07:	85 c0                	test   %eax,%eax
f0100d09:	75 19                	jne    f0100d24 <check_page_free_list+0x18e>
f0100d0b:	68 c1 68 10 f0       	push   $0xf01068c1
f0100d10:	68 98 68 10 f0       	push   $0xf0106898
f0100d15:	68 03 03 00 00       	push   $0x303
f0100d1a:	68 72 68 10 f0       	push   $0xf0106872
f0100d1f:	e8 1c f3 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) != IOPHYSMEM);
f0100d24:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d29:	75 19                	jne    f0100d44 <check_page_free_list+0x1ae>
f0100d2b:	68 d2 68 10 f0       	push   $0xf01068d2
f0100d30:	68 98 68 10 f0       	push   $0xf0106898
f0100d35:	68 04 03 00 00       	push   $0x304
f0100d3a:	68 72 68 10 f0       	push   $0xf0106872
f0100d3f:	e8 fc f2 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d44:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d49:	75 19                	jne    f0100d64 <check_page_free_list+0x1ce>
f0100d4b:	68 60 6c 10 f0       	push   $0xf0106c60
f0100d50:	68 98 68 10 f0       	push   $0xf0106898
f0100d55:	68 05 03 00 00       	push   $0x305
f0100d5a:	68 72 68 10 f0       	push   $0xf0106872
f0100d5f:	e8 dc f2 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) != EXTPHYSMEM);
f0100d64:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d69:	75 19                	jne    f0100d84 <check_page_free_list+0x1ee>
f0100d6b:	68 eb 68 10 f0       	push   $0xf01068eb
f0100d70:	68 98 68 10 f0       	push   $0xf0106898
f0100d75:	68 06 03 00 00       	push   $0x306
f0100d7a:	68 72 68 10 f0       	push   $0xf0106872
f0100d7f:	e8 bc f2 ff ff       	call   f0100040 <_panic>
			 assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d84:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d89:	0f 86 f1 00 00 00    	jbe    f0100e80 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d8f:	89 c7                	mov    %eax,%edi
f0100d91:	c1 ef 0c             	shr    $0xc,%edi
f0100d94:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d97:	77 12                	ja     f0100dab <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d99:	50                   	push   %eax
f0100d9a:	68 e4 62 10 f0       	push   $0xf01062e4
f0100d9f:	6a 58                	push   $0x58
f0100da1:	68 7e 68 10 f0       	push   $0xf010687e
f0100da6:	e8 95 f2 ff ff       	call   f0100040 <_panic>
f0100dab:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100db1:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100db4:	0f 86 b6 00 00 00    	jbe    f0100e70 <check_page_free_list+0x2da>
f0100dba:	68 84 6c 10 f0       	push   $0xf0106c84
f0100dbf:	68 98 68 10 f0       	push   $0xf0106898
f0100dc4:	68 07 03 00 00       	push   $0x307
f0100dc9:	68 72 68 10 f0       	push   $0xf0106872
f0100dce:	e8 6d f2 ff ff       	call   f0100040 <_panic>
			 // (new test for lab 4)
			 assert(page2pa(pp) != MPENTRY_PADDR);
f0100dd3:	68 05 69 10 f0       	push   $0xf0106905
f0100dd8:	68 98 68 10 f0       	push   $0xf0106898
f0100ddd:	68 09 03 00 00       	push   $0x309
f0100de2:	68 72 68 10 f0       	push   $0xf0106872
f0100de7:	e8 54 f2 ff ff       	call   f0100040 <_panic>

			 if (page2pa(pp) < EXTPHYSMEM)
				    ++nfree_basemem;
f0100dec:	83 c6 01             	add    $0x1,%esi
f0100def:	eb 03                	jmp    f0100df4 <check_page_free_list+0x25e>
			 else
				    ++nfree_extmem;
f0100df1:	83 c3 01             	add    $0x1,%ebx
	   for (pp = page_free_list; pp; pp = pp->pp_link)
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100df4:	8b 12                	mov    (%edx),%edx
f0100df6:	85 d2                	test   %edx,%edx
f0100df8:	0f 85 a6 fe ff ff    	jne    f0100ca4 <check_page_free_list+0x10e>
				    ++nfree_basemem;
			 else
				    ++nfree_extmem;
	   }

	   assert(nfree_basemem > 0);
f0100dfe:	85 f6                	test   %esi,%esi
f0100e00:	7f 19                	jg     f0100e1b <check_page_free_list+0x285>
f0100e02:	68 22 69 10 f0       	push   $0xf0106922
f0100e07:	68 98 68 10 f0       	push   $0xf0106898
f0100e0c:	68 11 03 00 00       	push   $0x311
f0100e11:	68 72 68 10 f0       	push   $0xf0106872
f0100e16:	e8 25 f2 ff ff       	call   f0100040 <_panic>
	   assert(nfree_extmem > 0);
f0100e1b:	85 db                	test   %ebx,%ebx
f0100e1d:	7f 19                	jg     f0100e38 <check_page_free_list+0x2a2>
f0100e1f:	68 34 69 10 f0       	push   $0xf0106934
f0100e24:	68 98 68 10 f0       	push   $0xf0106898
f0100e29:	68 12 03 00 00       	push   $0x312
f0100e2e:	68 72 68 10 f0       	push   $0xf0106872
f0100e33:	e8 08 f2 ff ff       	call   f0100040 <_panic>

	   cprintf("check_page_free_list() succeeded!\n");
f0100e38:	83 ec 0c             	sub    $0xc,%esp
f0100e3b:	68 cc 6c 10 f0       	push   $0xf0106ccc
f0100e40:	e8 df 29 00 00       	call   f0103824 <cprintf>
}
f0100e45:	eb 49                	jmp    f0100e90 <check_page_free_list+0x2fa>
	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	   int nfree_basemem = 0, nfree_extmem = 0;
	   char *first_free_page;

	   if (!page_free_list)
f0100e47:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0100e4c:	85 c0                	test   %eax,%eax
f0100e4e:	0f 85 6f fd ff ff    	jne    f0100bc3 <check_page_free_list+0x2d>
f0100e54:	e9 53 fd ff ff       	jmp    f0100bac <check_page_free_list+0x16>
f0100e59:	83 3d 40 22 21 f0 00 	cmpl   $0x0,0xf0212240
f0100e60:	0f 84 46 fd ff ff    	je     f0100bac <check_page_free_list+0x16>
	   static void
check_page_free_list(bool only_low_memory)
{

	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e66:	be 00 04 00 00       	mov    $0x400,%esi
f0100e6b:	e9 a1 fd ff ff       	jmp    f0100c11 <check_page_free_list+0x7b>
			 assert(page2pa(pp) != IOPHYSMEM);
			 assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
			 assert(page2pa(pp) != EXTPHYSMEM);
			 assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
			 // (new test for lab 4)
			 assert(page2pa(pp) != MPENTRY_PADDR);
f0100e70:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e75:	0f 85 76 ff ff ff    	jne    f0100df1 <check_page_free_list+0x25b>
f0100e7b:	e9 53 ff ff ff       	jmp    f0100dd3 <check_page_free_list+0x23d>
f0100e80:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e85:	0f 85 61 ff ff ff    	jne    f0100dec <check_page_free_list+0x256>
f0100e8b:	e9 43 ff ff ff       	jmp    f0100dd3 <check_page_free_list+0x23d>

	   assert(nfree_basemem > 0);
	   assert(nfree_extmem > 0);

	   cprintf("check_page_free_list() succeeded!\n");
}
f0100e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e93:	5b                   	pop    %ebx
f0100e94:	5e                   	pop    %esi
f0100e95:	5f                   	pop    %edi
f0100e96:	5d                   	pop    %ebp
f0100e97:	c3                   	ret    

f0100e98 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
	   void
page_init(void)
{
f0100e98:	55                   	push   %ebp
f0100e99:	89 e5                	mov    %esp,%ebp
f0100e9b:	57                   	push   %edi
f0100e9c:	56                   	push   %esi
f0100e9d:	53                   	push   %ebx
f0100e9e:	83 ec 0c             	sub    $0xc,%esp
	   // LAB 4:
	   // Change your code to mark the physical page at MPENTRY_PADDR
	   // as in use
	   extern unsigned char mpentry_start [], mpentry_end [];
	   assert((uintptr_t)(mpentry_end - mpentry_start) <= PGSIZE);
f0100ea1:	b8 7e 58 10 f0       	mov    $0xf010587e,%eax
f0100ea6:	2d 04 58 10 f0       	sub    $0xf0105804,%eax
f0100eab:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0100eb0:	76 19                	jbe    f0100ecb <page_init+0x33>
f0100eb2:	68 f0 6c 10 f0       	push   $0xf0106cf0
f0100eb7:	68 98 68 10 f0       	push   $0xf0106898
f0100ebc:	68 3b 01 00 00       	push   $0x13b
f0100ec1:	68 72 68 10 f0       	push   $0xf0106872
f0100ec6:	e8 75 f1 ff ff       	call   f0100040 <_panic>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ecb:	83 3d 88 2e 21 f0 07 	cmpl   $0x7,0xf0212e88
f0100ed2:	77 14                	ja     f0100ee8 <page_init+0x50>
		panic("pa2page called with invalid pa");
f0100ed4:	83 ec 04             	sub    $0x4,%esp
f0100ed7:	68 24 6d 10 f0       	push   $0xf0106d24
f0100edc:	6a 51                	push   $0x51
f0100ede:	68 7e 68 10 f0       	push   $0xf010687e
f0100ee3:	e8 58 f1 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0100ee8:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
	   struct PageInfo* start_ap = pa2page(MPENTRY_PADDR);
	   start_ap -> pp_ref = 1;
f0100eed:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
	   // The example code here marks all physical pages as free.
	   // However this is not truly the case.  What memory is free?
	   //  1) Mark physical page 0 as in use.
	   //     This way we preserve the real-mode IDT and BIOS structures
	   //     in case we ever need them.  (Currently we don't, but...)
	   pages[0].pp_ref = 1;
f0100ef3:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	   pages [0].pp_link = NULL;
f0100ef9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	   //     is free.
	   for (int i = 1; i < npages_basemem; i++)
f0100eff:	8b 35 44 22 21 f0    	mov    0xf0212244,%esi
f0100f05:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
f0100f0b:	bf 00 00 00 00       	mov    $0x0,%edi
f0100f10:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f15:	eb 2e                	jmp    f0100f45 <page_init+0xad>
f0100f17:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
	   {
	   if (pages[i].pp_ref ==1)
f0100f1e:	89 ca                	mov    %ecx,%edx
f0100f20:	03 15 90 2e 21 f0    	add    0xf0212e90,%edx
f0100f26:	66 83 7a 04 01       	cmpw   $0x1,0x4(%edx)
f0100f2b:	74 15                	je     f0100f42 <page_init+0xaa>
	   continue;
	   pages[i].pp_ref = 0;
f0100f2d:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
	   pages[i].pp_link = page_free_list;
f0100f33:	89 1a                	mov    %ebx,(%edx)
	   page_free_list = &pages [i];
f0100f35:	03 0d 90 2e 21 f0    	add    0xf0212e90,%ecx
f0100f3b:	89 cb                	mov    %ecx,%ebx
f0100f3d:	bf 01 00 00 00       	mov    $0x1,%edi
	   //     in case we ever need them.  (Currently we don't, but...)
	   pages[0].pp_ref = 1;
	   pages [0].pp_link = NULL;
	   //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	   //     is free.
	   for (int i = 1; i < npages_basemem; i++)
f0100f42:	83 c0 01             	add    $0x1,%eax
f0100f45:	39 c6                	cmp    %eax,%esi
f0100f47:	77 ce                	ja     f0100f17 <page_init+0x7f>
f0100f49:	89 f8                	mov    %edi,%eax
f0100f4b:	84 c0                	test   %al,%al
f0100f4d:	74 06                	je     f0100f55 <page_init+0xbd>
f0100f4f:	89 1d 40 22 21 f0    	mov    %ebx,0xf0212240
	   pages[i].pp_link = page_free_list;
	   page_free_list = &pages [i];
	   }
	   //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	   //     never be allocated.
	   uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
f0100f55:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5a:	e8 70 fb ff ff       	call   f0100acf <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f5f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f64:	77 15                	ja     f0100f7b <page_init+0xe3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f66:	50                   	push   %eax
f0100f67:	68 08 63 10 f0       	push   $0xf0106308
f0100f6c:	68 52 01 00 00       	push   $0x152
f0100f71:	68 72 68 10 f0       	push   $0xf0106872
f0100f76:	e8 c5 f0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100f7b:	05 00 00 00 10       	add    $0x10000000,%eax
	   assert (free_pa % PGSIZE == 0);
f0100f80:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0100f85:	74 19                	je     f0100fa0 <page_init+0x108>
f0100f87:	68 45 69 10 f0       	push   $0xf0106945
f0100f8c:	68 98 68 10 f0       	push   $0xf0106898
f0100f91:	68 53 01 00 00       	push   $0x153
f0100f96:	68 72 68 10 f0       	push   $0xf0106872
f0100f9b:	e8 a0 f0 ff ff       	call   f0100040 <_panic>
	   uint32_t free_pa_index = free_pa / PGSIZE;
f0100fa0:	c1 e8 0c             	shr    $0xc,%eax
	   for (int i = npages_basemem; i < free_pa_index; i++)
f0100fa3:	8b 15 44 22 21 f0    	mov    0xf0212244,%edx
f0100fa9:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100fb0:	eb 1a                	jmp    f0100fcc <page_init+0x134>
	   {
	   pages[i].pp_ref = 1;
f0100fb2:	89 cb                	mov    %ecx,%ebx
f0100fb4:	03 1d 90 2e 21 f0    	add    0xf0212e90,%ebx
f0100fba:	66 c7 43 04 01 00    	movw   $0x1,0x4(%ebx)
	   pages[i].pp_link = NULL;
f0100fc0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	   //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	   //     never be allocated.
	   uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
	   assert (free_pa % PGSIZE == 0);
	   uint32_t free_pa_index = free_pa / PGSIZE;
	   for (int i = npages_basemem; i < free_pa_index; i++)
f0100fc6:	83 c2 01             	add    $0x1,%edx
f0100fc9:	83 c1 08             	add    $0x8,%ecx
f0100fcc:	39 d0                	cmp    %edx,%eax
f0100fce:	77 e2                	ja     f0100fb2 <page_init+0x11a>
	   //     page tables and other data structures?
	   //
	   // Change the code to reflect this.
	   // NB: DO NOT actually touch the physical memory corresponding to
	   // free pages!
	   for (int i = free_pa_index; i < npages; i++)
f0100fd0:	89 c2                	mov    %eax,%edx
f0100fd2:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
f0100fd8:	c1 e0 03             	shl    $0x3,%eax
f0100fdb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fe0:	eb 23                	jmp    f0101005 <page_init+0x16d>
	   {
	   pages[i].pp_ref = 0;
f0100fe2:	89 c1                	mov    %eax,%ecx
f0100fe4:	03 0d 90 2e 21 f0    	add    0xf0212e90,%ecx
f0100fea:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
	   pages[i].pp_link = page_free_list;
f0100ff0:	89 19                	mov    %ebx,(%ecx)
	   page_free_list = &pages[i];
f0100ff2:	89 c3                	mov    %eax,%ebx
f0100ff4:	03 1d 90 2e 21 f0    	add    0xf0212e90,%ebx
	   //     page tables and other data structures?
	   //
	   // Change the code to reflect this.
	   // NB: DO NOT actually touch the physical memory corresponding to
	   // free pages!
	   for (int i = free_pa_index; i < npages; i++)
f0100ffa:	83 c2 01             	add    $0x1,%edx
f0100ffd:	83 c0 08             	add    $0x8,%eax
f0101000:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101005:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f010100b:	72 d5                	jb     f0100fe2 <page_init+0x14a>
f010100d:	84 c9                	test   %cl,%cl
f010100f:	74 06                	je     f0101017 <page_init+0x17f>
f0101011:	89 1d 40 22 21 f0    	mov    %ebx,0xf0212240
	   pages[i].pp_ref = 0;
	   pages[i].pp_link = page_free_list;
	   page_free_list = &pages[i];
	   }

	    }
f0101017:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010101a:	5b                   	pop    %ebx
f010101b:	5e                   	pop    %esi
f010101c:	5f                   	pop    %edi
f010101d:	5d                   	pop    %ebp
f010101e:	c3                   	ret    

f010101f <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
	   struct PageInfo *
page_alloc(int alloc_flags)
{
f010101f:	55                   	push   %ebp
f0101020:	89 e5                	mov    %esp,%ebp
f0101022:	53                   	push   %ebx
f0101023:	83 ec 04             	sub    $0x4,%esp
	   // Fill this function in

	   struct PageInfo* allocate_page = page_free_list;
f0101026:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
	   if (allocate_page == NULL)
f010102c:	85 db                	test   %ebx,%ebx
f010102e:	74 5c                	je     f010108c <page_alloc+0x6d>
			 return NULL;

	   page_free_list = allocate_page -> pp_link;
f0101030:	8b 03                	mov    (%ebx),%eax
f0101032:	a3 40 22 21 f0       	mov    %eax,0xf0212240
	   allocate_page -> pp_link = NULL;
f0101037:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	   if (alloc_flags & ALLOC_ZERO)
			 memset (page2kva (allocate_page), 0, PGSIZE);

	   return allocate_page;
f010103d:	89 d8                	mov    %ebx,%eax
			 return NULL;

	   page_free_list = allocate_page -> pp_link;
	   allocate_page -> pp_link = NULL;

	   if (alloc_flags & ALLOC_ZERO)
f010103f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101043:	74 4c                	je     f0101091 <page_alloc+0x72>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101045:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010104b:	c1 f8 03             	sar    $0x3,%eax
f010104e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101051:	89 c2                	mov    %eax,%edx
f0101053:	c1 ea 0c             	shr    $0xc,%edx
f0101056:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f010105c:	72 12                	jb     f0101070 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010105e:	50                   	push   %eax
f010105f:	68 e4 62 10 f0       	push   $0xf01062e4
f0101064:	6a 58                	push   $0x58
f0101066:	68 7e 68 10 f0       	push   $0xf010687e
f010106b:	e8 d0 ef ff ff       	call   f0100040 <_panic>
			 memset (page2kva (allocate_page), 0, PGSIZE);
f0101070:	83 ec 04             	sub    $0x4,%esp
f0101073:	68 00 10 00 00       	push   $0x1000
f0101078:	6a 00                	push   $0x0
f010107a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010107f:	50                   	push   %eax
f0101080:	e8 7a 45 00 00       	call   f01055ff <memset>
f0101085:	83 c4 10             	add    $0x10,%esp

	   return allocate_page;
f0101088:	89 d8                	mov    %ebx,%eax
f010108a:	eb 05                	jmp    f0101091 <page_alloc+0x72>
{
	   // Fill this function in

	   struct PageInfo* allocate_page = page_free_list;
	   if (allocate_page == NULL)
			 return NULL;
f010108c:	b8 00 00 00 00       	mov    $0x0,%eax

	   if (alloc_flags & ALLOC_ZERO)
			 memset (page2kva (allocate_page), 0, PGSIZE);

	   return allocate_page;
}
f0101091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101094:	c9                   	leave  
f0101095:	c3                   	ret    

f0101096 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
	   void
page_free(struct PageInfo *pp)
{
f0101096:	55                   	push   %ebp
f0101097:	89 e5                	mov    %esp,%ebp
f0101099:	83 ec 08             	sub    $0x8,%esp
f010109c:	8b 45 08             	mov    0x8(%ebp),%eax
	   // Fill this function in
	   // Hint: You may want to panic if pp->pp_ref is nonzero or
	   // pp->pp_link is not NULL.

	   assert (pp->pp_ref == 0);
f010109f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010a4:	74 19                	je     f01010bf <page_free+0x29>
f01010a6:	68 5b 69 10 f0       	push   $0xf010695b
f01010ab:	68 98 68 10 f0       	push   $0xf0106898
f01010b0:	68 95 01 00 00       	push   $0x195
f01010b5:	68 72 68 10 f0       	push   $0xf0106872
f01010ba:	e8 81 ef ff ff       	call   f0100040 <_panic>
	   assert (pp->pp_link == NULL);
f01010bf:	83 38 00             	cmpl   $0x0,(%eax)
f01010c2:	74 19                	je     f01010dd <page_free+0x47>
f01010c4:	68 6b 69 10 f0       	push   $0xf010696b
f01010c9:	68 98 68 10 f0       	push   $0xf0106898
f01010ce:	68 96 01 00 00       	push   $0x196
f01010d3:	68 72 68 10 f0       	push   $0xf0106872
f01010d8:	e8 63 ef ff ff       	call   f0100040 <_panic>

	   pp->pp_ref = 0;
f01010dd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	   pp->pp_link = page_free_list;
f01010e3:	8b 15 40 22 21 f0    	mov    0xf0212240,%edx
f01010e9:	89 10                	mov    %edx,(%eax)
	   page_free_list = pp;
f01010eb:	a3 40 22 21 f0       	mov    %eax,0xf0212240
}
f01010f0:	c9                   	leave  
f01010f1:	c3                   	ret    

f01010f2 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
	   void
page_decref(struct PageInfo* pp)
{
f01010f2:	55                   	push   %ebp
f01010f3:	89 e5                	mov    %esp,%ebp
f01010f5:	83 ec 08             	sub    $0x8,%esp
f01010f8:	8b 55 08             	mov    0x8(%ebp),%edx
	   if (--pp->pp_ref == 0)
f01010fb:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010ff:	83 e8 01             	sub    $0x1,%eax
f0101102:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101106:	66 85 c0             	test   %ax,%ax
f0101109:	75 0c                	jne    f0101117 <page_decref+0x25>
			 page_free(pp);
f010110b:	83 ec 0c             	sub    $0xc,%esp
f010110e:	52                   	push   %edx
f010110f:	e8 82 ff ff ff       	call   f0101096 <page_free>
f0101114:	83 c4 10             	add    $0x10,%esp
}
f0101117:	c9                   	leave  
f0101118:	c3                   	ret    

f0101119 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
	   pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101119:	55                   	push   %ebp
f010111a:	89 e5                	mov    %esp,%ebp
f010111c:	56                   	push   %esi
f010111d:	53                   	push   %ebx
f010111e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   // Fill this function in

	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
f0101121:	89 de                	mov    %ebx,%esi
f0101123:	c1 ee 16             	shr    $0x16,%esi
f0101126:	c1 e6 02             	shl    $0x2,%esi
f0101129:	03 75 08             	add    0x8(%ebp),%esi
f010112c:	8b 06                	mov    (%esi),%eax
	   if (!(pde_offset & PTE_P) && create)
f010112e:	89 c2                	mov    %eax,%edx
f0101130:	83 e2 01             	and    $0x1,%edx
f0101133:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101137:	74 2d                	je     f0101166 <pgdir_walk+0x4d>
f0101139:	85 d2                	test   %edx,%edx
f010113b:	75 29                	jne    f0101166 <pgdir_walk+0x4d>
	   {
			 struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
f010113d:	83 ec 0c             	sub    $0xc,%esp
f0101140:	6a 01                	push   $0x1
f0101142:	e8 d8 fe ff ff       	call   f010101f <page_alloc>
			 if (!new_page) return NULL;
f0101147:	83 c4 10             	add    $0x10,%esp
f010114a:	85 c0                	test   %eax,%eax
f010114c:	74 55                	je     f01011a3 <pgdir_walk+0x8a>

			 new_page -> pp_ref ++;
f010114e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
f0101153:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0101159:	c1 f8 03             	sar    $0x3,%eax
f010115c:	c1 e0 0c             	shl    $0xc,%eax
f010115f:	83 c8 07             	or     $0x7,%eax
			 pgdir [PDX(address)] = pde_offset;
f0101162:	89 06                	mov    %eax,(%esi)
	   // Fill this function in

	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
	   if (!(pde_offset & PTE_P) && create)
	   {
f0101164:	eb 04                	jmp    f010116a <pgdir_walk+0x51>
			 if (!new_page) return NULL;

			 new_page -> pp_ref ++;
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
			 pgdir [PDX(address)] = pde_offset;
	   } else if (!(pde_offset & PTE_P)) return NULL;
f0101166:	85 d2                	test   %edx,%edx
f0101168:	74 40                	je     f01011aa <pgdir_walk+0x91>

	   physaddr_t pt_pa = PTE_ADDR(pde_offset);
f010116a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010116f:	89 c2                	mov    %eax,%edx
f0101171:	c1 ea 0c             	shr    $0xc,%edx
f0101174:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f010117a:	72 15                	jb     f0101191 <pgdir_walk+0x78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010117c:	50                   	push   %eax
f010117d:	68 e4 62 10 f0       	push   $0xf01062e4
f0101182:	68 d0 01 00 00       	push   $0x1d0
f0101187:	68 72 68 10 f0       	push   $0xf0106872
f010118c:	e8 af ee ff ff       	call   f0100040 <_panic>
	   pte_t* pt_va = KADDR(pt_pa);
	   return &pt_va [PTX(address)];
f0101191:	c1 eb 0a             	shr    $0xa,%ebx
f0101194:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010119a:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01011a1:	eb 0c                	jmp    f01011af <pgdir_walk+0x96>
	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
	   if (!(pde_offset & PTE_P) && create)
	   {
			 struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
			 if (!new_page) return NULL;
f01011a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a8:	eb 05                	jmp    f01011af <pgdir_walk+0x96>

			 new_page -> pp_ref ++;
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
			 pgdir [PDX(address)] = pde_offset;
	   } else if (!(pde_offset & PTE_P)) return NULL;
f01011aa:	b8 00 00 00 00       	mov    $0x0,%eax

	   physaddr_t pt_pa = PTE_ADDR(pde_offset);
	   pte_t* pt_va = KADDR(pt_pa);
	   return &pt_va [PTX(address)];
}
f01011af:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011b2:	5b                   	pop    %ebx
f01011b3:	5e                   	pop    %esi
f01011b4:	5d                   	pop    %ebp
f01011b5:	c3                   	ret    

f01011b6 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	   static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011b6:	55                   	push   %ebp
f01011b7:	89 e5                	mov    %esp,%ebp
f01011b9:	57                   	push   %edi
f01011ba:	56                   	push   %esi
f01011bb:	53                   	push   %ebx
f01011bc:	83 ec 1c             	sub    $0x1c,%esp
f01011bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01011c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01011c5:	c1 e9 0c             	shr    $0xc,%ecx
f01011c8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f01011cb:	89 c3                	mov    %eax,%ebx
f01011cd:	be 00 00 00 00       	mov    $0x0,%esi
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f01011d2:	89 d7                	mov    %edx,%edi
f01011d4:	29 c7                	sub    %eax,%edi
			 assert (pte_entry != NULL);
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f01011d6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d9:	83 c8 01             	or     $0x1,%eax
f01011dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f01011df:	eb 41                	jmp    f0101222 <boot_map_region+0x6c>
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f01011e1:	83 ec 04             	sub    $0x4,%esp
f01011e4:	6a 01                	push   $0x1
f01011e6:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01011e9:	50                   	push   %eax
f01011ea:	ff 75 e0             	pushl  -0x20(%ebp)
f01011ed:	e8 27 ff ff ff       	call   f0101119 <pgdir_walk>
			 assert (pte_entry != NULL);
f01011f2:	83 c4 10             	add    $0x10,%esp
f01011f5:	85 c0                	test   %eax,%eax
f01011f7:	75 19                	jne    f0101212 <boot_map_region+0x5c>
f01011f9:	68 7f 69 10 f0       	push   $0xf010697f
f01011fe:	68 98 68 10 f0       	push   $0xf0106898
f0101203:	68 eb 01 00 00       	push   $0x1eb
f0101208:	68 72 68 10 f0       	push   $0xf0106872
f010120d:	e8 2e ee ff ff       	call   f0100040 <_panic>
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f0101212:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101215:	09 da                	or     %ebx,%edx
f0101217:	89 10                	mov    %edx,(%eax)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f0101219:	83 c6 01             	add    $0x1,%esi
f010121c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101222:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101225:	75 ba                	jne    f01011e1 <boot_map_region+0x2b>
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
			 assert (pte_entry != NULL);
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
	   }
}
f0101227:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010122a:	5b                   	pop    %ebx
f010122b:	5e                   	pop    %esi
f010122c:	5f                   	pop    %edi
f010122d:	5d                   	pop    %ebp
f010122e:	c3                   	ret    

f010122f <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
	   struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010122f:	55                   	push   %ebp
f0101230:	89 e5                	mov    %esp,%ebp
f0101232:	53                   	push   %ebx
f0101233:	83 ec 08             	sub    $0x8,%esp
f0101236:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, 0);
f0101239:	6a 00                	push   $0x0
f010123b:	ff 75 0c             	pushl  0xc(%ebp)
f010123e:	ff 75 08             	pushl  0x8(%ebp)
f0101241:	e8 d3 fe ff ff       	call   f0101119 <pgdir_walk>

	   if (!pte_entry || !(*pte_entry & PTE_P))
f0101246:	83 c4 10             	add    $0x10,%esp
f0101249:	85 c0                	test   %eax,%eax
f010124b:	74 37                	je     f0101284 <page_lookup+0x55>
f010124d:	f6 00 01             	testb  $0x1,(%eax)
f0101250:	74 39                	je     f010128b <page_lookup+0x5c>
			 return NULL;

	   if (pte_store)
f0101252:	85 db                	test   %ebx,%ebx
f0101254:	74 02                	je     f0101258 <page_lookup+0x29>
			 *pte_store = pte_entry;
f0101256:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101258:	8b 00                	mov    (%eax),%eax
f010125a:	c1 e8 0c             	shr    $0xc,%eax
f010125d:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0101263:	72 14                	jb     f0101279 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101265:	83 ec 04             	sub    $0x4,%esp
f0101268:	68 24 6d 10 f0       	push   $0xf0106d24
f010126d:	6a 51                	push   $0x51
f010126f:	68 7e 68 10 f0       	push   $0xf010687e
f0101274:	e8 c7 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101279:	8b 15 90 2e 21 f0    	mov    0xf0212e90,%edx
f010127f:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	   return pa2page(PTE_ADDR(*pte_entry));
f0101282:	eb 0c                	jmp    f0101290 <page_lookup+0x61>
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, 0);

	   if (!pte_entry || !(*pte_entry & PTE_P))
			 return NULL;
f0101284:	b8 00 00 00 00       	mov    $0x0,%eax
f0101289:	eb 05                	jmp    f0101290 <page_lookup+0x61>
f010128b:	b8 00 00 00 00       	mov    $0x0,%eax

	   if (pte_store)
			 *pte_store = pte_entry;

	   return pa2page(PTE_ADDR(*pte_entry));
}
f0101290:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101293:	c9                   	leave  
f0101294:	c3                   	ret    

f0101295 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
	   void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101295:	55                   	push   %ebp
f0101296:	89 e5                	mov    %esp,%ebp
f0101298:	83 ec 08             	sub    $0x8,%esp

	   // Flush the entry only if we're modifying the current address space.
	   if (!curenv || curenv->env_pgdir == pgdir)
f010129b:	e8 82 49 00 00       	call   f0105c22 <cpunum>
f01012a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01012a3:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f01012aa:	74 16                	je     f01012c2 <tlb_invalidate+0x2d>
f01012ac:	e8 71 49 00 00       	call   f0105c22 <cpunum>
f01012b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01012b4:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01012ba:	8b 55 08             	mov    0x8(%ebp),%edx
f01012bd:	39 50 60             	cmp    %edx,0x60(%eax)
f01012c0:	75 06                	jne    f01012c8 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012c5:	0f 01 38             	invlpg (%eax)
			 invlpg(va);
}
f01012c8:	c9                   	leave  
f01012c9:	c3                   	ret    

f01012ca <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
	   void
page_remove(pde_t *pgdir, void *va)
{
f01012ca:	55                   	push   %ebp
f01012cb:	89 e5                	mov    %esp,%ebp
f01012cd:	56                   	push   %esi
f01012ce:	53                   	push   %ebx
f01012cf:	83 ec 14             	sub    $0x14,%esp
f01012d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	   // Fill this function in

	   pte_t* pte_address = NULL;
f01012d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	   struct PageInfo* pp = page_lookup (pgdir, va, &pte_address);
f01012df:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012e2:	50                   	push   %eax
f01012e3:	56                   	push   %esi
f01012e4:	53                   	push   %ebx
f01012e5:	e8 45 ff ff ff       	call   f010122f <page_lookup>
	   if (!pp)
f01012ea:	83 c4 10             	add    $0x10,%esp
f01012ed:	85 c0                	test   %eax,%eax
f01012ef:	74 1f                	je     f0101310 <page_remove+0x46>
			 return;

	   *pte_address = 0;
f01012f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01012f4:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	   page_decref(pp);
f01012fa:	83 ec 0c             	sub    $0xc,%esp
f01012fd:	50                   	push   %eax
f01012fe:	e8 ef fd ff ff       	call   f01010f2 <page_decref>
	   tlb_invalidate (pgdir, va);
f0101303:	83 c4 08             	add    $0x8,%esp
f0101306:	56                   	push   %esi
f0101307:	53                   	push   %ebx
f0101308:	e8 88 ff ff ff       	call   f0101295 <tlb_invalidate>
f010130d:	83 c4 10             	add    $0x10,%esp

}
f0101310:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101313:	5b                   	pop    %ebx
f0101314:	5e                   	pop    %esi
f0101315:	5d                   	pop    %ebp
f0101316:	c3                   	ret    

f0101317 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
	   int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101317:	55                   	push   %ebp
f0101318:	89 e5                	mov    %esp,%ebp
f010131a:	57                   	push   %edi
f010131b:	56                   	push   %esi
f010131c:	53                   	push   %ebx
f010131d:	83 ec 10             	sub    $0x10,%esp
f0101320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101323:	8b 7d 10             	mov    0x10(%ebp),%edi
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, true);
f0101326:	6a 01                	push   $0x1
f0101328:	57                   	push   %edi
f0101329:	ff 75 08             	pushl  0x8(%ebp)
f010132c:	e8 e8 fd ff ff       	call   f0101119 <pgdir_walk>

	   if (!pte_entry) return -E_NO_MEM;
f0101331:	83 c4 10             	add    $0x10,%esp
f0101334:	85 c0                	test   %eax,%eax
f0101336:	0f 84 a2 00 00 00    	je     f01013de <page_insert+0xc7>
f010133c:	89 c6                	mov    %eax,%esi

	   if (PTE_ADDR(*pte_entry) == page2pa (pp))
f010133e:	8b 10                	mov    (%eax),%edx
f0101340:	89 d1                	mov    %edx,%ecx
f0101342:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101348:	89 d8                	mov    %ebx,%eax
f010134a:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0101350:	c1 f8 03             	sar    $0x3,%eax
f0101353:	c1 e0 0c             	shl    $0xc,%eax
f0101356:	39 c1                	cmp    %eax,%ecx
f0101358:	75 30                	jne    f010138a <page_insert+0x73>
	   {
			 if ((*pte_entry & 0x1FF) == perm) return 0;
f010135a:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
f0101360:	b8 00 00 00 00       	mov    $0x0,%eax
f0101365:	3b 55 14             	cmp    0x14(%ebp),%edx
f0101368:	74 79                	je     f01013e3 <page_insert+0xcc>

			 *pte_entry = page2pa (pp) | perm | PTE_P;
f010136a:	8b 45 14             	mov    0x14(%ebp),%eax
f010136d:	83 c8 01             	or     $0x1,%eax
f0101370:	09 c1                	or     %eax,%ecx
f0101372:	89 0e                	mov    %ecx,(%esi)
			 tlb_invalidate (pgdir, va);
f0101374:	83 ec 08             	sub    $0x8,%esp
f0101377:	57                   	push   %edi
f0101378:	ff 75 08             	pushl  0x8(%ebp)
f010137b:	e8 15 ff ff ff       	call   f0101295 <tlb_invalidate>
			 return 0;
f0101380:	83 c4 10             	add    $0x10,%esp
f0101383:	b8 00 00 00 00       	mov    $0x0,%eax
f0101388:	eb 59                	jmp    f01013e3 <page_insert+0xcc>
	   }

	   if (*pte_entry & PTE_P)
f010138a:	f6 c2 01             	test   $0x1,%dl
f010138d:	74 2d                	je     f01013bc <page_insert+0xa5>
	   {
			 page_remove (pgdir, va);
f010138f:	83 ec 08             	sub    $0x8,%esp
f0101392:	57                   	push   %edi
f0101393:	ff 75 08             	pushl  0x8(%ebp)
f0101396:	e8 2f ff ff ff       	call   f01012ca <page_remove>
			 assert (*pte_entry ==0);
f010139b:	83 c4 10             	add    $0x10,%esp
f010139e:	83 3e 00             	cmpl   $0x0,(%esi)
f01013a1:	74 19                	je     f01013bc <page_insert+0xa5>
f01013a3:	68 91 69 10 f0       	push   $0xf0106991
f01013a8:	68 98 68 10 f0       	push   $0xf0106898
f01013ad:	68 1e 02 00 00       	push   $0x21e
f01013b2:	68 72 68 10 f0       	push   $0xf0106872
f01013b7:	e8 84 ec ff ff       	call   f0100040 <_panic>
	   }

	   pp -> pp_ref ++;
f01013bc:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	   *pte_entry = page2pa (pp) | perm | PTE_P;
f01013c1:	2b 1d 90 2e 21 f0    	sub    0xf0212e90,%ebx
f01013c7:	c1 fb 03             	sar    $0x3,%ebx
f01013ca:	c1 e3 0c             	shl    $0xc,%ebx
f01013cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01013d0:	83 c8 01             	or     $0x1,%eax
f01013d3:	09 c3                	or     %eax,%ebx
f01013d5:	89 1e                	mov    %ebx,(%esi)
	   return 0;
f01013d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01013dc:	eb 05                	jmp    f01013e3 <page_insert+0xcc>
{
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, true);

	   if (!pte_entry) return -E_NO_MEM;
f01013de:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	   }

	   pp -> pp_ref ++;
	   *pte_entry = page2pa (pp) | perm | PTE_P;
	   return 0;
}
f01013e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013e6:	5b                   	pop    %ebx
f01013e7:	5e                   	pop    %esi
f01013e8:	5f                   	pop    %edi
f01013e9:	5d                   	pop    %ebp
f01013ea:	c3                   	ret    

f01013eb <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
	   void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013eb:	55                   	push   %ebp
f01013ec:	89 e5                	mov    %esp,%ebp
f01013ee:	53                   	push   %ebx
f01013ef:	83 ec 04             	sub    $0x4,%esp
f01013f2:	8b 45 08             	mov    0x8(%ebp),%eax
	   // okay to simply panic if this happens).
	   //
	   // Hint: The staff solution uses boot_map_region.
	   //
	   // Your code here:
		 assert (pa % PGSIZE == 0);
f01013f5:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01013fa:	74 19                	je     f0101415 <mmio_map_region+0x2a>
f01013fc:	68 4a 69 10 f0       	push   $0xf010694a
f0101401:	68 98 68 10 f0       	push   $0xf0106898
f0101406:	68 8d 02 00 00       	push   $0x28d
f010140b:	68 72 68 10 f0       	push   $0xf0106872
f0101410:	e8 2b ec ff ff       	call   f0100040 <_panic>
		 size = ROUNDUP (size, PGSIZE);
f0101415:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101418:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
f010141e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
		 if ((base + size) > MMIOLIM)
f0101424:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f010142a:	8d 0c 13             	lea    (%ebx,%edx,1),%ecx
f010142d:	81 f9 00 00 c0 ef    	cmp    $0xefc00000,%ecx
f0101433:	76 17                	jbe    f010144c <mmio_map_region+0x61>
		 panic ("Memory to be allocated greater than MMIOLIM. Out of memory \n");
f0101435:	83 ec 04             	sub    $0x4,%esp
f0101438:	68 44 6d 10 f0       	push   $0xf0106d44
f010143d:	68 90 02 00 00       	push   $0x290
f0101442:	68 72 68 10 f0       	push   $0xf0106872
f0101447:	e8 f4 eb ff ff       	call   f0100040 <_panic>

		 boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PCD | PTE_PWT | PTE_P);
f010144c:	83 ec 08             	sub    $0x8,%esp
f010144f:	6a 1b                	push   $0x1b
f0101451:	50                   	push   %eax
f0101452:	89 d9                	mov    %ebx,%ecx
f0101454:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101459:	e8 58 fd ff ff       	call   f01011b6 <boot_map_region>
		 void* return_base = (void*) base;
f010145e:	a1 00 03 12 f0       	mov    0xf0120300,%eax
		 base += size;
f0101463:	01 c3                	add    %eax,%ebx
f0101465:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
		 return return_base;

	   //panic("mmio_map_region not implemented");
	   }
f010146b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010146e:	c9                   	leave  
f010146f:	c3                   	ret    

f0101470 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	   void
mem_init(void)
{
f0101470:	55                   	push   %ebp
f0101471:	89 e5                	mov    %esp,%ebp
f0101473:	57                   	push   %edi
f0101474:	56                   	push   %esi
f0101475:	53                   	push   %ebx
f0101476:	83 ec 3c             	sub    $0x3c,%esp
{
	   size_t basemem, extmem, ext16mem, totalmem;

	   // Use CMOS calls to measure available base & extended memory.
	   // (CMOS calls return results in kilobytes.)
	   basemem = nvram_read(NVRAM_BASELO);
f0101479:	b8 15 00 00 00       	mov    $0x15,%eax
f010147e:	e8 23 f6 ff ff       	call   f0100aa6 <nvram_read>
f0101483:	89 c3                	mov    %eax,%ebx
	   extmem = nvram_read(NVRAM_EXTLO);
f0101485:	b8 17 00 00 00       	mov    $0x17,%eax
f010148a:	e8 17 f6 ff ff       	call   f0100aa6 <nvram_read>
f010148f:	89 c6                	mov    %eax,%esi
	   ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101491:	b8 34 00 00 00       	mov    $0x34,%eax
f0101496:	e8 0b f6 ff ff       	call   f0100aa6 <nvram_read>
f010149b:	c1 e0 06             	shl    $0x6,%eax

	   // Calculate the number of physical pages available in both base
	   // and extended memory.
	   if (ext16mem)
f010149e:	85 c0                	test   %eax,%eax
f01014a0:	74 07                	je     f01014a9 <mem_init+0x39>
			 totalmem = 16 * 1024 + ext16mem;
f01014a2:	05 00 40 00 00       	add    $0x4000,%eax
f01014a7:	eb 0b                	jmp    f01014b4 <mem_init+0x44>
	   else if (extmem)
			 totalmem = 1 * 1024 + extmem;
f01014a9:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014af:	85 f6                	test   %esi,%esi
f01014b1:	0f 44 c3             	cmove  %ebx,%eax
	   else
			 totalmem = basemem;

	   npages = totalmem / (PGSIZE / 1024);
f01014b4:	89 c2                	mov    %eax,%edx
f01014b6:	c1 ea 02             	shr    $0x2,%edx
f01014b9:	89 15 88 2e 21 f0    	mov    %edx,0xf0212e88
	   npages_basemem = basemem / (PGSIZE / 1024);
f01014bf:	89 da                	mov    %ebx,%edx
f01014c1:	c1 ea 02             	shr    $0x2,%edx
f01014c4:	89 15 44 22 21 f0    	mov    %edx,0xf0212244

	   cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ca:	89 c2                	mov    %eax,%edx
f01014cc:	29 da                	sub    %ebx,%edx
f01014ce:	52                   	push   %edx
f01014cf:	53                   	push   %ebx
f01014d0:	50                   	push   %eax
f01014d1:	68 84 6d 10 f0       	push   $0xf0106d84
f01014d6:	e8 49 23 00 00       	call   f0103824 <cprintf>
	   // Remove this line when you're ready to test this function.
	   //	   panic("mem_init: This function is not finished\n");

	   //////////////////////////////////////////////////////////////////////
	   // create initial page directory.
	   kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014db:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014e0:	e8 ea f5 ff ff       	call   f0100acf <boot_alloc>
f01014e5:	a3 8c 2e 21 f0       	mov    %eax,0xf0212e8c
	   memset(kern_pgdir, 0, PGSIZE);
f01014ea:	83 c4 0c             	add    $0xc,%esp
f01014ed:	68 00 10 00 00       	push   $0x1000
f01014f2:	6a 00                	push   $0x0
f01014f4:	50                   	push   %eax
f01014f5:	e8 05 41 00 00       	call   f01055ff <memset>
	   // a virtual page table at virtual address UVPT.
	   // (For now, you don't have understand the greater purpose of the
	   // following line.)

	   // Permissions: kernel R, user R
	   kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014fa:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014ff:	83 c4 10             	add    $0x10,%esp
f0101502:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101507:	77 15                	ja     f010151e <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101509:	50                   	push   %eax
f010150a:	68 08 63 10 f0       	push   $0xf0106308
f010150f:	68 9e 00 00 00       	push   $0x9e
f0101514:	68 72 68 10 f0       	push   $0xf0106872
f0101519:	e8 22 eb ff ff       	call   f0100040 <_panic>
f010151e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101524:	83 ca 05             	or     $0x5,%edx
f0101527:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	   // each physical page, there is a corresponding struct PageInfo in this
	   // array.  'npages' is the number of physical pages in memory.  Use memset
	   // to initialize all fields of each struct PageInfo to 0.
	   // Your code goes here:

	   pages = (struct PageInfo *) boot_alloc(npages * sizeof (struct PageInfo));
f010152d:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f0101532:	c1 e0 03             	shl    $0x3,%eax
f0101535:	e8 95 f5 ff ff       	call   f0100acf <boot_alloc>
f010153a:	a3 90 2e 21 f0       	mov    %eax,0xf0212e90
	   memset (pages, 0, npages * sizeof(struct PageInfo));
f010153f:	83 ec 04             	sub    $0x4,%esp
f0101542:	8b 0d 88 2e 21 f0    	mov    0xf0212e88,%ecx
f0101548:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010154f:	52                   	push   %edx
f0101550:	6a 00                	push   $0x0
f0101552:	50                   	push   %eax
f0101553:	e8 a7 40 00 00       	call   f01055ff <memset>

	   //////////////////////////////////////////////////////////////////////
	   // Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	   // LAB 3: Your code here.

	   envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f0101558:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010155d:	e8 6d f5 ff ff       	call   f0100acf <boot_alloc>
f0101562:	a3 48 22 21 f0       	mov    %eax,0xf0212248
	   memset(envs, 0, NENV * sizeof(struct Env));
f0101567:	83 c4 0c             	add    $0xc,%esp
f010156a:	68 00 f0 01 00       	push   $0x1f000
f010156f:	6a 00                	push   $0x0
f0101571:	50                   	push   %eax
f0101572:	e8 88 40 00 00       	call   f01055ff <memset>
	   // Now that we've allocated the initial kernel data structures, we set
	   // up the list of free physical pages. Once we've done so, all further
	   // memory management will go through the page_* functions. In
	   // particular, we can now map memory using boot_map_region
	   // or page_insert
	   page_init();
f0101577:	e8 1c f9 ff ff       	call   f0100e98 <page_init>

	   check_page_free_list(1);
f010157c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101581:	e8 10 f6 ff ff       	call   f0100b96 <check_page_free_list>
	   int nfree;
	   struct PageInfo *fl;
	   char *c;
	   int i;

	   if (!pages)
f0101586:	83 c4 10             	add    $0x10,%esp
f0101589:	83 3d 90 2e 21 f0 00 	cmpl   $0x0,0xf0212e90
f0101590:	75 17                	jne    f01015a9 <mem_init+0x139>
			 panic("'pages' is a null pointer!");
f0101592:	83 ec 04             	sub    $0x4,%esp
f0101595:	68 a0 69 10 f0       	push   $0xf01069a0
f010159a:	68 25 03 00 00       	push   $0x325
f010159f:	68 72 68 10 f0       	push   $0xf0106872
f01015a4:	e8 97 ea ff ff       	call   f0100040 <_panic>

	   // check number of free pages
	   for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015a9:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f01015ae:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015b3:	eb 05                	jmp    f01015ba <mem_init+0x14a>
			 ++nfree;
f01015b5:	83 c3 01             	add    $0x1,%ebx

	   if (!pages)
			 panic("'pages' is a null pointer!");

	   // check number of free pages
	   for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015b8:	8b 00                	mov    (%eax),%eax
f01015ba:	85 c0                	test   %eax,%eax
f01015bc:	75 f7                	jne    f01015b5 <mem_init+0x145>
			 ++nfree;

	   // should be able to allocate three pages
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f01015be:	83 ec 0c             	sub    $0xc,%esp
f01015c1:	6a 00                	push   $0x0
f01015c3:	e8 57 fa ff ff       	call   f010101f <page_alloc>
f01015c8:	89 c7                	mov    %eax,%edi
f01015ca:	83 c4 10             	add    $0x10,%esp
f01015cd:	85 c0                	test   %eax,%eax
f01015cf:	75 19                	jne    f01015ea <mem_init+0x17a>
f01015d1:	68 bb 69 10 f0       	push   $0xf01069bb
f01015d6:	68 98 68 10 f0       	push   $0xf0106898
f01015db:	68 2d 03 00 00       	push   $0x32d
f01015e0:	68 72 68 10 f0       	push   $0xf0106872
f01015e5:	e8 56 ea ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f01015ea:	83 ec 0c             	sub    $0xc,%esp
f01015ed:	6a 00                	push   $0x0
f01015ef:	e8 2b fa ff ff       	call   f010101f <page_alloc>
f01015f4:	89 c6                	mov    %eax,%esi
f01015f6:	83 c4 10             	add    $0x10,%esp
f01015f9:	85 c0                	test   %eax,%eax
f01015fb:	75 19                	jne    f0101616 <mem_init+0x1a6>
f01015fd:	68 d1 69 10 f0       	push   $0xf01069d1
f0101602:	68 98 68 10 f0       	push   $0xf0106898
f0101607:	68 2e 03 00 00       	push   $0x32e
f010160c:	68 72 68 10 f0       	push   $0xf0106872
f0101611:	e8 2a ea ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f0101616:	83 ec 0c             	sub    $0xc,%esp
f0101619:	6a 00                	push   $0x0
f010161b:	e8 ff f9 ff ff       	call   f010101f <page_alloc>
f0101620:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101623:	83 c4 10             	add    $0x10,%esp
f0101626:	85 c0                	test   %eax,%eax
f0101628:	75 19                	jne    f0101643 <mem_init+0x1d3>
f010162a:	68 e7 69 10 f0       	push   $0xf01069e7
f010162f:	68 98 68 10 f0       	push   $0xf0106898
f0101634:	68 2f 03 00 00       	push   $0x32f
f0101639:	68 72 68 10 f0       	push   $0xf0106872
f010163e:	e8 fd e9 ff ff       	call   f0100040 <_panic>

	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f0101643:	39 f7                	cmp    %esi,%edi
f0101645:	75 19                	jne    f0101660 <mem_init+0x1f0>
f0101647:	68 fd 69 10 f0       	push   $0xf01069fd
f010164c:	68 98 68 10 f0       	push   $0xf0106898
f0101651:	68 32 03 00 00       	push   $0x332
f0101656:	68 72 68 10 f0       	push   $0xf0106872
f010165b:	e8 e0 e9 ff ff       	call   f0100040 <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101660:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101663:	39 c6                	cmp    %eax,%esi
f0101665:	74 04                	je     f010166b <mem_init+0x1fb>
f0101667:	39 c7                	cmp    %eax,%edi
f0101669:	75 19                	jne    f0101684 <mem_init+0x214>
f010166b:	68 c0 6d 10 f0       	push   $0xf0106dc0
f0101670:	68 98 68 10 f0       	push   $0xf0106898
f0101675:	68 33 03 00 00       	push   $0x333
f010167a:	68 72 68 10 f0       	push   $0xf0106872
f010167f:	e8 bc e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101684:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
	   assert(page2pa(pp0) < npages*PGSIZE);
f010168a:	8b 15 88 2e 21 f0    	mov    0xf0212e88,%edx
f0101690:	c1 e2 0c             	shl    $0xc,%edx
f0101693:	89 f8                	mov    %edi,%eax
f0101695:	29 c8                	sub    %ecx,%eax
f0101697:	c1 f8 03             	sar    $0x3,%eax
f010169a:	c1 e0 0c             	shl    $0xc,%eax
f010169d:	39 d0                	cmp    %edx,%eax
f010169f:	72 19                	jb     f01016ba <mem_init+0x24a>
f01016a1:	68 0f 6a 10 f0       	push   $0xf0106a0f
f01016a6:	68 98 68 10 f0       	push   $0xf0106898
f01016ab:	68 34 03 00 00       	push   $0x334
f01016b0:	68 72 68 10 f0       	push   $0xf0106872
f01016b5:	e8 86 e9 ff ff       	call   f0100040 <_panic>
	   assert(page2pa(pp1) < npages*PGSIZE);
f01016ba:	89 f0                	mov    %esi,%eax
f01016bc:	29 c8                	sub    %ecx,%eax
f01016be:	c1 f8 03             	sar    $0x3,%eax
f01016c1:	c1 e0 0c             	shl    $0xc,%eax
f01016c4:	39 c2                	cmp    %eax,%edx
f01016c6:	77 19                	ja     f01016e1 <mem_init+0x271>
f01016c8:	68 2c 6a 10 f0       	push   $0xf0106a2c
f01016cd:	68 98 68 10 f0       	push   $0xf0106898
f01016d2:	68 35 03 00 00       	push   $0x335
f01016d7:	68 72 68 10 f0       	push   $0xf0106872
f01016dc:	e8 5f e9 ff ff       	call   f0100040 <_panic>
	   assert(page2pa(pp2) < npages*PGSIZE);
f01016e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016e4:	29 c8                	sub    %ecx,%eax
f01016e6:	c1 f8 03             	sar    $0x3,%eax
f01016e9:	c1 e0 0c             	shl    $0xc,%eax
f01016ec:	39 c2                	cmp    %eax,%edx
f01016ee:	77 19                	ja     f0101709 <mem_init+0x299>
f01016f0:	68 49 6a 10 f0       	push   $0xf0106a49
f01016f5:	68 98 68 10 f0       	push   $0xf0106898
f01016fa:	68 36 03 00 00       	push   $0x336
f01016ff:	68 72 68 10 f0       	push   $0xf0106872
f0101704:	e8 37 e9 ff ff       	call   f0100040 <_panic>

	   // temporarily steal the rest of the free pages
	   fl = page_free_list;
f0101709:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f010170e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	   page_free_list = 0;
f0101711:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f0101718:	00 00 00 

	   // should be no free memory
	   assert(!page_alloc(0));
f010171b:	83 ec 0c             	sub    $0xc,%esp
f010171e:	6a 00                	push   $0x0
f0101720:	e8 fa f8 ff ff       	call   f010101f <page_alloc>
f0101725:	83 c4 10             	add    $0x10,%esp
f0101728:	85 c0                	test   %eax,%eax
f010172a:	74 19                	je     f0101745 <mem_init+0x2d5>
f010172c:	68 66 6a 10 f0       	push   $0xf0106a66
f0101731:	68 98 68 10 f0       	push   $0xf0106898
f0101736:	68 3d 03 00 00       	push   $0x33d
f010173b:	68 72 68 10 f0       	push   $0xf0106872
f0101740:	e8 fb e8 ff ff       	call   f0100040 <_panic>

	   // free and re-allocate?
	   page_free(pp0);
f0101745:	83 ec 0c             	sub    $0xc,%esp
f0101748:	57                   	push   %edi
f0101749:	e8 48 f9 ff ff       	call   f0101096 <page_free>
	   page_free(pp1);
f010174e:	89 34 24             	mov    %esi,(%esp)
f0101751:	e8 40 f9 ff ff       	call   f0101096 <page_free>
	   page_free(pp2);
f0101756:	83 c4 04             	add    $0x4,%esp
f0101759:	ff 75 d4             	pushl  -0x2c(%ebp)
f010175c:	e8 35 f9 ff ff       	call   f0101096 <page_free>
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f0101761:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101768:	e8 b2 f8 ff ff       	call   f010101f <page_alloc>
f010176d:	89 c6                	mov    %eax,%esi
f010176f:	83 c4 10             	add    $0x10,%esp
f0101772:	85 c0                	test   %eax,%eax
f0101774:	75 19                	jne    f010178f <mem_init+0x31f>
f0101776:	68 bb 69 10 f0       	push   $0xf01069bb
f010177b:	68 98 68 10 f0       	push   $0xf0106898
f0101780:	68 44 03 00 00       	push   $0x344
f0101785:	68 72 68 10 f0       	push   $0xf0106872
f010178a:	e8 b1 e8 ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f010178f:	83 ec 0c             	sub    $0xc,%esp
f0101792:	6a 00                	push   $0x0
f0101794:	e8 86 f8 ff ff       	call   f010101f <page_alloc>
f0101799:	89 c7                	mov    %eax,%edi
f010179b:	83 c4 10             	add    $0x10,%esp
f010179e:	85 c0                	test   %eax,%eax
f01017a0:	75 19                	jne    f01017bb <mem_init+0x34b>
f01017a2:	68 d1 69 10 f0       	push   $0xf01069d1
f01017a7:	68 98 68 10 f0       	push   $0xf0106898
f01017ac:	68 45 03 00 00       	push   $0x345
f01017b1:	68 72 68 10 f0       	push   $0xf0106872
f01017b6:	e8 85 e8 ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f01017bb:	83 ec 0c             	sub    $0xc,%esp
f01017be:	6a 00                	push   $0x0
f01017c0:	e8 5a f8 ff ff       	call   f010101f <page_alloc>
f01017c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017c8:	83 c4 10             	add    $0x10,%esp
f01017cb:	85 c0                	test   %eax,%eax
f01017cd:	75 19                	jne    f01017e8 <mem_init+0x378>
f01017cf:	68 e7 69 10 f0       	push   $0xf01069e7
f01017d4:	68 98 68 10 f0       	push   $0xf0106898
f01017d9:	68 46 03 00 00       	push   $0x346
f01017de:	68 72 68 10 f0       	push   $0xf0106872
f01017e3:	e8 58 e8 ff ff       	call   f0100040 <_panic>
	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f01017e8:	39 fe                	cmp    %edi,%esi
f01017ea:	75 19                	jne    f0101805 <mem_init+0x395>
f01017ec:	68 fd 69 10 f0       	push   $0xf01069fd
f01017f1:	68 98 68 10 f0       	push   $0xf0106898
f01017f6:	68 48 03 00 00       	push   $0x348
f01017fb:	68 72 68 10 f0       	push   $0xf0106872
f0101800:	e8 3b e8 ff ff       	call   f0100040 <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101805:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101808:	39 c7                	cmp    %eax,%edi
f010180a:	74 04                	je     f0101810 <mem_init+0x3a0>
f010180c:	39 c6                	cmp    %eax,%esi
f010180e:	75 19                	jne    f0101829 <mem_init+0x3b9>
f0101810:	68 c0 6d 10 f0       	push   $0xf0106dc0
f0101815:	68 98 68 10 f0       	push   $0xf0106898
f010181a:	68 49 03 00 00       	push   $0x349
f010181f:	68 72 68 10 f0       	push   $0xf0106872
f0101824:	e8 17 e8 ff ff       	call   f0100040 <_panic>
	   assert(!page_alloc(0));
f0101829:	83 ec 0c             	sub    $0xc,%esp
f010182c:	6a 00                	push   $0x0
f010182e:	e8 ec f7 ff ff       	call   f010101f <page_alloc>
f0101833:	83 c4 10             	add    $0x10,%esp
f0101836:	85 c0                	test   %eax,%eax
f0101838:	74 19                	je     f0101853 <mem_init+0x3e3>
f010183a:	68 66 6a 10 f0       	push   $0xf0106a66
f010183f:	68 98 68 10 f0       	push   $0xf0106898
f0101844:	68 4a 03 00 00       	push   $0x34a
f0101849:	68 72 68 10 f0       	push   $0xf0106872
f010184e:	e8 ed e7 ff ff       	call   f0100040 <_panic>
f0101853:	89 f0                	mov    %esi,%eax
f0101855:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010185b:	c1 f8 03             	sar    $0x3,%eax
f010185e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101861:	89 c2                	mov    %eax,%edx
f0101863:	c1 ea 0c             	shr    $0xc,%edx
f0101866:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f010186c:	72 12                	jb     f0101880 <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010186e:	50                   	push   %eax
f010186f:	68 e4 62 10 f0       	push   $0xf01062e4
f0101874:	6a 58                	push   $0x58
f0101876:	68 7e 68 10 f0       	push   $0xf010687e
f010187b:	e8 c0 e7 ff ff       	call   f0100040 <_panic>

	   // test flags
	   memset(page2kva(pp0), 1, PGSIZE);
f0101880:	83 ec 04             	sub    $0x4,%esp
f0101883:	68 00 10 00 00       	push   $0x1000
f0101888:	6a 01                	push   $0x1
f010188a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010188f:	50                   	push   %eax
f0101890:	e8 6a 3d 00 00       	call   f01055ff <memset>
	   page_free(pp0);
f0101895:	89 34 24             	mov    %esi,(%esp)
f0101898:	e8 f9 f7 ff ff       	call   f0101096 <page_free>
	   assert((pp = page_alloc(ALLOC_ZERO)));
f010189d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018a4:	e8 76 f7 ff ff       	call   f010101f <page_alloc>
f01018a9:	83 c4 10             	add    $0x10,%esp
f01018ac:	85 c0                	test   %eax,%eax
f01018ae:	75 19                	jne    f01018c9 <mem_init+0x459>
f01018b0:	68 75 6a 10 f0       	push   $0xf0106a75
f01018b5:	68 98 68 10 f0       	push   $0xf0106898
f01018ba:	68 4f 03 00 00       	push   $0x34f
f01018bf:	68 72 68 10 f0       	push   $0xf0106872
f01018c4:	e8 77 e7 ff ff       	call   f0100040 <_panic>
	   assert(pp && pp0 == pp);
f01018c9:	39 c6                	cmp    %eax,%esi
f01018cb:	74 19                	je     f01018e6 <mem_init+0x476>
f01018cd:	68 93 6a 10 f0       	push   $0xf0106a93
f01018d2:	68 98 68 10 f0       	push   $0xf0106898
f01018d7:	68 50 03 00 00       	push   $0x350
f01018dc:	68 72 68 10 f0       	push   $0xf0106872
f01018e1:	e8 5a e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e6:	89 f0                	mov    %esi,%eax
f01018e8:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f01018ee:	c1 f8 03             	sar    $0x3,%eax
f01018f1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018f4:	89 c2                	mov    %eax,%edx
f01018f6:	c1 ea 0c             	shr    $0xc,%edx
f01018f9:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f01018ff:	72 12                	jb     f0101913 <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101901:	50                   	push   %eax
f0101902:	68 e4 62 10 f0       	push   $0xf01062e4
f0101907:	6a 58                	push   $0x58
f0101909:	68 7e 68 10 f0       	push   $0xf010687e
f010190e:	e8 2d e7 ff ff       	call   f0100040 <_panic>
f0101913:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101919:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	   c = page2kva(pp);
	   for (i = 0; i < PGSIZE; i++)
			 assert(c[i] == 0);
f010191f:	80 38 00             	cmpb   $0x0,(%eax)
f0101922:	74 19                	je     f010193d <mem_init+0x4cd>
f0101924:	68 a3 6a 10 f0       	push   $0xf0106aa3
f0101929:	68 98 68 10 f0       	push   $0xf0106898
f010192e:	68 53 03 00 00       	push   $0x353
f0101933:	68 72 68 10 f0       	push   $0xf0106872
f0101938:	e8 03 e7 ff ff       	call   f0100040 <_panic>
f010193d:	83 c0 01             	add    $0x1,%eax
	   memset(page2kva(pp0), 1, PGSIZE);
	   page_free(pp0);
	   assert((pp = page_alloc(ALLOC_ZERO)));
	   assert(pp && pp0 == pp);
	   c = page2kva(pp);
	   for (i = 0; i < PGSIZE; i++)
f0101940:	39 d0                	cmp    %edx,%eax
f0101942:	75 db                	jne    f010191f <mem_init+0x4af>
			 assert(c[i] == 0);

	   // give free list back
	   page_free_list = fl;
f0101944:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101947:	a3 40 22 21 f0       	mov    %eax,0xf0212240

	   // free the pages we took
	   page_free(pp0);
f010194c:	83 ec 0c             	sub    $0xc,%esp
f010194f:	56                   	push   %esi
f0101950:	e8 41 f7 ff ff       	call   f0101096 <page_free>
	   page_free(pp1);
f0101955:	89 3c 24             	mov    %edi,(%esp)
f0101958:	e8 39 f7 ff ff       	call   f0101096 <page_free>
	   page_free(pp2);
f010195d:	83 c4 04             	add    $0x4,%esp
f0101960:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101963:	e8 2e f7 ff ff       	call   f0101096 <page_free>

	   // number of free pages should be the same
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0101968:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f010196d:	83 c4 10             	add    $0x10,%esp
f0101970:	eb 05                	jmp    f0101977 <mem_init+0x507>
			 --nfree;
f0101972:	83 eb 01             	sub    $0x1,%ebx
	   page_free(pp0);
	   page_free(pp1);
	   page_free(pp2);

	   // number of free pages should be the same
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0101975:	8b 00                	mov    (%eax),%eax
f0101977:	85 c0                	test   %eax,%eax
f0101979:	75 f7                	jne    f0101972 <mem_init+0x502>
			 --nfree;
	   assert(nfree == 0);
f010197b:	85 db                	test   %ebx,%ebx
f010197d:	74 19                	je     f0101998 <mem_init+0x528>
f010197f:	68 ad 6a 10 f0       	push   $0xf0106aad
f0101984:	68 98 68 10 f0       	push   $0xf0106898
f0101989:	68 60 03 00 00       	push   $0x360
f010198e:	68 72 68 10 f0       	push   $0xf0106872
f0101993:	e8 a8 e6 ff ff       	call   f0100040 <_panic>

	   cprintf("check_page_alloc() succeeded!\n");
f0101998:	83 ec 0c             	sub    $0xc,%esp
f010199b:	68 e0 6d 10 f0       	push   $0xf0106de0
f01019a0:	e8 7f 1e 00 00       	call   f0103824 <cprintf>
	   int i;
	   extern pde_t entry_pgdir[];

	   // should be able to allocate three pages
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f01019a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019ac:	e8 6e f6 ff ff       	call   f010101f <page_alloc>
f01019b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019b4:	83 c4 10             	add    $0x10,%esp
f01019b7:	85 c0                	test   %eax,%eax
f01019b9:	75 19                	jne    f01019d4 <mem_init+0x564>
f01019bb:	68 bb 69 10 f0       	push   $0xf01069bb
f01019c0:	68 98 68 10 f0       	push   $0xf0106898
f01019c5:	68 c8 03 00 00       	push   $0x3c8
f01019ca:	68 72 68 10 f0       	push   $0xf0106872
f01019cf:	e8 6c e6 ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f01019d4:	83 ec 0c             	sub    $0xc,%esp
f01019d7:	6a 00                	push   $0x0
f01019d9:	e8 41 f6 ff ff       	call   f010101f <page_alloc>
f01019de:	89 c3                	mov    %eax,%ebx
f01019e0:	83 c4 10             	add    $0x10,%esp
f01019e3:	85 c0                	test   %eax,%eax
f01019e5:	75 19                	jne    f0101a00 <mem_init+0x590>
f01019e7:	68 d1 69 10 f0       	push   $0xf01069d1
f01019ec:	68 98 68 10 f0       	push   $0xf0106898
f01019f1:	68 c9 03 00 00       	push   $0x3c9
f01019f6:	68 72 68 10 f0       	push   $0xf0106872
f01019fb:	e8 40 e6 ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f0101a00:	83 ec 0c             	sub    $0xc,%esp
f0101a03:	6a 00                	push   $0x0
f0101a05:	e8 15 f6 ff ff       	call   f010101f <page_alloc>
f0101a0a:	89 c6                	mov    %eax,%esi
f0101a0c:	83 c4 10             	add    $0x10,%esp
f0101a0f:	85 c0                	test   %eax,%eax
f0101a11:	75 19                	jne    f0101a2c <mem_init+0x5bc>
f0101a13:	68 e7 69 10 f0       	push   $0xf01069e7
f0101a18:	68 98 68 10 f0       	push   $0xf0106898
f0101a1d:	68 ca 03 00 00       	push   $0x3ca
f0101a22:	68 72 68 10 f0       	push   $0xf0106872
f0101a27:	e8 14 e6 ff ff       	call   f0100040 <_panic>

	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f0101a2c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a2f:	75 19                	jne    f0101a4a <mem_init+0x5da>
f0101a31:	68 fd 69 10 f0       	push   $0xf01069fd
f0101a36:	68 98 68 10 f0       	push   $0xf0106898
f0101a3b:	68 cd 03 00 00       	push   $0x3cd
f0101a40:	68 72 68 10 f0       	push   $0xf0106872
f0101a45:	e8 f6 e5 ff ff       	call   f0100040 <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a4a:	39 c3                	cmp    %eax,%ebx
f0101a4c:	74 05                	je     f0101a53 <mem_init+0x5e3>
f0101a4e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a51:	75 19                	jne    f0101a6c <mem_init+0x5fc>
f0101a53:	68 c0 6d 10 f0       	push   $0xf0106dc0
f0101a58:	68 98 68 10 f0       	push   $0xf0106898
f0101a5d:	68 ce 03 00 00       	push   $0x3ce
f0101a62:	68 72 68 10 f0       	push   $0xf0106872
f0101a67:	e8 d4 e5 ff ff       	call   f0100040 <_panic>

	   // temporarily steal the rest of the free pages
	   fl = page_free_list;
f0101a6c:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0101a71:	89 45 d0             	mov    %eax,-0x30(%ebp)
	   page_free_list = 0;
f0101a74:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f0101a7b:	00 00 00 

	   // should be no free memory
	   assert(!page_alloc(0));
f0101a7e:	83 ec 0c             	sub    $0xc,%esp
f0101a81:	6a 00                	push   $0x0
f0101a83:	e8 97 f5 ff ff       	call   f010101f <page_alloc>
f0101a88:	83 c4 10             	add    $0x10,%esp
f0101a8b:	85 c0                	test   %eax,%eax
f0101a8d:	74 19                	je     f0101aa8 <mem_init+0x638>
f0101a8f:	68 66 6a 10 f0       	push   $0xf0106a66
f0101a94:	68 98 68 10 f0       	push   $0xf0106898
f0101a99:	68 d5 03 00 00       	push   $0x3d5
f0101a9e:	68 72 68 10 f0       	push   $0xf0106872
f0101aa3:	e8 98 e5 ff ff       	call   f0100040 <_panic>

	   // there is no page allocated at address 0
	   assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101aa8:	83 ec 04             	sub    $0x4,%esp
f0101aab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101aae:	50                   	push   %eax
f0101aaf:	6a 00                	push   $0x0
f0101ab1:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101ab7:	e8 73 f7 ff ff       	call   f010122f <page_lookup>
f0101abc:	83 c4 10             	add    $0x10,%esp
f0101abf:	85 c0                	test   %eax,%eax
f0101ac1:	74 19                	je     f0101adc <mem_init+0x66c>
f0101ac3:	68 00 6e 10 f0       	push   $0xf0106e00
f0101ac8:	68 98 68 10 f0       	push   $0xf0106898
f0101acd:	68 d8 03 00 00       	push   $0x3d8
f0101ad2:	68 72 68 10 f0       	push   $0xf0106872
f0101ad7:	e8 64 e5 ff ff       	call   f0100040 <_panic>

	   // there is no free memory, so we can't allocate a page table
	   assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101adc:	6a 02                	push   $0x2
f0101ade:	6a 00                	push   $0x0
f0101ae0:	53                   	push   %ebx
f0101ae1:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101ae7:	e8 2b f8 ff ff       	call   f0101317 <page_insert>
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	78 19                	js     f0101b0c <mem_init+0x69c>
f0101af3:	68 38 6e 10 f0       	push   $0xf0106e38
f0101af8:	68 98 68 10 f0       	push   $0xf0106898
f0101afd:	68 db 03 00 00       	push   $0x3db
f0101b02:	68 72 68 10 f0       	push   $0xf0106872
f0101b07:	e8 34 e5 ff ff       	call   f0100040 <_panic>

	   // free pp0 and try again: pp0 should be used for page table
	   page_free(pp0);
f0101b0c:	83 ec 0c             	sub    $0xc,%esp
f0101b0f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b12:	e8 7f f5 ff ff       	call   f0101096 <page_free>
	   assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b17:	6a 02                	push   $0x2
f0101b19:	6a 00                	push   $0x0
f0101b1b:	53                   	push   %ebx
f0101b1c:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101b22:	e8 f0 f7 ff ff       	call   f0101317 <page_insert>
f0101b27:	83 c4 20             	add    $0x20,%esp
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	74 19                	je     f0101b47 <mem_init+0x6d7>
f0101b2e:	68 68 6e 10 f0       	push   $0xf0106e68
f0101b33:	68 98 68 10 f0       	push   $0xf0106898
f0101b38:	68 df 03 00 00       	push   $0x3df
f0101b3d:	68 72 68 10 f0       	push   $0xf0106872
f0101b42:	e8 f9 e4 ff ff       	call   f0100040 <_panic>
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b47:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b4d:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
f0101b52:	89 c1                	mov    %eax,%ecx
f0101b54:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b57:	8b 17                	mov    (%edi),%edx
f0101b59:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b5f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b62:	29 c8                	sub    %ecx,%eax
f0101b64:	c1 f8 03             	sar    $0x3,%eax
f0101b67:	c1 e0 0c             	shl    $0xc,%eax
f0101b6a:	39 c2                	cmp    %eax,%edx
f0101b6c:	74 19                	je     f0101b87 <mem_init+0x717>
f0101b6e:	68 98 6e 10 f0       	push   $0xf0106e98
f0101b73:	68 98 68 10 f0       	push   $0xf0106898
f0101b78:	68 e0 03 00 00       	push   $0x3e0
f0101b7d:	68 72 68 10 f0       	push   $0xf0106872
f0101b82:	e8 b9 e4 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b87:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b8c:	89 f8                	mov    %edi,%eax
f0101b8e:	e8 9f ef ff ff       	call   f0100b32 <check_va2pa>
f0101b93:	89 da                	mov    %ebx,%edx
f0101b95:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b98:	c1 fa 03             	sar    $0x3,%edx
f0101b9b:	c1 e2 0c             	shl    $0xc,%edx
f0101b9e:	39 d0                	cmp    %edx,%eax
f0101ba0:	74 19                	je     f0101bbb <mem_init+0x74b>
f0101ba2:	68 c0 6e 10 f0       	push   $0xf0106ec0
f0101ba7:	68 98 68 10 f0       	push   $0xf0106898
f0101bac:	68 e1 03 00 00       	push   $0x3e1
f0101bb1:	68 72 68 10 f0       	push   $0xf0106872
f0101bb6:	e8 85 e4 ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 1);
f0101bbb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bc0:	74 19                	je     f0101bdb <mem_init+0x76b>
f0101bc2:	68 b8 6a 10 f0       	push   $0xf0106ab8
f0101bc7:	68 98 68 10 f0       	push   $0xf0106898
f0101bcc:	68 e2 03 00 00       	push   $0x3e2
f0101bd1:	68 72 68 10 f0       	push   $0xf0106872
f0101bd6:	e8 65 e4 ff ff       	call   f0100040 <_panic>
	   assert(pp0->pp_ref == 1);
f0101bdb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bde:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101be3:	74 19                	je     f0101bfe <mem_init+0x78e>
f0101be5:	68 c9 6a 10 f0       	push   $0xf0106ac9
f0101bea:	68 98 68 10 f0       	push   $0xf0106898
f0101bef:	68 e3 03 00 00       	push   $0x3e3
f0101bf4:	68 72 68 10 f0       	push   $0xf0106872
f0101bf9:	e8 42 e4 ff ff       	call   f0100040 <_panic>

	   // should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bfe:	6a 02                	push   $0x2
f0101c00:	68 00 10 00 00       	push   $0x1000
f0101c05:	56                   	push   %esi
f0101c06:	57                   	push   %edi
f0101c07:	e8 0b f7 ff ff       	call   f0101317 <page_insert>
f0101c0c:	83 c4 10             	add    $0x10,%esp
f0101c0f:	85 c0                	test   %eax,%eax
f0101c11:	74 19                	je     f0101c2c <mem_init+0x7bc>
f0101c13:	68 f0 6e 10 f0       	push   $0xf0106ef0
f0101c18:	68 98 68 10 f0       	push   $0xf0106898
f0101c1d:	68 e6 03 00 00       	push   $0x3e6
f0101c22:	68 72 68 10 f0       	push   $0xf0106872
f0101c27:	e8 14 e4 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c2c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c31:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101c36:	e8 f7 ee ff ff       	call   f0100b32 <check_va2pa>
f0101c3b:	89 f2                	mov    %esi,%edx
f0101c3d:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101c43:	c1 fa 03             	sar    $0x3,%edx
f0101c46:	c1 e2 0c             	shl    $0xc,%edx
f0101c49:	39 d0                	cmp    %edx,%eax
f0101c4b:	74 19                	je     f0101c66 <mem_init+0x7f6>
f0101c4d:	68 2c 6f 10 f0       	push   $0xf0106f2c
f0101c52:	68 98 68 10 f0       	push   $0xf0106898
f0101c57:	68 e7 03 00 00       	push   $0x3e7
f0101c5c:	68 72 68 10 f0       	push   $0xf0106872
f0101c61:	e8 da e3 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0101c66:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c6b:	74 19                	je     f0101c86 <mem_init+0x816>
f0101c6d:	68 da 6a 10 f0       	push   $0xf0106ada
f0101c72:	68 98 68 10 f0       	push   $0xf0106898
f0101c77:	68 e8 03 00 00       	push   $0x3e8
f0101c7c:	68 72 68 10 f0       	push   $0xf0106872
f0101c81:	e8 ba e3 ff ff       	call   f0100040 <_panic>

	   // should be no free memory
	   assert(!page_alloc(0));
f0101c86:	83 ec 0c             	sub    $0xc,%esp
f0101c89:	6a 00                	push   $0x0
f0101c8b:	e8 8f f3 ff ff       	call   f010101f <page_alloc>
f0101c90:	83 c4 10             	add    $0x10,%esp
f0101c93:	85 c0                	test   %eax,%eax
f0101c95:	74 19                	je     f0101cb0 <mem_init+0x840>
f0101c97:	68 66 6a 10 f0       	push   $0xf0106a66
f0101c9c:	68 98 68 10 f0       	push   $0xf0106898
f0101ca1:	68 eb 03 00 00       	push   $0x3eb
f0101ca6:	68 72 68 10 f0       	push   $0xf0106872
f0101cab:	e8 90 e3 ff ff       	call   f0100040 <_panic>

	   // should be able to map pp2 at PGSIZE because it's already there
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cb0:	6a 02                	push   $0x2
f0101cb2:	68 00 10 00 00       	push   $0x1000
f0101cb7:	56                   	push   %esi
f0101cb8:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101cbe:	e8 54 f6 ff ff       	call   f0101317 <page_insert>
f0101cc3:	83 c4 10             	add    $0x10,%esp
f0101cc6:	85 c0                	test   %eax,%eax
f0101cc8:	74 19                	je     f0101ce3 <mem_init+0x873>
f0101cca:	68 f0 6e 10 f0       	push   $0xf0106ef0
f0101ccf:	68 98 68 10 f0       	push   $0xf0106898
f0101cd4:	68 ee 03 00 00       	push   $0x3ee
f0101cd9:	68 72 68 10 f0       	push   $0xf0106872
f0101cde:	e8 5d e3 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ce3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce8:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101ced:	e8 40 ee ff ff       	call   f0100b32 <check_va2pa>
f0101cf2:	89 f2                	mov    %esi,%edx
f0101cf4:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101cfa:	c1 fa 03             	sar    $0x3,%edx
f0101cfd:	c1 e2 0c             	shl    $0xc,%edx
f0101d00:	39 d0                	cmp    %edx,%eax
f0101d02:	74 19                	je     f0101d1d <mem_init+0x8ad>
f0101d04:	68 2c 6f 10 f0       	push   $0xf0106f2c
f0101d09:	68 98 68 10 f0       	push   $0xf0106898
f0101d0e:	68 ef 03 00 00       	push   $0x3ef
f0101d13:	68 72 68 10 f0       	push   $0xf0106872
f0101d18:	e8 23 e3 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0101d1d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d22:	74 19                	je     f0101d3d <mem_init+0x8cd>
f0101d24:	68 da 6a 10 f0       	push   $0xf0106ada
f0101d29:	68 98 68 10 f0       	push   $0xf0106898
f0101d2e:	68 f0 03 00 00       	push   $0x3f0
f0101d33:	68 72 68 10 f0       	push   $0xf0106872
f0101d38:	e8 03 e3 ff ff       	call   f0100040 <_panic>

	   // pp2 should NOT be on the free list
	   // could happen in ref counts are handled sloppily in page_insert
	   assert(!page_alloc(0));
f0101d3d:	83 ec 0c             	sub    $0xc,%esp
f0101d40:	6a 00                	push   $0x0
f0101d42:	e8 d8 f2 ff ff       	call   f010101f <page_alloc>
f0101d47:	83 c4 10             	add    $0x10,%esp
f0101d4a:	85 c0                	test   %eax,%eax
f0101d4c:	74 19                	je     f0101d67 <mem_init+0x8f7>
f0101d4e:	68 66 6a 10 f0       	push   $0xf0106a66
f0101d53:	68 98 68 10 f0       	push   $0xf0106898
f0101d58:	68 f4 03 00 00       	push   $0x3f4
f0101d5d:	68 72 68 10 f0       	push   $0xf0106872
f0101d62:	e8 d9 e2 ff ff       	call   f0100040 <_panic>

	   // check that pgdir_walk returns a pointer to the pte
	   ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d67:	8b 15 8c 2e 21 f0    	mov    0xf0212e8c,%edx
f0101d6d:	8b 02                	mov    (%edx),%eax
f0101d6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d74:	89 c1                	mov    %eax,%ecx
f0101d76:	c1 e9 0c             	shr    $0xc,%ecx
f0101d79:	3b 0d 88 2e 21 f0    	cmp    0xf0212e88,%ecx
f0101d7f:	72 15                	jb     f0101d96 <mem_init+0x926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d81:	50                   	push   %eax
f0101d82:	68 e4 62 10 f0       	push   $0xf01062e4
f0101d87:	68 f7 03 00 00       	push   $0x3f7
f0101d8c:	68 72 68 10 f0       	push   $0xf0106872
f0101d91:	e8 aa e2 ff ff       	call   f0100040 <_panic>
f0101d96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d9e:	83 ec 04             	sub    $0x4,%esp
f0101da1:	6a 00                	push   $0x0
f0101da3:	68 00 10 00 00       	push   $0x1000
f0101da8:	52                   	push   %edx
f0101da9:	e8 6b f3 ff ff       	call   f0101119 <pgdir_walk>
f0101dae:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101db1:	8d 51 04             	lea    0x4(%ecx),%edx
f0101db4:	83 c4 10             	add    $0x10,%esp
f0101db7:	39 d0                	cmp    %edx,%eax
f0101db9:	74 19                	je     f0101dd4 <mem_init+0x964>
f0101dbb:	68 5c 6f 10 f0       	push   $0xf0106f5c
f0101dc0:	68 98 68 10 f0       	push   $0xf0106898
f0101dc5:	68 f8 03 00 00       	push   $0x3f8
f0101dca:	68 72 68 10 f0       	push   $0xf0106872
f0101dcf:	e8 6c e2 ff ff       	call   f0100040 <_panic>

	   // should be able to change permissions too.
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101dd4:	6a 06                	push   $0x6
f0101dd6:	68 00 10 00 00       	push   $0x1000
f0101ddb:	56                   	push   %esi
f0101ddc:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101de2:	e8 30 f5 ff ff       	call   f0101317 <page_insert>
f0101de7:	83 c4 10             	add    $0x10,%esp
f0101dea:	85 c0                	test   %eax,%eax
f0101dec:	74 19                	je     f0101e07 <mem_init+0x997>
f0101dee:	68 9c 6f 10 f0       	push   $0xf0106f9c
f0101df3:	68 98 68 10 f0       	push   $0xf0106898
f0101df8:	68 fb 03 00 00       	push   $0x3fb
f0101dfd:	68 72 68 10 f0       	push   $0xf0106872
f0101e02:	e8 39 e2 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e07:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0101e0d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e12:	89 f8                	mov    %edi,%eax
f0101e14:	e8 19 ed ff ff       	call   f0100b32 <check_va2pa>
f0101e19:	89 f2                	mov    %esi,%edx
f0101e1b:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101e21:	c1 fa 03             	sar    $0x3,%edx
f0101e24:	c1 e2 0c             	shl    $0xc,%edx
f0101e27:	39 d0                	cmp    %edx,%eax
f0101e29:	74 19                	je     f0101e44 <mem_init+0x9d4>
f0101e2b:	68 2c 6f 10 f0       	push   $0xf0106f2c
f0101e30:	68 98 68 10 f0       	push   $0xf0106898
f0101e35:	68 fc 03 00 00       	push   $0x3fc
f0101e3a:	68 72 68 10 f0       	push   $0xf0106872
f0101e3f:	e8 fc e1 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0101e44:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e49:	74 19                	je     f0101e64 <mem_init+0x9f4>
f0101e4b:	68 da 6a 10 f0       	push   $0xf0106ada
f0101e50:	68 98 68 10 f0       	push   $0xf0106898
f0101e55:	68 fd 03 00 00       	push   $0x3fd
f0101e5a:	68 72 68 10 f0       	push   $0xf0106872
f0101e5f:	e8 dc e1 ff ff       	call   f0100040 <_panic>
	   assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e64:	83 ec 04             	sub    $0x4,%esp
f0101e67:	6a 00                	push   $0x0
f0101e69:	68 00 10 00 00       	push   $0x1000
f0101e6e:	57                   	push   %edi
f0101e6f:	e8 a5 f2 ff ff       	call   f0101119 <pgdir_walk>
f0101e74:	83 c4 10             	add    $0x10,%esp
f0101e77:	f6 00 04             	testb  $0x4,(%eax)
f0101e7a:	75 19                	jne    f0101e95 <mem_init+0xa25>
f0101e7c:	68 dc 6f 10 f0       	push   $0xf0106fdc
f0101e81:	68 98 68 10 f0       	push   $0xf0106898
f0101e86:	68 fe 03 00 00       	push   $0x3fe
f0101e8b:	68 72 68 10 f0       	push   $0xf0106872
f0101e90:	e8 ab e1 ff ff       	call   f0100040 <_panic>
	   assert(kern_pgdir[0] & PTE_U);
f0101e95:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101e9a:	f6 00 04             	testb  $0x4,(%eax)
f0101e9d:	75 19                	jne    f0101eb8 <mem_init+0xa48>
f0101e9f:	68 eb 6a 10 f0       	push   $0xf0106aeb
f0101ea4:	68 98 68 10 f0       	push   $0xf0106898
f0101ea9:	68 ff 03 00 00       	push   $0x3ff
f0101eae:	68 72 68 10 f0       	push   $0xf0106872
f0101eb3:	e8 88 e1 ff ff       	call   f0100040 <_panic>

	   // should be able to remap with fewer permissions
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101eb8:	6a 02                	push   $0x2
f0101eba:	68 00 10 00 00       	push   $0x1000
f0101ebf:	56                   	push   %esi
f0101ec0:	50                   	push   %eax
f0101ec1:	e8 51 f4 ff ff       	call   f0101317 <page_insert>
f0101ec6:	83 c4 10             	add    $0x10,%esp
f0101ec9:	85 c0                	test   %eax,%eax
f0101ecb:	74 19                	je     f0101ee6 <mem_init+0xa76>
f0101ecd:	68 f0 6e 10 f0       	push   $0xf0106ef0
f0101ed2:	68 98 68 10 f0       	push   $0xf0106898
f0101ed7:	68 02 04 00 00       	push   $0x402
f0101edc:	68 72 68 10 f0       	push   $0xf0106872
f0101ee1:	e8 5a e1 ff ff       	call   f0100040 <_panic>
	   assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ee6:	83 ec 04             	sub    $0x4,%esp
f0101ee9:	6a 00                	push   $0x0
f0101eeb:	68 00 10 00 00       	push   $0x1000
f0101ef0:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101ef6:	e8 1e f2 ff ff       	call   f0101119 <pgdir_walk>
f0101efb:	83 c4 10             	add    $0x10,%esp
f0101efe:	f6 00 02             	testb  $0x2,(%eax)
f0101f01:	75 19                	jne    f0101f1c <mem_init+0xaac>
f0101f03:	68 10 70 10 f0       	push   $0xf0107010
f0101f08:	68 98 68 10 f0       	push   $0xf0106898
f0101f0d:	68 03 04 00 00       	push   $0x403
f0101f12:	68 72 68 10 f0       	push   $0xf0106872
f0101f17:	e8 24 e1 ff ff       	call   f0100040 <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f1c:	83 ec 04             	sub    $0x4,%esp
f0101f1f:	6a 00                	push   $0x0
f0101f21:	68 00 10 00 00       	push   $0x1000
f0101f26:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f2c:	e8 e8 f1 ff ff       	call   f0101119 <pgdir_walk>
f0101f31:	83 c4 10             	add    $0x10,%esp
f0101f34:	f6 00 04             	testb  $0x4,(%eax)
f0101f37:	74 19                	je     f0101f52 <mem_init+0xae2>
f0101f39:	68 44 70 10 f0       	push   $0xf0107044
f0101f3e:	68 98 68 10 f0       	push   $0xf0106898
f0101f43:	68 04 04 00 00       	push   $0x404
f0101f48:	68 72 68 10 f0       	push   $0xf0106872
f0101f4d:	e8 ee e0 ff ff       	call   f0100040 <_panic>

	   // should not be able to map at PTSIZE because need free page for page table
	   assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f52:	6a 02                	push   $0x2
f0101f54:	68 00 00 40 00       	push   $0x400000
f0101f59:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f5c:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f62:	e8 b0 f3 ff ff       	call   f0101317 <page_insert>
f0101f67:	83 c4 10             	add    $0x10,%esp
f0101f6a:	85 c0                	test   %eax,%eax
f0101f6c:	78 19                	js     f0101f87 <mem_init+0xb17>
f0101f6e:	68 7c 70 10 f0       	push   $0xf010707c
f0101f73:	68 98 68 10 f0       	push   $0xf0106898
f0101f78:	68 07 04 00 00       	push   $0x407
f0101f7d:	68 72 68 10 f0       	push   $0xf0106872
f0101f82:	e8 b9 e0 ff ff       	call   f0100040 <_panic>

	   // insert pp1 at PGSIZE (replacing pp2)
	   assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f87:	6a 02                	push   $0x2
f0101f89:	68 00 10 00 00       	push   $0x1000
f0101f8e:	53                   	push   %ebx
f0101f8f:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f95:	e8 7d f3 ff ff       	call   f0101317 <page_insert>
f0101f9a:	83 c4 10             	add    $0x10,%esp
f0101f9d:	85 c0                	test   %eax,%eax
f0101f9f:	74 19                	je     f0101fba <mem_init+0xb4a>
f0101fa1:	68 b4 70 10 f0       	push   $0xf01070b4
f0101fa6:	68 98 68 10 f0       	push   $0xf0106898
f0101fab:	68 0a 04 00 00       	push   $0x40a
f0101fb0:	68 72 68 10 f0       	push   $0xf0106872
f0101fb5:	e8 86 e0 ff ff       	call   f0100040 <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fba:	83 ec 04             	sub    $0x4,%esp
f0101fbd:	6a 00                	push   $0x0
f0101fbf:	68 00 10 00 00       	push   $0x1000
f0101fc4:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101fca:	e8 4a f1 ff ff       	call   f0101119 <pgdir_walk>
f0101fcf:	83 c4 10             	add    $0x10,%esp
f0101fd2:	f6 00 04             	testb  $0x4,(%eax)
f0101fd5:	74 19                	je     f0101ff0 <mem_init+0xb80>
f0101fd7:	68 44 70 10 f0       	push   $0xf0107044
f0101fdc:	68 98 68 10 f0       	push   $0xf0106898
f0101fe1:	68 0b 04 00 00       	push   $0x40b
f0101fe6:	68 72 68 10 f0       	push   $0xf0106872
f0101feb:	e8 50 e0 ff ff       	call   f0100040 <_panic>

	   // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	   assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ff0:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0101ff6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ffb:	89 f8                	mov    %edi,%eax
f0101ffd:	e8 30 eb ff ff       	call   f0100b32 <check_va2pa>
f0102002:	89 c1                	mov    %eax,%ecx
f0102004:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102007:	89 d8                	mov    %ebx,%eax
f0102009:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010200f:	c1 f8 03             	sar    $0x3,%eax
f0102012:	c1 e0 0c             	shl    $0xc,%eax
f0102015:	39 c1                	cmp    %eax,%ecx
f0102017:	74 19                	je     f0102032 <mem_init+0xbc2>
f0102019:	68 f0 70 10 f0       	push   $0xf01070f0
f010201e:	68 98 68 10 f0       	push   $0xf0106898
f0102023:	68 0e 04 00 00       	push   $0x40e
f0102028:	68 72 68 10 f0       	push   $0xf0106872
f010202d:	e8 0e e0 ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102032:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102037:	89 f8                	mov    %edi,%eax
f0102039:	e8 f4 ea ff ff       	call   f0100b32 <check_va2pa>
f010203e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102041:	74 19                	je     f010205c <mem_init+0xbec>
f0102043:	68 1c 71 10 f0       	push   $0xf010711c
f0102048:	68 98 68 10 f0       	push   $0xf0106898
f010204d:	68 0f 04 00 00       	push   $0x40f
f0102052:	68 72 68 10 f0       	push   $0xf0106872
f0102057:	e8 e4 df ff ff       	call   f0100040 <_panic>
	   // ... and ref counts should reflect this
	   assert(pp1->pp_ref == 2);
f010205c:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102061:	74 19                	je     f010207c <mem_init+0xc0c>
f0102063:	68 01 6b 10 f0       	push   $0xf0106b01
f0102068:	68 98 68 10 f0       	push   $0xf0106898
f010206d:	68 11 04 00 00       	push   $0x411
f0102072:	68 72 68 10 f0       	push   $0xf0106872
f0102077:	e8 c4 df ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 0);
f010207c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102081:	74 19                	je     f010209c <mem_init+0xc2c>
f0102083:	68 12 6b 10 f0       	push   $0xf0106b12
f0102088:	68 98 68 10 f0       	push   $0xf0106898
f010208d:	68 12 04 00 00       	push   $0x412
f0102092:	68 72 68 10 f0       	push   $0xf0106872
f0102097:	e8 a4 df ff ff       	call   f0100040 <_panic>

	   // pp2 should be returned by page_alloc
	   assert((pp = page_alloc(0)) && pp == pp2);
f010209c:	83 ec 0c             	sub    $0xc,%esp
f010209f:	6a 00                	push   $0x0
f01020a1:	e8 79 ef ff ff       	call   f010101f <page_alloc>
f01020a6:	83 c4 10             	add    $0x10,%esp
f01020a9:	85 c0                	test   %eax,%eax
f01020ab:	74 04                	je     f01020b1 <mem_init+0xc41>
f01020ad:	39 c6                	cmp    %eax,%esi
f01020af:	74 19                	je     f01020ca <mem_init+0xc5a>
f01020b1:	68 4c 71 10 f0       	push   $0xf010714c
f01020b6:	68 98 68 10 f0       	push   $0xf0106898
f01020bb:	68 15 04 00 00       	push   $0x415
f01020c0:	68 72 68 10 f0       	push   $0xf0106872
f01020c5:	e8 76 df ff ff       	call   f0100040 <_panic>

	   // unmapping pp1 at 0 should keep pp1 at PGSIZE
	   page_remove(kern_pgdir, 0x0);
f01020ca:	83 ec 08             	sub    $0x8,%esp
f01020cd:	6a 00                	push   $0x0
f01020cf:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01020d5:	e8 f0 f1 ff ff       	call   f01012ca <page_remove>
	   assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020da:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f01020e0:	ba 00 00 00 00       	mov    $0x0,%edx
f01020e5:	89 f8                	mov    %edi,%eax
f01020e7:	e8 46 ea ff ff       	call   f0100b32 <check_va2pa>
f01020ec:	83 c4 10             	add    $0x10,%esp
f01020ef:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020f2:	74 19                	je     f010210d <mem_init+0xc9d>
f01020f4:	68 70 71 10 f0       	push   $0xf0107170
f01020f9:	68 98 68 10 f0       	push   $0xf0106898
f01020fe:	68 19 04 00 00       	push   $0x419
f0102103:	68 72 68 10 f0       	push   $0xf0106872
f0102108:	e8 33 df ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010210d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102112:	89 f8                	mov    %edi,%eax
f0102114:	e8 19 ea ff ff       	call   f0100b32 <check_va2pa>
f0102119:	89 da                	mov    %ebx,%edx
f010211b:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0102121:	c1 fa 03             	sar    $0x3,%edx
f0102124:	c1 e2 0c             	shl    $0xc,%edx
f0102127:	39 d0                	cmp    %edx,%eax
f0102129:	74 19                	je     f0102144 <mem_init+0xcd4>
f010212b:	68 1c 71 10 f0       	push   $0xf010711c
f0102130:	68 98 68 10 f0       	push   $0xf0106898
f0102135:	68 1a 04 00 00       	push   $0x41a
f010213a:	68 72 68 10 f0       	push   $0xf0106872
f010213f:	e8 fc de ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 1);
f0102144:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102149:	74 19                	je     f0102164 <mem_init+0xcf4>
f010214b:	68 b8 6a 10 f0       	push   $0xf0106ab8
f0102150:	68 98 68 10 f0       	push   $0xf0106898
f0102155:	68 1b 04 00 00       	push   $0x41b
f010215a:	68 72 68 10 f0       	push   $0xf0106872
f010215f:	e8 dc de ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 0);
f0102164:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102169:	74 19                	je     f0102184 <mem_init+0xd14>
f010216b:	68 12 6b 10 f0       	push   $0xf0106b12
f0102170:	68 98 68 10 f0       	push   $0xf0106898
f0102175:	68 1c 04 00 00       	push   $0x41c
f010217a:	68 72 68 10 f0       	push   $0xf0106872
f010217f:	e8 bc de ff ff       	call   f0100040 <_panic>

	   // test re-inserting pp1 at PGSIZE
	   assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102184:	6a 00                	push   $0x0
f0102186:	68 00 10 00 00       	push   $0x1000
f010218b:	53                   	push   %ebx
f010218c:	57                   	push   %edi
f010218d:	e8 85 f1 ff ff       	call   f0101317 <page_insert>
f0102192:	83 c4 10             	add    $0x10,%esp
f0102195:	85 c0                	test   %eax,%eax
f0102197:	74 19                	je     f01021b2 <mem_init+0xd42>
f0102199:	68 94 71 10 f0       	push   $0xf0107194
f010219e:	68 98 68 10 f0       	push   $0xf0106898
f01021a3:	68 1f 04 00 00       	push   $0x41f
f01021a8:	68 72 68 10 f0       	push   $0xf0106872
f01021ad:	e8 8e de ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref);
f01021b2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021b7:	75 19                	jne    f01021d2 <mem_init+0xd62>
f01021b9:	68 23 6b 10 f0       	push   $0xf0106b23
f01021be:	68 98 68 10 f0       	push   $0xf0106898
f01021c3:	68 20 04 00 00       	push   $0x420
f01021c8:	68 72 68 10 f0       	push   $0xf0106872
f01021cd:	e8 6e de ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_link == NULL);
f01021d2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01021d5:	74 19                	je     f01021f0 <mem_init+0xd80>
f01021d7:	68 2f 6b 10 f0       	push   $0xf0106b2f
f01021dc:	68 98 68 10 f0       	push   $0xf0106898
f01021e1:	68 21 04 00 00       	push   $0x421
f01021e6:	68 72 68 10 f0       	push   $0xf0106872
f01021eb:	e8 50 de ff ff       	call   f0100040 <_panic>

	   // unmapping pp1 at PGSIZE should free it
	   page_remove(kern_pgdir, (void*) PGSIZE);
f01021f0:	83 ec 08             	sub    $0x8,%esp
f01021f3:	68 00 10 00 00       	push   $0x1000
f01021f8:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01021fe:	e8 c7 f0 ff ff       	call   f01012ca <page_remove>
	   assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102203:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0102209:	ba 00 00 00 00       	mov    $0x0,%edx
f010220e:	89 f8                	mov    %edi,%eax
f0102210:	e8 1d e9 ff ff       	call   f0100b32 <check_va2pa>
f0102215:	83 c4 10             	add    $0x10,%esp
f0102218:	83 f8 ff             	cmp    $0xffffffff,%eax
f010221b:	74 19                	je     f0102236 <mem_init+0xdc6>
f010221d:	68 70 71 10 f0       	push   $0xf0107170
f0102222:	68 98 68 10 f0       	push   $0xf0106898
f0102227:	68 25 04 00 00       	push   $0x425
f010222c:	68 72 68 10 f0       	push   $0xf0106872
f0102231:	e8 0a de ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102236:	ba 00 10 00 00       	mov    $0x1000,%edx
f010223b:	89 f8                	mov    %edi,%eax
f010223d:	e8 f0 e8 ff ff       	call   f0100b32 <check_va2pa>
f0102242:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102245:	74 19                	je     f0102260 <mem_init+0xdf0>
f0102247:	68 cc 71 10 f0       	push   $0xf01071cc
f010224c:	68 98 68 10 f0       	push   $0xf0106898
f0102251:	68 26 04 00 00       	push   $0x426
f0102256:	68 72 68 10 f0       	push   $0xf0106872
f010225b:	e8 e0 dd ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 0);
f0102260:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102265:	74 19                	je     f0102280 <mem_init+0xe10>
f0102267:	68 44 6b 10 f0       	push   $0xf0106b44
f010226c:	68 98 68 10 f0       	push   $0xf0106898
f0102271:	68 27 04 00 00       	push   $0x427
f0102276:	68 72 68 10 f0       	push   $0xf0106872
f010227b:	e8 c0 dd ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 0);
f0102280:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102285:	74 19                	je     f01022a0 <mem_init+0xe30>
f0102287:	68 12 6b 10 f0       	push   $0xf0106b12
f010228c:	68 98 68 10 f0       	push   $0xf0106898
f0102291:	68 28 04 00 00       	push   $0x428
f0102296:	68 72 68 10 f0       	push   $0xf0106872
f010229b:	e8 a0 dd ff ff       	call   f0100040 <_panic>

	   // so it should be returned by page_alloc
	   assert((pp = page_alloc(0)) && pp == pp1);
f01022a0:	83 ec 0c             	sub    $0xc,%esp
f01022a3:	6a 00                	push   $0x0
f01022a5:	e8 75 ed ff ff       	call   f010101f <page_alloc>
f01022aa:	83 c4 10             	add    $0x10,%esp
f01022ad:	39 c3                	cmp    %eax,%ebx
f01022af:	75 04                	jne    f01022b5 <mem_init+0xe45>
f01022b1:	85 c0                	test   %eax,%eax
f01022b3:	75 19                	jne    f01022ce <mem_init+0xe5e>
f01022b5:	68 f4 71 10 f0       	push   $0xf01071f4
f01022ba:	68 98 68 10 f0       	push   $0xf0106898
f01022bf:	68 2b 04 00 00       	push   $0x42b
f01022c4:	68 72 68 10 f0       	push   $0xf0106872
f01022c9:	e8 72 dd ff ff       	call   f0100040 <_panic>

	   // should be no free memory
	   assert(!page_alloc(0));
f01022ce:	83 ec 0c             	sub    $0xc,%esp
f01022d1:	6a 00                	push   $0x0
f01022d3:	e8 47 ed ff ff       	call   f010101f <page_alloc>
f01022d8:	83 c4 10             	add    $0x10,%esp
f01022db:	85 c0                	test   %eax,%eax
f01022dd:	74 19                	je     f01022f8 <mem_init+0xe88>
f01022df:	68 66 6a 10 f0       	push   $0xf0106a66
f01022e4:	68 98 68 10 f0       	push   $0xf0106898
f01022e9:	68 2e 04 00 00       	push   $0x42e
f01022ee:	68 72 68 10 f0       	push   $0xf0106872
f01022f3:	e8 48 dd ff ff       	call   f0100040 <_panic>

	   // forcibly take pp0 back
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022f8:	8b 0d 8c 2e 21 f0    	mov    0xf0212e8c,%ecx
f01022fe:	8b 11                	mov    (%ecx),%edx
f0102300:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102306:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102309:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010230f:	c1 f8 03             	sar    $0x3,%eax
f0102312:	c1 e0 0c             	shl    $0xc,%eax
f0102315:	39 c2                	cmp    %eax,%edx
f0102317:	74 19                	je     f0102332 <mem_init+0xec2>
f0102319:	68 98 6e 10 f0       	push   $0xf0106e98
f010231e:	68 98 68 10 f0       	push   $0xf0106898
f0102323:	68 31 04 00 00       	push   $0x431
f0102328:	68 72 68 10 f0       	push   $0xf0106872
f010232d:	e8 0e dd ff ff       	call   f0100040 <_panic>
	   kern_pgdir[0] = 0;
f0102332:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	   assert(pp0->pp_ref == 1);
f0102338:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010233b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102340:	74 19                	je     f010235b <mem_init+0xeeb>
f0102342:	68 c9 6a 10 f0       	push   $0xf0106ac9
f0102347:	68 98 68 10 f0       	push   $0xf0106898
f010234c:	68 33 04 00 00       	push   $0x433
f0102351:	68 72 68 10 f0       	push   $0xf0106872
f0102356:	e8 e5 dc ff ff       	call   f0100040 <_panic>
	   pp0->pp_ref = 0;
f010235b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010235e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	   // check pointer arithmetic in pgdir_walk
	   page_free(pp0);
f0102364:	83 ec 0c             	sub    $0xc,%esp
f0102367:	50                   	push   %eax
f0102368:	e8 29 ed ff ff       	call   f0101096 <page_free>
	   va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	   ptep = pgdir_walk(kern_pgdir, va, 1);
f010236d:	83 c4 0c             	add    $0xc,%esp
f0102370:	6a 01                	push   $0x1
f0102372:	68 00 10 40 00       	push   $0x401000
f0102377:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f010237d:	e8 97 ed ff ff       	call   f0101119 <pgdir_walk>
f0102382:	89 c7                	mov    %eax,%edi
f0102384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102387:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f010238c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010238f:	8b 40 04             	mov    0x4(%eax),%eax
f0102392:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102397:	8b 0d 88 2e 21 f0    	mov    0xf0212e88,%ecx
f010239d:	89 c2                	mov    %eax,%edx
f010239f:	c1 ea 0c             	shr    $0xc,%edx
f01023a2:	83 c4 10             	add    $0x10,%esp
f01023a5:	39 ca                	cmp    %ecx,%edx
f01023a7:	72 15                	jb     f01023be <mem_init+0xf4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023a9:	50                   	push   %eax
f01023aa:	68 e4 62 10 f0       	push   $0xf01062e4
f01023af:	68 3a 04 00 00       	push   $0x43a
f01023b4:	68 72 68 10 f0       	push   $0xf0106872
f01023b9:	e8 82 dc ff ff       	call   f0100040 <_panic>
	   assert(ptep == ptep1 + PTX(va));
f01023be:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01023c3:	39 c7                	cmp    %eax,%edi
f01023c5:	74 19                	je     f01023e0 <mem_init+0xf70>
f01023c7:	68 55 6b 10 f0       	push   $0xf0106b55
f01023cc:	68 98 68 10 f0       	push   $0xf0106898
f01023d1:	68 3b 04 00 00       	push   $0x43b
f01023d6:	68 72 68 10 f0       	push   $0xf0106872
f01023db:	e8 60 dc ff ff       	call   f0100040 <_panic>
	   kern_pgdir[PDX(va)] = 0;
f01023e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01023e3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	   pp0->pp_ref = 0;
f01023ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023ed:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023f3:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f01023f9:	c1 f8 03             	sar    $0x3,%eax
f01023fc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023ff:	89 c2                	mov    %eax,%edx
f0102401:	c1 ea 0c             	shr    $0xc,%edx
f0102404:	39 d1                	cmp    %edx,%ecx
f0102406:	77 12                	ja     f010241a <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102408:	50                   	push   %eax
f0102409:	68 e4 62 10 f0       	push   $0xf01062e4
f010240e:	6a 58                	push   $0x58
f0102410:	68 7e 68 10 f0       	push   $0xf010687e
f0102415:	e8 26 dc ff ff       	call   f0100040 <_panic>

	   // check that new page tables get cleared
	   memset(page2kva(pp0), 0xFF, PGSIZE);
f010241a:	83 ec 04             	sub    $0x4,%esp
f010241d:	68 00 10 00 00       	push   $0x1000
f0102422:	68 ff 00 00 00       	push   $0xff
f0102427:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010242c:	50                   	push   %eax
f010242d:	e8 cd 31 00 00       	call   f01055ff <memset>
	   page_free(pp0);
f0102432:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102435:	89 3c 24             	mov    %edi,(%esp)
f0102438:	e8 59 ec ff ff       	call   f0101096 <page_free>
	   pgdir_walk(kern_pgdir, 0x0, 1);
f010243d:	83 c4 0c             	add    $0xc,%esp
f0102440:	6a 01                	push   $0x1
f0102442:	6a 00                	push   $0x0
f0102444:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f010244a:	e8 ca ec ff ff       	call   f0101119 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010244f:	89 fa                	mov    %edi,%edx
f0102451:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0102457:	c1 fa 03             	sar    $0x3,%edx
f010245a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010245d:	89 d0                	mov    %edx,%eax
f010245f:	c1 e8 0c             	shr    $0xc,%eax
f0102462:	83 c4 10             	add    $0x10,%esp
f0102465:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f010246b:	72 12                	jb     f010247f <mem_init+0x100f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010246d:	52                   	push   %edx
f010246e:	68 e4 62 10 f0       	push   $0xf01062e4
f0102473:	6a 58                	push   $0x58
f0102475:	68 7e 68 10 f0       	push   $0xf010687e
f010247a:	e8 c1 db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010247f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	   ptep = (pte_t *) page2kva(pp0);
f0102485:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102488:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	   for(i=0; i<NPTENTRIES; i++)
			 assert((ptep[i] & PTE_P) == 0);
f010248e:	f6 00 01             	testb  $0x1,(%eax)
f0102491:	74 19                	je     f01024ac <mem_init+0x103c>
f0102493:	68 6d 6b 10 f0       	push   $0xf0106b6d
f0102498:	68 98 68 10 f0       	push   $0xf0106898
f010249d:	68 45 04 00 00       	push   $0x445
f01024a2:	68 72 68 10 f0       	push   $0xf0106872
f01024a7:	e8 94 db ff ff       	call   f0100040 <_panic>
f01024ac:	83 c0 04             	add    $0x4,%eax
	   // check that new page tables get cleared
	   memset(page2kva(pp0), 0xFF, PGSIZE);
	   page_free(pp0);
	   pgdir_walk(kern_pgdir, 0x0, 1);
	   ptep = (pte_t *) page2kva(pp0);
	   for(i=0; i<NPTENTRIES; i++)
f01024af:	39 d0                	cmp    %edx,%eax
f01024b1:	75 db                	jne    f010248e <mem_init+0x101e>
			 assert((ptep[i] & PTE_P) == 0);
	   kern_pgdir[0] = 0;
f01024b3:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01024b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   pp0->pp_ref = 0;
f01024be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024c1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	   // give free list back
	   page_free_list = fl;
f01024c7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01024ca:	89 0d 40 22 21 f0    	mov    %ecx,0xf0212240

	   // free the pages we took
	   page_free(pp0);
f01024d0:	83 ec 0c             	sub    $0xc,%esp
f01024d3:	50                   	push   %eax
f01024d4:	e8 bd eb ff ff       	call   f0101096 <page_free>
	   page_free(pp1);
f01024d9:	89 1c 24             	mov    %ebx,(%esp)
f01024dc:	e8 b5 eb ff ff       	call   f0101096 <page_free>
	   page_free(pp2);
f01024e1:	89 34 24             	mov    %esi,(%esp)
f01024e4:	e8 ad eb ff ff       	call   f0101096 <page_free>

	   // test mmio_map_region
	   mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01024e9:	83 c4 08             	add    $0x8,%esp
f01024ec:	68 01 10 00 00       	push   $0x1001
f01024f1:	6a 00                	push   $0x0
f01024f3:	e8 f3 ee ff ff       	call   f01013eb <mmio_map_region>
f01024f8:	89 c3                	mov    %eax,%ebx
	   mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01024fa:	83 c4 08             	add    $0x8,%esp
f01024fd:	68 00 10 00 00       	push   $0x1000
f0102502:	6a 00                	push   $0x0
f0102504:	e8 e2 ee ff ff       	call   f01013eb <mmio_map_region>
f0102509:	89 c6                	mov    %eax,%esi
	   // check that they're in the right region
	   assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010250b:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102511:	83 c4 10             	add    $0x10,%esp
f0102514:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010251a:	76 07                	jbe    f0102523 <mem_init+0x10b3>
f010251c:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102521:	76 19                	jbe    f010253c <mem_init+0x10cc>
f0102523:	68 18 72 10 f0       	push   $0xf0107218
f0102528:	68 98 68 10 f0       	push   $0xf0106898
f010252d:	68 55 04 00 00       	push   $0x455
f0102532:	68 72 68 10 f0       	push   $0xf0106872
f0102537:	e8 04 db ff ff       	call   f0100040 <_panic>
	   assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010253c:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102542:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102548:	77 08                	ja     f0102552 <mem_init+0x10e2>
f010254a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102550:	77 19                	ja     f010256b <mem_init+0x10fb>
f0102552:	68 40 72 10 f0       	push   $0xf0107240
f0102557:	68 98 68 10 f0       	push   $0xf0106898
f010255c:	68 56 04 00 00       	push   $0x456
f0102561:	68 72 68 10 f0       	push   $0xf0106872
f0102566:	e8 d5 da ff ff       	call   f0100040 <_panic>
	   // check that they're page-aligned
	   assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010256b:	89 da                	mov    %ebx,%edx
f010256d:	09 f2                	or     %esi,%edx
f010256f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102575:	74 19                	je     f0102590 <mem_init+0x1120>
f0102577:	68 68 72 10 f0       	push   $0xf0107268
f010257c:	68 98 68 10 f0       	push   $0xf0106898
f0102581:	68 58 04 00 00       	push   $0x458
f0102586:	68 72 68 10 f0       	push   $0xf0106872
f010258b:	e8 b0 da ff ff       	call   f0100040 <_panic>
	   // check that they don't overlap
	   assert(mm1 + 8192 <= mm2);
f0102590:	39 c6                	cmp    %eax,%esi
f0102592:	73 19                	jae    f01025ad <mem_init+0x113d>
f0102594:	68 84 6b 10 f0       	push   $0xf0106b84
f0102599:	68 98 68 10 f0       	push   $0xf0106898
f010259e:	68 5a 04 00 00       	push   $0x45a
f01025a3:	68 72 68 10 f0       	push   $0xf0106872
f01025a8:	e8 93 da ff ff       	call   f0100040 <_panic>
	   // check page mappings
	   assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025ad:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f01025b3:	89 da                	mov    %ebx,%edx
f01025b5:	89 f8                	mov    %edi,%eax
f01025b7:	e8 76 e5 ff ff       	call   f0100b32 <check_va2pa>
f01025bc:	85 c0                	test   %eax,%eax
f01025be:	74 19                	je     f01025d9 <mem_init+0x1169>
f01025c0:	68 90 72 10 f0       	push   $0xf0107290
f01025c5:	68 98 68 10 f0       	push   $0xf0106898
f01025ca:	68 5c 04 00 00       	push   $0x45c
f01025cf:	68 72 68 10 f0       	push   $0xf0106872
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01025d9:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01025df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025e2:	89 c2                	mov    %eax,%edx
f01025e4:	89 f8                	mov    %edi,%eax
f01025e6:	e8 47 e5 ff ff       	call   f0100b32 <check_va2pa>
f01025eb:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01025f0:	74 19                	je     f010260b <mem_init+0x119b>
f01025f2:	68 b4 72 10 f0       	push   $0xf01072b4
f01025f7:	68 98 68 10 f0       	push   $0xf0106898
f01025fc:	68 5d 04 00 00       	push   $0x45d
f0102601:	68 72 68 10 f0       	push   $0xf0106872
f0102606:	e8 35 da ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, mm2) == 0);
f010260b:	89 f2                	mov    %esi,%edx
f010260d:	89 f8                	mov    %edi,%eax
f010260f:	e8 1e e5 ff ff       	call   f0100b32 <check_va2pa>
f0102614:	85 c0                	test   %eax,%eax
f0102616:	74 19                	je     f0102631 <mem_init+0x11c1>
f0102618:	68 e4 72 10 f0       	push   $0xf01072e4
f010261d:	68 98 68 10 f0       	push   $0xf0106898
f0102622:	68 5e 04 00 00       	push   $0x45e
f0102627:	68 72 68 10 f0       	push   $0xf0106872
f010262c:	e8 0f da ff ff       	call   f0100040 <_panic>
	   assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102631:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102637:	89 f8                	mov    %edi,%eax
f0102639:	e8 f4 e4 ff ff       	call   f0100b32 <check_va2pa>
f010263e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102641:	74 19                	je     f010265c <mem_init+0x11ec>
f0102643:	68 08 73 10 f0       	push   $0xf0107308
f0102648:	68 98 68 10 f0       	push   $0xf0106898
f010264d:	68 5f 04 00 00       	push   $0x45f
f0102652:	68 72 68 10 f0       	push   $0xf0106872
f0102657:	e8 e4 d9 ff ff       	call   f0100040 <_panic>
	   // check permissions
	   assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010265c:	83 ec 04             	sub    $0x4,%esp
f010265f:	6a 00                	push   $0x0
f0102661:	53                   	push   %ebx
f0102662:	57                   	push   %edi
f0102663:	e8 b1 ea ff ff       	call   f0101119 <pgdir_walk>
f0102668:	83 c4 10             	add    $0x10,%esp
f010266b:	f6 00 1a             	testb  $0x1a,(%eax)
f010266e:	75 19                	jne    f0102689 <mem_init+0x1219>
f0102670:	68 34 73 10 f0       	push   $0xf0107334
f0102675:	68 98 68 10 f0       	push   $0xf0106898
f010267a:	68 61 04 00 00       	push   $0x461
f010267f:	68 72 68 10 f0       	push   $0xf0106872
f0102684:	e8 b7 d9 ff ff       	call   f0100040 <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102689:	83 ec 04             	sub    $0x4,%esp
f010268c:	6a 00                	push   $0x0
f010268e:	53                   	push   %ebx
f010268f:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102695:	e8 7f ea ff ff       	call   f0101119 <pgdir_walk>
f010269a:	8b 00                	mov    (%eax),%eax
f010269c:	83 c4 10             	add    $0x10,%esp
f010269f:	83 e0 04             	and    $0x4,%eax
f01026a2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026a5:	74 19                	je     f01026c0 <mem_init+0x1250>
f01026a7:	68 78 73 10 f0       	push   $0xf0107378
f01026ac:	68 98 68 10 f0       	push   $0xf0106898
f01026b1:	68 62 04 00 00       	push   $0x462
f01026b6:	68 72 68 10 f0       	push   $0xf0106872
f01026bb:	e8 80 d9 ff ff       	call   f0100040 <_panic>
	   // clear the mappings
	   *pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01026c0:	83 ec 04             	sub    $0x4,%esp
f01026c3:	6a 00                	push   $0x0
f01026c5:	53                   	push   %ebx
f01026c6:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01026cc:	e8 48 ea ff ff       	call   f0101119 <pgdir_walk>
f01026d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   *pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01026d7:	83 c4 0c             	add    $0xc,%esp
f01026da:	6a 00                	push   $0x0
f01026dc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01026df:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01026e5:	e8 2f ea ff ff       	call   f0101119 <pgdir_walk>
f01026ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   *pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01026f0:	83 c4 0c             	add    $0xc,%esp
f01026f3:	6a 00                	push   $0x0
f01026f5:	56                   	push   %esi
f01026f6:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01026fc:	e8 18 ea ff ff       	call   f0101119 <pgdir_walk>
f0102701:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	   cprintf("check_page() succeeded!\n");
f0102707:	c7 04 24 96 6b 10 f0 	movl   $0xf0106b96,(%esp)
f010270e:	e8 11 11 00 00       	call   f0103824 <cprintf>
	   //    - the new image at UPAGES -- kernel R, user R
	   //      (ie. perm = PTE_U | PTE_P)
	   //    - pages itself -- kernel RW, user NONE
	   // Your code goes here:

	   boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102713:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102718:	83 c4 10             	add    $0x10,%esp
f010271b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102720:	77 15                	ja     f0102737 <mem_init+0x12c7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102722:	50                   	push   %eax
f0102723:	68 08 63 10 f0       	push   $0xf0106308
f0102728:	68 ca 00 00 00       	push   $0xca
f010272d:	68 72 68 10 f0       	push   $0xf0106872
f0102732:	e8 09 d9 ff ff       	call   f0100040 <_panic>
f0102737:	83 ec 08             	sub    $0x8,%esp
f010273a:	6a 05                	push   $0x5
f010273c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102741:	50                   	push   %eax
f0102742:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102747:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010274c:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0102751:	e8 60 ea ff ff       	call   f01011b6 <boot_map_region>
	   // (ie. perm = PTE_U | PTE_P).
	   // Permissions:
	   //    - the new image at UENVS  -- kernel R, user R
	   //    - envs itself -- kernel RW, user NONE
	   // LAB 3: Your code here.
	   boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f0102756:	a1 48 22 21 f0       	mov    0xf0212248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010275b:	83 c4 10             	add    $0x10,%esp
f010275e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102763:	77 15                	ja     f010277a <mem_init+0x130a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102765:	50                   	push   %eax
f0102766:	68 08 63 10 f0       	push   $0xf0106308
f010276b:	68 d3 00 00 00       	push   $0xd3
f0102770:	68 72 68 10 f0       	push   $0xf0106872
f0102775:	e8 c6 d8 ff ff       	call   f0100040 <_panic>
f010277a:	83 ec 08             	sub    $0x8,%esp
f010277d:	6a 05                	push   $0x5
f010277f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102784:	50                   	push   %eax
f0102785:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010278a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010278f:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0102794:	e8 1d ea ff ff       	call   f01011b6 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102799:	83 c4 10             	add    $0x10,%esp
f010279c:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01027a1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027a6:	77 15                	ja     f01027bd <mem_init+0x134d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a8:	50                   	push   %eax
f01027a9:	68 08 63 10 f0       	push   $0xf0106308
f01027ae:	68 e1 00 00 00       	push   $0xe1
f01027b3:	68 72 68 10 f0       	push   $0xf0106872
f01027b8:	e8 83 d8 ff ff       	call   f0100040 <_panic>
	   //       the kernel overflows its stack, it will fault rather than
	   //       overwrite memory.  Known as a "guard page".
	   //     Permissions: kernel RW, user NONE
	   // Your code goes here:
	   uintptr_t address = KSTACKTOP - KSTKSIZE;
	   boot_map_region (kern_pgdir, address, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01027bd:	83 ec 08             	sub    $0x8,%esp
f01027c0:	6a 03                	push   $0x3
f01027c2:	68 00 60 11 00       	push   $0x116000
f01027c7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027cc:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027d1:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01027d6:	e8 db e9 ff ff       	call   f01011b6 <boot_map_region>
	   // We might not have 2^32 - KERNBASE bytes of physical memory, but
	   // we just set up the mapping anyway.
	   // Permissions: kernel RW, user NONE
	   // Your code goes here:
	   uint32_t pa_range = 0xFFFFFFFF - KERNBASE +1;
	   boot_map_region (kern_pgdir, KERNBASE, pa_range, 0, PTE_W | PTE_P);
f01027db:	83 c4 08             	add    $0x8,%esp
f01027de:	6a 03                	push   $0x3
f01027e0:	6a 00                	push   $0x0
f01027e2:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027e7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027ec:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01027f1:	e8 c0 e9 ff ff       	call   f01011b6 <boot_map_region>
f01027f6:	c7 45 c4 00 40 21 f0 	movl   $0xf0214000,-0x3c(%ebp)
f01027fd:	83 c4 10             	add    $0x10,%esp
f0102800:	bb 00 40 21 f0       	mov    $0xf0214000,%ebx
f0102805:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010280a:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102810:	77 15                	ja     f0102827 <mem_init+0x13b7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102812:	53                   	push   %ebx
f0102813:	68 08 63 10 f0       	push   $0xf0106308
f0102818:	68 24 01 00 00       	push   $0x124
f010281d:	68 72 68 10 f0       	push   $0xf0106872
f0102822:	e8 19 d8 ff ff       	call   f0100040 <_panic>
	   //
	   // LAB 4: Your code here:
		 for (int i = 0; i < NCPU; i ++)
		 {
		 uintptr_t stack_start = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
		 boot_map_region (kern_pgdir, stack_start - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f0102827:	83 ec 08             	sub    $0x8,%esp
f010282a:	6a 03                	push   $0x3
f010282c:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102832:	50                   	push   %eax
f0102833:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102838:	89 f2                	mov    %esi,%edx
f010283a:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f010283f:	e8 72 e9 ff ff       	call   f01011b6 <boot_map_region>
f0102844:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010284a:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	   //             it will fault rather than overwrite another CPU's stack.
	   //             Known as a "guard page".
	   //     Permissions: kernel RW, user NONE
	   //
	   // LAB 4: Your code here:
		 for (int i = 0; i < NCPU; i ++)
f0102850:	83 c4 10             	add    $0x10,%esp
f0102853:	b8 00 40 25 f0       	mov    $0xf0254000,%eax
f0102858:	39 d8                	cmp    %ebx,%eax
f010285a:	75 ae                	jne    f010280a <mem_init+0x139a>
{

	   uint32_t i, n;
	   pde_t *pgdir;

	   pgdir = kern_pgdir;
f010285c:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102862:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f0102867:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010286a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102871:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102876:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102879:	8b 35 90 2e 21 f0    	mov    0xf0212e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010287f:	89 75 d0             	mov    %esi,-0x30(%ebp)

	   pgdir = kern_pgdir;

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f0102882:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102887:	eb 55                	jmp    f01028de <mem_init+0x146e>
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102889:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010288f:	89 f8                	mov    %edi,%eax
f0102891:	e8 9c e2 ff ff       	call   f0100b32 <check_va2pa>
f0102896:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010289d:	77 15                	ja     f01028b4 <mem_init+0x1444>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010289f:	56                   	push   %esi
f01028a0:	68 08 63 10 f0       	push   $0xf0106308
f01028a5:	68 79 03 00 00       	push   $0x379
f01028aa:	68 72 68 10 f0       	push   $0xf0106872
f01028af:	e8 8c d7 ff ff       	call   f0100040 <_panic>
f01028b4:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01028bb:	39 c2                	cmp    %eax,%edx
f01028bd:	74 19                	je     f01028d8 <mem_init+0x1468>
f01028bf:	68 ac 73 10 f0       	push   $0xf01073ac
f01028c4:	68 98 68 10 f0       	push   $0xf0106898
f01028c9:	68 79 03 00 00       	push   $0x379
f01028ce:	68 72 68 10 f0       	push   $0xf0106872
f01028d3:	e8 68 d7 ff ff       	call   f0100040 <_panic>

	   pgdir = kern_pgdir;

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f01028d8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028de:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01028e1:	77 a6                	ja     f0102889 <mem_init+0x1419>
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	   // check envs array (new test for lab 3)
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028e3:	8b 35 48 22 21 f0    	mov    0xf0212248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028e9:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028ec:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028f1:	89 da                	mov    %ebx,%edx
f01028f3:	89 f8                	mov    %edi,%eax
f01028f5:	e8 38 e2 ff ff       	call   f0100b32 <check_va2pa>
f01028fa:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102901:	77 15                	ja     f0102918 <mem_init+0x14a8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102903:	56                   	push   %esi
f0102904:	68 08 63 10 f0       	push   $0xf0106308
f0102909:	68 7e 03 00 00       	push   $0x37e
f010290e:	68 72 68 10 f0       	push   $0xf0106872
f0102913:	e8 28 d7 ff ff       	call   f0100040 <_panic>
f0102918:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010291f:	39 d0                	cmp    %edx,%eax
f0102921:	74 19                	je     f010293c <mem_init+0x14cc>
f0102923:	68 e0 73 10 f0       	push   $0xf01073e0
f0102928:	68 98 68 10 f0       	push   $0xf0106898
f010292d:	68 7e 03 00 00       	push   $0x37e
f0102932:	68 72 68 10 f0       	push   $0xf0106872
f0102937:	e8 04 d7 ff ff       	call   f0100040 <_panic>
f010293c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	   // check envs array (new test for lab 3)
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f0102942:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102948:	75 a7                	jne    f01028f1 <mem_init+0x1481>
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	   // check phys mem
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010294a:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010294d:	c1 e6 0c             	shl    $0xc,%esi
f0102950:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102955:	eb 30                	jmp    f0102987 <mem_init+0x1517>
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102957:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010295d:	89 f8                	mov    %edi,%eax
f010295f:	e8 ce e1 ff ff       	call   f0100b32 <check_va2pa>
f0102964:	39 c3                	cmp    %eax,%ebx
f0102966:	74 19                	je     f0102981 <mem_init+0x1511>
f0102968:	68 14 74 10 f0       	push   $0xf0107414
f010296d:	68 98 68 10 f0       	push   $0xf0106898
f0102972:	68 82 03 00 00       	push   $0x382
f0102977:	68 72 68 10 f0       	push   $0xf0106872
f010297c:	e8 bf d6 ff ff       	call   f0100040 <_panic>
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	   // check phys mem
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102981:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102987:	39 f3                	cmp    %esi,%ebx
f0102989:	72 cc                	jb     f0102957 <mem_init+0x14e7>
f010298b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102990:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102993:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102996:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102999:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010299f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01029a2:	89 c3                	mov    %eax,%ebx
	   // check kernel stack
	   // (updated in lab 4 to check per-CPU kernel stacks)
	   for (n = 0; n < NCPU; n++) {
			 uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
			 for (i = 0; i < KSTKSIZE; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029a7:	05 00 80 00 20       	add    $0x20008000,%eax
f01029ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01029af:	89 da                	mov    %ebx,%edx
f01029b1:	89 f8                	mov    %edi,%eax
f01029b3:	e8 7a e1 ff ff       	call   f0100b32 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029b8:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029be:	77 15                	ja     f01029d5 <mem_init+0x1565>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029c0:	56                   	push   %esi
f01029c1:	68 08 63 10 f0       	push   $0xf0106308
f01029c6:	68 8a 03 00 00       	push   $0x38a
f01029cb:	68 72 68 10 f0       	push   $0xf0106872
f01029d0:	e8 6b d6 ff ff       	call   f0100040 <_panic>
f01029d5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01029d8:	8d 94 0b 00 40 21 f0 	lea    -0xfdec000(%ebx,%ecx,1),%edx
f01029df:	39 d0                	cmp    %edx,%eax
f01029e1:	74 19                	je     f01029fc <mem_init+0x158c>
f01029e3:	68 3c 74 10 f0       	push   $0xf010743c
f01029e8:	68 98 68 10 f0       	push   $0xf0106898
f01029ed:	68 8a 03 00 00       	push   $0x38a
f01029f2:	68 72 68 10 f0       	push   $0xf0106872
f01029f7:	e8 44 d6 ff ff       	call   f0100040 <_panic>
f01029fc:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	   // check kernel stack
	   // (updated in lab 4 to check per-CPU kernel stacks)
	   for (n = 0; n < NCPU; n++) {
			 uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
			 for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a02:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102a05:	75 a8                	jne    f01029af <mem_init+0x153f>
f0102a07:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a0a:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102a10:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102a13:	89 c6                	mov    %eax,%esi
				    assert(check_va2pa(pgdir, base + KSTKGAP + i)
								== PADDR(percpu_kstacks[n]) + i);
			 for (i = 0; i < KSTKGAP; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + i) == ~0);
f0102a15:	89 da                	mov    %ebx,%edx
f0102a17:	89 f8                	mov    %edi,%eax
f0102a19:	e8 14 e1 ff ff       	call   f0100b32 <check_va2pa>
f0102a1e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a21:	74 19                	je     f0102a3c <mem_init+0x15cc>
f0102a23:	68 84 74 10 f0       	push   $0xf0107484
f0102a28:	68 98 68 10 f0       	push   $0xf0106898
f0102a2d:	68 8c 03 00 00       	push   $0x38c
f0102a32:	68 72 68 10 f0       	push   $0xf0106872
f0102a37:	e8 04 d6 ff ff       	call   f0100040 <_panic>
f0102a3c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	   for (n = 0; n < NCPU; n++) {
			 uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
			 for (i = 0; i < KSTKSIZE; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + KSTKGAP + i)
								== PADDR(percpu_kstacks[n]) + i);
			 for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a42:	39 f3                	cmp    %esi,%ebx
f0102a44:	75 cf                	jne    f0102a15 <mem_init+0x15a5>
f0102a46:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102a49:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102a50:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102a57:	81 c6 00 80 00 00    	add    $0x8000,%esi
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);

	   // check kernel stack
	   // (updated in lab 4 to check per-CPU kernel stacks)
	   for (n = 0; n < NCPU; n++) {
f0102a5d:	b8 00 40 25 f0       	mov    $0xf0254000,%eax
f0102a62:	39 f0                	cmp    %esi,%eax
f0102a64:	0f 85 2c ff ff ff    	jne    f0102996 <mem_init+0x1526>
f0102a6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a6f:	eb 2a                	jmp    f0102a9b <mem_init+0x162b>
				    assert(check_va2pa(pgdir, base + i) == ~0);
	   }

	   // check PDE permissions
	   for (i = 0; i < NPDENTRIES; i++) {
			 switch (i) {
f0102a71:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a77:	83 fa 04             	cmp    $0x4,%edx
f0102a7a:	77 1f                	ja     f0102a9b <mem_init+0x162b>
				    case PDX(UVPT):
				    case PDX(KSTACKTOP-1):
				    case PDX(UPAGES):
				    case PDX(UENVS):
				    case PDX(MMIOBASE):
						  assert(pgdir[i] & PTE_P);
f0102a7c:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a80:	75 7e                	jne    f0102b00 <mem_init+0x1690>
f0102a82:	68 af 6b 10 f0       	push   $0xf0106baf
f0102a87:	68 98 68 10 f0       	push   $0xf0106898
f0102a8c:	68 97 03 00 00       	push   $0x397
f0102a91:	68 72 68 10 f0       	push   $0xf0106872
f0102a96:	e8 a5 d5 ff ff       	call   f0100040 <_panic>
						  break;
				    default:
						  if (i >= PDX(KERNBASE)) {
f0102a9b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102aa0:	76 3f                	jbe    f0102ae1 <mem_init+0x1671>
								assert(pgdir[i] & PTE_P);
f0102aa2:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102aa5:	f6 c2 01             	test   $0x1,%dl
f0102aa8:	75 19                	jne    f0102ac3 <mem_init+0x1653>
f0102aaa:	68 af 6b 10 f0       	push   $0xf0106baf
f0102aaf:	68 98 68 10 f0       	push   $0xf0106898
f0102ab4:	68 9b 03 00 00       	push   $0x39b
f0102ab9:	68 72 68 10 f0       	push   $0xf0106872
f0102abe:	e8 7d d5 ff ff       	call   f0100040 <_panic>
								assert(pgdir[i] & PTE_W);
f0102ac3:	f6 c2 02             	test   $0x2,%dl
f0102ac6:	75 38                	jne    f0102b00 <mem_init+0x1690>
f0102ac8:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0102acd:	68 98 68 10 f0       	push   $0xf0106898
f0102ad2:	68 9c 03 00 00       	push   $0x39c
f0102ad7:	68 72 68 10 f0       	push   $0xf0106872
f0102adc:	e8 5f d5 ff ff       	call   f0100040 <_panic>
						  } else
								assert(pgdir[i] == 0);
f0102ae1:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ae5:	74 19                	je     f0102b00 <mem_init+0x1690>
f0102ae7:	68 d1 6b 10 f0       	push   $0xf0106bd1
f0102aec:	68 98 68 10 f0       	push   $0xf0106898
f0102af1:	68 9e 03 00 00       	push   $0x39e
f0102af6:	68 72 68 10 f0       	push   $0xf0106872
f0102afb:	e8 40 d5 ff ff       	call   f0100040 <_panic>
			 for (i = 0; i < KSTKGAP; i += PGSIZE)
				    assert(check_va2pa(pgdir, base + i) == ~0);
	   }

	   // check PDE permissions
	   for (i = 0; i < NPDENTRIES; i++) {
f0102b00:	83 c0 01             	add    $0x1,%eax
f0102b03:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102b08:	0f 86 63 ff ff ff    	jbe    f0102a71 <mem_init+0x1601>
						  } else
								assert(pgdir[i] == 0);
						  break;
			 }
	   }
	   cprintf("check_kern_pgdir() succeeded!\n");
f0102b0e:	83 ec 0c             	sub    $0xc,%esp
f0102b11:	68 a8 74 10 f0       	push   $0xf01074a8
f0102b16:	e8 09 0d 00 00       	call   f0103824 <cprintf>
	   // somewhere between KERNBASE and KERNBASE+4MB right now, which is
	   // mapped the same way by both page tables.
	   //
	   // If the machine reboots at this point, you've probably set up your
	   // kern_pgdir wrong.
	   lcr3(PADDR(kern_pgdir));
f0102b1b:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b20:	83 c4 10             	add    $0x10,%esp
f0102b23:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b28:	77 15                	ja     f0102b3f <mem_init+0x16cf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2a:	50                   	push   %eax
f0102b2b:	68 08 63 10 f0       	push   $0xf0106308
f0102b30:	68 fc 00 00 00       	push   $0xfc
f0102b35:	68 72 68 10 f0       	push   $0xf0106872
f0102b3a:	e8 01 d5 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b3f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b44:	0f 22 d8             	mov    %eax,%cr3

	   check_page_free_list(0);
f0102b47:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b4c:	e8 45 e0 ff ff       	call   f0100b96 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b51:	0f 20 c0             	mov    %cr0,%eax
f0102b54:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b57:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b5c:	0f 22 c0             	mov    %eax,%cr0
	   uintptr_t va;
	   int i;

	   // check that we can read and write installed pages
	   pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f0102b5f:	83 ec 0c             	sub    $0xc,%esp
f0102b62:	6a 00                	push   $0x0
f0102b64:	e8 b6 e4 ff ff       	call   f010101f <page_alloc>
f0102b69:	89 c3                	mov    %eax,%ebx
f0102b6b:	83 c4 10             	add    $0x10,%esp
f0102b6e:	85 c0                	test   %eax,%eax
f0102b70:	75 19                	jne    f0102b8b <mem_init+0x171b>
f0102b72:	68 bb 69 10 f0       	push   $0xf01069bb
f0102b77:	68 98 68 10 f0       	push   $0xf0106898
f0102b7c:	68 77 04 00 00       	push   $0x477
f0102b81:	68 72 68 10 f0       	push   $0xf0106872
f0102b86:	e8 b5 d4 ff ff       	call   f0100040 <_panic>
	   assert((pp1 = page_alloc(0)));
f0102b8b:	83 ec 0c             	sub    $0xc,%esp
f0102b8e:	6a 00                	push   $0x0
f0102b90:	e8 8a e4 ff ff       	call   f010101f <page_alloc>
f0102b95:	89 c7                	mov    %eax,%edi
f0102b97:	83 c4 10             	add    $0x10,%esp
f0102b9a:	85 c0                	test   %eax,%eax
f0102b9c:	75 19                	jne    f0102bb7 <mem_init+0x1747>
f0102b9e:	68 d1 69 10 f0       	push   $0xf01069d1
f0102ba3:	68 98 68 10 f0       	push   $0xf0106898
f0102ba8:	68 78 04 00 00       	push   $0x478
f0102bad:	68 72 68 10 f0       	push   $0xf0106872
f0102bb2:	e8 89 d4 ff ff       	call   f0100040 <_panic>
	   assert((pp2 = page_alloc(0)));
f0102bb7:	83 ec 0c             	sub    $0xc,%esp
f0102bba:	6a 00                	push   $0x0
f0102bbc:	e8 5e e4 ff ff       	call   f010101f <page_alloc>
f0102bc1:	89 c6                	mov    %eax,%esi
f0102bc3:	83 c4 10             	add    $0x10,%esp
f0102bc6:	85 c0                	test   %eax,%eax
f0102bc8:	75 19                	jne    f0102be3 <mem_init+0x1773>
f0102bca:	68 e7 69 10 f0       	push   $0xf01069e7
f0102bcf:	68 98 68 10 f0       	push   $0xf0106898
f0102bd4:	68 79 04 00 00       	push   $0x479
f0102bd9:	68 72 68 10 f0       	push   $0xf0106872
f0102bde:	e8 5d d4 ff ff       	call   f0100040 <_panic>
	   page_free(pp0);
f0102be3:	83 ec 0c             	sub    $0xc,%esp
f0102be6:	53                   	push   %ebx
f0102be7:	e8 aa e4 ff ff       	call   f0101096 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bec:	89 f8                	mov    %edi,%eax
f0102bee:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102bf4:	c1 f8 03             	sar    $0x3,%eax
f0102bf7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bfa:	89 c2                	mov    %eax,%edx
f0102bfc:	c1 ea 0c             	shr    $0xc,%edx
f0102bff:	83 c4 10             	add    $0x10,%esp
f0102c02:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102c08:	72 12                	jb     f0102c1c <mem_init+0x17ac>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0a:	50                   	push   %eax
f0102c0b:	68 e4 62 10 f0       	push   $0xf01062e4
f0102c10:	6a 58                	push   $0x58
f0102c12:	68 7e 68 10 f0       	push   $0xf010687e
f0102c17:	e8 24 d4 ff ff       	call   f0100040 <_panic>
	   memset(page2kva(pp1), 1, PGSIZE);
f0102c1c:	83 ec 04             	sub    $0x4,%esp
f0102c1f:	68 00 10 00 00       	push   $0x1000
f0102c24:	6a 01                	push   $0x1
f0102c26:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c2b:	50                   	push   %eax
f0102c2c:	e8 ce 29 00 00       	call   f01055ff <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c31:	89 f0                	mov    %esi,%eax
f0102c33:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102c39:	c1 f8 03             	sar    $0x3,%eax
f0102c3c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c3f:	89 c2                	mov    %eax,%edx
f0102c41:	c1 ea 0c             	shr    $0xc,%edx
f0102c44:	83 c4 10             	add    $0x10,%esp
f0102c47:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102c4d:	72 12                	jb     f0102c61 <mem_init+0x17f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c4f:	50                   	push   %eax
f0102c50:	68 e4 62 10 f0       	push   $0xf01062e4
f0102c55:	6a 58                	push   $0x58
f0102c57:	68 7e 68 10 f0       	push   $0xf010687e
f0102c5c:	e8 df d3 ff ff       	call   f0100040 <_panic>
	   memset(page2kva(pp2), 2, PGSIZE);
f0102c61:	83 ec 04             	sub    $0x4,%esp
f0102c64:	68 00 10 00 00       	push   $0x1000
f0102c69:	6a 02                	push   $0x2
f0102c6b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c70:	50                   	push   %eax
f0102c71:	e8 89 29 00 00       	call   f01055ff <memset>
	   page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c76:	6a 02                	push   $0x2
f0102c78:	68 00 10 00 00       	push   $0x1000
f0102c7d:	57                   	push   %edi
f0102c7e:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102c84:	e8 8e e6 ff ff       	call   f0101317 <page_insert>
	   assert(pp1->pp_ref == 1);
f0102c89:	83 c4 20             	add    $0x20,%esp
f0102c8c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c91:	74 19                	je     f0102cac <mem_init+0x183c>
f0102c93:	68 b8 6a 10 f0       	push   $0xf0106ab8
f0102c98:	68 98 68 10 f0       	push   $0xf0106898
f0102c9d:	68 7e 04 00 00       	push   $0x47e
f0102ca2:	68 72 68 10 f0       	push   $0xf0106872
f0102ca7:	e8 94 d3 ff ff       	call   f0100040 <_panic>
	   assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cac:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cb3:	01 01 01 
f0102cb6:	74 19                	je     f0102cd1 <mem_init+0x1861>
f0102cb8:	68 c8 74 10 f0       	push   $0xf01074c8
f0102cbd:	68 98 68 10 f0       	push   $0xf0106898
f0102cc2:	68 7f 04 00 00       	push   $0x47f
f0102cc7:	68 72 68 10 f0       	push   $0xf0106872
f0102ccc:	e8 6f d3 ff ff       	call   f0100040 <_panic>
	   page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cd1:	6a 02                	push   $0x2
f0102cd3:	68 00 10 00 00       	push   $0x1000
f0102cd8:	56                   	push   %esi
f0102cd9:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102cdf:	e8 33 e6 ff ff       	call   f0101317 <page_insert>
	   assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ce4:	83 c4 10             	add    $0x10,%esp
f0102ce7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cee:	02 02 02 
f0102cf1:	74 19                	je     f0102d0c <mem_init+0x189c>
f0102cf3:	68 ec 74 10 f0       	push   $0xf01074ec
f0102cf8:	68 98 68 10 f0       	push   $0xf0106898
f0102cfd:	68 81 04 00 00       	push   $0x481
f0102d02:	68 72 68 10 f0       	push   $0xf0106872
f0102d07:	e8 34 d3 ff ff       	call   f0100040 <_panic>
	   assert(pp2->pp_ref == 1);
f0102d0c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d11:	74 19                	je     f0102d2c <mem_init+0x18bc>
f0102d13:	68 da 6a 10 f0       	push   $0xf0106ada
f0102d18:	68 98 68 10 f0       	push   $0xf0106898
f0102d1d:	68 82 04 00 00       	push   $0x482
f0102d22:	68 72 68 10 f0       	push   $0xf0106872
f0102d27:	e8 14 d3 ff ff       	call   f0100040 <_panic>
	   assert(pp1->pp_ref == 0);
f0102d2c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d31:	74 19                	je     f0102d4c <mem_init+0x18dc>
f0102d33:	68 44 6b 10 f0       	push   $0xf0106b44
f0102d38:	68 98 68 10 f0       	push   $0xf0106898
f0102d3d:	68 83 04 00 00       	push   $0x483
f0102d42:	68 72 68 10 f0       	push   $0xf0106872
f0102d47:	e8 f4 d2 ff ff       	call   f0100040 <_panic>
	   *(uint32_t *)PGSIZE = 0x03030303U;
f0102d4c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d53:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d56:	89 f0                	mov    %esi,%eax
f0102d58:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102d5e:	c1 f8 03             	sar    $0x3,%eax
f0102d61:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d64:	89 c2                	mov    %eax,%edx
f0102d66:	c1 ea 0c             	shr    $0xc,%edx
f0102d69:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102d6f:	72 12                	jb     f0102d83 <mem_init+0x1913>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d71:	50                   	push   %eax
f0102d72:	68 e4 62 10 f0       	push   $0xf01062e4
f0102d77:	6a 58                	push   $0x58
f0102d79:	68 7e 68 10 f0       	push   $0xf010687e
f0102d7e:	e8 bd d2 ff ff       	call   f0100040 <_panic>
	   assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d83:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d8a:	03 03 03 
f0102d8d:	74 19                	je     f0102da8 <mem_init+0x1938>
f0102d8f:	68 10 75 10 f0       	push   $0xf0107510
f0102d94:	68 98 68 10 f0       	push   $0xf0106898
f0102d99:	68 85 04 00 00       	push   $0x485
f0102d9e:	68 72 68 10 f0       	push   $0xf0106872
f0102da3:	e8 98 d2 ff ff       	call   f0100040 <_panic>
	   page_remove(kern_pgdir, (void*) PGSIZE);
f0102da8:	83 ec 08             	sub    $0x8,%esp
f0102dab:	68 00 10 00 00       	push   $0x1000
f0102db0:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102db6:	e8 0f e5 ff ff       	call   f01012ca <page_remove>
	   assert(pp2->pp_ref == 0);
f0102dbb:	83 c4 10             	add    $0x10,%esp
f0102dbe:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102dc3:	74 19                	je     f0102dde <mem_init+0x196e>
f0102dc5:	68 12 6b 10 f0       	push   $0xf0106b12
f0102dca:	68 98 68 10 f0       	push   $0xf0106898
f0102dcf:	68 87 04 00 00       	push   $0x487
f0102dd4:	68 72 68 10 f0       	push   $0xf0106872
f0102dd9:	e8 62 d2 ff ff       	call   f0100040 <_panic>

	   // forcibly take pp0 back
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dde:	8b 0d 8c 2e 21 f0    	mov    0xf0212e8c,%ecx
f0102de4:	8b 11                	mov    (%ecx),%edx
f0102de6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102dec:	89 d8                	mov    %ebx,%eax
f0102dee:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102df4:	c1 f8 03             	sar    $0x3,%eax
f0102df7:	c1 e0 0c             	shl    $0xc,%eax
f0102dfa:	39 c2                	cmp    %eax,%edx
f0102dfc:	74 19                	je     f0102e17 <mem_init+0x19a7>
f0102dfe:	68 98 6e 10 f0       	push   $0xf0106e98
f0102e03:	68 98 68 10 f0       	push   $0xf0106898
f0102e08:	68 8a 04 00 00       	push   $0x48a
f0102e0d:	68 72 68 10 f0       	push   $0xf0106872
f0102e12:	e8 29 d2 ff ff       	call   f0100040 <_panic>
	   kern_pgdir[0] = 0;
f0102e17:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	   assert(pp0->pp_ref == 1);
f0102e1d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e22:	74 19                	je     f0102e3d <mem_init+0x19cd>
f0102e24:	68 c9 6a 10 f0       	push   $0xf0106ac9
f0102e29:	68 98 68 10 f0       	push   $0xf0106898
f0102e2e:	68 8c 04 00 00       	push   $0x48c
f0102e33:	68 72 68 10 f0       	push   $0xf0106872
f0102e38:	e8 03 d2 ff ff       	call   f0100040 <_panic>
	   pp0->pp_ref = 0;
f0102e3d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	   // free the pages we took
	   page_free(pp0);
f0102e43:	83 ec 0c             	sub    $0xc,%esp
f0102e46:	53                   	push   %ebx
f0102e47:	e8 4a e2 ff ff       	call   f0101096 <page_free>

	   cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e4c:	c7 04 24 3c 75 10 f0 	movl   $0xf010753c,(%esp)
f0102e53:	e8 cc 09 00 00       	call   f0103824 <cprintf>
	   cr0 &= ~(CR0_TS|CR0_EM);
	   lcr0(cr0);

	   // Some more checks, only possible after kern_pgdir is installed.
	   check_page_installed_pgdir();
}
f0102e58:	83 c4 10             	add    $0x10,%esp
f0102e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e5e:	5b                   	pop    %ebx
f0102e5f:	5e                   	pop    %esi
f0102e60:	5f                   	pop    %edi
f0102e61:	5d                   	pop    %ebp
f0102e62:	c3                   	ret    

f0102e63 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e63:	55                   	push   %ebp
f0102e64:	89 e5                	mov    %esp,%ebp
f0102e66:	57                   	push   %edi
f0102e67:	56                   	push   %esi
f0102e68:	53                   	push   %ebx
f0102e69:	83 ec 2c             	sub    $0x2c,%esp
f0102e6c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f0102e72:	89 c3                	mov    %eax,%ebx
f0102e74:	03 45 10             	add    0x10(%ebp),%eax
f0102e77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	   {
			 pte_t* pte = NULL;
			 struct PageInfo* mapped_page = page_lookup (env -> env_pgdir, (void*) a, &pte);
f0102e7a:	8d 75 e4             	lea    -0x1c(%ebp),%esi
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f0102e7d:	eb 49                	jmp    f0102ec8 <user_mem_check+0x65>
	   {
			 pte_t* pte = NULL;
f0102e7f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			 struct PageInfo* mapped_page = page_lookup (env -> env_pgdir, (void*) a, &pte);
f0102e86:	83 ec 04             	sub    $0x4,%esp
f0102e89:	56                   	push   %esi
f0102e8a:	53                   	push   %ebx
f0102e8b:	ff 77 60             	pushl  0x60(%edi)
f0102e8e:	e8 9c e3 ff ff       	call   f010122f <page_lookup>

			 if ((!mapped_page) || !(*pte & (perm | PTE_P)) || ((uintptr_t)a >= ULIM))
f0102e93:	83 c4 10             	add    $0x10,%esp
f0102e96:	85 c0                	test   %eax,%eax
f0102e98:	74 15                	je     f0102eaf <user_mem_check+0x4c>
f0102e9a:	8b 55 14             	mov    0x14(%ebp),%edx
f0102e9d:	83 ca 01             	or     $0x1,%edx
f0102ea0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102ea3:	85 10                	test   %edx,(%eax)
f0102ea5:	74 08                	je     f0102eaf <user_mem_check+0x4c>
f0102ea7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102ead:	76 0d                	jbe    f0102ebc <user_mem_check+0x59>
			 {
				    user_mem_check_addr = (uintptr_t) a;
f0102eaf:	89 1d 3c 22 21 f0    	mov    %ebx,0xf021223c
				    return -E_FAULT;
f0102eb5:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102eba:	eb 16                	jmp    f0102ed2 <user_mem_check+0x6f>
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f0102ebc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ec2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102ec8:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102ecb:	72 b2                	jb     f0102e7f <user_mem_check+0x1c>
			 {
				    user_mem_check_addr = (uintptr_t) a;
				    return -E_FAULT;
			 }
	   }
	   return 0;
f0102ecd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ed5:	5b                   	pop    %ebx
f0102ed6:	5e                   	pop    %esi
f0102ed7:	5f                   	pop    %edi
f0102ed8:	5d                   	pop    %ebp
f0102ed9:	c3                   	ret    

f0102eda <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
	   void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102eda:	55                   	push   %ebp
f0102edb:	89 e5                	mov    %esp,%ebp
f0102edd:	53                   	push   %ebx
f0102ede:	83 ec 04             	sub    $0x4,%esp
f0102ee1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102ee4:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ee7:	83 c8 04             	or     $0x4,%eax
f0102eea:	50                   	push   %eax
f0102eeb:	ff 75 10             	pushl  0x10(%ebp)
f0102eee:	ff 75 0c             	pushl  0xc(%ebp)
f0102ef1:	53                   	push   %ebx
f0102ef2:	e8 6c ff ff ff       	call   f0102e63 <user_mem_check>
f0102ef7:	83 c4 10             	add    $0x10,%esp
f0102efa:	85 c0                	test   %eax,%eax
f0102efc:	79 21                	jns    f0102f1f <user_mem_assert+0x45>
			 cprintf("[%08x] user_mem_check assertion failure for "
f0102efe:	83 ec 04             	sub    $0x4,%esp
f0102f01:	ff 35 3c 22 21 f0    	pushl  0xf021223c
f0102f07:	ff 73 48             	pushl  0x48(%ebx)
f0102f0a:	68 68 75 10 f0       	push   $0xf0107568
f0102f0f:	e8 10 09 00 00       	call   f0103824 <cprintf>
						  "va %08x\n", env->env_id, user_mem_check_addr);
			 env_destroy(env);	// may not return
f0102f14:	89 1c 24             	mov    %ebx,(%esp)
f0102f17:	e8 3f 06 00 00       	call   f010355b <env_destroy>
f0102f1c:	83 c4 10             	add    $0x10,%esp
	   }
}
f0102f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f22:	c9                   	leave  
f0102f23:	c3                   	ret    

f0102f24 <region_alloc>:
	   // Hint: It is easier to use region_alloc if the caller can pass
	   //   'va' and 'len' values that are not page-aligned.
	   //   You should round va down, and round (va + len) up.
	   //   (Watch out for corner-cases!)

	   if (len == 0)
f0102f24:	85 c9                	test   %ecx,%ecx
f0102f26:	0f 84 97 00 00 00    	je     f0102fc3 <region_alloc+0x9f>
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
	   static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f2c:	55                   	push   %ebp
f0102f2d:	89 e5                	mov    %esp,%ebp
f0102f2f:	57                   	push   %edi
f0102f30:	56                   	push   %esi
f0102f31:	53                   	push   %ebx
f0102f32:	83 ec 1c             	sub    $0x1c,%esp
f0102f35:	89 d3                	mov    %edx,%ebx
f0102f37:	89 c7                	mov    %eax,%edi
	   //   (Watch out for corner-cases!)

	   if (len == 0)
			 return;

	   uintptr_t h_addr = ROUNDUP ((uintptr_t) va + len, PGSIZE);
f0102f39:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
	   uintptr_t l_addr = ROUNDDOWN ((uintptr_t) va, PGSIZE);
f0102f40:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f4b:	29 d8                	sub    %ebx,%eax
f0102f4d:	c1 e8 0c             	shr    $0xc,%eax
f0102f50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   uintptr_t page_count = (h_addr - l_addr) / PGSIZE;

	   for (int i = 0; i < page_count; i ++)
f0102f53:	be 00 00 00 00       	mov    $0x0,%esi
f0102f58:	eb 5d                	jmp    f0102fb7 <region_alloc+0x93>
	   {
			 struct PageInfo* new_page = page_alloc(ALLOC_ZERO);
f0102f5a:	83 ec 0c             	sub    $0xc,%esp
f0102f5d:	6a 01                	push   $0x1
f0102f5f:	e8 bb e0 ff ff       	call   f010101f <page_alloc>
			 assert (new_page);
f0102f64:	83 c4 10             	add    $0x10,%esp
f0102f67:	85 c0                	test   %eax,%eax
f0102f69:	75 19                	jne    f0102f84 <region_alloc+0x60>
f0102f6b:	68 9d 75 10 f0       	push   $0xf010759d
f0102f70:	68 98 68 10 f0       	push   $0xf0106898
f0102f75:	68 38 01 00 00       	push   $0x138
f0102f7a:	68 a6 75 10 f0       	push   $0xf01075a6
f0102f7f:	e8 bc d0 ff ff       	call   f0100040 <_panic>

			 void* addr = (void *) (l_addr + (i * PGSIZE));
			 if ((page_insert(e -> env_pgdir, new_page, addr, PTE_U | PTE_W)) < 0)
f0102f84:	6a 06                	push   $0x6
f0102f86:	53                   	push   %ebx
f0102f87:	50                   	push   %eax
f0102f88:	ff 77 60             	pushl  0x60(%edi)
f0102f8b:	e8 87 e3 ff ff       	call   f0101317 <page_insert>
f0102f90:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f96:	83 c4 10             	add    $0x10,%esp
f0102f99:	85 c0                	test   %eax,%eax
f0102f9b:	79 17                	jns    f0102fb4 <region_alloc+0x90>
				    panic ("Page Insert Failed \n");
f0102f9d:	83 ec 04             	sub    $0x4,%esp
f0102fa0:	68 b1 75 10 f0       	push   $0xf01075b1
f0102fa5:	68 3c 01 00 00       	push   $0x13c
f0102faa:	68 a6 75 10 f0       	push   $0xf01075a6
f0102faf:	e8 8c d0 ff ff       	call   f0100040 <_panic>

	   uintptr_t h_addr = ROUNDUP ((uintptr_t) va + len, PGSIZE);
	   uintptr_t l_addr = ROUNDDOWN ((uintptr_t) va, PGSIZE);
	   uintptr_t page_count = (h_addr - l_addr) / PGSIZE;

	   for (int i = 0; i < page_count; i ++)
f0102fb4:	83 c6 01             	add    $0x1,%esi
f0102fb7:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102fba:	75 9e                	jne    f0102f5a <region_alloc+0x36>

			 void* addr = (void *) (l_addr + (i * PGSIZE));
			 if ((page_insert(e -> env_pgdir, new_page, addr, PTE_U | PTE_W)) < 0)
				    panic ("Page Insert Failed \n");
	   }
}
f0102fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fbf:	5b                   	pop    %ebx
f0102fc0:	5e                   	pop    %esi
f0102fc1:	5f                   	pop    %edi
f0102fc2:	5d                   	pop    %ebp
f0102fc3:	f3 c3                	repz ret 

f0102fc5 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
	   int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102fc5:	55                   	push   %ebp
f0102fc6:	89 e5                	mov    %esp,%ebp
f0102fc8:	56                   	push   %esi
f0102fc9:	53                   	push   %ebx
f0102fca:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fcd:	8b 55 10             	mov    0x10(%ebp),%edx
	   struct Env *e;

	   // If envid is zero, return the current environment.
	   if (envid == 0) {
f0102fd0:	85 c0                	test   %eax,%eax
f0102fd2:	75 1a                	jne    f0102fee <envid2env+0x29>
			 *env_store = curenv;
f0102fd4:	e8 49 2c 00 00       	call   f0105c22 <cpunum>
f0102fd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fdc:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0102fe2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fe5:	89 01                	mov    %eax,(%ecx)
			 return 0;
f0102fe7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fec:	eb 70                	jmp    f010305e <envid2env+0x99>
	   // Look up the Env structure via the index part of the envid,
	   // then check the env_id field in that struct Env
	   // to ensure that the envid is not stale
	   // (i.e., does not refer to a _previous_ environment
	   // that used the same slot in the envs[] array).
	   e = &envs[ENVX(envid)];
f0102fee:	89 c3                	mov    %eax,%ebx
f0102ff0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102ff6:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102ff9:	03 1d 48 22 21 f0    	add    0xf0212248,%ebx
	   if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fff:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103003:	74 05                	je     f010300a <envid2env+0x45>
f0103005:	3b 43 48             	cmp    0x48(%ebx),%eax
f0103008:	74 10                	je     f010301a <envid2env+0x55>
			 *env_store = 0;
f010300a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010300d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			 return -E_BAD_ENV;
f0103013:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103018:	eb 44                	jmp    f010305e <envid2env+0x99>
	   // Check that the calling environment has legitimate permission
	   // to manipulate the specified environment.
	   // If checkperm is set, the specified environment
	   // must be either the current environment
	   // or an immediate child of the current environment.
	   if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010301a:	84 d2                	test   %dl,%dl
f010301c:	74 36                	je     f0103054 <envid2env+0x8f>
f010301e:	e8 ff 2b 00 00       	call   f0105c22 <cpunum>
f0103023:	6b c0 74             	imul   $0x74,%eax,%eax
f0103026:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f010302c:	74 26                	je     f0103054 <envid2env+0x8f>
f010302e:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103031:	e8 ec 2b 00 00       	call   f0105c22 <cpunum>
f0103036:	6b c0 74             	imul   $0x74,%eax,%eax
f0103039:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010303f:	3b 70 48             	cmp    0x48(%eax),%esi
f0103042:	74 10                	je     f0103054 <envid2env+0x8f>
			 *env_store = 0;
f0103044:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103047:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			 return -E_BAD_ENV;
f010304d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103052:	eb 0a                	jmp    f010305e <envid2env+0x99>
	   }

	   *env_store = e;
f0103054:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103057:	89 18                	mov    %ebx,(%eax)
	   return 0;
f0103059:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010305e:	5b                   	pop    %ebx
f010305f:	5e                   	pop    %esi
f0103060:	5d                   	pop    %ebp
f0103061:	c3                   	ret    

f0103062 <env_init_percpu>:
}

// Load GDT and segment descriptors.
	   void
env_init_percpu(void)
{
f0103062:	55                   	push   %ebp
f0103063:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103065:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f010306a:	0f 01 10             	lgdtl  (%eax)
	   lgdt(&gdt_pd);
	   // The kernel never uses GS or FS, so we leave those set to
	   // the user data segment.
	   asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010306d:	b8 23 00 00 00       	mov    $0x23,%eax
f0103072:	8e e8                	mov    %eax,%gs
	   asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103074:	8e e0                	mov    %eax,%fs
	   // The kernel does use ES, DS, and SS.  We'll change between
	   // the kernel and user data segments as needed.
	   asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103076:	b8 10 00 00 00       	mov    $0x10,%eax
f010307b:	8e c0                	mov    %eax,%es
	   asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010307d:	8e d8                	mov    %eax,%ds
	   asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010307f:	8e d0                	mov    %eax,%ss
	   // Load the kernel text segment into CS.
	   asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103081:	ea 88 30 10 f0 08 00 	ljmp   $0x8,$0xf0103088
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103088:	b8 00 00 00 00       	mov    $0x0,%eax
f010308d:	0f 00 d0             	lldt   %ax
	   // For good measure, clear the local descriptor table (LDT),
	   // since we don't use it.
	   lldt(0);
}
f0103090:	5d                   	pop    %ebp
f0103091:	c3                   	ret    

f0103092 <env_init>:
env_init(void)
{
	   // Set up envs array
	   // LAB 3: Your code here.

	   env_free_list = &envs[0];
f0103092:	8b 0d 48 22 21 f0    	mov    0xf0212248,%ecx
f0103098:	89 0d 4c 22 21 f0    	mov    %ecx,0xf021224c
	   envs[0].env_id = 0;
f010309e:	c7 41 48 00 00 00 00 	movl   $0x0,0x48(%ecx)
f01030a5:	8d 41 7c             	lea    0x7c(%ecx),%eax
f01030a8:	8d 91 00 f0 01 00    	lea    0x1f000(%ecx),%edx

	   for (int i = 1; i < NENV; i++)
	   {
			 envs [i-1].env_link = &envs[i];
f01030ae:	89 40 c8             	mov    %eax,-0x38(%eax)
			 envs [i].env_id = 0;
f01030b1:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
f01030b8:	83 c0 7c             	add    $0x7c,%eax
	   // LAB 3: Your code here.

	   env_free_list = &envs[0];
	   envs[0].env_id = 0;

	   for (int i = 1; i < NENV; i++)
f01030bb:	39 d0                	cmp    %edx,%eax
f01030bd:	75 ef                	jne    f01030ae <env_init+0x1c>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
	   void
env_init(void)
{
f01030bf:	55                   	push   %ebp
f01030c0:	89 e5                	mov    %esp,%ebp
	   {
			 envs [i-1].env_link = &envs[i];
			 envs [i].env_id = 0;
	   }

	   envs [NENV - 1].env_link = NULL;
f01030c2:	c7 81 c8 ef 01 00 00 	movl   $0x0,0x1efc8(%ecx)
f01030c9:	00 00 00 
	   // Per-CPU part of the initialization
	   env_init_percpu();
f01030cc:	e8 91 ff ff ff       	call   f0103062 <env_init_percpu>
}
f01030d1:	5d                   	pop    %ebp
f01030d2:	c3                   	ret    

f01030d3 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
	   int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030d3:	55                   	push   %ebp
f01030d4:	89 e5                	mov    %esp,%ebp
f01030d6:	57                   	push   %edi
f01030d7:	56                   	push   %esi
f01030d8:	53                   	push   %ebx
f01030d9:	83 ec 1c             	sub    $0x1c,%esp

	   int32_t generation;
	   int r;
	   struct Env *e;

	   if (!(e = env_free_list))
f01030dc:	8b 1d 4c 22 21 f0    	mov    0xf021224c,%ebx
f01030e2:	85 db                	test   %ebx,%ebx
f01030e4:	0f 84 31 01 00 00    	je     f010321b <env_alloc+0x148>
{
	   int i;
	   struct PageInfo *p = NULL;

	   // Allocate a page for the page directory
	   if (!(p = page_alloc(ALLOC_ZERO)))
f01030ea:	83 ec 0c             	sub    $0xc,%esp
f01030ed:	6a 01                	push   $0x1
f01030ef:	e8 2b df ff ff       	call   f010101f <page_alloc>
f01030f4:	89 c6                	mov    %eax,%esi
f01030f6:	83 c4 10             	add    $0x10,%esp
f01030f9:	85 c0                	test   %eax,%eax
f01030fb:	0f 84 21 01 00 00    	je     f0103222 <env_alloc+0x14f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103101:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0103107:	c1 f8 03             	sar    $0x3,%eax
f010310a:	c1 e0 0c             	shl    $0xc,%eax
f010310d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103110:	c1 e8 0c             	shr    $0xc,%eax
f0103113:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0103119:	72 14                	jb     f010312f <env_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010311b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010311e:	68 e4 62 10 f0       	push   $0xf01062e4
f0103123:	6a 58                	push   $0x58
f0103125:	68 7e 68 10 f0       	push   $0xf010687e
f010312a:	e8 11 cf ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010312f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103132:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
	   //    - The functions in kern/pmap.h are handy.

	   // LAB 3: Your code here.

	   pde_t *e_pgdir = page2kva(p);
	   memcpy(e_pgdir, kern_pgdir, PGSIZE);
f0103138:	83 ec 04             	sub    $0x4,%esp
f010313b:	68 00 10 00 00       	push   $0x1000
f0103140:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0103146:	57                   	push   %edi
f0103147:	e8 68 25 00 00       	call   f01056b4 <memcpy>
	   p->pp_ref++;
f010314c:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	   e->env_pgdir = e_pgdir;
f0103151:	89 7b 60             	mov    %edi,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103154:	83 c4 10             	add    $0x10,%esp
f0103157:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010315d:	77 15                	ja     f0103174 <env_alloc+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010315f:	57                   	push   %edi
f0103160:	68 08 63 10 f0       	push   $0xf0106308
f0103165:	68 cc 00 00 00       	push   $0xcc
f010316a:	68 a6 75 10 f0       	push   $0xf01075a6
f010316f:	e8 cc ce ff ff       	call   f0100040 <_panic>
	   // UVPT maps the env's own page table read-only.
	   // Permissions: kernel R, user R
	   e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103177:	83 c8 05             	or     $0x5,%eax
f010317a:	89 87 f4 0e 00 00    	mov    %eax,0xef4(%edi)
	   // Allocate and set up the page directory for this environment.
	   if ((r = env_setup_vm(e)) < 0)
			 return r;

	   // Generate an env_id for this environment.
	   generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103180:	8b 43 48             	mov    0x48(%ebx),%eax
f0103183:	05 00 10 00 00       	add    $0x1000,%eax
	   if (generation <= 0)	// Don't create a negative env_id.
f0103188:	25 00 fc ff ff       	and    $0xfffffc00,%eax
			 generation = 1 << ENVGENSHIFT;
f010318d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103192:	0f 4e c2             	cmovle %edx,%eax
	   e->env_id = generation | (e - envs);
f0103195:	89 da                	mov    %ebx,%edx
f0103197:	2b 15 48 22 21 f0    	sub    0xf0212248,%edx
f010319d:	c1 fa 02             	sar    $0x2,%edx
f01031a0:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031a6:	09 d0                	or     %edx,%eax
f01031a8:	89 43 48             	mov    %eax,0x48(%ebx)

	   // Set the basic status variables.
	   e->env_parent_id = parent_id;
f01031ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031ae:	89 43 4c             	mov    %eax,0x4c(%ebx)
	   e->env_type = ENV_TYPE_USER;
f01031b1:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	   e->env_status = ENV_RUNNABLE;
f01031b8:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	   e->env_runs = 0;
f01031bf:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	   // Clear out all the saved register state,
	   // to prevent the register values
	   // of a prior environment inhabiting this Env structure
	   // from "leaking" into our new environment.
	   memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031c6:	83 ec 04             	sub    $0x4,%esp
f01031c9:	6a 44                	push   $0x44
f01031cb:	6a 00                	push   $0x0
f01031cd:	53                   	push   %ebx
f01031ce:	e8 2c 24 00 00       	call   f01055ff <memset>
	   // The low 2 bits of each segment register contains the
	   // Requestor Privilege Level (RPL); 3 means user mode.  When
	   // we switch privilege levels, the hardware does various
	   // checks involving the RPL and the Descriptor Privilege Level
	   // (DPL) stored in the descriptors themselves.
	   e->env_tf.tf_ds = GD_UD | 3;
f01031d3:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	   e->env_tf.tf_es = GD_UD | 3;
f01031d9:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	   e->env_tf.tf_ss = GD_UD | 3;
f01031df:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	   e->env_tf.tf_esp = USTACKTOP;
f01031e5:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	   e->env_tf.tf_cs = GD_UT | 3;
f01031ec:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	   // You will set e->env_tf.tf_eip later.

	   // Enable interrupts while in user mode.
	   // LAB 4: Your code here.
	   e -> env_tf.tf_eflags |= FL_IF;
f01031f2:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	   // Clear the page fault handler until user installs one.
	   e->env_pgfault_upcall = 0;
f01031f9:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	   // Also clear the IPC receiving flag.
	   e->env_ipc_recving = 0;
f0103200:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	   // commit the allocation
	   env_free_list = e->env_link;
f0103204:	8b 43 44             	mov    0x44(%ebx),%eax
f0103207:	a3 4c 22 21 f0       	mov    %eax,0xf021224c
	   *newenv_store = e;
f010320c:	8b 45 08             	mov    0x8(%ebp),%eax
f010320f:	89 18                	mov    %ebx,(%eax)

	   // cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	   return 0;
f0103211:	83 c4 10             	add    $0x10,%esp
f0103214:	b8 00 00 00 00       	mov    $0x0,%eax
f0103219:	eb 0c                	jmp    f0103227 <env_alloc+0x154>
	   int32_t generation;
	   int r;
	   struct Env *e;

	   if (!(e = env_free_list))
			 return -E_NO_FREE_ENV;
f010321b:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103220:	eb 05                	jmp    f0103227 <env_alloc+0x154>
	   int i;
	   struct PageInfo *p = NULL;

	   // Allocate a page for the page directory
	   if (!(p = page_alloc(ALLOC_ZERO)))
			 return -E_NO_MEM;
f0103222:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	   *newenv_store = e;

	   // cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	   return 0;

}
f0103227:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010322a:	5b                   	pop    %ebx
f010322b:	5e                   	pop    %esi
f010322c:	5f                   	pop    %edi
f010322d:	5d                   	pop    %ebp
f010322e:	c3                   	ret    

f010322f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
	   void
env_create(uint8_t *binary, enum EnvType type)
{
f010322f:	55                   	push   %ebp
f0103230:	89 e5                	mov    %esp,%ebp
f0103232:	57                   	push   %edi
f0103233:	56                   	push   %esi
f0103234:	53                   	push   %ebx
f0103235:	83 ec 34             	sub    $0x34,%esp
f0103238:	8b 7d 08             	mov    0x8(%ebp),%edi
	   // LAB 3: Your code here.

	   struct Env* new_env = NULL;
f010323b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   if ((env_alloc(&new_env, 0)) < 0)
f0103242:	6a 00                	push   $0x0
f0103244:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103247:	50                   	push   %eax
f0103248:	e8 86 fe ff ff       	call   f01030d3 <env_alloc>
f010324d:	83 c4 10             	add    $0x10,%esp
f0103250:	85 c0                	test   %eax,%eax
f0103252:	79 17                	jns    f010326b <env_create+0x3c>
			 panic ("Environment Allocation Failed \n");
f0103254:	83 ec 04             	sub    $0x4,%esp
f0103257:	68 0c 76 10 f0       	push   $0xf010760c
f010325c:	68 aa 01 00 00       	push   $0x1aa
f0103261:	68 a6 75 10 f0       	push   $0xf01075a6
f0103266:	e8 d5 cd ff ff       	call   f0100040 <_panic>

	   load_icode (new_env, binary);
f010326b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010326e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	   // LAB 3: Your code here.

	   struct Elf* p_binary = (struct Elf*) binary;

	   if (p_binary -> e_magic != ELF_MAGIC)
f0103271:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103277:	74 17                	je     f0103290 <env_create+0x61>
			 panic ("Invalid ELF File \n");
f0103279:	83 ec 04             	sub    $0x4,%esp
f010327c:	68 c6 75 10 f0       	push   $0xf01075c6
f0103281:	68 7a 01 00 00       	push   $0x17a
f0103286:	68 a6 75 10 f0       	push   $0xf01075a6
f010328b:	e8 b0 cd ff ff       	call   f0100040 <_panic>

	   lcr3 (PADDR(e -> env_pgdir));
f0103290:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103293:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103296:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010329b:	77 15                	ja     f01032b2 <env_create+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010329d:	50                   	push   %eax
f010329e:	68 08 63 10 f0       	push   $0xf0106308
f01032a3:	68 7c 01 00 00       	push   $0x17c
f01032a8:	68 a6 75 10 f0       	push   $0xf01075a6
f01032ad:	e8 8e cd ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01032b2:	05 00 00 00 10       	add    $0x10000000,%eax
f01032b7:	0f 22 d8             	mov    %eax,%cr3

	   struct Proghdr* ph_browse = (struct Proghdr*) (binary + p_binary -> e_phoff);
f01032ba:	89 fb                	mov    %edi,%ebx
f01032bc:	03 5f 1c             	add    0x1c(%edi),%ebx
	   struct Proghdr* ph_entries = ph_browse + p_binary -> e_phnum;
f01032bf:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032c3:	c1 e6 05             	shl    $0x5,%esi
f01032c6:	01 de                	add    %ebx,%esi
f01032c8:	eb 70                	jmp    f010333a <env_create+0x10b>

	   for (; ph_browse < ph_entries ; ph_browse ++)
	   {
			 if (ph_browse -> p_type != ELF_PROG_LOAD)
f01032ca:	83 3b 01             	cmpl   $0x1,(%ebx)
f01032cd:	75 68                	jne    f0103337 <env_create+0x108>
				    continue;

			 if (ph_browse -> p_filesz > ph_browse -> p_memsz)
f01032cf:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01032d2:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f01032d5:	76 17                	jbe    f01032ee <env_create+0xbf>
				    panic("Error in ElF File \n");
f01032d7:	83 ec 04             	sub    $0x4,%esp
f01032da:	68 d9 75 10 f0       	push   $0xf01075d9
f01032df:	68 87 01 00 00       	push   $0x187
f01032e4:	68 a6 75 10 f0       	push   $0xf01075a6
f01032e9:	e8 52 cd ff ff       	call   f0100040 <_panic>

			 region_alloc (e, (void*)ph_browse -> p_va, ph_browse -> p_memsz);
f01032ee:	8b 53 08             	mov    0x8(%ebx),%edx
f01032f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032f4:	e8 2b fc ff ff       	call   f0102f24 <region_alloc>
			 memset ((void*)ph_browse -> p_va ,0 , ph_browse -> p_memsz);
f01032f9:	83 ec 04             	sub    $0x4,%esp
f01032fc:	ff 73 14             	pushl  0x14(%ebx)
f01032ff:	6a 00                	push   $0x0
f0103301:	ff 73 08             	pushl  0x8(%ebx)
f0103304:	e8 f6 22 00 00       	call   f01055ff <memset>
			 void* seg_offset = (void*) (binary + ph_browse -> p_offset);
			 memcpy ((void*)ph_browse -> p_va, seg_offset, ph_browse -> p_filesz);
f0103309:	83 c4 0c             	add    $0xc,%esp
f010330c:	ff 73 10             	pushl  0x10(%ebx)
f010330f:	89 f8                	mov    %edi,%eax
f0103311:	03 43 04             	add    0x4(%ebx),%eax
f0103314:	50                   	push   %eax
f0103315:	ff 73 08             	pushl  0x8(%ebx)
f0103318:	e8 97 23 00 00       	call   f01056b4 <memcpy>
			 memset ((void*)ph_browse -> p_va + ph_browse -> p_filesz , 0, (ph_browse -> p_memsz - ph_browse -> p_filesz));
f010331d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103320:	83 c4 0c             	add    $0xc,%esp
f0103323:	8b 53 14             	mov    0x14(%ebx),%edx
f0103326:	29 c2                	sub    %eax,%edx
f0103328:	52                   	push   %edx
f0103329:	6a 00                	push   $0x0
f010332b:	03 43 08             	add    0x8(%ebx),%eax
f010332e:	50                   	push   %eax
f010332f:	e8 cb 22 00 00       	call   f01055ff <memset>
f0103334:	83 c4 10             	add    $0x10,%esp
	   lcr3 (PADDR(e -> env_pgdir));

	   struct Proghdr* ph_browse = (struct Proghdr*) (binary + p_binary -> e_phoff);
	   struct Proghdr* ph_entries = ph_browse + p_binary -> e_phnum;

	   for (; ph_browse < ph_entries ; ph_browse ++)
f0103337:	83 c3 20             	add    $0x20,%ebx
f010333a:	39 de                	cmp    %ebx,%esi
f010333c:	77 8c                	ja     f01032ca <env_create+0x9b>
			 void* seg_offset = (void*) (binary + ph_browse -> p_offset);
			 memcpy ((void*)ph_browse -> p_va, seg_offset, ph_browse -> p_filesz);
			 memset ((void*)ph_browse -> p_va + ph_browse -> p_filesz , 0, (ph_browse -> p_memsz - ph_browse -> p_filesz));
	   }

	   e -> env_tf.tf_eip = p_binary -> e_entry;
f010333e:	8b 47 18             	mov    0x18(%edi),%eax
f0103341:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103344:	89 47 30             	mov    %eax,0x30(%edi)

	   // Now map one page for the program's initial stack
	   // at virtual address USTACKTOP - PGSIZE.
	   // LAB 3: Your code here.

	   region_alloc (e, (void*) (USTACKTOP - PGSIZE), PGSIZE);
f0103347:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010334c:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103351:	89 f8                	mov    %edi,%eax
f0103353:	e8 cc fb ff ff       	call   f0102f24 <region_alloc>
	   memset ((void*) (USTACKTOP - PGSIZE), 0, PGSIZE);
f0103358:	83 ec 04             	sub    $0x4,%esp
f010335b:	68 00 10 00 00       	push   $0x1000
f0103360:	6a 00                	push   $0x0
f0103362:	68 00 d0 bf ee       	push   $0xeebfd000
f0103367:	e8 93 22 00 00       	call   f01055ff <memset>

	   lcr3(PADDR(kern_pgdir));
f010336c:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103371:	83 c4 10             	add    $0x10,%esp
f0103374:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103379:	77 15                	ja     f0103390 <env_create+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337b:	50                   	push   %eax
f010337c:	68 08 63 10 f0       	push   $0xf0106308
f0103381:	68 99 01 00 00       	push   $0x199
f0103386:	68 a6 75 10 f0       	push   $0xf01075a6
f010338b:	e8 b0 cc ff ff       	call   f0100040 <_panic>
f0103390:	05 00 00 00 10       	add    $0x10000000,%eax
f0103395:	0f 22 d8             	mov    %eax,%cr3
	   struct Env* new_env = NULL;
	   if ((env_alloc(&new_env, 0)) < 0)
			 panic ("Environment Allocation Failed \n");

	   load_icode (new_env, binary);
	   new_env -> env_type = type;
f0103398:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010339b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010339e:	89 78 50             	mov    %edi,0x50(%eax)

	   // If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	   // LAB 5: Your code here.

	   if (type == ENV_TYPE_FS) 
f01033a1:	83 ff 01             	cmp    $0x1,%edi
f01033a4:	75 07                	jne    f01033ad <env_create+0x17e>
	   {
			 new_env->env_tf.tf_eflags |= FL_IOPL_3;
f01033a6:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	   }

}
f01033ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033b0:	5b                   	pop    %ebx
f01033b1:	5e                   	pop    %esi
f01033b2:	5f                   	pop    %edi
f01033b3:	5d                   	pop    %ebp
f01033b4:	c3                   	ret    

f01033b5 <env_free>:
//
// Frees env e and all memory it uses.
//
	   void
env_free(struct Env *e)
{
f01033b5:	55                   	push   %ebp
f01033b6:	89 e5                	mov    %esp,%ebp
f01033b8:	57                   	push   %edi
f01033b9:	56                   	push   %esi
f01033ba:	53                   	push   %ebx
f01033bb:	83 ec 1c             	sub    $0x1c,%esp
f01033be:	8b 7d 08             	mov    0x8(%ebp),%edi
	   physaddr_t pa;

	   // If freeing the current environment, switch to kern_pgdir
	   // before freeing the page directory, just in case the page
	   // gets reused.
	   if (e == curenv)
f01033c1:	e8 5c 28 00 00       	call   f0105c22 <cpunum>
f01033c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033c9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01033d0:	39 b8 28 30 21 f0    	cmp    %edi,-0xfdecfd8(%eax)
f01033d6:	75 30                	jne    f0103408 <env_free+0x53>
			 lcr3(PADDR(kern_pgdir));
f01033d8:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033e2:	77 15                	ja     f01033f9 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033e4:	50                   	push   %eax
f01033e5:	68 08 63 10 f0       	push   $0xf0106308
f01033ea:	68 c8 01 00 00       	push   $0x1c8
f01033ef:	68 a6 75 10 f0       	push   $0xf01075a6
f01033f4:	e8 47 cc ff ff       	call   f0100040 <_panic>
f01033f9:	05 00 00 00 10       	add    $0x10000000,%eax
f01033fe:	0f 22 d8             	mov    %eax,%cr3
f0103401:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103408:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010340b:	89 d0                	mov    %edx,%eax
f010340d:	c1 e0 02             	shl    $0x2,%eax
f0103410:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   // Flush all mapped pages in the user portion of the address space
	   static_assert(UTOP % PTSIZE == 0);
	   for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

			 // only look at mapped page tables
			 if (!(e->env_pgdir[pdeno] & PTE_P))
f0103413:	8b 47 60             	mov    0x60(%edi),%eax
f0103416:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103419:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010341f:	0f 84 a8 00 00 00    	je     f01034cd <env_free+0x118>
				    continue;

			 // find the pa and va of the page table
			 pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103425:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010342b:	89 f0                	mov    %esi,%eax
f010342d:	c1 e8 0c             	shr    $0xc,%eax
f0103430:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103433:	39 05 88 2e 21 f0    	cmp    %eax,0xf0212e88
f0103439:	77 15                	ja     f0103450 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010343b:	56                   	push   %esi
f010343c:	68 e4 62 10 f0       	push   $0xf01062e4
f0103441:	68 d7 01 00 00       	push   $0x1d7
f0103446:	68 a6 75 10 f0       	push   $0xf01075a6
f010344b:	e8 f0 cb ff ff       	call   f0100040 <_panic>
			 pt = (pte_t*) KADDR(pa);

			 // unmap all PTEs in this page table
			 for (pteno = 0; pteno <= PTX(~0); pteno++) {
				    if (pt[pteno] & PTE_P)
						  page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103450:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103453:	c1 e0 16             	shl    $0x16,%eax
f0103456:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			 // find the pa and va of the page table
			 pa = PTE_ADDR(e->env_pgdir[pdeno]);
			 pt = (pte_t*) KADDR(pa);

			 // unmap all PTEs in this page table
			 for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103459:	bb 00 00 00 00       	mov    $0x0,%ebx
				    if (pt[pteno] & PTE_P)
f010345e:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103465:	01 
f0103466:	74 17                	je     f010347f <env_free+0xca>
						  page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103468:	83 ec 08             	sub    $0x8,%esp
f010346b:	89 d8                	mov    %ebx,%eax
f010346d:	c1 e0 0c             	shl    $0xc,%eax
f0103470:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103473:	50                   	push   %eax
f0103474:	ff 77 60             	pushl  0x60(%edi)
f0103477:	e8 4e de ff ff       	call   f01012ca <page_remove>
f010347c:	83 c4 10             	add    $0x10,%esp
			 // find the pa and va of the page table
			 pa = PTE_ADDR(e->env_pgdir[pdeno]);
			 pt = (pte_t*) KADDR(pa);

			 // unmap all PTEs in this page table
			 for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010347f:	83 c3 01             	add    $0x1,%ebx
f0103482:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103488:	75 d4                	jne    f010345e <env_free+0xa9>
				    if (pt[pteno] & PTE_P)
						  page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
			 }

			 // free the page table itself
			 e->env_pgdir[pdeno] = 0;
f010348a:	8b 47 60             	mov    0x60(%edi),%eax
f010348d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103490:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103497:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010349a:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f01034a0:	72 14                	jb     f01034b6 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01034a2:	83 ec 04             	sub    $0x4,%esp
f01034a5:	68 24 6d 10 f0       	push   $0xf0106d24
f01034aa:	6a 51                	push   $0x51
f01034ac:	68 7e 68 10 f0       	push   $0xf010687e
f01034b1:	e8 8a cb ff ff       	call   f0100040 <_panic>
			 page_decref(pa2page(pa));
f01034b6:	83 ec 0c             	sub    $0xc,%esp
f01034b9:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
f01034be:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034c1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034c4:	50                   	push   %eax
f01034c5:	e8 28 dc ff ff       	call   f01010f2 <page_decref>
f01034ca:	83 c4 10             	add    $0x10,%esp
	   // Note the environment's demise.
	   // cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	   // Flush all mapped pages in the user portion of the address space
	   static_assert(UTOP % PTSIZE == 0);
	   for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034cd:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01034d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034d4:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01034d9:	0f 85 29 ff ff ff    	jne    f0103408 <env_free+0x53>
			 e->env_pgdir[pdeno] = 0;
			 page_decref(pa2page(pa));
	   }

	   // free the page directory
	   pa = PADDR(e->env_pgdir);
f01034df:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034e7:	77 15                	ja     f01034fe <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034e9:	50                   	push   %eax
f01034ea:	68 08 63 10 f0       	push   $0xf0106308
f01034ef:	68 e5 01 00 00       	push   $0x1e5
f01034f4:	68 a6 75 10 f0       	push   $0xf01075a6
f01034f9:	e8 42 cb ff ff       	call   f0100040 <_panic>
	   e->env_pgdir = 0;
f01034fe:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103505:	05 00 00 00 10       	add    $0x10000000,%eax
f010350a:	c1 e8 0c             	shr    $0xc,%eax
f010350d:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0103513:	72 14                	jb     f0103529 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103515:	83 ec 04             	sub    $0x4,%esp
f0103518:	68 24 6d 10 f0       	push   $0xf0106d24
f010351d:	6a 51                	push   $0x51
f010351f:	68 7e 68 10 f0       	push   $0xf010687e
f0103524:	e8 17 cb ff ff       	call   f0100040 <_panic>
	   page_decref(pa2page(pa));
f0103529:	83 ec 0c             	sub    $0xc,%esp
f010352c:	8b 15 90 2e 21 f0    	mov    0xf0212e90,%edx
f0103532:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103535:	50                   	push   %eax
f0103536:	e8 b7 db ff ff       	call   f01010f2 <page_decref>

	   // return the environment to the free list
	   e->env_status = ENV_FREE;
f010353b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	   e->env_link = env_free_list;
f0103542:	a1 4c 22 21 f0       	mov    0xf021224c,%eax
f0103547:	89 47 44             	mov    %eax,0x44(%edi)
	   env_free_list = e;
f010354a:	89 3d 4c 22 21 f0    	mov    %edi,0xf021224c
}
f0103550:	83 c4 10             	add    $0x10,%esp
f0103553:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103556:	5b                   	pop    %ebx
f0103557:	5e                   	pop    %esi
f0103558:	5f                   	pop    %edi
f0103559:	5d                   	pop    %ebp
f010355a:	c3                   	ret    

f010355b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
	   void
env_destroy(struct Env *e)
{
f010355b:	55                   	push   %ebp
f010355c:	89 e5                	mov    %esp,%ebp
f010355e:	53                   	push   %ebx
f010355f:	83 ec 04             	sub    $0x4,%esp
f0103562:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   // If e is currently running on other CPUs, we change its state to
	   // ENV_DYING. A zombie environment will be freed the next time
	   // it traps to the kernel.
	   if (e->env_status == ENV_RUNNING && curenv != e) {
f0103565:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103569:	75 29                	jne    f0103594 <env_destroy+0x39>
f010356b:	e8 b2 26 00 00       	call   f0105c22 <cpunum>
f0103570:	6b c0 74             	imul   $0x74,%eax,%eax
f0103573:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f0103579:	74 19                	je     f0103594 <env_destroy+0x39>
			 e->env_status = ENV_DYING;
f010357b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
			 cprintf("Environment dead \n");
f0103582:	83 ec 0c             	sub    $0xc,%esp
f0103585:	68 ed 75 10 f0       	push   $0xf01075ed
f010358a:	e8 95 02 00 00       	call   f0103824 <cprintf>

			 return;
f010358f:	83 c4 10             	add    $0x10,%esp
f0103592:	eb 33                	jmp    f01035c7 <env_destroy+0x6c>
	   }

	   env_free(e);
f0103594:	83 ec 0c             	sub    $0xc,%esp
f0103597:	53                   	push   %ebx
f0103598:	e8 18 fe ff ff       	call   f01033b5 <env_free>

	   if (curenv == e) {
f010359d:	e8 80 26 00 00       	call   f0105c22 <cpunum>
f01035a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a5:	83 c4 10             	add    $0x10,%esp
f01035a8:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f01035ae:	75 17                	jne    f01035c7 <env_destroy+0x6c>
			 curenv = NULL;
f01035b0:	e8 6d 26 00 00       	call   f0105c22 <cpunum>
f01035b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b8:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f01035bf:	00 00 00 
			 sched_yield();
f01035c2:	e8 78 0e 00 00       	call   f010443f <sched_yield>
	   }
}
f01035c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035ca:	c9                   	leave  
f01035cb:	c3                   	ret    

f01035cc <env_pop_tf>:
//
// This function does not return.
//
	   void
env_pop_tf(struct Trapframe *tf)
{
f01035cc:	55                   	push   %ebp
f01035cd:	89 e5                	mov    %esp,%ebp
f01035cf:	53                   	push   %ebx
f01035d0:	83 ec 04             	sub    $0x4,%esp
	   // Record the CPU we are running on for user-space debugging
	   curenv->env_cpunum = cpunum();
f01035d3:	e8 4a 26 00 00       	call   f0105c22 <cpunum>
f01035d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035db:	8b 98 28 30 21 f0    	mov    -0xfdecfd8(%eax),%ebx
f01035e1:	e8 3c 26 00 00       	call   f0105c22 <cpunum>
f01035e6:	89 43 5c             	mov    %eax,0x5c(%ebx)

	   asm volatile(
f01035e9:	8b 65 08             	mov    0x8(%ebp),%esp
f01035ec:	61                   	popa   
f01035ed:	07                   	pop    %es
f01035ee:	1f                   	pop    %ds
f01035ef:	83 c4 08             	add    $0x8,%esp
f01035f2:	cf                   	iret   
				    "\tpopl %%es\n"
				    "\tpopl %%ds\n"
				    "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
				    "\tiret\n"
				    : : "g" (tf) : "memory");
	   panic("iret failed");  /* mostly to placate the compiler */
f01035f3:	83 ec 04             	sub    $0x4,%esp
f01035f6:	68 00 76 10 f0       	push   $0xf0107600
f01035fb:	68 1e 02 00 00       	push   $0x21e
f0103600:	68 a6 75 10 f0       	push   $0xf01075a6
f0103605:	e8 36 ca ff ff       	call   f0100040 <_panic>

f010360a <env_run>:
//
// This function does not return.
//
	   void
env_run(struct Env *e)
{
f010360a:	55                   	push   %ebp
f010360b:	89 e5                	mov    %esp,%ebp
f010360d:	53                   	push   %ebx
f010360e:	83 ec 04             	sub    $0x4,%esp
f0103611:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   //	and make sure you have set the relevant parts of
	   //	e->env_tf to sensible values.

	   // LAB 3: Your code here.

	   if (curenv != NULL && curenv -> env_status == ENV_RUNNING)
f0103614:	e8 09 26 00 00       	call   f0105c22 <cpunum>
f0103619:	6b c0 74             	imul   $0x74,%eax,%eax
f010361c:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0103623:	74 29                	je     f010364e <env_run+0x44>
f0103625:	e8 f8 25 00 00       	call   f0105c22 <cpunum>
f010362a:	6b c0 74             	imul   $0x74,%eax,%eax
f010362d:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103633:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103637:	75 15                	jne    f010364e <env_run+0x44>
			 curenv -> env_status = ENV_RUNNABLE;
f0103639:	e8 e4 25 00 00       	call   f0105c22 <cpunum>
f010363e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103641:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103647:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	   curenv = e;
f010364e:	e8 cf 25 00 00       	call   f0105c22 <cpunum>
f0103653:	6b c0 74             	imul   $0x74,%eax,%eax
f0103656:	89 98 28 30 21 f0    	mov    %ebx,-0xfdecfd8(%eax)
	   e -> env_status = ENV_RUNNING;
f010365c:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	   e-> env_runs ++;
f0103663:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	   lcr3(PADDR(e -> env_pgdir));
f0103667:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010366a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010366f:	77 15                	ja     f0103686 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103671:	50                   	push   %eax
f0103672:	68 08 63 10 f0       	push   $0xf0106308
f0103677:	68 43 02 00 00       	push   $0x243
f010367c:	68 a6 75 10 f0       	push   $0xf01075a6
f0103681:	e8 ba c9 ff ff       	call   f0100040 <_panic>
f0103686:	05 00 00 00 10       	add    $0x10000000,%eax
f010368b:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010368e:	83 ec 0c             	sub    $0xc,%esp
f0103691:	68 c0 03 12 f0       	push   $0xf01203c0
f0103696:	e8 92 28 00 00       	call   f0105f2d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010369b:	f3 90                	pause  

	   unlock_kernel();
	   env_pop_tf (&e -> env_tf);
f010369d:	89 1c 24             	mov    %ebx,(%esp)
f01036a0:	e8 27 ff ff ff       	call   f01035cc <env_pop_tf>

f01036a5 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036a5:	55                   	push   %ebp
f01036a6:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036a8:	ba 70 00 00 00       	mov    $0x70,%edx
f01036ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036b1:	ba 71 00 00 00       	mov    $0x71,%edx
f01036b6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036b7:	0f b6 c0             	movzbl %al,%eax
}
f01036ba:	5d                   	pop    %ebp
f01036bb:	c3                   	ret    

f01036bc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036bc:	55                   	push   %ebp
f01036bd:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036bf:	ba 70 00 00 00       	mov    $0x70,%edx
f01036c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01036c7:	ee                   	out    %al,(%dx)
f01036c8:	ba 71 00 00 00       	mov    $0x71,%edx
f01036cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036d0:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036d1:	5d                   	pop    %ebp
f01036d2:	c3                   	ret    

f01036d3 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01036d3:	55                   	push   %ebp
f01036d4:	89 e5                	mov    %esp,%ebp
f01036d6:	56                   	push   %esi
f01036d7:	53                   	push   %ebx
f01036d8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01036db:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f01036e1:	80 3d 50 22 21 f0 00 	cmpb   $0x0,0xf0212250
f01036e8:	74 5a                	je     f0103744 <irq_setmask_8259A+0x71>
f01036ea:	89 c6                	mov    %eax,%esi
f01036ec:	ba 21 00 00 00       	mov    $0x21,%edx
f01036f1:	ee                   	out    %al,(%dx)
f01036f2:	66 c1 e8 08          	shr    $0x8,%ax
f01036f6:	ba a1 00 00 00       	mov    $0xa1,%edx
f01036fb:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01036fc:	83 ec 0c             	sub    $0xc,%esp
f01036ff:	68 2c 76 10 f0       	push   $0xf010762c
f0103704:	e8 1b 01 00 00       	call   f0103824 <cprintf>
f0103709:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010370c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103711:	0f b7 f6             	movzwl %si,%esi
f0103714:	f7 d6                	not    %esi
f0103716:	0f a3 de             	bt     %ebx,%esi
f0103719:	73 11                	jae    f010372c <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010371b:	83 ec 08             	sub    $0x8,%esp
f010371e:	53                   	push   %ebx
f010371f:	68 4f 7b 10 f0       	push   $0xf0107b4f
f0103724:	e8 fb 00 00 00       	call   f0103824 <cprintf>
f0103729:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010372c:	83 c3 01             	add    $0x1,%ebx
f010372f:	83 fb 10             	cmp    $0x10,%ebx
f0103732:	75 e2                	jne    f0103716 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103734:	83 ec 0c             	sub    $0xc,%esp
f0103737:	68 61 66 10 f0       	push   $0xf0106661
f010373c:	e8 e3 00 00 00       	call   f0103824 <cprintf>
f0103741:	83 c4 10             	add    $0x10,%esp
}
f0103744:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103747:	5b                   	pop    %ebx
f0103748:	5e                   	pop    %esi
f0103749:	5d                   	pop    %ebp
f010374a:	c3                   	ret    

f010374b <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010374b:	c6 05 50 22 21 f0 01 	movb   $0x1,0xf0212250
f0103752:	ba 21 00 00 00       	mov    $0x21,%edx
f0103757:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010375c:	ee                   	out    %al,(%dx)
f010375d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103762:	ee                   	out    %al,(%dx)
f0103763:	ba 20 00 00 00       	mov    $0x20,%edx
f0103768:	b8 11 00 00 00       	mov    $0x11,%eax
f010376d:	ee                   	out    %al,(%dx)
f010376e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103773:	b8 20 00 00 00       	mov    $0x20,%eax
f0103778:	ee                   	out    %al,(%dx)
f0103779:	b8 04 00 00 00       	mov    $0x4,%eax
f010377e:	ee                   	out    %al,(%dx)
f010377f:	b8 03 00 00 00       	mov    $0x3,%eax
f0103784:	ee                   	out    %al,(%dx)
f0103785:	ba a0 00 00 00       	mov    $0xa0,%edx
f010378a:	b8 11 00 00 00       	mov    $0x11,%eax
f010378f:	ee                   	out    %al,(%dx)
f0103790:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103795:	b8 28 00 00 00       	mov    $0x28,%eax
f010379a:	ee                   	out    %al,(%dx)
f010379b:	b8 02 00 00 00       	mov    $0x2,%eax
f01037a0:	ee                   	out    %al,(%dx)
f01037a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01037a6:	ee                   	out    %al,(%dx)
f01037a7:	ba 20 00 00 00       	mov    $0x20,%edx
f01037ac:	b8 68 00 00 00       	mov    $0x68,%eax
f01037b1:	ee                   	out    %al,(%dx)
f01037b2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037b7:	ee                   	out    %al,(%dx)
f01037b8:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037bd:	b8 68 00 00 00       	mov    $0x68,%eax
f01037c2:	ee                   	out    %al,(%dx)
f01037c3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037c8:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01037c9:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01037d0:	66 83 f8 ff          	cmp    $0xffff,%ax
f01037d4:	74 13                	je     f01037e9 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01037d6:	55                   	push   %ebp
f01037d7:	89 e5                	mov    %esp,%ebp
f01037d9:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01037dc:	0f b7 c0             	movzwl %ax,%eax
f01037df:	50                   	push   %eax
f01037e0:	e8 ee fe ff ff       	call   f01036d3 <irq_setmask_8259A>
f01037e5:	83 c4 10             	add    $0x10,%esp
}
f01037e8:	c9                   	leave  
f01037e9:	f3 c3                	repz ret 

f01037eb <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01037eb:	55                   	push   %ebp
f01037ec:	89 e5                	mov    %esp,%ebp
f01037ee:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01037f1:	ff 75 08             	pushl  0x8(%ebp)
f01037f4:	e8 89 cf ff ff       	call   f0100782 <cputchar>
	*cnt++;
}
f01037f9:	83 c4 10             	add    $0x10,%esp
f01037fc:	c9                   	leave  
f01037fd:	c3                   	ret    

f01037fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01037fe:	55                   	push   %ebp
f01037ff:	89 e5                	mov    %esp,%ebp
f0103801:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103804:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010380b:	ff 75 0c             	pushl  0xc(%ebp)
f010380e:	ff 75 08             	pushl  0x8(%ebp)
f0103811:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103814:	50                   	push   %eax
f0103815:	68 eb 37 10 f0       	push   $0xf01037eb
f010381a:	e8 5c 17 00 00       	call   f0104f7b <vprintfmt>
	return cnt;
}
f010381f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103822:	c9                   	leave  
f0103823:	c3                   	ret    

f0103824 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103824:	55                   	push   %ebp
f0103825:	89 e5                	mov    %esp,%ebp
f0103827:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010382a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010382d:	50                   	push   %eax
f010382e:	ff 75 08             	pushl  0x8(%ebp)
f0103831:	e8 c8 ff ff ff       	call   f01037fe <vcprintf>
	va_end(ap);

	return cnt;
}
f0103836:	c9                   	leave  
f0103837:	c3                   	ret    

f0103838 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
	   void
trap_init_percpu(void)
{
f0103838:	55                   	push   %ebp
f0103839:	89 e5                	mov    %esp,%ebp
f010383b:	56                   	push   %esi
f010383c:	53                   	push   %ebx
	   //
	   // LAB 4: Your code here:

	   // Setup a TSS so that we get the right stack
	   // when we trap to the kernel.
	   struct Taskstate* ts_cpu = &thiscpu -> cpu_ts;
f010383d:	e8 e0 23 00 00       	call   f0105c22 <cpunum>
f0103842:	6b f0 74             	imul   $0x74,%eax,%esi
f0103845:	8d 9e 2c 30 21 f0    	lea    -0xfdecfd4(%esi),%ebx
	   ts_cpu -> ts_esp0 = KSTACKTOP - thiscpu -> cpu_id * (KSTKSIZE + KSTKGAP);
f010384b:	e8 d2 23 00 00       	call   f0105c22 <cpunum>
f0103850:	6b c0 74             	imul   $0x74,%eax,%eax
f0103853:	0f b6 90 20 30 21 f0 	movzbl -0xfdecfe0(%eax),%edx
f010385a:	c1 e2 10             	shl    $0x10,%edx
f010385d:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f0103862:	29 d0                	sub    %edx,%eax
f0103864:	89 86 30 30 21 f0    	mov    %eax,-0xfdecfd0(%esi)
	   ts_cpu -> ts_ss0 = GD_KD;
f010386a:	66 c7 86 34 30 21 f0 	movw   $0x10,-0xfdecfcc(%esi)
f0103871:	10 00 
	   ts_cpu -> ts_iomb = sizeof (struct Taskstate);
f0103873:	66 c7 86 92 30 21 f0 	movw   $0x68,-0xfdecf6e(%esi)
f010387a:	68 00 

	   // Initialize the TSS slot of the gdt.
	   gdt[(GD_TSS0 >> 3) + thiscpu -> cpu_id] = SEG16(STS_T32A, (uint32_t) (ts_cpu),
f010387c:	e8 a1 23 00 00       	call   f0105c22 <cpunum>
f0103881:	6b c0 74             	imul   $0x74,%eax,%eax
f0103884:	0f b6 80 20 30 21 f0 	movzbl -0xfdecfe0(%eax),%eax
f010388b:	83 c0 05             	add    $0x5,%eax
f010388e:	66 c7 04 c5 40 03 12 	movw   $0x67,-0xfedfcc0(,%eax,8)
f0103895:	f0 67 00 
f0103898:	66 89 1c c5 42 03 12 	mov    %bx,-0xfedfcbe(,%eax,8)
f010389f:	f0 
f01038a0:	89 da                	mov    %ebx,%edx
f01038a2:	c1 ea 10             	shr    $0x10,%edx
f01038a5:	88 14 c5 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%eax,8)
f01038ac:	c6 04 c5 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%eax,8)
f01038b3:	99 
f01038b4:	c6 04 c5 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%eax,8)
f01038bb:	40 
f01038bc:	c1 eb 18             	shr    $0x18,%ebx
f01038bf:	88 1c c5 47 03 12 f0 	mov    %bl,-0xfedfcb9(,%eax,8)
				    sizeof(struct Taskstate) - 1, 0);
	   gdt[(GD_TSS0 >> 3) + thiscpu -> cpu_id].sd_s = 0;
f01038c6:	e8 57 23 00 00       	call   f0105c22 <cpunum>
f01038cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ce:	0f b6 80 20 30 21 f0 	movzbl -0xfdecfe0(%eax),%eax
f01038d5:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f01038dc:	ef 

	   // Load the TSS selector (like other segment selectors, the
	   // bottom three bits are special; we leave them 0)
	   ltr(GD_TSS0 + (thiscpu -> cpu_id << 3));
f01038dd:	e8 40 23 00 00       	call   f0105c22 <cpunum>
f01038e2:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f01038e5:	0f b6 80 20 30 21 f0 	movzbl -0xfdecfe0(%eax),%eax
f01038ec:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f01038f3:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f01038f6:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f01038fb:	0f 01 18             	lidtl  (%eax)
	   // bottom three bits are special; we leave them 0)
	   ltr(GD_TSS0);

	   // Load the IDT
	   lidt(&idt_pd);*/
}
f01038fe:	5b                   	pop    %ebx
f01038ff:	5e                   	pop    %esi
f0103900:	5d                   	pop    %ebp
f0103901:	c3                   	ret    

f0103902 <trap_init>:
{
	   extern struct Segdesc gdt[];

	   // LAB 3: Your code here.

	   SETGATE(idt[T_DIVIDE], false, GD_KT, divide_exception, 0);
f0103902:	b8 d0 42 10 f0       	mov    $0xf01042d0,%eax
f0103907:	66 a3 60 22 21 f0    	mov    %ax,0xf0212260
f010390d:	66 c7 05 62 22 21 f0 	movw   $0x8,0xf0212262
f0103914:	08 00 
f0103916:	c6 05 64 22 21 f0 00 	movb   $0x0,0xf0212264
f010391d:	c6 05 65 22 21 f0 8e 	movb   $0x8e,0xf0212265
f0103924:	c1 e8 10             	shr    $0x10,%eax
f0103927:	66 a3 66 22 21 f0    	mov    %ax,0xf0212266
	   SETGATE(idt[T_DEBUG], false, GD_KT, debug_exception, 0);
f010392d:	b8 da 42 10 f0       	mov    $0xf01042da,%eax
f0103932:	66 a3 68 22 21 f0    	mov    %ax,0xf0212268
f0103938:	66 c7 05 6a 22 21 f0 	movw   $0x8,0xf021226a
f010393f:	08 00 
f0103941:	c6 05 6c 22 21 f0 00 	movb   $0x0,0xf021226c
f0103948:	c6 05 6d 22 21 f0 8e 	movb   $0x8e,0xf021226d
f010394f:	c1 e8 10             	shr    $0x10,%eax
f0103952:	66 a3 6e 22 21 f0    	mov    %ax,0xf021226e
	   SETGATE(idt[T_NMI], false, GD_KT, nmi_interupt, 0);
f0103958:	b8 e0 42 10 f0       	mov    $0xf01042e0,%eax
f010395d:	66 a3 70 22 21 f0    	mov    %ax,0xf0212270
f0103963:	66 c7 05 72 22 21 f0 	movw   $0x8,0xf0212272
f010396a:	08 00 
f010396c:	c6 05 74 22 21 f0 00 	movb   $0x0,0xf0212274
f0103973:	c6 05 75 22 21 f0 8e 	movb   $0x8e,0xf0212275
f010397a:	c1 e8 10             	shr    $0x10,%eax
f010397d:	66 a3 76 22 21 f0    	mov    %ax,0xf0212276
	   SETGATE(idt[T_BRKPT], false, GD_KT, breakpoint_exception, 3);
f0103983:	b8 e6 42 10 f0       	mov    $0xf01042e6,%eax
f0103988:	66 a3 78 22 21 f0    	mov    %ax,0xf0212278
f010398e:	66 c7 05 7a 22 21 f0 	movw   $0x8,0xf021227a
f0103995:	08 00 
f0103997:	c6 05 7c 22 21 f0 00 	movb   $0x0,0xf021227c
f010399e:	c6 05 7d 22 21 f0 ee 	movb   $0xee,0xf021227d
f01039a5:	c1 e8 10             	shr    $0x10,%eax
f01039a8:	66 a3 7e 22 21 f0    	mov    %ax,0xf021227e
	   SETGATE(idt[T_OFLOW], false, GD_KT, overflow_exception, 0);
f01039ae:	b8 ec 42 10 f0       	mov    $0xf01042ec,%eax
f01039b3:	66 a3 80 22 21 f0    	mov    %ax,0xf0212280
f01039b9:	66 c7 05 82 22 21 f0 	movw   $0x8,0xf0212282
f01039c0:	08 00 
f01039c2:	c6 05 84 22 21 f0 00 	movb   $0x0,0xf0212284
f01039c9:	c6 05 85 22 21 f0 8e 	movb   $0x8e,0xf0212285
f01039d0:	c1 e8 10             	shr    $0x10,%eax
f01039d3:	66 a3 86 22 21 f0    	mov    %ax,0xf0212286
	   SETGATE(idt[T_BOUND], false, GD_KT, bounds_check_exception, 0);
f01039d9:	b8 f2 42 10 f0       	mov    $0xf01042f2,%eax
f01039de:	66 a3 88 22 21 f0    	mov    %ax,0xf0212288
f01039e4:	66 c7 05 8a 22 21 f0 	movw   $0x8,0xf021228a
f01039eb:	08 00 
f01039ed:	c6 05 8c 22 21 f0 00 	movb   $0x0,0xf021228c
f01039f4:	c6 05 8d 22 21 f0 8e 	movb   $0x8e,0xf021228d
f01039fb:	c1 e8 10             	shr    $0x10,%eax
f01039fe:	66 a3 8e 22 21 f0    	mov    %ax,0xf021228e
	   SETGATE(idt[T_ILLOP], false, GD_KT, illegal_opcode_exception, 0);
f0103a04:	b8 f8 42 10 f0       	mov    $0xf01042f8,%eax
f0103a09:	66 a3 90 22 21 f0    	mov    %ax,0xf0212290
f0103a0f:	66 c7 05 92 22 21 f0 	movw   $0x8,0xf0212292
f0103a16:	08 00 
f0103a18:	c6 05 94 22 21 f0 00 	movb   $0x0,0xf0212294
f0103a1f:	c6 05 95 22 21 f0 8e 	movb   $0x8e,0xf0212295
f0103a26:	c1 e8 10             	shr    $0x10,%eax
f0103a29:	66 a3 96 22 21 f0    	mov    %ax,0xf0212296
	   SETGATE(idt[T_DEVICE], false, GD_KT, coprocessor_exception, 0);
f0103a2f:	b8 fe 42 10 f0       	mov    $0xf01042fe,%eax
f0103a34:	66 a3 98 22 21 f0    	mov    %ax,0xf0212298
f0103a3a:	66 c7 05 9a 22 21 f0 	movw   $0x8,0xf021229a
f0103a41:	08 00 
f0103a43:	c6 05 9c 22 21 f0 00 	movb   $0x0,0xf021229c
f0103a4a:	c6 05 9d 22 21 f0 8e 	movb   $0x8e,0xf021229d
f0103a51:	c1 e8 10             	shr    $0x10,%eax
f0103a54:	66 a3 9e 22 21 f0    	mov    %ax,0xf021229e
	   SETGATE(idt[T_DBLFLT], false, GD_KT, double_fault_exception, 0);
f0103a5a:	b8 04 43 10 f0       	mov    $0xf0104304,%eax
f0103a5f:	66 a3 a0 22 21 f0    	mov    %ax,0xf02122a0
f0103a65:	66 c7 05 a2 22 21 f0 	movw   $0x8,0xf02122a2
f0103a6c:	08 00 
f0103a6e:	c6 05 a4 22 21 f0 00 	movb   $0x0,0xf02122a4
f0103a75:	c6 05 a5 22 21 f0 8e 	movb   $0x8e,0xf02122a5
f0103a7c:	c1 e8 10             	shr    $0x10,%eax
f0103a7f:	66 a3 a6 22 21 f0    	mov    %ax,0xf02122a6
	   SETGATE(idt[T_TSS], false, GD_KT, tss_exception, 0);
f0103a85:	b8 08 43 10 f0       	mov    $0xf0104308,%eax
f0103a8a:	66 a3 b0 22 21 f0    	mov    %ax,0xf02122b0
f0103a90:	66 c7 05 b2 22 21 f0 	movw   $0x8,0xf02122b2
f0103a97:	08 00 
f0103a99:	c6 05 b4 22 21 f0 00 	movb   $0x0,0xf02122b4
f0103aa0:	c6 05 b5 22 21 f0 8e 	movb   $0x8e,0xf02122b5
f0103aa7:	c1 e8 10             	shr    $0x10,%eax
f0103aaa:	66 a3 b6 22 21 f0    	mov    %ax,0xf02122b6
	   SETGATE(idt[T_SEGNP], false, GD_KT, segment_np_exception, 0);
f0103ab0:	b8 0c 43 10 f0       	mov    $0xf010430c,%eax
f0103ab5:	66 a3 b8 22 21 f0    	mov    %ax,0xf02122b8
f0103abb:	66 c7 05 ba 22 21 f0 	movw   $0x8,0xf02122ba
f0103ac2:	08 00 
f0103ac4:	c6 05 bc 22 21 f0 00 	movb   $0x0,0xf02122bc
f0103acb:	c6 05 bd 22 21 f0 8e 	movb   $0x8e,0xf02122bd
f0103ad2:	c1 e8 10             	shr    $0x10,%eax
f0103ad5:	66 a3 be 22 21 f0    	mov    %ax,0xf02122be
	   SETGATE(idt[T_STACK], false, GD_KT, stack_np_excecption, 0);
f0103adb:	b8 10 43 10 f0       	mov    $0xf0104310,%eax
f0103ae0:	66 a3 c0 22 21 f0    	mov    %ax,0xf02122c0
f0103ae6:	66 c7 05 c2 22 21 f0 	movw   $0x8,0xf02122c2
f0103aed:	08 00 
f0103aef:	c6 05 c4 22 21 f0 00 	movb   $0x0,0xf02122c4
f0103af6:	c6 05 c5 22 21 f0 8e 	movb   $0x8e,0xf02122c5
f0103afd:	c1 e8 10             	shr    $0x10,%eax
f0103b00:	66 a3 c6 22 21 f0    	mov    %ax,0xf02122c6
	   SETGATE(idt[T_GPFLT], false, GD_KT, general_protection_fault, 0);
f0103b06:	b8 14 43 10 f0       	mov    $0xf0104314,%eax
f0103b0b:	66 a3 c8 22 21 f0    	mov    %ax,0xf02122c8
f0103b11:	66 c7 05 ca 22 21 f0 	movw   $0x8,0xf02122ca
f0103b18:	08 00 
f0103b1a:	c6 05 cc 22 21 f0 00 	movb   $0x0,0xf02122cc
f0103b21:	c6 05 cd 22 21 f0 8e 	movb   $0x8e,0xf02122cd
f0103b28:	c1 e8 10             	shr    $0x10,%eax
f0103b2b:	66 a3 ce 22 21 f0    	mov    %ax,0xf02122ce
	   SETGATE(idt[T_PGFLT], false, GD_KT, page_fault_exception,0);
f0103b31:	b8 18 43 10 f0       	mov    $0xf0104318,%eax
f0103b36:	66 a3 d0 22 21 f0    	mov    %ax,0xf02122d0
f0103b3c:	66 c7 05 d2 22 21 f0 	movw   $0x8,0xf02122d2
f0103b43:	08 00 
f0103b45:	c6 05 d4 22 21 f0 00 	movb   $0x0,0xf02122d4
f0103b4c:	c6 05 d5 22 21 f0 8e 	movb   $0x8e,0xf02122d5
f0103b53:	c1 e8 10             	shr    $0x10,%eax
f0103b56:	66 a3 d6 22 21 f0    	mov    %ax,0xf02122d6
	   SETGATE(idt[T_FPERR], false, GD_KT, fp_err_exception, 0);
f0103b5c:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f0103b61:	66 a3 e0 22 21 f0    	mov    %ax,0xf02122e0
f0103b67:	66 c7 05 e2 22 21 f0 	movw   $0x8,0xf02122e2
f0103b6e:	08 00 
f0103b70:	c6 05 e4 22 21 f0 00 	movb   $0x0,0xf02122e4
f0103b77:	c6 05 e5 22 21 f0 8e 	movb   $0x8e,0xf02122e5
f0103b7e:	c1 e8 10             	shr    $0x10,%eax
f0103b81:	66 a3 e6 22 21 f0    	mov    %ax,0xf02122e6
	   SETGATE(idt[T_ALIGN], false, GD_KT, alignment_exception, 0);
f0103b87:	b8 22 43 10 f0       	mov    $0xf0104322,%eax
f0103b8c:	66 a3 e8 22 21 f0    	mov    %ax,0xf02122e8
f0103b92:	66 c7 05 ea 22 21 f0 	movw   $0x8,0xf02122ea
f0103b99:	08 00 
f0103b9b:	c6 05 ec 22 21 f0 00 	movb   $0x0,0xf02122ec
f0103ba2:	c6 05 ed 22 21 f0 8e 	movb   $0x8e,0xf02122ed
f0103ba9:	c1 e8 10             	shr    $0x10,%eax
f0103bac:	66 a3 ee 22 21 f0    	mov    %ax,0xf02122ee
	   SETGATE(idt[T_MCHK], false, GD_KT, machine_exception, 0);
f0103bb2:	b8 26 43 10 f0       	mov    $0xf0104326,%eax
f0103bb7:	66 a3 f0 22 21 f0    	mov    %ax,0xf02122f0
f0103bbd:	66 c7 05 f2 22 21 f0 	movw   $0x8,0xf02122f2
f0103bc4:	08 00 
f0103bc6:	c6 05 f4 22 21 f0 00 	movb   $0x0,0xf02122f4
f0103bcd:	c6 05 f5 22 21 f0 8e 	movb   $0x8e,0xf02122f5
f0103bd4:	c1 e8 10             	shr    $0x10,%eax
f0103bd7:	66 a3 f6 22 21 f0    	mov    %ax,0xf02122f6
	   SETGATE(idt[T_SIMDERR], false, GD_KT, SIMDerr_exception, 0);
f0103bdd:	b8 2c 43 10 f0       	mov    $0xf010432c,%eax
f0103be2:	66 a3 f8 22 21 f0    	mov    %ax,0xf02122f8
f0103be8:	66 c7 05 fa 22 21 f0 	movw   $0x8,0xf02122fa
f0103bef:	08 00 
f0103bf1:	c6 05 fc 22 21 f0 00 	movb   $0x0,0xf02122fc
f0103bf8:	c6 05 fd 22 21 f0 8e 	movb   $0x8e,0xf02122fd
f0103bff:	c1 e8 10             	shr    $0x10,%eax
f0103c02:	66 a3 fe 22 21 f0    	mov    %ax,0xf02122fe

	   SETGATE (idt[T_SYSCALL], false, GD_KT, syscall_interrupt, 3);
f0103c08:	b8 32 43 10 f0       	mov    $0xf0104332,%eax
f0103c0d:	66 a3 e0 23 21 f0    	mov    %ax,0xf02123e0
f0103c13:	66 c7 05 e2 23 21 f0 	movw   $0x8,0xf02123e2
f0103c1a:	08 00 
f0103c1c:	c6 05 e4 23 21 f0 00 	movb   $0x0,0xf02123e4
f0103c23:	c6 05 e5 23 21 f0 ee 	movb   $0xee,0xf02123e5
f0103c2a:	c1 e8 10             	shr    $0x10,%eax
f0103c2d:	66 a3 e6 23 21 f0    	mov    %ax,0xf02123e6


	   for (int i = 0; i < 15; i ++)
	   {
			 SETGATE (idt[IRQ_OFFSET + i], false, GD_KT, IRQ_ErrorINT, 0);
f0103c33:	ba 48 43 10 f0       	mov    $0xf0104348,%edx
f0103c38:	c1 ea 10             	shr    $0x10,%edx
f0103c3b:	b8 20 00 00 00       	mov    $0x20,%eax
f0103c40:	b9 48 43 10 f0       	mov    $0xf0104348,%ecx
f0103c45:	66 89 0c c5 60 22 21 	mov    %cx,-0xfdedda0(,%eax,8)
f0103c4c:	f0 
f0103c4d:	66 c7 04 c5 62 22 21 	movw   $0x8,-0xfdedd9e(,%eax,8)
f0103c54:	f0 08 00 
f0103c57:	c6 04 c5 64 22 21 f0 	movb   $0x0,-0xfdedd9c(,%eax,8)
f0103c5e:	00 
f0103c5f:	c6 04 c5 65 22 21 f0 	movb   $0x8e,-0xfdedd9b(,%eax,8)
f0103c66:	8e 
f0103c67:	66 89 14 c5 66 22 21 	mov    %dx,-0xfdedd9a(,%eax,8)
f0103c6e:	f0 
f0103c6f:	83 c0 01             	add    $0x1,%eax
	   SETGATE(idt[T_SIMDERR], false, GD_KT, SIMDerr_exception, 0);

	   SETGATE (idt[T_SYSCALL], false, GD_KT, syscall_interrupt, 3);


	   for (int i = 0; i < 15; i ++)
f0103c72:	83 f8 2f             	cmp    $0x2f,%eax
f0103c75:	75 ce                	jne    f0103c45 <trap_init+0x343>
}


	   void
trap_init(void)
{
f0103c77:	55                   	push   %ebp
f0103c78:	89 e5                	mov    %esp,%ebp
f0103c7a:	83 ec 08             	sub    $0x8,%esp
	   for (int i = 0; i < 15; i ++)
	   {
			 SETGATE (idt[IRQ_OFFSET + i], false, GD_KT, IRQ_ErrorINT, 0);
	   }

	   SETGATE (idt[IRQ_OFFSET + IRQ_TIMER], false, GD_KT, IRQ_TimerINT, 0);
f0103c7d:	b8 42 43 10 f0       	mov    $0xf0104342,%eax
f0103c82:	66 a3 60 23 21 f0    	mov    %ax,0xf0212360
f0103c88:	66 c7 05 62 23 21 f0 	movw   $0x8,0xf0212362
f0103c8f:	08 00 
f0103c91:	c6 05 64 23 21 f0 00 	movb   $0x0,0xf0212364
f0103c98:	c6 05 65 23 21 f0 8e 	movb   $0x8e,0xf0212365
f0103c9f:	c1 e8 10             	shr    $0x10,%eax
f0103ca2:	66 a3 66 23 21 f0    	mov    %ax,0xf0212366
	   SETGATE (idt[IRQ_OFFSET + IRQ_KBD], false, GD_KT, IRQ_KeyboardINT, 0);
f0103ca8:	b8 4e 43 10 f0       	mov    $0xf010434e,%eax
f0103cad:	66 a3 68 23 21 f0    	mov    %ax,0xf0212368
f0103cb3:	66 c7 05 6a 23 21 f0 	movw   $0x8,0xf021236a
f0103cba:	08 00 
f0103cbc:	c6 05 6c 23 21 f0 00 	movb   $0x0,0xf021236c
f0103cc3:	c6 05 6d 23 21 f0 8e 	movb   $0x8e,0xf021236d
f0103cca:	c1 e8 10             	shr    $0x10,%eax
f0103ccd:	66 a3 6e 23 21 f0    	mov    %ax,0xf021236e
	   SETGATE (idt[IRQ_OFFSET + IRQ_SERIAL], false, GD_KT, IRQ_SerialINT, 0);
f0103cd3:	b8 54 43 10 f0       	mov    $0xf0104354,%eax
f0103cd8:	66 a3 80 23 21 f0    	mov    %ax,0xf0212380
f0103cde:	66 c7 05 82 23 21 f0 	movw   $0x8,0xf0212382
f0103ce5:	08 00 
f0103ce7:	c6 05 84 23 21 f0 00 	movb   $0x0,0xf0212384
f0103cee:	c6 05 85 23 21 f0 8e 	movb   $0x8e,0xf0212385
f0103cf5:	c1 e8 10             	shr    $0x10,%eax
f0103cf8:	66 a3 86 23 21 f0    	mov    %ax,0xf0212386

	   // Per-CPU setup 
	   trap_init_percpu();
f0103cfe:	e8 35 fb ff ff       	call   f0103838 <trap_init_percpu>
}
f0103d03:	c9                   	leave  
f0103d04:	c3                   	ret    

f0103d05 <print_regs>:
	   }
}

	   void
print_regs(struct PushRegs *regs)
{
f0103d05:	55                   	push   %ebp
f0103d06:	89 e5                	mov    %esp,%ebp
f0103d08:	53                   	push   %ebx
f0103d09:	83 ec 0c             	sub    $0xc,%esp
f0103d0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d0f:	ff 33                	pushl  (%ebx)
f0103d11:	68 40 76 10 f0       	push   $0xf0107640
f0103d16:	e8 09 fb ff ff       	call   f0103824 <cprintf>
	   cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d1b:	83 c4 08             	add    $0x8,%esp
f0103d1e:	ff 73 04             	pushl  0x4(%ebx)
f0103d21:	68 4f 76 10 f0       	push   $0xf010764f
f0103d26:	e8 f9 fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d2b:	83 c4 08             	add    $0x8,%esp
f0103d2e:	ff 73 08             	pushl  0x8(%ebx)
f0103d31:	68 5e 76 10 f0       	push   $0xf010765e
f0103d36:	e8 e9 fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d3b:	83 c4 08             	add    $0x8,%esp
f0103d3e:	ff 73 0c             	pushl  0xc(%ebx)
f0103d41:	68 6d 76 10 f0       	push   $0xf010766d
f0103d46:	e8 d9 fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d4b:	83 c4 08             	add    $0x8,%esp
f0103d4e:	ff 73 10             	pushl  0x10(%ebx)
f0103d51:	68 7c 76 10 f0       	push   $0xf010767c
f0103d56:	e8 c9 fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d5b:	83 c4 08             	add    $0x8,%esp
f0103d5e:	ff 73 14             	pushl  0x14(%ebx)
f0103d61:	68 8b 76 10 f0       	push   $0xf010768b
f0103d66:	e8 b9 fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d6b:	83 c4 08             	add    $0x8,%esp
f0103d6e:	ff 73 18             	pushl  0x18(%ebx)
f0103d71:	68 9a 76 10 f0       	push   $0xf010769a
f0103d76:	e8 a9 fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d7b:	83 c4 08             	add    $0x8,%esp
f0103d7e:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d81:	68 a9 76 10 f0       	push   $0xf01076a9
f0103d86:	e8 99 fa ff ff       	call   f0103824 <cprintf>
}
f0103d8b:	83 c4 10             	add    $0x10,%esp
f0103d8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d91:	c9                   	leave  
f0103d92:	c3                   	ret    

f0103d93 <print_trapframe>:
	   lidt(&idt_pd);*/
}

	   void
print_trapframe(struct Trapframe *tf)
{
f0103d93:	55                   	push   %ebp
f0103d94:	89 e5                	mov    %esp,%ebp
f0103d96:	56                   	push   %esi
f0103d97:	53                   	push   %ebx
f0103d98:	8b 5d 08             	mov    0x8(%ebp),%ebx

	   cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d9b:	e8 82 1e 00 00       	call   f0105c22 <cpunum>
f0103da0:	83 ec 04             	sub    $0x4,%esp
f0103da3:	50                   	push   %eax
f0103da4:	53                   	push   %ebx
f0103da5:	68 0d 77 10 f0       	push   $0xf010770d
f0103daa:	e8 75 fa ff ff       	call   f0103824 <cprintf>
	   print_regs(&tf->tf_regs);
f0103daf:	89 1c 24             	mov    %ebx,(%esp)
f0103db2:	e8 4e ff ff ff       	call   f0103d05 <print_regs>
	   cprintf("  es   0x----%04x\n", tf->tf_es);
f0103db7:	83 c4 08             	add    $0x8,%esp
f0103dba:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103dbe:	50                   	push   %eax
f0103dbf:	68 2b 77 10 f0       	push   $0xf010772b
f0103dc4:	e8 5b fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103dc9:	83 c4 08             	add    $0x8,%esp
f0103dcc:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103dd0:	50                   	push   %eax
f0103dd1:	68 3e 77 10 f0       	push   $0xf010773e
f0103dd6:	e8 49 fa ff ff       	call   f0103824 <cprintf>
	   cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ddb:	8b 43 28             	mov    0x28(%ebx),%eax
			 "Alignment Check",
			 "Machine-Check",
			 "SIMD Floating-Point Exception"
	   };

	   if (trapno < ARRAY_SIZE(excnames))
f0103dde:	83 c4 10             	add    $0x10,%esp
f0103de1:	83 f8 13             	cmp    $0x13,%eax
f0103de4:	77 09                	ja     f0103def <print_trapframe+0x5c>
			 return excnames[trapno];
f0103de6:	8b 14 85 40 7a 10 f0 	mov    -0xfef85c0(,%eax,4),%edx
f0103ded:	eb 1f                	jmp    f0103e0e <print_trapframe+0x7b>
	   if (trapno == T_SYSCALL)
f0103def:	83 f8 30             	cmp    $0x30,%eax
f0103df2:	74 15                	je     f0103e09 <print_trapframe+0x76>
			 return "System call";
	   if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103df4:	8d 50 e0             	lea    -0x20(%eax),%edx
			 return "Hardware Interrupt";
	   return "(unknown trap)";
f0103df7:	83 fa 10             	cmp    $0x10,%edx
f0103dfa:	b9 d7 76 10 f0       	mov    $0xf01076d7,%ecx
f0103dff:	ba c4 76 10 f0       	mov    $0xf01076c4,%edx
f0103e04:	0f 43 d1             	cmovae %ecx,%edx
f0103e07:	eb 05                	jmp    f0103e0e <print_trapframe+0x7b>
	   };

	   if (trapno < ARRAY_SIZE(excnames))
			 return excnames[trapno];
	   if (trapno == T_SYSCALL)
			 return "System call";
f0103e09:	ba b8 76 10 f0       	mov    $0xf01076b8,%edx

	   cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	   print_regs(&tf->tf_regs);
	   cprintf("  es   0x----%04x\n", tf->tf_es);
	   cprintf("  ds   0x----%04x\n", tf->tf_ds);
	   cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e0e:	83 ec 04             	sub    $0x4,%esp
f0103e11:	52                   	push   %edx
f0103e12:	50                   	push   %eax
f0103e13:	68 51 77 10 f0       	push   $0xf0107751
f0103e18:	e8 07 fa ff ff       	call   f0103824 <cprintf>
	   // If this trap was a page fault that just happened
	   // (so %cr2 is meaningful), print the faulting linear address.
	   if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e1d:	83 c4 10             	add    $0x10,%esp
f0103e20:	3b 1d 60 2a 21 f0    	cmp    0xf0212a60,%ebx
f0103e26:	75 1a                	jne    f0103e42 <print_trapframe+0xaf>
f0103e28:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e2c:	75 14                	jne    f0103e42 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e2e:	0f 20 d0             	mov    %cr2,%eax
			 cprintf("  cr2  0x%08x\n", rcr2());
f0103e31:	83 ec 08             	sub    $0x8,%esp
f0103e34:	50                   	push   %eax
f0103e35:	68 63 77 10 f0       	push   $0xf0107763
f0103e3a:	e8 e5 f9 ff ff       	call   f0103824 <cprintf>
f0103e3f:	83 c4 10             	add    $0x10,%esp
	   cprintf("  err  0x%08x", tf->tf_err);
f0103e42:	83 ec 08             	sub    $0x8,%esp
f0103e45:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e48:	68 72 77 10 f0       	push   $0xf0107772
f0103e4d:	e8 d2 f9 ff ff       	call   f0103824 <cprintf>
	   // For page faults, print decoded fault error code:
	   // U/K=fault occurred in user/kernel mode
	   // W/R=a write/read caused the fault
	   // PR=a protection violation caused the fault (NP=page not present).
	   if (tf->tf_trapno == T_PGFLT)
f0103e52:	83 c4 10             	add    $0x10,%esp
f0103e55:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e59:	75 49                	jne    f0103ea4 <print_trapframe+0x111>
			 cprintf(" [%s, %s, %s]\n",
						  tf->tf_err & 4 ? "user" : "kernel",
						  tf->tf_err & 2 ? "write" : "read",
						  tf->tf_err & 1 ? "protection" : "not-present");
f0103e5b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	   // For page faults, print decoded fault error code:
	   // U/K=fault occurred in user/kernel mode
	   // W/R=a write/read caused the fault
	   // PR=a protection violation caused the fault (NP=page not present).
	   if (tf->tf_trapno == T_PGFLT)
			 cprintf(" [%s, %s, %s]\n",
f0103e5e:	89 c2                	mov    %eax,%edx
f0103e60:	83 e2 01             	and    $0x1,%edx
f0103e63:	ba f1 76 10 f0       	mov    $0xf01076f1,%edx
f0103e68:	b9 e6 76 10 f0       	mov    $0xf01076e6,%ecx
f0103e6d:	0f 44 ca             	cmove  %edx,%ecx
f0103e70:	89 c2                	mov    %eax,%edx
f0103e72:	83 e2 02             	and    $0x2,%edx
f0103e75:	ba 03 77 10 f0       	mov    $0xf0107703,%edx
f0103e7a:	be fd 76 10 f0       	mov    $0xf01076fd,%esi
f0103e7f:	0f 45 d6             	cmovne %esi,%edx
f0103e82:	83 e0 04             	and    $0x4,%eax
f0103e85:	be 66 78 10 f0       	mov    $0xf0107866,%esi
f0103e8a:	b8 08 77 10 f0       	mov    $0xf0107708,%eax
f0103e8f:	0f 44 c6             	cmove  %esi,%eax
f0103e92:	51                   	push   %ecx
f0103e93:	52                   	push   %edx
f0103e94:	50                   	push   %eax
f0103e95:	68 80 77 10 f0       	push   $0xf0107780
f0103e9a:	e8 85 f9 ff ff       	call   f0103824 <cprintf>
f0103e9f:	83 c4 10             	add    $0x10,%esp
f0103ea2:	eb 10                	jmp    f0103eb4 <print_trapframe+0x121>
						  tf->tf_err & 4 ? "user" : "kernel",
						  tf->tf_err & 2 ? "write" : "read",
						  tf->tf_err & 1 ? "protection" : "not-present");
	   else
			 cprintf("\n");
f0103ea4:	83 ec 0c             	sub    $0xc,%esp
f0103ea7:	68 61 66 10 f0       	push   $0xf0106661
f0103eac:	e8 73 f9 ff ff       	call   f0103824 <cprintf>
f0103eb1:	83 c4 10             	add    $0x10,%esp
	   cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103eb4:	83 ec 08             	sub    $0x8,%esp
f0103eb7:	ff 73 30             	pushl  0x30(%ebx)
f0103eba:	68 8f 77 10 f0       	push   $0xf010778f
f0103ebf:	e8 60 f9 ff ff       	call   f0103824 <cprintf>
	   cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ec4:	83 c4 08             	add    $0x8,%esp
f0103ec7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103ecb:	50                   	push   %eax
f0103ecc:	68 9e 77 10 f0       	push   $0xf010779e
f0103ed1:	e8 4e f9 ff ff       	call   f0103824 <cprintf>
	   cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ed6:	83 c4 08             	add    $0x8,%esp
f0103ed9:	ff 73 38             	pushl  0x38(%ebx)
f0103edc:	68 b1 77 10 f0       	push   $0xf01077b1
f0103ee1:	e8 3e f9 ff ff       	call   f0103824 <cprintf>
	   if ((tf->tf_cs & 3) != 0) {
f0103ee6:	83 c4 10             	add    $0x10,%esp
f0103ee9:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103eed:	74 25                	je     f0103f14 <print_trapframe+0x181>
			 cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103eef:	83 ec 08             	sub    $0x8,%esp
f0103ef2:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ef5:	68 c0 77 10 f0       	push   $0xf01077c0
f0103efa:	e8 25 f9 ff ff       	call   f0103824 <cprintf>
			 cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103eff:	83 c4 08             	add    $0x8,%esp
f0103f02:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f06:	50                   	push   %eax
f0103f07:	68 cf 77 10 f0       	push   $0xf01077cf
f0103f0c:	e8 13 f9 ff ff       	call   f0103824 <cprintf>
f0103f11:	83 c4 10             	add    $0x10,%esp
	   }
}
f0103f14:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f17:	5b                   	pop    %ebx
f0103f18:	5e                   	pop    %esi
f0103f19:	5d                   	pop    %ebp
f0103f1a:	c3                   	ret    

f0103f1b <page_fault_handler>:
}


	   void
page_fault_handler(struct Trapframe *tf)
{
f0103f1b:	55                   	push   %ebp
f0103f1c:	89 e5                	mov    %esp,%ebp
f0103f1e:	57                   	push   %edi
f0103f1f:	56                   	push   %esi
f0103f20:	53                   	push   %ebx
f0103f21:	83 ec 1c             	sub    $0x1c,%esp
f0103f24:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f27:	0f 20 d6             	mov    %cr2,%esi
	   fault_va = rcr2();

	   // Handle kernel-mode page faults.
	   // LAB 3: Your code here.

	   if((tf -> tf_cs & 0x03) == 0)
f0103f2a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f2e:	75 15                	jne    f0103f45 <page_fault_handler+0x2a>
			 panic ("Page Fault in Kernel at address %x", fault_va);
f0103f30:	56                   	push   %esi
f0103f31:	68 b0 79 10 f0       	push   $0xf01079b0
f0103f36:	68 70 01 00 00       	push   $0x170
f0103f3b:	68 e2 77 10 f0       	push   $0xf01077e2
f0103f40:	e8 fb c0 ff ff       	call   f0100040 <_panic>
	   //   To change what the user environment runs, modify 'curenv->env_tf'
	   //   (the 'tf' variable points at 'curenv->env_tf').

	   // LAB 4: Your code here.

	   if (curenv -> env_pgfault_upcall)
f0103f45:	e8 d8 1c 00 00       	call   f0105c22 <cpunum>
f0103f4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f4d:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103f53:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103f57:	0f 84 af 00 00 00    	je     f010400c <page_fault_handler+0xf1>
	   {
			 uintptr_t stack_top = UXSTACKTOP;
			 uintptr_t stack_bottom = UXSTACKTOP - PGSIZE;

			 if (tf -> tf_esp < UXSTACKTOP && tf -> tf_esp >= stack_bottom)
f0103f5d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f60:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
				    stack_top = tf -> tf_esp - 4;
f0103f66:	83 e8 04             	sub    $0x4,%eax
f0103f69:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103f6f:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0103f74:	0f 46 f8             	cmovbe %eax,%edi

			 struct UTrapframe* utf_addr = (struct UTrapframe *) (stack_top - sizeof (struct UTrapframe));
f0103f77:	8d 47 cc             	lea    -0x34(%edi),%eax
f0103f7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)

			 user_mem_assert (curenv, (void *) utf_addr, sizeof (struct UTrapframe), PTE_U | PTE_W | PTE_P);
f0103f7d:	e8 a0 1c 00 00       	call   f0105c22 <cpunum>
f0103f82:	6a 07                	push   $0x7
f0103f84:	6a 34                	push   $0x34
f0103f86:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103f89:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f8c:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0103f92:	e8 43 ef ff ff       	call   f0102eda <user_mem_assert>

			 utf_addr -> utf_fault_va = fault_va;
f0103f97:	89 77 cc             	mov    %esi,-0x34(%edi)
			 utf_addr -> utf_err = tf -> tf_err;
f0103f9a:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103f9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103fa0:	89 42 04             	mov    %eax,0x4(%edx)
			 utf_addr -> utf_regs = tf -> tf_regs;
f0103fa3:	83 ef 2c             	sub    $0x2c,%edi
f0103fa6:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103fab:	89 de                	mov    %ebx,%esi
f0103fad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			 utf_addr -> utf_eip = tf -> tf_eip;
f0103faf:	8b 43 30             	mov    0x30(%ebx),%eax
f0103fb2:	89 42 28             	mov    %eax,0x28(%edx)
			 utf_addr -> utf_eflags = tf -> tf_eflags;
f0103fb5:	8b 43 38             	mov    0x38(%ebx),%eax
f0103fb8:	89 d6                	mov    %edx,%esi
f0103fba:	89 42 2c             	mov    %eax,0x2c(%edx)
			 utf_addr -> utf_esp = tf -> tf_esp;
f0103fbd:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103fc0:	89 42 30             	mov    %eax,0x30(%edx)

			 curenv -> env_tf.tf_eip = (uintptr_t)(curenv -> env_pgfault_upcall);
f0103fc3:	e8 5a 1c 00 00       	call   f0105c22 <cpunum>
f0103fc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fcb:	8b 98 28 30 21 f0    	mov    -0xfdecfd8(%eax),%ebx
f0103fd1:	e8 4c 1c 00 00       	call   f0105c22 <cpunum>
f0103fd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd9:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103fdf:	8b 40 64             	mov    0x64(%eax),%eax
f0103fe2:	89 43 30             	mov    %eax,0x30(%ebx)
			 curenv -> env_tf.tf_esp = (uintptr_t) utf_addr;
f0103fe5:	e8 38 1c 00 00       	call   f0105c22 <cpunum>
f0103fea:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fed:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103ff3:	89 70 3c             	mov    %esi,0x3c(%eax)

			 env_run (curenv);
f0103ff6:	e8 27 1c 00 00       	call   f0105c22 <cpunum>
f0103ffb:	83 c4 04             	add    $0x4,%esp
f0103ffe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104001:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104007:	e8 fe f5 ff ff       	call   f010360a <env_run>
	   }

	   // Destroy the environment that caused the fault.
	   cprintf("Page fault upcall not defined for the environment \n");
f010400c:	83 ec 0c             	sub    $0xc,%esp
f010400f:	68 d4 79 10 f0       	push   $0xf01079d4
f0104014:	e8 0b f8 ff ff       	call   f0103824 <cprintf>
	   cprintf("[%08x] user fault va %08x ip %08x\n",
f0104019:	8b 7b 30             	mov    0x30(%ebx),%edi
				    curenv->env_id, fault_va, tf->tf_eip);
f010401c:	e8 01 1c 00 00       	call   f0105c22 <cpunum>
			 env_run (curenv);
	   }

	   // Destroy the environment that caused the fault.
	   cprintf("Page fault upcall not defined for the environment \n");
	   cprintf("[%08x] user fault va %08x ip %08x\n",
f0104021:	57                   	push   %edi
f0104022:	56                   	push   %esi
				    curenv->env_id, fault_va, tf->tf_eip);
f0104023:	6b c0 74             	imul   $0x74,%eax,%eax
			 env_run (curenv);
	   }

	   // Destroy the environment that caused the fault.
	   cprintf("Page fault upcall not defined for the environment \n");
	   cprintf("[%08x] user fault va %08x ip %08x\n",
f0104026:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010402c:	ff 70 48             	pushl  0x48(%eax)
f010402f:	68 08 7a 10 f0       	push   $0xf0107a08
f0104034:	e8 eb f7 ff ff       	call   f0103824 <cprintf>
				    curenv->env_id, fault_va, tf->tf_eip);
	   print_trapframe(tf);
f0104039:	83 c4 14             	add    $0x14,%esp
f010403c:	53                   	push   %ebx
f010403d:	e8 51 fd ff ff       	call   f0103d93 <print_trapframe>
	   env_destroy(curenv);
f0104042:	e8 db 1b 00 00       	call   f0105c22 <cpunum>
f0104047:	83 c4 04             	add    $0x4,%esp
f010404a:	6b c0 74             	imul   $0x74,%eax,%eax
f010404d:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104053:	e8 03 f5 ff ff       	call   f010355b <env_destroy>
}
f0104058:	83 c4 10             	add    $0x10,%esp
f010405b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010405e:	5b                   	pop    %ebx
f010405f:	5e                   	pop    %esi
f0104060:	5f                   	pop    %edi
f0104061:	5d                   	pop    %ebp
f0104062:	c3                   	ret    

f0104063 <trap>:
	   }
}

	   void
trap(struct Trapframe *tf)
{
f0104063:	55                   	push   %ebp
f0104064:	89 e5                	mov    %esp,%ebp
f0104066:	57                   	push   %edi
f0104067:	56                   	push   %esi
f0104068:	8b 75 08             	mov    0x8(%ebp),%esi
	   // The environment may have set DF and some versions
	   // of GCC rely on DF being clear
	   asm volatile("cld" ::: "cc");
f010406b:	fc                   	cld    

	   // Halt the CPU if some other CPU has called panic()
	   extern char *panicstr;
	   if (panicstr)
f010406c:	83 3d 80 2e 21 f0 00 	cmpl   $0x0,0xf0212e80
f0104073:	74 01                	je     f0104076 <trap+0x13>
			 asm volatile("hlt");
f0104075:	f4                   	hlt    

	   // Re-acqurie the big kernel lock if we were halted in
	   // sched_yield()
	   if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104076:	e8 a7 1b 00 00       	call   f0105c22 <cpunum>
f010407b:	6b d0 74             	imul   $0x74,%eax,%edx
f010407e:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104084:	b8 01 00 00 00       	mov    $0x1,%eax
f0104089:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010408d:	83 f8 02             	cmp    $0x2,%eax
f0104090:	75 10                	jne    f01040a2 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104092:	83 ec 0c             	sub    $0xc,%esp
f0104095:	68 c0 03 12 f0       	push   $0xf01203c0
f010409a:	e8 f1 1d 00 00       	call   f0105e90 <spin_lock>
f010409f:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01040a2:	9c                   	pushf  
f01040a3:	58                   	pop    %eax
			 lock_kernel();
	   // Check that interrupts are disabled.  If this assertion
	   // fails, DO NOT be tempted to fix it by inserting a "cli" in
	   // the interrupt path.
	   if (read_eflags() & FL_IF) {
f01040a4:	f6 c4 02             	test   $0x2,%ah
f01040a7:	74 2f                	je     f01040d8 <trap+0x75>
			 cprintf("TYPE 0x%08x\n", tf->tf_trapno);
f01040a9:	83 ec 08             	sub    $0x8,%esp
f01040ac:	ff 76 28             	pushl  0x28(%esi)
f01040af:	68 ee 77 10 f0       	push   $0xf01077ee
f01040b4:	e8 6b f7 ff ff       	call   f0103824 <cprintf>
			 print_trapframe(tf);
f01040b9:	89 34 24             	mov    %esi,(%esp)
f01040bc:	e8 d2 fc ff ff       	call   f0103d93 <print_trapframe>
			 panic("interrupts are not disabled");
f01040c1:	83 c4 0c             	add    $0xc,%esp
f01040c4:	68 fb 77 10 f0       	push   $0xf01077fb
f01040c9:	68 36 01 00 00       	push   $0x136
f01040ce:	68 e2 77 10 f0       	push   $0xf01077e2
f01040d3:	e8 68 bf ff ff       	call   f0100040 <_panic>
f01040d8:	9c                   	pushf  
f01040d9:	58                   	pop    %eax
	   }
	   assert(!(read_eflags() & FL_IF));
f01040da:	f6 c4 02             	test   $0x2,%ah
f01040dd:	74 19                	je     f01040f8 <trap+0x95>
f01040df:	68 17 78 10 f0       	push   $0xf0107817
f01040e4:	68 98 68 10 f0       	push   $0xf0106898
f01040e9:	68 38 01 00 00       	push   $0x138
f01040ee:	68 e2 77 10 f0       	push   $0xf01077e2
f01040f3:	e8 48 bf ff ff       	call   f0100040 <_panic>

	   if ((tf->tf_cs & 3) == 3) {
f01040f8:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040fc:	83 e0 03             	and    $0x3,%eax
f01040ff:	66 83 f8 03          	cmp    $0x3,%ax
f0104103:	0f 85 a0 00 00 00    	jne    f01041a9 <trap+0x146>
f0104109:	83 ec 0c             	sub    $0xc,%esp
f010410c:	68 c0 03 12 f0       	push   $0xf01203c0
f0104111:	e8 7a 1d 00 00       	call   f0105e90 <spin_lock>
			 // Trapped from user mode.
			 // Acquire the big kernel lock before doing any
			 // serious kernel work.
			 // LAB 4: Your code here.
			 lock_kernel();
			 assert(curenv);
f0104116:	e8 07 1b 00 00       	call   f0105c22 <cpunum>
f010411b:	6b c0 74             	imul   $0x74,%eax,%eax
f010411e:	83 c4 10             	add    $0x10,%esp
f0104121:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104128:	75 19                	jne    f0104143 <trap+0xe0>
f010412a:	68 30 78 10 f0       	push   $0xf0107830
f010412f:	68 98 68 10 f0       	push   $0xf0106898
f0104134:	68 40 01 00 00       	push   $0x140
f0104139:	68 e2 77 10 f0       	push   $0xf01077e2
f010413e:	e8 fd be ff ff       	call   f0100040 <_panic>


			 // Garbage collect if current enviroment is a zombie
			 if (curenv->env_status == ENV_DYING) {
f0104143:	e8 da 1a 00 00       	call   f0105c22 <cpunum>
f0104148:	6b c0 74             	imul   $0x74,%eax,%eax
f010414b:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104151:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104155:	75 2d                	jne    f0104184 <trap+0x121>
				    env_free(curenv);
f0104157:	e8 c6 1a 00 00       	call   f0105c22 <cpunum>
f010415c:	83 ec 0c             	sub    $0xc,%esp
f010415f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104162:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104168:	e8 48 f2 ff ff       	call   f01033b5 <env_free>
				    curenv = NULL;
f010416d:	e8 b0 1a 00 00       	call   f0105c22 <cpunum>
f0104172:	6b c0 74             	imul   $0x74,%eax,%eax
f0104175:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f010417c:	00 00 00 
				    sched_yield();
f010417f:	e8 bb 02 00 00       	call   f010443f <sched_yield>
			 }

			 // Copy trap frame (which is currently on the stack)
			 // into 'curenv->env_tf', so that running the environment
			 // will restart at the trap point.
			 curenv->env_tf = *tf;
f0104184:	e8 99 1a 00 00       	call   f0105c22 <cpunum>
f0104189:	6b c0 74             	imul   $0x74,%eax,%eax
f010418c:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104192:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104197:	89 c7                	mov    %eax,%edi
f0104199:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			 // The trapframe on the stack should be ignored from here on.
			 tf = &curenv->env_tf;
f010419b:	e8 82 1a 00 00       	call   f0105c22 <cpunum>
f01041a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a3:	8b b0 28 30 21 f0    	mov    -0xfdecfd8(%eax),%esi
	   }

	   // Record that tf is the last real trapframe so
	   // print_trapframe can print some additional information.
	   last_tf = tf;
f01041a9:	89 35 60 2a 21 f0    	mov    %esi,0xf0212a60
trap_dispatch(struct Trapframe *tf)
{

	   // Handle processor exceptions.
	   // LAB 3: Your code here.
	   if (tf -> tf_trapno == T_PGFLT)
f01041af:	8b 46 28             	mov    0x28(%esi),%eax
f01041b2:	83 f8 0e             	cmp    $0xe,%eax
f01041b5:	75 11                	jne    f01041c8 <trap+0x165>
	   {
			 page_fault_handler(tf);
f01041b7:	83 ec 0c             	sub    $0xc,%esp
f01041ba:	56                   	push   %esi
f01041bb:	e8 5b fd ff ff       	call   f0103f1b <page_fault_handler>
f01041c0:	83 c4 10             	add    $0x10,%esp
f01041c3:	e9 c8 00 00 00       	jmp    f0104290 <trap+0x22d>
			 return;
	   } else if (tf -> tf_trapno == T_BRKPT)
f01041c8:	83 f8 03             	cmp    $0x3,%eax
f01041cb:	75 11                	jne    f01041de <trap+0x17b>
	   {
			 monitor (tf);
f01041cd:	83 ec 0c             	sub    $0xc,%esp
f01041d0:	56                   	push   %esi
f01041d1:	e8 88 c7 ff ff       	call   f010095e <monitor>
f01041d6:	83 c4 10             	add    $0x10,%esp
f01041d9:	e9 b2 00 00 00       	jmp    f0104290 <trap+0x22d>
			 return;
	   } else if (tf -> tf_trapno == T_SYSCALL)
f01041de:	83 f8 30             	cmp    $0x30,%eax
f01041e1:	75 24                	jne    f0104207 <trap+0x1a4>
	   {
			 //             cprintf("SYSCALL Initiated \n");
			 int32_t return_value = syscall (tf -> tf_regs.reg_eax, tf -> tf_regs.reg_edx, tf -> tf_regs.reg_ecx, tf -> tf_regs.reg_ebx, tf -> tf_regs.reg_edi, tf -> tf_regs.reg_esi);
f01041e3:	83 ec 08             	sub    $0x8,%esp
f01041e6:	ff 76 04             	pushl  0x4(%esi)
f01041e9:	ff 36                	pushl  (%esi)
f01041eb:	ff 76 10             	pushl  0x10(%esi)
f01041ee:	ff 76 18             	pushl  0x18(%esi)
f01041f1:	ff 76 14             	pushl  0x14(%esi)
f01041f4:	ff 76 1c             	pushl  0x1c(%esi)
f01041f7:	e8 0b 03 00 00       	call   f0104507 <syscall>
			 tf -> tf_regs.reg_eax = return_value;
f01041fc:	89 46 1c             	mov    %eax,0x1c(%esi)
f01041ff:	83 c4 20             	add    $0x20,%esp
f0104202:	e9 89 00 00 00       	jmp    f0104290 <trap+0x22d>


	   // Handle spurious interrupts
	   // The hardware sometimes raises these because of noise on the
	   // IRQ line or other reasons. We don't care.
	   if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104207:	83 f8 27             	cmp    $0x27,%eax
f010420a:	75 1a                	jne    f0104226 <trap+0x1c3>
			 cprintf("Spurious interrupt on irq 7\n");
f010420c:	83 ec 0c             	sub    $0xc,%esp
f010420f:	68 37 78 10 f0       	push   $0xf0107837
f0104214:	e8 0b f6 ff ff       	call   f0103824 <cprintf>
			 print_trapframe(tf);
f0104219:	89 34 24             	mov    %esi,(%esp)
f010421c:	e8 72 fb ff ff       	call   f0103d93 <print_trapframe>
f0104221:	83 c4 10             	add    $0x10,%esp
f0104224:	eb 6a                	jmp    f0104290 <trap+0x22d>
	   }

	   // Handle clock interrupts. Don't forget to acknowledge the
	   // interrupt using lapic_eoi() before calling the scheduler!
	   // LAB 4: Your code here.
	   if (tf -> tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0104226:	83 f8 20             	cmp    $0x20,%eax
f0104229:	75 0a                	jne    f0104235 <trap+0x1d2>
	   {
			 lapic_eoi();
f010422b:	e8 3d 1b 00 00       	call   f0105d6d <lapic_eoi>
			 sched_yield();
f0104230:	e8 0a 02 00 00       	call   f010443f <sched_yield>
	   }


	   // Handle keyboard and serial interrupts.
	   // LAB 5: Your code here.
	   if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0104235:	83 f8 21             	cmp    $0x21,%eax
f0104238:	75 07                	jne    f0104241 <trap+0x1de>
			 kbd_intr();
f010423a:	e8 a1 c3 ff ff       	call   f01005e0 <kbd_intr>
f010423f:	eb 4f                	jmp    f0104290 <trap+0x22d>
			 return;
	   }
	   if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0104241:	83 f8 24             	cmp    $0x24,%eax
f0104244:	75 07                	jne    f010424d <trap+0x1ea>
			 serial_intr();
f0104246:	e8 79 c3 ff ff       	call   f01005c4 <serial_intr>
f010424b:	eb 43                	jmp    f0104290 <trap+0x22d>
			 return;
	   }

	   // Unexpected trap: The user process or the kernel has a bug.
	   print_trapframe(tf);
f010424d:	83 ec 0c             	sub    $0xc,%esp
f0104250:	56                   	push   %esi
f0104251:	e8 3d fb ff ff       	call   f0103d93 <print_trapframe>
	   if (tf->tf_cs == GD_KT)
f0104256:	83 c4 10             	add    $0x10,%esp
f0104259:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010425e:	75 17                	jne    f0104277 <trap+0x214>
			 panic("unhandled trap in kernel");
f0104260:	83 ec 04             	sub    $0x4,%esp
f0104263:	68 54 78 10 f0       	push   $0xf0107854
f0104268:	68 19 01 00 00       	push   $0x119
f010426d:	68 e2 77 10 f0       	push   $0xf01077e2
f0104272:	e8 c9 bd ff ff       	call   f0100040 <_panic>
	   else {
			 env_destroy(curenv);
f0104277:	e8 a6 19 00 00       	call   f0105c22 <cpunum>
f010427c:	83 ec 0c             	sub    $0xc,%esp
f010427f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104282:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104288:	e8 ce f2 ff ff       	call   f010355b <env_destroy>
f010428d:	83 c4 10             	add    $0x10,%esp
	   trap_dispatch(tf);

	   // If we made it to this point, then no other environment was
	   // scheduled, so we should return to the current environment
	   // if doing so makes sense.
	   if (curenv && curenv->env_status == ENV_RUNNING)
f0104290:	e8 8d 19 00 00       	call   f0105c22 <cpunum>
f0104295:	6b c0 74             	imul   $0x74,%eax,%eax
f0104298:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f010429f:	74 2a                	je     f01042cb <trap+0x268>
f01042a1:	e8 7c 19 00 00       	call   f0105c22 <cpunum>
f01042a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a9:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01042af:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042b3:	75 16                	jne    f01042cb <trap+0x268>
			 env_run(curenv);
f01042b5:	e8 68 19 00 00       	call   f0105c22 <cpunum>
f01042ba:	83 ec 0c             	sub    $0xc,%esp
f01042bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01042c0:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01042c6:	e8 3f f3 ff ff       	call   f010360a <env_run>
	   else
			 sched_yield();
f01042cb:	e8 6f 01 00 00       	call   f010443f <sched_yield>

f01042d0 <divide_exception>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC (divide_exception, T_DIVIDE);
f01042d0:	6a 00                	push   $0x0
f01042d2:	6a 00                	push   $0x0
f01042d4:	e9 81 00 00 00       	jmp    f010435a <_alltraps>
f01042d9:	90                   	nop

f01042da <debug_exception>:
TRAPHANDLER_NOEC (debug_exception, T_DEBUG);
f01042da:	6a 00                	push   $0x0
f01042dc:	6a 01                	push   $0x1
f01042de:	eb 7a                	jmp    f010435a <_alltraps>

f01042e0 <nmi_interupt>:
TRAPHANDLER_NOEC (nmi_interupt, T_NMI);
f01042e0:	6a 00                	push   $0x0
f01042e2:	6a 02                	push   $0x2
f01042e4:	eb 74                	jmp    f010435a <_alltraps>

f01042e6 <breakpoint_exception>:
TRAPHANDLER_NOEC (breakpoint_exception, T_BRKPT);
f01042e6:	6a 00                	push   $0x0
f01042e8:	6a 03                	push   $0x3
f01042ea:	eb 6e                	jmp    f010435a <_alltraps>

f01042ec <overflow_exception>:
TRAPHANDLER_NOEC (overflow_exception, T_OFLOW);
f01042ec:	6a 00                	push   $0x0
f01042ee:	6a 04                	push   $0x4
f01042f0:	eb 68                	jmp    f010435a <_alltraps>

f01042f2 <bounds_check_exception>:
TRAPHANDLER_NOEC (bounds_check_exception, T_BOUND);
f01042f2:	6a 00                	push   $0x0
f01042f4:	6a 05                	push   $0x5
f01042f6:	eb 62                	jmp    f010435a <_alltraps>

f01042f8 <illegal_opcode_exception>:
TRAPHANDLER_NOEC (illegal_opcode_exception, T_ILLOP);
f01042f8:	6a 00                	push   $0x0
f01042fa:	6a 06                	push   $0x6
f01042fc:	eb 5c                	jmp    f010435a <_alltraps>

f01042fe <coprocessor_exception>:
TRAPHANDLER_NOEC (coprocessor_exception, T_DEVICE);
f01042fe:	6a 00                	push   $0x0
f0104300:	6a 07                	push   $0x7
f0104302:	eb 56                	jmp    f010435a <_alltraps>

f0104304 <double_fault_exception>:
TRAPHANDLER (double_fault_exception, T_DBLFLT);
f0104304:	6a 08                	push   $0x8
f0104306:	eb 52                	jmp    f010435a <_alltraps>

f0104308 <tss_exception>:
TRAPHANDLER (tss_exception, T_TSS);
f0104308:	6a 0a                	push   $0xa
f010430a:	eb 4e                	jmp    f010435a <_alltraps>

f010430c <segment_np_exception>:
TRAPHANDLER (segment_np_exception, T_SEGNP);
f010430c:	6a 0b                	push   $0xb
f010430e:	eb 4a                	jmp    f010435a <_alltraps>

f0104310 <stack_np_excecption>:
TRAPHANDLER (stack_np_excecption, T_STACK);
f0104310:	6a 0c                	push   $0xc
f0104312:	eb 46                	jmp    f010435a <_alltraps>

f0104314 <general_protection_fault>:
TRAPHANDLER (general_protection_fault, T_GPFLT);
f0104314:	6a 0d                	push   $0xd
f0104316:	eb 42                	jmp    f010435a <_alltraps>

f0104318 <page_fault_exception>:
TRAPHANDLER (page_fault_exception, T_PGFLT);
f0104318:	6a 0e                	push   $0xe
f010431a:	eb 3e                	jmp    f010435a <_alltraps>

f010431c <fp_err_exception>:
TRAPHANDLER_NOEC (fp_err_exception, T_FPERR);
f010431c:	6a 00                	push   $0x0
f010431e:	6a 10                	push   $0x10
f0104320:	eb 38                	jmp    f010435a <_alltraps>

f0104322 <alignment_exception>:
TRAPHANDLER (alignment_exception, T_ALIGN);
f0104322:	6a 11                	push   $0x11
f0104324:	eb 34                	jmp    f010435a <_alltraps>

f0104326 <machine_exception>:
TRAPHANDLER_NOEC (machine_exception, T_MCHK);
f0104326:	6a 00                	push   $0x0
f0104328:	6a 12                	push   $0x12
f010432a:	eb 2e                	jmp    f010435a <_alltraps>

f010432c <SIMDerr_exception>:
TRAPHANDLER_NOEC  (SIMDerr_exception, T_SIMDERR);
f010432c:	6a 00                	push   $0x0
f010432e:	6a 13                	push   $0x13
f0104330:	eb 28                	jmp    f010435a <_alltraps>

f0104332 <syscall_interrupt>:

TRAPHANDLER_NOEC (syscall_interrupt, T_SYSCALL);
f0104332:	6a 00                	push   $0x0
f0104334:	6a 30                	push   $0x30
f0104336:	eb 22                	jmp    f010435a <_alltraps>

f0104338 <t_default>:

TRAPHANDLER_NOEC(t_default, T_DEFAULT);
f0104338:	6a 00                	push   $0x0
f010433a:	68 f4 01 00 00       	push   $0x1f4
f010433f:	eb 19                	jmp    f010435a <_alltraps>
f0104341:	90                   	nop

f0104342 <IRQ_TimerINT>:

TRAPHANDLER_NOEC (IRQ_TimerINT, IRQ_OFFSET + IRQ_TIMER);
f0104342:	6a 00                	push   $0x0
f0104344:	6a 20                	push   $0x20
f0104346:	eb 12                	jmp    f010435a <_alltraps>

f0104348 <IRQ_ErrorINT>:
TRAPHANDLER_NOEC (IRQ_ErrorINT, IRQ_OFFSET + IRQ_ERROR);
f0104348:	6a 00                	push   $0x0
f010434a:	6a 33                	push   $0x33
f010434c:	eb 0c                	jmp    f010435a <_alltraps>

f010434e <IRQ_KeyboardINT>:

TRAPHANDLER_NOEC (IRQ_KeyboardINT, IRQ_OFFSET + IRQ_KBD);
f010434e:	6a 00                	push   $0x0
f0104350:	6a 21                	push   $0x21
f0104352:	eb 06                	jmp    f010435a <_alltraps>

f0104354 <IRQ_SerialINT>:
TRAPHANDLER_NOEC (IRQ_SerialINT, IRQ_OFFSET + IRQ_SERIAL);
f0104354:	6a 00                	push   $0x0
f0104356:	6a 24                	push   $0x24
f0104358:	eb 00                	jmp    f010435a <_alltraps>

f010435a <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
pushl %ds
f010435a:	1e                   	push   %ds
pushl %es
f010435b:	06                   	push   %es
pushal
f010435c:	60                   	pusha  
movw $GD_KD, %ax
f010435d:	66 b8 10 00          	mov    $0x10,%ax
movw %ax, %ds
f0104361:	8e d8                	mov    %eax,%ds
movw %ax, %es
f0104363:	8e c0                	mov    %eax,%es
pushl %esp
f0104365:	54                   	push   %esp
call trap
f0104366:	e8 f8 fc ff ff       	call   f0104063 <trap>

f010436b <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
	   void
sched_halt(void)
{
f010436b:	55                   	push   %ebp
f010436c:	89 e5                	mov    %esp,%ebp
f010436e:	83 ec 08             	sub    $0x8,%esp
f0104371:	a1 48 22 21 f0       	mov    0xf0212248,%eax
f0104376:	8d 50 54             	lea    0x54(%eax),%edx
	   int i;

	   // For debugging and testing purposes, if there are no runnable
	   // environments in the system, then drop into the kernel monitor.
	   for (i = 0; i < NENV; i++) {
f0104379:	b9 00 00 00 00       	mov    $0x0,%ecx
			 if ((envs[i].env_status == ENV_RUNNABLE ||
f010437e:	8b 02                	mov    (%edx),%eax
f0104380:	83 e8 01             	sub    $0x1,%eax
f0104383:	83 f8 02             	cmp    $0x2,%eax
f0104386:	76 10                	jbe    f0104398 <sched_halt+0x2d>
{
	   int i;

	   // For debugging and testing purposes, if there are no runnable
	   // environments in the system, then drop into the kernel monitor.
	   for (i = 0; i < NENV; i++) {
f0104388:	83 c1 01             	add    $0x1,%ecx
f010438b:	83 c2 7c             	add    $0x7c,%edx
f010438e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104394:	75 e8                	jne    f010437e <sched_halt+0x13>
f0104396:	eb 08                	jmp    f01043a0 <sched_halt+0x35>
			 if ((envs[i].env_status == ENV_RUNNABLE ||
								envs[i].env_status == ENV_RUNNING ||
								envs[i].env_status == ENV_DYING))
				    break;
	   }
	   if (i == NENV) {
f0104398:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010439e:	75 1f                	jne    f01043bf <sched_halt+0x54>
			 cprintf("No runnable environments in the system!\n");
f01043a0:	83 ec 0c             	sub    $0xc,%esp
f01043a3:	68 90 7a 10 f0       	push   $0xf0107a90
f01043a8:	e8 77 f4 ff ff       	call   f0103824 <cprintf>
f01043ad:	83 c4 10             	add    $0x10,%esp
			 while (1)
				    monitor(NULL);
f01043b0:	83 ec 0c             	sub    $0xc,%esp
f01043b3:	6a 00                	push   $0x0
f01043b5:	e8 a4 c5 ff ff       	call   f010095e <monitor>
f01043ba:	83 c4 10             	add    $0x10,%esp
f01043bd:	eb f1                	jmp    f01043b0 <sched_halt+0x45>
	   }

	   // Mark that no environment is running on this CPU
	   curenv = NULL;
f01043bf:	e8 5e 18 00 00       	call   f0105c22 <cpunum>
f01043c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01043c7:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f01043ce:	00 00 00 
	   lcr3(PADDR(kern_pgdir));
f01043d1:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043db:	77 12                	ja     f01043ef <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043dd:	50                   	push   %eax
f01043de:	68 08 63 10 f0       	push   $0xf0106308
f01043e3:	6a 57                	push   $0x57
f01043e5:	68 dc 7a 10 f0       	push   $0xf0107adc
f01043ea:	e8 51 bc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01043ef:	05 00 00 00 10       	add    $0x10000000,%eax
f01043f4:	0f 22 d8             	mov    %eax,%cr3

	   // Mark that this CPU is in the HALT state, so that when
	   // timer interupts come in, we know we should re-acquire the
	   // big kernel lock
	   xchg(&thiscpu->cpu_status, CPU_HALTED);
f01043f7:	e8 26 18 00 00       	call   f0105c22 <cpunum>
f01043fc:	6b d0 74             	imul   $0x74,%eax,%edx
f01043ff:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104405:	b8 02 00 00 00       	mov    $0x2,%eax
f010440a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010440e:	83 ec 0c             	sub    $0xc,%esp
f0104411:	68 c0 03 12 f0       	push   $0xf01203c0
f0104416:	e8 12 1b 00 00       	call   f0105f2d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010441b:	f3 90                	pause  
				    // Uncomment the following line after completing exercise 13
				    		"sti\n"
				    "1:\n"
				    "hlt\n"
				    "jmp 1b\n"
				    : : "a" (thiscpu->cpu_ts.ts_esp0));
f010441d:	e8 00 18 00 00       	call   f0105c22 <cpunum>
f0104422:	6b c0 74             	imul   $0x74,%eax,%eax

	   // Release the big kernel lock as if we were "leaving" the kernel
	   unlock_kernel();

	   // Reset stack pointer, enable interrupts and then halt.
	   asm volatile (
f0104425:	8b 80 30 30 21 f0    	mov    -0xfdecfd0(%eax),%eax
f010442b:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104430:	89 c4                	mov    %eax,%esp
f0104432:	6a 00                	push   $0x0
f0104434:	6a 00                	push   $0x0
f0104436:	fb                   	sti    
f0104437:	f4                   	hlt    
f0104438:	eb fd                	jmp    f0104437 <sched_halt+0xcc>
				    		"sti\n"
				    "1:\n"
				    "hlt\n"
				    "jmp 1b\n"
				    : : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010443a:	83 c4 10             	add    $0x10,%esp
f010443d:	c9                   	leave  
f010443e:	c3                   	ret    

f010443f <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
	   void
sched_yield(void)
{
f010443f:	55                   	push   %ebp
f0104440:	89 e5                	mov    %esp,%ebp
f0104442:	56                   	push   %esi
f0104443:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	   // LAB 4: Your code here.

	   int begin = curenv ? ENVX(curenv -> env_id) + 1 : 0;
f0104444:	e8 d9 17 00 00       	call   f0105c22 <cpunum>
f0104449:	6b c0 74             	imul   $0x74,%eax,%eax
f010444c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104451:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104458:	74 1a                	je     f0104474 <sched_yield+0x35>
f010445a:	e8 c3 17 00 00       	call   f0105c22 <cpunum>
f010445f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104462:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104468:	8b 48 48             	mov    0x48(%eax),%ecx
f010446b:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104471:	83 c1 01             	add    $0x1,%ecx
	   bool found = false;

	   for (int i = 0; i < NENV; i++)
	   {
			 index = (begin + i) % NENV;
			 if (envs[index].env_status == ENV_RUNNABLE)
f0104474:	8b 1d 48 22 21 f0    	mov    0xf0212248,%ebx
f010447a:	89 ca                	mov    %ecx,%edx
f010447c:	81 c1 00 04 00 00    	add    $0x400,%ecx
f0104482:	89 d6                	mov    %edx,%esi
f0104484:	c1 fe 1f             	sar    $0x1f,%esi
f0104487:	c1 ee 16             	shr    $0x16,%esi
f010448a:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010448d:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104492:	29 f0                	sub    %esi,%eax
f0104494:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104497:	01 d8                	add    %ebx,%eax
f0104499:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010449d:	74 4c                	je     f01044eb <sched_yield+0xac>
f010449f:	83 c2 01             	add    $0x1,%edx

	   int begin = curenv ? ENVX(curenv -> env_id) + 1 : 0;
	   int index = begin;
	   bool found = false;

	   for (int i = 0; i < NENV; i++)
f01044a2:	39 ca                	cmp    %ecx,%edx
f01044a4:	75 dc                	jne    f0104482 <sched_yield+0x43>
f01044a6:	eb 4c                	jmp    f01044f4 <sched_yield+0xb5>
	   }

	   if (found)
	   {
			 env_run (&envs [index]);
	   } else if (curenv && curenv -> env_status == ENV_RUNNING)
f01044a8:	e8 75 17 00 00       	call   f0105c22 <cpunum>
f01044ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01044b0:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01044b6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01044ba:	75 16                	jne    f01044d2 <sched_yield+0x93>
	   {
			 env_run (curenv);
f01044bc:	e8 61 17 00 00       	call   f0105c22 <cpunum>
f01044c1:	83 ec 0c             	sub    $0xc,%esp
f01044c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c7:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01044cd:	e8 38 f1 ff ff       	call   f010360a <env_run>
	   } else 
	   {
			 // sched_halt never returns
			 sched_halt();
f01044d2:	e8 94 fe ff ff       	call   f010436b <sched_halt>
	   }
	   panic("sched_yield attempted to return");
f01044d7:	83 ec 04             	sub    $0x4,%esp
f01044da:	68 bc 7a 10 f0       	push   $0xf0107abc
f01044df:	6a 3c                	push   $0x3c
f01044e1:	68 dc 7a 10 f0       	push   $0xf0107adc
f01044e6:	e8 55 bb ff ff       	call   f0100040 <_panic>
			 }
	   }

	   if (found)
	   {
			 env_run (&envs [index]);
f01044eb:	83 ec 0c             	sub    $0xc,%esp
f01044ee:	50                   	push   %eax
f01044ef:	e8 16 f1 ff ff       	call   f010360a <env_run>
	   } else if (curenv && curenv -> env_status == ENV_RUNNING)
f01044f4:	e8 29 17 00 00       	call   f0105c22 <cpunum>
f01044f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044fc:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104503:	75 a3                	jne    f01044a8 <sched_yield+0x69>
f0104505:	eb cb                	jmp    f01044d2 <sched_yield+0x93>

f0104507 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
	   int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104507:	55                   	push   %ebp
f0104508:	89 e5                	mov    %esp,%ebp
f010450a:	57                   	push   %edi
f010450b:	56                   	push   %esi
f010450c:	53                   	push   %ebx
f010450d:	83 ec 1c             	sub    $0x1c,%esp
f0104510:	8b 45 08             	mov    0x8(%ebp),%eax
	   // Return any appropriate return value.
	   // LAB 3: Your code here.

	   //	panic("syscall not implemented");

	   switch (syscallno) {
f0104513:	83 f8 0d             	cmp    $0xd,%eax
f0104516:	0f 87 20 05 00 00    	ja     f0104a3c <syscall+0x535>
f010451c:	ff 24 85 f0 7a 10 f0 	jmp    *-0xfef8510(,%eax,4)
	   // Check that the user has permission to read memory [s, s+len).
	   // Destroy the environment if not.

	   // LAB 3: Your code here.
	   //	   if (curenv -> env_tf.tf_cs &3)
	   user_mem_assert (curenv, (void*)s, len, PTE_U | PTE_P);
f0104523:	e8 fa 16 00 00       	call   f0105c22 <cpunum>
f0104528:	6a 05                	push   $0x5
f010452a:	ff 75 10             	pushl  0x10(%ebp)
f010452d:	ff 75 0c             	pushl  0xc(%ebp)
f0104530:	6b c0 74             	imul   $0x74,%eax,%eax
f0104533:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104539:	e8 9c e9 ff ff       	call   f0102eda <user_mem_assert>

	   // Print the string supplied by the user.
	   cprintf("%.*s", len, s);
f010453e:	83 c4 0c             	add    $0xc,%esp
f0104541:	ff 75 0c             	pushl  0xc(%ebp)
f0104544:	ff 75 10             	pushl  0x10(%ebp)
f0104547:	68 e9 7a 10 f0       	push   $0xf0107ae9
f010454c:	e8 d3 f2 ff ff       	call   f0103824 <cprintf>
f0104551:	83 c4 10             	add    $0x10,%esp
	   //	panic("syscall not implemented");

	   switch (syscallno) {
			 case SYS_cputs:
				    sys_cputs (( char*) a1, a2);
				    return 0;
f0104554:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104559:	e9 88 05 00 00       	jmp    f0104ae6 <syscall+0x5df>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
	   static int
sys_cgetc(void)
{
	   return cons_getc();
f010455e:	e8 8f c0 ff ff       	call   f01005f2 <cons_getc>
f0104563:	89 c3                	mov    %eax,%ebx
	   switch (syscallno) {
			 case SYS_cputs:
				    sys_cputs (( char*) a1, a2);
				    return 0;
			 case SYS_cgetc:
				    return sys_cgetc ();
f0104565:	e9 7c 05 00 00       	jmp    f0104ae6 <syscall+0x5df>

// Returns the current environment's envid.
	   static envid_t
sys_getenvid(void)
{
	   return curenv->env_id;
f010456a:	e8 b3 16 00 00       	call   f0105c22 <cpunum>
f010456f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104572:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104578:	8b 58 48             	mov    0x48(%eax),%ebx
				    sys_cputs (( char*) a1, a2);
				    return 0;
			 case SYS_cgetc:
				    return sys_cgetc ();
			 case SYS_getenvid:
				    return sys_getenvid();
f010457b:	e9 66 05 00 00       	jmp    f0104ae6 <syscall+0x5df>
{

	   int r;
	   struct Env *e;

	   if ((r = envid2env(envid, &e, 1)) < 0)
f0104580:	83 ec 04             	sub    $0x4,%esp
f0104583:	6a 01                	push   $0x1
f0104585:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104588:	50                   	push   %eax
f0104589:	ff 75 0c             	pushl  0xc(%ebp)
f010458c:	e8 34 ea ff ff       	call   f0102fc5 <envid2env>
f0104591:	83 c4 10             	add    $0x10,%esp
			 return r;
f0104594:	89 c3                	mov    %eax,%ebx
{

	   int r;
	   struct Env *e;

	   if ((r = envid2env(envid, &e, 1)) < 0)
f0104596:	85 c0                	test   %eax,%eax
f0104598:	0f 88 48 05 00 00    	js     f0104ae6 <syscall+0x5df>
			 return r;
	   env_destroy(e);
f010459e:	83 ec 0c             	sub    $0xc,%esp
f01045a1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01045a4:	e8 b2 ef ff ff       	call   f010355b <env_destroy>
f01045a9:	83 c4 10             	add    $0x10,%esp
	   return 0;
f01045ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045b1:	e9 30 05 00 00       	jmp    f0104ae6 <syscall+0x5df>

// Deschedule current environment and pick a different one to run.
	   static void
sys_yield(void)
{
	   sched_yield();
f01045b6:	e8 84 fe ff ff       	call   f010443f <sched_yield>
	   // from the current environment -- but tweaked so sys_exofork
	   // will appear to return 0.

	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
f01045bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = env_alloc (&new_env, curenv -> env_id);
f01045c2:	e8 5b 16 00 00       	call   f0105c22 <cpunum>
f01045c7:	83 ec 08             	sub    $0x8,%esp
f01045ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01045cd:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01045d3:	ff 70 48             	pushl  0x48(%eax)
f01045d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045d9:	50                   	push   %eax
f01045da:	e8 f4 ea ff ff       	call   f01030d3 <env_alloc>
	   if (a < 0)
f01045df:	83 c4 10             	add    $0x10,%esp
			 return a;
f01045e2:	89 c3                	mov    %eax,%ebx

	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
	   int a = env_alloc (&new_env, curenv -> env_id);
	   if (a < 0)
f01045e4:	85 c0                	test   %eax,%eax
f01045e6:	0f 88 fa 04 00 00    	js     f0104ae6 <syscall+0x5df>
			 return a;

	   new_env -> env_status = ENV_NOT_RUNNABLE;
f01045ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01045ef:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	   new_env -> env_tf = curenv -> env_tf;
f01045f6:	e8 27 16 00 00       	call   f0105c22 <cpunum>
f01045fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01045fe:	8b b0 28 30 21 f0    	mov    -0xfdecfd8(%eax),%esi
f0104604:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104609:	89 df                	mov    %ebx,%edi
f010460b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	   new_env -> env_tf.tf_regs.reg_eax = 0;
f010460d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104610:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	   return new_env -> env_id;
f0104617:	8b 58 48             	mov    0x48(%eax),%ebx
f010461a:	e9 c7 04 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   // You should set envid2env's third argument to 1, which will
	   // check whether the current environment has permission to set
	   // envid's status.

	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
f010461f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = envid2env (envid, &new_env, 1);
f0104626:	83 ec 04             	sub    $0x4,%esp
f0104629:	6a 01                	push   $0x1
f010462b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010462e:	50                   	push   %eax
f010462f:	ff 75 0c             	pushl  0xc(%ebp)
f0104632:	e8 8e e9 ff ff       	call   f0102fc5 <envid2env>

	   if (a < 0)
f0104637:	83 c4 10             	add    $0x10,%esp
f010463a:	85 c0                	test   %eax,%eax
f010463c:	78 13                	js     f0104651 <syscall+0x14a>
			 return a;

	   if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
			 -E_INVAL;

	   new_env -> env_status = status;
f010463e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104641:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104644:	89 48 54             	mov    %ecx,0x54(%eax)
	   return 0;
f0104647:	bb 00 00 00 00       	mov    $0x0,%ebx
f010464c:	e9 95 04 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
	   int a = envid2env (envid, &new_env, 1);

	   if (a < 0)
			 return a;
f0104651:	89 c3                	mov    %eax,%ebx
				    sys_yield();
				    return 0;
			 case SYS_exofork:
				    return sys_exofork();
			 case SYS_env_set_status:
				    return sys_env_set_status((envid_t) a1, (int) a2);
f0104653:	e9 8e 04 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   // LAB 5: Your code here.
	   // Remember to check whether the user has supplied us with a good
	   // address!
	   int err;
	   struct Env *env;
	   if ((err = envid2env(envid, &env, true)) < 0) {
f0104658:	83 ec 04             	sub    $0x4,%esp
f010465b:	6a 01                	push   $0x1
f010465d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104660:	50                   	push   %eax
f0104661:	ff 75 0c             	pushl  0xc(%ebp)
f0104664:	e8 5c e9 ff ff       	call   f0102fc5 <envid2env>
f0104669:	83 c4 10             	add    $0x10,%esp
			 return err;
f010466c:	89 c3                	mov    %eax,%ebx
	   // LAB 5: Your code here.
	   // Remember to check whether the user has supplied us with a good
	   // address!
	   int err;
	   struct Env *env;
	   if ((err = envid2env(envid, &env, true)) < 0) {
f010466e:	85 c0                	test   %eax,%eax
f0104670:	0f 88 70 04 00 00    	js     f0104ae6 <syscall+0x5df>
			 case SYS_exofork:
				    return sys_exofork();
			 case SYS_env_set_status:
				    return sys_env_set_status((envid_t) a1, (int) a2);
			 case SYS_env_set_trapframe:
				    return sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
f0104676:	8b 75 10             	mov    0x10(%ebp),%esi
	   int err;
	   struct Env *env;
	   if ((err = envid2env(envid, &env, true)) < 0) {
			 return err;
	   }
	   if ((err = user_mem_check(env, tf, sizeof(struct Trapframe), PTE_U)) < 0) {
f0104679:	6a 04                	push   $0x4
f010467b:	6a 44                	push   $0x44
f010467d:	56                   	push   %esi
f010467e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104681:	e8 dd e7 ff ff       	call   f0102e63 <user_mem_check>
f0104686:	83 c4 10             	add    $0x10,%esp
f0104689:	85 c0                	test   %eax,%eax
f010468b:	78 3b                	js     f01046c8 <syscall+0x1c1>
			 return err;
	   }
	   env->env_tf = *tf;
f010468d:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104695:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	   // set the IOPL to 0
	   env->env_tf.tf_eflags &= ~FL_IOPL_MASK;
f0104697:	8b 45 e4             	mov    -0x1c(%ebp),%eax

	   // enable interrupts
	   env->env_tf.tf_eflags |= FL_IF;
f010469a:	8b 50 38             	mov    0x38(%eax),%edx
f010469d:	80 e6 cf             	and    $0xcf,%dh
f01046a0:	80 ce 02             	or     $0x2,%dh
f01046a3:	89 50 38             	mov    %edx,0x38(%eax)

	   // set user privilage level
	   env->env_tf.tf_ds = GD_UD | 3;
f01046a6:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	   env->env_tf.tf_es = GD_UD | 3;
f01046ac:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	   env->env_tf.tf_ss = GD_UD | 3;
f01046b2:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	   env->env_tf.tf_cs = GD_UT | 3;
f01046b8:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)


	   return 0;
f01046be:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046c3:	e9 1e 04 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   struct Env *env;
	   if ((err = envid2env(envid, &env, true)) < 0) {
			 return err;
	   }
	   if ((err = user_mem_check(env, tf, sizeof(struct Trapframe), PTE_U)) < 0) {
			 return err;
f01046c8:	89 c3                	mov    %eax,%ebx
			 case SYS_exofork:
				    return sys_exofork();
			 case SYS_env_set_status:
				    return sys_env_set_status((envid_t) a1, (int) a2);
			 case SYS_env_set_trapframe:
				    return sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
f01046ca:	e9 17 04 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
f01046cf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = envid2env (envid, &new_env, 1);
f01046d6:	83 ec 04             	sub    $0x4,%esp
f01046d9:	6a 01                	push   $0x1
f01046db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046de:	50                   	push   %eax
f01046df:	ff 75 0c             	pushl  0xc(%ebp)
f01046e2:	e8 de e8 ff ff       	call   f0102fc5 <envid2env>
	   if (a < 0)
f01046e7:	83 c4 10             	add    $0x10,%esp
f01046ea:	85 c0                	test   %eax,%eax
f01046ec:	78 13                	js     f0104701 <syscall+0x1fa>
			 return a;

	   new_env -> env_pgfault_upcall = func;
f01046ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046f1:	8b 7d 10             	mov    0x10(%ebp),%edi
f01046f4:	89 78 64             	mov    %edi,0x64(%eax)
	   return 0;
f01046f7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046fc:	e9 e5 03 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   // LAB 4: Your code here.

	   struct Env* new_env = NULL;
	   int a = envid2env (envid, &new_env, 1);
	   if (a < 0)
			 return a;
f0104701:	89 c3                	mov    %eax,%ebx
			 case SYS_env_set_status:
				    return sys_env_set_status((envid_t) a1, (int) a2);
			 case SYS_env_set_trapframe:
				    return sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
			 case SYS_env_set_pgfault_upcall:
				    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
f0104703:	e9 de 03 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   //   parameters for correctness.
	   //   If page_insert() fails, remember to free the page you
	   //   allocated!

	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
f0104708:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   int a = envid2env (envid, &new_env, 1);
f010470f:	83 ec 04             	sub    $0x4,%esp
f0104712:	6a 01                	push   $0x1
f0104714:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104717:	50                   	push   %eax
f0104718:	ff 75 0c             	pushl  0xc(%ebp)
f010471b:	e8 a5 e8 ff ff       	call   f0102fc5 <envid2env>

	   if (a < 0)
f0104720:	83 c4 10             	add    $0x10,%esp
f0104723:	85 c0                	test   %eax,%eax
f0104725:	78 66                	js     f010478d <syscall+0x286>
			 return a;
	   if ((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE != 0)
f0104727:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010472e:	77 64                	ja     f0104794 <syscall+0x28d>
f0104730:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104737:	75 65                	jne    f010479e <syscall+0x297>
			 return -E_INVAL;

	   if ((perm & ~PTE_SYSCALL) != 0)
f0104739:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010473c:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104742:	75 64                	jne    f01047a8 <syscall+0x2a1>
			 return -E_INVAL;

	   struct PageInfo* np = page_alloc(ALLOC_ZERO);
f0104744:	83 ec 0c             	sub    $0xc,%esp
f0104747:	6a 01                	push   $0x1
f0104749:	e8 d1 c8 ff ff       	call   f010101f <page_alloc>
f010474e:	89 c6                	mov    %eax,%esi
	   if (!np)
f0104750:	83 c4 10             	add    $0x10,%esp
f0104753:	85 c0                	test   %eax,%eax
f0104755:	74 5b                	je     f01047b2 <syscall+0x2ab>
			 return -E_NO_MEM;

	   a = page_insert (new_env -> env_pgdir, np, va, perm | PTE_U | PTE_P);//PTE_SYSCALL);
f0104757:	8b 45 14             	mov    0x14(%ebp),%eax
f010475a:	83 c8 05             	or     $0x5,%eax
f010475d:	50                   	push   %eax
f010475e:	ff 75 10             	pushl  0x10(%ebp)
f0104761:	56                   	push   %esi
f0104762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104765:	ff 70 60             	pushl  0x60(%eax)
f0104768:	e8 aa cb ff ff       	call   f0101317 <page_insert>
f010476d:	89 c7                	mov    %eax,%edi
	   if (a < 0)
f010476f:	83 c4 10             	add    $0x10,%esp
f0104772:	85 c0                	test   %eax,%eax
f0104774:	0f 89 6c 03 00 00    	jns    f0104ae6 <syscall+0x5df>
	   {
			 page_free (np);
f010477a:	83 ec 0c             	sub    $0xc,%esp
f010477d:	56                   	push   %esi
f010477e:	e8 13 c9 ff ff       	call   f0101096 <page_free>
f0104783:	83 c4 10             	add    $0x10,%esp
			 return a;
f0104786:	89 fb                	mov    %edi,%ebx
f0104788:	e9 59 03 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   // LAB 4: Your code here.
	   struct Env* new_env = NULL;
	   int a = envid2env (envid, &new_env, 1);

	   if (a < 0)
			 return a;
f010478d:	89 c3                	mov    %eax,%ebx
f010478f:	e9 52 03 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   if ((uintptr_t)va >= UTOP || (uintptr_t) va % PGSIZE != 0)
			 return -E_INVAL;
f0104794:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104799:	e9 48 03 00 00       	jmp    f0104ae6 <syscall+0x5df>
f010479e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047a3:	e9 3e 03 00 00       	jmp    f0104ae6 <syscall+0x5df>

	   if ((perm & ~PTE_SYSCALL) != 0)
			 return -E_INVAL;
f01047a8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047ad:	e9 34 03 00 00       	jmp    f0104ae6 <syscall+0x5df>

	   struct PageInfo* np = page_alloc(ALLOC_ZERO);
	   if (!np)
			 return -E_NO_MEM;
f01047b2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			 case SYS_env_set_trapframe:
				    return sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
			 case SYS_env_set_pgfault_upcall:
				    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
			 case SYS_page_alloc:
				    return sys_page_alloc((envid_t) a1, (void *)a2, (int) a3);
f01047b7:	e9 2a 03 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   //   parameters for correctness.
	   //   Use the third argument to page_lookup() to
	   //   check the current permissions on the page.

	   // LAB 4: Your code here.
	   struct Env* source_env = NULL;
f01047bc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	   struct Env* dest_env = NULL;
f01047c3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			 return -E_INVAL;

	   uintptr_t sa = (uintptr_t) srcva;
	   uintptr_t da = (uintptr_t) dstva;

	   if (sa >= UTOP || (sa % PGSIZE) != 0 || da >= UTOP || (da % PGSIZE) != 0)
f01047ca:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f01047d1:	0f 85 97 00 00 00    	jne    f010486e <syscall+0x367>
f01047d7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047de:	0f 87 8a 00 00 00    	ja     f010486e <syscall+0x367>
f01047e4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047eb:	0f 85 87 00 00 00    	jne    f0104878 <syscall+0x371>
f01047f1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01047f8:	77 7e                	ja     f0104878 <syscall+0x371>
f01047fa:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104801:	75 7f                	jne    f0104882 <syscall+0x37b>
			 return -E_INVAL;


	   a = envid2env (srcenvid, &source_env, 1);
f0104803:	83 ec 04             	sub    $0x4,%esp
f0104806:	6a 01                	push   $0x1
f0104808:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010480b:	50                   	push   %eax
f010480c:	ff 75 0c             	pushl  0xc(%ebp)
f010480f:	e8 b1 e7 ff ff       	call   f0102fc5 <envid2env>
	   if (a < 0)
			 return a;
	   a = envid2env (dstenvid, &dest_env, 1);
f0104814:	83 c4 0c             	add    $0xc,%esp
f0104817:	6a 01                	push   $0x1
f0104819:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010481c:	50                   	push   %eax
f010481d:	ff 75 14             	pushl  0x14(%ebp)
f0104820:	e8 a0 e7 ff ff       	call   f0102fc5 <envid2env>
	   if (a < 0)
			 return a;

	   struct PageInfo* np = page_lookup (source_env -> env_pgdir, srcva, &pte);
f0104825:	83 c4 0c             	add    $0xc,%esp
f0104828:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010482b:	50                   	push   %eax
f010482c:	ff 75 10             	pushl  0x10(%ebp)
f010482f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104832:	ff 70 60             	pushl  0x60(%eax)
f0104835:	e8 f5 c9 ff ff       	call   f010122f <page_lookup>
	   if (!np)
f010483a:	83 c4 10             	add    $0x10,%esp
f010483d:	85 c0                	test   %eax,%eax
f010483f:	74 4b                	je     f010488c <syscall+0x385>
			 return -E_INVAL;

	   if ((perm & PTE_W) && !(*pte & PTE_W))
f0104841:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104845:	74 08                	je     f010484f <syscall+0x348>
f0104847:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010484a:	f6 02 02             	testb  $0x2,(%edx)
f010484d:	74 47                	je     f0104896 <syscall+0x38f>
			 return -E_INVAL;

	   a = page_insert (dest_env -> env_pgdir, np, dstva, perm);
f010484f:	ff 75 1c             	pushl  0x1c(%ebp)
f0104852:	ff 75 18             	pushl  0x18(%ebp)
f0104855:	50                   	push   %eax
f0104856:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104859:	ff 70 60             	pushl  0x60(%eax)
f010485c:	e8 b6 ca ff ff       	call   f0101317 <page_insert>
f0104861:	83 c4 10             	add    $0x10,%esp
	   if (a < 0)
			 return a;

	   return 0;
f0104864:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104869:	e9 78 02 00 00       	jmp    f0104ae6 <syscall+0x5df>

	   uintptr_t sa = (uintptr_t) srcva;
	   uintptr_t da = (uintptr_t) dstva;

	   if (sa >= UTOP || (sa % PGSIZE) != 0 || da >= UTOP || (da % PGSIZE) != 0)
			 return -E_INVAL;
f010486e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104873:	e9 6e 02 00 00       	jmp    f0104ae6 <syscall+0x5df>
f0104878:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010487d:	e9 64 02 00 00       	jmp    f0104ae6 <syscall+0x5df>
f0104882:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104887:	e9 5a 02 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   if (a < 0)
			 return a;

	   struct PageInfo* np = page_lookup (source_env -> env_pgdir, srcva, &pte);
	   if (!np)
			 return -E_INVAL;
f010488c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104891:	e9 50 02 00 00       	jmp    f0104ae6 <syscall+0x5df>

	   if ((perm & PTE_W) && !(*pte & PTE_W))
			 return -E_INVAL;
f0104896:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			 case SYS_env_set_pgfault_upcall:
				    return sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
			 case SYS_page_alloc:
				    return sys_page_alloc((envid_t) a1, (void *)a2, (int) a3);
			 case SYS_page_map:
				    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
f010489b:	e9 46 02 00 00       	jmp    f0104ae6 <syscall+0x5df>
sys_page_unmap(envid_t envid, void *va)
{
	   // Hint: This function is a wrapper around page_remove().

	   // LAB 4: Your code here.
	   struct Env* e_env = NULL;
f01048a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   uint32_t a = 0;

	   if ((uintptr_t) va % PGSIZE != 0 || (uintptr_t) va >= UTOP)
f01048a7:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048ae:	75 38                	jne    f01048e8 <syscall+0x3e1>
f01048b0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048b7:	77 2f                	ja     f01048e8 <syscall+0x3e1>
			 return -E_INVAL;

	   a = envid2env (envid, &e_env, 1);
f01048b9:	83 ec 04             	sub    $0x4,%esp
f01048bc:	6a 01                	push   $0x1
f01048be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048c1:	50                   	push   %eax
f01048c2:	ff 75 0c             	pushl  0xc(%ebp)
f01048c5:	e8 fb e6 ff ff       	call   f0102fc5 <envid2env>
	   if (a < 0)
			 return a;

	   page_remove (e_env -> env_pgdir, va);
f01048ca:	83 c4 08             	add    $0x8,%esp
f01048cd:	ff 75 10             	pushl  0x10(%ebp)
f01048d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048d3:	ff 70 60             	pushl  0x60(%eax)
f01048d6:	e8 ef c9 ff ff       	call   f01012ca <page_remove>
f01048db:	83 c4 10             	add    $0x10,%esp

	   return 0;
f01048de:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048e3:	e9 fe 01 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   // LAB 4: Your code here.
	   struct Env* e_env = NULL;
	   uint32_t a = 0;

	   if ((uintptr_t) va % PGSIZE != 0 || (uintptr_t) va >= UTOP)
			 return -E_INVAL;
f01048e8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			 case SYS_page_alloc:
				    return sys_page_alloc((envid_t) a1, (void *)a2, (int) a3);
			 case SYS_page_map:
				    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
			 case SYS_page_unmap:
				    return sys_page_unmap((envid_t) a1, (void *) a2);
f01048ed:	e9 f4 01 00 00       	jmp    f0104ae6 <syscall+0x5df>
sys_ipc_recv(void *dstva)
{
	   // LAB 4: Your code here.
	   uintptr_t address = (intptr_t) dstva;

	   if ((address < UTOP) && (address % PGSIZE) != 0)
f01048f2:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01048f9:	0f 87 51 01 00 00    	ja     f0104a50 <syscall+0x549>
f01048ff:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104906:	0f 85 3a 01 00 00    	jne    f0104a46 <syscall+0x53f>
f010490c:	e9 80 01 00 00       	jmp    f0104a91 <syscall+0x58a>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	   // LAB 4: Your code here.
	   int a  = 0;
	   int r_perm = 0;
	   struct Env* d_env = NULL;
f0104911:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

	   uintptr_t address = (uintptr_t) srcva;

	   a = envid2env (envid, &d_env, 0);
f0104918:	83 ec 04             	sub    $0x4,%esp
f010491b:	6a 00                	push   $0x0
f010491d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104920:	50                   	push   %eax
f0104921:	ff 75 0c             	pushl  0xc(%ebp)
f0104924:	e8 9c e6 ff ff       	call   f0102fc5 <envid2env>
	   if (a < 0)
f0104929:	83 c4 10             	add    $0x10,%esp
f010492c:	85 c0                	test   %eax,%eax
f010492e:	0f 88 e3 00 00 00    	js     f0104a17 <syscall+0x510>
	   {
			 return a;
	   } else if (!(d_env -> env_ipc_recving))
f0104934:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104937:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010493b:	0f 84 dd 00 00 00    	je     f0104a1e <syscall+0x517>
	   {
			 return -E_IPC_NOT_RECV;
	   } else if ((address < UTOP) && (address % PGSIZE) != 0)
f0104941:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104948:	0f 87 8c 00 00 00    	ja     f01049da <syscall+0x4d3>
f010494e:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104955:	0f 85 cd 00 00 00    	jne    f0104a28 <syscall+0x521>
	   {	return -E_INVAL;
	   } else if ((address < UTOP) && (perm & ~PTE_SYSCALL) != 0)
f010495b:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104962:	0f 85 ca 00 00 00    	jne    f0104a32 <syscall+0x52b>
			 return -E_INVAL;
	   }

	   if (address < UTOP)
	   {
			 pte_t* pte = NULL;
f0104968:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			 struct PageInfo* page = page_lookup (curenv -> env_pgdir, srcva, &pte);
f010496f:	e8 ae 12 00 00       	call   f0105c22 <cpunum>
f0104974:	83 ec 04             	sub    $0x4,%esp
f0104977:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010497a:	52                   	push   %edx
f010497b:	ff 75 14             	pushl  0x14(%ebp)
f010497e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104981:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104987:	ff 70 60             	pushl  0x60(%eax)
f010498a:	e8 a0 c8 ff ff       	call   f010122f <page_lookup>
			 if (!page)
f010498f:	83 c4 10             	add    $0x10,%esp
f0104992:	85 c0                	test   %eax,%eax
f0104994:	74 33                	je     f01049c9 <syscall+0x4c2>
			 {
				    return -E_INVAL;
			 } else if ((perm & PTE_W) && !(*pte &PTE_W))
f0104996:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f010499a:	74 11                	je     f01049ad <syscall+0x4a6>
			 {
				    return -E_INVAL;
f010499c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			 pte_t* pte = NULL;
			 struct PageInfo* page = page_lookup (curenv -> env_pgdir, srcva, &pte);
			 if (!page)
			 {
				    return -E_INVAL;
			 } else if ((perm & PTE_W) && !(*pte &PTE_W))
f01049a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01049a4:	f6 02 02             	testb  $0x2,(%edx)
f01049a7:	0f 84 39 01 00 00    	je     f0104ae6 <syscall+0x5df>
			 {
				    return -E_INVAL;
			 }

			 a = page_insert (d_env -> env_pgdir, page, d_env -> env_ipc_dstva, perm);
f01049ad:	8b 75 18             	mov    0x18(%ebp),%esi
f01049b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01049b3:	56                   	push   %esi
f01049b4:	ff 72 6c             	pushl  0x6c(%edx)
f01049b7:	50                   	push   %eax
f01049b8:	ff 72 60             	pushl  0x60(%edx)
f01049bb:	e8 57 c9 ff ff       	call   f0101317 <page_insert>
			 if (a < 0)
f01049c0:	83 c4 10             	add    $0x10,%esp
f01049c3:	85 c0                	test   %eax,%eax
f01049c5:	79 18                	jns    f01049df <syscall+0x4d8>
f01049c7:	eb 0a                	jmp    f01049d3 <syscall+0x4cc>
	   {
			 pte_t* pte = NULL;
			 struct PageInfo* page = page_lookup (curenv -> env_pgdir, srcva, &pte);
			 if (!page)
			 {
				    return -E_INVAL;
f01049c9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049ce:	e9 13 01 00 00       	jmp    f0104ae6 <syscall+0x5df>
				    return -E_INVAL;
			 }

			 a = page_insert (d_env -> env_pgdir, page, d_env -> env_ipc_dstva, perm);
			 if (a < 0)
				    return a;
f01049d3:	89 c3                	mov    %eax,%ebx
f01049d5:	e9 0c 01 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	   // LAB 4: Your code here.
	   int a  = 0;
	   int r_perm = 0;
f01049da:	be 00 00 00 00       	mov    $0x0,%esi
				    return a;

			 r_perm = perm;
	   }

	   d_env->env_ipc_value = value;
f01049df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01049e2:	8b 45 10             	mov    0x10(%ebp),%eax
f01049e5:	89 43 70             	mov    %eax,0x70(%ebx)
	   d_env->env_ipc_from = curenv->env_id;
f01049e8:	e8 35 12 00 00       	call   f0105c22 <cpunum>
f01049ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f0:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01049f6:	8b 40 48             	mov    0x48(%eax),%eax
f01049f9:	89 43 74             	mov    %eax,0x74(%ebx)
	   d_env->env_ipc_perm = r_perm;
f01049fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049ff:	89 70 78             	mov    %esi,0x78(%eax)
	   d_env->env_ipc_recving = false;
f0104a02:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	   d_env->env_status = ENV_RUNNABLE;
f0104a06:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	   return 0;
f0104a0d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a12:	e9 cf 00 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   uintptr_t address = (uintptr_t) srcva;

	   a = envid2env (envid, &d_env, 0);
	   if (a < 0)
	   {
			 return a;
f0104a17:	89 c3                	mov    %eax,%ebx
f0104a19:	e9 c8 00 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   } else if (!(d_env -> env_ipc_recving))
	   {
			 return -E_IPC_NOT_RECV;
f0104a1e:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104a23:	e9 be 00 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   } else if ((address < UTOP) && (address % PGSIZE) != 0)
	   {	return -E_INVAL;
f0104a28:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a2d:	e9 b4 00 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   } else if ((address < UTOP) && (perm & ~PTE_SYSCALL) != 0)
	   {
			 return -E_INVAL;
f0104a32:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			 case SYS_page_unmap:
				    return sys_page_unmap((envid_t) a1, (void *) a2);
			 case SYS_ipc_recv:
				    return sys_ipc_recv((void *)a1);
			 case SYS_ipc_try_send:
				    return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104a37:	e9 aa 00 00 00       	jmp    f0104ae6 <syscall+0x5df>
			 default:
				    return -E_INVAL;
f0104a3c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a41:	e9 a0 00 00 00       	jmp    f0104ae6 <syscall+0x5df>
			 case SYS_page_map:
				    return sys_page_map((envid_t) a1, (void *) a2, (envid_t) a3, (void *) a4, (int) a5);
			 case SYS_page_unmap:
				    return sys_page_unmap((envid_t) a1, (void *) a2);
			 case SYS_ipc_recv:
				    return sys_ipc_recv((void *)a1);
f0104a46:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a4b:	e9 96 00 00 00       	jmp    f0104ae6 <syscall+0x5df>
	   if ((address < UTOP) && (address % PGSIZE) != 0)
	   {
			 return -E_INVAL;
	   }

	   curenv -> env_status = ENV_NOT_RUNNABLE;
f0104a50:	e8 cd 11 00 00       	call   f0105c22 <cpunum>
f0104a55:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a58:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104a5e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	   curenv -> env_ipc_recving = true;
f0104a65:	e8 b8 11 00 00       	call   f0105c22 <cpunum>
f0104a6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a6d:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104a73:	c6 40 68 01          	movb   $0x1,0x68(%eax)

	   if (address >= UTOP)
	   {
			 curenv -> env_tf.tf_regs.reg_eax = 0;
f0104a77:	e8 a6 11 00 00       	call   f0105c22 <cpunum>
f0104a7c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a7f:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104a85:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
			 sched_yield();
f0104a8c:	e8 ae f9 ff ff       	call   f010443f <sched_yield>
	   if ((address < UTOP) && (address % PGSIZE) != 0)
	   {
			 return -E_INVAL;
	   }

	   curenv -> env_status = ENV_NOT_RUNNABLE;
f0104a91:	e8 8c 11 00 00       	call   f0105c22 <cpunum>
f0104a96:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a99:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104a9f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	   curenv -> env_ipc_recving = true;
f0104aa6:	e8 77 11 00 00       	call   f0105c22 <cpunum>
f0104aab:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aae:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104ab4:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	   {
			 curenv -> env_tf.tf_regs.reg_eax = 0;
			 sched_yield();
	   }

	   curenv -> env_ipc_dstva = dstva;
f0104ab8:	e8 65 11 00 00       	call   f0105c22 <cpunum>
f0104abd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac0:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104ac6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ac9:	89 48 6c             	mov    %ecx,0x6c(%eax)
	   curenv -> env_tf.tf_regs.reg_eax = 0;
f0104acc:	e8 51 11 00 00       	call   f0105c22 <cpunum>
f0104ad1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad4:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104ada:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	   sched_yield();
f0104ae1:	e8 59 f9 ff ff       	call   f010443f <sched_yield>
			 case SYS_ipc_try_send:
				    return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
			 default:
				    return -E_INVAL;
	   }
}
f0104ae6:	89 d8                	mov    %ebx,%eax
f0104ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aeb:	5b                   	pop    %ebx
f0104aec:	5e                   	pop    %esi
f0104aed:	5f                   	pop    %edi
f0104aee:	5d                   	pop    %ebp
f0104aef:	c3                   	ret    

f0104af0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
	   static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
f0104af0:	55                   	push   %ebp
f0104af1:	89 e5                	mov    %esp,%ebp
f0104af3:	57                   	push   %edi
f0104af4:	56                   	push   %esi
f0104af5:	53                   	push   %ebx
f0104af6:	83 ec 14             	sub    $0x14,%esp
f0104af9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104afc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104aff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104b02:	8b 7d 08             	mov    0x8(%ebp),%edi
	   int l = *region_left, r = *region_right, any_matches = 0;
f0104b05:	8b 1a                	mov    (%edx),%ebx
f0104b07:	8b 01                	mov    (%ecx),%eax
f0104b09:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b0c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	   while (l <= r) {
f0104b13:	eb 7f                	jmp    f0104b94 <stab_binsearch+0xa4>
			 int true_m = (l + r) / 2, m = true_m;
f0104b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b18:	01 d8                	add    %ebx,%eax
f0104b1a:	89 c6                	mov    %eax,%esi
f0104b1c:	c1 ee 1f             	shr    $0x1f,%esi
f0104b1f:	01 c6                	add    %eax,%esi
f0104b21:	d1 fe                	sar    %esi
f0104b23:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104b26:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b29:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104b2c:	89 f0                	mov    %esi,%eax

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f0104b2e:	eb 03                	jmp    f0104b33 <stab_binsearch+0x43>
				    m--;
f0104b30:	83 e8 01             	sub    $0x1,%eax

	   while (l <= r) {
			 int true_m = (l + r) / 2, m = true_m;

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f0104b33:	39 c3                	cmp    %eax,%ebx
f0104b35:	7f 0d                	jg     f0104b44 <stab_binsearch+0x54>
f0104b37:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104b3b:	83 ea 0c             	sub    $0xc,%edx
f0104b3e:	39 f9                	cmp    %edi,%ecx
f0104b40:	75 ee                	jne    f0104b30 <stab_binsearch+0x40>
f0104b42:	eb 05                	jmp    f0104b49 <stab_binsearch+0x59>
				    m--;
			 if (m < l) {	// no match in [l, m]
				    l = true_m + 1;
f0104b44:	8d 5e 01             	lea    0x1(%esi),%ebx
				    continue;
f0104b47:	eb 4b                	jmp    f0104b94 <stab_binsearch+0xa4>
			 }

			 // actual binary search
			 any_matches = 1;
			 if (stabs[m].n_value < addr) {
f0104b49:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b4c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b4f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104b53:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b56:	76 11                	jbe    f0104b69 <stab_binsearch+0x79>
				    *region_left = m;
f0104b58:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104b5b:	89 03                	mov    %eax,(%ebx)
				    l = true_m + 1;
f0104b5d:	8d 5e 01             	lea    0x1(%esi),%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0104b60:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b67:	eb 2b                	jmp    f0104b94 <stab_binsearch+0xa4>
			 if (stabs[m].n_value < addr) {
				    *region_left = m;
				    l = true_m + 1;
			 } else if (stabs[m].n_value > addr) {
f0104b69:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b6c:	73 14                	jae    f0104b82 <stab_binsearch+0x92>
				    *region_right = m - 1;
f0104b6e:	83 e8 01             	sub    $0x1,%eax
f0104b71:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b74:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b77:	89 06                	mov    %eax,(%esi)
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0104b79:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b80:	eb 12                	jmp    f0104b94 <stab_binsearch+0xa4>
				    *region_right = m - 1;
				    r = m - 1;
			 } else {
				    // exact match for 'addr', but continue loop to find
				    // *region_right
				    *region_left = m;
f0104b82:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b85:	89 06                	mov    %eax,(%esi)
				    l = m;
				    addr++;
f0104b87:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b8b:	89 c3                	mov    %eax,%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0104b8d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
	   int l = *region_left, r = *region_right, any_matches = 0;

	   while (l <= r) {
f0104b94:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104b97:	0f 8e 78 ff ff ff    	jle    f0104b15 <stab_binsearch+0x25>
				    l = m;
				    addr++;
			 }
	   }

	   if (!any_matches)
f0104b9d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104ba1:	75 0f                	jne    f0104bb2 <stab_binsearch+0xc2>
			 *region_right = *region_left - 1;
f0104ba3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ba6:	8b 00                	mov    (%eax),%eax
f0104ba8:	83 e8 01             	sub    $0x1,%eax
f0104bab:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104bae:	89 06                	mov    %eax,(%esi)
f0104bb0:	eb 2c                	jmp    f0104bde <stab_binsearch+0xee>
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0104bb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104bb5:	8b 00                	mov    (%eax),%eax
						  l > *region_left && stabs[l].n_type != type;
f0104bb7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104bba:	8b 0e                	mov    (%esi),%ecx
f0104bbc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104bbf:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104bc2:	8d 14 96             	lea    (%esi,%edx,4),%edx

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0104bc5:	eb 03                	jmp    f0104bca <stab_binsearch+0xda>
						  l > *region_left && stabs[l].n_type != type;
						  l--)
f0104bc7:	83 e8 01             	sub    $0x1,%eax

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0104bca:	39 c8                	cmp    %ecx,%eax
f0104bcc:	7e 0b                	jle    f0104bd9 <stab_binsearch+0xe9>
						  l > *region_left && stabs[l].n_type != type;
f0104bce:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104bd2:	83 ea 0c             	sub    $0xc,%edx
f0104bd5:	39 df                	cmp    %ebx,%edi
f0104bd7:	75 ee                	jne    f0104bc7 <stab_binsearch+0xd7>
						  l--)
				    /* do nothing */;
			 *region_left = l;
f0104bd9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104bdc:	89 06                	mov    %eax,(%esi)
	   }
}
f0104bde:	83 c4 14             	add    $0x14,%esp
f0104be1:	5b                   	pop    %ebx
f0104be2:	5e                   	pop    %esi
f0104be3:	5f                   	pop    %edi
f0104be4:	5d                   	pop    %ebp
f0104be5:	c3                   	ret    

f0104be6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
	   int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104be6:	55                   	push   %ebp
f0104be7:	89 e5                	mov    %esp,%ebp
f0104be9:	57                   	push   %edi
f0104bea:	56                   	push   %esi
f0104beb:	53                   	push   %ebx
f0104bec:	83 ec 2c             	sub    $0x2c,%esp
f0104bef:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104bf2:	8b 75 0c             	mov    0xc(%ebp),%esi
	   const struct Stab *stabs, *stab_end;
	   const char *stabstr, *stabstr_end;
	   int lfile, rfile, lfun, rfun, lline, rline;

	   // Initialize *info
	   info->eip_file = "<unknown>";
f0104bf5:	c7 06 28 7b 10 f0    	movl   $0xf0107b28,(%esi)
	   info->eip_line = 0;
f0104bfb:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	   info->eip_fn_name = "<unknown>";
f0104c02:	c7 46 08 28 7b 10 f0 	movl   $0xf0107b28,0x8(%esi)
	   info->eip_fn_namelen = 9;
f0104c09:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	   info->eip_fn_addr = addr;
f0104c10:	89 7e 10             	mov    %edi,0x10(%esi)
	   info->eip_fn_narg = 0;
f0104c13:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
f0104c1a:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104c20:	0f 87 a3 00 00 00    	ja     f0104cc9 <debuginfo_eip+0xe3>

			 // Make sure this memory is valid.
			 // Return -1 if it is not.  Hint: Call user_mem_check.
			 // LAB 3: Your code here.

			 if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
f0104c26:	e8 f7 0f 00 00       	call   f0105c22 <cpunum>
f0104c2b:	6a 04                	push   $0x4
f0104c2d:	6a 10                	push   $0x10
f0104c2f:	68 00 00 20 00       	push   $0x200000
f0104c34:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c37:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104c3d:	e8 21 e2 ff ff       	call   f0102e63 <user_mem_check>
f0104c42:	83 c4 10             	add    $0x10,%esp
f0104c45:	85 c0                	test   %eax,%eax
f0104c47:	0f 88 d4 01 00 00    	js     f0104e21 <debuginfo_eip+0x23b>
				 return -1;

			 stabs = usd->stabs;
f0104c4d:	a1 00 00 20 00       	mov    0x200000,%eax
f0104c52:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			 stab_end = usd->stab_end;
f0104c55:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
			 stabstr = usd->stabstr;
f0104c5b:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104c61:	89 55 cc             	mov    %edx,-0x34(%ebp)
			 stabstr_end = usd->stabstr_end;
f0104c64:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104c69:	89 45 d0             	mov    %eax,-0x30(%ebp)

			 // Make sure the STABS and string table memory is valid.
			 // LAB 3: Your code here.

			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
f0104c6c:	e8 b1 0f 00 00       	call   f0105c22 <cpunum>
f0104c71:	6a 04                	push   $0x4
f0104c73:	89 da                	mov    %ebx,%edx
f0104c75:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104c78:	29 ca                	sub    %ecx,%edx
f0104c7a:	c1 fa 02             	sar    $0x2,%edx
f0104c7d:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104c83:	52                   	push   %edx
f0104c84:	51                   	push   %ecx
f0104c85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c88:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104c8e:	e8 d0 e1 ff ff       	call   f0102e63 <user_mem_check>
f0104c93:	83 c4 10             	add    $0x10,%esp
f0104c96:	85 c0                	test   %eax,%eax
f0104c98:	0f 88 8a 01 00 00    	js     f0104e28 <debuginfo_eip+0x242>
f0104c9e:	e8 7f 0f 00 00       	call   f0105c22 <cpunum>
f0104ca3:	6a 04                	push   $0x4
f0104ca5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104ca8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104cab:	29 ca                	sub    %ecx,%edx
f0104cad:	52                   	push   %edx
f0104cae:	51                   	push   %ecx
f0104caf:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cb2:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104cb8:	e8 a6 e1 ff ff       	call   f0102e63 <user_mem_check>
f0104cbd:	83 c4 10             	add    $0x10,%esp
f0104cc0:	85 c0                	test   %eax,%eax
f0104cc2:	79 1f                	jns    f0104ce3 <debuginfo_eip+0xfd>
f0104cc4:	e9 66 01 00 00       	jmp    f0104e2f <debuginfo_eip+0x249>
	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
			 stabstr = __STABSTR_BEGIN__;
			 stabstr_end = __STABSTR_END__;
f0104cc9:	c7 45 d0 4e 5d 11 f0 	movl   $0xf0115d4e,-0x30(%ebp)

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
			 stabstr = __STABSTR_BEGIN__;
f0104cd0:	c7 45 cc 89 25 11 f0 	movl   $0xf0112589,-0x34(%ebp)
	   info->eip_fn_narg = 0;

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
f0104cd7:	bb 88 25 11 f0       	mov    $0xf0112588,%ebx
	   info->eip_fn_addr = addr;
	   info->eip_fn_narg = 0;

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
f0104cdc:	c7 45 d4 d0 80 10 f0 	movl   $0xf01080d0,-0x2c(%ebp)
			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
				 return -1;
   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104ce3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ce6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0104ce9:	0f 83 47 01 00 00    	jae    f0104e36 <debuginfo_eip+0x250>
f0104cef:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104cf3:	0f 85 44 01 00 00    	jne    f0104e3d <debuginfo_eip+0x257>
	   // 'eip'.  First, we find the basic source file containing 'eip'.
	   // Then, we look in that source file for the function.  Then we look
	   // for the line number.

	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
f0104cf9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   rfile = (stab_end - stabs) - 1;
f0104d00:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f0104d03:	c1 fb 02             	sar    $0x2,%ebx
f0104d06:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0104d0c:	83 e8 01             	sub    $0x1,%eax
f0104d0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104d12:	83 ec 08             	sub    $0x8,%esp
f0104d15:	57                   	push   %edi
f0104d16:	6a 64                	push   $0x64
f0104d18:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104d1b:	89 d1                	mov    %edx,%ecx
f0104d1d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104d23:	89 d8                	mov    %ebx,%eax
f0104d25:	e8 c6 fd ff ff       	call   f0104af0 <stab_binsearch>
	   if (lfile == 0)
f0104d2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d2d:	83 c4 10             	add    $0x10,%esp
f0104d30:	85 c0                	test   %eax,%eax
f0104d32:	0f 84 0c 01 00 00    	je     f0104e44 <debuginfo_eip+0x25e>
			 return -1;

	   // Search within that file's stabs for the function definition
	   // (N_FUN).
	   lfun = lfile;
f0104d38:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   rfun = rfile;
f0104d3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	   stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104d41:	83 ec 08             	sub    $0x8,%esp
f0104d44:	57                   	push   %edi
f0104d45:	6a 24                	push   $0x24
f0104d47:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104d4a:	89 d1                	mov    %edx,%ecx
f0104d4c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104d4f:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104d52:	89 d8                	mov    %ebx,%eax
f0104d54:	e8 97 fd ff ff       	call   f0104af0 <stab_binsearch>

	   if (lfun <= rfun) {
f0104d59:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104d5c:	83 c4 10             	add    $0x10,%esp
f0104d5f:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104d62:	7f 24                	jg     f0104d88 <debuginfo_eip+0x1a2>
			 // stabs[lfun] points to the function name
			 // in the string table, but check bounds just in case.
			 if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104d64:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d67:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d6a:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0104d6d:	8b 02                	mov    (%edx),%eax
f0104d6f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104d72:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104d75:	29 f9                	sub    %edi,%ecx
f0104d77:	39 c8                	cmp    %ecx,%eax
f0104d79:	73 05                	jae    f0104d80 <debuginfo_eip+0x19a>
				    info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104d7b:	01 f8                	add    %edi,%eax
f0104d7d:	89 46 08             	mov    %eax,0x8(%esi)
			 info->eip_fn_addr = stabs[lfun].n_value;
f0104d80:	8b 42 08             	mov    0x8(%edx),%eax
f0104d83:	89 46 10             	mov    %eax,0x10(%esi)
f0104d86:	eb 06                	jmp    f0104d8e <debuginfo_eip+0x1a8>
			 lline = lfun;
			 rline = rfun;
	   } else {
			 // Couldn't find function stab!  Maybe we're in an assembly
			 // file.  Search the whole file for the line number.
			 info->eip_fn_addr = addr;
f0104d88:	89 7e 10             	mov    %edi,0x10(%esi)
			 lline = lfile;
f0104d8b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			 rline = rfile;
	   }
	   // Ignore stuff after the colon.
	   info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104d8e:	83 ec 08             	sub    $0x8,%esp
f0104d91:	6a 3a                	push   $0x3a
f0104d93:	ff 76 08             	pushl  0x8(%esi)
f0104d96:	e8 48 08 00 00       	call   f01055e3 <strfind>
f0104d9b:	2b 46 08             	sub    0x8(%esi),%eax
f0104d9e:	89 46 0c             	mov    %eax,0xc(%esi)
	   // Search backwards from the line number for the relevant filename
	   // stab.
	   // We can't just use the "lfile" stab because inlined functions
	   // can interpolate code from a different file!
	   // Such included source files use the N_SOL stab type.
	   while (lline >= lfile
f0104da1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104da4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104da7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104daa:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104dad:	83 c4 10             	add    $0x10,%esp
f0104db0:	eb 06                	jmp    f0104db8 <debuginfo_eip+0x1d2>
				    && stabs[lline].n_type != N_SOL
				    && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
			 lline--;
f0104db2:	83 eb 01             	sub    $0x1,%ebx
f0104db5:	83 e8 0c             	sub    $0xc,%eax
	   // Search backwards from the line number for the relevant filename
	   // stab.
	   // We can't just use the "lfile" stab because inlined functions
	   // can interpolate code from a different file!
	   // Such included source files use the N_SOL stab type.
	   while (lline >= lfile
f0104db8:	39 fb                	cmp    %edi,%ebx
f0104dba:	7c 2d                	jl     f0104de9 <debuginfo_eip+0x203>
				    && stabs[lline].n_type != N_SOL
f0104dbc:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104dc0:	80 fa 84             	cmp    $0x84,%dl
f0104dc3:	74 0b                	je     f0104dd0 <debuginfo_eip+0x1ea>
				    && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104dc5:	80 fa 64             	cmp    $0x64,%dl
f0104dc8:	75 e8                	jne    f0104db2 <debuginfo_eip+0x1cc>
f0104dca:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104dce:	74 e2                	je     f0104db2 <debuginfo_eip+0x1cc>
			 lline--;
	   if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104dd0:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104dd3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104dd6:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104dd9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104ddc:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104ddf:	29 f8                	sub    %edi,%eax
f0104de1:	39 c2                	cmp    %eax,%edx
f0104de3:	73 04                	jae    f0104de9 <debuginfo_eip+0x203>
			 info->eip_file = stabstr + stabs[lline].n_strx;
f0104de5:	01 fa                	add    %edi,%edx
f0104de7:	89 16                	mov    %edx,(%esi)


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0104de9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104dec:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0104def:	b8 00 00 00 00       	mov    $0x0,%eax
			 info->eip_file = stabstr + stabs[lline].n_strx;


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0104df4:	39 cb                	cmp    %ecx,%ebx
f0104df6:	7d 58                	jge    f0104e50 <debuginfo_eip+0x26a>
			 for (lline = lfun + 1;
f0104df8:	8d 53 01             	lea    0x1(%ebx),%edx
f0104dfb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104dfe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104e01:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104e04:	eb 07                	jmp    f0104e0d <debuginfo_eip+0x227>
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;
f0104e06:	83 46 14 01          	addl   $0x1,0x14(%esi)
	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
f0104e0a:	83 c2 01             	add    $0x1,%edx


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
			 for (lline = lfun + 1;
f0104e0d:	39 ca                	cmp    %ecx,%edx
f0104e0f:	74 3a                	je     f0104e4b <debuginfo_eip+0x265>
f0104e11:	83 c0 0c             	add    $0xc,%eax
						  lline < rfun && stabs[lline].n_type == N_PSYM;
f0104e14:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104e18:	74 ec                	je     f0104e06 <debuginfo_eip+0x220>
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0104e1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e1f:	eb 2f                	jmp    f0104e50 <debuginfo_eip+0x26a>
			 // Make sure this memory is valid.
			 // Return -1 if it is not.  Hint: Call user_mem_check.
			 // LAB 3: Your code here.

			 if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
				 return -1;
f0104e21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e26:	eb 28                	jmp    f0104e50 <debuginfo_eip+0x26a>

			 // Make sure the STABS and string table memory is valid.
			 // LAB 3: Your code here.

			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
				 return -1;
f0104e28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e2d:	eb 21                	jmp    f0104e50 <debuginfo_eip+0x26a>
f0104e2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e34:	eb 1a                	jmp    f0104e50 <debuginfo_eip+0x26a>
   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
			 return -1;
f0104e36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e3b:	eb 13                	jmp    f0104e50 <debuginfo_eip+0x26a>
f0104e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e42:	eb 0c                	jmp    f0104e50 <debuginfo_eip+0x26a>
	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
	   rfile = (stab_end - stabs) - 1;
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	   if (lfile == 0)
			 return -1;
f0104e44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e49:	eb 05                	jmp    f0104e50 <debuginfo_eip+0x26a>
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0104e4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e53:	5b                   	pop    %ebx
f0104e54:	5e                   	pop    %esi
f0104e55:	5f                   	pop    %edi
f0104e56:	5d                   	pop    %ebp
f0104e57:	c3                   	ret    

f0104e58 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e58:	55                   	push   %ebp
f0104e59:	89 e5                	mov    %esp,%ebp
f0104e5b:	57                   	push   %edi
f0104e5c:	56                   	push   %esi
f0104e5d:	53                   	push   %ebx
f0104e5e:	83 ec 1c             	sub    $0x1c,%esp
f0104e61:	89 c7                	mov    %eax,%edi
f0104e63:	89 d6                	mov    %edx,%esi
f0104e65:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e68:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e6e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e71:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e74:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e79:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e7c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e7f:	39 d3                	cmp    %edx,%ebx
f0104e81:	72 05                	jb     f0104e88 <printnum+0x30>
f0104e83:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e86:	77 45                	ja     f0104ecd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e88:	83 ec 0c             	sub    $0xc,%esp
f0104e8b:	ff 75 18             	pushl  0x18(%ebp)
f0104e8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e91:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e94:	53                   	push   %ebx
f0104e95:	ff 75 10             	pushl  0x10(%ebp)
f0104e98:	83 ec 08             	sub    $0x8,%esp
f0104e9b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e9e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ea1:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ea4:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ea7:	e8 74 11 00 00       	call   f0106020 <__udivdi3>
f0104eac:	83 c4 18             	add    $0x18,%esp
f0104eaf:	52                   	push   %edx
f0104eb0:	50                   	push   %eax
f0104eb1:	89 f2                	mov    %esi,%edx
f0104eb3:	89 f8                	mov    %edi,%eax
f0104eb5:	e8 9e ff ff ff       	call   f0104e58 <printnum>
f0104eba:	83 c4 20             	add    $0x20,%esp
f0104ebd:	eb 18                	jmp    f0104ed7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104ebf:	83 ec 08             	sub    $0x8,%esp
f0104ec2:	56                   	push   %esi
f0104ec3:	ff 75 18             	pushl  0x18(%ebp)
f0104ec6:	ff d7                	call   *%edi
f0104ec8:	83 c4 10             	add    $0x10,%esp
f0104ecb:	eb 03                	jmp    f0104ed0 <printnum+0x78>
f0104ecd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104ed0:	83 eb 01             	sub    $0x1,%ebx
f0104ed3:	85 db                	test   %ebx,%ebx
f0104ed5:	7f e8                	jg     f0104ebf <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104ed7:	83 ec 08             	sub    $0x8,%esp
f0104eda:	56                   	push   %esi
f0104edb:	83 ec 04             	sub    $0x4,%esp
f0104ede:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ee1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ee4:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ee7:	ff 75 d8             	pushl  -0x28(%ebp)
f0104eea:	e8 61 12 00 00       	call   f0106150 <__umoddi3>
f0104eef:	83 c4 14             	add    $0x14,%esp
f0104ef2:	0f be 80 32 7b 10 f0 	movsbl -0xfef84ce(%eax),%eax
f0104ef9:	50                   	push   %eax
f0104efa:	ff d7                	call   *%edi
}
f0104efc:	83 c4 10             	add    $0x10,%esp
f0104eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f02:	5b                   	pop    %ebx
f0104f03:	5e                   	pop    %esi
f0104f04:	5f                   	pop    %edi
f0104f05:	5d                   	pop    %ebp
f0104f06:	c3                   	ret    

f0104f07 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104f07:	55                   	push   %ebp
f0104f08:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104f0a:	83 fa 01             	cmp    $0x1,%edx
f0104f0d:	7e 0e                	jle    f0104f1d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104f0f:	8b 10                	mov    (%eax),%edx
f0104f11:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104f14:	89 08                	mov    %ecx,(%eax)
f0104f16:	8b 02                	mov    (%edx),%eax
f0104f18:	8b 52 04             	mov    0x4(%edx),%edx
f0104f1b:	eb 22                	jmp    f0104f3f <getuint+0x38>
	else if (lflag)
f0104f1d:	85 d2                	test   %edx,%edx
f0104f1f:	74 10                	je     f0104f31 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104f21:	8b 10                	mov    (%eax),%edx
f0104f23:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f26:	89 08                	mov    %ecx,(%eax)
f0104f28:	8b 02                	mov    (%edx),%eax
f0104f2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f2f:	eb 0e                	jmp    f0104f3f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104f31:	8b 10                	mov    (%eax),%edx
f0104f33:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f36:	89 08                	mov    %ecx,(%eax)
f0104f38:	8b 02                	mov    (%edx),%eax
f0104f3a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104f3f:	5d                   	pop    %ebp
f0104f40:	c3                   	ret    

f0104f41 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f41:	55                   	push   %ebp
f0104f42:	89 e5                	mov    %esp,%ebp
f0104f44:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f47:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f4b:	8b 10                	mov    (%eax),%edx
f0104f4d:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f50:	73 0a                	jae    f0104f5c <sprintputch+0x1b>
		*b->buf++ = ch;
f0104f52:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f55:	89 08                	mov    %ecx,(%eax)
f0104f57:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f5a:	88 02                	mov    %al,(%edx)
}
f0104f5c:	5d                   	pop    %ebp
f0104f5d:	c3                   	ret    

f0104f5e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104f5e:	55                   	push   %ebp
f0104f5f:	89 e5                	mov    %esp,%ebp
f0104f61:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104f64:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f67:	50                   	push   %eax
f0104f68:	ff 75 10             	pushl  0x10(%ebp)
f0104f6b:	ff 75 0c             	pushl  0xc(%ebp)
f0104f6e:	ff 75 08             	pushl  0x8(%ebp)
f0104f71:	e8 05 00 00 00       	call   f0104f7b <vprintfmt>
	va_end(ap);
}
f0104f76:	83 c4 10             	add    $0x10,%esp
f0104f79:	c9                   	leave  
f0104f7a:	c3                   	ret    

f0104f7b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104f7b:	55                   	push   %ebp
f0104f7c:	89 e5                	mov    %esp,%ebp
f0104f7e:	57                   	push   %edi
f0104f7f:	56                   	push   %esi
f0104f80:	53                   	push   %ebx
f0104f81:	83 ec 2c             	sub    $0x2c,%esp
f0104f84:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f87:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f8a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f8d:	eb 12                	jmp    f0104fa1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f8f:	85 c0                	test   %eax,%eax
f0104f91:	0f 84 89 03 00 00    	je     f0105320 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104f97:	83 ec 08             	sub    $0x8,%esp
f0104f9a:	53                   	push   %ebx
f0104f9b:	50                   	push   %eax
f0104f9c:	ff d6                	call   *%esi
f0104f9e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104fa1:	83 c7 01             	add    $0x1,%edi
f0104fa4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104fa8:	83 f8 25             	cmp    $0x25,%eax
f0104fab:	75 e2                	jne    f0104f8f <vprintfmt+0x14>
f0104fad:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104fb1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104fb8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104fbf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104fc6:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fcb:	eb 07                	jmp    f0104fd4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fcd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104fd0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fd4:	8d 47 01             	lea    0x1(%edi),%eax
f0104fd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fda:	0f b6 07             	movzbl (%edi),%eax
f0104fdd:	0f b6 c8             	movzbl %al,%ecx
f0104fe0:	83 e8 23             	sub    $0x23,%eax
f0104fe3:	3c 55                	cmp    $0x55,%al
f0104fe5:	0f 87 1a 03 00 00    	ja     f0105305 <vprintfmt+0x38a>
f0104feb:	0f b6 c0             	movzbl %al,%eax
f0104fee:	ff 24 85 80 7c 10 f0 	jmp    *-0xfef8380(,%eax,4)
f0104ff5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104ff8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104ffc:	eb d6                	jmp    f0104fd4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ffe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105001:	b8 00 00 00 00       	mov    $0x0,%eax
f0105006:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105009:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010500c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105010:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0105013:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105016:	83 fa 09             	cmp    $0x9,%edx
f0105019:	77 39                	ja     f0105054 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010501b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010501e:	eb e9                	jmp    f0105009 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105020:	8b 45 14             	mov    0x14(%ebp),%eax
f0105023:	8d 48 04             	lea    0x4(%eax),%ecx
f0105026:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105029:	8b 00                	mov    (%eax),%eax
f010502b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010502e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105031:	eb 27                	jmp    f010505a <vprintfmt+0xdf>
f0105033:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105036:	85 c0                	test   %eax,%eax
f0105038:	b9 00 00 00 00       	mov    $0x0,%ecx
f010503d:	0f 49 c8             	cmovns %eax,%ecx
f0105040:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105043:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105046:	eb 8c                	jmp    f0104fd4 <vprintfmt+0x59>
f0105048:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010504b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105052:	eb 80                	jmp    f0104fd4 <vprintfmt+0x59>
f0105054:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105057:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010505a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010505e:	0f 89 70 ff ff ff    	jns    f0104fd4 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105064:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105067:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010506a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105071:	e9 5e ff ff ff       	jmp    f0104fd4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105076:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105079:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010507c:	e9 53 ff ff ff       	jmp    f0104fd4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105081:	8b 45 14             	mov    0x14(%ebp),%eax
f0105084:	8d 50 04             	lea    0x4(%eax),%edx
f0105087:	89 55 14             	mov    %edx,0x14(%ebp)
f010508a:	83 ec 08             	sub    $0x8,%esp
f010508d:	53                   	push   %ebx
f010508e:	ff 30                	pushl  (%eax)
f0105090:	ff d6                	call   *%esi
			break;
f0105092:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105095:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105098:	e9 04 ff ff ff       	jmp    f0104fa1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010509d:	8b 45 14             	mov    0x14(%ebp),%eax
f01050a0:	8d 50 04             	lea    0x4(%eax),%edx
f01050a3:	89 55 14             	mov    %edx,0x14(%ebp)
f01050a6:	8b 00                	mov    (%eax),%eax
f01050a8:	99                   	cltd   
f01050a9:	31 d0                	xor    %edx,%eax
f01050ab:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01050ad:	83 f8 0f             	cmp    $0xf,%eax
f01050b0:	7f 0b                	jg     f01050bd <vprintfmt+0x142>
f01050b2:	8b 14 85 e0 7d 10 f0 	mov    -0xfef8220(,%eax,4),%edx
f01050b9:	85 d2                	test   %edx,%edx
f01050bb:	75 18                	jne    f01050d5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01050bd:	50                   	push   %eax
f01050be:	68 4a 7b 10 f0       	push   $0xf0107b4a
f01050c3:	53                   	push   %ebx
f01050c4:	56                   	push   %esi
f01050c5:	e8 94 fe ff ff       	call   f0104f5e <printfmt>
f01050ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01050d0:	e9 cc fe ff ff       	jmp    f0104fa1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01050d5:	52                   	push   %edx
f01050d6:	68 aa 68 10 f0       	push   $0xf01068aa
f01050db:	53                   	push   %ebx
f01050dc:	56                   	push   %esi
f01050dd:	e8 7c fe ff ff       	call   f0104f5e <printfmt>
f01050e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050e8:	e9 b4 fe ff ff       	jmp    f0104fa1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01050ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01050f0:	8d 50 04             	lea    0x4(%eax),%edx
f01050f3:	89 55 14             	mov    %edx,0x14(%ebp)
f01050f6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01050f8:	85 ff                	test   %edi,%edi
f01050fa:	b8 43 7b 10 f0       	mov    $0xf0107b43,%eax
f01050ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105102:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105106:	0f 8e 94 00 00 00    	jle    f01051a0 <vprintfmt+0x225>
f010510c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105110:	0f 84 98 00 00 00    	je     f01051ae <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105116:	83 ec 08             	sub    $0x8,%esp
f0105119:	ff 75 d0             	pushl  -0x30(%ebp)
f010511c:	57                   	push   %edi
f010511d:	e8 77 03 00 00       	call   f0105499 <strnlen>
f0105122:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105125:	29 c1                	sub    %eax,%ecx
f0105127:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010512a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010512d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105131:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105134:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105137:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105139:	eb 0f                	jmp    f010514a <vprintfmt+0x1cf>
					putch(padc, putdat);
f010513b:	83 ec 08             	sub    $0x8,%esp
f010513e:	53                   	push   %ebx
f010513f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105142:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105144:	83 ef 01             	sub    $0x1,%edi
f0105147:	83 c4 10             	add    $0x10,%esp
f010514a:	85 ff                	test   %edi,%edi
f010514c:	7f ed                	jg     f010513b <vprintfmt+0x1c0>
f010514e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105151:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105154:	85 c9                	test   %ecx,%ecx
f0105156:	b8 00 00 00 00       	mov    $0x0,%eax
f010515b:	0f 49 c1             	cmovns %ecx,%eax
f010515e:	29 c1                	sub    %eax,%ecx
f0105160:	89 75 08             	mov    %esi,0x8(%ebp)
f0105163:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105166:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105169:	89 cb                	mov    %ecx,%ebx
f010516b:	eb 4d                	jmp    f01051ba <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010516d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105171:	74 1b                	je     f010518e <vprintfmt+0x213>
f0105173:	0f be c0             	movsbl %al,%eax
f0105176:	83 e8 20             	sub    $0x20,%eax
f0105179:	83 f8 5e             	cmp    $0x5e,%eax
f010517c:	76 10                	jbe    f010518e <vprintfmt+0x213>
					putch('?', putdat);
f010517e:	83 ec 08             	sub    $0x8,%esp
f0105181:	ff 75 0c             	pushl  0xc(%ebp)
f0105184:	6a 3f                	push   $0x3f
f0105186:	ff 55 08             	call   *0x8(%ebp)
f0105189:	83 c4 10             	add    $0x10,%esp
f010518c:	eb 0d                	jmp    f010519b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010518e:	83 ec 08             	sub    $0x8,%esp
f0105191:	ff 75 0c             	pushl  0xc(%ebp)
f0105194:	52                   	push   %edx
f0105195:	ff 55 08             	call   *0x8(%ebp)
f0105198:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010519b:	83 eb 01             	sub    $0x1,%ebx
f010519e:	eb 1a                	jmp    f01051ba <vprintfmt+0x23f>
f01051a0:	89 75 08             	mov    %esi,0x8(%ebp)
f01051a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01051a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01051a9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01051ac:	eb 0c                	jmp    f01051ba <vprintfmt+0x23f>
f01051ae:	89 75 08             	mov    %esi,0x8(%ebp)
f01051b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01051b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01051b7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01051ba:	83 c7 01             	add    $0x1,%edi
f01051bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01051c1:	0f be d0             	movsbl %al,%edx
f01051c4:	85 d2                	test   %edx,%edx
f01051c6:	74 23                	je     f01051eb <vprintfmt+0x270>
f01051c8:	85 f6                	test   %esi,%esi
f01051ca:	78 a1                	js     f010516d <vprintfmt+0x1f2>
f01051cc:	83 ee 01             	sub    $0x1,%esi
f01051cf:	79 9c                	jns    f010516d <vprintfmt+0x1f2>
f01051d1:	89 df                	mov    %ebx,%edi
f01051d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01051d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051d9:	eb 18                	jmp    f01051f3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01051db:	83 ec 08             	sub    $0x8,%esp
f01051de:	53                   	push   %ebx
f01051df:	6a 20                	push   $0x20
f01051e1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01051e3:	83 ef 01             	sub    $0x1,%edi
f01051e6:	83 c4 10             	add    $0x10,%esp
f01051e9:	eb 08                	jmp    f01051f3 <vprintfmt+0x278>
f01051eb:	89 df                	mov    %ebx,%edi
f01051ed:	8b 75 08             	mov    0x8(%ebp),%esi
f01051f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051f3:	85 ff                	test   %edi,%edi
f01051f5:	7f e4                	jg     f01051db <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051fa:	e9 a2 fd ff ff       	jmp    f0104fa1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051ff:	83 fa 01             	cmp    $0x1,%edx
f0105202:	7e 16                	jle    f010521a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105204:	8b 45 14             	mov    0x14(%ebp),%eax
f0105207:	8d 50 08             	lea    0x8(%eax),%edx
f010520a:	89 55 14             	mov    %edx,0x14(%ebp)
f010520d:	8b 50 04             	mov    0x4(%eax),%edx
f0105210:	8b 00                	mov    (%eax),%eax
f0105212:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105215:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105218:	eb 32                	jmp    f010524c <vprintfmt+0x2d1>
	else if (lflag)
f010521a:	85 d2                	test   %edx,%edx
f010521c:	74 18                	je     f0105236 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010521e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105221:	8d 50 04             	lea    0x4(%eax),%edx
f0105224:	89 55 14             	mov    %edx,0x14(%ebp)
f0105227:	8b 00                	mov    (%eax),%eax
f0105229:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010522c:	89 c1                	mov    %eax,%ecx
f010522e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105231:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105234:	eb 16                	jmp    f010524c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105236:	8b 45 14             	mov    0x14(%ebp),%eax
f0105239:	8d 50 04             	lea    0x4(%eax),%edx
f010523c:	89 55 14             	mov    %edx,0x14(%ebp)
f010523f:	8b 00                	mov    (%eax),%eax
f0105241:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105244:	89 c1                	mov    %eax,%ecx
f0105246:	c1 f9 1f             	sar    $0x1f,%ecx
f0105249:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010524c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010524f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105252:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105257:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010525b:	79 74                	jns    f01052d1 <vprintfmt+0x356>
				putch('-', putdat);
f010525d:	83 ec 08             	sub    $0x8,%esp
f0105260:	53                   	push   %ebx
f0105261:	6a 2d                	push   $0x2d
f0105263:	ff d6                	call   *%esi
				num = -(long long) num;
f0105265:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105268:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010526b:	f7 d8                	neg    %eax
f010526d:	83 d2 00             	adc    $0x0,%edx
f0105270:	f7 da                	neg    %edx
f0105272:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105275:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010527a:	eb 55                	jmp    f01052d1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010527c:	8d 45 14             	lea    0x14(%ebp),%eax
f010527f:	e8 83 fc ff ff       	call   f0104f07 <getuint>
			base = 10;
f0105284:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105289:	eb 46                	jmp    f01052d1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f010528b:	8d 45 14             	lea    0x14(%ebp),%eax
f010528e:	e8 74 fc ff ff       	call   f0104f07 <getuint>
			base = 8;
f0105293:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105298:	eb 37                	jmp    f01052d1 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
f010529a:	83 ec 08             	sub    $0x8,%esp
f010529d:	53                   	push   %ebx
f010529e:	6a 30                	push   $0x30
f01052a0:	ff d6                	call   *%esi
			putch('x', putdat);
f01052a2:	83 c4 08             	add    $0x8,%esp
f01052a5:	53                   	push   %ebx
f01052a6:	6a 78                	push   $0x78
f01052a8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01052aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01052ad:	8d 50 04             	lea    0x4(%eax),%edx
f01052b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01052b3:	8b 00                	mov    (%eax),%eax
f01052b5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01052ba:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01052bd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01052c2:	eb 0d                	jmp    f01052d1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01052c4:	8d 45 14             	lea    0x14(%ebp),%eax
f01052c7:	e8 3b fc ff ff       	call   f0104f07 <getuint>
			base = 16;
f01052cc:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01052d1:	83 ec 0c             	sub    $0xc,%esp
f01052d4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01052d8:	57                   	push   %edi
f01052d9:	ff 75 e0             	pushl  -0x20(%ebp)
f01052dc:	51                   	push   %ecx
f01052dd:	52                   	push   %edx
f01052de:	50                   	push   %eax
f01052df:	89 da                	mov    %ebx,%edx
f01052e1:	89 f0                	mov    %esi,%eax
f01052e3:	e8 70 fb ff ff       	call   f0104e58 <printnum>
			break;
f01052e8:	83 c4 20             	add    $0x20,%esp
f01052eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052ee:	e9 ae fc ff ff       	jmp    f0104fa1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01052f3:	83 ec 08             	sub    $0x8,%esp
f01052f6:	53                   	push   %ebx
f01052f7:	51                   	push   %ecx
f01052f8:	ff d6                	call   *%esi
			break;
f01052fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105300:	e9 9c fc ff ff       	jmp    f0104fa1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105305:	83 ec 08             	sub    $0x8,%esp
f0105308:	53                   	push   %ebx
f0105309:	6a 25                	push   $0x25
f010530b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010530d:	83 c4 10             	add    $0x10,%esp
f0105310:	eb 03                	jmp    f0105315 <vprintfmt+0x39a>
f0105312:	83 ef 01             	sub    $0x1,%edi
f0105315:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105319:	75 f7                	jne    f0105312 <vprintfmt+0x397>
f010531b:	e9 81 fc ff ff       	jmp    f0104fa1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105320:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105323:	5b                   	pop    %ebx
f0105324:	5e                   	pop    %esi
f0105325:	5f                   	pop    %edi
f0105326:	5d                   	pop    %ebp
f0105327:	c3                   	ret    

f0105328 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105328:	55                   	push   %ebp
f0105329:	89 e5                	mov    %esp,%ebp
f010532b:	83 ec 18             	sub    $0x18,%esp
f010532e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105331:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105334:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105337:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010533b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010533e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105345:	85 c0                	test   %eax,%eax
f0105347:	74 26                	je     f010536f <vsnprintf+0x47>
f0105349:	85 d2                	test   %edx,%edx
f010534b:	7e 22                	jle    f010536f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010534d:	ff 75 14             	pushl  0x14(%ebp)
f0105350:	ff 75 10             	pushl  0x10(%ebp)
f0105353:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105356:	50                   	push   %eax
f0105357:	68 41 4f 10 f0       	push   $0xf0104f41
f010535c:	e8 1a fc ff ff       	call   f0104f7b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105361:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105364:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105367:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010536a:	83 c4 10             	add    $0x10,%esp
f010536d:	eb 05                	jmp    f0105374 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010536f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105374:	c9                   	leave  
f0105375:	c3                   	ret    

f0105376 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105376:	55                   	push   %ebp
f0105377:	89 e5                	mov    %esp,%ebp
f0105379:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010537c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010537f:	50                   	push   %eax
f0105380:	ff 75 10             	pushl  0x10(%ebp)
f0105383:	ff 75 0c             	pushl  0xc(%ebp)
f0105386:	ff 75 08             	pushl  0x8(%ebp)
f0105389:	e8 9a ff ff ff       	call   f0105328 <vsnprintf>
	va_end(ap);

	return rc;
}
f010538e:	c9                   	leave  
f010538f:	c3                   	ret    

f0105390 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105390:	55                   	push   %ebp
f0105391:	89 e5                	mov    %esp,%ebp
f0105393:	57                   	push   %edi
f0105394:	56                   	push   %esi
f0105395:	53                   	push   %ebx
f0105396:	83 ec 0c             	sub    $0xc,%esp
f0105399:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f010539c:	85 c0                	test   %eax,%eax
f010539e:	74 11                	je     f01053b1 <readline+0x21>
		cprintf("%s", prompt);
f01053a0:	83 ec 08             	sub    $0x8,%esp
f01053a3:	50                   	push   %eax
f01053a4:	68 aa 68 10 f0       	push   $0xf01068aa
f01053a9:	e8 76 e4 ff ff       	call   f0103824 <cprintf>
f01053ae:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01053b1:	83 ec 0c             	sub    $0xc,%esp
f01053b4:	6a 00                	push   $0x0
f01053b6:	e8 e8 b3 ff ff       	call   f01007a3 <iscons>
f01053bb:	89 c7                	mov    %eax,%edi
f01053bd:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01053c0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01053c5:	e8 c8 b3 ff ff       	call   f0100792 <getchar>
f01053ca:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01053cc:	85 c0                	test   %eax,%eax
f01053ce:	79 29                	jns    f01053f9 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01053d0:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01053d5:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01053d8:	0f 84 9b 00 00 00    	je     f0105479 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01053de:	83 ec 08             	sub    $0x8,%esp
f01053e1:	53                   	push   %ebx
f01053e2:	68 3f 7e 10 f0       	push   $0xf0107e3f
f01053e7:	e8 38 e4 ff ff       	call   f0103824 <cprintf>
f01053ec:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01053ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01053f4:	e9 80 00 00 00       	jmp    f0105479 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01053f9:	83 f8 08             	cmp    $0x8,%eax
f01053fc:	0f 94 c2             	sete   %dl
f01053ff:	83 f8 7f             	cmp    $0x7f,%eax
f0105402:	0f 94 c0             	sete   %al
f0105405:	08 c2                	or     %al,%dl
f0105407:	74 1a                	je     f0105423 <readline+0x93>
f0105409:	85 f6                	test   %esi,%esi
f010540b:	7e 16                	jle    f0105423 <readline+0x93>
			if (echoing)
f010540d:	85 ff                	test   %edi,%edi
f010540f:	74 0d                	je     f010541e <readline+0x8e>
				cputchar('\b');
f0105411:	83 ec 0c             	sub    $0xc,%esp
f0105414:	6a 08                	push   $0x8
f0105416:	e8 67 b3 ff ff       	call   f0100782 <cputchar>
f010541b:	83 c4 10             	add    $0x10,%esp
			i--;
f010541e:	83 ee 01             	sub    $0x1,%esi
f0105421:	eb a2                	jmp    f01053c5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105423:	83 fb 1f             	cmp    $0x1f,%ebx
f0105426:	7e 26                	jle    f010544e <readline+0xbe>
f0105428:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010542e:	7f 1e                	jg     f010544e <readline+0xbe>
			if (echoing)
f0105430:	85 ff                	test   %edi,%edi
f0105432:	74 0c                	je     f0105440 <readline+0xb0>
				cputchar(c);
f0105434:	83 ec 0c             	sub    $0xc,%esp
f0105437:	53                   	push   %ebx
f0105438:	e8 45 b3 ff ff       	call   f0100782 <cputchar>
f010543d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105440:	88 9e 80 2a 21 f0    	mov    %bl,-0xfded580(%esi)
f0105446:	8d 76 01             	lea    0x1(%esi),%esi
f0105449:	e9 77 ff ff ff       	jmp    f01053c5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010544e:	83 fb 0a             	cmp    $0xa,%ebx
f0105451:	74 09                	je     f010545c <readline+0xcc>
f0105453:	83 fb 0d             	cmp    $0xd,%ebx
f0105456:	0f 85 69 ff ff ff    	jne    f01053c5 <readline+0x35>
			if (echoing)
f010545c:	85 ff                	test   %edi,%edi
f010545e:	74 0d                	je     f010546d <readline+0xdd>
				cputchar('\n');
f0105460:	83 ec 0c             	sub    $0xc,%esp
f0105463:	6a 0a                	push   $0xa
f0105465:	e8 18 b3 ff ff       	call   f0100782 <cputchar>
f010546a:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010546d:	c6 86 80 2a 21 f0 00 	movb   $0x0,-0xfded580(%esi)
			return buf;
f0105474:	b8 80 2a 21 f0       	mov    $0xf0212a80,%eax
		}
	}
}
f0105479:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010547c:	5b                   	pop    %ebx
f010547d:	5e                   	pop    %esi
f010547e:	5f                   	pop    %edi
f010547f:	5d                   	pop    %ebp
f0105480:	c3                   	ret    

f0105481 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105481:	55                   	push   %ebp
f0105482:	89 e5                	mov    %esp,%ebp
f0105484:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105487:	b8 00 00 00 00       	mov    $0x0,%eax
f010548c:	eb 03                	jmp    f0105491 <strlen+0x10>
		n++;
f010548e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105491:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105495:	75 f7                	jne    f010548e <strlen+0xd>
		n++;
	return n;
}
f0105497:	5d                   	pop    %ebp
f0105498:	c3                   	ret    

f0105499 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105499:	55                   	push   %ebp
f010549a:	89 e5                	mov    %esp,%ebp
f010549c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010549f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054a2:	ba 00 00 00 00       	mov    $0x0,%edx
f01054a7:	eb 03                	jmp    f01054ac <strnlen+0x13>
		n++;
f01054a9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054ac:	39 c2                	cmp    %eax,%edx
f01054ae:	74 08                	je     f01054b8 <strnlen+0x1f>
f01054b0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01054b4:	75 f3                	jne    f01054a9 <strnlen+0x10>
f01054b6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01054b8:	5d                   	pop    %ebp
f01054b9:	c3                   	ret    

f01054ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01054ba:	55                   	push   %ebp
f01054bb:	89 e5                	mov    %esp,%ebp
f01054bd:	53                   	push   %ebx
f01054be:	8b 45 08             	mov    0x8(%ebp),%eax
f01054c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01054c4:	89 c2                	mov    %eax,%edx
f01054c6:	83 c2 01             	add    $0x1,%edx
f01054c9:	83 c1 01             	add    $0x1,%ecx
f01054cc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01054d0:	88 5a ff             	mov    %bl,-0x1(%edx)
f01054d3:	84 db                	test   %bl,%bl
f01054d5:	75 ef                	jne    f01054c6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01054d7:	5b                   	pop    %ebx
f01054d8:	5d                   	pop    %ebp
f01054d9:	c3                   	ret    

f01054da <strcat>:

char *
strcat(char *dst, const char *src)
{
f01054da:	55                   	push   %ebp
f01054db:	89 e5                	mov    %esp,%ebp
f01054dd:	53                   	push   %ebx
f01054de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054e1:	53                   	push   %ebx
f01054e2:	e8 9a ff ff ff       	call   f0105481 <strlen>
f01054e7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01054ea:	ff 75 0c             	pushl  0xc(%ebp)
f01054ed:	01 d8                	add    %ebx,%eax
f01054ef:	50                   	push   %eax
f01054f0:	e8 c5 ff ff ff       	call   f01054ba <strcpy>
	return dst;
}
f01054f5:	89 d8                	mov    %ebx,%eax
f01054f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01054fa:	c9                   	leave  
f01054fb:	c3                   	ret    

f01054fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01054fc:	55                   	push   %ebp
f01054fd:	89 e5                	mov    %esp,%ebp
f01054ff:	56                   	push   %esi
f0105500:	53                   	push   %ebx
f0105501:	8b 75 08             	mov    0x8(%ebp),%esi
f0105504:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105507:	89 f3                	mov    %esi,%ebx
f0105509:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010550c:	89 f2                	mov    %esi,%edx
f010550e:	eb 0f                	jmp    f010551f <strncpy+0x23>
		*dst++ = *src;
f0105510:	83 c2 01             	add    $0x1,%edx
f0105513:	0f b6 01             	movzbl (%ecx),%eax
f0105516:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105519:	80 39 01             	cmpb   $0x1,(%ecx)
f010551c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010551f:	39 da                	cmp    %ebx,%edx
f0105521:	75 ed                	jne    f0105510 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105523:	89 f0                	mov    %esi,%eax
f0105525:	5b                   	pop    %ebx
f0105526:	5e                   	pop    %esi
f0105527:	5d                   	pop    %ebp
f0105528:	c3                   	ret    

f0105529 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105529:	55                   	push   %ebp
f010552a:	89 e5                	mov    %esp,%ebp
f010552c:	56                   	push   %esi
f010552d:	53                   	push   %ebx
f010552e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105534:	8b 55 10             	mov    0x10(%ebp),%edx
f0105537:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105539:	85 d2                	test   %edx,%edx
f010553b:	74 21                	je     f010555e <strlcpy+0x35>
f010553d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105541:	89 f2                	mov    %esi,%edx
f0105543:	eb 09                	jmp    f010554e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105545:	83 c2 01             	add    $0x1,%edx
f0105548:	83 c1 01             	add    $0x1,%ecx
f010554b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010554e:	39 c2                	cmp    %eax,%edx
f0105550:	74 09                	je     f010555b <strlcpy+0x32>
f0105552:	0f b6 19             	movzbl (%ecx),%ebx
f0105555:	84 db                	test   %bl,%bl
f0105557:	75 ec                	jne    f0105545 <strlcpy+0x1c>
f0105559:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010555b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010555e:	29 f0                	sub    %esi,%eax
}
f0105560:	5b                   	pop    %ebx
f0105561:	5e                   	pop    %esi
f0105562:	5d                   	pop    %ebp
f0105563:	c3                   	ret    

f0105564 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105564:	55                   	push   %ebp
f0105565:	89 e5                	mov    %esp,%ebp
f0105567:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010556a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010556d:	eb 06                	jmp    f0105575 <strcmp+0x11>
		p++, q++;
f010556f:	83 c1 01             	add    $0x1,%ecx
f0105572:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105575:	0f b6 01             	movzbl (%ecx),%eax
f0105578:	84 c0                	test   %al,%al
f010557a:	74 04                	je     f0105580 <strcmp+0x1c>
f010557c:	3a 02                	cmp    (%edx),%al
f010557e:	74 ef                	je     f010556f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105580:	0f b6 c0             	movzbl %al,%eax
f0105583:	0f b6 12             	movzbl (%edx),%edx
f0105586:	29 d0                	sub    %edx,%eax
}
f0105588:	5d                   	pop    %ebp
f0105589:	c3                   	ret    

f010558a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010558a:	55                   	push   %ebp
f010558b:	89 e5                	mov    %esp,%ebp
f010558d:	53                   	push   %ebx
f010558e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105591:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105594:	89 c3                	mov    %eax,%ebx
f0105596:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105599:	eb 06                	jmp    f01055a1 <strncmp+0x17>
		n--, p++, q++;
f010559b:	83 c0 01             	add    $0x1,%eax
f010559e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01055a1:	39 d8                	cmp    %ebx,%eax
f01055a3:	74 15                	je     f01055ba <strncmp+0x30>
f01055a5:	0f b6 08             	movzbl (%eax),%ecx
f01055a8:	84 c9                	test   %cl,%cl
f01055aa:	74 04                	je     f01055b0 <strncmp+0x26>
f01055ac:	3a 0a                	cmp    (%edx),%cl
f01055ae:	74 eb                	je     f010559b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01055b0:	0f b6 00             	movzbl (%eax),%eax
f01055b3:	0f b6 12             	movzbl (%edx),%edx
f01055b6:	29 d0                	sub    %edx,%eax
f01055b8:	eb 05                	jmp    f01055bf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01055ba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01055bf:	5b                   	pop    %ebx
f01055c0:	5d                   	pop    %ebp
f01055c1:	c3                   	ret    

f01055c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01055c2:	55                   	push   %ebp
f01055c3:	89 e5                	mov    %esp,%ebp
f01055c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01055c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055cc:	eb 07                	jmp    f01055d5 <strchr+0x13>
		if (*s == c)
f01055ce:	38 ca                	cmp    %cl,%dl
f01055d0:	74 0f                	je     f01055e1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01055d2:	83 c0 01             	add    $0x1,%eax
f01055d5:	0f b6 10             	movzbl (%eax),%edx
f01055d8:	84 d2                	test   %dl,%dl
f01055da:	75 f2                	jne    f01055ce <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01055dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055e1:	5d                   	pop    %ebp
f01055e2:	c3                   	ret    

f01055e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055e3:	55                   	push   %ebp
f01055e4:	89 e5                	mov    %esp,%ebp
f01055e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01055e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055ed:	eb 03                	jmp    f01055f2 <strfind+0xf>
f01055ef:	83 c0 01             	add    $0x1,%eax
f01055f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01055f5:	38 ca                	cmp    %cl,%dl
f01055f7:	74 04                	je     f01055fd <strfind+0x1a>
f01055f9:	84 d2                	test   %dl,%dl
f01055fb:	75 f2                	jne    f01055ef <strfind+0xc>
			break;
	return (char *) s;
}
f01055fd:	5d                   	pop    %ebp
f01055fe:	c3                   	ret    

f01055ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01055ff:	55                   	push   %ebp
f0105600:	89 e5                	mov    %esp,%ebp
f0105602:	57                   	push   %edi
f0105603:	56                   	push   %esi
f0105604:	53                   	push   %ebx
f0105605:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105608:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010560b:	85 c9                	test   %ecx,%ecx
f010560d:	74 36                	je     f0105645 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010560f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105615:	75 28                	jne    f010563f <memset+0x40>
f0105617:	f6 c1 03             	test   $0x3,%cl
f010561a:	75 23                	jne    f010563f <memset+0x40>
		c &= 0xFF;
f010561c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105620:	89 d3                	mov    %edx,%ebx
f0105622:	c1 e3 08             	shl    $0x8,%ebx
f0105625:	89 d6                	mov    %edx,%esi
f0105627:	c1 e6 18             	shl    $0x18,%esi
f010562a:	89 d0                	mov    %edx,%eax
f010562c:	c1 e0 10             	shl    $0x10,%eax
f010562f:	09 f0                	or     %esi,%eax
f0105631:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105633:	89 d8                	mov    %ebx,%eax
f0105635:	09 d0                	or     %edx,%eax
f0105637:	c1 e9 02             	shr    $0x2,%ecx
f010563a:	fc                   	cld    
f010563b:	f3 ab                	rep stos %eax,%es:(%edi)
f010563d:	eb 06                	jmp    f0105645 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010563f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105642:	fc                   	cld    
f0105643:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105645:	89 f8                	mov    %edi,%eax
f0105647:	5b                   	pop    %ebx
f0105648:	5e                   	pop    %esi
f0105649:	5f                   	pop    %edi
f010564a:	5d                   	pop    %ebp
f010564b:	c3                   	ret    

f010564c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010564c:	55                   	push   %ebp
f010564d:	89 e5                	mov    %esp,%ebp
f010564f:	57                   	push   %edi
f0105650:	56                   	push   %esi
f0105651:	8b 45 08             	mov    0x8(%ebp),%eax
f0105654:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105657:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010565a:	39 c6                	cmp    %eax,%esi
f010565c:	73 35                	jae    f0105693 <memmove+0x47>
f010565e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105661:	39 d0                	cmp    %edx,%eax
f0105663:	73 2e                	jae    f0105693 <memmove+0x47>
		s += n;
		d += n;
f0105665:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105668:	89 d6                	mov    %edx,%esi
f010566a:	09 fe                	or     %edi,%esi
f010566c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105672:	75 13                	jne    f0105687 <memmove+0x3b>
f0105674:	f6 c1 03             	test   $0x3,%cl
f0105677:	75 0e                	jne    f0105687 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105679:	83 ef 04             	sub    $0x4,%edi
f010567c:	8d 72 fc             	lea    -0x4(%edx),%esi
f010567f:	c1 e9 02             	shr    $0x2,%ecx
f0105682:	fd                   	std    
f0105683:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105685:	eb 09                	jmp    f0105690 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105687:	83 ef 01             	sub    $0x1,%edi
f010568a:	8d 72 ff             	lea    -0x1(%edx),%esi
f010568d:	fd                   	std    
f010568e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105690:	fc                   	cld    
f0105691:	eb 1d                	jmp    f01056b0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105693:	89 f2                	mov    %esi,%edx
f0105695:	09 c2                	or     %eax,%edx
f0105697:	f6 c2 03             	test   $0x3,%dl
f010569a:	75 0f                	jne    f01056ab <memmove+0x5f>
f010569c:	f6 c1 03             	test   $0x3,%cl
f010569f:	75 0a                	jne    f01056ab <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01056a1:	c1 e9 02             	shr    $0x2,%ecx
f01056a4:	89 c7                	mov    %eax,%edi
f01056a6:	fc                   	cld    
f01056a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01056a9:	eb 05                	jmp    f01056b0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01056ab:	89 c7                	mov    %eax,%edi
f01056ad:	fc                   	cld    
f01056ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01056b0:	5e                   	pop    %esi
f01056b1:	5f                   	pop    %edi
f01056b2:	5d                   	pop    %ebp
f01056b3:	c3                   	ret    

f01056b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01056b4:	55                   	push   %ebp
f01056b5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01056b7:	ff 75 10             	pushl  0x10(%ebp)
f01056ba:	ff 75 0c             	pushl  0xc(%ebp)
f01056bd:	ff 75 08             	pushl  0x8(%ebp)
f01056c0:	e8 87 ff ff ff       	call   f010564c <memmove>
}
f01056c5:	c9                   	leave  
f01056c6:	c3                   	ret    

f01056c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01056c7:	55                   	push   %ebp
f01056c8:	89 e5                	mov    %esp,%ebp
f01056ca:	56                   	push   %esi
f01056cb:	53                   	push   %ebx
f01056cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01056cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056d2:	89 c6                	mov    %eax,%esi
f01056d4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056d7:	eb 1a                	jmp    f01056f3 <memcmp+0x2c>
		if (*s1 != *s2)
f01056d9:	0f b6 08             	movzbl (%eax),%ecx
f01056dc:	0f b6 1a             	movzbl (%edx),%ebx
f01056df:	38 d9                	cmp    %bl,%cl
f01056e1:	74 0a                	je     f01056ed <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01056e3:	0f b6 c1             	movzbl %cl,%eax
f01056e6:	0f b6 db             	movzbl %bl,%ebx
f01056e9:	29 d8                	sub    %ebx,%eax
f01056eb:	eb 0f                	jmp    f01056fc <memcmp+0x35>
		s1++, s2++;
f01056ed:	83 c0 01             	add    $0x1,%eax
f01056f0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056f3:	39 f0                	cmp    %esi,%eax
f01056f5:	75 e2                	jne    f01056d9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01056f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056fc:	5b                   	pop    %ebx
f01056fd:	5e                   	pop    %esi
f01056fe:	5d                   	pop    %ebp
f01056ff:	c3                   	ret    

f0105700 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105700:	55                   	push   %ebp
f0105701:	89 e5                	mov    %esp,%ebp
f0105703:	53                   	push   %ebx
f0105704:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105707:	89 c1                	mov    %eax,%ecx
f0105709:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010570c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105710:	eb 0a                	jmp    f010571c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105712:	0f b6 10             	movzbl (%eax),%edx
f0105715:	39 da                	cmp    %ebx,%edx
f0105717:	74 07                	je     f0105720 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105719:	83 c0 01             	add    $0x1,%eax
f010571c:	39 c8                	cmp    %ecx,%eax
f010571e:	72 f2                	jb     f0105712 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105720:	5b                   	pop    %ebx
f0105721:	5d                   	pop    %ebp
f0105722:	c3                   	ret    

f0105723 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105723:	55                   	push   %ebp
f0105724:	89 e5                	mov    %esp,%ebp
f0105726:	57                   	push   %edi
f0105727:	56                   	push   %esi
f0105728:	53                   	push   %ebx
f0105729:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010572c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010572f:	eb 03                	jmp    f0105734 <strtol+0x11>
		s++;
f0105731:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105734:	0f b6 01             	movzbl (%ecx),%eax
f0105737:	3c 20                	cmp    $0x20,%al
f0105739:	74 f6                	je     f0105731 <strtol+0xe>
f010573b:	3c 09                	cmp    $0x9,%al
f010573d:	74 f2                	je     f0105731 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010573f:	3c 2b                	cmp    $0x2b,%al
f0105741:	75 0a                	jne    f010574d <strtol+0x2a>
		s++;
f0105743:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105746:	bf 00 00 00 00       	mov    $0x0,%edi
f010574b:	eb 11                	jmp    f010575e <strtol+0x3b>
f010574d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105752:	3c 2d                	cmp    $0x2d,%al
f0105754:	75 08                	jne    f010575e <strtol+0x3b>
		s++, neg = 1;
f0105756:	83 c1 01             	add    $0x1,%ecx
f0105759:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010575e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105764:	75 15                	jne    f010577b <strtol+0x58>
f0105766:	80 39 30             	cmpb   $0x30,(%ecx)
f0105769:	75 10                	jne    f010577b <strtol+0x58>
f010576b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010576f:	75 7c                	jne    f01057ed <strtol+0xca>
		s += 2, base = 16;
f0105771:	83 c1 02             	add    $0x2,%ecx
f0105774:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105779:	eb 16                	jmp    f0105791 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010577b:	85 db                	test   %ebx,%ebx
f010577d:	75 12                	jne    f0105791 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010577f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105784:	80 39 30             	cmpb   $0x30,(%ecx)
f0105787:	75 08                	jne    f0105791 <strtol+0x6e>
		s++, base = 8;
f0105789:	83 c1 01             	add    $0x1,%ecx
f010578c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105791:	b8 00 00 00 00       	mov    $0x0,%eax
f0105796:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105799:	0f b6 11             	movzbl (%ecx),%edx
f010579c:	8d 72 d0             	lea    -0x30(%edx),%esi
f010579f:	89 f3                	mov    %esi,%ebx
f01057a1:	80 fb 09             	cmp    $0x9,%bl
f01057a4:	77 08                	ja     f01057ae <strtol+0x8b>
			dig = *s - '0';
f01057a6:	0f be d2             	movsbl %dl,%edx
f01057a9:	83 ea 30             	sub    $0x30,%edx
f01057ac:	eb 22                	jmp    f01057d0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01057ae:	8d 72 9f             	lea    -0x61(%edx),%esi
f01057b1:	89 f3                	mov    %esi,%ebx
f01057b3:	80 fb 19             	cmp    $0x19,%bl
f01057b6:	77 08                	ja     f01057c0 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01057b8:	0f be d2             	movsbl %dl,%edx
f01057bb:	83 ea 57             	sub    $0x57,%edx
f01057be:	eb 10                	jmp    f01057d0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01057c0:	8d 72 bf             	lea    -0x41(%edx),%esi
f01057c3:	89 f3                	mov    %esi,%ebx
f01057c5:	80 fb 19             	cmp    $0x19,%bl
f01057c8:	77 16                	ja     f01057e0 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01057ca:	0f be d2             	movsbl %dl,%edx
f01057cd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01057d0:	3b 55 10             	cmp    0x10(%ebp),%edx
f01057d3:	7d 0b                	jge    f01057e0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01057d5:	83 c1 01             	add    $0x1,%ecx
f01057d8:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057dc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01057de:	eb b9                	jmp    f0105799 <strtol+0x76>

	if (endptr)
f01057e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057e4:	74 0d                	je     f01057f3 <strtol+0xd0>
		*endptr = (char *) s;
f01057e6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057e9:	89 0e                	mov    %ecx,(%esi)
f01057eb:	eb 06                	jmp    f01057f3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01057ed:	85 db                	test   %ebx,%ebx
f01057ef:	74 98                	je     f0105789 <strtol+0x66>
f01057f1:	eb 9e                	jmp    f0105791 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01057f3:	89 c2                	mov    %eax,%edx
f01057f5:	f7 da                	neg    %edx
f01057f7:	85 ff                	test   %edi,%edi
f01057f9:	0f 45 c2             	cmovne %edx,%eax
}
f01057fc:	5b                   	pop    %ebx
f01057fd:	5e                   	pop    %esi
f01057fe:	5f                   	pop    %edi
f01057ff:	5d                   	pop    %ebp
f0105800:	c3                   	ret    
f0105801:	66 90                	xchg   %ax,%ax
f0105803:	90                   	nop

f0105804 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105804:	fa                   	cli    

	xorw    %ax, %ax
f0105805:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105807:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105809:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010580b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010580d:	0f 01 16             	lgdtl  (%esi)
f0105810:	74 70                	je     f0105882 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105812:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105815:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105819:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010581c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105822:	08 00                	or     %al,(%eax)

f0105824 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105824:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105828:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010582a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010582c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010582e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105832:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105834:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105836:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010583b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010583e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105841:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105846:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105849:	8b 25 84 2e 21 f0    	mov    0xf0212e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010584f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105854:	b8 b0 01 10 f0       	mov    $0xf01001b0,%eax
	call    *%eax
f0105859:	ff d0                	call   *%eax

f010585b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010585b:	eb fe                	jmp    f010585b <spin>
f010585d:	8d 76 00             	lea    0x0(%esi),%esi

f0105860 <gdt>:
	...
f0105868:	ff                   	(bad)  
f0105869:	ff 00                	incl   (%eax)
f010586b:	00 00                	add    %al,(%eax)
f010586d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105874:	00                   	.byte 0x0
f0105875:	92                   	xchg   %eax,%edx
f0105876:	cf                   	iret   
	...

f0105878 <gdtdesc>:
f0105878:	17                   	pop    %ss
f0105879:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010587e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010587e:	90                   	nop

f010587f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010587f:	55                   	push   %ebp
f0105880:	89 e5                	mov    %esp,%ebp
f0105882:	57                   	push   %edi
f0105883:	56                   	push   %esi
f0105884:	53                   	push   %ebx
f0105885:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105888:	8b 0d 88 2e 21 f0    	mov    0xf0212e88,%ecx
f010588e:	89 c3                	mov    %eax,%ebx
f0105890:	c1 eb 0c             	shr    $0xc,%ebx
f0105893:	39 cb                	cmp    %ecx,%ebx
f0105895:	72 12                	jb     f01058a9 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105897:	50                   	push   %eax
f0105898:	68 e4 62 10 f0       	push   $0xf01062e4
f010589d:	6a 57                	push   $0x57
f010589f:	68 dd 7f 10 f0       	push   $0xf0107fdd
f01058a4:	e8 97 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01058a9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01058af:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058b1:	89 c2                	mov    %eax,%edx
f01058b3:	c1 ea 0c             	shr    $0xc,%edx
f01058b6:	39 ca                	cmp    %ecx,%edx
f01058b8:	72 12                	jb     f01058cc <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058ba:	50                   	push   %eax
f01058bb:	68 e4 62 10 f0       	push   $0xf01062e4
f01058c0:	6a 57                	push   $0x57
f01058c2:	68 dd 7f 10 f0       	push   $0xf0107fdd
f01058c7:	e8 74 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01058cc:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01058d2:	eb 2f                	jmp    f0105903 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058d4:	83 ec 04             	sub    $0x4,%esp
f01058d7:	6a 04                	push   $0x4
f01058d9:	68 ed 7f 10 f0       	push   $0xf0107fed
f01058de:	53                   	push   %ebx
f01058df:	e8 e3 fd ff ff       	call   f01056c7 <memcmp>
f01058e4:	83 c4 10             	add    $0x10,%esp
f01058e7:	85 c0                	test   %eax,%eax
f01058e9:	75 15                	jne    f0105900 <mpsearch1+0x81>
f01058eb:	89 da                	mov    %ebx,%edx
f01058ed:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01058f0:	0f b6 0a             	movzbl (%edx),%ecx
f01058f3:	01 c8                	add    %ecx,%eax
f01058f5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058f8:	39 d7                	cmp    %edx,%edi
f01058fa:	75 f4                	jne    f01058f0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058fc:	84 c0                	test   %al,%al
f01058fe:	74 0e                	je     f010590e <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105900:	83 c3 10             	add    $0x10,%ebx
f0105903:	39 f3                	cmp    %esi,%ebx
f0105905:	72 cd                	jb     f01058d4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105907:	b8 00 00 00 00       	mov    $0x0,%eax
f010590c:	eb 02                	jmp    f0105910 <mpsearch1+0x91>
f010590e:	89 d8                	mov    %ebx,%eax
}
f0105910:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105913:	5b                   	pop    %ebx
f0105914:	5e                   	pop    %esi
f0105915:	5f                   	pop    %edi
f0105916:	5d                   	pop    %ebp
f0105917:	c3                   	ret    

f0105918 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105918:	55                   	push   %ebp
f0105919:	89 e5                	mov    %esp,%ebp
f010591b:	57                   	push   %edi
f010591c:	56                   	push   %esi
f010591d:	53                   	push   %ebx
f010591e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105921:	c7 05 c0 33 21 f0 20 	movl   $0xf0213020,0xf02133c0
f0105928:	30 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010592b:	83 3d 88 2e 21 f0 00 	cmpl   $0x0,0xf0212e88
f0105932:	75 16                	jne    f010594a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105934:	68 00 04 00 00       	push   $0x400
f0105939:	68 e4 62 10 f0       	push   $0xf01062e4
f010593e:	6a 6f                	push   $0x6f
f0105940:	68 dd 7f 10 f0       	push   $0xf0107fdd
f0105945:	e8 f6 a6 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010594a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105951:	85 c0                	test   %eax,%eax
f0105953:	74 16                	je     f010596b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105955:	c1 e0 04             	shl    $0x4,%eax
f0105958:	ba 00 04 00 00       	mov    $0x400,%edx
f010595d:	e8 1d ff ff ff       	call   f010587f <mpsearch1>
f0105962:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105965:	85 c0                	test   %eax,%eax
f0105967:	75 3c                	jne    f01059a5 <mp_init+0x8d>
f0105969:	eb 20                	jmp    f010598b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010596b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105972:	c1 e0 0a             	shl    $0xa,%eax
f0105975:	2d 00 04 00 00       	sub    $0x400,%eax
f010597a:	ba 00 04 00 00       	mov    $0x400,%edx
f010597f:	e8 fb fe ff ff       	call   f010587f <mpsearch1>
f0105984:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105987:	85 c0                	test   %eax,%eax
f0105989:	75 1a                	jne    f01059a5 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010598b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105990:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105995:	e8 e5 fe ff ff       	call   f010587f <mpsearch1>
f010599a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010599d:	85 c0                	test   %eax,%eax
f010599f:	0f 84 5d 02 00 00    	je     f0105c02 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01059a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059a8:	8b 70 04             	mov    0x4(%eax),%esi
f01059ab:	85 f6                	test   %esi,%esi
f01059ad:	74 06                	je     f01059b5 <mp_init+0x9d>
f01059af:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01059b3:	74 15                	je     f01059ca <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01059b5:	83 ec 0c             	sub    $0xc,%esp
f01059b8:	68 50 7e 10 f0       	push   $0xf0107e50
f01059bd:	e8 62 de ff ff       	call   f0103824 <cprintf>
f01059c2:	83 c4 10             	add    $0x10,%esp
f01059c5:	e9 38 02 00 00       	jmp    f0105c02 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059ca:	89 f0                	mov    %esi,%eax
f01059cc:	c1 e8 0c             	shr    $0xc,%eax
f01059cf:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f01059d5:	72 15                	jb     f01059ec <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059d7:	56                   	push   %esi
f01059d8:	68 e4 62 10 f0       	push   $0xf01062e4
f01059dd:	68 90 00 00 00       	push   $0x90
f01059e2:	68 dd 7f 10 f0       	push   $0xf0107fdd
f01059e7:	e8 54 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059ec:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059f2:	83 ec 04             	sub    $0x4,%esp
f01059f5:	6a 04                	push   $0x4
f01059f7:	68 f2 7f 10 f0       	push   $0xf0107ff2
f01059fc:	53                   	push   %ebx
f01059fd:	e8 c5 fc ff ff       	call   f01056c7 <memcmp>
f0105a02:	83 c4 10             	add    $0x10,%esp
f0105a05:	85 c0                	test   %eax,%eax
f0105a07:	74 15                	je     f0105a1e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105a09:	83 ec 0c             	sub    $0xc,%esp
f0105a0c:	68 80 7e 10 f0       	push   $0xf0107e80
f0105a11:	e8 0e de ff ff       	call   f0103824 <cprintf>
f0105a16:	83 c4 10             	add    $0x10,%esp
f0105a19:	e9 e4 01 00 00       	jmp    f0105c02 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a1e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105a22:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105a26:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a29:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a33:	eb 0d                	jmp    f0105a42 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105a35:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105a3c:	f0 
f0105a3d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a3f:	83 c0 01             	add    $0x1,%eax
f0105a42:	39 c7                	cmp    %eax,%edi
f0105a44:	75 ef                	jne    f0105a35 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a46:	84 d2                	test   %dl,%dl
f0105a48:	74 15                	je     f0105a5f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a4a:	83 ec 0c             	sub    $0xc,%esp
f0105a4d:	68 b4 7e 10 f0       	push   $0xf0107eb4
f0105a52:	e8 cd dd ff ff       	call   f0103824 <cprintf>
f0105a57:	83 c4 10             	add    $0x10,%esp
f0105a5a:	e9 a3 01 00 00       	jmp    f0105c02 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105a5f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105a63:	3c 01                	cmp    $0x1,%al
f0105a65:	74 1d                	je     f0105a84 <mp_init+0x16c>
f0105a67:	3c 04                	cmp    $0x4,%al
f0105a69:	74 19                	je     f0105a84 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105a6b:	83 ec 08             	sub    $0x8,%esp
f0105a6e:	0f b6 c0             	movzbl %al,%eax
f0105a71:	50                   	push   %eax
f0105a72:	68 d8 7e 10 f0       	push   $0xf0107ed8
f0105a77:	e8 a8 dd ff ff       	call   f0103824 <cprintf>
f0105a7c:	83 c4 10             	add    $0x10,%esp
f0105a7f:	e9 7e 01 00 00       	jmp    f0105c02 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a84:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105a88:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a8c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a91:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105a96:	01 ce                	add    %ecx,%esi
f0105a98:	eb 0d                	jmp    f0105aa7 <mp_init+0x18f>
f0105a9a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105aa1:	f0 
f0105aa2:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105aa4:	83 c0 01             	add    $0x1,%eax
f0105aa7:	39 c7                	cmp    %eax,%edi
f0105aa9:	75 ef                	jne    f0105a9a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105aab:	89 d0                	mov    %edx,%eax
f0105aad:	02 43 2a             	add    0x2a(%ebx),%al
f0105ab0:	74 15                	je     f0105ac7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105ab2:	83 ec 0c             	sub    $0xc,%esp
f0105ab5:	68 f8 7e 10 f0       	push   $0xf0107ef8
f0105aba:	e8 65 dd ff ff       	call   f0103824 <cprintf>
f0105abf:	83 c4 10             	add    $0x10,%esp
f0105ac2:	e9 3b 01 00 00       	jmp    f0105c02 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105ac7:	85 db                	test   %ebx,%ebx
f0105ac9:	0f 84 33 01 00 00    	je     f0105c02 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105acf:	c7 05 00 30 21 f0 01 	movl   $0x1,0xf0213000
f0105ad6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105ad9:	8b 43 24             	mov    0x24(%ebx),%eax
f0105adc:	a3 00 40 25 f0       	mov    %eax,0xf0254000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ae1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105ae4:	be 00 00 00 00       	mov    $0x0,%esi
f0105ae9:	e9 85 00 00 00       	jmp    f0105b73 <mp_init+0x25b>
		switch (*p) {
f0105aee:	0f b6 07             	movzbl (%edi),%eax
f0105af1:	84 c0                	test   %al,%al
f0105af3:	74 06                	je     f0105afb <mp_init+0x1e3>
f0105af5:	3c 04                	cmp    $0x4,%al
f0105af7:	77 55                	ja     f0105b4e <mp_init+0x236>
f0105af9:	eb 4e                	jmp    f0105b49 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105afb:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105aff:	74 11                	je     f0105b12 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105b01:	6b 05 c4 33 21 f0 74 	imul   $0x74,0xf02133c4,%eax
f0105b08:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0105b0d:	a3 c0 33 21 f0       	mov    %eax,0xf02133c0
			if (ncpu < NCPU) {
f0105b12:	a1 c4 33 21 f0       	mov    0xf02133c4,%eax
f0105b17:	83 f8 07             	cmp    $0x7,%eax
f0105b1a:	7f 13                	jg     f0105b2f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105b1c:	6b d0 74             	imul   $0x74,%eax,%edx
f0105b1f:	88 82 20 30 21 f0    	mov    %al,-0xfdecfe0(%edx)
				ncpu++;
f0105b25:	83 c0 01             	add    $0x1,%eax
f0105b28:	a3 c4 33 21 f0       	mov    %eax,0xf02133c4
f0105b2d:	eb 15                	jmp    f0105b44 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105b2f:	83 ec 08             	sub    $0x8,%esp
f0105b32:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105b36:	50                   	push   %eax
f0105b37:	68 28 7f 10 f0       	push   $0xf0107f28
f0105b3c:	e8 e3 dc ff ff       	call   f0103824 <cprintf>
f0105b41:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b44:	83 c7 14             	add    $0x14,%edi
			continue;
f0105b47:	eb 27                	jmp    f0105b70 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b49:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b4c:	eb 22                	jmp    f0105b70 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b4e:	83 ec 08             	sub    $0x8,%esp
f0105b51:	0f b6 c0             	movzbl %al,%eax
f0105b54:	50                   	push   %eax
f0105b55:	68 50 7f 10 f0       	push   $0xf0107f50
f0105b5a:	e8 c5 dc ff ff       	call   f0103824 <cprintf>
			ismp = 0;
f0105b5f:	c7 05 00 30 21 f0 00 	movl   $0x0,0xf0213000
f0105b66:	00 00 00 
			i = conf->entry;
f0105b69:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105b6d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b70:	83 c6 01             	add    $0x1,%esi
f0105b73:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105b77:	39 c6                	cmp    %eax,%esi
f0105b79:	0f 82 6f ff ff ff    	jb     f0105aee <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b7f:	a1 c0 33 21 f0       	mov    0xf02133c0,%eax
f0105b84:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b8b:	83 3d 00 30 21 f0 00 	cmpl   $0x0,0xf0213000
f0105b92:	75 26                	jne    f0105bba <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b94:	c7 05 c4 33 21 f0 01 	movl   $0x1,0xf02133c4
f0105b9b:	00 00 00 
		lapicaddr = 0;
f0105b9e:	c7 05 00 40 25 f0 00 	movl   $0x0,0xf0254000
f0105ba5:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ba8:	83 ec 0c             	sub    $0xc,%esp
f0105bab:	68 70 7f 10 f0       	push   $0xf0107f70
f0105bb0:	e8 6f dc ff ff       	call   f0103824 <cprintf>
		return;
f0105bb5:	83 c4 10             	add    $0x10,%esp
f0105bb8:	eb 48                	jmp    f0105c02 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105bba:	83 ec 04             	sub    $0x4,%esp
f0105bbd:	ff 35 c4 33 21 f0    	pushl  0xf02133c4
f0105bc3:	0f b6 00             	movzbl (%eax),%eax
f0105bc6:	50                   	push   %eax
f0105bc7:	68 f7 7f 10 f0       	push   $0xf0107ff7
f0105bcc:	e8 53 dc ff ff       	call   f0103824 <cprintf>

	if (mp->imcrp) {
f0105bd1:	83 c4 10             	add    $0x10,%esp
f0105bd4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bd7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105bdb:	74 25                	je     f0105c02 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105bdd:	83 ec 0c             	sub    $0xc,%esp
f0105be0:	68 9c 7f 10 f0       	push   $0xf0107f9c
f0105be5:	e8 3a dc ff ff       	call   f0103824 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bea:	ba 22 00 00 00       	mov    $0x22,%edx
f0105bef:	b8 70 00 00 00       	mov    $0x70,%eax
f0105bf4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bf5:	ba 23 00 00 00       	mov    $0x23,%edx
f0105bfa:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bfb:	83 c8 01             	or     $0x1,%eax
f0105bfe:	ee                   	out    %al,(%dx)
f0105bff:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c05:	5b                   	pop    %ebx
f0105c06:	5e                   	pop    %esi
f0105c07:	5f                   	pop    %edi
f0105c08:	5d                   	pop    %ebp
f0105c09:	c3                   	ret    

f0105c0a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105c0a:	55                   	push   %ebp
f0105c0b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105c0d:	8b 0d 04 40 25 f0    	mov    0xf0254004,%ecx
f0105c13:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105c16:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105c18:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f0105c1d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105c20:	5d                   	pop    %ebp
f0105c21:	c3                   	ret    

f0105c22 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105c22:	55                   	push   %ebp
f0105c23:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105c25:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f0105c2a:	85 c0                	test   %eax,%eax
f0105c2c:	74 08                	je     f0105c36 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105c2e:	8b 40 20             	mov    0x20(%eax),%eax
f0105c31:	c1 e8 18             	shr    $0x18,%eax
f0105c34:	eb 05                	jmp    f0105c3b <cpunum+0x19>
	return 0;
f0105c36:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c3b:	5d                   	pop    %ebp
f0105c3c:	c3                   	ret    

f0105c3d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105c3d:	a1 00 40 25 f0       	mov    0xf0254000,%eax
f0105c42:	85 c0                	test   %eax,%eax
f0105c44:	0f 84 21 01 00 00    	je     f0105d6b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105c4a:	55                   	push   %ebp
f0105c4b:	89 e5                	mov    %esp,%ebp
f0105c4d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c50:	68 00 10 00 00       	push   $0x1000
f0105c55:	50                   	push   %eax
f0105c56:	e8 90 b7 ff ff       	call   f01013eb <mmio_map_region>
f0105c5b:	a3 04 40 25 f0       	mov    %eax,0xf0254004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c60:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c65:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c6a:	e8 9b ff ff ff       	call   f0105c0a <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105c6f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c74:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c79:	e8 8c ff ff ff       	call   f0105c0a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c7e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c83:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c88:	e8 7d ff ff ff       	call   f0105c0a <lapicw>
	lapicw(TICR, 10000000); 
f0105c8d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c92:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c97:	e8 6e ff ff ff       	call   f0105c0a <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105c9c:	e8 81 ff ff ff       	call   f0105c22 <cpunum>
f0105ca1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ca4:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0105ca9:	83 c4 10             	add    $0x10,%esp
f0105cac:	39 05 c0 33 21 f0    	cmp    %eax,0xf02133c0
f0105cb2:	74 0f                	je     f0105cc3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105cb4:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cb9:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105cbe:	e8 47 ff ff ff       	call   f0105c0a <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105cc3:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cc8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ccd:	e8 38 ff ff ff       	call   f0105c0a <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105cd2:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f0105cd7:	8b 40 30             	mov    0x30(%eax),%eax
f0105cda:	c1 e8 10             	shr    $0x10,%eax
f0105cdd:	3c 03                	cmp    $0x3,%al
f0105cdf:	76 0f                	jbe    f0105cf0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105ce1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ce6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105ceb:	e8 1a ff ff ff       	call   f0105c0a <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105cf0:	ba 33 00 00 00       	mov    $0x33,%edx
f0105cf5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105cfa:	e8 0b ff ff ff       	call   f0105c0a <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105cff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d04:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d09:	e8 fc fe ff ff       	call   f0105c0a <lapicw>
	lapicw(ESR, 0);
f0105d0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d13:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d18:	e8 ed fe ff ff       	call   f0105c0a <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105d1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d22:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d27:	e8 de fe ff ff       	call   f0105c0a <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105d2c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d31:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d36:	e8 cf fe ff ff       	call   f0105c0a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d3b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d40:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d45:	e8 c0 fe ff ff       	call   f0105c0a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d4a:	8b 15 04 40 25 f0    	mov    0xf0254004,%edx
f0105d50:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d56:	f6 c4 10             	test   $0x10,%ah
f0105d59:	75 f5                	jne    f0105d50 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105d5b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d60:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d65:	e8 a0 fe ff ff       	call   f0105c0a <lapicw>
}
f0105d6a:	c9                   	leave  
f0105d6b:	f3 c3                	repz ret 

f0105d6d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d6d:	83 3d 04 40 25 f0 00 	cmpl   $0x0,0xf0254004
f0105d74:	74 13                	je     f0105d89 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d76:	55                   	push   %ebp
f0105d77:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d79:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d7e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d83:	e8 82 fe ff ff       	call   f0105c0a <lapicw>
}
f0105d88:	5d                   	pop    %ebp
f0105d89:	f3 c3                	repz ret 

f0105d8b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d8b:	55                   	push   %ebp
f0105d8c:	89 e5                	mov    %esp,%ebp
f0105d8e:	56                   	push   %esi
f0105d8f:	53                   	push   %ebx
f0105d90:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d96:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d9b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105da0:	ee                   	out    %al,(%dx)
f0105da1:	ba 71 00 00 00       	mov    $0x71,%edx
f0105da6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105dab:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105dac:	83 3d 88 2e 21 f0 00 	cmpl   $0x0,0xf0212e88
f0105db3:	75 19                	jne    f0105dce <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105db5:	68 67 04 00 00       	push   $0x467
f0105dba:	68 e4 62 10 f0       	push   $0xf01062e4
f0105dbf:	68 98 00 00 00       	push   $0x98
f0105dc4:	68 14 80 10 f0       	push   $0xf0108014
f0105dc9:	e8 72 a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105dce:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105dd5:	00 00 
	wrv[1] = addr >> 4;
f0105dd7:	89 d8                	mov    %ebx,%eax
f0105dd9:	c1 e8 04             	shr    $0x4,%eax
f0105ddc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105de2:	c1 e6 18             	shl    $0x18,%esi
f0105de5:	89 f2                	mov    %esi,%edx
f0105de7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dec:	e8 19 fe ff ff       	call   f0105c0a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105df1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105df6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dfb:	e8 0a fe ff ff       	call   f0105c0a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105e00:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105e05:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e0a:	e8 fb fd ff ff       	call   f0105c0a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e0f:	c1 eb 0c             	shr    $0xc,%ebx
f0105e12:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105e15:	89 f2                	mov    %esi,%edx
f0105e17:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e1c:	e8 e9 fd ff ff       	call   f0105c0a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e21:	89 da                	mov    %ebx,%edx
f0105e23:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e28:	e8 dd fd ff ff       	call   f0105c0a <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105e2d:	89 f2                	mov    %esi,%edx
f0105e2f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e34:	e8 d1 fd ff ff       	call   f0105c0a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e39:	89 da                	mov    %ebx,%edx
f0105e3b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e40:	e8 c5 fd ff ff       	call   f0105c0a <lapicw>
		microdelay(200);
	}
}
f0105e45:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e48:	5b                   	pop    %ebx
f0105e49:	5e                   	pop    %esi
f0105e4a:	5d                   	pop    %ebp
f0105e4b:	c3                   	ret    

f0105e4c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e4c:	55                   	push   %ebp
f0105e4d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e4f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e52:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e58:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e5d:	e8 a8 fd ff ff       	call   f0105c0a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e62:	8b 15 04 40 25 f0    	mov    0xf0254004,%edx
f0105e68:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e6e:	f6 c4 10             	test   $0x10,%ah
f0105e71:	75 f5                	jne    f0105e68 <lapic_ipi+0x1c>
		;
}
f0105e73:	5d                   	pop    %ebp
f0105e74:	c3                   	ret    

f0105e75 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e75:	55                   	push   %ebp
f0105e76:	89 e5                	mov    %esp,%ebp
f0105e78:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e81:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e84:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e87:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e8e:	5d                   	pop    %ebp
f0105e8f:	c3                   	ret    

f0105e90 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e90:	55                   	push   %ebp
f0105e91:	89 e5                	mov    %esp,%ebp
f0105e93:	56                   	push   %esi
f0105e94:	53                   	push   %ebx
f0105e95:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e98:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105e9b:	74 14                	je     f0105eb1 <spin_lock+0x21>
f0105e9d:	8b 73 08             	mov    0x8(%ebx),%esi
f0105ea0:	e8 7d fd ff ff       	call   f0105c22 <cpunum>
f0105ea5:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ea8:	05 20 30 21 f0       	add    $0xf0213020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105ead:	39 c6                	cmp    %eax,%esi
f0105eaf:	74 07                	je     f0105eb8 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105eb1:	ba 01 00 00 00       	mov    $0x1,%edx
f0105eb6:	eb 20                	jmp    f0105ed8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105eb8:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ebb:	e8 62 fd ff ff       	call   f0105c22 <cpunum>
f0105ec0:	83 ec 0c             	sub    $0xc,%esp
f0105ec3:	53                   	push   %ebx
f0105ec4:	50                   	push   %eax
f0105ec5:	68 24 80 10 f0       	push   $0xf0108024
f0105eca:	6a 41                	push   $0x41
f0105ecc:	68 88 80 10 f0       	push   $0xf0108088
f0105ed1:	e8 6a a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105ed6:	f3 90                	pause  
f0105ed8:	89 d0                	mov    %edx,%eax
f0105eda:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105edd:	85 c0                	test   %eax,%eax
f0105edf:	75 f5                	jne    f0105ed6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105ee1:	e8 3c fd ff ff       	call   f0105c22 <cpunum>
f0105ee6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ee9:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0105eee:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105ef1:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105ef4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ef6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105efb:	eb 0b                	jmp    f0105f08 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105efd:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105f00:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105f03:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105f05:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105f08:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105f0e:	76 11                	jbe    f0105f21 <spin_lock+0x91>
f0105f10:	83 f8 09             	cmp    $0x9,%eax
f0105f13:	7e e8                	jle    f0105efd <spin_lock+0x6d>
f0105f15:	eb 0a                	jmp    f0105f21 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105f17:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105f1e:	83 c0 01             	add    $0x1,%eax
f0105f21:	83 f8 09             	cmp    $0x9,%eax
f0105f24:	7e f1                	jle    f0105f17 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105f26:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f29:	5b                   	pop    %ebx
f0105f2a:	5e                   	pop    %esi
f0105f2b:	5d                   	pop    %ebp
f0105f2c:	c3                   	ret    

f0105f2d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105f2d:	55                   	push   %ebp
f0105f2e:	89 e5                	mov    %esp,%ebp
f0105f30:	57                   	push   %edi
f0105f31:	56                   	push   %esi
f0105f32:	53                   	push   %ebx
f0105f33:	83 ec 4c             	sub    $0x4c,%esp
f0105f36:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f39:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f3c:	74 18                	je     f0105f56 <spin_unlock+0x29>
f0105f3e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f41:	e8 dc fc ff ff       	call   f0105c22 <cpunum>
f0105f46:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f49:	05 20 30 21 f0       	add    $0xf0213020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105f4e:	39 c3                	cmp    %eax,%ebx
f0105f50:	0f 84 a5 00 00 00    	je     f0105ffb <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f56:	83 ec 04             	sub    $0x4,%esp
f0105f59:	6a 28                	push   $0x28
f0105f5b:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f5e:	50                   	push   %eax
f0105f5f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f62:	53                   	push   %ebx
f0105f63:	e8 e4 f6 ff ff       	call   f010564c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f68:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f6b:	0f b6 38             	movzbl (%eax),%edi
f0105f6e:	8b 76 04             	mov    0x4(%esi),%esi
f0105f71:	e8 ac fc ff ff       	call   f0105c22 <cpunum>
f0105f76:	57                   	push   %edi
f0105f77:	56                   	push   %esi
f0105f78:	50                   	push   %eax
f0105f79:	68 50 80 10 f0       	push   $0xf0108050
f0105f7e:	e8 a1 d8 ff ff       	call   f0103824 <cprintf>
f0105f83:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f86:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f89:	eb 54                	jmp    f0105fdf <spin_unlock+0xb2>
f0105f8b:	83 ec 08             	sub    $0x8,%esp
f0105f8e:	57                   	push   %edi
f0105f8f:	50                   	push   %eax
f0105f90:	e8 51 ec ff ff       	call   f0104be6 <debuginfo_eip>
f0105f95:	83 c4 10             	add    $0x10,%esp
f0105f98:	85 c0                	test   %eax,%eax
f0105f9a:	78 27                	js     f0105fc3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105f9c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105f9e:	83 ec 04             	sub    $0x4,%esp
f0105fa1:	89 c2                	mov    %eax,%edx
f0105fa3:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105fa6:	52                   	push   %edx
f0105fa7:	ff 75 b0             	pushl  -0x50(%ebp)
f0105faa:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105fad:	ff 75 ac             	pushl  -0x54(%ebp)
f0105fb0:	ff 75 a8             	pushl  -0x58(%ebp)
f0105fb3:	50                   	push   %eax
f0105fb4:	68 98 80 10 f0       	push   $0xf0108098
f0105fb9:	e8 66 d8 ff ff       	call   f0103824 <cprintf>
f0105fbe:	83 c4 20             	add    $0x20,%esp
f0105fc1:	eb 12                	jmp    f0105fd5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105fc3:	83 ec 08             	sub    $0x8,%esp
f0105fc6:	ff 36                	pushl  (%esi)
f0105fc8:	68 af 80 10 f0       	push   $0xf01080af
f0105fcd:	e8 52 d8 ff ff       	call   f0103824 <cprintf>
f0105fd2:	83 c4 10             	add    $0x10,%esp
f0105fd5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105fd8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105fdb:	39 c3                	cmp    %eax,%ebx
f0105fdd:	74 08                	je     f0105fe7 <spin_unlock+0xba>
f0105fdf:	89 de                	mov    %ebx,%esi
f0105fe1:	8b 03                	mov    (%ebx),%eax
f0105fe3:	85 c0                	test   %eax,%eax
f0105fe5:	75 a4                	jne    f0105f8b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105fe7:	83 ec 04             	sub    $0x4,%esp
f0105fea:	68 b7 80 10 f0       	push   $0xf01080b7
f0105fef:	6a 67                	push   $0x67
f0105ff1:	68 88 80 10 f0       	push   $0xf0108088
f0105ff6:	e8 45 a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105ffb:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106002:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106009:	b8 00 00 00 00       	mov    $0x0,%eax
f010600e:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106011:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106014:	5b                   	pop    %ebx
f0106015:	5e                   	pop    %esi
f0106016:	5f                   	pop    %edi
f0106017:	5d                   	pop    %ebp
f0106018:	c3                   	ret    
f0106019:	66 90                	xchg   %ax,%ax
f010601b:	66 90                	xchg   %ax,%ax
f010601d:	66 90                	xchg   %ax,%ax
f010601f:	90                   	nop

f0106020 <__udivdi3>:
f0106020:	55                   	push   %ebp
f0106021:	57                   	push   %edi
f0106022:	56                   	push   %esi
f0106023:	53                   	push   %ebx
f0106024:	83 ec 1c             	sub    $0x1c,%esp
f0106027:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010602b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010602f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106033:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106037:	85 f6                	test   %esi,%esi
f0106039:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010603d:	89 ca                	mov    %ecx,%edx
f010603f:	89 f8                	mov    %edi,%eax
f0106041:	75 3d                	jne    f0106080 <__udivdi3+0x60>
f0106043:	39 cf                	cmp    %ecx,%edi
f0106045:	0f 87 c5 00 00 00    	ja     f0106110 <__udivdi3+0xf0>
f010604b:	85 ff                	test   %edi,%edi
f010604d:	89 fd                	mov    %edi,%ebp
f010604f:	75 0b                	jne    f010605c <__udivdi3+0x3c>
f0106051:	b8 01 00 00 00       	mov    $0x1,%eax
f0106056:	31 d2                	xor    %edx,%edx
f0106058:	f7 f7                	div    %edi
f010605a:	89 c5                	mov    %eax,%ebp
f010605c:	89 c8                	mov    %ecx,%eax
f010605e:	31 d2                	xor    %edx,%edx
f0106060:	f7 f5                	div    %ebp
f0106062:	89 c1                	mov    %eax,%ecx
f0106064:	89 d8                	mov    %ebx,%eax
f0106066:	89 cf                	mov    %ecx,%edi
f0106068:	f7 f5                	div    %ebp
f010606a:	89 c3                	mov    %eax,%ebx
f010606c:	89 d8                	mov    %ebx,%eax
f010606e:	89 fa                	mov    %edi,%edx
f0106070:	83 c4 1c             	add    $0x1c,%esp
f0106073:	5b                   	pop    %ebx
f0106074:	5e                   	pop    %esi
f0106075:	5f                   	pop    %edi
f0106076:	5d                   	pop    %ebp
f0106077:	c3                   	ret    
f0106078:	90                   	nop
f0106079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106080:	39 ce                	cmp    %ecx,%esi
f0106082:	77 74                	ja     f01060f8 <__udivdi3+0xd8>
f0106084:	0f bd fe             	bsr    %esi,%edi
f0106087:	83 f7 1f             	xor    $0x1f,%edi
f010608a:	0f 84 98 00 00 00    	je     f0106128 <__udivdi3+0x108>
f0106090:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106095:	89 f9                	mov    %edi,%ecx
f0106097:	89 c5                	mov    %eax,%ebp
f0106099:	29 fb                	sub    %edi,%ebx
f010609b:	d3 e6                	shl    %cl,%esi
f010609d:	89 d9                	mov    %ebx,%ecx
f010609f:	d3 ed                	shr    %cl,%ebp
f01060a1:	89 f9                	mov    %edi,%ecx
f01060a3:	d3 e0                	shl    %cl,%eax
f01060a5:	09 ee                	or     %ebp,%esi
f01060a7:	89 d9                	mov    %ebx,%ecx
f01060a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060ad:	89 d5                	mov    %edx,%ebp
f01060af:	8b 44 24 08          	mov    0x8(%esp),%eax
f01060b3:	d3 ed                	shr    %cl,%ebp
f01060b5:	89 f9                	mov    %edi,%ecx
f01060b7:	d3 e2                	shl    %cl,%edx
f01060b9:	89 d9                	mov    %ebx,%ecx
f01060bb:	d3 e8                	shr    %cl,%eax
f01060bd:	09 c2                	or     %eax,%edx
f01060bf:	89 d0                	mov    %edx,%eax
f01060c1:	89 ea                	mov    %ebp,%edx
f01060c3:	f7 f6                	div    %esi
f01060c5:	89 d5                	mov    %edx,%ebp
f01060c7:	89 c3                	mov    %eax,%ebx
f01060c9:	f7 64 24 0c          	mull   0xc(%esp)
f01060cd:	39 d5                	cmp    %edx,%ebp
f01060cf:	72 10                	jb     f01060e1 <__udivdi3+0xc1>
f01060d1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01060d5:	89 f9                	mov    %edi,%ecx
f01060d7:	d3 e6                	shl    %cl,%esi
f01060d9:	39 c6                	cmp    %eax,%esi
f01060db:	73 07                	jae    f01060e4 <__udivdi3+0xc4>
f01060dd:	39 d5                	cmp    %edx,%ebp
f01060df:	75 03                	jne    f01060e4 <__udivdi3+0xc4>
f01060e1:	83 eb 01             	sub    $0x1,%ebx
f01060e4:	31 ff                	xor    %edi,%edi
f01060e6:	89 d8                	mov    %ebx,%eax
f01060e8:	89 fa                	mov    %edi,%edx
f01060ea:	83 c4 1c             	add    $0x1c,%esp
f01060ed:	5b                   	pop    %ebx
f01060ee:	5e                   	pop    %esi
f01060ef:	5f                   	pop    %edi
f01060f0:	5d                   	pop    %ebp
f01060f1:	c3                   	ret    
f01060f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060f8:	31 ff                	xor    %edi,%edi
f01060fa:	31 db                	xor    %ebx,%ebx
f01060fc:	89 d8                	mov    %ebx,%eax
f01060fe:	89 fa                	mov    %edi,%edx
f0106100:	83 c4 1c             	add    $0x1c,%esp
f0106103:	5b                   	pop    %ebx
f0106104:	5e                   	pop    %esi
f0106105:	5f                   	pop    %edi
f0106106:	5d                   	pop    %ebp
f0106107:	c3                   	ret    
f0106108:	90                   	nop
f0106109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106110:	89 d8                	mov    %ebx,%eax
f0106112:	f7 f7                	div    %edi
f0106114:	31 ff                	xor    %edi,%edi
f0106116:	89 c3                	mov    %eax,%ebx
f0106118:	89 d8                	mov    %ebx,%eax
f010611a:	89 fa                	mov    %edi,%edx
f010611c:	83 c4 1c             	add    $0x1c,%esp
f010611f:	5b                   	pop    %ebx
f0106120:	5e                   	pop    %esi
f0106121:	5f                   	pop    %edi
f0106122:	5d                   	pop    %ebp
f0106123:	c3                   	ret    
f0106124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106128:	39 ce                	cmp    %ecx,%esi
f010612a:	72 0c                	jb     f0106138 <__udivdi3+0x118>
f010612c:	31 db                	xor    %ebx,%ebx
f010612e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106132:	0f 87 34 ff ff ff    	ja     f010606c <__udivdi3+0x4c>
f0106138:	bb 01 00 00 00       	mov    $0x1,%ebx
f010613d:	e9 2a ff ff ff       	jmp    f010606c <__udivdi3+0x4c>
f0106142:	66 90                	xchg   %ax,%ax
f0106144:	66 90                	xchg   %ax,%ax
f0106146:	66 90                	xchg   %ax,%ax
f0106148:	66 90                	xchg   %ax,%ax
f010614a:	66 90                	xchg   %ax,%ax
f010614c:	66 90                	xchg   %ax,%ax
f010614e:	66 90                	xchg   %ax,%ax

f0106150 <__umoddi3>:
f0106150:	55                   	push   %ebp
f0106151:	57                   	push   %edi
f0106152:	56                   	push   %esi
f0106153:	53                   	push   %ebx
f0106154:	83 ec 1c             	sub    $0x1c,%esp
f0106157:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010615b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010615f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106163:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106167:	85 d2                	test   %edx,%edx
f0106169:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010616d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106171:	89 f3                	mov    %esi,%ebx
f0106173:	89 3c 24             	mov    %edi,(%esp)
f0106176:	89 74 24 04          	mov    %esi,0x4(%esp)
f010617a:	75 1c                	jne    f0106198 <__umoddi3+0x48>
f010617c:	39 f7                	cmp    %esi,%edi
f010617e:	76 50                	jbe    f01061d0 <__umoddi3+0x80>
f0106180:	89 c8                	mov    %ecx,%eax
f0106182:	89 f2                	mov    %esi,%edx
f0106184:	f7 f7                	div    %edi
f0106186:	89 d0                	mov    %edx,%eax
f0106188:	31 d2                	xor    %edx,%edx
f010618a:	83 c4 1c             	add    $0x1c,%esp
f010618d:	5b                   	pop    %ebx
f010618e:	5e                   	pop    %esi
f010618f:	5f                   	pop    %edi
f0106190:	5d                   	pop    %ebp
f0106191:	c3                   	ret    
f0106192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106198:	39 f2                	cmp    %esi,%edx
f010619a:	89 d0                	mov    %edx,%eax
f010619c:	77 52                	ja     f01061f0 <__umoddi3+0xa0>
f010619e:	0f bd ea             	bsr    %edx,%ebp
f01061a1:	83 f5 1f             	xor    $0x1f,%ebp
f01061a4:	75 5a                	jne    f0106200 <__umoddi3+0xb0>
f01061a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01061aa:	0f 82 e0 00 00 00    	jb     f0106290 <__umoddi3+0x140>
f01061b0:	39 0c 24             	cmp    %ecx,(%esp)
f01061b3:	0f 86 d7 00 00 00    	jbe    f0106290 <__umoddi3+0x140>
f01061b9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01061bd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01061c1:	83 c4 1c             	add    $0x1c,%esp
f01061c4:	5b                   	pop    %ebx
f01061c5:	5e                   	pop    %esi
f01061c6:	5f                   	pop    %edi
f01061c7:	5d                   	pop    %ebp
f01061c8:	c3                   	ret    
f01061c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061d0:	85 ff                	test   %edi,%edi
f01061d2:	89 fd                	mov    %edi,%ebp
f01061d4:	75 0b                	jne    f01061e1 <__umoddi3+0x91>
f01061d6:	b8 01 00 00 00       	mov    $0x1,%eax
f01061db:	31 d2                	xor    %edx,%edx
f01061dd:	f7 f7                	div    %edi
f01061df:	89 c5                	mov    %eax,%ebp
f01061e1:	89 f0                	mov    %esi,%eax
f01061e3:	31 d2                	xor    %edx,%edx
f01061e5:	f7 f5                	div    %ebp
f01061e7:	89 c8                	mov    %ecx,%eax
f01061e9:	f7 f5                	div    %ebp
f01061eb:	89 d0                	mov    %edx,%eax
f01061ed:	eb 99                	jmp    f0106188 <__umoddi3+0x38>
f01061ef:	90                   	nop
f01061f0:	89 c8                	mov    %ecx,%eax
f01061f2:	89 f2                	mov    %esi,%edx
f01061f4:	83 c4 1c             	add    $0x1c,%esp
f01061f7:	5b                   	pop    %ebx
f01061f8:	5e                   	pop    %esi
f01061f9:	5f                   	pop    %edi
f01061fa:	5d                   	pop    %ebp
f01061fb:	c3                   	ret    
f01061fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106200:	8b 34 24             	mov    (%esp),%esi
f0106203:	bf 20 00 00 00       	mov    $0x20,%edi
f0106208:	89 e9                	mov    %ebp,%ecx
f010620a:	29 ef                	sub    %ebp,%edi
f010620c:	d3 e0                	shl    %cl,%eax
f010620e:	89 f9                	mov    %edi,%ecx
f0106210:	89 f2                	mov    %esi,%edx
f0106212:	d3 ea                	shr    %cl,%edx
f0106214:	89 e9                	mov    %ebp,%ecx
f0106216:	09 c2                	or     %eax,%edx
f0106218:	89 d8                	mov    %ebx,%eax
f010621a:	89 14 24             	mov    %edx,(%esp)
f010621d:	89 f2                	mov    %esi,%edx
f010621f:	d3 e2                	shl    %cl,%edx
f0106221:	89 f9                	mov    %edi,%ecx
f0106223:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106227:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010622b:	d3 e8                	shr    %cl,%eax
f010622d:	89 e9                	mov    %ebp,%ecx
f010622f:	89 c6                	mov    %eax,%esi
f0106231:	d3 e3                	shl    %cl,%ebx
f0106233:	89 f9                	mov    %edi,%ecx
f0106235:	89 d0                	mov    %edx,%eax
f0106237:	d3 e8                	shr    %cl,%eax
f0106239:	89 e9                	mov    %ebp,%ecx
f010623b:	09 d8                	or     %ebx,%eax
f010623d:	89 d3                	mov    %edx,%ebx
f010623f:	89 f2                	mov    %esi,%edx
f0106241:	f7 34 24             	divl   (%esp)
f0106244:	89 d6                	mov    %edx,%esi
f0106246:	d3 e3                	shl    %cl,%ebx
f0106248:	f7 64 24 04          	mull   0x4(%esp)
f010624c:	39 d6                	cmp    %edx,%esi
f010624e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106252:	89 d1                	mov    %edx,%ecx
f0106254:	89 c3                	mov    %eax,%ebx
f0106256:	72 08                	jb     f0106260 <__umoddi3+0x110>
f0106258:	75 11                	jne    f010626b <__umoddi3+0x11b>
f010625a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010625e:	73 0b                	jae    f010626b <__umoddi3+0x11b>
f0106260:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106264:	1b 14 24             	sbb    (%esp),%edx
f0106267:	89 d1                	mov    %edx,%ecx
f0106269:	89 c3                	mov    %eax,%ebx
f010626b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010626f:	29 da                	sub    %ebx,%edx
f0106271:	19 ce                	sbb    %ecx,%esi
f0106273:	89 f9                	mov    %edi,%ecx
f0106275:	89 f0                	mov    %esi,%eax
f0106277:	d3 e0                	shl    %cl,%eax
f0106279:	89 e9                	mov    %ebp,%ecx
f010627b:	d3 ea                	shr    %cl,%edx
f010627d:	89 e9                	mov    %ebp,%ecx
f010627f:	d3 ee                	shr    %cl,%esi
f0106281:	09 d0                	or     %edx,%eax
f0106283:	89 f2                	mov    %esi,%edx
f0106285:	83 c4 1c             	add    $0x1c,%esp
f0106288:	5b                   	pop    %ebx
f0106289:	5e                   	pop    %esi
f010628a:	5f                   	pop    %edi
f010628b:	5d                   	pop    %ebp
f010628c:	c3                   	ret    
f010628d:	8d 76 00             	lea    0x0(%esi),%esi
f0106290:	29 f9                	sub    %edi,%ecx
f0106292:	19 d6                	sbb    %edx,%esi
f0106294:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106298:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010629c:	e9 18 ff ff ff       	jmp    f01061b9 <__umoddi3+0x69>
