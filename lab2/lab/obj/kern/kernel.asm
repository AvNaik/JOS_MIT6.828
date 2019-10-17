
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:



void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 60 79 11 f0       	mov    $0xf0117960,%eax
f010004b:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 73 11 f0       	push   $0xf0117300
f0100058:	e8 87 32 00 00       	call   f01032e4 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 37 10 f0       	push   $0xf0103780
f010006f:	e8 ac 27 00 00       	call   f0102820 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 f6 10 00 00       	call   f010116f <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 56 07 00 00       	call   f01007dc <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 64 79 11 f0 00 	cmpl   $0x0,0xf0117964
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 64 79 11 f0    	mov    %esi,0xf0117964

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 9b 37 10 f0       	push   $0xf010379b
f01000b5:	e8 66 27 00 00       	call   f0102820 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 36 27 00 00       	call   f01027fa <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 a1 3a 10 f0 	movl   $0xf0103aa1,(%esp)
f01000cb:	e8 50 27 00 00       	call   f0102820 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 ff 06 00 00       	call   f01007dc <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 b3 37 10 f0       	push   $0xf01037b3
f01000f7:	e8 24 27 00 00       	call   f0102820 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 f2 26 00 00       	call   f01027fa <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 a1 3a 10 f0 	movl   $0xf0103aa1,(%esp)
f010010f:	e8 0c 27 00 00       	call   f0102820 <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f0100159:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f8 00 00 00    	je     f0100284 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010018c:	a8 20                	test   $0x20,%al
f010018e:	0f 85 f6 00 00 00    	jne    f010028a <kbd_proc_data+0x10c>
f0100194:	ba 60 00 00 00       	mov    $0x60,%edx
f0100199:	ec                   	in     (%dx),%al
f010019a:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010019c:	3c e0                	cmp    $0xe0,%al
f010019e:	75 0d                	jne    f01001ad <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001a0:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f01001a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ac:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	53                   	push   %ebx
f01001b1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001b4:	84 c0                	test   %al,%al
f01001b6:	79 36                	jns    f01001ee <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b8:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 20 39 10 f0 	movzbl -0xfefc6e0(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 20 39 10 f0 	movzbl -0xfefc6e0(%edx),%eax
f0100211:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100217:	0f b6 8a 20 38 10 f0 	movzbl -0xfefc7e0(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 00 38 10 f0 	mov    -0xfefc800(,%ecx,4),%ecx
f0100231:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100235:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100238:	a8 08                	test   $0x8,%al
f010023a:	74 1b                	je     f0100257 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010023c:	89 da                	mov    %ebx,%edx
f010023e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100241:	83 f9 19             	cmp    $0x19,%ecx
f0100244:	77 05                	ja     f010024b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100246:	83 eb 20             	sub    $0x20,%ebx
f0100249:	eb 0c                	jmp    f0100257 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010024b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010024e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100251:	83 fa 19             	cmp    $0x19,%edx
f0100254:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100257:	f7 d0                	not    %eax
f0100259:	a8 06                	test   $0x6,%al
f010025b:	75 33                	jne    f0100290 <kbd_proc_data+0x112>
f010025d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100263:	75 2b                	jne    f0100290 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100265:	83 ec 0c             	sub    $0xc,%esp
f0100268:	68 cd 37 10 f0       	push   $0xf01037cd
f010026d:	e8 ae 25 00 00       	call   f0102820 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100272:	ba 92 00 00 00       	mov    $0x92,%edx
f0100277:	b8 03 00 00 00       	mov    $0x3,%eax
f010027c:	ee                   	out    %al,(%dx)
f010027d:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
f0100282:	eb 0e                	jmp    f0100292 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100289:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010028a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010028f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100290:	89 d8                	mov    %ebx,%eax
}
f0100292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100295:	c9                   	leave  
f0100296:	c3                   	ret    

f0100297 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
f010029a:	57                   	push   %edi
f010029b:	56                   	push   %esi
f010029c:	53                   	push   %ebx
f010029d:	83 ec 1c             	sub    $0x1c,%esp
f01002a0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ac:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b1:	eb 09                	jmp    f01002bc <cons_putc+0x25>
f01002b3:	89 ca                	mov    %ecx,%edx
f01002b5:	ec                   	in     (%dx),%al
f01002b6:	ec                   	in     (%dx),%al
f01002b7:	ec                   	in     (%dx),%al
f01002b8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002b9:	83 c3 01             	add    $0x1,%ebx
f01002bc:	89 f2                	mov    %esi,%edx
f01002be:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bf:	a8 20                	test   $0x20,%al
f01002c1:	75 08                	jne    f01002cb <cons_putc+0x34>
f01002c3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002c9:	7e e8                	jle    f01002b3 <cons_putc+0x1c>
f01002cb:	89 f8                	mov    %edi,%eax
f01002cd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d5:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002db:	be 79 03 00 00       	mov    $0x379,%esi
f01002e0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e5:	eb 09                	jmp    f01002f0 <cons_putc+0x59>
f01002e7:	89 ca                	mov    %ecx,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	83 c3 01             	add    $0x1,%ebx
f01002f0:	89 f2                	mov    %esi,%edx
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f9:	7f 04                	jg     f01002ff <cons_putc+0x68>
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 e8                	jns    f01002e7 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba 78 03 00 00       	mov    $0x378,%edx
f0100304:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100308:	ee                   	out    %al,(%dx)
f0100309:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010030e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	b8 08 00 00 00       	mov    $0x8,%eax
f0100319:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031a:	89 fa                	mov    %edi,%edx
f010031c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	80 cc 07             	or     $0x7,%ah
f0100327:	85 d2                	test   %edx,%edx
f0100329:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	83 f8 09             	cmp    $0x9,%eax
f0100334:	74 74                	je     f01003aa <cons_putc+0x113>
f0100336:	83 f8 09             	cmp    $0x9,%eax
f0100339:	7f 0a                	jg     f0100345 <cons_putc+0xae>
f010033b:	83 f8 08             	cmp    $0x8,%eax
f010033e:	74 14                	je     f0100354 <cons_putc+0xbd>
f0100340:	e9 99 00 00 00       	jmp    f01003de <cons_putc+0x147>
f0100345:	83 f8 0a             	cmp    $0xa,%eax
f0100348:	74 3a                	je     f0100384 <cons_putc+0xed>
f010034a:	83 f8 0d             	cmp    $0xd,%eax
f010034d:	74 3d                	je     f010038c <cons_putc+0xf5>
f010034f:	e9 8a 00 00 00       	jmp    f01003de <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100354:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f01003a8:	eb 52                	jmp    f01003fc <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003aa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003af:	e8 e3 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b9:	e8 d9 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003be:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c3:	e8 cf fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cd:	e8 c5 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 bb fe ff ff       	call   f0100297 <cons_putc>
f01003dc:	eb 1e                	jmp    f01003fc <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003de:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 10 2f 00 00       	call   f0103331 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100427:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010042d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100433:	83 c4 10             	add    $0x10,%esp
f0100436:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043e:	39 d0                	cmp    %edx,%eax
f0100440:	75 f4                	jne    f0100436 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100442:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f010045f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	66 c1 e8 08          	shr    $0x8,%ax
f0100468:	89 f2                	mov    %esi,%edx
f010046a:	ee                   	out    %al,(%dx)
f010046b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100470:	89 ca                	mov    %ecx,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	89 d8                	mov    %ebx,%eax
f0100475:	89 f2                	mov    %esi,%edx
f0100477:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047b:	5b                   	pop    %ebx
f010047c:	5e                   	pop    %esi
f010047d:	5f                   	pop    %edi
f010047e:	5d                   	pop    %ebp
f010047f:	c3                   	ret    

f0100480 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100480:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f0100487:	74 11                	je     f010049a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010048f:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100494:	e8 a2 fc ff ff       	call   f010013b <cons_intr>
}
f0100499:	c9                   	leave  
f010049a:	f3 c3                	repz ret 

f010049c <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a2:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004a7:	e8 8f fc ff ff       	call   f010013b <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b4:	e8 c7 ff ff ff       	call   f0100480 <serial_intr>
	kbd_intr();
f01004b9:	e8 de ff ff ff       	call   f010049c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004be:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f01004c3:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f01004d4:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004db:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004dd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e3:	75 11                	jne    f01004f6 <cons_getc+0x48>
			cons.rpos = 0;
f01004e5:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f01004ec:	00 00 00 
f01004ef:	eb 05                	jmp    f01004f6 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	57                   	push   %edi
f01004fc:	56                   	push   %esi
f01004fd:	53                   	push   %ebx
f01004fe:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100501:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100508:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010050f:	5a a5 
	if (*cp != 0xA55A) {
f0100511:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100518:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051c:	74 11                	je     f010052f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010051e:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f0100525:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100528:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010052d:	eb 16                	jmp    f0100545 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010052f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100536:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f010053d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100540:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100545:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
f010054b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100550:	89 fa                	mov    %edi,%edx
f0100552:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100553:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100556:	89 da                	mov    %ebx,%edx
f0100558:	ec                   	in     (%dx),%al
f0100559:	0f b6 c8             	movzbl %al,%ecx
f010055c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100564:	89 fa                	mov    %edi,%edx
f0100566:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100567:	89 da                	mov    %ebx,%edx
f0100569:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010056a:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100580:	b8 00 00 00 00       	mov    $0x0,%eax
f0100585:	89 f2                	mov    %esi,%edx
f0100587:	ee                   	out    %al,(%dx)
f0100588:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010058d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100592:	ee                   	out    %al,(%dx)
f0100593:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100598:	b8 0c 00 00 00       	mov    $0xc,%eax
f010059d:	89 da                	mov    %ebx,%edx
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005cb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d4:	3c ff                	cmp    $0xff,%al
f01005d6:	0f 95 05 34 75 11 f0 	setne  0xf0117534
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	89 da                	mov    %ebx,%edx
f01005e2:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e3:	80 f9 ff             	cmp    $0xff,%cl
f01005e6:	75 10                	jne    f01005f8 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005e8:	83 ec 0c             	sub    $0xc,%esp
f01005eb:	68 d9 37 10 f0       	push   $0xf01037d9
f01005f0:	e8 2b 22 00 00       	call   f0102820 <cprintf>
f01005f5:	83 c4 10             	add    $0x10,%esp
}
f01005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005fb:	5b                   	pop    %ebx
f01005fc:	5e                   	pop    %esi
f01005fd:	5f                   	pop    %edi
f01005fe:	5d                   	pop    %ebp
f01005ff:	c3                   	ret    

f0100600 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100606:	8b 45 08             	mov    0x8(%ebp),%eax
f0100609:	e8 89 fc ff ff       	call   f0100297 <cons_putc>
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <getchar>:

int
getchar(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100616:	e8 93 fe ff ff       	call   f01004ae <cons_getc>
f010061b:	85 c0                	test   %eax,%eax
f010061d:	74 f7                	je     f0100616 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <iscons>:

int
iscons(int fdnum)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100624:	b8 01 00 00 00       	mov    $0x1,%eax
f0100629:	5d                   	pop    %ebp
f010062a:	c3                   	ret    

f010062b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

	   int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	83 ec 0c             	sub    $0xc,%esp
	   int i;

	   for (i = 0; i < ARRAY_SIZE(commands); i++)
			 cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100631:	68 20 3a 10 f0       	push   $0xf0103a20
f0100636:	68 3e 3a 10 f0       	push   $0xf0103a3e
f010063b:	68 43 3a 10 f0       	push   $0xf0103a43
f0100640:	e8 db 21 00 00       	call   f0102820 <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 10 3b 10 f0       	push   $0xf0103b10
f010064d:	68 4c 3a 10 f0       	push   $0xf0103a4c
f0100652:	68 43 3a 10 f0       	push   $0xf0103a43
f0100657:	e8 c4 21 00 00       	call   f0102820 <cprintf>
f010065c:	83 c4 0c             	add    $0xc,%esp
f010065f:	68 55 3a 10 f0       	push   $0xf0103a55
f0100664:	68 6d 3a 10 f0       	push   $0xf0103a6d
f0100669:	68 43 3a 10 f0       	push   $0xf0103a43
f010066e:	e8 ad 21 00 00       	call   f0102820 <cprintf>
	   return 0;
}
f0100673:	b8 00 00 00 00       	mov    $0x0,%eax
f0100678:	c9                   	leave  
f0100679:	c3                   	ret    

f010067a <mon_kerninfo>:

	   int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010067a:	55                   	push   %ebp
f010067b:	89 e5                	mov    %esp,%ebp
f010067d:	83 ec 14             	sub    $0x14,%esp
	   extern char _start[], entry[], etext[], edata[], end[];

	   cprintf("Special kernel symbols:\n");
f0100680:	68 77 3a 10 f0       	push   $0xf0103a77
f0100685:	e8 96 21 00 00       	call   f0102820 <cprintf>
	   cprintf("  _start                  %08x (phys)\n", _start);
f010068a:	83 c4 08             	add    $0x8,%esp
f010068d:	68 0c 00 10 00       	push   $0x10000c
f0100692:	68 38 3b 10 f0       	push   $0xf0103b38
f0100697:	e8 84 21 00 00       	call   f0102820 <cprintf>
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 0c 00 10 00       	push   $0x10000c
f01006a4:	68 0c 00 10 f0       	push   $0xf010000c
f01006a9:	68 60 3b 10 f0       	push   $0xf0103b60
f01006ae:	e8 6d 21 00 00       	call   f0102820 <cprintf>
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 71 37 10 00       	push   $0x103771
f01006bb:	68 71 37 10 f0       	push   $0xf0103771
f01006c0:	68 84 3b 10 f0       	push   $0xf0103b84
f01006c5:	e8 56 21 00 00       	call   f0102820 <cprintf>
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 00 73 11 00       	push   $0x117300
f01006d2:	68 00 73 11 f0       	push   $0xf0117300
f01006d7:	68 a8 3b 10 f0       	push   $0xf0103ba8
f01006dc:	e8 3f 21 00 00       	call   f0102820 <cprintf>
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 60 79 11 00       	push   $0x117960
f01006e9:	68 60 79 11 f0       	push   $0xf0117960
f01006ee:	68 cc 3b 10 f0       	push   $0xf0103bcc
f01006f3:	e8 28 21 00 00       	call   f0102820 <cprintf>
	   cprintf("Kernel executable memory footprint: %dKB\n",
				    ROUNDUP(end - entry, 1024) / 1024);
f01006f8:	b8 5f 7d 11 f0       	mov    $0xf0117d5f,%eax
f01006fd:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	   cprintf("  _start                  %08x (phys)\n", _start);
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	   cprintf("Kernel executable memory footprint: %dKB\n",
f0100702:	83 c4 08             	add    $0x8,%esp
f0100705:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010070a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100710:	85 c0                	test   %eax,%eax
f0100712:	0f 48 c2             	cmovs  %edx,%eax
f0100715:	c1 f8 0a             	sar    $0xa,%eax
f0100718:	50                   	push   %eax
f0100719:	68 f0 3b 10 f0       	push   $0xf0103bf0
f010071e:	e8 fd 20 00 00       	call   f0102820 <cprintf>
				    ROUNDUP(end - entry, 1024) / 1024);
	   return 0;
}
f0100723:	b8 00 00 00 00       	mov    $0x0,%eax
f0100728:	c9                   	leave  
f0100729:	c3                   	ret    

f010072a <mon_backtrace>:
	   int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010072a:	55                   	push   %ebp
f010072b:	89 e5                	mov    %esp,%ebp
f010072d:	57                   	push   %edi
f010072e:	56                   	push   %esi
f010072f:	53                   	push   %ebx
f0100730:	83 ec 48             	sub    $0x48,%esp
	   // Your code here.

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
f0100733:	89 ee                	mov    %ebp,%esi
	   cprintf("Stack Backtrace: \n");
f0100735:	68 90 3a 10 f0       	push   $0xf0103a90
f010073a:	e8 e1 20 00 00       	call   f0102820 <cprintf>
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f010073f:	83 c4 10             	add    $0x10,%esp
f0100742:	e9 80 00 00 00       	jmp    f01007c7 <mon_backtrace+0x9d>
	   {
			 ueip = *((uint32_t *)baseframe + 1);
f0100747:	8b 46 04             	mov    0x4(%esi),%eax
f010074a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
f010074d:	83 ec 04             	sub    $0x4,%esp
f0100750:	50                   	push   %eax
f0100751:	56                   	push   %esi
f0100752:	68 a3 3a 10 f0       	push   $0xf0103aa3
f0100757:	e8 c4 20 00 00       	call   f0102820 <cprintf>
f010075c:	8d 5e 08             	lea    0x8(%esi),%ebx
f010075f:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100762:	83 c4 10             	add    $0x10,%esp
			 for (int i = 2; i < 7; i ++)
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
f0100765:	83 ec 08             	sub    $0x8,%esp
f0100768:	ff 33                	pushl  (%ebx)
f010076a:	68 bb 3a 10 f0       	push   $0xf0103abb
f010076f:	e8 ac 20 00 00       	call   f0102820 <cprintf>
f0100774:	83 c3 04             	add    $0x4,%ebx
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
	   {
			 ueip = *((uint32_t *)baseframe + 1);
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
			 for (int i = 2; i < 7; i ++)
f0100777:	83 c4 10             	add    $0x10,%esp
f010077a:	39 fb                	cmp    %edi,%ebx
f010077c:	75 e7                	jne    f0100765 <mon_backtrace+0x3b>
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
			 }

			 cprintf("\n");
f010077e:	83 ec 0c             	sub    $0xc,%esp
f0100781:	68 a1 3a 10 f0       	push   $0xf0103aa1
f0100786:	e8 95 20 00 00       	call   f0102820 <cprintf>
			 struct Eipdebuginfo information;
			 debuginfo_eip (ueip, &information);
f010078b:	83 c4 08             	add    $0x8,%esp
f010078e:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100791:	50                   	push   %eax
f0100792:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100795:	53                   	push   %ebx
f0100796:	e8 8f 21 00 00       	call   f010292a <debuginfo_eip>
			 uintptr_t offset = ueip - information.eip_fn_addr;
f010079b:	2b 5d e0             	sub    -0x20(%ebp),%ebx
			 cprintf("\t%s:%d: ", information.eip_file, information.eip_line);
f010079e:	83 c4 0c             	add    $0xc,%esp
f01007a1:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007a4:	ff 75 d0             	pushl  -0x30(%ebp)
f01007a7:	68 c2 3a 10 f0       	push   $0xf0103ac2
f01007ac:	e8 6f 20 00 00       	call   f0102820 <cprintf>
			 cprintf("%.*s+%d\n",information.eip_fn_namelen, information.eip_fn_name, offset);
f01007b1:	53                   	push   %ebx
f01007b2:	ff 75 d8             	pushl  -0x28(%ebp)
f01007b5:	ff 75 dc             	pushl  -0x24(%ebp)
f01007b8:	68 cb 3a 10 f0       	push   $0xf0103acb
f01007bd:	e8 5e 20 00 00       	call   f0102820 <cprintf>

			 baseframe = *(uint32_t *) baseframe;
f01007c2:	8b 36                	mov    (%esi),%esi
f01007c4:	83 c4 20             	add    $0x20,%esp

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
	   cprintf("Stack Backtrace: \n");
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f01007c7:	85 f6                	test   %esi,%esi
f01007c9:	0f 85 78 ff ff ff    	jne    f0100747 <mon_backtrace+0x1d>


	   }

	   return 0;
}
f01007cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007d7:	5b                   	pop    %ebx
f01007d8:	5e                   	pop    %esi
f01007d9:	5f                   	pop    %edi
f01007da:	5d                   	pop    %ebp
f01007db:	c3                   	ret    

f01007dc <monitor>:
	   return 0;
}

	   void
monitor(struct Trapframe *tf)
{
f01007dc:	55                   	push   %ebp
f01007dd:	89 e5                	mov    %esp,%ebp
f01007df:	57                   	push   %edi
f01007e0:	56                   	push   %esi
f01007e1:	53                   	push   %ebx
f01007e2:	83 ec 58             	sub    $0x58,%esp
	   char *buf;

	   cprintf("Welcome to the JOS kernel monitor!\n");
f01007e5:	68 1c 3c 10 f0       	push   $0xf0103c1c
f01007ea:	e8 31 20 00 00       	call   f0102820 <cprintf>
	   cprintf("Type 'help' for a list of commands.\n");
f01007ef:	c7 04 24 40 3c 10 f0 	movl   $0xf0103c40,(%esp)
f01007f6:	e8 25 20 00 00       	call   f0102820 <cprintf>
f01007fb:	83 c4 10             	add    $0x10,%esp


	   while (1) {
			 buf = readline("K> ");
f01007fe:	83 ec 0c             	sub    $0xc,%esp
f0100801:	68 d4 3a 10 f0       	push   $0xf0103ad4
f0100806:	e8 82 28 00 00       	call   f010308d <readline>
f010080b:	89 c3                	mov    %eax,%ebx
			 if (buf != NULL)
f010080d:	83 c4 10             	add    $0x10,%esp
f0100810:	85 c0                	test   %eax,%eax
f0100812:	74 ea                	je     f01007fe <monitor+0x22>
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
f0100814:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	   int argc;
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
f010081b:	be 00 00 00 00       	mov    $0x0,%esi
f0100820:	eb 0a                	jmp    f010082c <monitor+0x50>
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
				    *buf++ = 0;
f0100822:	c6 03 00             	movb   $0x0,(%ebx)
f0100825:	89 f7                	mov    %esi,%edi
f0100827:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010082a:	89 fe                	mov    %edi,%esi
	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
f010082c:	0f b6 03             	movzbl (%ebx),%eax
f010082f:	84 c0                	test   %al,%al
f0100831:	74 63                	je     f0100896 <monitor+0xba>
f0100833:	83 ec 08             	sub    $0x8,%esp
f0100836:	0f be c0             	movsbl %al,%eax
f0100839:	50                   	push   %eax
f010083a:	68 d8 3a 10 f0       	push   $0xf0103ad8
f010083f:	e8 63 2a 00 00       	call   f01032a7 <strchr>
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	85 c0                	test   %eax,%eax
f0100849:	75 d7                	jne    f0100822 <monitor+0x46>
				    *buf++ = 0;
			 if (*buf == 0)
f010084b:	80 3b 00             	cmpb   $0x0,(%ebx)
f010084e:	74 46                	je     f0100896 <monitor+0xba>
				    break;

			 // save and scan past next arg
			 if (argc == MAXARGS-1) {
f0100850:	83 fe 0f             	cmp    $0xf,%esi
f0100853:	75 14                	jne    f0100869 <monitor+0x8d>
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100855:	83 ec 08             	sub    $0x8,%esp
f0100858:	6a 10                	push   $0x10
f010085a:	68 dd 3a 10 f0       	push   $0xf0103add
f010085f:	e8 bc 1f 00 00       	call   f0102820 <cprintf>
f0100864:	83 c4 10             	add    $0x10,%esp
f0100867:	eb 95                	jmp    f01007fe <monitor+0x22>
				    return 0;
			 }
			 argv[argc++] = buf;
f0100869:	8d 7e 01             	lea    0x1(%esi),%edi
f010086c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100870:	eb 03                	jmp    f0100875 <monitor+0x99>
			 while (*buf && !strchr(WHITESPACE, *buf))
				    buf++;
f0100872:	83 c3 01             	add    $0x1,%ebx
			 if (argc == MAXARGS-1) {
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
				    return 0;
			 }
			 argv[argc++] = buf;
			 while (*buf && !strchr(WHITESPACE, *buf))
f0100875:	0f b6 03             	movzbl (%ebx),%eax
f0100878:	84 c0                	test   %al,%al
f010087a:	74 ae                	je     f010082a <monitor+0x4e>
f010087c:	83 ec 08             	sub    $0x8,%esp
f010087f:	0f be c0             	movsbl %al,%eax
f0100882:	50                   	push   %eax
f0100883:	68 d8 3a 10 f0       	push   $0xf0103ad8
f0100888:	e8 1a 2a 00 00       	call   f01032a7 <strchr>
f010088d:	83 c4 10             	add    $0x10,%esp
f0100890:	85 c0                	test   %eax,%eax
f0100892:	74 de                	je     f0100872 <monitor+0x96>
f0100894:	eb 94                	jmp    f010082a <monitor+0x4e>
				    buf++;
	   }
	   argv[argc] = 0;
f0100896:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010089d:	00 

	   // Lookup and invoke the command
	   if (argc == 0)
f010089e:	85 f6                	test   %esi,%esi
f01008a0:	0f 84 58 ff ff ff    	je     f01007fe <monitor+0x22>
f01008a6:	bb 00 00 00 00       	mov    $0x0,%ebx
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
			 if (strcmp(argv[0], commands[i].name) == 0)
f01008ab:	83 ec 08             	sub    $0x8,%esp
f01008ae:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008b1:	ff 34 85 80 3c 10 f0 	pushl  -0xfefc380(,%eax,4)
f01008b8:	ff 75 a8             	pushl  -0x58(%ebp)
f01008bb:	e8 89 29 00 00       	call   f0103249 <strcmp>
f01008c0:	83 c4 10             	add    $0x10,%esp
f01008c3:	85 c0                	test   %eax,%eax
f01008c5:	75 21                	jne    f01008e8 <monitor+0x10c>
				    return commands[i].func(argc, argv, tf);
f01008c7:	83 ec 04             	sub    $0x4,%esp
f01008ca:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008cd:	ff 75 08             	pushl  0x8(%ebp)
f01008d0:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008d3:	52                   	push   %edx
f01008d4:	56                   	push   %esi
f01008d5:	ff 14 85 88 3c 10 f0 	call   *-0xfefc378(,%eax,4)


	   while (1) {
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
f01008dc:	83 c4 10             	add    $0x10,%esp
f01008df:	85 c0                	test   %eax,%eax
f01008e1:	78 25                	js     f0100908 <monitor+0x12c>
f01008e3:	e9 16 ff ff ff       	jmp    f01007fe <monitor+0x22>
	   argv[argc] = 0;

	   // Lookup and invoke the command
	   if (argc == 0)
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008e8:	83 c3 01             	add    $0x1,%ebx
f01008eb:	83 fb 03             	cmp    $0x3,%ebx
f01008ee:	75 bb                	jne    f01008ab <monitor+0xcf>
			 if (strcmp(argv[0], commands[i].name) == 0)
				    return commands[i].func(argc, argv, tf);
	   }
	   cprintf("Unknown command '%s'\n", argv[0]);
f01008f0:	83 ec 08             	sub    $0x8,%esp
f01008f3:	ff 75 a8             	pushl  -0x58(%ebp)
f01008f6:	68 fa 3a 10 f0       	push   $0xf0103afa
f01008fb:	e8 20 1f 00 00       	call   f0102820 <cprintf>
f0100900:	83 c4 10             	add    $0x10,%esp
f0100903:	e9 f6 fe ff ff       	jmp    f01007fe <monitor+0x22>
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
						  break;
	   }
}
f0100908:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010090b:	5b                   	pop    %ebx
f010090c:	5e                   	pop    %esi
f010090d:	5f                   	pop    %edi
f010090e:	5d                   	pop    %ebp
f010090f:	c3                   	ret    

