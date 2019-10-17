
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

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
f0100046:	b8 40 2c 17 f0       	mov    $0xf0172c40,%eax
f010004b:	2d 40 1d 17 f0       	sub    $0xf0171d40,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 40 1d 17 f0       	push   $0xf0171d40
f0100058:	e8 fa 43 00 00       	call   f0104457 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 b7 04 00 00       	call   f0100519 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 49 10 f0       	push   $0xf0104900
f010006f:	e8 5d 30 00 00       	call   f01030d1 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 2b 11 00 00       	call   f01011a4 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 49 2a 00 00       	call   f0102ac7 <env_init>
	trap_init();
f010007e:	e8 c8 30 00 00       	call   f010314b <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 c6 fb 12 f0       	push   $0xf012fbc6
f010008d:	e8 f6 2b 00 00       	call   f0102c88 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	cprintf("Reached here!!! \n");
f0100092:	c7 04 24 1b 49 10 f0 	movl   $0xf010491b,(%esp)
f0100099:	e8 33 30 00 00       	call   f01030d1 <cprintf>
	env_run(&envs[0]);
f010009e:	83 c4 04             	add    $0x4,%esp
f01000a1:	ff 35 8c 1f 17 f0    	pushl  0xf0171f8c
f01000a7:	e8 62 2f 00 00       	call   f010300e <env_run>

f01000ac <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000ac:	55                   	push   %ebp
f01000ad:	89 e5                	mov    %esp,%ebp
f01000af:	56                   	push   %esi
f01000b0:	53                   	push   %ebx
f01000b1:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000b4:	83 3d 44 2c 17 f0 00 	cmpl   $0x0,0xf0172c44
f01000bb:	75 37                	jne    f01000f4 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000bd:	89 35 44 2c 17 f0    	mov    %esi,0xf0172c44

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000c3:	fa                   	cli    
f01000c4:	fc                   	cld    

	va_start(ap, fmt);
f01000c5:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000c8:	83 ec 04             	sub    $0x4,%esp
f01000cb:	ff 75 0c             	pushl  0xc(%ebp)
f01000ce:	ff 75 08             	pushl  0x8(%ebp)
f01000d1:	68 2d 49 10 f0       	push   $0xf010492d
f01000d6:	e8 f6 2f 00 00       	call   f01030d1 <cprintf>
	vcprintf(fmt, ap);
f01000db:	83 c4 08             	add    $0x8,%esp
f01000de:	53                   	push   %ebx
f01000df:	56                   	push   %esi
f01000e0:	e8 c6 2f 00 00       	call   f01030ab <vcprintf>
	cprintf("\n");
f01000e5:	c7 04 24 2b 49 10 f0 	movl   $0xf010492b,(%esp)
f01000ec:	e8 e0 2f 00 00       	call   f01030d1 <cprintf>
	va_end(ap);
f01000f1:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000f4:	83 ec 0c             	sub    $0xc,%esp
f01000f7:	6a 00                	push   $0x0
f01000f9:	e8 ff 06 00 00       	call   f01007fd <monitor>
f01000fe:	83 c4 10             	add    $0x10,%esp
f0100101:	eb f1                	jmp    f01000f4 <_panic+0x48>

f0100103 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100103:	55                   	push   %ebp
f0100104:	89 e5                	mov    %esp,%ebp
f0100106:	53                   	push   %ebx
f0100107:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010010a:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010010d:	ff 75 0c             	pushl  0xc(%ebp)
f0100110:	ff 75 08             	pushl  0x8(%ebp)
f0100113:	68 45 49 10 f0       	push   $0xf0104945
f0100118:	e8 b4 2f 00 00       	call   f01030d1 <cprintf>
	vcprintf(fmt, ap);
f010011d:	83 c4 08             	add    $0x8,%esp
f0100120:	53                   	push   %ebx
f0100121:	ff 75 10             	pushl  0x10(%ebp)
f0100124:	e8 82 2f 00 00       	call   f01030ab <vcprintf>
	cprintf("\n");
f0100129:	c7 04 24 2b 49 10 f0 	movl   $0xf010492b,(%esp)
f0100130:	e8 9c 2f 00 00       	call   f01030d1 <cprintf>
	va_end(ap);
}
f0100135:	83 c4 10             	add    $0x10,%esp
f0100138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010013b:	c9                   	leave  
f010013c:	c3                   	ret    

f010013d <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100140:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100145:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100146:	a8 01                	test   $0x1,%al
f0100148:	74 0b                	je     f0100155 <serial_proc_data+0x18>
f010014a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010014f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100150:	0f b6 c0             	movzbl %al,%eax
f0100153:	eb 05                	jmp    f010015a <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010015a:	5d                   	pop    %ebp
f010015b:	c3                   	ret    

f010015c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010015c:	55                   	push   %ebp
f010015d:	89 e5                	mov    %esp,%ebp
f010015f:	53                   	push   %ebx
f0100160:	83 ec 04             	sub    $0x4,%esp
f0100163:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100165:	eb 2b                	jmp    f0100192 <cons_intr+0x36>
		if (c == 0)
f0100167:	85 c0                	test   %eax,%eax
f0100169:	74 27                	je     f0100192 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010016b:	8b 0d 64 1f 17 f0    	mov    0xf0171f64,%ecx
f0100171:	8d 51 01             	lea    0x1(%ecx),%edx
f0100174:	89 15 64 1f 17 f0    	mov    %edx,0xf0171f64
f010017a:	88 81 60 1d 17 f0    	mov    %al,-0xfe8e2a0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100180:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100186:	75 0a                	jne    f0100192 <cons_intr+0x36>
			cons.wpos = 0;
f0100188:	c7 05 64 1f 17 f0 00 	movl   $0x0,0xf0171f64
f010018f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100192:	ff d3                	call   *%ebx
f0100194:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100197:	75 ce                	jne    f0100167 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100199:	83 c4 04             	add    $0x4,%esp
f010019c:	5b                   	pop    %ebx
f010019d:	5d                   	pop    %ebp
f010019e:	c3                   	ret    

f010019f <kbd_proc_data>:
f010019f:	ba 64 00 00 00       	mov    $0x64,%edx
f01001a4:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001a5:	a8 01                	test   $0x1,%al
f01001a7:	0f 84 f8 00 00 00    	je     f01002a5 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001ad:	a8 20                	test   $0x20,%al
f01001af:	0f 85 f6 00 00 00    	jne    f01002ab <kbd_proc_data+0x10c>
f01001b5:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ba:	ec                   	in     (%dx),%al
f01001bb:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001bd:	3c e0                	cmp    $0xe0,%al
f01001bf:	75 0d                	jne    f01001ce <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001c1:	83 0d 40 1d 17 f0 40 	orl    $0x40,0xf0171d40
		return 0;
f01001c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01001cd:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ce:	55                   	push   %ebp
f01001cf:	89 e5                	mov    %esp,%ebp
f01001d1:	53                   	push   %ebx
f01001d2:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001d5:	84 c0                	test   %al,%al
f01001d7:	79 36                	jns    f010020f <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001d9:	8b 0d 40 1d 17 f0    	mov    0xf0171d40,%ecx
f01001df:	89 cb                	mov    %ecx,%ebx
f01001e1:	83 e3 40             	and    $0x40,%ebx
f01001e4:	83 e0 7f             	and    $0x7f,%eax
f01001e7:	85 db                	test   %ebx,%ebx
f01001e9:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001ec:	0f b6 d2             	movzbl %dl,%edx
f01001ef:	0f b6 82 c0 4a 10 f0 	movzbl -0xfefb540(%edx),%eax
f01001f6:	83 c8 40             	or     $0x40,%eax
f01001f9:	0f b6 c0             	movzbl %al,%eax
f01001fc:	f7 d0                	not    %eax
f01001fe:	21 c8                	and    %ecx,%eax
f0100200:	a3 40 1d 17 f0       	mov    %eax,0xf0171d40
		return 0;
f0100205:	b8 00 00 00 00       	mov    $0x0,%eax
f010020a:	e9 a4 00 00 00       	jmp    f01002b3 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010020f:	8b 0d 40 1d 17 f0    	mov    0xf0171d40,%ecx
f0100215:	f6 c1 40             	test   $0x40,%cl
f0100218:	74 0e                	je     f0100228 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010021a:	83 c8 80             	or     $0xffffff80,%eax
f010021d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010021f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100222:	89 0d 40 1d 17 f0    	mov    %ecx,0xf0171d40
	}

	shift |= shiftcode[data];
f0100228:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010022b:	0f b6 82 c0 4a 10 f0 	movzbl -0xfefb540(%edx),%eax
f0100232:	0b 05 40 1d 17 f0    	or     0xf0171d40,%eax
f0100238:	0f b6 8a c0 49 10 f0 	movzbl -0xfefb640(%edx),%ecx
f010023f:	31 c8                	xor    %ecx,%eax
f0100241:	a3 40 1d 17 f0       	mov    %eax,0xf0171d40

	c = charcode[shift & (CTL | SHIFT)][data];
f0100246:	89 c1                	mov    %eax,%ecx
f0100248:	83 e1 03             	and    $0x3,%ecx
f010024b:	8b 0c 8d a0 49 10 f0 	mov    -0xfefb660(,%ecx,4),%ecx
f0100252:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100256:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100259:	a8 08                	test   $0x8,%al
f010025b:	74 1b                	je     f0100278 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010025d:	89 da                	mov    %ebx,%edx
f010025f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100262:	83 f9 19             	cmp    $0x19,%ecx
f0100265:	77 05                	ja     f010026c <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100267:	83 eb 20             	sub    $0x20,%ebx
f010026a:	eb 0c                	jmp    f0100278 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010026c:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010026f:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100272:	83 fa 19             	cmp    $0x19,%edx
f0100275:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100278:	f7 d0                	not    %eax
f010027a:	a8 06                	test   $0x6,%al
f010027c:	75 33                	jne    f01002b1 <kbd_proc_data+0x112>
f010027e:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100284:	75 2b                	jne    f01002b1 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100286:	83 ec 0c             	sub    $0xc,%esp
f0100289:	68 5f 49 10 f0       	push   $0xf010495f
f010028e:	e8 3e 2e 00 00       	call   f01030d1 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100293:	ba 92 00 00 00       	mov    $0x92,%edx
f0100298:	b8 03 00 00 00       	mov    $0x3,%eax
f010029d:	ee                   	out    %al,(%dx)
f010029e:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002a1:	89 d8                	mov    %ebx,%eax
f01002a3:	eb 0e                	jmp    f01002b3 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002aa:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002b0:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b1:	89 d8                	mov    %ebx,%eax
}
f01002b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002b6:	c9                   	leave  
f01002b7:	c3                   	ret    

f01002b8 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002b8:	55                   	push   %ebp
f01002b9:	89 e5                	mov    %esp,%ebp
f01002bb:	57                   	push   %edi
f01002bc:	56                   	push   %esi
f01002bd:	53                   	push   %ebx
f01002be:	83 ec 1c             	sub    $0x1c,%esp
f01002c1:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002c3:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c8:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002cd:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d2:	eb 09                	jmp    f01002dd <cons_putc+0x25>
f01002d4:	89 ca                	mov    %ecx,%edx
f01002d6:	ec                   	in     (%dx),%al
f01002d7:	ec                   	in     (%dx),%al
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002da:	83 c3 01             	add    $0x1,%ebx
f01002dd:	89 f2                	mov    %esi,%edx
f01002df:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002e0:	a8 20                	test   $0x20,%al
f01002e2:	75 08                	jne    f01002ec <cons_putc+0x34>
f01002e4:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002ea:	7e e8                	jle    f01002d4 <cons_putc+0x1c>
f01002ec:	89 f8                	mov    %edi,%eax
f01002ee:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002f6:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002f7:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002fc:	be 79 03 00 00       	mov    $0x379,%esi
f0100301:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100306:	eb 09                	jmp    f0100311 <cons_putc+0x59>
f0100308:	89 ca                	mov    %ecx,%edx
f010030a:	ec                   	in     (%dx),%al
f010030b:	ec                   	in     (%dx),%al
f010030c:	ec                   	in     (%dx),%al
f010030d:	ec                   	in     (%dx),%al
f010030e:	83 c3 01             	add    $0x1,%ebx
f0100311:	89 f2                	mov    %esi,%edx
f0100313:	ec                   	in     (%dx),%al
f0100314:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010031a:	7f 04                	jg     f0100320 <cons_putc+0x68>
f010031c:	84 c0                	test   %al,%al
f010031e:	79 e8                	jns    f0100308 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100320:	ba 78 03 00 00       	mov    $0x378,%edx
f0100325:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100329:	ee                   	out    %al,(%dx)
f010032a:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010032f:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100334:	ee                   	out    %al,(%dx)
f0100335:	b8 08 00 00 00       	mov    $0x8,%eax
f010033a:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010033b:	89 fa                	mov    %edi,%edx
f010033d:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100343:	89 f8                	mov    %edi,%eax
f0100345:	80 cc 07             	or     $0x7,%ah
f0100348:	85 d2                	test   %edx,%edx
f010034a:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010034d:	89 f8                	mov    %edi,%eax
f010034f:	0f b6 c0             	movzbl %al,%eax
f0100352:	83 f8 09             	cmp    $0x9,%eax
f0100355:	74 74                	je     f01003cb <cons_putc+0x113>
f0100357:	83 f8 09             	cmp    $0x9,%eax
f010035a:	7f 0a                	jg     f0100366 <cons_putc+0xae>
f010035c:	83 f8 08             	cmp    $0x8,%eax
f010035f:	74 14                	je     f0100375 <cons_putc+0xbd>
f0100361:	e9 99 00 00 00       	jmp    f01003ff <cons_putc+0x147>
f0100366:	83 f8 0a             	cmp    $0xa,%eax
f0100369:	74 3a                	je     f01003a5 <cons_putc+0xed>
f010036b:	83 f8 0d             	cmp    $0xd,%eax
f010036e:	74 3d                	je     f01003ad <cons_putc+0xf5>
f0100370:	e9 8a 00 00 00       	jmp    f01003ff <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100375:	0f b7 05 68 1f 17 f0 	movzwl 0xf0171f68,%eax
f010037c:	66 85 c0             	test   %ax,%ax
f010037f:	0f 84 e6 00 00 00    	je     f010046b <cons_putc+0x1b3>
			crt_pos--;
f0100385:	83 e8 01             	sub    $0x1,%eax
f0100388:	66 a3 68 1f 17 f0    	mov    %ax,0xf0171f68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010038e:	0f b7 c0             	movzwl %ax,%eax
f0100391:	66 81 e7 00 ff       	and    $0xff00,%di
f0100396:	83 cf 20             	or     $0x20,%edi
f0100399:	8b 15 6c 1f 17 f0    	mov    0xf0171f6c,%edx
f010039f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003a3:	eb 78                	jmp    f010041d <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003a5:	66 83 05 68 1f 17 f0 	addw   $0x50,0xf0171f68
f01003ac:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003ad:	0f b7 05 68 1f 17 f0 	movzwl 0xf0171f68,%eax
f01003b4:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003ba:	c1 e8 16             	shr    $0x16,%eax
f01003bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c0:	c1 e0 04             	shl    $0x4,%eax
f01003c3:	66 a3 68 1f 17 f0    	mov    %ax,0xf0171f68
f01003c9:	eb 52                	jmp    f010041d <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d0:	e8 e3 fe ff ff       	call   f01002b8 <cons_putc>
		cons_putc(' ');
f01003d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003da:	e8 d9 fe ff ff       	call   f01002b8 <cons_putc>
		cons_putc(' ');
f01003df:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e4:	e8 cf fe ff ff       	call   f01002b8 <cons_putc>
		cons_putc(' ');
f01003e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ee:	e8 c5 fe ff ff       	call   f01002b8 <cons_putc>
		cons_putc(' ');
f01003f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f8:	e8 bb fe ff ff       	call   f01002b8 <cons_putc>
f01003fd:	eb 1e                	jmp    f010041d <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003ff:	0f b7 05 68 1f 17 f0 	movzwl 0xf0171f68,%eax
f0100406:	8d 50 01             	lea    0x1(%eax),%edx
f0100409:	66 89 15 68 1f 17 f0 	mov    %dx,0xf0171f68
f0100410:	0f b7 c0             	movzwl %ax,%eax
f0100413:	8b 15 6c 1f 17 f0    	mov    0xf0171f6c,%edx
f0100419:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010041d:	66 81 3d 68 1f 17 f0 	cmpw   $0x7cf,0xf0171f68
f0100424:	cf 07 
f0100426:	76 43                	jbe    f010046b <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100428:	a1 6c 1f 17 f0       	mov    0xf0171f6c,%eax
f010042d:	83 ec 04             	sub    $0x4,%esp
f0100430:	68 00 0f 00 00       	push   $0xf00
f0100435:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010043b:	52                   	push   %edx
f010043c:	50                   	push   %eax
f010043d:	e8 62 40 00 00       	call   f01044a4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100442:	8b 15 6c 1f 17 f0    	mov    0xf0171f6c,%edx
f0100448:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010044e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100454:	83 c4 10             	add    $0x10,%esp
f0100457:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010045c:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045f:	39 d0                	cmp    %edx,%eax
f0100461:	75 f4                	jne    f0100457 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100463:	66 83 2d 68 1f 17 f0 	subw   $0x50,0xf0171f68
f010046a:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010046b:	8b 0d 70 1f 17 f0    	mov    0xf0171f70,%ecx
f0100471:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100476:	89 ca                	mov    %ecx,%edx
f0100478:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100479:	0f b7 1d 68 1f 17 f0 	movzwl 0xf0171f68,%ebx
f0100480:	8d 71 01             	lea    0x1(%ecx),%esi
f0100483:	89 d8                	mov    %ebx,%eax
f0100485:	66 c1 e8 08          	shr    $0x8,%ax
f0100489:	89 f2                	mov    %esi,%edx
f010048b:	ee                   	out    %al,(%dx)
f010048c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100491:	89 ca                	mov    %ecx,%edx
f0100493:	ee                   	out    %al,(%dx)
f0100494:	89 d8                	mov    %ebx,%eax
f0100496:	89 f2                	mov    %esi,%edx
f0100498:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100499:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010049c:	5b                   	pop    %ebx
f010049d:	5e                   	pop    %esi
f010049e:	5f                   	pop    %edi
f010049f:	5d                   	pop    %ebp
f01004a0:	c3                   	ret    

f01004a1 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004a1:	80 3d 74 1f 17 f0 00 	cmpb   $0x0,0xf0171f74
f01004a8:	74 11                	je     f01004bb <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004aa:	55                   	push   %ebp
f01004ab:	89 e5                	mov    %esp,%ebp
f01004ad:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004b0:	b8 3d 01 10 f0       	mov    $0xf010013d,%eax
f01004b5:	e8 a2 fc ff ff       	call   f010015c <cons_intr>
}
f01004ba:	c9                   	leave  
f01004bb:	f3 c3                	repz ret 

f01004bd <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004bd:	55                   	push   %ebp
f01004be:	89 e5                	mov    %esp,%ebp
f01004c0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c3:	b8 9f 01 10 f0       	mov    $0xf010019f,%eax
f01004c8:	e8 8f fc ff ff       	call   f010015c <cons_intr>
}
f01004cd:	c9                   	leave  
f01004ce:	c3                   	ret    

f01004cf <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004cf:	55                   	push   %ebp
f01004d0:	89 e5                	mov    %esp,%ebp
f01004d2:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004d5:	e8 c7 ff ff ff       	call   f01004a1 <serial_intr>
	kbd_intr();
f01004da:	e8 de ff ff ff       	call   f01004bd <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004df:	a1 60 1f 17 f0       	mov    0xf0171f60,%eax
f01004e4:	3b 05 64 1f 17 f0    	cmp    0xf0171f64,%eax
f01004ea:	74 26                	je     f0100512 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004ec:	8d 50 01             	lea    0x1(%eax),%edx
f01004ef:	89 15 60 1f 17 f0    	mov    %edx,0xf0171f60
f01004f5:	0f b6 88 60 1d 17 f0 	movzbl -0xfe8e2a0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004fc:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004fe:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100504:	75 11                	jne    f0100517 <cons_getc+0x48>
			cons.rpos = 0;
f0100506:	c7 05 60 1f 17 f0 00 	movl   $0x0,0xf0171f60
f010050d:	00 00 00 
f0100510:	eb 05                	jmp    f0100517 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100512:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100517:	c9                   	leave  
f0100518:	c3                   	ret    

f0100519 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100519:	55                   	push   %ebp
f010051a:	89 e5                	mov    %esp,%ebp
f010051c:	57                   	push   %edi
f010051d:	56                   	push   %esi
f010051e:	53                   	push   %ebx
f010051f:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100522:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100529:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100530:	5a a5 
	if (*cp != 0xA55A) {
f0100532:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100539:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010053d:	74 11                	je     f0100550 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010053f:	c7 05 70 1f 17 f0 b4 	movl   $0x3b4,0xf0171f70
f0100546:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100549:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010054e:	eb 16                	jmp    f0100566 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100550:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100557:	c7 05 70 1f 17 f0 d4 	movl   $0x3d4,0xf0171f70
f010055e:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100561:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100566:	8b 3d 70 1f 17 f0    	mov    0xf0171f70,%edi
f010056c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100571:	89 fa                	mov    %edi,%edx
f0100573:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100574:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100577:	89 da                	mov    %ebx,%edx
f0100579:	ec                   	in     (%dx),%al
f010057a:	0f b6 c8             	movzbl %al,%ecx
f010057d:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100580:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100585:	89 fa                	mov    %edi,%edx
f0100587:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100588:	89 da                	mov    %ebx,%edx
f010058a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010058b:	89 35 6c 1f 17 f0    	mov    %esi,0xf0171f6c
	crt_pos = pos;
f0100591:	0f b6 c0             	movzbl %al,%eax
f0100594:	09 c8                	or     %ecx,%eax
f0100596:	66 a3 68 1f 17 f0    	mov    %ax,0xf0171f68
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059c:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a6:	89 f2                	mov    %esi,%edx
f01005a8:	ee                   	out    %al,(%dx)
f01005a9:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005ae:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005b3:	ee                   	out    %al,(%dx)
f01005b4:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005b9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005be:	89 da                	mov    %ebx,%edx
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01005cb:	ee                   	out    %al,(%dx)
f01005cc:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005d1:	b8 03 00 00 00       	mov    $0x3,%eax
f01005d6:	ee                   	out    %al,(%dx)
f01005d7:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e1:	ee                   	out    %al,(%dx)
f01005e2:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005e7:	b8 01 00 00 00       	mov    $0x1,%eax
f01005ec:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ed:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005f2:	ec                   	in     (%dx),%al
f01005f3:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005f5:	3c ff                	cmp    $0xff,%al
f01005f7:	0f 95 05 74 1f 17 f0 	setne  0xf0171f74
f01005fe:	89 f2                	mov    %esi,%edx
f0100600:	ec                   	in     (%dx),%al
f0100601:	89 da                	mov    %ebx,%edx
f0100603:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100604:	80 f9 ff             	cmp    $0xff,%cl
f0100607:	75 10                	jne    f0100619 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100609:	83 ec 0c             	sub    $0xc,%esp
f010060c:	68 6b 49 10 f0       	push   $0xf010496b
f0100611:	e8 bb 2a 00 00       	call   f01030d1 <cprintf>
f0100616:	83 c4 10             	add    $0x10,%esp
}
f0100619:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010061c:	5b                   	pop    %ebx
f010061d:	5e                   	pop    %esi
f010061e:	5f                   	pop    %edi
f010061f:	5d                   	pop    %ebp
f0100620:	c3                   	ret    

f0100621 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
f0100624:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100627:	8b 45 08             	mov    0x8(%ebp),%eax
f010062a:	e8 89 fc ff ff       	call   f01002b8 <cons_putc>
}
f010062f:	c9                   	leave  
f0100630:	c3                   	ret    

f0100631 <getchar>:

int
getchar(void)
{
f0100631:	55                   	push   %ebp
f0100632:	89 e5                	mov    %esp,%ebp
f0100634:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100637:	e8 93 fe ff ff       	call   f01004cf <cons_getc>
f010063c:	85 c0                	test   %eax,%eax
f010063e:	74 f7                	je     f0100637 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100640:	c9                   	leave  
f0100641:	c3                   	ret    

f0100642 <iscons>:

int
iscons(int fdnum)
{
f0100642:	55                   	push   %ebp
f0100643:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100645:	b8 01 00 00 00       	mov    $0x1,%eax
f010064a:	5d                   	pop    %ebp
f010064b:	c3                   	ret    

f010064c <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

	   int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010064c:	55                   	push   %ebp
f010064d:	89 e5                	mov    %esp,%ebp
f010064f:	83 ec 0c             	sub    $0xc,%esp
	   int i;

	   for (i = 0; i < ARRAY_SIZE(commands); i++)
			 cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100652:	68 c0 4b 10 f0       	push   $0xf0104bc0
f0100657:	68 de 4b 10 f0       	push   $0xf0104bde
f010065c:	68 e3 4b 10 f0       	push   $0xf0104be3
f0100661:	e8 6b 2a 00 00       	call   f01030d1 <cprintf>
f0100666:	83 c4 0c             	add    $0xc,%esp
f0100669:	68 b0 4c 10 f0       	push   $0xf0104cb0
f010066e:	68 ec 4b 10 f0       	push   $0xf0104bec
f0100673:	68 e3 4b 10 f0       	push   $0xf0104be3
f0100678:	e8 54 2a 00 00       	call   f01030d1 <cprintf>
f010067d:	83 c4 0c             	add    $0xc,%esp
f0100680:	68 f5 4b 10 f0       	push   $0xf0104bf5
f0100685:	68 0d 4c 10 f0       	push   $0xf0104c0d
f010068a:	68 e3 4b 10 f0       	push   $0xf0104be3
f010068f:	e8 3d 2a 00 00       	call   f01030d1 <cprintf>
	   return 0;
}
f0100694:	b8 00 00 00 00       	mov    $0x0,%eax
f0100699:	c9                   	leave  
f010069a:	c3                   	ret    

f010069b <mon_kerninfo>:

	   int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010069b:	55                   	push   %ebp
f010069c:	89 e5                	mov    %esp,%ebp
f010069e:	83 ec 14             	sub    $0x14,%esp
	   extern char _start[], entry[], etext[], edata[], end[];

	   cprintf("Special kernel symbols:\n");
f01006a1:	68 17 4c 10 f0       	push   $0xf0104c17
f01006a6:	e8 26 2a 00 00       	call   f01030d1 <cprintf>
	   cprintf("  _start                  %08x (phys)\n", _start);
f01006ab:	83 c4 08             	add    $0x8,%esp
f01006ae:	68 0c 00 10 00       	push   $0x10000c
f01006b3:	68 d8 4c 10 f0       	push   $0xf0104cd8
f01006b8:	e8 14 2a 00 00       	call   f01030d1 <cprintf>
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006bd:	83 c4 0c             	add    $0xc,%esp
f01006c0:	68 0c 00 10 00       	push   $0x10000c
f01006c5:	68 0c 00 10 f0       	push   $0xf010000c
f01006ca:	68 00 4d 10 f0       	push   $0xf0104d00
f01006cf:	e8 fd 29 00 00       	call   f01030d1 <cprintf>
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006d4:	83 c4 0c             	add    $0xc,%esp
f01006d7:	68 e1 48 10 00       	push   $0x1048e1
f01006dc:	68 e1 48 10 f0       	push   $0xf01048e1
f01006e1:	68 24 4d 10 f0       	push   $0xf0104d24
f01006e6:	e8 e6 29 00 00       	call   f01030d1 <cprintf>
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006eb:	83 c4 0c             	add    $0xc,%esp
f01006ee:	68 40 1d 17 00       	push   $0x171d40
f01006f3:	68 40 1d 17 f0       	push   $0xf0171d40
f01006f8:	68 48 4d 10 f0       	push   $0xf0104d48
f01006fd:	e8 cf 29 00 00       	call   f01030d1 <cprintf>
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100702:	83 c4 0c             	add    $0xc,%esp
f0100705:	68 40 2c 17 00       	push   $0x172c40
f010070a:	68 40 2c 17 f0       	push   $0xf0172c40
f010070f:	68 6c 4d 10 f0       	push   $0xf0104d6c
f0100714:	e8 b8 29 00 00       	call   f01030d1 <cprintf>
	   cprintf("Kernel executable memory footprint: %dKB\n",
				    ROUNDUP(end - entry, 1024) / 1024);
f0100719:	b8 3f 30 17 f0       	mov    $0xf017303f,%eax
f010071e:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	   cprintf("  _start                  %08x (phys)\n", _start);
	   cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	   cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	   cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	   cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	   cprintf("Kernel executable memory footprint: %dKB\n",
f0100723:	83 c4 08             	add    $0x8,%esp
f0100726:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010072b:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100731:	85 c0                	test   %eax,%eax
f0100733:	0f 48 c2             	cmovs  %edx,%eax
f0100736:	c1 f8 0a             	sar    $0xa,%eax
f0100739:	50                   	push   %eax
f010073a:	68 90 4d 10 f0       	push   $0xf0104d90
f010073f:	e8 8d 29 00 00       	call   f01030d1 <cprintf>
				    ROUNDUP(end - entry, 1024) / 1024);
	   return 0;
}
f0100744:	b8 00 00 00 00       	mov    $0x0,%eax
f0100749:	c9                   	leave  
f010074a:	c3                   	ret    

f010074b <mon_backtrace>:
	   int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074b:	55                   	push   %ebp
f010074c:	89 e5                	mov    %esp,%ebp
f010074e:	57                   	push   %edi
f010074f:	56                   	push   %esi
f0100750:	53                   	push   %ebx
f0100751:	83 ec 48             	sub    $0x48,%esp
	   // Your code here.

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
f0100754:	89 ee                	mov    %ebp,%esi
	   cprintf("Stack Backtrace: \n");
f0100756:	68 30 4c 10 f0       	push   $0xf0104c30
f010075b:	e8 71 29 00 00       	call   f01030d1 <cprintf>
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f0100760:	83 c4 10             	add    $0x10,%esp
f0100763:	e9 80 00 00 00       	jmp    f01007e8 <mon_backtrace+0x9d>
	   {
			 ueip = *((uint32_t *)baseframe + 1);
f0100768:	8b 46 04             	mov    0x4(%esi),%eax
f010076b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
f010076e:	83 ec 04             	sub    $0x4,%esp
f0100771:	50                   	push   %eax
f0100772:	56                   	push   %esi
f0100773:	68 43 4c 10 f0       	push   $0xf0104c43
f0100778:	e8 54 29 00 00       	call   f01030d1 <cprintf>
f010077d:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100780:	8d 7e 1c             	lea    0x1c(%esi),%edi
f0100783:	83 c4 10             	add    $0x10,%esp
			 for (int i = 2; i < 7; i ++)
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
f0100786:	83 ec 08             	sub    $0x8,%esp
f0100789:	ff 33                	pushl  (%ebx)
f010078b:	68 5b 4c 10 f0       	push   $0xf0104c5b
f0100790:	e8 3c 29 00 00       	call   f01030d1 <cprintf>
f0100795:	83 c3 04             	add    $0x4,%ebx
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
	   {
			 ueip = *((uint32_t *)baseframe + 1);
			 cprintf("ebp %08x eip %08x args ", baseframe, ueip);
			 for (int i = 2; i < 7; i ++)
f0100798:	83 c4 10             	add    $0x10,%esp
f010079b:	39 fb                	cmp    %edi,%ebx
f010079d:	75 e7                	jne    f0100786 <mon_backtrace+0x3b>
			 {
				    arg = *((uint32_t*) baseframe + i);
				    cprintf(" %08x ", arg);
			 }

			 cprintf("\n");
f010079f:	83 ec 0c             	sub    $0xc,%esp
f01007a2:	68 2b 49 10 f0       	push   $0xf010492b
f01007a7:	e8 25 29 00 00       	call   f01030d1 <cprintf>
			 struct Eipdebuginfo information;
			 debuginfo_eip (ueip, &information);
f01007ac:	83 c4 08             	add    $0x8,%esp
f01007af:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007b2:	50                   	push   %eax
f01007b3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01007b6:	53                   	push   %ebx
f01007b7:	e8 b3 32 00 00       	call   f0103a6f <debuginfo_eip>
			 uintptr_t offset = ueip - information.eip_fn_addr;
f01007bc:	2b 5d e0             	sub    -0x20(%ebp),%ebx
			 cprintf("\t%s:%d: ", information.eip_file, information.eip_line);
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007c5:	ff 75 d0             	pushl  -0x30(%ebp)
f01007c8:	68 62 4c 10 f0       	push   $0xf0104c62
f01007cd:	e8 ff 28 00 00       	call   f01030d1 <cprintf>
			 cprintf("%.*s+%d\n",information.eip_fn_namelen, information.eip_fn_name, offset);
f01007d2:	53                   	push   %ebx
f01007d3:	ff 75 d8             	pushl  -0x28(%ebp)
f01007d6:	ff 75 dc             	pushl  -0x24(%ebp)
f01007d9:	68 6b 4c 10 f0       	push   $0xf0104c6b
f01007de:	e8 ee 28 00 00       	call   f01030d1 <cprintf>

			 baseframe = *(uint32_t *) baseframe;
f01007e3:	8b 36                	mov    (%esi),%esi
f01007e5:	83 c4 20             	add    $0x20,%esp

	   uint32_t func_ebp = 0, ueip = 0, arg = 0;
	   asm volatile("movl %%ebp,%0" : "=r" (func_ebp));
	   cprintf("Stack Backtrace: \n");
	   uint32_t baseframe = func_ebp;
	   while(baseframe != 0)
f01007e8:	85 f6                	test   %esi,%esi
f01007ea:	0f 85 78 ff ff ff    	jne    f0100768 <mon_backtrace+0x1d>


	   }

	   return 0;
}
f01007f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007f8:	5b                   	pop    %ebx
f01007f9:	5e                   	pop    %esi
f01007fa:	5f                   	pop    %edi
f01007fb:	5d                   	pop    %ebp
f01007fc:	c3                   	ret    

f01007fd <monitor>:
	   return 0;
}

	   void
monitor(struct Trapframe *tf)
{
f01007fd:	55                   	push   %ebp
f01007fe:	89 e5                	mov    %esp,%ebp
f0100800:	57                   	push   %edi
f0100801:	56                   	push   %esi
f0100802:	53                   	push   %ebx
f0100803:	83 ec 58             	sub    $0x58,%esp
	   char *buf;

	   cprintf("Welcome to the JOS kernel monitor!\n");
f0100806:	68 bc 4d 10 f0       	push   $0xf0104dbc
f010080b:	e8 c1 28 00 00       	call   f01030d1 <cprintf>
	   cprintf("Type 'help' for a list of commands.\n");
f0100810:	c7 04 24 e0 4d 10 f0 	movl   $0xf0104de0,(%esp)
f0100817:	e8 b5 28 00 00       	call   f01030d1 <cprintf>

	if (tf != NULL)
f010081c:	83 c4 10             	add    $0x10,%esp
f010081f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100823:	74 0e                	je     f0100833 <monitor+0x36>
		print_trapframe(tf);
f0100825:	83 ec 0c             	sub    $0xc,%esp
f0100828:	ff 75 08             	pushl  0x8(%ebp)
f010082b:	e8 e4 2c 00 00       	call   f0103514 <print_trapframe>
f0100830:	83 c4 10             	add    $0x10,%esp

	   while (1) {
			 buf = readline("K> ");
f0100833:	83 ec 0c             	sub    $0xc,%esp
f0100836:	68 74 4c 10 f0       	push   $0xf0104c74
f010083b:	e8 c0 39 00 00       	call   f0104200 <readline>
f0100840:	89 c3                	mov    %eax,%ebx
			 if (buf != NULL)
f0100842:	83 c4 10             	add    $0x10,%esp
f0100845:	85 c0                	test   %eax,%eax
f0100847:	74 ea                	je     f0100833 <monitor+0x36>
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
f0100849:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	   int argc;
	   char *argv[MAXARGS];
	   int i;

	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
f0100850:	be 00 00 00 00       	mov    $0x0,%esi
f0100855:	eb 0a                	jmp    f0100861 <monitor+0x64>
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
				    *buf++ = 0;
f0100857:	c6 03 00             	movb   $0x0,(%ebx)
f010085a:	89 f7                	mov    %esi,%edi
f010085c:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010085f:	89 fe                	mov    %edi,%esi
	   // Parse the command buffer into whitespace-separated arguments
	   argc = 0;
	   argv[argc] = 0;
	   while (1) {
			 // gobble whitespace
			 while (*buf && strchr(WHITESPACE, *buf))
f0100861:	0f b6 03             	movzbl (%ebx),%eax
f0100864:	84 c0                	test   %al,%al
f0100866:	74 63                	je     f01008cb <monitor+0xce>
f0100868:	83 ec 08             	sub    $0x8,%esp
f010086b:	0f be c0             	movsbl %al,%eax
f010086e:	50                   	push   %eax
f010086f:	68 78 4c 10 f0       	push   $0xf0104c78
f0100874:	e8 a1 3b 00 00       	call   f010441a <strchr>
f0100879:	83 c4 10             	add    $0x10,%esp
f010087c:	85 c0                	test   %eax,%eax
f010087e:	75 d7                	jne    f0100857 <monitor+0x5a>
				    *buf++ = 0;
			 if (*buf == 0)
f0100880:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100883:	74 46                	je     f01008cb <monitor+0xce>
				    break;

			 // save and scan past next arg
			 if (argc == MAXARGS-1) {
f0100885:	83 fe 0f             	cmp    $0xf,%esi
f0100888:	75 14                	jne    f010089e <monitor+0xa1>
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	6a 10                	push   $0x10
f010088f:	68 7d 4c 10 f0       	push   $0xf0104c7d
f0100894:	e8 38 28 00 00       	call   f01030d1 <cprintf>
f0100899:	83 c4 10             	add    $0x10,%esp
f010089c:	eb 95                	jmp    f0100833 <monitor+0x36>
				    return 0;
			 }
			 argv[argc++] = buf;
f010089e:	8d 7e 01             	lea    0x1(%esi),%edi
f01008a1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008a5:	eb 03                	jmp    f01008aa <monitor+0xad>
			 while (*buf && !strchr(WHITESPACE, *buf))
				    buf++;
f01008a7:	83 c3 01             	add    $0x1,%ebx
			 if (argc == MAXARGS-1) {
				    cprintf("Too many arguments (max %d)\n", MAXARGS);
				    return 0;
			 }
			 argv[argc++] = buf;
			 while (*buf && !strchr(WHITESPACE, *buf))
f01008aa:	0f b6 03             	movzbl (%ebx),%eax
f01008ad:	84 c0                	test   %al,%al
f01008af:	74 ae                	je     f010085f <monitor+0x62>
f01008b1:	83 ec 08             	sub    $0x8,%esp
f01008b4:	0f be c0             	movsbl %al,%eax
f01008b7:	50                   	push   %eax
f01008b8:	68 78 4c 10 f0       	push   $0xf0104c78
f01008bd:	e8 58 3b 00 00       	call   f010441a <strchr>
f01008c2:	83 c4 10             	add    $0x10,%esp
f01008c5:	85 c0                	test   %eax,%eax
f01008c7:	74 de                	je     f01008a7 <monitor+0xaa>
f01008c9:	eb 94                	jmp    f010085f <monitor+0x62>
				    buf++;
	   }
	   argv[argc] = 0;
f01008cb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008d2:	00 

	   // Lookup and invoke the command
	   if (argc == 0)
f01008d3:	85 f6                	test   %esi,%esi
f01008d5:	0f 84 58 ff ff ff    	je     f0100833 <monitor+0x36>
f01008db:	bb 00 00 00 00       	mov    $0x0,%ebx
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
			 if (strcmp(argv[0], commands[i].name) == 0)
f01008e0:	83 ec 08             	sub    $0x8,%esp
f01008e3:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008e6:	ff 34 85 20 4e 10 f0 	pushl  -0xfefb1e0(,%eax,4)
f01008ed:	ff 75 a8             	pushl  -0x58(%ebp)
f01008f0:	e8 c7 3a 00 00       	call   f01043bc <strcmp>
f01008f5:	83 c4 10             	add    $0x10,%esp
f01008f8:	85 c0                	test   %eax,%eax
f01008fa:	75 21                	jne    f010091d <monitor+0x120>
				    return commands[i].func(argc, argv, tf);
f01008fc:	83 ec 04             	sub    $0x4,%esp
f01008ff:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100902:	ff 75 08             	pushl  0x8(%ebp)
f0100905:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100908:	52                   	push   %edx
f0100909:	56                   	push   %esi
f010090a:	ff 14 85 28 4e 10 f0 	call   *-0xfefb1d8(,%eax,4)
		print_trapframe(tf);

	   while (1) {
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
f0100911:	83 c4 10             	add    $0x10,%esp
f0100914:	85 c0                	test   %eax,%eax
f0100916:	78 25                	js     f010093d <monitor+0x140>
f0100918:	e9 16 ff ff ff       	jmp    f0100833 <monitor+0x36>
	   argv[argc] = 0;

	   // Lookup and invoke the command
	   if (argc == 0)
			 return 0;
	   for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010091d:	83 c3 01             	add    $0x1,%ebx
f0100920:	83 fb 03             	cmp    $0x3,%ebx
f0100923:	75 bb                	jne    f01008e0 <monitor+0xe3>
			 if (strcmp(argv[0], commands[i].name) == 0)
				    return commands[i].func(argc, argv, tf);
	   }
	   cprintf("Unknown command '%s'\n", argv[0]);
f0100925:	83 ec 08             	sub    $0x8,%esp
f0100928:	ff 75 a8             	pushl  -0x58(%ebp)
f010092b:	68 9a 4c 10 f0       	push   $0xf0104c9a
f0100930:	e8 9c 27 00 00       	call   f01030d1 <cprintf>
f0100935:	83 c4 10             	add    $0x10,%esp
f0100938:	e9 f6 fe ff ff       	jmp    f0100833 <monitor+0x36>
			 buf = readline("K> ");
			 if (buf != NULL)
				    if (runcmd(buf, tf) < 0)
						  break;
	   }
}
f010093d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100940:	5b                   	pop    %ebx
f0100941:	5e                   	pop    %esi
f0100942:	5f                   	pop    %edi
f0100943:	5d                   	pop    %ebp
f0100944:	c3                   	ret    

f0100945 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

	   static int
nvram_read(int r)
{
f0100945:	55                   	push   %ebp
f0100946:	89 e5                	mov    %esp,%ebp
f0100948:	56                   	push   %esi
f0100949:	53                   	push   %ebx
f010094a:	89 c3                	mov    %eax,%ebx
	   return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010094c:	83 ec 0c             	sub    $0xc,%esp
f010094f:	50                   	push   %eax
f0100950:	e8 15 27 00 00       	call   f010306a <mc146818_read>
f0100955:	89 c6                	mov    %eax,%esi
f0100957:	83 c3 01             	add    $0x1,%ebx
f010095a:	89 1c 24             	mov    %ebx,(%esp)
f010095d:	e8 08 27 00 00       	call   f010306a <mc146818_read>
f0100962:	c1 e0 08             	shl    $0x8,%eax
f0100965:	09 f0                	or     %esi,%eax
}
f0100967:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010096a:	5b                   	pop    %ebx
f010096b:	5e                   	pop    %esi
f010096c:	5d                   	pop    %ebp
f010096d:	c3                   	ret    

f010096e <boot_alloc>:
	   // Initialize nextfree if this is the first time.
	   // 'end' is a magic symbol automatically generated by the linker,
	   // which points to the end of the kernel's bss segment:
	   // the first virtual address that the linker did *not* assign
	   // to any kernel code or global variables.
	   if (!nextfree) {
f010096e:	83 3d 78 1f 17 f0 00 	cmpl   $0x0,0xf0171f78
f0100975:	75 11                	jne    f0100988 <boot_alloc+0x1a>
			 extern char end[];
			 nextfree = ROUNDUP((char *) end, PGSIZE);
f0100977:	ba 3f 3c 17 f0       	mov    $0xf0173c3f,%edx
f010097c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100982:	89 15 78 1f 17 f0    	mov    %edx,0xf0171f78
	   }

	   result = nextfree;
f0100988:	8b 0d 78 1f 17 f0    	mov    0xf0171f78,%ecx
	   // nextfree.  Make sure nextfree is kept aligned
	   // to a multiple of PGSIZE.
	   //
	   // LAB 2: Your code here.

	   nextfree = ROUNDUP ( result + n, PGSIZE);
f010098e:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100995:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010099b:	89 15 78 1f 17 f0    	mov    %edx,0xf0171f78
	   if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
f01009a1:	81 fa ff ff 3f f0    	cmp    $0xf03fffff,%edx
f01009a7:	76 25                	jbe    f01009ce <boot_alloc+0x60>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
	   static void *
boot_alloc(uint32_t n)
{
f01009a9:	55                   	push   %ebp
f01009aa:	89 e5                	mov    %esp,%ebp
f01009ac:	53                   	push   %ebx
f01009ad:	83 ec 10             	sub    $0x10,%esp
f01009b0:	89 c3                	mov    %eax,%ebx
	   // LAB 2: Your code here.

	   nextfree = ROUNDUP ( result + n, PGSIZE);
	   if ((uintptr_t)nextfree >= (KERNBASE + PTSIZE))
	   {
			 cprintf("OUT OF MEMORY");
f01009b2:	68 44 4e 10 f0       	push   $0xf0104e44
f01009b7:	e8 15 27 00 00       	call   f01030d1 <cprintf>
			 panic ("boot alloc Failed to allocate %d bytes", n);
f01009bc:	53                   	push   %ebx
f01009bd:	68 90 51 10 f0       	push   $0xf0105190
f01009c2:	6a 71                	push   $0x71
f01009c4:	68 52 4e 10 f0       	push   $0xf0104e52
f01009c9:	e8 de f6 ff ff       	call   f01000ac <_panic>
	   }

	   return result;
}
f01009ce:	89 c8                	mov    %ecx,%eax
f01009d0:	c3                   	ret    

f01009d1 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	   pte_t *p;

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
f01009d1:	89 d1                	mov    %edx,%ecx
f01009d3:	c1 e9 16             	shr    $0x16,%ecx
f01009d6:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009d9:	a8 01                	test   $0x1,%al
f01009db:	74 52                	je     f0100a2f <check_va2pa+0x5e>
			 return ~0;
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009e2:	89 c1                	mov    %eax,%ecx
f01009e4:	c1 e9 0c             	shr    $0xc,%ecx
f01009e7:	3b 0d 48 2c 17 f0    	cmp    0xf0172c48,%ecx
f01009ed:	72 1b                	jb     f0100a0a <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

	   static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009ef:	55                   	push   %ebp
f01009f0:	89 e5                	mov    %esp,%ebp
f01009f2:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009f5:	50                   	push   %eax
f01009f6:	68 b8 51 10 f0       	push   $0xf01051b8
f01009fb:	68 44 03 00 00       	push   $0x344
f0100a00:	68 52 4e 10 f0       	push   $0xf0104e52
f0100a05:	e8 a2 f6 ff ff       	call   f01000ac <_panic>

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
			 return ~0;
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	   if (!(p[PTX(va)] & PTE_P))
f0100a0a:	c1 ea 0c             	shr    $0xc,%edx
f0100a0d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a13:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a1a:	89 c2                	mov    %eax,%edx
f0100a1c:	83 e2 01             	and    $0x1,%edx
			 return ~0;
	   return PTE_ADDR(p[PTX(va)]);
f0100a1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a24:	85 d2                	test   %edx,%edx
f0100a26:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a2b:	0f 44 c2             	cmove  %edx,%eax
f0100a2e:	c3                   	ret    
{
	   pte_t *p;

	   pgdir = &pgdir[PDX(va)];
	   if (!(*pgdir & PTE_P))
			 return ~0;
f0100a2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	   p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	   if (!(p[PTX(va)] & PTE_P))
			 return ~0;
	   return PTE_ADDR(p[PTX(va)]);
}
f0100a34:	c3                   	ret    

f0100a35 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
	   static void
check_page_free_list(bool only_low_memory)
{
f0100a35:	55                   	push   %ebp
f0100a36:	89 e5                	mov    %esp,%ebp
f0100a38:	57                   	push   %edi
f0100a39:	56                   	push   %esi
f0100a3a:	53                   	push   %ebx
f0100a3b:	83 ec 2c             	sub    $0x2c,%esp
	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a3e:	84 c0                	test   %al,%al
f0100a40:	0f 85 81 02 00 00    	jne    f0100cc7 <check_page_free_list+0x292>
f0100a46:	e9 8e 02 00 00       	jmp    f0100cd9 <check_page_free_list+0x2a4>
	   int nfree_basemem = 0, nfree_extmem = 0;
	   char *first_free_page;

	   if (!page_free_list)
			 panic("'page_free_list' is a null pointer!");
f0100a4b:	83 ec 04             	sub    $0x4,%esp
f0100a4e:	68 dc 51 10 f0       	push   $0xf01051dc
f0100a53:	68 80 02 00 00       	push   $0x280
f0100a58:	68 52 4e 10 f0       	push   $0xf0104e52
f0100a5d:	e8 4a f6 ff ff       	call   f01000ac <_panic>

	   if (only_low_memory) {
			 // Move pages with lower addresses first in the free
			 // list, since entry_pgdir does not map all pages.
			 struct PageInfo *pp1, *pp2;
			 struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a62:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a65:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a68:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a6b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			 for (pp = page_free_list; pp; pp = pp->pp_link) {
				    int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a6e:	89 c2                	mov    %eax,%edx
f0100a70:	2b 15 50 2c 17 f0    	sub    0xf0172c50,%edx
f0100a76:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a7c:	0f 95 c2             	setne  %dl
f0100a7f:	0f b6 d2             	movzbl %dl,%edx
				    *tp[pagetype] = pp;
f0100a82:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a86:	89 01                	mov    %eax,(%ecx)
				    tp[pagetype] = &pp->pp_link;
f0100a88:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	   if (only_low_memory) {
			 // Move pages with lower addresses first in the free
			 // list, since entry_pgdir does not map all pages.
			 struct PageInfo *pp1, *pp2;
			 struct PageInfo **tp[2] = { &pp1, &pp2 };
			 for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a8c:	8b 00                	mov    (%eax),%eax
f0100a8e:	85 c0                	test   %eax,%eax
f0100a90:	75 dc                	jne    f0100a6e <check_page_free_list+0x39>
				    int pagetype = PDX(page2pa(pp)) >= pdx_limit;
				    *tp[pagetype] = pp;
				    tp[pagetype] = &pp->pp_link;
			 }
			 *tp[1] = 0;
f0100a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a95:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			 *tp[0] = pp2;
f0100a9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a9e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100aa1:	89 10                	mov    %edx,(%eax)
			 page_free_list = pp1;
f0100aa3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100aa6:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80
//
	   static void
check_page_free_list(bool only_low_memory)
{
	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aab:	be 01 00 00 00       	mov    $0x1,%esi
			 page_free_list = pp1;
	   }

	   // if there's a page that shouldn't be on the free list,
	   // try to make sure it eventually causes trouble.
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ab0:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
f0100ab6:	eb 53                	jmp    f0100b0b <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ab8:	89 d8                	mov    %ebx,%eax
f0100aba:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0100ac0:	c1 f8 03             	sar    $0x3,%eax
f0100ac3:	c1 e0 0c             	shl    $0xc,%eax
			 if (PDX(page2pa(pp)) < pdx_limit)
f0100ac6:	89 c2                	mov    %eax,%edx
f0100ac8:	c1 ea 16             	shr    $0x16,%edx
f0100acb:	39 f2                	cmp    %esi,%edx
f0100acd:	73 3a                	jae    f0100b09 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100acf:	89 c2                	mov    %eax,%edx
f0100ad1:	c1 ea 0c             	shr    $0xc,%edx
f0100ad4:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f0100ada:	72 12                	jb     f0100aee <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100adc:	50                   	push   %eax
f0100add:	68 b8 51 10 f0       	push   $0xf01051b8
f0100ae2:	6a 56                	push   $0x56
f0100ae4:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100ae9:	e8 be f5 ff ff       	call   f01000ac <_panic>
				    memset(page2kva(pp), 0x97, 128);
f0100aee:	83 ec 04             	sub    $0x4,%esp
f0100af1:	68 80 00 00 00       	push   $0x80
f0100af6:	68 97 00 00 00       	push   $0x97
f0100afb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b00:	50                   	push   %eax
f0100b01:	e8 51 39 00 00       	call   f0104457 <memset>
f0100b06:	83 c4 10             	add    $0x10,%esp
			 page_free_list = pp1;
	   }

	   // if there's a page that shouldn't be on the free list,
	   // try to make sure it eventually causes trouble.
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b09:	8b 1b                	mov    (%ebx),%ebx
f0100b0b:	85 db                	test   %ebx,%ebx
f0100b0d:	75 a9                	jne    f0100ab8 <check_page_free_list+0x83>
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
f0100b0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b14:	e8 55 fe ff ff       	call   f010096e <boot_alloc>
f0100b19:	89 45 cc             	mov    %eax,-0x34(%ebp)
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b1c:	8b 15 80 1f 17 f0    	mov    0xf0171f80,%edx
			 // check that we didn't corrupt the free list itself
			 assert(pp >= pages);
f0100b22:	8b 0d 50 2c 17 f0    	mov    0xf0172c50,%ecx
			 assert(pp < pages + npages);
f0100b28:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0100b2d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b30:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
			 assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b33:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	   static void
check_page_free_list(bool only_low_memory)
{
	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	   int nfree_basemem = 0, nfree_extmem = 0;
f0100b36:	be 00 00 00 00       	mov    $0x0,%esi
f0100b3b:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	   for (pp = page_free_list; pp; pp = pp->pp_link)
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b3e:	e9 30 01 00 00       	jmp    f0100c73 <check_page_free_list+0x23e>
			 // check that we didn't corrupt the free list itself
			 assert(pp >= pages);
f0100b43:	39 ca                	cmp    %ecx,%edx
f0100b45:	73 19                	jae    f0100b60 <check_page_free_list+0x12b>
f0100b47:	68 6c 4e 10 f0       	push   $0xf0104e6c
f0100b4c:	68 78 4e 10 f0       	push   $0xf0104e78
f0100b51:	68 9a 02 00 00       	push   $0x29a
f0100b56:	68 52 4e 10 f0       	push   $0xf0104e52
f0100b5b:	e8 4c f5 ff ff       	call   f01000ac <_panic>
			 assert(pp < pages + npages);
f0100b60:	39 fa                	cmp    %edi,%edx
f0100b62:	72 19                	jb     f0100b7d <check_page_free_list+0x148>
f0100b64:	68 8d 4e 10 f0       	push   $0xf0104e8d
f0100b69:	68 78 4e 10 f0       	push   $0xf0104e78
f0100b6e:	68 9b 02 00 00       	push   $0x29b
f0100b73:	68 52 4e 10 f0       	push   $0xf0104e52
f0100b78:	e8 2f f5 ff ff       	call   f01000ac <_panic>
			 assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b7d:	89 d0                	mov    %edx,%eax
f0100b7f:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b82:	a8 07                	test   $0x7,%al
f0100b84:	74 19                	je     f0100b9f <check_page_free_list+0x16a>
f0100b86:	68 00 52 10 f0       	push   $0xf0105200
f0100b8b:	68 78 4e 10 f0       	push   $0xf0104e78
f0100b90:	68 9c 02 00 00       	push   $0x29c
f0100b95:	68 52 4e 10 f0       	push   $0xf0104e52
f0100b9a:	e8 0d f5 ff ff       	call   f01000ac <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b9f:	c1 f8 03             	sar    $0x3,%eax
f0100ba2:	c1 e0 0c             	shl    $0xc,%eax

			 // check a few pages that shouldn't be on the free list
			 assert(page2pa(pp) != 0);
f0100ba5:	85 c0                	test   %eax,%eax
f0100ba7:	75 19                	jne    f0100bc2 <check_page_free_list+0x18d>
f0100ba9:	68 a1 4e 10 f0       	push   $0xf0104ea1
f0100bae:	68 78 4e 10 f0       	push   $0xf0104e78
f0100bb3:	68 9f 02 00 00       	push   $0x29f
f0100bb8:	68 52 4e 10 f0       	push   $0xf0104e52
f0100bbd:	e8 ea f4 ff ff       	call   f01000ac <_panic>
			 assert(page2pa(pp) != IOPHYSMEM);
f0100bc2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bc7:	75 19                	jne    f0100be2 <check_page_free_list+0x1ad>
f0100bc9:	68 b2 4e 10 f0       	push   $0xf0104eb2
f0100bce:	68 78 4e 10 f0       	push   $0xf0104e78
f0100bd3:	68 a0 02 00 00       	push   $0x2a0
f0100bd8:	68 52 4e 10 f0       	push   $0xf0104e52
f0100bdd:	e8 ca f4 ff ff       	call   f01000ac <_panic>
			 assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be2:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100be7:	75 19                	jne    f0100c02 <check_page_free_list+0x1cd>
f0100be9:	68 34 52 10 f0       	push   $0xf0105234
f0100bee:	68 78 4e 10 f0       	push   $0xf0104e78
f0100bf3:	68 a1 02 00 00       	push   $0x2a1
f0100bf8:	68 52 4e 10 f0       	push   $0xf0104e52
f0100bfd:	e8 aa f4 ff ff       	call   f01000ac <_panic>
			 assert(page2pa(pp) != EXTPHYSMEM);
f0100c02:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c07:	75 19                	jne    f0100c22 <check_page_free_list+0x1ed>
f0100c09:	68 cb 4e 10 f0       	push   $0xf0104ecb
f0100c0e:	68 78 4e 10 f0       	push   $0xf0104e78
f0100c13:	68 a2 02 00 00       	push   $0x2a2
f0100c18:	68 52 4e 10 f0       	push   $0xf0104e52
f0100c1d:	e8 8a f4 ff ff       	call   f01000ac <_panic>
			 assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c22:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c27:	76 3f                	jbe    f0100c68 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c29:	89 c3                	mov    %eax,%ebx
f0100c2b:	c1 eb 0c             	shr    $0xc,%ebx
f0100c2e:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c31:	77 12                	ja     f0100c45 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c33:	50                   	push   %eax
f0100c34:	68 b8 51 10 f0       	push   $0xf01051b8
f0100c39:	6a 56                	push   $0x56
f0100c3b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100c40:	e8 67 f4 ff ff       	call   f01000ac <_panic>
f0100c45:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c4d:	76 1e                	jbe    f0100c6d <check_page_free_list+0x238>
f0100c4f:	68 58 52 10 f0       	push   $0xf0105258
f0100c54:	68 78 4e 10 f0       	push   $0xf0104e78
f0100c59:	68 a3 02 00 00       	push   $0x2a3
f0100c5e:	68 52 4e 10 f0       	push   $0xf0104e52
f0100c63:	e8 44 f4 ff ff       	call   f01000ac <_panic>

			 if (page2pa(pp) < EXTPHYSMEM)
				    ++nfree_basemem;
f0100c68:	83 c6 01             	add    $0x1,%esi
f0100c6b:	eb 04                	jmp    f0100c71 <check_page_free_list+0x23c>
			 else
				    ++nfree_extmem;
f0100c6d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	   for (pp = page_free_list; pp; pp = pp->pp_link)
			 if (PDX(page2pa(pp)) < pdx_limit)
				    memset(page2kva(pp), 0x97, 128);

	   first_free_page = (char *) boot_alloc(0);
	   for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c71:	8b 12                	mov    (%edx),%edx
f0100c73:	85 d2                	test   %edx,%edx
f0100c75:	0f 85 c8 fe ff ff    	jne    f0100b43 <check_page_free_list+0x10e>
f0100c7b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
				    ++nfree_basemem;
			 else
				    ++nfree_extmem;
	   }

	   assert(nfree_basemem > 0);
f0100c7e:	85 f6                	test   %esi,%esi
f0100c80:	7f 19                	jg     f0100c9b <check_page_free_list+0x266>
f0100c82:	68 e5 4e 10 f0       	push   $0xf0104ee5
f0100c87:	68 78 4e 10 f0       	push   $0xf0104e78
f0100c8c:	68 ab 02 00 00       	push   $0x2ab
f0100c91:	68 52 4e 10 f0       	push   $0xf0104e52
f0100c96:	e8 11 f4 ff ff       	call   f01000ac <_panic>
	   assert(nfree_extmem > 0);
f0100c9b:	85 db                	test   %ebx,%ebx
f0100c9d:	7f 19                	jg     f0100cb8 <check_page_free_list+0x283>
f0100c9f:	68 f7 4e 10 f0       	push   $0xf0104ef7
f0100ca4:	68 78 4e 10 f0       	push   $0xf0104e78
f0100ca9:	68 ac 02 00 00       	push   $0x2ac
f0100cae:	68 52 4e 10 f0       	push   $0xf0104e52
f0100cb3:	e8 f4 f3 ff ff       	call   f01000ac <_panic>

	   cprintf("check_page_free_list() succeeded!\n");
f0100cb8:	83 ec 0c             	sub    $0xc,%esp
f0100cbb:	68 a0 52 10 f0       	push   $0xf01052a0
f0100cc0:	e8 0c 24 00 00       	call   f01030d1 <cprintf>
}
f0100cc5:	eb 29                	jmp    f0100cf0 <check_page_free_list+0x2bb>
	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	   int nfree_basemem = 0, nfree_extmem = 0;
	   char *first_free_page;

	   if (!page_free_list)
f0100cc7:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f0100ccc:	85 c0                	test   %eax,%eax
f0100cce:	0f 85 8e fd ff ff    	jne    f0100a62 <check_page_free_list+0x2d>
f0100cd4:	e9 72 fd ff ff       	jmp    f0100a4b <check_page_free_list+0x16>
f0100cd9:	83 3d 80 1f 17 f0 00 	cmpl   $0x0,0xf0171f80
f0100ce0:	0f 84 65 fd ff ff    	je     f0100a4b <check_page_free_list+0x16>
//
	   static void
check_page_free_list(bool only_low_memory)
{
	   struct PageInfo *pp;
	   unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ce6:	be 00 04 00 00       	mov    $0x400,%esi
f0100ceb:	e9 c0 fd ff ff       	jmp    f0100ab0 <check_page_free_list+0x7b>

	   assert(nfree_basemem > 0);
	   assert(nfree_extmem > 0);

	   cprintf("check_page_free_list() succeeded!\n");
}
f0100cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cf3:	5b                   	pop    %ebx
f0100cf4:	5e                   	pop    %esi
f0100cf5:	5f                   	pop    %edi
f0100cf6:	5d                   	pop    %ebp
f0100cf7:	c3                   	ret    

f0100cf8 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
	   void
page_init(void)
{
f0100cf8:	55                   	push   %ebp
f0100cf9:	89 e5                	mov    %esp,%ebp
f0100cfb:	56                   	push   %esi
f0100cfc:	53                   	push   %ebx
	   // The example code here marks all physical pages as free.
	   // However this is not truly the case.  What memory is free?
	   //  1) Mark physical page 0 as in use.
	   //     This way we preserve the real-mode IDT and BIOS structures
	   //     in case we ever need them.  (Currently we don't, but...)
	   pages[0].pp_ref = 1;
f0100cfd:	a1 50 2c 17 f0       	mov    0xf0172c50,%eax
f0100d02:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	   pages [0].pp_link = NULL;
f0100d08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	   //     is free.
	   for (int i = 1; i < npages_basemem; i++)
f0100d0e:	8b 35 84 1f 17 f0    	mov    0xf0171f84,%esi
f0100d14:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
f0100d1a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d1f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100d24:	eb 27                	jmp    f0100d4d <page_init+0x55>
f0100d26:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
	   {
			 pages[i].pp_ref = 0;
f0100d2d:	89 d1                	mov    %edx,%ecx
f0100d2f:	03 0d 50 2c 17 f0    	add    0xf0172c50,%ecx
f0100d35:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			 pages[i].pp_link = page_free_list;
f0100d3b:	89 19                	mov    %ebx,(%ecx)
	   //     in case we ever need them.  (Currently we don't, but...)
	   pages[0].pp_ref = 1;
	   pages [0].pp_link = NULL;
	   //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	   //     is free.
	   for (int i = 1; i < npages_basemem; i++)
f0100d3d:	83 c0 01             	add    $0x1,%eax
	   {
			 pages[i].pp_ref = 0;
			 pages[i].pp_link = page_free_list;
			 page_free_list = &pages [i];
f0100d40:	89 d3                	mov    %edx,%ebx
f0100d42:	03 1d 50 2c 17 f0    	add    0xf0172c50,%ebx
f0100d48:	ba 01 00 00 00       	mov    $0x1,%edx
	   //     in case we ever need them.  (Currently we don't, but...)
	   pages[0].pp_ref = 1;
	   pages [0].pp_link = NULL;
	   //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
	   //     is free.
	   for (int i = 1; i < npages_basemem; i++)
f0100d4d:	39 c6                	cmp    %eax,%esi
f0100d4f:	77 d5                	ja     f0100d26 <page_init+0x2e>
f0100d51:	84 d2                	test   %dl,%dl
f0100d53:	74 06                	je     f0100d5b <page_init+0x63>
f0100d55:	89 1d 80 1f 17 f0    	mov    %ebx,0xf0171f80
			 pages[i].pp_link = page_free_list;
			 page_free_list = &pages [i];
	   }
	   //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	   //     never be allocated.
	   uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
f0100d5b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d60:	e8 09 fc ff ff       	call   f010096e <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d65:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d6a:	77 15                	ja     f0100d81 <page_init+0x89>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d6c:	50                   	push   %eax
f0100d6d:	68 c4 52 10 f0       	push   $0xf01052c4
f0100d72:	68 1e 01 00 00       	push   $0x11e
f0100d77:	68 52 4e 10 f0       	push   $0xf0104e52
f0100d7c:	e8 2b f3 ff ff       	call   f01000ac <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100d81:	05 00 00 00 10       	add    $0x10000000,%eax
	   assert (free_pa % PGSIZE == 0);
f0100d86:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0100d8b:	74 19                	je     f0100da6 <page_init+0xae>
f0100d8d:	68 08 4f 10 f0       	push   $0xf0104f08
f0100d92:	68 78 4e 10 f0       	push   $0xf0104e78
f0100d97:	68 1f 01 00 00       	push   $0x11f
f0100d9c:	68 52 4e 10 f0       	push   $0xf0104e52
f0100da1:	e8 06 f3 ff ff       	call   f01000ac <_panic>
	   uint32_t free_pa_index = free_pa / PGSIZE;
f0100da6:	c1 e8 0c             	shr    $0xc,%eax
	   for (int i = npages_basemem; i < free_pa_index; i++)
f0100da9:	8b 15 84 1f 17 f0    	mov    0xf0171f84,%edx
f0100daf:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100db6:	eb 1a                	jmp    f0100dd2 <page_init+0xda>
	   {
			 pages[i].pp_ref = 1;
f0100db8:	89 cb                	mov    %ecx,%ebx
f0100dba:	03 1d 50 2c 17 f0    	add    0xf0172c50,%ebx
f0100dc0:	66 c7 43 04 01 00    	movw   $0x1,0x4(%ebx)
			 pages[i].pp_link = NULL;
f0100dc6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	   //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
	   //     never be allocated.
	   uint32_t free_pa = (uint32_t)PADDR (boot_alloc (0));
	   assert (free_pa % PGSIZE == 0);
	   uint32_t free_pa_index = free_pa / PGSIZE;
	   for (int i = npages_basemem; i < free_pa_index; i++)
f0100dcc:	83 c2 01             	add    $0x1,%edx
f0100dcf:	83 c1 08             	add    $0x8,%ecx
f0100dd2:	39 d0                	cmp    %edx,%eax
f0100dd4:	77 e2                	ja     f0100db8 <page_init+0xc0>
	   //     page tables and other data structures?
	   //
	   // Change the code to reflect this.
	   // NB: DO NOT actually touch the physical memory corresponding to
	   // free pages!
	   for (int i = free_pa_index; i < npages; i++)
f0100dd6:	89 c2                	mov    %eax,%edx
f0100dd8:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
f0100dde:	c1 e0 03             	shl    $0x3,%eax
f0100de1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100de6:	eb 23                	jmp    f0100e0b <page_init+0x113>
	   {
			 pages[i].pp_ref = 0;
f0100de8:	89 c1                	mov    %eax,%ecx
f0100dea:	03 0d 50 2c 17 f0    	add    0xf0172c50,%ecx
f0100df0:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			 pages[i].pp_link = page_free_list;
f0100df6:	89 19                	mov    %ebx,(%ecx)
			 page_free_list = &pages[i];
f0100df8:	89 c3                	mov    %eax,%ebx
f0100dfa:	03 1d 50 2c 17 f0    	add    0xf0172c50,%ebx
	   //     page tables and other data structures?
	   //
	   // Change the code to reflect this.
	   // NB: DO NOT actually touch the physical memory corresponding to
	   // free pages!
	   for (int i = free_pa_index; i < npages; i++)
f0100e00:	83 c2 01             	add    $0x1,%edx
f0100e03:	83 c0 08             	add    $0x8,%eax
f0100e06:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100e0b:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f0100e11:	72 d5                	jb     f0100de8 <page_init+0xf0>
f0100e13:	84 c9                	test   %cl,%cl
f0100e15:	74 06                	je     f0100e1d <page_init+0x125>
f0100e17:	89 1d 80 1f 17 f0    	mov    %ebx,0xf0171f80
	   {
			 pages[i].pp_ref = 0;
			 pages[i].pp_link = page_free_list;
			 page_free_list = &pages[i];
	   }
}
f0100e1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e20:	5b                   	pop    %ebx
f0100e21:	5e                   	pop    %esi
f0100e22:	5d                   	pop    %ebp
f0100e23:	c3                   	ret    

f0100e24 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
	   struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e24:	55                   	push   %ebp
f0100e25:	89 e5                	mov    %esp,%ebp
f0100e27:	53                   	push   %ebx
f0100e28:	83 ec 04             	sub    $0x4,%esp
	   // Fill this function in

	   struct PageInfo* allocate_page = page_free_list;
f0100e2b:	8b 1d 80 1f 17 f0    	mov    0xf0171f80,%ebx
	   if (allocate_page == NULL)
f0100e31:	85 db                	test   %ebx,%ebx
f0100e33:	74 5c                	je     f0100e91 <page_alloc+0x6d>
			 return NULL;

	   page_free_list = allocate_page -> pp_link;
f0100e35:	8b 03                	mov    (%ebx),%eax
f0100e37:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80
	   allocate_page -> pp_link = NULL;
f0100e3c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	   if (alloc_flags & ALLOC_ZERO)
			 memset (page2kva (allocate_page), 0, PGSIZE);

	   return allocate_page;
f0100e42:	89 d8                	mov    %ebx,%eax
			 return NULL;

	   page_free_list = allocate_page -> pp_link;
	   allocate_page -> pp_link = NULL;

	   if (alloc_flags & ALLOC_ZERO)
f0100e44:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e48:	74 4c                	je     f0100e96 <page_alloc+0x72>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e4a:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0100e50:	c1 f8 03             	sar    $0x3,%eax
f0100e53:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e56:	89 c2                	mov    %eax,%edx
f0100e58:	c1 ea 0c             	shr    $0xc,%edx
f0100e5b:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f0100e61:	72 12                	jb     f0100e75 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e63:	50                   	push   %eax
f0100e64:	68 b8 51 10 f0       	push   $0xf01051b8
f0100e69:	6a 56                	push   $0x56
f0100e6b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0100e70:	e8 37 f2 ff ff       	call   f01000ac <_panic>
			 memset (page2kva (allocate_page), 0, PGSIZE);
f0100e75:	83 ec 04             	sub    $0x4,%esp
f0100e78:	68 00 10 00 00       	push   $0x1000
f0100e7d:	6a 00                	push   $0x0
f0100e7f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e84:	50                   	push   %eax
f0100e85:	e8 cd 35 00 00       	call   f0104457 <memset>
f0100e8a:	83 c4 10             	add    $0x10,%esp

	   return allocate_page;
f0100e8d:	89 d8                	mov    %ebx,%eax
f0100e8f:	eb 05                	jmp    f0100e96 <page_alloc+0x72>
{
	   // Fill this function in

	   struct PageInfo* allocate_page = page_free_list;
	   if (allocate_page == NULL)
			 return NULL;
f0100e91:	b8 00 00 00 00       	mov    $0x0,%eax

	   if (alloc_flags & ALLOC_ZERO)
			 memset (page2kva (allocate_page), 0, PGSIZE);

	   return allocate_page;
}
f0100e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e99:	c9                   	leave  
f0100e9a:	c3                   	ret    

f0100e9b <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
	   void
page_free(struct PageInfo *pp)
{
f0100e9b:	55                   	push   %ebp
f0100e9c:	89 e5                	mov    %esp,%ebp
f0100e9e:	83 ec 08             	sub    $0x8,%esp
f0100ea1:	8b 45 08             	mov    0x8(%ebp),%eax
	   // Fill this function in
	   // Hint: You may want to panic if pp->pp_ref is nonzero or
	   // pp->pp_link is not NULL.

	   assert (pp->pp_ref == 0);
f0100ea4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ea9:	74 19                	je     f0100ec4 <page_free+0x29>
f0100eab:	68 1e 4f 10 f0       	push   $0xf0104f1e
f0100eb0:	68 78 4e 10 f0       	push   $0xf0104e78
f0100eb5:	68 60 01 00 00       	push   $0x160
f0100eba:	68 52 4e 10 f0       	push   $0xf0104e52
f0100ebf:	e8 e8 f1 ff ff       	call   f01000ac <_panic>
	   assert (pp->pp_link == NULL);
f0100ec4:	83 38 00             	cmpl   $0x0,(%eax)
f0100ec7:	74 19                	je     f0100ee2 <page_free+0x47>
f0100ec9:	68 2e 4f 10 f0       	push   $0xf0104f2e
f0100ece:	68 78 4e 10 f0       	push   $0xf0104e78
f0100ed3:	68 61 01 00 00       	push   $0x161
f0100ed8:	68 52 4e 10 f0       	push   $0xf0104e52
f0100edd:	e8 ca f1 ff ff       	call   f01000ac <_panic>

	   pp->pp_ref = 0;
f0100ee2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	   pp->pp_link = page_free_list;
f0100ee8:	8b 15 80 1f 17 f0    	mov    0xf0171f80,%edx
f0100eee:	89 10                	mov    %edx,(%eax)
	   page_free_list = pp;
f0100ef0:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80
}
f0100ef5:	c9                   	leave  
f0100ef6:	c3                   	ret    

f0100ef7 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
	   void
page_decref(struct PageInfo* pp)
{
f0100ef7:	55                   	push   %ebp
f0100ef8:	89 e5                	mov    %esp,%ebp
f0100efa:	83 ec 08             	sub    $0x8,%esp
f0100efd:	8b 55 08             	mov    0x8(%ebp),%edx
	   if (--pp->pp_ref == 0)
f0100f00:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f04:	83 e8 01             	sub    $0x1,%eax
f0100f07:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f0b:	66 85 c0             	test   %ax,%ax
f0100f0e:	75 0c                	jne    f0100f1c <page_decref+0x25>
			 page_free(pp);
f0100f10:	83 ec 0c             	sub    $0xc,%esp
f0100f13:	52                   	push   %edx
f0100f14:	e8 82 ff ff ff       	call   f0100e9b <page_free>
f0100f19:	83 c4 10             	add    $0x10,%esp
}
f0100f1c:	c9                   	leave  
f0100f1d:	c3                   	ret    

f0100f1e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
	   pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f1e:	55                   	push   %ebp
f0100f1f:	89 e5                	mov    %esp,%ebp
f0100f21:	56                   	push   %esi
f0100f22:	53                   	push   %ebx
f0100f23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   // Fill this function in

	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
f0100f26:	89 de                	mov    %ebx,%esi
f0100f28:	c1 ee 16             	shr    $0x16,%esi
f0100f2b:	c1 e6 02             	shl    $0x2,%esi
f0100f2e:	03 75 08             	add    0x8(%ebp),%esi
f0100f31:	8b 06                	mov    (%esi),%eax
	   if (!(pde_offset & PTE_P) && create)
f0100f33:	89 c2                	mov    %eax,%edx
f0100f35:	83 e2 01             	and    $0x1,%edx
f0100f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f3c:	74 2d                	je     f0100f6b <pgdir_walk+0x4d>
f0100f3e:	85 d2                	test   %edx,%edx
f0100f40:	75 29                	jne    f0100f6b <pgdir_walk+0x4d>
	   {
			 struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
f0100f42:	83 ec 0c             	sub    $0xc,%esp
f0100f45:	6a 01                	push   $0x1
f0100f47:	e8 d8 fe ff ff       	call   f0100e24 <page_alloc>
			 if (!new_page) return NULL;
f0100f4c:	83 c4 10             	add    $0x10,%esp
f0100f4f:	85 c0                	test   %eax,%eax
f0100f51:	74 55                	je     f0100fa8 <pgdir_walk+0x8a>

			 new_page -> pp_ref ++;
f0100f53:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
f0100f58:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0100f5e:	c1 f8 03             	sar    $0x3,%eax
f0100f61:	c1 e0 0c             	shl    $0xc,%eax
f0100f64:	83 c8 07             	or     $0x7,%eax
			 pgdir [PDX(address)] = pde_offset;
f0100f67:	89 06                	mov    %eax,(%esi)
	   // Fill this function in

	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
	   if (!(pde_offset & PTE_P) && create)
	   {
f0100f69:	eb 04                	jmp    f0100f6f <pgdir_walk+0x51>
			 if (!new_page) return NULL;

			 new_page -> pp_ref ++;
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
			 pgdir [PDX(address)] = pde_offset;
	   } else if (!(pde_offset & PTE_P)) return NULL;
f0100f6b:	85 d2                	test   %edx,%edx
f0100f6d:	74 40                	je     f0100faf <pgdir_walk+0x91>

	   physaddr_t pt_pa = PTE_ADDR(pde_offset);
f0100f6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f74:	89 c2                	mov    %eax,%edx
f0100f76:	c1 ea 0c             	shr    $0xc,%edx
f0100f79:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f0100f7f:	72 15                	jb     f0100f96 <pgdir_walk+0x78>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f81:	50                   	push   %eax
f0100f82:	68 b8 51 10 f0       	push   $0xf01051b8
f0100f87:	68 9b 01 00 00       	push   $0x19b
f0100f8c:	68 52 4e 10 f0       	push   $0xf0104e52
f0100f91:	e8 16 f1 ff ff       	call   f01000ac <_panic>
	   pte_t* pt_va = KADDR(pt_pa);
	   return &pt_va [PTX(address)];
f0100f96:	c1 eb 0a             	shr    $0xa,%ebx
f0100f99:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f9f:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100fa6:	eb 0c                	jmp    f0100fb4 <pgdir_walk+0x96>
	   uintptr_t address = (uintptr_t) va;
	   pde_t pde_offset = pgdir [PDX(address)];
	   if (!(pde_offset & PTE_P) && create)
	   {
			 struct PageInfo* new_page = page_alloc (ALLOC_ZERO);
			 if (!new_page) return NULL;
f0100fa8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fad:	eb 05                	jmp    f0100fb4 <pgdir_walk+0x96>

			 new_page -> pp_ref ++;
			 pde_offset = page2pa (new_page) | PTE_W | PTE_U | PTE_P;
			 pgdir [PDX(address)] = pde_offset;
	   } else if (!(pde_offset & PTE_P)) return NULL;
f0100faf:	b8 00 00 00 00       	mov    $0x0,%eax

	   physaddr_t pt_pa = PTE_ADDR(pde_offset);
	   pte_t* pt_va = KADDR(pt_pa);
	   return &pt_va [PTX(address)];
}
f0100fb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fb7:	5b                   	pop    %ebx
f0100fb8:	5e                   	pop    %esi
f0100fb9:	5d                   	pop    %ebp
f0100fba:	c3                   	ret    

f0100fbb <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
	   static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100fbb:	55                   	push   %ebp
f0100fbc:	89 e5                	mov    %esp,%ebp
f0100fbe:	57                   	push   %edi
f0100fbf:	56                   	push   %esi
f0100fc0:	53                   	push   %ebx
f0100fc1:	83 ec 1c             	sub    $0x1c,%esp
f0100fc4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fca:	c1 e9 0c             	shr    $0xc,%ecx
f0100fcd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f0100fd0:	89 c3                	mov    %eax,%ebx
f0100fd2:	be 00 00 00 00       	mov    $0x0,%esi
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f0100fd7:	89 d7                	mov    %edx,%edi
f0100fd9:	29 c7                	sub    %eax,%edi
			 assert (pte_entry != NULL);
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f0100fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fde:	83 c8 01             	or     $0x1,%eax
f0100fe1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f0100fe4:	eb 41                	jmp    f0101027 <boot_map_region+0x6c>
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
f0100fe6:	83 ec 04             	sub    $0x4,%esp
f0100fe9:	6a 01                	push   $0x1
f0100feb:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0100fee:	50                   	push   %eax
f0100fef:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ff2:	e8 27 ff ff ff       	call   f0100f1e <pgdir_walk>
			 assert (pte_entry != NULL);
f0100ff7:	83 c4 10             	add    $0x10,%esp
f0100ffa:	85 c0                	test   %eax,%eax
f0100ffc:	75 19                	jne    f0101017 <boot_map_region+0x5c>
f0100ffe:	68 42 4f 10 f0       	push   $0xf0104f42
f0101003:	68 78 4e 10 f0       	push   $0xf0104e78
f0101008:	68 b6 01 00 00       	push   $0x1b6
f010100d:	68 52 4e 10 f0       	push   $0xf0104e52
f0101012:	e8 95 f0 ff ff       	call   f01000ac <_panic>
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
f0101017:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010101a:	09 da                	or     %ebx,%edx
f010101c:	89 10                	mov    %edx,(%eax)
	   /*
		 if (va % PGSIZE != 0 || pa % PGSIZE != 0 || size % PGSIZE != 0)
		 panic ("boot_map_region cannot be executed \n");
	    */
	   uint32_t no_pages = size / PGSIZE;
	   for (int i = 0; i < no_pages; i ++)
f010101e:	83 c6 01             	add    $0x1,%esi
f0101021:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101027:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010102a:	75 ba                	jne    f0100fe6 <boot_map_region+0x2b>
	   {
			 pte_t* pte_entry = pgdir_walk (pgdir, (void*) (va + i*PGSIZE), 1);
			 assert (pte_entry != NULL);
			 *pte_entry = (pa + i *PGSIZE) | perm | PTE_P;
	   }
}
f010102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010102f:	5b                   	pop    %ebx
f0101030:	5e                   	pop    %esi
f0101031:	5f                   	pop    %edi
f0101032:	5d                   	pop    %ebp
f0101033:	c3                   	ret    

f0101034 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
	   struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101034:	55                   	push   %ebp
f0101035:	89 e5                	mov    %esp,%ebp
f0101037:	53                   	push   %ebx
f0101038:	83 ec 08             	sub    $0x8,%esp
f010103b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, 0);
f010103e:	6a 00                	push   $0x0
f0101040:	ff 75 0c             	pushl  0xc(%ebp)
f0101043:	ff 75 08             	pushl  0x8(%ebp)
f0101046:	e8 d3 fe ff ff       	call   f0100f1e <pgdir_walk>

	   if (!pte_entry || !(*pte_entry & PTE_P))
f010104b:	83 c4 10             	add    $0x10,%esp
f010104e:	85 c0                	test   %eax,%eax
f0101050:	74 37                	je     f0101089 <page_lookup+0x55>
f0101052:	f6 00 01             	testb  $0x1,(%eax)
f0101055:	74 39                	je     f0101090 <page_lookup+0x5c>
			 return NULL;

	   if (pte_store)
f0101057:	85 db                	test   %ebx,%ebx
f0101059:	74 02                	je     f010105d <page_lookup+0x29>
			 *pte_store = pte_entry;
f010105b:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010105d:	8b 00                	mov    (%eax),%eax
f010105f:	c1 e8 0c             	shr    $0xc,%eax
f0101062:	3b 05 48 2c 17 f0    	cmp    0xf0172c48,%eax
f0101068:	72 14                	jb     f010107e <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010106a:	83 ec 04             	sub    $0x4,%esp
f010106d:	68 e8 52 10 f0       	push   $0xf01052e8
f0101072:	6a 4f                	push   $0x4f
f0101074:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101079:	e8 2e f0 ff ff       	call   f01000ac <_panic>
	return &pages[PGNUM(pa)];
f010107e:	8b 15 50 2c 17 f0    	mov    0xf0172c50,%edx
f0101084:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	   return pa2page(PTE_ADDR(*pte_entry));
f0101087:	eb 0c                	jmp    f0101095 <page_lookup+0x61>
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, 0);

	   if (!pte_entry || !(*pte_entry & PTE_P))
			 return NULL;
f0101089:	b8 00 00 00 00       	mov    $0x0,%eax
f010108e:	eb 05                	jmp    f0101095 <page_lookup+0x61>
f0101090:	b8 00 00 00 00       	mov    $0x0,%eax

	   if (pte_store)
			 *pte_store = pte_entry;

	   return pa2page(PTE_ADDR(*pte_entry));
}
f0101095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101098:	c9                   	leave  
f0101099:	c3                   	ret    

f010109a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
	   void
page_remove(pde_t *pgdir, void *va)
{
f010109a:	55                   	push   %ebp
f010109b:	89 e5                	mov    %esp,%ebp
f010109d:	53                   	push   %ebx
f010109e:	83 ec 18             	sub    $0x18,%esp
f01010a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	   // Fill this function in

	   pte_t* pte_address = NULL;
f01010a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	   struct PageInfo* pp = page_lookup (pgdir, va, &pte_address);
f01010ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010ae:	50                   	push   %eax
f01010af:	53                   	push   %ebx
f01010b0:	ff 75 08             	pushl  0x8(%ebp)
f01010b3:	e8 7c ff ff ff       	call   f0101034 <page_lookup>
	   if (!pp)
f01010b8:	83 c4 10             	add    $0x10,%esp
f01010bb:	85 c0                	test   %eax,%eax
f01010bd:	74 18                	je     f01010d7 <page_remove+0x3d>
			 return;

	   *pte_address = 0;
f01010bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01010c2:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	   page_decref(pp);
f01010c8:	83 ec 0c             	sub    $0xc,%esp
f01010cb:	50                   	push   %eax
f01010cc:	e8 26 fe ff ff       	call   f0100ef7 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010d1:	0f 01 3b             	invlpg (%ebx)
f01010d4:	83 c4 10             	add    $0x10,%esp
	   tlb_invalidate (pgdir, va);

}
f01010d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010da:	c9                   	leave  
f01010db:	c3                   	ret    

f01010dc <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
	   int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010dc:	55                   	push   %ebp
f01010dd:	89 e5                	mov    %esp,%ebp
f01010df:	57                   	push   %edi
f01010e0:	56                   	push   %esi
f01010e1:	53                   	push   %ebx
f01010e2:	83 ec 10             	sub    $0x10,%esp
f01010e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010e8:	8b 7d 10             	mov    0x10(%ebp),%edi
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, true);
f01010eb:	6a 01                	push   $0x1
f01010ed:	57                   	push   %edi
f01010ee:	ff 75 08             	pushl  0x8(%ebp)
f01010f1:	e8 28 fe ff ff       	call   f0100f1e <pgdir_walk>

	   if (!pte_entry) return -E_NO_MEM;
f01010f6:	83 c4 10             	add    $0x10,%esp
f01010f9:	85 c0                	test   %eax,%eax
f01010fb:	0f 84 96 00 00 00    	je     f0101197 <page_insert+0xbb>
f0101101:	89 c6                	mov    %eax,%esi

	   if (PTE_ADDR(*pte_entry) == page2pa (pp))
f0101103:	8b 10                	mov    (%eax),%edx
f0101105:	89 d1                	mov    %edx,%ecx
f0101107:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010110d:	89 d8                	mov    %ebx,%eax
f010110f:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0101115:	c1 f8 03             	sar    $0x3,%eax
f0101118:	c1 e0 0c             	shl    $0xc,%eax
f010111b:	39 c1                	cmp    %eax,%ecx
f010111d:	75 24                	jne    f0101143 <page_insert+0x67>
	   {
			 if ((*pte_entry & 0x1FF) == perm) return 0;
f010111f:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
f0101125:	b8 00 00 00 00       	mov    $0x0,%eax
f010112a:	3b 55 14             	cmp    0x14(%ebp),%edx
f010112d:	74 6d                	je     f010119c <page_insert+0xc0>

			 *pte_entry = page2pa (pp) | perm | PTE_P;
f010112f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101132:	83 c8 01             	or     $0x1,%eax
f0101135:	09 c1                	or     %eax,%ecx
f0101137:	89 0e                	mov    %ecx,(%esi)
f0101139:	0f 01 3f             	invlpg (%edi)
			 tlb_invalidate (pgdir, va);
			 return 0;
f010113c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101141:	eb 59                	jmp    f010119c <page_insert+0xc0>
	   }

	   if (*pte_entry & PTE_P)
f0101143:	f6 c2 01             	test   $0x1,%dl
f0101146:	74 2d                	je     f0101175 <page_insert+0x99>
	   {
			 page_remove (pgdir, va);
f0101148:	83 ec 08             	sub    $0x8,%esp
f010114b:	57                   	push   %edi
f010114c:	ff 75 08             	pushl  0x8(%ebp)
f010114f:	e8 46 ff ff ff       	call   f010109a <page_remove>
			 assert (*pte_entry ==0);
f0101154:	83 c4 10             	add    $0x10,%esp
f0101157:	83 3e 00             	cmpl   $0x0,(%esi)
f010115a:	74 19                	je     f0101175 <page_insert+0x99>
f010115c:	68 54 4f 10 f0       	push   $0xf0104f54
f0101161:	68 78 4e 10 f0       	push   $0xf0104e78
f0101166:	68 e9 01 00 00       	push   $0x1e9
f010116b:	68 52 4e 10 f0       	push   $0xf0104e52
f0101170:	e8 37 ef ff ff       	call   f01000ac <_panic>
	   }

	   pp -> pp_ref ++;
f0101175:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	   *pte_entry = page2pa (pp) | perm | PTE_P;
f010117a:	2b 1d 50 2c 17 f0    	sub    0xf0172c50,%ebx
f0101180:	c1 fb 03             	sar    $0x3,%ebx
f0101183:	c1 e3 0c             	shl    $0xc,%ebx
f0101186:	8b 45 14             	mov    0x14(%ebp),%eax
f0101189:	83 c8 01             	or     $0x1,%eax
f010118c:	09 c3                	or     %eax,%ebx
f010118e:	89 1e                	mov    %ebx,(%esi)
	   return 0;
f0101190:	b8 00 00 00 00       	mov    $0x0,%eax
f0101195:	eb 05                	jmp    f010119c <page_insert+0xc0>
{
	   // Fill this function in

	   pte_t* pte_entry = pgdir_walk (pgdir, va, true);

	   if (!pte_entry) return -E_NO_MEM;
f0101197:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	   }

	   pp -> pp_ref ++;
	   *pte_entry = page2pa (pp) | perm | PTE_P;
	   return 0;
}
f010119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010119f:	5b                   	pop    %ebx
f01011a0:	5e                   	pop    %esi
f01011a1:	5f                   	pop    %edi
f01011a2:	5d                   	pop    %ebp
f01011a3:	c3                   	ret    

f01011a4 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
	   void
mem_init(void)
{
f01011a4:	55                   	push   %ebp
f01011a5:	89 e5                	mov    %esp,%ebp
f01011a7:	57                   	push   %edi
f01011a8:	56                   	push   %esi
f01011a9:	53                   	push   %ebx
f01011aa:	83 ec 2c             	sub    $0x2c,%esp
{
	   size_t basemem, extmem, ext16mem, totalmem;

	   // Use CMOS calls to measure available base & extended memory.
	   // (CMOS calls return results in kilobytes.)
	   basemem = nvram_read(NVRAM_BASELO);
f01011ad:	b8 15 00 00 00       	mov    $0x15,%eax
f01011b2:	e8 8e f7 ff ff       	call   f0100945 <nvram_read>
f01011b7:	89 c3                	mov    %eax,%ebx
	   extmem = nvram_read(NVRAM_EXTLO);
f01011b9:	b8 17 00 00 00       	mov    $0x17,%eax
f01011be:	e8 82 f7 ff ff       	call   f0100945 <nvram_read>
f01011c3:	89 c6                	mov    %eax,%esi
	   ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01011c5:	b8 34 00 00 00       	mov    $0x34,%eax
f01011ca:	e8 76 f7 ff ff       	call   f0100945 <nvram_read>
f01011cf:	c1 e0 06             	shl    $0x6,%eax

	   // Calculate the number of physical pages available in both base
	   // and extended memory.
	   if (ext16mem)
f01011d2:	85 c0                	test   %eax,%eax
f01011d4:	74 07                	je     f01011dd <mem_init+0x39>
			 totalmem = 16 * 1024 + ext16mem;
f01011d6:	05 00 40 00 00       	add    $0x4000,%eax
f01011db:	eb 0b                	jmp    f01011e8 <mem_init+0x44>
	   else if (extmem)
			 totalmem = 1 * 1024 + extmem;
f01011dd:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01011e3:	85 f6                	test   %esi,%esi
f01011e5:	0f 44 c3             	cmove  %ebx,%eax
	   else
			 totalmem = basemem;

	   npages = totalmem / (PGSIZE / 1024);
f01011e8:	89 c2                	mov    %eax,%edx
f01011ea:	c1 ea 02             	shr    $0x2,%edx
f01011ed:	89 15 48 2c 17 f0    	mov    %edx,0xf0172c48
	   npages_basemem = basemem / (PGSIZE / 1024);
f01011f3:	89 da                	mov    %ebx,%edx
f01011f5:	c1 ea 02             	shr    $0x2,%edx
f01011f8:	89 15 84 1f 17 f0    	mov    %edx,0xf0171f84

	   cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011fe:	89 c2                	mov    %eax,%edx
f0101200:	29 da                	sub    %ebx,%edx
f0101202:	52                   	push   %edx
f0101203:	53                   	push   %ebx
f0101204:	50                   	push   %eax
f0101205:	68 08 53 10 f0       	push   $0xf0105308
f010120a:	e8 c2 1e 00 00       	call   f01030d1 <cprintf>
	   // Remove this line when you're ready to test this function.
	   //	panic("mem_init: This function is not finished\n");

	   //////////////////////////////////////////////////////////////////////
	   // create initial page directory.
	   kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010120f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101214:	e8 55 f7 ff ff       	call   f010096e <boot_alloc>
f0101219:	a3 4c 2c 17 f0       	mov    %eax,0xf0172c4c
	   memset(kern_pgdir, 0, PGSIZE);
f010121e:	83 c4 0c             	add    $0xc,%esp
f0101221:	68 00 10 00 00       	push   $0x1000
f0101226:	6a 00                	push   $0x0
f0101228:	50                   	push   %eax
f0101229:	e8 29 32 00 00       	call   f0104457 <memset>
	   // a virtual page table at virtual address UVPT.
	   // (For now, you don't have understand the greater purpose of the
	   // following line.)

	   // Permissions: kernel R, user R
	   kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010122e:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101233:	83 c4 10             	add    $0x10,%esp
f0101236:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010123b:	77 15                	ja     f0101252 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010123d:	50                   	push   %eax
f010123e:	68 c4 52 10 f0       	push   $0xf01052c4
f0101243:	68 98 00 00 00       	push   $0x98
f0101248:	68 52 4e 10 f0       	push   $0xf0104e52
f010124d:	e8 5a ee ff ff       	call   f01000ac <_panic>
f0101252:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101258:	83 ca 05             	or     $0x5,%edx
f010125b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	   // each physical page, there is a corresponding struct PageInfo in this
	   // array.  'npages' is the number of physical pages in memory.  Use memset
	   // to initialize all fields of each struct PageInfo to 0.
	   // Your code goes here:

	   pages = (struct PageInfo *) boot_alloc(npages * sizeof (struct PageInfo));
f0101261:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0101266:	c1 e0 03             	shl    $0x3,%eax
f0101269:	e8 00 f7 ff ff       	call   f010096e <boot_alloc>
f010126e:	a3 50 2c 17 f0       	mov    %eax,0xf0172c50
	   memset (pages, 0, npages * sizeof(struct PageInfo));
f0101273:	83 ec 04             	sub    $0x4,%esp
f0101276:	8b 3d 48 2c 17 f0    	mov    0xf0172c48,%edi
f010127c:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101283:	52                   	push   %edx
f0101284:	6a 00                	push   $0x0
f0101286:	50                   	push   %eax
f0101287:	e8 cb 31 00 00       	call   f0104457 <memset>

	   //////////////////////////////////////////////////////////////////////
	   // Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	   // LAB 3: Your code here.
	   envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f010128c:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101291:	e8 d8 f6 ff ff       	call   f010096e <boot_alloc>
f0101296:	a3 8c 1f 17 f0       	mov    %eax,0xf0171f8c
	   memset(envs, 0, NENV * sizeof(struct Env));
f010129b:	83 c4 0c             	add    $0xc,%esp
f010129e:	68 00 80 01 00       	push   $0x18000
f01012a3:	6a 00                	push   $0x0
f01012a5:	50                   	push   %eax
f01012a6:	e8 ac 31 00 00       	call   f0104457 <memset>
	   // Now that we've allocated the initial kernel data structures, we set
	   // up the list of free physical pages. Once we've done so, all further
	   // memory management will go through the page_* functions. In
	   // particular, we can now map memory using boot_map_region
	   // or page_insert
	   page_init();
f01012ab:	e8 48 fa ff ff       	call   f0100cf8 <page_init>

	   check_page_free_list(1);
f01012b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01012b5:	e8 7b f7 ff ff       	call   f0100a35 <check_page_free_list>
	   int nfree;
	   struct PageInfo *fl;
	   char *c;
	   int i;

	   if (!pages)
f01012ba:	83 c4 10             	add    $0x10,%esp
f01012bd:	83 3d 50 2c 17 f0 00 	cmpl   $0x0,0xf0172c50
f01012c4:	75 17                	jne    f01012dd <mem_init+0x139>
			 panic("'pages' is a null pointer!");
f01012c6:	83 ec 04             	sub    $0x4,%esp
f01012c9:	68 63 4f 10 f0       	push   $0xf0104f63
f01012ce:	68 bf 02 00 00       	push   $0x2bf
f01012d3:	68 52 4e 10 f0       	push   $0xf0104e52
f01012d8:	e8 cf ed ff ff       	call   f01000ac <_panic>

	   // check number of free pages
	   for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012dd:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f01012e2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012e7:	eb 05                	jmp    f01012ee <mem_init+0x14a>
			 ++nfree;
f01012e9:	83 c3 01             	add    $0x1,%ebx

	   if (!pages)
			 panic("'pages' is a null pointer!");

	   // check number of free pages
	   for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012ec:	8b 00                	mov    (%eax),%eax
f01012ee:	85 c0                	test   %eax,%eax
f01012f0:	75 f7                	jne    f01012e9 <mem_init+0x145>
			 ++nfree;

	   // should be able to allocate three pages
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f01012f2:	83 ec 0c             	sub    $0xc,%esp
f01012f5:	6a 00                	push   $0x0
f01012f7:	e8 28 fb ff ff       	call   f0100e24 <page_alloc>
f01012fc:	89 c7                	mov    %eax,%edi
f01012fe:	83 c4 10             	add    $0x10,%esp
f0101301:	85 c0                	test   %eax,%eax
f0101303:	75 19                	jne    f010131e <mem_init+0x17a>
f0101305:	68 7e 4f 10 f0       	push   $0xf0104f7e
f010130a:	68 78 4e 10 f0       	push   $0xf0104e78
f010130f:	68 c7 02 00 00       	push   $0x2c7
f0101314:	68 52 4e 10 f0       	push   $0xf0104e52
f0101319:	e8 8e ed ff ff       	call   f01000ac <_panic>
	   assert((pp1 = page_alloc(0)));
f010131e:	83 ec 0c             	sub    $0xc,%esp
f0101321:	6a 00                	push   $0x0
f0101323:	e8 fc fa ff ff       	call   f0100e24 <page_alloc>
f0101328:	89 c6                	mov    %eax,%esi
f010132a:	83 c4 10             	add    $0x10,%esp
f010132d:	85 c0                	test   %eax,%eax
f010132f:	75 19                	jne    f010134a <mem_init+0x1a6>
f0101331:	68 94 4f 10 f0       	push   $0xf0104f94
f0101336:	68 78 4e 10 f0       	push   $0xf0104e78
f010133b:	68 c8 02 00 00       	push   $0x2c8
f0101340:	68 52 4e 10 f0       	push   $0xf0104e52
f0101345:	e8 62 ed ff ff       	call   f01000ac <_panic>
	   assert((pp2 = page_alloc(0)));
f010134a:	83 ec 0c             	sub    $0xc,%esp
f010134d:	6a 00                	push   $0x0
f010134f:	e8 d0 fa ff ff       	call   f0100e24 <page_alloc>
f0101354:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101357:	83 c4 10             	add    $0x10,%esp
f010135a:	85 c0                	test   %eax,%eax
f010135c:	75 19                	jne    f0101377 <mem_init+0x1d3>
f010135e:	68 aa 4f 10 f0       	push   $0xf0104faa
f0101363:	68 78 4e 10 f0       	push   $0xf0104e78
f0101368:	68 c9 02 00 00       	push   $0x2c9
f010136d:	68 52 4e 10 f0       	push   $0xf0104e52
f0101372:	e8 35 ed ff ff       	call   f01000ac <_panic>

	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f0101377:	39 f7                	cmp    %esi,%edi
f0101379:	75 19                	jne    f0101394 <mem_init+0x1f0>
f010137b:	68 c0 4f 10 f0       	push   $0xf0104fc0
f0101380:	68 78 4e 10 f0       	push   $0xf0104e78
f0101385:	68 cc 02 00 00       	push   $0x2cc
f010138a:	68 52 4e 10 f0       	push   $0xf0104e52
f010138f:	e8 18 ed ff ff       	call   f01000ac <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101394:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101397:	39 c6                	cmp    %eax,%esi
f0101399:	74 04                	je     f010139f <mem_init+0x1fb>
f010139b:	39 c7                	cmp    %eax,%edi
f010139d:	75 19                	jne    f01013b8 <mem_init+0x214>
f010139f:	68 44 53 10 f0       	push   $0xf0105344
f01013a4:	68 78 4e 10 f0       	push   $0xf0104e78
f01013a9:	68 cd 02 00 00       	push   $0x2cd
f01013ae:	68 52 4e 10 f0       	push   $0xf0104e52
f01013b3:	e8 f4 ec ff ff       	call   f01000ac <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013b8:	8b 0d 50 2c 17 f0    	mov    0xf0172c50,%ecx
	   assert(page2pa(pp0) < npages*PGSIZE);
f01013be:	8b 15 48 2c 17 f0    	mov    0xf0172c48,%edx
f01013c4:	c1 e2 0c             	shl    $0xc,%edx
f01013c7:	89 f8                	mov    %edi,%eax
f01013c9:	29 c8                	sub    %ecx,%eax
f01013cb:	c1 f8 03             	sar    $0x3,%eax
f01013ce:	c1 e0 0c             	shl    $0xc,%eax
f01013d1:	39 d0                	cmp    %edx,%eax
f01013d3:	72 19                	jb     f01013ee <mem_init+0x24a>
f01013d5:	68 d2 4f 10 f0       	push   $0xf0104fd2
f01013da:	68 78 4e 10 f0       	push   $0xf0104e78
f01013df:	68 ce 02 00 00       	push   $0x2ce
f01013e4:	68 52 4e 10 f0       	push   $0xf0104e52
f01013e9:	e8 be ec ff ff       	call   f01000ac <_panic>
	   assert(page2pa(pp1) < npages*PGSIZE);
f01013ee:	89 f0                	mov    %esi,%eax
f01013f0:	29 c8                	sub    %ecx,%eax
f01013f2:	c1 f8 03             	sar    $0x3,%eax
f01013f5:	c1 e0 0c             	shl    $0xc,%eax
f01013f8:	39 c2                	cmp    %eax,%edx
f01013fa:	77 19                	ja     f0101415 <mem_init+0x271>
f01013fc:	68 ef 4f 10 f0       	push   $0xf0104fef
f0101401:	68 78 4e 10 f0       	push   $0xf0104e78
f0101406:	68 cf 02 00 00       	push   $0x2cf
f010140b:	68 52 4e 10 f0       	push   $0xf0104e52
f0101410:	e8 97 ec ff ff       	call   f01000ac <_panic>
	   assert(page2pa(pp2) < npages*PGSIZE);
f0101415:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101418:	29 c8                	sub    %ecx,%eax
f010141a:	c1 f8 03             	sar    $0x3,%eax
f010141d:	c1 e0 0c             	shl    $0xc,%eax
f0101420:	39 c2                	cmp    %eax,%edx
f0101422:	77 19                	ja     f010143d <mem_init+0x299>
f0101424:	68 0c 50 10 f0       	push   $0xf010500c
f0101429:	68 78 4e 10 f0       	push   $0xf0104e78
f010142e:	68 d0 02 00 00       	push   $0x2d0
f0101433:	68 52 4e 10 f0       	push   $0xf0104e52
f0101438:	e8 6f ec ff ff       	call   f01000ac <_panic>

	   // temporarily steal the rest of the free pages
	   fl = page_free_list;
f010143d:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f0101442:	89 45 d0             	mov    %eax,-0x30(%ebp)
	   page_free_list = 0;
f0101445:	c7 05 80 1f 17 f0 00 	movl   $0x0,0xf0171f80
f010144c:	00 00 00 

	   // should be no free memory
	   assert(!page_alloc(0));
f010144f:	83 ec 0c             	sub    $0xc,%esp
f0101452:	6a 00                	push   $0x0
f0101454:	e8 cb f9 ff ff       	call   f0100e24 <page_alloc>
f0101459:	83 c4 10             	add    $0x10,%esp
f010145c:	85 c0                	test   %eax,%eax
f010145e:	74 19                	je     f0101479 <mem_init+0x2d5>
f0101460:	68 29 50 10 f0       	push   $0xf0105029
f0101465:	68 78 4e 10 f0       	push   $0xf0104e78
f010146a:	68 d7 02 00 00       	push   $0x2d7
f010146f:	68 52 4e 10 f0       	push   $0xf0104e52
f0101474:	e8 33 ec ff ff       	call   f01000ac <_panic>

	   // free and re-allocate?
	   page_free(pp0);
f0101479:	83 ec 0c             	sub    $0xc,%esp
f010147c:	57                   	push   %edi
f010147d:	e8 19 fa ff ff       	call   f0100e9b <page_free>
	   page_free(pp1);
f0101482:	89 34 24             	mov    %esi,(%esp)
f0101485:	e8 11 fa ff ff       	call   f0100e9b <page_free>
	   page_free(pp2);
f010148a:	83 c4 04             	add    $0x4,%esp
f010148d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101490:	e8 06 fa ff ff       	call   f0100e9b <page_free>
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f0101495:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010149c:	e8 83 f9 ff ff       	call   f0100e24 <page_alloc>
f01014a1:	89 c6                	mov    %eax,%esi
f01014a3:	83 c4 10             	add    $0x10,%esp
f01014a6:	85 c0                	test   %eax,%eax
f01014a8:	75 19                	jne    f01014c3 <mem_init+0x31f>
f01014aa:	68 7e 4f 10 f0       	push   $0xf0104f7e
f01014af:	68 78 4e 10 f0       	push   $0xf0104e78
f01014b4:	68 de 02 00 00       	push   $0x2de
f01014b9:	68 52 4e 10 f0       	push   $0xf0104e52
f01014be:	e8 e9 eb ff ff       	call   f01000ac <_panic>
	   assert((pp1 = page_alloc(0)));
f01014c3:	83 ec 0c             	sub    $0xc,%esp
f01014c6:	6a 00                	push   $0x0
f01014c8:	e8 57 f9 ff ff       	call   f0100e24 <page_alloc>
f01014cd:	89 c7                	mov    %eax,%edi
f01014cf:	83 c4 10             	add    $0x10,%esp
f01014d2:	85 c0                	test   %eax,%eax
f01014d4:	75 19                	jne    f01014ef <mem_init+0x34b>
f01014d6:	68 94 4f 10 f0       	push   $0xf0104f94
f01014db:	68 78 4e 10 f0       	push   $0xf0104e78
f01014e0:	68 df 02 00 00       	push   $0x2df
f01014e5:	68 52 4e 10 f0       	push   $0xf0104e52
f01014ea:	e8 bd eb ff ff       	call   f01000ac <_panic>
	   assert((pp2 = page_alloc(0)));
f01014ef:	83 ec 0c             	sub    $0xc,%esp
f01014f2:	6a 00                	push   $0x0
f01014f4:	e8 2b f9 ff ff       	call   f0100e24 <page_alloc>
f01014f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014fc:	83 c4 10             	add    $0x10,%esp
f01014ff:	85 c0                	test   %eax,%eax
f0101501:	75 19                	jne    f010151c <mem_init+0x378>
f0101503:	68 aa 4f 10 f0       	push   $0xf0104faa
f0101508:	68 78 4e 10 f0       	push   $0xf0104e78
f010150d:	68 e0 02 00 00       	push   $0x2e0
f0101512:	68 52 4e 10 f0       	push   $0xf0104e52
f0101517:	e8 90 eb ff ff       	call   f01000ac <_panic>
	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f010151c:	39 fe                	cmp    %edi,%esi
f010151e:	75 19                	jne    f0101539 <mem_init+0x395>
f0101520:	68 c0 4f 10 f0       	push   $0xf0104fc0
f0101525:	68 78 4e 10 f0       	push   $0xf0104e78
f010152a:	68 e2 02 00 00       	push   $0x2e2
f010152f:	68 52 4e 10 f0       	push   $0xf0104e52
f0101534:	e8 73 eb ff ff       	call   f01000ac <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101539:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010153c:	39 c7                	cmp    %eax,%edi
f010153e:	74 04                	je     f0101544 <mem_init+0x3a0>
f0101540:	39 c6                	cmp    %eax,%esi
f0101542:	75 19                	jne    f010155d <mem_init+0x3b9>
f0101544:	68 44 53 10 f0       	push   $0xf0105344
f0101549:	68 78 4e 10 f0       	push   $0xf0104e78
f010154e:	68 e3 02 00 00       	push   $0x2e3
f0101553:	68 52 4e 10 f0       	push   $0xf0104e52
f0101558:	e8 4f eb ff ff       	call   f01000ac <_panic>
	   assert(!page_alloc(0));
f010155d:	83 ec 0c             	sub    $0xc,%esp
f0101560:	6a 00                	push   $0x0
f0101562:	e8 bd f8 ff ff       	call   f0100e24 <page_alloc>
f0101567:	83 c4 10             	add    $0x10,%esp
f010156a:	85 c0                	test   %eax,%eax
f010156c:	74 19                	je     f0101587 <mem_init+0x3e3>
f010156e:	68 29 50 10 f0       	push   $0xf0105029
f0101573:	68 78 4e 10 f0       	push   $0xf0104e78
f0101578:	68 e4 02 00 00       	push   $0x2e4
f010157d:	68 52 4e 10 f0       	push   $0xf0104e52
f0101582:	e8 25 eb ff ff       	call   f01000ac <_panic>
f0101587:	89 f0                	mov    %esi,%eax
f0101589:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f010158f:	c1 f8 03             	sar    $0x3,%eax
f0101592:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101595:	89 c2                	mov    %eax,%edx
f0101597:	c1 ea 0c             	shr    $0xc,%edx
f010159a:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f01015a0:	72 12                	jb     f01015b4 <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015a2:	50                   	push   %eax
f01015a3:	68 b8 51 10 f0       	push   $0xf01051b8
f01015a8:	6a 56                	push   $0x56
f01015aa:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01015af:	e8 f8 ea ff ff       	call   f01000ac <_panic>

	   // test flags
	   memset(page2kva(pp0), 1, PGSIZE);
f01015b4:	83 ec 04             	sub    $0x4,%esp
f01015b7:	68 00 10 00 00       	push   $0x1000
f01015bc:	6a 01                	push   $0x1
f01015be:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015c3:	50                   	push   %eax
f01015c4:	e8 8e 2e 00 00       	call   f0104457 <memset>
	   page_free(pp0);
f01015c9:	89 34 24             	mov    %esi,(%esp)
f01015cc:	e8 ca f8 ff ff       	call   f0100e9b <page_free>
	   assert((pp = page_alloc(ALLOC_ZERO)));
f01015d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015d8:	e8 47 f8 ff ff       	call   f0100e24 <page_alloc>
f01015dd:	83 c4 10             	add    $0x10,%esp
f01015e0:	85 c0                	test   %eax,%eax
f01015e2:	75 19                	jne    f01015fd <mem_init+0x459>
f01015e4:	68 38 50 10 f0       	push   $0xf0105038
f01015e9:	68 78 4e 10 f0       	push   $0xf0104e78
f01015ee:	68 e9 02 00 00       	push   $0x2e9
f01015f3:	68 52 4e 10 f0       	push   $0xf0104e52
f01015f8:	e8 af ea ff ff       	call   f01000ac <_panic>
	   assert(pp && pp0 == pp);
f01015fd:	39 c6                	cmp    %eax,%esi
f01015ff:	74 19                	je     f010161a <mem_init+0x476>
f0101601:	68 56 50 10 f0       	push   $0xf0105056
f0101606:	68 78 4e 10 f0       	push   $0xf0104e78
f010160b:	68 ea 02 00 00       	push   $0x2ea
f0101610:	68 52 4e 10 f0       	push   $0xf0104e52
f0101615:	e8 92 ea ff ff       	call   f01000ac <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010161a:	89 f0                	mov    %esi,%eax
f010161c:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0101622:	c1 f8 03             	sar    $0x3,%eax
f0101625:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101628:	89 c2                	mov    %eax,%edx
f010162a:	c1 ea 0c             	shr    $0xc,%edx
f010162d:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f0101633:	72 12                	jb     f0101647 <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101635:	50                   	push   %eax
f0101636:	68 b8 51 10 f0       	push   $0xf01051b8
f010163b:	6a 56                	push   $0x56
f010163d:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0101642:	e8 65 ea ff ff       	call   f01000ac <_panic>
f0101647:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010164d:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	   c = page2kva(pp);
	   for (i = 0; i < PGSIZE; i++)
			 assert(c[i] == 0);
f0101653:	80 38 00             	cmpb   $0x0,(%eax)
f0101656:	74 19                	je     f0101671 <mem_init+0x4cd>
f0101658:	68 66 50 10 f0       	push   $0xf0105066
f010165d:	68 78 4e 10 f0       	push   $0xf0104e78
f0101662:	68 ed 02 00 00       	push   $0x2ed
f0101667:	68 52 4e 10 f0       	push   $0xf0104e52
f010166c:	e8 3b ea ff ff       	call   f01000ac <_panic>
f0101671:	83 c0 01             	add    $0x1,%eax
	   memset(page2kva(pp0), 1, PGSIZE);
	   page_free(pp0);
	   assert((pp = page_alloc(ALLOC_ZERO)));
	   assert(pp && pp0 == pp);
	   c = page2kva(pp);
	   for (i = 0; i < PGSIZE; i++)
f0101674:	39 d0                	cmp    %edx,%eax
f0101676:	75 db                	jne    f0101653 <mem_init+0x4af>
			 assert(c[i] == 0);

	   // give free list back
	   page_free_list = fl;
f0101678:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010167b:	a3 80 1f 17 f0       	mov    %eax,0xf0171f80

	   // free the pages we took
	   page_free(pp0);
f0101680:	83 ec 0c             	sub    $0xc,%esp
f0101683:	56                   	push   %esi
f0101684:	e8 12 f8 ff ff       	call   f0100e9b <page_free>
	   page_free(pp1);
f0101689:	89 3c 24             	mov    %edi,(%esp)
f010168c:	e8 0a f8 ff ff       	call   f0100e9b <page_free>
	   page_free(pp2);
f0101691:	83 c4 04             	add    $0x4,%esp
f0101694:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101697:	e8 ff f7 ff ff       	call   f0100e9b <page_free>

	   // number of free pages should be the same
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f010169c:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f01016a1:	83 c4 10             	add    $0x10,%esp
f01016a4:	eb 05                	jmp    f01016ab <mem_init+0x507>
			 --nfree;
f01016a6:	83 eb 01             	sub    $0x1,%ebx
	   page_free(pp0);
	   page_free(pp1);
	   page_free(pp2);

	   // number of free pages should be the same
	   for (pp = page_free_list; pp; pp = pp->pp_link)
f01016a9:	8b 00                	mov    (%eax),%eax
f01016ab:	85 c0                	test   %eax,%eax
f01016ad:	75 f7                	jne    f01016a6 <mem_init+0x502>
			 --nfree;
	   assert(nfree == 0);
f01016af:	85 db                	test   %ebx,%ebx
f01016b1:	74 19                	je     f01016cc <mem_init+0x528>
f01016b3:	68 70 50 10 f0       	push   $0xf0105070
f01016b8:	68 78 4e 10 f0       	push   $0xf0104e78
f01016bd:	68 fa 02 00 00       	push   $0x2fa
f01016c2:	68 52 4e 10 f0       	push   $0xf0104e52
f01016c7:	e8 e0 e9 ff ff       	call   f01000ac <_panic>

	   cprintf("check_page_alloc() succeeded!\n");
f01016cc:	83 ec 0c             	sub    $0xc,%esp
f01016cf:	68 64 53 10 f0       	push   $0xf0105364
f01016d4:	e8 f8 19 00 00       	call   f01030d1 <cprintf>
	   int i;
	   extern pde_t entry_pgdir[];

	   // should be able to allocate three pages
	   pp0 = pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f01016d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016e0:	e8 3f f7 ff ff       	call   f0100e24 <page_alloc>
f01016e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016e8:	83 c4 10             	add    $0x10,%esp
f01016eb:	85 c0                	test   %eax,%eax
f01016ed:	75 19                	jne    f0101708 <mem_init+0x564>
f01016ef:	68 7e 4f 10 f0       	push   $0xf0104f7e
f01016f4:	68 78 4e 10 f0       	push   $0xf0104e78
f01016f9:	68 58 03 00 00       	push   $0x358
f01016fe:	68 52 4e 10 f0       	push   $0xf0104e52
f0101703:	e8 a4 e9 ff ff       	call   f01000ac <_panic>
	   assert((pp1 = page_alloc(0)));
f0101708:	83 ec 0c             	sub    $0xc,%esp
f010170b:	6a 00                	push   $0x0
f010170d:	e8 12 f7 ff ff       	call   f0100e24 <page_alloc>
f0101712:	89 c3                	mov    %eax,%ebx
f0101714:	83 c4 10             	add    $0x10,%esp
f0101717:	85 c0                	test   %eax,%eax
f0101719:	75 19                	jne    f0101734 <mem_init+0x590>
f010171b:	68 94 4f 10 f0       	push   $0xf0104f94
f0101720:	68 78 4e 10 f0       	push   $0xf0104e78
f0101725:	68 59 03 00 00       	push   $0x359
f010172a:	68 52 4e 10 f0       	push   $0xf0104e52
f010172f:	e8 78 e9 ff ff       	call   f01000ac <_panic>
	   assert((pp2 = page_alloc(0)));
f0101734:	83 ec 0c             	sub    $0xc,%esp
f0101737:	6a 00                	push   $0x0
f0101739:	e8 e6 f6 ff ff       	call   f0100e24 <page_alloc>
f010173e:	89 c6                	mov    %eax,%esi
f0101740:	83 c4 10             	add    $0x10,%esp
f0101743:	85 c0                	test   %eax,%eax
f0101745:	75 19                	jne    f0101760 <mem_init+0x5bc>
f0101747:	68 aa 4f 10 f0       	push   $0xf0104faa
f010174c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101751:	68 5a 03 00 00       	push   $0x35a
f0101756:	68 52 4e 10 f0       	push   $0xf0104e52
f010175b:	e8 4c e9 ff ff       	call   f01000ac <_panic>

	   assert(pp0);
	   assert(pp1 && pp1 != pp0);
f0101760:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101763:	75 19                	jne    f010177e <mem_init+0x5da>
f0101765:	68 c0 4f 10 f0       	push   $0xf0104fc0
f010176a:	68 78 4e 10 f0       	push   $0xf0104e78
f010176f:	68 5d 03 00 00       	push   $0x35d
f0101774:	68 52 4e 10 f0       	push   $0xf0104e52
f0101779:	e8 2e e9 ff ff       	call   f01000ac <_panic>
	   assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177e:	39 c3                	cmp    %eax,%ebx
f0101780:	74 05                	je     f0101787 <mem_init+0x5e3>
f0101782:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101785:	75 19                	jne    f01017a0 <mem_init+0x5fc>
f0101787:	68 44 53 10 f0       	push   $0xf0105344
f010178c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101791:	68 5e 03 00 00       	push   $0x35e
f0101796:	68 52 4e 10 f0       	push   $0xf0104e52
f010179b:	e8 0c e9 ff ff       	call   f01000ac <_panic>

	   // temporarily steal the rest of the free pages
	   fl = page_free_list;
f01017a0:	a1 80 1f 17 f0       	mov    0xf0171f80,%eax
f01017a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	   page_free_list = 0;
f01017a8:	c7 05 80 1f 17 f0 00 	movl   $0x0,0xf0171f80
f01017af:	00 00 00 

	   // should be no free memory
	   assert(!page_alloc(0));
f01017b2:	83 ec 0c             	sub    $0xc,%esp
f01017b5:	6a 00                	push   $0x0
f01017b7:	e8 68 f6 ff ff       	call   f0100e24 <page_alloc>
f01017bc:	83 c4 10             	add    $0x10,%esp
f01017bf:	85 c0                	test   %eax,%eax
f01017c1:	74 19                	je     f01017dc <mem_init+0x638>
f01017c3:	68 29 50 10 f0       	push   $0xf0105029
f01017c8:	68 78 4e 10 f0       	push   $0xf0104e78
f01017cd:	68 65 03 00 00       	push   $0x365
f01017d2:	68 52 4e 10 f0       	push   $0xf0104e52
f01017d7:	e8 d0 e8 ff ff       	call   f01000ac <_panic>

	   // there is no page allocated at address 0
	   assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01017dc:	83 ec 04             	sub    $0x4,%esp
f01017df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017e2:	50                   	push   %eax
f01017e3:	6a 00                	push   $0x0
f01017e5:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f01017eb:	e8 44 f8 ff ff       	call   f0101034 <page_lookup>
f01017f0:	83 c4 10             	add    $0x10,%esp
f01017f3:	85 c0                	test   %eax,%eax
f01017f5:	74 19                	je     f0101810 <mem_init+0x66c>
f01017f7:	68 84 53 10 f0       	push   $0xf0105384
f01017fc:	68 78 4e 10 f0       	push   $0xf0104e78
f0101801:	68 68 03 00 00       	push   $0x368
f0101806:	68 52 4e 10 f0       	push   $0xf0104e52
f010180b:	e8 9c e8 ff ff       	call   f01000ac <_panic>

	   // there is no free memory, so we can't allocate a page table
	   assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101810:	6a 02                	push   $0x2
f0101812:	6a 00                	push   $0x0
f0101814:	53                   	push   %ebx
f0101815:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f010181b:	e8 bc f8 ff ff       	call   f01010dc <page_insert>
f0101820:	83 c4 10             	add    $0x10,%esp
f0101823:	85 c0                	test   %eax,%eax
f0101825:	78 19                	js     f0101840 <mem_init+0x69c>
f0101827:	68 bc 53 10 f0       	push   $0xf01053bc
f010182c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101831:	68 6b 03 00 00       	push   $0x36b
f0101836:	68 52 4e 10 f0       	push   $0xf0104e52
f010183b:	e8 6c e8 ff ff       	call   f01000ac <_panic>

	   // free pp0 and try again: pp0 should be used for page table
	   page_free(pp0);
f0101840:	83 ec 0c             	sub    $0xc,%esp
f0101843:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101846:	e8 50 f6 ff ff       	call   f0100e9b <page_free>
	   assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010184b:	6a 02                	push   $0x2
f010184d:	6a 00                	push   $0x0
f010184f:	53                   	push   %ebx
f0101850:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101856:	e8 81 f8 ff ff       	call   f01010dc <page_insert>
f010185b:	83 c4 20             	add    $0x20,%esp
f010185e:	85 c0                	test   %eax,%eax
f0101860:	74 19                	je     f010187b <mem_init+0x6d7>
f0101862:	68 ec 53 10 f0       	push   $0xf01053ec
f0101867:	68 78 4e 10 f0       	push   $0xf0104e78
f010186c:	68 6f 03 00 00       	push   $0x36f
f0101871:	68 52 4e 10 f0       	push   $0xf0104e52
f0101876:	e8 31 e8 ff ff       	call   f01000ac <_panic>
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010187b:	8b 3d 4c 2c 17 f0    	mov    0xf0172c4c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101881:	a1 50 2c 17 f0       	mov    0xf0172c50,%eax
f0101886:	89 c1                	mov    %eax,%ecx
f0101888:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010188b:	8b 17                	mov    (%edi),%edx
f010188d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101893:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101896:	29 c8                	sub    %ecx,%eax
f0101898:	c1 f8 03             	sar    $0x3,%eax
f010189b:	c1 e0 0c             	shl    $0xc,%eax
f010189e:	39 c2                	cmp    %eax,%edx
f01018a0:	74 19                	je     f01018bb <mem_init+0x717>
f01018a2:	68 1c 54 10 f0       	push   $0xf010541c
f01018a7:	68 78 4e 10 f0       	push   $0xf0104e78
f01018ac:	68 70 03 00 00       	push   $0x370
f01018b1:	68 52 4e 10 f0       	push   $0xf0104e52
f01018b6:	e8 f1 e7 ff ff       	call   f01000ac <_panic>
	   assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01018c0:	89 f8                	mov    %edi,%eax
f01018c2:	e8 0a f1 ff ff       	call   f01009d1 <check_va2pa>
f01018c7:	89 da                	mov    %ebx,%edx
f01018c9:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01018cc:	c1 fa 03             	sar    $0x3,%edx
f01018cf:	c1 e2 0c             	shl    $0xc,%edx
f01018d2:	39 d0                	cmp    %edx,%eax
f01018d4:	74 19                	je     f01018ef <mem_init+0x74b>
f01018d6:	68 44 54 10 f0       	push   $0xf0105444
f01018db:	68 78 4e 10 f0       	push   $0xf0104e78
f01018e0:	68 71 03 00 00       	push   $0x371
f01018e5:	68 52 4e 10 f0       	push   $0xf0104e52
f01018ea:	e8 bd e7 ff ff       	call   f01000ac <_panic>
	   assert(pp1->pp_ref == 1);
f01018ef:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018f4:	74 19                	je     f010190f <mem_init+0x76b>
f01018f6:	68 7b 50 10 f0       	push   $0xf010507b
f01018fb:	68 78 4e 10 f0       	push   $0xf0104e78
f0101900:	68 72 03 00 00       	push   $0x372
f0101905:	68 52 4e 10 f0       	push   $0xf0104e52
f010190a:	e8 9d e7 ff ff       	call   f01000ac <_panic>
	   assert(pp0->pp_ref == 1);
f010190f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101912:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101917:	74 19                	je     f0101932 <mem_init+0x78e>
f0101919:	68 8c 50 10 f0       	push   $0xf010508c
f010191e:	68 78 4e 10 f0       	push   $0xf0104e78
f0101923:	68 73 03 00 00       	push   $0x373
f0101928:	68 52 4e 10 f0       	push   $0xf0104e52
f010192d:	e8 7a e7 ff ff       	call   f01000ac <_panic>

	   // should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101932:	6a 02                	push   $0x2
f0101934:	68 00 10 00 00       	push   $0x1000
f0101939:	56                   	push   %esi
f010193a:	57                   	push   %edi
f010193b:	e8 9c f7 ff ff       	call   f01010dc <page_insert>
f0101940:	83 c4 10             	add    $0x10,%esp
f0101943:	85 c0                	test   %eax,%eax
f0101945:	74 19                	je     f0101960 <mem_init+0x7bc>
f0101947:	68 74 54 10 f0       	push   $0xf0105474
f010194c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101951:	68 76 03 00 00       	push   $0x376
f0101956:	68 52 4e 10 f0       	push   $0xf0104e52
f010195b:	e8 4c e7 ff ff       	call   f01000ac <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101960:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101965:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f010196a:	e8 62 f0 ff ff       	call   f01009d1 <check_va2pa>
f010196f:	89 f2                	mov    %esi,%edx
f0101971:	2b 15 50 2c 17 f0    	sub    0xf0172c50,%edx
f0101977:	c1 fa 03             	sar    $0x3,%edx
f010197a:	c1 e2 0c             	shl    $0xc,%edx
f010197d:	39 d0                	cmp    %edx,%eax
f010197f:	74 19                	je     f010199a <mem_init+0x7f6>
f0101981:	68 b0 54 10 f0       	push   $0xf01054b0
f0101986:	68 78 4e 10 f0       	push   $0xf0104e78
f010198b:	68 77 03 00 00       	push   $0x377
f0101990:	68 52 4e 10 f0       	push   $0xf0104e52
f0101995:	e8 12 e7 ff ff       	call   f01000ac <_panic>
	   assert(pp2->pp_ref == 1);
f010199a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010199f:	74 19                	je     f01019ba <mem_init+0x816>
f01019a1:	68 9d 50 10 f0       	push   $0xf010509d
f01019a6:	68 78 4e 10 f0       	push   $0xf0104e78
f01019ab:	68 78 03 00 00       	push   $0x378
f01019b0:	68 52 4e 10 f0       	push   $0xf0104e52
f01019b5:	e8 f2 e6 ff ff       	call   f01000ac <_panic>

	   // should be no free memory
	   assert(!page_alloc(0));
f01019ba:	83 ec 0c             	sub    $0xc,%esp
f01019bd:	6a 00                	push   $0x0
f01019bf:	e8 60 f4 ff ff       	call   f0100e24 <page_alloc>
f01019c4:	83 c4 10             	add    $0x10,%esp
f01019c7:	85 c0                	test   %eax,%eax
f01019c9:	74 19                	je     f01019e4 <mem_init+0x840>
f01019cb:	68 29 50 10 f0       	push   $0xf0105029
f01019d0:	68 78 4e 10 f0       	push   $0xf0104e78
f01019d5:	68 7b 03 00 00       	push   $0x37b
f01019da:	68 52 4e 10 f0       	push   $0xf0104e52
f01019df:	e8 c8 e6 ff ff       	call   f01000ac <_panic>

	   // should be able to map pp2 at PGSIZE because it's already there
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019e4:	6a 02                	push   $0x2
f01019e6:	68 00 10 00 00       	push   $0x1000
f01019eb:	56                   	push   %esi
f01019ec:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f01019f2:	e8 e5 f6 ff ff       	call   f01010dc <page_insert>
f01019f7:	83 c4 10             	add    $0x10,%esp
f01019fa:	85 c0                	test   %eax,%eax
f01019fc:	74 19                	je     f0101a17 <mem_init+0x873>
f01019fe:	68 74 54 10 f0       	push   $0xf0105474
f0101a03:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a08:	68 7e 03 00 00       	push   $0x37e
f0101a0d:	68 52 4e 10 f0       	push   $0xf0104e52
f0101a12:	e8 95 e6 ff ff       	call   f01000ac <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a17:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a1c:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f0101a21:	e8 ab ef ff ff       	call   f01009d1 <check_va2pa>
f0101a26:	89 f2                	mov    %esi,%edx
f0101a28:	2b 15 50 2c 17 f0    	sub    0xf0172c50,%edx
f0101a2e:	c1 fa 03             	sar    $0x3,%edx
f0101a31:	c1 e2 0c             	shl    $0xc,%edx
f0101a34:	39 d0                	cmp    %edx,%eax
f0101a36:	74 19                	je     f0101a51 <mem_init+0x8ad>
f0101a38:	68 b0 54 10 f0       	push   $0xf01054b0
f0101a3d:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a42:	68 7f 03 00 00       	push   $0x37f
f0101a47:	68 52 4e 10 f0       	push   $0xf0104e52
f0101a4c:	e8 5b e6 ff ff       	call   f01000ac <_panic>
	   assert(pp2->pp_ref == 1);
f0101a51:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a56:	74 19                	je     f0101a71 <mem_init+0x8cd>
f0101a58:	68 9d 50 10 f0       	push   $0xf010509d
f0101a5d:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a62:	68 80 03 00 00       	push   $0x380
f0101a67:	68 52 4e 10 f0       	push   $0xf0104e52
f0101a6c:	e8 3b e6 ff ff       	call   f01000ac <_panic>

	   // pp2 should NOT be on the free list
	   // could happen in ref counts are handled sloppily in page_insert
	   assert(!page_alloc(0));
f0101a71:	83 ec 0c             	sub    $0xc,%esp
f0101a74:	6a 00                	push   $0x0
f0101a76:	e8 a9 f3 ff ff       	call   f0100e24 <page_alloc>
f0101a7b:	83 c4 10             	add    $0x10,%esp
f0101a7e:	85 c0                	test   %eax,%eax
f0101a80:	74 19                	je     f0101a9b <mem_init+0x8f7>
f0101a82:	68 29 50 10 f0       	push   $0xf0105029
f0101a87:	68 78 4e 10 f0       	push   $0xf0104e78
f0101a8c:	68 84 03 00 00       	push   $0x384
f0101a91:	68 52 4e 10 f0       	push   $0xf0104e52
f0101a96:	e8 11 e6 ff ff       	call   f01000ac <_panic>

	   // check that pgdir_walk returns a pointer to the pte
	   ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a9b:	8b 15 4c 2c 17 f0    	mov    0xf0172c4c,%edx
f0101aa1:	8b 02                	mov    (%edx),%eax
f0101aa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101aa8:	89 c1                	mov    %eax,%ecx
f0101aaa:	c1 e9 0c             	shr    $0xc,%ecx
f0101aad:	3b 0d 48 2c 17 f0    	cmp    0xf0172c48,%ecx
f0101ab3:	72 15                	jb     f0101aca <mem_init+0x926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ab5:	50                   	push   %eax
f0101ab6:	68 b8 51 10 f0       	push   $0xf01051b8
f0101abb:	68 87 03 00 00       	push   $0x387
f0101ac0:	68 52 4e 10 f0       	push   $0xf0104e52
f0101ac5:	e8 e2 e5 ff ff       	call   f01000ac <_panic>
f0101aca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101acf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ad2:	83 ec 04             	sub    $0x4,%esp
f0101ad5:	6a 00                	push   $0x0
f0101ad7:	68 00 10 00 00       	push   $0x1000
f0101adc:	52                   	push   %edx
f0101add:	e8 3c f4 ff ff       	call   f0100f1e <pgdir_walk>
f0101ae2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101ae5:	8d 57 04             	lea    0x4(%edi),%edx
f0101ae8:	83 c4 10             	add    $0x10,%esp
f0101aeb:	39 d0                	cmp    %edx,%eax
f0101aed:	74 19                	je     f0101b08 <mem_init+0x964>
f0101aef:	68 e0 54 10 f0       	push   $0xf01054e0
f0101af4:	68 78 4e 10 f0       	push   $0xf0104e78
f0101af9:	68 88 03 00 00       	push   $0x388
f0101afe:	68 52 4e 10 f0       	push   $0xf0104e52
f0101b03:	e8 a4 e5 ff ff       	call   f01000ac <_panic>

	   // should be able to change permissions too.
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b08:	6a 06                	push   $0x6
f0101b0a:	68 00 10 00 00       	push   $0x1000
f0101b0f:	56                   	push   %esi
f0101b10:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101b16:	e8 c1 f5 ff ff       	call   f01010dc <page_insert>
f0101b1b:	83 c4 10             	add    $0x10,%esp
f0101b1e:	85 c0                	test   %eax,%eax
f0101b20:	74 19                	je     f0101b3b <mem_init+0x997>
f0101b22:	68 20 55 10 f0       	push   $0xf0105520
f0101b27:	68 78 4e 10 f0       	push   $0xf0104e78
f0101b2c:	68 8b 03 00 00       	push   $0x38b
f0101b31:	68 52 4e 10 f0       	push   $0xf0104e52
f0101b36:	e8 71 e5 ff ff       	call   f01000ac <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b3b:	8b 3d 4c 2c 17 f0    	mov    0xf0172c4c,%edi
f0101b41:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b46:	89 f8                	mov    %edi,%eax
f0101b48:	e8 84 ee ff ff       	call   f01009d1 <check_va2pa>
f0101b4d:	89 f2                	mov    %esi,%edx
f0101b4f:	2b 15 50 2c 17 f0    	sub    0xf0172c50,%edx
f0101b55:	c1 fa 03             	sar    $0x3,%edx
f0101b58:	c1 e2 0c             	shl    $0xc,%edx
f0101b5b:	39 d0                	cmp    %edx,%eax
f0101b5d:	74 19                	je     f0101b78 <mem_init+0x9d4>
f0101b5f:	68 b0 54 10 f0       	push   $0xf01054b0
f0101b64:	68 78 4e 10 f0       	push   $0xf0104e78
f0101b69:	68 8c 03 00 00       	push   $0x38c
f0101b6e:	68 52 4e 10 f0       	push   $0xf0104e52
f0101b73:	e8 34 e5 ff ff       	call   f01000ac <_panic>
	   assert(pp2->pp_ref == 1);
f0101b78:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b7d:	74 19                	je     f0101b98 <mem_init+0x9f4>
f0101b7f:	68 9d 50 10 f0       	push   $0xf010509d
f0101b84:	68 78 4e 10 f0       	push   $0xf0104e78
f0101b89:	68 8d 03 00 00       	push   $0x38d
f0101b8e:	68 52 4e 10 f0       	push   $0xf0104e52
f0101b93:	e8 14 e5 ff ff       	call   f01000ac <_panic>
	   assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b98:	83 ec 04             	sub    $0x4,%esp
f0101b9b:	6a 00                	push   $0x0
f0101b9d:	68 00 10 00 00       	push   $0x1000
f0101ba2:	57                   	push   %edi
f0101ba3:	e8 76 f3 ff ff       	call   f0100f1e <pgdir_walk>
f0101ba8:	83 c4 10             	add    $0x10,%esp
f0101bab:	f6 00 04             	testb  $0x4,(%eax)
f0101bae:	75 19                	jne    f0101bc9 <mem_init+0xa25>
f0101bb0:	68 60 55 10 f0       	push   $0xf0105560
f0101bb5:	68 78 4e 10 f0       	push   $0xf0104e78
f0101bba:	68 8e 03 00 00       	push   $0x38e
f0101bbf:	68 52 4e 10 f0       	push   $0xf0104e52
f0101bc4:	e8 e3 e4 ff ff       	call   f01000ac <_panic>
	   assert(kern_pgdir[0] & PTE_U);
f0101bc9:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f0101bce:	f6 00 04             	testb  $0x4,(%eax)
f0101bd1:	75 19                	jne    f0101bec <mem_init+0xa48>
f0101bd3:	68 ae 50 10 f0       	push   $0xf01050ae
f0101bd8:	68 78 4e 10 f0       	push   $0xf0104e78
f0101bdd:	68 8f 03 00 00       	push   $0x38f
f0101be2:	68 52 4e 10 f0       	push   $0xf0104e52
f0101be7:	e8 c0 e4 ff ff       	call   f01000ac <_panic>

	   // should be able to remap with fewer permissions
	   assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bec:	6a 02                	push   $0x2
f0101bee:	68 00 10 00 00       	push   $0x1000
f0101bf3:	56                   	push   %esi
f0101bf4:	50                   	push   %eax
f0101bf5:	e8 e2 f4 ff ff       	call   f01010dc <page_insert>
f0101bfa:	83 c4 10             	add    $0x10,%esp
f0101bfd:	85 c0                	test   %eax,%eax
f0101bff:	74 19                	je     f0101c1a <mem_init+0xa76>
f0101c01:	68 74 54 10 f0       	push   $0xf0105474
f0101c06:	68 78 4e 10 f0       	push   $0xf0104e78
f0101c0b:	68 92 03 00 00       	push   $0x392
f0101c10:	68 52 4e 10 f0       	push   $0xf0104e52
f0101c15:	e8 92 e4 ff ff       	call   f01000ac <_panic>
	   assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c1a:	83 ec 04             	sub    $0x4,%esp
f0101c1d:	6a 00                	push   $0x0
f0101c1f:	68 00 10 00 00       	push   $0x1000
f0101c24:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101c2a:	e8 ef f2 ff ff       	call   f0100f1e <pgdir_walk>
f0101c2f:	83 c4 10             	add    $0x10,%esp
f0101c32:	f6 00 02             	testb  $0x2,(%eax)
f0101c35:	75 19                	jne    f0101c50 <mem_init+0xaac>
f0101c37:	68 94 55 10 f0       	push   $0xf0105594
f0101c3c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101c41:	68 93 03 00 00       	push   $0x393
f0101c46:	68 52 4e 10 f0       	push   $0xf0104e52
f0101c4b:	e8 5c e4 ff ff       	call   f01000ac <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c50:	83 ec 04             	sub    $0x4,%esp
f0101c53:	6a 00                	push   $0x0
f0101c55:	68 00 10 00 00       	push   $0x1000
f0101c5a:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101c60:	e8 b9 f2 ff ff       	call   f0100f1e <pgdir_walk>
f0101c65:	83 c4 10             	add    $0x10,%esp
f0101c68:	f6 00 04             	testb  $0x4,(%eax)
f0101c6b:	74 19                	je     f0101c86 <mem_init+0xae2>
f0101c6d:	68 c8 55 10 f0       	push   $0xf01055c8
f0101c72:	68 78 4e 10 f0       	push   $0xf0104e78
f0101c77:	68 94 03 00 00       	push   $0x394
f0101c7c:	68 52 4e 10 f0       	push   $0xf0104e52
f0101c81:	e8 26 e4 ff ff       	call   f01000ac <_panic>


	   assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c86:	6a 02                	push   $0x2
f0101c88:	68 00 00 40 00       	push   $0x400000
f0101c8d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c90:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101c96:	e8 41 f4 ff ff       	call   f01010dc <page_insert>
f0101c9b:	83 c4 10             	add    $0x10,%esp
f0101c9e:	85 c0                	test   %eax,%eax
f0101ca0:	78 19                	js     f0101cbb <mem_init+0xb17>
f0101ca2:	68 00 56 10 f0       	push   $0xf0105600
f0101ca7:	68 78 4e 10 f0       	push   $0xf0104e78
f0101cac:	68 97 03 00 00       	push   $0x397
f0101cb1:	68 52 4e 10 f0       	push   $0xf0104e52
f0101cb6:	e8 f1 e3 ff ff       	call   f01000ac <_panic>

	   // insert pp1 at PGSIZE (replacing pp2)
	   assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cbb:	6a 02                	push   $0x2
f0101cbd:	68 00 10 00 00       	push   $0x1000
f0101cc2:	53                   	push   %ebx
f0101cc3:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101cc9:	e8 0e f4 ff ff       	call   f01010dc <page_insert>
f0101cce:	83 c4 10             	add    $0x10,%esp
f0101cd1:	85 c0                	test   %eax,%eax
f0101cd3:	74 19                	je     f0101cee <mem_init+0xb4a>
f0101cd5:	68 38 56 10 f0       	push   $0xf0105638
f0101cda:	68 78 4e 10 f0       	push   $0xf0104e78
f0101cdf:	68 9a 03 00 00       	push   $0x39a
f0101ce4:	68 52 4e 10 f0       	push   $0xf0104e52
f0101ce9:	e8 be e3 ff ff       	call   f01000ac <_panic>
	   assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cee:	83 ec 04             	sub    $0x4,%esp
f0101cf1:	6a 00                	push   $0x0
f0101cf3:	68 00 10 00 00       	push   $0x1000
f0101cf8:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101cfe:	e8 1b f2 ff ff       	call   f0100f1e <pgdir_walk>
f0101d03:	83 c4 10             	add    $0x10,%esp
f0101d06:	f6 00 04             	testb  $0x4,(%eax)
f0101d09:	74 19                	je     f0101d24 <mem_init+0xb80>
f0101d0b:	68 c8 55 10 f0       	push   $0xf01055c8
f0101d10:	68 78 4e 10 f0       	push   $0xf0104e78
f0101d15:	68 9b 03 00 00       	push   $0x39b
f0101d1a:	68 52 4e 10 f0       	push   $0xf0104e52
f0101d1f:	e8 88 e3 ff ff       	call   f01000ac <_panic>

	   // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	   assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d24:	8b 3d 4c 2c 17 f0    	mov    0xf0172c4c,%edi
f0101d2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d2f:	89 f8                	mov    %edi,%eax
f0101d31:	e8 9b ec ff ff       	call   f01009d1 <check_va2pa>
f0101d36:	89 c1                	mov    %eax,%ecx
f0101d38:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d3b:	89 d8                	mov    %ebx,%eax
f0101d3d:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0101d43:	c1 f8 03             	sar    $0x3,%eax
f0101d46:	c1 e0 0c             	shl    $0xc,%eax
f0101d49:	39 c1                	cmp    %eax,%ecx
f0101d4b:	74 19                	je     f0101d66 <mem_init+0xbc2>
f0101d4d:	68 74 56 10 f0       	push   $0xf0105674
f0101d52:	68 78 4e 10 f0       	push   $0xf0104e78
f0101d57:	68 9e 03 00 00       	push   $0x39e
f0101d5c:	68 52 4e 10 f0       	push   $0xf0104e52
f0101d61:	e8 46 e3 ff ff       	call   f01000ac <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d66:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d6b:	89 f8                	mov    %edi,%eax
f0101d6d:	e8 5f ec ff ff       	call   f01009d1 <check_va2pa>
f0101d72:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d75:	74 19                	je     f0101d90 <mem_init+0xbec>
f0101d77:	68 a0 56 10 f0       	push   $0xf01056a0
f0101d7c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101d81:	68 9f 03 00 00       	push   $0x39f
f0101d86:	68 52 4e 10 f0       	push   $0xf0104e52
f0101d8b:	e8 1c e3 ff ff       	call   f01000ac <_panic>
	   // ... and ref counts should reflect this
	   assert(pp1->pp_ref == 2);
f0101d90:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d95:	74 19                	je     f0101db0 <mem_init+0xc0c>
f0101d97:	68 c4 50 10 f0       	push   $0xf01050c4
f0101d9c:	68 78 4e 10 f0       	push   $0xf0104e78
f0101da1:	68 a1 03 00 00       	push   $0x3a1
f0101da6:	68 52 4e 10 f0       	push   $0xf0104e52
f0101dab:	e8 fc e2 ff ff       	call   f01000ac <_panic>
	   assert(pp2->pp_ref == 0);
f0101db0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101db5:	74 19                	je     f0101dd0 <mem_init+0xc2c>
f0101db7:	68 d5 50 10 f0       	push   $0xf01050d5
f0101dbc:	68 78 4e 10 f0       	push   $0xf0104e78
f0101dc1:	68 a2 03 00 00       	push   $0x3a2
f0101dc6:	68 52 4e 10 f0       	push   $0xf0104e52
f0101dcb:	e8 dc e2 ff ff       	call   f01000ac <_panic>

	   // pp2 should be returned by page_alloc
	   assert((pp = page_alloc(0)) && pp == pp2);
f0101dd0:	83 ec 0c             	sub    $0xc,%esp
f0101dd3:	6a 00                	push   $0x0
f0101dd5:	e8 4a f0 ff ff       	call   f0100e24 <page_alloc>
f0101dda:	83 c4 10             	add    $0x10,%esp
f0101ddd:	85 c0                	test   %eax,%eax
f0101ddf:	74 04                	je     f0101de5 <mem_init+0xc41>
f0101de1:	39 c6                	cmp    %eax,%esi
f0101de3:	74 19                	je     f0101dfe <mem_init+0xc5a>
f0101de5:	68 d0 56 10 f0       	push   $0xf01056d0
f0101dea:	68 78 4e 10 f0       	push   $0xf0104e78
f0101def:	68 a5 03 00 00       	push   $0x3a5
f0101df4:	68 52 4e 10 f0       	push   $0xf0104e52
f0101df9:	e8 ae e2 ff ff       	call   f01000ac <_panic>

	   // unmapping pp1 at 0 should keep pp1 at PGSIZE
	   page_remove(kern_pgdir, 0x0);
f0101dfe:	83 ec 08             	sub    $0x8,%esp
f0101e01:	6a 00                	push   $0x0
f0101e03:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101e09:	e8 8c f2 ff ff       	call   f010109a <page_remove>
	   assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e0e:	8b 3d 4c 2c 17 f0    	mov    0xf0172c4c,%edi
f0101e14:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e19:	89 f8                	mov    %edi,%eax
f0101e1b:	e8 b1 eb ff ff       	call   f01009d1 <check_va2pa>
f0101e20:	83 c4 10             	add    $0x10,%esp
f0101e23:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e26:	74 19                	je     f0101e41 <mem_init+0xc9d>
f0101e28:	68 f4 56 10 f0       	push   $0xf01056f4
f0101e2d:	68 78 4e 10 f0       	push   $0xf0104e78
f0101e32:	68 a9 03 00 00       	push   $0x3a9
f0101e37:	68 52 4e 10 f0       	push   $0xf0104e52
f0101e3c:	e8 6b e2 ff ff       	call   f01000ac <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e41:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e46:	89 f8                	mov    %edi,%eax
f0101e48:	e8 84 eb ff ff       	call   f01009d1 <check_va2pa>
f0101e4d:	89 da                	mov    %ebx,%edx
f0101e4f:	2b 15 50 2c 17 f0    	sub    0xf0172c50,%edx
f0101e55:	c1 fa 03             	sar    $0x3,%edx
f0101e58:	c1 e2 0c             	shl    $0xc,%edx
f0101e5b:	39 d0                	cmp    %edx,%eax
f0101e5d:	74 19                	je     f0101e78 <mem_init+0xcd4>
f0101e5f:	68 a0 56 10 f0       	push   $0xf01056a0
f0101e64:	68 78 4e 10 f0       	push   $0xf0104e78
f0101e69:	68 aa 03 00 00       	push   $0x3aa
f0101e6e:	68 52 4e 10 f0       	push   $0xf0104e52
f0101e73:	e8 34 e2 ff ff       	call   f01000ac <_panic>
	   assert(pp1->pp_ref == 1);
f0101e78:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e7d:	74 19                	je     f0101e98 <mem_init+0xcf4>
f0101e7f:	68 7b 50 10 f0       	push   $0xf010507b
f0101e84:	68 78 4e 10 f0       	push   $0xf0104e78
f0101e89:	68 ab 03 00 00       	push   $0x3ab
f0101e8e:	68 52 4e 10 f0       	push   $0xf0104e52
f0101e93:	e8 14 e2 ff ff       	call   f01000ac <_panic>
	   assert(pp2->pp_ref == 0);
f0101e98:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e9d:	74 19                	je     f0101eb8 <mem_init+0xd14>
f0101e9f:	68 d5 50 10 f0       	push   $0xf01050d5
f0101ea4:	68 78 4e 10 f0       	push   $0xf0104e78
f0101ea9:	68 ac 03 00 00       	push   $0x3ac
f0101eae:	68 52 4e 10 f0       	push   $0xf0104e52
f0101eb3:	e8 f4 e1 ff ff       	call   f01000ac <_panic>

	   // test re-inserting pp1 at PGSIZE
	   assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101eb8:	6a 00                	push   $0x0
f0101eba:	68 00 10 00 00       	push   $0x1000
f0101ebf:	53                   	push   %ebx
f0101ec0:	57                   	push   %edi
f0101ec1:	e8 16 f2 ff ff       	call   f01010dc <page_insert>
f0101ec6:	83 c4 10             	add    $0x10,%esp
f0101ec9:	85 c0                	test   %eax,%eax
f0101ecb:	74 19                	je     f0101ee6 <mem_init+0xd42>
f0101ecd:	68 18 57 10 f0       	push   $0xf0105718
f0101ed2:	68 78 4e 10 f0       	push   $0xf0104e78
f0101ed7:	68 af 03 00 00       	push   $0x3af
f0101edc:	68 52 4e 10 f0       	push   $0xf0104e52
f0101ee1:	e8 c6 e1 ff ff       	call   f01000ac <_panic>
	   assert(pp1->pp_ref);
f0101ee6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101eeb:	75 19                	jne    f0101f06 <mem_init+0xd62>
f0101eed:	68 e6 50 10 f0       	push   $0xf01050e6
f0101ef2:	68 78 4e 10 f0       	push   $0xf0104e78
f0101ef7:	68 b0 03 00 00       	push   $0x3b0
f0101efc:	68 52 4e 10 f0       	push   $0xf0104e52
f0101f01:	e8 a6 e1 ff ff       	call   f01000ac <_panic>
	   assert(pp1->pp_link == NULL);
f0101f06:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f09:	74 19                	je     f0101f24 <mem_init+0xd80>
f0101f0b:	68 f2 50 10 f0       	push   $0xf01050f2
f0101f10:	68 78 4e 10 f0       	push   $0xf0104e78
f0101f15:	68 b1 03 00 00       	push   $0x3b1
f0101f1a:	68 52 4e 10 f0       	push   $0xf0104e52
f0101f1f:	e8 88 e1 ff ff       	call   f01000ac <_panic>

	   // unmapping pp1 at PGSIZE should free it
	   page_remove(kern_pgdir, (void*) PGSIZE);
f0101f24:	83 ec 08             	sub    $0x8,%esp
f0101f27:	68 00 10 00 00       	push   $0x1000
f0101f2c:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0101f32:	e8 63 f1 ff ff       	call   f010109a <page_remove>
	   assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f37:	8b 3d 4c 2c 17 f0    	mov    0xf0172c4c,%edi
f0101f3d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f42:	89 f8                	mov    %edi,%eax
f0101f44:	e8 88 ea ff ff       	call   f01009d1 <check_va2pa>
f0101f49:	83 c4 10             	add    $0x10,%esp
f0101f4c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f4f:	74 19                	je     f0101f6a <mem_init+0xdc6>
f0101f51:	68 f4 56 10 f0       	push   $0xf01056f4
f0101f56:	68 78 4e 10 f0       	push   $0xf0104e78
f0101f5b:	68 b5 03 00 00       	push   $0x3b5
f0101f60:	68 52 4e 10 f0       	push   $0xf0104e52
f0101f65:	e8 42 e1 ff ff       	call   f01000ac <_panic>
	   assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f6a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f6f:	89 f8                	mov    %edi,%eax
f0101f71:	e8 5b ea ff ff       	call   f01009d1 <check_va2pa>
f0101f76:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f79:	74 19                	je     f0101f94 <mem_init+0xdf0>
f0101f7b:	68 50 57 10 f0       	push   $0xf0105750
f0101f80:	68 78 4e 10 f0       	push   $0xf0104e78
f0101f85:	68 b6 03 00 00       	push   $0x3b6
f0101f8a:	68 52 4e 10 f0       	push   $0xf0104e52
f0101f8f:	e8 18 e1 ff ff       	call   f01000ac <_panic>
	   assert(pp1->pp_ref == 0);
f0101f94:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f99:	74 19                	je     f0101fb4 <mem_init+0xe10>
f0101f9b:	68 07 51 10 f0       	push   $0xf0105107
f0101fa0:	68 78 4e 10 f0       	push   $0xf0104e78
f0101fa5:	68 b7 03 00 00       	push   $0x3b7
f0101faa:	68 52 4e 10 f0       	push   $0xf0104e52
f0101faf:	e8 f8 e0 ff ff       	call   f01000ac <_panic>
	   assert(pp2->pp_ref == 0);
f0101fb4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fb9:	74 19                	je     f0101fd4 <mem_init+0xe30>
f0101fbb:	68 d5 50 10 f0       	push   $0xf01050d5
f0101fc0:	68 78 4e 10 f0       	push   $0xf0104e78
f0101fc5:	68 b8 03 00 00       	push   $0x3b8
f0101fca:	68 52 4e 10 f0       	push   $0xf0104e52
f0101fcf:	e8 d8 e0 ff ff       	call   f01000ac <_panic>

	   // so it should be returned by page_alloc
	   assert((pp = page_alloc(0)) && pp == pp1);
f0101fd4:	83 ec 0c             	sub    $0xc,%esp
f0101fd7:	6a 00                	push   $0x0
f0101fd9:	e8 46 ee ff ff       	call   f0100e24 <page_alloc>
f0101fde:	83 c4 10             	add    $0x10,%esp
f0101fe1:	39 c3                	cmp    %eax,%ebx
f0101fe3:	75 04                	jne    f0101fe9 <mem_init+0xe45>
f0101fe5:	85 c0                	test   %eax,%eax
f0101fe7:	75 19                	jne    f0102002 <mem_init+0xe5e>
f0101fe9:	68 78 57 10 f0       	push   $0xf0105778
f0101fee:	68 78 4e 10 f0       	push   $0xf0104e78
f0101ff3:	68 bb 03 00 00       	push   $0x3bb
f0101ff8:	68 52 4e 10 f0       	push   $0xf0104e52
f0101ffd:	e8 aa e0 ff ff       	call   f01000ac <_panic>

	   // should be no free memory
	   assert(!page_alloc(0));
f0102002:	83 ec 0c             	sub    $0xc,%esp
f0102005:	6a 00                	push   $0x0
f0102007:	e8 18 ee ff ff       	call   f0100e24 <page_alloc>
f010200c:	83 c4 10             	add    $0x10,%esp
f010200f:	85 c0                	test   %eax,%eax
f0102011:	74 19                	je     f010202c <mem_init+0xe88>
f0102013:	68 29 50 10 f0       	push   $0xf0105029
f0102018:	68 78 4e 10 f0       	push   $0xf0104e78
f010201d:	68 be 03 00 00       	push   $0x3be
f0102022:	68 52 4e 10 f0       	push   $0xf0104e52
f0102027:	e8 80 e0 ff ff       	call   f01000ac <_panic>

	   // forcibly take pp0 back
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010202c:	8b 0d 4c 2c 17 f0    	mov    0xf0172c4c,%ecx
f0102032:	8b 11                	mov    (%ecx),%edx
f0102034:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010203a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010203d:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0102043:	c1 f8 03             	sar    $0x3,%eax
f0102046:	c1 e0 0c             	shl    $0xc,%eax
f0102049:	39 c2                	cmp    %eax,%edx
f010204b:	74 19                	je     f0102066 <mem_init+0xec2>
f010204d:	68 1c 54 10 f0       	push   $0xf010541c
f0102052:	68 78 4e 10 f0       	push   $0xf0104e78
f0102057:	68 c1 03 00 00       	push   $0x3c1
f010205c:	68 52 4e 10 f0       	push   $0xf0104e52
f0102061:	e8 46 e0 ff ff       	call   f01000ac <_panic>
	   kern_pgdir[0] = 0;
f0102066:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	   assert(pp0->pp_ref == 1);
f010206c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010206f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102074:	74 19                	je     f010208f <mem_init+0xeeb>
f0102076:	68 8c 50 10 f0       	push   $0xf010508c
f010207b:	68 78 4e 10 f0       	push   $0xf0104e78
f0102080:	68 c3 03 00 00       	push   $0x3c3
f0102085:	68 52 4e 10 f0       	push   $0xf0104e52
f010208a:	e8 1d e0 ff ff       	call   f01000ac <_panic>
	   pp0->pp_ref = 0;
f010208f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102092:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	   // check pointer arithmetic in pgdir_walk
	   page_free(pp0);
f0102098:	83 ec 0c             	sub    $0xc,%esp
f010209b:	50                   	push   %eax
f010209c:	e8 fa ed ff ff       	call   f0100e9b <page_free>
	   va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	   ptep = pgdir_walk(kern_pgdir, va, 1);
f01020a1:	83 c4 0c             	add    $0xc,%esp
f01020a4:	6a 01                	push   $0x1
f01020a6:	68 00 10 40 00       	push   $0x401000
f01020ab:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f01020b1:	e8 68 ee ff ff       	call   f0100f1e <pgdir_walk>
f01020b6:	89 c7                	mov    %eax,%edi
f01020b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	   ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01020bb:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f01020c0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020c3:	8b 40 04             	mov    0x4(%eax),%eax
f01020c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020cb:	8b 0d 48 2c 17 f0    	mov    0xf0172c48,%ecx
f01020d1:	89 c2                	mov    %eax,%edx
f01020d3:	c1 ea 0c             	shr    $0xc,%edx
f01020d6:	83 c4 10             	add    $0x10,%esp
f01020d9:	39 ca                	cmp    %ecx,%edx
f01020db:	72 15                	jb     f01020f2 <mem_init+0xf4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020dd:	50                   	push   %eax
f01020de:	68 b8 51 10 f0       	push   $0xf01051b8
f01020e3:	68 ca 03 00 00       	push   $0x3ca
f01020e8:	68 52 4e 10 f0       	push   $0xf0104e52
f01020ed:	e8 ba df ff ff       	call   f01000ac <_panic>
	   assert(ptep == ptep1 + PTX(va));
f01020f2:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01020f7:	39 c7                	cmp    %eax,%edi
f01020f9:	74 19                	je     f0102114 <mem_init+0xf70>
f01020fb:	68 18 51 10 f0       	push   $0xf0105118
f0102100:	68 78 4e 10 f0       	push   $0xf0104e78
f0102105:	68 cb 03 00 00       	push   $0x3cb
f010210a:	68 52 4e 10 f0       	push   $0xf0104e52
f010210f:	e8 98 df ff ff       	call   f01000ac <_panic>
	   kern_pgdir[PDX(va)] = 0;
f0102114:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102117:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	   pp0->pp_ref = 0;
f010211e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102121:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102127:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f010212d:	c1 f8 03             	sar    $0x3,%eax
f0102130:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102133:	89 c2                	mov    %eax,%edx
f0102135:	c1 ea 0c             	shr    $0xc,%edx
f0102138:	39 d1                	cmp    %edx,%ecx
f010213a:	77 12                	ja     f010214e <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010213c:	50                   	push   %eax
f010213d:	68 b8 51 10 f0       	push   $0xf01051b8
f0102142:	6a 56                	push   $0x56
f0102144:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102149:	e8 5e df ff ff       	call   f01000ac <_panic>

	   // check that new page tables get cleared
	   memset(page2kva(pp0), 0xFF, PGSIZE);
f010214e:	83 ec 04             	sub    $0x4,%esp
f0102151:	68 00 10 00 00       	push   $0x1000
f0102156:	68 ff 00 00 00       	push   $0xff
f010215b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102160:	50                   	push   %eax
f0102161:	e8 f1 22 00 00       	call   f0104457 <memset>
	   page_free(pp0);
f0102166:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102169:	89 3c 24             	mov    %edi,(%esp)
f010216c:	e8 2a ed ff ff       	call   f0100e9b <page_free>
	   pgdir_walk(kern_pgdir, 0x0, 1);
f0102171:	83 c4 0c             	add    $0xc,%esp
f0102174:	6a 01                	push   $0x1
f0102176:	6a 00                	push   $0x0
f0102178:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f010217e:	e8 9b ed ff ff       	call   f0100f1e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102183:	89 fa                	mov    %edi,%edx
f0102185:	2b 15 50 2c 17 f0    	sub    0xf0172c50,%edx
f010218b:	c1 fa 03             	sar    $0x3,%edx
f010218e:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102191:	89 d0                	mov    %edx,%eax
f0102193:	c1 e8 0c             	shr    $0xc,%eax
f0102196:	83 c4 10             	add    $0x10,%esp
f0102199:	3b 05 48 2c 17 f0    	cmp    0xf0172c48,%eax
f010219f:	72 12                	jb     f01021b3 <mem_init+0x100f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021a1:	52                   	push   %edx
f01021a2:	68 b8 51 10 f0       	push   $0xf01051b8
f01021a7:	6a 56                	push   $0x56
f01021a9:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01021ae:	e8 f9 de ff ff       	call   f01000ac <_panic>
	return (void *)(pa + KERNBASE);
f01021b3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	   ptep = (pte_t *) page2kva(pp0);
f01021b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01021bc:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	   for(i=0; i<NPTENTRIES; i++)
			 assert((ptep[i] & PTE_P) == 0);
f01021c2:	f6 00 01             	testb  $0x1,(%eax)
f01021c5:	74 19                	je     f01021e0 <mem_init+0x103c>
f01021c7:	68 30 51 10 f0       	push   $0xf0105130
f01021cc:	68 78 4e 10 f0       	push   $0xf0104e78
f01021d1:	68 d5 03 00 00       	push   $0x3d5
f01021d6:	68 52 4e 10 f0       	push   $0xf0104e52
f01021db:	e8 cc de ff ff       	call   f01000ac <_panic>
f01021e0:	83 c0 04             	add    $0x4,%eax
	   // check that new page tables get cleared
	   memset(page2kva(pp0), 0xFF, PGSIZE);
	   page_free(pp0);
	   pgdir_walk(kern_pgdir, 0x0, 1);
	   ptep = (pte_t *) page2kva(pp0);
	   for(i=0; i<NPTENTRIES; i++)
f01021e3:	39 c2                	cmp    %eax,%edx
f01021e5:	75 db                	jne    f01021c2 <mem_init+0x101e>
			 assert((ptep[i] & PTE_P) == 0);
	   kern_pgdir[0] = 0;
f01021e7:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f01021ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	   pp0->pp_ref = 0;
f01021f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021f5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	   // give free list back
	   page_free_list = fl;
f01021fb:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01021fe:	89 3d 80 1f 17 f0    	mov    %edi,0xf0171f80

	   // free the pages we took
	   page_free(pp0);
f0102204:	83 ec 0c             	sub    $0xc,%esp
f0102207:	50                   	push   %eax
f0102208:	e8 8e ec ff ff       	call   f0100e9b <page_free>
	   page_free(pp1);
f010220d:	89 1c 24             	mov    %ebx,(%esp)
f0102210:	e8 86 ec ff ff       	call   f0100e9b <page_free>
	   page_free(pp2);
f0102215:	89 34 24             	mov    %esi,(%esp)
f0102218:	e8 7e ec ff ff       	call   f0100e9b <page_free>

	   cprintf("check_page() succeeded!\n");
f010221d:	c7 04 24 47 51 10 f0 	movl   $0xf0105147,(%esp)
f0102224:	e8 a8 0e 00 00       	call   f01030d1 <cprintf>
	   // Permissions:
	   //    - the new image at UPAGES -- kernel R, user R
	   //      (ie. perm = PTE_U | PTE_P)
	   //    - pages itself -- kernel RW, user NONE
	   // Your code goes here:
	   boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102229:	a1 50 2c 17 f0       	mov    0xf0172c50,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010222e:	83 c4 10             	add    $0x10,%esp
f0102231:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102236:	77 15                	ja     f010224d <mem_init+0x10a9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102238:	50                   	push   %eax
f0102239:	68 c4 52 10 f0       	push   $0xf01052c4
f010223e:	68 c1 00 00 00       	push   $0xc1
f0102243:	68 52 4e 10 f0       	push   $0xf0104e52
f0102248:	e8 5f de ff ff       	call   f01000ac <_panic>
f010224d:	83 ec 08             	sub    $0x8,%esp
f0102250:	6a 05                	push   $0x5
f0102252:	05 00 00 00 10       	add    $0x10000000,%eax
f0102257:	50                   	push   %eax
f0102258:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010225d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102262:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f0102267:	e8 4f ed ff ff       	call   f0100fbb <boot_map_region>
	   // (ie. perm = PTE_U | PTE_P).
	   // Permissions:
	   //    - the new image at UENVS  -- kernel R, user R
	   //    - envs itself -- kernel RW, user NONE
	   // LAB 3: Your code here.
	   boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f010226c:	a1 8c 1f 17 f0       	mov    0xf0171f8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102271:	83 c4 10             	add    $0x10,%esp
f0102274:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102279:	77 15                	ja     f0102290 <mem_init+0x10ec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010227b:	50                   	push   %eax
f010227c:	68 c4 52 10 f0       	push   $0xf01052c4
f0102281:	68 ca 00 00 00       	push   $0xca
f0102286:	68 52 4e 10 f0       	push   $0xf0104e52
f010228b:	e8 1c de ff ff       	call   f01000ac <_panic>
f0102290:	83 ec 08             	sub    $0x8,%esp
f0102293:	6a 05                	push   $0x5
f0102295:	05 00 00 00 10       	add    $0x10000000,%eax
f010229a:	50                   	push   %eax
f010229b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01022a0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01022a5:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f01022aa:	e8 0c ed ff ff       	call   f0100fbb <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022af:	83 c4 10             	add    $0x10,%esp
f01022b2:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f01022b7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022bc:	77 15                	ja     f01022d3 <mem_init+0x112f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022be:	50                   	push   %eax
f01022bf:	68 c4 52 10 f0       	push   $0xf01052c4
f01022c4:	68 d8 00 00 00       	push   $0xd8
f01022c9:	68 52 4e 10 f0       	push   $0xf0104e52
f01022ce:	e8 d9 dd ff ff       	call   f01000ac <_panic>
	   //       the kernel overflows its stack, it will fault rather than
	   //       overwrite memory.  Known as a "guard page".
	   //     Permissions: kernel RW, user NONE
	   // Your code goes here:
	   uintptr_t address = KSTACKTOP - KSTKSIZE;
	   boot_map_region (kern_pgdir, address, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01022d3:	83 ec 08             	sub    $0x8,%esp
f01022d6:	6a 03                	push   $0x3
f01022d8:	68 00 10 11 00       	push   $0x111000
f01022dd:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01022e2:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01022e7:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f01022ec:	e8 ca ec ff ff       	call   f0100fbb <boot_map_region>
	   // We might not have 2^32 - KERNBASE bytes of physical memory, but
	   // we just set up the mapping anyway.
	   // Permissions: kernel RW, user NONE
	   // Your code goes here:
	   uint32_t pa_range = 0xFFFFFFFF - KERNBASE +1;
	   boot_map_region (kern_pgdir, KERNBASE, pa_range, 0, PTE_W | PTE_P);
f01022f1:	83 c4 08             	add    $0x8,%esp
f01022f4:	6a 03                	push   $0x3
f01022f6:	6a 00                	push   $0x0
f01022f8:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01022fd:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102302:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
f0102307:	e8 af ec ff ff       	call   f0100fbb <boot_map_region>
check_kern_pgdir(void)
{
	   uint32_t i, n;
	   pde_t *pgdir;

	   pgdir = kern_pgdir;
f010230c:	8b 1d 4c 2c 17 f0    	mov    0xf0172c4c,%ebx

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102312:	a1 48 2c 17 f0       	mov    0xf0172c48,%eax
f0102317:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010231a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102321:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102326:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102329:	8b 3d 50 2c 17 f0    	mov    0xf0172c50,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010232f:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102332:	83 c4 10             	add    $0x10,%esp

	   pgdir = kern_pgdir;

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f0102335:	be 00 00 00 00       	mov    $0x0,%esi
f010233a:	eb 55                	jmp    f0102391 <mem_init+0x11ed>
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010233c:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102342:	89 d8                	mov    %ebx,%eax
f0102344:	e8 88 e6 ff ff       	call   f01009d1 <check_va2pa>
f0102349:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102350:	77 15                	ja     f0102367 <mem_init+0x11c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102352:	57                   	push   %edi
f0102353:	68 c4 52 10 f0       	push   $0xf01052c4
f0102358:	68 12 03 00 00       	push   $0x312
f010235d:	68 52 4e 10 f0       	push   $0xf0104e52
f0102362:	e8 45 dd ff ff       	call   f01000ac <_panic>
f0102367:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f010236e:	39 d0                	cmp    %edx,%eax
f0102370:	74 19                	je     f010238b <mem_init+0x11e7>
f0102372:	68 9c 57 10 f0       	push   $0xf010579c
f0102377:	68 78 4e 10 f0       	push   $0xf0104e78
f010237c:	68 12 03 00 00       	push   $0x312
f0102381:	68 52 4e 10 f0       	push   $0xf0104e52
f0102386:	e8 21 dd ff ff       	call   f01000ac <_panic>

	   pgdir = kern_pgdir;

	   // check pages array
	   n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f010238b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102391:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102394:	77 a6                	ja     f010233c <mem_init+0x1198>
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	   // check envs array (new test for lab 3)
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102396:	8b 3d 8c 1f 17 f0    	mov    0xf0171f8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010239c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010239f:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01023a4:	89 f2                	mov    %esi,%edx
f01023a6:	89 d8                	mov    %ebx,%eax
f01023a8:	e8 24 e6 ff ff       	call   f01009d1 <check_va2pa>
f01023ad:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01023b4:	77 15                	ja     f01023cb <mem_init+0x1227>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023b6:	57                   	push   %edi
f01023b7:	68 c4 52 10 f0       	push   $0xf01052c4
f01023bc:	68 17 03 00 00       	push   $0x317
f01023c1:	68 52 4e 10 f0       	push   $0xf0104e52
f01023c6:	e8 e1 dc ff ff       	call   f01000ac <_panic>
f01023cb:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f01023d2:	39 c2                	cmp    %eax,%edx
f01023d4:	74 19                	je     f01023ef <mem_init+0x124b>
f01023d6:	68 d0 57 10 f0       	push   $0xf01057d0
f01023db:	68 78 4e 10 f0       	push   $0xf0104e78
f01023e0:	68 17 03 00 00       	push   $0x317
f01023e5:	68 52 4e 10 f0       	push   $0xf0104e52
f01023ea:	e8 bd dc ff ff       	call   f01000ac <_panic>
f01023ef:	81 c6 00 10 00 00    	add    $0x1000,%esi
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	   // check envs array (new test for lab 3)
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
f01023f5:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01023fb:	75 a7                	jne    f01023a4 <mem_init+0x1200>
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	   // check phys mem
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023fd:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102400:	c1 e7 0c             	shl    $0xc,%edi
f0102403:	be 00 00 00 00       	mov    $0x0,%esi
f0102408:	eb 30                	jmp    f010243a <mem_init+0x1296>
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010240a:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102410:	89 d8                	mov    %ebx,%eax
f0102412:	e8 ba e5 ff ff       	call   f01009d1 <check_va2pa>
f0102417:	39 c6                	cmp    %eax,%esi
f0102419:	74 19                	je     f0102434 <mem_init+0x1290>
f010241b:	68 04 58 10 f0       	push   $0xf0105804
f0102420:	68 78 4e 10 f0       	push   $0xf0104e78
f0102425:	68 1b 03 00 00       	push   $0x31b
f010242a:	68 52 4e 10 f0       	push   $0xf0104e52
f010242f:	e8 78 dc ff ff       	call   f01000ac <_panic>
	   n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	   for (i = 0; i < n; i += PGSIZE)
			 assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	   // check phys mem
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102434:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010243a:	39 fe                	cmp    %edi,%esi
f010243c:	72 cc                	jb     f010240a <mem_init+0x1266>
f010243e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);

	   // check kernel stack
	   for (i = 0; i < KSTKSIZE; i += PGSIZE)
			 assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102443:	89 f2                	mov    %esi,%edx
f0102445:	89 d8                	mov    %ebx,%eax
f0102447:	e8 85 e5 ff ff       	call   f01009d1 <check_va2pa>
f010244c:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f0102452:	39 c2                	cmp    %eax,%edx
f0102454:	74 19                	je     f010246f <mem_init+0x12cb>
f0102456:	68 2c 58 10 f0       	push   $0xf010582c
f010245b:	68 78 4e 10 f0       	push   $0xf0104e78
f0102460:	68 1f 03 00 00       	push   $0x31f
f0102465:	68 52 4e 10 f0       	push   $0xf0104e52
f010246a:	e8 3d dc ff ff       	call   f01000ac <_panic>
f010246f:	81 c6 00 10 00 00    	add    $0x1000,%esi
	   // check phys mem
	   for (i = 0; i < npages * PGSIZE; i += PGSIZE)
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);

	   // check kernel stack
	   for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102475:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010247b:	75 c6                	jne    f0102443 <mem_init+0x129f>
			 assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	   assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010247d:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102482:	89 d8                	mov    %ebx,%eax
f0102484:	e8 48 e5 ff ff       	call   f01009d1 <check_va2pa>
f0102489:	83 f8 ff             	cmp    $0xffffffff,%eax
f010248c:	74 51                	je     f01024df <mem_init+0x133b>
f010248e:	68 74 58 10 f0       	push   $0xf0105874
f0102493:	68 78 4e 10 f0       	push   $0xf0104e78
f0102498:	68 20 03 00 00       	push   $0x320
f010249d:	68 52 4e 10 f0       	push   $0xf0104e52
f01024a2:	e8 05 dc ff ff       	call   f01000ac <_panic>

	   // check PDE permissions
	   for (i = 0; i < NPDENTRIES; i++) {
			 switch (i) {
f01024a7:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01024ac:	72 36                	jb     f01024e4 <mem_init+0x1340>
f01024ae:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01024b3:	76 07                	jbe    f01024bc <mem_init+0x1318>
f01024b5:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01024ba:	75 28                	jne    f01024e4 <mem_init+0x1340>
				    case PDX(UVPT):
				    case PDX(KSTACKTOP-1):
				    case PDX(UPAGES):
				    case PDX(UENVS):
						  assert(pgdir[i] & PTE_P);
f01024bc:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01024c0:	0f 85 83 00 00 00    	jne    f0102549 <mem_init+0x13a5>
f01024c6:	68 60 51 10 f0       	push   $0xf0105160
f01024cb:	68 78 4e 10 f0       	push   $0xf0104e78
f01024d0:	68 29 03 00 00       	push   $0x329
f01024d5:	68 52 4e 10 f0       	push   $0xf0104e52
f01024da:	e8 cd db ff ff       	call   f01000ac <_panic>
			 assert(check_va2pa(pgdir, KERNBASE + i) == i);

	   // check kernel stack
	   for (i = 0; i < KSTKSIZE; i += PGSIZE)
			 assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	   assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01024df:	b8 00 00 00 00       	mov    $0x0,%eax
				    case PDX(UPAGES):
				    case PDX(UENVS):
						  assert(pgdir[i] & PTE_P);
						  break;
				    default:
						  if (i >= PDX(KERNBASE)) {
f01024e4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01024e9:	76 3f                	jbe    f010252a <mem_init+0x1386>
								assert(pgdir[i] & PTE_P);
f01024eb:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01024ee:	f6 c2 01             	test   $0x1,%dl
f01024f1:	75 19                	jne    f010250c <mem_init+0x1368>
f01024f3:	68 60 51 10 f0       	push   $0xf0105160
f01024f8:	68 78 4e 10 f0       	push   $0xf0104e78
f01024fd:	68 2d 03 00 00       	push   $0x32d
f0102502:	68 52 4e 10 f0       	push   $0xf0104e52
f0102507:	e8 a0 db ff ff       	call   f01000ac <_panic>
								assert(pgdir[i] & PTE_W);
f010250c:	f6 c2 02             	test   $0x2,%dl
f010250f:	75 38                	jne    f0102549 <mem_init+0x13a5>
f0102511:	68 71 51 10 f0       	push   $0xf0105171
f0102516:	68 78 4e 10 f0       	push   $0xf0104e78
f010251b:	68 2e 03 00 00       	push   $0x32e
f0102520:	68 52 4e 10 f0       	push   $0xf0104e52
f0102525:	e8 82 db ff ff       	call   f01000ac <_panic>
						  } else
								assert(pgdir[i] == 0);
f010252a:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010252e:	74 19                	je     f0102549 <mem_init+0x13a5>
f0102530:	68 82 51 10 f0       	push   $0xf0105182
f0102535:	68 78 4e 10 f0       	push   $0xf0104e78
f010253a:	68 30 03 00 00       	push   $0x330
f010253f:	68 52 4e 10 f0       	push   $0xf0104e52
f0102544:	e8 63 db ff ff       	call   f01000ac <_panic>
	   for (i = 0; i < KSTKSIZE; i += PGSIZE)
			 assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	   assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	   // check PDE permissions
	   for (i = 0; i < NPDENTRIES; i++) {
f0102549:	83 c0 01             	add    $0x1,%eax
f010254c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102551:	0f 86 50 ff ff ff    	jbe    f01024a7 <mem_init+0x1303>
						  } else
								assert(pgdir[i] == 0);
						  break;
			 }
	   }
	   cprintf("check_kern_pgdir() succeeded!\n");
f0102557:	83 ec 0c             	sub    $0xc,%esp
f010255a:	68 a4 58 10 f0       	push   $0xf01058a4
f010255f:	e8 6d 0b 00 00       	call   f01030d1 <cprintf>
	   // somewhere between KERNBASE and KERNBASE+4MB right now, which is
	   // mapped the same way by both page tables.
	   //
	   // If the machine reboots at this point, you've probably set up your
	   // kern_pgdir wrong.
	   lcr3(PADDR(kern_pgdir));
f0102564:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102569:	83 c4 10             	add    $0x10,%esp
f010256c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102571:	77 15                	ja     f0102588 <mem_init+0x13e4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102573:	50                   	push   %eax
f0102574:	68 c4 52 10 f0       	push   $0xf01052c4
f0102579:	68 ef 00 00 00       	push   $0xef
f010257e:	68 52 4e 10 f0       	push   $0xf0104e52
f0102583:	e8 24 db ff ff       	call   f01000ac <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102588:	05 00 00 00 10       	add    $0x10000000,%eax
f010258d:	0f 22 d8             	mov    %eax,%cr3

	   check_page_free_list(0);
f0102590:	b8 00 00 00 00       	mov    $0x0,%eax
f0102595:	e8 9b e4 ff ff       	call   f0100a35 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010259a:	0f 20 c0             	mov    %cr0,%eax
f010259d:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01025a0:	0d 23 00 05 80       	or     $0x80050023,%eax
f01025a5:	0f 22 c0             	mov    %eax,%cr0
	   uintptr_t va;
	   int i;

	   // check that we can read and write installed pages
	   pp1 = pp2 = 0;
	   assert((pp0 = page_alloc(0)));
f01025a8:	83 ec 0c             	sub    $0xc,%esp
f01025ab:	6a 00                	push   $0x0
f01025ad:	e8 72 e8 ff ff       	call   f0100e24 <page_alloc>
f01025b2:	89 c3                	mov    %eax,%ebx
f01025b4:	83 c4 10             	add    $0x10,%esp
f01025b7:	85 c0                	test   %eax,%eax
f01025b9:	75 19                	jne    f01025d4 <mem_init+0x1430>
f01025bb:	68 7e 4f 10 f0       	push   $0xf0104f7e
f01025c0:	68 78 4e 10 f0       	push   $0xf0104e78
f01025c5:	68 f0 03 00 00       	push   $0x3f0
f01025ca:	68 52 4e 10 f0       	push   $0xf0104e52
f01025cf:	e8 d8 da ff ff       	call   f01000ac <_panic>
	   assert((pp1 = page_alloc(0)));
f01025d4:	83 ec 0c             	sub    $0xc,%esp
f01025d7:	6a 00                	push   $0x0
f01025d9:	e8 46 e8 ff ff       	call   f0100e24 <page_alloc>
f01025de:	89 c7                	mov    %eax,%edi
f01025e0:	83 c4 10             	add    $0x10,%esp
f01025e3:	85 c0                	test   %eax,%eax
f01025e5:	75 19                	jne    f0102600 <mem_init+0x145c>
f01025e7:	68 94 4f 10 f0       	push   $0xf0104f94
f01025ec:	68 78 4e 10 f0       	push   $0xf0104e78
f01025f1:	68 f1 03 00 00       	push   $0x3f1
f01025f6:	68 52 4e 10 f0       	push   $0xf0104e52
f01025fb:	e8 ac da ff ff       	call   f01000ac <_panic>
	   assert((pp2 = page_alloc(0)));
f0102600:	83 ec 0c             	sub    $0xc,%esp
f0102603:	6a 00                	push   $0x0
f0102605:	e8 1a e8 ff ff       	call   f0100e24 <page_alloc>
f010260a:	89 c6                	mov    %eax,%esi
f010260c:	83 c4 10             	add    $0x10,%esp
f010260f:	85 c0                	test   %eax,%eax
f0102611:	75 19                	jne    f010262c <mem_init+0x1488>
f0102613:	68 aa 4f 10 f0       	push   $0xf0104faa
f0102618:	68 78 4e 10 f0       	push   $0xf0104e78
f010261d:	68 f2 03 00 00       	push   $0x3f2
f0102622:	68 52 4e 10 f0       	push   $0xf0104e52
f0102627:	e8 80 da ff ff       	call   f01000ac <_panic>
	   page_free(pp0);
f010262c:	83 ec 0c             	sub    $0xc,%esp
f010262f:	53                   	push   %ebx
f0102630:	e8 66 e8 ff ff       	call   f0100e9b <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102635:	89 f8                	mov    %edi,%eax
f0102637:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f010263d:	c1 f8 03             	sar    $0x3,%eax
f0102640:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102643:	89 c2                	mov    %eax,%edx
f0102645:	c1 ea 0c             	shr    $0xc,%edx
f0102648:	83 c4 10             	add    $0x10,%esp
f010264b:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f0102651:	72 12                	jb     f0102665 <mem_init+0x14c1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102653:	50                   	push   %eax
f0102654:	68 b8 51 10 f0       	push   $0xf01051b8
f0102659:	6a 56                	push   $0x56
f010265b:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102660:	e8 47 da ff ff       	call   f01000ac <_panic>
	   memset(page2kva(pp1), 1, PGSIZE);
f0102665:	83 ec 04             	sub    $0x4,%esp
f0102668:	68 00 10 00 00       	push   $0x1000
f010266d:	6a 01                	push   $0x1
f010266f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102674:	50                   	push   %eax
f0102675:	e8 dd 1d 00 00       	call   f0104457 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010267a:	89 f0                	mov    %esi,%eax
f010267c:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0102682:	c1 f8 03             	sar    $0x3,%eax
f0102685:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102688:	89 c2                	mov    %eax,%edx
f010268a:	c1 ea 0c             	shr    $0xc,%edx
f010268d:	83 c4 10             	add    $0x10,%esp
f0102690:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f0102696:	72 12                	jb     f01026aa <mem_init+0x1506>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102698:	50                   	push   %eax
f0102699:	68 b8 51 10 f0       	push   $0xf01051b8
f010269e:	6a 56                	push   $0x56
f01026a0:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01026a5:	e8 02 da ff ff       	call   f01000ac <_panic>
	   memset(page2kva(pp2), 2, PGSIZE);
f01026aa:	83 ec 04             	sub    $0x4,%esp
f01026ad:	68 00 10 00 00       	push   $0x1000
f01026b2:	6a 02                	push   $0x2
f01026b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026b9:	50                   	push   %eax
f01026ba:	e8 98 1d 00 00       	call   f0104457 <memset>
	   page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01026bf:	6a 02                	push   $0x2
f01026c1:	68 00 10 00 00       	push   $0x1000
f01026c6:	57                   	push   %edi
f01026c7:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f01026cd:	e8 0a ea ff ff       	call   f01010dc <page_insert>
	   assert(pp1->pp_ref == 1);
f01026d2:	83 c4 20             	add    $0x20,%esp
f01026d5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01026da:	74 19                	je     f01026f5 <mem_init+0x1551>
f01026dc:	68 7b 50 10 f0       	push   $0xf010507b
f01026e1:	68 78 4e 10 f0       	push   $0xf0104e78
f01026e6:	68 f7 03 00 00       	push   $0x3f7
f01026eb:	68 52 4e 10 f0       	push   $0xf0104e52
f01026f0:	e8 b7 d9 ff ff       	call   f01000ac <_panic>
	   assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01026f5:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01026fc:	01 01 01 
f01026ff:	74 19                	je     f010271a <mem_init+0x1576>
f0102701:	68 c4 58 10 f0       	push   $0xf01058c4
f0102706:	68 78 4e 10 f0       	push   $0xf0104e78
f010270b:	68 f8 03 00 00       	push   $0x3f8
f0102710:	68 52 4e 10 f0       	push   $0xf0104e52
f0102715:	e8 92 d9 ff ff       	call   f01000ac <_panic>
	   page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010271a:	6a 02                	push   $0x2
f010271c:	68 00 10 00 00       	push   $0x1000
f0102721:	56                   	push   %esi
f0102722:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0102728:	e8 af e9 ff ff       	call   f01010dc <page_insert>
	   assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010272d:	83 c4 10             	add    $0x10,%esp
f0102730:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102737:	02 02 02 
f010273a:	74 19                	je     f0102755 <mem_init+0x15b1>
f010273c:	68 e8 58 10 f0       	push   $0xf01058e8
f0102741:	68 78 4e 10 f0       	push   $0xf0104e78
f0102746:	68 fa 03 00 00       	push   $0x3fa
f010274b:	68 52 4e 10 f0       	push   $0xf0104e52
f0102750:	e8 57 d9 ff ff       	call   f01000ac <_panic>
	   assert(pp2->pp_ref == 1);
f0102755:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010275a:	74 19                	je     f0102775 <mem_init+0x15d1>
f010275c:	68 9d 50 10 f0       	push   $0xf010509d
f0102761:	68 78 4e 10 f0       	push   $0xf0104e78
f0102766:	68 fb 03 00 00       	push   $0x3fb
f010276b:	68 52 4e 10 f0       	push   $0xf0104e52
f0102770:	e8 37 d9 ff ff       	call   f01000ac <_panic>
	   assert(pp1->pp_ref == 0);
f0102775:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010277a:	74 19                	je     f0102795 <mem_init+0x15f1>
f010277c:	68 07 51 10 f0       	push   $0xf0105107
f0102781:	68 78 4e 10 f0       	push   $0xf0104e78
f0102786:	68 fc 03 00 00       	push   $0x3fc
f010278b:	68 52 4e 10 f0       	push   $0xf0104e52
f0102790:	e8 17 d9 ff ff       	call   f01000ac <_panic>
	   *(uint32_t *)PGSIZE = 0x03030303U;
f0102795:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010279c:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010279f:	89 f0                	mov    %esi,%eax
f01027a1:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f01027a7:	c1 f8 03             	sar    $0x3,%eax
f01027aa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027ad:	89 c2                	mov    %eax,%edx
f01027af:	c1 ea 0c             	shr    $0xc,%edx
f01027b2:	3b 15 48 2c 17 f0    	cmp    0xf0172c48,%edx
f01027b8:	72 12                	jb     f01027cc <mem_init+0x1628>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027ba:	50                   	push   %eax
f01027bb:	68 b8 51 10 f0       	push   $0xf01051b8
f01027c0:	6a 56                	push   $0x56
f01027c2:	68 5e 4e 10 f0       	push   $0xf0104e5e
f01027c7:	e8 e0 d8 ff ff       	call   f01000ac <_panic>
	   assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01027cc:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01027d3:	03 03 03 
f01027d6:	74 19                	je     f01027f1 <mem_init+0x164d>
f01027d8:	68 0c 59 10 f0       	push   $0xf010590c
f01027dd:	68 78 4e 10 f0       	push   $0xf0104e78
f01027e2:	68 fe 03 00 00       	push   $0x3fe
f01027e7:	68 52 4e 10 f0       	push   $0xf0104e52
f01027ec:	e8 bb d8 ff ff       	call   f01000ac <_panic>
	   page_remove(kern_pgdir, (void*) PGSIZE);
f01027f1:	83 ec 08             	sub    $0x8,%esp
f01027f4:	68 00 10 00 00       	push   $0x1000
f01027f9:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f01027ff:	e8 96 e8 ff ff       	call   f010109a <page_remove>
	   assert(pp2->pp_ref == 0);
f0102804:	83 c4 10             	add    $0x10,%esp
f0102807:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010280c:	74 19                	je     f0102827 <mem_init+0x1683>
f010280e:	68 d5 50 10 f0       	push   $0xf01050d5
f0102813:	68 78 4e 10 f0       	push   $0xf0104e78
f0102818:	68 00 04 00 00       	push   $0x400
f010281d:	68 52 4e 10 f0       	push   $0xf0104e52
f0102822:	e8 85 d8 ff ff       	call   f01000ac <_panic>

	   // forcibly take pp0 back
	   assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102827:	8b 0d 4c 2c 17 f0    	mov    0xf0172c4c,%ecx
f010282d:	8b 11                	mov    (%ecx),%edx
f010282f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102835:	89 d8                	mov    %ebx,%eax
f0102837:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f010283d:	c1 f8 03             	sar    $0x3,%eax
f0102840:	c1 e0 0c             	shl    $0xc,%eax
f0102843:	39 c2                	cmp    %eax,%edx
f0102845:	74 19                	je     f0102860 <mem_init+0x16bc>
f0102847:	68 1c 54 10 f0       	push   $0xf010541c
f010284c:	68 78 4e 10 f0       	push   $0xf0104e78
f0102851:	68 03 04 00 00       	push   $0x403
f0102856:	68 52 4e 10 f0       	push   $0xf0104e52
f010285b:	e8 4c d8 ff ff       	call   f01000ac <_panic>
	   kern_pgdir[0] = 0;
f0102860:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	   assert(pp0->pp_ref == 1);
f0102866:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010286b:	74 19                	je     f0102886 <mem_init+0x16e2>
f010286d:	68 8c 50 10 f0       	push   $0xf010508c
f0102872:	68 78 4e 10 f0       	push   $0xf0104e78
f0102877:	68 05 04 00 00       	push   $0x405
f010287c:	68 52 4e 10 f0       	push   $0xf0104e52
f0102881:	e8 26 d8 ff ff       	call   f01000ac <_panic>
	   pp0->pp_ref = 0;
f0102886:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	   // free the pages we took
	   page_free(pp0);
f010288c:	83 ec 0c             	sub    $0xc,%esp
f010288f:	53                   	push   %ebx
f0102890:	e8 06 e6 ff ff       	call   f0100e9b <page_free>

	   cprintf("check_page_installed_pgdir() succeeded!\n");
f0102895:	c7 04 24 38 59 10 f0 	movl   $0xf0105938,(%esp)
f010289c:	e8 30 08 00 00       	call   f01030d1 <cprintf>
	   cr0 &= ~(CR0_TS|CR0_EM);
	   lcr0(cr0);

	   // Some more checks, only possible after kern_pgdir is installed.
	   check_page_installed_pgdir();
}
f01028a1:	83 c4 10             	add    $0x10,%esp
f01028a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01028a7:	5b                   	pop    %ebx
f01028a8:	5e                   	pop    %esi
f01028a9:	5f                   	pop    %edi
f01028aa:	5d                   	pop    %ebp
f01028ab:	c3                   	ret    

f01028ac <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
	   void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01028ac:	55                   	push   %ebp
f01028ad:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01028af:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028b2:	0f 01 38             	invlpg (%eax)
	   // Flush the entry only if we're modifying the current address space.
	   // For now, there is only one address space, so always invalidate.
	   invlpg(va);
}
f01028b5:	5d                   	pop    %ebp
f01028b6:	c3                   	ret    

f01028b7 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01028b7:	55                   	push   %ebp
f01028b8:	89 e5                	mov    %esp,%ebp
f01028ba:	57                   	push   %edi
f01028bb:	56                   	push   %esi
f01028bc:	53                   	push   %ebx
f01028bd:	83 ec 2c             	sub    $0x2c,%esp
f01028c0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01028c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f01028c6:	89 c3                	mov    %eax,%ebx
f01028c8:	03 45 10             	add    0x10(%ebp),%eax
f01028cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	   {
			 pte_t* pte = NULL;
			 struct PageInfo* mapped_page = page_lookup (env -> env_pgdir, (void*) a, &pte);
f01028ce:	8d 75 e4             	lea    -0x1c(%ebp),%esi
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f01028d1:	eb 49                	jmp    f010291c <user_mem_check+0x65>
	   {
			 pte_t* pte = NULL;
f01028d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			 struct PageInfo* mapped_page = page_lookup (env -> env_pgdir, (void*) a, &pte);
f01028da:	83 ec 04             	sub    $0x4,%esp
f01028dd:	56                   	push   %esi
f01028de:	53                   	push   %ebx
f01028df:	ff 77 5c             	pushl  0x5c(%edi)
f01028e2:	e8 4d e7 ff ff       	call   f0101034 <page_lookup>

			 if ((!mapped_page) || !(*pte & (perm | PTE_P)) || ((uintptr_t)a >= ULIM))
f01028e7:	83 c4 10             	add    $0x10,%esp
f01028ea:	85 c0                	test   %eax,%eax
f01028ec:	74 15                	je     f0102903 <user_mem_check+0x4c>
f01028ee:	8b 55 14             	mov    0x14(%ebp),%edx
f01028f1:	83 ca 01             	or     $0x1,%edx
f01028f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028f7:	85 10                	test   %edx,(%eax)
f01028f9:	74 08                	je     f0102903 <user_mem_check+0x4c>
f01028fb:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102901:	76 0d                	jbe    f0102910 <user_mem_check+0x59>
			 {
				    user_mem_check_addr = (uintptr_t) a;
f0102903:	89 1d 7c 1f 17 f0    	mov    %ebx,0xf0171f7c
				    return -E_FAULT;
f0102909:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010290e:	eb 16                	jmp    f0102926 <user_mem_check+0x6f>
	   int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	   // LAB 3: Your code here.

	   for (char* a = (char*) va; a < (char*) va + len; a = ROUNDDOWN (a + PGSIZE, PGSIZE))
f0102910:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102916:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010291c:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010291f:	72 b2                	jb     f01028d3 <user_mem_check+0x1c>
			 {
				    user_mem_check_addr = (uintptr_t) a;
				    return -E_FAULT;
			 }
	   }
	   return 0;
f0102921:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102926:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102929:	5b                   	pop    %ebx
f010292a:	5e                   	pop    %esi
f010292b:	5f                   	pop    %edi
f010292c:	5d                   	pop    %ebp
f010292d:	c3                   	ret    

f010292e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
	   void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010292e:	55                   	push   %ebp
f010292f:	89 e5                	mov    %esp,%ebp
f0102931:	53                   	push   %ebx
f0102932:	83 ec 04             	sub    $0x4,%esp
f0102935:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102938:	8b 45 14             	mov    0x14(%ebp),%eax
f010293b:	83 c8 04             	or     $0x4,%eax
f010293e:	50                   	push   %eax
f010293f:	ff 75 10             	pushl  0x10(%ebp)
f0102942:	ff 75 0c             	pushl  0xc(%ebp)
f0102945:	53                   	push   %ebx
f0102946:	e8 6c ff ff ff       	call   f01028b7 <user_mem_check>
f010294b:	83 c4 10             	add    $0x10,%esp
f010294e:	85 c0                	test   %eax,%eax
f0102950:	79 21                	jns    f0102973 <user_mem_assert+0x45>
			 cprintf("[%08x] user_mem_check assertion failure for "
f0102952:	83 ec 04             	sub    $0x4,%esp
f0102955:	ff 35 7c 1f 17 f0    	pushl  0xf0171f7c
f010295b:	ff 73 48             	pushl  0x48(%ebx)
f010295e:	68 64 59 10 f0       	push   $0xf0105964
f0102963:	e8 69 07 00 00       	call   f01030d1 <cprintf>
						  "va %08x\n", env->env_id, user_mem_check_addr);
			 env_destroy(env);	// may not return
f0102968:	89 1c 24             	mov    %ebx,(%esp)
f010296b:	e8 4e 06 00 00       	call   f0102fbe <env_destroy>
f0102970:	83 c4 10             	add    $0x10,%esp
	   }
}
f0102973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102976:	c9                   	leave  
f0102977:	c3                   	ret    

f0102978 <region_alloc>:
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	if (len == 0)
f0102978:	85 c9                	test   %ecx,%ecx
f010297a:	0f 84 97 00 00 00    	je     f0102a17 <region_alloc+0x9f>
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102980:	55                   	push   %ebp
f0102981:	89 e5                	mov    %esp,%ebp
f0102983:	57                   	push   %edi
f0102984:	56                   	push   %esi
f0102985:	53                   	push   %ebx
f0102986:	83 ec 1c             	sub    $0x1c,%esp
f0102989:	89 d3                	mov    %edx,%ebx
f010298b:	89 c7                	mov    %eax,%edi
	//   (Watch out for corner-cases!)

	if (len == 0)
	return;

	uintptr_t h_addr = ROUNDUP ((uintptr_t) va + len, PGSIZE);
f010298d:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
	uintptr_t l_addr = ROUNDDOWN ((uintptr_t) va, PGSIZE);
f0102994:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010299a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010299f:	29 d8                	sub    %ebx,%eax
f01029a1:	c1 e8 0c             	shr    $0xc,%eax
f01029a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uintptr_t page_count = (h_addr - l_addr) / PGSIZE;

	for (int i = 0; i < page_count; i ++)
f01029a7:	be 00 00 00 00       	mov    $0x0,%esi
f01029ac:	eb 5d                	jmp    f0102a0b <region_alloc+0x93>
	{
		struct PageInfo* new_page = page_alloc(ALLOC_ZERO);
f01029ae:	83 ec 0c             	sub    $0xc,%esp
f01029b1:	6a 01                	push   $0x1
f01029b3:	e8 6c e4 ff ff       	call   f0100e24 <page_alloc>
		assert (new_page);
f01029b8:	83 c4 10             	add    $0x10,%esp
f01029bb:	85 c0                	test   %eax,%eax
f01029bd:	75 19                	jne    f01029d8 <region_alloc+0x60>
f01029bf:	68 99 59 10 f0       	push   $0xf0105999
f01029c4:	68 78 4e 10 f0       	push   $0xf0104e78
f01029c9:	68 28 01 00 00       	push   $0x128
f01029ce:	68 a2 59 10 f0       	push   $0xf01059a2
f01029d3:	e8 d4 d6 ff ff       	call   f01000ac <_panic>

		void* addr = (void *) (l_addr + (i * PGSIZE));
		if ((page_insert(e -> env_pgdir, new_page, addr, PTE_U | PTE_W)) < 0)
f01029d8:	6a 06                	push   $0x6
f01029da:	53                   	push   %ebx
f01029db:	50                   	push   %eax
f01029dc:	ff 77 5c             	pushl  0x5c(%edi)
f01029df:	e8 f8 e6 ff ff       	call   f01010dc <page_insert>
f01029e4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029ea:	83 c4 10             	add    $0x10,%esp
f01029ed:	85 c0                	test   %eax,%eax
f01029ef:	79 17                	jns    f0102a08 <region_alloc+0x90>
			panic ("Page Insert Failed \n");
f01029f1:	83 ec 04             	sub    $0x4,%esp
f01029f4:	68 ad 59 10 f0       	push   $0xf01059ad
f01029f9:	68 2c 01 00 00       	push   $0x12c
f01029fe:	68 a2 59 10 f0       	push   $0xf01059a2
f0102a03:	e8 a4 d6 ff ff       	call   f01000ac <_panic>

	uintptr_t h_addr = ROUNDUP ((uintptr_t) va + len, PGSIZE);
	uintptr_t l_addr = ROUNDDOWN ((uintptr_t) va, PGSIZE);
	uintptr_t page_count = (h_addr - l_addr) / PGSIZE;

	for (int i = 0; i < page_count; i ++)
f0102a08:	83 c6 01             	add    $0x1,%esi
f0102a0b:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102a0e:	75 9e                	jne    f01029ae <region_alloc+0x36>

		void* addr = (void *) (l_addr + (i * PGSIZE));
		if ((page_insert(e -> env_pgdir, new_page, addr, PTE_U | PTE_W)) < 0)
			panic ("Page Insert Failed \n");
	}
}
f0102a10:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a13:	5b                   	pop    %ebx
f0102a14:	5e                   	pop    %esi
f0102a15:	5f                   	pop    %edi
f0102a16:	5d                   	pop    %ebp
f0102a17:	f3 c3                	repz ret 

f0102a19 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102a19:	55                   	push   %ebp
f0102a1a:	89 e5                	mov    %esp,%ebp
f0102a1c:	8b 55 08             	mov    0x8(%ebp),%edx
f0102a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102a22:	85 d2                	test   %edx,%edx
f0102a24:	75 11                	jne    f0102a37 <envid2env+0x1e>
		*env_store = curenv;
f0102a26:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f0102a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102a2e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102a30:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a35:	eb 5e                	jmp    f0102a95 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102a37:	89 d0                	mov    %edx,%eax
f0102a39:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102a3e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102a41:	c1 e0 05             	shl    $0x5,%eax
f0102a44:	03 05 8c 1f 17 f0    	add    0xf0171f8c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102a4a:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102a4e:	74 05                	je     f0102a55 <envid2env+0x3c>
f0102a50:	3b 50 48             	cmp    0x48(%eax),%edx
f0102a53:	74 10                	je     f0102a65 <envid2env+0x4c>
		*env_store = 0;
f0102a55:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102a5e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102a63:	eb 30                	jmp    f0102a95 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102a65:	84 c9                	test   %cl,%cl
f0102a67:	74 22                	je     f0102a8b <envid2env+0x72>
f0102a69:	8b 15 88 1f 17 f0    	mov    0xf0171f88,%edx
f0102a6f:	39 d0                	cmp    %edx,%eax
f0102a71:	74 18                	je     f0102a8b <envid2env+0x72>
f0102a73:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102a76:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102a79:	74 10                	je     f0102a8b <envid2env+0x72>
		*env_store = 0;
f0102a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a7e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102a84:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102a89:	eb 0a                	jmp    f0102a95 <envid2env+0x7c>
	}

	*env_store = e;
f0102a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102a8e:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a95:	5d                   	pop    %ebp
f0102a96:	c3                   	ret    

f0102a97 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102a97:	55                   	push   %ebp
f0102a98:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102a9a:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102a9f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102aa2:	b8 23 00 00 00       	mov    $0x23,%eax
f0102aa7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102aa9:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102aab:	b8 10 00 00 00       	mov    $0x10,%eax
f0102ab0:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102ab2:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102ab4:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102ab6:	ea bd 2a 10 f0 08 00 	ljmp   $0x8,$0xf0102abd
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102abd:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ac2:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102ac5:	5d                   	pop    %ebp
f0102ac6:	c3                   	ret    

f0102ac7 <env_init>:
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.

	env_free_list = &envs[0];
f0102ac7:	8b 0d 8c 1f 17 f0    	mov    0xf0171f8c,%ecx
f0102acd:	89 0d 90 1f 17 f0    	mov    %ecx,0xf0171f90
	envs[0].env_id = 0;
f0102ad3:	c7 41 48 00 00 00 00 	movl   $0x0,0x48(%ecx)
f0102ada:	8d 41 60             	lea    0x60(%ecx),%eax
f0102add:	8d 91 00 80 01 00    	lea    0x18000(%ecx),%edx

	for (int i = 1; i < NENV; i++)
	{
		envs [i-1].env_link = &envs[i];
f0102ae3:	89 40 e4             	mov    %eax,-0x1c(%eax)
		envs [i].env_id = 0;
f0102ae6:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
f0102aed:	83 c0 60             	add    $0x60,%eax
	// LAB 3: Your code here.

	env_free_list = &envs[0];
	envs[0].env_id = 0;

	for (int i = 1; i < NENV; i++)
f0102af0:	39 d0                	cmp    %edx,%eax
f0102af2:	75 ef                	jne    f0102ae3 <env_init+0x1c>
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102af4:	55                   	push   %ebp
f0102af5:	89 e5                	mov    %esp,%ebp
	{
		envs [i-1].env_link = &envs[i];
		envs [i].env_id = 0;
	}

	envs [NENV - 1].env_link = NULL;
f0102af7:	c7 81 e4 7f 01 00 00 	movl   $0x0,0x17fe4(%ecx)
f0102afe:	00 00 00 
	// Per-CPU part of the initialization
	env_init_percpu();
f0102b01:	e8 91 ff ff ff       	call   f0102a97 <env_init_percpu>
}
f0102b06:	5d                   	pop    %ebp
f0102b07:	c3                   	ret    

f0102b08 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102b08:	55                   	push   %ebp
f0102b09:	89 e5                	mov    %esp,%ebp
f0102b0b:	57                   	push   %edi
f0102b0c:	56                   	push   %esi
f0102b0d:	53                   	push   %ebx
f0102b0e:	83 ec 1c             	sub    $0x1c,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102b11:	8b 1d 90 1f 17 f0    	mov    0xf0171f90,%ebx
f0102b17:	85 db                	test   %ebx,%ebx
f0102b19:	0f 84 55 01 00 00    	je     f0102c74 <env_alloc+0x16c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102b1f:	83 ec 0c             	sub    $0xc,%esp
f0102b22:	6a 01                	push   $0x1
f0102b24:	e8 fb e2 ff ff       	call   f0100e24 <page_alloc>
f0102b29:	89 c7                	mov    %eax,%edi
f0102b2b:	83 c4 10             	add    $0x10,%esp
f0102b2e:	85 c0                	test   %eax,%eax
f0102b30:	0f 84 45 01 00 00    	je     f0102c7b <env_alloc+0x173>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b36:	2b 05 50 2c 17 f0    	sub    0xf0172c50,%eax
f0102b3c:	c1 f8 03             	sar    $0x3,%eax
f0102b3f:	c1 e0 0c             	shl    $0xc,%eax
f0102b42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b45:	c1 e8 0c             	shr    $0xc,%eax
f0102b48:	3b 05 48 2c 17 f0    	cmp    0xf0172c48,%eax
f0102b4e:	72 14                	jb     f0102b64 <env_alloc+0x5c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b50:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b53:	68 b8 51 10 f0       	push   $0xf01051b8
f0102b58:	6a 56                	push   $0x56
f0102b5a:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102b5f:	e8 48 d5 ff ff       	call   f01000ac <_panic>
	return (void *)(pa + KERNBASE);
f0102b64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b67:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	pde_t* e_pgdir = page2kva (p);
	memcpy (e_pgdir, kern_pgdir, PGSIZE);
f0102b6d:	83 ec 04             	sub    $0x4,%esp
f0102b70:	68 00 10 00 00       	push   $0x1000
f0102b75:	ff 35 4c 2c 17 f0    	pushl  0xf0172c4c
f0102b7b:	56                   	push   %esi
f0102b7c:	e8 8b 19 00 00       	call   f010450c <memcpy>
	p -> pp_ref ++;
f0102b81:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	e -> env_pgdir = e_pgdir;
f0102b86:	89 73 5c             	mov    %esi,0x5c(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b89:	83 c4 10             	add    $0x10,%esp
f0102b8c:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102b92:	77 15                	ja     f0102ba9 <env_alloc+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b94:	56                   	push   %esi
f0102b95:	68 c4 52 10 f0       	push   $0xf01052c4
f0102b9a:	68 c7 00 00 00       	push   $0xc7
f0102b9f:	68 a2 59 10 f0       	push   $0xf01059a2
f0102ba4:	e8 03 d5 ff ff       	call   f01000ac <_panic>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102ba9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bac:	83 c8 05             	or     $0x5,%eax
f0102baf:	89 86 f4 0e 00 00    	mov    %eax,0xef4(%esi)
//	cprintf("SET UP VM!!! \n");
cprintf("env_pgdir: %x\n", e_pgdir);
f0102bb5:	83 ec 08             	sub    $0x8,%esp
f0102bb8:	56                   	push   %esi
f0102bb9:	68 c2 59 10 f0       	push   $0xf01059c2
f0102bbe:	e8 0e 05 00 00       	call   f01030d1 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102bc3:	8b 43 48             	mov    0x48(%ebx),%eax
f0102bc6:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102bcb:	83 c4 0c             	add    $0xc,%esp
f0102bce:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102bd3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102bd8:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102bdb:	89 da                	mov    %ebx,%edx
f0102bdd:	2b 15 8c 1f 17 f0    	sub    0xf0171f8c,%edx
f0102be3:	c1 fa 05             	sar    $0x5,%edx
f0102be6:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102bec:	09 d0                	or     %edx,%eax
f0102bee:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bf4:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102bf7:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102bfe:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102c05:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102c0c:	6a 44                	push   $0x44
f0102c0e:	6a 00                	push   $0x0
f0102c10:	53                   	push   %ebx
f0102c11:	e8 41 18 00 00       	call   f0104457 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102c16:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102c1c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102c22:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102c28:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102c2f:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102c35:	8b 43 44             	mov    0x44(%ebx),%eax
f0102c38:	a3 90 1f 17 f0       	mov    %eax,0xf0171f90
	*newenv_store = e;
f0102c3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c40:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c42:	8b 53 48             	mov    0x48(%ebx),%edx
f0102c45:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f0102c4a:	83 c4 10             	add    $0x10,%esp
f0102c4d:	85 c0                	test   %eax,%eax
f0102c4f:	74 05                	je     f0102c56 <env_alloc+0x14e>
f0102c51:	8b 40 48             	mov    0x48(%eax),%eax
f0102c54:	eb 05                	jmp    f0102c5b <env_alloc+0x153>
f0102c56:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c5b:	83 ec 04             	sub    $0x4,%esp
f0102c5e:	52                   	push   %edx
f0102c5f:	50                   	push   %eax
f0102c60:	68 d1 59 10 f0       	push   $0xf01059d1
f0102c65:	e8 67 04 00 00       	call   f01030d1 <cprintf>
	return 0;
f0102c6a:	83 c4 10             	add    $0x10,%esp
f0102c6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c72:	eb 0c                	jmp    f0102c80 <env_alloc+0x178>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102c74:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102c79:	eb 05                	jmp    f0102c80 <env_alloc+0x178>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102c7b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c83:	5b                   	pop    %ebx
f0102c84:	5e                   	pop    %esi
f0102c85:	5f                   	pop    %edi
f0102c86:	5d                   	pop    %ebp
f0102c87:	c3                   	ret    

f0102c88 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102c88:	55                   	push   %ebp
f0102c89:	89 e5                	mov    %esp,%ebp
f0102c8b:	57                   	push   %edi
f0102c8c:	56                   	push   %esi
f0102c8d:	53                   	push   %ebx
f0102c8e:	83 ec 34             	sub    $0x34,%esp
f0102c91:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env* new_env = NULL;
f0102c94:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if ((env_alloc(&new_env, 0)) < 0)
f0102c9b:	6a 00                	push   $0x0
f0102c9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102ca0:	50                   	push   %eax
f0102ca1:	e8 62 fe ff ff       	call   f0102b08 <env_alloc>
f0102ca6:	83 c4 10             	add    $0x10,%esp
f0102ca9:	85 c0                	test   %eax,%eax
f0102cab:	79 17                	jns    f0102cc4 <env_create+0x3c>
		panic ("Environment Allocation Failed \n");
f0102cad:	83 ec 04             	sub    $0x4,%esp
f0102cb0:	68 30 5a 10 f0       	push   $0xf0105a30
f0102cb5:	68 99 01 00 00       	push   $0x199
f0102cba:	68 a2 59 10 f0       	push   $0xf01059a2
f0102cbf:	e8 e8 d3 ff ff       	call   f01000ac <_panic>
	
	load_icode (new_env, binary);
f0102cc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.

	struct Elf* p_binary = (struct Elf*) binary;

	if (p_binary -> e_magic != ELF_MAGIC)
f0102cca:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102cd0:	74 17                	je     f0102ce9 <env_create+0x61>
		panic ("Invalid ELF File \n");
f0102cd2:	83 ec 04             	sub    $0x4,%esp
f0102cd5:	68 e6 59 10 f0       	push   $0xf01059e6
f0102cda:	68 6a 01 00 00       	push   $0x16a
f0102cdf:	68 a2 59 10 f0       	push   $0xf01059a2
f0102ce4:	e8 c3 d3 ff ff       	call   f01000ac <_panic>

	lcr3 (PADDR(e -> env_pgdir));
f0102ce9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cec:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cef:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cf4:	77 15                	ja     f0102d0b <env_create+0x83>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf6:	50                   	push   %eax
f0102cf7:	68 c4 52 10 f0       	push   $0xf01052c4
f0102cfc:	68 6c 01 00 00       	push   $0x16c
f0102d01:	68 a2 59 10 f0       	push   $0xf01059a2
f0102d06:	e8 a1 d3 ff ff       	call   f01000ac <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d0b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d10:	0f 22 d8             	mov    %eax,%cr3
	
	struct Proghdr* ph_browse = (struct Proghdr*) (binary + p_binary -> e_phoff);
f0102d13:	89 fb                	mov    %edi,%ebx
f0102d15:	03 5f 1c             	add    0x1c(%edi),%ebx
	struct Proghdr* ph_entries = ph_browse + p_binary -> e_phnum;
f0102d18:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102d1c:	c1 e6 05             	shl    $0x5,%esi
f0102d1f:	01 de                	add    %ebx,%esi
f0102d21:	eb 70                	jmp    f0102d93 <env_create+0x10b>

	for (; ph_browse < ph_entries ; ph_browse ++)
	{
		if (ph_browse -> p_type != ELF_PROG_LOAD)
f0102d23:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102d26:	75 68                	jne    f0102d90 <env_create+0x108>
			continue;
		
		if (ph_browse -> p_filesz > ph_browse -> p_memsz)
f0102d28:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102d2b:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102d2e:	76 17                	jbe    f0102d47 <env_create+0xbf>
			panic("Error in ElF File \n");
f0102d30:	83 ec 04             	sub    $0x4,%esp
f0102d33:	68 f9 59 10 f0       	push   $0xf01059f9
f0102d38:	68 77 01 00 00       	push   $0x177
f0102d3d:	68 a2 59 10 f0       	push   $0xf01059a2
f0102d42:	e8 65 d3 ff ff       	call   f01000ac <_panic>

		region_alloc (e, (void*)ph_browse -> p_va, ph_browse -> p_memsz);
f0102d47:	8b 53 08             	mov    0x8(%ebx),%edx
f0102d4a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d4d:	e8 26 fc ff ff       	call   f0102978 <region_alloc>
		memset ((void*)ph_browse -> p_va ,0 , ph_browse -> p_memsz);
f0102d52:	83 ec 04             	sub    $0x4,%esp
f0102d55:	ff 73 14             	pushl  0x14(%ebx)
f0102d58:	6a 00                	push   $0x0
f0102d5a:	ff 73 08             	pushl  0x8(%ebx)
f0102d5d:	e8 f5 16 00 00       	call   f0104457 <memset>
		void* seg_offset = (void*) (binary + ph_browse -> p_offset);
		memcpy ((void*)ph_browse -> p_va, seg_offset, ph_browse -> p_filesz);
f0102d62:	83 c4 0c             	add    $0xc,%esp
f0102d65:	ff 73 10             	pushl  0x10(%ebx)
f0102d68:	89 f8                	mov    %edi,%eax
f0102d6a:	03 43 04             	add    0x4(%ebx),%eax
f0102d6d:	50                   	push   %eax
f0102d6e:	ff 73 08             	pushl  0x8(%ebx)
f0102d71:	e8 96 17 00 00       	call   f010450c <memcpy>
		memset ((void*)ph_browse -> p_va + ph_browse -> p_filesz , 0, (ph_browse -> p_memsz - ph_browse -> p_filesz));
f0102d76:	8b 43 10             	mov    0x10(%ebx),%eax
f0102d79:	83 c4 0c             	add    $0xc,%esp
f0102d7c:	8b 53 14             	mov    0x14(%ebx),%edx
f0102d7f:	29 c2                	sub    %eax,%edx
f0102d81:	52                   	push   %edx
f0102d82:	6a 00                	push   $0x0
f0102d84:	03 43 08             	add    0x8(%ebx),%eax
f0102d87:	50                   	push   %eax
f0102d88:	e8 ca 16 00 00       	call   f0104457 <memset>
f0102d8d:	83 c4 10             	add    $0x10,%esp
	lcr3 (PADDR(e -> env_pgdir));
	
	struct Proghdr* ph_browse = (struct Proghdr*) (binary + p_binary -> e_phoff);
	struct Proghdr* ph_entries = ph_browse + p_binary -> e_phnum;

	for (; ph_browse < ph_entries ; ph_browse ++)
f0102d90:	83 c3 20             	add    $0x20,%ebx
f0102d93:	39 de                	cmp    %ebx,%esi
f0102d95:	77 8c                	ja     f0102d23 <env_create+0x9b>
		void* seg_offset = (void*) (binary + ph_browse -> p_offset);
		memcpy ((void*)ph_browse -> p_va, seg_offset, ph_browse -> p_filesz);
		memset ((void*)ph_browse -> p_va + ph_browse -> p_filesz , 0, (ph_browse -> p_memsz - ph_browse -> p_filesz));
	}

	e -> env_tf.tf_eip = p_binary -> e_entry;
f0102d97:	8b 47 18             	mov    0x18(%edi),%eax
f0102d9a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d9d:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.

	region_alloc (e, (void*) (USTACKTOP - PGSIZE), PGSIZE);
f0102da0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102da5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102daa:	89 f8                	mov    %edi,%eax
f0102dac:	e8 c7 fb ff ff       	call   f0102978 <region_alloc>
	memset ((void*) (USTACKTOP - PGSIZE), 0, PGSIZE);
f0102db1:	83 ec 04             	sub    $0x4,%esp
f0102db4:	68 00 10 00 00       	push   $0x1000
f0102db9:	6a 00                	push   $0x0
f0102dbb:	68 00 d0 bf ee       	push   $0xeebfd000
f0102dc0:	e8 92 16 00 00       	call   f0104457 <memset>

	lcr3(PADDR(kern_pgdir));
f0102dc5:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dca:	83 c4 10             	add    $0x10,%esp
f0102dcd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102dd2:	77 15                	ja     f0102de9 <env_create+0x161>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd4:	50                   	push   %eax
f0102dd5:	68 c4 52 10 f0       	push   $0xf01052c4
f0102dda:	68 89 01 00 00       	push   $0x189
f0102ddf:	68 a2 59 10 f0       	push   $0xf01059a2
f0102de4:	e8 c3 d2 ff ff       	call   f01000ac <_panic>
f0102de9:	05 00 00 00 10       	add    $0x10000000,%eax
f0102dee:	0f 22 d8             	mov    %eax,%cr3
	struct Env* new_env = NULL;
	if ((env_alloc(&new_env, 0)) < 0)
		panic ("Environment Allocation Failed \n");
	
	load_icode (new_env, binary);
	new_env -> env_type = type;
f0102df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102df4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102df7:	89 50 50             	mov    %edx,0x50(%eax)
}
f0102dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dfd:	5b                   	pop    %ebx
f0102dfe:	5e                   	pop    %esi
f0102dff:	5f                   	pop    %edi
f0102e00:	5d                   	pop    %ebp
f0102e01:	c3                   	ret    

f0102e02 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102e02:	55                   	push   %ebp
f0102e03:	89 e5                	mov    %esp,%ebp
f0102e05:	57                   	push   %edi
f0102e06:	56                   	push   %esi
f0102e07:	53                   	push   %ebx
f0102e08:	83 ec 1c             	sub    $0x1c,%esp
f0102e0b:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102e0e:	8b 15 88 1f 17 f0    	mov    0xf0171f88,%edx
f0102e14:	39 fa                	cmp    %edi,%edx
f0102e16:	75 29                	jne    f0102e41 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102e18:	a1 4c 2c 17 f0       	mov    0xf0172c4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e22:	77 15                	ja     f0102e39 <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e24:	50                   	push   %eax
f0102e25:	68 c4 52 10 f0       	push   $0xf01052c4
f0102e2a:	68 ad 01 00 00       	push   $0x1ad
f0102e2f:	68 a2 59 10 f0       	push   $0xf01059a2
f0102e34:	e8 73 d2 ff ff       	call   f01000ac <_panic>
f0102e39:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e3e:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102e41:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102e44:	85 d2                	test   %edx,%edx
f0102e46:	74 05                	je     f0102e4d <env_free+0x4b>
f0102e48:	8b 42 48             	mov    0x48(%edx),%eax
f0102e4b:	eb 05                	jmp    f0102e52 <env_free+0x50>
f0102e4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e52:	83 ec 04             	sub    $0x4,%esp
f0102e55:	51                   	push   %ecx
f0102e56:	50                   	push   %eax
f0102e57:	68 0d 5a 10 f0       	push   $0xf0105a0d
f0102e5c:	e8 70 02 00 00       	call   f01030d1 <cprintf>
f0102e61:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102e64:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102e6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102e6e:	89 d0                	mov    %edx,%eax
f0102e70:	c1 e0 02             	shl    $0x2,%eax
f0102e73:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102e76:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e79:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102e7c:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102e82:	0f 84 a8 00 00 00    	je     f0102f30 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102e88:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e8e:	89 f0                	mov    %esi,%eax
f0102e90:	c1 e8 0c             	shr    $0xc,%eax
f0102e93:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e96:	39 05 48 2c 17 f0    	cmp    %eax,0xf0172c48
f0102e9c:	77 15                	ja     f0102eb3 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e9e:	56                   	push   %esi
f0102e9f:	68 b8 51 10 f0       	push   $0xf01051b8
f0102ea4:	68 bc 01 00 00       	push   $0x1bc
f0102ea9:	68 a2 59 10 f0       	push   $0xf01059a2
f0102eae:	e8 f9 d1 ff ff       	call   f01000ac <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102eb3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102eb6:	c1 e0 16             	shl    $0x16,%eax
f0102eb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102ebc:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102ec1:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102ec8:	01 
f0102ec9:	74 17                	je     f0102ee2 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102ecb:	83 ec 08             	sub    $0x8,%esp
f0102ece:	89 d8                	mov    %ebx,%eax
f0102ed0:	c1 e0 0c             	shl    $0xc,%eax
f0102ed3:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102ed6:	50                   	push   %eax
f0102ed7:	ff 77 5c             	pushl  0x5c(%edi)
f0102eda:	e8 bb e1 ff ff       	call   f010109a <page_remove>
f0102edf:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102ee2:	83 c3 01             	add    $0x1,%ebx
f0102ee5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102eeb:	75 d4                	jne    f0102ec1 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102eed:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102ef0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ef3:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102efa:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102efd:	3b 05 48 2c 17 f0    	cmp    0xf0172c48,%eax
f0102f03:	72 14                	jb     f0102f19 <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102f05:	83 ec 04             	sub    $0x4,%esp
f0102f08:	68 e8 52 10 f0       	push   $0xf01052e8
f0102f0d:	6a 4f                	push   $0x4f
f0102f0f:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102f14:	e8 93 d1 ff ff       	call   f01000ac <_panic>
		page_decref(pa2page(pa));
f0102f19:	83 ec 0c             	sub    $0xc,%esp
f0102f1c:	a1 50 2c 17 f0       	mov    0xf0172c50,%eax
f0102f21:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f24:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102f27:	50                   	push   %eax
f0102f28:	e8 ca df ff ff       	call   f0100ef7 <page_decref>
f0102f2d:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102f30:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102f34:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f37:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102f3c:	0f 85 29 ff ff ff    	jne    f0102e6b <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102f42:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f45:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f4a:	77 15                	ja     f0102f61 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f4c:	50                   	push   %eax
f0102f4d:	68 c4 52 10 f0       	push   $0xf01052c4
f0102f52:	68 ca 01 00 00       	push   $0x1ca
f0102f57:	68 a2 59 10 f0       	push   $0xf01059a2
f0102f5c:	e8 4b d1 ff ff       	call   f01000ac <_panic>
	e->env_pgdir = 0;
f0102f61:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f68:	05 00 00 00 10       	add    $0x10000000,%eax
f0102f6d:	c1 e8 0c             	shr    $0xc,%eax
f0102f70:	3b 05 48 2c 17 f0    	cmp    0xf0172c48,%eax
f0102f76:	72 14                	jb     f0102f8c <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102f78:	83 ec 04             	sub    $0x4,%esp
f0102f7b:	68 e8 52 10 f0       	push   $0xf01052e8
f0102f80:	6a 4f                	push   $0x4f
f0102f82:	68 5e 4e 10 f0       	push   $0xf0104e5e
f0102f87:	e8 20 d1 ff ff       	call   f01000ac <_panic>
	page_decref(pa2page(pa));
f0102f8c:	83 ec 0c             	sub    $0xc,%esp
f0102f8f:	8b 15 50 2c 17 f0    	mov    0xf0172c50,%edx
f0102f95:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102f98:	50                   	push   %eax
f0102f99:	e8 59 df ff ff       	call   f0100ef7 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102f9e:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102fa5:	a1 90 1f 17 f0       	mov    0xf0171f90,%eax
f0102faa:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102fad:	89 3d 90 1f 17 f0    	mov    %edi,0xf0171f90
}
f0102fb3:	83 c4 10             	add    $0x10,%esp
f0102fb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fb9:	5b                   	pop    %ebx
f0102fba:	5e                   	pop    %esi
f0102fbb:	5f                   	pop    %edi
f0102fbc:	5d                   	pop    %ebp
f0102fbd:	c3                   	ret    

f0102fbe <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102fbe:	55                   	push   %ebp
f0102fbf:	89 e5                	mov    %esp,%ebp
f0102fc1:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102fc4:	ff 75 08             	pushl  0x8(%ebp)
f0102fc7:	e8 36 fe ff ff       	call   f0102e02 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102fcc:	c7 04 24 50 5a 10 f0 	movl   $0xf0105a50,(%esp)
f0102fd3:	e8 f9 00 00 00       	call   f01030d1 <cprintf>
f0102fd8:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102fdb:	83 ec 0c             	sub    $0xc,%esp
f0102fde:	6a 00                	push   $0x0
f0102fe0:	e8 18 d8 ff ff       	call   f01007fd <monitor>
f0102fe5:	83 c4 10             	add    $0x10,%esp
f0102fe8:	eb f1                	jmp    f0102fdb <env_destroy+0x1d>

f0102fea <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102fea:	55                   	push   %ebp
f0102feb:	89 e5                	mov    %esp,%ebp
f0102fed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0102ff0:	8b 65 08             	mov    0x8(%ebp),%esp
f0102ff3:	61                   	popa   
f0102ff4:	07                   	pop    %es
f0102ff5:	1f                   	pop    %ds
f0102ff6:	83 c4 08             	add    $0x8,%esp
f0102ff9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102ffa:	68 23 5a 10 f0       	push   $0xf0105a23
f0102fff:	68 f3 01 00 00       	push   $0x1f3
f0103004:	68 a2 59 10 f0       	push   $0xf01059a2
f0103009:	e8 9e d0 ff ff       	call   f01000ac <_panic>

f010300e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010300e:	55                   	push   %ebp
f010300f:	89 e5                	mov    %esp,%ebp
f0103011:	83 ec 08             	sub    $0x8,%esp
f0103014:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	
	if (curenv != NULL)
f0103017:	8b 15 88 1f 17 f0    	mov    0xf0171f88,%edx
f010301d:	85 d2                	test   %edx,%edx
f010301f:	74 07                	je     f0103028 <env_run+0x1a>
		curenv -> env_status = ENV_RUNNABLE;
f0103021:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	
	curenv = e;
f0103028:	a3 88 1f 17 f0       	mov    %eax,0xf0171f88
	e -> env_status = ENV_RUNNING;
f010302d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e-> env_runs ++;
f0103034:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e -> env_pgdir));
f0103038:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010303b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103041:	77 15                	ja     f0103058 <env_run+0x4a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103043:	52                   	push   %edx
f0103044:	68 c4 52 10 f0       	push   $0xf01052c4
f0103049:	68 18 02 00 00       	push   $0x218
f010304e:	68 a2 59 10 f0       	push   $0xf01059a2
f0103053:	e8 54 d0 ff ff       	call   f01000ac <_panic>
f0103058:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010305e:	0f 22 da             	mov    %edx,%cr3

	env_pop_tf (&e -> env_tf);
f0103061:	83 ec 0c             	sub    $0xc,%esp
f0103064:	50                   	push   %eax
f0103065:	e8 80 ff ff ff       	call   f0102fea <env_pop_tf>

f010306a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010306a:	55                   	push   %ebp
f010306b:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010306d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103072:	8b 45 08             	mov    0x8(%ebp),%eax
f0103075:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103076:	ba 71 00 00 00       	mov    $0x71,%edx
f010307b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010307c:	0f b6 c0             	movzbl %al,%eax
}
f010307f:	5d                   	pop    %ebp
f0103080:	c3                   	ret    

f0103081 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103081:	55                   	push   %ebp
f0103082:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103084:	ba 70 00 00 00       	mov    $0x70,%edx
f0103089:	8b 45 08             	mov    0x8(%ebp),%eax
f010308c:	ee                   	out    %al,(%dx)
f010308d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103092:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103095:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103096:	5d                   	pop    %ebp
f0103097:	c3                   	ret    

f0103098 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103098:	55                   	push   %ebp
f0103099:	89 e5                	mov    %esp,%ebp
f010309b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010309e:	ff 75 08             	pushl  0x8(%ebp)
f01030a1:	e8 7b d5 ff ff       	call   f0100621 <cputchar>
	*cnt++;
}
f01030a6:	83 c4 10             	add    $0x10,%esp
f01030a9:	c9                   	leave  
f01030aa:	c3                   	ret    

f01030ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01030ab:	55                   	push   %ebp
f01030ac:	89 e5                	mov    %esp,%ebp
f01030ae:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01030b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01030b8:	ff 75 0c             	pushl  0xc(%ebp)
f01030bb:	ff 75 08             	pushl  0x8(%ebp)
f01030be:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01030c1:	50                   	push   %eax
f01030c2:	68 98 30 10 f0       	push   $0xf0103098
f01030c7:	e8 1f 0d 00 00       	call   f0103deb <vprintfmt>
	return cnt;
}
f01030cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030cf:	c9                   	leave  
f01030d0:	c3                   	ret    

f01030d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01030d1:	55                   	push   %ebp
f01030d2:	89 e5                	mov    %esp,%ebp
f01030d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01030d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01030da:	50                   	push   %eax
f01030db:	ff 75 08             	pushl  0x8(%ebp)
f01030de:	e8 c8 ff ff ff       	call   f01030ab <vcprintf>
	va_end(ap);

	return cnt;
}
f01030e3:	c9                   	leave  
f01030e4:	c3                   	ret    

f01030e5 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
	   void
trap_init_percpu(void)
{
f01030e5:	55                   	push   %ebp
f01030e6:	89 e5                	mov    %esp,%ebp
	   // Setup a TSS so that we get the right stack
	   // when we trap to the kernel.
	   ts.ts_esp0 = KSTACKTOP;
f01030e8:	b8 c0 27 17 f0       	mov    $0xf01727c0,%eax
f01030ed:	c7 05 c4 27 17 f0 00 	movl   $0xf0000000,0xf01727c4
f01030f4:	00 00 f0 
	   ts.ts_ss0 = GD_KD;
f01030f7:	66 c7 05 c8 27 17 f0 	movw   $0x10,0xf01727c8
f01030fe:	10 00 
	   ts.ts_iomb = sizeof(struct Taskstate);
f0103100:	66 c7 05 26 28 17 f0 	movw   $0x68,0xf0172826
f0103107:	68 00 

	   // Initialize the TSS slot of the gdt.
	   gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103109:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f0103110:	67 00 
f0103112:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0103118:	89 c2                	mov    %eax,%edx
f010311a:	c1 ea 10             	shr    $0x10,%edx
f010311d:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103123:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f010312a:	c1 e8 18             	shr    $0x18,%eax
f010312d:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
				    sizeof(struct Taskstate) - 1, 0);
	   gdt[GD_TSS0 >> 3].sd_s = 0;
f0103132:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103139:	b8 28 00 00 00       	mov    $0x28,%eax
f010313e:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103141:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103146:	0f 01 18             	lidtl  (%eax)
	   // bottom three bits are special; we leave them 0)
	   ltr(GD_TSS0);

	   // Load the IDT
	   lidt(&idt_pd);
}
f0103149:	5d                   	pop    %ebp
f010314a:	c3                   	ret    

f010314b <trap_init>:
}


	   void
trap_init(void)
{
f010314b:	55                   	push   %ebp
f010314c:	89 e5                	mov    %esp,%ebp
	   extern struct Segdesc gdt[];

	   // LAB 3: Your code here.

	   SETGATE(idt[T_DIVIDE], true, GD_KT, divide_exception, 0);
f010314e:	b8 2c 38 10 f0       	mov    $0xf010382c,%eax
f0103153:	66 a3 a0 1f 17 f0    	mov    %ax,0xf0171fa0
f0103159:	66 c7 05 a2 1f 17 f0 	movw   $0x8,0xf0171fa2
f0103160:	08 00 
f0103162:	c6 05 a4 1f 17 f0 00 	movb   $0x0,0xf0171fa4
f0103169:	c6 05 a5 1f 17 f0 8f 	movb   $0x8f,0xf0171fa5
f0103170:	c1 e8 10             	shr    $0x10,%eax
f0103173:	66 a3 a6 1f 17 f0    	mov    %ax,0xf0171fa6
	   SETGATE(idt[T_DEBUG], true, GD_KT, debug_exception, 0);
f0103179:	b8 32 38 10 f0       	mov    $0xf0103832,%eax
f010317e:	66 a3 a8 1f 17 f0    	mov    %ax,0xf0171fa8
f0103184:	66 c7 05 aa 1f 17 f0 	movw   $0x8,0xf0171faa
f010318b:	08 00 
f010318d:	c6 05 ac 1f 17 f0 00 	movb   $0x0,0xf0171fac
f0103194:	c6 05 ad 1f 17 f0 8f 	movb   $0x8f,0xf0171fad
f010319b:	c1 e8 10             	shr    $0x10,%eax
f010319e:	66 a3 ae 1f 17 f0    	mov    %ax,0xf0171fae
	   SETGATE(idt[T_NMI], false, GD_KT, nmi_interupt, 0);
f01031a4:	b8 38 38 10 f0       	mov    $0xf0103838,%eax
f01031a9:	66 a3 b0 1f 17 f0    	mov    %ax,0xf0171fb0
f01031af:	66 c7 05 b2 1f 17 f0 	movw   $0x8,0xf0171fb2
f01031b6:	08 00 
f01031b8:	c6 05 b4 1f 17 f0 00 	movb   $0x0,0xf0171fb4
f01031bf:	c6 05 b5 1f 17 f0 8e 	movb   $0x8e,0xf0171fb5
f01031c6:	c1 e8 10             	shr    $0x10,%eax
f01031c9:	66 a3 b6 1f 17 f0    	mov    %ax,0xf0171fb6
	   SETGATE(idt[T_BRKPT], true, GD_KT, breakpoint_exception, 3);
f01031cf:	b8 3e 38 10 f0       	mov    $0xf010383e,%eax
f01031d4:	66 a3 b8 1f 17 f0    	mov    %ax,0xf0171fb8
f01031da:	66 c7 05 ba 1f 17 f0 	movw   $0x8,0xf0171fba
f01031e1:	08 00 
f01031e3:	c6 05 bc 1f 17 f0 00 	movb   $0x0,0xf0171fbc
f01031ea:	c6 05 bd 1f 17 f0 ef 	movb   $0xef,0xf0171fbd
f01031f1:	c1 e8 10             	shr    $0x10,%eax
f01031f4:	66 a3 be 1f 17 f0    	mov    %ax,0xf0171fbe
	   SETGATE(idt[T_OFLOW], true, GD_KT, overflow_exception, 0);
f01031fa:	b8 44 38 10 f0       	mov    $0xf0103844,%eax
f01031ff:	66 a3 c0 1f 17 f0    	mov    %ax,0xf0171fc0
f0103205:	66 c7 05 c2 1f 17 f0 	movw   $0x8,0xf0171fc2
f010320c:	08 00 
f010320e:	c6 05 c4 1f 17 f0 00 	movb   $0x0,0xf0171fc4
f0103215:	c6 05 c5 1f 17 f0 8f 	movb   $0x8f,0xf0171fc5
f010321c:	c1 e8 10             	shr    $0x10,%eax
f010321f:	66 a3 c6 1f 17 f0    	mov    %ax,0xf0171fc6
	   SETGATE(idt[T_BOUND], true, GD_KT, bounds_check_exception, 0);
f0103225:	b8 4a 38 10 f0       	mov    $0xf010384a,%eax
f010322a:	66 a3 c8 1f 17 f0    	mov    %ax,0xf0171fc8
f0103230:	66 c7 05 ca 1f 17 f0 	movw   $0x8,0xf0171fca
f0103237:	08 00 
f0103239:	c6 05 cc 1f 17 f0 00 	movb   $0x0,0xf0171fcc
f0103240:	c6 05 cd 1f 17 f0 8f 	movb   $0x8f,0xf0171fcd
f0103247:	c1 e8 10             	shr    $0x10,%eax
f010324a:	66 a3 ce 1f 17 f0    	mov    %ax,0xf0171fce
	   SETGATE(idt[T_ILLOP], true, GD_KT, illegal_opcode_exception, 0);
f0103250:	b8 50 38 10 f0       	mov    $0xf0103850,%eax
f0103255:	66 a3 d0 1f 17 f0    	mov    %ax,0xf0171fd0
f010325b:	66 c7 05 d2 1f 17 f0 	movw   $0x8,0xf0171fd2
f0103262:	08 00 
f0103264:	c6 05 d4 1f 17 f0 00 	movb   $0x0,0xf0171fd4
f010326b:	c6 05 d5 1f 17 f0 8f 	movb   $0x8f,0xf0171fd5
f0103272:	c1 e8 10             	shr    $0x10,%eax
f0103275:	66 a3 d6 1f 17 f0    	mov    %ax,0xf0171fd6
	   SETGATE(idt[T_DEVICE], true, GD_KT, coprocessor_exception, 0);
f010327b:	b8 56 38 10 f0       	mov    $0xf0103856,%eax
f0103280:	66 a3 d8 1f 17 f0    	mov    %ax,0xf0171fd8
f0103286:	66 c7 05 da 1f 17 f0 	movw   $0x8,0xf0171fda
f010328d:	08 00 
f010328f:	c6 05 dc 1f 17 f0 00 	movb   $0x0,0xf0171fdc
f0103296:	c6 05 dd 1f 17 f0 8f 	movb   $0x8f,0xf0171fdd
f010329d:	c1 e8 10             	shr    $0x10,%eax
f01032a0:	66 a3 de 1f 17 f0    	mov    %ax,0xf0171fde
	   SETGATE(idt[T_DBLFLT], false, GD_KT, double_fault_exception, 0);
f01032a6:	b8 5c 38 10 f0       	mov    $0xf010385c,%eax
f01032ab:	66 a3 e0 1f 17 f0    	mov    %ax,0xf0171fe0
f01032b1:	66 c7 05 e2 1f 17 f0 	movw   $0x8,0xf0171fe2
f01032b8:	08 00 
f01032ba:	c6 05 e4 1f 17 f0 00 	movb   $0x0,0xf0171fe4
f01032c1:	c6 05 e5 1f 17 f0 8e 	movb   $0x8e,0xf0171fe5
f01032c8:	c1 e8 10             	shr    $0x10,%eax
f01032cb:	66 a3 e6 1f 17 f0    	mov    %ax,0xf0171fe6
	   SETGATE(idt[T_TSS], true, GD_KT, tss_exception, 0);
f01032d1:	b8 60 38 10 f0       	mov    $0xf0103860,%eax
f01032d6:	66 a3 f0 1f 17 f0    	mov    %ax,0xf0171ff0
f01032dc:	66 c7 05 f2 1f 17 f0 	movw   $0x8,0xf0171ff2
f01032e3:	08 00 
f01032e5:	c6 05 f4 1f 17 f0 00 	movb   $0x0,0xf0171ff4
f01032ec:	c6 05 f5 1f 17 f0 8f 	movb   $0x8f,0xf0171ff5
f01032f3:	c1 e8 10             	shr    $0x10,%eax
f01032f6:	66 a3 f6 1f 17 f0    	mov    %ax,0xf0171ff6
	   SETGATE(idt[T_SEGNP], true, GD_KT, segment_np_exception, 0);
f01032fc:	b8 64 38 10 f0       	mov    $0xf0103864,%eax
f0103301:	66 a3 f8 1f 17 f0    	mov    %ax,0xf0171ff8
f0103307:	66 c7 05 fa 1f 17 f0 	movw   $0x8,0xf0171ffa
f010330e:	08 00 
f0103310:	c6 05 fc 1f 17 f0 00 	movb   $0x0,0xf0171ffc
f0103317:	c6 05 fd 1f 17 f0 8f 	movb   $0x8f,0xf0171ffd
f010331e:	c1 e8 10             	shr    $0x10,%eax
f0103321:	66 a3 fe 1f 17 f0    	mov    %ax,0xf0171ffe
	   SETGATE(idt[T_STACK], true, GD_KT, stack_np_excecption, 0);
f0103327:	b8 68 38 10 f0       	mov    $0xf0103868,%eax
f010332c:	66 a3 00 20 17 f0    	mov    %ax,0xf0172000
f0103332:	66 c7 05 02 20 17 f0 	movw   $0x8,0xf0172002
f0103339:	08 00 
f010333b:	c6 05 04 20 17 f0 00 	movb   $0x0,0xf0172004
f0103342:	c6 05 05 20 17 f0 8f 	movb   $0x8f,0xf0172005
f0103349:	c1 e8 10             	shr    $0x10,%eax
f010334c:	66 a3 06 20 17 f0    	mov    %ax,0xf0172006
	   SETGATE(idt[T_GPFLT], true, GD_KT, general_protection_fault, 0);
f0103352:	b8 6c 38 10 f0       	mov    $0xf010386c,%eax
f0103357:	66 a3 08 20 17 f0    	mov    %ax,0xf0172008
f010335d:	66 c7 05 0a 20 17 f0 	movw   $0x8,0xf017200a
f0103364:	08 00 
f0103366:	c6 05 0c 20 17 f0 00 	movb   $0x0,0xf017200c
f010336d:	c6 05 0d 20 17 f0 8f 	movb   $0x8f,0xf017200d
f0103374:	c1 e8 10             	shr    $0x10,%eax
f0103377:	66 a3 0e 20 17 f0    	mov    %ax,0xf017200e
	   SETGATE(idt[T_PGFLT], true, GD_KT, page_fault_exception,0);
f010337d:	b8 70 38 10 f0       	mov    $0xf0103870,%eax
f0103382:	66 a3 10 20 17 f0    	mov    %ax,0xf0172010
f0103388:	66 c7 05 12 20 17 f0 	movw   $0x8,0xf0172012
f010338f:	08 00 
f0103391:	c6 05 14 20 17 f0 00 	movb   $0x0,0xf0172014
f0103398:	c6 05 15 20 17 f0 8f 	movb   $0x8f,0xf0172015
f010339f:	c1 e8 10             	shr    $0x10,%eax
f01033a2:	66 a3 16 20 17 f0    	mov    %ax,0xf0172016
	   SETGATE(idt[T_FPERR], true, GD_KT, fp_err_exception, 0);
f01033a8:	b8 74 38 10 f0       	mov    $0xf0103874,%eax
f01033ad:	66 a3 20 20 17 f0    	mov    %ax,0xf0172020
f01033b3:	66 c7 05 22 20 17 f0 	movw   $0x8,0xf0172022
f01033ba:	08 00 
f01033bc:	c6 05 24 20 17 f0 00 	movb   $0x0,0xf0172024
f01033c3:	c6 05 25 20 17 f0 8f 	movb   $0x8f,0xf0172025
f01033ca:	c1 e8 10             	shr    $0x10,%eax
f01033cd:	66 a3 26 20 17 f0    	mov    %ax,0xf0172026
	   SETGATE(idt[T_ALIGN], true, GD_KT, alignment_exception, 0);
f01033d3:	b8 7a 38 10 f0       	mov    $0xf010387a,%eax
f01033d8:	66 a3 28 20 17 f0    	mov    %ax,0xf0172028
f01033de:	66 c7 05 2a 20 17 f0 	movw   $0x8,0xf017202a
f01033e5:	08 00 
f01033e7:	c6 05 2c 20 17 f0 00 	movb   $0x0,0xf017202c
f01033ee:	c6 05 2d 20 17 f0 8f 	movb   $0x8f,0xf017202d
f01033f5:	c1 e8 10             	shr    $0x10,%eax
f01033f8:	66 a3 2e 20 17 f0    	mov    %ax,0xf017202e
	   SETGATE(idt[T_MCHK], false, GD_KT, machine_exception, 0);
f01033fe:	b8 7e 38 10 f0       	mov    $0xf010387e,%eax
f0103403:	66 a3 30 20 17 f0    	mov    %ax,0xf0172030
f0103409:	66 c7 05 32 20 17 f0 	movw   $0x8,0xf0172032
f0103410:	08 00 
f0103412:	c6 05 34 20 17 f0 00 	movb   $0x0,0xf0172034
f0103419:	c6 05 35 20 17 f0 8e 	movb   $0x8e,0xf0172035
f0103420:	c1 e8 10             	shr    $0x10,%eax
f0103423:	66 a3 36 20 17 f0    	mov    %ax,0xf0172036
	   SETGATE(idt[T_SIMDERR], true, GD_KT, SIMDerr_exception, 0);
f0103429:	b8 84 38 10 f0       	mov    $0xf0103884,%eax
f010342e:	66 a3 38 20 17 f0    	mov    %ax,0xf0172038
f0103434:	66 c7 05 3a 20 17 f0 	movw   $0x8,0xf017203a
f010343b:	08 00 
f010343d:	c6 05 3c 20 17 f0 00 	movb   $0x0,0xf017203c
f0103444:	c6 05 3d 20 17 f0 8f 	movb   $0x8f,0xf017203d
f010344b:	c1 e8 10             	shr    $0x10,%eax
f010344e:	66 a3 3e 20 17 f0    	mov    %ax,0xf017203e

	   SETGATE (idt[T_SYSCALL], false, GD_KT, syscall_interrupt, 3);
f0103454:	b8 8a 38 10 f0       	mov    $0xf010388a,%eax
f0103459:	66 a3 20 21 17 f0    	mov    %ax,0xf0172120
f010345f:	66 c7 05 22 21 17 f0 	movw   $0x8,0xf0172122
f0103466:	08 00 
f0103468:	c6 05 24 21 17 f0 00 	movb   $0x0,0xf0172124
f010346f:	c6 05 25 21 17 f0 ee 	movb   $0xee,0xf0172125
f0103476:	c1 e8 10             	shr    $0x10,%eax
f0103479:	66 a3 26 21 17 f0    	mov    %ax,0xf0172126
	   // Per-CPU setup 
	   trap_init_percpu();
f010347f:	e8 61 fc ff ff       	call   f01030e5 <trap_init_percpu>
}
f0103484:	5d                   	pop    %ebp
f0103485:	c3                   	ret    

f0103486 <print_regs>:
	   }
}

	   void
print_regs(struct PushRegs *regs)
{
f0103486:	55                   	push   %ebp
f0103487:	89 e5                	mov    %esp,%ebp
f0103489:	53                   	push   %ebx
f010348a:	83 ec 0c             	sub    $0xc,%esp
f010348d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103490:	ff 33                	pushl  (%ebx)
f0103492:	68 86 5a 10 f0       	push   $0xf0105a86
f0103497:	e8 35 fc ff ff       	call   f01030d1 <cprintf>
	   cprintf("  esi  0x%08x\n", regs->reg_esi);
f010349c:	83 c4 08             	add    $0x8,%esp
f010349f:	ff 73 04             	pushl  0x4(%ebx)
f01034a2:	68 95 5a 10 f0       	push   $0xf0105a95
f01034a7:	e8 25 fc ff ff       	call   f01030d1 <cprintf>
	   cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01034ac:	83 c4 08             	add    $0x8,%esp
f01034af:	ff 73 08             	pushl  0x8(%ebx)
f01034b2:	68 a4 5a 10 f0       	push   $0xf0105aa4
f01034b7:	e8 15 fc ff ff       	call   f01030d1 <cprintf>
	   cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01034bc:	83 c4 08             	add    $0x8,%esp
f01034bf:	ff 73 0c             	pushl  0xc(%ebx)
f01034c2:	68 b3 5a 10 f0       	push   $0xf0105ab3
f01034c7:	e8 05 fc ff ff       	call   f01030d1 <cprintf>
	   cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01034cc:	83 c4 08             	add    $0x8,%esp
f01034cf:	ff 73 10             	pushl  0x10(%ebx)
f01034d2:	68 c2 5a 10 f0       	push   $0xf0105ac2
f01034d7:	e8 f5 fb ff ff       	call   f01030d1 <cprintf>
	   cprintf("  edx  0x%08x\n", regs->reg_edx);
f01034dc:	83 c4 08             	add    $0x8,%esp
f01034df:	ff 73 14             	pushl  0x14(%ebx)
f01034e2:	68 d1 5a 10 f0       	push   $0xf0105ad1
f01034e7:	e8 e5 fb ff ff       	call   f01030d1 <cprintf>
	   cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01034ec:	83 c4 08             	add    $0x8,%esp
f01034ef:	ff 73 18             	pushl  0x18(%ebx)
f01034f2:	68 e0 5a 10 f0       	push   $0xf0105ae0
f01034f7:	e8 d5 fb ff ff       	call   f01030d1 <cprintf>
	   cprintf("  eax  0x%08x\n", regs->reg_eax);
f01034fc:	83 c4 08             	add    $0x8,%esp
f01034ff:	ff 73 1c             	pushl  0x1c(%ebx)
f0103502:	68 ef 5a 10 f0       	push   $0xf0105aef
f0103507:	e8 c5 fb ff ff       	call   f01030d1 <cprintf>
}
f010350c:	83 c4 10             	add    $0x10,%esp
f010350f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103512:	c9                   	leave  
f0103513:	c3                   	ret    

f0103514 <print_trapframe>:
	   lidt(&idt_pd);
}

	   void
print_trapframe(struct Trapframe *tf)
{
f0103514:	55                   	push   %ebp
f0103515:	89 e5                	mov    %esp,%ebp
f0103517:	56                   	push   %esi
f0103518:	53                   	push   %ebx
f0103519:	8b 5d 08             	mov    0x8(%ebp),%ebx
	   cprintf("TRAP frame at %p\n", tf);
f010351c:	83 ec 08             	sub    $0x8,%esp
f010351f:	53                   	push   %ebx
f0103520:	68 25 5c 10 f0       	push   $0xf0105c25
f0103525:	e8 a7 fb ff ff       	call   f01030d1 <cprintf>
	   print_regs(&tf->tf_regs);
f010352a:	89 1c 24             	mov    %ebx,(%esp)
f010352d:	e8 54 ff ff ff       	call   f0103486 <print_regs>
	   cprintf("  es   0x----%04x\n", tf->tf_es);
f0103532:	83 c4 08             	add    $0x8,%esp
f0103535:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103539:	50                   	push   %eax
f010353a:	68 40 5b 10 f0       	push   $0xf0105b40
f010353f:	e8 8d fb ff ff       	call   f01030d1 <cprintf>
	   cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103544:	83 c4 08             	add    $0x8,%esp
f0103547:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010354b:	50                   	push   %eax
f010354c:	68 53 5b 10 f0       	push   $0xf0105b53
f0103551:	e8 7b fb ff ff       	call   f01030d1 <cprintf>
	   cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103556:	8b 43 28             	mov    0x28(%ebx),%eax
			 "Alignment Check",
			 "Machine-Check",
			 "SIMD Floating-Point Exception"
	   };

	   if (trapno < ARRAY_SIZE(excnames))
f0103559:	83 c4 10             	add    $0x10,%esp
f010355c:	83 f8 13             	cmp    $0x13,%eax
f010355f:	77 09                	ja     f010356a <print_trapframe+0x56>
			 return excnames[trapno];
f0103561:	8b 14 85 40 5e 10 f0 	mov    -0xfefa1c0(,%eax,4),%edx
f0103568:	eb 10                	jmp    f010357a <print_trapframe+0x66>
	   if (trapno == T_SYSCALL)
			 return "System call";
	   return "(unknown trap)";
f010356a:	83 f8 30             	cmp    $0x30,%eax
f010356d:	b9 0a 5b 10 f0       	mov    $0xf0105b0a,%ecx
f0103572:	ba fe 5a 10 f0       	mov    $0xf0105afe,%edx
f0103577:	0f 45 d1             	cmovne %ecx,%edx
{
	   cprintf("TRAP frame at %p\n", tf);
	   print_regs(&tf->tf_regs);
	   cprintf("  es   0x----%04x\n", tf->tf_es);
	   cprintf("  ds   0x----%04x\n", tf->tf_ds);
	   cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010357a:	83 ec 04             	sub    $0x4,%esp
f010357d:	52                   	push   %edx
f010357e:	50                   	push   %eax
f010357f:	68 66 5b 10 f0       	push   $0xf0105b66
f0103584:	e8 48 fb ff ff       	call   f01030d1 <cprintf>
	   // If this trap was a page fault that just happened
	   // (so %cr2 is meaningful), print the faulting linear address.
	   if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103589:	83 c4 10             	add    $0x10,%esp
f010358c:	3b 1d a0 27 17 f0    	cmp    0xf01727a0,%ebx
f0103592:	75 1a                	jne    f01035ae <print_trapframe+0x9a>
f0103594:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103598:	75 14                	jne    f01035ae <print_trapframe+0x9a>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010359a:	0f 20 d0             	mov    %cr2,%eax
			 cprintf("  cr2  0x%08x\n", rcr2());
f010359d:	83 ec 08             	sub    $0x8,%esp
f01035a0:	50                   	push   %eax
f01035a1:	68 78 5b 10 f0       	push   $0xf0105b78
f01035a6:	e8 26 fb ff ff       	call   f01030d1 <cprintf>
f01035ab:	83 c4 10             	add    $0x10,%esp
	   cprintf("  err  0x%08x", tf->tf_err);
f01035ae:	83 ec 08             	sub    $0x8,%esp
f01035b1:	ff 73 2c             	pushl  0x2c(%ebx)
f01035b4:	68 87 5b 10 f0       	push   $0xf0105b87
f01035b9:	e8 13 fb ff ff       	call   f01030d1 <cprintf>
	   // For page faults, print decoded fault error code:
	   // U/K=fault occurred in user/kernel mode
	   // W/R=a write/read caused the fault
	   // PR=a protection violation caused the fault (NP=page not present).
	   if (tf->tf_trapno == T_PGFLT)
f01035be:	83 c4 10             	add    $0x10,%esp
f01035c1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01035c5:	75 49                	jne    f0103610 <print_trapframe+0xfc>
			 cprintf(" [%s, %s, %s]\n",
						  tf->tf_err & 4 ? "user" : "kernel",
						  tf->tf_err & 2 ? "write" : "read",
						  tf->tf_err & 1 ? "protection" : "not-present");
f01035c7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	   // For page faults, print decoded fault error code:
	   // U/K=fault occurred in user/kernel mode
	   // W/R=a write/read caused the fault
	   // PR=a protection violation caused the fault (NP=page not present).
	   if (tf->tf_trapno == T_PGFLT)
			 cprintf(" [%s, %s, %s]\n",
f01035ca:	89 c2                	mov    %eax,%edx
f01035cc:	83 e2 01             	and    $0x1,%edx
f01035cf:	ba 24 5b 10 f0       	mov    $0xf0105b24,%edx
f01035d4:	b9 19 5b 10 f0       	mov    $0xf0105b19,%ecx
f01035d9:	0f 44 ca             	cmove  %edx,%ecx
f01035dc:	89 c2                	mov    %eax,%edx
f01035de:	83 e2 02             	and    $0x2,%edx
f01035e1:	ba 36 5b 10 f0       	mov    $0xf0105b36,%edx
f01035e6:	be 30 5b 10 f0       	mov    $0xf0105b30,%esi
f01035eb:	0f 45 d6             	cmovne %esi,%edx
f01035ee:	83 e0 04             	and    $0x4,%eax
f01035f1:	be 64 5c 10 f0       	mov    $0xf0105c64,%esi
f01035f6:	b8 3b 5b 10 f0       	mov    $0xf0105b3b,%eax
f01035fb:	0f 44 c6             	cmove  %esi,%eax
f01035fe:	51                   	push   %ecx
f01035ff:	52                   	push   %edx
f0103600:	50                   	push   %eax
f0103601:	68 95 5b 10 f0       	push   $0xf0105b95
f0103606:	e8 c6 fa ff ff       	call   f01030d1 <cprintf>
f010360b:	83 c4 10             	add    $0x10,%esp
f010360e:	eb 10                	jmp    f0103620 <print_trapframe+0x10c>
						  tf->tf_err & 4 ? "user" : "kernel",
						  tf->tf_err & 2 ? "write" : "read",
						  tf->tf_err & 1 ? "protection" : "not-present");
	   else
			 cprintf("\n");
f0103610:	83 ec 0c             	sub    $0xc,%esp
f0103613:	68 2b 49 10 f0       	push   $0xf010492b
f0103618:	e8 b4 fa ff ff       	call   f01030d1 <cprintf>
f010361d:	83 c4 10             	add    $0x10,%esp
	   cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103620:	83 ec 08             	sub    $0x8,%esp
f0103623:	ff 73 30             	pushl  0x30(%ebx)
f0103626:	68 a4 5b 10 f0       	push   $0xf0105ba4
f010362b:	e8 a1 fa ff ff       	call   f01030d1 <cprintf>
	   cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103630:	83 c4 08             	add    $0x8,%esp
f0103633:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103637:	50                   	push   %eax
f0103638:	68 b3 5b 10 f0       	push   $0xf0105bb3
f010363d:	e8 8f fa ff ff       	call   f01030d1 <cprintf>
	   cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103642:	83 c4 08             	add    $0x8,%esp
f0103645:	ff 73 38             	pushl  0x38(%ebx)
f0103648:	68 c6 5b 10 f0       	push   $0xf0105bc6
f010364d:	e8 7f fa ff ff       	call   f01030d1 <cprintf>
	   if ((tf->tf_cs & 3) != 0) {
f0103652:	83 c4 10             	add    $0x10,%esp
f0103655:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103659:	74 25                	je     f0103680 <print_trapframe+0x16c>
			 cprintf("  esp  0x%08x\n", tf->tf_esp);
f010365b:	83 ec 08             	sub    $0x8,%esp
f010365e:	ff 73 3c             	pushl  0x3c(%ebx)
f0103661:	68 d5 5b 10 f0       	push   $0xf0105bd5
f0103666:	e8 66 fa ff ff       	call   f01030d1 <cprintf>
			 cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010366b:	83 c4 08             	add    $0x8,%esp
f010366e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103672:	50                   	push   %eax
f0103673:	68 e4 5b 10 f0       	push   $0xf0105be4
f0103678:	e8 54 fa ff ff       	call   f01030d1 <cprintf>
f010367d:	83 c4 10             	add    $0x10,%esp
	   }
}
f0103680:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103683:	5b                   	pop    %ebx
f0103684:	5e                   	pop    %esi
f0103685:	5d                   	pop    %ebp
f0103686:	c3                   	ret    

f0103687 <page_fault_handler>:
}


	   void
page_fault_handler(struct Trapframe *tf)
{
f0103687:	55                   	push   %ebp
f0103688:	89 e5                	mov    %esp,%ebp
f010368a:	53                   	push   %ebx
f010368b:	83 ec 04             	sub    $0x4,%esp
f010368e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103691:	0f 20 d0             	mov    %cr2,%eax
	   fault_va = rcr2();

	   // Handle kernel-mode page faults.
	   // LAB 3: Your code here.

	   if((tf -> tf_cs & 0x03) == 0)
f0103694:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103698:	75 15                	jne    f01036af <page_fault_handler+0x28>
			 panic ("Page Fault in Kernel at address %x", fault_va);
f010369a:	50                   	push   %eax
f010369b:	68 b0 5d 10 f0       	push   $0xf0105db0
f01036a0:	68 f5 00 00 00       	push   $0xf5
f01036a5:	68 f7 5b 10 f0       	push   $0xf0105bf7
f01036aa:	e8 fd c9 ff ff       	call   f01000ac <_panic>

	   // We've already handled kernel-mode exceptions, so if we get here,
	   // the page fault happened in user mode.

	   // Destroy the environment that caused the fault.
	   cprintf("[%08x] user fault va %08x ip %08x\n",
f01036af:	ff 73 30             	pushl  0x30(%ebx)
f01036b2:	50                   	push   %eax
f01036b3:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f01036b8:	ff 70 48             	pushl  0x48(%eax)
f01036bb:	68 d4 5d 10 f0       	push   $0xf0105dd4
f01036c0:	e8 0c fa ff ff       	call   f01030d1 <cprintf>
				    curenv->env_id, fault_va, tf->tf_eip);
	   print_trapframe(tf);
f01036c5:	89 1c 24             	mov    %ebx,(%esp)
f01036c8:	e8 47 fe ff ff       	call   f0103514 <print_trapframe>
	   env_destroy(curenv);
f01036cd:	83 c4 04             	add    $0x4,%esp
f01036d0:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f01036d6:	e8 e3 f8 ff ff       	call   f0102fbe <env_destroy>
}
f01036db:	83 c4 10             	add    $0x10,%esp
f01036de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036e1:	c9                   	leave  
f01036e2:	c3                   	ret    

f01036e3 <trap>:
	   }
}

	   void
trap(struct Trapframe *tf)
{
f01036e3:	55                   	push   %ebp
f01036e4:	89 e5                	mov    %esp,%ebp
f01036e6:	57                   	push   %edi
f01036e7:	56                   	push   %esi
f01036e8:	8b 75 08             	mov    0x8(%ebp),%esi
	   // The environment may have set DF and some versions
	   // of GCC rely on DF being clear
	   asm volatile("cld" ::: "cc");
f01036eb:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01036ec:	9c                   	pushf  
f01036ed:	58                   	pop    %eax

	   // Check that interrupts are disabled.  If this assertion
	   // fails, DO NOT be tempted to fix it by inserting a "cli" in
	   // the interrupt path.
	   assert(!(read_eflags() & FL_IF));
f01036ee:	f6 c4 02             	test   $0x2,%ah
f01036f1:	74 19                	je     f010370c <trap+0x29>
f01036f3:	68 03 5c 10 f0       	push   $0xf0105c03
f01036f8:	68 78 4e 10 f0       	push   $0xf0104e78
f01036fd:	68 cc 00 00 00       	push   $0xcc
f0103702:	68 f7 5b 10 f0       	push   $0xf0105bf7
f0103707:	e8 a0 c9 ff ff       	call   f01000ac <_panic>

	   cprintf("Incoming TRAP frame at %p\n", tf);
f010370c:	83 ec 08             	sub    $0x8,%esp
f010370f:	56                   	push   %esi
f0103710:	68 1c 5c 10 f0       	push   $0xf0105c1c
f0103715:	e8 b7 f9 ff ff       	call   f01030d1 <cprintf>

	   if ((tf->tf_cs & 3) == 3) {
f010371a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010371e:	83 e0 03             	and    $0x3,%eax
f0103721:	83 c4 10             	add    $0x10,%esp
f0103724:	66 83 f8 03          	cmp    $0x3,%ax
f0103728:	75 31                	jne    f010375b <trap+0x78>
			 // Trapped from user mode.
			 assert(curenv);
f010372a:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f010372f:	85 c0                	test   %eax,%eax
f0103731:	75 19                	jne    f010374c <trap+0x69>
f0103733:	68 37 5c 10 f0       	push   $0xf0105c37
f0103738:	68 78 4e 10 f0       	push   $0xf0104e78
f010373d:	68 d2 00 00 00       	push   $0xd2
f0103742:	68 f7 5b 10 f0       	push   $0xf0105bf7
f0103747:	e8 60 c9 ff ff       	call   f01000ac <_panic>

			 // Copy trap frame (which is currently on the stack)
			 // into 'curenv->env_tf', so that running the environment
			 // will restart at the trap point.
			 curenv->env_tf = *tf;
f010374c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103751:	89 c7                	mov    %eax,%edi
f0103753:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			 // The trapframe on the stack should be ignored from here on.
			 tf = &curenv->env_tf;
f0103755:	8b 35 88 1f 17 f0    	mov    0xf0171f88,%esi
	   }

	   // Record that tf is the last real trapframe so
	   // print_trapframe can print some additional information.
	   last_tf = tf;
f010375b:	89 35 a0 27 17 f0    	mov    %esi,0xf01727a0
trap_dispatch(struct Trapframe *tf)
{
	   // Handle processor exceptions.
	   // LAB 3: Your code here.

	   if (tf -> tf_trapno == T_PGFLT)
f0103761:	8b 46 28             	mov    0x28(%esi),%eax
f0103764:	83 f8 0e             	cmp    $0xe,%eax
f0103767:	75 11                	jne    f010377a <trap+0x97>
	   {
			 page_fault_handler(tf);
f0103769:	83 ec 0c             	sub    $0xc,%esp
f010376c:	56                   	push   %esi
f010376d:	e8 15 ff ff ff       	call   f0103687 <page_fault_handler>
f0103772:	83 c4 10             	add    $0x10,%esp
f0103775:	e9 81 00 00 00       	jmp    f01037fb <trap+0x118>
			 return;
	   } else if (tf -> tf_trapno == T_BRKPT)
f010377a:	83 f8 03             	cmp    $0x3,%eax
f010377d:	75 0e                	jne    f010378d <trap+0xaa>
	   {
			 monitor (tf);
f010377f:	83 ec 0c             	sub    $0xc,%esp
f0103782:	56                   	push   %esi
f0103783:	e8 75 d0 ff ff       	call   f01007fd <monitor>
f0103788:	83 c4 10             	add    $0x10,%esp
f010378b:	eb 6e                	jmp    f01037fb <trap+0x118>
			 return;
	   } else if (tf -> tf_trapno == T_SYSCALL)
f010378d:	83 f8 30             	cmp    $0x30,%eax
f0103790:	75 2e                	jne    f01037c0 <trap+0xdd>
	   {
			 cprintf("SYSCALL Initiated \n");
f0103792:	83 ec 0c             	sub    $0xc,%esp
f0103795:	68 3e 5c 10 f0       	push   $0xf0105c3e
f010379a:	e8 32 f9 ff ff       	call   f01030d1 <cprintf>
			 int32_t return_value = syscall (tf -> tf_regs.reg_eax, tf -> tf_regs.reg_edx, tf -> tf_regs.reg_ecx, tf -> tf_regs.reg_ebx, tf -> tf_regs.reg_edi, tf -> tf_regs.reg_esi);
f010379f:	83 c4 08             	add    $0x8,%esp
f01037a2:	ff 76 04             	pushl  0x4(%esi)
f01037a5:	ff 36                	pushl  (%esi)
f01037a7:	ff 76 10             	pushl  0x10(%esi)
f01037aa:	ff 76 18             	pushl  0x18(%esi)
f01037ad:	ff 76 14             	pushl  0x14(%esi)
f01037b0:	ff 76 1c             	pushl  0x1c(%esi)
f01037b3:	e8 e9 00 00 00       	call   f01038a1 <syscall>
			 tf -> tf_regs.reg_eax = return_value;
f01037b8:	89 46 1c             	mov    %eax,0x1c(%esi)
f01037bb:	83 c4 20             	add    $0x20,%esp
f01037be:	eb 3b                	jmp    f01037fb <trap+0x118>
			 return;
	   }

	   // Unexpected trap: The user process or the kernel has a bug.
	   print_trapframe(tf);
f01037c0:	83 ec 0c             	sub    $0xc,%esp
f01037c3:	56                   	push   %esi
f01037c4:	e8 4b fd ff ff       	call   f0103514 <print_trapframe>
	   if (tf->tf_cs == GD_KT)
f01037c9:	83 c4 10             	add    $0x10,%esp
f01037cc:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01037d1:	75 17                	jne    f01037ea <trap+0x107>
			 panic("unhandled trap in kernel");
f01037d3:	83 ec 04             	sub    $0x4,%esp
f01037d6:	68 52 5c 10 f0       	push   $0xf0105c52
f01037db:	68 bb 00 00 00       	push   $0xbb
f01037e0:	68 f7 5b 10 f0       	push   $0xf0105bf7
f01037e5:	e8 c2 c8 ff ff       	call   f01000ac <_panic>
	   else {
			 env_destroy(curenv);
f01037ea:	83 ec 0c             	sub    $0xc,%esp
f01037ed:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f01037f3:	e8 c6 f7 ff ff       	call   f0102fbe <env_destroy>
f01037f8:	83 c4 10             	add    $0x10,%esp

	   // Dispatch based on what type of trap occurred
	   trap_dispatch(tf);

	   // Return to the current environment, which should be running.
	   assert(curenv && curenv->env_status == ENV_RUNNING);
f01037fb:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f0103800:	85 c0                	test   %eax,%eax
f0103802:	74 06                	je     f010380a <trap+0x127>
f0103804:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103808:	74 19                	je     f0103823 <trap+0x140>
f010380a:	68 f8 5d 10 f0       	push   $0xf0105df8
f010380f:	68 78 4e 10 f0       	push   $0xf0104e78
f0103814:	68 e4 00 00 00       	push   $0xe4
f0103819:	68 f7 5b 10 f0       	push   $0xf0105bf7
f010381e:	e8 89 c8 ff ff       	call   f01000ac <_panic>
	   env_run(curenv);
f0103823:	83 ec 0c             	sub    $0xc,%esp
f0103826:	50                   	push   %eax
f0103827:	e8 e2 f7 ff ff       	call   f010300e <env_run>

f010382c <divide_exception>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC (divide_exception, T_DIVIDE);
f010382c:	6a 00                	push   $0x0
f010382e:	6a 00                	push   $0x0
f0103830:	eb 5e                	jmp    f0103890 <_alltraps>

f0103832 <debug_exception>:
TRAPHANDLER_NOEC (debug_exception, T_DEBUG);
f0103832:	6a 00                	push   $0x0
f0103834:	6a 01                	push   $0x1
f0103836:	eb 58                	jmp    f0103890 <_alltraps>

f0103838 <nmi_interupt>:
TRAPHANDLER_NOEC (nmi_interupt, T_NMI);
f0103838:	6a 00                	push   $0x0
f010383a:	6a 02                	push   $0x2
f010383c:	eb 52                	jmp    f0103890 <_alltraps>

f010383e <breakpoint_exception>:
TRAPHANDLER_NOEC (breakpoint_exception, T_BRKPT);
f010383e:	6a 00                	push   $0x0
f0103840:	6a 03                	push   $0x3
f0103842:	eb 4c                	jmp    f0103890 <_alltraps>

f0103844 <overflow_exception>:
TRAPHANDLER_NOEC (overflow_exception, T_OFLOW);
f0103844:	6a 00                	push   $0x0
f0103846:	6a 04                	push   $0x4
f0103848:	eb 46                	jmp    f0103890 <_alltraps>

f010384a <bounds_check_exception>:
TRAPHANDLER_NOEC (bounds_check_exception, T_BOUND);
f010384a:	6a 00                	push   $0x0
f010384c:	6a 05                	push   $0x5
f010384e:	eb 40                	jmp    f0103890 <_alltraps>

f0103850 <illegal_opcode_exception>:
TRAPHANDLER_NOEC (illegal_opcode_exception, T_ILLOP);
f0103850:	6a 00                	push   $0x0
f0103852:	6a 06                	push   $0x6
f0103854:	eb 3a                	jmp    f0103890 <_alltraps>

f0103856 <coprocessor_exception>:
TRAPHANDLER_NOEC (coprocessor_exception, T_DEVICE);
f0103856:	6a 00                	push   $0x0
f0103858:	6a 07                	push   $0x7
f010385a:	eb 34                	jmp    f0103890 <_alltraps>

f010385c <double_fault_exception>:
TRAPHANDLER (double_fault_exception, T_DBLFLT);
f010385c:	6a 08                	push   $0x8
f010385e:	eb 30                	jmp    f0103890 <_alltraps>

f0103860 <tss_exception>:
TRAPHANDLER (tss_exception, T_TSS);
f0103860:	6a 0a                	push   $0xa
f0103862:	eb 2c                	jmp    f0103890 <_alltraps>

f0103864 <segment_np_exception>:
TRAPHANDLER (segment_np_exception, T_SEGNP);
f0103864:	6a 0b                	push   $0xb
f0103866:	eb 28                	jmp    f0103890 <_alltraps>

f0103868 <stack_np_excecption>:
TRAPHANDLER (stack_np_excecption, T_STACK);
f0103868:	6a 0c                	push   $0xc
f010386a:	eb 24                	jmp    f0103890 <_alltraps>

f010386c <general_protection_fault>:
TRAPHANDLER (general_protection_fault, T_GPFLT);
f010386c:	6a 0d                	push   $0xd
f010386e:	eb 20                	jmp    f0103890 <_alltraps>

f0103870 <page_fault_exception>:
TRAPHANDLER (page_fault_exception, T_PGFLT);
f0103870:	6a 0e                	push   $0xe
f0103872:	eb 1c                	jmp    f0103890 <_alltraps>

f0103874 <fp_err_exception>:
TRAPHANDLER_NOEC (fp_err_exception, T_FPERR);
f0103874:	6a 00                	push   $0x0
f0103876:	6a 10                	push   $0x10
f0103878:	eb 16                	jmp    f0103890 <_alltraps>

f010387a <alignment_exception>:
TRAPHANDLER (alignment_exception, T_ALIGN);
f010387a:	6a 11                	push   $0x11
f010387c:	eb 12                	jmp    f0103890 <_alltraps>

f010387e <machine_exception>:
TRAPHANDLER_NOEC (machine_exception, T_MCHK);
f010387e:	6a 00                	push   $0x0
f0103880:	6a 12                	push   $0x12
f0103882:	eb 0c                	jmp    f0103890 <_alltraps>

f0103884 <SIMDerr_exception>:
TRAPHANDLER_NOEC  (SIMDerr_exception, T_SIMDERR);
f0103884:	6a 00                	push   $0x0
f0103886:	6a 13                	push   $0x13
f0103888:	eb 06                	jmp    f0103890 <_alltraps>

f010388a <syscall_interrupt>:

TRAPHANDLER_NOEC (syscall_interrupt, T_SYSCALL);
f010388a:	6a 00                	push   $0x0
f010388c:	6a 30                	push   $0x30
f010388e:	eb 00                	jmp    f0103890 <_alltraps>

f0103890 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
pushl %ds
f0103890:	1e                   	push   %ds
pushl %es
f0103891:	06                   	push   %es
pushal
f0103892:	60                   	pusha  
movw $GD_KD, %ax
f0103893:	66 b8 10 00          	mov    $0x10,%ax
movw %ax, %ds
f0103897:	8e d8                	mov    %eax,%ds
movw %ax, %es
f0103899:	8e c0                	mov    %eax,%es
pushl %esp
f010389b:	54                   	push   %esp
call trap
f010389c:	e8 42 fe ff ff       	call   f01036e3 <trap>

f01038a1 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
	   int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01038a1:	55                   	push   %ebp
f01038a2:	89 e5                	mov    %esp,%ebp
f01038a4:	83 ec 18             	sub    $0x18,%esp
f01038a7:	8b 45 08             	mov    0x8(%ebp),%eax
	   // Return any appropriate return value.
	   // LAB 3: Your code here.

	   //	panic("syscall not implemented");

	   switch (syscallno) {
f01038aa:	83 f8 01             	cmp    $0x1,%eax
f01038ad:	74 4d                	je     f01038fc <syscall+0x5b>
f01038af:	83 f8 01             	cmp    $0x1,%eax
f01038b2:	72 0f                	jb     f01038c3 <syscall+0x22>
f01038b4:	83 f8 02             	cmp    $0x2,%eax
f01038b7:	74 4a                	je     f0103903 <syscall+0x62>
f01038b9:	83 f8 03             	cmp    $0x3,%eax
f01038bc:	74 4f                	je     f010390d <syscall+0x6c>
f01038be:	e9 af 00 00 00       	jmp    f0103972 <syscall+0xd1>
{
	   // Check that the user has permission to read memory [s, s+len).
	   // Destroy the environment if not.

	   // LAB 3: Your code here.
	   if (curenv -> env_tf.tf_cs &3)
f01038c3:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f01038c8:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f01038cc:	74 11                	je     f01038df <syscall+0x3e>
	   		user_mem_assert (curenv, (void*)s, len, PTE_U | PTE_P);
f01038ce:	6a 05                	push   $0x5
f01038d0:	ff 75 10             	pushl  0x10(%ebp)
f01038d3:	ff 75 0c             	pushl  0xc(%ebp)
f01038d6:	50                   	push   %eax
f01038d7:	e8 52 f0 ff ff       	call   f010292e <user_mem_assert>
f01038dc:	83 c4 10             	add    $0x10,%esp

	   // Print the string supplied by the user.
	   cprintf("%.*s", len, s);
f01038df:	83 ec 04             	sub    $0x4,%esp
f01038e2:	ff 75 0c             	pushl  0xc(%ebp)
f01038e5:	ff 75 10             	pushl  0x10(%ebp)
f01038e8:	68 90 5e 10 f0       	push   $0xf0105e90
f01038ed:	e8 df f7 ff ff       	call   f01030d1 <cprintf>
f01038f2:	83 c4 10             	add    $0x10,%esp

	   switch (syscallno) {

			 case SYS_cputs:
				    sys_cputs (( char*) a1, a2);
				    return 0;
f01038f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01038fa:	eb 7b                	jmp    f0103977 <syscall+0xd6>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
	   static int
sys_cgetc(void)
{
	   return cons_getc();
f01038fc:	e8 ce cb ff ff       	call   f01004cf <cons_getc>

			 case SYS_cputs:
				    sys_cputs (( char*) a1, a2);
				    return 0;
			 case SYS_cgetc:
				    return sys_cgetc ();
f0103901:	eb 74                	jmp    f0103977 <syscall+0xd6>

// Returns the current environment's envid.
	   static envid_t
sys_getenvid(void)
{
	   return curenv->env_id;
f0103903:	a1 88 1f 17 f0       	mov    0xf0171f88,%eax
f0103908:	8b 40 48             	mov    0x48(%eax),%eax
				    sys_cputs (( char*) a1, a2);
				    return 0;
			 case SYS_cgetc:
				    return sys_cgetc ();
			 case SYS_getenvid:
				    return sys_getenvid();
f010390b:	eb 6a                	jmp    f0103977 <syscall+0xd6>
sys_env_destroy(envid_t envid)
{
	   int r;
	   struct Env *e;

	   if ((r = envid2env(envid, &e, 1)) < 0)
f010390d:	83 ec 04             	sub    $0x4,%esp
f0103910:	6a 01                	push   $0x1
f0103912:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103915:	50                   	push   %eax
f0103916:	ff 75 0c             	pushl  0xc(%ebp)
f0103919:	e8 fb f0 ff ff       	call   f0102a19 <envid2env>
f010391e:	83 c4 10             	add    $0x10,%esp
f0103921:	85 c0                	test   %eax,%eax
f0103923:	78 52                	js     f0103977 <syscall+0xd6>
			 return r;
	   if (e == curenv)
f0103925:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103928:	8b 15 88 1f 17 f0    	mov    0xf0171f88,%edx
f010392e:	39 d0                	cmp    %edx,%eax
f0103930:	75 15                	jne    f0103947 <syscall+0xa6>
			 cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103932:	83 ec 08             	sub    $0x8,%esp
f0103935:	ff 70 48             	pushl  0x48(%eax)
f0103938:	68 95 5e 10 f0       	push   $0xf0105e95
f010393d:	e8 8f f7 ff ff       	call   f01030d1 <cprintf>
f0103942:	83 c4 10             	add    $0x10,%esp
f0103945:	eb 16                	jmp    f010395d <syscall+0xbc>
	   else
			 cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103947:	83 ec 04             	sub    $0x4,%esp
f010394a:	ff 70 48             	pushl  0x48(%eax)
f010394d:	ff 72 48             	pushl  0x48(%edx)
f0103950:	68 b0 5e 10 f0       	push   $0xf0105eb0
f0103955:	e8 77 f7 ff ff       	call   f01030d1 <cprintf>
f010395a:	83 c4 10             	add    $0x10,%esp
	   env_destroy(e);
f010395d:	83 ec 0c             	sub    $0xc,%esp
f0103960:	ff 75 f4             	pushl  -0xc(%ebp)
f0103963:	e8 56 f6 ff ff       	call   f0102fbe <env_destroy>
f0103968:	83 c4 10             	add    $0x10,%esp
	   return 0;
f010396b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103970:	eb 05                	jmp    f0103977 <syscall+0xd6>
			 case SYS_getenvid:
				    return sys_getenvid();
			 case SYS_env_destroy:
				    return sys_env_destroy ((envid_t) a1);
			 default:
				    return -E_INVAL;
f0103972:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	   }
}
f0103977:	c9                   	leave  
f0103978:	c3                   	ret    

f0103979 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
	   static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
f0103979:	55                   	push   %ebp
f010397a:	89 e5                	mov    %esp,%ebp
f010397c:	57                   	push   %edi
f010397d:	56                   	push   %esi
f010397e:	53                   	push   %ebx
f010397f:	83 ec 14             	sub    $0x14,%esp
f0103982:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103985:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103988:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010398b:	8b 7d 08             	mov    0x8(%ebp),%edi
	   int l = *region_left, r = *region_right, any_matches = 0;
f010398e:	8b 1a                	mov    (%edx),%ebx
f0103990:	8b 01                	mov    (%ecx),%eax
f0103992:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103995:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	   while (l <= r) {
f010399c:	eb 7f                	jmp    f0103a1d <stab_binsearch+0xa4>
			 int true_m = (l + r) / 2, m = true_m;
f010399e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01039a1:	01 d8                	add    %ebx,%eax
f01039a3:	89 c6                	mov    %eax,%esi
f01039a5:	c1 ee 1f             	shr    $0x1f,%esi
f01039a8:	01 c6                	add    %eax,%esi
f01039aa:	d1 fe                	sar    %esi
f01039ac:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01039af:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01039b2:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01039b5:	89 f0                	mov    %esi,%eax

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f01039b7:	eb 03                	jmp    f01039bc <stab_binsearch+0x43>
				    m--;
f01039b9:	83 e8 01             	sub    $0x1,%eax

	   while (l <= r) {
			 int true_m = (l + r) / 2, m = true_m;

			 // search for earliest stab with right type
			 while (m >= l && stabs[m].n_type != type)
f01039bc:	39 c3                	cmp    %eax,%ebx
f01039be:	7f 0d                	jg     f01039cd <stab_binsearch+0x54>
f01039c0:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01039c4:	83 ea 0c             	sub    $0xc,%edx
f01039c7:	39 f9                	cmp    %edi,%ecx
f01039c9:	75 ee                	jne    f01039b9 <stab_binsearch+0x40>
f01039cb:	eb 05                	jmp    f01039d2 <stab_binsearch+0x59>
				    m--;
			 if (m < l) {	// no match in [l, m]
				    l = true_m + 1;
f01039cd:	8d 5e 01             	lea    0x1(%esi),%ebx
				    continue;
f01039d0:	eb 4b                	jmp    f0103a1d <stab_binsearch+0xa4>
			 }

			 // actual binary search
			 any_matches = 1;
			 if (stabs[m].n_value < addr) {
f01039d2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01039d5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01039d8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01039dc:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01039df:	76 11                	jbe    f01039f2 <stab_binsearch+0x79>
				    *region_left = m;
f01039e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01039e4:	89 03                	mov    %eax,(%ebx)
				    l = true_m + 1;
f01039e6:	8d 5e 01             	lea    0x1(%esi),%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f01039e9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01039f0:	eb 2b                	jmp    f0103a1d <stab_binsearch+0xa4>
			 if (stabs[m].n_value < addr) {
				    *region_left = m;
				    l = true_m + 1;
			 } else if (stabs[m].n_value > addr) {
f01039f2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01039f5:	73 14                	jae    f0103a0b <stab_binsearch+0x92>
				    *region_right = m - 1;
f01039f7:	83 e8 01             	sub    $0x1,%eax
f01039fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01039fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103a00:	89 06                	mov    %eax,(%esi)
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0103a02:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a09:	eb 12                	jmp    f0103a1d <stab_binsearch+0xa4>
				    *region_right = m - 1;
				    r = m - 1;
			 } else {
				    // exact match for 'addr', but continue loop to find
				    // *region_right
				    *region_left = m;
f0103a0b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a0e:	89 06                	mov    %eax,(%esi)
				    l = m;
				    addr++;
f0103a10:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103a14:	89 c3                	mov    %eax,%ebx
				    l = true_m + 1;
				    continue;
			 }

			 // actual binary search
			 any_matches = 1;
f0103a16:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			 int type, uintptr_t addr)
{
	   int l = *region_left, r = *region_right, any_matches = 0;

	   while (l <= r) {
f0103a1d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103a20:	0f 8e 78 ff ff ff    	jle    f010399e <stab_binsearch+0x25>
				    l = m;
				    addr++;
			 }
	   }

	   if (!any_matches)
f0103a26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103a2a:	75 0f                	jne    f0103a3b <stab_binsearch+0xc2>
			 *region_right = *region_left - 1;
f0103a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a2f:	8b 00                	mov    (%eax),%eax
f0103a31:	83 e8 01             	sub    $0x1,%eax
f0103a34:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103a37:	89 06                	mov    %eax,(%esi)
f0103a39:	eb 2c                	jmp    f0103a67 <stab_binsearch+0xee>
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0103a3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a3e:	8b 00                	mov    (%eax),%eax
						  l > *region_left && stabs[l].n_type != type;
f0103a40:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a43:	8b 0e                	mov    (%esi),%ecx
f0103a45:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103a48:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103a4b:	8d 14 96             	lea    (%esi,%edx,4),%edx

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0103a4e:	eb 03                	jmp    f0103a53 <stab_binsearch+0xda>
						  l > *region_left && stabs[l].n_type != type;
						  l--)
f0103a50:	83 e8 01             	sub    $0x1,%eax

	   if (!any_matches)
			 *region_right = *region_left - 1;
	   else {
			 // find rightmost region containing 'addr'
			 for (l = *region_right;
f0103a53:	39 c8                	cmp    %ecx,%eax
f0103a55:	7e 0b                	jle    f0103a62 <stab_binsearch+0xe9>
						  l > *region_left && stabs[l].n_type != type;
f0103a57:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0103a5b:	83 ea 0c             	sub    $0xc,%edx
f0103a5e:	39 df                	cmp    %ebx,%edi
f0103a60:	75 ee                	jne    f0103a50 <stab_binsearch+0xd7>
						  l--)
				    /* do nothing */;
			 *region_left = l;
f0103a62:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a65:	89 06                	mov    %eax,(%esi)
	   }
}
f0103a67:	83 c4 14             	add    $0x14,%esp
f0103a6a:	5b                   	pop    %ebx
f0103a6b:	5e                   	pop    %esi
f0103a6c:	5f                   	pop    %edi
f0103a6d:	5d                   	pop    %ebp
f0103a6e:	c3                   	ret    

f0103a6f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
	   int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103a6f:	55                   	push   %ebp
f0103a70:	89 e5                	mov    %esp,%ebp
f0103a72:	57                   	push   %edi
f0103a73:	56                   	push   %esi
f0103a74:	53                   	push   %ebx
f0103a75:	83 ec 2c             	sub    $0x2c,%esp
f0103a78:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
	   const struct Stab *stabs, *stab_end;
	   const char *stabstr, *stabstr_end;
	   int lfile, rfile, lfun, rfun, lline, rline;

	   // Initialize *info
	   info->eip_file = "<unknown>";
f0103a7e:	c7 06 c8 5e 10 f0    	movl   $0xf0105ec8,(%esi)
	   info->eip_line = 0;
f0103a84:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	   info->eip_fn_name = "<unknown>";
f0103a8b:	c7 46 08 c8 5e 10 f0 	movl   $0xf0105ec8,0x8(%esi)
	   info->eip_fn_namelen = 9;
f0103a92:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	   info->eip_fn_addr = addr;
f0103a99:	89 7e 10             	mov    %edi,0x10(%esi)
	   info->eip_fn_narg = 0;
f0103a9c:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
f0103aa3:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103aa9:	0f 87 8a 00 00 00    	ja     f0103b39 <debuginfo_eip+0xca>

			 // Make sure this memory is valid.
			 // Return -1 if it is not.  Hint: Call user_mem_check.
			 // LAB 3: Your code here.

			 if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
f0103aaf:	6a 04                	push   $0x4
f0103ab1:	6a 10                	push   $0x10
f0103ab3:	68 00 00 20 00       	push   $0x200000
f0103ab8:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f0103abe:	e8 f4 ed ff ff       	call   f01028b7 <user_mem_check>
f0103ac3:	83 c4 10             	add    $0x10,%esp
f0103ac6:	85 c0                	test   %eax,%eax
f0103ac8:	0f 88 c3 01 00 00    	js     f0103c91 <debuginfo_eip+0x222>
				 return -1;

			 stabs = usd->stabs;
f0103ace:	a1 00 00 20 00       	mov    0x200000,%eax
f0103ad3:	89 c1                	mov    %eax,%ecx
f0103ad5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			 stab_end = usd->stab_end;
f0103ad8:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
			 stabstr = usd->stabstr;
f0103ade:	a1 08 00 20 00       	mov    0x200008,%eax
f0103ae3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			 stabstr_end = usd->stabstr_end;
f0103ae6:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103aec:	89 55 d0             	mov    %edx,-0x30(%ebp)

			 // Make sure the STABS and string table memory is valid.
			 // LAB 3: Your code here.

			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
f0103aef:	6a 04                	push   $0x4
f0103af1:	89 d8                	mov    %ebx,%eax
f0103af3:	29 c8                	sub    %ecx,%eax
f0103af5:	c1 f8 02             	sar    $0x2,%eax
f0103af8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103afe:	50                   	push   %eax
f0103aff:	51                   	push   %ecx
f0103b00:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f0103b06:	e8 ac ed ff ff       	call   f01028b7 <user_mem_check>
f0103b0b:	83 c4 10             	add    $0x10,%esp
f0103b0e:	85 c0                	test   %eax,%eax
f0103b10:	0f 88 82 01 00 00    	js     f0103c98 <debuginfo_eip+0x229>
f0103b16:	6a 04                	push   $0x4
f0103b18:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103b1b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103b1e:	29 ca                	sub    %ecx,%edx
f0103b20:	52                   	push   %edx
f0103b21:	51                   	push   %ecx
f0103b22:	ff 35 88 1f 17 f0    	pushl  0xf0171f88
f0103b28:	e8 8a ed ff ff       	call   f01028b7 <user_mem_check>
f0103b2d:	83 c4 10             	add    $0x10,%esp
f0103b30:	85 c0                	test   %eax,%eax
f0103b32:	79 1f                	jns    f0103b53 <debuginfo_eip+0xe4>
f0103b34:	e9 66 01 00 00       	jmp    f0103c9f <debuginfo_eip+0x230>
	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
			 stabstr = __STABSTR_BEGIN__;
			 stabstr_end = __STABSTR_END__;
f0103b39:	c7 45 d0 c0 06 11 f0 	movl   $0xf01106c0,-0x30(%ebp)

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
			 stabstr = __STABSTR_BEGIN__;
f0103b40:	c7 45 cc e1 db 10 f0 	movl   $0xf010dbe1,-0x34(%ebp)
	   info->eip_fn_narg = 0;

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
			 stab_end = __STAB_END__;
f0103b47:	bb e0 db 10 f0       	mov    $0xf010dbe0,%ebx
	   info->eip_fn_addr = addr;
	   info->eip_fn_narg = 0;

	   // Find the relevant set of stabs
	   if (addr >= ULIM) {
			 stabs = __STAB_BEGIN__;
f0103b4c:	c7 45 d4 e0 60 10 f0 	movl   $0xf01060e0,-0x2c(%ebp)
			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
				 return -1;
   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103b53:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103b56:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0103b59:	0f 83 47 01 00 00    	jae    f0103ca6 <debuginfo_eip+0x237>
f0103b5f:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103b63:	0f 85 44 01 00 00    	jne    f0103cad <debuginfo_eip+0x23e>
	   // 'eip'.  First, we find the basic source file containing 'eip'.
	   // Then, we look in that source file for the function.  Then we look
	   // for the line number.

	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
f0103b69:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	   rfile = (stab_end - stabs) - 1;
f0103b70:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f0103b73:	c1 fb 02             	sar    $0x2,%ebx
f0103b76:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0103b7c:	83 e8 01             	sub    $0x1,%eax
f0103b7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103b82:	83 ec 08             	sub    $0x8,%esp
f0103b85:	57                   	push   %edi
f0103b86:	6a 64                	push   $0x64
f0103b88:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103b8b:	89 d1                	mov    %edx,%ecx
f0103b8d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103b90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103b93:	89 d8                	mov    %ebx,%eax
f0103b95:	e8 df fd ff ff       	call   f0103979 <stab_binsearch>
	   if (lfile == 0)
f0103b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b9d:	83 c4 10             	add    $0x10,%esp
f0103ba0:	85 c0                	test   %eax,%eax
f0103ba2:	0f 84 0c 01 00 00    	je     f0103cb4 <debuginfo_eip+0x245>
			 return -1;

	   // Search within that file's stabs for the function definition
	   // (N_FUN).
	   lfun = lfile;
f0103ba8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	   rfun = rfile;
f0103bab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
	   stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103bb1:	83 ec 08             	sub    $0x8,%esp
f0103bb4:	57                   	push   %edi
f0103bb5:	6a 24                	push   $0x24
f0103bb7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103bba:	89 d1                	mov    %edx,%ecx
f0103bbc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103bbf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0103bc2:	89 d8                	mov    %ebx,%eax
f0103bc4:	e8 b0 fd ff ff       	call   f0103979 <stab_binsearch>

	   if (lfun <= rfun) {
f0103bc9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103bcc:	83 c4 10             	add    $0x10,%esp
f0103bcf:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0103bd2:	7f 24                	jg     f0103bf8 <debuginfo_eip+0x189>
			 // stabs[lfun] points to the function name
			 // in the string table, but check bounds just in case.
			 if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103bd4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103bd7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103bda:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0103bdd:	8b 02                	mov    (%edx),%eax
f0103bdf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103be2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103be5:	29 f9                	sub    %edi,%ecx
f0103be7:	39 c8                	cmp    %ecx,%eax
f0103be9:	73 05                	jae    f0103bf0 <debuginfo_eip+0x181>
				    info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103beb:	01 f8                	add    %edi,%eax
f0103bed:	89 46 08             	mov    %eax,0x8(%esi)
			 info->eip_fn_addr = stabs[lfun].n_value;
f0103bf0:	8b 42 08             	mov    0x8(%edx),%eax
f0103bf3:	89 46 10             	mov    %eax,0x10(%esi)
f0103bf6:	eb 06                	jmp    f0103bfe <debuginfo_eip+0x18f>
			 lline = lfun;
			 rline = rfun;
	   } else {
			 // Couldn't find function stab!  Maybe we're in an assembly
			 // file.  Search the whole file for the line number.
			 info->eip_fn_addr = addr;
f0103bf8:	89 7e 10             	mov    %edi,0x10(%esi)
			 lline = lfile;
f0103bfb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			 rline = rfile;
	   }
	   // Ignore stuff after the colon.
	   info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103bfe:	83 ec 08             	sub    $0x8,%esp
f0103c01:	6a 3a                	push   $0x3a
f0103c03:	ff 76 08             	pushl  0x8(%esi)
f0103c06:	e8 30 08 00 00       	call   f010443b <strfind>
f0103c0b:	2b 46 08             	sub    0x8(%esi),%eax
f0103c0e:	89 46 0c             	mov    %eax,0xc(%esi)
	   // Search backwards from the line number for the relevant filename
	   // stab.
	   // We can't just use the "lfile" stab because inlined functions
	   // can interpolate code from a different file!
	   // Such included source files use the N_SOL stab type.
	   while (lline >= lfile
f0103c11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c14:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103c17:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103c1a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0103c1d:	83 c4 10             	add    $0x10,%esp
f0103c20:	eb 06                	jmp    f0103c28 <debuginfo_eip+0x1b9>
				    && stabs[lline].n_type != N_SOL
				    && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
			 lline--;
f0103c22:	83 eb 01             	sub    $0x1,%ebx
f0103c25:	83 e8 0c             	sub    $0xc,%eax
	   // Search backwards from the line number for the relevant filename
	   // stab.
	   // We can't just use the "lfile" stab because inlined functions
	   // can interpolate code from a different file!
	   // Such included source files use the N_SOL stab type.
	   while (lline >= lfile
f0103c28:	39 fb                	cmp    %edi,%ebx
f0103c2a:	7c 2d                	jl     f0103c59 <debuginfo_eip+0x1ea>
				    && stabs[lline].n_type != N_SOL
f0103c2c:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0103c30:	80 fa 84             	cmp    $0x84,%dl
f0103c33:	74 0b                	je     f0103c40 <debuginfo_eip+0x1d1>
				    && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c35:	80 fa 64             	cmp    $0x64,%dl
f0103c38:	75 e8                	jne    f0103c22 <debuginfo_eip+0x1b3>
f0103c3a:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103c3e:	74 e2                	je     f0103c22 <debuginfo_eip+0x1b3>
			 lline--;
	   if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c40:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103c43:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103c46:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103c49:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c4c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103c4f:	29 f8                	sub    %edi,%eax
f0103c51:	39 c2                	cmp    %eax,%edx
f0103c53:	73 04                	jae    f0103c59 <debuginfo_eip+0x1ea>
			 info->eip_file = stabstr + stabs[lline].n_strx;
f0103c55:	01 fa                	add    %edi,%edx
f0103c57:	89 16                	mov    %edx,(%esi)


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0103c59:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103c5c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0103c5f:	b8 00 00 00 00       	mov    $0x0,%eax
			 info->eip_file = stabstr + stabs[lline].n_strx;


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
f0103c64:	39 cb                	cmp    %ecx,%ebx
f0103c66:	7d 58                	jge    f0103cc0 <debuginfo_eip+0x251>
			 for (lline = lfun + 1;
f0103c68:	8d 53 01             	lea    0x1(%ebx),%edx
f0103c6b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103c6e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103c71:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103c74:	eb 07                	jmp    f0103c7d <debuginfo_eip+0x20e>
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;
f0103c76:	83 46 14 01          	addl   $0x1,0x14(%esi)
	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
f0103c7a:	83 c2 01             	add    $0x1,%edx


	   // Set eip_fn_narg to the number of arguments taken by the function,
	   // or 0 if there was no containing function.
	   if (lfun < rfun)
			 for (lline = lfun + 1;
f0103c7d:	39 ca                	cmp    %ecx,%edx
f0103c7f:	74 3a                	je     f0103cbb <debuginfo_eip+0x24c>
f0103c81:	83 c0 0c             	add    $0xc,%eax
						  lline < rfun && stabs[lline].n_type == N_PSYM;
f0103c84:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0103c88:	74 ec                	je     f0103c76 <debuginfo_eip+0x207>
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0103c8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c8f:	eb 2f                	jmp    f0103cc0 <debuginfo_eip+0x251>
			 // Make sure this memory is valid.
			 // Return -1 if it is not.  Hint: Call user_mem_check.
			 // LAB 3: Your code here.

			 if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0)
				 return -1;
f0103c91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c96:	eb 28                	jmp    f0103cc0 <debuginfo_eip+0x251>

			 // Make sure the STABS and string table memory is valid.
			 // LAB 3: Your code here.

			 if ((user_mem_check (curenv, (void*) stabs, (uintptr_t)(stab_end - stabs), PTE_U) < 0) || (user_mem_check (curenv, (void*) stabstr, (uintptr_t)(stabstr_end - stabstr), PTE_U) < 0))
				 return -1;
f0103c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c9d:	eb 21                	jmp    f0103cc0 <debuginfo_eip+0x251>
f0103c9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ca4:	eb 1a                	jmp    f0103cc0 <debuginfo_eip+0x251>
   }

	   // String table validity checks
	   if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
			 return -1;
f0103ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cab:	eb 13                	jmp    f0103cc0 <debuginfo_eip+0x251>
f0103cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cb2:	eb 0c                	jmp    f0103cc0 <debuginfo_eip+0x251>
	   // Search the entire set of stabs for the source file (type N_SO).
	   lfile = 0;
	   rfile = (stab_end - stabs) - 1;
	   stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	   if (lfile == 0)
			 return -1;
f0103cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cb9:	eb 05                	jmp    f0103cc0 <debuginfo_eip+0x251>
			 for (lline = lfun + 1;
						  lline < rfun && stabs[lline].n_type == N_PSYM;
						  lline++)
				    info->eip_fn_narg++;

	   return 0;
f0103cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cc3:	5b                   	pop    %ebx
f0103cc4:	5e                   	pop    %esi
f0103cc5:	5f                   	pop    %edi
f0103cc6:	5d                   	pop    %ebp
f0103cc7:	c3                   	ret    

f0103cc8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103cc8:	55                   	push   %ebp
f0103cc9:	89 e5                	mov    %esp,%ebp
f0103ccb:	57                   	push   %edi
f0103ccc:	56                   	push   %esi
f0103ccd:	53                   	push   %ebx
f0103cce:	83 ec 1c             	sub    $0x1c,%esp
f0103cd1:	89 c7                	mov    %eax,%edi
f0103cd3:	89 d6                	mov    %edx,%esi
f0103cd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103cdb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103cde:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103ce1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103ce9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103cec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103cef:	39 d3                	cmp    %edx,%ebx
f0103cf1:	72 05                	jb     f0103cf8 <printnum+0x30>
f0103cf3:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103cf6:	77 45                	ja     f0103d3d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103cf8:	83 ec 0c             	sub    $0xc,%esp
f0103cfb:	ff 75 18             	pushl  0x18(%ebp)
f0103cfe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d01:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103d04:	53                   	push   %ebx
f0103d05:	ff 75 10             	pushl  0x10(%ebp)
f0103d08:	83 ec 08             	sub    $0x8,%esp
f0103d0b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d0e:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d11:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d14:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d17:	e8 44 09 00 00       	call   f0104660 <__udivdi3>
f0103d1c:	83 c4 18             	add    $0x18,%esp
f0103d1f:	52                   	push   %edx
f0103d20:	50                   	push   %eax
f0103d21:	89 f2                	mov    %esi,%edx
f0103d23:	89 f8                	mov    %edi,%eax
f0103d25:	e8 9e ff ff ff       	call   f0103cc8 <printnum>
f0103d2a:	83 c4 20             	add    $0x20,%esp
f0103d2d:	eb 18                	jmp    f0103d47 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d2f:	83 ec 08             	sub    $0x8,%esp
f0103d32:	56                   	push   %esi
f0103d33:	ff 75 18             	pushl  0x18(%ebp)
f0103d36:	ff d7                	call   *%edi
f0103d38:	83 c4 10             	add    $0x10,%esp
f0103d3b:	eb 03                	jmp    f0103d40 <printnum+0x78>
f0103d3d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103d40:	83 eb 01             	sub    $0x1,%ebx
f0103d43:	85 db                	test   %ebx,%ebx
f0103d45:	7f e8                	jg     f0103d2f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d47:	83 ec 08             	sub    $0x8,%esp
f0103d4a:	56                   	push   %esi
f0103d4b:	83 ec 04             	sub    $0x4,%esp
f0103d4e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d51:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d54:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d57:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d5a:	e8 31 0a 00 00       	call   f0104790 <__umoddi3>
f0103d5f:	83 c4 14             	add    $0x14,%esp
f0103d62:	0f be 80 d2 5e 10 f0 	movsbl -0xfefa12e(%eax),%eax
f0103d69:	50                   	push   %eax
f0103d6a:	ff d7                	call   *%edi
}
f0103d6c:	83 c4 10             	add    $0x10,%esp
f0103d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d72:	5b                   	pop    %ebx
f0103d73:	5e                   	pop    %esi
f0103d74:	5f                   	pop    %edi
f0103d75:	5d                   	pop    %ebp
f0103d76:	c3                   	ret    

f0103d77 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103d77:	55                   	push   %ebp
f0103d78:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103d7a:	83 fa 01             	cmp    $0x1,%edx
f0103d7d:	7e 0e                	jle    f0103d8d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103d7f:	8b 10                	mov    (%eax),%edx
f0103d81:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103d84:	89 08                	mov    %ecx,(%eax)
f0103d86:	8b 02                	mov    (%edx),%eax
f0103d88:	8b 52 04             	mov    0x4(%edx),%edx
f0103d8b:	eb 22                	jmp    f0103daf <getuint+0x38>
	else if (lflag)
f0103d8d:	85 d2                	test   %edx,%edx
f0103d8f:	74 10                	je     f0103da1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103d91:	8b 10                	mov    (%eax),%edx
f0103d93:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103d96:	89 08                	mov    %ecx,(%eax)
f0103d98:	8b 02                	mov    (%edx),%eax
f0103d9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d9f:	eb 0e                	jmp    f0103daf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103da1:	8b 10                	mov    (%eax),%edx
f0103da3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103da6:	89 08                	mov    %ecx,(%eax)
f0103da8:	8b 02                	mov    (%edx),%eax
f0103daa:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103daf:	5d                   	pop    %ebp
f0103db0:	c3                   	ret    

f0103db1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103db1:	55                   	push   %ebp
f0103db2:	89 e5                	mov    %esp,%ebp
f0103db4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103db7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103dbb:	8b 10                	mov    (%eax),%edx
f0103dbd:	3b 50 04             	cmp    0x4(%eax),%edx
f0103dc0:	73 0a                	jae    f0103dcc <sprintputch+0x1b>
		*b->buf++ = ch;
f0103dc2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103dc5:	89 08                	mov    %ecx,(%eax)
f0103dc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dca:	88 02                	mov    %al,(%edx)
}
f0103dcc:	5d                   	pop    %ebp
f0103dcd:	c3                   	ret    

f0103dce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103dce:	55                   	push   %ebp
f0103dcf:	89 e5                	mov    %esp,%ebp
f0103dd1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103dd4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103dd7:	50                   	push   %eax
f0103dd8:	ff 75 10             	pushl  0x10(%ebp)
f0103ddb:	ff 75 0c             	pushl  0xc(%ebp)
f0103dde:	ff 75 08             	pushl  0x8(%ebp)
f0103de1:	e8 05 00 00 00       	call   f0103deb <vprintfmt>
	va_end(ap);
}
f0103de6:	83 c4 10             	add    $0x10,%esp
f0103de9:	c9                   	leave  
f0103dea:	c3                   	ret    

f0103deb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103deb:	55                   	push   %ebp
f0103dec:	89 e5                	mov    %esp,%ebp
f0103dee:	57                   	push   %edi
f0103def:	56                   	push   %esi
f0103df0:	53                   	push   %ebx
f0103df1:	83 ec 2c             	sub    $0x2c,%esp
f0103df4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103df7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103dfa:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103dfd:	eb 12                	jmp    f0103e11 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103dff:	85 c0                	test   %eax,%eax
f0103e01:	0f 84 89 03 00 00    	je     f0104190 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0103e07:	83 ec 08             	sub    $0x8,%esp
f0103e0a:	53                   	push   %ebx
f0103e0b:	50                   	push   %eax
f0103e0c:	ff d6                	call   *%esi
f0103e0e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103e11:	83 c7 01             	add    $0x1,%edi
f0103e14:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103e18:	83 f8 25             	cmp    $0x25,%eax
f0103e1b:	75 e2                	jne    f0103dff <vprintfmt+0x14>
f0103e1d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103e21:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103e28:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103e2f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103e36:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e3b:	eb 07                	jmp    f0103e44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103e40:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e44:	8d 47 01             	lea    0x1(%edi),%eax
f0103e47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e4a:	0f b6 07             	movzbl (%edi),%eax
f0103e4d:	0f b6 c8             	movzbl %al,%ecx
f0103e50:	83 e8 23             	sub    $0x23,%eax
f0103e53:	3c 55                	cmp    $0x55,%al
f0103e55:	0f 87 1a 03 00 00    	ja     f0104175 <vprintfmt+0x38a>
f0103e5b:	0f b6 c0             	movzbl %al,%eax
f0103e5e:	ff 24 85 5c 5f 10 f0 	jmp    *-0xfefa0a4(,%eax,4)
f0103e65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103e68:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103e6c:	eb d6                	jmp    f0103e44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e71:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103e79:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103e7c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0103e80:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103e83:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103e86:	83 fa 09             	cmp    $0x9,%edx
f0103e89:	77 39                	ja     f0103ec4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103e8b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103e8e:	eb e9                	jmp    f0103e79 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103e90:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e93:	8d 48 04             	lea    0x4(%eax),%ecx
f0103e96:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103e99:	8b 00                	mov    (%eax),%eax
f0103e9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103ea1:	eb 27                	jmp    f0103eca <vprintfmt+0xdf>
f0103ea3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ea6:	85 c0                	test   %eax,%eax
f0103ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103ead:	0f 49 c8             	cmovns %eax,%ecx
f0103eb0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103eb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103eb6:	eb 8c                	jmp    f0103e44 <vprintfmt+0x59>
f0103eb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103ebb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103ec2:	eb 80                	jmp    f0103e44 <vprintfmt+0x59>
f0103ec4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103ec7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103eca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103ece:	0f 89 70 ff ff ff    	jns    f0103e44 <vprintfmt+0x59>
				width = precision, precision = -1;
f0103ed4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ed7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103eda:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103ee1:	e9 5e ff ff ff       	jmp    f0103e44 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ee6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ee9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103eec:	e9 53 ff ff ff       	jmp    f0103e44 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103ef1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ef4:	8d 50 04             	lea    0x4(%eax),%edx
f0103ef7:	89 55 14             	mov    %edx,0x14(%ebp)
f0103efa:	83 ec 08             	sub    $0x8,%esp
f0103efd:	53                   	push   %ebx
f0103efe:	ff 30                	pushl  (%eax)
f0103f00:	ff d6                	call   *%esi
			break;
f0103f02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103f08:	e9 04 ff ff ff       	jmp    f0103e11 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103f0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f10:	8d 50 04             	lea    0x4(%eax),%edx
f0103f13:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f16:	8b 00                	mov    (%eax),%eax
f0103f18:	99                   	cltd   
f0103f19:	31 d0                	xor    %edx,%eax
f0103f1b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103f1d:	83 f8 06             	cmp    $0x6,%eax
f0103f20:	7f 0b                	jg     f0103f2d <vprintfmt+0x142>
f0103f22:	8b 14 85 b4 60 10 f0 	mov    -0xfef9f4c(,%eax,4),%edx
f0103f29:	85 d2                	test   %edx,%edx
f0103f2b:	75 18                	jne    f0103f45 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0103f2d:	50                   	push   %eax
f0103f2e:	68 ea 5e 10 f0       	push   $0xf0105eea
f0103f33:	53                   	push   %ebx
f0103f34:	56                   	push   %esi
f0103f35:	e8 94 fe ff ff       	call   f0103dce <printfmt>
f0103f3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103f40:	e9 cc fe ff ff       	jmp    f0103e11 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103f45:	52                   	push   %edx
f0103f46:	68 8a 4e 10 f0       	push   $0xf0104e8a
f0103f4b:	53                   	push   %ebx
f0103f4c:	56                   	push   %esi
f0103f4d:	e8 7c fe ff ff       	call   f0103dce <printfmt>
f0103f52:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f58:	e9 b4 fe ff ff       	jmp    f0103e11 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103f5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f60:	8d 50 04             	lea    0x4(%eax),%edx
f0103f63:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f66:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103f68:	85 ff                	test   %edi,%edi
f0103f6a:	b8 e3 5e 10 f0       	mov    $0xf0105ee3,%eax
f0103f6f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103f72:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103f76:	0f 8e 94 00 00 00    	jle    f0104010 <vprintfmt+0x225>
f0103f7c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103f80:	0f 84 98 00 00 00    	je     f010401e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f86:	83 ec 08             	sub    $0x8,%esp
f0103f89:	ff 75 d0             	pushl  -0x30(%ebp)
f0103f8c:	57                   	push   %edi
f0103f8d:	e8 5f 03 00 00       	call   f01042f1 <strnlen>
f0103f92:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f95:	29 c1                	sub    %eax,%ecx
f0103f97:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103f9a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103f9d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103fa1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103fa4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103fa7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fa9:	eb 0f                	jmp    f0103fba <vprintfmt+0x1cf>
					putch(padc, putdat);
f0103fab:	83 ec 08             	sub    $0x8,%esp
f0103fae:	53                   	push   %ebx
f0103faf:	ff 75 e0             	pushl  -0x20(%ebp)
f0103fb2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fb4:	83 ef 01             	sub    $0x1,%edi
f0103fb7:	83 c4 10             	add    $0x10,%esp
f0103fba:	85 ff                	test   %edi,%edi
f0103fbc:	7f ed                	jg     f0103fab <vprintfmt+0x1c0>
f0103fbe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103fc1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103fc4:	85 c9                	test   %ecx,%ecx
f0103fc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fcb:	0f 49 c1             	cmovns %ecx,%eax
f0103fce:	29 c1                	sub    %eax,%ecx
f0103fd0:	89 75 08             	mov    %esi,0x8(%ebp)
f0103fd3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103fd6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103fd9:	89 cb                	mov    %ecx,%ebx
f0103fdb:	eb 4d                	jmp    f010402a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103fdd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103fe1:	74 1b                	je     f0103ffe <vprintfmt+0x213>
f0103fe3:	0f be c0             	movsbl %al,%eax
f0103fe6:	83 e8 20             	sub    $0x20,%eax
f0103fe9:	83 f8 5e             	cmp    $0x5e,%eax
f0103fec:	76 10                	jbe    f0103ffe <vprintfmt+0x213>
					putch('?', putdat);
f0103fee:	83 ec 08             	sub    $0x8,%esp
f0103ff1:	ff 75 0c             	pushl  0xc(%ebp)
f0103ff4:	6a 3f                	push   $0x3f
f0103ff6:	ff 55 08             	call   *0x8(%ebp)
f0103ff9:	83 c4 10             	add    $0x10,%esp
f0103ffc:	eb 0d                	jmp    f010400b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0103ffe:	83 ec 08             	sub    $0x8,%esp
f0104001:	ff 75 0c             	pushl  0xc(%ebp)
f0104004:	52                   	push   %edx
f0104005:	ff 55 08             	call   *0x8(%ebp)
f0104008:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010400b:	83 eb 01             	sub    $0x1,%ebx
f010400e:	eb 1a                	jmp    f010402a <vprintfmt+0x23f>
f0104010:	89 75 08             	mov    %esi,0x8(%ebp)
f0104013:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104016:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104019:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010401c:	eb 0c                	jmp    f010402a <vprintfmt+0x23f>
f010401e:	89 75 08             	mov    %esi,0x8(%ebp)
f0104021:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104024:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104027:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010402a:	83 c7 01             	add    $0x1,%edi
f010402d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104031:	0f be d0             	movsbl %al,%edx
f0104034:	85 d2                	test   %edx,%edx
f0104036:	74 23                	je     f010405b <vprintfmt+0x270>
f0104038:	85 f6                	test   %esi,%esi
f010403a:	78 a1                	js     f0103fdd <vprintfmt+0x1f2>
f010403c:	83 ee 01             	sub    $0x1,%esi
f010403f:	79 9c                	jns    f0103fdd <vprintfmt+0x1f2>
f0104041:	89 df                	mov    %ebx,%edi
f0104043:	8b 75 08             	mov    0x8(%ebp),%esi
f0104046:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104049:	eb 18                	jmp    f0104063 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010404b:	83 ec 08             	sub    $0x8,%esp
f010404e:	53                   	push   %ebx
f010404f:	6a 20                	push   $0x20
f0104051:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104053:	83 ef 01             	sub    $0x1,%edi
f0104056:	83 c4 10             	add    $0x10,%esp
f0104059:	eb 08                	jmp    f0104063 <vprintfmt+0x278>
f010405b:	89 df                	mov    %ebx,%edi
f010405d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104060:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104063:	85 ff                	test   %edi,%edi
f0104065:	7f e4                	jg     f010404b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104067:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010406a:	e9 a2 fd ff ff       	jmp    f0103e11 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010406f:	83 fa 01             	cmp    $0x1,%edx
f0104072:	7e 16                	jle    f010408a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104074:	8b 45 14             	mov    0x14(%ebp),%eax
f0104077:	8d 50 08             	lea    0x8(%eax),%edx
f010407a:	89 55 14             	mov    %edx,0x14(%ebp)
f010407d:	8b 50 04             	mov    0x4(%eax),%edx
f0104080:	8b 00                	mov    (%eax),%eax
f0104082:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104085:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104088:	eb 32                	jmp    f01040bc <vprintfmt+0x2d1>
	else if (lflag)
f010408a:	85 d2                	test   %edx,%edx
f010408c:	74 18                	je     f01040a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010408e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104091:	8d 50 04             	lea    0x4(%eax),%edx
f0104094:	89 55 14             	mov    %edx,0x14(%ebp)
f0104097:	8b 00                	mov    (%eax),%eax
f0104099:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010409c:	89 c1                	mov    %eax,%ecx
f010409e:	c1 f9 1f             	sar    $0x1f,%ecx
f01040a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01040a4:	eb 16                	jmp    f01040bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01040a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01040a9:	8d 50 04             	lea    0x4(%eax),%edx
f01040ac:	89 55 14             	mov    %edx,0x14(%ebp)
f01040af:	8b 00                	mov    (%eax),%eax
f01040b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040b4:	89 c1                	mov    %eax,%ecx
f01040b6:	c1 f9 1f             	sar    $0x1f,%ecx
f01040b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01040bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01040bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01040c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01040c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01040cb:	79 74                	jns    f0104141 <vprintfmt+0x356>
				putch('-', putdat);
f01040cd:	83 ec 08             	sub    $0x8,%esp
f01040d0:	53                   	push   %ebx
f01040d1:	6a 2d                	push   $0x2d
f01040d3:	ff d6                	call   *%esi
				num = -(long long) num;
f01040d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01040d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040db:	f7 d8                	neg    %eax
f01040dd:	83 d2 00             	adc    $0x0,%edx
f01040e0:	f7 da                	neg    %edx
f01040e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01040e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01040ea:	eb 55                	jmp    f0104141 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01040ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01040ef:	e8 83 fc ff ff       	call   f0103d77 <getuint>
			base = 10;
f01040f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01040f9:	eb 46                	jmp    f0104141 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01040fb:	8d 45 14             	lea    0x14(%ebp),%eax
f01040fe:	e8 74 fc ff ff       	call   f0103d77 <getuint>
			base = 8;
f0104103:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0104108:	eb 37                	jmp    f0104141 <vprintfmt+0x356>
			putch('X', putdat);
		*/	break;

		// pointer
		case 'p':
			putch('0', putdat);
f010410a:	83 ec 08             	sub    $0x8,%esp
f010410d:	53                   	push   %ebx
f010410e:	6a 30                	push   $0x30
f0104110:	ff d6                	call   *%esi
			putch('x', putdat);
f0104112:	83 c4 08             	add    $0x8,%esp
f0104115:	53                   	push   %ebx
f0104116:	6a 78                	push   $0x78
f0104118:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010411a:	8b 45 14             	mov    0x14(%ebp),%eax
f010411d:	8d 50 04             	lea    0x4(%eax),%edx
f0104120:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104123:	8b 00                	mov    (%eax),%eax
f0104125:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010412a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010412d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104132:	eb 0d                	jmp    f0104141 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104134:	8d 45 14             	lea    0x14(%ebp),%eax
f0104137:	e8 3b fc ff ff       	call   f0103d77 <getuint>
			base = 16;
f010413c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104141:	83 ec 0c             	sub    $0xc,%esp
f0104144:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104148:	57                   	push   %edi
f0104149:	ff 75 e0             	pushl  -0x20(%ebp)
f010414c:	51                   	push   %ecx
f010414d:	52                   	push   %edx
f010414e:	50                   	push   %eax
f010414f:	89 da                	mov    %ebx,%edx
f0104151:	89 f0                	mov    %esi,%eax
f0104153:	e8 70 fb ff ff       	call   f0103cc8 <printnum>
			break;
f0104158:	83 c4 20             	add    $0x20,%esp
f010415b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010415e:	e9 ae fc ff ff       	jmp    f0103e11 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104163:	83 ec 08             	sub    $0x8,%esp
f0104166:	53                   	push   %ebx
f0104167:	51                   	push   %ecx
f0104168:	ff d6                	call   *%esi
			break;
f010416a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010416d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104170:	e9 9c fc ff ff       	jmp    f0103e11 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104175:	83 ec 08             	sub    $0x8,%esp
f0104178:	53                   	push   %ebx
f0104179:	6a 25                	push   $0x25
f010417b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010417d:	83 c4 10             	add    $0x10,%esp
f0104180:	eb 03                	jmp    f0104185 <vprintfmt+0x39a>
f0104182:	83 ef 01             	sub    $0x1,%edi
f0104185:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104189:	75 f7                	jne    f0104182 <vprintfmt+0x397>
f010418b:	e9 81 fc ff ff       	jmp    f0103e11 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104190:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104193:	5b                   	pop    %ebx
f0104194:	5e                   	pop    %esi
f0104195:	5f                   	pop    %edi
f0104196:	5d                   	pop    %ebp
f0104197:	c3                   	ret    

f0104198 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104198:	55                   	push   %ebp
f0104199:	89 e5                	mov    %esp,%ebp
f010419b:	83 ec 18             	sub    $0x18,%esp
f010419e:	8b 45 08             	mov    0x8(%ebp),%eax
f01041a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01041a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01041a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01041ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01041ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01041b5:	85 c0                	test   %eax,%eax
f01041b7:	74 26                	je     f01041df <vsnprintf+0x47>
f01041b9:	85 d2                	test   %edx,%edx
f01041bb:	7e 22                	jle    f01041df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01041bd:	ff 75 14             	pushl  0x14(%ebp)
f01041c0:	ff 75 10             	pushl  0x10(%ebp)
f01041c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01041c6:	50                   	push   %eax
f01041c7:	68 b1 3d 10 f0       	push   $0xf0103db1
f01041cc:	e8 1a fc ff ff       	call   f0103deb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01041d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01041d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01041d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041da:	83 c4 10             	add    $0x10,%esp
f01041dd:	eb 05                	jmp    f01041e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01041df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01041e4:	c9                   	leave  
f01041e5:	c3                   	ret    

f01041e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01041e6:	55                   	push   %ebp
f01041e7:	89 e5                	mov    %esp,%ebp
f01041e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01041ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01041ef:	50                   	push   %eax
f01041f0:	ff 75 10             	pushl  0x10(%ebp)
f01041f3:	ff 75 0c             	pushl  0xc(%ebp)
f01041f6:	ff 75 08             	pushl  0x8(%ebp)
f01041f9:	e8 9a ff ff ff       	call   f0104198 <vsnprintf>
	va_end(ap);

	return rc;
}
f01041fe:	c9                   	leave  
f01041ff:	c3                   	ret    

f0104200 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104200:	55                   	push   %ebp
f0104201:	89 e5                	mov    %esp,%ebp
f0104203:	57                   	push   %edi
f0104204:	56                   	push   %esi
f0104205:	53                   	push   %ebx
f0104206:	83 ec 0c             	sub    $0xc,%esp
f0104209:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010420c:	85 c0                	test   %eax,%eax
f010420e:	74 11                	je     f0104221 <readline+0x21>
		cprintf("%s", prompt);
f0104210:	83 ec 08             	sub    $0x8,%esp
f0104213:	50                   	push   %eax
f0104214:	68 8a 4e 10 f0       	push   $0xf0104e8a
f0104219:	e8 b3 ee ff ff       	call   f01030d1 <cprintf>
f010421e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104221:	83 ec 0c             	sub    $0xc,%esp
f0104224:	6a 00                	push   $0x0
f0104226:	e8 17 c4 ff ff       	call   f0100642 <iscons>
f010422b:	89 c7                	mov    %eax,%edi
f010422d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104230:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104235:	e8 f7 c3 ff ff       	call   f0100631 <getchar>
f010423a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010423c:	85 c0                	test   %eax,%eax
f010423e:	79 18                	jns    f0104258 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104240:	83 ec 08             	sub    $0x8,%esp
f0104243:	50                   	push   %eax
f0104244:	68 d0 60 10 f0       	push   $0xf01060d0
f0104249:	e8 83 ee ff ff       	call   f01030d1 <cprintf>
			return NULL;
f010424e:	83 c4 10             	add    $0x10,%esp
f0104251:	b8 00 00 00 00       	mov    $0x0,%eax
f0104256:	eb 79                	jmp    f01042d1 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104258:	83 f8 08             	cmp    $0x8,%eax
f010425b:	0f 94 c2             	sete   %dl
f010425e:	83 f8 7f             	cmp    $0x7f,%eax
f0104261:	0f 94 c0             	sete   %al
f0104264:	08 c2                	or     %al,%dl
f0104266:	74 1a                	je     f0104282 <readline+0x82>
f0104268:	85 f6                	test   %esi,%esi
f010426a:	7e 16                	jle    f0104282 <readline+0x82>
			if (echoing)
f010426c:	85 ff                	test   %edi,%edi
f010426e:	74 0d                	je     f010427d <readline+0x7d>
				cputchar('\b');
f0104270:	83 ec 0c             	sub    $0xc,%esp
f0104273:	6a 08                	push   $0x8
f0104275:	e8 a7 c3 ff ff       	call   f0100621 <cputchar>
f010427a:	83 c4 10             	add    $0x10,%esp
			i--;
f010427d:	83 ee 01             	sub    $0x1,%esi
f0104280:	eb b3                	jmp    f0104235 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104282:	83 fb 1f             	cmp    $0x1f,%ebx
f0104285:	7e 23                	jle    f01042aa <readline+0xaa>
f0104287:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010428d:	7f 1b                	jg     f01042aa <readline+0xaa>
			if (echoing)
f010428f:	85 ff                	test   %edi,%edi
f0104291:	74 0c                	je     f010429f <readline+0x9f>
				cputchar(c);
f0104293:	83 ec 0c             	sub    $0xc,%esp
f0104296:	53                   	push   %ebx
f0104297:	e8 85 c3 ff ff       	call   f0100621 <cputchar>
f010429c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010429f:	88 9e 40 28 17 f0    	mov    %bl,-0xfe8d7c0(%esi)
f01042a5:	8d 76 01             	lea    0x1(%esi),%esi
f01042a8:	eb 8b                	jmp    f0104235 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01042aa:	83 fb 0a             	cmp    $0xa,%ebx
f01042ad:	74 05                	je     f01042b4 <readline+0xb4>
f01042af:	83 fb 0d             	cmp    $0xd,%ebx
f01042b2:	75 81                	jne    f0104235 <readline+0x35>
			if (echoing)
f01042b4:	85 ff                	test   %edi,%edi
f01042b6:	74 0d                	je     f01042c5 <readline+0xc5>
				cputchar('\n');
f01042b8:	83 ec 0c             	sub    $0xc,%esp
f01042bb:	6a 0a                	push   $0xa
f01042bd:	e8 5f c3 ff ff       	call   f0100621 <cputchar>
f01042c2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01042c5:	c6 86 40 28 17 f0 00 	movb   $0x0,-0xfe8d7c0(%esi)
			return buf;
f01042cc:	b8 40 28 17 f0       	mov    $0xf0172840,%eax
		}
	}
}
f01042d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042d4:	5b                   	pop    %ebx
f01042d5:	5e                   	pop    %esi
f01042d6:	5f                   	pop    %edi
f01042d7:	5d                   	pop    %ebp
f01042d8:	c3                   	ret    

f01042d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01042d9:	55                   	push   %ebp
f01042da:	89 e5                	mov    %esp,%ebp
f01042dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01042df:	b8 00 00 00 00       	mov    $0x0,%eax
f01042e4:	eb 03                	jmp    f01042e9 <strlen+0x10>
		n++;
f01042e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01042e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01042ed:	75 f7                	jne    f01042e6 <strlen+0xd>
		n++;
	return n;
}
f01042ef:	5d                   	pop    %ebp
f01042f0:	c3                   	ret    

f01042f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01042f1:	55                   	push   %ebp
f01042f2:	89 e5                	mov    %esp,%ebp
f01042f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01042f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01042fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01042ff:	eb 03                	jmp    f0104304 <strnlen+0x13>
		n++;
f0104301:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104304:	39 c2                	cmp    %eax,%edx
f0104306:	74 08                	je     f0104310 <strnlen+0x1f>
f0104308:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010430c:	75 f3                	jne    f0104301 <strnlen+0x10>
f010430e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104310:	5d                   	pop    %ebp
f0104311:	c3                   	ret    

f0104312 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104312:	55                   	push   %ebp
f0104313:	89 e5                	mov    %esp,%ebp
f0104315:	53                   	push   %ebx
f0104316:	8b 45 08             	mov    0x8(%ebp),%eax
f0104319:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010431c:	89 c2                	mov    %eax,%edx
f010431e:	83 c2 01             	add    $0x1,%edx
f0104321:	83 c1 01             	add    $0x1,%ecx
f0104324:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104328:	88 5a ff             	mov    %bl,-0x1(%edx)
f010432b:	84 db                	test   %bl,%bl
f010432d:	75 ef                	jne    f010431e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010432f:	5b                   	pop    %ebx
f0104330:	5d                   	pop    %ebp
f0104331:	c3                   	ret    

f0104332 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104332:	55                   	push   %ebp
f0104333:	89 e5                	mov    %esp,%ebp
f0104335:	53                   	push   %ebx
f0104336:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104339:	53                   	push   %ebx
f010433a:	e8 9a ff ff ff       	call   f01042d9 <strlen>
f010433f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104342:	ff 75 0c             	pushl  0xc(%ebp)
f0104345:	01 d8                	add    %ebx,%eax
f0104347:	50                   	push   %eax
f0104348:	e8 c5 ff ff ff       	call   f0104312 <strcpy>
	return dst;
}
f010434d:	89 d8                	mov    %ebx,%eax
f010434f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104352:	c9                   	leave  
f0104353:	c3                   	ret    

f0104354 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104354:	55                   	push   %ebp
f0104355:	89 e5                	mov    %esp,%ebp
f0104357:	56                   	push   %esi
f0104358:	53                   	push   %ebx
f0104359:	8b 75 08             	mov    0x8(%ebp),%esi
f010435c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010435f:	89 f3                	mov    %esi,%ebx
f0104361:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104364:	89 f2                	mov    %esi,%edx
f0104366:	eb 0f                	jmp    f0104377 <strncpy+0x23>
		*dst++ = *src;
f0104368:	83 c2 01             	add    $0x1,%edx
f010436b:	0f b6 01             	movzbl (%ecx),%eax
f010436e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104371:	80 39 01             	cmpb   $0x1,(%ecx)
f0104374:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104377:	39 da                	cmp    %ebx,%edx
f0104379:	75 ed                	jne    f0104368 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010437b:	89 f0                	mov    %esi,%eax
f010437d:	5b                   	pop    %ebx
f010437e:	5e                   	pop    %esi
f010437f:	5d                   	pop    %ebp
f0104380:	c3                   	ret    

f0104381 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104381:	55                   	push   %ebp
f0104382:	89 e5                	mov    %esp,%ebp
f0104384:	56                   	push   %esi
f0104385:	53                   	push   %ebx
f0104386:	8b 75 08             	mov    0x8(%ebp),%esi
f0104389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010438c:	8b 55 10             	mov    0x10(%ebp),%edx
f010438f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104391:	85 d2                	test   %edx,%edx
f0104393:	74 21                	je     f01043b6 <strlcpy+0x35>
f0104395:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104399:	89 f2                	mov    %esi,%edx
f010439b:	eb 09                	jmp    f01043a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010439d:	83 c2 01             	add    $0x1,%edx
f01043a0:	83 c1 01             	add    $0x1,%ecx
f01043a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01043a6:	39 c2                	cmp    %eax,%edx
f01043a8:	74 09                	je     f01043b3 <strlcpy+0x32>
f01043aa:	0f b6 19             	movzbl (%ecx),%ebx
f01043ad:	84 db                	test   %bl,%bl
f01043af:	75 ec                	jne    f010439d <strlcpy+0x1c>
f01043b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01043b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01043b6:	29 f0                	sub    %esi,%eax
}
f01043b8:	5b                   	pop    %ebx
f01043b9:	5e                   	pop    %esi
f01043ba:	5d                   	pop    %ebp
f01043bb:	c3                   	ret    

f01043bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01043bc:	55                   	push   %ebp
f01043bd:	89 e5                	mov    %esp,%ebp
f01043bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01043c5:	eb 06                	jmp    f01043cd <strcmp+0x11>
		p++, q++;
f01043c7:	83 c1 01             	add    $0x1,%ecx
f01043ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01043cd:	0f b6 01             	movzbl (%ecx),%eax
f01043d0:	84 c0                	test   %al,%al
f01043d2:	74 04                	je     f01043d8 <strcmp+0x1c>
f01043d4:	3a 02                	cmp    (%edx),%al
f01043d6:	74 ef                	je     f01043c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01043d8:	0f b6 c0             	movzbl %al,%eax
f01043db:	0f b6 12             	movzbl (%edx),%edx
f01043de:	29 d0                	sub    %edx,%eax
}
f01043e0:	5d                   	pop    %ebp
f01043e1:	c3                   	ret    

f01043e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01043e2:	55                   	push   %ebp
f01043e3:	89 e5                	mov    %esp,%ebp
f01043e5:	53                   	push   %ebx
f01043e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01043e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043ec:	89 c3                	mov    %eax,%ebx
f01043ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01043f1:	eb 06                	jmp    f01043f9 <strncmp+0x17>
		n--, p++, q++;
f01043f3:	83 c0 01             	add    $0x1,%eax
f01043f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01043f9:	39 d8                	cmp    %ebx,%eax
f01043fb:	74 15                	je     f0104412 <strncmp+0x30>
f01043fd:	0f b6 08             	movzbl (%eax),%ecx
f0104400:	84 c9                	test   %cl,%cl
f0104402:	74 04                	je     f0104408 <strncmp+0x26>
f0104404:	3a 0a                	cmp    (%edx),%cl
f0104406:	74 eb                	je     f01043f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104408:	0f b6 00             	movzbl (%eax),%eax
f010440b:	0f b6 12             	movzbl (%edx),%edx
f010440e:	29 d0                	sub    %edx,%eax
f0104410:	eb 05                	jmp    f0104417 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104412:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104417:	5b                   	pop    %ebx
f0104418:	5d                   	pop    %ebp
f0104419:	c3                   	ret    

f010441a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010441a:	55                   	push   %ebp
f010441b:	89 e5                	mov    %esp,%ebp
f010441d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104420:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104424:	eb 07                	jmp    f010442d <strchr+0x13>
		if (*s == c)
f0104426:	38 ca                	cmp    %cl,%dl
f0104428:	74 0f                	je     f0104439 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010442a:	83 c0 01             	add    $0x1,%eax
f010442d:	0f b6 10             	movzbl (%eax),%edx
f0104430:	84 d2                	test   %dl,%dl
f0104432:	75 f2                	jne    f0104426 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104434:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104439:	5d                   	pop    %ebp
f010443a:	c3                   	ret    

f010443b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010443b:	55                   	push   %ebp
f010443c:	89 e5                	mov    %esp,%ebp
f010443e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104441:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104445:	eb 03                	jmp    f010444a <strfind+0xf>
f0104447:	83 c0 01             	add    $0x1,%eax
f010444a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010444d:	38 ca                	cmp    %cl,%dl
f010444f:	74 04                	je     f0104455 <strfind+0x1a>
f0104451:	84 d2                	test   %dl,%dl
f0104453:	75 f2                	jne    f0104447 <strfind+0xc>
			break;
	return (char *) s;
}
f0104455:	5d                   	pop    %ebp
f0104456:	c3                   	ret    

f0104457 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104457:	55                   	push   %ebp
f0104458:	89 e5                	mov    %esp,%ebp
f010445a:	57                   	push   %edi
f010445b:	56                   	push   %esi
f010445c:	53                   	push   %ebx
f010445d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104460:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104463:	85 c9                	test   %ecx,%ecx
f0104465:	74 36                	je     f010449d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104467:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010446d:	75 28                	jne    f0104497 <memset+0x40>
f010446f:	f6 c1 03             	test   $0x3,%cl
f0104472:	75 23                	jne    f0104497 <memset+0x40>
		c &= 0xFF;
f0104474:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104478:	89 d3                	mov    %edx,%ebx
f010447a:	c1 e3 08             	shl    $0x8,%ebx
f010447d:	89 d6                	mov    %edx,%esi
f010447f:	c1 e6 18             	shl    $0x18,%esi
f0104482:	89 d0                	mov    %edx,%eax
f0104484:	c1 e0 10             	shl    $0x10,%eax
f0104487:	09 f0                	or     %esi,%eax
f0104489:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010448b:	89 d8                	mov    %ebx,%eax
f010448d:	09 d0                	or     %edx,%eax
f010448f:	c1 e9 02             	shr    $0x2,%ecx
f0104492:	fc                   	cld    
f0104493:	f3 ab                	rep stos %eax,%es:(%edi)
f0104495:	eb 06                	jmp    f010449d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104497:	8b 45 0c             	mov    0xc(%ebp),%eax
f010449a:	fc                   	cld    
f010449b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010449d:	89 f8                	mov    %edi,%eax
f010449f:	5b                   	pop    %ebx
f01044a0:	5e                   	pop    %esi
f01044a1:	5f                   	pop    %edi
f01044a2:	5d                   	pop    %ebp
f01044a3:	c3                   	ret    

f01044a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01044a4:	55                   	push   %ebp
f01044a5:	89 e5                	mov    %esp,%ebp
f01044a7:	57                   	push   %edi
f01044a8:	56                   	push   %esi
f01044a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01044ac:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01044b2:	39 c6                	cmp    %eax,%esi
f01044b4:	73 35                	jae    f01044eb <memmove+0x47>
f01044b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01044b9:	39 d0                	cmp    %edx,%eax
f01044bb:	73 2e                	jae    f01044eb <memmove+0x47>
		s += n;
		d += n;
f01044bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01044c0:	89 d6                	mov    %edx,%esi
f01044c2:	09 fe                	or     %edi,%esi
f01044c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01044ca:	75 13                	jne    f01044df <memmove+0x3b>
f01044cc:	f6 c1 03             	test   $0x3,%cl
f01044cf:	75 0e                	jne    f01044df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01044d1:	83 ef 04             	sub    $0x4,%edi
f01044d4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01044d7:	c1 e9 02             	shr    $0x2,%ecx
f01044da:	fd                   	std    
f01044db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01044dd:	eb 09                	jmp    f01044e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01044df:	83 ef 01             	sub    $0x1,%edi
f01044e2:	8d 72 ff             	lea    -0x1(%edx),%esi
f01044e5:	fd                   	std    
f01044e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01044e8:	fc                   	cld    
f01044e9:	eb 1d                	jmp    f0104508 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01044eb:	89 f2                	mov    %esi,%edx
f01044ed:	09 c2                	or     %eax,%edx
f01044ef:	f6 c2 03             	test   $0x3,%dl
f01044f2:	75 0f                	jne    f0104503 <memmove+0x5f>
f01044f4:	f6 c1 03             	test   $0x3,%cl
f01044f7:	75 0a                	jne    f0104503 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01044f9:	c1 e9 02             	shr    $0x2,%ecx
f01044fc:	89 c7                	mov    %eax,%edi
f01044fe:	fc                   	cld    
f01044ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104501:	eb 05                	jmp    f0104508 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104503:	89 c7                	mov    %eax,%edi
f0104505:	fc                   	cld    
f0104506:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104508:	5e                   	pop    %esi
f0104509:	5f                   	pop    %edi
f010450a:	5d                   	pop    %ebp
f010450b:	c3                   	ret    

f010450c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010450c:	55                   	push   %ebp
f010450d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010450f:	ff 75 10             	pushl  0x10(%ebp)
f0104512:	ff 75 0c             	pushl  0xc(%ebp)
f0104515:	ff 75 08             	pushl  0x8(%ebp)
f0104518:	e8 87 ff ff ff       	call   f01044a4 <memmove>
}
f010451d:	c9                   	leave  
f010451e:	c3                   	ret    

f010451f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010451f:	55                   	push   %ebp
f0104520:	89 e5                	mov    %esp,%ebp
f0104522:	56                   	push   %esi
f0104523:	53                   	push   %ebx
f0104524:	8b 45 08             	mov    0x8(%ebp),%eax
f0104527:	8b 55 0c             	mov    0xc(%ebp),%edx
f010452a:	89 c6                	mov    %eax,%esi
f010452c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010452f:	eb 1a                	jmp    f010454b <memcmp+0x2c>
		if (*s1 != *s2)
f0104531:	0f b6 08             	movzbl (%eax),%ecx
f0104534:	0f b6 1a             	movzbl (%edx),%ebx
f0104537:	38 d9                	cmp    %bl,%cl
f0104539:	74 0a                	je     f0104545 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010453b:	0f b6 c1             	movzbl %cl,%eax
f010453e:	0f b6 db             	movzbl %bl,%ebx
f0104541:	29 d8                	sub    %ebx,%eax
f0104543:	eb 0f                	jmp    f0104554 <memcmp+0x35>
		s1++, s2++;
f0104545:	83 c0 01             	add    $0x1,%eax
f0104548:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010454b:	39 f0                	cmp    %esi,%eax
f010454d:	75 e2                	jne    f0104531 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010454f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104554:	5b                   	pop    %ebx
f0104555:	5e                   	pop    %esi
f0104556:	5d                   	pop    %ebp
f0104557:	c3                   	ret    

f0104558 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104558:	55                   	push   %ebp
f0104559:	89 e5                	mov    %esp,%ebp
f010455b:	53                   	push   %ebx
f010455c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010455f:	89 c1                	mov    %eax,%ecx
f0104561:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104564:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104568:	eb 0a                	jmp    f0104574 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010456a:	0f b6 10             	movzbl (%eax),%edx
f010456d:	39 da                	cmp    %ebx,%edx
f010456f:	74 07                	je     f0104578 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104571:	83 c0 01             	add    $0x1,%eax
f0104574:	39 c8                	cmp    %ecx,%eax
f0104576:	72 f2                	jb     f010456a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104578:	5b                   	pop    %ebx
f0104579:	5d                   	pop    %ebp
f010457a:	c3                   	ret    

f010457b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010457b:	55                   	push   %ebp
f010457c:	89 e5                	mov    %esp,%ebp
f010457e:	57                   	push   %edi
f010457f:	56                   	push   %esi
f0104580:	53                   	push   %ebx
f0104581:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104584:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104587:	eb 03                	jmp    f010458c <strtol+0x11>
		s++;
f0104589:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010458c:	0f b6 01             	movzbl (%ecx),%eax
f010458f:	3c 20                	cmp    $0x20,%al
f0104591:	74 f6                	je     f0104589 <strtol+0xe>
f0104593:	3c 09                	cmp    $0x9,%al
f0104595:	74 f2                	je     f0104589 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104597:	3c 2b                	cmp    $0x2b,%al
f0104599:	75 0a                	jne    f01045a5 <strtol+0x2a>
		s++;
f010459b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010459e:	bf 00 00 00 00       	mov    $0x0,%edi
f01045a3:	eb 11                	jmp    f01045b6 <strtol+0x3b>
f01045a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01045aa:	3c 2d                	cmp    $0x2d,%al
f01045ac:	75 08                	jne    f01045b6 <strtol+0x3b>
		s++, neg = 1;
f01045ae:	83 c1 01             	add    $0x1,%ecx
f01045b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01045b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01045bc:	75 15                	jne    f01045d3 <strtol+0x58>
f01045be:	80 39 30             	cmpb   $0x30,(%ecx)
f01045c1:	75 10                	jne    f01045d3 <strtol+0x58>
f01045c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01045c7:	75 7c                	jne    f0104645 <strtol+0xca>
		s += 2, base = 16;
f01045c9:	83 c1 02             	add    $0x2,%ecx
f01045cc:	bb 10 00 00 00       	mov    $0x10,%ebx
f01045d1:	eb 16                	jmp    f01045e9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01045d3:	85 db                	test   %ebx,%ebx
f01045d5:	75 12                	jne    f01045e9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01045d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01045dc:	80 39 30             	cmpb   $0x30,(%ecx)
f01045df:	75 08                	jne    f01045e9 <strtol+0x6e>
		s++, base = 8;
f01045e1:	83 c1 01             	add    $0x1,%ecx
f01045e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01045e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01045ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01045f1:	0f b6 11             	movzbl (%ecx),%edx
f01045f4:	8d 72 d0             	lea    -0x30(%edx),%esi
f01045f7:	89 f3                	mov    %esi,%ebx
f01045f9:	80 fb 09             	cmp    $0x9,%bl
f01045fc:	77 08                	ja     f0104606 <strtol+0x8b>
			dig = *s - '0';
f01045fe:	0f be d2             	movsbl %dl,%edx
f0104601:	83 ea 30             	sub    $0x30,%edx
f0104604:	eb 22                	jmp    f0104628 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0104606:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104609:	89 f3                	mov    %esi,%ebx
f010460b:	80 fb 19             	cmp    $0x19,%bl
f010460e:	77 08                	ja     f0104618 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104610:	0f be d2             	movsbl %dl,%edx
f0104613:	83 ea 57             	sub    $0x57,%edx
f0104616:	eb 10                	jmp    f0104628 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0104618:	8d 72 bf             	lea    -0x41(%edx),%esi
f010461b:	89 f3                	mov    %esi,%ebx
f010461d:	80 fb 19             	cmp    $0x19,%bl
f0104620:	77 16                	ja     f0104638 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104622:	0f be d2             	movsbl %dl,%edx
f0104625:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104628:	3b 55 10             	cmp    0x10(%ebp),%edx
f010462b:	7d 0b                	jge    f0104638 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010462d:	83 c1 01             	add    $0x1,%ecx
f0104630:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104634:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104636:	eb b9                	jmp    f01045f1 <strtol+0x76>

	if (endptr)
f0104638:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010463c:	74 0d                	je     f010464b <strtol+0xd0>
		*endptr = (char *) s;
f010463e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104641:	89 0e                	mov    %ecx,(%esi)
f0104643:	eb 06                	jmp    f010464b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104645:	85 db                	test   %ebx,%ebx
f0104647:	74 98                	je     f01045e1 <strtol+0x66>
f0104649:	eb 9e                	jmp    f01045e9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010464b:	89 c2                	mov    %eax,%edx
f010464d:	f7 da                	neg    %edx
f010464f:	85 ff                	test   %edi,%edi
f0104651:	0f 45 c2             	cmovne %edx,%eax
}
f0104654:	5b                   	pop    %ebx
f0104655:	5e                   	pop    %esi
f0104656:	5f                   	pop    %edi
f0104657:	5d                   	pop    %ebp
f0104658:	c3                   	ret    
f0104659:	66 90                	xchg   %ax,%ax
f010465b:	66 90                	xchg   %ax,%ax
f010465d:	66 90                	xchg   %ax,%ax
f010465f:	90                   	nop

f0104660 <__udivdi3>:
f0104660:	55                   	push   %ebp
f0104661:	57                   	push   %edi
f0104662:	56                   	push   %esi
f0104663:	53                   	push   %ebx
f0104664:	83 ec 1c             	sub    $0x1c,%esp
f0104667:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010466b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010466f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104673:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104677:	85 f6                	test   %esi,%esi
f0104679:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010467d:	89 ca                	mov    %ecx,%edx
f010467f:	89 f8                	mov    %edi,%eax
f0104681:	75 3d                	jne    f01046c0 <__udivdi3+0x60>
f0104683:	39 cf                	cmp    %ecx,%edi
f0104685:	0f 87 c5 00 00 00    	ja     f0104750 <__udivdi3+0xf0>
f010468b:	85 ff                	test   %edi,%edi
f010468d:	89 fd                	mov    %edi,%ebp
f010468f:	75 0b                	jne    f010469c <__udivdi3+0x3c>
f0104691:	b8 01 00 00 00       	mov    $0x1,%eax
f0104696:	31 d2                	xor    %edx,%edx
f0104698:	f7 f7                	div    %edi
f010469a:	89 c5                	mov    %eax,%ebp
f010469c:	89 c8                	mov    %ecx,%eax
f010469e:	31 d2                	xor    %edx,%edx
f01046a0:	f7 f5                	div    %ebp
f01046a2:	89 c1                	mov    %eax,%ecx
f01046a4:	89 d8                	mov    %ebx,%eax
f01046a6:	89 cf                	mov    %ecx,%edi
f01046a8:	f7 f5                	div    %ebp
f01046aa:	89 c3                	mov    %eax,%ebx
f01046ac:	89 d8                	mov    %ebx,%eax
f01046ae:	89 fa                	mov    %edi,%edx
f01046b0:	83 c4 1c             	add    $0x1c,%esp
f01046b3:	5b                   	pop    %ebx
f01046b4:	5e                   	pop    %esi
f01046b5:	5f                   	pop    %edi
f01046b6:	5d                   	pop    %ebp
f01046b7:	c3                   	ret    
f01046b8:	90                   	nop
f01046b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01046c0:	39 ce                	cmp    %ecx,%esi
f01046c2:	77 74                	ja     f0104738 <__udivdi3+0xd8>
f01046c4:	0f bd fe             	bsr    %esi,%edi
f01046c7:	83 f7 1f             	xor    $0x1f,%edi
f01046ca:	0f 84 98 00 00 00    	je     f0104768 <__udivdi3+0x108>
f01046d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01046d5:	89 f9                	mov    %edi,%ecx
f01046d7:	89 c5                	mov    %eax,%ebp
f01046d9:	29 fb                	sub    %edi,%ebx
f01046db:	d3 e6                	shl    %cl,%esi
f01046dd:	89 d9                	mov    %ebx,%ecx
f01046df:	d3 ed                	shr    %cl,%ebp
f01046e1:	89 f9                	mov    %edi,%ecx
f01046e3:	d3 e0                	shl    %cl,%eax
f01046e5:	09 ee                	or     %ebp,%esi
f01046e7:	89 d9                	mov    %ebx,%ecx
f01046e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01046ed:	89 d5                	mov    %edx,%ebp
f01046ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01046f3:	d3 ed                	shr    %cl,%ebp
f01046f5:	89 f9                	mov    %edi,%ecx
f01046f7:	d3 e2                	shl    %cl,%edx
f01046f9:	89 d9                	mov    %ebx,%ecx
f01046fb:	d3 e8                	shr    %cl,%eax
f01046fd:	09 c2                	or     %eax,%edx
f01046ff:	89 d0                	mov    %edx,%eax
f0104701:	89 ea                	mov    %ebp,%edx
f0104703:	f7 f6                	div    %esi
f0104705:	89 d5                	mov    %edx,%ebp
f0104707:	89 c3                	mov    %eax,%ebx
f0104709:	f7 64 24 0c          	mull   0xc(%esp)
f010470d:	39 d5                	cmp    %edx,%ebp
f010470f:	72 10                	jb     f0104721 <__udivdi3+0xc1>
f0104711:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104715:	89 f9                	mov    %edi,%ecx
f0104717:	d3 e6                	shl    %cl,%esi
f0104719:	39 c6                	cmp    %eax,%esi
f010471b:	73 07                	jae    f0104724 <__udivdi3+0xc4>
f010471d:	39 d5                	cmp    %edx,%ebp
f010471f:	75 03                	jne    f0104724 <__udivdi3+0xc4>
f0104721:	83 eb 01             	sub    $0x1,%ebx
f0104724:	31 ff                	xor    %edi,%edi
f0104726:	89 d8                	mov    %ebx,%eax
f0104728:	89 fa                	mov    %edi,%edx
f010472a:	83 c4 1c             	add    $0x1c,%esp
f010472d:	5b                   	pop    %ebx
f010472e:	5e                   	pop    %esi
f010472f:	5f                   	pop    %edi
f0104730:	5d                   	pop    %ebp
f0104731:	c3                   	ret    
f0104732:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104738:	31 ff                	xor    %edi,%edi
f010473a:	31 db                	xor    %ebx,%ebx
f010473c:	89 d8                	mov    %ebx,%eax
f010473e:	89 fa                	mov    %edi,%edx
f0104740:	83 c4 1c             	add    $0x1c,%esp
f0104743:	5b                   	pop    %ebx
f0104744:	5e                   	pop    %esi
f0104745:	5f                   	pop    %edi
f0104746:	5d                   	pop    %ebp
f0104747:	c3                   	ret    
f0104748:	90                   	nop
f0104749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104750:	89 d8                	mov    %ebx,%eax
f0104752:	f7 f7                	div    %edi
f0104754:	31 ff                	xor    %edi,%edi
f0104756:	89 c3                	mov    %eax,%ebx
f0104758:	89 d8                	mov    %ebx,%eax
f010475a:	89 fa                	mov    %edi,%edx
f010475c:	83 c4 1c             	add    $0x1c,%esp
f010475f:	5b                   	pop    %ebx
f0104760:	5e                   	pop    %esi
f0104761:	5f                   	pop    %edi
f0104762:	5d                   	pop    %ebp
f0104763:	c3                   	ret    
f0104764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104768:	39 ce                	cmp    %ecx,%esi
f010476a:	72 0c                	jb     f0104778 <__udivdi3+0x118>
f010476c:	31 db                	xor    %ebx,%ebx
f010476e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104772:	0f 87 34 ff ff ff    	ja     f01046ac <__udivdi3+0x4c>
f0104778:	bb 01 00 00 00       	mov    $0x1,%ebx
f010477d:	e9 2a ff ff ff       	jmp    f01046ac <__udivdi3+0x4c>
f0104782:	66 90                	xchg   %ax,%ax
f0104784:	66 90                	xchg   %ax,%ax
f0104786:	66 90                	xchg   %ax,%ax
f0104788:	66 90                	xchg   %ax,%ax
f010478a:	66 90                	xchg   %ax,%ax
f010478c:	66 90                	xchg   %ax,%ax
f010478e:	66 90                	xchg   %ax,%ax

f0104790 <__umoddi3>:
f0104790:	55                   	push   %ebp
f0104791:	57                   	push   %edi
f0104792:	56                   	push   %esi
f0104793:	53                   	push   %ebx
f0104794:	83 ec 1c             	sub    $0x1c,%esp
f0104797:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010479b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010479f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01047a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01047a7:	85 d2                	test   %edx,%edx
f01047a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01047ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01047b1:	89 f3                	mov    %esi,%ebx
f01047b3:	89 3c 24             	mov    %edi,(%esp)
f01047b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01047ba:	75 1c                	jne    f01047d8 <__umoddi3+0x48>
f01047bc:	39 f7                	cmp    %esi,%edi
f01047be:	76 50                	jbe    f0104810 <__umoddi3+0x80>
f01047c0:	89 c8                	mov    %ecx,%eax
f01047c2:	89 f2                	mov    %esi,%edx
f01047c4:	f7 f7                	div    %edi
f01047c6:	89 d0                	mov    %edx,%eax
f01047c8:	31 d2                	xor    %edx,%edx
f01047ca:	83 c4 1c             	add    $0x1c,%esp
f01047cd:	5b                   	pop    %ebx
f01047ce:	5e                   	pop    %esi
f01047cf:	5f                   	pop    %edi
f01047d0:	5d                   	pop    %ebp
f01047d1:	c3                   	ret    
f01047d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01047d8:	39 f2                	cmp    %esi,%edx
f01047da:	89 d0                	mov    %edx,%eax
f01047dc:	77 52                	ja     f0104830 <__umoddi3+0xa0>
f01047de:	0f bd ea             	bsr    %edx,%ebp
f01047e1:	83 f5 1f             	xor    $0x1f,%ebp
f01047e4:	75 5a                	jne    f0104840 <__umoddi3+0xb0>
f01047e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01047ea:	0f 82 e0 00 00 00    	jb     f01048d0 <__umoddi3+0x140>
f01047f0:	39 0c 24             	cmp    %ecx,(%esp)
f01047f3:	0f 86 d7 00 00 00    	jbe    f01048d0 <__umoddi3+0x140>
f01047f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01047fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104801:	83 c4 1c             	add    $0x1c,%esp
f0104804:	5b                   	pop    %ebx
f0104805:	5e                   	pop    %esi
f0104806:	5f                   	pop    %edi
f0104807:	5d                   	pop    %ebp
f0104808:	c3                   	ret    
f0104809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104810:	85 ff                	test   %edi,%edi
f0104812:	89 fd                	mov    %edi,%ebp
f0104814:	75 0b                	jne    f0104821 <__umoddi3+0x91>
f0104816:	b8 01 00 00 00       	mov    $0x1,%eax
f010481b:	31 d2                	xor    %edx,%edx
f010481d:	f7 f7                	div    %edi
f010481f:	89 c5                	mov    %eax,%ebp
f0104821:	89 f0                	mov    %esi,%eax
f0104823:	31 d2                	xor    %edx,%edx
f0104825:	f7 f5                	div    %ebp
f0104827:	89 c8                	mov    %ecx,%eax
f0104829:	f7 f5                	div    %ebp
f010482b:	89 d0                	mov    %edx,%eax
f010482d:	eb 99                	jmp    f01047c8 <__umoddi3+0x38>
f010482f:	90                   	nop
f0104830:	89 c8                	mov    %ecx,%eax
f0104832:	89 f2                	mov    %esi,%edx
f0104834:	83 c4 1c             	add    $0x1c,%esp
f0104837:	5b                   	pop    %ebx
f0104838:	5e                   	pop    %esi
f0104839:	5f                   	pop    %edi
f010483a:	5d                   	pop    %ebp
f010483b:	c3                   	ret    
f010483c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104840:	8b 34 24             	mov    (%esp),%esi
f0104843:	bf 20 00 00 00       	mov    $0x20,%edi
f0104848:	89 e9                	mov    %ebp,%ecx
f010484a:	29 ef                	sub    %ebp,%edi
f010484c:	d3 e0                	shl    %cl,%eax
f010484e:	89 f9                	mov    %edi,%ecx
f0104850:	89 f2                	mov    %esi,%edx
f0104852:	d3 ea                	shr    %cl,%edx
f0104854:	89 e9                	mov    %ebp,%ecx
f0104856:	09 c2                	or     %eax,%edx
f0104858:	89 d8                	mov    %ebx,%eax
f010485a:	89 14 24             	mov    %edx,(%esp)
f010485d:	89 f2                	mov    %esi,%edx
f010485f:	d3 e2                	shl    %cl,%edx
f0104861:	89 f9                	mov    %edi,%ecx
f0104863:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104867:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010486b:	d3 e8                	shr    %cl,%eax
f010486d:	89 e9                	mov    %ebp,%ecx
f010486f:	89 c6                	mov    %eax,%esi
f0104871:	d3 e3                	shl    %cl,%ebx
f0104873:	89 f9                	mov    %edi,%ecx
f0104875:	89 d0                	mov    %edx,%eax
f0104877:	d3 e8                	shr    %cl,%eax
f0104879:	89 e9                	mov    %ebp,%ecx
f010487b:	09 d8                	or     %ebx,%eax
f010487d:	89 d3                	mov    %edx,%ebx
f010487f:	89 f2                	mov    %esi,%edx
f0104881:	f7 34 24             	divl   (%esp)
f0104884:	89 d6                	mov    %edx,%esi
f0104886:	d3 e3                	shl    %cl,%ebx
f0104888:	f7 64 24 04          	mull   0x4(%esp)
f010488c:	39 d6                	cmp    %edx,%esi
f010488e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104892:	89 d1                	mov    %edx,%ecx
f0104894:	89 c3                	mov    %eax,%ebx
f0104896:	72 08                	jb     f01048a0 <__umoddi3+0x110>
f0104898:	75 11                	jne    f01048ab <__umoddi3+0x11b>
f010489a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010489e:	73 0b                	jae    f01048ab <__umoddi3+0x11b>
f01048a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01048a4:	1b 14 24             	sbb    (%esp),%edx
f01048a7:	89 d1                	mov    %edx,%ecx
f01048a9:	89 c3                	mov    %eax,%ebx
f01048ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01048af:	29 da                	sub    %ebx,%edx
f01048b1:	19 ce                	sbb    %ecx,%esi
f01048b3:	89 f9                	mov    %edi,%ecx
f01048b5:	89 f0                	mov    %esi,%eax
f01048b7:	d3 e0                	shl    %cl,%eax
f01048b9:	89 e9                	mov    %ebp,%ecx
f01048bb:	d3 ea                	shr    %cl,%edx
f01048bd:	89 e9                	mov    %ebp,%ecx
f01048bf:	d3 ee                	shr    %cl,%esi
f01048c1:	09 d0                	or     %edx,%eax
f01048c3:	89 f2                	mov    %esi,%edx
f01048c5:	83 c4 1c             	add    $0x1c,%esp
f01048c8:	5b                   	pop    %ebx
f01048c9:	5e                   	pop    %esi
f01048ca:	5f                   	pop    %edi
f01048cb:	5d                   	pop    %ebp
f01048cc:	c3                   	ret    
f01048cd:	8d 76 00             	lea    0x0(%esi),%esi
f01048d0:	29 f9                	sub    %edi,%ecx
f01048d2:	19 d6                	sbb    %edx,%esi
f01048d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01048d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01048dc:	e9 18 ff ff ff       	jmp    f01047f9 <__umoddi3+0x69>
