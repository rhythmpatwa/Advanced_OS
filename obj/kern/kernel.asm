
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

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
f0100048:	83 3d 98 fe 29 f0 00 	cmpl   $0x0,0xf029fe98
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 98 fe 29 f0    	mov    %esi,0xf029fe98

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 c5 5b 00 00       	call   f0105c26 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 68 10 f0       	push   $0xf0106820
f010006d:	e8 b3 35 00 00       	call   f0103625 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 83 35 00 00       	call   f01035ff <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 1b 7a 10 f0 	movl   $0xf0107a1b,(%esp)
f0100083:	e8 9d 35 00 00       	call   f0103625 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 e3 08 00 00       	call   f0100978 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 10 2e f0       	mov    $0xf02e1008,%eax
f01000a6:	2d f0 e4 29 f0       	sub    $0xf029e4f0,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 f0 e4 29 f0       	push   $0xf029e4f0
f01000b3:	e8 4e 55 00 00       	call   f0105606 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 d1 05 00 00       	call   f010068e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 8c 68 10 f0       	push   $0xf010688c
f01000ca:	e8 56 35 00 00       	call   f0103625 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 13 12 00 00       	call   f01012e7 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 2b 2e 00 00       	call   f0102f04 <env_init>
	trap_init();
f01000d9:	e8 2a 36 00 00       	call   f0103708 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 39 58 00 00       	call   f010591c <mp_init>
	lapic_init();
f01000e3:	e8 59 5b 00 00       	call   f0105c41 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 49 34 00 00       	call   f0103536 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000ed:	e8 44 64 00 00       	call   f0106536 <time_init>
	pci_init();
f01000f2:	e8 1f 64 00 00       	call   f0106516 <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000f7:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f01000fe:	e8 91 5d 00 00       	call   f0105e94 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100103:	83 c4 10             	add    $0x10,%esp
f0100106:	83 3d a0 fe 29 f0 07 	cmpl   $0x7,0xf029fea0
f010010d:	77 16                	ja     f0100125 <i386_init+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010010f:	68 00 70 00 00       	push   $0x7000
f0100114:	68 44 68 10 f0       	push   $0xf0106844
f0100119:	6a 6c                	push   $0x6c
f010011b:	68 a7 68 10 f0       	push   $0xf01068a7
f0100120:	e8 1b ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100125:	83 ec 04             	sub    $0x4,%esp
f0100128:	b8 82 58 10 f0       	mov    $0xf0105882,%eax
f010012d:	2d 08 58 10 f0       	sub    $0xf0105808,%eax
f0100132:	50                   	push   %eax
f0100133:	68 08 58 10 f0       	push   $0xf0105808
f0100138:	68 00 70 00 f0       	push   $0xf0007000
f010013d:	e8 11 55 00 00       	call   f0105653 <memmove>
f0100142:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 20 00 2a f0       	mov    $0xf02a0020,%ebx
f010014a:	eb 4d                	jmp    f0100199 <i386_init+0xff>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 d5 5a 00 00       	call   f0105c26 <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 39                	je     f0100196 <i386_init+0xfc>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 20 00 2a f0       	sub    $0xf02a0020,%eax
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	05 00 90 2a f0       	add    $0xf02a9000,%eax
f0100175:	a3 9c fe 29 f0       	mov    %eax,0xf029fe9c
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010017a:	83 ec 08             	sub    $0x8,%esp
f010017d:	68 00 70 00 00       	push   $0x7000
f0100182:	0f b6 03             	movzbl (%ebx),%eax
f0100185:	50                   	push   %eax
f0100186:	e8 04 5c 00 00       	call   f0105d8f <lapic_startap>
f010018b:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010018e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100191:	83 f8 01             	cmp    $0x1,%eax
f0100194:	75 f8                	jne    f010018e <i386_init+0xf4>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100196:	83 c3 74             	add    $0x74,%ebx
f0100199:	6b 05 c4 03 2a f0 74 	imul   $0x74,0xf02a03c4,%eax
f01001a0:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f01001a5:	39 c3                	cmp    %eax,%ebx
f01001a7:	72 a3                	jb     f010014c <i386_init+0xb2>
	
	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001a9:	83 ec 08             	sub    $0x8,%esp
f01001ac:	6a 01                	push   $0x1
f01001ae:	68 b4 fe 1c f0       	push   $0xf01cfeb4
f01001b3:	e8 e4 2e 00 00       	call   f010309c <env_create>

#if !defined(TEST_NO_NS)
	// Start ns.
	ENV_CREATE(net_ns, ENV_TYPE_NS);
f01001b8:	83 c4 08             	add    $0x8,%esp
f01001bb:	6a 02                	push   $0x2
f01001bd:	68 78 74 22 f0       	push   $0xf0227478
f01001c2:	e8 d5 2e 00 00       	call   f010309c <env_create>
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
//<<<<<<< HEAD
	ENV_CREATE(user_icode, ENV_TYPE_USER);
f01001c7:	83 c4 08             	add    $0x8,%esp
f01001ca:	6a 00                	push   $0x0
f01001cc:	68 7c ad 1c f0       	push   $0xf01cad7c
f01001d1:	e8 c6 2e 00 00       	call   f010309c <env_create>
//=======
	//ENV_CREATE(user_primes, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001d6:	83 c4 08             	add    $0x8,%esp
f01001d9:	6a 00                	push   $0x0
f01001db:	68 14 92 16 f0       	push   $0xf0169214
f01001e0:	e8 b7 2e 00 00       	call   f010309c <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001e5:	83 c4 08             	add    $0x8,%esp
f01001e8:	6a 00                	push   $0x0
f01001ea:	68 14 92 16 f0       	push   $0xf0169214
f01001ef:	e8 a8 2e 00 00       	call   f010309c <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001f4:	83 c4 08             	add    $0x8,%esp
f01001f7:	6a 00                	push   $0x0
f01001f9:	68 14 92 16 f0       	push   $0xf0169214
f01001fe:	e8 99 2e 00 00       	call   f010309c <env_create>
//>>>>>>> lab4
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100203:	e8 2a 04 00 00       	call   f0100632 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f0100208:	e8 96 41 00 00       	call   f01043a3 <sched_yield>

f010020d <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f010020d:	55                   	push   %ebp
f010020e:	89 e5                	mov    %esp,%ebp
f0100210:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f0100213:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100218:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010021d:	77 15                	ja     f0100234 <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010021f:	50                   	push   %eax
f0100220:	68 68 68 10 f0       	push   $0xf0106868
f0100225:	68 83 00 00 00       	push   $0x83
f010022a:	68 a7 68 10 f0       	push   $0xf01068a7
f010022f:	e8 0c fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100234:	05 00 00 00 10       	add    $0x10000000,%eax
f0100239:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010023c:	e8 e5 59 00 00       	call   f0105c26 <cpunum>
f0100241:	83 ec 08             	sub    $0x8,%esp
f0100244:	50                   	push   %eax
f0100245:	68 b3 68 10 f0       	push   $0xf01068b3
f010024a:	e8 d6 33 00 00       	call   f0103625 <cprintf>

	lapic_init();
f010024f:	e8 ed 59 00 00       	call   f0105c41 <lapic_init>
	env_init_percpu();
f0100254:	e8 7b 2c 00 00       	call   f0102ed4 <env_init_percpu>
	trap_init_percpu();
f0100259:	e8 db 33 00 00       	call   f0103639 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010025e:	e8 c3 59 00 00       	call   f0105c26 <cpunum>
f0100263:	6b d0 74             	imul   $0x74,%eax,%edx
f0100266:	81 c2 20 00 2a f0    	add    $0xf02a0020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010026c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100271:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100275:	c7 04 24 c0 23 12 f0 	movl   $0xf01223c0,(%esp)
f010027c:	e8 13 5c 00 00       	call   f0105e94 <spin_lock>
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	
	sched_yield();
f0100281:	e8 1d 41 00 00       	call   f01043a3 <sched_yield>

f0100286 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100286:	55                   	push   %ebp
f0100287:	89 e5                	mov    %esp,%ebp
f0100289:	53                   	push   %ebx
f010028a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010028d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100290:	ff 75 0c             	pushl  0xc(%ebp)
f0100293:	ff 75 08             	pushl  0x8(%ebp)
f0100296:	68 c9 68 10 f0       	push   $0xf01068c9
f010029b:	e8 85 33 00 00       	call   f0103625 <cprintf>
	vcprintf(fmt, ap);
f01002a0:	83 c4 08             	add    $0x8,%esp
f01002a3:	53                   	push   %ebx
f01002a4:	ff 75 10             	pushl  0x10(%ebp)
f01002a7:	e8 53 33 00 00       	call   f01035ff <vcprintf>
	cprintf("\n");
f01002ac:	c7 04 24 1b 7a 10 f0 	movl   $0xf0107a1b,(%esp)
f01002b3:	e8 6d 33 00 00       	call   f0103625 <cprintf>
	va_end(ap);
}
f01002b8:	83 c4 10             	add    $0x10,%esp
f01002bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002be:	c9                   	leave  
f01002bf:	c3                   	ret    

f01002c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002c9:	a8 01                	test   $0x1,%al
f01002cb:	74 0b                	je     f01002d8 <serial_proc_data+0x18>
f01002cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002d3:	0f b6 c0             	movzbl %al,%eax
f01002d6:	eb 05                	jmp    f01002dd <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002dd:	5d                   	pop    %ebp
f01002de:	c3                   	ret    

f01002df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002df:	55                   	push   %ebp
f01002e0:	89 e5                	mov    %esp,%ebp
f01002e2:	53                   	push   %ebx
f01002e3:	83 ec 04             	sub    $0x4,%esp
f01002e6:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e8:	eb 2b                	jmp    f0100315 <cons_intr+0x36>
		if (c == 0)
f01002ea:	85 c0                	test   %eax,%eax
f01002ec:	74 27                	je     f0100315 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002ee:	8b 0d 24 f2 29 f0    	mov    0xf029f224,%ecx
f01002f4:	8d 51 01             	lea    0x1(%ecx),%edx
f01002f7:	89 15 24 f2 29 f0    	mov    %edx,0xf029f224
f01002fd:	88 81 20 f0 29 f0    	mov    %al,-0xfd60fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100303:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100309:	75 0a                	jne    f0100315 <cons_intr+0x36>
			cons.wpos = 0;
f010030b:	c7 05 24 f2 29 f0 00 	movl   $0x0,0xf029f224
f0100312:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100315:	ff d3                	call   *%ebx
f0100317:	83 f8 ff             	cmp    $0xffffffff,%eax
f010031a:	75 ce                	jne    f01002ea <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010031c:	83 c4 04             	add    $0x4,%esp
f010031f:	5b                   	pop    %ebx
f0100320:	5d                   	pop    %ebp
f0100321:	c3                   	ret    

f0100322 <kbd_proc_data>:
f0100322:	ba 64 00 00 00       	mov    $0x64,%edx
f0100327:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100328:	a8 01                	test   $0x1,%al
f010032a:	0f 84 f0 00 00 00    	je     f0100420 <kbd_proc_data+0xfe>
f0100330:	ba 60 00 00 00       	mov    $0x60,%edx
f0100335:	ec                   	in     (%dx),%al
f0100336:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100338:	3c e0                	cmp    $0xe0,%al
f010033a:	75 0d                	jne    f0100349 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f010033c:	83 0d 00 f0 29 f0 40 	orl    $0x40,0xf029f000
		return 0;
f0100343:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100348:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100349:	55                   	push   %ebp
f010034a:	89 e5                	mov    %esp,%ebp
f010034c:	53                   	push   %ebx
f010034d:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100350:	84 c0                	test   %al,%al
f0100352:	79 36                	jns    f010038a <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100354:	8b 0d 00 f0 29 f0    	mov    0xf029f000,%ecx
f010035a:	89 cb                	mov    %ecx,%ebx
f010035c:	83 e3 40             	and    $0x40,%ebx
f010035f:	83 e0 7f             	and    $0x7f,%eax
f0100362:	85 db                	test   %ebx,%ebx
f0100364:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100367:	0f b6 d2             	movzbl %dl,%edx
f010036a:	0f b6 82 40 6a 10 f0 	movzbl -0xfef95c0(%edx),%eax
f0100371:	83 c8 40             	or     $0x40,%eax
f0100374:	0f b6 c0             	movzbl %al,%eax
f0100377:	f7 d0                	not    %eax
f0100379:	21 c8                	and    %ecx,%eax
f010037b:	a3 00 f0 29 f0       	mov    %eax,0xf029f000
		return 0;
f0100380:	b8 00 00 00 00       	mov    $0x0,%eax
f0100385:	e9 9e 00 00 00       	jmp    f0100428 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010038a:	8b 0d 00 f0 29 f0    	mov    0xf029f000,%ecx
f0100390:	f6 c1 40             	test   $0x40,%cl
f0100393:	74 0e                	je     f01003a3 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100395:	83 c8 80             	or     $0xffffff80,%eax
f0100398:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010039a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010039d:	89 0d 00 f0 29 f0    	mov    %ecx,0xf029f000
	}

	shift |= shiftcode[data];
f01003a3:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01003a6:	0f b6 82 40 6a 10 f0 	movzbl -0xfef95c0(%edx),%eax
f01003ad:	0b 05 00 f0 29 f0    	or     0xf029f000,%eax
f01003b3:	0f b6 8a 40 69 10 f0 	movzbl -0xfef96c0(%edx),%ecx
f01003ba:	31 c8                	xor    %ecx,%eax
f01003bc:	a3 00 f0 29 f0       	mov    %eax,0xf029f000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003c1:	89 c1                	mov    %eax,%ecx
f01003c3:	83 e1 03             	and    $0x3,%ecx
f01003c6:	8b 0c 8d 20 69 10 f0 	mov    -0xfef96e0(,%ecx,4),%ecx
f01003cd:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003d1:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003d4:	a8 08                	test   $0x8,%al
f01003d6:	74 1b                	je     f01003f3 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01003d8:	89 da                	mov    %ebx,%edx
f01003da:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003dd:	83 f9 19             	cmp    $0x19,%ecx
f01003e0:	77 05                	ja     f01003e7 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01003e2:	83 eb 20             	sub    $0x20,%ebx
f01003e5:	eb 0c                	jmp    f01003f3 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01003e7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ea:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ed:	83 fa 19             	cmp    $0x19,%edx
f01003f0:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003f3:	f7 d0                	not    %eax
f01003f5:	a8 06                	test   $0x6,%al
f01003f7:	75 2d                	jne    f0100426 <kbd_proc_data+0x104>
f01003f9:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003ff:	75 25                	jne    f0100426 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100401:	83 ec 0c             	sub    $0xc,%esp
f0100404:	68 e3 68 10 f0       	push   $0xf01068e3
f0100409:	e8 17 32 00 00       	call   f0103625 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100413:	b8 03 00 00 00       	mov    $0x3,%eax
f0100418:	ee                   	out    %al,(%dx)
f0100419:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010041c:	89 d8                	mov    %ebx,%eax
f010041e:	eb 08                	jmp    f0100428 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100425:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100426:	89 d8                	mov    %ebx,%eax
}
f0100428:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010042b:	c9                   	leave  
f010042c:	c3                   	ret    

f010042d <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010042d:	55                   	push   %ebp
f010042e:	89 e5                	mov    %esp,%ebp
f0100430:	57                   	push   %edi
f0100431:	56                   	push   %esi
f0100432:	53                   	push   %ebx
f0100433:	83 ec 1c             	sub    $0x1c,%esp
f0100436:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100438:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010043d:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100442:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100447:	eb 09                	jmp    f0100452 <cons_putc+0x25>
f0100449:	89 ca                	mov    %ecx,%edx
f010044b:	ec                   	in     (%dx),%al
f010044c:	ec                   	in     (%dx),%al
f010044d:	ec                   	in     (%dx),%al
f010044e:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010044f:	83 c3 01             	add    $0x1,%ebx
f0100452:	89 f2                	mov    %esi,%edx
f0100454:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100455:	a8 20                	test   $0x20,%al
f0100457:	75 08                	jne    f0100461 <cons_putc+0x34>
f0100459:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010045f:	7e e8                	jle    f0100449 <cons_putc+0x1c>
f0100461:	89 f8                	mov    %edi,%eax
f0100463:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100466:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010046b:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010046c:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100471:	be 79 03 00 00       	mov    $0x379,%esi
f0100476:	b9 84 00 00 00       	mov    $0x84,%ecx
f010047b:	eb 09                	jmp    f0100486 <cons_putc+0x59>
f010047d:	89 ca                	mov    %ecx,%edx
f010047f:	ec                   	in     (%dx),%al
f0100480:	ec                   	in     (%dx),%al
f0100481:	ec                   	in     (%dx),%al
f0100482:	ec                   	in     (%dx),%al
f0100483:	83 c3 01             	add    $0x1,%ebx
f0100486:	89 f2                	mov    %esi,%edx
f0100488:	ec                   	in     (%dx),%al
f0100489:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010048f:	7f 04                	jg     f0100495 <cons_putc+0x68>
f0100491:	84 c0                	test   %al,%al
f0100493:	79 e8                	jns    f010047d <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100495:	ba 78 03 00 00       	mov    $0x378,%edx
f010049a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010049e:	ee                   	out    %al,(%dx)
f010049f:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004a4:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004a9:	ee                   	out    %al,(%dx)
f01004aa:	b8 08 00 00 00       	mov    $0x8,%eax
f01004af:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004b0:	89 fa                	mov    %edi,%edx
f01004b2:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004b8:	89 f8                	mov    %edi,%eax
f01004ba:	80 cc 07             	or     $0x7,%ah
f01004bd:	85 d2                	test   %edx,%edx
f01004bf:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004c2:	89 f8                	mov    %edi,%eax
f01004c4:	0f b6 c0             	movzbl %al,%eax
f01004c7:	83 f8 09             	cmp    $0x9,%eax
f01004ca:	74 74                	je     f0100540 <cons_putc+0x113>
f01004cc:	83 f8 09             	cmp    $0x9,%eax
f01004cf:	7f 0a                	jg     f01004db <cons_putc+0xae>
f01004d1:	83 f8 08             	cmp    $0x8,%eax
f01004d4:	74 14                	je     f01004ea <cons_putc+0xbd>
f01004d6:	e9 99 00 00 00       	jmp    f0100574 <cons_putc+0x147>
f01004db:	83 f8 0a             	cmp    $0xa,%eax
f01004de:	74 3a                	je     f010051a <cons_putc+0xed>
f01004e0:	83 f8 0d             	cmp    $0xd,%eax
f01004e3:	74 3d                	je     f0100522 <cons_putc+0xf5>
f01004e5:	e9 8a 00 00 00       	jmp    f0100574 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004ea:	0f b7 05 28 f2 29 f0 	movzwl 0xf029f228,%eax
f01004f1:	66 85 c0             	test   %ax,%ax
f01004f4:	0f 84 e6 00 00 00    	je     f01005e0 <cons_putc+0x1b3>
			crt_pos--;
f01004fa:	83 e8 01             	sub    $0x1,%eax
f01004fd:	66 a3 28 f2 29 f0    	mov    %ax,0xf029f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100503:	0f b7 c0             	movzwl %ax,%eax
f0100506:	66 81 e7 00 ff       	and    $0xff00,%di
f010050b:	83 cf 20             	or     $0x20,%edi
f010050e:	8b 15 2c f2 29 f0    	mov    0xf029f22c,%edx
f0100514:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100518:	eb 78                	jmp    f0100592 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010051a:	66 83 05 28 f2 29 f0 	addw   $0x50,0xf029f228
f0100521:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100522:	0f b7 05 28 f2 29 f0 	movzwl 0xf029f228,%eax
f0100529:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010052f:	c1 e8 16             	shr    $0x16,%eax
f0100532:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100535:	c1 e0 04             	shl    $0x4,%eax
f0100538:	66 a3 28 f2 29 f0    	mov    %ax,0xf029f228
f010053e:	eb 52                	jmp    f0100592 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100540:	b8 20 00 00 00       	mov    $0x20,%eax
f0100545:	e8 e3 fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f010054a:	b8 20 00 00 00       	mov    $0x20,%eax
f010054f:	e8 d9 fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f0100554:	b8 20 00 00 00       	mov    $0x20,%eax
f0100559:	e8 cf fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f010055e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100563:	e8 c5 fe ff ff       	call   f010042d <cons_putc>
		cons_putc(' ');
f0100568:	b8 20 00 00 00       	mov    $0x20,%eax
f010056d:	e8 bb fe ff ff       	call   f010042d <cons_putc>
f0100572:	eb 1e                	jmp    f0100592 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100574:	0f b7 05 28 f2 29 f0 	movzwl 0xf029f228,%eax
f010057b:	8d 50 01             	lea    0x1(%eax),%edx
f010057e:	66 89 15 28 f2 29 f0 	mov    %dx,0xf029f228
f0100585:	0f b7 c0             	movzwl %ax,%eax
f0100588:	8b 15 2c f2 29 f0    	mov    0xf029f22c,%edx
f010058e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100592:	66 81 3d 28 f2 29 f0 	cmpw   $0x7cf,0xf029f228
f0100599:	cf 07 
f010059b:	76 43                	jbe    f01005e0 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010059d:	a1 2c f2 29 f0       	mov    0xf029f22c,%eax
f01005a2:	83 ec 04             	sub    $0x4,%esp
f01005a5:	68 00 0f 00 00       	push   $0xf00
f01005aa:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b0:	52                   	push   %edx
f01005b1:	50                   	push   %eax
f01005b2:	e8 9c 50 00 00       	call   f0105653 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005b7:	8b 15 2c f2 29 f0    	mov    0xf029f22c,%edx
f01005bd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005c3:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005c9:	83 c4 10             	add    $0x10,%esp
f01005cc:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005d1:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d4:	39 d0                	cmp    %edx,%eax
f01005d6:	75 f4                	jne    f01005cc <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005d8:	66 83 2d 28 f2 29 f0 	subw   $0x50,0xf029f228
f01005df:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005e0:	8b 0d 30 f2 29 f0    	mov    0xf029f230,%ecx
f01005e6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005eb:	89 ca                	mov    %ecx,%edx
f01005ed:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ee:	0f b7 1d 28 f2 29 f0 	movzwl 0xf029f228,%ebx
f01005f5:	8d 71 01             	lea    0x1(%ecx),%esi
f01005f8:	89 d8                	mov    %ebx,%eax
f01005fa:	66 c1 e8 08          	shr    $0x8,%ax
f01005fe:	89 f2                	mov    %esi,%edx
f0100600:	ee                   	out    %al,(%dx)
f0100601:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100606:	89 ca                	mov    %ecx,%edx
f0100608:	ee                   	out    %al,(%dx)
f0100609:	89 d8                	mov    %ebx,%eax
f010060b:	89 f2                	mov    %esi,%edx
f010060d:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010060e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100611:	5b                   	pop    %ebx
f0100612:	5e                   	pop    %esi
f0100613:	5f                   	pop    %edi
f0100614:	5d                   	pop    %ebp
f0100615:	c3                   	ret    

f0100616 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100616:	80 3d 34 f2 29 f0 00 	cmpb   $0x0,0xf029f234
f010061d:	74 11                	je     f0100630 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010061f:	55                   	push   %ebp
f0100620:	89 e5                	mov    %esp,%ebp
f0100622:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100625:	b8 c0 02 10 f0       	mov    $0xf01002c0,%eax
f010062a:	e8 b0 fc ff ff       	call   f01002df <cons_intr>
}
f010062f:	c9                   	leave  
f0100630:	f3 c3                	repz ret 

f0100632 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100638:	b8 22 03 10 f0       	mov    $0xf0100322,%eax
f010063d:	e8 9d fc ff ff       	call   f01002df <cons_intr>
}
f0100642:	c9                   	leave  
f0100643:	c3                   	ret    

f0100644 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100644:	55                   	push   %ebp
f0100645:	89 e5                	mov    %esp,%ebp
f0100647:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010064a:	e8 c7 ff ff ff       	call   f0100616 <serial_intr>
	kbd_intr();
f010064f:	e8 de ff ff ff       	call   f0100632 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100654:	a1 20 f2 29 f0       	mov    0xf029f220,%eax
f0100659:	3b 05 24 f2 29 f0    	cmp    0xf029f224,%eax
f010065f:	74 26                	je     f0100687 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100661:	8d 50 01             	lea    0x1(%eax),%edx
f0100664:	89 15 20 f2 29 f0    	mov    %edx,0xf029f220
f010066a:	0f b6 88 20 f0 29 f0 	movzbl -0xfd60fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100671:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100673:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100679:	75 11                	jne    f010068c <cons_getc+0x48>
			cons.rpos = 0;
f010067b:	c7 05 20 f2 29 f0 00 	movl   $0x0,0xf029f220
f0100682:	00 00 00 
f0100685:	eb 05                	jmp    f010068c <cons_getc+0x48>
		return c;
	}
	return 0;
f0100687:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010068c:	c9                   	leave  
f010068d:	c3                   	ret    

f010068e <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010068e:	55                   	push   %ebp
f010068f:	89 e5                	mov    %esp,%ebp
f0100691:	57                   	push   %edi
f0100692:	56                   	push   %esi
f0100693:	53                   	push   %ebx
f0100694:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100697:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010069e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006a5:	5a a5 
	if (*cp != 0xA55A) {
f01006a7:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006ae:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006b2:	74 11                	je     f01006c5 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006b4:	c7 05 30 f2 29 f0 b4 	movl   $0x3b4,0xf029f230
f01006bb:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006be:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006c3:	eb 16                	jmp    f01006db <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006c5:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006cc:	c7 05 30 f2 29 f0 d4 	movl   $0x3d4,0xf029f230
f01006d3:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006d6:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006db:	8b 3d 30 f2 29 f0    	mov    0xf029f230,%edi
f01006e1:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e6:	89 fa                	mov    %edi,%edx
f01006e8:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006e9:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ec:	89 da                	mov    %ebx,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	0f b6 c8             	movzbl %al,%ecx
f01006f2:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fa:	89 fa                	mov    %edi,%edx
f01006fc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fd:	89 da                	mov    %ebx,%edx
f01006ff:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100700:	89 35 2c f2 29 f0    	mov    %esi,0xf029f22c
	crt_pos = pos;
f0100706:	0f b6 c0             	movzbl %al,%eax
f0100709:	09 c8                	or     %ecx,%eax
f010070b:	66 a3 28 f2 29 f0    	mov    %ax,0xf029f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f0100711:	e8 1c ff ff ff       	call   f0100632 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100716:	83 ec 0c             	sub    $0xc,%esp
f0100719:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0100720:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100725:	50                   	push   %eax
f0100726:	e8 93 2d 00 00       	call   f01034be <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100730:	b8 00 00 00 00       	mov    $0x0,%eax
f0100735:	89 f2                	mov    %esi,%edx
f0100737:	ee                   	out    %al,(%dx)
f0100738:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010073d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100742:	ee                   	out    %al,(%dx)
f0100743:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100748:	b8 0c 00 00 00       	mov    $0xc,%eax
f010074d:	89 da                	mov    %ebx,%edx
f010074f:	ee                   	out    %al,(%dx)
f0100750:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100755:	b8 00 00 00 00       	mov    $0x0,%eax
f010075a:	ee                   	out    %al,(%dx)
f010075b:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100760:	b8 03 00 00 00       	mov    $0x3,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010076b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100770:	ee                   	out    %al,(%dx)
f0100771:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100776:	b8 01 00 00 00       	mov    $0x1,%eax
f010077b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010077c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100781:	ec                   	in     (%dx),%al
f0100782:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100784:	83 c4 10             	add    $0x10,%esp
f0100787:	3c ff                	cmp    $0xff,%al
f0100789:	0f 95 05 34 f2 29 f0 	setne  0xf029f234
f0100790:	89 f2                	mov    %esi,%edx
f0100792:	ec                   	in     (%dx),%al
f0100793:	89 da                	mov    %ebx,%edx
f0100795:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100796:	80 f9 ff             	cmp    $0xff,%cl
f0100799:	74 21                	je     f01007bc <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010079b:	83 ec 0c             	sub    $0xc,%esp
f010079e:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01007a5:	25 ef ff 00 00       	and    $0xffef,%eax
f01007aa:	50                   	push   %eax
f01007ab:	e8 0e 2d 00 00       	call   f01034be <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b0:	83 c4 10             	add    $0x10,%esp
f01007b3:	80 3d 34 f2 29 f0 00 	cmpb   $0x0,0xf029f234
f01007ba:	75 10                	jne    f01007cc <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f01007bc:	83 ec 0c             	sub    $0xc,%esp
f01007bf:	68 ef 68 10 f0       	push   $0xf01068ef
f01007c4:	e8 5c 2e 00 00       	call   f0103625 <cprintf>
f01007c9:	83 c4 10             	add    $0x10,%esp
}
f01007cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007cf:	5b                   	pop    %ebx
f01007d0:	5e                   	pop    %esi
f01007d1:	5f                   	pop    %edi
f01007d2:	5d                   	pop    %ebp
f01007d3:	c3                   	ret    

f01007d4 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007d4:	55                   	push   %ebp
f01007d5:	89 e5                	mov    %esp,%ebp
f01007d7:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007da:	8b 45 08             	mov    0x8(%ebp),%eax
f01007dd:	e8 4b fc ff ff       	call   f010042d <cons_putc>
}
f01007e2:	c9                   	leave  
f01007e3:	c3                   	ret    

f01007e4 <getchar>:

int
getchar(void)
{
f01007e4:	55                   	push   %ebp
f01007e5:	89 e5                	mov    %esp,%ebp
f01007e7:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ea:	e8 55 fe ff ff       	call   f0100644 <cons_getc>
f01007ef:	85 c0                	test   %eax,%eax
f01007f1:	74 f7                	je     f01007ea <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007f3:	c9                   	leave  
f01007f4:	c3                   	ret    

f01007f5 <iscons>:

int
iscons(int fdnum)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01007fd:	5d                   	pop    %ebp
f01007fe:	c3                   	ret    

f01007ff <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007ff:	55                   	push   %ebp
f0100800:	89 e5                	mov    %esp,%ebp
f0100802:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100805:	68 40 6b 10 f0       	push   $0xf0106b40
f010080a:	68 5e 6b 10 f0       	push   $0xf0106b5e
f010080f:	68 63 6b 10 f0       	push   $0xf0106b63
f0100814:	e8 0c 2e 00 00       	call   f0103625 <cprintf>
f0100819:	83 c4 0c             	add    $0xc,%esp
f010081c:	68 fc 6b 10 f0       	push   $0xf0106bfc
f0100821:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0100826:	68 63 6b 10 f0       	push   $0xf0106b63
f010082b:	e8 f5 2d 00 00       	call   f0103625 <cprintf>
f0100830:	83 c4 0c             	add    $0xc,%esp
f0100833:	68 24 6c 10 f0       	push   $0xf0106c24
f0100838:	68 75 6b 10 f0       	push   $0xf0106b75
f010083d:	68 63 6b 10 f0       	push   $0xf0106b63
f0100842:	e8 de 2d 00 00       	call   f0103625 <cprintf>
	return 0;
}
f0100847:	b8 00 00 00 00       	mov    $0x0,%eax
f010084c:	c9                   	leave  
f010084d:	c3                   	ret    

f010084e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010084e:	55                   	push   %ebp
f010084f:	89 e5                	mov    %esp,%ebp
f0100851:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100854:	68 7f 6b 10 f0       	push   $0xf0106b7f
f0100859:	e8 c7 2d 00 00       	call   f0103625 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010085e:	83 c4 08             	add    $0x8,%esp
f0100861:	68 0c 00 10 00       	push   $0x10000c
f0100866:	68 44 6c 10 f0       	push   $0xf0106c44
f010086b:	e8 b5 2d 00 00       	call   f0103625 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100870:	83 c4 0c             	add    $0xc,%esp
f0100873:	68 0c 00 10 00       	push   $0x10000c
f0100878:	68 0c 00 10 f0       	push   $0xf010000c
f010087d:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0100882:	e8 9e 2d 00 00       	call   f0103625 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100887:	83 c4 0c             	add    $0xc,%esp
f010088a:	68 11 68 10 00       	push   $0x106811
f010088f:	68 11 68 10 f0       	push   $0xf0106811
f0100894:	68 90 6c 10 f0       	push   $0xf0106c90
f0100899:	e8 87 2d 00 00       	call   f0103625 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010089e:	83 c4 0c             	add    $0xc,%esp
f01008a1:	68 f0 e4 29 00       	push   $0x29e4f0
f01008a6:	68 f0 e4 29 f0       	push   $0xf029e4f0
f01008ab:	68 b4 6c 10 f0       	push   $0xf0106cb4
f01008b0:	e8 70 2d 00 00       	call   f0103625 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008b5:	83 c4 0c             	add    $0xc,%esp
f01008b8:	68 08 10 2e 00       	push   $0x2e1008
f01008bd:	68 08 10 2e f0       	push   $0xf02e1008
f01008c2:	68 d8 6c 10 f0       	push   $0xf0106cd8
f01008c7:	e8 59 2d 00 00       	call   f0103625 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008cc:	b8 07 14 2e f0       	mov    $0xf02e1407,%eax
f01008d1:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008d6:	83 c4 08             	add    $0x8,%esp
f01008d9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008de:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008e4:	85 c0                	test   %eax,%eax
f01008e6:	0f 48 c2             	cmovs  %edx,%eax
f01008e9:	c1 f8 0a             	sar    $0xa,%eax
f01008ec:	50                   	push   %eax
f01008ed:	68 fc 6c 10 f0       	push   $0xf0106cfc
f01008f2:	e8 2e 2d 00 00       	call   f0103625 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fc:	c9                   	leave  
f01008fd:	c3                   	ret    

f01008fe <mon_backtrace>:


int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008fe:	55                   	push   %ebp
f01008ff:	89 e5                	mov    %esp,%ebp
f0100901:	56                   	push   %esi
f0100902:	53                   	push   %ebx
f0100903:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100906:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo info;
	uint32_t* test_ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
f0100908:	68 98 6b 10 f0       	push   $0xf0106b98
f010090d:	e8 13 2d 00 00       	call   f0103625 <cprintf>
	while (test_ebp)
f0100912:	83 c4 10             	add    $0x10,%esp
	 {
		cprintf("  ebp %08x eip %08x args %08x %08x %08x %08x %08x",test_ebp, test_ebp[1],test_ebp[2],test_ebp[3],test_ebp[4],test_ebp[5], test_ebp[6]);
		debuginfo_eip(test_ebp[1],&info);
f0100915:	8d 75 e0             	lea    -0x20(%ebp),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	struct Eipdebuginfo info;
	uint32_t* test_ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (test_ebp)
f0100918:	eb 4e                	jmp    f0100968 <mon_backtrace+0x6a>
	 {
		cprintf("  ebp %08x eip %08x args %08x %08x %08x %08x %08x",test_ebp, test_ebp[1],test_ebp[2],test_ebp[3],test_ebp[4],test_ebp[5], test_ebp[6]);
f010091a:	ff 73 18             	pushl  0x18(%ebx)
f010091d:	ff 73 14             	pushl  0x14(%ebx)
f0100920:	ff 73 10             	pushl  0x10(%ebx)
f0100923:	ff 73 0c             	pushl  0xc(%ebx)
f0100926:	ff 73 08             	pushl  0x8(%ebx)
f0100929:	ff 73 04             	pushl  0x4(%ebx)
f010092c:	53                   	push   %ebx
f010092d:	68 28 6d 10 f0       	push   $0xf0106d28
f0100932:	e8 ee 2c 00 00       	call   f0103625 <cprintf>
		debuginfo_eip(test_ebp[1],&info);
f0100937:	83 c4 18             	add    $0x18,%esp
f010093a:	56                   	push   %esi
f010093b:	ff 73 04             	pushl  0x4(%ebx)
f010093e:	e8 19 42 00 00       	call   f0104b5c <debuginfo_eip>
		cprintf("\t    %s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,test_ebp[1] - info.eip_fn_addr);
f0100943:	83 c4 08             	add    $0x8,%esp
f0100946:	8b 43 04             	mov    0x4(%ebx),%eax
f0100949:	2b 45 f0             	sub    -0x10(%ebp),%eax
f010094c:	50                   	push   %eax
f010094d:	ff 75 e8             	pushl  -0x18(%ebp)
f0100950:	ff 75 ec             	pushl  -0x14(%ebp)
f0100953:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100956:	ff 75 e0             	pushl  -0x20(%ebp)
f0100959:	68 aa 6b 10 f0       	push   $0xf0106baa
f010095e:	e8 c2 2c 00 00       	call   f0103625 <cprintf>
		test_ebp = (uint32_t*) *test_ebp;
f0100963:	8b 1b                	mov    (%ebx),%ebx
f0100965:	83 c4 20             	add    $0x20,%esp
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	struct Eipdebuginfo info;
	uint32_t* test_ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (test_ebp)
f0100968:	85 db                	test   %ebx,%ebx
f010096a:	75 ae                	jne    f010091a <mon_backtrace+0x1c>
		debuginfo_eip(test_ebp[1],&info);
		cprintf("\t    %s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,test_ebp[1] - info.eip_fn_addr);
		test_ebp = (uint32_t*) *test_ebp;
	}
return 0;
}
f010096c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100971:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100974:	5b                   	pop    %ebx
f0100975:	5e                   	pop    %esi
f0100976:	5d                   	pop    %ebp
f0100977:	c3                   	ret    

f0100978 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
f010097b:	57                   	push   %edi
f010097c:	56                   	push   %esi
f010097d:	53                   	push   %ebx
f010097e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100981:	68 5c 6d 10 f0       	push   $0xf0106d5c
f0100986:	e8 9a 2c 00 00       	call   f0103625 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010098b:	c7 04 24 80 6d 10 f0 	movl   $0xf0106d80,(%esp)
f0100992:	e8 8e 2c 00 00       	call   f0103625 <cprintf>

	if (tf != NULL)
f0100997:	83 c4 10             	add    $0x10,%esp
f010099a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010099e:	74 0e                	je     f01009ae <monitor+0x36>
		print_trapframe(tf);
f01009a0:	83 ec 0c             	sub    $0xc,%esp
f01009a3:	ff 75 08             	pushl  0x8(%ebp)
f01009a6:	e8 58 33 00 00       	call   f0103d03 <print_trapframe>
f01009ab:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009ae:	83 ec 0c             	sub    $0xc,%esp
f01009b1:	68 bf 6b 10 f0       	push   $0xf0106bbf
f01009b6:	e8 dc 49 00 00       	call   f0105397 <readline>
f01009bb:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009bd:	83 c4 10             	add    $0x10,%esp
f01009c0:	85 c0                	test   %eax,%eax
f01009c2:	74 ea                	je     f01009ae <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009c4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009cb:	be 00 00 00 00       	mov    $0x0,%esi
f01009d0:	eb 0a                	jmp    f01009dc <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009d2:	c6 03 00             	movb   $0x0,(%ebx)
f01009d5:	89 f7                	mov    %esi,%edi
f01009d7:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009da:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009dc:	0f b6 03             	movzbl (%ebx),%eax
f01009df:	84 c0                	test   %al,%al
f01009e1:	74 63                	je     f0100a46 <monitor+0xce>
f01009e3:	83 ec 08             	sub    $0x8,%esp
f01009e6:	0f be c0             	movsbl %al,%eax
f01009e9:	50                   	push   %eax
f01009ea:	68 c3 6b 10 f0       	push   $0xf0106bc3
f01009ef:	e8 d5 4b 00 00       	call   f01055c9 <strchr>
f01009f4:	83 c4 10             	add    $0x10,%esp
f01009f7:	85 c0                	test   %eax,%eax
f01009f9:	75 d7                	jne    f01009d2 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009fb:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009fe:	74 46                	je     f0100a46 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a00:	83 fe 0f             	cmp    $0xf,%esi
f0100a03:	75 14                	jne    f0100a19 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a05:	83 ec 08             	sub    $0x8,%esp
f0100a08:	6a 10                	push   $0x10
f0100a0a:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0100a0f:	e8 11 2c 00 00       	call   f0103625 <cprintf>
f0100a14:	83 c4 10             	add    $0x10,%esp
f0100a17:	eb 95                	jmp    f01009ae <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100a19:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a1c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a20:	eb 03                	jmp    f0100a25 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a22:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a25:	0f b6 03             	movzbl (%ebx),%eax
f0100a28:	84 c0                	test   %al,%al
f0100a2a:	74 ae                	je     f01009da <monitor+0x62>
f0100a2c:	83 ec 08             	sub    $0x8,%esp
f0100a2f:	0f be c0             	movsbl %al,%eax
f0100a32:	50                   	push   %eax
f0100a33:	68 c3 6b 10 f0       	push   $0xf0106bc3
f0100a38:	e8 8c 4b 00 00       	call   f01055c9 <strchr>
f0100a3d:	83 c4 10             	add    $0x10,%esp
f0100a40:	85 c0                	test   %eax,%eax
f0100a42:	74 de                	je     f0100a22 <monitor+0xaa>
f0100a44:	eb 94                	jmp    f01009da <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a46:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a4d:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a4e:	85 f6                	test   %esi,%esi
f0100a50:	0f 84 58 ff ff ff    	je     f01009ae <monitor+0x36>
f0100a56:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a5b:	83 ec 08             	sub    $0x8,%esp
f0100a5e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a61:	ff 34 85 c0 6d 10 f0 	pushl  -0xfef9240(,%eax,4)
f0100a68:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a6b:	e8 fb 4a 00 00       	call   f010556b <strcmp>
f0100a70:	83 c4 10             	add    $0x10,%esp
f0100a73:	85 c0                	test   %eax,%eax
f0100a75:	75 21                	jne    f0100a98 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a77:	83 ec 04             	sub    $0x4,%esp
f0100a7a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a7d:	ff 75 08             	pushl  0x8(%ebp)
f0100a80:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a83:	52                   	push   %edx
f0100a84:	56                   	push   %esi
f0100a85:	ff 14 85 c8 6d 10 f0 	call   *-0xfef9238(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a8c:	83 c4 10             	add    $0x10,%esp
f0100a8f:	85 c0                	test   %eax,%eax
f0100a91:	78 25                	js     f0100ab8 <monitor+0x140>
f0100a93:	e9 16 ff ff ff       	jmp    f01009ae <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a98:	83 c3 01             	add    $0x1,%ebx
f0100a9b:	83 fb 03             	cmp    $0x3,%ebx
f0100a9e:	75 bb                	jne    f0100a5b <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aa0:	83 ec 08             	sub    $0x8,%esp
f0100aa3:	ff 75 a8             	pushl  -0x58(%ebp)
f0100aa6:	68 e5 6b 10 f0       	push   $0xf0106be5
f0100aab:	e8 75 2b 00 00       	call   f0103625 <cprintf>
f0100ab0:	83 c4 10             	add    $0x10,%esp
f0100ab3:	e9 f6 fe ff ff       	jmp    f01009ae <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100ab8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100abb:	5b                   	pop    %ebx
f0100abc:	5e                   	pop    %esi
f0100abd:	5f                   	pop    %edi
f0100abe:	5d                   	pop    %ebp
f0100abf:	c3                   	ret    

f0100ac0 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ac0:	55                   	push   %ebp
f0100ac1:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ac3:	83 3d 38 f2 29 f0 00 	cmpl   $0x0,0xf029f238
f0100aca:	75 11                	jne    f0100add <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100acc:	ba 07 20 2e f0       	mov    $0xf02e2007,%edx
f0100ad1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ad7:	89 15 38 f2 29 f0    	mov    %edx,0xf029f238
		nextfree = nextfree + n;
		nextfree = ROUNDUP((char *) nextfree, PGSIZE);
		return result;
	}
	else
		return nextfree;
f0100add:	8b 15 38 f2 29 f0    	mov    0xf029f238,%edx
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n != 0){
f0100ae3:	85 c0                	test   %eax,%eax
f0100ae5:	74 11                	je     f0100af8 <boot_alloc+0x38>
		result = nextfree;
		nextfree = nextfree + n;
		nextfree = ROUNDUP((char *) nextfree, PGSIZE);
f0100ae7:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100aee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af3:	a3 38 f2 29 f0       	mov    %eax,0xf029f238
	}
	else
		return nextfree;

	return NULL;
}
f0100af8:	89 d0                	mov    %edx,%eax
f0100afa:	5d                   	pop    %ebp
f0100afb:	c3                   	ret    

f0100afc <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100afc:	89 d1                	mov    %edx,%ecx
f0100afe:	c1 e9 16             	shr    $0x16,%ecx
f0100b01:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b04:	a8 01                	test   $0x1,%al
f0100b06:	74 52                	je     f0100b5a <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b0d:	89 c1                	mov    %eax,%ecx
f0100b0f:	c1 e9 0c             	shr    $0xc,%ecx
f0100b12:	3b 0d a0 fe 29 f0    	cmp    0xf029fea0,%ecx
f0100b18:	72 1b                	jb     f0100b35 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b1a:	55                   	push   %ebp
f0100b1b:	89 e5                	mov    %esp,%ebp
f0100b1d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b20:	50                   	push   %eax
f0100b21:	68 44 68 10 f0       	push   $0xf0106844
f0100b26:	68 9c 03 00 00       	push   $0x39c
f0100b2b:	68 15 77 10 f0       	push   $0xf0107715
f0100b30:	e8 0b f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b35:	c1 ea 0c             	shr    $0xc,%edx
f0100b38:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b3e:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b45:	89 c2                	mov    %eax,%edx
f0100b47:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b4f:	85 d2                	test   %edx,%edx
f0100b51:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b56:	0f 44 c2             	cmove  %edx,%eax
f0100b59:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b5f:	c3                   	ret    

f0100b60 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b60:	55                   	push   %ebp
f0100b61:	89 e5                	mov    %esp,%ebp
f0100b63:	57                   	push   %edi
f0100b64:	56                   	push   %esi
f0100b65:	53                   	push   %ebx
f0100b66:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b69:	84 c0                	test   %al,%al
f0100b6b:	0f 85 a0 02 00 00    	jne    f0100e11 <check_page_free_list+0x2b1>
f0100b71:	e9 ad 02 00 00       	jmp    f0100e23 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b76:	83 ec 04             	sub    $0x4,%esp
f0100b79:	68 e4 6d 10 f0       	push   $0xf0106de4
f0100b7e:	68 cf 02 00 00       	push   $0x2cf
f0100b83:	68 15 77 10 f0       	push   $0xf0107715
f0100b88:	e8 b3 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b8d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b90:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b93:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b96:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b99:	89 c2                	mov    %eax,%edx
f0100b9b:	2b 15 a8 fe 29 f0    	sub    0xf029fea8,%edx
f0100ba1:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ba7:	0f 95 c2             	setne  %dl
f0100baa:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bad:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bb1:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bb3:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bb7:	8b 00                	mov    (%eax),%eax
f0100bb9:	85 c0                	test   %eax,%eax
f0100bbb:	75 dc                	jne    f0100b99 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bc9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bcc:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bce:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bd1:	a3 40 f2 29 f0       	mov    %eax,0xf029f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd6:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bdb:	8b 1d 40 f2 29 f0    	mov    0xf029f240,%ebx
f0100be1:	eb 53                	jmp    f0100c36 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100be3:	89 d8                	mov    %ebx,%eax
f0100be5:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0100beb:	c1 f8 03             	sar    $0x3,%eax
f0100bee:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bf1:	89 c2                	mov    %eax,%edx
f0100bf3:	c1 ea 16             	shr    $0x16,%edx
f0100bf6:	39 f2                	cmp    %esi,%edx
f0100bf8:	73 3a                	jae    f0100c34 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bfa:	89 c2                	mov    %eax,%edx
f0100bfc:	c1 ea 0c             	shr    $0xc,%edx
f0100bff:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0100c05:	72 12                	jb     f0100c19 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c07:	50                   	push   %eax
f0100c08:	68 44 68 10 f0       	push   $0xf0106844
f0100c0d:	6a 58                	push   $0x58
f0100c0f:	68 21 77 10 f0       	push   $0xf0107721
f0100c14:	e8 27 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c19:	83 ec 04             	sub    $0x4,%esp
f0100c1c:	68 80 00 00 00       	push   $0x80
f0100c21:	68 97 00 00 00       	push   $0x97
f0100c26:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c2b:	50                   	push   %eax
f0100c2c:	e8 d5 49 00 00       	call   f0105606 <memset>
f0100c31:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c34:	8b 1b                	mov    (%ebx),%ebx
f0100c36:	85 db                	test   %ebx,%ebx
f0100c38:	75 a9                	jne    f0100be3 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3f:	e8 7c fe ff ff       	call   f0100ac0 <boot_alloc>
f0100c44:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c47:	8b 15 40 f2 29 f0    	mov    0xf029f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c4d:	8b 0d a8 fe 29 f0    	mov    0xf029fea8,%ecx
		assert(pp < pages + npages);
f0100c53:	a1 a0 fe 29 f0       	mov    0xf029fea0,%eax
f0100c58:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c5b:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c5e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c61:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c64:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c69:	e9 52 01 00 00       	jmp    f0100dc0 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c6e:	39 ca                	cmp    %ecx,%edx
f0100c70:	73 19                	jae    f0100c8b <check_page_free_list+0x12b>
f0100c72:	68 2f 77 10 f0       	push   $0xf010772f
f0100c77:	68 3b 77 10 f0       	push   $0xf010773b
f0100c7c:	68 e9 02 00 00       	push   $0x2e9
f0100c81:	68 15 77 10 f0       	push   $0xf0107715
f0100c86:	e8 b5 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c8b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c8e:	72 19                	jb     f0100ca9 <check_page_free_list+0x149>
f0100c90:	68 50 77 10 f0       	push   $0xf0107750
f0100c95:	68 3b 77 10 f0       	push   $0xf010773b
f0100c9a:	68 ea 02 00 00       	push   $0x2ea
f0100c9f:	68 15 77 10 f0       	push   $0xf0107715
f0100ca4:	e8 97 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ca9:	89 d0                	mov    %edx,%eax
f0100cab:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cae:	a8 07                	test   $0x7,%al
f0100cb0:	74 19                	je     f0100ccb <check_page_free_list+0x16b>
f0100cb2:	68 08 6e 10 f0       	push   $0xf0106e08
f0100cb7:	68 3b 77 10 f0       	push   $0xf010773b
f0100cbc:	68 eb 02 00 00       	push   $0x2eb
f0100cc1:	68 15 77 10 f0       	push   $0xf0107715
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ccb:	c1 f8 03             	sar    $0x3,%eax
f0100cce:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cd1:	85 c0                	test   %eax,%eax
f0100cd3:	75 19                	jne    f0100cee <check_page_free_list+0x18e>
f0100cd5:	68 64 77 10 f0       	push   $0xf0107764
f0100cda:	68 3b 77 10 f0       	push   $0xf010773b
f0100cdf:	68 ee 02 00 00       	push   $0x2ee
f0100ce4:	68 15 77 10 f0       	push   $0xf0107715
f0100ce9:	e8 52 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cee:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cf3:	75 19                	jne    f0100d0e <check_page_free_list+0x1ae>
f0100cf5:	68 75 77 10 f0       	push   $0xf0107775
f0100cfa:	68 3b 77 10 f0       	push   $0xf010773b
f0100cff:	68 ef 02 00 00       	push   $0x2ef
f0100d04:	68 15 77 10 f0       	push   $0xf0107715
f0100d09:	e8 32 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d0e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d13:	75 19                	jne    f0100d2e <check_page_free_list+0x1ce>
f0100d15:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0100d1a:	68 3b 77 10 f0       	push   $0xf010773b
f0100d1f:	68 f0 02 00 00       	push   $0x2f0
f0100d24:	68 15 77 10 f0       	push   $0xf0107715
f0100d29:	e8 12 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d2e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d33:	75 19                	jne    f0100d4e <check_page_free_list+0x1ee>
f0100d35:	68 8e 77 10 f0       	push   $0xf010778e
f0100d3a:	68 3b 77 10 f0       	push   $0xf010773b
f0100d3f:	68 f1 02 00 00       	push   $0x2f1
f0100d44:	68 15 77 10 f0       	push   $0xf0107715
f0100d49:	e8 f2 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d4e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d53:	0f 86 f1 00 00 00    	jbe    f0100e4a <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d59:	89 c7                	mov    %eax,%edi
f0100d5b:	c1 ef 0c             	shr    $0xc,%edi
f0100d5e:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d61:	77 12                	ja     f0100d75 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d63:	50                   	push   %eax
f0100d64:	68 44 68 10 f0       	push   $0xf0106844
f0100d69:	6a 58                	push   $0x58
f0100d6b:	68 21 77 10 f0       	push   $0xf0107721
f0100d70:	e8 cb f2 ff ff       	call   f0100040 <_panic>
f0100d75:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d7b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d7e:	0f 86 b6 00 00 00    	jbe    f0100e3a <check_page_free_list+0x2da>
f0100d84:	68 60 6e 10 f0       	push   $0xf0106e60
f0100d89:	68 3b 77 10 f0       	push   $0xf010773b
f0100d8e:	68 f2 02 00 00       	push   $0x2f2
f0100d93:	68 15 77 10 f0       	push   $0xf0107715
f0100d98:	e8 a3 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d9d:	68 a8 77 10 f0       	push   $0xf01077a8
f0100da2:	68 3b 77 10 f0       	push   $0xf010773b
f0100da7:	68 f4 02 00 00       	push   $0x2f4
f0100dac:	68 15 77 10 f0       	push   $0xf0107715
f0100db1:	e8 8a f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100db6:	83 c6 01             	add    $0x1,%esi
f0100db9:	eb 03                	jmp    f0100dbe <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100dbb:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dbe:	8b 12                	mov    (%edx),%edx
f0100dc0:	85 d2                	test   %edx,%edx
f0100dc2:	0f 85 a6 fe ff ff    	jne    f0100c6e <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dc8:	85 f6                	test   %esi,%esi
f0100dca:	7f 19                	jg     f0100de5 <check_page_free_list+0x285>
f0100dcc:	68 c5 77 10 f0       	push   $0xf01077c5
f0100dd1:	68 3b 77 10 f0       	push   $0xf010773b
f0100dd6:	68 fc 02 00 00       	push   $0x2fc
f0100ddb:	68 15 77 10 f0       	push   $0xf0107715
f0100de0:	e8 5b f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100de5:	85 db                	test   %ebx,%ebx
f0100de7:	7f 19                	jg     f0100e02 <check_page_free_list+0x2a2>
f0100de9:	68 d7 77 10 f0       	push   $0xf01077d7
f0100dee:	68 3b 77 10 f0       	push   $0xf010773b
f0100df3:	68 fd 02 00 00       	push   $0x2fd
f0100df8:	68 15 77 10 f0       	push   $0xf0107715
f0100dfd:	e8 3e f2 ff ff       	call   f0100040 <_panic>
	
	cprintf("check_page_free_list() succeeded!\n");				//added by me
f0100e02:	83 ec 0c             	sub    $0xc,%esp
f0100e05:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0100e0a:	e8 16 28 00 00       	call   f0103625 <cprintf>
}
f0100e0f:	eb 49                	jmp    f0100e5a <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e11:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f0100e16:	85 c0                	test   %eax,%eax
f0100e18:	0f 85 6f fd ff ff    	jne    f0100b8d <check_page_free_list+0x2d>
f0100e1e:	e9 53 fd ff ff       	jmp    f0100b76 <check_page_free_list+0x16>
f0100e23:	83 3d 40 f2 29 f0 00 	cmpl   $0x0,0xf029f240
f0100e2a:	0f 84 46 fd ff ff    	je     f0100b76 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e30:	be 00 04 00 00       	mov    $0x400,%esi
f0100e35:	e9 a1 fd ff ff       	jmp    f0100bdb <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e3a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e3f:	0f 85 76 ff ff ff    	jne    f0100dbb <check_page_free_list+0x25b>
f0100e45:	e9 53 ff ff ff       	jmp    f0100d9d <check_page_free_list+0x23d>
f0100e4a:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e4f:	0f 85 61 ff ff ff    	jne    f0100db6 <check_page_free_list+0x256>
f0100e55:	e9 43 ff ff ff       	jmp    f0100d9d <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	
	cprintf("check_page_free_list() succeeded!\n");				//added by me
}
f0100e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5d:	5b                   	pop    %ebx
f0100e5e:	5e                   	pop    %esi
f0100e5f:	5f                   	pop    %edi
f0100e60:	5d                   	pop    %ebp
f0100e61:	c3                   	ret    

f0100e62 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e62:	55                   	push   %ebp
f0100e63:	89 e5                	mov    %esp,%ebp
f0100e65:	56                   	push   %esi
f0100e66:	53                   	push   %ebx
	size_t i;
	
	//cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
	//cprintf("npages_basemem: %x\n", npages_basemem);
	
	for (i = 1; i < npages_basemem; i++) {
f0100e67:	8b 35 44 f2 29 f0    	mov    0xf029f244,%esi
f0100e6d:	8b 1d 40 f2 29 f0    	mov    0xf029f240,%ebx
f0100e73:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e78:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e7d:	eb 41                	jmp    f0100ec0 <page_init+0x5e>
		if (i == MPENTRY_PADDR/PGSIZE) {
f0100e7f:	83 f8 07             	cmp    $0x7,%eax
f0100e82:	75 15                	jne    f0100e99 <page_init+0x37>
            pages[i].pp_ref = 1;
f0100e84:	8b 0d a8 fe 29 f0    	mov    0xf029fea8,%ecx
f0100e8a:	66 c7 41 3c 01 00    	movw   $0x1,0x3c(%ecx)
            pages[i].pp_link = NULL;
f0100e90:	c7 41 38 00 00 00 00 	movl   $0x0,0x38(%ecx)
            continue;
f0100e97:	eb 24                	jmp    f0100ebd <page_init+0x5b>
        }
		pages[i].pp_ref = 0;
f0100e99:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ea0:	89 d1                	mov    %edx,%ecx
f0100ea2:	03 0d a8 fe 29 f0    	add    0xf029fea8,%ecx
f0100ea8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100eae:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100eb0:	03 15 a8 fe 29 f0    	add    0xf029fea8,%edx
f0100eb6:	89 d3                	mov    %edx,%ebx
f0100eb8:	ba 01 00 00 00       	mov    $0x1,%edx
	size_t i;
	
	//cprintf("MPENTRY_PADDR: %x\n", MPENTRY_PADDR);
	//cprintf("npages_basemem: %x\n", npages_basemem);
	
	for (i = 1; i < npages_basemem; i++) {
f0100ebd:	83 c0 01             	add    $0x1,%eax
f0100ec0:	39 f0                	cmp    %esi,%eax
f0100ec2:	72 bb                	jb     f0100e7f <page_init+0x1d>
f0100ec4:	84 d2                	test   %dl,%dl
f0100ec6:	74 06                	je     f0100ece <page_init+0x6c>
f0100ec8:	89 1d 40 f2 29 f0    	mov    %ebx,0xf029f240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	
	int free = (int)ROUNDUP((char *)envs + (sizeof(struct Env) * NENV) - KERNBASE,PGSIZE)/PGSIZE;
f0100ece:	a1 48 f2 29 f0       	mov    0xf029f248,%eax
f0100ed3:	05 ff ff 01 10       	add    $0x1001ffff,%eax

	for (i = free; i < npages; i++) {
f0100ed8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100edd:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100ee3:	85 c0                	test   %eax,%eax
f0100ee5:	0f 48 c2             	cmovs  %edx,%eax
f0100ee8:	c1 f8 0c             	sar    $0xc,%eax
f0100eeb:	89 c2                	mov    %eax,%edx
f0100eed:	8b 1d 40 f2 29 f0    	mov    0xf029f240,%ebx
f0100ef3:	c1 e0 03             	shl    $0x3,%eax
f0100ef6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100efb:	eb 23                	jmp    f0100f20 <page_init+0xbe>
		pages[i].pp_ref = 0;
f0100efd:	89 c1                	mov    %eax,%ecx
f0100eff:	03 0d a8 fe 29 f0    	add    0xf029fea8,%ecx
f0100f05:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f0b:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100f0d:	89 c3                	mov    %eax,%ebx
f0100f0f:	03 1d a8 fe 29 f0    	add    0xf029fea8,%ebx
		page_free_list = &pages[i];
	}
	
	int free = (int)ROUNDUP((char *)envs + (sizeof(struct Env) * NENV) - KERNBASE,PGSIZE)/PGSIZE;

	for (i = free; i < npages; i++) {
f0100f15:	83 c2 01             	add    $0x1,%edx
f0100f18:	83 c0 08             	add    $0x8,%eax
f0100f1b:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100f20:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0100f26:	72 d5                	jb     f0100efd <page_init+0x9b>
f0100f28:	84 c9                	test   %cl,%cl
f0100f2a:	74 06                	je     f0100f32 <page_init+0xd0>
f0100f2c:	89 1d 40 f2 29 f0    	mov    %ebx,0xf029f240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100f32:	5b                   	pop    %ebx
f0100f33:	5e                   	pop    %esi
f0100f34:	5d                   	pop    %ebp
f0100f35:	c3                   	ret    

f0100f36 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f36:	55                   	push   %ebp
f0100f37:	89 e5                	mov    %esp,%ebp
f0100f39:	53                   	push   %ebx
f0100f3a:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if(page_free_list != 0){
f0100f3d:	8b 1d 40 f2 29 f0    	mov    0xf029f240,%ebx
f0100f43:	85 db                	test   %ebx,%ebx
f0100f45:	74 58                	je     f0100f9f <page_alloc+0x69>
		struct PageInfo *result = page_free_list;
		page_free_list = page_free_list -> pp_link;
f0100f47:	8b 03                	mov    (%ebx),%eax
f0100f49:	a3 40 f2 29 f0       	mov    %eax,0xf029f240
		if(alloc_flags & ALLOC_ZERO)
f0100f4e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f52:	74 45                	je     f0100f99 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f54:	89 d8                	mov    %ebx,%eax
f0100f56:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0100f5c:	c1 f8 03             	sar    $0x3,%eax
f0100f5f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f62:	89 c2                	mov    %eax,%edx
f0100f64:	c1 ea 0c             	shr    $0xc,%edx
f0100f67:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0100f6d:	72 12                	jb     f0100f81 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f6f:	50                   	push   %eax
f0100f70:	68 44 68 10 f0       	push   $0xf0106844
f0100f75:	6a 58                	push   $0x58
f0100f77:	68 21 77 10 f0       	push   $0xf0107721
f0100f7c:	e8 bf f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0 , PGSIZE);
f0100f81:	83 ec 04             	sub    $0x4,%esp
f0100f84:	68 00 10 00 00       	push   $0x1000
f0100f89:	6a 00                	push   $0x0
f0100f8b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f90:	50                   	push   %eax
f0100f91:	e8 70 46 00 00       	call   f0105606 <memset>
f0100f96:	83 c4 10             	add    $0x10,%esp
		result->pp_link = NULL;
f0100f99:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return result;
	}
	else
		return NULL;
}
f0100f9f:	89 d8                	mov    %ebx,%eax
f0100fa1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fa4:	c9                   	leave  
f0100fa5:	c3                   	ret    

f0100fa6 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fa6:	55                   	push   %ebp
f0100fa7:	89 e5                	mov    %esp,%ebp
f0100fa9:	83 ec 08             	sub    $0x8,%esp
f0100fac:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0) 
f0100faf:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fb4:	74 17                	je     f0100fcd <page_free+0x27>
		panic("pp_ref is nonzero");
f0100fb6:	83 ec 04             	sub    $0x4,%esp
f0100fb9:	68 e8 77 10 f0       	push   $0xf01077e8
f0100fbe:	68 86 01 00 00       	push   $0x186
f0100fc3:	68 15 77 10 f0       	push   $0xf0107715
f0100fc8:	e8 73 f0 ff ff       	call   f0100040 <_panic>
	if(pp->pp_link != NULL)
f0100fcd:	83 38 00             	cmpl   $0x0,(%eax)
f0100fd0:	74 17                	je     f0100fe9 <page_free+0x43>
		panic("pp_link is not NULL");
f0100fd2:	83 ec 04             	sub    $0x4,%esp
f0100fd5:	68 fa 77 10 f0       	push   $0xf01077fa
f0100fda:	68 88 01 00 00       	push   $0x188
f0100fdf:	68 15 77 10 f0       	push   $0xf0107715
f0100fe4:	e8 57 f0 ff ff       	call   f0100040 <_panic>

	pp->pp_link = page_free_list;
f0100fe9:	8b 15 40 f2 29 f0    	mov    0xf029f240,%edx
f0100fef:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ff1:	a3 40 f2 29 f0       	mov    %eax,0xf029f240
}
f0100ff6:	c9                   	leave  
f0100ff7:	c3                   	ret    

f0100ff8 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	83 ec 08             	sub    $0x8,%esp
f0100ffe:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101001:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101005:	83 e8 01             	sub    $0x1,%eax
f0101008:	66 89 42 04          	mov    %ax,0x4(%edx)
f010100c:	66 85 c0             	test   %ax,%ax
f010100f:	75 0c                	jne    f010101d <page_decref+0x25>
		page_free(pp);
f0101011:	83 ec 0c             	sub    $0xc,%esp
f0101014:	52                   	push   %edx
f0101015:	e8 8c ff ff ff       	call   f0100fa6 <page_free>
f010101a:	83 c4 10             	add    $0x10,%esp
}
f010101d:	c9                   	leave  
f010101e:	c3                   	ret    

f010101f <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)				//this fn creates a page table entry for the given va
{
f010101f:	55                   	push   %ebp
f0101020:	89 e5                	mov    %esp,%ebp
f0101022:	56                   	push   %esi
f0101023:	53                   	push   %ebx
f0101024:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int pdindex = PDX(va);
	int ptindex = PTX(va);
f0101027:	89 de                	mov    %ebx,%esi
f0101029:	c1 ee 0c             	shr    $0xc,%esi
f010102c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	pte_t *ptable;
	//cprintf("\ntindex %x",ptindex);
	if(!(pgdir[pdindex] & PTE_P)){						// if relevant page doesn't exist, allocate a new one
f0101032:	c1 eb 16             	shr    $0x16,%ebx
f0101035:	c1 e3 02             	shl    $0x2,%ebx
f0101038:	03 5d 08             	add    0x8(%ebp),%ebx
f010103b:	f6 03 01             	testb  $0x1,(%ebx)
f010103e:	75 2d                	jne    f010106d <pgdir_walk+0x4e>
		if(create == true){
f0101040:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
f0101044:	75 59                	jne    f010109f <pgdir_walk+0x80>
			struct PageInfo *newpage = page_alloc(ALLOC_ZERO);	//free page allocated and cleared
f0101046:	83 ec 0c             	sub    $0xc,%esp
f0101049:	6a 01                	push   $0x1
f010104b:	e8 e6 fe ff ff       	call   f0100f36 <page_alloc>
			if(newpage == NULL)
f0101050:	83 c4 10             	add    $0x10,%esp
f0101053:	85 c0                	test   %eax,%eax
f0101055:	74 4f                	je     f01010a6 <pgdir_walk+0x87>
				return NULL;

			newpage->pp_ref++;
f0101057:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[pdindex] = page2pa(newpage)|PTE_P|PTE_W|PTE_U;
f010105c:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0101062:	c1 f8 03             	sar    $0x3,%eax
f0101065:	c1 e0 0c             	shl    $0xc,%eax
f0101068:	83 c8 07             	or     $0x7,%eax
f010106b:	89 03                	mov    %eax,(%ebx)
		}
		else
			return NULL;
	}
	
	ptable = (pte_t *) KADDR(PTE_ADDR(pgdir[pdindex]));
f010106d:	8b 03                	mov    (%ebx),%eax
f010106f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101074:	89 c2                	mov    %eax,%edx
f0101076:	c1 ea 0c             	shr    $0xc,%edx
f0101079:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f010107f:	72 15                	jb     f0101096 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101081:	50                   	push   %eax
f0101082:	68 44 68 10 f0       	push   $0xf0106844
f0101087:	68 c4 01 00 00       	push   $0x1c4
f010108c:	68 15 77 10 f0       	push   $0xf0107715
f0101091:	e8 aa ef ff ff       	call   f0100040 <_panic>

	return &ptable[ptindex];//(ptable + ptindex);				//page table start + page table index = page table entry                    
f0101096:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010109d:	eb 0c                	jmp    f01010ab <pgdir_walk+0x8c>
			newpage->pp_ref++;
			pgdir[pdindex] = page2pa(newpage)|PTE_P|PTE_W|PTE_U;
			
		}
		else
			return NULL;
f010109f:	b8 00 00 00 00       	mov    $0x0,%eax
f01010a4:	eb 05                	jmp    f01010ab <pgdir_walk+0x8c>
	//cprintf("\ntindex %x",ptindex);
	if(!(pgdir[pdindex] & PTE_P)){						// if relevant page doesn't exist, allocate a new one
		if(create == true){
			struct PageInfo *newpage = page_alloc(ALLOC_ZERO);	//free page allocated and cleared
			if(newpage == NULL)
				return NULL;
f01010a6:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	
	ptable = (pte_t *) KADDR(PTE_ADDR(pgdir[pdindex]));

	return &ptable[ptindex];//(ptable + ptindex);				//page table start + page table index = page table entry                    
}
f01010ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010ae:	5b                   	pop    %ebx
f01010af:	5e                   	pop    %esi
f01010b0:	5d                   	pop    %ebp
f01010b1:	c3                   	ret    

f01010b2 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010b2:	55                   	push   %ebp
f01010b3:	89 e5                	mov    %esp,%ebp
f01010b5:	57                   	push   %edi
f01010b6:	56                   	push   %esi
f01010b7:	53                   	push   %ebx
f01010b8:	83 ec 1c             	sub    $0x1c,%esp
f01010bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010be:	8b 45 08             	mov    0x8(%ebp),%eax
f01010c1:	c1 e9 0c             	shr    $0xc,%ecx
f01010c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(int i = 0; i < size/PGSIZE; ++i,va += PGSIZE, pa += PGSIZE){
f01010c7:	89 c3                	mov    %eax,%ebx
f01010c9:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t * ptentry = pgdir_walk(pgdir, (void *) va, 1);
f01010ce:	89 d7                	mov    %edx,%edi
f01010d0:	29 c7                	sub    %eax,%edi
		if (!ptentry) panic("boot_map_region panic, out of memory");
		*ptentry = pa|perm|PTE_P;
f01010d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010d5:	83 c8 01             	or     $0x1,%eax
f01010d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	for(int i = 0; i < size/PGSIZE; ++i,va += PGSIZE, pa += PGSIZE){
f01010db:	eb 3f                	jmp    f010111c <boot_map_region+0x6a>
		pte_t * ptentry = pgdir_walk(pgdir, (void *) va, 1);
f01010dd:	83 ec 04             	sub    $0x4,%esp
f01010e0:	6a 01                	push   $0x1
f01010e2:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010e5:	50                   	push   %eax
f01010e6:	ff 75 e0             	pushl  -0x20(%ebp)
f01010e9:	e8 31 ff ff ff       	call   f010101f <pgdir_walk>
		if (!ptentry) panic("boot_map_region panic, out of memory");
f01010ee:	83 c4 10             	add    $0x10,%esp
f01010f1:	85 c0                	test   %eax,%eax
f01010f3:	75 17                	jne    f010110c <boot_map_region+0x5a>
f01010f5:	83 ec 04             	sub    $0x4,%esp
f01010f8:	68 cc 6e 10 f0       	push   $0xf0106ecc
f01010fd:	68 d9 01 00 00       	push   $0x1d9
f0101102:	68 15 77 10 f0       	push   $0xf0107715
f0101107:	e8 34 ef ff ff       	call   f0100040 <_panic>
		*ptentry = pa|perm|PTE_P;
f010110c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010110f:	09 da                	or     %ebx,%edx
f0101111:	89 10                	mov    %edx,(%eax)
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	for(int i = 0; i < size/PGSIZE; ++i,va += PGSIZE, pa += PGSIZE){
f0101113:	83 c6 01             	add    $0x1,%esi
f0101116:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010111c:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010111f:	75 bc                	jne    f01010dd <boot_map_region+0x2b>
		pte_t * ptentry = pgdir_walk(pgdir, (void *) va, 1);
		if (!ptentry) panic("boot_map_region panic, out of memory");
		*ptentry = pa|perm|PTE_P;
	}
	
}
f0101121:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101124:	5b                   	pop    %ebx
f0101125:	5e                   	pop    %esi
f0101126:	5f                   	pop    %edi
f0101127:	5d                   	pop    %ebp
f0101128:	c3                   	ret    

f0101129 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101129:	55                   	push   %ebp
f010112a:	89 e5                	mov    %esp,%ebp
f010112c:	57                   	push   %edi
f010112d:	56                   	push   %esi
f010112e:	53                   	push   %ebx
f010112f:	83 ec 10             	sub    $0x10,%esp
f0101132:	8b 75 08             	mov    0x8(%ebp),%esi
f0101135:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101138:	8b 7d 10             	mov    0x10(%ebp),%edi
	int pdindex = PDX(va);
	int ptindex = PTX(va);
	pte_t *ptentry = pgdir_walk(pgdir, va, 0);
f010113b:	6a 00                	push   $0x0
f010113d:	53                   	push   %ebx
f010113e:	56                   	push   %esi
f010113f:	e8 db fe ff ff       	call   f010101f <pgdir_walk>
	
	if(!(pgdir[pdindex] & PTE_P)){
f0101144:	c1 eb 16             	shr    $0x16,%ebx
f0101147:	83 c4 10             	add    $0x10,%esp
f010114a:	f6 04 9e 01          	testb  $0x1,(%esi,%ebx,4)
f010114e:	74 32                	je     f0101182 <page_lookup+0x59>
		return NULL;
	}

	if(pte_store)
f0101150:	85 ff                	test   %edi,%edi
f0101152:	74 02                	je     f0101156 <page_lookup+0x2d>
		*pte_store = ptentry;
f0101154:	89 07                	mov    %eax,(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101156:	8b 00                	mov    (%eax),%eax
f0101158:	c1 e8 0c             	shr    $0xc,%eax
f010115b:	3b 05 a0 fe 29 f0    	cmp    0xf029fea0,%eax
f0101161:	72 14                	jb     f0101177 <page_lookup+0x4e>
		panic("pa2page called with invalid pa");
f0101163:	83 ec 04             	sub    $0x4,%esp
f0101166:	68 f4 6e 10 f0       	push   $0xf0106ef4
f010116b:	6a 51                	push   $0x51
f010116d:	68 21 77 10 f0       	push   $0xf0107721
f0101172:	e8 c9 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101177:	8b 15 a8 fe 29 f0    	mov    0xf029fea8,%edx
f010117d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	
	return pa2page(PTE_ADDR(*ptentry));
f0101180:	eb 05                	jmp    f0101187 <page_lookup+0x5e>
	int pdindex = PDX(va);
	int ptindex = PTX(va);
	pte_t *ptentry = pgdir_walk(pgdir, va, 0);
	
	if(!(pgdir[pdindex] & PTE_P)){
		return NULL;
f0101182:	b8 00 00 00 00       	mov    $0x0,%eax
	if(pte_store)
		*pte_store = ptentry;
	
	return pa2page(PTE_ADDR(*ptentry));
		
}
f0101187:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010118a:	5b                   	pop    %ebx
f010118b:	5e                   	pop    %esi
f010118c:	5f                   	pop    %edi
f010118d:	5d                   	pop    %ebp
f010118e:	c3                   	ret    

f010118f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010118f:	55                   	push   %ebp
f0101190:	89 e5                	mov    %esp,%ebp
f0101192:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101195:	e8 8c 4a 00 00       	call   f0105c26 <cpunum>
f010119a:	6b c0 74             	imul   $0x74,%eax,%eax
f010119d:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f01011a4:	74 16                	je     f01011bc <tlb_invalidate+0x2d>
f01011a6:	e8 7b 4a 00 00       	call   f0105c26 <cpunum>
f01011ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01011ae:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01011b4:	8b 55 08             	mov    0x8(%ebp),%edx
f01011b7:	39 50 60             	cmp    %edx,0x60(%eax)
f01011ba:	75 06                	jne    f01011c2 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011bf:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011c2:	c9                   	leave  
f01011c3:	c3                   	ret    

f01011c4 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011c4:	55                   	push   %ebp
f01011c5:	89 e5                	mov    %esp,%ebp
f01011c7:	56                   	push   %esi
f01011c8:	53                   	push   %ebx
f01011c9:	83 ec 14             	sub    $0x14,%esp
f01011cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011cf:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *ptentry;

	struct PageInfo *oldpage = page_lookup(pgdir, va, &ptentry);
f01011d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011d5:	50                   	push   %eax
f01011d6:	56                   	push   %esi
f01011d7:	53                   	push   %ebx
f01011d8:	e8 4c ff ff ff       	call   f0101129 <page_lookup>

	if(!oldpage || !(*ptentry & PTE_P))
f01011dd:	83 c4 10             	add    $0x10,%esp
f01011e0:	85 c0                	test   %eax,%eax
f01011e2:	74 27                	je     f010120b <page_remove+0x47>
f01011e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01011e7:	f6 02 01             	testb  $0x1,(%edx)
f01011ea:	74 1f                	je     f010120b <page_remove+0x47>
		return;
	page_decref(oldpage);
f01011ec:	83 ec 0c             	sub    $0xc,%esp
f01011ef:	50                   	push   %eax
f01011f0:	e8 03 fe ff ff       	call   f0100ff8 <page_decref>
	*ptentry = 0;
f01011f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01011fe:	83 c4 08             	add    $0x8,%esp
f0101201:	56                   	push   %esi
f0101202:	53                   	push   %ebx
f0101203:	e8 87 ff ff ff       	call   f010118f <tlb_invalidate>
f0101208:	83 c4 10             	add    $0x10,%esp
}
f010120b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010120e:	5b                   	pop    %ebx
f010120f:	5e                   	pop    %esi
f0101210:	5d                   	pop    %ebp
f0101211:	c3                   	ret    

f0101212 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101212:	55                   	push   %ebp
f0101213:	89 e5                	mov    %esp,%ebp
f0101215:	57                   	push   %edi
f0101216:	56                   	push   %esi
f0101217:	53                   	push   %ebx
f0101218:	83 ec 10             	sub    $0x10,%esp
f010121b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010121e:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *ptentry = pgdir_walk(pgdir, va, 1);
f0101221:	6a 01                	push   $0x1
f0101223:	57                   	push   %edi
f0101224:	ff 75 08             	pushl  0x8(%ebp)
f0101227:	e8 f3 fd ff ff       	call   f010101f <pgdir_walk>
	
	if(!ptentry)
f010122c:	83 c4 10             	add    $0x10,%esp
f010122f:	85 c0                	test   %eax,%eax
f0101231:	74 38                	je     f010126b <page_insert+0x59>
f0101233:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
		
	pp->pp_ref++;
f0101235:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
		
	if(*ptentry & PTE_P)
f010123a:	f6 00 01             	testb  $0x1,(%eax)
f010123d:	74 0f                	je     f010124e <page_insert+0x3c>
		page_remove(pgdir, va);
f010123f:	83 ec 08             	sub    $0x8,%esp
f0101242:	57                   	push   %edi
f0101243:	ff 75 08             	pushl  0x8(%ebp)
f0101246:	e8 79 ff ff ff       	call   f01011c4 <page_remove>
f010124b:	83 c4 10             	add    $0x10,%esp
	
	*ptentry = page2pa(pp) | perm | PTE_P;
f010124e:	2b 1d a8 fe 29 f0    	sub    0xf029fea8,%ebx
f0101254:	c1 fb 03             	sar    $0x3,%ebx
f0101257:	c1 e3 0c             	shl    $0xc,%ebx
f010125a:	8b 45 14             	mov    0x14(%ebp),%eax
f010125d:	83 c8 01             	or     $0x1,%eax
f0101260:	09 c3                	or     %eax,%ebx
f0101262:	89 1e                	mov    %ebx,(%esi)
	
	return 0;
f0101264:	b8 00 00 00 00       	mov    $0x0,%eax
f0101269:	eb 05                	jmp    f0101270 <page_insert+0x5e>
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *ptentry = pgdir_walk(pgdir, va, 1);
	
	if(!ptentry)
		return -E_NO_MEM;
f010126b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	
	*ptentry = page2pa(pp) | perm | PTE_P;
	
	return 0;
}
f0101270:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101273:	5b                   	pop    %ebx
f0101274:	5e                   	pop    %esi
f0101275:	5f                   	pop    %edi
f0101276:	5d                   	pop    %ebp
f0101277:	c3                   	ret    

f0101278 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101278:	55                   	push   %ebp
f0101279:	89 e5                	mov    %esp,%ebp
f010127b:	53                   	push   %ebx
f010127c:	83 ec 04             	sub    $0x4,%esp
f010127f:	8b 45 08             	mov    0x8(%ebp),%eax
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	
	physaddr_t start = (physaddr_t)ROUNDDOWN(pa, PGSIZE);
f0101282:	89 c1                	mov    %eax,%ecx
f0101284:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	size_t end = (size_t)ROUNDUP(pa + size, PGSIZE);
f010128a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010128d:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
	
	size = end - start;
f0101294:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010129a:	29 cb                	sub    %ecx,%ebx
	
	if((base + size) >= MMIOLIM)
f010129c:	8b 15 00 23 12 f0    	mov    0xf0122300,%edx
f01012a2:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01012a5:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01012aa:	76 17                	jbe    f01012c3 <mmio_map_region+0x4b>
		panic("Extending memory mapped IO limit");
f01012ac:	83 ec 04             	sub    $0x4,%esp
f01012af:	68 14 6f 10 f0       	push   $0xf0106f14
f01012b4:	68 77 02 00 00       	push   $0x277
f01012b9:	68 15 77 10 f0       	push   $0xf0107715
f01012be:	e8 7d ed ff ff       	call   f0100040 <_panic>
	
	boot_map_region(kern_pgdir, base, size, start, PTE_W|PTE_PCD|PTE_PWT);
f01012c3:	83 ec 08             	sub    $0x8,%esp
f01012c6:	6a 1a                	push   $0x1a
f01012c8:	51                   	push   %ecx
f01012c9:	89 d9                	mov    %ebx,%ecx
f01012cb:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f01012d0:	e8 dd fd ff ff       	call   f01010b2 <boot_map_region>
	
	base = base + size;
f01012d5:	a1 00 23 12 f0       	mov    0xf0122300,%eax
f01012da:	01 c3                	add    %eax,%ebx
f01012dc:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300
	
	return (void *)(base - size);
}
f01012e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012e5:	c9                   	leave  
f01012e6:	c3                   	ret    

f01012e7 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01012e7:	55                   	push   %ebp
f01012e8:	89 e5                	mov    %esp,%ebp
f01012ea:	57                   	push   %edi
f01012eb:	56                   	push   %esi
f01012ec:	53                   	push   %ebx
f01012ed:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012f0:	6a 15                	push   $0x15
f01012f2:	e8 99 21 00 00       	call   f0103490 <mc146818_read>
f01012f7:	89 c3                	mov    %eax,%ebx
f01012f9:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101300:	e8 8b 21 00 00       	call   f0103490 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101305:	c1 e0 08             	shl    $0x8,%eax
f0101308:	09 d8                	or     %ebx,%eax
f010130a:	c1 e0 0a             	shl    $0xa,%eax
f010130d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101313:	85 c0                	test   %eax,%eax
f0101315:	0f 48 c2             	cmovs  %edx,%eax
f0101318:	c1 f8 0c             	sar    $0xc,%eax
f010131b:	a3 44 f2 29 f0       	mov    %eax,0xf029f244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101320:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101327:	e8 64 21 00 00       	call   f0103490 <mc146818_read>
f010132c:	89 c3                	mov    %eax,%ebx
f010132e:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101335:	e8 56 21 00 00       	call   f0103490 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010133a:	c1 e0 08             	shl    $0x8,%eax
f010133d:	09 d8                	or     %ebx,%eax
f010133f:	c1 e0 0a             	shl    $0xa,%eax
f0101342:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101348:	83 c4 10             	add    $0x10,%esp
f010134b:	85 c0                	test   %eax,%eax
f010134d:	0f 48 c2             	cmovs  %edx,%eax
f0101350:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101353:	85 c0                	test   %eax,%eax
f0101355:	74 0c                	je     f0101363 <mem_init+0x7c>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101357:	05 00 01 00 00       	add    $0x100,%eax
f010135c:	a3 a0 fe 29 f0       	mov    %eax,0xf029fea0
f0101361:	eb 0a                	jmp    f010136d <mem_init+0x86>
	else
		npages = npages_basemem;
f0101363:	a1 44 f2 29 f0       	mov    0xf029f244,%eax
f0101368:	a3 a0 fe 29 f0       	mov    %eax,0xf029fea0
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010136d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101372:	e8 49 f7 ff ff       	call   f0100ac0 <boot_alloc>
f0101377:	a3 a4 fe 29 f0       	mov    %eax,0xf029fea4
	memset(kern_pgdir, 0, PGSIZE);
f010137c:	83 ec 04             	sub    $0x4,%esp
f010137f:	68 00 10 00 00       	push   $0x1000
f0101384:	6a 00                	push   $0x0
f0101386:	50                   	push   %eax
f0101387:	e8 7a 42 00 00       	call   f0105606 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010138c:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101391:	83 c4 10             	add    $0x10,%esp
f0101394:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101399:	77 15                	ja     f01013b0 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010139b:	50                   	push   %eax
f010139c:	68 68 68 10 f0       	push   $0xf0106868
f01013a1:	68 96 00 00 00       	push   $0x96
f01013a6:	68 15 77 10 f0       	push   $0xf0107715
f01013ab:	e8 90 ec ff ff       	call   f0100040 <_panic>
f01013b0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013b6:	83 ca 05             	or     $0x5,%edx
f01013b9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f01013bf:	a1 a0 fe 29 f0       	mov    0xf029fea0,%eax
f01013c4:	c1 e0 03             	shl    $0x3,%eax
f01013c7:	e8 f4 f6 ff ff       	call   f0100ac0 <boot_alloc>
f01013cc:	a3 a8 fe 29 f0       	mov    %eax,0xf029fea8
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f01013d1:	83 ec 04             	sub    $0x4,%esp
f01013d4:	8b 0d a0 fe 29 f0    	mov    0xf029fea0,%ecx
f01013da:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013e1:	52                   	push   %edx
f01013e2:	6a 00                	push   $0x0
f01013e4:	50                   	push   %eax
f01013e5:	e8 1c 42 00 00       	call   f0105606 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f01013ea:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013ef:	e8 cc f6 ff ff       	call   f0100ac0 <boot_alloc>
f01013f4:	a3 48 f2 29 f0       	mov    %eax,0xf029f248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013f9:	e8 64 fa ff ff       	call   f0100e62 <page_init>

	check_page_free_list(1);
f01013fe:	b8 01 00 00 00       	mov    $0x1,%eax
f0101403:	e8 58 f7 ff ff       	call   f0100b60 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101408:	83 c4 10             	add    $0x10,%esp
f010140b:	83 3d a8 fe 29 f0 00 	cmpl   $0x0,0xf029fea8
f0101412:	75 17                	jne    f010142b <mem_init+0x144>
		panic("'pages' is a null pointer!");
f0101414:	83 ec 04             	sub    $0x4,%esp
f0101417:	68 0e 78 10 f0       	push   $0xf010780e
f010141c:	68 10 03 00 00       	push   $0x310
f0101421:	68 15 77 10 f0       	push   $0xf0107715
f0101426:	e8 15 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010142b:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f0101430:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101435:	eb 05                	jmp    f010143c <mem_init+0x155>
		++nfree;
f0101437:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010143a:	8b 00                	mov    (%eax),%eax
f010143c:	85 c0                	test   %eax,%eax
f010143e:	75 f7                	jne    f0101437 <mem_init+0x150>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101440:	83 ec 0c             	sub    $0xc,%esp
f0101443:	6a 00                	push   $0x0
f0101445:	e8 ec fa ff ff       	call   f0100f36 <page_alloc>
f010144a:	89 c7                	mov    %eax,%edi
f010144c:	83 c4 10             	add    $0x10,%esp
f010144f:	85 c0                	test   %eax,%eax
f0101451:	75 19                	jne    f010146c <mem_init+0x185>
f0101453:	68 29 78 10 f0       	push   $0xf0107829
f0101458:	68 3b 77 10 f0       	push   $0xf010773b
f010145d:	68 18 03 00 00       	push   $0x318
f0101462:	68 15 77 10 f0       	push   $0xf0107715
f0101467:	e8 d4 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010146c:	83 ec 0c             	sub    $0xc,%esp
f010146f:	6a 00                	push   $0x0
f0101471:	e8 c0 fa ff ff       	call   f0100f36 <page_alloc>
f0101476:	89 c6                	mov    %eax,%esi
f0101478:	83 c4 10             	add    $0x10,%esp
f010147b:	85 c0                	test   %eax,%eax
f010147d:	75 19                	jne    f0101498 <mem_init+0x1b1>
f010147f:	68 3f 78 10 f0       	push   $0xf010783f
f0101484:	68 3b 77 10 f0       	push   $0xf010773b
f0101489:	68 19 03 00 00       	push   $0x319
f010148e:	68 15 77 10 f0       	push   $0xf0107715
f0101493:	e8 a8 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101498:	83 ec 0c             	sub    $0xc,%esp
f010149b:	6a 00                	push   $0x0
f010149d:	e8 94 fa ff ff       	call   f0100f36 <page_alloc>
f01014a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014a5:	83 c4 10             	add    $0x10,%esp
f01014a8:	85 c0                	test   %eax,%eax
f01014aa:	75 19                	jne    f01014c5 <mem_init+0x1de>
f01014ac:	68 55 78 10 f0       	push   $0xf0107855
f01014b1:	68 3b 77 10 f0       	push   $0xf010773b
f01014b6:	68 1a 03 00 00       	push   $0x31a
f01014bb:	68 15 77 10 f0       	push   $0xf0107715
f01014c0:	e8 7b eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014c5:	39 f7                	cmp    %esi,%edi
f01014c7:	75 19                	jne    f01014e2 <mem_init+0x1fb>
f01014c9:	68 6b 78 10 f0       	push   $0xf010786b
f01014ce:	68 3b 77 10 f0       	push   $0xf010773b
f01014d3:	68 1d 03 00 00       	push   $0x31d
f01014d8:	68 15 77 10 f0       	push   $0xf0107715
f01014dd:	e8 5e eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e5:	39 c6                	cmp    %eax,%esi
f01014e7:	74 04                	je     f01014ed <mem_init+0x206>
f01014e9:	39 c7                	cmp    %eax,%edi
f01014eb:	75 19                	jne    f0101506 <mem_init+0x21f>
f01014ed:	68 38 6f 10 f0       	push   $0xf0106f38
f01014f2:	68 3b 77 10 f0       	push   $0xf010773b
f01014f7:	68 1e 03 00 00       	push   $0x31e
f01014fc:	68 15 77 10 f0       	push   $0xf0107715
f0101501:	e8 3a eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101506:	8b 0d a8 fe 29 f0    	mov    0xf029fea8,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010150c:	8b 15 a0 fe 29 f0    	mov    0xf029fea0,%edx
f0101512:	c1 e2 0c             	shl    $0xc,%edx
f0101515:	89 f8                	mov    %edi,%eax
f0101517:	29 c8                	sub    %ecx,%eax
f0101519:	c1 f8 03             	sar    $0x3,%eax
f010151c:	c1 e0 0c             	shl    $0xc,%eax
f010151f:	39 d0                	cmp    %edx,%eax
f0101521:	72 19                	jb     f010153c <mem_init+0x255>
f0101523:	68 7d 78 10 f0       	push   $0xf010787d
f0101528:	68 3b 77 10 f0       	push   $0xf010773b
f010152d:	68 1f 03 00 00       	push   $0x31f
f0101532:	68 15 77 10 f0       	push   $0xf0107715
f0101537:	e8 04 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010153c:	89 f0                	mov    %esi,%eax
f010153e:	29 c8                	sub    %ecx,%eax
f0101540:	c1 f8 03             	sar    $0x3,%eax
f0101543:	c1 e0 0c             	shl    $0xc,%eax
f0101546:	39 c2                	cmp    %eax,%edx
f0101548:	77 19                	ja     f0101563 <mem_init+0x27c>
f010154a:	68 9a 78 10 f0       	push   $0xf010789a
f010154f:	68 3b 77 10 f0       	push   $0xf010773b
f0101554:	68 20 03 00 00       	push   $0x320
f0101559:	68 15 77 10 f0       	push   $0xf0107715
f010155e:	e8 dd ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101563:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101566:	29 c8                	sub    %ecx,%eax
f0101568:	c1 f8 03             	sar    $0x3,%eax
f010156b:	c1 e0 0c             	shl    $0xc,%eax
f010156e:	39 c2                	cmp    %eax,%edx
f0101570:	77 19                	ja     f010158b <mem_init+0x2a4>
f0101572:	68 b7 78 10 f0       	push   $0xf01078b7
f0101577:	68 3b 77 10 f0       	push   $0xf010773b
f010157c:	68 21 03 00 00       	push   $0x321
f0101581:	68 15 77 10 f0       	push   $0xf0107715
f0101586:	e8 b5 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010158b:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f0101590:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101593:	c7 05 40 f2 29 f0 00 	movl   $0x0,0xf029f240
f010159a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010159d:	83 ec 0c             	sub    $0xc,%esp
f01015a0:	6a 00                	push   $0x0
f01015a2:	e8 8f f9 ff ff       	call   f0100f36 <page_alloc>
f01015a7:	83 c4 10             	add    $0x10,%esp
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	74 19                	je     f01015c7 <mem_init+0x2e0>
f01015ae:	68 d4 78 10 f0       	push   $0xf01078d4
f01015b3:	68 3b 77 10 f0       	push   $0xf010773b
f01015b8:	68 28 03 00 00       	push   $0x328
f01015bd:	68 15 77 10 f0       	push   $0xf0107715
f01015c2:	e8 79 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015c7:	83 ec 0c             	sub    $0xc,%esp
f01015ca:	57                   	push   %edi
f01015cb:	e8 d6 f9 ff ff       	call   f0100fa6 <page_free>
	page_free(pp1);
f01015d0:	89 34 24             	mov    %esi,(%esp)
f01015d3:	e8 ce f9 ff ff       	call   f0100fa6 <page_free>
	page_free(pp2);
f01015d8:	83 c4 04             	add    $0x4,%esp
f01015db:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015de:	e8 c3 f9 ff ff       	call   f0100fa6 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ea:	e8 47 f9 ff ff       	call   f0100f36 <page_alloc>
f01015ef:	89 c6                	mov    %eax,%esi
f01015f1:	83 c4 10             	add    $0x10,%esp
f01015f4:	85 c0                	test   %eax,%eax
f01015f6:	75 19                	jne    f0101611 <mem_init+0x32a>
f01015f8:	68 29 78 10 f0       	push   $0xf0107829
f01015fd:	68 3b 77 10 f0       	push   $0xf010773b
f0101602:	68 2f 03 00 00       	push   $0x32f
f0101607:	68 15 77 10 f0       	push   $0xf0107715
f010160c:	e8 2f ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101611:	83 ec 0c             	sub    $0xc,%esp
f0101614:	6a 00                	push   $0x0
f0101616:	e8 1b f9 ff ff       	call   f0100f36 <page_alloc>
f010161b:	89 c7                	mov    %eax,%edi
f010161d:	83 c4 10             	add    $0x10,%esp
f0101620:	85 c0                	test   %eax,%eax
f0101622:	75 19                	jne    f010163d <mem_init+0x356>
f0101624:	68 3f 78 10 f0       	push   $0xf010783f
f0101629:	68 3b 77 10 f0       	push   $0xf010773b
f010162e:	68 30 03 00 00       	push   $0x330
f0101633:	68 15 77 10 f0       	push   $0xf0107715
f0101638:	e8 03 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010163d:	83 ec 0c             	sub    $0xc,%esp
f0101640:	6a 00                	push   $0x0
f0101642:	e8 ef f8 ff ff       	call   f0100f36 <page_alloc>
f0101647:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010164a:	83 c4 10             	add    $0x10,%esp
f010164d:	85 c0                	test   %eax,%eax
f010164f:	75 19                	jne    f010166a <mem_init+0x383>
f0101651:	68 55 78 10 f0       	push   $0xf0107855
f0101656:	68 3b 77 10 f0       	push   $0xf010773b
f010165b:	68 31 03 00 00       	push   $0x331
f0101660:	68 15 77 10 f0       	push   $0xf0107715
f0101665:	e8 d6 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010166a:	39 fe                	cmp    %edi,%esi
f010166c:	75 19                	jne    f0101687 <mem_init+0x3a0>
f010166e:	68 6b 78 10 f0       	push   $0xf010786b
f0101673:	68 3b 77 10 f0       	push   $0xf010773b
f0101678:	68 33 03 00 00       	push   $0x333
f010167d:	68 15 77 10 f0       	push   $0xf0107715
f0101682:	e8 b9 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101687:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010168a:	39 c7                	cmp    %eax,%edi
f010168c:	74 04                	je     f0101692 <mem_init+0x3ab>
f010168e:	39 c6                	cmp    %eax,%esi
f0101690:	75 19                	jne    f01016ab <mem_init+0x3c4>
f0101692:	68 38 6f 10 f0       	push   $0xf0106f38
f0101697:	68 3b 77 10 f0       	push   $0xf010773b
f010169c:	68 34 03 00 00       	push   $0x334
f01016a1:	68 15 77 10 f0       	push   $0xf0107715
f01016a6:	e8 95 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01016ab:	83 ec 0c             	sub    $0xc,%esp
f01016ae:	6a 00                	push   $0x0
f01016b0:	e8 81 f8 ff ff       	call   f0100f36 <page_alloc>
f01016b5:	83 c4 10             	add    $0x10,%esp
f01016b8:	85 c0                	test   %eax,%eax
f01016ba:	74 19                	je     f01016d5 <mem_init+0x3ee>
f01016bc:	68 d4 78 10 f0       	push   $0xf01078d4
f01016c1:	68 3b 77 10 f0       	push   $0xf010773b
f01016c6:	68 35 03 00 00       	push   $0x335
f01016cb:	68 15 77 10 f0       	push   $0xf0107715
f01016d0:	e8 6b e9 ff ff       	call   f0100040 <_panic>
f01016d5:	89 f0                	mov    %esi,%eax
f01016d7:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f01016dd:	c1 f8 03             	sar    $0x3,%eax
f01016e0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016e3:	89 c2                	mov    %eax,%edx
f01016e5:	c1 ea 0c             	shr    $0xc,%edx
f01016e8:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f01016ee:	72 12                	jb     f0101702 <mem_init+0x41b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016f0:	50                   	push   %eax
f01016f1:	68 44 68 10 f0       	push   $0xf0106844
f01016f6:	6a 58                	push   $0x58
f01016f8:	68 21 77 10 f0       	push   $0xf0107721
f01016fd:	e8 3e e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101702:	83 ec 04             	sub    $0x4,%esp
f0101705:	68 00 10 00 00       	push   $0x1000
f010170a:	6a 01                	push   $0x1
f010170c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101711:	50                   	push   %eax
f0101712:	e8 ef 3e 00 00       	call   f0105606 <memset>
	page_free(pp0);
f0101717:	89 34 24             	mov    %esi,(%esp)
f010171a:	e8 87 f8 ff ff       	call   f0100fa6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010171f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101726:	e8 0b f8 ff ff       	call   f0100f36 <page_alloc>
f010172b:	83 c4 10             	add    $0x10,%esp
f010172e:	85 c0                	test   %eax,%eax
f0101730:	75 19                	jne    f010174b <mem_init+0x464>
f0101732:	68 e3 78 10 f0       	push   $0xf01078e3
f0101737:	68 3b 77 10 f0       	push   $0xf010773b
f010173c:	68 3a 03 00 00       	push   $0x33a
f0101741:	68 15 77 10 f0       	push   $0xf0107715
f0101746:	e8 f5 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010174b:	39 c6                	cmp    %eax,%esi
f010174d:	74 19                	je     f0101768 <mem_init+0x481>
f010174f:	68 01 79 10 f0       	push   $0xf0107901
f0101754:	68 3b 77 10 f0       	push   $0xf010773b
f0101759:	68 3b 03 00 00       	push   $0x33b
f010175e:	68 15 77 10 f0       	push   $0xf0107715
f0101763:	e8 d8 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101768:	89 f0                	mov    %esi,%eax
f010176a:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0101770:	c1 f8 03             	sar    $0x3,%eax
f0101773:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101776:	89 c2                	mov    %eax,%edx
f0101778:	c1 ea 0c             	shr    $0xc,%edx
f010177b:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0101781:	72 12                	jb     f0101795 <mem_init+0x4ae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101783:	50                   	push   %eax
f0101784:	68 44 68 10 f0       	push   $0xf0106844
f0101789:	6a 58                	push   $0x58
f010178b:	68 21 77 10 f0       	push   $0xf0107721
f0101790:	e8 ab e8 ff ff       	call   f0100040 <_panic>
f0101795:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010179b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01017a1:	80 38 00             	cmpb   $0x0,(%eax)
f01017a4:	74 19                	je     f01017bf <mem_init+0x4d8>
f01017a6:	68 11 79 10 f0       	push   $0xf0107911
f01017ab:	68 3b 77 10 f0       	push   $0xf010773b
f01017b0:	68 3e 03 00 00       	push   $0x33e
f01017b5:	68 15 77 10 f0       	push   $0xf0107715
f01017ba:	e8 81 e8 ff ff       	call   f0100040 <_panic>
f01017bf:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017c2:	39 d0                	cmp    %edx,%eax
f01017c4:	75 db                	jne    f01017a1 <mem_init+0x4ba>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017c6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017c9:	a3 40 f2 29 f0       	mov    %eax,0xf029f240

	// free the pages we took
	page_free(pp0);
f01017ce:	83 ec 0c             	sub    $0xc,%esp
f01017d1:	56                   	push   %esi
f01017d2:	e8 cf f7 ff ff       	call   f0100fa6 <page_free>
	page_free(pp1);
f01017d7:	89 3c 24             	mov    %edi,(%esp)
f01017da:	e8 c7 f7 ff ff       	call   f0100fa6 <page_free>
	page_free(pp2);
f01017df:	83 c4 04             	add    $0x4,%esp
f01017e2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017e5:	e8 bc f7 ff ff       	call   f0100fa6 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017ea:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f01017ef:	83 c4 10             	add    $0x10,%esp
f01017f2:	eb 05                	jmp    f01017f9 <mem_init+0x512>
		--nfree;
f01017f4:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017f7:	8b 00                	mov    (%eax),%eax
f01017f9:	85 c0                	test   %eax,%eax
f01017fb:	75 f7                	jne    f01017f4 <mem_init+0x50d>
		--nfree;
	assert(nfree == 0);
f01017fd:	85 db                	test   %ebx,%ebx
f01017ff:	74 19                	je     f010181a <mem_init+0x533>
f0101801:	68 1b 79 10 f0       	push   $0xf010791b
f0101806:	68 3b 77 10 f0       	push   $0xf010773b
f010180b:	68 4b 03 00 00       	push   $0x34b
f0101810:	68 15 77 10 f0       	push   $0xf0107715
f0101815:	e8 26 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010181a:	83 ec 0c             	sub    $0xc,%esp
f010181d:	68 58 6f 10 f0       	push   $0xf0106f58
f0101822:	e8 fe 1d 00 00       	call   f0103625 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101827:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010182e:	e8 03 f7 ff ff       	call   f0100f36 <page_alloc>
f0101833:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101836:	83 c4 10             	add    $0x10,%esp
f0101839:	85 c0                	test   %eax,%eax
f010183b:	75 19                	jne    f0101856 <mem_init+0x56f>
f010183d:	68 29 78 10 f0       	push   $0xf0107829
f0101842:	68 3b 77 10 f0       	push   $0xf010773b
f0101847:	68 b1 03 00 00       	push   $0x3b1
f010184c:	68 15 77 10 f0       	push   $0xf0107715
f0101851:	e8 ea e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101856:	83 ec 0c             	sub    $0xc,%esp
f0101859:	6a 00                	push   $0x0
f010185b:	e8 d6 f6 ff ff       	call   f0100f36 <page_alloc>
f0101860:	89 c3                	mov    %eax,%ebx
f0101862:	83 c4 10             	add    $0x10,%esp
f0101865:	85 c0                	test   %eax,%eax
f0101867:	75 19                	jne    f0101882 <mem_init+0x59b>
f0101869:	68 3f 78 10 f0       	push   $0xf010783f
f010186e:	68 3b 77 10 f0       	push   $0xf010773b
f0101873:	68 b2 03 00 00       	push   $0x3b2
f0101878:	68 15 77 10 f0       	push   $0xf0107715
f010187d:	e8 be e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101882:	83 ec 0c             	sub    $0xc,%esp
f0101885:	6a 00                	push   $0x0
f0101887:	e8 aa f6 ff ff       	call   f0100f36 <page_alloc>
f010188c:	89 c6                	mov    %eax,%esi
f010188e:	83 c4 10             	add    $0x10,%esp
f0101891:	85 c0                	test   %eax,%eax
f0101893:	75 19                	jne    f01018ae <mem_init+0x5c7>
f0101895:	68 55 78 10 f0       	push   $0xf0107855
f010189a:	68 3b 77 10 f0       	push   $0xf010773b
f010189f:	68 b3 03 00 00       	push   $0x3b3
f01018a4:	68 15 77 10 f0       	push   $0xf0107715
f01018a9:	e8 92 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018ae:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018b1:	75 19                	jne    f01018cc <mem_init+0x5e5>
f01018b3:	68 6b 78 10 f0       	push   $0xf010786b
f01018b8:	68 3b 77 10 f0       	push   $0xf010773b
f01018bd:	68 b6 03 00 00       	push   $0x3b6
f01018c2:	68 15 77 10 f0       	push   $0xf0107715
f01018c7:	e8 74 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018cc:	39 c3                	cmp    %eax,%ebx
f01018ce:	74 05                	je     f01018d5 <mem_init+0x5ee>
f01018d0:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018d3:	75 19                	jne    f01018ee <mem_init+0x607>
f01018d5:	68 38 6f 10 f0       	push   $0xf0106f38
f01018da:	68 3b 77 10 f0       	push   $0xf010773b
f01018df:	68 b7 03 00 00       	push   $0x3b7
f01018e4:	68 15 77 10 f0       	push   $0xf0107715
f01018e9:	e8 52 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018ee:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f01018f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018f6:	c7 05 40 f2 29 f0 00 	movl   $0x0,0xf029f240
f01018fd:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101900:	83 ec 0c             	sub    $0xc,%esp
f0101903:	6a 00                	push   $0x0
f0101905:	e8 2c f6 ff ff       	call   f0100f36 <page_alloc>
f010190a:	83 c4 10             	add    $0x10,%esp
f010190d:	85 c0                	test   %eax,%eax
f010190f:	74 19                	je     f010192a <mem_init+0x643>
f0101911:	68 d4 78 10 f0       	push   $0xf01078d4
f0101916:	68 3b 77 10 f0       	push   $0xf010773b
f010191b:	68 be 03 00 00       	push   $0x3be
f0101920:	68 15 77 10 f0       	push   $0xf0107715
f0101925:	e8 16 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010192a:	83 ec 04             	sub    $0x4,%esp
f010192d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101930:	50                   	push   %eax
f0101931:	6a 00                	push   $0x0
f0101933:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101939:	e8 eb f7 ff ff       	call   f0101129 <page_lookup>
f010193e:	83 c4 10             	add    $0x10,%esp
f0101941:	85 c0                	test   %eax,%eax
f0101943:	74 19                	je     f010195e <mem_init+0x677>
f0101945:	68 78 6f 10 f0       	push   $0xf0106f78
f010194a:	68 3b 77 10 f0       	push   $0xf010773b
f010194f:	68 c1 03 00 00       	push   $0x3c1
f0101954:	68 15 77 10 f0       	push   $0xf0107715
f0101959:	e8 e2 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010195e:	6a 02                	push   $0x2
f0101960:	6a 00                	push   $0x0
f0101962:	53                   	push   %ebx
f0101963:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101969:	e8 a4 f8 ff ff       	call   f0101212 <page_insert>
f010196e:	83 c4 10             	add    $0x10,%esp
f0101971:	85 c0                	test   %eax,%eax
f0101973:	78 19                	js     f010198e <mem_init+0x6a7>
f0101975:	68 b0 6f 10 f0       	push   $0xf0106fb0
f010197a:	68 3b 77 10 f0       	push   $0xf010773b
f010197f:	68 c4 03 00 00       	push   $0x3c4
f0101984:	68 15 77 10 f0       	push   $0xf0107715
f0101989:	e8 b2 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010198e:	83 ec 0c             	sub    $0xc,%esp
f0101991:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101994:	e8 0d f6 ff ff       	call   f0100fa6 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101999:	6a 02                	push   $0x2
f010199b:	6a 00                	push   $0x0
f010199d:	53                   	push   %ebx
f010199e:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f01019a4:	e8 69 f8 ff ff       	call   f0101212 <page_insert>
f01019a9:	83 c4 20             	add    $0x20,%esp
f01019ac:	85 c0                	test   %eax,%eax
f01019ae:	74 19                	je     f01019c9 <mem_init+0x6e2>
f01019b0:	68 e0 6f 10 f0       	push   $0xf0106fe0
f01019b5:	68 3b 77 10 f0       	push   $0xf010773b
f01019ba:	68 c8 03 00 00       	push   $0x3c8
f01019bf:	68 15 77 10 f0       	push   $0xf0107715
f01019c4:	e8 77 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019c9:	8b 3d a4 fe 29 f0    	mov    0xf029fea4,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019cf:	a1 a8 fe 29 f0       	mov    0xf029fea8,%eax
f01019d4:	89 c1                	mov    %eax,%ecx
f01019d6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019d9:	8b 17                	mov    (%edi),%edx
f01019db:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019e4:	29 c8                	sub    %ecx,%eax
f01019e6:	c1 f8 03             	sar    $0x3,%eax
f01019e9:	c1 e0 0c             	shl    $0xc,%eax
f01019ec:	39 c2                	cmp    %eax,%edx
f01019ee:	74 19                	je     f0101a09 <mem_init+0x722>
f01019f0:	68 10 70 10 f0       	push   $0xf0107010
f01019f5:	68 3b 77 10 f0       	push   $0xf010773b
f01019fa:	68 c9 03 00 00       	push   $0x3c9
f01019ff:	68 15 77 10 f0       	push   $0xf0107715
f0101a04:	e8 37 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a09:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a0e:	89 f8                	mov    %edi,%eax
f0101a10:	e8 e7 f0 ff ff       	call   f0100afc <check_va2pa>
f0101a15:	89 da                	mov    %ebx,%edx
f0101a17:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a1a:	c1 fa 03             	sar    $0x3,%edx
f0101a1d:	c1 e2 0c             	shl    $0xc,%edx
f0101a20:	39 d0                	cmp    %edx,%eax
f0101a22:	74 19                	je     f0101a3d <mem_init+0x756>
f0101a24:	68 38 70 10 f0       	push   $0xf0107038
f0101a29:	68 3b 77 10 f0       	push   $0xf010773b
f0101a2e:	68 ca 03 00 00       	push   $0x3ca
f0101a33:	68 15 77 10 f0       	push   $0xf0107715
f0101a38:	e8 03 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a3d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a42:	74 19                	je     f0101a5d <mem_init+0x776>
f0101a44:	68 26 79 10 f0       	push   $0xf0107926
f0101a49:	68 3b 77 10 f0       	push   $0xf010773b
f0101a4e:	68 cb 03 00 00       	push   $0x3cb
f0101a53:	68 15 77 10 f0       	push   $0xf0107715
f0101a58:	e8 e3 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a60:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a65:	74 19                	je     f0101a80 <mem_init+0x799>
f0101a67:	68 37 79 10 f0       	push   $0xf0107937
f0101a6c:	68 3b 77 10 f0       	push   $0xf010773b
f0101a71:	68 cc 03 00 00       	push   $0x3cc
f0101a76:	68 15 77 10 f0       	push   $0xf0107715
f0101a7b:	e8 c0 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a80:	6a 02                	push   $0x2
f0101a82:	68 00 10 00 00       	push   $0x1000
f0101a87:	56                   	push   %esi
f0101a88:	57                   	push   %edi
f0101a89:	e8 84 f7 ff ff       	call   f0101212 <page_insert>
f0101a8e:	83 c4 10             	add    $0x10,%esp
f0101a91:	85 c0                	test   %eax,%eax
f0101a93:	74 19                	je     f0101aae <mem_init+0x7c7>
f0101a95:	68 68 70 10 f0       	push   $0xf0107068
f0101a9a:	68 3b 77 10 f0       	push   $0xf010773b
f0101a9f:	68 cf 03 00 00       	push   $0x3cf
f0101aa4:	68 15 77 10 f0       	push   $0xf0107715
f0101aa9:	e8 92 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ab3:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f0101ab8:	e8 3f f0 ff ff       	call   f0100afc <check_va2pa>
f0101abd:	89 f2                	mov    %esi,%edx
f0101abf:	2b 15 a8 fe 29 f0    	sub    0xf029fea8,%edx
f0101ac5:	c1 fa 03             	sar    $0x3,%edx
f0101ac8:	c1 e2 0c             	shl    $0xc,%edx
f0101acb:	39 d0                	cmp    %edx,%eax
f0101acd:	74 19                	je     f0101ae8 <mem_init+0x801>
f0101acf:	68 a4 70 10 f0       	push   $0xf01070a4
f0101ad4:	68 3b 77 10 f0       	push   $0xf010773b
f0101ad9:	68 d0 03 00 00       	push   $0x3d0
f0101ade:	68 15 77 10 f0       	push   $0xf0107715
f0101ae3:	e8 58 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ae8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101aed:	74 19                	je     f0101b08 <mem_init+0x821>
f0101aef:	68 48 79 10 f0       	push   $0xf0107948
f0101af4:	68 3b 77 10 f0       	push   $0xf010773b
f0101af9:	68 d1 03 00 00       	push   $0x3d1
f0101afe:	68 15 77 10 f0       	push   $0xf0107715
f0101b03:	e8 38 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b08:	83 ec 0c             	sub    $0xc,%esp
f0101b0b:	6a 00                	push   $0x0
f0101b0d:	e8 24 f4 ff ff       	call   f0100f36 <page_alloc>
f0101b12:	83 c4 10             	add    $0x10,%esp
f0101b15:	85 c0                	test   %eax,%eax
f0101b17:	74 19                	je     f0101b32 <mem_init+0x84b>
f0101b19:	68 d4 78 10 f0       	push   $0xf01078d4
f0101b1e:	68 3b 77 10 f0       	push   $0xf010773b
f0101b23:	68 d4 03 00 00       	push   $0x3d4
f0101b28:	68 15 77 10 f0       	push   $0xf0107715
f0101b2d:	e8 0e e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b32:	6a 02                	push   $0x2
f0101b34:	68 00 10 00 00       	push   $0x1000
f0101b39:	56                   	push   %esi
f0101b3a:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101b40:	e8 cd f6 ff ff       	call   f0101212 <page_insert>
f0101b45:	83 c4 10             	add    $0x10,%esp
f0101b48:	85 c0                	test   %eax,%eax
f0101b4a:	74 19                	je     f0101b65 <mem_init+0x87e>
f0101b4c:	68 68 70 10 f0       	push   $0xf0107068
f0101b51:	68 3b 77 10 f0       	push   $0xf010773b
f0101b56:	68 d7 03 00 00       	push   $0x3d7
f0101b5b:	68 15 77 10 f0       	push   $0xf0107715
f0101b60:	e8 db e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b65:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b6a:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f0101b6f:	e8 88 ef ff ff       	call   f0100afc <check_va2pa>
f0101b74:	89 f2                	mov    %esi,%edx
f0101b76:	2b 15 a8 fe 29 f0    	sub    0xf029fea8,%edx
f0101b7c:	c1 fa 03             	sar    $0x3,%edx
f0101b7f:	c1 e2 0c             	shl    $0xc,%edx
f0101b82:	39 d0                	cmp    %edx,%eax
f0101b84:	74 19                	je     f0101b9f <mem_init+0x8b8>
f0101b86:	68 a4 70 10 f0       	push   $0xf01070a4
f0101b8b:	68 3b 77 10 f0       	push   $0xf010773b
f0101b90:	68 d8 03 00 00       	push   $0x3d8
f0101b95:	68 15 77 10 f0       	push   $0xf0107715
f0101b9a:	e8 a1 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b9f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ba4:	74 19                	je     f0101bbf <mem_init+0x8d8>
f0101ba6:	68 48 79 10 f0       	push   $0xf0107948
f0101bab:	68 3b 77 10 f0       	push   $0xf010773b
f0101bb0:	68 d9 03 00 00       	push   $0x3d9
f0101bb5:	68 15 77 10 f0       	push   $0xf0107715
f0101bba:	e8 81 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bbf:	83 ec 0c             	sub    $0xc,%esp
f0101bc2:	6a 00                	push   $0x0
f0101bc4:	e8 6d f3 ff ff       	call   f0100f36 <page_alloc>
f0101bc9:	83 c4 10             	add    $0x10,%esp
f0101bcc:	85 c0                	test   %eax,%eax
f0101bce:	74 19                	je     f0101be9 <mem_init+0x902>
f0101bd0:	68 d4 78 10 f0       	push   $0xf01078d4
f0101bd5:	68 3b 77 10 f0       	push   $0xf010773b
f0101bda:	68 dd 03 00 00       	push   $0x3dd
f0101bdf:	68 15 77 10 f0       	push   $0xf0107715
f0101be4:	e8 57 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101be9:	8b 15 a4 fe 29 f0    	mov    0xf029fea4,%edx
f0101bef:	8b 02                	mov    (%edx),%eax
f0101bf1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bf6:	89 c1                	mov    %eax,%ecx
f0101bf8:	c1 e9 0c             	shr    $0xc,%ecx
f0101bfb:	3b 0d a0 fe 29 f0    	cmp    0xf029fea0,%ecx
f0101c01:	72 15                	jb     f0101c18 <mem_init+0x931>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c03:	50                   	push   %eax
f0101c04:	68 44 68 10 f0       	push   $0xf0106844
f0101c09:	68 e0 03 00 00       	push   $0x3e0
f0101c0e:	68 15 77 10 f0       	push   $0xf0107715
f0101c13:	e8 28 e4 ff ff       	call   f0100040 <_panic>
f0101c18:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c20:	83 ec 04             	sub    $0x4,%esp
f0101c23:	6a 00                	push   $0x0
f0101c25:	68 00 10 00 00       	push   $0x1000
f0101c2a:	52                   	push   %edx
f0101c2b:	e8 ef f3 ff ff       	call   f010101f <pgdir_walk>
f0101c30:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c33:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c36:	83 c4 10             	add    $0x10,%esp
f0101c39:	39 d0                	cmp    %edx,%eax
f0101c3b:	74 19                	je     f0101c56 <mem_init+0x96f>
f0101c3d:	68 d4 70 10 f0       	push   $0xf01070d4
f0101c42:	68 3b 77 10 f0       	push   $0xf010773b
f0101c47:	68 e1 03 00 00       	push   $0x3e1
f0101c4c:	68 15 77 10 f0       	push   $0xf0107715
f0101c51:	e8 ea e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c56:	6a 06                	push   $0x6
f0101c58:	68 00 10 00 00       	push   $0x1000
f0101c5d:	56                   	push   %esi
f0101c5e:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101c64:	e8 a9 f5 ff ff       	call   f0101212 <page_insert>
f0101c69:	83 c4 10             	add    $0x10,%esp
f0101c6c:	85 c0                	test   %eax,%eax
f0101c6e:	74 19                	je     f0101c89 <mem_init+0x9a2>
f0101c70:	68 14 71 10 f0       	push   $0xf0107114
f0101c75:	68 3b 77 10 f0       	push   $0xf010773b
f0101c7a:	68 e4 03 00 00       	push   $0x3e4
f0101c7f:	68 15 77 10 f0       	push   $0xf0107715
f0101c84:	e8 b7 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c89:	8b 3d a4 fe 29 f0    	mov    0xf029fea4,%edi
f0101c8f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c94:	89 f8                	mov    %edi,%eax
f0101c96:	e8 61 ee ff ff       	call   f0100afc <check_va2pa>
f0101c9b:	89 f2                	mov    %esi,%edx
f0101c9d:	2b 15 a8 fe 29 f0    	sub    0xf029fea8,%edx
f0101ca3:	c1 fa 03             	sar    $0x3,%edx
f0101ca6:	c1 e2 0c             	shl    $0xc,%edx
f0101ca9:	39 d0                	cmp    %edx,%eax
f0101cab:	74 19                	je     f0101cc6 <mem_init+0x9df>
f0101cad:	68 a4 70 10 f0       	push   $0xf01070a4
f0101cb2:	68 3b 77 10 f0       	push   $0xf010773b
f0101cb7:	68 e5 03 00 00       	push   $0x3e5
f0101cbc:	68 15 77 10 f0       	push   $0xf0107715
f0101cc1:	e8 7a e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101cc6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ccb:	74 19                	je     f0101ce6 <mem_init+0x9ff>
f0101ccd:	68 48 79 10 f0       	push   $0xf0107948
f0101cd2:	68 3b 77 10 f0       	push   $0xf010773b
f0101cd7:	68 e6 03 00 00       	push   $0x3e6
f0101cdc:	68 15 77 10 f0       	push   $0xf0107715
f0101ce1:	e8 5a e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ce6:	83 ec 04             	sub    $0x4,%esp
f0101ce9:	6a 00                	push   $0x0
f0101ceb:	68 00 10 00 00       	push   $0x1000
f0101cf0:	57                   	push   %edi
f0101cf1:	e8 29 f3 ff ff       	call   f010101f <pgdir_walk>
f0101cf6:	83 c4 10             	add    $0x10,%esp
f0101cf9:	f6 00 04             	testb  $0x4,(%eax)
f0101cfc:	75 19                	jne    f0101d17 <mem_init+0xa30>
f0101cfe:	68 54 71 10 f0       	push   $0xf0107154
f0101d03:	68 3b 77 10 f0       	push   $0xf010773b
f0101d08:	68 e7 03 00 00       	push   $0x3e7
f0101d0d:	68 15 77 10 f0       	push   $0xf0107715
f0101d12:	e8 29 e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d17:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f0101d1c:	f6 00 04             	testb  $0x4,(%eax)
f0101d1f:	75 19                	jne    f0101d3a <mem_init+0xa53>
f0101d21:	68 59 79 10 f0       	push   $0xf0107959
f0101d26:	68 3b 77 10 f0       	push   $0xf010773b
f0101d2b:	68 e8 03 00 00       	push   $0x3e8
f0101d30:	68 15 77 10 f0       	push   $0xf0107715
f0101d35:	e8 06 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d3a:	6a 02                	push   $0x2
f0101d3c:	68 00 10 00 00       	push   $0x1000
f0101d41:	56                   	push   %esi
f0101d42:	50                   	push   %eax
f0101d43:	e8 ca f4 ff ff       	call   f0101212 <page_insert>
f0101d48:	83 c4 10             	add    $0x10,%esp
f0101d4b:	85 c0                	test   %eax,%eax
f0101d4d:	74 19                	je     f0101d68 <mem_init+0xa81>
f0101d4f:	68 68 70 10 f0       	push   $0xf0107068
f0101d54:	68 3b 77 10 f0       	push   $0xf010773b
f0101d59:	68 eb 03 00 00       	push   $0x3eb
f0101d5e:	68 15 77 10 f0       	push   $0xf0107715
f0101d63:	e8 d8 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d68:	83 ec 04             	sub    $0x4,%esp
f0101d6b:	6a 00                	push   $0x0
f0101d6d:	68 00 10 00 00       	push   $0x1000
f0101d72:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101d78:	e8 a2 f2 ff ff       	call   f010101f <pgdir_walk>
f0101d7d:	83 c4 10             	add    $0x10,%esp
f0101d80:	f6 00 02             	testb  $0x2,(%eax)
f0101d83:	75 19                	jne    f0101d9e <mem_init+0xab7>
f0101d85:	68 88 71 10 f0       	push   $0xf0107188
f0101d8a:	68 3b 77 10 f0       	push   $0xf010773b
f0101d8f:	68 ec 03 00 00       	push   $0x3ec
f0101d94:	68 15 77 10 f0       	push   $0xf0107715
f0101d99:	e8 a2 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d9e:	83 ec 04             	sub    $0x4,%esp
f0101da1:	6a 00                	push   $0x0
f0101da3:	68 00 10 00 00       	push   $0x1000
f0101da8:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101dae:	e8 6c f2 ff ff       	call   f010101f <pgdir_walk>
f0101db3:	83 c4 10             	add    $0x10,%esp
f0101db6:	f6 00 04             	testb  $0x4,(%eax)
f0101db9:	74 19                	je     f0101dd4 <mem_init+0xaed>
f0101dbb:	68 bc 71 10 f0       	push   $0xf01071bc
f0101dc0:	68 3b 77 10 f0       	push   $0xf010773b
f0101dc5:	68 ed 03 00 00       	push   $0x3ed
f0101dca:	68 15 77 10 f0       	push   $0xf0107715
f0101dcf:	e8 6c e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101dd4:	6a 02                	push   $0x2
f0101dd6:	68 00 00 40 00       	push   $0x400000
f0101ddb:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101dde:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101de4:	e8 29 f4 ff ff       	call   f0101212 <page_insert>
f0101de9:	83 c4 10             	add    $0x10,%esp
f0101dec:	85 c0                	test   %eax,%eax
f0101dee:	78 19                	js     f0101e09 <mem_init+0xb22>
f0101df0:	68 f4 71 10 f0       	push   $0xf01071f4
f0101df5:	68 3b 77 10 f0       	push   $0xf010773b
f0101dfa:	68 f0 03 00 00       	push   $0x3f0
f0101dff:	68 15 77 10 f0       	push   $0xf0107715
f0101e04:	e8 37 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e09:	6a 02                	push   $0x2
f0101e0b:	68 00 10 00 00       	push   $0x1000
f0101e10:	53                   	push   %ebx
f0101e11:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101e17:	e8 f6 f3 ff ff       	call   f0101212 <page_insert>
f0101e1c:	83 c4 10             	add    $0x10,%esp
f0101e1f:	85 c0                	test   %eax,%eax
f0101e21:	74 19                	je     f0101e3c <mem_init+0xb55>
f0101e23:	68 2c 72 10 f0       	push   $0xf010722c
f0101e28:	68 3b 77 10 f0       	push   $0xf010773b
f0101e2d:	68 f3 03 00 00       	push   $0x3f3
f0101e32:	68 15 77 10 f0       	push   $0xf0107715
f0101e37:	e8 04 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e3c:	83 ec 04             	sub    $0x4,%esp
f0101e3f:	6a 00                	push   $0x0
f0101e41:	68 00 10 00 00       	push   $0x1000
f0101e46:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101e4c:	e8 ce f1 ff ff       	call   f010101f <pgdir_walk>
f0101e51:	83 c4 10             	add    $0x10,%esp
f0101e54:	f6 00 04             	testb  $0x4,(%eax)
f0101e57:	74 19                	je     f0101e72 <mem_init+0xb8b>
f0101e59:	68 bc 71 10 f0       	push   $0xf01071bc
f0101e5e:	68 3b 77 10 f0       	push   $0xf010773b
f0101e63:	68 f4 03 00 00       	push   $0x3f4
f0101e68:	68 15 77 10 f0       	push   $0xf0107715
f0101e6d:	e8 ce e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e72:	8b 3d a4 fe 29 f0    	mov    0xf029fea4,%edi
f0101e78:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e7d:	89 f8                	mov    %edi,%eax
f0101e7f:	e8 78 ec ff ff       	call   f0100afc <check_va2pa>
f0101e84:	89 c1                	mov    %eax,%ecx
f0101e86:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e89:	89 d8                	mov    %ebx,%eax
f0101e8b:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0101e91:	c1 f8 03             	sar    $0x3,%eax
f0101e94:	c1 e0 0c             	shl    $0xc,%eax
f0101e97:	39 c1                	cmp    %eax,%ecx
f0101e99:	74 19                	je     f0101eb4 <mem_init+0xbcd>
f0101e9b:	68 68 72 10 f0       	push   $0xf0107268
f0101ea0:	68 3b 77 10 f0       	push   $0xf010773b
f0101ea5:	68 f7 03 00 00       	push   $0x3f7
f0101eaa:	68 15 77 10 f0       	push   $0xf0107715
f0101eaf:	e8 8c e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101eb4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eb9:	89 f8                	mov    %edi,%eax
f0101ebb:	e8 3c ec ff ff       	call   f0100afc <check_va2pa>
f0101ec0:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ec3:	74 19                	je     f0101ede <mem_init+0xbf7>
f0101ec5:	68 94 72 10 f0       	push   $0xf0107294
f0101eca:	68 3b 77 10 f0       	push   $0xf010773b
f0101ecf:	68 f8 03 00 00       	push   $0x3f8
f0101ed4:	68 15 77 10 f0       	push   $0xf0107715
f0101ed9:	e8 62 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ede:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ee3:	74 19                	je     f0101efe <mem_init+0xc17>
f0101ee5:	68 6f 79 10 f0       	push   $0xf010796f
f0101eea:	68 3b 77 10 f0       	push   $0xf010773b
f0101eef:	68 fa 03 00 00       	push   $0x3fa
f0101ef4:	68 15 77 10 f0       	push   $0xf0107715
f0101ef9:	e8 42 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101efe:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f03:	74 19                	je     f0101f1e <mem_init+0xc37>
f0101f05:	68 80 79 10 f0       	push   $0xf0107980
f0101f0a:	68 3b 77 10 f0       	push   $0xf010773b
f0101f0f:	68 fb 03 00 00       	push   $0x3fb
f0101f14:	68 15 77 10 f0       	push   $0xf0107715
f0101f19:	e8 22 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f1e:	83 ec 0c             	sub    $0xc,%esp
f0101f21:	6a 00                	push   $0x0
f0101f23:	e8 0e f0 ff ff       	call   f0100f36 <page_alloc>
f0101f28:	83 c4 10             	add    $0x10,%esp
f0101f2b:	85 c0                	test   %eax,%eax
f0101f2d:	74 04                	je     f0101f33 <mem_init+0xc4c>
f0101f2f:	39 c6                	cmp    %eax,%esi
f0101f31:	74 19                	je     f0101f4c <mem_init+0xc65>
f0101f33:	68 c4 72 10 f0       	push   $0xf01072c4
f0101f38:	68 3b 77 10 f0       	push   $0xf010773b
f0101f3d:	68 fe 03 00 00       	push   $0x3fe
f0101f42:	68 15 77 10 f0       	push   $0xf0107715
f0101f47:	e8 f4 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f4c:	83 ec 08             	sub    $0x8,%esp
f0101f4f:	6a 00                	push   $0x0
f0101f51:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0101f57:	e8 68 f2 ff ff       	call   f01011c4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f5c:	8b 3d a4 fe 29 f0    	mov    0xf029fea4,%edi
f0101f62:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f67:	89 f8                	mov    %edi,%eax
f0101f69:	e8 8e eb ff ff       	call   f0100afc <check_va2pa>
f0101f6e:	83 c4 10             	add    $0x10,%esp
f0101f71:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f74:	74 19                	je     f0101f8f <mem_init+0xca8>
f0101f76:	68 e8 72 10 f0       	push   $0xf01072e8
f0101f7b:	68 3b 77 10 f0       	push   $0xf010773b
f0101f80:	68 02 04 00 00       	push   $0x402
f0101f85:	68 15 77 10 f0       	push   $0xf0107715
f0101f8a:	e8 b1 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f8f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f94:	89 f8                	mov    %edi,%eax
f0101f96:	e8 61 eb ff ff       	call   f0100afc <check_va2pa>
f0101f9b:	89 da                	mov    %ebx,%edx
f0101f9d:	2b 15 a8 fe 29 f0    	sub    0xf029fea8,%edx
f0101fa3:	c1 fa 03             	sar    $0x3,%edx
f0101fa6:	c1 e2 0c             	shl    $0xc,%edx
f0101fa9:	39 d0                	cmp    %edx,%eax
f0101fab:	74 19                	je     f0101fc6 <mem_init+0xcdf>
f0101fad:	68 94 72 10 f0       	push   $0xf0107294
f0101fb2:	68 3b 77 10 f0       	push   $0xf010773b
f0101fb7:	68 03 04 00 00       	push   $0x403
f0101fbc:	68 15 77 10 f0       	push   $0xf0107715
f0101fc1:	e8 7a e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fc6:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fcb:	74 19                	je     f0101fe6 <mem_init+0xcff>
f0101fcd:	68 26 79 10 f0       	push   $0xf0107926
f0101fd2:	68 3b 77 10 f0       	push   $0xf010773b
f0101fd7:	68 04 04 00 00       	push   $0x404
f0101fdc:	68 15 77 10 f0       	push   $0xf0107715
f0101fe1:	e8 5a e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fe6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101feb:	74 19                	je     f0102006 <mem_init+0xd1f>
f0101fed:	68 80 79 10 f0       	push   $0xf0107980
f0101ff2:	68 3b 77 10 f0       	push   $0xf010773b
f0101ff7:	68 05 04 00 00       	push   $0x405
f0101ffc:	68 15 77 10 f0       	push   $0xf0107715
f0102001:	e8 3a e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102006:	6a 00                	push   $0x0
f0102008:	68 00 10 00 00       	push   $0x1000
f010200d:	53                   	push   %ebx
f010200e:	57                   	push   %edi
f010200f:	e8 fe f1 ff ff       	call   f0101212 <page_insert>
f0102014:	83 c4 10             	add    $0x10,%esp
f0102017:	85 c0                	test   %eax,%eax
f0102019:	74 19                	je     f0102034 <mem_init+0xd4d>
f010201b:	68 0c 73 10 f0       	push   $0xf010730c
f0102020:	68 3b 77 10 f0       	push   $0xf010773b
f0102025:	68 08 04 00 00       	push   $0x408
f010202a:	68 15 77 10 f0       	push   $0xf0107715
f010202f:	e8 0c e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102034:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102039:	75 19                	jne    f0102054 <mem_init+0xd6d>
f010203b:	68 91 79 10 f0       	push   $0xf0107991
f0102040:	68 3b 77 10 f0       	push   $0xf010773b
f0102045:	68 09 04 00 00       	push   $0x409
f010204a:	68 15 77 10 f0       	push   $0xf0107715
f010204f:	e8 ec df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102054:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102057:	74 19                	je     f0102072 <mem_init+0xd8b>
f0102059:	68 9d 79 10 f0       	push   $0xf010799d
f010205e:	68 3b 77 10 f0       	push   $0xf010773b
f0102063:	68 0a 04 00 00       	push   $0x40a
f0102068:	68 15 77 10 f0       	push   $0xf0107715
f010206d:	e8 ce df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102072:	83 ec 08             	sub    $0x8,%esp
f0102075:	68 00 10 00 00       	push   $0x1000
f010207a:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0102080:	e8 3f f1 ff ff       	call   f01011c4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102085:	8b 3d a4 fe 29 f0    	mov    0xf029fea4,%edi
f010208b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102090:	89 f8                	mov    %edi,%eax
f0102092:	e8 65 ea ff ff       	call   f0100afc <check_va2pa>
f0102097:	83 c4 10             	add    $0x10,%esp
f010209a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010209d:	74 19                	je     f01020b8 <mem_init+0xdd1>
f010209f:	68 e8 72 10 f0       	push   $0xf01072e8
f01020a4:	68 3b 77 10 f0       	push   $0xf010773b
f01020a9:	68 0e 04 00 00       	push   $0x40e
f01020ae:	68 15 77 10 f0       	push   $0xf0107715
f01020b3:	e8 88 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01020b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020bd:	89 f8                	mov    %edi,%eax
f01020bf:	e8 38 ea ff ff       	call   f0100afc <check_va2pa>
f01020c4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020c7:	74 19                	je     f01020e2 <mem_init+0xdfb>
f01020c9:	68 44 73 10 f0       	push   $0xf0107344
f01020ce:	68 3b 77 10 f0       	push   $0xf010773b
f01020d3:	68 0f 04 00 00       	push   $0x40f
f01020d8:	68 15 77 10 f0       	push   $0xf0107715
f01020dd:	e8 5e df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020e2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020e7:	74 19                	je     f0102102 <mem_init+0xe1b>
f01020e9:	68 b2 79 10 f0       	push   $0xf01079b2
f01020ee:	68 3b 77 10 f0       	push   $0xf010773b
f01020f3:	68 10 04 00 00       	push   $0x410
f01020f8:	68 15 77 10 f0       	push   $0xf0107715
f01020fd:	e8 3e df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102102:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102107:	74 19                	je     f0102122 <mem_init+0xe3b>
f0102109:	68 80 79 10 f0       	push   $0xf0107980
f010210e:	68 3b 77 10 f0       	push   $0xf010773b
f0102113:	68 11 04 00 00       	push   $0x411
f0102118:	68 15 77 10 f0       	push   $0xf0107715
f010211d:	e8 1e df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102122:	83 ec 0c             	sub    $0xc,%esp
f0102125:	6a 00                	push   $0x0
f0102127:	e8 0a ee ff ff       	call   f0100f36 <page_alloc>
f010212c:	83 c4 10             	add    $0x10,%esp
f010212f:	39 c3                	cmp    %eax,%ebx
f0102131:	75 04                	jne    f0102137 <mem_init+0xe50>
f0102133:	85 c0                	test   %eax,%eax
f0102135:	75 19                	jne    f0102150 <mem_init+0xe69>
f0102137:	68 6c 73 10 f0       	push   $0xf010736c
f010213c:	68 3b 77 10 f0       	push   $0xf010773b
f0102141:	68 14 04 00 00       	push   $0x414
f0102146:	68 15 77 10 f0       	push   $0xf0107715
f010214b:	e8 f0 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102150:	83 ec 0c             	sub    $0xc,%esp
f0102153:	6a 00                	push   $0x0
f0102155:	e8 dc ed ff ff       	call   f0100f36 <page_alloc>
f010215a:	83 c4 10             	add    $0x10,%esp
f010215d:	85 c0                	test   %eax,%eax
f010215f:	74 19                	je     f010217a <mem_init+0xe93>
f0102161:	68 d4 78 10 f0       	push   $0xf01078d4
f0102166:	68 3b 77 10 f0       	push   $0xf010773b
f010216b:	68 17 04 00 00       	push   $0x417
f0102170:	68 15 77 10 f0       	push   $0xf0107715
f0102175:	e8 c6 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010217a:	8b 0d a4 fe 29 f0    	mov    0xf029fea4,%ecx
f0102180:	8b 11                	mov    (%ecx),%edx
f0102182:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102188:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010218b:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0102191:	c1 f8 03             	sar    $0x3,%eax
f0102194:	c1 e0 0c             	shl    $0xc,%eax
f0102197:	39 c2                	cmp    %eax,%edx
f0102199:	74 19                	je     f01021b4 <mem_init+0xecd>
f010219b:	68 10 70 10 f0       	push   $0xf0107010
f01021a0:	68 3b 77 10 f0       	push   $0xf010773b
f01021a5:	68 1a 04 00 00       	push   $0x41a
f01021aa:	68 15 77 10 f0       	push   $0xf0107715
f01021af:	e8 8c de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01021b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01021ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021c2:	74 19                	je     f01021dd <mem_init+0xef6>
f01021c4:	68 37 79 10 f0       	push   $0xf0107937
f01021c9:	68 3b 77 10 f0       	push   $0xf010773b
f01021ce:	68 1c 04 00 00       	push   $0x41c
f01021d3:	68 15 77 10 f0       	push   $0xf0107715
f01021d8:	e8 63 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021e0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021e6:	83 ec 0c             	sub    $0xc,%esp
f01021e9:	50                   	push   %eax
f01021ea:	e8 b7 ed ff ff       	call   f0100fa6 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021ef:	83 c4 0c             	add    $0xc,%esp
f01021f2:	6a 01                	push   $0x1
f01021f4:	68 00 10 40 00       	push   $0x401000
f01021f9:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f01021ff:	e8 1b ee ff ff       	call   f010101f <pgdir_walk>
f0102204:	89 c7                	mov    %eax,%edi
f0102206:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102209:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f010220e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102211:	8b 40 04             	mov    0x4(%eax),%eax
f0102214:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102219:	8b 0d a0 fe 29 f0    	mov    0xf029fea0,%ecx
f010221f:	89 c2                	mov    %eax,%edx
f0102221:	c1 ea 0c             	shr    $0xc,%edx
f0102224:	83 c4 10             	add    $0x10,%esp
f0102227:	39 ca                	cmp    %ecx,%edx
f0102229:	72 15                	jb     f0102240 <mem_init+0xf59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010222b:	50                   	push   %eax
f010222c:	68 44 68 10 f0       	push   $0xf0106844
f0102231:	68 23 04 00 00       	push   $0x423
f0102236:	68 15 77 10 f0       	push   $0xf0107715
f010223b:	e8 00 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102240:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102245:	39 c7                	cmp    %eax,%edi
f0102247:	74 19                	je     f0102262 <mem_init+0xf7b>
f0102249:	68 c3 79 10 f0       	push   $0xf01079c3
f010224e:	68 3b 77 10 f0       	push   $0xf010773b
f0102253:	68 24 04 00 00       	push   $0x424
f0102258:	68 15 77 10 f0       	push   $0xf0107715
f010225d:	e8 de dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102262:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102265:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010226c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010226f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102275:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f010227b:	c1 f8 03             	sar    $0x3,%eax
f010227e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102281:	89 c2                	mov    %eax,%edx
f0102283:	c1 ea 0c             	shr    $0xc,%edx
f0102286:	39 d1                	cmp    %edx,%ecx
f0102288:	77 12                	ja     f010229c <mem_init+0xfb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010228a:	50                   	push   %eax
f010228b:	68 44 68 10 f0       	push   $0xf0106844
f0102290:	6a 58                	push   $0x58
f0102292:	68 21 77 10 f0       	push   $0xf0107721
f0102297:	e8 a4 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010229c:	83 ec 04             	sub    $0x4,%esp
f010229f:	68 00 10 00 00       	push   $0x1000
f01022a4:	68 ff 00 00 00       	push   $0xff
f01022a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01022ae:	50                   	push   %eax
f01022af:	e8 52 33 00 00       	call   f0105606 <memset>
	page_free(pp0);
f01022b4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01022b7:	89 3c 24             	mov    %edi,(%esp)
f01022ba:	e8 e7 ec ff ff       	call   f0100fa6 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022bf:	83 c4 0c             	add    $0xc,%esp
f01022c2:	6a 01                	push   $0x1
f01022c4:	6a 00                	push   $0x0
f01022c6:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f01022cc:	e8 4e ed ff ff       	call   f010101f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022d1:	89 fa                	mov    %edi,%edx
f01022d3:	2b 15 a8 fe 29 f0    	sub    0xf029fea8,%edx
f01022d9:	c1 fa 03             	sar    $0x3,%edx
f01022dc:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022df:	89 d0                	mov    %edx,%eax
f01022e1:	c1 e8 0c             	shr    $0xc,%eax
f01022e4:	83 c4 10             	add    $0x10,%esp
f01022e7:	3b 05 a0 fe 29 f0    	cmp    0xf029fea0,%eax
f01022ed:	72 12                	jb     f0102301 <mem_init+0x101a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022ef:	52                   	push   %edx
f01022f0:	68 44 68 10 f0       	push   $0xf0106844
f01022f5:	6a 58                	push   $0x58
f01022f7:	68 21 77 10 f0       	push   $0xf0107721
f01022fc:	e8 3f dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102301:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102307:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010230a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102310:	f6 00 01             	testb  $0x1,(%eax)
f0102313:	74 19                	je     f010232e <mem_init+0x1047>
f0102315:	68 db 79 10 f0       	push   $0xf01079db
f010231a:	68 3b 77 10 f0       	push   $0xf010773b
f010231f:	68 2e 04 00 00       	push   $0x42e
f0102324:	68 15 77 10 f0       	push   $0xf0107715
f0102329:	e8 12 dd ff ff       	call   f0100040 <_panic>
f010232e:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102331:	39 c2                	cmp    %eax,%edx
f0102333:	75 db                	jne    f0102310 <mem_init+0x1029>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102335:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f010233a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102340:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102343:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102349:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010234c:	89 0d 40 f2 29 f0    	mov    %ecx,0xf029f240

	// free the pages we took
	page_free(pp0);
f0102352:	83 ec 0c             	sub    $0xc,%esp
f0102355:	50                   	push   %eax
f0102356:	e8 4b ec ff ff       	call   f0100fa6 <page_free>
	page_free(pp1);
f010235b:	89 1c 24             	mov    %ebx,(%esp)
f010235e:	e8 43 ec ff ff       	call   f0100fa6 <page_free>
	page_free(pp2);
f0102363:	89 34 24             	mov    %esi,(%esp)
f0102366:	e8 3b ec ff ff       	call   f0100fa6 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010236b:	83 c4 08             	add    $0x8,%esp
f010236e:	68 01 10 00 00       	push   $0x1001
f0102373:	6a 00                	push   $0x0
f0102375:	e8 fe ee ff ff       	call   f0101278 <mmio_map_region>
f010237a:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010237c:	83 c4 08             	add    $0x8,%esp
f010237f:	68 00 10 00 00       	push   $0x1000
f0102384:	6a 00                	push   $0x0
f0102386:	e8 ed ee ff ff       	call   f0101278 <mmio_map_region>
f010238b:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010238d:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102393:	83 c4 10             	add    $0x10,%esp
f0102396:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010239c:	76 07                	jbe    f01023a5 <mem_init+0x10be>
f010239e:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01023a3:	76 19                	jbe    f01023be <mem_init+0x10d7>
f01023a5:	68 90 73 10 f0       	push   $0xf0107390
f01023aa:	68 3b 77 10 f0       	push   $0xf010773b
f01023af:	68 3e 04 00 00       	push   $0x43e
f01023b4:	68 15 77 10 f0       	push   $0xf0107715
f01023b9:	e8 82 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01023be:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01023c4:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023ca:	77 08                	ja     f01023d4 <mem_init+0x10ed>
f01023cc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01023d2:	77 19                	ja     f01023ed <mem_init+0x1106>
f01023d4:	68 b8 73 10 f0       	push   $0xf01073b8
f01023d9:	68 3b 77 10 f0       	push   $0xf010773b
f01023de:	68 3f 04 00 00       	push   $0x43f
f01023e3:	68 15 77 10 f0       	push   $0xf0107715
f01023e8:	e8 53 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023ed:	89 da                	mov    %ebx,%edx
f01023ef:	09 f2                	or     %esi,%edx
f01023f1:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01023f7:	74 19                	je     f0102412 <mem_init+0x112b>
f01023f9:	68 e0 73 10 f0       	push   $0xf01073e0
f01023fe:	68 3b 77 10 f0       	push   $0xf010773b
f0102403:	68 41 04 00 00       	push   $0x441
f0102408:	68 15 77 10 f0       	push   $0xf0107715
f010240d:	e8 2e dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102412:	39 c6                	cmp    %eax,%esi
f0102414:	73 19                	jae    f010242f <mem_init+0x1148>
f0102416:	68 f2 79 10 f0       	push   $0xf01079f2
f010241b:	68 3b 77 10 f0       	push   $0xf010773b
f0102420:	68 43 04 00 00       	push   $0x443
f0102425:	68 15 77 10 f0       	push   $0xf0107715
f010242a:	e8 11 dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010242f:	8b 3d a4 fe 29 f0    	mov    0xf029fea4,%edi
f0102435:	89 da                	mov    %ebx,%edx
f0102437:	89 f8                	mov    %edi,%eax
f0102439:	e8 be e6 ff ff       	call   f0100afc <check_va2pa>
f010243e:	85 c0                	test   %eax,%eax
f0102440:	74 19                	je     f010245b <mem_init+0x1174>
f0102442:	68 08 74 10 f0       	push   $0xf0107408
f0102447:	68 3b 77 10 f0       	push   $0xf010773b
f010244c:	68 45 04 00 00       	push   $0x445
f0102451:	68 15 77 10 f0       	push   $0xf0107715
f0102456:	e8 e5 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010245b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102461:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102464:	89 c2                	mov    %eax,%edx
f0102466:	89 f8                	mov    %edi,%eax
f0102468:	e8 8f e6 ff ff       	call   f0100afc <check_va2pa>
f010246d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102472:	74 19                	je     f010248d <mem_init+0x11a6>
f0102474:	68 2c 74 10 f0       	push   $0xf010742c
f0102479:	68 3b 77 10 f0       	push   $0xf010773b
f010247e:	68 46 04 00 00       	push   $0x446
f0102483:	68 15 77 10 f0       	push   $0xf0107715
f0102488:	e8 b3 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010248d:	89 f2                	mov    %esi,%edx
f010248f:	89 f8                	mov    %edi,%eax
f0102491:	e8 66 e6 ff ff       	call   f0100afc <check_va2pa>
f0102496:	85 c0                	test   %eax,%eax
f0102498:	74 19                	je     f01024b3 <mem_init+0x11cc>
f010249a:	68 5c 74 10 f0       	push   $0xf010745c
f010249f:	68 3b 77 10 f0       	push   $0xf010773b
f01024a4:	68 47 04 00 00       	push   $0x447
f01024a9:	68 15 77 10 f0       	push   $0xf0107715
f01024ae:	e8 8d db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01024b3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01024b9:	89 f8                	mov    %edi,%eax
f01024bb:	e8 3c e6 ff ff       	call   f0100afc <check_va2pa>
f01024c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c3:	74 19                	je     f01024de <mem_init+0x11f7>
f01024c5:	68 80 74 10 f0       	push   $0xf0107480
f01024ca:	68 3b 77 10 f0       	push   $0xf010773b
f01024cf:	68 48 04 00 00       	push   $0x448
f01024d4:	68 15 77 10 f0       	push   $0xf0107715
f01024d9:	e8 62 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024de:	83 ec 04             	sub    $0x4,%esp
f01024e1:	6a 00                	push   $0x0
f01024e3:	53                   	push   %ebx
f01024e4:	57                   	push   %edi
f01024e5:	e8 35 eb ff ff       	call   f010101f <pgdir_walk>
f01024ea:	83 c4 10             	add    $0x10,%esp
f01024ed:	f6 00 1a             	testb  $0x1a,(%eax)
f01024f0:	75 19                	jne    f010250b <mem_init+0x1224>
f01024f2:	68 ac 74 10 f0       	push   $0xf01074ac
f01024f7:	68 3b 77 10 f0       	push   $0xf010773b
f01024fc:	68 4a 04 00 00       	push   $0x44a
f0102501:	68 15 77 10 f0       	push   $0xf0107715
f0102506:	e8 35 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010250b:	83 ec 04             	sub    $0x4,%esp
f010250e:	6a 00                	push   $0x0
f0102510:	53                   	push   %ebx
f0102511:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0102517:	e8 03 eb ff ff       	call   f010101f <pgdir_walk>
f010251c:	8b 00                	mov    (%eax),%eax
f010251e:	83 c4 10             	add    $0x10,%esp
f0102521:	83 e0 04             	and    $0x4,%eax
f0102524:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102527:	74 19                	je     f0102542 <mem_init+0x125b>
f0102529:	68 f0 74 10 f0       	push   $0xf01074f0
f010252e:	68 3b 77 10 f0       	push   $0xf010773b
f0102533:	68 4b 04 00 00       	push   $0x44b
f0102538:	68 15 77 10 f0       	push   $0xf0107715
f010253d:	e8 fe da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102542:	83 ec 04             	sub    $0x4,%esp
f0102545:	6a 00                	push   $0x0
f0102547:	53                   	push   %ebx
f0102548:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f010254e:	e8 cc ea ff ff       	call   f010101f <pgdir_walk>
f0102553:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102559:	83 c4 0c             	add    $0xc,%esp
f010255c:	6a 00                	push   $0x0
f010255e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102561:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0102567:	e8 b3 ea ff ff       	call   f010101f <pgdir_walk>
f010256c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102572:	83 c4 0c             	add    $0xc,%esp
f0102575:	6a 00                	push   $0x0
f0102577:	56                   	push   %esi
f0102578:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f010257e:	e8 9c ea ff ff       	call   f010101f <pgdir_walk>
f0102583:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102589:	c7 04 24 04 7a 10 f0 	movl   $0xf0107a04,(%esp)
f0102590:	e8 90 10 00 00       	call   f0103625 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102595:	a1 a8 fe 29 f0       	mov    0xf029fea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010259a:	83 c4 10             	add    $0x10,%esp
f010259d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025a2:	77 15                	ja     f01025b9 <mem_init+0x12d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025a4:	50                   	push   %eax
f01025a5:	68 68 68 10 f0       	push   $0xf0106868
f01025aa:	68 c0 00 00 00       	push   $0xc0
f01025af:	68 15 77 10 f0       	push   $0xf0107715
f01025b4:	e8 87 da ff ff       	call   f0100040 <_panic>
f01025b9:	83 ec 08             	sub    $0x8,%esp
f01025bc:	6a 04                	push   $0x4
f01025be:	05 00 00 00 10       	add    $0x10000000,%eax
f01025c3:	50                   	push   %eax
f01025c4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025c9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025ce:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f01025d3:	e8 da ea ff ff       	call   f01010b2 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01025d8:	a1 48 f2 29 f0       	mov    0xf029f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025dd:	83 c4 10             	add    $0x10,%esp
f01025e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025e5:	77 15                	ja     f01025fc <mem_init+0x1315>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025e7:	50                   	push   %eax
f01025e8:	68 68 68 10 f0       	push   $0xf0106868
f01025ed:	68 ca 00 00 00       	push   $0xca
f01025f2:	68 15 77 10 f0       	push   $0xf0107715
f01025f7:	e8 44 da ff ff       	call   f0100040 <_panic>
f01025fc:	83 ec 08             	sub    $0x8,%esp
f01025ff:	6a 04                	push   $0x4
f0102601:	05 00 00 00 10       	add    $0x10000000,%eax
f0102606:	50                   	push   %eax
f0102607:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010260c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102611:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f0102616:	e8 97 ea ff ff       	call   f01010b2 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010261b:	83 c4 10             	add    $0x10,%esp
f010261e:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f0102623:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102628:	77 15                	ja     f010263f <mem_init+0x1358>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010262a:	50                   	push   %eax
f010262b:	68 68 68 10 f0       	push   $0xf0106868
f0102630:	68 d8 00 00 00       	push   $0xd8
f0102635:	68 15 77 10 f0       	push   $0xf0107715
f010263a:	e8 01 da ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f010263f:	83 ec 08             	sub    $0x8,%esp
f0102642:	6a 02                	push   $0x2
f0102644:	68 00 80 11 00       	push   $0x118000
f0102649:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010264e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102653:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f0102658:	e8 55 ea ff ff       	call   f01010b2 <boot_map_region>
f010265d:	c7 45 c4 00 10 2a f0 	movl   $0xf02a1000,-0x3c(%ebp)
f0102664:	83 c4 10             	add    $0x10,%esp
f0102667:	bb 00 10 2a f0       	mov    $0xf02a1000,%ebx
f010266c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102671:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102677:	77 15                	ja     f010268e <mem_init+0x13a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102679:	53                   	push   %ebx
f010267a:	68 68 68 10 f0       	push   $0xf0106868
f010267f:	68 1c 01 00 00       	push   $0x11c
f0102684:	68 15 77 10 f0       	push   $0xf0107715
f0102689:	e8 b2 d9 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	
	for (int i = 0; i < NCPU; i++) {
	
		boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f010268e:	83 ec 08             	sub    $0x8,%esp
f0102691:	6a 02                	push   $0x2
f0102693:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102699:	50                   	push   %eax
f010269a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010269f:	89 f2                	mov    %esi,%edx
f01026a1:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f01026a6:	e8 07 ea ff ff       	call   f01010b2 <boot_map_region>
f01026ab:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026b1:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	
	for (int i = 0; i < NCPU; i++) {
f01026b7:	83 c4 10             	add    $0x10,%esp
f01026ba:	b8 00 10 2e f0       	mov    $0xf02e1000,%eax
f01026bf:	39 d8                	cmp    %ebx,%eax
f01026c1:	75 ae                	jne    f0102671 <mem_init+0x138a>

//<<<<<<< HEAD
	// Initialize the SMP-related parts of the memory map
	mem_init_mp();
//=======
	boot_map_region(kern_pgdir, KERNBASE, -KERNBASE, 0, PTE_W);
f01026c3:	83 ec 08             	sub    $0x8,%esp
f01026c6:	6a 02                	push   $0x2
f01026c8:	6a 00                	push   $0x0
f01026ca:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026cf:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026d4:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
f01026d9:	e8 d4 e9 ff ff       	call   f01010b2 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026de:	8b 3d a4 fe 29 f0    	mov    0xf029fea4,%edi
	cprintf("entering check\n");
f01026e4:	c7 04 24 1d 7a 10 f0 	movl   $0xf0107a1d,(%esp)
f01026eb:	e8 35 0f 00 00       	call   f0103625 <cprintf>
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026f0:	a1 a0 fe 29 f0       	mov    0xf029fea0,%eax
f01026f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026f8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102704:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102707:	8b 35 a8 fe 29 f0    	mov    0xf029fea8,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270d:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102710:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;
	cprintf("entering check\n");
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102713:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102718:	eb 55                	jmp    f010276f <mem_init+0x1488>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010271a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102720:	89 f8                	mov    %edi,%eax
f0102722:	e8 d5 e3 ff ff       	call   f0100afc <check_va2pa>
f0102727:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010272e:	77 15                	ja     f0102745 <mem_init+0x145e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102730:	56                   	push   %esi
f0102731:	68 68 68 10 f0       	push   $0xf0106868
f0102736:	68 63 03 00 00       	push   $0x363
f010273b:	68 15 77 10 f0       	push   $0xf0107715
f0102740:	e8 fb d8 ff ff       	call   f0100040 <_panic>
f0102745:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010274c:	39 c2                	cmp    %eax,%edx
f010274e:	74 19                	je     f0102769 <mem_init+0x1482>
f0102750:	68 24 75 10 f0       	push   $0xf0107524
f0102755:	68 3b 77 10 f0       	push   $0xf010773b
f010275a:	68 63 03 00 00       	push   $0x363
f010275f:	68 15 77 10 f0       	push   $0xf0107715
f0102764:	e8 d7 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;
	cprintf("entering check\n");
	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102769:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010276f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102772:	77 a6                	ja     f010271a <mem_init+0x1433>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102774:	8b 35 48 f2 29 f0    	mov    0xf029f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010277a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010277d:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102782:	89 da                	mov    %ebx,%edx
f0102784:	89 f8                	mov    %edi,%eax
f0102786:	e8 71 e3 ff ff       	call   f0100afc <check_va2pa>
f010278b:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102792:	77 15                	ja     f01027a9 <mem_init+0x14c2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102794:	56                   	push   %esi
f0102795:	68 68 68 10 f0       	push   $0xf0106868
f010279a:	68 68 03 00 00       	push   $0x368
f010279f:	68 15 77 10 f0       	push   $0xf0107715
f01027a4:	e8 97 d8 ff ff       	call   f0100040 <_panic>
f01027a9:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01027b0:	39 d0                	cmp    %edx,%eax
f01027b2:	74 19                	je     f01027cd <mem_init+0x14e6>
f01027b4:	68 58 75 10 f0       	push   $0xf0107558
f01027b9:	68 3b 77 10 f0       	push   $0xf010773b
f01027be:	68 68 03 00 00       	push   $0x368
f01027c3:	68 15 77 10 f0       	push   $0xf0107715
f01027c8:	e8 73 d8 ff ff       	call   f0100040 <_panic>
f01027cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027d3:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01027d9:	75 a7                	jne    f0102782 <mem_init+0x149b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027db:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01027de:	c1 e6 0c             	shl    $0xc,%esi
f01027e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027e6:	eb 30                	jmp    f0102818 <mem_init+0x1531>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027e8:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01027ee:	89 f8                	mov    %edi,%eax
f01027f0:	e8 07 e3 ff ff       	call   f0100afc <check_va2pa>
f01027f5:	39 c3                	cmp    %eax,%ebx
f01027f7:	74 19                	je     f0102812 <mem_init+0x152b>
f01027f9:	68 8c 75 10 f0       	push   $0xf010758c
f01027fe:	68 3b 77 10 f0       	push   $0xf010773b
f0102803:	68 6c 03 00 00       	push   $0x36c
f0102808:	68 15 77 10 f0       	push   $0xf0107715
f010280d:	e8 2e d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102812:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102818:	39 f3                	cmp    %esi,%ebx
f010281a:	72 cc                	jb     f01027e8 <mem_init+0x1501>
f010281c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102821:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102824:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102827:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010282a:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102830:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102833:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102835:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102838:	05 00 80 00 20       	add    $0x20008000,%eax
f010283d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102840:	89 da                	mov    %ebx,%edx
f0102842:	89 f8                	mov    %edi,%eax
f0102844:	e8 b3 e2 ff ff       	call   f0100afc <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102849:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010284f:	77 15                	ja     f0102866 <mem_init+0x157f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102851:	56                   	push   %esi
f0102852:	68 68 68 10 f0       	push   $0xf0106868
f0102857:	68 74 03 00 00       	push   $0x374
f010285c:	68 15 77 10 f0       	push   $0xf0107715
f0102861:	e8 da d7 ff ff       	call   f0100040 <_panic>
f0102866:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102869:	8d 94 0b 00 10 2a f0 	lea    -0xfd5f000(%ebx,%ecx,1),%edx
f0102870:	39 d0                	cmp    %edx,%eax
f0102872:	74 19                	je     f010288d <mem_init+0x15a6>
f0102874:	68 b4 75 10 f0       	push   $0xf01075b4
f0102879:	68 3b 77 10 f0       	push   $0xf010773b
f010287e:	68 74 03 00 00       	push   $0x374
f0102883:	68 15 77 10 f0       	push   $0xf0107715
f0102888:	e8 b3 d7 ff ff       	call   f0100040 <_panic>
f010288d:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102893:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102896:	75 a8                	jne    f0102840 <mem_init+0x1559>
f0102898:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010289b:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028a1:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028a4:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01028a6:	89 da                	mov    %ebx,%edx
f01028a8:	89 f8                	mov    %edi,%eax
f01028aa:	e8 4d e2 ff ff       	call   f0100afc <check_va2pa>
f01028af:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028b2:	74 19                	je     f01028cd <mem_init+0x15e6>
f01028b4:	68 fc 75 10 f0       	push   $0xf01075fc
f01028b9:	68 3b 77 10 f0       	push   $0xf010773b
f01028be:	68 76 03 00 00       	push   $0x376
f01028c3:	68 15 77 10 f0       	push   $0xf0107715
f01028c8:	e8 73 d7 ff ff       	call   f0100040 <_panic>
f01028cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01028d3:	39 de                	cmp    %ebx,%esi
f01028d5:	75 cf                	jne    f01028a6 <mem_init+0x15bf>
f01028d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028da:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01028e1:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01028e8:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01028ee:	81 fe 00 10 2e f0    	cmp    $0xf02e1000,%esi
f01028f4:	0f 85 2d ff ff ff    	jne    f0102827 <mem_init+0x1540>
f01028fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01028ff:	eb 2a                	jmp    f010292b <mem_init+0x1644>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102901:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102907:	83 fa 04             	cmp    $0x4,%edx
f010290a:	77 1f                	ja     f010292b <mem_init+0x1644>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010290c:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102910:	75 7e                	jne    f0102990 <mem_init+0x16a9>
f0102912:	68 2d 7a 10 f0       	push   $0xf0107a2d
f0102917:	68 3b 77 10 f0       	push   $0xf010773b
f010291c:	68 81 03 00 00       	push   $0x381
f0102921:	68 15 77 10 f0       	push   $0xf0107715
f0102926:	e8 15 d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010292b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102930:	76 3f                	jbe    f0102971 <mem_init+0x168a>
				assert(pgdir[i] & PTE_P);
f0102932:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102935:	f6 c2 01             	test   $0x1,%dl
f0102938:	75 19                	jne    f0102953 <mem_init+0x166c>
f010293a:	68 2d 7a 10 f0       	push   $0xf0107a2d
f010293f:	68 3b 77 10 f0       	push   $0xf010773b
f0102944:	68 85 03 00 00       	push   $0x385
f0102949:	68 15 77 10 f0       	push   $0xf0107715
f010294e:	e8 ed d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102953:	f6 c2 02             	test   $0x2,%dl
f0102956:	75 38                	jne    f0102990 <mem_init+0x16a9>
f0102958:	68 3e 7a 10 f0       	push   $0xf0107a3e
f010295d:	68 3b 77 10 f0       	push   $0xf010773b
f0102962:	68 86 03 00 00       	push   $0x386
f0102967:	68 15 77 10 f0       	push   $0xf0107715
f010296c:	e8 cf d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102971:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102975:	74 19                	je     f0102990 <mem_init+0x16a9>
f0102977:	68 4f 7a 10 f0       	push   $0xf0107a4f
f010297c:	68 3b 77 10 f0       	push   $0xf010773b
f0102981:	68 88 03 00 00       	push   $0x388
f0102986:	68 15 77 10 f0       	push   $0xf0107715
f010298b:	e8 b0 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102990:	83 c0 01             	add    $0x1,%eax
f0102993:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102998:	0f 86 63 ff ff ff    	jbe    f0102901 <mem_init+0x161a>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010299e:	83 ec 0c             	sub    $0xc,%esp
f01029a1:	68 20 76 10 f0       	push   $0xf0107620
f01029a6:	e8 7a 0c 00 00       	call   f0103625 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029ab:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029b0:	83 c4 10             	add    $0x10,%esp
f01029b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029b8:	77 15                	ja     f01029cf <mem_init+0x16e8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029ba:	50                   	push   %eax
f01029bb:	68 68 68 10 f0       	push   $0xf0106868
f01029c0:	68 f4 00 00 00       	push   $0xf4
f01029c5:	68 15 77 10 f0       	push   $0xf0107715
f01029ca:	e8 71 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01029d4:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01029dc:	e8 7f e1 ff ff       	call   f0100b60 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029e1:	0f 20 c0             	mov    %cr0,%eax
f01029e4:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029e7:	0d 23 00 05 80       	or     $0x80050023,%eax
f01029ec:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029ef:	83 ec 0c             	sub    $0xc,%esp
f01029f2:	6a 00                	push   $0x0
f01029f4:	e8 3d e5 ff ff       	call   f0100f36 <page_alloc>
f01029f9:	89 c3                	mov    %eax,%ebx
f01029fb:	83 c4 10             	add    $0x10,%esp
f01029fe:	85 c0                	test   %eax,%eax
f0102a00:	75 19                	jne    f0102a1b <mem_init+0x1734>
f0102a02:	68 29 78 10 f0       	push   $0xf0107829
f0102a07:	68 3b 77 10 f0       	push   $0xf010773b
f0102a0c:	68 60 04 00 00       	push   $0x460
f0102a11:	68 15 77 10 f0       	push   $0xf0107715
f0102a16:	e8 25 d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a1b:	83 ec 0c             	sub    $0xc,%esp
f0102a1e:	6a 00                	push   $0x0
f0102a20:	e8 11 e5 ff ff       	call   f0100f36 <page_alloc>
f0102a25:	89 c7                	mov    %eax,%edi
f0102a27:	83 c4 10             	add    $0x10,%esp
f0102a2a:	85 c0                	test   %eax,%eax
f0102a2c:	75 19                	jne    f0102a47 <mem_init+0x1760>
f0102a2e:	68 3f 78 10 f0       	push   $0xf010783f
f0102a33:	68 3b 77 10 f0       	push   $0xf010773b
f0102a38:	68 61 04 00 00       	push   $0x461
f0102a3d:	68 15 77 10 f0       	push   $0xf0107715
f0102a42:	e8 f9 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a47:	83 ec 0c             	sub    $0xc,%esp
f0102a4a:	6a 00                	push   $0x0
f0102a4c:	e8 e5 e4 ff ff       	call   f0100f36 <page_alloc>
f0102a51:	89 c6                	mov    %eax,%esi
f0102a53:	83 c4 10             	add    $0x10,%esp
f0102a56:	85 c0                	test   %eax,%eax
f0102a58:	75 19                	jne    f0102a73 <mem_init+0x178c>
f0102a5a:	68 55 78 10 f0       	push   $0xf0107855
f0102a5f:	68 3b 77 10 f0       	push   $0xf010773b
f0102a64:	68 62 04 00 00       	push   $0x462
f0102a69:	68 15 77 10 f0       	push   $0xf0107715
f0102a6e:	e8 cd d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a73:	83 ec 0c             	sub    $0xc,%esp
f0102a76:	53                   	push   %ebx
f0102a77:	e8 2a e5 ff ff       	call   f0100fa6 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a7c:	89 f8                	mov    %edi,%eax
f0102a7e:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0102a84:	c1 f8 03             	sar    $0x3,%eax
f0102a87:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a8a:	89 c2                	mov    %eax,%edx
f0102a8c:	c1 ea 0c             	shr    $0xc,%edx
f0102a8f:	83 c4 10             	add    $0x10,%esp
f0102a92:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0102a98:	72 12                	jb     f0102aac <mem_init+0x17c5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a9a:	50                   	push   %eax
f0102a9b:	68 44 68 10 f0       	push   $0xf0106844
f0102aa0:	6a 58                	push   $0x58
f0102aa2:	68 21 77 10 f0       	push   $0xf0107721
f0102aa7:	e8 94 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102aac:	83 ec 04             	sub    $0x4,%esp
f0102aaf:	68 00 10 00 00       	push   $0x1000
f0102ab4:	6a 01                	push   $0x1
f0102ab6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102abb:	50                   	push   %eax
f0102abc:	e8 45 2b 00 00       	call   f0105606 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ac1:	89 f0                	mov    %esi,%eax
f0102ac3:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0102ac9:	c1 f8 03             	sar    $0x3,%eax
f0102acc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102acf:	89 c2                	mov    %eax,%edx
f0102ad1:	c1 ea 0c             	shr    $0xc,%edx
f0102ad4:	83 c4 10             	add    $0x10,%esp
f0102ad7:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0102add:	72 12                	jb     f0102af1 <mem_init+0x180a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102adf:	50                   	push   %eax
f0102ae0:	68 44 68 10 f0       	push   $0xf0106844
f0102ae5:	6a 58                	push   $0x58
f0102ae7:	68 21 77 10 f0       	push   $0xf0107721
f0102aec:	e8 4f d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102af1:	83 ec 04             	sub    $0x4,%esp
f0102af4:	68 00 10 00 00       	push   $0x1000
f0102af9:	6a 02                	push   $0x2
f0102afb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b00:	50                   	push   %eax
f0102b01:	e8 00 2b 00 00       	call   f0105606 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b06:	6a 02                	push   $0x2
f0102b08:	68 00 10 00 00       	push   $0x1000
f0102b0d:	57                   	push   %edi
f0102b0e:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0102b14:	e8 f9 e6 ff ff       	call   f0101212 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b19:	83 c4 20             	add    $0x20,%esp
f0102b1c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b21:	74 19                	je     f0102b3c <mem_init+0x1855>
f0102b23:	68 26 79 10 f0       	push   $0xf0107926
f0102b28:	68 3b 77 10 f0       	push   $0xf010773b
f0102b2d:	68 67 04 00 00       	push   $0x467
f0102b32:	68 15 77 10 f0       	push   $0xf0107715
f0102b37:	e8 04 d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b3c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b43:	01 01 01 
f0102b46:	74 19                	je     f0102b61 <mem_init+0x187a>
f0102b48:	68 40 76 10 f0       	push   $0xf0107640
f0102b4d:	68 3b 77 10 f0       	push   $0xf010773b
f0102b52:	68 68 04 00 00       	push   $0x468
f0102b57:	68 15 77 10 f0       	push   $0xf0107715
f0102b5c:	e8 df d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b61:	6a 02                	push   $0x2
f0102b63:	68 00 10 00 00       	push   $0x1000
f0102b68:	56                   	push   %esi
f0102b69:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0102b6f:	e8 9e e6 ff ff       	call   f0101212 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b74:	83 c4 10             	add    $0x10,%esp
f0102b77:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b7e:	02 02 02 
f0102b81:	74 19                	je     f0102b9c <mem_init+0x18b5>
f0102b83:	68 64 76 10 f0       	push   $0xf0107664
f0102b88:	68 3b 77 10 f0       	push   $0xf010773b
f0102b8d:	68 6a 04 00 00       	push   $0x46a
f0102b92:	68 15 77 10 f0       	push   $0xf0107715
f0102b97:	e8 a4 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102b9c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ba1:	74 19                	je     f0102bbc <mem_init+0x18d5>
f0102ba3:	68 48 79 10 f0       	push   $0xf0107948
f0102ba8:	68 3b 77 10 f0       	push   $0xf010773b
f0102bad:	68 6b 04 00 00       	push   $0x46b
f0102bb2:	68 15 77 10 f0       	push   $0xf0107715
f0102bb7:	e8 84 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bbc:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bc1:	74 19                	je     f0102bdc <mem_init+0x18f5>
f0102bc3:	68 b2 79 10 f0       	push   $0xf01079b2
f0102bc8:	68 3b 77 10 f0       	push   $0xf010773b
f0102bcd:	68 6c 04 00 00       	push   $0x46c
f0102bd2:	68 15 77 10 f0       	push   $0xf0107715
f0102bd7:	e8 64 d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bdc:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102be3:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102be6:	89 f0                	mov    %esi,%eax
f0102be8:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0102bee:	c1 f8 03             	sar    $0x3,%eax
f0102bf1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bf4:	89 c2                	mov    %eax,%edx
f0102bf6:	c1 ea 0c             	shr    $0xc,%edx
f0102bf9:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0102bff:	72 12                	jb     f0102c13 <mem_init+0x192c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c01:	50                   	push   %eax
f0102c02:	68 44 68 10 f0       	push   $0xf0106844
f0102c07:	6a 58                	push   $0x58
f0102c09:	68 21 77 10 f0       	push   $0xf0107721
f0102c0e:	e8 2d d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c13:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c1a:	03 03 03 
f0102c1d:	74 19                	je     f0102c38 <mem_init+0x1951>
f0102c1f:	68 88 76 10 f0       	push   $0xf0107688
f0102c24:	68 3b 77 10 f0       	push   $0xf010773b
f0102c29:	68 6e 04 00 00       	push   $0x46e
f0102c2e:	68 15 77 10 f0       	push   $0xf0107715
f0102c33:	e8 08 d4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c38:	83 ec 08             	sub    $0x8,%esp
f0102c3b:	68 00 10 00 00       	push   $0x1000
f0102c40:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0102c46:	e8 79 e5 ff ff       	call   f01011c4 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c4b:	83 c4 10             	add    $0x10,%esp
f0102c4e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c53:	74 19                	je     f0102c6e <mem_init+0x1987>
f0102c55:	68 80 79 10 f0       	push   $0xf0107980
f0102c5a:	68 3b 77 10 f0       	push   $0xf010773b
f0102c5f:	68 70 04 00 00       	push   $0x470
f0102c64:	68 15 77 10 f0       	push   $0xf0107715
f0102c69:	e8 d2 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c6e:	8b 0d a4 fe 29 f0    	mov    0xf029fea4,%ecx
f0102c74:	8b 11                	mov    (%ecx),%edx
f0102c76:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c7c:	89 d8                	mov    %ebx,%eax
f0102c7e:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0102c84:	c1 f8 03             	sar    $0x3,%eax
f0102c87:	c1 e0 0c             	shl    $0xc,%eax
f0102c8a:	39 c2                	cmp    %eax,%edx
f0102c8c:	74 19                	je     f0102ca7 <mem_init+0x19c0>
f0102c8e:	68 10 70 10 f0       	push   $0xf0107010
f0102c93:	68 3b 77 10 f0       	push   $0xf010773b
f0102c98:	68 73 04 00 00       	push   $0x473
f0102c9d:	68 15 77 10 f0       	push   $0xf0107715
f0102ca2:	e8 99 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102ca7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cad:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cb2:	74 19                	je     f0102ccd <mem_init+0x19e6>
f0102cb4:	68 37 79 10 f0       	push   $0xf0107937
f0102cb9:	68 3b 77 10 f0       	push   $0xf010773b
f0102cbe:	68 75 04 00 00       	push   $0x475
f0102cc3:	68 15 77 10 f0       	push   $0xf0107715
f0102cc8:	e8 73 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102ccd:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102cd3:	83 ec 0c             	sub    $0xc,%esp
f0102cd6:	53                   	push   %ebx
f0102cd7:	e8 ca e2 ff ff       	call   f0100fa6 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cdc:	c7 04 24 b4 76 10 f0 	movl   $0xf01076b4,(%esp)
f0102ce3:	e8 3d 09 00 00       	call   f0103625 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ce8:	83 c4 10             	add    $0x10,%esp
f0102ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cee:	5b                   	pop    %ebx
f0102cef:	5e                   	pop    %esi
f0102cf0:	5f                   	pop    %edi
f0102cf1:	5d                   	pop    %ebp
f0102cf2:	c3                   	ret    

f0102cf3 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102cf3:	55                   	push   %ebp
f0102cf4:	89 e5                	mov    %esp,%ebp
f0102cf6:	57                   	push   %edi
f0102cf7:	56                   	push   %esi
f0102cf8:	53                   	push   %ebx
f0102cf9:	83 ec 1c             	sub    $0x1c,%esp
f0102cfc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102cff:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	//cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t start = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102d02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d05:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d0e:	03 45 10             	add    0x10(%ebp),%eax
f0102d11:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	for(;start < end; start = start + PGSIZE){
f0102d1e:	eb 50                	jmp    f0102d70 <user_mem_check+0x7d>
		pte_t *ptentry = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102d20:	83 ec 04             	sub    $0x4,%esp
f0102d23:	6a 00                	push   $0x0
f0102d25:	53                   	push   %ebx
f0102d26:	ff 77 60             	pushl  0x60(%edi)
f0102d29:	e8 f1 e2 ff ff       	call   f010101f <pgdir_walk>
		
		if((start >= ULIM) || !ptentry || !(*ptentry & PTE_P) || ((*ptentry & perm) != perm)){	//check for errors
f0102d2e:	83 c4 10             	add    $0x10,%esp
f0102d31:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d37:	77 10                	ja     f0102d49 <user_mem_check+0x56>
f0102d39:	85 c0                	test   %eax,%eax
f0102d3b:	74 0c                	je     f0102d49 <user_mem_check+0x56>
f0102d3d:	8b 00                	mov    (%eax),%eax
f0102d3f:	a8 01                	test   $0x1,%al
f0102d41:	74 06                	je     f0102d49 <user_mem_check+0x56>
f0102d43:	21 f0                	and    %esi,%eax
f0102d45:	39 c6                	cmp    %eax,%esi
f0102d47:	74 21                	je     f0102d6a <user_mem_check+0x77>
			if(start < (uint32_t)va)	//because "start" has been rounded down
f0102d49:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d4c:	73 0f                	jae    f0102d5d <user_mem_check+0x6a>
				user_mem_check_addr = (uint32_t)va;
f0102d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d51:	a3 3c f2 29 f0       	mov    %eax,0xf029f23c
			else
				user_mem_check_addr = start;
			
			return -E_FAULT;
f0102d56:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d5b:	eb 1d                	jmp    f0102d7a <user_mem_check+0x87>
		
		if((start >= ULIM) || !ptentry || !(*ptentry & PTE_P) || ((*ptentry & perm) != perm)){	//check for errors
			if(start < (uint32_t)va)	//because "start" has been rounded down
				user_mem_check_addr = (uint32_t)va;
			else
				user_mem_check_addr = start;
f0102d5d:	89 1d 3c f2 29 f0    	mov    %ebx,0xf029f23c
			
			return -E_FAULT;
f0102d63:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d68:	eb 10                	jmp    f0102d7a <user_mem_check+0x87>
	// LAB 3: Your code here.
	//cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t start = (uint32_t)ROUNDDOWN(va, PGSIZE);
	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);

	for(;start < end; start = start + PGSIZE){
f0102d6a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d70:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d73:	72 ab                	jb     f0102d20 <user_mem_check+0x2d>
			return -E_FAULT;
		}
	}
	//cprintf("user_mem_check success va: %x, len: %x\n", va, len);
	
	return 0;
f0102d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d7d:	5b                   	pop    %ebx
f0102d7e:	5e                   	pop    %esi
f0102d7f:	5f                   	pop    %edi
f0102d80:	5d                   	pop    %ebp
f0102d81:	c3                   	ret    

f0102d82 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d82:	55                   	push   %ebp
f0102d83:	89 e5                	mov    %esp,%ebp
f0102d85:	53                   	push   %ebx
f0102d86:	83 ec 04             	sub    $0x4,%esp
f0102d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d8f:	83 c8 04             	or     $0x4,%eax
f0102d92:	50                   	push   %eax
f0102d93:	ff 75 10             	pushl  0x10(%ebp)
f0102d96:	ff 75 0c             	pushl  0xc(%ebp)
f0102d99:	53                   	push   %ebx
f0102d9a:	e8 54 ff ff ff       	call   f0102cf3 <user_mem_check>
f0102d9f:	83 c4 10             	add    $0x10,%esp
f0102da2:	85 c0                	test   %eax,%eax
f0102da4:	79 21                	jns    f0102dc7 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102da6:	83 ec 04             	sub    $0x4,%esp
f0102da9:	ff 35 3c f2 29 f0    	pushl  0xf029f23c
f0102daf:	ff 73 48             	pushl  0x48(%ebx)
f0102db2:	68 e0 76 10 f0       	push   $0xf01076e0
f0102db7:	e8 69 08 00 00       	call   f0103625 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102dbc:	89 1c 24             	mov    %ebx,(%esp)
f0102dbf:	e8 92 05 00 00       	call   f0103356 <env_destroy>
f0102dc4:	83 c4 10             	add    $0x10,%esp
	}
}
f0102dc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102dca:	c9                   	leave  
f0102dcb:	c3                   	ret    

f0102dcc <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102dcc:	55                   	push   %ebp
f0102dcd:	89 e5                	mov    %esp,%ebp
f0102dcf:	57                   	push   %edi
f0102dd0:	56                   	push   %esi
f0102dd1:	53                   	push   %ebx
f0102dd2:	83 ec 0c             	sub    $0xc,%esp
f0102dd5:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	void *start = ROUNDDOWN(va,PGSIZE);
f0102dd7:	89 d3                	mov    %edx,%ebx
f0102dd9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va + len, PGSIZE);
f0102ddf:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102de6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	
	for(; start < end; start = start + PGSIZE){
f0102dec:	eb 3d                	jmp    f0102e2b <region_alloc+0x5f>
		struct PageInfo *p = page_alloc(!ALLOC_ZERO);
f0102dee:	83 ec 0c             	sub    $0xc,%esp
f0102df1:	6a 00                	push   $0x0
f0102df3:	e8 3e e1 ff ff       	call   f0100f36 <page_alloc>
		if(!p)
f0102df8:	83 c4 10             	add    $0x10,%esp
f0102dfb:	85 c0                	test   %eax,%eax
f0102dfd:	75 17                	jne    f0102e16 <region_alloc+0x4a>
			panic("Allocation attempt failed");
f0102dff:	83 ec 04             	sub    $0x4,%esp
f0102e02:	68 5d 7a 10 f0       	push   $0xf0107a5d
f0102e07:	68 2c 01 00 00       	push   $0x12c
f0102e0c:	68 77 7a 10 f0       	push   $0xf0107a77
f0102e11:	e8 2a d2 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, p, start, PTE_W|PTE_U);		
f0102e16:	6a 06                	push   $0x6
f0102e18:	53                   	push   %ebx
f0102e19:	50                   	push   %eax
f0102e1a:	ff 77 60             	pushl  0x60(%edi)
f0102e1d:	e8 f0 e3 ff ff       	call   f0101212 <page_insert>
	//   (Watch out for corner-cases!)
	
	void *start = ROUNDDOWN(va,PGSIZE);
	void *end = ROUNDUP(va + len, PGSIZE);
	
	for(; start < end; start = start + PGSIZE){
f0102e22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e28:	83 c4 10             	add    $0x10,%esp
f0102e2b:	39 f3                	cmp    %esi,%ebx
f0102e2d:	72 bf                	jb     f0102dee <region_alloc+0x22>
		struct PageInfo *p = page_alloc(!ALLOC_ZERO);
		if(!p)
			panic("Allocation attempt failed");
		page_insert(e->env_pgdir, p, start, PTE_W|PTE_U);		
	}
}
f0102e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e32:	5b                   	pop    %ebx
f0102e33:	5e                   	pop    %esi
f0102e34:	5f                   	pop    %edi
f0102e35:	5d                   	pop    %ebp
f0102e36:	c3                   	ret    

f0102e37 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e37:	55                   	push   %ebp
f0102e38:	89 e5                	mov    %esp,%ebp
f0102e3a:	56                   	push   %esi
f0102e3b:	53                   	push   %ebx
f0102e3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e3f:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e42:	85 c0                	test   %eax,%eax
f0102e44:	75 1a                	jne    f0102e60 <envid2env+0x29>
		*env_store = curenv;
f0102e46:	e8 db 2d 00 00       	call   f0105c26 <cpunum>
f0102e4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e4e:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0102e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e57:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e59:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e5e:	eb 70                	jmp    f0102ed0 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e60:	89 c3                	mov    %eax,%ebx
f0102e62:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e68:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e6b:	03 1d 48 f2 29 f0    	add    0xf029f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e71:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e75:	74 05                	je     f0102e7c <envid2env+0x45>
f0102e77:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102e7a:	74 10                	je     f0102e8c <envid2env+0x55>
		*env_store = 0;
f0102e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e85:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e8a:	eb 44                	jmp    f0102ed0 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e8c:	84 d2                	test   %dl,%dl
f0102e8e:	74 36                	je     f0102ec6 <envid2env+0x8f>
f0102e90:	e8 91 2d 00 00       	call   f0105c26 <cpunum>
f0102e95:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e98:	3b 98 28 00 2a f0    	cmp    -0xfd5ffd8(%eax),%ebx
f0102e9e:	74 26                	je     f0102ec6 <envid2env+0x8f>
f0102ea0:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ea3:	e8 7e 2d 00 00       	call   f0105c26 <cpunum>
f0102ea8:	6b c0 74             	imul   $0x74,%eax,%eax
f0102eab:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0102eb1:	3b 70 48             	cmp    0x48(%eax),%esi
f0102eb4:	74 10                	je     f0102ec6 <envid2env+0x8f>
		*env_store = 0;
f0102eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102eb9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ebf:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ec4:	eb 0a                	jmp    f0102ed0 <envid2env+0x99>
	}

	*env_store = e;
f0102ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ec9:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102ecb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ed0:	5b                   	pop    %ebx
f0102ed1:	5e                   	pop    %esi
f0102ed2:	5d                   	pop    %ebp
f0102ed3:	c3                   	ret    

f0102ed4 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ed4:	55                   	push   %ebp
f0102ed5:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ed7:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0102edc:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102edf:	b8 23 00 00 00       	mov    $0x23,%eax
f0102ee4:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102ee6:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102ee8:	b8 10 00 00 00       	mov    $0x10,%eax
f0102eed:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102eef:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102ef1:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102ef3:	ea fa 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102efa
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102efa:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eff:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f02:	5d                   	pop    %ebp
f0102f03:	c3                   	ret    

f0102f04 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f04:	55                   	push   %ebp
f0102f05:	89 e5                	mov    %esp,%ebp
f0102f07:	56                   	push   %esi
f0102f08:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV - 1; i >= 0; --i) {
		envs[i].env_status = ENV_FREE;
f0102f09:	8b 35 48 f2 29 f0    	mov    0xf029f248,%esi
f0102f0f:	8b 15 4c f2 29 f0    	mov    0xf029f24c,%edx
f0102f15:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f1b:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f1e:	89 c1                	mov    %eax,%ecx
f0102f20:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102f27:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f2e:	89 50 44             	mov    %edx,0x44(%eax)
f0102f31:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102f34:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV - 1; i >= 0; --i) {
f0102f36:	39 d8                	cmp    %ebx,%eax
f0102f38:	75 e4                	jne    f0102f1e <env_init+0x1a>
f0102f3a:	89 35 4c f2 29 f0    	mov    %esi,0xf029f24c
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	
	// Per-CPU part of the initialization
	env_init_percpu();
f0102f40:	e8 8f ff ff ff       	call   f0102ed4 <env_init_percpu>
}
f0102f45:	5b                   	pop    %ebx
f0102f46:	5e                   	pop    %esi
f0102f47:	5d                   	pop    %ebp
f0102f48:	c3                   	ret    

f0102f49 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f49:	55                   	push   %ebp
f0102f4a:	89 e5                	mov    %esp,%ebp
f0102f4c:	53                   	push   %ebx
f0102f4d:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f50:	8b 1d 4c f2 29 f0    	mov    0xf029f24c,%ebx
f0102f56:	85 db                	test   %ebx,%ebx
f0102f58:	0f 84 2d 01 00 00    	je     f010308b <env_alloc+0x142>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f5e:	83 ec 0c             	sub    $0xc,%esp
f0102f61:	6a 01                	push   $0x1
f0102f63:	e8 ce df ff ff       	call   f0100f36 <page_alloc>
f0102f68:	83 c4 10             	add    $0x10,%esp
f0102f6b:	85 c0                	test   %eax,%eax
f0102f6d:	0f 84 1f 01 00 00    	je     f0103092 <env_alloc+0x149>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	p->pp_ref++;
f0102f73:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f78:	2b 05 a8 fe 29 f0    	sub    0xf029fea8,%eax
f0102f7e:	c1 f8 03             	sar    $0x3,%eax
f0102f81:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f84:	89 c2                	mov    %eax,%edx
f0102f86:	c1 ea 0c             	shr    $0xc,%edx
f0102f89:	3b 15 a0 fe 29 f0    	cmp    0xf029fea0,%edx
f0102f8f:	72 12                	jb     f0102fa3 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f91:	50                   	push   %eax
f0102f92:	68 44 68 10 f0       	push   $0xf0106844
f0102f97:	6a 58                	push   $0x58
f0102f99:	68 21 77 10 f0       	push   $0xf0107721
f0102f9e:	e8 9d d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102fa3:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f0102fa8:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fab:	83 ec 04             	sub    $0x4,%esp
f0102fae:	68 00 10 00 00       	push   $0x1000
f0102fb3:	ff 35 a4 fe 29 f0    	pushl  0xf029fea4
f0102fb9:	50                   	push   %eax
f0102fba:	e8 fc 26 00 00       	call   f01056bb <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fbf:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fc2:	83 c4 10             	add    $0x10,%esp
f0102fc5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fca:	77 15                	ja     f0102fe1 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fcc:	50                   	push   %eax
f0102fcd:	68 68 68 10 f0       	push   $0xf0106868
f0102fd2:	68 c7 00 00 00       	push   $0xc7
f0102fd7:	68 77 7a 10 f0       	push   $0xf0107a77
f0102fdc:	e8 5f d0 ff ff       	call   f0100040 <_panic>
f0102fe1:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102fe7:	83 ca 05             	or     $0x5,%edx
f0102fea:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ff0:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ff3:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ff8:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ffd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103002:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103005:	89 da                	mov    %ebx,%edx
f0103007:	2b 15 48 f2 29 f0    	sub    0xf029f248,%edx
f010300d:	c1 fa 02             	sar    $0x2,%edx
f0103010:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103016:	09 d0                	or     %edx,%eax
f0103018:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010301b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010301e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103021:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103028:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010302f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103036:	83 ec 04             	sub    $0x4,%esp
f0103039:	6a 44                	push   $0x44
f010303b:	6a 00                	push   $0x0
f010303d:	53                   	push   %ebx
f010303e:	e8 c3 25 00 00       	call   f0105606 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103043:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103049:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010304f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103055:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010305c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103062:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103069:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103070:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103074:	8b 43 44             	mov    0x44(%ebx),%eax
f0103077:	a3 4c f2 29 f0       	mov    %eax,0xf029f24c
	*newenv_store = e;
f010307c:	8b 45 08             	mov    0x8(%ebp),%eax
f010307f:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103081:	83 c4 10             	add    $0x10,%esp
f0103084:	b8 00 00 00 00       	mov    $0x0,%eax
f0103089:	eb 0c                	jmp    f0103097 <env_alloc+0x14e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010308b:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103090:	eb 05                	jmp    f0103097 <env_alloc+0x14e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103092:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103097:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010309a:	c9                   	leave  
f010309b:	c3                   	ret    

f010309c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010309c:	55                   	push   %ebp
f010309d:	89 e5                	mov    %esp,%ebp
f010309f:	57                   	push   %edi
f01030a0:	56                   	push   %esi
f01030a1:	53                   	push   %ebx
f01030a2:	83 ec 24             	sub    $0x24,%esp
f01030a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
//=======	
	struct Env *e;
	env_alloc(&e, 0);
f01030a8:	6a 00                	push   $0x0
f01030aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030ad:	50                   	push   %eax
f01030ae:	e8 96 fe ff ff       	call   f0102f49 <env_alloc>
	e->env_type = type;
f01030b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01030b6:	89 5f 50             	mov    %ebx,0x50(%edi)
	if(type == ENV_TYPE_FS)
f01030b9:	83 c4 10             	add    $0x10,%esp
f01030bc:	83 fb 01             	cmp    $0x1,%ebx
f01030bf:	75 07                	jne    f01030c8 <env_create+0x2c>
		e->env_tf.tf_eflags |= FL_IOPL_3;
f01030c1:	81 4f 38 00 30 00 00 	orl    $0x3000,0x38(%edi)
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;
	
	
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
f01030c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01030cb:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01030d1:	74 17                	je     f01030ea <env_create+0x4e>
		panic("Not a valid ELF Header");
f01030d3:	83 ec 04             	sub    $0x4,%esp
f01030d6:	68 82 7a 10 f0       	push   $0xf0107a82
f01030db:	68 6e 01 00 00       	push   $0x16e
f01030e0:	68 77 7a 10 f0       	push   $0xf0107a77
f01030e5:	e8 56 cf ff ff       	call   f0100040 <_panic>
		
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f01030ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01030ed:	89 c3                	mov    %eax,%ebx
f01030ef:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
f01030f2:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f01030f6:	c1 e6 05             	shl    $0x5,%esi
f01030f9:	01 de                	add    %ebx,%esi
	
	lcr3(PADDR(e->env_pgdir));
f01030fb:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103103:	77 15                	ja     f010311a <env_create+0x7e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103105:	50                   	push   %eax
f0103106:	68 68 68 10 f0       	push   $0xf0106868
f010310b:	68 73 01 00 00       	push   $0x173
f0103110:	68 77 7a 10 f0       	push   $0xf0107a77
f0103115:	e8 26 cf ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010311a:	05 00 00 00 10       	add    $0x10000000,%eax
f010311f:	0f 22 d8             	mov    %eax,%cr3
f0103122:	eb 3d                	jmp    f0103161 <env_create+0xc5>
	
	for (; ph < eph; ph++){
		if(ph->p_type == ELF_PROG_LOAD){
f0103124:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103127:	75 35                	jne    f010315e <env_create+0xc2>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103129:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010312c:	8b 53 08             	mov    0x8(%ebx),%edx
f010312f:	89 f8                	mov    %edi,%eax
f0103131:	e8 96 fc ff ff       	call   f0102dcc <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103136:	83 ec 04             	sub    $0x4,%esp
f0103139:	ff 73 14             	pushl  0x14(%ebx)
f010313c:	6a 00                	push   $0x0
f010313e:	ff 73 08             	pushl  0x8(%ebx)
f0103141:	e8 c0 24 00 00       	call   f0105606 <memset>
			memcpy((void*)ph->p_va, (void*)binary + ph->p_offset, ph->p_filesz);
f0103146:	83 c4 0c             	add    $0xc,%esp
f0103149:	ff 73 10             	pushl  0x10(%ebx)
f010314c:	8b 45 08             	mov    0x8(%ebp),%eax
f010314f:	03 43 04             	add    0x4(%ebx),%eax
f0103152:	50                   	push   %eax
f0103153:	ff 73 08             	pushl  0x8(%ebx)
f0103156:	e8 60 25 00 00       	call   f01056bb <memcpy>
f010315b:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	
	lcr3(PADDR(e->env_pgdir));
	
	for (; ph < eph; ph++){
f010315e:	83 c3 20             	add    $0x20,%ebx
f0103161:	39 de                	cmp    %ebx,%esi
f0103163:	77 bf                	ja     f0103124 <env_create+0x88>
			//memset((void *)(binary + ph->p_offset + ph->p_filesz), 0, (uint32_t)ph->p_memsz - ph->p_filesz);
			
		}
	}

	lcr3(PADDR(kern_pgdir));
f0103165:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010316a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010316f:	77 15                	ja     f0103186 <env_create+0xea>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103171:	50                   	push   %eax
f0103172:	68 68 68 10 f0       	push   $0xf0106868
f0103177:	68 7f 01 00 00       	push   $0x17f
f010317c:	68 77 7a 10 f0       	push   $0xf0107a77
f0103181:	e8 ba ce ff ff       	call   f0100040 <_panic>
f0103186:	05 00 00 00 10       	add    $0x10000000,%eax
f010318b:	0f 22 d8             	mov    %eax,%cr3

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f010318e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103193:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103198:	89 f8                	mov    %edi,%eax
f010319a:	e8 2d fc ff ff       	call   f0102dcc <region_alloc>
	
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f010319f:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a2:	8b 40 18             	mov    0x18(%eax),%eax
f01031a5:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_type = type;
	if(type == ENV_TYPE_FS)
		e->env_tf.tf_eflags |= FL_IOPL_3;
	load_icode(e, binary);
//>>>>>>> lab4
}
f01031a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031ab:	5b                   	pop    %ebx
f01031ac:	5e                   	pop    %esi
f01031ad:	5f                   	pop    %edi
f01031ae:	5d                   	pop    %ebp
f01031af:	c3                   	ret    

f01031b0 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01031b0:	55                   	push   %ebp
f01031b1:	89 e5                	mov    %esp,%ebp
f01031b3:	57                   	push   %edi
f01031b4:	56                   	push   %esi
f01031b5:	53                   	push   %ebx
f01031b6:	83 ec 1c             	sub    $0x1c,%esp
f01031b9:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01031bc:	e8 65 2a 00 00       	call   f0105c26 <cpunum>
f01031c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01031c4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01031cb:	39 b8 28 00 2a f0    	cmp    %edi,-0xfd5ffd8(%eax)
f01031d1:	75 30                	jne    f0103203 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01031d3:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031d8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031dd:	77 15                	ja     f01031f4 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031df:	50                   	push   %eax
f01031e0:	68 68 68 10 f0       	push   $0xf0106868
f01031e5:	68 b1 01 00 00       	push   $0x1b1
f01031ea:	68 77 7a 10 f0       	push   $0xf0107a77
f01031ef:	e8 4c ce ff ff       	call   f0100040 <_panic>
f01031f4:	05 00 00 00 10       	add    $0x10000000,%eax
f01031f9:	0f 22 d8             	mov    %eax,%cr3
f01031fc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103203:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103206:	89 d0                	mov    %edx,%eax
f0103208:	c1 e0 02             	shl    $0x2,%eax
f010320b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010320e:	8b 47 60             	mov    0x60(%edi),%eax
f0103211:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103214:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010321a:	0f 84 a8 00 00 00    	je     f01032c8 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103220:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103226:	89 f0                	mov    %esi,%eax
f0103228:	c1 e8 0c             	shr    $0xc,%eax
f010322b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010322e:	39 05 a0 fe 29 f0    	cmp    %eax,0xf029fea0
f0103234:	77 15                	ja     f010324b <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103236:	56                   	push   %esi
f0103237:	68 44 68 10 f0       	push   $0xf0106844
f010323c:	68 c0 01 00 00       	push   $0x1c0
f0103241:	68 77 7a 10 f0       	push   $0xf0107a77
f0103246:	e8 f5 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010324b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010324e:	c1 e0 16             	shl    $0x16,%eax
f0103251:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103254:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103259:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103260:	01 
f0103261:	74 17                	je     f010327a <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103263:	83 ec 08             	sub    $0x8,%esp
f0103266:	89 d8                	mov    %ebx,%eax
f0103268:	c1 e0 0c             	shl    $0xc,%eax
f010326b:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010326e:	50                   	push   %eax
f010326f:	ff 77 60             	pushl  0x60(%edi)
f0103272:	e8 4d df ff ff       	call   f01011c4 <page_remove>
f0103277:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010327a:	83 c3 01             	add    $0x1,%ebx
f010327d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103283:	75 d4                	jne    f0103259 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103285:	8b 47 60             	mov    0x60(%edi),%eax
f0103288:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010328b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103292:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103295:	3b 05 a0 fe 29 f0    	cmp    0xf029fea0,%eax
f010329b:	72 14                	jb     f01032b1 <env_free+0x101>
		panic("pa2page called with invalid pa");
f010329d:	83 ec 04             	sub    $0x4,%esp
f01032a0:	68 f4 6e 10 f0       	push   $0xf0106ef4
f01032a5:	6a 51                	push   $0x51
f01032a7:	68 21 77 10 f0       	push   $0xf0107721
f01032ac:	e8 8f cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01032b1:	83 ec 0c             	sub    $0xc,%esp
f01032b4:	a1 a8 fe 29 f0       	mov    0xf029fea8,%eax
f01032b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032bc:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01032bf:	50                   	push   %eax
f01032c0:	e8 33 dd ff ff       	call   f0100ff8 <page_decref>
f01032c5:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032c8:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01032cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032cf:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01032d4:	0f 85 29 ff ff ff    	jne    f0103203 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01032da:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e2:	77 15                	ja     f01032f9 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e4:	50                   	push   %eax
f01032e5:	68 68 68 10 f0       	push   $0xf0106868
f01032ea:	68 ce 01 00 00       	push   $0x1ce
f01032ef:	68 77 7a 10 f0       	push   $0xf0107a77
f01032f4:	e8 47 cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01032f9:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103300:	05 00 00 00 10       	add    $0x10000000,%eax
f0103305:	c1 e8 0c             	shr    $0xc,%eax
f0103308:	3b 05 a0 fe 29 f0    	cmp    0xf029fea0,%eax
f010330e:	72 14                	jb     f0103324 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103310:	83 ec 04             	sub    $0x4,%esp
f0103313:	68 f4 6e 10 f0       	push   $0xf0106ef4
f0103318:	6a 51                	push   $0x51
f010331a:	68 21 77 10 f0       	push   $0xf0107721
f010331f:	e8 1c cd ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103324:	83 ec 0c             	sub    $0xc,%esp
f0103327:	8b 15 a8 fe 29 f0    	mov    0xf029fea8,%edx
f010332d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103330:	50                   	push   %eax
f0103331:	e8 c2 dc ff ff       	call   f0100ff8 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103336:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010333d:	a1 4c f2 29 f0       	mov    0xf029f24c,%eax
f0103342:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103345:	89 3d 4c f2 29 f0    	mov    %edi,0xf029f24c
}
f010334b:	83 c4 10             	add    $0x10,%esp
f010334e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103351:	5b                   	pop    %ebx
f0103352:	5e                   	pop    %esi
f0103353:	5f                   	pop    %edi
f0103354:	5d                   	pop    %ebp
f0103355:	c3                   	ret    

f0103356 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103356:	55                   	push   %ebp
f0103357:	89 e5                	mov    %esp,%ebp
f0103359:	53                   	push   %ebx
f010335a:	83 ec 04             	sub    $0x4,%esp
f010335d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103360:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103364:	75 19                	jne    f010337f <env_destroy+0x29>
f0103366:	e8 bb 28 00 00       	call   f0105c26 <cpunum>
f010336b:	6b c0 74             	imul   $0x74,%eax,%eax
f010336e:	3b 98 28 00 2a f0    	cmp    -0xfd5ffd8(%eax),%ebx
f0103374:	74 09                	je     f010337f <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103376:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010337d:	eb 33                	jmp    f01033b2 <env_destroy+0x5c>
	}

	env_free(e);
f010337f:	83 ec 0c             	sub    $0xc,%esp
f0103382:	53                   	push   %ebx
f0103383:	e8 28 fe ff ff       	call   f01031b0 <env_free>

	if (curenv == e) {
f0103388:	e8 99 28 00 00       	call   f0105c26 <cpunum>
f010338d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103390:	83 c4 10             	add    $0x10,%esp
f0103393:	3b 98 28 00 2a f0    	cmp    -0xfd5ffd8(%eax),%ebx
f0103399:	75 17                	jne    f01033b2 <env_destroy+0x5c>
		curenv = NULL;
f010339b:	e8 86 28 00 00       	call   f0105c26 <cpunum>
f01033a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01033a3:	c7 80 28 00 2a f0 00 	movl   $0x0,-0xfd5ffd8(%eax)
f01033aa:	00 00 00 
		sched_yield();
f01033ad:	e8 f1 0f 00 00       	call   f01043a3 <sched_yield>
	}
}
f01033b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033b5:	c9                   	leave  
f01033b6:	c3                   	ret    

f01033b7 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01033b7:	55                   	push   %ebp
f01033b8:	89 e5                	mov    %esp,%ebp
f01033ba:	53                   	push   %ebx
f01033bb:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01033be:	e8 63 28 00 00       	call   f0105c26 <cpunum>
f01033c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01033c6:	8b 98 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%ebx
f01033cc:	e8 55 28 00 00       	call   f0105c26 <cpunum>
f01033d1:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01033d4:	8b 65 08             	mov    0x8(%ebp),%esp
f01033d7:	61                   	popa   
f01033d8:	07                   	pop    %es
f01033d9:	1f                   	pop    %ds
f01033da:	83 c4 08             	add    $0x8,%esp
f01033dd:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01033de:	83 ec 04             	sub    $0x4,%esp
f01033e1:	68 99 7a 10 f0       	push   $0xf0107a99
f01033e6:	68 04 02 00 00       	push   $0x204
f01033eb:	68 77 7a 10 f0       	push   $0xf0107a77
f01033f0:	e8 4b cc ff ff       	call   f0100040 <_panic>

f01033f5 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01033f5:	55                   	push   %ebp
f01033f6:	89 e5                	mov    %esp,%ebp
f01033f8:	53                   	push   %ebx
f01033f9:	83 ec 04             	sub    $0x4,%esp
f01033fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
//	cprintf("curenv: %x, e: %x\n", curenv, e);
	if ((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f01033ff:	e8 22 28 00 00       	call   f0105c26 <cpunum>
f0103404:	6b c0 74             	imul   $0x74,%eax,%eax
f0103407:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f010340e:	74 29                	je     f0103439 <env_run+0x44>
f0103410:	e8 11 28 00 00       	call   f0105c26 <cpunum>
f0103415:	6b c0 74             	imul   $0x74,%eax,%eax
f0103418:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f010341e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103422:	75 15                	jne    f0103439 <env_run+0x44>
		curenv->env_status = ENV_RUNNABLE;
f0103424:	e8 fd 27 00 00       	call   f0105c26 <cpunum>
f0103429:	6b c0 74             	imul   $0x74,%eax,%eax
f010342c:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103432:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	//if(curenv != e){
	//	if (curenv->env_status == ENV_RUNNING)
	//		curenv->env_status = ENV_RUNNABLE;
		curenv = e;
f0103439:	e8 e8 27 00 00       	call   f0105c26 <cpunum>
f010343e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103441:	89 98 28 00 2a f0    	mov    %ebx,-0xfd5ffd8(%eax)
		e->env_status = ENV_RUNNING;
f0103447:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f010344e:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));	
f0103452:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103455:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010345a:	77 15                	ja     f0103471 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010345c:	50                   	push   %eax
f010345d:	68 68 68 10 f0       	push   $0xf0106868
f0103462:	68 2b 02 00 00       	push   $0x22b
f0103467:	68 77 7a 10 f0       	push   $0xf0107a77
f010346c:	e8 cf cb ff ff       	call   f0100040 <_panic>
f0103471:	05 00 00 00 10       	add    $0x10000000,%eax
f0103476:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103479:	83 ec 0c             	sub    $0xc,%esp
f010347c:	68 c0 23 12 f0       	push   $0xf01223c0
f0103481:	e8 ab 2a 00 00       	call   f0105f31 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103486:	f3 90                	pause  
	//}
	unlock_kernel();
	env_pop_tf(&e->env_tf);
f0103488:	89 1c 24             	mov    %ebx,(%esp)
f010348b:	e8 27 ff ff ff       	call   f01033b7 <env_pop_tf>

f0103490 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103490:	55                   	push   %ebp
f0103491:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103493:	ba 70 00 00 00       	mov    $0x70,%edx
f0103498:	8b 45 08             	mov    0x8(%ebp),%eax
f010349b:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010349c:	ba 71 00 00 00       	mov    $0x71,%edx
f01034a1:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034a2:	0f b6 c0             	movzbl %al,%eax
}
f01034a5:	5d                   	pop    %ebp
f01034a6:	c3                   	ret    

f01034a7 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034a7:	55                   	push   %ebp
f01034a8:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034aa:	ba 70 00 00 00       	mov    $0x70,%edx
f01034af:	8b 45 08             	mov    0x8(%ebp),%eax
f01034b2:	ee                   	out    %al,(%dx)
f01034b3:	ba 71 00 00 00       	mov    $0x71,%edx
f01034b8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034bb:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034bc:	5d                   	pop    %ebp
f01034bd:	c3                   	ret    

f01034be <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01034be:	55                   	push   %ebp
f01034bf:	89 e5                	mov    %esp,%ebp
f01034c1:	56                   	push   %esi
f01034c2:	53                   	push   %ebx
f01034c3:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01034c6:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01034cc:	80 3d 50 f2 29 f0 00 	cmpb   $0x0,0xf029f250
f01034d3:	74 5a                	je     f010352f <irq_setmask_8259A+0x71>
f01034d5:	89 c6                	mov    %eax,%esi
f01034d7:	ba 21 00 00 00       	mov    $0x21,%edx
f01034dc:	ee                   	out    %al,(%dx)
f01034dd:	66 c1 e8 08          	shr    $0x8,%ax
f01034e1:	ba a1 00 00 00       	mov    $0xa1,%edx
f01034e6:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01034e7:	83 ec 0c             	sub    $0xc,%esp
f01034ea:	68 a5 7a 10 f0       	push   $0xf0107aa5
f01034ef:	e8 31 01 00 00       	call   f0103625 <cprintf>
f01034f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01034f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01034fc:	0f b7 f6             	movzwl %si,%esi
f01034ff:	f7 d6                	not    %esi
f0103501:	0f a3 de             	bt     %ebx,%esi
f0103504:	73 11                	jae    f0103517 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103506:	83 ec 08             	sub    $0x8,%esp
f0103509:	53                   	push   %ebx
f010350a:	68 2b 7f 10 f0       	push   $0xf0107f2b
f010350f:	e8 11 01 00 00       	call   f0103625 <cprintf>
f0103514:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103517:	83 c3 01             	add    $0x1,%ebx
f010351a:	83 fb 10             	cmp    $0x10,%ebx
f010351d:	75 e2                	jne    f0103501 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010351f:	83 ec 0c             	sub    $0xc,%esp
f0103522:	68 1b 7a 10 f0       	push   $0xf0107a1b
f0103527:	e8 f9 00 00 00       	call   f0103625 <cprintf>
f010352c:	83 c4 10             	add    $0x10,%esp
}
f010352f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103532:	5b                   	pop    %ebx
f0103533:	5e                   	pop    %esi
f0103534:	5d                   	pop    %ebp
f0103535:	c3                   	ret    

f0103536 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103536:	c6 05 50 f2 29 f0 01 	movb   $0x1,0xf029f250
f010353d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103542:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103547:	ee                   	out    %al,(%dx)
f0103548:	ba a1 00 00 00       	mov    $0xa1,%edx
f010354d:	ee                   	out    %al,(%dx)
f010354e:	ba 20 00 00 00       	mov    $0x20,%edx
f0103553:	b8 11 00 00 00       	mov    $0x11,%eax
f0103558:	ee                   	out    %al,(%dx)
f0103559:	ba 21 00 00 00       	mov    $0x21,%edx
f010355e:	b8 20 00 00 00       	mov    $0x20,%eax
f0103563:	ee                   	out    %al,(%dx)
f0103564:	b8 04 00 00 00       	mov    $0x4,%eax
f0103569:	ee                   	out    %al,(%dx)
f010356a:	b8 03 00 00 00       	mov    $0x3,%eax
f010356f:	ee                   	out    %al,(%dx)
f0103570:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103575:	b8 11 00 00 00       	mov    $0x11,%eax
f010357a:	ee                   	out    %al,(%dx)
f010357b:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103580:	b8 28 00 00 00       	mov    $0x28,%eax
f0103585:	ee                   	out    %al,(%dx)
f0103586:	b8 02 00 00 00       	mov    $0x2,%eax
f010358b:	ee                   	out    %al,(%dx)
f010358c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103591:	ee                   	out    %al,(%dx)
f0103592:	ba 20 00 00 00       	mov    $0x20,%edx
f0103597:	b8 68 00 00 00       	mov    $0x68,%eax
f010359c:	ee                   	out    %al,(%dx)
f010359d:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035a2:	ee                   	out    %al,(%dx)
f01035a3:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035a8:	b8 68 00 00 00       	mov    $0x68,%eax
f01035ad:	ee                   	out    %al,(%dx)
f01035ae:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035b3:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01035b4:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01035bb:	66 83 f8 ff          	cmp    $0xffff,%ax
f01035bf:	74 13                	je     f01035d4 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01035c1:	55                   	push   %ebp
f01035c2:	89 e5                	mov    %esp,%ebp
f01035c4:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01035c7:	0f b7 c0             	movzwl %ax,%eax
f01035ca:	50                   	push   %eax
f01035cb:	e8 ee fe ff ff       	call   f01034be <irq_setmask_8259A>
f01035d0:	83 c4 10             	add    $0x10,%esp
}
f01035d3:	c9                   	leave  
f01035d4:	f3 c3                	repz ret 

f01035d6 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f01035d6:	55                   	push   %ebp
f01035d7:	89 e5                	mov    %esp,%ebp
f01035d9:	ba 20 00 00 00       	mov    $0x20,%edx
f01035de:	b8 20 00 00 00       	mov    $0x20,%eax
f01035e3:	ee                   	out    %al,(%dx)
f01035e4:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035e9:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f01035ea:	5d                   	pop    %ebp
f01035eb:	c3                   	ret    

f01035ec <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01035ec:	55                   	push   %ebp
f01035ed:	89 e5                	mov    %esp,%ebp
f01035ef:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01035f2:	ff 75 08             	pushl  0x8(%ebp)
f01035f5:	e8 da d1 ff ff       	call   f01007d4 <cputchar>
	*cnt++;
}
f01035fa:	83 c4 10             	add    $0x10,%esp
f01035fd:	c9                   	leave  
f01035fe:	c3                   	ret    

f01035ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01035ff:	55                   	push   %ebp
f0103600:	89 e5                	mov    %esp,%ebp
f0103602:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103605:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010360c:	ff 75 0c             	pushl  0xc(%ebp)
f010360f:	ff 75 08             	pushl  0x8(%ebp)
f0103612:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103615:	50                   	push   %eax
f0103616:	68 ec 35 10 f0       	push   $0xf01035ec
f010361b:	e8 42 19 00 00       	call   f0104f62 <vprintfmt>
	return cnt;
}
f0103620:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103623:	c9                   	leave  
f0103624:	c3                   	ret    

f0103625 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103625:	55                   	push   %ebp
f0103626:	89 e5                	mov    %esp,%ebp
f0103628:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010362b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010362e:	50                   	push   %eax
f010362f:	ff 75 08             	pushl  0x8(%ebp)
f0103632:	e8 c8 ff ff ff       	call   f01035ff <vcprintf>
	va_end(ap);

	return cnt;
}
f0103637:	c9                   	leave  
f0103638:	c3                   	ret    

f0103639 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103639:	55                   	push   %ebp
f010363a:	89 e5                	mov    %esp,%ebp
f010363c:	57                   	push   %edi
f010363d:	56                   	push   %esi
f010363e:	53                   	push   %ebx
f010363f:	83 ec 1c             	sub    $0x1c,%esp
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	
	int i = thiscpu->cpu_id;
f0103642:	e8 df 25 00 00       	call   f0105c26 <cpunum>
f0103647:	6b c0 74             	imul   $0x74,%eax,%eax
f010364a:	0f b6 b0 20 00 2a f0 	movzbl -0xfd5ffe0(%eax),%esi
f0103651:	89 f0                	mov    %esi,%eax
f0103653:	0f b6 d8             	movzbl %al,%ebx
	
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103656:	e8 cb 25 00 00       	call   f0105c26 <cpunum>
f010365b:	6b c0 74             	imul   $0x74,%eax,%eax
f010365e:	89 d9                	mov    %ebx,%ecx
f0103660:	c1 e1 10             	shl    $0x10,%ecx
f0103663:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103668:	29 ca                	sub    %ecx,%edx
f010366a:	89 90 30 00 2a f0    	mov    %edx,-0xfd5ffd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103670:	e8 b1 25 00 00       	call   f0105c26 <cpunum>
f0103675:	6b c0 74             	imul   $0x74,%eax,%eax
f0103678:	66 c7 80 34 00 2a f0 	movw   $0x10,-0xfd5ffcc(%eax)
f010367f:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103681:	83 c3 05             	add    $0x5,%ebx
f0103684:	e8 9d 25 00 00       	call   f0105c26 <cpunum>
f0103689:	89 c7                	mov    %eax,%edi
f010368b:	e8 96 25 00 00       	call   f0105c26 <cpunum>
f0103690:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103693:	e8 8e 25 00 00       	call   f0105c26 <cpunum>
f0103698:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f010369f:	f0 67 00 
f01036a2:	6b ff 74             	imul   $0x74,%edi,%edi
f01036a5:	81 c7 2c 00 2a f0    	add    $0xf02a002c,%edi
f01036ab:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f01036b2:	f0 
f01036b3:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f01036b7:	81 c2 2c 00 2a f0    	add    $0xf02a002c,%edx
f01036bd:	c1 ea 10             	shr    $0x10,%edx
f01036c0:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f01036c7:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f01036ce:	40 
f01036cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d2:	05 2c 00 2a f0       	add    $0xf02a002c,%eax
f01036d7:	c1 e8 18             	shr    $0x18,%eax
f01036da:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f01036e1:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f01036e8:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01036e9:	89 f0                	mov    %esi,%eax
f01036eb:	0f b6 f0             	movzbl %al,%esi
f01036ee:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f01036f5:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01036f8:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f01036fd:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f0103700:	83 c4 1c             	add    $0x1c,%esp
f0103703:	5b                   	pop    %ebx
f0103704:	5e                   	pop    %esi
f0103705:	5f                   	pop    %edi
f0103706:	5d                   	pop    %ebp
f0103707:	c3                   	ret    

f0103708 <trap_init>:
}


void
trap_init(void)
{
f0103708:	55                   	push   %ebp
f0103709:	89 e5                	mov    %esp,%ebp
f010370b:	83 ec 08             	sub    $0x8,%esp
    void th45();
    void th46();
    void th47();
    void th48();
    
    SETGATE(idt[0], 0, GD_KT, th0, 0);
f010370e:	b8 e8 41 10 f0       	mov    $0xf01041e8,%eax
f0103713:	66 a3 60 f2 29 f0    	mov    %ax,0xf029f260
f0103719:	66 c7 05 62 f2 29 f0 	movw   $0x8,0xf029f262
f0103720:	08 00 
f0103722:	c6 05 64 f2 29 f0 00 	movb   $0x0,0xf029f264
f0103729:	c6 05 65 f2 29 f0 8e 	movb   $0x8e,0xf029f265
f0103730:	c1 e8 10             	shr    $0x10,%eax
f0103733:	66 a3 66 f2 29 f0    	mov    %ax,0xf029f266
    SETGATE(idt[1], 0, GD_KT, th1, 0);
f0103739:	b8 f2 41 10 f0       	mov    $0xf01041f2,%eax
f010373e:	66 a3 68 f2 29 f0    	mov    %ax,0xf029f268
f0103744:	66 c7 05 6a f2 29 f0 	movw   $0x8,0xf029f26a
f010374b:	08 00 
f010374d:	c6 05 6c f2 29 f0 00 	movb   $0x0,0xf029f26c
f0103754:	c6 05 6d f2 29 f0 8e 	movb   $0x8e,0xf029f26d
f010375b:	c1 e8 10             	shr    $0x10,%eax
f010375e:	66 a3 6e f2 29 f0    	mov    %ax,0xf029f26e
    SETGATE(idt[3], 0, GD_KT, th3, 3);
f0103764:	b8 fc 41 10 f0       	mov    $0xf01041fc,%eax
f0103769:	66 a3 78 f2 29 f0    	mov    %ax,0xf029f278
f010376f:	66 c7 05 7a f2 29 f0 	movw   $0x8,0xf029f27a
f0103776:	08 00 
f0103778:	c6 05 7c f2 29 f0 00 	movb   $0x0,0xf029f27c
f010377f:	c6 05 7d f2 29 f0 ee 	movb   $0xee,0xf029f27d
f0103786:	c1 e8 10             	shr    $0x10,%eax
f0103789:	66 a3 7e f2 29 f0    	mov    %ax,0xf029f27e
    SETGATE(idt[4], 0, GD_KT, th4, 0);
f010378f:	b8 06 42 10 f0       	mov    $0xf0104206,%eax
f0103794:	66 a3 80 f2 29 f0    	mov    %ax,0xf029f280
f010379a:	66 c7 05 82 f2 29 f0 	movw   $0x8,0xf029f282
f01037a1:	08 00 
f01037a3:	c6 05 84 f2 29 f0 00 	movb   $0x0,0xf029f284
f01037aa:	c6 05 85 f2 29 f0 8e 	movb   $0x8e,0xf029f285
f01037b1:	c1 e8 10             	shr    $0x10,%eax
f01037b4:	66 a3 86 f2 29 f0    	mov    %ax,0xf029f286
    SETGATE(idt[5], 0, GD_KT, th5, 0);
f01037ba:	b8 10 42 10 f0       	mov    $0xf0104210,%eax
f01037bf:	66 a3 88 f2 29 f0    	mov    %ax,0xf029f288
f01037c5:	66 c7 05 8a f2 29 f0 	movw   $0x8,0xf029f28a
f01037cc:	08 00 
f01037ce:	c6 05 8c f2 29 f0 00 	movb   $0x0,0xf029f28c
f01037d5:	c6 05 8d f2 29 f0 8e 	movb   $0x8e,0xf029f28d
f01037dc:	c1 e8 10             	shr    $0x10,%eax
f01037df:	66 a3 8e f2 29 f0    	mov    %ax,0xf029f28e
    SETGATE(idt[6], 0, GD_KT, th6, 0);
f01037e5:	b8 1a 42 10 f0       	mov    $0xf010421a,%eax
f01037ea:	66 a3 90 f2 29 f0    	mov    %ax,0xf029f290
f01037f0:	66 c7 05 92 f2 29 f0 	movw   $0x8,0xf029f292
f01037f7:	08 00 
f01037f9:	c6 05 94 f2 29 f0 00 	movb   $0x0,0xf029f294
f0103800:	c6 05 95 f2 29 f0 8e 	movb   $0x8e,0xf029f295
f0103807:	c1 e8 10             	shr    $0x10,%eax
f010380a:	66 a3 96 f2 29 f0    	mov    %ax,0xf029f296
    SETGATE(idt[7], 0, GD_KT, th7, 0);
f0103810:	b8 24 42 10 f0       	mov    $0xf0104224,%eax
f0103815:	66 a3 98 f2 29 f0    	mov    %ax,0xf029f298
f010381b:	66 c7 05 9a f2 29 f0 	movw   $0x8,0xf029f29a
f0103822:	08 00 
f0103824:	c6 05 9c f2 29 f0 00 	movb   $0x0,0xf029f29c
f010382b:	c6 05 9d f2 29 f0 8e 	movb   $0x8e,0xf029f29d
f0103832:	c1 e8 10             	shr    $0x10,%eax
f0103835:	66 a3 9e f2 29 f0    	mov    %ax,0xf029f29e
    SETGATE(idt[8], 0, GD_KT, th8, 0);
f010383b:	b8 2e 42 10 f0       	mov    $0xf010422e,%eax
f0103840:	66 a3 a0 f2 29 f0    	mov    %ax,0xf029f2a0
f0103846:	66 c7 05 a2 f2 29 f0 	movw   $0x8,0xf029f2a2
f010384d:	08 00 
f010384f:	c6 05 a4 f2 29 f0 00 	movb   $0x0,0xf029f2a4
f0103856:	c6 05 a5 f2 29 f0 8e 	movb   $0x8e,0xf029f2a5
f010385d:	c1 e8 10             	shr    $0x10,%eax
f0103860:	66 a3 a6 f2 29 f0    	mov    %ax,0xf029f2a6
    SETGATE(idt[9], 0, GD_KT, th9, 0);
f0103866:	b8 36 42 10 f0       	mov    $0xf0104236,%eax
f010386b:	66 a3 a8 f2 29 f0    	mov    %ax,0xf029f2a8
f0103871:	66 c7 05 aa f2 29 f0 	movw   $0x8,0xf029f2aa
f0103878:	08 00 
f010387a:	c6 05 ac f2 29 f0 00 	movb   $0x0,0xf029f2ac
f0103881:	c6 05 ad f2 29 f0 8e 	movb   $0x8e,0xf029f2ad
f0103888:	c1 e8 10             	shr    $0x10,%eax
f010388b:	66 a3 ae f2 29 f0    	mov    %ax,0xf029f2ae
    SETGATE(idt[10], 0, GD_KT, th10, 0);
f0103891:	b8 40 42 10 f0       	mov    $0xf0104240,%eax
f0103896:	66 a3 b0 f2 29 f0    	mov    %ax,0xf029f2b0
f010389c:	66 c7 05 b2 f2 29 f0 	movw   $0x8,0xf029f2b2
f01038a3:	08 00 
f01038a5:	c6 05 b4 f2 29 f0 00 	movb   $0x0,0xf029f2b4
f01038ac:	c6 05 b5 f2 29 f0 8e 	movb   $0x8e,0xf029f2b5
f01038b3:	c1 e8 10             	shr    $0x10,%eax
f01038b6:	66 a3 b6 f2 29 f0    	mov    %ax,0xf029f2b6
    SETGATE(idt[11], 0, GD_KT, th11, 0);
f01038bc:	b8 44 42 10 f0       	mov    $0xf0104244,%eax
f01038c1:	66 a3 b8 f2 29 f0    	mov    %ax,0xf029f2b8
f01038c7:	66 c7 05 ba f2 29 f0 	movw   $0x8,0xf029f2ba
f01038ce:	08 00 
f01038d0:	c6 05 bc f2 29 f0 00 	movb   $0x0,0xf029f2bc
f01038d7:	c6 05 bd f2 29 f0 8e 	movb   $0x8e,0xf029f2bd
f01038de:	c1 e8 10             	shr    $0x10,%eax
f01038e1:	66 a3 be f2 29 f0    	mov    %ax,0xf029f2be
    SETGATE(idt[12], 0, GD_KT, th12, 0);
f01038e7:	b8 48 42 10 f0       	mov    $0xf0104248,%eax
f01038ec:	66 a3 c0 f2 29 f0    	mov    %ax,0xf029f2c0
f01038f2:	66 c7 05 c2 f2 29 f0 	movw   $0x8,0xf029f2c2
f01038f9:	08 00 
f01038fb:	c6 05 c4 f2 29 f0 00 	movb   $0x0,0xf029f2c4
f0103902:	c6 05 c5 f2 29 f0 8e 	movb   $0x8e,0xf029f2c5
f0103909:	c1 e8 10             	shr    $0x10,%eax
f010390c:	66 a3 c6 f2 29 f0    	mov    %ax,0xf029f2c6
    SETGATE(idt[13], 0, GD_KT, th13, 0);
f0103912:	b8 4c 42 10 f0       	mov    $0xf010424c,%eax
f0103917:	66 a3 c8 f2 29 f0    	mov    %ax,0xf029f2c8
f010391d:	66 c7 05 ca f2 29 f0 	movw   $0x8,0xf029f2ca
f0103924:	08 00 
f0103926:	c6 05 cc f2 29 f0 00 	movb   $0x0,0xf029f2cc
f010392d:	c6 05 cd f2 29 f0 8e 	movb   $0x8e,0xf029f2cd
f0103934:	c1 e8 10             	shr    $0x10,%eax
f0103937:	66 a3 ce f2 29 f0    	mov    %ax,0xf029f2ce
    SETGATE(idt[14], 0, GD_KT, th14, 0);
f010393d:	b8 50 42 10 f0       	mov    $0xf0104250,%eax
f0103942:	66 a3 d0 f2 29 f0    	mov    %ax,0xf029f2d0
f0103948:	66 c7 05 d2 f2 29 f0 	movw   $0x8,0xf029f2d2
f010394f:	08 00 
f0103951:	c6 05 d4 f2 29 f0 00 	movb   $0x0,0xf029f2d4
f0103958:	c6 05 d5 f2 29 f0 8e 	movb   $0x8e,0xf029f2d5
f010395f:	c1 e8 10             	shr    $0x10,%eax
f0103962:	66 a3 d6 f2 29 f0    	mov    %ax,0xf029f2d6
    SETGATE(idt[16], 0, GD_KT, th16, 0);
f0103968:	b8 54 42 10 f0       	mov    $0xf0104254,%eax
f010396d:	66 a3 e0 f2 29 f0    	mov    %ax,0xf029f2e0
f0103973:	66 c7 05 e2 f2 29 f0 	movw   $0x8,0xf029f2e2
f010397a:	08 00 
f010397c:	c6 05 e4 f2 29 f0 00 	movb   $0x0,0xf029f2e4
f0103983:	c6 05 e5 f2 29 f0 8e 	movb   $0x8e,0xf029f2e5
f010398a:	c1 e8 10             	shr    $0x10,%eax
f010398d:	66 a3 e6 f2 29 f0    	mov    %ax,0xf029f2e6
    SETGATE(idt[32], 0, GD_KT, th32, 0);
f0103993:	b8 5a 42 10 f0       	mov    $0xf010425a,%eax
f0103998:	66 a3 60 f3 29 f0    	mov    %ax,0xf029f360
f010399e:	66 c7 05 62 f3 29 f0 	movw   $0x8,0xf029f362
f01039a5:	08 00 
f01039a7:	c6 05 64 f3 29 f0 00 	movb   $0x0,0xf029f364
f01039ae:	c6 05 65 f3 29 f0 8e 	movb   $0x8e,0xf029f365
f01039b5:	c1 e8 10             	shr    $0x10,%eax
f01039b8:	66 a3 66 f3 29 f0    	mov    %ax,0xf029f366
    SETGATE(idt[33], 0, GD_KT, th33, 0);
f01039be:	b8 60 42 10 f0       	mov    $0xf0104260,%eax
f01039c3:	66 a3 68 f3 29 f0    	mov    %ax,0xf029f368
f01039c9:	66 c7 05 6a f3 29 f0 	movw   $0x8,0xf029f36a
f01039d0:	08 00 
f01039d2:	c6 05 6c f3 29 f0 00 	movb   $0x0,0xf029f36c
f01039d9:	c6 05 6d f3 29 f0 8e 	movb   $0x8e,0xf029f36d
f01039e0:	c1 e8 10             	shr    $0x10,%eax
f01039e3:	66 a3 6e f3 29 f0    	mov    %ax,0xf029f36e
    SETGATE(idt[34], 0, GD_KT, th34, 0);
f01039e9:	b8 66 42 10 f0       	mov    $0xf0104266,%eax
f01039ee:	66 a3 70 f3 29 f0    	mov    %ax,0xf029f370
f01039f4:	66 c7 05 72 f3 29 f0 	movw   $0x8,0xf029f372
f01039fb:	08 00 
f01039fd:	c6 05 74 f3 29 f0 00 	movb   $0x0,0xf029f374
f0103a04:	c6 05 75 f3 29 f0 8e 	movb   $0x8e,0xf029f375
f0103a0b:	c1 e8 10             	shr    $0x10,%eax
f0103a0e:	66 a3 76 f3 29 f0    	mov    %ax,0xf029f376
    SETGATE(idt[35], 0, GD_KT, th35, 0);
f0103a14:	b8 6c 42 10 f0       	mov    $0xf010426c,%eax
f0103a19:	66 a3 78 f3 29 f0    	mov    %ax,0xf029f378
f0103a1f:	66 c7 05 7a f3 29 f0 	movw   $0x8,0xf029f37a
f0103a26:	08 00 
f0103a28:	c6 05 7c f3 29 f0 00 	movb   $0x0,0xf029f37c
f0103a2f:	c6 05 7d f3 29 f0 8e 	movb   $0x8e,0xf029f37d
f0103a36:	c1 e8 10             	shr    $0x10,%eax
f0103a39:	66 a3 7e f3 29 f0    	mov    %ax,0xf029f37e
    SETGATE(idt[36], 0, GD_KT, th36, 0);
f0103a3f:	b8 72 42 10 f0       	mov    $0xf0104272,%eax
f0103a44:	66 a3 80 f3 29 f0    	mov    %ax,0xf029f380
f0103a4a:	66 c7 05 82 f3 29 f0 	movw   $0x8,0xf029f382
f0103a51:	08 00 
f0103a53:	c6 05 84 f3 29 f0 00 	movb   $0x0,0xf029f384
f0103a5a:	c6 05 85 f3 29 f0 8e 	movb   $0x8e,0xf029f385
f0103a61:	c1 e8 10             	shr    $0x10,%eax
f0103a64:	66 a3 86 f3 29 f0    	mov    %ax,0xf029f386
    SETGATE(idt[37], 0, GD_KT, th37, 0);
f0103a6a:	b8 78 42 10 f0       	mov    $0xf0104278,%eax
f0103a6f:	66 a3 88 f3 29 f0    	mov    %ax,0xf029f388
f0103a75:	66 c7 05 8a f3 29 f0 	movw   $0x8,0xf029f38a
f0103a7c:	08 00 
f0103a7e:	c6 05 8c f3 29 f0 00 	movb   $0x0,0xf029f38c
f0103a85:	c6 05 8d f3 29 f0 8e 	movb   $0x8e,0xf029f38d
f0103a8c:	c1 e8 10             	shr    $0x10,%eax
f0103a8f:	66 a3 8e f3 29 f0    	mov    %ax,0xf029f38e
    SETGATE(idt[38], 0, GD_KT, th38, 0);
f0103a95:	b8 7e 42 10 f0       	mov    $0xf010427e,%eax
f0103a9a:	66 a3 90 f3 29 f0    	mov    %ax,0xf029f390
f0103aa0:	66 c7 05 92 f3 29 f0 	movw   $0x8,0xf029f392
f0103aa7:	08 00 
f0103aa9:	c6 05 94 f3 29 f0 00 	movb   $0x0,0xf029f394
f0103ab0:	c6 05 95 f3 29 f0 8e 	movb   $0x8e,0xf029f395
f0103ab7:	c1 e8 10             	shr    $0x10,%eax
f0103aba:	66 a3 96 f3 29 f0    	mov    %ax,0xf029f396
    SETGATE(idt[39], 0, GD_KT, th39, 0);
f0103ac0:	b8 84 42 10 f0       	mov    $0xf0104284,%eax
f0103ac5:	66 a3 98 f3 29 f0    	mov    %ax,0xf029f398
f0103acb:	66 c7 05 9a f3 29 f0 	movw   $0x8,0xf029f39a
f0103ad2:	08 00 
f0103ad4:	c6 05 9c f3 29 f0 00 	movb   $0x0,0xf029f39c
f0103adb:	c6 05 9d f3 29 f0 8e 	movb   $0x8e,0xf029f39d
f0103ae2:	c1 e8 10             	shr    $0x10,%eax
f0103ae5:	66 a3 9e f3 29 f0    	mov    %ax,0xf029f39e
    SETGATE(idt[40], 0, GD_KT, th40, 0);
f0103aeb:	b8 8a 42 10 f0       	mov    $0xf010428a,%eax
f0103af0:	66 a3 a0 f3 29 f0    	mov    %ax,0xf029f3a0
f0103af6:	66 c7 05 a2 f3 29 f0 	movw   $0x8,0xf029f3a2
f0103afd:	08 00 
f0103aff:	c6 05 a4 f3 29 f0 00 	movb   $0x0,0xf029f3a4
f0103b06:	c6 05 a5 f3 29 f0 8e 	movb   $0x8e,0xf029f3a5
f0103b0d:	c1 e8 10             	shr    $0x10,%eax
f0103b10:	66 a3 a6 f3 29 f0    	mov    %ax,0xf029f3a6
    SETGATE(idt[41], 0, GD_KT, th41, 0);
f0103b16:	b8 90 42 10 f0       	mov    $0xf0104290,%eax
f0103b1b:	66 a3 a8 f3 29 f0    	mov    %ax,0xf029f3a8
f0103b21:	66 c7 05 aa f3 29 f0 	movw   $0x8,0xf029f3aa
f0103b28:	08 00 
f0103b2a:	c6 05 ac f3 29 f0 00 	movb   $0x0,0xf029f3ac
f0103b31:	c6 05 ad f3 29 f0 8e 	movb   $0x8e,0xf029f3ad
f0103b38:	c1 e8 10             	shr    $0x10,%eax
f0103b3b:	66 a3 ae f3 29 f0    	mov    %ax,0xf029f3ae
    SETGATE(idt[42], 0, GD_KT, th42, 0);
f0103b41:	b8 96 42 10 f0       	mov    $0xf0104296,%eax
f0103b46:	66 a3 b0 f3 29 f0    	mov    %ax,0xf029f3b0
f0103b4c:	66 c7 05 b2 f3 29 f0 	movw   $0x8,0xf029f3b2
f0103b53:	08 00 
f0103b55:	c6 05 b4 f3 29 f0 00 	movb   $0x0,0xf029f3b4
f0103b5c:	c6 05 b5 f3 29 f0 8e 	movb   $0x8e,0xf029f3b5
f0103b63:	c1 e8 10             	shr    $0x10,%eax
f0103b66:	66 a3 b6 f3 29 f0    	mov    %ax,0xf029f3b6
    SETGATE(idt[43], 0, GD_KT, th43, 0);
f0103b6c:	b8 9c 42 10 f0       	mov    $0xf010429c,%eax
f0103b71:	66 a3 b8 f3 29 f0    	mov    %ax,0xf029f3b8
f0103b77:	66 c7 05 ba f3 29 f0 	movw   $0x8,0xf029f3ba
f0103b7e:	08 00 
f0103b80:	c6 05 bc f3 29 f0 00 	movb   $0x0,0xf029f3bc
f0103b87:	c6 05 bd f3 29 f0 8e 	movb   $0x8e,0xf029f3bd
f0103b8e:	c1 e8 10             	shr    $0x10,%eax
f0103b91:	66 a3 be f3 29 f0    	mov    %ax,0xf029f3be
    SETGATE(idt[44], 0, GD_KT, th44, 0);
f0103b97:	b8 a2 42 10 f0       	mov    $0xf01042a2,%eax
f0103b9c:	66 a3 c0 f3 29 f0    	mov    %ax,0xf029f3c0
f0103ba2:	66 c7 05 c2 f3 29 f0 	movw   $0x8,0xf029f3c2
f0103ba9:	08 00 
f0103bab:	c6 05 c4 f3 29 f0 00 	movb   $0x0,0xf029f3c4
f0103bb2:	c6 05 c5 f3 29 f0 8e 	movb   $0x8e,0xf029f3c5
f0103bb9:	c1 e8 10             	shr    $0x10,%eax
f0103bbc:	66 a3 c6 f3 29 f0    	mov    %ax,0xf029f3c6
    SETGATE(idt[45], 0, GD_KT, th45, 0);
f0103bc2:	b8 a8 42 10 f0       	mov    $0xf01042a8,%eax
f0103bc7:	66 a3 c8 f3 29 f0    	mov    %ax,0xf029f3c8
f0103bcd:	66 c7 05 ca f3 29 f0 	movw   $0x8,0xf029f3ca
f0103bd4:	08 00 
f0103bd6:	c6 05 cc f3 29 f0 00 	movb   $0x0,0xf029f3cc
f0103bdd:	c6 05 cd f3 29 f0 8e 	movb   $0x8e,0xf029f3cd
f0103be4:	c1 e8 10             	shr    $0x10,%eax
f0103be7:	66 a3 ce f3 29 f0    	mov    %ax,0xf029f3ce
    SETGATE(idt[46], 0, GD_KT, th46, 0);
f0103bed:	b8 ae 42 10 f0       	mov    $0xf01042ae,%eax
f0103bf2:	66 a3 d0 f3 29 f0    	mov    %ax,0xf029f3d0
f0103bf8:	66 c7 05 d2 f3 29 f0 	movw   $0x8,0xf029f3d2
f0103bff:	08 00 
f0103c01:	c6 05 d4 f3 29 f0 00 	movb   $0x0,0xf029f3d4
f0103c08:	c6 05 d5 f3 29 f0 8e 	movb   $0x8e,0xf029f3d5
f0103c0f:	c1 e8 10             	shr    $0x10,%eax
f0103c12:	66 a3 d6 f3 29 f0    	mov    %ax,0xf029f3d6
    SETGATE(idt[47], 0, GD_KT, th47, 0);
f0103c18:	b8 b4 42 10 f0       	mov    $0xf01042b4,%eax
f0103c1d:	66 a3 d8 f3 29 f0    	mov    %ax,0xf029f3d8
f0103c23:	66 c7 05 da f3 29 f0 	movw   $0x8,0xf029f3da
f0103c2a:	08 00 
f0103c2c:	c6 05 dc f3 29 f0 00 	movb   $0x0,0xf029f3dc
f0103c33:	c6 05 dd f3 29 f0 8e 	movb   $0x8e,0xf029f3dd
f0103c3a:	c1 e8 10             	shr    $0x10,%eax
f0103c3d:	66 a3 de f3 29 f0    	mov    %ax,0xf029f3de
    SETGATE(idt[48], 0, GD_KT, th48, 3);
f0103c43:	b8 ba 42 10 f0       	mov    $0xf01042ba,%eax
f0103c48:	66 a3 e0 f3 29 f0    	mov    %ax,0xf029f3e0
f0103c4e:	66 c7 05 e2 f3 29 f0 	movw   $0x8,0xf029f3e2
f0103c55:	08 00 
f0103c57:	c6 05 e4 f3 29 f0 00 	movb   $0x0,0xf029f3e4
f0103c5e:	c6 05 e5 f3 29 f0 ee 	movb   $0xee,0xf029f3e5
f0103c65:	c1 e8 10             	shr    $0x10,%eax
f0103c68:	66 a3 e6 f3 29 f0    	mov    %ax,0xf029f3e6
    

	
	// Per-CPU setup 
	trap_init_percpu();
f0103c6e:	e8 c6 f9 ff ff       	call   f0103639 <trap_init_percpu>
}
f0103c73:	c9                   	leave  
f0103c74:	c3                   	ret    

f0103c75 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c75:	55                   	push   %ebp
f0103c76:	89 e5                	mov    %esp,%ebp
f0103c78:	53                   	push   %ebx
f0103c79:	83 ec 0c             	sub    $0xc,%esp
f0103c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c7f:	ff 33                	pushl  (%ebx)
f0103c81:	68 b9 7a 10 f0       	push   $0xf0107ab9
f0103c86:	e8 9a f9 ff ff       	call   f0103625 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c8b:	83 c4 08             	add    $0x8,%esp
f0103c8e:	ff 73 04             	pushl  0x4(%ebx)
f0103c91:	68 c8 7a 10 f0       	push   $0xf0107ac8
f0103c96:	e8 8a f9 ff ff       	call   f0103625 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103c9b:	83 c4 08             	add    $0x8,%esp
f0103c9e:	ff 73 08             	pushl  0x8(%ebx)
f0103ca1:	68 d7 7a 10 f0       	push   $0xf0107ad7
f0103ca6:	e8 7a f9 ff ff       	call   f0103625 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cab:	83 c4 08             	add    $0x8,%esp
f0103cae:	ff 73 0c             	pushl  0xc(%ebx)
f0103cb1:	68 e6 7a 10 f0       	push   $0xf0107ae6
f0103cb6:	e8 6a f9 ff ff       	call   f0103625 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103cbb:	83 c4 08             	add    $0x8,%esp
f0103cbe:	ff 73 10             	pushl  0x10(%ebx)
f0103cc1:	68 f5 7a 10 f0       	push   $0xf0107af5
f0103cc6:	e8 5a f9 ff ff       	call   f0103625 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103ccb:	83 c4 08             	add    $0x8,%esp
f0103cce:	ff 73 14             	pushl  0x14(%ebx)
f0103cd1:	68 04 7b 10 f0       	push   $0xf0107b04
f0103cd6:	e8 4a f9 ff ff       	call   f0103625 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103cdb:	83 c4 08             	add    $0x8,%esp
f0103cde:	ff 73 18             	pushl  0x18(%ebx)
f0103ce1:	68 13 7b 10 f0       	push   $0xf0107b13
f0103ce6:	e8 3a f9 ff ff       	call   f0103625 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103ceb:	83 c4 08             	add    $0x8,%esp
f0103cee:	ff 73 1c             	pushl  0x1c(%ebx)
f0103cf1:	68 22 7b 10 f0       	push   $0xf0107b22
f0103cf6:	e8 2a f9 ff ff       	call   f0103625 <cprintf>
}
f0103cfb:	83 c4 10             	add    $0x10,%esp
f0103cfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d01:	c9                   	leave  
f0103d02:	c3                   	ret    

f0103d03 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d03:	55                   	push   %ebp
f0103d04:	89 e5                	mov    %esp,%ebp
f0103d06:	56                   	push   %esi
f0103d07:	53                   	push   %ebx
f0103d08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d0b:	e8 16 1f 00 00       	call   f0105c26 <cpunum>
f0103d10:	83 ec 04             	sub    $0x4,%esp
f0103d13:	50                   	push   %eax
f0103d14:	53                   	push   %ebx
f0103d15:	68 86 7b 10 f0       	push   $0xf0107b86
f0103d1a:	e8 06 f9 ff ff       	call   f0103625 <cprintf>
	print_regs(&tf->tf_regs);
f0103d1f:	89 1c 24             	mov    %ebx,(%esp)
f0103d22:	e8 4e ff ff ff       	call   f0103c75 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d27:	83 c4 08             	add    $0x8,%esp
f0103d2a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d2e:	50                   	push   %eax
f0103d2f:	68 a4 7b 10 f0       	push   $0xf0107ba4
f0103d34:	e8 ec f8 ff ff       	call   f0103625 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d39:	83 c4 08             	add    $0x8,%esp
f0103d3c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d40:	50                   	push   %eax
f0103d41:	68 b7 7b 10 f0       	push   $0xf0107bb7
f0103d46:	e8 da f8 ff ff       	call   f0103625 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d4b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103d4e:	83 c4 10             	add    $0x10,%esp
f0103d51:	83 f8 13             	cmp    $0x13,%eax
f0103d54:	77 09                	ja     f0103d5f <print_trapframe+0x5c>
		return excnames[trapno];
f0103d56:	8b 14 85 40 7e 10 f0 	mov    -0xfef81c0(,%eax,4),%edx
f0103d5d:	eb 1f                	jmp    f0103d7e <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103d5f:	83 f8 30             	cmp    $0x30,%eax
f0103d62:	74 15                	je     f0103d79 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103d64:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103d67:	83 fa 10             	cmp    $0x10,%edx
f0103d6a:	b9 50 7b 10 f0       	mov    $0xf0107b50,%ecx
f0103d6f:	ba 3d 7b 10 f0       	mov    $0xf0107b3d,%edx
f0103d74:	0f 43 d1             	cmovae %ecx,%edx
f0103d77:	eb 05                	jmp    f0103d7e <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103d79:	ba 31 7b 10 f0       	mov    $0xf0107b31,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d7e:	83 ec 04             	sub    $0x4,%esp
f0103d81:	52                   	push   %edx
f0103d82:	50                   	push   %eax
f0103d83:	68 ca 7b 10 f0       	push   $0xf0107bca
f0103d88:	e8 98 f8 ff ff       	call   f0103625 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d8d:	83 c4 10             	add    $0x10,%esp
f0103d90:	3b 1d 60 fa 29 f0    	cmp    0xf029fa60,%ebx
f0103d96:	75 1a                	jne    f0103db2 <print_trapframe+0xaf>
f0103d98:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103d9c:	75 14                	jne    f0103db2 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103d9e:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103da1:	83 ec 08             	sub    $0x8,%esp
f0103da4:	50                   	push   %eax
f0103da5:	68 dc 7b 10 f0       	push   $0xf0107bdc
f0103daa:	e8 76 f8 ff ff       	call   f0103625 <cprintf>
f0103daf:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103db2:	83 ec 08             	sub    $0x8,%esp
f0103db5:	ff 73 2c             	pushl  0x2c(%ebx)
f0103db8:	68 eb 7b 10 f0       	push   $0xf0107beb
f0103dbd:	e8 63 f8 ff ff       	call   f0103625 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103dc2:	83 c4 10             	add    $0x10,%esp
f0103dc5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103dc9:	75 49                	jne    f0103e14 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103dcb:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103dce:	89 c2                	mov    %eax,%edx
f0103dd0:	83 e2 01             	and    $0x1,%edx
f0103dd3:	ba 6a 7b 10 f0       	mov    $0xf0107b6a,%edx
f0103dd8:	b9 5f 7b 10 f0       	mov    $0xf0107b5f,%ecx
f0103ddd:	0f 44 ca             	cmove  %edx,%ecx
f0103de0:	89 c2                	mov    %eax,%edx
f0103de2:	83 e2 02             	and    $0x2,%edx
f0103de5:	ba 7c 7b 10 f0       	mov    $0xf0107b7c,%edx
f0103dea:	be 76 7b 10 f0       	mov    $0xf0107b76,%esi
f0103def:	0f 45 d6             	cmovne %esi,%edx
f0103df2:	83 e0 04             	and    $0x4,%eax
f0103df5:	be c9 7c 10 f0       	mov    $0xf0107cc9,%esi
f0103dfa:	b8 81 7b 10 f0       	mov    $0xf0107b81,%eax
f0103dff:	0f 44 c6             	cmove  %esi,%eax
f0103e02:	51                   	push   %ecx
f0103e03:	52                   	push   %edx
f0103e04:	50                   	push   %eax
f0103e05:	68 f9 7b 10 f0       	push   $0xf0107bf9
f0103e0a:	e8 16 f8 ff ff       	call   f0103625 <cprintf>
f0103e0f:	83 c4 10             	add    $0x10,%esp
f0103e12:	eb 10                	jmp    f0103e24 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e14:	83 ec 0c             	sub    $0xc,%esp
f0103e17:	68 1b 7a 10 f0       	push   $0xf0107a1b
f0103e1c:	e8 04 f8 ff ff       	call   f0103625 <cprintf>
f0103e21:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e24:	83 ec 08             	sub    $0x8,%esp
f0103e27:	ff 73 30             	pushl  0x30(%ebx)
f0103e2a:	68 08 7c 10 f0       	push   $0xf0107c08
f0103e2f:	e8 f1 f7 ff ff       	call   f0103625 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e34:	83 c4 08             	add    $0x8,%esp
f0103e37:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e3b:	50                   	push   %eax
f0103e3c:	68 17 7c 10 f0       	push   $0xf0107c17
f0103e41:	e8 df f7 ff ff       	call   f0103625 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e46:	83 c4 08             	add    $0x8,%esp
f0103e49:	ff 73 38             	pushl  0x38(%ebx)
f0103e4c:	68 2a 7c 10 f0       	push   $0xf0107c2a
f0103e51:	e8 cf f7 ff ff       	call   f0103625 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e56:	83 c4 10             	add    $0x10,%esp
f0103e59:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e5d:	74 25                	je     f0103e84 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e5f:	83 ec 08             	sub    $0x8,%esp
f0103e62:	ff 73 3c             	pushl  0x3c(%ebx)
f0103e65:	68 39 7c 10 f0       	push   $0xf0107c39
f0103e6a:	e8 b6 f7 ff ff       	call   f0103625 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e6f:	83 c4 08             	add    $0x8,%esp
f0103e72:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e76:	50                   	push   %eax
f0103e77:	68 48 7c 10 f0       	push   $0xf0107c48
f0103e7c:	e8 a4 f7 ff ff       	call   f0103625 <cprintf>
f0103e81:	83 c4 10             	add    $0x10,%esp
	}
}
f0103e84:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e87:	5b                   	pop    %ebx
f0103e88:	5e                   	pop    %esi
f0103e89:	5d                   	pop    %ebp
f0103e8a:	c3                   	ret    

f0103e8b <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e8b:	55                   	push   %ebp
f0103e8c:	89 e5                	mov    %esp,%ebp
f0103e8e:	57                   	push   %edi
f0103e8f:	56                   	push   %esi
f0103e90:	53                   	push   %ebx
f0103e91:	83 ec 0c             	sub    $0xc,%esp
f0103e94:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103e97:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	
	if ((tf->tf_cs&3) == 0)
f0103e9a:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e9e:	75 17                	jne    f0103eb7 <page_fault_handler+0x2c>
        	panic("Kernel page fault!");
f0103ea0:	83 ec 04             	sub    $0x4,%esp
f0103ea3:	68 5b 7c 10 f0       	push   $0xf0107c5b
f0103ea8:	68 98 01 00 00       	push   $0x198
f0103ead:	68 6e 7c 10 f0       	push   $0xf0107c6e
f0103eb2:	e8 89 c1 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	
	if(curenv->env_pgfault_upcall){
f0103eb7:	e8 6a 1d 00 00       	call   f0105c26 <cpunum>
f0103ebc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ebf:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103ec5:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103ec9:	0f 84 a7 00 00 00    	je     f0103f76 <page_fault_handler+0xeb>
		uintptr_t newstacktop;
		struct UTrapframe *utf;
		if((tf->tf_esp < UXSTACKTOP) && (tf->tf_esp >= (UXSTACKTOP-PGSIZE)))
f0103ecf:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103ed2:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			newstacktop = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0103ed8:	83 e8 38             	sub    $0x38,%eax
f0103edb:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103ee1:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103ee6:	0f 46 d0             	cmovbe %eax,%edx
f0103ee9:	89 d7                	mov    %edx,%edi
		else //if(tf->tf_esp < USTACKTOP)
			newstacktop = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void *)newstacktop, 1, PTE_W);
f0103eeb:	e8 36 1d 00 00       	call   f0105c26 <cpunum>
f0103ef0:	6a 02                	push   $0x2
f0103ef2:	6a 01                	push   $0x1
f0103ef4:	57                   	push   %edi
f0103ef5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ef8:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103efe:	e8 7f ee ff ff       	call   f0102d82 <user_mem_assert>
		utf = (struct UTrapframe *)newstacktop;
		utf->utf_fault_va = fault_va;
f0103f03:	89 fa                	mov    %edi,%edx
f0103f05:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0103f07:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103f0a:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0103f0d:	8d 7f 08             	lea    0x8(%edi),%edi
f0103f10:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103f15:	89 de                	mov    %ebx,%esi
f0103f17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0103f19:	8b 43 30             	mov    0x30(%ebx),%eax
f0103f1c:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0103f1f:	8b 43 38             	mov    0x38(%ebx),%eax
f0103f22:	89 d7                	mov    %edx,%edi
f0103f24:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0103f27:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103f2a:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_esp = newstacktop;
f0103f2d:	e8 f4 1c 00 00       	call   f0105c26 <cpunum>
f0103f32:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f35:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103f3b:	89 78 3c             	mov    %edi,0x3c(%eax)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0103f3e:	e8 e3 1c 00 00       	call   f0105c26 <cpunum>
f0103f43:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f46:	8b 98 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%ebx
f0103f4c:	e8 d5 1c 00 00       	call   f0105c26 <cpunum>
f0103f51:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f54:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103f5a:	8b 40 64             	mov    0x64(%eax),%eax
f0103f5d:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f0103f60:	e8 c1 1c 00 00       	call   f0105c26 <cpunum>
f0103f65:	83 c4 04             	add    $0x4,%esp
f0103f68:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f6b:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103f71:	e8 7f f4 ff ff       	call   f01033f5 <env_run>
	}
		
	// Destroy the environment that caused the fault.
	else{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f76:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0103f79:	e8 a8 1c 00 00       	call   f0105c26 <cpunum>
		env_run(curenv);
	}
		
	// Destroy the environment that caused the fault.
	else{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f7e:	57                   	push   %edi
f0103f7f:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0103f80:	6b c0 74             	imul   $0x74,%eax,%eax
		env_run(curenv);
	}
		
	// Destroy the environment that caused the fault.
	else{
		cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f83:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103f89:	ff 70 48             	pushl  0x48(%eax)
f0103f8c:	68 14 7e 10 f0       	push   $0xf0107e14
f0103f91:	e8 8f f6 ff ff       	call   f0103625 <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
f0103f96:	89 1c 24             	mov    %ebx,(%esp)
f0103f99:	e8 65 fd ff ff       	call   f0103d03 <print_trapframe>
		env_destroy(curenv);
f0103f9e:	e8 83 1c 00 00       	call   f0105c26 <cpunum>
f0103fa3:	83 c4 04             	add    $0x4,%esp
f0103fa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa9:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103faf:	e8 a2 f3 ff ff       	call   f0103356 <env_destroy>
	}
}
f0103fb4:	83 c4 10             	add    $0x10,%esp
f0103fb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103fba:	5b                   	pop    %ebx
f0103fbb:	5e                   	pop    %esi
f0103fbc:	5f                   	pop    %edi
f0103fbd:	5d                   	pop    %ebp
f0103fbe:	c3                   	ret    

f0103fbf <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103fbf:	55                   	push   %ebp
f0103fc0:	89 e5                	mov    %esp,%ebp
f0103fc2:	57                   	push   %edi
f0103fc3:	56                   	push   %esi
f0103fc4:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103fc7:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103fc8:	83 3d 98 fe 29 f0 00 	cmpl   $0x0,0xf029fe98
f0103fcf:	74 01                	je     f0103fd2 <trap+0x13>
		asm volatile("hlt");
f0103fd1:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103fd2:	e8 4f 1c 00 00       	call   f0105c26 <cpunum>
f0103fd7:	6b d0 74             	imul   $0x74,%eax,%edx
f0103fda:	81 c2 20 00 2a f0    	add    $0xf02a0020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103fe0:	b8 01 00 00 00       	mov    $0x1,%eax
f0103fe5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103fe9:	83 f8 02             	cmp    $0x2,%eax
f0103fec:	75 10                	jne    f0103ffe <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103fee:	83 ec 0c             	sub    $0xc,%esp
f0103ff1:	68 c0 23 12 f0       	push   $0xf01223c0
f0103ff6:	e8 99 1e 00 00       	call   f0105e94 <spin_lock>
f0103ffb:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103ffe:	9c                   	pushf  
f0103fff:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104000:	f6 c4 02             	test   $0x2,%ah
f0104003:	74 19                	je     f010401e <trap+0x5f>
f0104005:	68 7a 7c 10 f0       	push   $0xf0107c7a
f010400a:	68 3b 77 10 f0       	push   $0xf010773b
f010400f:	68 5b 01 00 00       	push   $0x15b
f0104014:	68 6e 7c 10 f0       	push   $0xf0107c6e
f0104019:	e8 22 c0 ff ff       	call   f0100040 <_panic>
//<<<<<<< HEAD
//=======
	//cprintf("Incoming TRAP frame at %p\n", tf);
	
//>>>>>>> lab3
	if ((tf->tf_cs & 3) == 3) {
f010401e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104022:	83 e0 03             	and    $0x3,%eax
f0104025:	66 83 f8 03          	cmp    $0x3,%ax
f0104029:	0f 85 a0 00 00 00    	jne    f01040cf <trap+0x110>
f010402f:	83 ec 0c             	sub    $0xc,%esp
f0104032:	68 c0 23 12 f0       	push   $0xf01223c0
f0104037:	e8 58 1e 00 00       	call   f0105e94 <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		
		assert(curenv);
f010403c:	e8 e5 1b 00 00       	call   f0105c26 <cpunum>
f0104041:	6b c0 74             	imul   $0x74,%eax,%eax
f0104044:	83 c4 10             	add    $0x10,%esp
f0104047:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f010404e:	75 19                	jne    f0104069 <trap+0xaa>
f0104050:	68 93 7c 10 f0       	push   $0xf0107c93
f0104055:	68 3b 77 10 f0       	push   $0xf010773b
f010405a:	68 69 01 00 00       	push   $0x169
f010405f:	68 6e 7c 10 f0       	push   $0xf0107c6e
f0104064:	e8 d7 bf ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104069:	e8 b8 1b 00 00       	call   f0105c26 <cpunum>
f010406e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104071:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0104077:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010407b:	75 2d                	jne    f01040aa <trap+0xeb>
			env_free(curenv);
f010407d:	e8 a4 1b 00 00       	call   f0105c26 <cpunum>
f0104082:	83 ec 0c             	sub    $0xc,%esp
f0104085:	6b c0 74             	imul   $0x74,%eax,%eax
f0104088:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f010408e:	e8 1d f1 ff ff       	call   f01031b0 <env_free>
			curenv = NULL;
f0104093:	e8 8e 1b 00 00       	call   f0105c26 <cpunum>
f0104098:	6b c0 74             	imul   $0x74,%eax,%eax
f010409b:	c7 80 28 00 2a f0 00 	movl   $0x0,-0xfd5ffd8(%eax)
f01040a2:	00 00 00 
			sched_yield();
f01040a5:	e8 f9 02 00 00       	call   f01043a3 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01040aa:	e8 77 1b 00 00       	call   f0105c26 <cpunum>
f01040af:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b2:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01040b8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01040bd:	89 c7                	mov    %eax,%edi
f01040bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01040c1:	e8 60 1b 00 00       	call   f0105c26 <cpunum>
f01040c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c9:	8b b0 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01040cf:	89 35 60 fa 29 f0    	mov    %esi,0xf029fa60
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01040d5:	8b 46 28             	mov    0x28(%esi),%eax
f01040d8:	83 f8 27             	cmp    $0x27,%eax
f01040db:	75 1d                	jne    f01040fa <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f01040dd:	83 ec 0c             	sub    $0xc,%esp
f01040e0:	68 9a 7c 10 f0       	push   $0xf0107c9a
f01040e5:	e8 3b f5 ff ff       	call   f0103625 <cprintf>
		print_trapframe(tf);
f01040ea:	89 34 24             	mov    %esi,(%esp)
f01040ed:	e8 11 fc ff ff       	call   f0103d03 <print_trapframe>
f01040f2:	83 c4 10             	add    $0x10,%esp
f01040f5:	e9 ad 00 00 00       	jmp    f01041a7 <trap+0x1e8>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

//=======
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f01040fa:	83 f8 20             	cmp    $0x20,%eax
f01040fd:	75 0a                	jne    f0104109 <trap+0x14a>
		lapic_eoi();
f01040ff:	e8 6d 1c 00 00       	call   f0105d71 <lapic_eoi>
		sched_yield();
f0104104:	e8 9a 02 00 00       	call   f01043a3 <sched_yield>
	}
//=======
	if(tf->tf_trapno == T_PGFLT){
f0104109:	83 f8 0e             	cmp    $0xe,%eax
f010410c:	75 11                	jne    f010411f <trap+0x160>
		//cprintf("PAGE FAULT\n");
		page_fault_handler(tf);
f010410e:	83 ec 0c             	sub    $0xc,%esp
f0104111:	56                   	push   %esi
f0104112:	e8 74 fd ff ff       	call   f0103e8b <page_fault_handler>
f0104117:	83 c4 10             	add    $0x10,%esp
f010411a:	e9 88 00 00 00       	jmp    f01041a7 <trap+0x1e8>
		return;
	}
	
	if(tf->tf_trapno == T_BRKPT){
f010411f:	83 f8 03             	cmp    $0x3,%eax
f0104122:	75 0e                	jne    f0104132 <trap+0x173>
		//cprintf("BREAK POINT\n");
		monitor(tf);
f0104124:	83 ec 0c             	sub    $0xc,%esp
f0104127:	56                   	push   %esi
f0104128:	e8 4b c8 ff ff       	call   f0100978 <monitor>
f010412d:	83 c4 10             	add    $0x10,%esp
f0104130:	eb 75                	jmp    f01041a7 <trap+0x1e8>
		return;
	}
	
	if(tf->tf_trapno == T_SYSCALL){
f0104132:	83 f8 30             	cmp    $0x30,%eax
f0104135:	75 21                	jne    f0104158 <trap+0x199>
		//cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax,
f0104137:	83 ec 08             	sub    $0x8,%esp
f010413a:	ff 76 04             	pushl  0x4(%esi)
f010413d:	ff 36                	pushl  (%esi)
f010413f:	ff 76 10             	pushl  0x10(%esi)
f0104142:	ff 76 18             	pushl  0x18(%esi)
f0104145:	ff 76 14             	pushl  0x14(%esi)
f0104148:	ff 76 1c             	pushl  0x1c(%esi)
f010414b:	e8 33 03 00 00       	call   f0104483 <syscall>
f0104150:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104153:	83 c4 20             	add    $0x20,%esp
f0104156:	eb 4f                	jmp    f01041a7 <trap+0x1e8>
					      tf->tf_regs.reg_ebx,
					      tf->tf_regs.reg_edi,
					      tf->tf_regs.reg_esi);
		return;
	}
	if(tf->tf_trapno == IRQ_OFFSET+IRQ_KBD){
f0104158:	83 f8 21             	cmp    $0x21,%eax
f010415b:	75 07                	jne    f0104164 <trap+0x1a5>
		//cprintf("BREAK POINT\n");
		kbd_intr();
f010415d:	e8 d0 c4 ff ff       	call   f0100632 <kbd_intr>
f0104162:	eb 43                	jmp    f01041a7 <trap+0x1e8>
		return;
	}
	if(tf->tf_trapno == IRQ_OFFSET+IRQ_SERIAL){
f0104164:	83 f8 24             	cmp    $0x24,%eax
f0104167:	75 07                	jne    f0104170 <trap+0x1b1>
		//cprintf("BREAK POINT\n");
		serial_intr();
f0104169:	e8 a8 c4 ff ff       	call   f0100616 <serial_intr>
f010416e:	eb 37                	jmp    f01041a7 <trap+0x1e8>
	
//>>>>>>> lab3
//>>>>>>> lab4
	// Unexpected trap: The user process or the kernel has a bug.
	//print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
f0104170:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104175:	75 17                	jne    f010418e <trap+0x1cf>
		panic("unhandled trap in kernel");
f0104177:	83 ec 04             	sub    $0x4,%esp
f010417a:	68 b7 7c 10 f0       	push   $0xf0107cb7
f010417f:	68 41 01 00 00       	push   $0x141
f0104184:	68 6e 7c 10 f0       	push   $0xf0107c6e
f0104189:	e8 b2 be ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f010418e:	e8 93 1a 00 00       	call   f0105c26 <cpunum>
f0104193:	83 ec 0c             	sub    $0xc,%esp
f0104196:	6b c0 74             	imul   $0x74,%eax,%eax
f0104199:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f010419f:	e8 b2 f1 ff ff       	call   f0103356 <env_destroy>
f01041a4:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01041a7:	e8 7a 1a 00 00       	call   f0105c26 <cpunum>
f01041ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01041af:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f01041b6:	74 2a                	je     f01041e2 <trap+0x223>
f01041b8:	e8 69 1a 00 00       	call   f0105c26 <cpunum>
f01041bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c0:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01041c6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01041ca:	75 16                	jne    f01041e2 <trap+0x223>
		env_run(curenv);
f01041cc:	e8 55 1a 00 00       	call   f0105c26 <cpunum>
f01041d1:	83 ec 0c             	sub    $0xc,%esp
f01041d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d7:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f01041dd:	e8 13 f2 ff ff       	call   f01033f5 <env_run>
	else
		sched_yield();
f01041e2:	e8 bc 01 00 00       	call   f01043a3 <sched_yield>
f01041e7:	90                   	nop

f01041e8 <th0>:
	Page fault                        14            Yes
	Coprocessor error                 16            No
	Two-byte SW interrupt             0-255         No
 */

    TRAPHANDLER_NOEC(th0, 0)
f01041e8:	6a 00                	push   $0x0
f01041ea:	6a 00                	push   $0x0
f01041ec:	e9 cf 00 00 00       	jmp    f01042c0 <_alltraps>
f01041f1:	90                   	nop

f01041f2 <th1>:
    TRAPHANDLER_NOEC(th1, 1)
f01041f2:	6a 00                	push   $0x0
f01041f4:	6a 01                	push   $0x1
f01041f6:	e9 c5 00 00 00       	jmp    f01042c0 <_alltraps>
f01041fb:	90                   	nop

f01041fc <th3>:
    TRAPHANDLER_NOEC(th3, 3)
f01041fc:	6a 00                	push   $0x0
f01041fe:	6a 03                	push   $0x3
f0104200:	e9 bb 00 00 00       	jmp    f01042c0 <_alltraps>
f0104205:	90                   	nop

f0104206 <th4>:
    TRAPHANDLER_NOEC(th4, 4)
f0104206:	6a 00                	push   $0x0
f0104208:	6a 04                	push   $0x4
f010420a:	e9 b1 00 00 00       	jmp    f01042c0 <_alltraps>
f010420f:	90                   	nop

f0104210 <th5>:
    TRAPHANDLER_NOEC(th5, 5)
f0104210:	6a 00                	push   $0x0
f0104212:	6a 05                	push   $0x5
f0104214:	e9 a7 00 00 00       	jmp    f01042c0 <_alltraps>
f0104219:	90                   	nop

f010421a <th6>:
    TRAPHANDLER_NOEC(th6, 6)
f010421a:	6a 00                	push   $0x0
f010421c:	6a 06                	push   $0x6
f010421e:	e9 9d 00 00 00       	jmp    f01042c0 <_alltraps>
f0104223:	90                   	nop

f0104224 <th7>:
    TRAPHANDLER_NOEC(th7, 7)
f0104224:	6a 00                	push   $0x0
f0104226:	6a 07                	push   $0x7
f0104228:	e9 93 00 00 00       	jmp    f01042c0 <_alltraps>
f010422d:	90                   	nop

f010422e <th8>:
    TRAPHANDLER(th8, 8)
f010422e:	6a 08                	push   $0x8
f0104230:	e9 8b 00 00 00       	jmp    f01042c0 <_alltraps>
f0104235:	90                   	nop

f0104236 <th9>:
    TRAPHANDLER_NOEC(th9, 9)
f0104236:	6a 00                	push   $0x0
f0104238:	6a 09                	push   $0x9
f010423a:	e9 81 00 00 00       	jmp    f01042c0 <_alltraps>
f010423f:	90                   	nop

f0104240 <th10>:
    TRAPHANDLER(th10, 10)
f0104240:	6a 0a                	push   $0xa
f0104242:	eb 7c                	jmp    f01042c0 <_alltraps>

f0104244 <th11>:
    TRAPHANDLER(th11, 11)
f0104244:	6a 0b                	push   $0xb
f0104246:	eb 78                	jmp    f01042c0 <_alltraps>

f0104248 <th12>:
    TRAPHANDLER(th12, 12)
f0104248:	6a 0c                	push   $0xc
f010424a:	eb 74                	jmp    f01042c0 <_alltraps>

f010424c <th13>:
    TRAPHANDLER(th13, 13)
f010424c:	6a 0d                	push   $0xd
f010424e:	eb 70                	jmp    f01042c0 <_alltraps>

f0104250 <th14>:
    TRAPHANDLER(th14, 14)
f0104250:	6a 0e                	push   $0xe
f0104252:	eb 6c                	jmp    f01042c0 <_alltraps>

f0104254 <th16>:
    TRAPHANDLER_NOEC(th16, 16)
f0104254:	6a 00                	push   $0x0
f0104256:	6a 10                	push   $0x10
f0104258:	eb 66                	jmp    f01042c0 <_alltraps>

f010425a <th32>:
    TRAPHANDLER_NOEC(th32, 32)
f010425a:	6a 00                	push   $0x0
f010425c:	6a 20                	push   $0x20
f010425e:	eb 60                	jmp    f01042c0 <_alltraps>

f0104260 <th33>:
    TRAPHANDLER_NOEC(th33, 33)
f0104260:	6a 00                	push   $0x0
f0104262:	6a 21                	push   $0x21
f0104264:	eb 5a                	jmp    f01042c0 <_alltraps>

f0104266 <th34>:
    TRAPHANDLER_NOEC(th34, 34)
f0104266:	6a 00                	push   $0x0
f0104268:	6a 22                	push   $0x22
f010426a:	eb 54                	jmp    f01042c0 <_alltraps>

f010426c <th35>:
    TRAPHANDLER_NOEC(th35, 35)
f010426c:	6a 00                	push   $0x0
f010426e:	6a 23                	push   $0x23
f0104270:	eb 4e                	jmp    f01042c0 <_alltraps>

f0104272 <th36>:
    TRAPHANDLER_NOEC(th36, 36)
f0104272:	6a 00                	push   $0x0
f0104274:	6a 24                	push   $0x24
f0104276:	eb 48                	jmp    f01042c0 <_alltraps>

f0104278 <th37>:
    TRAPHANDLER_NOEC(th37, 37)
f0104278:	6a 00                	push   $0x0
f010427a:	6a 25                	push   $0x25
f010427c:	eb 42                	jmp    f01042c0 <_alltraps>

f010427e <th38>:
    TRAPHANDLER_NOEC(th38, 38)
f010427e:	6a 00                	push   $0x0
f0104280:	6a 26                	push   $0x26
f0104282:	eb 3c                	jmp    f01042c0 <_alltraps>

f0104284 <th39>:
    TRAPHANDLER_NOEC(th39, 39)
f0104284:	6a 00                	push   $0x0
f0104286:	6a 27                	push   $0x27
f0104288:	eb 36                	jmp    f01042c0 <_alltraps>

f010428a <th40>:
    TRAPHANDLER_NOEC(th40, 40)
f010428a:	6a 00                	push   $0x0
f010428c:	6a 28                	push   $0x28
f010428e:	eb 30                	jmp    f01042c0 <_alltraps>

f0104290 <th41>:
    TRAPHANDLER_NOEC(th41, 41)
f0104290:	6a 00                	push   $0x0
f0104292:	6a 29                	push   $0x29
f0104294:	eb 2a                	jmp    f01042c0 <_alltraps>

f0104296 <th42>:
    TRAPHANDLER_NOEC(th42, 42)
f0104296:	6a 00                	push   $0x0
f0104298:	6a 2a                	push   $0x2a
f010429a:	eb 24                	jmp    f01042c0 <_alltraps>

f010429c <th43>:
    TRAPHANDLER_NOEC(th43, 43)
f010429c:	6a 00                	push   $0x0
f010429e:	6a 2b                	push   $0x2b
f01042a0:	eb 1e                	jmp    f01042c0 <_alltraps>

f01042a2 <th44>:
    TRAPHANDLER_NOEC(th44, 44)
f01042a2:	6a 00                	push   $0x0
f01042a4:	6a 2c                	push   $0x2c
f01042a6:	eb 18                	jmp    f01042c0 <_alltraps>

f01042a8 <th45>:
    TRAPHANDLER_NOEC(th45, 45)
f01042a8:	6a 00                	push   $0x0
f01042aa:	6a 2d                	push   $0x2d
f01042ac:	eb 12                	jmp    f01042c0 <_alltraps>

f01042ae <th46>:
    TRAPHANDLER_NOEC(th46, 46)
f01042ae:	6a 00                	push   $0x0
f01042b0:	6a 2e                	push   $0x2e
f01042b2:	eb 0c                	jmp    f01042c0 <_alltraps>

f01042b4 <th47>:
    TRAPHANDLER_NOEC(th47, 47)
f01042b4:	6a 00                	push   $0x0
f01042b6:	6a 2f                	push   $0x2f
f01042b8:	eb 06                	jmp    f01042c0 <_alltraps>

f01042ba <th48>:
    TRAPHANDLER_NOEC(th48, 48)
f01042ba:	6a 00                	push   $0x0
f01042bc:	6a 30                	push   $0x30
f01042be:	eb 00                	jmp    f01042c0 <_alltraps>

f01042c0 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
   	pushl %ds
f01042c0:	1e                   	push   %ds
    pushl %es
f01042c1:	06                   	push   %es
    pushal
f01042c2:	60                   	pusha  
    pushl $GD_KD
f01042c3:	6a 10                	push   $0x10
    popl %ds
f01042c5:	1f                   	pop    %ds
    pushl $GD_KD
f01042c6:	6a 10                	push   $0x10
    popl %es
f01042c8:	07                   	pop    %es
    pushl %esp
f01042c9:	54                   	push   %esp
    call trap
f01042ca:	e8 f0 fc ff ff       	call   f0103fbf <trap>

f01042cf <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01042cf:	55                   	push   %ebp
f01042d0:	89 e5                	mov    %esp,%ebp
f01042d2:	83 ec 08             	sub    $0x8,%esp
f01042d5:	a1 48 f2 29 f0       	mov    0xf029f248,%eax
f01042da:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01042dd:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01042e2:	8b 02                	mov    (%edx),%eax
f01042e4:	83 e8 01             	sub    $0x1,%eax
f01042e7:	83 f8 02             	cmp    $0x2,%eax
f01042ea:	76 10                	jbe    f01042fc <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01042ec:	83 c1 01             	add    $0x1,%ecx
f01042ef:	83 c2 7c             	add    $0x7c,%edx
f01042f2:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01042f8:	75 e8                	jne    f01042e2 <sched_halt+0x13>
f01042fa:	eb 08                	jmp    f0104304 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01042fc:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104302:	75 1f                	jne    f0104323 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104304:	83 ec 0c             	sub    $0xc,%esp
f0104307:	68 90 7e 10 f0       	push   $0xf0107e90
f010430c:	e8 14 f3 ff ff       	call   f0103625 <cprintf>
f0104311:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104314:	83 ec 0c             	sub    $0xc,%esp
f0104317:	6a 00                	push   $0x0
f0104319:	e8 5a c6 ff ff       	call   f0100978 <monitor>
f010431e:	83 c4 10             	add    $0x10,%esp
f0104321:	eb f1                	jmp    f0104314 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104323:	e8 fe 18 00 00       	call   f0105c26 <cpunum>
f0104328:	6b c0 74             	imul   $0x74,%eax,%eax
f010432b:	c7 80 28 00 2a f0 00 	movl   $0x0,-0xfd5ffd8(%eax)
f0104332:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104335:	a1 a4 fe 29 f0       	mov    0xf029fea4,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010433a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010433f:	77 12                	ja     f0104353 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104341:	50                   	push   %eax
f0104342:	68 68 68 10 f0       	push   $0xf0106868
f0104347:	6a 4c                	push   $0x4c
f0104349:	68 b9 7e 10 f0       	push   $0xf0107eb9
f010434e:	e8 ed bc ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104353:	05 00 00 00 10       	add    $0x10000000,%eax
f0104358:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010435b:	e8 c6 18 00 00       	call   f0105c26 <cpunum>
f0104360:	6b d0 74             	imul   $0x74,%eax,%edx
f0104363:	81 c2 20 00 2a f0    	add    $0xf02a0020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104369:	b8 02 00 00 00       	mov    $0x2,%eax
f010436e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104372:	83 ec 0c             	sub    $0xc,%esp
f0104375:	68 c0 23 12 f0       	push   $0xf01223c0
f010437a:	e8 b2 1b 00 00       	call   f0105f31 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010437f:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104381:	e8 a0 18 00 00       	call   f0105c26 <cpunum>
f0104386:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104389:	8b 80 30 00 2a f0    	mov    -0xfd5ffd0(%eax),%eax
f010438f:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104394:	89 c4                	mov    %eax,%esp
f0104396:	6a 00                	push   $0x0
f0104398:	6a 00                	push   $0x0
f010439a:	fb                   	sti    
f010439b:	f4                   	hlt    
f010439c:	eb fd                	jmp    f010439b <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010439e:	83 c4 10             	add    $0x10,%esp
f01043a1:	c9                   	leave  
f01043a2:	c3                   	ret    

f01043a3 <sched_yield>:
int i =0;

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01043a3:	55                   	push   %ebp
f01043a4:	89 e5                	mov    %esp,%ebp
f01043a6:	57                   	push   %edi
f01043a7:	56                   	push   %esi
f01043a8:	53                   	push   %ebx
f01043a9:	83 ec 0c             	sub    $0xc,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	if(curenv != NULL)
f01043ac:	e8 75 18 00 00       	call   f0105c26 <cpunum>
f01043b1:	6b c0 74             	imul   $0x74,%eax,%eax
		j = ENVX(curenv->env_id);
	else
		j = 0;
f01043b4:	b9 00 00 00 00       	mov    $0x0,%ecx
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	if(curenv != NULL)
f01043b9:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f01043c0:	74 17                	je     f01043d9 <sched_yield+0x36>
		j = ENVX(curenv->env_id);
f01043c2:	e8 5f 18 00 00       	call   f0105c26 <cpunum>
f01043c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ca:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01043d0:	8b 48 48             	mov    0x48(%eax),%ecx
f01043d3:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	else
		j = 0;

	for (i = 0; i < NENV; i++) {
f01043d9:	c7 05 64 fa 29 f0 00 	movl   $0x0,0xf029fa64
f01043e0:	00 00 00 
		int k = (j + i)%NENV;
		if (envs[k].env_status == ENV_RUNNABLE){
f01043e3:	8b 35 48 f2 29 f0    	mov    0xf029f248,%esi
f01043e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	if(curenv != NULL)
		j = ENVX(curenv->env_id);
	else
		j = 0;

	for (i = 0; i < NENV; i++) {
f01043ee:	ba 00 00 00 00       	mov    $0x0,%edx
		int k = (j + i)%NENV;
		if (envs[k].env_status == ENV_RUNNABLE){
f01043f3:	8d 04 11             	lea    (%ecx,%edx,1),%eax
f01043f6:	89 c7                	mov    %eax,%edi
f01043f8:	c1 ff 1f             	sar    $0x1f,%edi
f01043fb:	c1 ef 16             	shr    $0x16,%edi
f01043fe:	01 f8                	add    %edi,%eax
f0104400:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104405:	29 f8                	sub    %edi,%eax
f0104407:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010440a:	01 f0                	add    %esi,%eax
f010440c:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104410:	75 13                	jne    f0104425 <sched_yield+0x82>
f0104412:	84 db                	test   %bl,%bl
f0104414:	74 06                	je     f010441c <sched_yield+0x79>
f0104416:	89 15 64 fa 29 f0    	mov    %edx,0xf029fa64
			idle = &envs[k];
			env_run(idle);
f010441c:	83 ec 0c             	sub    $0xc,%esp
f010441f:	50                   	push   %eax
f0104420:	e8 d0 ef ff ff       	call   f01033f5 <env_run>
	if(curenv != NULL)
		j = ENVX(curenv->env_id);
	else
		j = 0;

	for (i = 0; i < NENV; i++) {
f0104425:	83 c2 01             	add    $0x1,%edx
f0104428:	bb 01 00 00 00       	mov    $0x1,%ebx
f010442d:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0104433:	7e be                	jle    f01043f3 <sched_yield+0x50>
f0104435:	89 15 64 fa 29 f0    	mov    %edx,0xf029fa64
		if (envs[k].env_status == ENV_RUNNABLE){
			idle = &envs[k];
			env_run(idle);
		}
	}
	if((curenv != NULL) && (curenv->env_status == ENV_RUNNING))
f010443b:	e8 e6 17 00 00       	call   f0105c26 <cpunum>
f0104440:	6b c0 74             	imul   $0x74,%eax,%eax
f0104443:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f010444a:	74 2a                	je     f0104476 <sched_yield+0xd3>
f010444c:	e8 d5 17 00 00       	call   f0105c26 <cpunum>
f0104451:	6b c0 74             	imul   $0x74,%eax,%eax
f0104454:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f010445a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010445e:	75 16                	jne    f0104476 <sched_yield+0xd3>
		env_run(curenv);
f0104460:	e8 c1 17 00 00       	call   f0105c26 <cpunum>
f0104465:	83 ec 0c             	sub    $0xc,%esp
f0104468:	6b c0 74             	imul   $0x74,%eax,%eax
f010446b:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0104471:	e8 7f ef ff ff       	call   f01033f5 <env_run>
	// sched_halt never returns
	sched_halt();
f0104476:	e8 54 fe ff ff       	call   f01042cf <sched_halt>
}
f010447b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010447e:	5b                   	pop    %ebx
f010447f:	5e                   	pop    %esi
f0104480:	5f                   	pop    %edi
f0104481:	5d                   	pop    %ebp
f0104482:	c3                   	ret    

f0104483 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104483:	55                   	push   %ebp
f0104484:	89 e5                	mov    %esp,%ebp
f0104486:	57                   	push   %edi
f0104487:	56                   	push   %esi
f0104488:	53                   	push   %ebx
f0104489:	83 ec 1c             	sub    $0x1c,%esp
f010448c:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.
	
	int ret = 0;

	switch (syscallno) {
f010448f:	83 f8 0d             	cmp    $0xd,%eax
f0104492:	0f 87 a8 05 00 00    	ja     f0104a40 <syscall+0x5bd>
f0104498:	ff 24 85 cc 7e 10 f0 	jmp    *-0xfef8134(,%eax,4)

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010449f:	e8 82 17 00 00       	call   f0105c26 <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f01044a4:	83 ec 04             	sub    $0x4,%esp
f01044a7:	6a 01                	push   $0x1
f01044a9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01044ac:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01044ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01044b0:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f01044b6:	ff 70 48             	pushl  0x48(%eax)
f01044b9:	e8 79 e9 ff ff       	call   f0102e37 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f01044be:	6a 04                	push   $0x4
f01044c0:	ff 75 10             	pushl  0x10(%ebp)
f01044c3:	ff 75 0c             	pushl  0xc(%ebp)
f01044c6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01044c9:	e8 b4 e8 ff ff       	call   f0102d82 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01044ce:	83 c4 1c             	add    $0x1c,%esp
f01044d1:	ff 75 0c             	pushl  0xc(%ebp)
f01044d4:	ff 75 10             	pushl  0x10(%ebp)
f01044d7:	68 c6 7e 10 f0       	push   $0xf0107ec6
f01044dc:	e8 44 f1 ff ff       	call   f0103625 <cprintf>
f01044e1:	83 c4 10             	add    $0x10,%esp
	//default:
		//return -E_INVAL;
//=======
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			ret = 0;
f01044e4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044e9:	e9 6e 05 00 00       	jmp    f0104a5c <syscall+0x5d9>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01044ee:	e8 51 c1 ff ff       	call   f0100644 <cons_getc>
f01044f3:	89 c3                	mov    %eax,%ebx
			sys_cputs((char *)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f01044f5:	e9 62 05 00 00       	jmp    f0104a5c <syscall+0x5d9>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01044fa:	e8 27 17 00 00       	call   f0105c26 <cpunum>
f01044ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104502:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0104508:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f010450b:	e9 4c 05 00 00       	jmp    f0104a5c <syscall+0x5d9>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104510:	83 ec 04             	sub    $0x4,%esp
f0104513:	6a 01                	push   $0x1
f0104515:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104518:	50                   	push   %eax
f0104519:	ff 75 0c             	pushl  0xc(%ebp)
f010451c:	e8 16 e9 ff ff       	call   f0102e37 <envid2env>
f0104521:	83 c4 10             	add    $0x10,%esp
f0104524:	85 c0                	test   %eax,%eax
f0104526:	78 0e                	js     f0104536 <syscall+0xb3>
		return r;
	env_destroy(e);
f0104528:	83 ec 0c             	sub    $0xc,%esp
f010452b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010452e:	e8 23 ee ff ff       	call   f0103356 <env_destroy>
f0104533:	83 c4 10             	add    $0x10,%esp
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f0104536:	bb 00 00 00 00       	mov    $0x0,%ebx
f010453b:	e9 1c 05 00 00       	jmp    f0104a5c <syscall+0x5d9>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104540:	e8 5e fe ff ff       	call   f01043a3 <sched_yield>
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	int check = env_alloc(&e, curenv->env_id);
f0104545:	e8 dc 16 00 00       	call   f0105c26 <cpunum>
f010454a:	83 ec 08             	sub    $0x8,%esp
f010454d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104550:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0104556:	ff 70 48             	pushl  0x48(%eax)
f0104559:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010455c:	50                   	push   %eax
f010455d:	e8 e7 e9 ff ff       	call   f0102f49 <env_alloc>
	if (check < 0){
f0104562:	83 c4 10             	add    $0x10,%esp
		return check;
f0104565:	89 c3                	mov    %eax,%ebx
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	int check = env_alloc(&e, curenv->env_id);
	if (check < 0){
f0104567:	85 c0                	test   %eax,%eax
f0104569:	0f 88 ed 04 00 00    	js     f0104a5c <syscall+0x5d9>
		return check;
		panic("sys_exofork not implemented");
	}
	// LAB 4: Your code here.
	e->env_status = ENV_NOT_RUNNABLE;
f010456f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104572:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104579:	e8 a8 16 00 00       	call   f0105c26 <cpunum>
f010457e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104581:	8b b0 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%esi
f0104587:	b9 11 00 00 00       	mov    $0x11,%ecx
f010458c:	89 df                	mov    %ebx,%edi
f010458e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0104590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104593:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	
	return e->env_id;
f010459a:	8b 58 48             	mov    0x48(%eax),%ebx
f010459d:	e9 ba 04 00 00       	jmp    f0104a5c <syscall+0x5d9>
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env *e;
	// LAB 4: Your code here.
	int check = envid2env(envid, &e, 1);
f01045a2:	83 ec 04             	sub    $0x4,%esp
f01045a5:	6a 01                	push   $0x1
f01045a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045aa:	50                   	push   %eax
f01045ab:	ff 75 0c             	pushl  0xc(%ebp)
f01045ae:	e8 84 e8 ff ff       	call   f0102e37 <envid2env>
	if (check < 0){
f01045b3:	83 c4 10             	add    $0x10,%esp
f01045b6:	85 c0                	test   %eax,%eax
f01045b8:	78 20                	js     f01045da <syscall+0x157>
		return check;
		//panic("sys_env_set_status not implemented");
	}
	else if ((e->env_status != ENV_RUNNABLE) && (e->env_status != ENV_NOT_RUNNABLE)){
f01045ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01045bd:	8b 42 54             	mov    0x54(%edx),%eax
f01045c0:	83 e8 02             	sub    $0x2,%eax
f01045c3:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01045c8:	75 17                	jne    f01045e1 <syscall+0x15e>
		return -E_INVAL;
		//panic("sys_env_set_status not implemented");
	}
	e->env_status = status;
f01045ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01045cd:	89 42 54             	mov    %eax,0x54(%edx)
	return 0;
f01045d0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01045d5:	e9 82 04 00 00       	jmp    f0104a5c <syscall+0x5d9>
	// envid's status.
	struct Env *e;
	// LAB 4: Your code here.
	int check = envid2env(envid, &e, 1);
	if (check < 0){
		return check;
f01045da:	89 c3                	mov    %eax,%ebx
f01045dc:	e9 7b 04 00 00       	jmp    f0104a5c <syscall+0x5d9>
		//panic("sys_env_set_status not implemented");
	}
	else if ((e->env_status != ENV_RUNNABLE) && (e->env_status != ENV_NOT_RUNNABLE)){
		return -E_INVAL;
f01045e1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
		case SYS_exofork:
			return sys_exofork();
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
f01045e6:	e9 71 04 00 00       	jmp    f0104a5c <syscall+0x5d9>
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	struct PageInfo *env_page;
	struct Env *env;
	
	int check = envid2env(envid, &env, 1);
f01045eb:	83 ec 04             	sub    $0x4,%esp
f01045ee:	6a 01                	push   $0x1
f01045f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045f3:	50                   	push   %eax
f01045f4:	ff 75 0c             	pushl  0xc(%ebp)
f01045f7:	e8 3b e8 ff ff       	call   f0102e37 <envid2env>
	
	if(check != 0)
f01045fc:	83 c4 10             	add    $0x10,%esp
		return check;
f01045ff:	89 c3                	mov    %eax,%ebx
	struct PageInfo *env_page;
	struct Env *env;
	
	int check = envid2env(envid, &env, 1);
	
	if(check != 0)
f0104601:	85 c0                	test   %eax,%eax
f0104603:	0f 85 53 04 00 00    	jne    f0104a5c <syscall+0x5d9>
		return check;
	
	if(((uint32_t)va >= UTOP)||((uint32_t)va % PGSIZE != 0))
f0104609:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104610:	77 64                	ja     f0104676 <syscall+0x1f3>
f0104612:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104619:	75 65                	jne    f0104680 <syscall+0x1fd>
		return -E_INVAL;
	
	if(!((perm & PTE_P) == PTE_P))
		return -E_INVAL;
	
	if(!((perm & PTE_U) == PTE_U))
f010461b:	8b 45 14             	mov    0x14(%ebp),%eax
f010461e:	83 e0 05             	and    $0x5,%eax
f0104621:	83 f8 05             	cmp    $0x5,%eax
f0104624:	75 64                	jne    f010468a <syscall+0x207>
		return -E_INVAL;
	
	if ((perm & ~PTE_SYSCALL) != 0)
f0104626:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104629:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f010462f:	75 63                	jne    f0104694 <syscall+0x211>
		return -E_INVAL;
	
	env_page = page_alloc(ALLOC_ZERO);
f0104631:	83 ec 0c             	sub    $0xc,%esp
f0104634:	6a 01                	push   $0x1
f0104636:	e8 fb c8 ff ff       	call   f0100f36 <page_alloc>
f010463b:	89 c6                	mov    %eax,%esi
	
	if(env_page != NULL){
f010463d:	83 c4 10             	add    $0x10,%esp
f0104640:	85 c0                	test   %eax,%eax
f0104642:	74 5a                	je     f010469e <syscall+0x21b>
		int pgchk = page_insert(env->env_pgdir, env_page, va, perm);
f0104644:	ff 75 14             	pushl  0x14(%ebp)
f0104647:	ff 75 10             	pushl  0x10(%ebp)
f010464a:	50                   	push   %eax
f010464b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010464e:	ff 70 60             	pushl  0x60(%eax)
f0104651:	e8 bc cb ff ff       	call   f0101212 <page_insert>
f0104656:	89 c7                	mov    %eax,%edi
		if(pgchk < 0){
f0104658:	83 c4 10             	add    $0x10,%esp
f010465b:	85 c0                	test   %eax,%eax
f010465d:	0f 89 f9 03 00 00    	jns    f0104a5c <syscall+0x5d9>
			page_free(env_page);
f0104663:	83 ec 0c             	sub    $0xc,%esp
f0104666:	56                   	push   %esi
f0104667:	e8 3a c9 ff ff       	call   f0100fa6 <page_free>
f010466c:	83 c4 10             	add    $0x10,%esp
			return pgchk;
f010466f:	89 fb                	mov    %edi,%ebx
f0104671:	e9 e6 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if(check != 0)
		return check;
	
	if(((uint32_t)va >= UTOP)||((uint32_t)va % PGSIZE != 0))
		return -E_INVAL;
f0104676:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010467b:	e9 dc 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
f0104680:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104685:	e9 d2 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if(!((perm & PTE_P) == PTE_P))
		return -E_INVAL;
	
	if(!((perm & PTE_U) == PTE_U))
		return -E_INVAL;
f010468a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010468f:	e9 c8 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if ((perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f0104694:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104699:	e9 be 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
			return pgchk;
		}
		//env_page->pp_ref++;
	}
	else
		return -E_NO_MEM;
f010469e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			break;
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
			break;
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void *)a2, a3);
f01046a3:	e9 b4 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
	struct Env *srcenv;
	struct Env *dstenv;
	
	struct PageInfo *srcpg;
	
	int chck1 = envid2env(srcenvid, &srcenv, 1);
f01046a8:	83 ec 04             	sub    $0x4,%esp
f01046ab:	6a 01                	push   $0x1
f01046ad:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01046b0:	50                   	push   %eax
f01046b1:	ff 75 0c             	pushl  0xc(%ebp)
f01046b4:	e8 7e e7 ff ff       	call   f0102e37 <envid2env>
f01046b9:	89 c3                	mov    %eax,%ebx
	int chck2 = envid2env(dstenvid, &dstenv, 1);
f01046bb:	83 c4 0c             	add    $0xc,%esp
f01046be:	6a 01                	push   $0x1
f01046c0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01046c3:	50                   	push   %eax
f01046c4:	ff 75 14             	pushl  0x14(%ebp)
f01046c7:	e8 6b e7 ff ff       	call   f0102e37 <envid2env>
	pte_t *ptentry;
	
	if(((uint32_t)srcva >= UTOP)||((uint32_t)srcva % PGSIZE != 0)||((uint32_t)dstva >= UTOP)||((uint32_t)dstva % PGSIZE != 0))
f01046cc:	83 c4 10             	add    $0x10,%esp
f01046cf:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046d6:	77 78                	ja     f0104750 <syscall+0x2cd>
f01046d8:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01046df:	75 79                	jne    f010475a <syscall+0x2d7>
f01046e1:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01046e8:	77 70                	ja     f010475a <syscall+0x2d7>
f01046ea:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01046f1:	75 71                	jne    f0104764 <syscall+0x2e1>
		return -E_INVAL;
	
	if(!((perm & PTE_P) == PTE_P))
		return -E_INVAL;
	
	if(!((perm & PTE_U) == PTE_U))
f01046f3:	8b 55 1c             	mov    0x1c(%ebp),%edx
f01046f6:	83 e2 05             	and    $0x5,%edx
f01046f9:	83 fa 05             	cmp    $0x5,%edx
f01046fc:	75 70                	jne    f010476e <syscall+0x2eb>
		return -E_INVAL;
	
	if((chck1 != 0)||(chck2 != 0))
f01046fe:	09 c3                	or     %eax,%ebx
f0104700:	75 76                	jne    f0104778 <syscall+0x2f5>
		return -E_BAD_ENV;
		
	srcpg = page_lookup(srcenv->env_pgdir, srcva, &ptentry);
f0104702:	83 ec 04             	sub    $0x4,%esp
f0104705:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104708:	50                   	push   %eax
f0104709:	ff 75 10             	pushl  0x10(%ebp)
f010470c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010470f:	ff 70 60             	pushl  0x60(%eax)
f0104712:	e8 12 ca ff ff       	call   f0101129 <page_lookup>
	if(srcpg == NULL)
f0104717:	83 c4 10             	add    $0x10,%esp
f010471a:	85 c0                	test   %eax,%eax
f010471c:	74 64                	je     f0104782 <syscall+0x2ff>
		return -E_INVAL;
		
	if(((perm & PTE_W) == PTE_W) && ((*ptentry & PTE_W) == 0))
f010471e:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104722:	74 08                	je     f010472c <syscall+0x2a9>
f0104724:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104727:	f6 02 02             	testb  $0x2,(%edx)
f010472a:	74 60                	je     f010478c <syscall+0x309>
		return -E_INVAL;
	
	int pgchk = page_insert(dstenv->env_pgdir, srcpg, dstva, perm);
f010472c:	ff 75 1c             	pushl  0x1c(%ebp)
f010472f:	ff 75 18             	pushl  0x18(%ebp)
f0104732:	50                   	push   %eax
f0104733:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104736:	ff 70 60             	pushl  0x60(%eax)
f0104739:	e8 d4 ca ff ff       	call   f0101212 <page_insert>
f010473e:	83 c4 10             	add    $0x10,%esp
f0104741:	85 c0                	test   %eax,%eax
f0104743:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104748:	0f 4e d8             	cmovle %eax,%ebx
f010474b:	e9 0c 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
	int chck1 = envid2env(srcenvid, &srcenv, 1);
	int chck2 = envid2env(dstenvid, &dstenv, 1);
	pte_t *ptentry;
	
	if(((uint32_t)srcva >= UTOP)||((uint32_t)srcva % PGSIZE != 0)||((uint32_t)dstva >= UTOP)||((uint32_t)dstva % PGSIZE != 0))
		return -E_INVAL;
f0104750:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104755:	e9 02 03 00 00       	jmp    f0104a5c <syscall+0x5d9>
f010475a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010475f:	e9 f8 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
f0104764:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104769:	e9 ee 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if(!((perm & PTE_P) == PTE_P))
		return -E_INVAL;
	
	if(!((perm & PTE_U) == PTE_U))
		return -E_INVAL;
f010476e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104773:	e9 e4 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if((chck1 != 0)||(chck2 != 0))
		return -E_BAD_ENV;
f0104778:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010477d:	e9 da 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
		
	srcpg = page_lookup(srcenv->env_pgdir, srcva, &ptentry);
	if(srcpg == NULL)
		return -E_INVAL;
f0104782:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104787:	e9 d0 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
		
	if(((perm & PTE_W) == PTE_W) && ((*ptentry & PTE_W) == 0))
		return -E_INVAL;
f010478c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void *)a2, a3);
			break;
		case SYS_page_map:
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0104791:	e9 c6 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env *env;
	int chck = envid2env(envid, &env, 1);
f0104796:	83 ec 04             	sub    $0x4,%esp
f0104799:	6a 01                	push   $0x1
f010479b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010479e:	50                   	push   %eax
f010479f:	ff 75 0c             	pushl  0xc(%ebp)
f01047a2:	e8 90 e6 ff ff       	call   f0102e37 <envid2env>
	if(chck < 0)
f01047a7:	83 c4 10             	add    $0x10,%esp
f01047aa:	85 c0                	test   %eax,%eax
f01047ac:	78 30                	js     f01047de <syscall+0x35b>
		return chck;
	if(((uint32_t)va >= UTOP)||((uint32_t)va % PGSIZE != 0))
f01047ae:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047b5:	77 2e                	ja     f01047e5 <syscall+0x362>
f01047b7:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047be:	75 2f                	jne    f01047ef <syscall+0x36c>
		return -E_INVAL;
	page_remove(env->env_pgdir, va);
f01047c0:	83 ec 08             	sub    $0x8,%esp
f01047c3:	ff 75 10             	pushl  0x10(%ebp)
f01047c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047c9:	ff 70 60             	pushl  0x60(%eax)
f01047cc:	e8 f3 c9 ff ff       	call   f01011c4 <page_remove>
f01047d1:	83 c4 10             	add    $0x10,%esp
	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");
	return 0;
f01047d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01047d9:	e9 7e 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
{
	// Hint: This function is a wrapper around page_remove().
	struct Env *env;
	int chck = envid2env(envid, &env, 1);
	if(chck < 0)
		return chck;
f01047de:	89 c3                	mov    %eax,%ebx
f01047e0:	e9 77 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
	if(((uint32_t)va >= UTOP)||((uint32_t)va % PGSIZE != 0))
		return -E_INVAL;
f01047e5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047ea:	e9 6d 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
f01047ef:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
		case SYS_page_map:
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
			break;
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void *)a2);
f01047f4:	e9 63 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env *env;
	// LAB 4: Your code here.
	int chck = envid2env(envid, &env, 1);
f01047f9:	83 ec 04             	sub    $0x4,%esp
f01047fc:	6a 01                	push   $0x1
f01047fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104801:	50                   	push   %eax
f0104802:	ff 75 0c             	pushl  0xc(%ebp)
f0104805:	e8 2d e6 ff ff       	call   f0102e37 <envid2env>
	if(chck < 0)
f010480a:	83 c4 10             	add    $0x10,%esp
f010480d:	85 c0                	test   %eax,%eax
f010480f:	78 13                	js     f0104824 <syscall+0x3a1>
		return chck;
		
	env->env_pgfault_upcall = func;
f0104811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104814:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104817:	89 48 64             	mov    %ecx,0x64(%eax)
	
	//panic("sys_env_set_pgfault_upcall not implemented");
	
	return 0;
f010481a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010481f:	e9 38 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
{
	struct Env *env;
	// LAB 4: Your code here.
	int chck = envid2env(envid, &env, 1);
	if(chck < 0)
		return chck;
f0104824:	89 c3                	mov    %eax,%ebx
			break;
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void *)a2);
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104826:	e9 31 02 00 00       	jmp    f0104a5c <syscall+0x5d9>
	// LAB 4: Your code here.
	struct Env *env;
	pte_t  *pte_store;
	struct PageInfo *page;
	
	int check1 = envid2env(envid, &env, 0);
f010482b:	83 ec 04             	sub    $0x4,%esp
f010482e:	6a 00                	push   $0x0
f0104830:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104833:	50                   	push   %eax
f0104834:	ff 75 0c             	pushl  0xc(%ebp)
f0104837:	e8 fb e5 ff ff       	call   f0102e37 <envid2env>
	
	if(check1 < 0)
f010483c:	83 c4 10             	add    $0x10,%esp
f010483f:	85 c0                	test   %eax,%eax
f0104841:	0f 88 f0 00 00 00    	js     f0104937 <syscall+0x4b4>
		return check1;
		
	if(env->env_ipc_recving == 0)
f0104847:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010484a:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010484e:	0f 84 ea 00 00 00    	je     f010493e <syscall+0x4bb>
		return -E_IPC_NOT_RECV;
	
	if((srcva < (void *)UTOP) && (((uint32_t)srcva % PGSIZE)!=0))
f0104854:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010485b:	0f 87 9a 00 00 00    	ja     f01048fb <syscall+0x478>
f0104861:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104868:	0f 85 da 00 00 00    	jne    f0104948 <syscall+0x4c5>
		return -E_INVAL;
	
	if((srcva < (void *)UTOP) && ((perm & PTE_P) != PTE_P))
f010486e:	f6 45 18 01          	testb  $0x1,0x18(%ebp)
f0104872:	0f 84 da 00 00 00    	je     f0104952 <syscall+0x4cf>
		return -E_INVAL;
	
	if((srcva < (void *)UTOP) && ((perm & PTE_U) != PTE_U))
f0104878:	f6 45 18 04          	testb  $0x4,0x18(%ebp)
f010487c:	0f 84 da 00 00 00    	je     f010495c <syscall+0x4d9>
		return -E_INVAL;
	
	if((srcva < (void *)UTOP) && ((perm & ~PTE_SYSCALL) != 0))
f0104882:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104889:	0f 85 d7 00 00 00    	jne    f0104966 <syscall+0x4e3>
		return -E_INVAL;
	
	if(srcva < (void *)UTOP){
		page = page_lookup(curenv->env_pgdir, srcva, &pte_store);
f010488f:	e8 92 13 00 00       	call   f0105c26 <cpunum>
f0104894:	83 ec 04             	sub    $0x4,%esp
f0104897:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010489a:	52                   	push   %edx
f010489b:	ff 75 14             	pushl  0x14(%ebp)
f010489e:	6b c0 74             	imul   $0x74,%eax,%eax
f01048a1:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01048a7:	ff 70 60             	pushl  0x60(%eax)
f01048aa:	e8 7a c8 ff ff       	call   f0101129 <page_lookup>
		if(page == NULL)
f01048af:	83 c4 10             	add    $0x10,%esp
f01048b2:	85 c0                	test   %eax,%eax
f01048b4:	0f 84 b6 00 00 00    	je     f0104970 <syscall+0x4ed>
			return -E_INVAL;
	}
	
	if((srcva < (void *)UTOP) && ((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W))
f01048ba:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01048be:	74 0c                	je     f01048cc <syscall+0x449>
f01048c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048c3:	f6 02 02             	testb  $0x2,(%edx)
f01048c6:	0f 84 ae 00 00 00    	je     f010497a <syscall+0x4f7>
		return -E_INVAL;
	
	if((srcva < (void *)UTOP) && (env->env_ipc_dstva < (void *)UTOP)){
f01048cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01048cf:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01048d2:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01048d8:	0f 87 70 01 00 00    	ja     f0104a4e <syscall+0x5cb>
		int check2 = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm);
f01048de:	ff 75 18             	pushl  0x18(%ebp)
f01048e1:	51                   	push   %ecx
f01048e2:	50                   	push   %eax
f01048e3:	ff 72 60             	pushl  0x60(%edx)
f01048e6:	e8 27 c9 ff ff       	call   f0101212 <page_insert>
		if(check2 < 0){
f01048eb:	83 c4 10             	add    $0x10,%esp
f01048ee:	85 c0                	test   %eax,%eax
f01048f0:	0f 89 58 01 00 00    	jns    f0104a4e <syscall+0x5cb>
f01048f6:	e9 89 00 00 00       	jmp    f0104984 <syscall+0x501>
		}
	}
	if(srcva < (void *)UTOP)
		env->env_ipc_perm = perm;
	else
		env->env_ipc_perm = 0;
f01048fb:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	
	env->env_ipc_recving = 0;
f0104902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104905:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env->env_ipc_from = curenv->env_id;
f0104909:	e8 18 13 00 00       	call   f0105c26 <cpunum>
f010490e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104911:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0104917:	8b 40 48             	mov    0x48(%eax),%eax
f010491a:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f010491d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104920:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104923:	89 78 70             	mov    %edi,0x70(%eax)
	env->env_status = ENV_RUNNABLE;
f0104926:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	
	return 0;	
f010492d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104932:	e9 25 01 00 00       	jmp    f0104a5c <syscall+0x5d9>
	struct PageInfo *page;
	
	int check1 = envid2env(envid, &env, 0);
	
	if(check1 < 0)
		return check1;
f0104937:	89 c3                	mov    %eax,%ebx
f0104939:	e9 1e 01 00 00       	jmp    f0104a5c <syscall+0x5d9>
		
	if(env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
f010493e:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104943:	e9 14 01 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if((srcva < (void *)UTOP) && (((uint32_t)srcva % PGSIZE)!=0))
		return -E_INVAL;
f0104948:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010494d:	e9 0a 01 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if((srcva < (void *)UTOP) && ((perm & PTE_P) != PTE_P))
		return -E_INVAL;
f0104952:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104957:	e9 00 01 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if((srcva < (void *)UTOP) && ((perm & PTE_U) != PTE_U))
		return -E_INVAL;
f010495c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104961:	e9 f6 00 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if((srcva < (void *)UTOP) && ((perm & ~PTE_SYSCALL) != 0))
		return -E_INVAL;
f0104966:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496b:	e9 ec 00 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if(srcva < (void *)UTOP){
		page = page_lookup(curenv->env_pgdir, srcva, &pte_store);
		if(page == NULL)
			return -E_INVAL;
f0104970:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104975:	e9 e2 00 00 00       	jmp    f0104a5c <syscall+0x5d9>
	}
	
	if((srcva < (void *)UTOP) && ((perm & PTE_W) == PTE_W) && ((*pte_store & PTE_W) != PTE_W))
		return -E_INVAL;
f010497a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010497f:	e9 d8 00 00 00       	jmp    f0104a5c <syscall+0x5d9>
	
	if((srcva < (void *)UTOP) && (env->env_ipc_dstva < (void *)UTOP)){
		int check2 = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm);
		if(check2 < 0){
			return check2;	
f0104984:	89 c3                	mov    %eax,%ebx
			break;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104986:	e9 d1 00 00 00       	jmp    f0104a5c <syscall+0x5d9>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.

static int
sys_ipc_recv(void *dstva)
{
	if((uint32_t)dstva < UTOP){
f010498b:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104992:	77 21                	ja     f01049b5 <syscall+0x532>
		if(((uint32_t)dstva % PGSIZE) == 0) 
f0104994:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010499b:	0f 85 a6 00 00 00    	jne    f0104a47 <syscall+0x5c4>
			curenv->env_ipc_dstva = dstva;
f01049a1:	e8 80 12 00 00       	call   f0105c26 <cpunum>
f01049a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a9:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01049af:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01049b2:	89 78 6c             	mov    %edi,0x6c(%eax)
		else
			return -E_INVAL;
	}
	curenv->env_ipc_recving = 1;
f01049b5:	e8 6c 12 00 00       	call   f0105c26 <cpunum>
f01049ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01049bd:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01049c3:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01049c7:	e8 5a 12 00 00       	call   f0105c26 <cpunum>
f01049cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cf:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01049d5:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f01049dc:	e8 45 12 00 00       	call   f0105c26 <cpunum>
f01049e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e4:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01049ea:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01049f1:	e8 ad f9 ff ff       	call   f01043a3 <sched_yield>
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *child;
	int r;
	
	if((r = envid2env(envid, &child, 1)) < 0)
f01049f6:	83 ec 04             	sub    $0x4,%esp
f01049f9:	6a 01                	push   $0x1
f01049fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049fe:	50                   	push   %eax
f01049ff:	ff 75 0c             	pushl  0xc(%ebp)
f0104a02:	e8 30 e4 ff ff       	call   f0102e37 <envid2env>
f0104a07:	83 c4 10             	add    $0x10,%esp
		return r;
f0104a0a:	89 c3                	mov    %eax,%ebx
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *child;
	int r;
	
	if((r = envid2env(envid, &child, 1)) < 0)
f0104a0c:	85 c0                	test   %eax,%eax
f0104a0e:	78 4c                	js     f0104a5c <syscall+0x5d9>
		return r;
		
	user_mem_assert(child, tf, sizeof(struct Trapframe), PTE_W);
f0104a10:	6a 02                	push   $0x2
f0104a12:	6a 44                	push   $0x44
f0104a14:	ff 75 10             	pushl  0x10(%ebp)
f0104a17:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104a1a:	e8 63 e3 ff ff       	call   f0102d82 <user_mem_assert>
	
	child->env_tf = *tf;
f0104a1f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a27:	8b 75 10             	mov    0x10(%ebp),%esi
f0104a2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child->env_tf.tf_eflags |= FL_IF;
f0104a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a2f:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f0104a36:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f0104a39:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a3e:	eb 1c                	jmp    f0104a5c <syscall+0x5d9>
			break;
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
			break;
		default:
			ret = -E_INVAL;
f0104a40:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a45:	eb 15                	jmp    f0104a5c <syscall+0x5d9>
			break;
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
			break;
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104a47:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a4c:	eb 0e                	jmp    f0104a5c <syscall+0x5d9>
		if(check2 < 0){
			return check2;	
		}
	}
	if(srcva < (void *)UTOP)
		env->env_ipc_perm = perm;
f0104a4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a51:	8b 75 18             	mov    0x18(%ebp),%esi
f0104a54:	89 70 78             	mov    %esi,0x78(%eax)
f0104a57:	e9 a6 fe ff ff       	jmp    f0104902 <syscall+0x47f>
//>>>>>>> lab4
	}
	
	return ret;
	panic("syscall not implemented");
}
f0104a5c:	89 d8                	mov    %ebx,%eax
f0104a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a61:	5b                   	pop    %ebx
f0104a62:	5e                   	pop    %esi
f0104a63:	5f                   	pop    %edi
f0104a64:	5d                   	pop    %ebp
f0104a65:	c3                   	ret    

f0104a66 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104a66:	55                   	push   %ebp
f0104a67:	89 e5                	mov    %esp,%ebp
f0104a69:	57                   	push   %edi
f0104a6a:	56                   	push   %esi
f0104a6b:	53                   	push   %ebx
f0104a6c:	83 ec 14             	sub    $0x14,%esp
f0104a6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a75:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a78:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104a7b:	8b 1a                	mov    (%edx),%ebx
f0104a7d:	8b 01                	mov    (%ecx),%eax
f0104a7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a82:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104a89:	eb 7f                	jmp    f0104b0a <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a8e:	01 d8                	add    %ebx,%eax
f0104a90:	89 c6                	mov    %eax,%esi
f0104a92:	c1 ee 1f             	shr    $0x1f,%esi
f0104a95:	01 c6                	add    %eax,%esi
f0104a97:	d1 fe                	sar    %esi
f0104a99:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104a9c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a9f:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104aa2:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104aa4:	eb 03                	jmp    f0104aa9 <stab_binsearch+0x43>
			m--;
f0104aa6:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104aa9:	39 c3                	cmp    %eax,%ebx
f0104aab:	7f 0d                	jg     f0104aba <stab_binsearch+0x54>
f0104aad:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104ab1:	83 ea 0c             	sub    $0xc,%edx
f0104ab4:	39 f9                	cmp    %edi,%ecx
f0104ab6:	75 ee                	jne    f0104aa6 <stab_binsearch+0x40>
f0104ab8:	eb 05                	jmp    f0104abf <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104aba:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104abd:	eb 4b                	jmp    f0104b0a <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104abf:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ac2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ac5:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104ac9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104acc:	76 11                	jbe    f0104adf <stab_binsearch+0x79>
			*region_left = m;
f0104ace:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ad1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104ad3:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104ad6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104add:	eb 2b                	jmp    f0104b0a <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104adf:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104ae2:	73 14                	jae    f0104af8 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104ae4:	83 e8 01             	sub    $0x1,%eax
f0104ae7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104aea:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104aed:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104aef:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104af6:	eb 12                	jmp    f0104b0a <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104af8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104afb:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104afd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b01:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b03:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104b0a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104b0d:	0f 8e 78 ff ff ff    	jle    f0104a8b <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104b13:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b17:	75 0f                	jne    f0104b28 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104b19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b1c:	8b 00                	mov    (%eax),%eax
f0104b1e:	83 e8 01             	sub    $0x1,%eax
f0104b21:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b24:	89 06                	mov    %eax,(%esi)
f0104b26:	eb 2c                	jmp    f0104b54 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b2b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b2d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b30:	8b 0e                	mov    (%esi),%ecx
f0104b32:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b35:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b38:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b3b:	eb 03                	jmp    f0104b40 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104b3d:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b40:	39 c8                	cmp    %ecx,%eax
f0104b42:	7e 0b                	jle    f0104b4f <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104b44:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b48:	83 ea 0c             	sub    $0xc,%edx
f0104b4b:	39 df                	cmp    %ebx,%edi
f0104b4d:	75 ee                	jne    f0104b3d <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104b4f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b52:	89 06                	mov    %eax,(%esi)
	}
}
f0104b54:	83 c4 14             	add    $0x14,%esp
f0104b57:	5b                   	pop    %ebx
f0104b58:	5e                   	pop    %esi
f0104b59:	5f                   	pop    %edi
f0104b5a:	5d                   	pop    %ebp
f0104b5b:	c3                   	ret    

f0104b5c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b5c:	55                   	push   %ebp
f0104b5d:	89 e5                	mov    %esp,%ebp
f0104b5f:	57                   	push   %edi
f0104b60:	56                   	push   %esi
f0104b61:	53                   	push   %ebx
f0104b62:	83 ec 3c             	sub    $0x3c,%esp
f0104b65:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104b68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104b6b:	c7 03 04 7f 10 f0    	movl   $0xf0107f04,(%ebx)
	info->eip_line = 0;
f0104b71:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104b78:	c7 43 08 04 7f 10 f0 	movl   $0xf0107f04,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104b7f:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104b86:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104b89:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104b90:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104b96:	0f 87 a3 00 00 00    	ja     f0104c3f <debuginfo_eip+0xe3>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0104b9c:	e8 85 10 00 00       	call   f0105c26 <cpunum>
f0104ba1:	6a 04                	push   $0x4
f0104ba3:	6a 10                	push   $0x10
f0104ba5:	68 00 00 20 00       	push   $0x200000
f0104baa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bad:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0104bb3:	e8 3b e1 ff ff       	call   f0102cf3 <user_mem_check>
f0104bb8:	83 c4 10             	add    $0x10,%esp
f0104bbb:	85 c0                	test   %eax,%eax
f0104bbd:	0f 85 3e 02 00 00    	jne    f0104e01 <debuginfo_eip+0x2a5>
			return -1;

		stabs = usd->stabs;
f0104bc3:	a1 00 00 20 00       	mov    0x200000,%eax
f0104bc8:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104bcb:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104bd1:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104bd7:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104bda:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104bdf:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
f0104be2:	e8 3f 10 00 00       	call   f0105c26 <cpunum>
f0104be7:	6a 04                	push   $0x4
f0104be9:	89 f2                	mov    %esi,%edx
f0104beb:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104bee:	29 ca                	sub    %ecx,%edx
f0104bf0:	c1 fa 02             	sar    $0x2,%edx
f0104bf3:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104bf9:	52                   	push   %edx
f0104bfa:	51                   	push   %ecx
f0104bfb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bfe:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0104c04:	e8 ea e0 ff ff       	call   f0102cf3 <user_mem_check>
f0104c09:	83 c4 10             	add    $0x10,%esp
f0104c0c:	85 c0                	test   %eax,%eax
f0104c0e:	0f 85 f4 01 00 00    	jne    f0104e08 <debuginfo_eip+0x2ac>
			return -1;
		
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f0104c14:	e8 0d 10 00 00       	call   f0105c26 <cpunum>
f0104c19:	6a 04                	push   $0x4
f0104c1b:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104c1e:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104c21:	29 ca                	sub    %ecx,%edx
f0104c23:	52                   	push   %edx
f0104c24:	51                   	push   %ecx
f0104c25:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c28:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0104c2e:	e8 c0 e0 ff ff       	call   f0102cf3 <user_mem_check>
f0104c33:	83 c4 10             	add    $0x10,%esp
f0104c36:	85 c0                	test   %eax,%eax
f0104c38:	74 1f                	je     f0104c59 <debuginfo_eip+0xfd>
f0104c3a:	e9 d0 01 00 00       	jmp    f0104e0f <debuginfo_eip+0x2b3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104c3f:	c7 45 bc b0 78 11 f0 	movl   $0xf01178b0,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104c46:	c7 45 b8 51 38 11 f0 	movl   $0xf0113851,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104c4d:	be 50 38 11 f0       	mov    $0xf0113850,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104c52:	c7 45 c0 08 87 10 f0 	movl   $0xf0108708,-0x40(%ebp)
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c59:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104c5c:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104c5f:	0f 83 b1 01 00 00    	jae    f0104e16 <debuginfo_eip+0x2ba>
f0104c65:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104c69:	0f 85 ae 01 00 00    	jne    f0104e1d <debuginfo_eip+0x2c1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c6f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c76:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104c79:	c1 fe 02             	sar    $0x2,%esi
f0104c7c:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104c82:	83 e8 01             	sub    $0x1,%eax
f0104c85:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c88:	83 ec 08             	sub    $0x8,%esp
f0104c8b:	57                   	push   %edi
f0104c8c:	6a 64                	push   $0x64
f0104c8e:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104c91:	89 d1                	mov    %edx,%ecx
f0104c93:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c96:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104c99:	89 f0                	mov    %esi,%eax
f0104c9b:	e8 c6 fd ff ff       	call   f0104a66 <stab_binsearch>
	if (lfile == 0)
f0104ca0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ca3:	83 c4 10             	add    $0x10,%esp
f0104ca6:	85 c0                	test   %eax,%eax
f0104ca8:	0f 84 76 01 00 00    	je     f0104e24 <debuginfo_eip+0x2c8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104cae:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104cb7:	83 ec 08             	sub    $0x8,%esp
f0104cba:	57                   	push   %edi
f0104cbb:	6a 24                	push   $0x24
f0104cbd:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104cc0:	89 d1                	mov    %edx,%ecx
f0104cc2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104cc5:	89 f0                	mov    %esi,%eax
f0104cc7:	e8 9a fd ff ff       	call   f0104a66 <stab_binsearch>

	if (lfun <= rfun) {
f0104ccc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ccf:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104cd2:	83 c4 10             	add    $0x10,%esp
f0104cd5:	39 d0                	cmp    %edx,%eax
f0104cd7:	7f 2e                	jg     f0104d07 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104cd9:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104cdc:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104cdf:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104ce2:	8b 36                	mov    (%esi),%esi
f0104ce4:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104ce7:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104cea:	39 ce                	cmp    %ecx,%esi
f0104cec:	73 06                	jae    f0104cf4 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104cee:	03 75 b8             	add    -0x48(%ebp),%esi
f0104cf1:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104cf4:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104cf7:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104cfa:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104cfd:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104cff:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104d02:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104d05:	eb 0f                	jmp    f0104d16 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104d07:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104d0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104d10:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d13:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104d16:	83 ec 08             	sub    $0x8,%esp
f0104d19:	6a 3a                	push   $0x3a
f0104d1b:	ff 73 08             	pushl  0x8(%ebx)
f0104d1e:	e8 c7 08 00 00       	call   f01055ea <strfind>
f0104d23:	2b 43 08             	sub    0x8(%ebx),%eax
f0104d26:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104d29:	83 c4 08             	add    $0x8,%esp
f0104d2c:	57                   	push   %edi
f0104d2d:	6a 44                	push   $0x44
f0104d2f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104d32:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104d35:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d38:	89 f8                	mov    %edi,%eax
f0104d3a:	e8 27 fd ff ff       	call   f0104a66 <stab_binsearch>
	//cprintf("%d	%d",lline,rline);
	if(lline <= rline)
f0104d3f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104d42:	83 c4 10             	add    $0x10,%esp
f0104d45:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104d48:	0f 8f dd 00 00 00    	jg     f0104e2b <debuginfo_eip+0x2cf>
		info->eip_line = stabs[lline].n_desc;
f0104d4e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d51:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104d54:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104d58:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d5e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104d62:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d65:	eb 0a                	jmp    f0104d71 <debuginfo_eip+0x215>
f0104d67:	83 e8 01             	sub    $0x1,%eax
f0104d6a:	83 ea 0c             	sub    $0xc,%edx
f0104d6d:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104d71:	39 c7                	cmp    %eax,%edi
f0104d73:	7e 05                	jle    f0104d7a <debuginfo_eip+0x21e>
f0104d75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d78:	eb 47                	jmp    f0104dc1 <debuginfo_eip+0x265>
	       && stabs[lline].n_type != N_SOL
f0104d7a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d7e:	80 f9 84             	cmp    $0x84,%cl
f0104d81:	75 0e                	jne    f0104d91 <debuginfo_eip+0x235>
f0104d83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d86:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d8a:	74 1c                	je     f0104da8 <debuginfo_eip+0x24c>
f0104d8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104d8f:	eb 17                	jmp    f0104da8 <debuginfo_eip+0x24c>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d91:	80 f9 64             	cmp    $0x64,%cl
f0104d94:	75 d1                	jne    f0104d67 <debuginfo_eip+0x20b>
f0104d96:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104d9a:	74 cb                	je     f0104d67 <debuginfo_eip+0x20b>
f0104d9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d9f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104da3:	74 03                	je     f0104da8 <debuginfo_eip+0x24c>
f0104da5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104da8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104dab:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104dae:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104db1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104db4:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104db7:	29 f8                	sub    %edi,%eax
f0104db9:	39 c2                	cmp    %eax,%edx
f0104dbb:	73 04                	jae    f0104dc1 <debuginfo_eip+0x265>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104dbd:	01 fa                	add    %edi,%edx
f0104dbf:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104dc1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104dc4:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104dc7:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104dcc:	39 f2                	cmp    %esi,%edx
f0104dce:	7d 67                	jge    f0104e37 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
f0104dd0:	83 c2 01             	add    $0x1,%edx
f0104dd3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104dd6:	89 d0                	mov    %edx,%eax
f0104dd8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104ddb:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104dde:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104de1:	eb 04                	jmp    f0104de7 <debuginfo_eip+0x28b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104de3:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104de7:	39 c6                	cmp    %eax,%esi
f0104de9:	7e 47                	jle    f0104e32 <debuginfo_eip+0x2d6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104deb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104def:	83 c0 01             	add    $0x1,%eax
f0104df2:	83 c2 0c             	add    $0xc,%edx
f0104df5:	80 f9 a0             	cmp    $0xa0,%cl
f0104df8:	74 e9                	je     f0104de3 <debuginfo_eip+0x287>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104dfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dff:	eb 36                	jmp    f0104e37 <debuginfo_eip+0x2db>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e06:	eb 2f                	jmp    f0104e37 <debuginfo_eip+0x2db>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv, stabs, stab_end - stabs, PTE_U))
			return -1;
f0104e08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e0d:	eb 28                	jmp    f0104e37 <debuginfo_eip+0x2db>
		
		if(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f0104e0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e14:	eb 21                	jmp    f0104e37 <debuginfo_eip+0x2db>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104e16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e1b:	eb 1a                	jmp    f0104e37 <debuginfo_eip+0x2db>
f0104e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e22:	eb 13                	jmp    f0104e37 <debuginfo_eip+0x2db>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104e24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e29:	eb 0c                	jmp    f0104e37 <debuginfo_eip+0x2db>
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	//cprintf("%d	%d",lline,rline);
	if(lline <= rline)
		info->eip_line = stabs[lline].n_desc;
	else
		return -1;	
f0104e2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e30:	eb 05                	jmp    f0104e37 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e32:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e3a:	5b                   	pop    %ebx
f0104e3b:	5e                   	pop    %esi
f0104e3c:	5f                   	pop    %edi
f0104e3d:	5d                   	pop    %ebp
f0104e3e:	c3                   	ret    

f0104e3f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e3f:	55                   	push   %ebp
f0104e40:	89 e5                	mov    %esp,%ebp
f0104e42:	57                   	push   %edi
f0104e43:	56                   	push   %esi
f0104e44:	53                   	push   %ebx
f0104e45:	83 ec 1c             	sub    $0x1c,%esp
f0104e48:	89 c7                	mov    %eax,%edi
f0104e4a:	89 d6                	mov    %edx,%esi
f0104e4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e4f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e52:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e55:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e58:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e5b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e60:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e63:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e66:	39 d3                	cmp    %edx,%ebx
f0104e68:	72 05                	jb     f0104e6f <printnum+0x30>
f0104e6a:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e6d:	77 45                	ja     f0104eb4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e6f:	83 ec 0c             	sub    $0xc,%esp
f0104e72:	ff 75 18             	pushl  0x18(%ebp)
f0104e75:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e78:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e7b:	53                   	push   %ebx
f0104e7c:	ff 75 10             	pushl  0x10(%ebp)
f0104e7f:	83 ec 08             	sub    $0x8,%esp
f0104e82:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e85:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e88:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e8b:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e8e:	e8 fd 16 00 00       	call   f0106590 <__udivdi3>
f0104e93:	83 c4 18             	add    $0x18,%esp
f0104e96:	52                   	push   %edx
f0104e97:	50                   	push   %eax
f0104e98:	89 f2                	mov    %esi,%edx
f0104e9a:	89 f8                	mov    %edi,%eax
f0104e9c:	e8 9e ff ff ff       	call   f0104e3f <printnum>
f0104ea1:	83 c4 20             	add    $0x20,%esp
f0104ea4:	eb 18                	jmp    f0104ebe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104ea6:	83 ec 08             	sub    $0x8,%esp
f0104ea9:	56                   	push   %esi
f0104eaa:	ff 75 18             	pushl  0x18(%ebp)
f0104ead:	ff d7                	call   *%edi
f0104eaf:	83 c4 10             	add    $0x10,%esp
f0104eb2:	eb 03                	jmp    f0104eb7 <printnum+0x78>
f0104eb4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104eb7:	83 eb 01             	sub    $0x1,%ebx
f0104eba:	85 db                	test   %ebx,%ebx
f0104ebc:	7f e8                	jg     f0104ea6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104ebe:	83 ec 08             	sub    $0x8,%esp
f0104ec1:	56                   	push   %esi
f0104ec2:	83 ec 04             	sub    $0x4,%esp
f0104ec5:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ec8:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ecb:	ff 75 dc             	pushl  -0x24(%ebp)
f0104ece:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ed1:	e8 ea 17 00 00       	call   f01066c0 <__umoddi3>
f0104ed6:	83 c4 14             	add    $0x14,%esp
f0104ed9:	0f be 80 0e 7f 10 f0 	movsbl -0xfef80f2(%eax),%eax
f0104ee0:	50                   	push   %eax
f0104ee1:	ff d7                	call   *%edi
}
f0104ee3:	83 c4 10             	add    $0x10,%esp
f0104ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ee9:	5b                   	pop    %ebx
f0104eea:	5e                   	pop    %esi
f0104eeb:	5f                   	pop    %edi
f0104eec:	5d                   	pop    %ebp
f0104eed:	c3                   	ret    

f0104eee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104eee:	55                   	push   %ebp
f0104eef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104ef1:	83 fa 01             	cmp    $0x1,%edx
f0104ef4:	7e 0e                	jle    f0104f04 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104ef6:	8b 10                	mov    (%eax),%edx
f0104ef8:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104efb:	89 08                	mov    %ecx,(%eax)
f0104efd:	8b 02                	mov    (%edx),%eax
f0104eff:	8b 52 04             	mov    0x4(%edx),%edx
f0104f02:	eb 22                	jmp    f0104f26 <getuint+0x38>
	else if (lflag)
f0104f04:	85 d2                	test   %edx,%edx
f0104f06:	74 10                	je     f0104f18 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104f08:	8b 10                	mov    (%eax),%edx
f0104f0a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f0d:	89 08                	mov    %ecx,(%eax)
f0104f0f:	8b 02                	mov    (%edx),%eax
f0104f11:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f16:	eb 0e                	jmp    f0104f26 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104f18:	8b 10                	mov    (%eax),%edx
f0104f1a:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f1d:	89 08                	mov    %ecx,(%eax)
f0104f1f:	8b 02                	mov    (%edx),%eax
f0104f21:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104f26:	5d                   	pop    %ebp
f0104f27:	c3                   	ret    

f0104f28 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f28:	55                   	push   %ebp
f0104f29:	89 e5                	mov    %esp,%ebp
f0104f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f2e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f32:	8b 10                	mov    (%eax),%edx
f0104f34:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f37:	73 0a                	jae    f0104f43 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104f39:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f3c:	89 08                	mov    %ecx,(%eax)
f0104f3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f41:	88 02                	mov    %al,(%edx)
}
f0104f43:	5d                   	pop    %ebp
f0104f44:	c3                   	ret    

f0104f45 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104f45:	55                   	push   %ebp
f0104f46:	89 e5                	mov    %esp,%ebp
f0104f48:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104f4b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f4e:	50                   	push   %eax
f0104f4f:	ff 75 10             	pushl  0x10(%ebp)
f0104f52:	ff 75 0c             	pushl  0xc(%ebp)
f0104f55:	ff 75 08             	pushl  0x8(%ebp)
f0104f58:	e8 05 00 00 00       	call   f0104f62 <vprintfmt>
	va_end(ap);
}
f0104f5d:	83 c4 10             	add    $0x10,%esp
f0104f60:	c9                   	leave  
f0104f61:	c3                   	ret    

f0104f62 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104f62:	55                   	push   %ebp
f0104f63:	89 e5                	mov    %esp,%ebp
f0104f65:	57                   	push   %edi
f0104f66:	56                   	push   %esi
f0104f67:	53                   	push   %ebx
f0104f68:	83 ec 2c             	sub    $0x2c,%esp
f0104f6b:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f71:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f74:	eb 12                	jmp    f0104f88 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f76:	85 c0                	test   %eax,%eax
f0104f78:	0f 84 a9 03 00 00    	je     f0105327 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
f0104f7e:	83 ec 08             	sub    $0x8,%esp
f0104f81:	53                   	push   %ebx
f0104f82:	50                   	push   %eax
f0104f83:	ff d6                	call   *%esi
f0104f85:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f88:	83 c7 01             	add    $0x1,%edi
f0104f8b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f8f:	83 f8 25             	cmp    $0x25,%eax
f0104f92:	75 e2                	jne    f0104f76 <vprintfmt+0x14>
f0104f94:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104f98:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104f9f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104fa6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104fad:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fb2:	eb 07                	jmp    f0104fbb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104fb7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fbb:	8d 47 01             	lea    0x1(%edi),%eax
f0104fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fc1:	0f b6 07             	movzbl (%edi),%eax
f0104fc4:	0f b6 c8             	movzbl %al,%ecx
f0104fc7:	83 e8 23             	sub    $0x23,%eax
f0104fca:	3c 55                	cmp    $0x55,%al
f0104fcc:	0f 87 3a 03 00 00    	ja     f010530c <vprintfmt+0x3aa>
f0104fd2:	0f b6 c0             	movzbl %al,%eax
f0104fd5:	ff 24 85 60 80 10 f0 	jmp    *-0xfef7fa0(,%eax,4)
f0104fdc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104fdf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104fe3:	eb d6                	jmp    f0104fbb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fe5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fe8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104ff0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104ff3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104ff7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104ffa:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104ffd:	83 fa 09             	cmp    $0x9,%edx
f0105000:	77 39                	ja     f010503b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105002:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105005:	eb e9                	jmp    f0104ff0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105007:	8b 45 14             	mov    0x14(%ebp),%eax
f010500a:	8d 48 04             	lea    0x4(%eax),%ecx
f010500d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105010:	8b 00                	mov    (%eax),%eax
f0105012:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105015:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105018:	eb 27                	jmp    f0105041 <vprintfmt+0xdf>
f010501a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010501d:	85 c0                	test   %eax,%eax
f010501f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105024:	0f 49 c8             	cmovns %eax,%ecx
f0105027:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010502a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010502d:	eb 8c                	jmp    f0104fbb <vprintfmt+0x59>
f010502f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105032:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105039:	eb 80                	jmp    f0104fbb <vprintfmt+0x59>
f010503b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010503e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0105041:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105045:	0f 89 70 ff ff ff    	jns    f0104fbb <vprintfmt+0x59>
				width = precision, precision = -1;
f010504b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010504e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105051:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105058:	e9 5e ff ff ff       	jmp    f0104fbb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010505d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105060:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105063:	e9 53 ff ff ff       	jmp    f0104fbb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105068:	8b 45 14             	mov    0x14(%ebp),%eax
f010506b:	8d 50 04             	lea    0x4(%eax),%edx
f010506e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105071:	83 ec 08             	sub    $0x8,%esp
f0105074:	53                   	push   %ebx
f0105075:	ff 30                	pushl  (%eax)
f0105077:	ff d6                	call   *%esi
			break;
f0105079:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010507c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010507f:	e9 04 ff ff ff       	jmp    f0104f88 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105084:	8b 45 14             	mov    0x14(%ebp),%eax
f0105087:	8d 50 04             	lea    0x4(%eax),%edx
f010508a:	89 55 14             	mov    %edx,0x14(%ebp)
f010508d:	8b 00                	mov    (%eax),%eax
f010508f:	99                   	cltd   
f0105090:	31 d0                	xor    %edx,%eax
f0105092:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105094:	83 f8 0f             	cmp    $0xf,%eax
f0105097:	7f 0b                	jg     f01050a4 <vprintfmt+0x142>
f0105099:	8b 14 85 c0 81 10 f0 	mov    -0xfef7e40(,%eax,4),%edx
f01050a0:	85 d2                	test   %edx,%edx
f01050a2:	75 18                	jne    f01050bc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01050a4:	50                   	push   %eax
f01050a5:	68 26 7f 10 f0       	push   $0xf0107f26
f01050aa:	53                   	push   %ebx
f01050ab:	56                   	push   %esi
f01050ac:	e8 94 fe ff ff       	call   f0104f45 <printfmt>
f01050b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01050b7:	e9 cc fe ff ff       	jmp    f0104f88 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01050bc:	52                   	push   %edx
f01050bd:	68 4d 77 10 f0       	push   $0xf010774d
f01050c2:	53                   	push   %ebx
f01050c3:	56                   	push   %esi
f01050c4:	e8 7c fe ff ff       	call   f0104f45 <printfmt>
f01050c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050cf:	e9 b4 fe ff ff       	jmp    f0104f88 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01050d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01050d7:	8d 50 04             	lea    0x4(%eax),%edx
f01050da:	89 55 14             	mov    %edx,0x14(%ebp)
f01050dd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01050df:	85 ff                	test   %edi,%edi
f01050e1:	b8 1f 7f 10 f0       	mov    $0xf0107f1f,%eax
f01050e6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01050e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050ed:	0f 8e 94 00 00 00    	jle    f0105187 <vprintfmt+0x225>
f01050f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01050f7:	0f 84 98 00 00 00    	je     f0105195 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f01050fd:	83 ec 08             	sub    $0x8,%esp
f0105100:	ff 75 d0             	pushl  -0x30(%ebp)
f0105103:	57                   	push   %edi
f0105104:	e8 97 03 00 00       	call   f01054a0 <strnlen>
f0105109:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010510c:	29 c1                	sub    %eax,%ecx
f010510e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105111:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105114:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105118:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010511b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010511e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105120:	eb 0f                	jmp    f0105131 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105122:	83 ec 08             	sub    $0x8,%esp
f0105125:	53                   	push   %ebx
f0105126:	ff 75 e0             	pushl  -0x20(%ebp)
f0105129:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010512b:	83 ef 01             	sub    $0x1,%edi
f010512e:	83 c4 10             	add    $0x10,%esp
f0105131:	85 ff                	test   %edi,%edi
f0105133:	7f ed                	jg     f0105122 <vprintfmt+0x1c0>
f0105135:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105138:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010513b:	85 c9                	test   %ecx,%ecx
f010513d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105142:	0f 49 c1             	cmovns %ecx,%eax
f0105145:	29 c1                	sub    %eax,%ecx
f0105147:	89 75 08             	mov    %esi,0x8(%ebp)
f010514a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010514d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105150:	89 cb                	mov    %ecx,%ebx
f0105152:	eb 4d                	jmp    f01051a1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105154:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105158:	74 1b                	je     f0105175 <vprintfmt+0x213>
f010515a:	0f be c0             	movsbl %al,%eax
f010515d:	83 e8 20             	sub    $0x20,%eax
f0105160:	83 f8 5e             	cmp    $0x5e,%eax
f0105163:	76 10                	jbe    f0105175 <vprintfmt+0x213>
					putch('?', putdat);
f0105165:	83 ec 08             	sub    $0x8,%esp
f0105168:	ff 75 0c             	pushl  0xc(%ebp)
f010516b:	6a 3f                	push   $0x3f
f010516d:	ff 55 08             	call   *0x8(%ebp)
f0105170:	83 c4 10             	add    $0x10,%esp
f0105173:	eb 0d                	jmp    f0105182 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105175:	83 ec 08             	sub    $0x8,%esp
f0105178:	ff 75 0c             	pushl  0xc(%ebp)
f010517b:	52                   	push   %edx
f010517c:	ff 55 08             	call   *0x8(%ebp)
f010517f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105182:	83 eb 01             	sub    $0x1,%ebx
f0105185:	eb 1a                	jmp    f01051a1 <vprintfmt+0x23f>
f0105187:	89 75 08             	mov    %esi,0x8(%ebp)
f010518a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010518d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105190:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105193:	eb 0c                	jmp    f01051a1 <vprintfmt+0x23f>
f0105195:	89 75 08             	mov    %esi,0x8(%ebp)
f0105198:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010519b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010519e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01051a1:	83 c7 01             	add    $0x1,%edi
f01051a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01051a8:	0f be d0             	movsbl %al,%edx
f01051ab:	85 d2                	test   %edx,%edx
f01051ad:	74 23                	je     f01051d2 <vprintfmt+0x270>
f01051af:	85 f6                	test   %esi,%esi
f01051b1:	78 a1                	js     f0105154 <vprintfmt+0x1f2>
f01051b3:	83 ee 01             	sub    $0x1,%esi
f01051b6:	79 9c                	jns    f0105154 <vprintfmt+0x1f2>
f01051b8:	89 df                	mov    %ebx,%edi
f01051ba:	8b 75 08             	mov    0x8(%ebp),%esi
f01051bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051c0:	eb 18                	jmp    f01051da <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01051c2:	83 ec 08             	sub    $0x8,%esp
f01051c5:	53                   	push   %ebx
f01051c6:	6a 20                	push   $0x20
f01051c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01051ca:	83 ef 01             	sub    $0x1,%edi
f01051cd:	83 c4 10             	add    $0x10,%esp
f01051d0:	eb 08                	jmp    f01051da <vprintfmt+0x278>
f01051d2:	89 df                	mov    %ebx,%edi
f01051d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01051d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01051da:	85 ff                	test   %edi,%edi
f01051dc:	7f e4                	jg     f01051c2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051e1:	e9 a2 fd ff ff       	jmp    f0104f88 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01051e6:	83 fa 01             	cmp    $0x1,%edx
f01051e9:	7e 16                	jle    f0105201 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01051eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ee:	8d 50 08             	lea    0x8(%eax),%edx
f01051f1:	89 55 14             	mov    %edx,0x14(%ebp)
f01051f4:	8b 50 04             	mov    0x4(%eax),%edx
f01051f7:	8b 00                	mov    (%eax),%eax
f01051f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01051ff:	eb 32                	jmp    f0105233 <vprintfmt+0x2d1>
	else if (lflag)
f0105201:	85 d2                	test   %edx,%edx
f0105203:	74 18                	je     f010521d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105205:	8b 45 14             	mov    0x14(%ebp),%eax
f0105208:	8d 50 04             	lea    0x4(%eax),%edx
f010520b:	89 55 14             	mov    %edx,0x14(%ebp)
f010520e:	8b 00                	mov    (%eax),%eax
f0105210:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105213:	89 c1                	mov    %eax,%ecx
f0105215:	c1 f9 1f             	sar    $0x1f,%ecx
f0105218:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010521b:	eb 16                	jmp    f0105233 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010521d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105220:	8d 50 04             	lea    0x4(%eax),%edx
f0105223:	89 55 14             	mov    %edx,0x14(%ebp)
f0105226:	8b 00                	mov    (%eax),%eax
f0105228:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010522b:	89 c1                	mov    %eax,%ecx
f010522d:	c1 f9 1f             	sar    $0x1f,%ecx
f0105230:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105233:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105236:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105239:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010523e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105242:	0f 89 90 00 00 00    	jns    f01052d8 <vprintfmt+0x376>
				putch('-', putdat);
f0105248:	83 ec 08             	sub    $0x8,%esp
f010524b:	53                   	push   %ebx
f010524c:	6a 2d                	push   $0x2d
f010524e:	ff d6                	call   *%esi
				num = -(long long) num;
f0105250:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105253:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105256:	f7 d8                	neg    %eax
f0105258:	83 d2 00             	adc    $0x0,%edx
f010525b:	f7 da                	neg    %edx
f010525d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105260:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105265:	eb 71                	jmp    f01052d8 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105267:	8d 45 14             	lea    0x14(%ebp),%eax
f010526a:	e8 7f fc ff ff       	call   f0104eee <getuint>
			base = 10;
f010526f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105274:	eb 62                	jmp    f01052d8 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105276:	8d 45 14             	lea    0x14(%ebp),%eax
f0105279:	e8 70 fc ff ff       	call   f0104eee <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
f010527e:	83 ec 0c             	sub    $0xc,%esp
f0105281:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f0105285:	51                   	push   %ecx
f0105286:	ff 75 e0             	pushl  -0x20(%ebp)
f0105289:	6a 08                	push   $0x8
f010528b:	52                   	push   %edx
f010528c:	50                   	push   %eax
f010528d:	89 da                	mov    %ebx,%edx
f010528f:	89 f0                	mov    %esi,%eax
f0105291:	e8 a9 fb ff ff       	call   f0104e3f <printnum>
			break;
f0105296:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105299:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
f010529c:	e9 e7 fc ff ff       	jmp    f0104f88 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f01052a1:	83 ec 08             	sub    $0x8,%esp
f01052a4:	53                   	push   %ebx
f01052a5:	6a 30                	push   $0x30
f01052a7:	ff d6                	call   *%esi
			putch('x', putdat);
f01052a9:	83 c4 08             	add    $0x8,%esp
f01052ac:	53                   	push   %ebx
f01052ad:	6a 78                	push   $0x78
f01052af:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01052b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01052b4:	8d 50 04             	lea    0x4(%eax),%edx
f01052b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01052ba:	8b 00                	mov    (%eax),%eax
f01052bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01052c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01052c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01052c9:	eb 0d                	jmp    f01052d8 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01052cb:	8d 45 14             	lea    0x14(%ebp),%eax
f01052ce:	e8 1b fc ff ff       	call   f0104eee <getuint>
			base = 16;
f01052d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01052d8:	83 ec 0c             	sub    $0xc,%esp
f01052db:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01052df:	57                   	push   %edi
f01052e0:	ff 75 e0             	pushl  -0x20(%ebp)
f01052e3:	51                   	push   %ecx
f01052e4:	52                   	push   %edx
f01052e5:	50                   	push   %eax
f01052e6:	89 da                	mov    %ebx,%edx
f01052e8:	89 f0                	mov    %esi,%eax
f01052ea:	e8 50 fb ff ff       	call   f0104e3f <printnum>
			break;
f01052ef:	83 c4 20             	add    $0x20,%esp
f01052f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052f5:	e9 8e fc ff ff       	jmp    f0104f88 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01052fa:	83 ec 08             	sub    $0x8,%esp
f01052fd:	53                   	push   %ebx
f01052fe:	51                   	push   %ecx
f01052ff:	ff d6                	call   *%esi
			break;
f0105301:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105307:	e9 7c fc ff ff       	jmp    f0104f88 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010530c:	83 ec 08             	sub    $0x8,%esp
f010530f:	53                   	push   %ebx
f0105310:	6a 25                	push   $0x25
f0105312:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105314:	83 c4 10             	add    $0x10,%esp
f0105317:	eb 03                	jmp    f010531c <vprintfmt+0x3ba>
f0105319:	83 ef 01             	sub    $0x1,%edi
f010531c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105320:	75 f7                	jne    f0105319 <vprintfmt+0x3b7>
f0105322:	e9 61 fc ff ff       	jmp    f0104f88 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105327:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010532a:	5b                   	pop    %ebx
f010532b:	5e                   	pop    %esi
f010532c:	5f                   	pop    %edi
f010532d:	5d                   	pop    %ebp
f010532e:	c3                   	ret    

f010532f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010532f:	55                   	push   %ebp
f0105330:	89 e5                	mov    %esp,%ebp
f0105332:	83 ec 18             	sub    $0x18,%esp
f0105335:	8b 45 08             	mov    0x8(%ebp),%eax
f0105338:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010533b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010533e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105342:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010534c:	85 c0                	test   %eax,%eax
f010534e:	74 26                	je     f0105376 <vsnprintf+0x47>
f0105350:	85 d2                	test   %edx,%edx
f0105352:	7e 22                	jle    f0105376 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105354:	ff 75 14             	pushl  0x14(%ebp)
f0105357:	ff 75 10             	pushl  0x10(%ebp)
f010535a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010535d:	50                   	push   %eax
f010535e:	68 28 4f 10 f0       	push   $0xf0104f28
f0105363:	e8 fa fb ff ff       	call   f0104f62 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105368:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010536b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010536e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105371:	83 c4 10             	add    $0x10,%esp
f0105374:	eb 05                	jmp    f010537b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105376:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010537b:	c9                   	leave  
f010537c:	c3                   	ret    

f010537d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010537d:	55                   	push   %ebp
f010537e:	89 e5                	mov    %esp,%ebp
f0105380:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105383:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105386:	50                   	push   %eax
f0105387:	ff 75 10             	pushl  0x10(%ebp)
f010538a:	ff 75 0c             	pushl  0xc(%ebp)
f010538d:	ff 75 08             	pushl  0x8(%ebp)
f0105390:	e8 9a ff ff ff       	call   f010532f <vsnprintf>
	va_end(ap);

	return rc;
}
f0105395:	c9                   	leave  
f0105396:	c3                   	ret    

f0105397 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105397:	55                   	push   %ebp
f0105398:	89 e5                	mov    %esp,%ebp
f010539a:	57                   	push   %edi
f010539b:	56                   	push   %esi
f010539c:	53                   	push   %ebx
f010539d:	83 ec 0c             	sub    $0xc,%esp
f01053a0:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01053a3:	85 c0                	test   %eax,%eax
f01053a5:	74 11                	je     f01053b8 <readline+0x21>
		cprintf("%s", prompt);
f01053a7:	83 ec 08             	sub    $0x8,%esp
f01053aa:	50                   	push   %eax
f01053ab:	68 4d 77 10 f0       	push   $0xf010774d
f01053b0:	e8 70 e2 ff ff       	call   f0103625 <cprintf>
f01053b5:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01053b8:	83 ec 0c             	sub    $0xc,%esp
f01053bb:	6a 00                	push   $0x0
f01053bd:	e8 33 b4 ff ff       	call   f01007f5 <iscons>
f01053c2:	89 c7                	mov    %eax,%edi
f01053c4:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01053c7:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01053cc:	e8 13 b4 ff ff       	call   f01007e4 <getchar>
f01053d1:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01053d3:	85 c0                	test   %eax,%eax
f01053d5:	79 29                	jns    f0105400 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f01053d7:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f01053dc:	83 fb f8             	cmp    $0xfffffff8,%ebx
f01053df:	0f 84 9b 00 00 00    	je     f0105480 <readline+0xe9>
				cprintf("read error: %e\n", c);
f01053e5:	83 ec 08             	sub    $0x8,%esp
f01053e8:	53                   	push   %ebx
f01053e9:	68 1f 82 10 f0       	push   $0xf010821f
f01053ee:	e8 32 e2 ff ff       	call   f0103625 <cprintf>
f01053f3:	83 c4 10             	add    $0x10,%esp
			return NULL;
f01053f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01053fb:	e9 80 00 00 00       	jmp    f0105480 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105400:	83 f8 08             	cmp    $0x8,%eax
f0105403:	0f 94 c2             	sete   %dl
f0105406:	83 f8 7f             	cmp    $0x7f,%eax
f0105409:	0f 94 c0             	sete   %al
f010540c:	08 c2                	or     %al,%dl
f010540e:	74 1a                	je     f010542a <readline+0x93>
f0105410:	85 f6                	test   %esi,%esi
f0105412:	7e 16                	jle    f010542a <readline+0x93>
			if (echoing)
f0105414:	85 ff                	test   %edi,%edi
f0105416:	74 0d                	je     f0105425 <readline+0x8e>
				cputchar('\b');
f0105418:	83 ec 0c             	sub    $0xc,%esp
f010541b:	6a 08                	push   $0x8
f010541d:	e8 b2 b3 ff ff       	call   f01007d4 <cputchar>
f0105422:	83 c4 10             	add    $0x10,%esp
			i--;
f0105425:	83 ee 01             	sub    $0x1,%esi
f0105428:	eb a2                	jmp    f01053cc <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010542a:	83 fb 1f             	cmp    $0x1f,%ebx
f010542d:	7e 26                	jle    f0105455 <readline+0xbe>
f010542f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105435:	7f 1e                	jg     f0105455 <readline+0xbe>
			if (echoing)
f0105437:	85 ff                	test   %edi,%edi
f0105439:	74 0c                	je     f0105447 <readline+0xb0>
				cputchar(c);
f010543b:	83 ec 0c             	sub    $0xc,%esp
f010543e:	53                   	push   %ebx
f010543f:	e8 90 b3 ff ff       	call   f01007d4 <cputchar>
f0105444:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105447:	88 9e 80 fa 29 f0    	mov    %bl,-0xfd60580(%esi)
f010544d:	8d 76 01             	lea    0x1(%esi),%esi
f0105450:	e9 77 ff ff ff       	jmp    f01053cc <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105455:	83 fb 0a             	cmp    $0xa,%ebx
f0105458:	74 09                	je     f0105463 <readline+0xcc>
f010545a:	83 fb 0d             	cmp    $0xd,%ebx
f010545d:	0f 85 69 ff ff ff    	jne    f01053cc <readline+0x35>
			if (echoing)
f0105463:	85 ff                	test   %edi,%edi
f0105465:	74 0d                	je     f0105474 <readline+0xdd>
				cputchar('\n');
f0105467:	83 ec 0c             	sub    $0xc,%esp
f010546a:	6a 0a                	push   $0xa
f010546c:	e8 63 b3 ff ff       	call   f01007d4 <cputchar>
f0105471:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105474:	c6 86 80 fa 29 f0 00 	movb   $0x0,-0xfd60580(%esi)
			return buf;
f010547b:	b8 80 fa 29 f0       	mov    $0xf029fa80,%eax
		}
	}
}
f0105480:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105483:	5b                   	pop    %ebx
f0105484:	5e                   	pop    %esi
f0105485:	5f                   	pop    %edi
f0105486:	5d                   	pop    %ebp
f0105487:	c3                   	ret    

f0105488 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105488:	55                   	push   %ebp
f0105489:	89 e5                	mov    %esp,%ebp
f010548b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010548e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105493:	eb 03                	jmp    f0105498 <strlen+0x10>
		n++;
f0105495:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105498:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010549c:	75 f7                	jne    f0105495 <strlen+0xd>
		n++;
	return n;
}
f010549e:	5d                   	pop    %ebp
f010549f:	c3                   	ret    

f01054a0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01054a0:	55                   	push   %ebp
f01054a1:	89 e5                	mov    %esp,%ebp
f01054a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01054ae:	eb 03                	jmp    f01054b3 <strnlen+0x13>
		n++;
f01054b0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054b3:	39 c2                	cmp    %eax,%edx
f01054b5:	74 08                	je     f01054bf <strnlen+0x1f>
f01054b7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01054bb:	75 f3                	jne    f01054b0 <strnlen+0x10>
f01054bd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01054bf:	5d                   	pop    %ebp
f01054c0:	c3                   	ret    

f01054c1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01054c1:	55                   	push   %ebp
f01054c2:	89 e5                	mov    %esp,%ebp
f01054c4:	53                   	push   %ebx
f01054c5:	8b 45 08             	mov    0x8(%ebp),%eax
f01054c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01054cb:	89 c2                	mov    %eax,%edx
f01054cd:	83 c2 01             	add    $0x1,%edx
f01054d0:	83 c1 01             	add    $0x1,%ecx
f01054d3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01054d7:	88 5a ff             	mov    %bl,-0x1(%edx)
f01054da:	84 db                	test   %bl,%bl
f01054dc:	75 ef                	jne    f01054cd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01054de:	5b                   	pop    %ebx
f01054df:	5d                   	pop    %ebp
f01054e0:	c3                   	ret    

f01054e1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01054e1:	55                   	push   %ebp
f01054e2:	89 e5                	mov    %esp,%ebp
f01054e4:	53                   	push   %ebx
f01054e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01054e8:	53                   	push   %ebx
f01054e9:	e8 9a ff ff ff       	call   f0105488 <strlen>
f01054ee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01054f1:	ff 75 0c             	pushl  0xc(%ebp)
f01054f4:	01 d8                	add    %ebx,%eax
f01054f6:	50                   	push   %eax
f01054f7:	e8 c5 ff ff ff       	call   f01054c1 <strcpy>
	return dst;
}
f01054fc:	89 d8                	mov    %ebx,%eax
f01054fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105501:	c9                   	leave  
f0105502:	c3                   	ret    

f0105503 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105503:	55                   	push   %ebp
f0105504:	89 e5                	mov    %esp,%ebp
f0105506:	56                   	push   %esi
f0105507:	53                   	push   %ebx
f0105508:	8b 75 08             	mov    0x8(%ebp),%esi
f010550b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010550e:	89 f3                	mov    %esi,%ebx
f0105510:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105513:	89 f2                	mov    %esi,%edx
f0105515:	eb 0f                	jmp    f0105526 <strncpy+0x23>
		*dst++ = *src;
f0105517:	83 c2 01             	add    $0x1,%edx
f010551a:	0f b6 01             	movzbl (%ecx),%eax
f010551d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105520:	80 39 01             	cmpb   $0x1,(%ecx)
f0105523:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105526:	39 da                	cmp    %ebx,%edx
f0105528:	75 ed                	jne    f0105517 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010552a:	89 f0                	mov    %esi,%eax
f010552c:	5b                   	pop    %ebx
f010552d:	5e                   	pop    %esi
f010552e:	5d                   	pop    %ebp
f010552f:	c3                   	ret    

f0105530 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105530:	55                   	push   %ebp
f0105531:	89 e5                	mov    %esp,%ebp
f0105533:	56                   	push   %esi
f0105534:	53                   	push   %ebx
f0105535:	8b 75 08             	mov    0x8(%ebp),%esi
f0105538:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010553b:	8b 55 10             	mov    0x10(%ebp),%edx
f010553e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105540:	85 d2                	test   %edx,%edx
f0105542:	74 21                	je     f0105565 <strlcpy+0x35>
f0105544:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105548:	89 f2                	mov    %esi,%edx
f010554a:	eb 09                	jmp    f0105555 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010554c:	83 c2 01             	add    $0x1,%edx
f010554f:	83 c1 01             	add    $0x1,%ecx
f0105552:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105555:	39 c2                	cmp    %eax,%edx
f0105557:	74 09                	je     f0105562 <strlcpy+0x32>
f0105559:	0f b6 19             	movzbl (%ecx),%ebx
f010555c:	84 db                	test   %bl,%bl
f010555e:	75 ec                	jne    f010554c <strlcpy+0x1c>
f0105560:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105562:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105565:	29 f0                	sub    %esi,%eax
}
f0105567:	5b                   	pop    %ebx
f0105568:	5e                   	pop    %esi
f0105569:	5d                   	pop    %ebp
f010556a:	c3                   	ret    

f010556b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010556b:	55                   	push   %ebp
f010556c:	89 e5                	mov    %esp,%ebp
f010556e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105571:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105574:	eb 06                	jmp    f010557c <strcmp+0x11>
		p++, q++;
f0105576:	83 c1 01             	add    $0x1,%ecx
f0105579:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010557c:	0f b6 01             	movzbl (%ecx),%eax
f010557f:	84 c0                	test   %al,%al
f0105581:	74 04                	je     f0105587 <strcmp+0x1c>
f0105583:	3a 02                	cmp    (%edx),%al
f0105585:	74 ef                	je     f0105576 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105587:	0f b6 c0             	movzbl %al,%eax
f010558a:	0f b6 12             	movzbl (%edx),%edx
f010558d:	29 d0                	sub    %edx,%eax
}
f010558f:	5d                   	pop    %ebp
f0105590:	c3                   	ret    

f0105591 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105591:	55                   	push   %ebp
f0105592:	89 e5                	mov    %esp,%ebp
f0105594:	53                   	push   %ebx
f0105595:	8b 45 08             	mov    0x8(%ebp),%eax
f0105598:	8b 55 0c             	mov    0xc(%ebp),%edx
f010559b:	89 c3                	mov    %eax,%ebx
f010559d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01055a0:	eb 06                	jmp    f01055a8 <strncmp+0x17>
		n--, p++, q++;
f01055a2:	83 c0 01             	add    $0x1,%eax
f01055a5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01055a8:	39 d8                	cmp    %ebx,%eax
f01055aa:	74 15                	je     f01055c1 <strncmp+0x30>
f01055ac:	0f b6 08             	movzbl (%eax),%ecx
f01055af:	84 c9                	test   %cl,%cl
f01055b1:	74 04                	je     f01055b7 <strncmp+0x26>
f01055b3:	3a 0a                	cmp    (%edx),%cl
f01055b5:	74 eb                	je     f01055a2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01055b7:	0f b6 00             	movzbl (%eax),%eax
f01055ba:	0f b6 12             	movzbl (%edx),%edx
f01055bd:	29 d0                	sub    %edx,%eax
f01055bf:	eb 05                	jmp    f01055c6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01055c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01055c6:	5b                   	pop    %ebx
f01055c7:	5d                   	pop    %ebp
f01055c8:	c3                   	ret    

f01055c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01055c9:	55                   	push   %ebp
f01055ca:	89 e5                	mov    %esp,%ebp
f01055cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01055cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055d3:	eb 07                	jmp    f01055dc <strchr+0x13>
		if (*s == c)
f01055d5:	38 ca                	cmp    %cl,%dl
f01055d7:	74 0f                	je     f01055e8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01055d9:	83 c0 01             	add    $0x1,%eax
f01055dc:	0f b6 10             	movzbl (%eax),%edx
f01055df:	84 d2                	test   %dl,%dl
f01055e1:	75 f2                	jne    f01055d5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01055e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055e8:	5d                   	pop    %ebp
f01055e9:	c3                   	ret    

f01055ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01055ea:	55                   	push   %ebp
f01055eb:	89 e5                	mov    %esp,%ebp
f01055ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01055f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055f4:	eb 03                	jmp    f01055f9 <strfind+0xf>
f01055f6:	83 c0 01             	add    $0x1,%eax
f01055f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01055fc:	38 ca                	cmp    %cl,%dl
f01055fe:	74 04                	je     f0105604 <strfind+0x1a>
f0105600:	84 d2                	test   %dl,%dl
f0105602:	75 f2                	jne    f01055f6 <strfind+0xc>
			break;
	return (char *) s;
}
f0105604:	5d                   	pop    %ebp
f0105605:	c3                   	ret    

f0105606 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105606:	55                   	push   %ebp
f0105607:	89 e5                	mov    %esp,%ebp
f0105609:	57                   	push   %edi
f010560a:	56                   	push   %esi
f010560b:	53                   	push   %ebx
f010560c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010560f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105612:	85 c9                	test   %ecx,%ecx
f0105614:	74 36                	je     f010564c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105616:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010561c:	75 28                	jne    f0105646 <memset+0x40>
f010561e:	f6 c1 03             	test   $0x3,%cl
f0105621:	75 23                	jne    f0105646 <memset+0x40>
		c &= 0xFF;
f0105623:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105627:	89 d3                	mov    %edx,%ebx
f0105629:	c1 e3 08             	shl    $0x8,%ebx
f010562c:	89 d6                	mov    %edx,%esi
f010562e:	c1 e6 18             	shl    $0x18,%esi
f0105631:	89 d0                	mov    %edx,%eax
f0105633:	c1 e0 10             	shl    $0x10,%eax
f0105636:	09 f0                	or     %esi,%eax
f0105638:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010563a:	89 d8                	mov    %ebx,%eax
f010563c:	09 d0                	or     %edx,%eax
f010563e:	c1 e9 02             	shr    $0x2,%ecx
f0105641:	fc                   	cld    
f0105642:	f3 ab                	rep stos %eax,%es:(%edi)
f0105644:	eb 06                	jmp    f010564c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105646:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105649:	fc                   	cld    
f010564a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010564c:	89 f8                	mov    %edi,%eax
f010564e:	5b                   	pop    %ebx
f010564f:	5e                   	pop    %esi
f0105650:	5f                   	pop    %edi
f0105651:	5d                   	pop    %ebp
f0105652:	c3                   	ret    

f0105653 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105653:	55                   	push   %ebp
f0105654:	89 e5                	mov    %esp,%ebp
f0105656:	57                   	push   %edi
f0105657:	56                   	push   %esi
f0105658:	8b 45 08             	mov    0x8(%ebp),%eax
f010565b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010565e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105661:	39 c6                	cmp    %eax,%esi
f0105663:	73 35                	jae    f010569a <memmove+0x47>
f0105665:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105668:	39 d0                	cmp    %edx,%eax
f010566a:	73 2e                	jae    f010569a <memmove+0x47>
		s += n;
		d += n;
f010566c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010566f:	89 d6                	mov    %edx,%esi
f0105671:	09 fe                	or     %edi,%esi
f0105673:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105679:	75 13                	jne    f010568e <memmove+0x3b>
f010567b:	f6 c1 03             	test   $0x3,%cl
f010567e:	75 0e                	jne    f010568e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105680:	83 ef 04             	sub    $0x4,%edi
f0105683:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105686:	c1 e9 02             	shr    $0x2,%ecx
f0105689:	fd                   	std    
f010568a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010568c:	eb 09                	jmp    f0105697 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010568e:	83 ef 01             	sub    $0x1,%edi
f0105691:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105694:	fd                   	std    
f0105695:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105697:	fc                   	cld    
f0105698:	eb 1d                	jmp    f01056b7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010569a:	89 f2                	mov    %esi,%edx
f010569c:	09 c2                	or     %eax,%edx
f010569e:	f6 c2 03             	test   $0x3,%dl
f01056a1:	75 0f                	jne    f01056b2 <memmove+0x5f>
f01056a3:	f6 c1 03             	test   $0x3,%cl
f01056a6:	75 0a                	jne    f01056b2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01056a8:	c1 e9 02             	shr    $0x2,%ecx
f01056ab:	89 c7                	mov    %eax,%edi
f01056ad:	fc                   	cld    
f01056ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01056b0:	eb 05                	jmp    f01056b7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01056b2:	89 c7                	mov    %eax,%edi
f01056b4:	fc                   	cld    
f01056b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01056b7:	5e                   	pop    %esi
f01056b8:	5f                   	pop    %edi
f01056b9:	5d                   	pop    %ebp
f01056ba:	c3                   	ret    

f01056bb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01056bb:	55                   	push   %ebp
f01056bc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01056be:	ff 75 10             	pushl  0x10(%ebp)
f01056c1:	ff 75 0c             	pushl  0xc(%ebp)
f01056c4:	ff 75 08             	pushl  0x8(%ebp)
f01056c7:	e8 87 ff ff ff       	call   f0105653 <memmove>
}
f01056cc:	c9                   	leave  
f01056cd:	c3                   	ret    

f01056ce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01056ce:	55                   	push   %ebp
f01056cf:	89 e5                	mov    %esp,%ebp
f01056d1:	56                   	push   %esi
f01056d2:	53                   	push   %ebx
f01056d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01056d6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056d9:	89 c6                	mov    %eax,%esi
f01056db:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056de:	eb 1a                	jmp    f01056fa <memcmp+0x2c>
		if (*s1 != *s2)
f01056e0:	0f b6 08             	movzbl (%eax),%ecx
f01056e3:	0f b6 1a             	movzbl (%edx),%ebx
f01056e6:	38 d9                	cmp    %bl,%cl
f01056e8:	74 0a                	je     f01056f4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01056ea:	0f b6 c1             	movzbl %cl,%eax
f01056ed:	0f b6 db             	movzbl %bl,%ebx
f01056f0:	29 d8                	sub    %ebx,%eax
f01056f2:	eb 0f                	jmp    f0105703 <memcmp+0x35>
		s1++, s2++;
f01056f4:	83 c0 01             	add    $0x1,%eax
f01056f7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01056fa:	39 f0                	cmp    %esi,%eax
f01056fc:	75 e2                	jne    f01056e0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01056fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105703:	5b                   	pop    %ebx
f0105704:	5e                   	pop    %esi
f0105705:	5d                   	pop    %ebp
f0105706:	c3                   	ret    

f0105707 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105707:	55                   	push   %ebp
f0105708:	89 e5                	mov    %esp,%ebp
f010570a:	53                   	push   %ebx
f010570b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010570e:	89 c1                	mov    %eax,%ecx
f0105710:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105713:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105717:	eb 0a                	jmp    f0105723 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105719:	0f b6 10             	movzbl (%eax),%edx
f010571c:	39 da                	cmp    %ebx,%edx
f010571e:	74 07                	je     f0105727 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105720:	83 c0 01             	add    $0x1,%eax
f0105723:	39 c8                	cmp    %ecx,%eax
f0105725:	72 f2                	jb     f0105719 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105727:	5b                   	pop    %ebx
f0105728:	5d                   	pop    %ebp
f0105729:	c3                   	ret    

f010572a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010572a:	55                   	push   %ebp
f010572b:	89 e5                	mov    %esp,%ebp
f010572d:	57                   	push   %edi
f010572e:	56                   	push   %esi
f010572f:	53                   	push   %ebx
f0105730:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105733:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105736:	eb 03                	jmp    f010573b <strtol+0x11>
		s++;
f0105738:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010573b:	0f b6 01             	movzbl (%ecx),%eax
f010573e:	3c 20                	cmp    $0x20,%al
f0105740:	74 f6                	je     f0105738 <strtol+0xe>
f0105742:	3c 09                	cmp    $0x9,%al
f0105744:	74 f2                	je     f0105738 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105746:	3c 2b                	cmp    $0x2b,%al
f0105748:	75 0a                	jne    f0105754 <strtol+0x2a>
		s++;
f010574a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010574d:	bf 00 00 00 00       	mov    $0x0,%edi
f0105752:	eb 11                	jmp    f0105765 <strtol+0x3b>
f0105754:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105759:	3c 2d                	cmp    $0x2d,%al
f010575b:	75 08                	jne    f0105765 <strtol+0x3b>
		s++, neg = 1;
f010575d:	83 c1 01             	add    $0x1,%ecx
f0105760:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105765:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010576b:	75 15                	jne    f0105782 <strtol+0x58>
f010576d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105770:	75 10                	jne    f0105782 <strtol+0x58>
f0105772:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105776:	75 7c                	jne    f01057f4 <strtol+0xca>
		s += 2, base = 16;
f0105778:	83 c1 02             	add    $0x2,%ecx
f010577b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105780:	eb 16                	jmp    f0105798 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105782:	85 db                	test   %ebx,%ebx
f0105784:	75 12                	jne    f0105798 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105786:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010578b:	80 39 30             	cmpb   $0x30,(%ecx)
f010578e:	75 08                	jne    f0105798 <strtol+0x6e>
		s++, base = 8;
f0105790:	83 c1 01             	add    $0x1,%ecx
f0105793:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105798:	b8 00 00 00 00       	mov    $0x0,%eax
f010579d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01057a0:	0f b6 11             	movzbl (%ecx),%edx
f01057a3:	8d 72 d0             	lea    -0x30(%edx),%esi
f01057a6:	89 f3                	mov    %esi,%ebx
f01057a8:	80 fb 09             	cmp    $0x9,%bl
f01057ab:	77 08                	ja     f01057b5 <strtol+0x8b>
			dig = *s - '0';
f01057ad:	0f be d2             	movsbl %dl,%edx
f01057b0:	83 ea 30             	sub    $0x30,%edx
f01057b3:	eb 22                	jmp    f01057d7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01057b5:	8d 72 9f             	lea    -0x61(%edx),%esi
f01057b8:	89 f3                	mov    %esi,%ebx
f01057ba:	80 fb 19             	cmp    $0x19,%bl
f01057bd:	77 08                	ja     f01057c7 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01057bf:	0f be d2             	movsbl %dl,%edx
f01057c2:	83 ea 57             	sub    $0x57,%edx
f01057c5:	eb 10                	jmp    f01057d7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01057c7:	8d 72 bf             	lea    -0x41(%edx),%esi
f01057ca:	89 f3                	mov    %esi,%ebx
f01057cc:	80 fb 19             	cmp    $0x19,%bl
f01057cf:	77 16                	ja     f01057e7 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01057d1:	0f be d2             	movsbl %dl,%edx
f01057d4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01057d7:	3b 55 10             	cmp    0x10(%ebp),%edx
f01057da:	7d 0b                	jge    f01057e7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01057dc:	83 c1 01             	add    $0x1,%ecx
f01057df:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057e3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01057e5:	eb b9                	jmp    f01057a0 <strtol+0x76>

	if (endptr)
f01057e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01057eb:	74 0d                	je     f01057fa <strtol+0xd0>
		*endptr = (char *) s;
f01057ed:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057f0:	89 0e                	mov    %ecx,(%esi)
f01057f2:	eb 06                	jmp    f01057fa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01057f4:	85 db                	test   %ebx,%ebx
f01057f6:	74 98                	je     f0105790 <strtol+0x66>
f01057f8:	eb 9e                	jmp    f0105798 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01057fa:	89 c2                	mov    %eax,%edx
f01057fc:	f7 da                	neg    %edx
f01057fe:	85 ff                	test   %edi,%edi
f0105800:	0f 45 c2             	cmovne %edx,%eax
}
f0105803:	5b                   	pop    %ebx
f0105804:	5e                   	pop    %esi
f0105805:	5f                   	pop    %edi
f0105806:	5d                   	pop    %ebp
f0105807:	c3                   	ret    

f0105808 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105808:	fa                   	cli    

	xorw    %ax, %ax
f0105809:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010580b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010580d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010580f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105811:	0f 01 16             	lgdtl  (%esi)
f0105814:	74 70                	je     f0105886 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105816:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105819:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010581d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105820:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105826:	08 00                	or     %al,(%eax)

f0105828 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105828:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010582c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010582e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105830:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105832:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105836:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105838:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010583a:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f010583f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105842:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105845:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010584a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010584d:	8b 25 9c fe 29 f0    	mov    0xf029fe9c,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105853:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105858:	b8 0d 02 10 f0       	mov    $0xf010020d,%eax
	call    *%eax
f010585d:	ff d0                	call   *%eax

f010585f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010585f:	eb fe                	jmp    f010585f <spin>
f0105861:	8d 76 00             	lea    0x0(%esi),%esi

f0105864 <gdt>:
	...
f010586c:	ff                   	(bad)  
f010586d:	ff 00                	incl   (%eax)
f010586f:	00 00                	add    %al,(%eax)
f0105871:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105878:	00                   	.byte 0x0
f0105879:	92                   	xchg   %eax,%edx
f010587a:	cf                   	iret   
	...

f010587c <gdtdesc>:
f010587c:	17                   	pop    %ss
f010587d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105882 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105882:	90                   	nop

f0105883 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105883:	55                   	push   %ebp
f0105884:	89 e5                	mov    %esp,%ebp
f0105886:	57                   	push   %edi
f0105887:	56                   	push   %esi
f0105888:	53                   	push   %ebx
f0105889:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010588c:	8b 0d a0 fe 29 f0    	mov    0xf029fea0,%ecx
f0105892:	89 c3                	mov    %eax,%ebx
f0105894:	c1 eb 0c             	shr    $0xc,%ebx
f0105897:	39 cb                	cmp    %ecx,%ebx
f0105899:	72 12                	jb     f01058ad <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010589b:	50                   	push   %eax
f010589c:	68 44 68 10 f0       	push   $0xf0106844
f01058a1:	6a 57                	push   $0x57
f01058a3:	68 bd 83 10 f0       	push   $0xf01083bd
f01058a8:	e8 93 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01058ad:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01058b3:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058b5:	89 c2                	mov    %eax,%edx
f01058b7:	c1 ea 0c             	shr    $0xc,%edx
f01058ba:	39 ca                	cmp    %ecx,%edx
f01058bc:	72 12                	jb     f01058d0 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058be:	50                   	push   %eax
f01058bf:	68 44 68 10 f0       	push   $0xf0106844
f01058c4:	6a 57                	push   $0x57
f01058c6:	68 bd 83 10 f0       	push   $0xf01083bd
f01058cb:	e8 70 a7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01058d0:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01058d6:	eb 2f                	jmp    f0105907 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01058d8:	83 ec 04             	sub    $0x4,%esp
f01058db:	6a 04                	push   $0x4
f01058dd:	68 cd 83 10 f0       	push   $0xf01083cd
f01058e2:	53                   	push   %ebx
f01058e3:	e8 e6 fd ff ff       	call   f01056ce <memcmp>
f01058e8:	83 c4 10             	add    $0x10,%esp
f01058eb:	85 c0                	test   %eax,%eax
f01058ed:	75 15                	jne    f0105904 <mpsearch1+0x81>
f01058ef:	89 da                	mov    %ebx,%edx
f01058f1:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01058f4:	0f b6 0a             	movzbl (%edx),%ecx
f01058f7:	01 c8                	add    %ecx,%eax
f01058f9:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01058fc:	39 d7                	cmp    %edx,%edi
f01058fe:	75 f4                	jne    f01058f4 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105900:	84 c0                	test   %al,%al
f0105902:	74 0e                	je     f0105912 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105904:	83 c3 10             	add    $0x10,%ebx
f0105907:	39 f3                	cmp    %esi,%ebx
f0105909:	72 cd                	jb     f01058d8 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010590b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105910:	eb 02                	jmp    f0105914 <mpsearch1+0x91>
f0105912:	89 d8                	mov    %ebx,%eax
}
f0105914:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105917:	5b                   	pop    %ebx
f0105918:	5e                   	pop    %esi
f0105919:	5f                   	pop    %edi
f010591a:	5d                   	pop    %ebp
f010591b:	c3                   	ret    

f010591c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010591c:	55                   	push   %ebp
f010591d:	89 e5                	mov    %esp,%ebp
f010591f:	57                   	push   %edi
f0105920:	56                   	push   %esi
f0105921:	53                   	push   %ebx
f0105922:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105925:	c7 05 c0 03 2a f0 20 	movl   $0xf02a0020,0xf02a03c0
f010592c:	00 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010592f:	83 3d a0 fe 29 f0 00 	cmpl   $0x0,0xf029fea0
f0105936:	75 16                	jne    f010594e <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105938:	68 00 04 00 00       	push   $0x400
f010593d:	68 44 68 10 f0       	push   $0xf0106844
f0105942:	6a 6f                	push   $0x6f
f0105944:	68 bd 83 10 f0       	push   $0xf01083bd
f0105949:	e8 f2 a6 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010594e:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105955:	85 c0                	test   %eax,%eax
f0105957:	74 16                	je     f010596f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105959:	c1 e0 04             	shl    $0x4,%eax
f010595c:	ba 00 04 00 00       	mov    $0x400,%edx
f0105961:	e8 1d ff ff ff       	call   f0105883 <mpsearch1>
f0105966:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105969:	85 c0                	test   %eax,%eax
f010596b:	75 3c                	jne    f01059a9 <mp_init+0x8d>
f010596d:	eb 20                	jmp    f010598f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010596f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105976:	c1 e0 0a             	shl    $0xa,%eax
f0105979:	2d 00 04 00 00       	sub    $0x400,%eax
f010597e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105983:	e8 fb fe ff ff       	call   f0105883 <mpsearch1>
f0105988:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010598b:	85 c0                	test   %eax,%eax
f010598d:	75 1a                	jne    f01059a9 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010598f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105994:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105999:	e8 e5 fe ff ff       	call   f0105883 <mpsearch1>
f010599e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01059a1:	85 c0                	test   %eax,%eax
f01059a3:	0f 84 5d 02 00 00    	je     f0105c06 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01059a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059ac:	8b 70 04             	mov    0x4(%eax),%esi
f01059af:	85 f6                	test   %esi,%esi
f01059b1:	74 06                	je     f01059b9 <mp_init+0x9d>
f01059b3:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01059b7:	74 15                	je     f01059ce <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01059b9:	83 ec 0c             	sub    $0xc,%esp
f01059bc:	68 30 82 10 f0       	push   $0xf0108230
f01059c1:	e8 5f dc ff ff       	call   f0103625 <cprintf>
f01059c6:	83 c4 10             	add    $0x10,%esp
f01059c9:	e9 38 02 00 00       	jmp    f0105c06 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059ce:	89 f0                	mov    %esi,%eax
f01059d0:	c1 e8 0c             	shr    $0xc,%eax
f01059d3:	3b 05 a0 fe 29 f0    	cmp    0xf029fea0,%eax
f01059d9:	72 15                	jb     f01059f0 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059db:	56                   	push   %esi
f01059dc:	68 44 68 10 f0       	push   $0xf0106844
f01059e1:	68 90 00 00 00       	push   $0x90
f01059e6:	68 bd 83 10 f0       	push   $0xf01083bd
f01059eb:	e8 50 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059f0:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059f6:	83 ec 04             	sub    $0x4,%esp
f01059f9:	6a 04                	push   $0x4
f01059fb:	68 d2 83 10 f0       	push   $0xf01083d2
f0105a00:	53                   	push   %ebx
f0105a01:	e8 c8 fc ff ff       	call   f01056ce <memcmp>
f0105a06:	83 c4 10             	add    $0x10,%esp
f0105a09:	85 c0                	test   %eax,%eax
f0105a0b:	74 15                	je     f0105a22 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105a0d:	83 ec 0c             	sub    $0xc,%esp
f0105a10:	68 60 82 10 f0       	push   $0xf0108260
f0105a15:	e8 0b dc ff ff       	call   f0103625 <cprintf>
f0105a1a:	83 c4 10             	add    $0x10,%esp
f0105a1d:	e9 e4 01 00 00       	jmp    f0105c06 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a22:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105a26:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105a2a:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a2d:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a32:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a37:	eb 0d                	jmp    f0105a46 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105a39:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105a40:	f0 
f0105a41:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a43:	83 c0 01             	add    $0x1,%eax
f0105a46:	39 c7                	cmp    %eax,%edi
f0105a48:	75 ef                	jne    f0105a39 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105a4a:	84 d2                	test   %dl,%dl
f0105a4c:	74 15                	je     f0105a63 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105a4e:	83 ec 0c             	sub    $0xc,%esp
f0105a51:	68 94 82 10 f0       	push   $0xf0108294
f0105a56:	e8 ca db ff ff       	call   f0103625 <cprintf>
f0105a5b:	83 c4 10             	add    $0x10,%esp
f0105a5e:	e9 a3 01 00 00       	jmp    f0105c06 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105a63:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105a67:	3c 01                	cmp    $0x1,%al
f0105a69:	74 1d                	je     f0105a88 <mp_init+0x16c>
f0105a6b:	3c 04                	cmp    $0x4,%al
f0105a6d:	74 19                	je     f0105a88 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105a6f:	83 ec 08             	sub    $0x8,%esp
f0105a72:	0f b6 c0             	movzbl %al,%eax
f0105a75:	50                   	push   %eax
f0105a76:	68 b8 82 10 f0       	push   $0xf01082b8
f0105a7b:	e8 a5 db ff ff       	call   f0103625 <cprintf>
f0105a80:	83 c4 10             	add    $0x10,%esp
f0105a83:	e9 7e 01 00 00       	jmp    f0105c06 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a88:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105a8c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105a90:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105a95:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105a9a:	01 ce                	add    %ecx,%esi
f0105a9c:	eb 0d                	jmp    f0105aab <mp_init+0x18f>
f0105a9e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105aa5:	f0 
f0105aa6:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105aa8:	83 c0 01             	add    $0x1,%eax
f0105aab:	39 c7                	cmp    %eax,%edi
f0105aad:	75 ef                	jne    f0105a9e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105aaf:	89 d0                	mov    %edx,%eax
f0105ab1:	02 43 2a             	add    0x2a(%ebx),%al
f0105ab4:	74 15                	je     f0105acb <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105ab6:	83 ec 0c             	sub    $0xc,%esp
f0105ab9:	68 d8 82 10 f0       	push   $0xf01082d8
f0105abe:	e8 62 db ff ff       	call   f0103625 <cprintf>
f0105ac3:	83 c4 10             	add    $0x10,%esp
f0105ac6:	e9 3b 01 00 00       	jmp    f0105c06 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105acb:	85 db                	test   %ebx,%ebx
f0105acd:	0f 84 33 01 00 00    	je     f0105c06 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105ad3:	c7 05 00 00 2a f0 01 	movl   $0x1,0xf02a0000
f0105ada:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105add:	8b 43 24             	mov    0x24(%ebx),%eax
f0105ae0:	a3 00 10 2e f0       	mov    %eax,0xf02e1000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ae5:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105ae8:	be 00 00 00 00       	mov    $0x0,%esi
f0105aed:	e9 85 00 00 00       	jmp    f0105b77 <mp_init+0x25b>
		switch (*p) {
f0105af2:	0f b6 07             	movzbl (%edi),%eax
f0105af5:	84 c0                	test   %al,%al
f0105af7:	74 06                	je     f0105aff <mp_init+0x1e3>
f0105af9:	3c 04                	cmp    $0x4,%al
f0105afb:	77 55                	ja     f0105b52 <mp_init+0x236>
f0105afd:	eb 4e                	jmp    f0105b4d <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105aff:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105b03:	74 11                	je     f0105b16 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105b05:	6b 05 c4 03 2a f0 74 	imul   $0x74,0xf02a03c4,%eax
f0105b0c:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f0105b11:	a3 c0 03 2a f0       	mov    %eax,0xf02a03c0
			if (ncpu < NCPU) {
f0105b16:	a1 c4 03 2a f0       	mov    0xf02a03c4,%eax
f0105b1b:	83 f8 07             	cmp    $0x7,%eax
f0105b1e:	7f 13                	jg     f0105b33 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105b20:	6b d0 74             	imul   $0x74,%eax,%edx
f0105b23:	88 82 20 00 2a f0    	mov    %al,-0xfd5ffe0(%edx)
				ncpu++;
f0105b29:	83 c0 01             	add    $0x1,%eax
f0105b2c:	a3 c4 03 2a f0       	mov    %eax,0xf02a03c4
f0105b31:	eb 15                	jmp    f0105b48 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105b33:	83 ec 08             	sub    $0x8,%esp
f0105b36:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105b3a:	50                   	push   %eax
f0105b3b:	68 08 83 10 f0       	push   $0xf0108308
f0105b40:	e8 e0 da ff ff       	call   f0103625 <cprintf>
f0105b45:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b48:	83 c7 14             	add    $0x14,%edi
			continue;
f0105b4b:	eb 27                	jmp    f0105b74 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b4d:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b50:	eb 22                	jmp    f0105b74 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b52:	83 ec 08             	sub    $0x8,%esp
f0105b55:	0f b6 c0             	movzbl %al,%eax
f0105b58:	50                   	push   %eax
f0105b59:	68 30 83 10 f0       	push   $0xf0108330
f0105b5e:	e8 c2 da ff ff       	call   f0103625 <cprintf>
			ismp = 0;
f0105b63:	c7 05 00 00 2a f0 00 	movl   $0x0,0xf02a0000
f0105b6a:	00 00 00 
			i = conf->entry;
f0105b6d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105b71:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b74:	83 c6 01             	add    $0x1,%esi
f0105b77:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105b7b:	39 c6                	cmp    %eax,%esi
f0105b7d:	0f 82 6f ff ff ff    	jb     f0105af2 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105b83:	a1 c0 03 2a f0       	mov    0xf02a03c0,%eax
f0105b88:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105b8f:	83 3d 00 00 2a f0 00 	cmpl   $0x0,0xf02a0000
f0105b96:	75 26                	jne    f0105bbe <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105b98:	c7 05 c4 03 2a f0 01 	movl   $0x1,0xf02a03c4
f0105b9f:	00 00 00 
		lapicaddr = 0;
f0105ba2:	c7 05 00 10 2e f0 00 	movl   $0x0,0xf02e1000
f0105ba9:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105bac:	83 ec 0c             	sub    $0xc,%esp
f0105baf:	68 50 83 10 f0       	push   $0xf0108350
f0105bb4:	e8 6c da ff ff       	call   f0103625 <cprintf>
		return;
f0105bb9:	83 c4 10             	add    $0x10,%esp
f0105bbc:	eb 48                	jmp    f0105c06 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105bbe:	83 ec 04             	sub    $0x4,%esp
f0105bc1:	ff 35 c4 03 2a f0    	pushl  0xf02a03c4
f0105bc7:	0f b6 00             	movzbl (%eax),%eax
f0105bca:	50                   	push   %eax
f0105bcb:	68 d7 83 10 f0       	push   $0xf01083d7
f0105bd0:	e8 50 da ff ff       	call   f0103625 <cprintf>

	if (mp->imcrp) {
f0105bd5:	83 c4 10             	add    $0x10,%esp
f0105bd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105bdb:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105bdf:	74 25                	je     f0105c06 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105be1:	83 ec 0c             	sub    $0xc,%esp
f0105be4:	68 7c 83 10 f0       	push   $0xf010837c
f0105be9:	e8 37 da ff ff       	call   f0103625 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bee:	ba 22 00 00 00       	mov    $0x22,%edx
f0105bf3:	b8 70 00 00 00       	mov    $0x70,%eax
f0105bf8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105bf9:	ba 23 00 00 00       	mov    $0x23,%edx
f0105bfe:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105bff:	83 c8 01             	or     $0x1,%eax
f0105c02:	ee                   	out    %al,(%dx)
f0105c03:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105c06:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c09:	5b                   	pop    %ebx
f0105c0a:	5e                   	pop    %esi
f0105c0b:	5f                   	pop    %edi
f0105c0c:	5d                   	pop    %ebp
f0105c0d:	c3                   	ret    

f0105c0e <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105c0e:	55                   	push   %ebp
f0105c0f:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105c11:	8b 0d 04 10 2e f0    	mov    0xf02e1004,%ecx
f0105c17:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105c1a:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105c1c:	a1 04 10 2e f0       	mov    0xf02e1004,%eax
f0105c21:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105c24:	5d                   	pop    %ebp
f0105c25:	c3                   	ret    

f0105c26 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105c26:	55                   	push   %ebp
f0105c27:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105c29:	a1 04 10 2e f0       	mov    0xf02e1004,%eax
f0105c2e:	85 c0                	test   %eax,%eax
f0105c30:	74 08                	je     f0105c3a <cpunum+0x14>
		return lapic[ID] >> 24;
f0105c32:	8b 40 20             	mov    0x20(%eax),%eax
f0105c35:	c1 e8 18             	shr    $0x18,%eax
f0105c38:	eb 05                	jmp    f0105c3f <cpunum+0x19>
	return 0;
f0105c3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c3f:	5d                   	pop    %ebp
f0105c40:	c3                   	ret    

f0105c41 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105c41:	a1 00 10 2e f0       	mov    0xf02e1000,%eax
f0105c46:	85 c0                	test   %eax,%eax
f0105c48:	0f 84 21 01 00 00    	je     f0105d6f <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105c4e:	55                   	push   %ebp
f0105c4f:	89 e5                	mov    %esp,%ebp
f0105c51:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c54:	68 00 10 00 00       	push   $0x1000
f0105c59:	50                   	push   %eax
f0105c5a:	e8 19 b6 ff ff       	call   f0101278 <mmio_map_region>
f0105c5f:	a3 04 10 2e f0       	mov    %eax,0xf02e1004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c64:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c69:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c6e:	e8 9b ff ff ff       	call   f0105c0e <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105c73:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105c78:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105c7d:	e8 8c ff ff ff       	call   f0105c0e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105c82:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105c87:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105c8c:	e8 7d ff ff ff       	call   f0105c0e <lapicw>
	lapicw(TICR, 10000000); 
f0105c91:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105c96:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105c9b:	e8 6e ff ff ff       	call   f0105c0e <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105ca0:	e8 81 ff ff ff       	call   f0105c26 <cpunum>
f0105ca5:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ca8:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f0105cad:	83 c4 10             	add    $0x10,%esp
f0105cb0:	39 05 c0 03 2a f0    	cmp    %eax,0xf02a03c0
f0105cb6:	74 0f                	je     f0105cc7 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105cb8:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cbd:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105cc2:	e8 47 ff ff ff       	call   f0105c0e <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105cc7:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ccc:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105cd1:	e8 38 ff ff ff       	call   f0105c0e <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105cd6:	a1 04 10 2e f0       	mov    0xf02e1004,%eax
f0105cdb:	8b 40 30             	mov    0x30(%eax),%eax
f0105cde:	c1 e8 10             	shr    $0x10,%eax
f0105ce1:	3c 03                	cmp    $0x3,%al
f0105ce3:	76 0f                	jbe    f0105cf4 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105ce5:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cea:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105cef:	e8 1a ff ff ff       	call   f0105c0e <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105cf4:	ba 33 00 00 00       	mov    $0x33,%edx
f0105cf9:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105cfe:	e8 0b ff ff ff       	call   f0105c0e <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105d03:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d08:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d0d:	e8 fc fe ff ff       	call   f0105c0e <lapicw>
	lapicw(ESR, 0);
f0105d12:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d17:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d1c:	e8 ed fe ff ff       	call   f0105c0e <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105d21:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d26:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d2b:	e8 de fe ff ff       	call   f0105c0e <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105d30:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d35:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d3a:	e8 cf fe ff ff       	call   f0105c0e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d3f:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d44:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d49:	e8 c0 fe ff ff       	call   f0105c0e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d4e:	8b 15 04 10 2e f0    	mov    0xf02e1004,%edx
f0105d54:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d5a:	f6 c4 10             	test   $0x10,%ah
f0105d5d:	75 f5                	jne    f0105d54 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105d5f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d64:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d69:	e8 a0 fe ff ff       	call   f0105c0e <lapicw>
}
f0105d6e:	c9                   	leave  
f0105d6f:	f3 c3                	repz ret 

f0105d71 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d71:	83 3d 04 10 2e f0 00 	cmpl   $0x0,0xf02e1004
f0105d78:	74 13                	je     f0105d8d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105d7a:	55                   	push   %ebp
f0105d7b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105d7d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d82:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d87:	e8 82 fe ff ff       	call   f0105c0e <lapicw>
}
f0105d8c:	5d                   	pop    %ebp
f0105d8d:	f3 c3                	repz ret 

f0105d8f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105d8f:	55                   	push   %ebp
f0105d90:	89 e5                	mov    %esp,%ebp
f0105d92:	56                   	push   %esi
f0105d93:	53                   	push   %ebx
f0105d94:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105d9a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105d9f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105da4:	ee                   	out    %al,(%dx)
f0105da5:	ba 71 00 00 00       	mov    $0x71,%edx
f0105daa:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105daf:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105db0:	83 3d a0 fe 29 f0 00 	cmpl   $0x0,0xf029fea0
f0105db7:	75 19                	jne    f0105dd2 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105db9:	68 67 04 00 00       	push   $0x467
f0105dbe:	68 44 68 10 f0       	push   $0xf0106844
f0105dc3:	68 98 00 00 00       	push   $0x98
f0105dc8:	68 f4 83 10 f0       	push   $0xf01083f4
f0105dcd:	e8 6e a2 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105dd2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105dd9:	00 00 
	wrv[1] = addr >> 4;
f0105ddb:	89 d8                	mov    %ebx,%eax
f0105ddd:	c1 e8 04             	shr    $0x4,%eax
f0105de0:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105de6:	c1 e6 18             	shl    $0x18,%esi
f0105de9:	89 f2                	mov    %esi,%edx
f0105deb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105df0:	e8 19 fe ff ff       	call   f0105c0e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105df5:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105dfa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105dff:	e8 0a fe ff ff       	call   f0105c0e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105e04:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105e09:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e0e:	e8 fb fd ff ff       	call   f0105c0e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e13:	c1 eb 0c             	shr    $0xc,%ebx
f0105e16:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105e19:	89 f2                	mov    %esi,%edx
f0105e1b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e20:	e8 e9 fd ff ff       	call   f0105c0e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e25:	89 da                	mov    %ebx,%edx
f0105e27:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e2c:	e8 dd fd ff ff       	call   f0105c0e <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105e31:	89 f2                	mov    %esi,%edx
f0105e33:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e38:	e8 d1 fd ff ff       	call   f0105c0e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e3d:	89 da                	mov    %ebx,%edx
f0105e3f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e44:	e8 c5 fd ff ff       	call   f0105c0e <lapicw>
		microdelay(200);
	}
}
f0105e49:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e4c:	5b                   	pop    %ebx
f0105e4d:	5e                   	pop    %esi
f0105e4e:	5d                   	pop    %ebp
f0105e4f:	c3                   	ret    

f0105e50 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e50:	55                   	push   %ebp
f0105e51:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e53:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e56:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e5c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e61:	e8 a8 fd ff ff       	call   f0105c0e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e66:	8b 15 04 10 2e f0    	mov    0xf02e1004,%edx
f0105e6c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e72:	f6 c4 10             	test   $0x10,%ah
f0105e75:	75 f5                	jne    f0105e6c <lapic_ipi+0x1c>
		;
}
f0105e77:	5d                   	pop    %ebp
f0105e78:	c3                   	ret    

f0105e79 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105e79:	55                   	push   %ebp
f0105e7a:	89 e5                	mov    %esp,%ebp
f0105e7c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105e7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105e85:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e88:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105e8b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105e92:	5d                   	pop    %ebp
f0105e93:	c3                   	ret    

f0105e94 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105e94:	55                   	push   %ebp
f0105e95:	89 e5                	mov    %esp,%ebp
f0105e97:	56                   	push   %esi
f0105e98:	53                   	push   %ebx
f0105e99:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e9c:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105e9f:	74 14                	je     f0105eb5 <spin_lock+0x21>
f0105ea1:	8b 73 08             	mov    0x8(%ebx),%esi
f0105ea4:	e8 7d fd ff ff       	call   f0105c26 <cpunum>
f0105ea9:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eac:	05 20 00 2a f0       	add    $0xf02a0020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105eb1:	39 c6                	cmp    %eax,%esi
f0105eb3:	74 07                	je     f0105ebc <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105eb5:	ba 01 00 00 00       	mov    $0x1,%edx
f0105eba:	eb 20                	jmp    f0105edc <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105ebc:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105ebf:	e8 62 fd ff ff       	call   f0105c26 <cpunum>
f0105ec4:	83 ec 0c             	sub    $0xc,%esp
f0105ec7:	53                   	push   %ebx
f0105ec8:	50                   	push   %eax
f0105ec9:	68 04 84 10 f0       	push   $0xf0108404
f0105ece:	6a 41                	push   $0x41
f0105ed0:	68 66 84 10 f0       	push   $0xf0108466
f0105ed5:	e8 66 a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105eda:	f3 90                	pause  
f0105edc:	89 d0                	mov    %edx,%eax
f0105ede:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105ee1:	85 c0                	test   %eax,%eax
f0105ee3:	75 f5                	jne    f0105eda <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105ee5:	e8 3c fd ff ff       	call   f0105c26 <cpunum>
f0105eea:	6b c0 74             	imul   $0x74,%eax,%eax
f0105eed:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f0105ef2:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105ef5:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105ef8:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105efa:	b8 00 00 00 00       	mov    $0x0,%eax
f0105eff:	eb 0b                	jmp    f0105f0c <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105f01:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105f04:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105f07:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105f09:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105f0c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105f12:	76 11                	jbe    f0105f25 <spin_lock+0x91>
f0105f14:	83 f8 09             	cmp    $0x9,%eax
f0105f17:	7e e8                	jle    f0105f01 <spin_lock+0x6d>
f0105f19:	eb 0a                	jmp    f0105f25 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105f1b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105f22:	83 c0 01             	add    $0x1,%eax
f0105f25:	83 f8 09             	cmp    $0x9,%eax
f0105f28:	7e f1                	jle    f0105f1b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105f2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f2d:	5b                   	pop    %ebx
f0105f2e:	5e                   	pop    %esi
f0105f2f:	5d                   	pop    %ebp
f0105f30:	c3                   	ret    

f0105f31 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105f31:	55                   	push   %ebp
f0105f32:	89 e5                	mov    %esp,%ebp
f0105f34:	57                   	push   %edi
f0105f35:	56                   	push   %esi
f0105f36:	53                   	push   %ebx
f0105f37:	83 ec 4c             	sub    $0x4c,%esp
f0105f3a:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f3d:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f40:	74 18                	je     f0105f5a <spin_unlock+0x29>
f0105f42:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105f45:	e8 dc fc ff ff       	call   f0105c26 <cpunum>
f0105f4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f4d:	05 20 00 2a f0       	add    $0xf02a0020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105f52:	39 c3                	cmp    %eax,%ebx
f0105f54:	0f 84 a5 00 00 00    	je     f0105fff <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f5a:	83 ec 04             	sub    $0x4,%esp
f0105f5d:	6a 28                	push   $0x28
f0105f5f:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f62:	50                   	push   %eax
f0105f63:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f66:	53                   	push   %ebx
f0105f67:	e8 e7 f6 ff ff       	call   f0105653 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f6c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f6f:	0f b6 38             	movzbl (%eax),%edi
f0105f72:	8b 76 04             	mov    0x4(%esi),%esi
f0105f75:	e8 ac fc ff ff       	call   f0105c26 <cpunum>
f0105f7a:	57                   	push   %edi
f0105f7b:	56                   	push   %esi
f0105f7c:	50                   	push   %eax
f0105f7d:	68 30 84 10 f0       	push   $0xf0108430
f0105f82:	e8 9e d6 ff ff       	call   f0103625 <cprintf>
f0105f87:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105f8a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105f8d:	eb 54                	jmp    f0105fe3 <spin_unlock+0xb2>
f0105f8f:	83 ec 08             	sub    $0x8,%esp
f0105f92:	57                   	push   %edi
f0105f93:	50                   	push   %eax
f0105f94:	e8 c3 eb ff ff       	call   f0104b5c <debuginfo_eip>
f0105f99:	83 c4 10             	add    $0x10,%esp
f0105f9c:	85 c0                	test   %eax,%eax
f0105f9e:	78 27                	js     f0105fc7 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105fa0:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105fa2:	83 ec 04             	sub    $0x4,%esp
f0105fa5:	89 c2                	mov    %eax,%edx
f0105fa7:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105faa:	52                   	push   %edx
f0105fab:	ff 75 b0             	pushl  -0x50(%ebp)
f0105fae:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105fb1:	ff 75 ac             	pushl  -0x54(%ebp)
f0105fb4:	ff 75 a8             	pushl  -0x58(%ebp)
f0105fb7:	50                   	push   %eax
f0105fb8:	68 76 84 10 f0       	push   $0xf0108476
f0105fbd:	e8 63 d6 ff ff       	call   f0103625 <cprintf>
f0105fc2:	83 c4 20             	add    $0x20,%esp
f0105fc5:	eb 12                	jmp    f0105fd9 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105fc7:	83 ec 08             	sub    $0x8,%esp
f0105fca:	ff 36                	pushl  (%esi)
f0105fcc:	68 8d 84 10 f0       	push   $0xf010848d
f0105fd1:	e8 4f d6 ff ff       	call   f0103625 <cprintf>
f0105fd6:	83 c4 10             	add    $0x10,%esp
f0105fd9:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105fdc:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105fdf:	39 c3                	cmp    %eax,%ebx
f0105fe1:	74 08                	je     f0105feb <spin_unlock+0xba>
f0105fe3:	89 de                	mov    %ebx,%esi
f0105fe5:	8b 03                	mov    (%ebx),%eax
f0105fe7:	85 c0                	test   %eax,%eax
f0105fe9:	75 a4                	jne    f0105f8f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105feb:	83 ec 04             	sub    $0x4,%esp
f0105fee:	68 95 84 10 f0       	push   $0xf0108495
f0105ff3:	6a 67                	push   $0x67
f0105ff5:	68 66 84 10 f0       	push   $0xf0108466
f0105ffa:	e8 41 a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105fff:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106006:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010600d:	b8 00 00 00 00       	mov    $0x0,%eax
f0106012:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106015:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106018:	5b                   	pop    %ebx
f0106019:	5e                   	pop    %esi
f010601a:	5f                   	pop    %edi
f010601b:	5d                   	pop    %ebp
f010601c:	c3                   	ret    

f010601d <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f010601d:	55                   	push   %ebp
f010601e:	89 e5                	mov    %esp,%ebp
f0106020:	57                   	push   %edi
f0106021:	56                   	push   %esi
f0106022:	53                   	push   %ebx
f0106023:	83 ec 0c             	sub    $0xc,%esp
f0106026:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106029:	8b 45 10             	mov    0x10(%ebp),%eax
f010602c:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f010602f:	eb 3a                	jmp    f010606b <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0106031:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f0106034:	75 32                	jne    f0106068 <pci_attach_match+0x4b>
f0106036:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106039:	39 56 fc             	cmp    %edx,-0x4(%esi)
f010603c:	75 2a                	jne    f0106068 <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f010603e:	83 ec 0c             	sub    $0xc,%esp
f0106041:	ff 75 14             	pushl  0x14(%ebp)
f0106044:	ff d0                	call   *%eax
			if (r > 0)
f0106046:	83 c4 10             	add    $0x10,%esp
f0106049:	85 c0                	test   %eax,%eax
f010604b:	7f 26                	jg     f0106073 <pci_attach_match+0x56>
				return r;
			if (r < 0)
f010604d:	85 c0                	test   %eax,%eax
f010604f:	79 17                	jns    f0106068 <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f0106051:	83 ec 0c             	sub    $0xc,%esp
f0106054:	50                   	push   %eax
f0106055:	ff 36                	pushl  (%esi)
f0106057:	ff 75 0c             	pushl  0xc(%ebp)
f010605a:	57                   	push   %edi
f010605b:	68 b0 84 10 f0       	push   $0xf01084b0
f0106060:	e8 c0 d5 ff ff       	call   f0103625 <cprintf>
f0106065:	83 c4 20             	add    $0x20,%esp
f0106068:	83 c3 0c             	add    $0xc,%ebx
f010606b:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f010606d:	8b 03                	mov    (%ebx),%eax
f010606f:	85 c0                	test   %eax,%eax
f0106071:	75 be                	jne    f0106031 <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0106073:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106076:	5b                   	pop    %ebx
f0106077:	5e                   	pop    %esi
f0106078:	5f                   	pop    %edi
f0106079:	5d                   	pop    %ebp
f010607a:	c3                   	ret    

f010607b <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f010607b:	55                   	push   %ebp
f010607c:	89 e5                	mov    %esp,%ebp
f010607e:	53                   	push   %ebx
f010607f:	83 ec 04             	sub    $0x4,%esp
f0106082:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f0106085:	3d ff 00 00 00       	cmp    $0xff,%eax
f010608a:	76 16                	jbe    f01060a2 <pci_conf1_set_addr+0x27>
f010608c:	68 08 86 10 f0       	push   $0xf0108608
f0106091:	68 3b 77 10 f0       	push   $0xf010773b
f0106096:	6a 2b                	push   $0x2b
f0106098:	68 12 86 10 f0       	push   $0xf0108612
f010609d:	e8 9e 9f ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f01060a2:	83 fa 1f             	cmp    $0x1f,%edx
f01060a5:	76 16                	jbe    f01060bd <pci_conf1_set_addr+0x42>
f01060a7:	68 1d 86 10 f0       	push   $0xf010861d
f01060ac:	68 3b 77 10 f0       	push   $0xf010773b
f01060b1:	6a 2c                	push   $0x2c
f01060b3:	68 12 86 10 f0       	push   $0xf0108612
f01060b8:	e8 83 9f ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f01060bd:	83 f9 07             	cmp    $0x7,%ecx
f01060c0:	76 16                	jbe    f01060d8 <pci_conf1_set_addr+0x5d>
f01060c2:	68 26 86 10 f0       	push   $0xf0108626
f01060c7:	68 3b 77 10 f0       	push   $0xf010773b
f01060cc:	6a 2d                	push   $0x2d
f01060ce:	68 12 86 10 f0       	push   $0xf0108612
f01060d3:	e8 68 9f ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f01060d8:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f01060de:	76 16                	jbe    f01060f6 <pci_conf1_set_addr+0x7b>
f01060e0:	68 2f 86 10 f0       	push   $0xf010862f
f01060e5:	68 3b 77 10 f0       	push   $0xf010773b
f01060ea:	6a 2e                	push   $0x2e
f01060ec:	68 12 86 10 f0       	push   $0xf0108612
f01060f1:	e8 4a 9f ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f01060f6:	f6 c3 03             	test   $0x3,%bl
f01060f9:	74 16                	je     f0106111 <pci_conf1_set_addr+0x96>
f01060fb:	68 3c 86 10 f0       	push   $0xf010863c
f0106100:	68 3b 77 10 f0       	push   $0xf010773b
f0106105:	6a 2f                	push   $0x2f
f0106107:	68 12 86 10 f0       	push   $0xf0108612
f010610c:	e8 2f 9f ff ff       	call   f0100040 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0106111:	c1 e1 08             	shl    $0x8,%ecx
f0106114:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f010611a:	09 cb                	or     %ecx,%ebx
f010611c:	c1 e2 0b             	shl    $0xb,%edx
f010611f:	09 d3                	or     %edx,%ebx
f0106121:	c1 e0 10             	shl    $0x10,%eax
f0106124:	09 d8                	or     %ebx,%eax
f0106126:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f010612b:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f010612c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010612f:	c9                   	leave  
f0106130:	c3                   	ret    

f0106131 <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0106131:	55                   	push   %ebp
f0106132:	89 e5                	mov    %esp,%ebp
f0106134:	53                   	push   %ebx
f0106135:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0106138:	8b 48 08             	mov    0x8(%eax),%ecx
f010613b:	8b 58 04             	mov    0x4(%eax),%ebx
f010613e:	8b 00                	mov    (%eax),%eax
f0106140:	8b 40 04             	mov    0x4(%eax),%eax
f0106143:	52                   	push   %edx
f0106144:	89 da                	mov    %ebx,%edx
f0106146:	e8 30 ff ff ff       	call   f010607b <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f010614b:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0106150:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0106151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0106154:	c9                   	leave  
f0106155:	c3                   	ret    

f0106156 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f0106156:	55                   	push   %ebp
f0106157:	89 e5                	mov    %esp,%ebp
f0106159:	57                   	push   %edi
f010615a:	56                   	push   %esi
f010615b:	53                   	push   %ebx
f010615c:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0106162:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0106164:	6a 48                	push   $0x48
f0106166:	6a 00                	push   $0x0
f0106168:	8d 45 a0             	lea    -0x60(%ebp),%eax
f010616b:	50                   	push   %eax
f010616c:	e8 95 f4 ff ff       	call   f0105606 <memset>
	df.bus = bus;
f0106171:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0106174:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f010617b:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f010617e:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f0106185:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0106188:	ba 0c 00 00 00       	mov    $0xc,%edx
f010618d:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0106190:	e8 9c ff ff ff       	call   f0106131 <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0106195:	89 c2                	mov    %eax,%edx
f0106197:	c1 ea 10             	shr    $0x10,%edx
f010619a:	83 e2 7f             	and    $0x7f,%edx
f010619d:	83 fa 01             	cmp    $0x1,%edx
f01061a0:	0f 87 4b 01 00 00    	ja     f01062f1 <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f01061a6:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f01061ad:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f01061b3:	8d 75 a0             	lea    -0x60(%ebp),%esi
f01061b6:	b9 12 00 00 00       	mov    $0x12,%ecx
f01061bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01061bd:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f01061c4:	00 00 00 
f01061c7:	25 00 00 80 00       	and    $0x800000,%eax
f01061cc:	83 f8 01             	cmp    $0x1,%eax
f01061cf:	19 c0                	sbb    %eax,%eax
f01061d1:	83 e0 f9             	and    $0xfffffff9,%eax
f01061d4:	83 c0 08             	add    $0x8,%eax
f01061d7:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f01061dd:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01061e3:	e9 f7 00 00 00       	jmp    f01062df <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f01061e8:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f01061ee:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f01061f4:	b9 12 00 00 00       	mov    $0x12,%ecx
f01061f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f01061fb:	ba 00 00 00 00       	mov    $0x0,%edx
f0106200:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0106206:	e8 26 ff ff ff       	call   f0106131 <pci_conf_read>
f010620b:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0106211:	66 83 f8 ff          	cmp    $0xffff,%ax
f0106215:	0f 84 bd 00 00 00    	je     f01062d8 <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f010621b:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0106220:	89 d8                	mov    %ebx,%eax
f0106222:	e8 0a ff ff ff       	call   f0106131 <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0106227:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f010622a:	ba 08 00 00 00       	mov    $0x8,%edx
f010622f:	89 d8                	mov    %ebx,%eax
f0106231:	e8 fb fe ff ff       	call   f0106131 <pci_conf_read>
f0106236:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f010623c:	89 c1                	mov    %eax,%ecx
f010623e:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f0106241:	be 50 86 10 f0       	mov    $0xf0108650,%esi
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f0106246:	83 f9 06             	cmp    $0x6,%ecx
f0106249:	77 07                	ja     f0106252 <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f010624b:	8b 34 8d c4 86 10 f0 	mov    -0xfef793c(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0106252:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0106258:	83 ec 08             	sub    $0x8,%esp
f010625b:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f010625f:	57                   	push   %edi
f0106260:	56                   	push   %esi
f0106261:	c1 e8 10             	shr    $0x10,%eax
f0106264:	0f b6 c0             	movzbl %al,%eax
f0106267:	50                   	push   %eax
f0106268:	51                   	push   %ecx
f0106269:	89 d0                	mov    %edx,%eax
f010626b:	c1 e8 10             	shr    $0x10,%eax
f010626e:	50                   	push   %eax
f010626f:	0f b7 d2             	movzwl %dx,%edx
f0106272:	52                   	push   %edx
f0106273:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f0106279:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f010627f:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0106285:	ff 70 04             	pushl  0x4(%eax)
f0106288:	68 dc 84 10 f0       	push   $0xf01084dc
f010628d:	e8 93 d3 ff ff       	call   f0103625 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f0106292:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0106298:	83 c4 30             	add    $0x30,%esp
f010629b:	53                   	push   %ebx
f010629c:	68 f4 23 12 f0       	push   $0xf01223f4
f01062a1:	89 c2                	mov    %eax,%edx
f01062a3:	c1 ea 10             	shr    $0x10,%edx
f01062a6:	0f b6 d2             	movzbl %dl,%edx
f01062a9:	52                   	push   %edx
f01062aa:	c1 e8 18             	shr    $0x18,%eax
f01062ad:	50                   	push   %eax
f01062ae:	e8 6a fd ff ff       	call   f010601d <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f01062b3:	83 c4 10             	add    $0x10,%esp
f01062b6:	85 c0                	test   %eax,%eax
f01062b8:	75 1e                	jne    f01062d8 <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f01062ba:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f01062c0:	53                   	push   %ebx
f01062c1:	68 80 fe 29 f0       	push   $0xf029fe80
f01062c6:	89 c2                	mov    %eax,%edx
f01062c8:	c1 ea 10             	shr    $0x10,%edx
f01062cb:	52                   	push   %edx
f01062cc:	0f b7 c0             	movzwl %ax,%eax
f01062cf:	50                   	push   %eax
f01062d0:	e8 48 fd ff ff       	call   f010601d <pci_attach_match>
f01062d5:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f01062d8:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01062df:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f01062e5:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f01062eb:	0f 87 f7 fe ff ff    	ja     f01061e8 <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01062f1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01062f4:	83 c0 01             	add    $0x1,%eax
f01062f7:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01062fa:	83 f8 1f             	cmp    $0x1f,%eax
f01062fd:	0f 86 85 fe ff ff    	jbe    f0106188 <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0106303:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0106309:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010630c:	5b                   	pop    %ebx
f010630d:	5e                   	pop    %esi
f010630e:	5f                   	pop    %edi
f010630f:	5d                   	pop    %ebp
f0106310:	c3                   	ret    

f0106311 <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0106311:	55                   	push   %ebp
f0106312:	89 e5                	mov    %esp,%ebp
f0106314:	57                   	push   %edi
f0106315:	56                   	push   %esi
f0106316:	53                   	push   %ebx
f0106317:	83 ec 1c             	sub    $0x1c,%esp
f010631a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f010631d:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0106322:	89 d8                	mov    %ebx,%eax
f0106324:	e8 08 fe ff ff       	call   f0106131 <pci_conf_read>
f0106329:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f010632b:	ba 18 00 00 00       	mov    $0x18,%edx
f0106330:	89 d8                	mov    %ebx,%eax
f0106332:	e8 fa fd ff ff       	call   f0106131 <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0106337:	83 e7 0f             	and    $0xf,%edi
f010633a:	83 ff 01             	cmp    $0x1,%edi
f010633d:	75 1f                	jne    f010635e <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f010633f:	ff 73 08             	pushl  0x8(%ebx)
f0106342:	ff 73 04             	pushl  0x4(%ebx)
f0106345:	8b 03                	mov    (%ebx),%eax
f0106347:	ff 70 04             	pushl  0x4(%eax)
f010634a:	68 18 85 10 f0       	push   $0xf0108518
f010634f:	e8 d1 d2 ff ff       	call   f0103625 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0106354:	83 c4 10             	add    $0x10,%esp
f0106357:	b8 00 00 00 00       	mov    $0x0,%eax
f010635c:	eb 4e                	jmp    f01063ac <pci_bridge_attach+0x9b>
f010635e:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0106360:	83 ec 04             	sub    $0x4,%esp
f0106363:	6a 08                	push   $0x8
f0106365:	6a 00                	push   $0x0
f0106367:	8d 7d e0             	lea    -0x20(%ebp),%edi
f010636a:	57                   	push   %edi
f010636b:	e8 96 f2 ff ff       	call   f0105606 <memset>
	nbus.parent_bridge = pcif;
f0106370:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0106373:	89 f0                	mov    %esi,%eax
f0106375:	0f b6 c4             	movzbl %ah,%eax
f0106378:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f010637b:	83 c4 08             	add    $0x8,%esp
f010637e:	89 f2                	mov    %esi,%edx
f0106380:	c1 ea 10             	shr    $0x10,%edx
f0106383:	0f b6 f2             	movzbl %dl,%esi
f0106386:	56                   	push   %esi
f0106387:	50                   	push   %eax
f0106388:	ff 73 08             	pushl  0x8(%ebx)
f010638b:	ff 73 04             	pushl  0x4(%ebx)
f010638e:	8b 03                	mov    (%ebx),%eax
f0106390:	ff 70 04             	pushl  0x4(%eax)
f0106393:	68 4c 85 10 f0       	push   $0xf010854c
f0106398:	e8 88 d2 ff ff       	call   f0103625 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f010639d:	83 c4 20             	add    $0x20,%esp
f01063a0:	89 f8                	mov    %edi,%eax
f01063a2:	e8 af fd ff ff       	call   f0106156 <pci_scan_bus>
	return 1;
f01063a7:	b8 01 00 00 00       	mov    $0x1,%eax
}
f01063ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01063af:	5b                   	pop    %ebx
f01063b0:	5e                   	pop    %esi
f01063b1:	5f                   	pop    %edi
f01063b2:	5d                   	pop    %ebp
f01063b3:	c3                   	ret    

f01063b4 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f01063b4:	55                   	push   %ebp
f01063b5:	89 e5                	mov    %esp,%ebp
f01063b7:	56                   	push   %esi
f01063b8:	53                   	push   %ebx
f01063b9:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01063bb:	8b 48 08             	mov    0x8(%eax),%ecx
f01063be:	8b 70 04             	mov    0x4(%eax),%esi
f01063c1:	8b 00                	mov    (%eax),%eax
f01063c3:	8b 40 04             	mov    0x4(%eax),%eax
f01063c6:	83 ec 0c             	sub    $0xc,%esp
f01063c9:	52                   	push   %edx
f01063ca:	89 f2                	mov    %esi,%edx
f01063cc:	e8 aa fc ff ff       	call   f010607b <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f01063d1:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01063d6:	89 d8                	mov    %ebx,%eax
f01063d8:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f01063d9:	83 c4 10             	add    $0x10,%esp
f01063dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01063df:	5b                   	pop    %ebx
f01063e0:	5e                   	pop    %esi
f01063e1:	5d                   	pop    %ebp
f01063e2:	c3                   	ret    

f01063e3 <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f01063e3:	55                   	push   %ebp
f01063e4:	89 e5                	mov    %esp,%ebp
f01063e6:	57                   	push   %edi
f01063e7:	56                   	push   %esi
f01063e8:	53                   	push   %ebx
f01063e9:	83 ec 1c             	sub    $0x1c,%esp
f01063ec:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f01063ef:	b9 07 00 00 00       	mov    $0x7,%ecx
f01063f4:	ba 04 00 00 00       	mov    $0x4,%edx
f01063f9:	89 f8                	mov    %edi,%eax
f01063fb:	e8 b4 ff ff ff       	call   f01063b4 <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0106400:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0106405:	89 f2                	mov    %esi,%edx
f0106407:	89 f8                	mov    %edi,%eax
f0106409:	e8 23 fd ff ff       	call   f0106131 <pci_conf_read>
f010640e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0106411:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0106416:	89 f2                	mov    %esi,%edx
f0106418:	89 f8                	mov    %edi,%eax
f010641a:	e8 95 ff ff ff       	call   f01063b4 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f010641f:	89 f2                	mov    %esi,%edx
f0106421:	89 f8                	mov    %edi,%eax
f0106423:	e8 09 fd ff ff       	call   f0106131 <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106428:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f010642d:	85 c0                	test   %eax,%eax
f010642f:	0f 84 a6 00 00 00    	je     f01064db <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0106435:	8d 56 f0             	lea    -0x10(%esi),%edx
f0106438:	c1 ea 02             	shr    $0x2,%edx
f010643b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f010643e:	a8 01                	test   $0x1,%al
f0106440:	75 2c                	jne    f010646e <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0106442:	89 c2                	mov    %eax,%edx
f0106444:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f0106447:	83 fa 04             	cmp    $0x4,%edx
f010644a:	0f 94 c3             	sete   %bl
f010644d:	0f b6 db             	movzbl %bl,%ebx
f0106450:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f0106457:	83 e0 f0             	and    $0xfffffff0,%eax
f010645a:	89 c2                	mov    %eax,%edx
f010645c:	f7 da                	neg    %edx
f010645e:	21 c2                	and    %eax,%edx
f0106460:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0106463:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106466:	83 e0 f0             	and    $0xfffffff0,%eax
f0106469:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010646c:	eb 1a                	jmp    f0106488 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f010646e:	83 e0 fc             	and    $0xfffffffc,%eax
f0106471:	89 c2                	mov    %eax,%edx
f0106473:	f7 da                	neg    %edx
f0106475:	21 c2                	and    %eax,%edx
f0106477:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f010647a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010647d:	83 e0 fc             	and    $0xfffffffc,%eax
f0106480:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0106483:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0106488:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010648b:	89 f2                	mov    %esi,%edx
f010648d:	89 f8                	mov    %edi,%eax
f010648f:	e8 20 ff ff ff       	call   f01063b4 <pci_conf_write>
f0106494:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0106497:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f010649a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010649d:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f01064a0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01064a3:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f01064a6:	85 c9                	test   %ecx,%ecx
f01064a8:	74 31                	je     f01064db <pci_func_enable+0xf8>
f01064aa:	85 d2                	test   %edx,%edx
f01064ac:	75 2d                	jne    f01064db <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f01064ae:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f01064b1:	83 ec 0c             	sub    $0xc,%esp
f01064b4:	51                   	push   %ecx
f01064b5:	52                   	push   %edx
f01064b6:	ff 75 e0             	pushl  -0x20(%ebp)
f01064b9:	89 c2                	mov    %eax,%edx
f01064bb:	c1 ea 10             	shr    $0x10,%edx
f01064be:	52                   	push   %edx
f01064bf:	0f b7 c0             	movzwl %ax,%eax
f01064c2:	50                   	push   %eax
f01064c3:	ff 77 08             	pushl  0x8(%edi)
f01064c6:	ff 77 04             	pushl  0x4(%edi)
f01064c9:	8b 07                	mov    (%edi),%eax
f01064cb:	ff 70 04             	pushl  0x4(%eax)
f01064ce:	68 7c 85 10 f0       	push   $0xf010857c
f01064d3:	e8 4d d1 ff ff       	call   f0103625 <cprintf>
f01064d8:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f01064db:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f01064dd:	83 fe 27             	cmp    $0x27,%esi
f01064e0:	0f 86 1f ff ff ff    	jbe    f0106405 <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f01064e6:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f01064e9:	83 ec 08             	sub    $0x8,%esp
f01064ec:	89 c2                	mov    %eax,%edx
f01064ee:	c1 ea 10             	shr    $0x10,%edx
f01064f1:	52                   	push   %edx
f01064f2:	0f b7 c0             	movzwl %ax,%eax
f01064f5:	50                   	push   %eax
f01064f6:	ff 77 08             	pushl  0x8(%edi)
f01064f9:	ff 77 04             	pushl  0x4(%edi)
f01064fc:	8b 07                	mov    (%edi),%eax
f01064fe:	ff 70 04             	pushl  0x4(%eax)
f0106501:	68 d8 85 10 f0       	push   $0xf01085d8
f0106506:	e8 1a d1 ff ff       	call   f0103625 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f010650b:	83 c4 20             	add    $0x20,%esp
f010650e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106511:	5b                   	pop    %ebx
f0106512:	5e                   	pop    %esi
f0106513:	5f                   	pop    %edi
f0106514:	5d                   	pop    %ebp
f0106515:	c3                   	ret    

f0106516 <pci_init>:

int
pci_init(void)
{
f0106516:	55                   	push   %ebp
f0106517:	89 e5                	mov    %esp,%ebp
f0106519:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f010651c:	6a 08                	push   $0x8
f010651e:	6a 00                	push   $0x0
f0106520:	68 8c fe 29 f0       	push   $0xf029fe8c
f0106525:	e8 dc f0 ff ff       	call   f0105606 <memset>

	return pci_scan_bus(&root_bus);
f010652a:	b8 8c fe 29 f0       	mov    $0xf029fe8c,%eax
f010652f:	e8 22 fc ff ff       	call   f0106156 <pci_scan_bus>
}
f0106534:	c9                   	leave  
f0106535:	c3                   	ret    

f0106536 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0106536:	55                   	push   %ebp
f0106537:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0106539:	c7 05 94 fe 29 f0 00 	movl   $0x0,0xf029fe94
f0106540:	00 00 00 
}
f0106543:	5d                   	pop    %ebp
f0106544:	c3                   	ret    

f0106545 <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f0106545:	a1 94 fe 29 f0       	mov    0xf029fe94,%eax
f010654a:	83 c0 01             	add    $0x1,%eax
f010654d:	a3 94 fe 29 f0       	mov    %eax,0xf029fe94
	if (ticks * 10 < ticks)
f0106552:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0106555:	01 d2                	add    %edx,%edx
f0106557:	39 d0                	cmp    %edx,%eax
f0106559:	76 17                	jbe    f0106572 <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f010655b:	55                   	push   %ebp
f010655c:	89 e5                	mov    %esp,%ebp
f010655e:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f0106561:	68 e0 86 10 f0       	push   $0xf01086e0
f0106566:	6a 13                	push   $0x13
f0106568:	68 fb 86 10 f0       	push   $0xf01086fb
f010656d:	e8 ce 9a ff ff       	call   f0100040 <_panic>
f0106572:	f3 c3                	repz ret 

f0106574 <time_msec>:
}

unsigned int
time_msec(void)
{
f0106574:	55                   	push   %ebp
f0106575:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f0106577:	a1 94 fe 29 f0       	mov    0xf029fe94,%eax
f010657c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010657f:	01 c0                	add    %eax,%eax
}
f0106581:	5d                   	pop    %ebp
f0106582:	c3                   	ret    
f0106583:	66 90                	xchg   %ax,%ax
f0106585:	66 90                	xchg   %ax,%ax
f0106587:	66 90                	xchg   %ax,%ax
f0106589:	66 90                	xchg   %ax,%ax
f010658b:	66 90                	xchg   %ax,%ax
f010658d:	66 90                	xchg   %ax,%ax
f010658f:	90                   	nop

f0106590 <__udivdi3>:
f0106590:	55                   	push   %ebp
f0106591:	57                   	push   %edi
f0106592:	56                   	push   %esi
f0106593:	53                   	push   %ebx
f0106594:	83 ec 1c             	sub    $0x1c,%esp
f0106597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010659b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010659f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01065a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01065a7:	85 f6                	test   %esi,%esi
f01065a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01065ad:	89 ca                	mov    %ecx,%edx
f01065af:	89 f8                	mov    %edi,%eax
f01065b1:	75 3d                	jne    f01065f0 <__udivdi3+0x60>
f01065b3:	39 cf                	cmp    %ecx,%edi
f01065b5:	0f 87 c5 00 00 00    	ja     f0106680 <__udivdi3+0xf0>
f01065bb:	85 ff                	test   %edi,%edi
f01065bd:	89 fd                	mov    %edi,%ebp
f01065bf:	75 0b                	jne    f01065cc <__udivdi3+0x3c>
f01065c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01065c6:	31 d2                	xor    %edx,%edx
f01065c8:	f7 f7                	div    %edi
f01065ca:	89 c5                	mov    %eax,%ebp
f01065cc:	89 c8                	mov    %ecx,%eax
f01065ce:	31 d2                	xor    %edx,%edx
f01065d0:	f7 f5                	div    %ebp
f01065d2:	89 c1                	mov    %eax,%ecx
f01065d4:	89 d8                	mov    %ebx,%eax
f01065d6:	89 cf                	mov    %ecx,%edi
f01065d8:	f7 f5                	div    %ebp
f01065da:	89 c3                	mov    %eax,%ebx
f01065dc:	89 d8                	mov    %ebx,%eax
f01065de:	89 fa                	mov    %edi,%edx
f01065e0:	83 c4 1c             	add    $0x1c,%esp
f01065e3:	5b                   	pop    %ebx
f01065e4:	5e                   	pop    %esi
f01065e5:	5f                   	pop    %edi
f01065e6:	5d                   	pop    %ebp
f01065e7:	c3                   	ret    
f01065e8:	90                   	nop
f01065e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01065f0:	39 ce                	cmp    %ecx,%esi
f01065f2:	77 74                	ja     f0106668 <__udivdi3+0xd8>
f01065f4:	0f bd fe             	bsr    %esi,%edi
f01065f7:	83 f7 1f             	xor    $0x1f,%edi
f01065fa:	0f 84 98 00 00 00    	je     f0106698 <__udivdi3+0x108>
f0106600:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106605:	89 f9                	mov    %edi,%ecx
f0106607:	89 c5                	mov    %eax,%ebp
f0106609:	29 fb                	sub    %edi,%ebx
f010660b:	d3 e6                	shl    %cl,%esi
f010660d:	89 d9                	mov    %ebx,%ecx
f010660f:	d3 ed                	shr    %cl,%ebp
f0106611:	89 f9                	mov    %edi,%ecx
f0106613:	d3 e0                	shl    %cl,%eax
f0106615:	09 ee                	or     %ebp,%esi
f0106617:	89 d9                	mov    %ebx,%ecx
f0106619:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010661d:	89 d5                	mov    %edx,%ebp
f010661f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106623:	d3 ed                	shr    %cl,%ebp
f0106625:	89 f9                	mov    %edi,%ecx
f0106627:	d3 e2                	shl    %cl,%edx
f0106629:	89 d9                	mov    %ebx,%ecx
f010662b:	d3 e8                	shr    %cl,%eax
f010662d:	09 c2                	or     %eax,%edx
f010662f:	89 d0                	mov    %edx,%eax
f0106631:	89 ea                	mov    %ebp,%edx
f0106633:	f7 f6                	div    %esi
f0106635:	89 d5                	mov    %edx,%ebp
f0106637:	89 c3                	mov    %eax,%ebx
f0106639:	f7 64 24 0c          	mull   0xc(%esp)
f010663d:	39 d5                	cmp    %edx,%ebp
f010663f:	72 10                	jb     f0106651 <__udivdi3+0xc1>
f0106641:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106645:	89 f9                	mov    %edi,%ecx
f0106647:	d3 e6                	shl    %cl,%esi
f0106649:	39 c6                	cmp    %eax,%esi
f010664b:	73 07                	jae    f0106654 <__udivdi3+0xc4>
f010664d:	39 d5                	cmp    %edx,%ebp
f010664f:	75 03                	jne    f0106654 <__udivdi3+0xc4>
f0106651:	83 eb 01             	sub    $0x1,%ebx
f0106654:	31 ff                	xor    %edi,%edi
f0106656:	89 d8                	mov    %ebx,%eax
f0106658:	89 fa                	mov    %edi,%edx
f010665a:	83 c4 1c             	add    $0x1c,%esp
f010665d:	5b                   	pop    %ebx
f010665e:	5e                   	pop    %esi
f010665f:	5f                   	pop    %edi
f0106660:	5d                   	pop    %ebp
f0106661:	c3                   	ret    
f0106662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106668:	31 ff                	xor    %edi,%edi
f010666a:	31 db                	xor    %ebx,%ebx
f010666c:	89 d8                	mov    %ebx,%eax
f010666e:	89 fa                	mov    %edi,%edx
f0106670:	83 c4 1c             	add    $0x1c,%esp
f0106673:	5b                   	pop    %ebx
f0106674:	5e                   	pop    %esi
f0106675:	5f                   	pop    %edi
f0106676:	5d                   	pop    %ebp
f0106677:	c3                   	ret    
f0106678:	90                   	nop
f0106679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106680:	89 d8                	mov    %ebx,%eax
f0106682:	f7 f7                	div    %edi
f0106684:	31 ff                	xor    %edi,%edi
f0106686:	89 c3                	mov    %eax,%ebx
f0106688:	89 d8                	mov    %ebx,%eax
f010668a:	89 fa                	mov    %edi,%edx
f010668c:	83 c4 1c             	add    $0x1c,%esp
f010668f:	5b                   	pop    %ebx
f0106690:	5e                   	pop    %esi
f0106691:	5f                   	pop    %edi
f0106692:	5d                   	pop    %ebp
f0106693:	c3                   	ret    
f0106694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106698:	39 ce                	cmp    %ecx,%esi
f010669a:	72 0c                	jb     f01066a8 <__udivdi3+0x118>
f010669c:	31 db                	xor    %ebx,%ebx
f010669e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01066a2:	0f 87 34 ff ff ff    	ja     f01065dc <__udivdi3+0x4c>
f01066a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01066ad:	e9 2a ff ff ff       	jmp    f01065dc <__udivdi3+0x4c>
f01066b2:	66 90                	xchg   %ax,%ax
f01066b4:	66 90                	xchg   %ax,%ax
f01066b6:	66 90                	xchg   %ax,%ax
f01066b8:	66 90                	xchg   %ax,%ax
f01066ba:	66 90                	xchg   %ax,%ax
f01066bc:	66 90                	xchg   %ax,%ax
f01066be:	66 90                	xchg   %ax,%ax

f01066c0 <__umoddi3>:
f01066c0:	55                   	push   %ebp
f01066c1:	57                   	push   %edi
f01066c2:	56                   	push   %esi
f01066c3:	53                   	push   %ebx
f01066c4:	83 ec 1c             	sub    $0x1c,%esp
f01066c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01066cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01066cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01066d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01066d7:	85 d2                	test   %edx,%edx
f01066d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01066dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01066e1:	89 f3                	mov    %esi,%ebx
f01066e3:	89 3c 24             	mov    %edi,(%esp)
f01066e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01066ea:	75 1c                	jne    f0106708 <__umoddi3+0x48>
f01066ec:	39 f7                	cmp    %esi,%edi
f01066ee:	76 50                	jbe    f0106740 <__umoddi3+0x80>
f01066f0:	89 c8                	mov    %ecx,%eax
f01066f2:	89 f2                	mov    %esi,%edx
f01066f4:	f7 f7                	div    %edi
f01066f6:	89 d0                	mov    %edx,%eax
f01066f8:	31 d2                	xor    %edx,%edx
f01066fa:	83 c4 1c             	add    $0x1c,%esp
f01066fd:	5b                   	pop    %ebx
f01066fe:	5e                   	pop    %esi
f01066ff:	5f                   	pop    %edi
f0106700:	5d                   	pop    %ebp
f0106701:	c3                   	ret    
f0106702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106708:	39 f2                	cmp    %esi,%edx
f010670a:	89 d0                	mov    %edx,%eax
f010670c:	77 52                	ja     f0106760 <__umoddi3+0xa0>
f010670e:	0f bd ea             	bsr    %edx,%ebp
f0106711:	83 f5 1f             	xor    $0x1f,%ebp
f0106714:	75 5a                	jne    f0106770 <__umoddi3+0xb0>
f0106716:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010671a:	0f 82 e0 00 00 00    	jb     f0106800 <__umoddi3+0x140>
f0106720:	39 0c 24             	cmp    %ecx,(%esp)
f0106723:	0f 86 d7 00 00 00    	jbe    f0106800 <__umoddi3+0x140>
f0106729:	8b 44 24 08          	mov    0x8(%esp),%eax
f010672d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106731:	83 c4 1c             	add    $0x1c,%esp
f0106734:	5b                   	pop    %ebx
f0106735:	5e                   	pop    %esi
f0106736:	5f                   	pop    %edi
f0106737:	5d                   	pop    %ebp
f0106738:	c3                   	ret    
f0106739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106740:	85 ff                	test   %edi,%edi
f0106742:	89 fd                	mov    %edi,%ebp
f0106744:	75 0b                	jne    f0106751 <__umoddi3+0x91>
f0106746:	b8 01 00 00 00       	mov    $0x1,%eax
f010674b:	31 d2                	xor    %edx,%edx
f010674d:	f7 f7                	div    %edi
f010674f:	89 c5                	mov    %eax,%ebp
f0106751:	89 f0                	mov    %esi,%eax
f0106753:	31 d2                	xor    %edx,%edx
f0106755:	f7 f5                	div    %ebp
f0106757:	89 c8                	mov    %ecx,%eax
f0106759:	f7 f5                	div    %ebp
f010675b:	89 d0                	mov    %edx,%eax
f010675d:	eb 99                	jmp    f01066f8 <__umoddi3+0x38>
f010675f:	90                   	nop
f0106760:	89 c8                	mov    %ecx,%eax
f0106762:	89 f2                	mov    %esi,%edx
f0106764:	83 c4 1c             	add    $0x1c,%esp
f0106767:	5b                   	pop    %ebx
f0106768:	5e                   	pop    %esi
f0106769:	5f                   	pop    %edi
f010676a:	5d                   	pop    %ebp
f010676b:	c3                   	ret    
f010676c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106770:	8b 34 24             	mov    (%esp),%esi
f0106773:	bf 20 00 00 00       	mov    $0x20,%edi
f0106778:	89 e9                	mov    %ebp,%ecx
f010677a:	29 ef                	sub    %ebp,%edi
f010677c:	d3 e0                	shl    %cl,%eax
f010677e:	89 f9                	mov    %edi,%ecx
f0106780:	89 f2                	mov    %esi,%edx
f0106782:	d3 ea                	shr    %cl,%edx
f0106784:	89 e9                	mov    %ebp,%ecx
f0106786:	09 c2                	or     %eax,%edx
f0106788:	89 d8                	mov    %ebx,%eax
f010678a:	89 14 24             	mov    %edx,(%esp)
f010678d:	89 f2                	mov    %esi,%edx
f010678f:	d3 e2                	shl    %cl,%edx
f0106791:	89 f9                	mov    %edi,%ecx
f0106793:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106797:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010679b:	d3 e8                	shr    %cl,%eax
f010679d:	89 e9                	mov    %ebp,%ecx
f010679f:	89 c6                	mov    %eax,%esi
f01067a1:	d3 e3                	shl    %cl,%ebx
f01067a3:	89 f9                	mov    %edi,%ecx
f01067a5:	89 d0                	mov    %edx,%eax
f01067a7:	d3 e8                	shr    %cl,%eax
f01067a9:	89 e9                	mov    %ebp,%ecx
f01067ab:	09 d8                	or     %ebx,%eax
f01067ad:	89 d3                	mov    %edx,%ebx
f01067af:	89 f2                	mov    %esi,%edx
f01067b1:	f7 34 24             	divl   (%esp)
f01067b4:	89 d6                	mov    %edx,%esi
f01067b6:	d3 e3                	shl    %cl,%ebx
f01067b8:	f7 64 24 04          	mull   0x4(%esp)
f01067bc:	39 d6                	cmp    %edx,%esi
f01067be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01067c2:	89 d1                	mov    %edx,%ecx
f01067c4:	89 c3                	mov    %eax,%ebx
f01067c6:	72 08                	jb     f01067d0 <__umoddi3+0x110>
f01067c8:	75 11                	jne    f01067db <__umoddi3+0x11b>
f01067ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01067ce:	73 0b                	jae    f01067db <__umoddi3+0x11b>
f01067d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01067d4:	1b 14 24             	sbb    (%esp),%edx
f01067d7:	89 d1                	mov    %edx,%ecx
f01067d9:	89 c3                	mov    %eax,%ebx
f01067db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01067df:	29 da                	sub    %ebx,%edx
f01067e1:	19 ce                	sbb    %ecx,%esi
f01067e3:	89 f9                	mov    %edi,%ecx
f01067e5:	89 f0                	mov    %esi,%eax
f01067e7:	d3 e0                	shl    %cl,%eax
f01067e9:	89 e9                	mov    %ebp,%ecx
f01067eb:	d3 ea                	shr    %cl,%edx
f01067ed:	89 e9                	mov    %ebp,%ecx
f01067ef:	d3 ee                	shr    %cl,%esi
f01067f1:	09 d0                	or     %edx,%eax
f01067f3:	89 f2                	mov    %esi,%edx
f01067f5:	83 c4 1c             	add    $0x1c,%esp
f01067f8:	5b                   	pop    %ebx
f01067f9:	5e                   	pop    %esi
f01067fa:	5f                   	pop    %edi
f01067fb:	5d                   	pop    %ebp
f01067fc:	c3                   	ret    
f01067fd:	8d 76 00             	lea    0x0(%esi),%esi
f0106800:	29 f9                	sub    %edi,%ecx
f0106802:	19 d6                	sbb    %edx,%esi
f0106804:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010680c:	e9 18 ff ff ff       	jmp    f0106729 <__umoddi3+0x69>