f0100910 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100910:	55                   	push   %ebp
f0100911:	89 e5                	mov    %esp,%ebp
f0100913:	56                   	push   %esi
f0100914:	53                   	push   %ebx
f0100915:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100917:	83 ec 0c             	sub    $0xc,%esp
f010091a:	50                   	push   %eax
f010091b:	e8 99 1e 00 00       	call   f01027b9 <mc146818_read>
f0100920:	89 c6                	mov    %eax,%esi
f0100922:	83 c3 01             	add    $0x1,%ebx
f0100925:	89 1c 24             	mov    %ebx,(%esp)
f0100928:	e8 8c 1e 00 00       	call   f01027b9 <mc146818_read>
f010092d:	c1 e0 08             	shl    $0x8,%eax
f0100930:	09 f0                	or     %esi,%eax
}
f0100932:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100935:	5b                   	pop    %ebx
f0100936:	5e                   	pop    %esi
f0100937:	5d                   	pop    %ebp
f0100938:	c3                   	ret    

f0100939 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100939:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f0100940:	75 11                	jne    f0100953 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100942:	ba 5f 89 11 f0       	mov    $0xf011895f,%edx
f0100947:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010094d:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	}

	result = nextfree;
f0100953:	8b 0d 38 75 11 f0    	mov    0xf0117538,%ecx
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.

	nextfree = ROUNDUP ( result + n, PGSIZE);
f0100959:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100960:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100966:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
f010096c:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f0100972:	76 25                	jbe    f0100999 <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100974:	55                   	push   %ebp
f0100975:	89 e5                	mov    %esp,%ebp
f0100977:	53                   	push   %ebx
f0100978:	83 ec 10             	sub    $0x10,%esp
f010097b:	89 c3                	mov    %eax,%ebx
	// LAB 2: Your code here.

	nextfree = ROUNDUP ( result + n, PGSIZE);
	if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
	{
		cprintf("OUT OF MEMORY");
f010097d:	68 a4 3c 10 f0       	push   $0xf0103ca4
f0100982:	e8 99 1e 00 00       	call   f0102820 <cprintf>
		panic ("boot alloc Failed to allocate %d bytes", n);
f0100987:	53                   	push   %ebx
f0100988:	68 f0 3f 10 f0       	push   $0xf0103ff0
f010098d:	6a 70                	push   $0x70
f010098f:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100994:	e8 f2 f6 ff ff       	call   f010008b <_panic>
	}

	return result;
}
f0100999:	89 c8                	mov    %ecx,%eax
f010099b:	c3                   	ret    

f010099c <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010099c:	89 d1                	mov    %edx,%ecx
f010099e:	c1 e9 16             	shr    $0x16,%ecx
f01009a1:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009a4:	a8 01                	test   $0x1,%al
f01009a6:	74 52                	je     f01009fa <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009ad:	89 c1                	mov    %eax,%ecx
f01009af:	c1 e9 0c             	shr    $0xc,%ecx
f01009b2:	3b 0d 68 79 11 f0    	cmp    0xf0117968,%ecx
f01009b8:	72 1b                	jb     f01009d5 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009ba:	55                   	push   %ebp
f01009bb:	89 e5                	mov    %esp,%ebp
f01009bd:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009c0:	50                   	push   %eax
f01009c1:	68 18 40 10 f0       	push   $0xf0104018
f01009c6:	68 f7 02 00 00       	push   $0x2f7
f01009cb:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01009d0:	e8 b6 f6 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009d5:	c1 ea 0c             	shr    $0xc,%edx
f01009d8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009de:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009e5:	89 c2                	mov    %eax,%edx
f01009e7:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009ef:	85 d2                	test   %edx,%edx
f01009f1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009f6:	0f 44 c2             	cmove  %edx,%eax
f01009f9:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009ff:	c3                   	ret    

f0100a00 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a00:	55                   	push   %ebp
f0100a01:	89 e5                	mov    %esp,%ebp
f0100a03:	57                   	push   %edi
f0100a04:	56                   	push   %esi
f0100a05:	53                   	push   %ebx
f0100a06:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a09:	84 c0                	test   %al,%al
f0100a0b:	0f 85 81 02 00 00    	jne    f0100c92 <check_page_free_list+0x292>
f0100a11:	e9 8e 02 00 00       	jmp    f0100ca4 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a16:	83 ec 04             	sub    $0x4,%esp
f0100a19:	68 3c 40 10 f0       	push   $0xf010403c
f0100a1e:	68 38 02 00 00       	push   $0x238
f0100a23:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100a28:	e8 5e f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a2d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a30:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a33:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a36:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a39:	89 c2                	mov    %eax,%edx
f0100a3b:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0100a41:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a47:	0f 95 c2             	setne  %dl
f0100a4a:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a4d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a51:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a53:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a57:	8b 00                	mov    (%eax),%eax
f0100a59:	85 c0                	test   %eax,%eax
f0100a5b:	75 dc                	jne    f0100a39 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a66:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a69:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a6c:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a6e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a71:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a76:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a7b:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100a81:	eb 53                	jmp    f0100ad6 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a83:	89 d8                	mov    %ebx,%eax
f0100a85:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0100a8b:	c1 f8 03             	sar    $0x3,%eax
f0100a8e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a91:	89 c2                	mov    %eax,%edx
f0100a93:	c1 ea 16             	shr    $0x16,%edx
f0100a96:	39 f2                	cmp    %esi,%edx
f0100a98:	73 3a                	jae    f0100ad4 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a9a:	89 c2                	mov    %eax,%edx
f0100a9c:	c1 ea 0c             	shr    $0xc,%edx
f0100a9f:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100aa5:	72 12                	jb     f0100ab9 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aa7:	50                   	push   %eax
f0100aa8:	68 18 40 10 f0       	push   $0xf0104018
f0100aad:	6a 52                	push   $0x52
f0100aaf:	68 be 3c 10 f0       	push   $0xf0103cbe
f0100ab4:	e8 d2 f5 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ab9:	83 ec 04             	sub    $0x4,%esp
f0100abc:	68 80 00 00 00       	push   $0x80
f0100ac1:	68 97 00 00 00       	push   $0x97
f0100ac6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100acb:	50                   	push   %eax
f0100acc:	e8 13 28 00 00       	call   f01032e4 <memset>
f0100ad1:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ad4:	8b 1b                	mov    (%ebx),%ebx
f0100ad6:	85 db                	test   %ebx,%ebx
f0100ad8:	75 a9                	jne    f0100a83 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ada:	b8 00 00 00 00       	mov    $0x0,%eax
f0100adf:	e8 55 fe ff ff       	call   f0100939 <boot_alloc>
f0100ae4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ae7:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aed:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
		assert(pp < pages + npages);
f0100af3:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0100af8:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100afb:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100afe:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b01:	be 00 00 00 00       	mov    $0x0,%esi
f0100b06:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b09:	e9 30 01 00 00       	jmp    f0100c3e <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b0e:	39 ca                	cmp    %ecx,%edx
f0100b10:	73 19                	jae    f0100b2b <check_page_free_list+0x12b>
f0100b12:	68 cc 3c 10 f0       	push   $0xf0103ccc
f0100b17:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100b1c:	68 52 02 00 00       	push   $0x252
f0100b21:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100b26:	e8 60 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100b2b:	39 fa                	cmp    %edi,%edx
f0100b2d:	72 19                	jb     f0100b48 <check_page_free_list+0x148>
f0100b2f:	68 ed 3c 10 f0       	push   $0xf0103ced
f0100b34:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100b39:	68 53 02 00 00       	push   $0x253
f0100b3e:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100b43:	e8 43 f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b48:	89 d0                	mov    %edx,%eax
f0100b4a:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b4d:	a8 07                	test   $0x7,%al
f0100b4f:	74 19                	je     f0100b6a <check_page_free_list+0x16a>
f0100b51:	68 60 40 10 f0       	push   $0xf0104060
f0100b56:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100b5b:	68 54 02 00 00       	push   $0x254
f0100b60:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100b65:	e8 21 f5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b6a:	c1 f8 03             	sar    $0x3,%eax
f0100b6d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b70:	85 c0                	test   %eax,%eax
f0100b72:	75 19                	jne    f0100b8d <check_page_free_list+0x18d>
f0100b74:	68 01 3d 10 f0       	push   $0xf0103d01
f0100b79:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100b7e:	68 57 02 00 00       	push   $0x257
f0100b83:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100b88:	e8 fe f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b8d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b92:	75 19                	jne    f0100bad <check_page_free_list+0x1ad>
f0100b94:	68 12 3d 10 f0       	push   $0xf0103d12
f0100b99:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100b9e:	68 58 02 00 00       	push   $0x258
f0100ba3:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100ba8:	e8 de f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bad:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bb2:	75 19                	jne    f0100bcd <check_page_free_list+0x1cd>
f0100bb4:	68 94 40 10 f0       	push   $0xf0104094
f0100bb9:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100bbe:	68 59 02 00 00       	push   $0x259
f0100bc3:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100bc8:	e8 be f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bcd:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bd2:	75 19                	jne    f0100bed <check_page_free_list+0x1ed>
f0100bd4:	68 2b 3d 10 f0       	push   $0xf0103d2b
f0100bd9:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100bde:	68 5a 02 00 00       	push   $0x25a
f0100be3:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100be8:	e8 9e f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bed:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bf2:	76 3f                	jbe    f0100c33 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bf4:	89 c3                	mov    %eax,%ebx
f0100bf6:	c1 eb 0c             	shr    $0xc,%ebx
f0100bf9:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100bfc:	77 12                	ja     f0100c10 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bfe:	50                   	push   %eax
f0100bff:	68 18 40 10 f0       	push   $0xf0104018
f0100c04:	6a 52                	push   $0x52
f0100c06:	68 be 3c 10 f0       	push   $0xf0103cbe
f0100c0b:	e8 7b f4 ff ff       	call   f010008b <_panic>
f0100c10:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c15:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c18:	76 1e                	jbe    f0100c38 <check_page_free_list+0x238>
f0100c1a:	68 b8 40 10 f0       	push   $0xf01040b8
f0100c1f:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100c24:	68 5b 02 00 00       	push   $0x25b
f0100c29:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100c2e:	e8 58 f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c33:	83 c6 01             	add    $0x1,%esi
f0100c36:	eb 04                	jmp    f0100c3c <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c38:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3c:	8b 12                	mov    (%edx),%edx
f0100c3e:	85 d2                	test   %edx,%edx
f0100c40:	0f 85 c8 fe ff ff    	jne    f0100b0e <check_page_free_list+0x10e>
f0100c46:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c49:	85 f6                	test   %esi,%esi
f0100c4b:	7f 19                	jg     f0100c66 <check_page_free_list+0x266>
f0100c4d:	68 45 3d 10 f0       	push   $0xf0103d45
f0100c52:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100c57:	68 63 02 00 00       	push   $0x263
f0100c5c:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100c61:	e8 25 f4 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c66:	85 db                	test   %ebx,%ebx
f0100c68:	7f 19                	jg     f0100c83 <check_page_free_list+0x283>
f0100c6a:	68 57 3d 10 f0       	push   $0xf0103d57
f0100c6f:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100c74:	68 64 02 00 00       	push   $0x264
f0100c79:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100c7e:	e8 08 f4 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100c83:	83 ec 0c             	sub    $0xc,%esp
f0100c86:	68 00 41 10 f0       	push   $0xf0104100
f0100c8b:	e8 90 1b 00 00       	call   f0102820 <cprintf>
}
f0100c90:	eb 29                	jmp    f0100cbb <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c92:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100c97:	85 c0                	test   %eax,%eax
f0100c99:	0f 85 8e fd ff ff    	jne    f0100a2d <check_page_free_list+0x2d>
f0100c9f:	e9 72 fd ff ff       	jmp    f0100a16 <check_page_free_list+0x16>
f0100ca4:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100cab:	0f 84 65 fd ff ff    	je     f0100a16 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cb1:	be 00 04 00 00       	mov    $0x400,%esi
f0100cb6:	e9 c0 fd ff ff       	jmp    f0100a7b <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cbe:	5b                   	pop    %ebx
f0100cbf:	5e                   	pop    %esi
f0100cc0:	5f                   	pop    %edi
f0100cc1:	5d                   	pop    %ebp
f0100cc2:	c3                   	ret    

f0100cc3 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cc3:	55                   	push   %ebp
f0100cc4:	89 e5                	mov    %esp,%ebp
f0100cc6:	56                   	push   %esi
f0100cc7:	53                   	push   %ebx
	// The example code here marks all physical pages as free.
	// However this is not truly the case.  What memory is free?
	//  1) Mark physical page 0 as in use.
	//     This way we preserve the real-mode IDT and BIOS structures
	//     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
f0100cc8:	a1 70 79 11 f0       	mov    0xf0117970,%eax
f0100ccd:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages [0].pp_link = NULL;
f0100cd3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	for (int i = 1; i < npages_basemem; i++)
f0100cd9:	8b 35 40 75 11 f0    	mov    0xf0117540,%esi
f0100cdf:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100ce5:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cea:	b8 01 00 00 00       	mov    $0x1,%eax
f0100cef:	eb 27                	jmp    f0100d18 <page_init+0x55>
f0100cf1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	{
		pages[i].pp_ref = 0;
f0100cf8:	89 d1                	mov    %edx,%ecx
f0100cfa:	03 0d 70 79 11 f0    	add    0xf0117970,%ecx
f0100d00:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d06:	89 19                	mov    %ebx,(%ecx)
	//     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
	pages [0].pp_link = NULL;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	for (int i = 1; i < npages_basemem; i++)
f0100d08:	83 c0 01             	add    $0x1,%eax
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages [i];
f0100d0b:	89 d3                	mov    %edx,%ebx
f0100d0d:	03 1d 70 79 11 f0    	add    0xf0117970,%ebx
f0100d13:	ba 01 00 00 00       	mov    $0x1,%edx
	//     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
	pages [0].pp_link = NULL;
	//  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	//     is free.
	for (int i = 1; i < npages_basemem; i++)
f0100d18:	39 c6                	cmp    %eax,%esi
f0100d1a:	77 d5                	ja     f0100cf1 <page_init+0x2e>
f0100d1c:	84 d2                	test   %dl,%dl
f0100d1e:	74 06                	je     f0100d26 <page_init+0x63>
f0100d20:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
		pages[i].pp_link = page_free_list;
		page_free_list = &pages [i];
	}
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
f0100d26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d2b:	e8 09 fc ff ff       	call   f0100939 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d30:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d35:	77 15                	ja     f0100d4c <page_init+0x89>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d37:	50                   	push   %eax
f0100d38:	68 24 41 10 f0       	push   $0xf0104124
f0100d3d:	68 0e 01 00 00       	push   $0x10e
f0100d42:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100d47:	e8 3f f3 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d4c:	05 00 00 00 10       	add    $0x10000000,%eax
	assert (free_pa % PGSIZE == 0);
f0100d51:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0100d56:	74 19                	je     f0100d71 <page_init+0xae>
f0100d58:	68 68 3d 10 f0       	push   $0xf0103d68
f0100d5d:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100d62:	68 0f 01 00 00       	push   $0x10f
f0100d67:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100d6c:	e8 1a f3 ff ff       	call   f010008b <_panic>
	uint32_t free_pa_index = free_pa / PGSIZE;
f0100d71:	c1 e8 0c             	shr    $0xc,%eax
	for (int i = npages_basemem; i < free_pa_index; i++)
f0100d74:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f0100d7a:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100d81:	eb 1a                	jmp    f0100d9d <page_init+0xda>
	{
		pages[i].pp_ref = 1;
f0100d83:	89 cb                	mov    %ecx,%ebx
f0100d85:	03 1d 70 79 11 f0    	add    0xf0117970,%ebx
f0100d8b:	66 c7 43 04 01 00    	movw   $0x1,0x4(%ebx)
		pages[i].pp_link = NULL;
f0100d91:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	//  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	//     never be allocated.
	uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
	assert (free_pa % PGSIZE == 0);
	uint32_t free_pa_index = free_pa / PGSIZE;
	for (int i = npages_basemem; i < free_pa_index; i++)
f0100d97:	83 c2 01             	add    $0x1,%edx
f0100d9a:	83 c1 08             	add    $0x8,%ecx
f0100d9d:	39 d0                	cmp    %edx,%eax
f0100d9f:	77 e2                	ja     f0100d83 <page_init+0xc0>
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	for (int i = free_pa_index; i < npages; i++)
f0100da1:	89 c2                	mov    %eax,%edx
f0100da3:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100da9:	c1 e0 03             	shl    $0x3,%eax
f0100dac:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100db1:	eb 23                	jmp    f0100dd6 <page_init+0x113>
	{
		pages[i].pp_ref = 0;
f0100db3:	89 c1                	mov    %eax,%ecx
f0100db5:	03 0d 70 79 11 f0    	add    0xf0117970,%ecx
f0100dbb:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100dc1:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100dc3:	89 c3                	mov    %eax,%ebx
f0100dc5:	03 1d 70 79 11 f0    	add    0xf0117970,%ebx
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	for (int i = free_pa_index; i < npages; i++)
f0100dcb:	83 c2 01             	add    $0x1,%edx
f0100dce:	83 c0 08             	add    $0x8,%eax
f0100dd1:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100dd6:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100ddc:	72 d5                	jb     f0100db3 <page_init+0xf0>
f0100dde:	84 c9                	test   %cl,%cl
f0100de0:	74 06                	je     f0100de8 <page_init+0x125>
f0100de2:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	}
f0100de8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100deb:	5b                   	pop    %ebx
f0100dec:	5e                   	pop    %esi
f0100ded:	5d                   	pop    %ebp
f0100dee:	c3                   	ret    

f0100def <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100def:	55                   	push   %ebp
f0100df0:	89 e5                	mov    %esp,%ebp
f0100df2:	53                   	push   %ebx
f0100df3:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

	struct PageInfo* allocate_page = page_free_list;
f0100df6:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
	if (allocate_page == NULL)
f0100dfc:	85 db                	test   %ebx,%ebx
f0100dfe:	74 5c                	je     f0100e5c <page_alloc+0x6d>
	return NULL;

	page_free_list = allocate_page -> pp_link;
f0100e00:	8b 03                	mov    (%ebx),%eax
f0100e02:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	allocate_page -> pp_link = NULL;
f0100e07:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO)
	memset (page2kva (allocate_page), 0, PGSIZE);

	return allocate_page;
f0100e0d:	89 d8                	mov    %ebx,%eax
	return NULL;

	page_free_list = allocate_page -> pp_link;
	allocate_page -> pp_link = NULL;

	if (alloc_flags & ALLOC_ZERO)
f0100e0f:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e13:	74 4c                	je     f0100e61 <page_alloc+0x72>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e15:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0100e1b:	c1 f8 03             	sar    $0x3,%eax
f0100e1e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e21:	89 c2                	mov    %eax,%edx
f0100e23:	c1 ea 0c             	shr    $0xc,%edx
f0100e26:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100e2c:	72 12                	jb     f0100e40 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e2e:	50                   	push   %eax
f0100e2f:	68 18 40 10 f0       	push   $0xf0104018
f0100e34:	6a 52                	push   $0x52
f0100e36:	68 be 3c 10 f0       	push   $0xf0103cbe
f0100e3b:	e8 4b f2 ff ff       	call   f010008b <_panic>
	memset (page2kva (allocate_page), 0, PGSIZE);
f0100e40:	83 ec 04             	sub    $0x4,%esp
f0100e43:	68 00 10 00 00       	push   $0x1000
f0100e48:	6a 00                	push   $0x0
f0100e4a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e4f:	50                   	push   %eax
f0100e50:	e8 8f 24 00 00       	call   f01032e4 <memset>
f0100e55:	83 c4 10             	add    $0x10,%esp

	return allocate_page;
f0100e58:	89 d8                	mov    %ebx,%eax
f0100e5a:	eb 05                	jmp    f0100e61 <page_alloc+0x72>
{
	// Fill this function in

	struct PageInfo* allocate_page = page_free_list;
	if (allocate_page == NULL)
	return NULL;
f0100e5c:	b8 00 00 00 00       	mov    $0x0,%eax

	if (alloc_flags & ALLOC_ZERO)
	memset (page2kva (allocate_page), 0, PGSIZE);

	return allocate_page;
}
f0100e61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e64:	c9                   	leave  
f0100e65:	c3                   	ret    

f0100e66 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e66:	55                   	push   %ebp
f0100e67:	89 e5                	mov    %esp,%ebp
f0100e69:	83 ec 08             	sub    $0x8,%esp
f0100e6c:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	assert (pp->pp_ref == 0);
f0100e6f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e74:	74 19                	je     f0100e8f <page_free+0x29>
f0100e76:	68 7e 3d 10 f0       	push   $0xf0103d7e
f0100e7b:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100e80:	68 50 01 00 00       	push   $0x150
f0100e85:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100e8a:	e8 fc f1 ff ff       	call   f010008b <_panic>
	assert (pp->pp_link == NULL);
f0100e8f:	83 38 00             	cmpl   $0x0,(%eax)
f0100e92:	74 19                	je     f0100ead <page_free+0x47>
f0100e94:	68 8e 3d 10 f0       	push   $0xf0103d8e
f0100e99:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100e9e:	68 51 01 00 00       	push   $0x151
f0100ea3:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100ea8:	e8 de f1 ff ff       	call   f010008b <_panic>

	pp->pp_ref = 0;
f0100ead:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pp->pp_link = page_free_list;
f0100eb3:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100eb9:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ebb:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
}
f0100ec0:	c9                   	leave  
f0100ec1:	c3                   	ret    

f0100ec2 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ec2:	55                   	push   %ebp
f0100ec3:	89 e5                	mov    %esp,%ebp
f0100ec5:	83 ec 08             	sub    $0x8,%esp
f0100ec8:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100ecb:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100ecf:	83 e8 01             	sub    $0x1,%eax
f0100ed2:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100ed6:	66 85 c0             	test   %ax,%ax
f0100ed9:	75 0c                	jne    f0100ee7 <page_decref+0x25>
		page_free(pp);
f0100edb:	83 ec 0c             	sub    $0xc,%esp
f0100ede:	52                   	push   %edx
f0100edf:	e8 82 ff ff ff       	call   f0100e66 <page_free>
f0100ee4:	83 c4 10             	add    $0x10,%esp
}
f0100ee7:	c9                   	leave  
f0100ee8:	c3                   	ret    

f0100ee9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ee9:	55                   	push   %ebp
f0100eea:	89 e5                	mov    %esp,%ebp
f0100eec:	56                   	push   %esi
f0100eed:	53                   	push   %ebx
f0100eee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	uintptr_t address = (uintptr_t) va;
	pde_t pde_offset = pgdir [PDX(address)];
f0100ef1:	89 de                	mov    %ebx,%esi
f0100ef3:	c1 ee 16             	shr    $0x16,%esi
f0100ef6:	c1 e6 02             	shl    $0x2,%esi
f0100ef9:	03 75 08             	add    0x8(%ebp),%esi
f0100efc:	8b 06                	mov    (%esi),%eax
	if (!(pde_offset & PTE_P) && create)
f0100efe:	89 c2                	mov    %eax,%edx
f0100f00:	83 e2 01             	and    $0x1,%edx
f0100f03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f07:	74 2d                	je     f0100f36 <pgdir_walk+0x4d>
f0100f09:	85 d2                	test   %edx,%edx
f0100f0b:	75 29                	jne    f0100f36 <pgdir_walk+0x4d>
	{
		struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
f0100f0d:	83 ec 0c             	sub    $0xc,%esp
f0100f10:	6a 01                	push   $0x1
f0100f12:	e8 d8 fe ff ff       	call   f0100def <page_alloc>
		if (!new_page) return NULL;
f0100f17:	83 c4 10             	add    $0x10,%esp
f0100f1a:	85 c0                	test   %eax,%eax
f0100f1c:	74 55                	je     f0100f73 <pgdir_walk+0x8a>

		new_page -> pp_ref ++;
f0100f1e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
f0100f23:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0100f29:	c1 f8 03             	sar    $0x3,%eax
f0100f2c:	c1 e0 0c             	shl    $0xc,%eax
f0100f2f:	83 c8 07             	or     $0x7,%eax
		pgdir [PDX(address)] = pde_offset;
f0100f32:	89 06                	mov    %eax,(%esi)
	// Fill this function in

	uintptr_t address = (uintptr_t) va;
	pde_t pde_offset = pgdir [PDX(address)];
	if (!(pde_offset & PTE_P) && create)
	{
f0100f34:	eb 04                	jmp    f0100f3a <pgdir_walk+0x51>
		if (!new_page) return NULL;

		new_page -> pp_ref ++;
		pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
		pgdir [PDX(address)] = pde_offset;
	} else if (!(pde_offset & PTE_P)) return NULL;
f0100f36:	85 d2                	test   %edx,%edx
f0100f38:	74 40                	je     f0100f7a <pgdir_walk+0x91>

	physaddr_t pt_pa = PTE_ADDR(pde_offset);
f0100f3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f3f:	89 c2                	mov    %eax,%edx
f0100f41:	c1 ea 0c             	shr    $0xc,%edx
f0100f44:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0100f4a:	72 15                	jb     f0100f61 <pgdir_walk+0x78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f4c:	50                   	push   %eax
f0100f4d:	68 18 40 10 f0       	push   $0xf0104018
f0100f52:	68 8b 01 00 00       	push   $0x18b
f0100f57:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100f5c:	e8 2a f1 ff ff       	call   f010008b <_panic>
	pte_t* pt_va = KADDR(pt_pa);
	return &pt_va [PTX(address)];
f0100f61:	c1 eb 0a             	shr    $0xa,%ebx
f0100f64:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f6a:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100f71:	eb 0c                	jmp    f0100f7f <pgdir_walk+0x96>
	uintptr_t address = (uintptr_t) va;
	pde_t pde_offset = pgdir [PDX(address)];
	if (!(pde_offset & PTE_P) && create)
	{
		struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
		if (!new_page) return NULL;
f0100f73:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f78:	eb 05                	jmp    f0100f7f <pgdir_walk+0x96>

		new_page -> pp_ref ++;
		pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
		pgdir [PDX(address)] = pde_offset;
	} else if (!(pde_offset & PTE_P)) return NULL;
f0100f7a:	b8 00 00 00 00       	mov    $0x0,%eax

	physaddr_t pt_pa = PTE_ADDR(pde_offset);
	pte_t* pt_va = KADDR(pt_pa);
	return &pt_va [PTX(address)];
}
f0100f7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f82:	5b                   	pop    %ebx
f0100f83:	5e                   	pop    %esi
f0100f84:	5d                   	pop    %ebp
f0100f85:	c3                   	ret    

f0100f86 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f86:	55                   	push   %ebp
f0100f87:	89 e5                	mov    %esp,%ebp
f0100f89:	57                   	push   %edi
f0100f8a:	56                   	push   %esi
f0100f8b:	53                   	push   %ebx
f0100f8c:	83 ec 1c             	sub    $0x1c,%esp
f0100f8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f92:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f95:	c1 e9 0c             	shr    $0xc,%ecx
f0100f98:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
/*
	if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
	panic ("boot_map_region cannot be executed \n");
*/
	uint32_t no_pages = size / PGSIZE;
	for (int i = 0; i < no_pages; i ++)
f0100f9b:	89 c3                	mov    %eax,%ebx
f0100f9d:	be 00 00 00 00       	mov    $0x0,%esi
	{
		pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f0100fa2:	89 d7                	mov    %edx,%edi
f0100fa4:	29 c7                	sub    %eax,%edi
		assert (pte_entry != NULL);
		*pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f0100fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa9:	83 c8 01             	or     $0x1,%eax
f0100fac:	89 45 dc             	mov    %eax,-0x24(%ebp)
/*
	if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
	panic ("boot_map_region cannot be executed \n");
*/
	uint32_t no_pages = size / PGSIZE;
	for (int i = 0; i < no_pages; i ++)
f0100faf:	eb 41                	jmp    f0100ff2 <boot_map_region+0x6c>
	{
		pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f0100fb1:	83 ec 04             	sub    $0x4,%esp
f0100fb4:	6a 01                	push   $0x1
f0100fb6:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0100fb9:	50                   	push   %eax
f0100fba:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fbd:	e8 27 ff ff ff       	call   f0100ee9 <pgdir_walk>
		assert (pte_entry != NULL);
f0100fc2:	83 c4 10             	add    $0x10,%esp
f0100fc5:	85 c0                	test   %eax,%eax
f0100fc7:	75 19                	jne    f0100fe2 <boot_map_region+0x5c>
f0100fc9:	68 a2 3d 10 f0       	push   $0xf0103da2
f0100fce:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0100fd3:	68 a6 01 00 00       	push   $0x1a6
f0100fd8:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0100fdd:	e8 a9 f0 ff ff       	call   f010008b <_panic>
		*pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f0100fe2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fe5:	09 da                	or     %ebx,%edx
f0100fe7:	89 10                	mov    %edx,(%eax)
/*
	if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
	panic ("boot_map_region cannot be executed \n");
*/
	uint32_t no_pages = size / PGSIZE;
	for (int i = 0; i < no_pages; i ++)
f0100fe9:	83 c6 01             	add    $0x1,%esi
f0100fec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100ff2:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100ff5:	75 ba                	jne    f0100fb1 <boot_map_region+0x2b>
	{
		pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
		assert (pte_entry != NULL);
		*pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
	}
}
f0100ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ffa:	5b                   	pop    %ebx
f0100ffb:	5e                   	pop    %esi
f0100ffc:	5f                   	pop    %edi
f0100ffd:	5d                   	pop    %ebp
f0100ffe:	c3                   	ret    

f0100fff <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fff:	55                   	push   %ebp
f0101000:	89 e5                	mov    %esp,%ebp
f0101002:	53                   	push   %ebx
f0101003:	83 ec 08             	sub    $0x8,%esp
f0101006:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in

	pte_t* pte_entry = pgdir_walk (pgdir, va, 0);
f0101009:	6a 00                	push   $0x0
f010100b:	ff 75 0c             	pushl  0xc(%ebp)
f010100e:	ff 75 08             	pushl  0x8(%ebp)
f0101011:	e8 d3 fe ff ff       	call   f0100ee9 <pgdir_walk>

	if (!pte_entry || !(*pte_entry & PTE_P))
f0101016:	83 c4 10             	add    $0x10,%esp
f0101019:	85 c0                	test   %eax,%eax
f010101b:	74 37                	je     f0101054 <page_lookup+0x55>
f010101d:	f6 00 01             	testb  $0x1,(%eax)
f0101020:	74 39                	je     f010105b <page_lookup+0x5c>
	return NULL;

	if (pte_store)
f0101022:	85 db                	test   %ebx,%ebx
f0101024:	74 02                	je     f0101028 <page_lookup+0x29>
	*pte_store = pte_entry;
f0101026:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101028:	8b 00                	mov    (%eax),%eax
f010102a:	c1 e8 0c             	shr    $0xc,%eax
f010102d:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f0101033:	72 14                	jb     f0101049 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101035:	83 ec 04             	sub    $0x4,%esp
f0101038:	68 48 41 10 f0       	push   $0xf0104148
f010103d:	6a 4b                	push   $0x4b
f010103f:	68 be 3c 10 f0       	push   $0xf0103cbe
f0101044:	e8 42 f0 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0101049:	8b 15 70 79 11 f0    	mov    0xf0117970,%edx
f010104f:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte_entry));
f0101052:	eb 0c                	jmp    f0101060 <page_lookup+0x61>
	// Fill this function in

	pte_t* pte_entry = pgdir_walk (pgdir, va, 0);

	if (!pte_entry || !(*pte_entry & PTE_P))
	return NULL;
f0101054:	b8 00 00 00 00       	mov    $0x0,%eax
f0101059:	eb 05                	jmp    f0101060 <page_lookup+0x61>
f010105b:	b8 00 00 00 00       	mov    $0x0,%eax

	if (pte_store)
	*pte_store = pte_entry;

	return pa2page(PTE_ADDR(*pte_entry));
}
f0101060:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101063:	c9                   	leave  
f0101064:	c3                   	ret    

f0101065 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101065:	55                   	push   %ebp
f0101066:	89 e5                	mov    %esp,%ebp
f0101068:	53                   	push   %ebx
f0101069:	83 ec 18             	sub    $0x18,%esp
f010106c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in

	pte_t* pte_address = NULL;
f010106f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo* pp = page_lookup (pgdir, va, &pte_address);
f0101076:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101079:	50                   	push   %eax
f010107a:	53                   	push   %ebx
f010107b:	ff 75 08             	pushl  0x8(%ebp)
f010107e:	e8 7c ff ff ff       	call   f0100fff <page_lookup>
	if (!pp)
f0101083:	83 c4 10             	add    $0x10,%esp
f0101086:	85 c0                	test   %eax,%eax
f0101088:	74 18                	je     f01010a2 <page_remove+0x3d>
	return;

	*pte_address = 0;
f010108a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010108d:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(pp);
f0101093:	83 ec 0c             	sub    $0xc,%esp
f0101096:	50                   	push   %eax
f0101097:	e8 26 fe ff ff       	call   f0100ec2 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010109c:	0f 01 3b             	invlpg (%ebx)
f010109f:	83 c4 10             	add    $0x10,%esp
	tlb_invalidate (pgdir, va);

}
f01010a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010a5:	c9                   	leave  
f01010a6:	c3                   	ret    

f01010a7 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010a7:	55                   	push   %ebp
f01010a8:	89 e5                	mov    %esp,%ebp
f01010aa:	57                   	push   %edi
f01010ab:	56                   	push   %esi
f01010ac:	53                   	push   %ebx
f01010ad:	83 ec 10             	sub    $0x10,%esp
f01010b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010b3:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in

	pte_t* pte_entry = pgdir_walk (pgdir, va, true);
f01010b6:	6a 01                	push   $0x1
f01010b8:	57                   	push   %edi
f01010b9:	ff 75 08             	pushl  0x8(%ebp)
f01010bc:	e8 28 fe ff ff       	call   f0100ee9 <pgdir_walk>

	if (!pte_entry) return -E_NO_MEM;
f01010c1:	83 c4 10             	add    $0x10,%esp
f01010c4:	85 c0                	test   %eax,%eax
f01010c6:	0f 84 96 00 00 00    	je     f0101162 <page_insert+0xbb>
f01010cc:	89 c6                	mov    %eax,%esi

	if (PTE_ADDR(*pte_entry) == page2pa (pp))
f01010ce:	8b 10                	mov    (%eax),%edx
f01010d0:	89 d1                	mov    %edx,%ecx
f01010d2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01010d8:	89 d8                	mov    %ebx,%eax
f01010da:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01010e0:	c1 f8 03             	sar    $0x3,%eax
f01010e3:	c1 e0 0c             	shl    $0xc,%eax
f01010e6:	39 c1                	cmp    %eax,%ecx
f01010e8:	75 24                	jne    f010110e <page_insert+0x67>
	{
		if ((*pte_entry & 0x1FF) == perm) return 0;
f01010ea:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
f01010f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01010f5:	3b 55 14             	cmp    0x14(%ebp),%edx
f01010f8:	74 6d                	je     f0101167 <page_insert+0xc0>

		*pte_entry = page2pa (pp) | perm | PTE_P;
f01010fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fd:	83 c8 01             	or     $0x1,%eax
f0101100:	09 c1                	or     %eax,%ecx
f0101102:	89 0e                	mov    %ecx,(%esi)
f0101104:	0f 01 3f             	invlpg (%edi)
		tlb_invalidate (pgdir, va);
		return 0;
f0101107:	b8 00 00 00 00       	mov    $0x0,%eax
f010110c:	eb 59                	jmp    f0101167 <page_insert+0xc0>
	}

	if (*pte_entry & PTE_P)
f010110e:	f6 c2 01             	test   $0x1,%dl
f0101111:	74 2d                	je     f0101140 <page_insert+0x99>
	{
		page_remove (pgdir, va);
f0101113:	83 ec 08             	sub    $0x8,%esp
f0101116:	57                   	push   %edi
f0101117:	ff 75 08             	pushl  0x8(%ebp)
f010111a:	e8 46 ff ff ff       	call   f0101065 <page_remove>
		assert (*pte_entry ==0);
f010111f:	83 c4 10             	add    $0x10,%esp
f0101122:	83 3e 00             	cmpl   $0x0,(%esi)
f0101125:	74 19                	je     f0101140 <page_insert+0x99>
f0101127:	68 b4 3d 10 f0       	push   $0xf0103db4
f010112c:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101131:	68 d9 01 00 00       	push   $0x1d9
f0101136:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010113b:	e8 4b ef ff ff       	call   f010008b <_panic>
	}

	pp -> pp_ref ++;
f0101140:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	*pte_entry = page2pa (pp) | perm | PTE_P;
f0101145:	2b 1d 70 79 11 f0    	sub    0xf0117970,%ebx
f010114b:	c1 fb 03             	sar    $0x3,%ebx
f010114e:	c1 e3 0c             	shl    $0xc,%ebx
f0101151:	8b 45 14             	mov    0x14(%ebp),%eax
f0101154:	83 c8 01             	or     $0x1,%eax
f0101157:	09 c3                	or     %eax,%ebx
f0101159:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010115b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101160:	eb 05                	jmp    f0101167 <page_insert+0xc0>
{
	// Fill this function in

	pte_t* pte_entry = pgdir_walk (pgdir, va, true);

	if (!pte_entry) return -E_NO_MEM;
f0101162:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}

	pp -> pp_ref ++;
	*pte_entry = page2pa (pp) | perm | PTE_P;
	return 0;
	}
f0101167:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010116a:	5b                   	pop    %ebx
f010116b:	5e                   	pop    %esi
f010116c:	5f                   	pop    %edi
f010116d:	5d                   	pop    %ebp
f010116e:	c3                   	ret    

f010116f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010116f:	55                   	push   %ebp
f0101170:	89 e5                	mov    %esp,%ebp
f0101172:	57                   	push   %edi
f0101173:	56                   	push   %esi
f0101174:	53                   	push   %ebx
f0101175:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101178:	b8 15 00 00 00       	mov    $0x15,%eax
f010117d:	e8 8e f7 ff ff       	call   f0100910 <nvram_read>
f0101182:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101184:	b8 17 00 00 00       	mov    $0x17,%eax
f0101189:	e8 82 f7 ff ff       	call   f0100910 <nvram_read>
f010118e:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101190:	b8 34 00 00 00       	mov    $0x34,%eax
f0101195:	e8 76 f7 ff ff       	call   f0100910 <nvram_read>
f010119a:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010119d:	85 c0                	test   %eax,%eax
f010119f:	74 07                	je     f01011a8 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01011a1:	05 00 40 00 00       	add    $0x4000,%eax
f01011a6:	eb 0b                	jmp    f01011b3 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01011a8:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01011ae:	85 f6                	test   %esi,%esi
f01011b0:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01011b3:	89 c2                	mov    %eax,%edx
f01011b5:	c1 ea 02             	shr    $0x2,%edx
f01011b8:	89 15 68 79 11 f0    	mov    %edx,0xf0117968
	npages_basemem = basemem / (PGSIZE / 1024);
f01011be:	89 da                	mov    %ebx,%edx
f01011c0:	c1 ea 02             	shr    $0x2,%edx
f01011c3:	89 15 40 75 11 f0    	mov    %edx,0xf0117540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c9:	89 c2                	mov    %eax,%edx
f01011cb:	29 da                	sub    %ebx,%edx
f01011cd:	52                   	push   %edx
f01011ce:	53                   	push   %ebx
f01011cf:	50                   	push   %eax
f01011d0:	68 68 41 10 f0       	push   $0xf0104168
f01011d5:	e8 46 16 00 00       	call   f0102820 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011da:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011df:	e8 55 f7 ff ff       	call   f0100939 <boot_alloc>
f01011e4:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(kern_pgdir, 0, PGSIZE);
f01011e9:	83 c4 0c             	add    $0xc,%esp
f01011ec:	68 00 10 00 00       	push   $0x1000
f01011f1:	6a 00                	push   $0x0
f01011f3:	50                   	push   %eax
f01011f4:	e8 eb 20 00 00       	call   f01032e4 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011f9:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011fe:	83 c4 10             	add    $0x10,%esp
f0101201:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101206:	77 15                	ja     f010121d <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101208:	50                   	push   %eax
f0101209:	68 24 41 10 f0       	push   $0xf0104124
f010120e:	68 97 00 00 00       	push   $0x97
f0101213:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101218:	e8 6e ee ff ff       	call   f010008b <_panic>
f010121d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101223:	83 ca 05             	or     $0x5,%edx
f0101226:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *) boot_alloc(npages * sizeof (struct PageInfo));
f010122c:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101231:	c1 e0 03             	shl    $0x3,%eax
f0101234:	e8 00 f7 ff ff       	call   f0100939 <boot_alloc>
f0101239:	a3 70 79 11 f0       	mov    %eax,0xf0117970
	memset (pages, 0, npages * sizeof(struct PageInfo));
f010123e:	83 ec 04             	sub    $0x4,%esp
f0101241:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0101247:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010124e:	52                   	push   %edx
f010124f:	6a 00                	push   $0x0
f0101251:	50                   	push   %eax
f0101252:	e8 8d 20 00 00       	call   f01032e4 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101257:	e8 67 fa ff ff       	call   f0100cc3 <page_init>

	check_page_free_list(1);
f010125c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101261:	e8 9a f7 ff ff       	call   f0100a00 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101266:	83 c4 10             	add    $0x10,%esp
f0101269:	83 3d 70 79 11 f0 00 	cmpl   $0x0,0xf0117970
f0101270:	75 17                	jne    f0101289 <mem_init+0x11a>
		panic("'pages' is a null pointer!");
f0101272:	83 ec 04             	sub    $0x4,%esp
f0101275:	68 c3 3d 10 f0       	push   $0xf0103dc3
f010127a:	68 77 02 00 00       	push   $0x277
f010127f:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101284:	e8 02 ee ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101289:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010128e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101293:	eb 05                	jmp    f010129a <mem_init+0x12b>
		++nfree;
f0101295:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101298:	8b 00                	mov    (%eax),%eax
f010129a:	85 c0                	test   %eax,%eax
f010129c:	75 f7                	jne    f0101295 <mem_init+0x126>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010129e:	83 ec 0c             	sub    $0xc,%esp
f01012a1:	6a 00                	push   $0x0
f01012a3:	e8 47 fb ff ff       	call   f0100def <page_alloc>
f01012a8:	89 c7                	mov    %eax,%edi
f01012aa:	83 c4 10             	add    $0x10,%esp
f01012ad:	85 c0                	test   %eax,%eax
f01012af:	75 19                	jne    f01012ca <mem_init+0x15b>
f01012b1:	68 de 3d 10 f0       	push   $0xf0103dde
f01012b6:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01012bb:	68 7f 02 00 00       	push   $0x27f
f01012c0:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01012c5:	e8 c1 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01012ca:	83 ec 0c             	sub    $0xc,%esp
f01012cd:	6a 00                	push   $0x0
f01012cf:	e8 1b fb ff ff       	call   f0100def <page_alloc>
f01012d4:	89 c6                	mov    %eax,%esi
f01012d6:	83 c4 10             	add    $0x10,%esp
f01012d9:	85 c0                	test   %eax,%eax
f01012db:	75 19                	jne    f01012f6 <mem_init+0x187>
f01012dd:	68 f4 3d 10 f0       	push   $0xf0103df4
f01012e2:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01012e7:	68 80 02 00 00       	push   $0x280
f01012ec:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01012f1:	e8 95 ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01012f6:	83 ec 0c             	sub    $0xc,%esp
f01012f9:	6a 00                	push   $0x0
f01012fb:	e8 ef fa ff ff       	call   f0100def <page_alloc>
f0101300:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101303:	83 c4 10             	add    $0x10,%esp
f0101306:	85 c0                	test   %eax,%eax
f0101308:	75 19                	jne    f0101323 <mem_init+0x1b4>
f010130a:	68 0a 3e 10 f0       	push   $0xf0103e0a
f010130f:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101314:	68 81 02 00 00       	push   $0x281
f0101319:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010131e:	e8 68 ed ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101323:	39 f7                	cmp    %esi,%edi
f0101325:	75 19                	jne    f0101340 <mem_init+0x1d1>
f0101327:	68 20 3e 10 f0       	push   $0xf0103e20
f010132c:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101331:	68 84 02 00 00       	push   $0x284
f0101336:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010133b:	e8 4b ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101340:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101343:	39 c6                	cmp    %eax,%esi
f0101345:	74 04                	je     f010134b <mem_init+0x1dc>
f0101347:	39 c7                	cmp    %eax,%edi
f0101349:	75 19                	jne    f0101364 <mem_init+0x1f5>
f010134b:	68 a4 41 10 f0       	push   $0xf01041a4
f0101350:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101355:	68 85 02 00 00       	push   $0x285
f010135a:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010135f:	e8 27 ed ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101364:	8b 0d 70 79 11 f0    	mov    0xf0117970,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010136a:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101370:	c1 e2 0c             	shl    $0xc,%edx
f0101373:	89 f8                	mov    %edi,%eax
f0101375:	29 c8                	sub    %ecx,%eax
f0101377:	c1 f8 03             	sar    $0x3,%eax
f010137a:	c1 e0 0c             	shl    $0xc,%eax
f010137d:	39 d0                	cmp    %edx,%eax
f010137f:	72 19                	jb     f010139a <mem_init+0x22b>
f0101381:	68 32 3e 10 f0       	push   $0xf0103e32
f0101386:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010138b:	68 86 02 00 00       	push   $0x286
f0101390:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101395:	e8 f1 ec ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010139a:	89 f0                	mov    %esi,%eax
f010139c:	29 c8                	sub    %ecx,%eax
f010139e:	c1 f8 03             	sar    $0x3,%eax
f01013a1:	c1 e0 0c             	shl    $0xc,%eax
f01013a4:	39 c2                	cmp    %eax,%edx
f01013a6:	77 19                	ja     f01013c1 <mem_init+0x252>
f01013a8:	68 4f 3e 10 f0       	push   $0xf0103e4f
f01013ad:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01013b2:	68 87 02 00 00       	push   $0x287
f01013b7:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01013bc:	e8 ca ec ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01013c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013c4:	29 c8                	sub    %ecx,%eax
f01013c6:	c1 f8 03             	sar    $0x3,%eax
f01013c9:	c1 e0 0c             	shl    $0xc,%eax
f01013cc:	39 c2                	cmp    %eax,%edx
f01013ce:	77 19                	ja     f01013e9 <mem_init+0x27a>
f01013d0:	68 6c 3e 10 f0       	push   $0xf0103e6c
f01013d5:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01013da:	68 88 02 00 00       	push   $0x288
f01013df:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01013e4:	e8 a2 ec ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013e9:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01013ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013f1:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01013f8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013fb:	83 ec 0c             	sub    $0xc,%esp
f01013fe:	6a 00                	push   $0x0
f0101400:	e8 ea f9 ff ff       	call   f0100def <page_alloc>
f0101405:	83 c4 10             	add    $0x10,%esp
f0101408:	85 c0                	test   %eax,%eax
f010140a:	74 19                	je     f0101425 <mem_init+0x2b6>
f010140c:	68 89 3e 10 f0       	push   $0xf0103e89
f0101411:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101416:	68 8f 02 00 00       	push   $0x28f
f010141b:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101420:	e8 66 ec ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101425:	83 ec 0c             	sub    $0xc,%esp
f0101428:	57                   	push   %edi
f0101429:	e8 38 fa ff ff       	call   f0100e66 <page_free>
	page_free(pp1);
f010142e:	89 34 24             	mov    %esi,(%esp)
f0101431:	e8 30 fa ff ff       	call   f0100e66 <page_free>
	page_free(pp2);
f0101436:	83 c4 04             	add    $0x4,%esp
f0101439:	ff 75 d4             	pushl  -0x2c(%ebp)
f010143c:	e8 25 fa ff ff       	call   f0100e66 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101448:	e8 a2 f9 ff ff       	call   f0100def <page_alloc>
f010144d:	89 c6                	mov    %eax,%esi
f010144f:	83 c4 10             	add    $0x10,%esp
f0101452:	85 c0                	test   %eax,%eax
f0101454:	75 19                	jne    f010146f <mem_init+0x300>
f0101456:	68 de 3d 10 f0       	push   $0xf0103dde
f010145b:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101460:	68 96 02 00 00       	push   $0x296
f0101465:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010146a:	e8 1c ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f010146f:	83 ec 0c             	sub    $0xc,%esp
f0101472:	6a 00                	push   $0x0
f0101474:	e8 76 f9 ff ff       	call   f0100def <page_alloc>
f0101479:	89 c7                	mov    %eax,%edi
f010147b:	83 c4 10             	add    $0x10,%esp
f010147e:	85 c0                	test   %eax,%eax
f0101480:	75 19                	jne    f010149b <mem_init+0x32c>
f0101482:	68 f4 3d 10 f0       	push   $0xf0103df4
f0101487:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010148c:	68 97 02 00 00       	push   $0x297
f0101491:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101496:	e8 f0 eb ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010149b:	83 ec 0c             	sub    $0xc,%esp
f010149e:	6a 00                	push   $0x0
f01014a0:	e8 4a f9 ff ff       	call   f0100def <page_alloc>
f01014a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014a8:	83 c4 10             	add    $0x10,%esp
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	75 19                	jne    f01014c8 <mem_init+0x359>
f01014af:	68 0a 3e 10 f0       	push   $0xf0103e0a
f01014b4:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01014b9:	68 98 02 00 00       	push   $0x298
f01014be:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01014c3:	e8 c3 eb ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014c8:	39 fe                	cmp    %edi,%esi
f01014ca:	75 19                	jne    f01014e5 <mem_init+0x376>
f01014cc:	68 20 3e 10 f0       	push   $0xf0103e20
f01014d1:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01014d6:	68 9a 02 00 00       	push   $0x29a
f01014db:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01014e0:	e8 a6 eb ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e8:	39 c7                	cmp    %eax,%edi
f01014ea:	74 04                	je     f01014f0 <mem_init+0x381>
f01014ec:	39 c6                	cmp    %eax,%esi
f01014ee:	75 19                	jne    f0101509 <mem_init+0x39a>
f01014f0:	68 a4 41 10 f0       	push   $0xf01041a4
f01014f5:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01014fa:	68 9b 02 00 00       	push   $0x29b
f01014ff:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101504:	e8 82 eb ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101509:	83 ec 0c             	sub    $0xc,%esp
f010150c:	6a 00                	push   $0x0
f010150e:	e8 dc f8 ff ff       	call   f0100def <page_alloc>
f0101513:	83 c4 10             	add    $0x10,%esp
f0101516:	85 c0                	test   %eax,%eax
f0101518:	74 19                	je     f0101533 <mem_init+0x3c4>
f010151a:	68 89 3e 10 f0       	push   $0xf0103e89
f010151f:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101524:	68 9c 02 00 00       	push   $0x29c
f0101529:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010152e:	e8 58 eb ff ff       	call   f010008b <_panic>
f0101533:	89 f0                	mov    %esi,%eax
f0101535:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010153b:	c1 f8 03             	sar    $0x3,%eax
f010153e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101541:	89 c2                	mov    %eax,%edx
f0101543:	c1 ea 0c             	shr    $0xc,%edx
f0101546:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f010154c:	72 12                	jb     f0101560 <mem_init+0x3f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010154e:	50                   	push   %eax
f010154f:	68 18 40 10 f0       	push   $0xf0104018
f0101554:	6a 52                	push   $0x52
f0101556:	68 be 3c 10 f0       	push   $0xf0103cbe
f010155b:	e8 2b eb ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101560:	83 ec 04             	sub    $0x4,%esp
f0101563:	68 00 10 00 00       	push   $0x1000
f0101568:	6a 01                	push   $0x1
f010156a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010156f:	50                   	push   %eax
f0101570:	e8 6f 1d 00 00       	call   f01032e4 <memset>
	page_free(pp0);
f0101575:	89 34 24             	mov    %esi,(%esp)
f0101578:	e8 e9 f8 ff ff       	call   f0100e66 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010157d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101584:	e8 66 f8 ff ff       	call   f0100def <page_alloc>
f0101589:	83 c4 10             	add    $0x10,%esp
f010158c:	85 c0                	test   %eax,%eax
f010158e:	75 19                	jne    f01015a9 <mem_init+0x43a>
f0101590:	68 98 3e 10 f0       	push   $0xf0103e98
f0101595:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010159a:	68 a1 02 00 00       	push   $0x2a1
f010159f:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01015a4:	e8 e2 ea ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01015a9:	39 c6                	cmp    %eax,%esi
f01015ab:	74 19                	je     f01015c6 <mem_init+0x457>
f01015ad:	68 b6 3e 10 f0       	push   $0xf0103eb6
f01015b2:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01015b7:	68 a2 02 00 00       	push   $0x2a2
f01015bc:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01015c1:	e8 c5 ea ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015c6:	89 f0                	mov    %esi,%eax
f01015c8:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01015ce:	c1 f8 03             	sar    $0x3,%eax
f01015d1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015d4:	89 c2                	mov    %eax,%edx
f01015d6:	c1 ea 0c             	shr    $0xc,%edx
f01015d9:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01015df:	72 12                	jb     f01015f3 <mem_init+0x484>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015e1:	50                   	push   %eax
f01015e2:	68 18 40 10 f0       	push   $0xf0104018
f01015e7:	6a 52                	push   $0x52
f01015e9:	68 be 3c 10 f0       	push   $0xf0103cbe
f01015ee:	e8 98 ea ff ff       	call   f010008b <_panic>
f01015f3:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015f9:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01015ff:	80 38 00             	cmpb   $0x0,(%eax)
f0101602:	74 19                	je     f010161d <mem_init+0x4ae>
f0101604:	68 c6 3e 10 f0       	push   $0xf0103ec6
f0101609:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010160e:	68 a5 02 00 00       	push   $0x2a5
f0101613:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101618:	e8 6e ea ff ff       	call   f010008b <_panic>
f010161d:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101620:	39 d0                	cmp    %edx,%eax
f0101622:	75 db                	jne    f01015ff <mem_init+0x490>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101624:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101627:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f010162c:	83 ec 0c             	sub    $0xc,%esp
f010162f:	56                   	push   %esi
f0101630:	e8 31 f8 ff ff       	call   f0100e66 <page_free>
	page_free(pp1);
f0101635:	89 3c 24             	mov    %edi,(%esp)
f0101638:	e8 29 f8 ff ff       	call   f0100e66 <page_free>
	page_free(pp2);
f010163d:	83 c4 04             	add    $0x4,%esp
f0101640:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101643:	e8 1e f8 ff ff       	call   f0100e66 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101648:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010164d:	83 c4 10             	add    $0x10,%esp
f0101650:	eb 05                	jmp    f0101657 <mem_init+0x4e8>
		--nfree;
f0101652:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101655:	8b 00                	mov    (%eax),%eax
f0101657:	85 c0                	test   %eax,%eax
f0101659:	75 f7                	jne    f0101652 <mem_init+0x4e3>
		--nfree;
	assert(nfree == 0);
f010165b:	85 db                	test   %ebx,%ebx
f010165d:	74 19                	je     f0101678 <mem_init+0x509>
f010165f:	68 d0 3e 10 f0       	push   $0xf0103ed0
f0101664:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101669:	68 b2 02 00 00       	push   $0x2b2
f010166e:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101673:	e8 13 ea ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101678:	83 ec 0c             	sub    $0xc,%esp
f010167b:	68 c4 41 10 f0       	push   $0xf01041c4
f0101680:	e8 9b 11 00 00       	call   f0102820 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101685:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010168c:	e8 5e f7 ff ff       	call   f0100def <page_alloc>
f0101691:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101694:	83 c4 10             	add    $0x10,%esp
f0101697:	85 c0                	test   %eax,%eax
f0101699:	75 19                	jne    f01016b4 <mem_init+0x545>
f010169b:	68 de 3d 10 f0       	push   $0xf0103dde
f01016a0:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01016a5:	68 0b 03 00 00       	push   $0x30b
f01016aa:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01016af:	e8 d7 e9 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01016b4:	83 ec 0c             	sub    $0xc,%esp
f01016b7:	6a 00                	push   $0x0
f01016b9:	e8 31 f7 ff ff       	call   f0100def <page_alloc>
f01016be:	89 c3                	mov    %eax,%ebx
f01016c0:	83 c4 10             	add    $0x10,%esp
f01016c3:	85 c0                	test   %eax,%eax
f01016c5:	75 19                	jne    f01016e0 <mem_init+0x571>
f01016c7:	68 f4 3d 10 f0       	push   $0xf0103df4
f01016cc:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01016d1:	68 0c 03 00 00       	push   $0x30c
f01016d6:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01016db:	e8 ab e9 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01016e0:	83 ec 0c             	sub    $0xc,%esp
f01016e3:	6a 00                	push   $0x0
f01016e5:	e8 05 f7 ff ff       	call   f0100def <page_alloc>
f01016ea:	89 c6                	mov    %eax,%esi
f01016ec:	83 c4 10             	add    $0x10,%esp
f01016ef:	85 c0                	test   %eax,%eax
f01016f1:	75 19                	jne    f010170c <mem_init+0x59d>
f01016f3:	68 0a 3e 10 f0       	push   $0xf0103e0a
f01016f8:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01016fd:	68 0d 03 00 00       	push   $0x30d
f0101702:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101707:	e8 7f e9 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010170c:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010170f:	75 19                	jne    f010172a <mem_init+0x5bb>
f0101711:	68 20 3e 10 f0       	push   $0xf0103e20
f0101716:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010171b:	68 10 03 00 00       	push   $0x310
f0101720:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101725:	e8 61 e9 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010172a:	39 c3                	cmp    %eax,%ebx
f010172c:	74 05                	je     f0101733 <mem_init+0x5c4>
f010172e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101731:	75 19                	jne    f010174c <mem_init+0x5dd>
f0101733:	68 a4 41 10 f0       	push   $0xf01041a4
f0101738:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010173d:	68 11 03 00 00       	push   $0x311
f0101742:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101747:	e8 3f e9 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010174c:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101751:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101754:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f010175b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010175e:	83 ec 0c             	sub    $0xc,%esp
f0101761:	6a 00                	push   $0x0
f0101763:	e8 87 f6 ff ff       	call   f0100def <page_alloc>
f0101768:	83 c4 10             	add    $0x10,%esp
f010176b:	85 c0                	test   %eax,%eax
f010176d:	74 19                	je     f0101788 <mem_init+0x619>
f010176f:	68 89 3e 10 f0       	push   $0xf0103e89
f0101774:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101779:	68 18 03 00 00       	push   $0x318
f010177e:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101783:	e8 03 e9 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101788:	83 ec 04             	sub    $0x4,%esp
f010178b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010178e:	50                   	push   %eax
f010178f:	6a 00                	push   $0x0
f0101791:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101797:	e8 63 f8 ff ff       	call   f0100fff <page_lookup>
f010179c:	83 c4 10             	add    $0x10,%esp
f010179f:	85 c0                	test   %eax,%eax
f01017a1:	74 19                	je     f01017bc <mem_init+0x64d>
f01017a3:	68 e4 41 10 f0       	push   $0xf01041e4
f01017a8:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01017ad:	68 1b 03 00 00       	push   $0x31b
f01017b2:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01017b7:	e8 cf e8 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017bc:	6a 02                	push   $0x2
f01017be:	6a 00                	push   $0x0
f01017c0:	53                   	push   %ebx
f01017c1:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01017c7:	e8 db f8 ff ff       	call   f01010a7 <page_insert>
f01017cc:	83 c4 10             	add    $0x10,%esp
f01017cf:	85 c0                	test   %eax,%eax
f01017d1:	78 19                	js     f01017ec <mem_init+0x67d>
f01017d3:	68 1c 42 10 f0       	push   $0xf010421c
f01017d8:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01017dd:	68 1e 03 00 00       	push   $0x31e
f01017e2:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01017e7:	e8 9f e8 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017ec:	83 ec 0c             	sub    $0xc,%esp
f01017ef:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017f2:	e8 6f f6 ff ff       	call   f0100e66 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017f7:	6a 02                	push   $0x2
f01017f9:	6a 00                	push   $0x0
f01017fb:	53                   	push   %ebx
f01017fc:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101802:	e8 a0 f8 ff ff       	call   f01010a7 <page_insert>
f0101807:	83 c4 20             	add    $0x20,%esp
f010180a:	85 c0                	test   %eax,%eax
f010180c:	74 19                	je     f0101827 <mem_init+0x6b8>
f010180e:	68 4c 42 10 f0       	push   $0xf010424c
f0101813:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101818:	68 22 03 00 00       	push   $0x322
f010181d:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101822:	e8 64 e8 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101827:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010182d:	a1 70 79 11 f0       	mov    0xf0117970,%eax
f0101832:	89 c1                	mov    %eax,%ecx
f0101834:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101837:	8b 17                	mov    (%edi),%edx
f0101839:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010183f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101842:	29 c8                	sub    %ecx,%eax
f0101844:	c1 f8 03             	sar    $0x3,%eax
f0101847:	c1 e0 0c             	shl    $0xc,%eax
f010184a:	39 c2                	cmp    %eax,%edx
f010184c:	74 19                	je     f0101867 <mem_init+0x6f8>
f010184e:	68 7c 42 10 f0       	push   $0xf010427c
f0101853:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101858:	68 23 03 00 00       	push   $0x323
f010185d:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101862:	e8 24 e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101867:	ba 00 00 00 00       	mov    $0x0,%edx
f010186c:	89 f8                	mov    %edi,%eax
f010186e:	e8 29 f1 ff ff       	call   f010099c <check_va2pa>
f0101873:	89 da                	mov    %ebx,%edx
f0101875:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101878:	c1 fa 03             	sar    $0x3,%edx
f010187b:	c1 e2 0c             	shl    $0xc,%edx
f010187e:	39 d0                	cmp    %edx,%eax
f0101880:	74 19                	je     f010189b <mem_init+0x72c>
f0101882:	68 a4 42 10 f0       	push   $0xf01042a4
f0101887:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010188c:	68 24 03 00 00       	push   $0x324
f0101891:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101896:	e8 f0 e7 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f010189b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018a0:	74 19                	je     f01018bb <mem_init+0x74c>
f01018a2:	68 db 3e 10 f0       	push   $0xf0103edb
f01018a7:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01018ac:	68 25 03 00 00       	push   $0x325
f01018b1:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01018b6:	e8 d0 e7 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01018bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018be:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01018c3:	74 19                	je     f01018de <mem_init+0x76f>
f01018c5:	68 ec 3e 10 f0       	push   $0xf0103eec
f01018ca:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01018cf:	68 26 03 00 00       	push   $0x326
f01018d4:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01018d9:	e8 ad e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018de:	6a 02                	push   $0x2
f01018e0:	68 00 10 00 00       	push   $0x1000
f01018e5:	56                   	push   %esi
f01018e6:	57                   	push   %edi
f01018e7:	e8 bb f7 ff ff       	call   f01010a7 <page_insert>
f01018ec:	83 c4 10             	add    $0x10,%esp
f01018ef:	85 c0                	test   %eax,%eax
f01018f1:	74 19                	je     f010190c <mem_init+0x79d>
f01018f3:	68 d4 42 10 f0       	push   $0xf01042d4
f01018f8:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01018fd:	68 29 03 00 00       	push   $0x329
f0101902:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101907:	e8 7f e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010190c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101911:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101916:	e8 81 f0 ff ff       	call   f010099c <check_va2pa>
f010191b:	89 f2                	mov    %esi,%edx
f010191d:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101923:	c1 fa 03             	sar    $0x3,%edx
f0101926:	c1 e2 0c             	shl    $0xc,%edx
f0101929:	39 d0                	cmp    %edx,%eax
f010192b:	74 19                	je     f0101946 <mem_init+0x7d7>
f010192d:	68 10 43 10 f0       	push   $0xf0104310
f0101932:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101937:	68 2a 03 00 00       	push   $0x32a
f010193c:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101941:	e8 45 e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101946:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010194b:	74 19                	je     f0101966 <mem_init+0x7f7>
f010194d:	68 fd 3e 10 f0       	push   $0xf0103efd
f0101952:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101957:	68 2b 03 00 00       	push   $0x32b
f010195c:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101961:	e8 25 e7 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101966:	83 ec 0c             	sub    $0xc,%esp
f0101969:	6a 00                	push   $0x0
f010196b:	e8 7f f4 ff ff       	call   f0100def <page_alloc>
f0101970:	83 c4 10             	add    $0x10,%esp
f0101973:	85 c0                	test   %eax,%eax
f0101975:	74 19                	je     f0101990 <mem_init+0x821>
f0101977:	68 89 3e 10 f0       	push   $0xf0103e89
f010197c:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101981:	68 2e 03 00 00       	push   $0x32e
f0101986:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010198b:	e8 fb e6 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101990:	6a 02                	push   $0x2
f0101992:	68 00 10 00 00       	push   $0x1000
f0101997:	56                   	push   %esi
f0101998:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010199e:	e8 04 f7 ff ff       	call   f01010a7 <page_insert>
f01019a3:	83 c4 10             	add    $0x10,%esp
f01019a6:	85 c0                	test   %eax,%eax
f01019a8:	74 19                	je     f01019c3 <mem_init+0x854>
f01019aa:	68 d4 42 10 f0       	push   $0xf01042d4
f01019af:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01019b4:	68 31 03 00 00       	push   $0x331
f01019b9:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01019be:	e8 c8 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019c3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019c8:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f01019cd:	e8 ca ef ff ff       	call   f010099c <check_va2pa>
f01019d2:	89 f2                	mov    %esi,%edx
f01019d4:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f01019da:	c1 fa 03             	sar    $0x3,%edx
f01019dd:	c1 e2 0c             	shl    $0xc,%edx
f01019e0:	39 d0                	cmp    %edx,%eax
f01019e2:	74 19                	je     f01019fd <mem_init+0x88e>
f01019e4:	68 10 43 10 f0       	push   $0xf0104310
f01019e9:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01019ee:	68 32 03 00 00       	push   $0x332
f01019f3:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01019f8:	e8 8e e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01019fd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a02:	74 19                	je     f0101a1d <mem_init+0x8ae>
f0101a04:	68 fd 3e 10 f0       	push   $0xf0103efd
f0101a09:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101a0e:	68 33 03 00 00       	push   $0x333
f0101a13:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101a18:	e8 6e e6 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a1d:	83 ec 0c             	sub    $0xc,%esp
f0101a20:	6a 00                	push   $0x0
f0101a22:	e8 c8 f3 ff ff       	call   f0100def <page_alloc>
f0101a27:	83 c4 10             	add    $0x10,%esp
f0101a2a:	85 c0                	test   %eax,%eax
f0101a2c:	74 19                	je     f0101a47 <mem_init+0x8d8>
f0101a2e:	68 89 3e 10 f0       	push   $0xf0103e89
f0101a33:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101a38:	68 37 03 00 00       	push   $0x337
f0101a3d:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101a42:	e8 44 e6 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a47:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101a4d:	8b 02                	mov    (%edx),%eax
f0101a4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a54:	89 c1                	mov    %eax,%ecx
f0101a56:	c1 e9 0c             	shr    $0xc,%ecx
f0101a59:	3b 0d 68 79 11 f0    	cmp    0xf0117968,%ecx
f0101a5f:	72 15                	jb     f0101a76 <mem_init+0x907>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a61:	50                   	push   %eax
f0101a62:	68 18 40 10 f0       	push   $0xf0104018
f0101a67:	68 3a 03 00 00       	push   $0x33a
f0101a6c:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101a71:	e8 15 e6 ff ff       	call   f010008b <_panic>
f0101a76:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a7e:	83 ec 04             	sub    $0x4,%esp
f0101a81:	6a 00                	push   $0x0
f0101a83:	68 00 10 00 00       	push   $0x1000
f0101a88:	52                   	push   %edx
f0101a89:	e8 5b f4 ff ff       	call   f0100ee9 <pgdir_walk>
f0101a8e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a91:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a94:	83 c4 10             	add    $0x10,%esp
f0101a97:	39 d0                	cmp    %edx,%eax
f0101a99:	74 19                	je     f0101ab4 <mem_init+0x945>
f0101a9b:	68 40 43 10 f0       	push   $0xf0104340
f0101aa0:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101aa5:	68 3b 03 00 00       	push   $0x33b
f0101aaa:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101aaf:	e8 d7 e5 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ab4:	6a 06                	push   $0x6
f0101ab6:	68 00 10 00 00       	push   $0x1000
f0101abb:	56                   	push   %esi
f0101abc:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101ac2:	e8 e0 f5 ff ff       	call   f01010a7 <page_insert>
f0101ac7:	83 c4 10             	add    $0x10,%esp
f0101aca:	85 c0                	test   %eax,%eax
f0101acc:	74 19                	je     f0101ae7 <mem_init+0x978>
f0101ace:	68 80 43 10 f0       	push   $0xf0104380
f0101ad3:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101ad8:	68 3e 03 00 00       	push   $0x33e
f0101add:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101ae2:	e8 a4 e5 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae7:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101aed:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101af2:	89 f8                	mov    %edi,%eax
f0101af4:	e8 a3 ee ff ff       	call   f010099c <check_va2pa>
f0101af9:	89 f2                	mov    %esi,%edx
f0101afb:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101b01:	c1 fa 03             	sar    $0x3,%edx
f0101b04:	c1 e2 0c             	shl    $0xc,%edx
f0101b07:	39 d0                	cmp    %edx,%eax
f0101b09:	74 19                	je     f0101b24 <mem_init+0x9b5>
f0101b0b:	68 10 43 10 f0       	push   $0xf0104310
f0101b10:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101b15:	68 3f 03 00 00       	push   $0x33f
f0101b1a:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101b1f:	e8 67 e5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101b24:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b29:	74 19                	je     f0101b44 <mem_init+0x9d5>
f0101b2b:	68 fd 3e 10 f0       	push   $0xf0103efd
f0101b30:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101b35:	68 40 03 00 00       	push   $0x340
f0101b3a:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101b3f:	e8 47 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b44:	83 ec 04             	sub    $0x4,%esp
f0101b47:	6a 00                	push   $0x0
f0101b49:	68 00 10 00 00       	push   $0x1000
f0101b4e:	57                   	push   %edi
f0101b4f:	e8 95 f3 ff ff       	call   f0100ee9 <pgdir_walk>
f0101b54:	83 c4 10             	add    $0x10,%esp
f0101b57:	f6 00 04             	testb  $0x4,(%eax)
f0101b5a:	75 19                	jne    f0101b75 <mem_init+0xa06>
f0101b5c:	68 c0 43 10 f0       	push   $0xf01043c0
f0101b61:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101b66:	68 41 03 00 00       	push   $0x341
f0101b6b:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101b70:	e8 16 e5 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b75:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101b7a:	f6 00 04             	testb  $0x4,(%eax)
f0101b7d:	75 19                	jne    f0101b98 <mem_init+0xa29>
f0101b7f:	68 0e 3f 10 f0       	push   $0xf0103f0e
f0101b84:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101b89:	68 42 03 00 00       	push   $0x342
f0101b8e:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101b93:	e8 f3 e4 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b98:	6a 02                	push   $0x2
f0101b9a:	68 00 10 00 00       	push   $0x1000
f0101b9f:	56                   	push   %esi
f0101ba0:	50                   	push   %eax
f0101ba1:	e8 01 f5 ff ff       	call   f01010a7 <page_insert>
f0101ba6:	83 c4 10             	add    $0x10,%esp
f0101ba9:	85 c0                	test   %eax,%eax
f0101bab:	74 19                	je     f0101bc6 <mem_init+0xa57>
f0101bad:	68 d4 42 10 f0       	push   $0xf01042d4
f0101bb2:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101bb7:	68 45 03 00 00       	push   $0x345
f0101bbc:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101bc1:	e8 c5 e4 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bc6:	83 ec 04             	sub    $0x4,%esp
f0101bc9:	6a 00                	push   $0x0
f0101bcb:	68 00 10 00 00       	push   $0x1000
f0101bd0:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101bd6:	e8 0e f3 ff ff       	call   f0100ee9 <pgdir_walk>
f0101bdb:	83 c4 10             	add    $0x10,%esp
f0101bde:	f6 00 02             	testb  $0x2,(%eax)
f0101be1:	75 19                	jne    f0101bfc <mem_init+0xa8d>
f0101be3:	68 f4 43 10 f0       	push   $0xf01043f4
f0101be8:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101bed:	68 46 03 00 00       	push   $0x346
f0101bf2:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101bf7:	e8 8f e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bfc:	83 ec 04             	sub    $0x4,%esp
f0101bff:	6a 00                	push   $0x0
f0101c01:	68 00 10 00 00       	push   $0x1000
f0101c06:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c0c:	e8 d8 f2 ff ff       	call   f0100ee9 <pgdir_walk>
f0101c11:	83 c4 10             	add    $0x10,%esp
f0101c14:	f6 00 04             	testb  $0x4,(%eax)
f0101c17:	74 19                	je     f0101c32 <mem_init+0xac3>
f0101c19:	68 28 44 10 f0       	push   $0xf0104428
f0101c1e:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101c23:	68 47 03 00 00       	push   $0x347
f0101c28:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101c2d:	e8 59 e4 ff ff       	call   f010008b <_panic>


	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c32:	6a 02                	push   $0x2
f0101c34:	68 00 00 40 00       	push   $0x400000
f0101c39:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c3c:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c42:	e8 60 f4 ff ff       	call   f01010a7 <page_insert>
f0101c47:	83 c4 10             	add    $0x10,%esp
f0101c4a:	85 c0                	test   %eax,%eax
f0101c4c:	78 19                	js     f0101c67 <mem_init+0xaf8>
f0101c4e:	68 60 44 10 f0       	push   $0xf0104460
f0101c53:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101c58:	68 4a 03 00 00       	push   $0x34a
f0101c5d:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101c62:	e8 24 e4 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c67:	6a 02                	push   $0x2
f0101c69:	68 00 10 00 00       	push   $0x1000
f0101c6e:	53                   	push   %ebx
f0101c6f:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101c75:	e8 2d f4 ff ff       	call   f01010a7 <page_insert>
f0101c7a:	83 c4 10             	add    $0x10,%esp
f0101c7d:	85 c0                	test   %eax,%eax
f0101c7f:	74 19                	je     f0101c9a <mem_init+0xb2b>
f0101c81:	68 98 44 10 f0       	push   $0xf0104498
f0101c86:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101c8b:	68 4d 03 00 00       	push   $0x34d
f0101c90:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101c95:	e8 f1 e3 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c9a:	83 ec 04             	sub    $0x4,%esp
f0101c9d:	6a 00                	push   $0x0
f0101c9f:	68 00 10 00 00       	push   $0x1000
f0101ca4:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101caa:	e8 3a f2 ff ff       	call   f0100ee9 <pgdir_walk>
f0101caf:	83 c4 10             	add    $0x10,%esp
f0101cb2:	f6 00 04             	testb  $0x4,(%eax)
f0101cb5:	74 19                	je     f0101cd0 <mem_init+0xb61>
f0101cb7:	68 28 44 10 f0       	push   $0xf0104428
f0101cbc:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101cc1:	68 4e 03 00 00       	push   $0x34e
f0101cc6:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101ccb:	e8 bb e3 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cd0:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101cd6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cdb:	89 f8                	mov    %edi,%eax
f0101cdd:	e8 ba ec ff ff       	call   f010099c <check_va2pa>
f0101ce2:	89 c1                	mov    %eax,%ecx
f0101ce4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ce7:	89 d8                	mov    %ebx,%eax
f0101ce9:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101cef:	c1 f8 03             	sar    $0x3,%eax
f0101cf2:	c1 e0 0c             	shl    $0xc,%eax
f0101cf5:	39 c1                	cmp    %eax,%ecx
f0101cf7:	74 19                	je     f0101d12 <mem_init+0xba3>
f0101cf9:	68 d4 44 10 f0       	push   $0xf01044d4
f0101cfe:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101d03:	68 51 03 00 00       	push   $0x351
f0101d08:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101d0d:	e8 79 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d12:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d17:	89 f8                	mov    %edi,%eax
f0101d19:	e8 7e ec ff ff       	call   f010099c <check_va2pa>
f0101d1e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d21:	74 19                	je     f0101d3c <mem_init+0xbcd>
f0101d23:	68 00 45 10 f0       	push   $0xf0104500
f0101d28:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101d2d:	68 52 03 00 00       	push   $0x352
f0101d32:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101d37:	e8 4f e3 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d3c:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d41:	74 19                	je     f0101d5c <mem_init+0xbed>
f0101d43:	68 24 3f 10 f0       	push   $0xf0103f24
f0101d48:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101d4d:	68 54 03 00 00       	push   $0x354
f0101d52:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101d57:	e8 2f e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d5c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d61:	74 19                	je     f0101d7c <mem_init+0xc0d>
f0101d63:	68 35 3f 10 f0       	push   $0xf0103f35
f0101d68:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101d6d:	68 55 03 00 00       	push   $0x355
f0101d72:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101d77:	e8 0f e3 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d7c:	83 ec 0c             	sub    $0xc,%esp
f0101d7f:	6a 00                	push   $0x0
f0101d81:	e8 69 f0 ff ff       	call   f0100def <page_alloc>
f0101d86:	83 c4 10             	add    $0x10,%esp
f0101d89:	85 c0                	test   %eax,%eax
f0101d8b:	74 04                	je     f0101d91 <mem_init+0xc22>
f0101d8d:	39 c6                	cmp    %eax,%esi
f0101d8f:	74 19                	je     f0101daa <mem_init+0xc3b>
f0101d91:	68 30 45 10 f0       	push   $0xf0104530
f0101d96:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101d9b:	68 58 03 00 00       	push   $0x358
f0101da0:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101da5:	e8 e1 e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101daa:	83 ec 08             	sub    $0x8,%esp
f0101dad:	6a 00                	push   $0x0
f0101daf:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101db5:	e8 ab f2 ff ff       	call   f0101065 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dba:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101dc0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dc5:	89 f8                	mov    %edi,%eax
f0101dc7:	e8 d0 eb ff ff       	call   f010099c <check_va2pa>
f0101dcc:	83 c4 10             	add    $0x10,%esp
f0101dcf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dd2:	74 19                	je     f0101ded <mem_init+0xc7e>
f0101dd4:	68 54 45 10 f0       	push   $0xf0104554
f0101dd9:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101dde:	68 5c 03 00 00       	push   $0x35c
f0101de3:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101de8:	e8 9e e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ded:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df2:	89 f8                	mov    %edi,%eax
f0101df4:	e8 a3 eb ff ff       	call   f010099c <check_va2pa>
f0101df9:	89 da                	mov    %ebx,%edx
f0101dfb:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0101e01:	c1 fa 03             	sar    $0x3,%edx
f0101e04:	c1 e2 0c             	shl    $0xc,%edx
f0101e07:	39 d0                	cmp    %edx,%eax
f0101e09:	74 19                	je     f0101e24 <mem_init+0xcb5>
f0101e0b:	68 00 45 10 f0       	push   $0xf0104500
f0101e10:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101e15:	68 5d 03 00 00       	push   $0x35d
f0101e1a:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101e1f:	e8 67 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101e24:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e29:	74 19                	je     f0101e44 <mem_init+0xcd5>
f0101e2b:	68 db 3e 10 f0       	push   $0xf0103edb
f0101e30:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101e35:	68 5e 03 00 00       	push   $0x35e
f0101e3a:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101e3f:	e8 47 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101e44:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e49:	74 19                	je     f0101e64 <mem_init+0xcf5>
f0101e4b:	68 35 3f 10 f0       	push   $0xf0103f35
f0101e50:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101e55:	68 5f 03 00 00       	push   $0x35f
f0101e5a:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101e5f:	e8 27 e2 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e64:	6a 00                	push   $0x0
f0101e66:	68 00 10 00 00       	push   $0x1000
f0101e6b:	53                   	push   %ebx
f0101e6c:	57                   	push   %edi
f0101e6d:	e8 35 f2 ff ff       	call   f01010a7 <page_insert>
f0101e72:	83 c4 10             	add    $0x10,%esp
f0101e75:	85 c0                	test   %eax,%eax
f0101e77:	74 19                	je     f0101e92 <mem_init+0xd23>
f0101e79:	68 78 45 10 f0       	push   $0xf0104578
f0101e7e:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101e83:	68 62 03 00 00       	push   $0x362
f0101e88:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101e8d:	e8 f9 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101e92:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e97:	75 19                	jne    f0101eb2 <mem_init+0xd43>
f0101e99:	68 46 3f 10 f0       	push   $0xf0103f46
f0101e9e:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101ea3:	68 63 03 00 00       	push   $0x363
f0101ea8:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101ead:	e8 d9 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101eb2:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101eb5:	74 19                	je     f0101ed0 <mem_init+0xd61>
f0101eb7:	68 52 3f 10 f0       	push   $0xf0103f52
f0101ebc:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101ec1:	68 64 03 00 00       	push   $0x364
f0101ec6:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101ecb:	e8 bb e1 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101ed0:	83 ec 08             	sub    $0x8,%esp
f0101ed3:	68 00 10 00 00       	push   $0x1000
f0101ed8:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0101ede:	e8 82 f1 ff ff       	call   f0101065 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ee3:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
f0101ee9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eee:	89 f8                	mov    %edi,%eax
f0101ef0:	e8 a7 ea ff ff       	call   f010099c <check_va2pa>
f0101ef5:	83 c4 10             	add    $0x10,%esp
f0101ef8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101efb:	74 19                	je     f0101f16 <mem_init+0xda7>
f0101efd:	68 54 45 10 f0       	push   $0xf0104554
f0101f02:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101f07:	68 68 03 00 00       	push   $0x368
f0101f0c:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101f11:	e8 75 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f16:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f1b:	89 f8                	mov    %edi,%eax
f0101f1d:	e8 7a ea ff ff       	call   f010099c <check_va2pa>
f0101f22:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f25:	74 19                	je     f0101f40 <mem_init+0xdd1>
f0101f27:	68 b0 45 10 f0       	push   $0xf01045b0
f0101f2c:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101f31:	68 69 03 00 00       	push   $0x369
f0101f36:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101f3b:	e8 4b e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101f40:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f45:	74 19                	je     f0101f60 <mem_init+0xdf1>
f0101f47:	68 67 3f 10 f0       	push   $0xf0103f67
f0101f4c:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101f51:	68 6a 03 00 00       	push   $0x36a
f0101f56:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101f5b:	e8 2b e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101f60:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f65:	74 19                	je     f0101f80 <mem_init+0xe11>
f0101f67:	68 35 3f 10 f0       	push   $0xf0103f35
f0101f6c:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101f71:	68 6b 03 00 00       	push   $0x36b
f0101f76:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101f7b:	e8 0b e1 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f80:	83 ec 0c             	sub    $0xc,%esp
f0101f83:	6a 00                	push   $0x0
f0101f85:	e8 65 ee ff ff       	call   f0100def <page_alloc>
f0101f8a:	83 c4 10             	add    $0x10,%esp
f0101f8d:	39 c3                	cmp    %eax,%ebx
f0101f8f:	75 04                	jne    f0101f95 <mem_init+0xe26>
f0101f91:	85 c0                	test   %eax,%eax
f0101f93:	75 19                	jne    f0101fae <mem_init+0xe3f>
f0101f95:	68 d8 45 10 f0       	push   $0xf01045d8
f0101f9a:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101f9f:	68 6e 03 00 00       	push   $0x36e
f0101fa4:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101fa9:	e8 dd e0 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101fae:	83 ec 0c             	sub    $0xc,%esp
f0101fb1:	6a 00                	push   $0x0
f0101fb3:	e8 37 ee ff ff       	call   f0100def <page_alloc>
f0101fb8:	83 c4 10             	add    $0x10,%esp
f0101fbb:	85 c0                	test   %eax,%eax
f0101fbd:	74 19                	je     f0101fd8 <mem_init+0xe69>
f0101fbf:	68 89 3e 10 f0       	push   $0xf0103e89
f0101fc4:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0101fc9:	68 71 03 00 00       	push   $0x371
f0101fce:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0101fd3:	e8 b3 e0 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fd8:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0101fde:	8b 11                	mov    (%ecx),%edx
f0101fe0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fe6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe9:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0101fef:	c1 f8 03             	sar    $0x3,%eax
f0101ff2:	c1 e0 0c             	shl    $0xc,%eax
f0101ff5:	39 c2                	cmp    %eax,%edx
f0101ff7:	74 19                	je     f0102012 <mem_init+0xea3>
f0101ff9:	68 7c 42 10 f0       	push   $0xf010427c
f0101ffe:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102003:	68 74 03 00 00       	push   $0x374
f0102008:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010200d:	e8 79 e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102012:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102018:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010201b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102020:	74 19                	je     f010203b <mem_init+0xecc>
f0102022:	68 ec 3e 10 f0       	push   $0xf0103eec
f0102027:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010202c:	68 76 03 00 00       	push   $0x376
f0102031:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102036:	e8 50 e0 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f010203b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010203e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102044:	83 ec 0c             	sub    $0xc,%esp
f0102047:	50                   	push   %eax
f0102048:	e8 19 ee ff ff       	call   f0100e66 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010204d:	83 c4 0c             	add    $0xc,%esp
f0102050:	6a 01                	push   $0x1
f0102052:	68 00 10 40 00       	push   $0x401000
f0102057:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010205d:	e8 87 ee ff ff       	call   f0100ee9 <pgdir_walk>
f0102062:	89 c7                	mov    %eax,%edi
f0102064:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102067:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f010206c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010206f:	8b 40 04             	mov    0x4(%eax),%eax
f0102072:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102077:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f010207d:	89 c2                	mov    %eax,%edx
f010207f:	c1 ea 0c             	shr    $0xc,%edx
f0102082:	83 c4 10             	add    $0x10,%esp
f0102085:	39 ca                	cmp    %ecx,%edx
f0102087:	72 15                	jb     f010209e <mem_init+0xf2f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102089:	50                   	push   %eax
f010208a:	68 18 40 10 f0       	push   $0xf0104018
f010208f:	68 7d 03 00 00       	push   $0x37d
f0102094:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102099:	e8 ed df ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f010209e:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01020a3:	39 c7                	cmp    %eax,%edi
f01020a5:	74 19                	je     f01020c0 <mem_init+0xf51>
f01020a7:	68 78 3f 10 f0       	push   $0xf0103f78
f01020ac:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01020b1:	68 7e 03 00 00       	push   $0x37e
f01020b6:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01020bb:	e8 cb df ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01020c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01020c3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01020ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020cd:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020d3:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01020d9:	c1 f8 03             	sar    $0x3,%eax
f01020dc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020df:	89 c2                	mov    %eax,%edx
f01020e1:	c1 ea 0c             	shr    $0xc,%edx
f01020e4:	39 d1                	cmp    %edx,%ecx
f01020e6:	77 12                	ja     f01020fa <mem_init+0xf8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020e8:	50                   	push   %eax
f01020e9:	68 18 40 10 f0       	push   $0xf0104018
f01020ee:	6a 52                	push   $0x52
f01020f0:	68 be 3c 10 f0       	push   $0xf0103cbe
f01020f5:	e8 91 df ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020fa:	83 ec 04             	sub    $0x4,%esp
f01020fd:	68 00 10 00 00       	push   $0x1000
f0102102:	68 ff 00 00 00       	push   $0xff
f0102107:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010210c:	50                   	push   %eax
f010210d:	e8 d2 11 00 00       	call   f01032e4 <memset>
	page_free(pp0);
f0102112:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102115:	89 3c 24             	mov    %edi,(%esp)
f0102118:	e8 49 ed ff ff       	call   f0100e66 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010211d:	83 c4 0c             	add    $0xc,%esp
f0102120:	6a 01                	push   $0x1
f0102122:	6a 00                	push   $0x0
f0102124:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010212a:	e8 ba ed ff ff       	call   f0100ee9 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010212f:	89 fa                	mov    %edi,%edx
f0102131:	2b 15 70 79 11 f0    	sub    0xf0117970,%edx
f0102137:	c1 fa 03             	sar    $0x3,%edx
f010213a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010213d:	89 d0                	mov    %edx,%eax
f010213f:	c1 e8 0c             	shr    $0xc,%eax
f0102142:	83 c4 10             	add    $0x10,%esp
f0102145:	3b 05 68 79 11 f0    	cmp    0xf0117968,%eax
f010214b:	72 12                	jb     f010215f <mem_init+0xff0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010214d:	52                   	push   %edx
f010214e:	68 18 40 10 f0       	push   $0xf0104018
f0102153:	6a 52                	push   $0x52
f0102155:	68 be 3c 10 f0       	push   $0xf0103cbe
f010215a:	e8 2c df ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f010215f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102165:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102168:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010216e:	f6 00 01             	testb  $0x1,(%eax)
f0102171:	74 19                	je     f010218c <mem_init+0x101d>
f0102173:	68 90 3f 10 f0       	push   $0xf0103f90
f0102178:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010217d:	68 88 03 00 00       	push   $0x388
f0102182:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102187:	e8 ff de ff ff       	call   f010008b <_panic>
f010218c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010218f:	39 d0                	cmp    %edx,%eax
f0102191:	75 db                	jne    f010216e <mem_init+0xfff>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102193:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0102198:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010219e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021a1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01021a7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01021aa:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f01021b0:	83 ec 0c             	sub    $0xc,%esp
f01021b3:	50                   	push   %eax
f01021b4:	e8 ad ec ff ff       	call   f0100e66 <page_free>
	page_free(pp1);
f01021b9:	89 1c 24             	mov    %ebx,(%esp)
f01021bc:	e8 a5 ec ff ff       	call   f0100e66 <page_free>
	page_free(pp2);
f01021c1:	89 34 24             	mov    %esi,(%esp)
f01021c4:	e8 9d ec ff ff       	call   f0100e66 <page_free>

	cprintf("check_page() succeeded!\n");
f01021c9:	c7 04 24 a7 3f 10 f0 	movl   $0xf0103fa7,(%esp)
f01021d0:	e8 4b 06 00 00       	call   f0102820 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f01021d5:	a1 70 79 11 f0       	mov    0xf0117970,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021da:	83 c4 10             	add    $0x10,%esp
f01021dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021e2:	77 15                	ja     f01021f9 <mem_init+0x108a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021e4:	50                   	push   %eax
f01021e5:	68 24 41 10 f0       	push   $0xf0104124
f01021ea:	68 ba 00 00 00       	push   $0xba
f01021ef:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01021f4:	e8 92 de ff ff       	call   f010008b <_panic>
f01021f9:	83 ec 08             	sub    $0x8,%esp
f01021fc:	6a 05                	push   $0x5
f01021fe:	05 00 00 00 10       	add    $0x10000000,%eax
f0102203:	50                   	push   %eax
f0102204:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102209:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010220e:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0102213:	e8 6e ed ff ff       	call   f0100f86 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102218:	83 c4 10             	add    $0x10,%esp
f010221b:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f0102220:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102225:	77 15                	ja     f010223c <mem_init+0x10cd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102227:	50                   	push   %eax
f0102228:	68 24 41 10 f0       	push   $0xf0104124
f010222d:	68 c8 00 00 00       	push   $0xc8
f0102232:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102237:	e8 4f de ff ff       	call   f010008b <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	uintptr_t address = KSTACKTOP - KSTKSIZE;
	boot_map_region (kern_pgdir, address, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f010223c:	83 ec 08             	sub    $0x8,%esp
f010223f:	6a 03                	push   $0x3
f0102241:	68 00 d0 10 00       	push   $0x10d000
f0102246:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010224b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102250:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0102255:	e8 2c ed ff ff       	call   f0100f86 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	uint32_t pa_range = 0xFFFFFFFF - KERNBASE +1;
	boot_map_region (kern_pgdir, KERNBASE, pa_range, 0, PTE_W | PTE_P);
f010225a:	83 c4 08             	add    $0x8,%esp
f010225d:	6a 03                	push   $0x3
f010225f:	6a 00                	push   $0x0
f0102261:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102266:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010226b:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0102270:	e8 11 ed ff ff       	call   f0100f86 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102275:	8b 35 6c 79 11 f0    	mov    0xf011796c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010227b:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102280:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102283:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010228a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010228f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102292:	8b 3d 70 79 11 f0    	mov    0xf0117970,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102298:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010229b:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010229e:	bb 00 00 00 00       	mov    $0x0,%ebx
f01022a3:	eb 55                	jmp    f01022fa <mem_init+0x118b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022a5:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01022ab:	89 f0                	mov    %esi,%eax
f01022ad:	e8 ea e6 ff ff       	call   f010099c <check_va2pa>
f01022b2:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01022b9:	77 15                	ja     f01022d0 <mem_init+0x1161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022bb:	57                   	push   %edi
f01022bc:	68 24 41 10 f0       	push   $0xf0104124
f01022c1:	68 ca 02 00 00       	push   $0x2ca
f01022c6:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01022cb:	e8 bb dd ff ff       	call   f010008b <_panic>
f01022d0:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f01022d7:	39 c2                	cmp    %eax,%edx
f01022d9:	74 19                	je     f01022f4 <mem_init+0x1185>
f01022db:	68 fc 45 10 f0       	push   $0xf01045fc
f01022e0:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01022e5:	68 ca 02 00 00       	push   $0x2ca
f01022ea:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01022ef:	e8 97 dd ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022f4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022fa:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01022fd:	77 a6                	ja     f01022a5 <mem_init+0x1136>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022ff:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102302:	c1 e7 0c             	shl    $0xc,%edi
f0102305:	bb 00 00 00 00       	mov    $0x0,%ebx
f010230a:	eb 30                	jmp    f010233c <mem_init+0x11cd>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010230c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102312:	89 f0                	mov    %esi,%eax
f0102314:	e8 83 e6 ff ff       	call   f010099c <check_va2pa>
f0102319:	39 c3                	cmp    %eax,%ebx
f010231b:	74 19                	je     f0102336 <mem_init+0x11c7>
f010231d:	68 30 46 10 f0       	push   $0xf0104630
f0102322:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102327:	68 cf 02 00 00       	push   $0x2cf
f010232c:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102331:	e8 55 dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102336:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010233c:	39 fb                	cmp    %edi,%ebx
f010233e:	72 cc                	jb     f010230c <mem_init+0x119d>
f0102340:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102345:	89 da                	mov    %ebx,%edx
f0102347:	89 f0                	mov    %esi,%eax
f0102349:	e8 4e e6 ff ff       	call   f010099c <check_va2pa>
f010234e:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102354:	39 c2                	cmp    %eax,%edx
f0102356:	74 19                	je     f0102371 <mem_init+0x1202>
f0102358:	68 58 46 10 f0       	push   $0xf0104658
f010235d:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102362:	68 d3 02 00 00       	push   $0x2d3
f0102367:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010236c:	e8 1a dd ff ff       	call   f010008b <_panic>
f0102371:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102377:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010237d:	75 c6                	jne    f0102345 <mem_init+0x11d6>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010237f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102384:	89 f0                	mov    %esi,%eax
f0102386:	e8 11 e6 ff ff       	call   f010099c <check_va2pa>
f010238b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010238e:	74 51                	je     f01023e1 <mem_init+0x1272>
f0102390:	68 a0 46 10 f0       	push   $0xf01046a0
f0102395:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010239a:	68 d4 02 00 00       	push   $0x2d4
f010239f:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01023a4:	e8 e2 dc ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01023a9:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01023ae:	72 36                	jb     f01023e6 <mem_init+0x1277>
f01023b0:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01023b5:	76 07                	jbe    f01023be <mem_init+0x124f>
f01023b7:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023bc:	75 28                	jne    f01023e6 <mem_init+0x1277>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01023be:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01023c2:	0f 85 83 00 00 00    	jne    f010244b <mem_init+0x12dc>
f01023c8:	68 c0 3f 10 f0       	push   $0xf0103fc0
f01023cd:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01023d2:	68 dc 02 00 00       	push   $0x2dc
f01023d7:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01023dc:	e8 aa dc ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023e1:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01023e6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023eb:	76 3f                	jbe    f010242c <mem_init+0x12bd>
				assert(pgdir[i] & PTE_P);
f01023ed:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01023f0:	f6 c2 01             	test   $0x1,%dl
f01023f3:	75 19                	jne    f010240e <mem_init+0x129f>
f01023f5:	68 c0 3f 10 f0       	push   $0xf0103fc0
f01023fa:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01023ff:	68 e0 02 00 00       	push   $0x2e0
f0102404:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102409:	e8 7d dc ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f010240e:	f6 c2 02             	test   $0x2,%dl
f0102411:	75 38                	jne    f010244b <mem_init+0x12dc>
f0102413:	68 d1 3f 10 f0       	push   $0xf0103fd1
f0102418:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010241d:	68 e1 02 00 00       	push   $0x2e1
f0102422:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102427:	e8 5f dc ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f010242c:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102430:	74 19                	je     f010244b <mem_init+0x12dc>
f0102432:	68 e2 3f 10 f0       	push   $0xf0103fe2
f0102437:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010243c:	68 e3 02 00 00       	push   $0x2e3
f0102441:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102446:	e8 40 dc ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010244b:	83 c0 01             	add    $0x1,%eax
f010244e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102453:	0f 86 50 ff ff ff    	jbe    f01023a9 <mem_init+0x123a>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102459:	83 ec 0c             	sub    $0xc,%esp
f010245c:	68 d0 46 10 f0       	push   $0xf01046d0
f0102461:	e8 ba 03 00 00       	call   f0102820 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102466:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010246b:	83 c4 10             	add    $0x10,%esp
f010246e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102473:	77 15                	ja     f010248a <mem_init+0x131b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102475:	50                   	push   %eax
f0102476:	68 24 41 10 f0       	push   $0xf0104124
f010247b:	68 df 00 00 00       	push   $0xdf
f0102480:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102485:	e8 01 dc ff ff       	call   f010008b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010248a:	05 00 00 00 10       	add    $0x10000000,%eax
f010248f:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102492:	b8 00 00 00 00       	mov    $0x0,%eax
f0102497:	e8 64 e5 ff ff       	call   f0100a00 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010249c:	0f 20 c0             	mov    %cr0,%eax
f010249f:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01024a2:	0d 23 00 05 80       	or     $0x80050023,%eax
f01024a7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01024aa:	83 ec 0c             	sub    $0xc,%esp
f01024ad:	6a 00                	push   $0x0
f01024af:	e8 3b e9 ff ff       	call   f0100def <page_alloc>
f01024b4:	89 c3                	mov    %eax,%ebx
f01024b6:	83 c4 10             	add    $0x10,%esp
f01024b9:	85 c0                	test   %eax,%eax
f01024bb:	75 19                	jne    f01024d6 <mem_init+0x1367>
f01024bd:	68 de 3d 10 f0       	push   $0xf0103dde
f01024c2:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01024c7:	68 a3 03 00 00       	push   $0x3a3
f01024cc:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01024d1:	e8 b5 db ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01024d6:	83 ec 0c             	sub    $0xc,%esp
f01024d9:	6a 00                	push   $0x0
f01024db:	e8 0f e9 ff ff       	call   f0100def <page_alloc>
f01024e0:	89 c7                	mov    %eax,%edi
f01024e2:	83 c4 10             	add    $0x10,%esp
f01024e5:	85 c0                	test   %eax,%eax
f01024e7:	75 19                	jne    f0102502 <mem_init+0x1393>
f01024e9:	68 f4 3d 10 f0       	push   $0xf0103df4
f01024ee:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01024f3:	68 a4 03 00 00       	push   $0x3a4
f01024f8:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01024fd:	e8 89 db ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102502:	83 ec 0c             	sub    $0xc,%esp
f0102505:	6a 00                	push   $0x0
f0102507:	e8 e3 e8 ff ff       	call   f0100def <page_alloc>
f010250c:	89 c6                	mov    %eax,%esi
f010250e:	83 c4 10             	add    $0x10,%esp
f0102511:	85 c0                	test   %eax,%eax
f0102513:	75 19                	jne    f010252e <mem_init+0x13bf>
f0102515:	68 0a 3e 10 f0       	push   $0xf0103e0a
f010251a:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010251f:	68 a5 03 00 00       	push   $0x3a5
f0102524:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102529:	e8 5d db ff ff       	call   f010008b <_panic>
	page_free(pp0);
f010252e:	83 ec 0c             	sub    $0xc,%esp
f0102531:	53                   	push   %ebx
f0102532:	e8 2f e9 ff ff       	call   f0100e66 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102537:	89 f8                	mov    %edi,%eax
f0102539:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010253f:	c1 f8 03             	sar    $0x3,%eax
f0102542:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102545:	89 c2                	mov    %eax,%edx
f0102547:	c1 ea 0c             	shr    $0xc,%edx
f010254a:	83 c4 10             	add    $0x10,%esp
f010254d:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0102553:	72 12                	jb     f0102567 <mem_init+0x13f8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102555:	50                   	push   %eax
f0102556:	68 18 40 10 f0       	push   $0xf0104018
f010255b:	6a 52                	push   $0x52
f010255d:	68 be 3c 10 f0       	push   $0xf0103cbe
f0102562:	e8 24 db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102567:	83 ec 04             	sub    $0x4,%esp
f010256a:	68 00 10 00 00       	push   $0x1000
f010256f:	6a 01                	push   $0x1
f0102571:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102576:	50                   	push   %eax
f0102577:	e8 68 0d 00 00       	call   f01032e4 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010257c:	89 f0                	mov    %esi,%eax
f010257e:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f0102584:	c1 f8 03             	sar    $0x3,%eax
f0102587:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010258a:	89 c2                	mov    %eax,%edx
f010258c:	c1 ea 0c             	shr    $0xc,%edx
f010258f:	83 c4 10             	add    $0x10,%esp
f0102592:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f0102598:	72 12                	jb     f01025ac <mem_init+0x143d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010259a:	50                   	push   %eax
f010259b:	68 18 40 10 f0       	push   $0xf0104018
f01025a0:	6a 52                	push   $0x52
f01025a2:	68 be 3c 10 f0       	push   $0xf0103cbe
f01025a7:	e8 df da ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01025ac:	83 ec 04             	sub    $0x4,%esp
f01025af:	68 00 10 00 00       	push   $0x1000
f01025b4:	6a 02                	push   $0x2
f01025b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025bb:	50                   	push   %eax
f01025bc:	e8 23 0d 00 00       	call   f01032e4 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01025c1:	6a 02                	push   $0x2
f01025c3:	68 00 10 00 00       	push   $0x1000
f01025c8:	57                   	push   %edi
f01025c9:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f01025cf:	e8 d3 ea ff ff       	call   f01010a7 <page_insert>
	assert(pp1->pp_ref == 1);
f01025d4:	83 c4 20             	add    $0x20,%esp
f01025d7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025dc:	74 19                	je     f01025f7 <mem_init+0x1488>
f01025de:	68 db 3e 10 f0       	push   $0xf0103edb
f01025e3:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01025e8:	68 aa 03 00 00       	push   $0x3aa
f01025ed:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01025f2:	e8 94 da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025f7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025fe:	01 01 01 
f0102601:	74 19                	je     f010261c <mem_init+0x14ad>
f0102603:	68 f0 46 10 f0       	push   $0xf01046f0
f0102608:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010260d:	68 ab 03 00 00       	push   $0x3ab
f0102612:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102617:	e8 6f da ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010261c:	6a 02                	push   $0x2
f010261e:	68 00 10 00 00       	push   $0x1000
f0102623:	56                   	push   %esi
f0102624:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f010262a:	e8 78 ea ff ff       	call   f01010a7 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010262f:	83 c4 10             	add    $0x10,%esp
f0102632:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102639:	02 02 02 
f010263c:	74 19                	je     f0102657 <mem_init+0x14e8>
f010263e:	68 14 47 10 f0       	push   $0xf0104714
f0102643:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102648:	68 ad 03 00 00       	push   $0x3ad
f010264d:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102652:	e8 34 da ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102657:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010265c:	74 19                	je     f0102677 <mem_init+0x1508>
f010265e:	68 fd 3e 10 f0       	push   $0xf0103efd
f0102663:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102668:	68 ae 03 00 00       	push   $0x3ae
f010266d:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102672:	e8 14 da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102677:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010267c:	74 19                	je     f0102697 <mem_init+0x1528>
f010267e:	68 67 3f 10 f0       	push   $0xf0103f67
f0102683:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102688:	68 af 03 00 00       	push   $0x3af
f010268d:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102692:	e8 f4 d9 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102697:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010269e:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026a1:	89 f0                	mov    %esi,%eax
f01026a3:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f01026a9:	c1 f8 03             	sar    $0x3,%eax
f01026ac:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026af:	89 c2                	mov    %eax,%edx
f01026b1:	c1 ea 0c             	shr    $0xc,%edx
f01026b4:	3b 15 68 79 11 f0    	cmp    0xf0117968,%edx
f01026ba:	72 12                	jb     f01026ce <mem_init+0x155f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026bc:	50                   	push   %eax
f01026bd:	68 18 40 10 f0       	push   $0xf0104018
f01026c2:	6a 52                	push   $0x52
f01026c4:	68 be 3c 10 f0       	push   $0xf0103cbe
f01026c9:	e8 bd d9 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01026ce:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01026d5:	03 03 03 
f01026d8:	74 19                	je     f01026f3 <mem_init+0x1584>
f01026da:	68 38 47 10 f0       	push   $0xf0104738
f01026df:	68 d8 3c 10 f0       	push   $0xf0103cd8
f01026e4:	68 b1 03 00 00       	push   $0x3b1
f01026e9:	68 b2 3c 10 f0       	push   $0xf0103cb2
f01026ee:	e8 98 d9 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026f3:	83 ec 08             	sub    $0x8,%esp
f01026f6:	68 00 10 00 00       	push   $0x1000
f01026fb:	ff 35 6c 79 11 f0    	pushl  0xf011796c
f0102701:	e8 5f e9 ff ff       	call   f0101065 <page_remove>
	assert(pp2->pp_ref == 0);
f0102706:	83 c4 10             	add    $0x10,%esp
f0102709:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010270e:	74 19                	je     f0102729 <mem_init+0x15ba>
f0102710:	68 35 3f 10 f0       	push   $0xf0103f35
f0102715:	68 d8 3c 10 f0       	push   $0xf0103cd8
f010271a:	68 b3 03 00 00       	push   $0x3b3
f010271f:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102724:	e8 62 d9 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102729:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f010272f:	8b 11                	mov    (%ecx),%edx
f0102731:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102737:	89 d8                	mov    %ebx,%eax
f0102739:	2b 05 70 79 11 f0    	sub    0xf0117970,%eax
f010273f:	c1 f8 03             	sar    $0x3,%eax
f0102742:	c1 e0 0c             	shl    $0xc,%eax
f0102745:	39 c2                	cmp    %eax,%edx
f0102747:	74 19                	je     f0102762 <mem_init+0x15f3>
f0102749:	68 7c 42 10 f0       	push   $0xf010427c
f010274e:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102753:	68 b6 03 00 00       	push   $0x3b6
f0102758:	68 b2 3c 10 f0       	push   $0xf0103cb2
f010275d:	e8 29 d9 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102762:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102768:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010276d:	74 19                	je     f0102788 <mem_init+0x1619>
f010276f:	68 ec 3e 10 f0       	push   $0xf0103eec
f0102774:	68 d8 3c 10 f0       	push   $0xf0103cd8
f0102779:	68 b8 03 00 00       	push   $0x3b8
f010277e:	68 b2 3c 10 f0       	push   $0xf0103cb2
f0102783:	e8 03 d9 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102788:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010278e:	83 ec 0c             	sub    $0xc,%esp
f0102791:	53                   	push   %ebx
f0102792:	e8 cf e6 ff ff       	call   f0100e66 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102797:	c7 04 24 64 47 10 f0 	movl   $0xf0104764,(%esp)
f010279e:	e8 7d 00 00 00       	call   f0102820 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01027a3:	83 c4 10             	add    $0x10,%esp
f01027a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01027a9:	5b                   	pop    %ebx
f01027aa:	5e                   	pop    %esi
f01027ab:	5f                   	pop    %edi
f01027ac:	5d                   	pop    %ebp
f01027ad:	c3                   	ret    

f01027ae <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01027ae:	55                   	push   %ebp
f01027af:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01027b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027b4:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01027b7:	5d                   	pop    %ebp
f01027b8:	c3                   	ret    

f01027b9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01027b9:	55                   	push   %ebp
f01027ba:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01027bc:	ba 70 00 00 00       	mov    $0x70,%edx
f01027c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01027c4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01027c5:	ba 71 00 00 00       	mov    $0x71,%edx
f01027ca:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01027cb:	0f b6 c0             	movzbl %al,%eax
}
f01027ce:	5d                   	pop    %ebp
f01027cf:	c3                   	ret    

f01027d0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01027d0:	55                   	push   %ebp
f01027d1:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01027d3:	ba 70 00 00 00       	mov    $0x70,%edx
f01027d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01027db:	ee                   	out    %al,(%dx)
f01027dc:	ba 71 00 00 00       	mov    $0x71,%edx
f01027e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027e4:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01027e5:	5d                   	pop    %ebp
f01027e6:	c3                   	ret    

f01027e7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01027e7:	55                   	push   %ebp
f01027e8:	89 e5                	mov    %esp,%ebp
f01027ea:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01027ed:	ff 75 08             	pushl  0x8(%ebp)
f01027f0:	e8 0b de ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f01027f5:	83 c4 10             	add    $0x10,%esp
f01027f8:	c9                   	leave  
f01027f9:	c3                   	ret    

f01027fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01027fa:	55                   	push   %ebp
f01027fb:	89 e5                	mov    %esp,%ebp
f01027fd:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102800:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102807:	ff 75 0c             	pushl  0xc(%ebp)
f010280a:	ff 75 08             	pushl  0x8(%ebp)
f010280d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102810:	50                   	push   %eax
f0102811:	68 e7 27 10 f0       	push   $0xf01027e7
f0102816:	e8 5d 04 00 00       	call   f0102c78 <vprintfmt>
	return cnt;
}
f010281b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010281e:	c9                   	leave  
f010281f:	c3                   	ret    

f0102820 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102820:	55                   	push   %ebp
f0102821:	89 e5                	mov    %esp,%ebp
f0102823:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102826:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102829:	50                   	push   %eax
f010282a:	ff 75 08             	pushl  0x8(%ebp)
f010282d:	e8 c8 ff ff ff       	call   f01027fa <vcprintf>
	va_end(ap);

	return cnt;
}
f0102832:	c9                   	leave  
f0102833:	c3                   	ret    

f0102834 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
	   static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
f0102834:	55                   	push   %ebp
f0102835:	89 e5                	mov    %esp,%ebp
f0102837:	57                   	push   %edi
f0102838:	56                   	push   %esi
f0102839:	53                   	push   %ebx
f010283a:	83 ec 14             	sub    $0x14,%esp
f010283d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102840:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102843:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102846:	8b 7d 08             	mov    0x8(%ebp),%edi
	   int l = *region_left, r = *region_right, any_matches = 0;
f0102849:	8b 1a                	mov    (%edx),%ebx
f010284b:	8b 01                	mov    (%ecx),%eax
f010284d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102850:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	   while (l <= r) {
f0102857:	eb 7f                	jmp    f01028d8 <stab_binsearch+0xa4>
			 int true_m = (l + r) / 2, m = true_m;
f0102859:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010285c:	01 d8                	add    %ebx,%eax
f010285e:	89 c6                	mov    %eax,%esi
f0102860:	c1 ee 1f             	shr    $0x1f,%esi
f0102863:	01 c6                	add    %eax,%esi
f0102865:	d1 fe                	sar    %esi
f0102867:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010286a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010286d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102870:	89 f0                	mov    %esi,%eax

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f0102872:	eb 03                	jmp    f0102877 <stab_binsearch+0x43>
				    m--;
f0102874:	83 e8 01             	sub    $0x1,%eax

	   while (l <= r) {
			 int true_m = (l + r) / 2, m = true_m;

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f0102877:	39 c3                	cmp    %eax,%ebx
f0102879:	7f 0d                	jg     f0102888 <stab_binsearch+0x54>
f010287b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010287f:	83 ea 0c             	sub    $0xc,%edx
f0102882:	39 f9                	cmp    %edi,%ecx
f0102884:	75 ee                	jne    f0102874 <stab_binsearch+0x40>
f0102886:	eb 05                	jmp    f010288d <stab_binsearch+0x59>
				    m--;
			 if (m < l) {	// no match in [l, m]
				    l = true_m + 1;
f0102888:	8d 5e 01             	lea    0x1(%esi),%ebx
				    continue;
f010288b:	eb 4b                	jmp    f01028d8 <stab_binsearch+0xa4>
			 }

			 // actual binary search
			 any_matches = 1;
			 if (stabs[m].n_value < addr) {
f010288d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102890:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102893:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102897:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010289a:	76 11                	jbe    f01028ad <stab_binsearch+0x79>
				    *region_left = m;
f010289c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010289f:	89 03                	mov    %eax,(%ebx)
				    l = true_m + 1;
f01028a1:	8d 5e 01             	lea    0x1(%esi),%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f01028a4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01028ab:	eb 2b                	jmp    f01028d8 <stab_binsearch+0xa4>
			 if (stabs[m].n_value < addr) {
				    *region_left = m;
				    l = true_m + 1;
			 } else if (stabs[m].n_value > addr) {
f01028ad:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01028b0:	73 14                	jae    f01028c6 <stab_binsearch+0x92>
				    *region_right = m - 1;
f01028b2:	83 e8 01             	sub    $0x1,%eax
f01028b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01028b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028bb:	89 06                	mov    %eax,(%esi)
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f01028bd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01028c4:	eb 12                	jmp    f01028d8 <stab_binsearch+0xa4>
				    *region_right = m - 1;
				    r = m - 1;
			 } else {
				    // exact match for 'addr', but continue loop to find
				    // *region_right
				    *region_left = m;
f01028c6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028c9:	89 06                	mov    %eax,(%esi)
				    l = m;
				    addr++;
f01028cb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01028cf:	89 c3                	mov    %eax,%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f01028d1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
	   int l = *region_left, r = *region_right, any_matches = 0;

	   while (l <= r) {
f01028d8:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01028db:	0f 8e 78 ff ff ff    	jle    f0102859 <stab_binsearch+0x25>
				    l = m;
				    addr++;
			 }
	   }

	   if (!any_matches)
f01028e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01028e5:	75 0f                	jne    f01028f6 <stab_binsearch+0xc2>
			 *region_right = *region_left - 1;
f01028e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028ea:	8b 00                	mov    (%eax),%eax
f01028ec:	83 e8 01             	sub    $0x1,%eax
f01028ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028f2:	89 06                	mov    %eax,(%esi)
f01028f4:	eb 2c                	jmp    f0102922 <stab_binsearch+0xee>
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f01028f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028f9:	8b 00                	mov    (%eax),%eax
						  l > *region_left && stabs[l].n_type != type;
f01028fb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028fe:	8b 0e                	mov    (%esi),%ecx
f0102900:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102903:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102906:	8d 14 96             	lea    (%esi,%edx,4),%edx

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0102909:	eb 03                	jmp    f010290e <stab_binsearch+0xda>
						  l > *region_left && stabs[l].n_type != type;
						  l--)
f010290b:	83 e8 01             	sub    $0x1,%eax

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f010290e:	39 c8                	cmp    %ecx,%eax
f0102910:	7e 0b                	jle    f010291d <stab_binsearch+0xe9>
						  l > *region_left && stabs[l].n_type != type;
f0102912:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102916:	83 ea 0c             	sub    $0xc,%edx
f0102919:	39 df                	cmp    %ebx,%edi
f010291b:	75 ee                	jne    f010290b <stab_binsearch+0xd7>
						  l--)
				    /* do nothing */;
			 *region_left = l;
f010291d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102920:	89 06                	mov    %eax,(%esi)
	   }
}
f0102922:	83 c4 14             	add    $0x14,%esp
f0102925:	5b                   	pop    %ebx
f0102926:	5e                   	pop    %esi
f0102927:	5f                   	pop    %edi
f0102928:	5d                   	pop    %ebp
f0102929:	c3                   	ret    

f010292a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
	   int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010292a:	55                   	push   %ebp
f010292b:	89 e5                	mov    %esp,%ebp
f010292d:	57                   	push   %edi
f010292e:	56                   	push   %esi
f010292f:	53                   	push   %ebx
f0102930:	83 ec 3c             	sub    $0x3c,%esp
f0102933:	8b 75 08             	mov    0x8(%ebp),%esi
f0102936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   const struct Stab *stabs, *stab_end;
	   const char *stabstr, *stabstr_end;
	   int lfile, rfile, lfun, rfun, lline, rline;

	   // Initialize *info
	   info->eip_file = "<unknown>";
f0102939:	c7 03 90 47 10 f0    	movl   $0xf0104790,(%ebx)
	   info->eip_line = 0;
f010293f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	   info->eip_fn_name = "<unknown>";
f0102946:	c7 43 08 90 47 10 f0 	movl   $0xf0104790,0x8(%ebx)
	   info->eip_fn_namelen = 9;
f010294d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	   info->eip_fn_addr = addr;
f0102954:	89 73 10             	mov    %esi,0x10(%ebx)
	   info->eip_fn_narg = 0;
f0102957:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
f010295e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102964:	76 11                	jbe    f0102977 <debuginfo_eip+0x4d>
			 // Can't search for user-level addresses yet!
			 panic("User address");
	   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102966:	b8 47 c3 10 f0       	mov    $0xf010c347,%eax
f010296b:	3d 15 a5 10 f0       	cmp    $0xf010a515,%eax
f0102970:	77 19                	ja     f010298b <debuginfo_eip+0x61>
f0102972:	e9 b5 01 00 00       	jmp    f0102b2c <debuginfo_eip+0x202>
			 stab_end = __STAB_END__;
			 stabstr = __STABSTR_BEGIN__;
			 stabstr_end = __STABSTR_END__;
	   } else {
			 // Can't search for user-level addresses yet!
			 panic("User address");
f0102977:	83 ec 04             	sub    $0x4,%esp
f010297a:	68 9a 47 10 f0       	push   $0xf010479a
f010297f:	6a 7f                	push   $0x7f
f0102981:	68 a7 47 10 f0       	push   $0xf01047a7
f0102986:	e8 00 d7 ff ff       	call   f010008b <_panic>
	   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010298b:	80 3d 46 c3 10 f0 00 	cmpb   $0x0,0xf010c346
f0102992:	0f 85 9b 01 00 00    	jne    f0102b33 <debuginfo_eip+0x209>
	   // 'eip'.  First, we find the basic source file containing 'eip'.
	   // Then, we look in that source file for the function.  Then we look
	   // for the line number.

	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
f0102998:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   rfile = (stab_end - stabs) - 1;
f010299f:	b8 14 a5 10 f0       	mov    $0xf010a514,%eax
f01029a4:	2d c4 49 10 f0       	sub    $0xf01049c4,%eax
f01029a9:	c1 f8 02             	sar    $0x2,%eax
f01029ac:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01029b2:	83 e8 01             	sub    $0x1,%eax
f01029b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01029b8:	83 ec 08             	sub    $0x8,%esp
f01029bb:	56                   	push   %esi
f01029bc:	6a 64                	push   $0x64
f01029be:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01029c1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01029c4:	b8 c4 49 10 f0       	mov    $0xf01049c4,%eax
f01029c9:	e8 66 fe ff ff       	call   f0102834 <stab_binsearch>
	   if (lfile == 0)
f01029ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029d1:	83 c4 10             	add    $0x10,%esp
f01029d4:	85 c0                	test   %eax,%eax
f01029d6:	0f 84 5e 01 00 00    	je     f0102b3a <debuginfo_eip+0x210>
			 return -1;

	   // Search within that file's stabs for the function definition
	   // (N_FUN).
	   lfun = lfile;
f01029dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   rfun = rfile;
f01029df:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	   stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01029e5:	83 ec 08             	sub    $0x8,%esp
f01029e8:	56                   	push   %esi
f01029e9:	6a 24                	push   $0x24
f01029eb:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01029ee:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01029f1:	b8 c4 49 10 f0       	mov    $0xf01049c4,%eax
f01029f6:	e8 39 fe ff ff       	call   f0102834 <stab_binsearch>

	   if (lfun <= rfun) {
f01029fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01029fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102a01:	83 c4 10             	add    $0x10,%esp
f0102a04:	39 d0                	cmp    %edx,%eax
f0102a06:	7f 40                	jg     f0102a48 <debuginfo_eip+0x11e>
			 // stabs[lfun] points to the function name
			 // in the string table, but check bounds just in case.
			 if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102a08:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102a0b:	c1 e1 02             	shl    $0x2,%ecx
f0102a0e:	8d b9 c4 49 10 f0    	lea    -0xfefb63c(%ecx),%edi
f0102a14:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102a17:	8b b9 c4 49 10 f0    	mov    -0xfefb63c(%ecx),%edi
f0102a1d:	b9 47 c3 10 f0       	mov    $0xf010c347,%ecx
f0102a22:	81 e9 15 a5 10 f0    	sub    $0xf010a515,%ecx
f0102a28:	39 cf                	cmp    %ecx,%edi
f0102a2a:	73 09                	jae    f0102a35 <debuginfo_eip+0x10b>
				    info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102a2c:	81 c7 15 a5 10 f0    	add    $0xf010a515,%edi
f0102a32:	89 7b 08             	mov    %edi,0x8(%ebx)
			 info->eip_fn_addr = stabs[lfun].n_value;
f0102a35:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102a38:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102a3b:	89 4b 10             	mov    %ecx,0x10(%ebx)
			 addr -= info->eip_fn_addr;
f0102a3e:	29 ce                	sub    %ecx,%esi
			 // Search within the function definition for the line number.
			 lline = lfun;
f0102a40:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			 rline = rfun;
f0102a43:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102a46:	eb 0f                	jmp    f0102a57 <debuginfo_eip+0x12d>
	   } else {
			 // Couldn't find function stab!  Maybe we're in an assembly
			 // file.  Search the whole file for the line number.
			 info->eip_fn_addr = addr;
f0102a48:	89 73 10             	mov    %esi,0x10(%ebx)
			 lline = lfile;
f0102a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a4e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			 rline = rfile;
f0102a51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a54:	89 45 d0             	mov    %eax,-0x30(%ebp)
	   }
	   // Ignore stuff after the colon.
	   info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102a57:	83 ec 08             	sub    $0x8,%esp
f0102a5a:	6a 3a                	push   $0x3a
f0102a5c:	ff 73 08             	pushl  0x8(%ebx)
f0102a5f:	e8 64 08 00 00       	call   f01032c8 <strfind>
f0102a64:	2b 43 08             	sub    0x8(%ebx),%eax
f0102a67:	89 43 0c             	mov    %eax,0xc(%ebx)
	   //	There's a particular stabs type used for line numbers.
	   //	Look at the STABS documentation and <inc/stab.h> to find
	   //	which one.
	   // Your code here.

	   stab_binsearch (stabs, &lline, &rline, N_SLINE, addr);
f0102a6a:	83 c4 08             	add    $0x8,%esp
f0102a6d:	56                   	push   %esi
f0102a6e:	6a 44                	push   $0x44
f0102a70:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102a73:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102a76:	b8 c4 49 10 f0       	mov    $0xf01049c4,%eax
f0102a7b:	e8 b4 fd ff ff       	call   f0102834 <stab_binsearch>
	   if (lline <= rline)
f0102a80:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a83:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102a86:	83 c4 10             	add    $0x10,%esp
f0102a89:	39 d0                	cmp    %edx,%eax
f0102a8b:	0f 8f b0 00 00 00    	jg     f0102b41 <debuginfo_eip+0x217>
	   {
			 info -> eip_line = stabs [rline].n_desc;
f0102a91:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102a94:	0f b7 14 95 ca 49 10 	movzwl -0xfefb636(,%edx,4),%edx
f0102a9b:	f0 
f0102a9c:	89 53 04             	mov    %edx,0x4(%ebx)
	   // Search backwards from the line number for the relevant filename
	   // stab.
	   // We can't just use the "lfile" stab because inlined functions
	   // can interpolate code from a different file!
	   // Such included source files use the N_SOL stab type.
	   while (lline >= lfile
f0102a9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102aa2:	89 c2                	mov    %eax,%edx
f0102aa4:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102aa7:	8d 04 85 c4 49 10 f0 	lea    -0xfefb63c(,%eax,4),%eax
f0102aae:	eb 06                	jmp    f0102ab6 <debuginfo_eip+0x18c>
f0102ab0:	83 ea 01             	sub    $0x1,%edx
f0102ab3:	83 e8 0c             	sub    $0xc,%eax
f0102ab6:	39 d7                	cmp    %edx,%edi
f0102ab8:	7f 34                	jg     f0102aee <debuginfo_eip+0x1c4>
				    && stabs[lline].n_type != N_SOL
f0102aba:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102abe:	80 f9 84             	cmp    $0x84,%cl
f0102ac1:	74 0b                	je     f0102ace <debuginfo_eip+0x1a4>
				    && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102ac3:	80 f9 64             	cmp    $0x64,%cl
f0102ac6:	75 e8                	jne    f0102ab0 <debuginfo_eip+0x186>
f0102ac8:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102acc:	74 e2                	je     f0102ab0 <debuginfo_eip+0x186>
			 lline--;
	   if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102ace:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102ad1:	8b 14 85 c4 49 10 f0 	mov    -0xfefb63c(,%eax,4),%edx
f0102ad8:	b8 47 c3 10 f0       	mov    $0xf010c347,%eax
f0102add:	2d 15 a5 10 f0       	sub    $0xf010a515,%eax
f0102ae2:	39 c2                	cmp    %eax,%edx
f0102ae4:	73 08                	jae    f0102aee <debuginfo_eip+0x1c4>
			 info->eip_file = stabstr + stabs[lline].n_strx;
f0102ae6:	81 c2 15 a5 10 f0    	add    $0xf010a515,%edx
f0102aec:	89 13                	mov    %edx,(%ebx)


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0102aee:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102af1:	8b 75 d8             	mov    -0x28(%ebp),%esi
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0102af4:	b8 00 00 00 00       	mov    $0x0,%eax
			 info->eip_file = stabstr + stabs[lline].n_strx;


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0102af9:	39 f2                	cmp    %esi,%edx
f0102afb:	7d 50                	jge    f0102b4d <debuginfo_eip+0x223>
			 for (lline = lfun + 1;
f0102afd:	83 c2 01             	add    $0x1,%edx
f0102b00:	89 d0                	mov    %edx,%eax
f0102b02:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102b05:	8d 14 95 c4 49 10 f0 	lea    -0xfefb63c(,%edx,4),%edx
f0102b0c:	eb 04                	jmp    f0102b12 <debuginfo_eip+0x1e8>
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;
f0102b0e:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
			 for (lline = lfun + 1;
f0102b12:	39 c6                	cmp    %eax,%esi
f0102b14:	7e 32                	jle    f0102b48 <debuginfo_eip+0x21e>
						  lline < rfun && stabs[lline].n_type == N_PSYM;
f0102b16:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102b1a:	83 c0 01             	add    $0x1,%eax
f0102b1d:	83 c2 0c             	add    $0xc,%edx
f0102b20:	80 f9 a0             	cmp    $0xa0,%cl
f0102b23:	74 e9                	je     f0102b0e <debuginfo_eip+0x1e4>
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0102b25:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b2a:	eb 21                	jmp    f0102b4d <debuginfo_eip+0x223>
			 panic("User address");
	   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
			 return -1;
f0102b2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b31:	eb 1a                	jmp    f0102b4d <debuginfo_eip+0x223>
f0102b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b38:	eb 13                	jmp    f0102b4d <debuginfo_eip+0x223>
	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
	   rfile = (stab_end - stabs) - 1;
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	   if (lfile == 0)
			 return -1;
f0102b3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b3f:	eb 0c                	jmp    f0102b4d <debuginfo_eip+0x223>
	   if (lline <= rline)
	   {
			 info -> eip_line = stabs [rline].n_desc;
	   } else
	   {
			 return -1;
f0102b41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b46:	eb 05                	jmp    f0102b4d <debuginfo_eip+0x223>
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0102b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b50:	5b                   	pop    %ebx
f0102b51:	5e                   	pop    %esi
f0102b52:	5f                   	pop    %edi
f0102b53:	5d                   	pop    %ebp
f0102b54:	c3                   	ret    

f0102b55 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102b55:	55                   	push   %ebp
f0102b56:	89 e5                	mov    %esp,%ebp
f0102b58:	57                   	push   %edi
f0102b59:	56                   	push   %esi
f0102b5a:	53                   	push   %ebx
f0102b5b:	83 ec 1c             	sub    $0x1c,%esp
f0102b5e:	89 c7                	mov    %eax,%edi
f0102b60:	89 d6                	mov    %edx,%esi
f0102b62:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b65:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102b68:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b6b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102b71:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b76:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102b79:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102b7c:	39 d3                	cmp    %edx,%ebx
f0102b7e:	72 05                	jb     f0102b85 <printnum+0x30>
f0102b80:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102b83:	77 45                	ja     f0102bca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102b85:	83 ec 0c             	sub    $0xc,%esp
f0102b88:	ff 75 18             	pushl  0x18(%ebp)
f0102b8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b8e:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102b91:	53                   	push   %ebx
f0102b92:	ff 75 10             	pushl  0x10(%ebp)
f0102b95:	83 ec 08             	sub    $0x8,%esp
f0102b98:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b9b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b9e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102ba1:	ff 75 d8             	pushl  -0x28(%ebp)
f0102ba4:	e8 47 09 00 00       	call   f01034f0 <__udivdi3>
f0102ba9:	83 c4 18             	add    $0x18,%esp
f0102bac:	52                   	push   %edx
f0102bad:	50                   	push   %eax
f0102bae:	89 f2                	mov    %esi,%edx
f0102bb0:	89 f8                	mov    %edi,%eax
f0102bb2:	e8 9e ff ff ff       	call   f0102b55 <printnum>
f0102bb7:	83 c4 20             	add    $0x20,%esp
f0102bba:	eb 18                	jmp    f0102bd4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102bbc:	83 ec 08             	sub    $0x8,%esp
f0102bbf:	56                   	push   %esi
f0102bc0:	ff 75 18             	pushl  0x18(%ebp)
f0102bc3:	ff d7                	call   *%edi
f0102bc5:	83 c4 10             	add    $0x10,%esp
f0102bc8:	eb 03                	jmp    f0102bcd <printnum+0x78>
f0102bca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102bcd:	83 eb 01             	sub    $0x1,%ebx
f0102bd0:	85 db                	test   %ebx,%ebx
f0102bd2:	7f e8                	jg     f0102bbc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102bd4:	83 ec 08             	sub    $0x8,%esp
f0102bd7:	56                   	push   %esi
f0102bd8:	83 ec 04             	sub    $0x4,%esp
f0102bdb:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102bde:	ff 75 e0             	pushl  -0x20(%ebp)
f0102be1:	ff 75 dc             	pushl  -0x24(%ebp)
f0102be4:	ff 75 d8             	pushl  -0x28(%ebp)
f0102be7:	e8 34 0a 00 00       	call   f0103620 <__umoddi3>
f0102bec:	83 c4 14             	add    $0x14,%esp
f0102bef:	0f be 80 b5 47 10 f0 	movsbl -0xfefb84b(%eax),%eax
f0102bf6:	50                   	push   %eax
f0102bf7:	ff d7                	call   *%edi
}
f0102bf9:	83 c4 10             	add    $0x10,%esp
f0102bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bff:	5b                   	pop    %ebx
f0102c00:	5e                   	pop    %esi
f0102c01:	5f                   	pop    %edi
f0102c02:	5d                   	pop    %ebp
f0102c03:	c3                   	ret    

f0102c04 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102c04:	55                   	push   %ebp
f0102c05:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102c07:	83 fa 01             	cmp    $0x1,%edx
f0102c0a:	7e 0e                	jle    f0102c1a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102c0c:	8b 10                	mov    (%eax),%edx
f0102c0e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102c11:	89 08                	mov    %ecx,(%eax)
f0102c13:	8b 02                	mov    (%edx),%eax
f0102c15:	8b 52 04             	mov    0x4(%edx),%edx
f0102c18:	eb 22                	jmp    f0102c3c <getuint+0x38>
	else if (lflag)
f0102c1a:	85 d2                	test   %edx,%edx
f0102c1c:	74 10                	je     f0102c2e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102c1e:	8b 10                	mov    (%eax),%edx
f0102c20:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102c23:	89 08                	mov    %ecx,(%eax)
f0102c25:	8b 02                	mov    (%edx),%eax
f0102c27:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c2c:	eb 0e                	jmp    f0102c3c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102c2e:	8b 10                	mov    (%eax),%edx
f0102c30:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102c33:	89 08                	mov    %ecx,(%eax)
f0102c35:	8b 02                	mov    (%edx),%eax
f0102c37:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102c3c:	5d                   	pop    %ebp
f0102c3d:	c3                   	ret    

f0102c3e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102c3e:	55                   	push   %ebp
f0102c3f:	89 e5                	mov    %esp,%ebp
f0102c41:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102c44:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102c48:	8b 10                	mov    (%eax),%edx
f0102c4a:	3b 50 04             	cmp    0x4(%eax),%edx
f0102c4d:	73 0a                	jae    f0102c59 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102c4f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102c52:	89 08                	mov    %ecx,(%eax)
f0102c54:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c57:	88 02                	mov    %al,(%edx)
}
f0102c59:	5d                   	pop    %ebp
f0102c5a:	c3                   	ret    

f0102c5b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102c5b:	55                   	push   %ebp
f0102c5c:	89 e5                	mov    %esp,%ebp
f0102c5e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102c61:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102c64:	50                   	push   %eax
f0102c65:	ff 75 10             	pushl  0x10(%ebp)
f0102c68:	ff 75 0c             	pushl  0xc(%ebp)
f0102c6b:	ff 75 08             	pushl  0x8(%ebp)
f0102c6e:	e8 05 00 00 00       	call   f0102c78 <vprintfmt>
	va_end(ap);
}
f0102c73:	83 c4 10             	add    $0x10,%esp
f0102c76:	c9                   	leave  
f0102c77:	c3                   	ret    

f0102c78 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102c78:	55                   	push   %ebp
f0102c79:	89 e5                	mov    %esp,%ebp
f0102c7b:	57                   	push   %edi
f0102c7c:	56                   	push   %esi
f0102c7d:	53                   	push   %ebx
f0102c7e:	83 ec 2c             	sub    $0x2c,%esp
f0102c81:	8b 75 08             	mov    0x8(%ebp),%esi
f0102c84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102c87:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102c8a:	eb 12                	jmp    f0102c9e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102c8c:	85 c0                	test   %eax,%eax
f0102c8e:	0f 84 89 03 00 00    	je     f010301d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102c94:	83 ec 08             	sub    $0x8,%esp
f0102c97:	53                   	push   %ebx
f0102c98:	50                   	push   %eax
f0102c99:	ff d6                	call   *%esi
f0102c9b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102c9e:	83 c7 01             	add    $0x1,%edi
f0102ca1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102ca5:	83 f8 25             	cmp    $0x25,%eax
f0102ca8:	75 e2                	jne    f0102c8c <vprintfmt+0x14>
f0102caa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102cae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102cb5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102cbc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102cc3:	ba 00 00 00 00       	mov    $0x0,%edx
f0102cc8:	eb 07                	jmp    f0102cd1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cca:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102ccd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cd1:	8d 47 01             	lea    0x1(%edi),%eax
f0102cd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102cd7:	0f b6 07             	movzbl (%edi),%eax
f0102cda:	0f b6 c8             	movzbl %al,%ecx
f0102cdd:	83 e8 23             	sub    $0x23,%eax
f0102ce0:	3c 55                	cmp    $0x55,%al
f0102ce2:	0f 87 1a 03 00 00    	ja     f0103002 <vprintfmt+0x38a>
f0102ce8:	0f b6 c0             	movzbl %al,%eax
f0102ceb:	ff 24 85 40 48 10 f0 	jmp    *-0xfefb7c0(,%eax,4)
f0102cf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102cf5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102cf9:	eb d6                	jmp    f0102cd1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cfb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cfe:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d03:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102d06:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102d09:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102d0d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102d10:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102d13:	83 fa 09             	cmp    $0x9,%edx
f0102d16:	77 39                	ja     f0102d51 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102d18:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102d1b:	eb e9                	jmp    f0102d06 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102d1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d20:	8d 48 04             	lea    0x4(%eax),%ecx
f0102d23:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102d26:	8b 00                	mov    (%eax),%eax
f0102d28:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102d2e:	eb 27                	jmp    f0102d57 <vprintfmt+0xdf>
f0102d30:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d33:	85 c0                	test   %eax,%eax
f0102d35:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102d3a:	0f 49 c8             	cmovns %eax,%ecx
f0102d3d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d43:	eb 8c                	jmp    f0102cd1 <vprintfmt+0x59>
f0102d45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102d48:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102d4f:	eb 80                	jmp    f0102cd1 <vprintfmt+0x59>
f0102d51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102d54:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102d57:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d5b:	0f 89 70 ff ff ff    	jns    f0102cd1 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102d61:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d64:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d67:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102d6e:	e9 5e ff ff ff       	jmp    f0102cd1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102d73:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102d79:	e9 53 ff ff ff       	jmp    f0102cd1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102d7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d81:	8d 50 04             	lea    0x4(%eax),%edx
f0102d84:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d87:	83 ec 08             	sub    $0x8,%esp
f0102d8a:	53                   	push   %ebx
f0102d8b:	ff 30                	pushl  (%eax)
f0102d8d:	ff d6                	call   *%esi
			break;
f0102d8f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102d95:	e9 04 ff ff ff       	jmp    f0102c9e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d9a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d9d:	8d 50 04             	lea    0x4(%eax),%edx
f0102da0:	89 55 14             	mov    %edx,0x14(%ebp)
f0102da3:	8b 00                	mov    (%eax),%eax
f0102da5:	99                   	cltd   
f0102da6:	31 d0                	xor    %edx,%eax
f0102da8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102daa:	83 f8 06             	cmp    $0x6,%eax
f0102dad:	7f 0b                	jg     f0102dba <vprintfmt+0x142>
f0102daf:	8b 14 85 98 49 10 f0 	mov    -0xfefb668(,%eax,4),%edx
f0102db6:	85 d2                	test   %edx,%edx
f0102db8:	75 18                	jne    f0102dd2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102dba:	50                   	push   %eax
f0102dbb:	68 cd 47 10 f0       	push   $0xf01047cd
f0102dc0:	53                   	push   %ebx
f0102dc1:	56                   	push   %esi
f0102dc2:	e8 94 fe ff ff       	call   f0102c5b <printfmt>
f0102dc7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102dca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102dcd:	e9 cc fe ff ff       	jmp    f0102c9e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102dd2:	52                   	push   %edx
f0102dd3:	68 ea 3c 10 f0       	push   $0xf0103cea
f0102dd8:	53                   	push   %ebx
f0102dd9:	56                   	push   %esi
f0102dda:	e8 7c fe ff ff       	call   f0102c5b <printfmt>
f0102ddf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102de2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102de5:	e9 b4 fe ff ff       	jmp    f0102c9e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102dea:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ded:	8d 50 04             	lea    0x4(%eax),%edx
f0102df0:	89 55 14             	mov    %edx,0x14(%ebp)
f0102df3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102df5:	85 ff                	test   %edi,%edi
f0102df7:	b8 c6 47 10 f0       	mov    $0xf01047c6,%eax
f0102dfc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102dff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e03:	0f 8e 94 00 00 00    	jle    f0102e9d <vprintfmt+0x225>
f0102e09:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102e0d:	0f 84 98 00 00 00    	je     f0102eab <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e13:	83 ec 08             	sub    $0x8,%esp
f0102e16:	ff 75 d0             	pushl  -0x30(%ebp)
f0102e19:	57                   	push   %edi
f0102e1a:	e8 5f 03 00 00       	call   f010317e <strnlen>
f0102e1f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102e22:	29 c1                	sub    %eax,%ecx
f0102e24:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102e27:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102e2a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102e2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e31:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102e34:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e36:	eb 0f                	jmp    f0102e47 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102e38:	83 ec 08             	sub    $0x8,%esp
f0102e3b:	53                   	push   %ebx
f0102e3c:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e3f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e41:	83 ef 01             	sub    $0x1,%edi
f0102e44:	83 c4 10             	add    $0x10,%esp
f0102e47:	85 ff                	test   %edi,%edi
f0102e49:	7f ed                	jg     f0102e38 <vprintfmt+0x1c0>
f0102e4b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e4e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102e51:	85 c9                	test   %ecx,%ecx
f0102e53:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e58:	0f 49 c1             	cmovns %ecx,%eax
f0102e5b:	29 c1                	sub    %eax,%ecx
f0102e5d:	89 75 08             	mov    %esi,0x8(%ebp)
f0102e60:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102e63:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e66:	89 cb                	mov    %ecx,%ebx
f0102e68:	eb 4d                	jmp    f0102eb7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102e6a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102e6e:	74 1b                	je     f0102e8b <vprintfmt+0x213>
f0102e70:	0f be c0             	movsbl %al,%eax
f0102e73:	83 e8 20             	sub    $0x20,%eax
f0102e76:	83 f8 5e             	cmp    $0x5e,%eax
f0102e79:	76 10                	jbe    f0102e8b <vprintfmt+0x213>
					putch('?', putdat);
f0102e7b:	83 ec 08             	sub    $0x8,%esp
f0102e7e:	ff 75 0c             	pushl  0xc(%ebp)
f0102e81:	6a 3f                	push   $0x3f
f0102e83:	ff 55 08             	call   *0x8(%ebp)
f0102e86:	83 c4 10             	add    $0x10,%esp
f0102e89:	eb 0d                	jmp    f0102e98 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102e8b:	83 ec 08             	sub    $0x8,%esp
f0102e8e:	ff 75 0c             	pushl  0xc(%ebp)
f0102e91:	52                   	push   %edx
f0102e92:	ff 55 08             	call   *0x8(%ebp)
f0102e95:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102e98:	83 eb 01             	sub    $0x1,%ebx
f0102e9b:	eb 1a                	jmp    f0102eb7 <vprintfmt+0x23f>
f0102e9d:	89 75 08             	mov    %esi,0x8(%ebp)
f0102ea0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102ea3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102ea6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102ea9:	eb 0c                	jmp    f0102eb7 <vprintfmt+0x23f>
f0102eab:	89 75 08             	mov    %esi,0x8(%ebp)
f0102eae:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102eb1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102eb4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102eb7:	83 c7 01             	add    $0x1,%edi
f0102eba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102ebe:	0f be d0             	movsbl %al,%edx
f0102ec1:	85 d2                	test   %edx,%edx
f0102ec3:	74 23                	je     f0102ee8 <vprintfmt+0x270>
f0102ec5:	85 f6                	test   %esi,%esi
f0102ec7:	78 a1                	js     f0102e6a <vprintfmt+0x1f2>
f0102ec9:	83 ee 01             	sub    $0x1,%esi
f0102ecc:	79 9c                	jns    f0102e6a <vprintfmt+0x1f2>
f0102ece:	89 df                	mov    %ebx,%edi
f0102ed0:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ed3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ed6:	eb 18                	jmp    f0102ef0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102ed8:	83 ec 08             	sub    $0x8,%esp
f0102edb:	53                   	push   %ebx
f0102edc:	6a 20                	push   $0x20
f0102ede:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102ee0:	83 ef 01             	sub    $0x1,%edi
f0102ee3:	83 c4 10             	add    $0x10,%esp
f0102ee6:	eb 08                	jmp    f0102ef0 <vprintfmt+0x278>
f0102ee8:	89 df                	mov    %ebx,%edi
f0102eea:	8b 75 08             	mov    0x8(%ebp),%esi
f0102eed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ef0:	85 ff                	test   %edi,%edi
f0102ef2:	7f e4                	jg     f0102ed8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ef4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ef7:	e9 a2 fd ff ff       	jmp    f0102c9e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102efc:	83 fa 01             	cmp    $0x1,%edx
f0102eff:	7e 16                	jle    f0102f17 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102f01:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f04:	8d 50 08             	lea    0x8(%eax),%edx
f0102f07:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f0a:	8b 50 04             	mov    0x4(%eax),%edx
f0102f0d:	8b 00                	mov    (%eax),%eax
f0102f0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f12:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102f15:	eb 32                	jmp    f0102f49 <vprintfmt+0x2d1>
	else if (lflag)
f0102f17:	85 d2                	test   %edx,%edx
f0102f19:	74 18                	je     f0102f33 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102f1b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f1e:	8d 50 04             	lea    0x4(%eax),%edx
f0102f21:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f24:	8b 00                	mov    (%eax),%eax
f0102f26:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f29:	89 c1                	mov    %eax,%ecx
f0102f2b:	c1 f9 1f             	sar    $0x1f,%ecx
f0102f2e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102f31:	eb 16                	jmp    f0102f49 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102f33:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f36:	8d 50 04             	lea    0x4(%eax),%edx
f0102f39:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f3c:	8b 00                	mov    (%eax),%eax
f0102f3e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f41:	89 c1                	mov    %eax,%ecx
f0102f43:	c1 f9 1f             	sar    $0x1f,%ecx
f0102f46:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102f49:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102f4f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102f54:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102f58:	79 74                	jns    f0102fce <vprintfmt+0x356>
				putch('-', putdat);
f0102f5a:	83 ec 08             	sub    $0x8,%esp
f0102f5d:	53                   	push   %ebx
f0102f5e:	6a 2d                	push   $0x2d
f0102f60:	ff d6                	call   *%esi
				num = -(long long) num;
f0102f62:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102f65:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f68:	f7 d8                	neg    %eax
f0102f6a:	83 d2 00             	adc    $0x0,%edx
f0102f6d:	f7 da                	neg    %edx
f0102f6f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102f72:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102f77:	eb 55                	jmp    f0102fce <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102f79:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f7c:	e8 83 fc ff ff       	call   f0102c04 <getuint>
			base = 10;
f0102f81:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102f86:	eb 46                	jmp    f0102fce <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0102f88:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f8b:	e8 74 fc ff ff       	call   f0102c04 <getuint>
			base = 8;
f0102f90:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0102f95:	eb 37                	jmp    f0102fce <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
f0102f97:	83 ec 08             	sub    $0x8,%esp
f0102f9a:	53                   	push   %ebx
f0102f9b:	6a 30                	push   $0x30
f0102f9d:	ff d6                	call   *%esi
			putch('x', putdat);
f0102f9f:	83 c4 08             	add    $0x8,%esp
f0102fa2:	53                   	push   %ebx
f0102fa3:	6a 78                	push   $0x78
f0102fa5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102fa7:	8b 45 14             	mov    0x14(%ebp),%eax
f0102faa:	8d 50 04             	lea    0x4(%eax),%edx
f0102fad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102fb0:	8b 00                	mov    (%eax),%eax
f0102fb2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102fb7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102fba:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102fbf:	eb 0d                	jmp    f0102fce <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102fc1:	8d 45 14             	lea    0x14(%ebp),%eax
f0102fc4:	e8 3b fc ff ff       	call   f0102c04 <getuint>
			base = 16;
f0102fc9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102fce:	83 ec 0c             	sub    $0xc,%esp
f0102fd1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102fd5:	57                   	push   %edi
f0102fd6:	ff 75 e0             	pushl  -0x20(%ebp)
f0102fd9:	51                   	push   %ecx
f0102fda:	52                   	push   %edx
f0102fdb:	50                   	push   %eax
f0102fdc:	89 da                	mov    %ebx,%edx
f0102fde:	89 f0                	mov    %esi,%eax
f0102fe0:	e8 70 fb ff ff       	call   f0102b55 <printnum>
			break;
f0102fe5:	83 c4 20             	add    $0x20,%esp
f0102fe8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102feb:	e9 ae fc ff ff       	jmp    f0102c9e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102ff0:	83 ec 08             	sub    $0x8,%esp
f0102ff3:	53                   	push   %ebx
f0102ff4:	51                   	push   %ecx
f0102ff5:	ff d6                	call   *%esi
			break;
f0102ff7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ffa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102ffd:	e9 9c fc ff ff       	jmp    f0102c9e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103002:	83 ec 08             	sub    $0x8,%esp
f0103005:	53                   	push   %ebx
f0103006:	6a 25                	push   $0x25
f0103008:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010300a:	83 c4 10             	add    $0x10,%esp
f010300d:	eb 03                	jmp    f0103012 <vprintfmt+0x39a>
f010300f:	83 ef 01             	sub    $0x1,%edi
f0103012:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103016:	75 f7                	jne    f010300f <vprintfmt+0x397>
f0103018:	e9 81 fc ff ff       	jmp    f0102c9e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010301d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103020:	5b                   	pop    %ebx
f0103021:	5e                   	pop    %esi
f0103022:	5f                   	pop    %edi
f0103023:	5d                   	pop    %ebp
f0103024:	c3                   	ret    

f0103025 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103025:	55                   	push   %ebp
f0103026:	89 e5                	mov    %esp,%ebp
f0103028:	83 ec 18             	sub    $0x18,%esp
f010302b:	8b 45 08             	mov    0x8(%ebp),%eax
f010302e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103031:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103034:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103038:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010303b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103042:	85 c0                	test   %eax,%eax
f0103044:	74 26                	je     f010306c <vsnprintf+0x47>
f0103046:	85 d2                	test   %edx,%edx
f0103048:	7e 22                	jle    f010306c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010304a:	ff 75 14             	pushl  0x14(%ebp)
f010304d:	ff 75 10             	pushl  0x10(%ebp)
f0103050:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103053:	50                   	push   %eax
f0103054:	68 3e 2c 10 f0       	push   $0xf0102c3e
f0103059:	e8 1a fc ff ff       	call   f0102c78 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010305e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103061:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103064:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103067:	83 c4 10             	add    $0x10,%esp
f010306a:	eb 05                	jmp    f0103071 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010306c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103071:	c9                   	leave  
f0103072:	c3                   	ret    

f0103073 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103073:	55                   	push   %ebp
f0103074:	89 e5                	mov    %esp,%ebp
f0103076:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103079:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010307c:	50                   	push   %eax
f010307d:	ff 75 10             	pushl  0x10(%ebp)
f0103080:	ff 75 0c             	pushl  0xc(%ebp)
f0103083:	ff 75 08             	pushl  0x8(%ebp)
f0103086:	e8 9a ff ff ff       	call   f0103025 <vsnprintf>
	va_end(ap);

	return rc;
}
f010308b:	c9                   	leave  
f010308c:	c3                   	ret    

f010308d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010308d:	55                   	push   %ebp
f010308e:	89 e5                	mov    %esp,%ebp
f0103090:	57                   	push   %edi
f0103091:	56                   	push   %esi
f0103092:	53                   	push   %ebx
f0103093:	83 ec 0c             	sub    $0xc,%esp
f0103096:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103099:	85 c0                	test   %eax,%eax
f010309b:	74 11                	je     f01030ae <readline+0x21>
		cprintf("%s", prompt);
f010309d:	83 ec 08             	sub    $0x8,%esp
f01030a0:	50                   	push   %eax
f01030a1:	68 ea 3c 10 f0       	push   $0xf0103cea
f01030a6:	e8 75 f7 ff ff       	call   f0102820 <cprintf>
f01030ab:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01030ae:	83 ec 0c             	sub    $0xc,%esp
f01030b1:	6a 00                	push   $0x0
f01030b3:	e8 69 d5 ff ff       	call   f0100621 <iscons>
f01030b8:	89 c7                	mov    %eax,%edi
f01030ba:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01030bd:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01030c2:	e8 49 d5 ff ff       	call   f0100610 <getchar>
f01030c7:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01030c9:	85 c0                	test   %eax,%eax
f01030cb:	79 18                	jns    f01030e5 <readline+0x58>
			cprintf("read error: %e\n", c);
f01030cd:	83 ec 08             	sub    $0x8,%esp
f01030d0:	50                   	push   %eax
f01030d1:	68 b4 49 10 f0       	push   $0xf01049b4
f01030d6:	e8 45 f7 ff ff       	call   f0102820 <cprintf>
			return NULL;
f01030db:	83 c4 10             	add    $0x10,%esp
f01030de:	b8 00 00 00 00       	mov    $0x0,%eax
f01030e3:	eb 79                	jmp    f010315e <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01030e5:	83 f8 08             	cmp    $0x8,%eax
f01030e8:	0f 94 c2             	sete   %dl
f01030eb:	83 f8 7f             	cmp    $0x7f,%eax
f01030ee:	0f 94 c0             	sete   %al
f01030f1:	08 c2                	or     %al,%dl
f01030f3:	74 1a                	je     f010310f <readline+0x82>
f01030f5:	85 f6                	test   %esi,%esi
f01030f7:	7e 16                	jle    f010310f <readline+0x82>
			if (echoing)
f01030f9:	85 ff                	test   %edi,%edi
f01030fb:	74 0d                	je     f010310a <readline+0x7d>
				cputchar('\b');
f01030fd:	83 ec 0c             	sub    $0xc,%esp
f0103100:	6a 08                	push   $0x8
f0103102:	e8 f9 d4 ff ff       	call   f0100600 <cputchar>
f0103107:	83 c4 10             	add    $0x10,%esp
			i--;
f010310a:	83 ee 01             	sub    $0x1,%esi
f010310d:	eb b3                	jmp    f01030c2 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010310f:	83 fb 1f             	cmp    $0x1f,%ebx
f0103112:	7e 23                	jle    f0103137 <readline+0xaa>
f0103114:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010311a:	7f 1b                	jg     f0103137 <readline+0xaa>
			if (echoing)
f010311c:	85 ff                	test   %edi,%edi
f010311e:	74 0c                	je     f010312c <readline+0x9f>
				cputchar(c);
f0103120:	83 ec 0c             	sub    $0xc,%esp
f0103123:	53                   	push   %ebx
f0103124:	e8 d7 d4 ff ff       	call   f0100600 <cputchar>
f0103129:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010312c:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0103132:	8d 76 01             	lea    0x1(%esi),%esi
f0103135:	eb 8b                	jmp    f01030c2 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103137:	83 fb 0a             	cmp    $0xa,%ebx
f010313a:	74 05                	je     f0103141 <readline+0xb4>
f010313c:	83 fb 0d             	cmp    $0xd,%ebx
f010313f:	75 81                	jne    f01030c2 <readline+0x35>
			if (echoing)
f0103141:	85 ff                	test   %edi,%edi
f0103143:	74 0d                	je     f0103152 <readline+0xc5>
				cputchar('\n');
f0103145:	83 ec 0c             	sub    $0xc,%esp
f0103148:	6a 0a                	push   $0xa
f010314a:	e8 b1 d4 ff ff       	call   f0100600 <cputchar>
f010314f:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103152:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f0103159:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f010315e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103161:	5b                   	pop    %ebx
f0103162:	5e                   	pop    %esi
f0103163:	5f                   	pop    %edi
f0103164:	5d                   	pop    %ebp
f0103165:	c3                   	ret    

f0103166 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103166:	55                   	push   %ebp
f0103167:	89 e5                	mov    %esp,%ebp
f0103169:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010316c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103171:	eb 03                	jmp    f0103176 <strlen+0x10>
		n++;
f0103173:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103176:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010317a:	75 f7                	jne    f0103173 <strlen+0xd>
		n++;
	return n;
}
f010317c:	5d                   	pop    %ebp
f010317d:	c3                   	ret    

f010317e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010317e:	55                   	push   %ebp
f010317f:	89 e5                	mov    %esp,%ebp
f0103181:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103184:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103187:	ba 00 00 00 00       	mov    $0x0,%edx
f010318c:	eb 03                	jmp    f0103191 <strnlen+0x13>
		n++;
f010318e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103191:	39 c2                	cmp    %eax,%edx
f0103193:	74 08                	je     f010319d <strnlen+0x1f>
f0103195:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103199:	75 f3                	jne    f010318e <strnlen+0x10>
f010319b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010319d:	5d                   	pop    %ebp
f010319e:	c3                   	ret    

f010319f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010319f:	55                   	push   %ebp
f01031a0:	89 e5                	mov    %esp,%ebp
f01031a2:	53                   	push   %ebx
f01031a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01031a9:	89 c2                	mov    %eax,%edx
f01031ab:	83 c2 01             	add    $0x1,%edx
f01031ae:	83 c1 01             	add    $0x1,%ecx
f01031b1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01031b5:	88 5a ff             	mov    %bl,-0x1(%edx)
f01031b8:	84 db                	test   %bl,%bl
f01031ba:	75 ef                	jne    f01031ab <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01031bc:	5b                   	pop    %ebx
f01031bd:	5d                   	pop    %ebp
f01031be:	c3                   	ret    

f01031bf <strcat>:

char *
strcat(char *dst, const char *src)
{
f01031bf:	55                   	push   %ebp
f01031c0:	89 e5                	mov    %esp,%ebp
f01031c2:	53                   	push   %ebx
f01031c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01031c6:	53                   	push   %ebx
f01031c7:	e8 9a ff ff ff       	call   f0103166 <strlen>
f01031cc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01031cf:	ff 75 0c             	pushl  0xc(%ebp)
f01031d2:	01 d8                	add    %ebx,%eax
f01031d4:	50                   	push   %eax
f01031d5:	e8 c5 ff ff ff       	call   f010319f <strcpy>
	return dst;
}
f01031da:	89 d8                	mov    %ebx,%eax
f01031dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031df:	c9                   	leave  
f01031e0:	c3                   	ret    

f01031e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01031e1:	55                   	push   %ebp
f01031e2:	89 e5                	mov    %esp,%ebp
f01031e4:	56                   	push   %esi
f01031e5:	53                   	push   %ebx
f01031e6:	8b 75 08             	mov    0x8(%ebp),%esi
f01031e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031ec:	89 f3                	mov    %esi,%ebx
f01031ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01031f1:	89 f2                	mov    %esi,%edx
f01031f3:	eb 0f                	jmp    f0103204 <strncpy+0x23>
		*dst++ = *src;
f01031f5:	83 c2 01             	add    $0x1,%edx
f01031f8:	0f b6 01             	movzbl (%ecx),%eax
f01031fb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01031fe:	80 39 01             	cmpb   $0x1,(%ecx)
f0103201:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103204:	39 da                	cmp    %ebx,%edx
f0103206:	75 ed                	jne    f01031f5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103208:	89 f0                	mov    %esi,%eax
f010320a:	5b                   	pop    %ebx
f010320b:	5e                   	pop    %esi
f010320c:	5d                   	pop    %ebp
f010320d:	c3                   	ret    

f010320e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010320e:	55                   	push   %ebp
f010320f:	89 e5                	mov    %esp,%ebp
f0103211:	56                   	push   %esi
f0103212:	53                   	push   %ebx
f0103213:	8b 75 08             	mov    0x8(%ebp),%esi
f0103216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103219:	8b 55 10             	mov    0x10(%ebp),%edx
f010321c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010321e:	85 d2                	test   %edx,%edx
f0103220:	74 21                	je     f0103243 <strlcpy+0x35>
f0103222:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103226:	89 f2                	mov    %esi,%edx
f0103228:	eb 09                	jmp    f0103233 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010322a:	83 c2 01             	add    $0x1,%edx
f010322d:	83 c1 01             	add    $0x1,%ecx
f0103230:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103233:	39 c2                	cmp    %eax,%edx
f0103235:	74 09                	je     f0103240 <strlcpy+0x32>
f0103237:	0f b6 19             	movzbl (%ecx),%ebx
f010323a:	84 db                	test   %bl,%bl
f010323c:	75 ec                	jne    f010322a <strlcpy+0x1c>
f010323e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103240:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103243:	29 f0                	sub    %esi,%eax
}
f0103245:	5b                   	pop    %ebx
f0103246:	5e                   	pop    %esi
f0103247:	5d                   	pop    %ebp
f0103248:	c3                   	ret    

f0103249 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103249:	55                   	push   %ebp
f010324a:	89 e5                	mov    %esp,%ebp
f010324c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010324f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103252:	eb 06                	jmp    f010325a <strcmp+0x11>
		p++, q++;
f0103254:	83 c1 01             	add    $0x1,%ecx
f0103257:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010325a:	0f b6 01             	movzbl (%ecx),%eax
f010325d:	84 c0                	test   %al,%al
f010325f:	74 04                	je     f0103265 <strcmp+0x1c>
f0103261:	3a 02                	cmp    (%edx),%al
f0103263:	74 ef                	je     f0103254 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103265:	0f b6 c0             	movzbl %al,%eax
f0103268:	0f b6 12             	movzbl (%edx),%edx
f010326b:	29 d0                	sub    %edx,%eax
}
f010326d:	5d                   	pop    %ebp
f010326e:	c3                   	ret    

f010326f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010326f:	55                   	push   %ebp
f0103270:	89 e5                	mov    %esp,%ebp
f0103272:	53                   	push   %ebx
f0103273:	8b 45 08             	mov    0x8(%ebp),%eax
f0103276:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103279:	89 c3                	mov    %eax,%ebx
f010327b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010327e:	eb 06                	jmp    f0103286 <strncmp+0x17>
		n--, p++, q++;
f0103280:	83 c0 01             	add    $0x1,%eax
f0103283:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103286:	39 d8                	cmp    %ebx,%eax
f0103288:	74 15                	je     f010329f <strncmp+0x30>
f010328a:	0f b6 08             	movzbl (%eax),%ecx
f010328d:	84 c9                	test   %cl,%cl
f010328f:	74 04                	je     f0103295 <strncmp+0x26>
f0103291:	3a 0a                	cmp    (%edx),%cl
f0103293:	74 eb                	je     f0103280 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103295:	0f b6 00             	movzbl (%eax),%eax
f0103298:	0f b6 12             	movzbl (%edx),%edx
f010329b:	29 d0                	sub    %edx,%eax
f010329d:	eb 05                	jmp    f01032a4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010329f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01032a4:	5b                   	pop    %ebx
f01032a5:	5d                   	pop    %ebp
f01032a6:	c3                   	ret    

f01032a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01032a7:	55                   	push   %ebp
f01032a8:	89 e5                	mov    %esp,%ebp
f01032aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032b1:	eb 07                	jmp    f01032ba <strchr+0x13>
		if (*s == c)
f01032b3:	38 ca                	cmp    %cl,%dl
f01032b5:	74 0f                	je     f01032c6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01032b7:	83 c0 01             	add    $0x1,%eax
f01032ba:	0f b6 10             	movzbl (%eax),%edx
f01032bd:	84 d2                	test   %dl,%dl
f01032bf:	75 f2                	jne    f01032b3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01032c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032c6:	5d                   	pop    %ebp
f01032c7:	c3                   	ret    

f01032c8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01032c8:	55                   	push   %ebp
f01032c9:	89 e5                	mov    %esp,%ebp
f01032cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032d2:	eb 03                	jmp    f01032d7 <strfind+0xf>
f01032d4:	83 c0 01             	add    $0x1,%eax
f01032d7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01032da:	38 ca                	cmp    %cl,%dl
f01032dc:	74 04                	je     f01032e2 <strfind+0x1a>
f01032de:	84 d2                	test   %dl,%dl
f01032e0:	75 f2                	jne    f01032d4 <strfind+0xc>
			break;
	return (char *) s;
}
f01032e2:	5d                   	pop    %ebp
f01032e3:	c3                   	ret    

f01032e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01032e4:	55                   	push   %ebp
f01032e5:	89 e5                	mov    %esp,%ebp
f01032e7:	57                   	push   %edi
f01032e8:	56                   	push   %esi
f01032e9:	53                   	push   %ebx
f01032ea:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01032f0:	85 c9                	test   %ecx,%ecx
f01032f2:	74 36                	je     f010332a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01032f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01032fa:	75 28                	jne    f0103324 <memset+0x40>
f01032fc:	f6 c1 03             	test   $0x3,%cl
f01032ff:	75 23                	jne    f0103324 <memset+0x40>
		c &= 0xFF;
f0103301:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103305:	89 d3                	mov    %edx,%ebx
f0103307:	c1 e3 08             	shl    $0x8,%ebx
f010330a:	89 d6                	mov    %edx,%esi
f010330c:	c1 e6 18             	shl    $0x18,%esi
f010330f:	89 d0                	mov    %edx,%eax
f0103311:	c1 e0 10             	shl    $0x10,%eax
f0103314:	09 f0                	or     %esi,%eax
f0103316:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103318:	89 d8                	mov    %ebx,%eax
f010331a:	09 d0                	or     %edx,%eax
f010331c:	c1 e9 02             	shr    $0x2,%ecx
f010331f:	fc                   	cld    
f0103320:	f3 ab                	rep stos %eax,%es:(%edi)
f0103322:	eb 06                	jmp    f010332a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103324:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103327:	fc                   	cld    
f0103328:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010332a:	89 f8                	mov    %edi,%eax
f010332c:	5b                   	pop    %ebx
f010332d:	5e                   	pop    %esi
f010332e:	5f                   	pop    %edi
f010332f:	5d                   	pop    %ebp
f0103330:	c3                   	ret    

f0103331 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103331:	55                   	push   %ebp
f0103332:	89 e5                	mov    %esp,%ebp
f0103334:	57                   	push   %edi
f0103335:	56                   	push   %esi
f0103336:	8b 45 08             	mov    0x8(%ebp),%eax
f0103339:	8b 75 0c             	mov    0xc(%ebp),%esi
f010333c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010333f:	39 c6                	cmp    %eax,%esi
f0103341:	73 35                	jae    f0103378 <memmove+0x47>
f0103343:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103346:	39 d0                	cmp    %edx,%eax
f0103348:	73 2e                	jae    f0103378 <memmove+0x47>
		s += n;
		d += n;
f010334a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010334d:	89 d6                	mov    %edx,%esi
f010334f:	09 fe                	or     %edi,%esi
f0103351:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103357:	75 13                	jne    f010336c <memmove+0x3b>
f0103359:	f6 c1 03             	test   $0x3,%cl
f010335c:	75 0e                	jne    f010336c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010335e:	83 ef 04             	sub    $0x4,%edi
f0103361:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103364:	c1 e9 02             	shr    $0x2,%ecx
f0103367:	fd                   	std    
f0103368:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010336a:	eb 09                	jmp    f0103375 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010336c:	83 ef 01             	sub    $0x1,%edi
f010336f:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103372:	fd                   	std    
f0103373:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103375:	fc                   	cld    
f0103376:	eb 1d                	jmp    f0103395 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103378:	89 f2                	mov    %esi,%edx
f010337a:	09 c2                	or     %eax,%edx
f010337c:	f6 c2 03             	test   $0x3,%dl
f010337f:	75 0f                	jne    f0103390 <memmove+0x5f>
f0103381:	f6 c1 03             	test   $0x3,%cl
f0103384:	75 0a                	jne    f0103390 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0103386:	c1 e9 02             	shr    $0x2,%ecx
f0103389:	89 c7                	mov    %eax,%edi
f010338b:	fc                   	cld    
f010338c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010338e:	eb 05                	jmp    f0103395 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103390:	89 c7                	mov    %eax,%edi
f0103392:	fc                   	cld    
f0103393:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103395:	5e                   	pop    %esi
f0103396:	5f                   	pop    %edi
f0103397:	5d                   	pop    %ebp
f0103398:	c3                   	ret    

f0103399 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103399:	55                   	push   %ebp
f010339a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010339c:	ff 75 10             	pushl  0x10(%ebp)
f010339f:	ff 75 0c             	pushl  0xc(%ebp)
f01033a2:	ff 75 08             	pushl  0x8(%ebp)
f01033a5:	e8 87 ff ff ff       	call   f0103331 <memmove>
}
f01033aa:	c9                   	leave  
f01033ab:	c3                   	ret    

f01033ac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01033ac:	55                   	push   %ebp
f01033ad:	89 e5                	mov    %esp,%ebp
f01033af:	56                   	push   %esi
f01033b0:	53                   	push   %ebx
f01033b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033b7:	89 c6                	mov    %eax,%esi
f01033b9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033bc:	eb 1a                	jmp    f01033d8 <memcmp+0x2c>
		if (*s1 != *s2)
f01033be:	0f b6 08             	movzbl (%eax),%ecx
f01033c1:	0f b6 1a             	movzbl (%edx),%ebx
f01033c4:	38 d9                	cmp    %bl,%cl
f01033c6:	74 0a                	je     f01033d2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01033c8:	0f b6 c1             	movzbl %cl,%eax
f01033cb:	0f b6 db             	movzbl %bl,%ebx
f01033ce:	29 d8                	sub    %ebx,%eax
f01033d0:	eb 0f                	jmp    f01033e1 <memcmp+0x35>
		s1++, s2++;
f01033d2:	83 c0 01             	add    $0x1,%eax
f01033d5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033d8:	39 f0                	cmp    %esi,%eax
f01033da:	75 e2                	jne    f01033be <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01033dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033e1:	5b                   	pop    %ebx
f01033e2:	5e                   	pop    %esi
f01033e3:	5d                   	pop    %ebp
f01033e4:	c3                   	ret    

f01033e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01033e5:	55                   	push   %ebp
f01033e6:	89 e5                	mov    %esp,%ebp
f01033e8:	53                   	push   %ebx
f01033e9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01033ec:	89 c1                	mov    %eax,%ecx
f01033ee:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01033f1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01033f5:	eb 0a                	jmp    f0103401 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01033f7:	0f b6 10             	movzbl (%eax),%edx
f01033fa:	39 da                	cmp    %ebx,%edx
f01033fc:	74 07                	je     f0103405 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01033fe:	83 c0 01             	add    $0x1,%eax
f0103401:	39 c8                	cmp    %ecx,%eax
f0103403:	72 f2                	jb     f01033f7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103405:	5b                   	pop    %ebx
f0103406:	5d                   	pop    %ebp
f0103407:	c3                   	ret    

f0103408 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103408:	55                   	push   %ebp
f0103409:	89 e5                	mov    %esp,%ebp
f010340b:	57                   	push   %edi
f010340c:	56                   	push   %esi
f010340d:	53                   	push   %ebx
f010340e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103411:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103414:	eb 03                	jmp    f0103419 <strtol+0x11>
		s++;
f0103416:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103419:	0f b6 01             	movzbl (%ecx),%eax
f010341c:	3c 20                	cmp    $0x20,%al
f010341e:	74 f6                	je     f0103416 <strtol+0xe>
f0103420:	3c 09                	cmp    $0x9,%al
f0103422:	74 f2                	je     f0103416 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103424:	3c 2b                	cmp    $0x2b,%al
f0103426:	75 0a                	jne    f0103432 <strtol+0x2a>
		s++;
f0103428:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010342b:	bf 00 00 00 00       	mov    $0x0,%edi
f0103430:	eb 11                	jmp    f0103443 <strtol+0x3b>
f0103432:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103437:	3c 2d                	cmp    $0x2d,%al
f0103439:	75 08                	jne    f0103443 <strtol+0x3b>
		s++, neg = 1;
f010343b:	83 c1 01             	add    $0x1,%ecx
f010343e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103443:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103449:	75 15                	jne    f0103460 <strtol+0x58>
f010344b:	80 39 30             	cmpb   $0x30,(%ecx)
f010344e:	75 10                	jne    f0103460 <strtol+0x58>
f0103450:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103454:	75 7c                	jne    f01034d2 <strtol+0xca>
		s += 2, base = 16;
f0103456:	83 c1 02             	add    $0x2,%ecx
f0103459:	bb 10 00 00 00       	mov    $0x10,%ebx
f010345e:	eb 16                	jmp    f0103476 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103460:	85 db                	test   %ebx,%ebx
f0103462:	75 12                	jne    f0103476 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103464:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103469:	80 39 30             	cmpb   $0x30,(%ecx)
f010346c:	75 08                	jne    f0103476 <strtol+0x6e>
		s++, base = 8;
f010346e:	83 c1 01             	add    $0x1,%ecx
f0103471:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0103476:	b8 00 00 00 00       	mov    $0x0,%eax
f010347b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010347e:	0f b6 11             	movzbl (%ecx),%edx
f0103481:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103484:	89 f3                	mov    %esi,%ebx
f0103486:	80 fb 09             	cmp    $0x9,%bl
f0103489:	77 08                	ja     f0103493 <strtol+0x8b>
			dig = *s - '0';
f010348b:	0f be d2             	movsbl %dl,%edx
f010348e:	83 ea 30             	sub    $0x30,%edx
f0103491:	eb 22                	jmp    f01034b5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103493:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103496:	89 f3                	mov    %esi,%ebx
f0103498:	80 fb 19             	cmp    $0x19,%bl
f010349b:	77 08                	ja     f01034a5 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010349d:	0f be d2             	movsbl %dl,%edx
f01034a0:	83 ea 57             	sub    $0x57,%edx
f01034a3:	eb 10                	jmp    f01034b5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01034a5:	8d 72 bf             	lea    -0x41(%edx),%esi
f01034a8:	89 f3                	mov    %esi,%ebx
f01034aa:	80 fb 19             	cmp    $0x19,%bl
f01034ad:	77 16                	ja     f01034c5 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01034af:	0f be d2             	movsbl %dl,%edx
f01034b2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01034b5:	3b 55 10             	cmp    0x10(%ebp),%edx
f01034b8:	7d 0b                	jge    f01034c5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01034ba:	83 c1 01             	add    $0x1,%ecx
f01034bd:	0f af 45 10          	imul   0x10(%ebp),%eax
f01034c1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01034c3:	eb b9                	jmp    f010347e <strtol+0x76>

	if (endptr)
f01034c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01034c9:	74 0d                	je     f01034d8 <strtol+0xd0>
		*endptr = (char *) s;
f01034cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01034ce:	89 0e                	mov    %ecx,(%esi)
f01034d0:	eb 06                	jmp    f01034d8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01034d2:	85 db                	test   %ebx,%ebx
f01034d4:	74 98                	je     f010346e <strtol+0x66>
f01034d6:	eb 9e                	jmp    f0103476 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01034d8:	89 c2                	mov    %eax,%edx
f01034da:	f7 da                	neg    %edx
f01034dc:	85 ff                	test   %edi,%edi
f01034de:	0f 45 c2             	cmovne %edx,%eax
}
f01034e1:	5b                   	pop    %ebx
f01034e2:	5e                   	pop    %esi
f01034e3:	5f                   	pop    %edi
f01034e4:	5d                   	pop    %ebp
f01034e5:	c3                   	ret    
f01034e6:	66 90                	xchg   %ax,%ax
f01034e8:	66 90                	xchg   %ax,%ax
f01034ea:	66 90                	xchg   %ax,%ax
f01034ec:	66 90                	xchg   %ax,%ax
f01034ee:	66 90                	xchg   %ax,%ax

f01034f0 <__udivdi3>:
f01034f0:	55                   	push   %ebp
f01034f1:	57                   	push   %edi
f01034f2:	56                   	push   %esi
f01034f3:	53                   	push   %ebx
f01034f4:	83 ec 1c             	sub    $0x1c,%esp
f01034f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01034fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01034ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103503:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103507:	85 f6                	test   %esi,%esi
f0103509:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010350d:	89 ca                	mov    %ecx,%edx
f010350f:	89 f8                	mov    %edi,%eax
f0103511:	75 3d                	jne    f0103550 <__udivdi3+0x60>
f0103513:	39 cf                	cmp    %ecx,%edi
f0103515:	0f 87 c5 00 00 00    	ja     f01035e0 <__udivdi3+0xf0>
f010351b:	85 ff                	test   %edi,%edi
f010351d:	89 fd                	mov    %edi,%ebp
f010351f:	75 0b                	jne    f010352c <__udivdi3+0x3c>
f0103521:	b8 01 00 00 00       	mov    $0x1,%eax
f0103526:	31 d2                	xor    %edx,%edx
f0103528:	f7 f7                	div    %edi
f010352a:	89 c5                	mov    %eax,%ebp
f010352c:	89 c8                	mov    %ecx,%eax
f010352e:	31 d2                	xor    %edx,%edx
f0103530:	f7 f5                	div    %ebp
f0103532:	89 c1                	mov    %eax,%ecx
f0103534:	89 d8                	mov    %ebx,%eax
f0103536:	89 cf                	mov    %ecx,%edi
f0103538:	f7 f5                	div    %ebp
f010353a:	89 c3                	mov    %eax,%ebx
f010353c:	89 d8                	mov    %ebx,%eax
f010353e:	89 fa                	mov    %edi,%edx
f0103540:	83 c4 1c             	add    $0x1c,%esp
f0103543:	5b                   	pop    %ebx
f0103544:	5e                   	pop    %esi
f0103545:	5f                   	pop    %edi
f0103546:	5d                   	pop    %ebp
f0103547:	c3                   	ret    
f0103548:	90                   	nop
f0103549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103550:	39 ce                	cmp    %ecx,%esi
f0103552:	77 74                	ja     f01035c8 <__udivdi3+0xd8>
f0103554:	0f bd fe             	bsr    %esi,%edi
f0103557:	83 f7 1f             	xor    $0x1f,%edi
f010355a:	0f 84 98 00 00 00    	je     f01035f8 <__udivdi3+0x108>
f0103560:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103565:	89 f9                	mov    %edi,%ecx
f0103567:	89 c5                	mov    %eax,%ebp
f0103569:	29 fb                	sub    %edi,%ebx
f010356b:	d3 e6                	shl    %cl,%esi
f010356d:	89 d9                	mov    %ebx,%ecx
f010356f:	d3 ed                	shr    %cl,%ebp
f0103571:	89 f9                	mov    %edi,%ecx
f0103573:	d3 e0                	shl    %cl,%eax
f0103575:	09 ee                	or     %ebp,%esi
f0103577:	89 d9                	mov    %ebx,%ecx
f0103579:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010357d:	89 d5                	mov    %edx,%ebp
f010357f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103583:	d3 ed                	shr    %cl,%ebp
f0103585:	89 f9                	mov    %edi,%ecx
f0103587:	d3 e2                	shl    %cl,%edx
f0103589:	89 d9                	mov    %ebx,%ecx
f010358b:	d3 e8                	shr    %cl,%eax
f010358d:	09 c2                	or     %eax,%edx
f010358f:	89 d0                	mov    %edx,%eax
f0103591:	89 ea                	mov    %ebp,%edx
f0103593:	f7 f6                	div    %esi
f0103595:	89 d5                	mov    %edx,%ebp
f0103597:	89 c3                	mov    %eax,%ebx
f0103599:	f7 64 24 0c          	mull   0xc(%esp)
f010359d:	39 d5                	cmp    %edx,%ebp
f010359f:	72 10                	jb     f01035b1 <__udivdi3+0xc1>
f01035a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01035a5:	89 f9                	mov    %edi,%ecx
f01035a7:	d3 e6                	shl    %cl,%esi
f01035a9:	39 c6                	cmp    %eax,%esi
f01035ab:	73 07                	jae    f01035b4 <__udivdi3+0xc4>
f01035ad:	39 d5                	cmp    %edx,%ebp
f01035af:	75 03                	jne    f01035b4 <__udivdi3+0xc4>
f01035b1:	83 eb 01             	sub    $0x1,%ebx
f01035b4:	31 ff                	xor    %edi,%edi
f01035b6:	89 d8                	mov    %ebx,%eax
f01035b8:	89 fa                	mov    %edi,%edx
f01035ba:	83 c4 1c             	add    $0x1c,%esp
f01035bd:	5b                   	pop    %ebx
f01035be:	5e                   	pop    %esi
f01035bf:	5f                   	pop    %edi
f01035c0:	5d                   	pop    %ebp
f01035c1:	c3                   	ret    
f01035c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01035c8:	31 ff                	xor    %edi,%edi
f01035ca:	31 db                	xor    %ebx,%ebx
f01035cc:	89 d8                	mov    %ebx,%eax
f01035ce:	89 fa                	mov    %edi,%edx
f01035d0:	83 c4 1c             	add    $0x1c,%esp
f01035d3:	5b                   	pop    %ebx
f01035d4:	5e                   	pop    %esi
f01035d5:	5f                   	pop    %edi
f01035d6:	5d                   	pop    %ebp
f01035d7:	c3                   	ret    
f01035d8:	90                   	nop
f01035d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035e0:	89 d8                	mov    %ebx,%eax
f01035e2:	f7 f7                	div    %edi
f01035e4:	31 ff                	xor    %edi,%edi
f01035e6:	89 c3                	mov    %eax,%ebx
f01035e8:	89 d8                	mov    %ebx,%eax
f01035ea:	89 fa                	mov    %edi,%edx
f01035ec:	83 c4 1c             	add    $0x1c,%esp
f01035ef:	5b                   	pop    %ebx
f01035f0:	5e                   	pop    %esi
f01035f1:	5f                   	pop    %edi
f01035f2:	5d                   	pop    %ebp
f01035f3:	c3                   	ret    
f01035f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01035f8:	39 ce                	cmp    %ecx,%esi
f01035fa:	72 0c                	jb     f0103608 <__udivdi3+0x118>
f01035fc:	31 db                	xor    %ebx,%ebx
f01035fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103602:	0f 87 34 ff ff ff    	ja     f010353c <__udivdi3+0x4c>
f0103608:	bb 01 00 00 00       	mov    $0x1,%ebx
f010360d:	e9 2a ff ff ff       	jmp    f010353c <__udivdi3+0x4c>
f0103612:	66 90                	xchg   %ax,%ax
f0103614:	66 90                	xchg   %ax,%ax
f0103616:	66 90                	xchg   %ax,%ax
f0103618:	66 90                	xchg   %ax,%ax
f010361a:	66 90                	xchg   %ax,%ax
f010361c:	66 90                	xchg   %ax,%ax
f010361e:	66 90                	xchg   %ax,%ax

f0103620 <__umoddi3>:
f0103620:	55                   	push   %ebp
f0103621:	57                   	push   %edi
f0103622:	56                   	push   %esi
f0103623:	53                   	push   %ebx
f0103624:	83 ec 1c             	sub    $0x1c,%esp
f0103627:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010362b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010362f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103633:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103637:	85 d2                	test   %edx,%edx
f0103639:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010363d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103641:	89 f3                	mov    %esi,%ebx
f0103643:	89 3c 24             	mov    %edi,(%esp)
f0103646:	89 74 24 04          	mov    %esi,0x4(%esp)
f010364a:	75 1c                	jne    f0103668 <__umoddi3+0x48>
f010364c:	39 f7                	cmp    %esi,%edi
f010364e:	76 50                	jbe    f01036a0 <__umoddi3+0x80>
f0103650:	89 c8                	mov    %ecx,%eax
f0103652:	89 f2                	mov    %esi,%edx
f0103654:	f7 f7                	div    %edi
f0103656:	89 d0                	mov    %edx,%eax
f0103658:	31 d2                	xor    %edx,%edx
f010365a:	83 c4 1c             	add    $0x1c,%esp
f010365d:	5b                   	pop    %ebx
f010365e:	5e                   	pop    %esi
f010365f:	5f                   	pop    %edi
f0103660:	5d                   	pop    %ebp
f0103661:	c3                   	ret    
f0103662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103668:	39 f2                	cmp    %esi,%edx
f010366a:	89 d0                	mov    %edx,%eax
f010366c:	77 52                	ja     f01036c0 <__umoddi3+0xa0>
f010366e:	0f bd ea             	bsr    %edx,%ebp
f0103671:	83 f5 1f             	xor    $0x1f,%ebp
f0103674:	75 5a                	jne    f01036d0 <__umoddi3+0xb0>
f0103676:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010367a:	0f 82 e0 00 00 00    	jb     f0103760 <__umoddi3+0x140>
f0103680:	39 0c 24             	cmp    %ecx,(%esp)
f0103683:	0f 86 d7 00 00 00    	jbe    f0103760 <__umoddi3+0x140>
f0103689:	8b 44 24 08          	mov    0x8(%esp),%eax
f010368d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103691:	83 c4 1c             	add    $0x1c,%esp
f0103694:	5b                   	pop    %ebx
f0103695:	5e                   	pop    %esi
f0103696:	5f                   	pop    %edi
f0103697:	5d                   	pop    %ebp
f0103698:	c3                   	ret    
f0103699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01036a0:	85 ff                	test   %edi,%edi
f01036a2:	89 fd                	mov    %edi,%ebp
f01036a4:	75 0b                	jne    f01036b1 <__umoddi3+0x91>
f01036a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01036ab:	31 d2                	xor    %edx,%edx
f01036ad:	f7 f7                	div    %edi
f01036af:	89 c5                	mov    %eax,%ebp
f01036b1:	89 f0                	mov    %esi,%eax
f01036b3:	31 d2                	xor    %edx,%edx
f01036b5:	f7 f5                	div    %ebp
f01036b7:	89 c8                	mov    %ecx,%eax
f01036b9:	f7 f5                	div    %ebp
f01036bb:	89 d0                	mov    %edx,%eax
f01036bd:	eb 99                	jmp    f0103658 <__umoddi3+0x38>
f01036bf:	90                   	nop
f01036c0:	89 c8                	mov    %ecx,%eax
f01036c2:	89 f2                	mov    %esi,%edx
f01036c4:	83 c4 1c             	add    $0x1c,%esp
f01036c7:	5b                   	pop    %ebx
f01036c8:	5e                   	pop    %esi
f01036c9:	5f                   	pop    %edi
f01036ca:	5d                   	pop    %ebp
f01036cb:	c3                   	ret    
f01036cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01036d0:	8b 34 24             	mov    (%esp),%esi
f01036d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01036d8:	89 e9                	mov    %ebp,%ecx
f01036da:	29 ef                	sub    %ebp,%edi
f01036dc:	d3 e0                	shl    %cl,%eax
f01036de:	89 f9                	mov    %edi,%ecx
f01036e0:	89 f2                	mov    %esi,%edx
f01036e2:	d3 ea                	shr    %cl,%edx
f01036e4:	89 e9                	mov    %ebp,%ecx
f01036e6:	09 c2                	or     %eax,%edx
f01036e8:	89 d8                	mov    %ebx,%eax
f01036ea:	89 14 24             	mov    %edx,(%esp)
f01036ed:	89 f2                	mov    %esi,%edx
f01036ef:	d3 e2                	shl    %cl,%edx
f01036f1:	89 f9                	mov    %edi,%ecx
f01036f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01036f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01036fb:	d3 e8                	shr    %cl,%eax
f01036fd:	89 e9                	mov    %ebp,%ecx
f01036ff:	89 c6                	mov    %eax,%esi
f0103701:	d3 e3                	shl    %cl,%ebx
f0103703:	89 f9                	mov    %edi,%ecx
f0103705:	89 d0                	mov    %edx,%eax
f0103707:	d3 e8                	shr    %cl,%eax
f0103709:	89 e9                	mov    %ebp,%ecx
f010370b:	09 d8                	or     %ebx,%eax
f010370d:	89 d3                	mov    %edx,%ebx
f010370f:	89 f2                	mov    %esi,%edx
f0103711:	f7 34 24             	divl   (%esp)
f0103714:	89 d6                	mov    %edx,%esi
f0103716:	d3 e3                	shl    %cl,%ebx
f0103718:	f7 64 24 04          	mull   0x4(%esp)
f010371c:	39 d6                	cmp    %edx,%esi
f010371e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103722:	89 d1                	mov    %edx,%ecx
f0103724:	89 c3                	mov    %eax,%ebx
f0103726:	72 08                	jb     f0103730 <__umoddi3+0x110>
f0103728:	75 11                	jne    f010373b <__umoddi3+0x11b>
f010372a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010372e:	73 0b                	jae    f010373b <__umoddi3+0x11b>
f0103730:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103734:	1b 14 24             	sbb    (%esp),%edx
f0103737:	89 d1                	mov    %edx,%ecx
f0103739:	89 c3                	mov    %eax,%ebx
f010373b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010373f:	29 da                	sub    %ebx,%edx
f0103741:	19 ce                	sbb    %ecx,%esi
f0103743:	89 f9                	mov    %edi,%ecx
f0103745:	89 f0                	mov    %esi,%eax
f0103747:	d3 e0                	shl    %cl,%eax
f0103749:	89 e9                	mov    %ebp,%ecx
f010374b:	d3 ea                	shr    %cl,%edx
f010374d:	89 e9                	mov    %ebp,%ecx
f010374f:	d3 ee                	shr    %cl,%esi
f0103751:	09 d0                	or     %edx,%eax
f0103753:	89 f2                	mov    %esi,%edx
f0103755:	83 c4 1c             	add    $0x1c,%esp
f0103758:	5b                   	pop    %ebx
f0103759:	5e                   	pop    %esi
f010375a:	5f                   	pop    %edi
f010375b:	5d                   	pop    %ebp
f010375c:	c3                   	ret    
f010375d:	8d 76 00             	lea    0x0(%esi),%esi
f0103760:	29 f9                	sub    %edi,%ecx
f0103762:	19 d6                	sbb    %edx,%esi
f0103764:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103768:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010376c:	e9 18 ff ff ff       	jmp    f0103689 <__umoddi3+0x69>
