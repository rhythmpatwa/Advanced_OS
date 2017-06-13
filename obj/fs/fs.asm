
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
  80002c:	e8 f6 18 00 00       	call   801927 <libmain>
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

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
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

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
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

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
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
  8000b2:	68 e0 3b 80 00       	push   $0x803be0
  8000b7:	e8 a4 19 00 00       	call   801a60 <cprintf>
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
  8000d4:	68 f7 3b 80 00       	push   $0x803bf7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 07 3c 80 00       	push   $0x803c07
  8000e0:	e8 a2 18 00 00       	call   801987 <_panic>
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
  800106:	68 10 3c 80 00       	push   $0x803c10
  80010b:	68 1d 3c 80 00       	push   $0x803c1d
  800110:	6a 44                	push   $0x44
  800112:	68 07 3c 80 00       	push   $0x803c07
  800117:	e8 6b 18 00 00       	call   801987 <_panic>

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

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
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
  8001ca:	68 10 3c 80 00       	push   $0x803c10
  8001cf:	68 1d 3c 80 00       	push   $0x803c1d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 07 3c 80 00       	push   $0x803c07
  8001db:	e8 a7 17 00 00       	call   801987 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
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

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
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
	uint32_t sectno = blockno*BLKSECTS;
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
  80029e:	68 34 3c 80 00       	push   $0x803c34
  8002a3:	6a 28                	push   $0x28
  8002a5:	68 14 3d 80 00       	push   $0x803d14
  8002aa:	e8 d8 16 00 00       	call   801987 <_panic>
  8002af:	8d 3c f5 00 00 00 00 	lea    0x0(,%esi,8),%edi
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002b6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	74 17                	je     8002d6 <bc_pgfault+0x62>
  8002bf:	3b 70 04             	cmp    0x4(%eax),%esi
  8002c2:	72 12                	jb     8002d6 <bc_pgfault+0x62>
		panic("reading non-existent block %08x\n", blockno);
  8002c4:	56                   	push   %esi
  8002c5:	68 64 3c 80 00       	push   $0x803c64
  8002ca:	6a 2c                	push   $0x2c
  8002cc:	68 14 3d 80 00       	push   $0x803d14
  8002d1:	e8 b1 16 00 00       	call   801987 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = ROUNDDOWN(addr, PGSIZE);
  8002d6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if((r = sys_page_alloc(0, addr, PTE_U|PTE_P|PTE_W)))
  8002dc:	83 ec 04             	sub    $0x4,%esp
  8002df:	6a 07                	push   $0x7
  8002e1:	53                   	push   %ebx
  8002e2:	6a 00                	push   $0x0
  8002e4:	e8 1f 21 00 00       	call   802408 <sys_page_alloc>
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	74 12                	je     800302 <bc_pgfault+0x8e>
		panic("bc_pgfault %e", r);
  8002f0:	50                   	push   %eax
  8002f1:	68 1c 3d 80 00       	push   $0x803d1c
  8002f6:	6a 36                	push   $0x36
  8002f8:	68 14 3d 80 00       	push   $0x803d14
  8002fd:	e8 85 16 00 00       	call   801987 <_panic>
	if((r = ide_read(sectno, addr, BLKSECTS)))
  800302:	83 ec 04             	sub    $0x4,%esp
  800305:	6a 08                	push   $0x8
  800307:	53                   	push   %ebx
  800308:	57                   	push   %edi
  800309:	e8 de fd ff ff       	call   8000ec <ide_read>
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	85 c0                	test   %eax,%eax
  800313:	74 12                	je     800327 <bc_pgfault+0xb3>
		panic("ide_read failed %e", r);
  800315:	50                   	push   %eax
  800316:	68 2a 3d 80 00       	push   $0x803d2a
  80031b:	6a 38                	push   $0x38
  80031d:	68 14 3d 80 00       	push   $0x803d14
  800322:	e8 60 16 00 00       	call   801987 <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800327:	89 d8                	mov    %ebx,%eax
  800329:	c1 e8 0c             	shr    $0xc,%eax
  80032c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	25 07 0e 00 00       	and    $0xe07,%eax
  80033b:	50                   	push   %eax
  80033c:	53                   	push   %ebx
  80033d:	6a 00                	push   $0x0
  80033f:	53                   	push   %ebx
  800340:	6a 00                	push   $0x0
  800342:	e8 04 21 00 00       	call   80244b <sys_page_map>
  800347:	83 c4 20             	add    $0x20,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 12                	jns    800360 <bc_pgfault+0xec>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034e:	50                   	push   %eax
  80034f:	68 88 3c 80 00       	push   $0x803c88
  800354:	6a 3d                	push   $0x3d
  800356:	68 14 3d 80 00       	push   $0x803d14
  80035b:	e8 27 16 00 00       	call   801987 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800360:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800367:	74 22                	je     80038b <bc_pgfault+0x117>
  800369:	83 ec 0c             	sub    $0xc,%esp
  80036c:	56                   	push   %esi
  80036d:	e8 4a 03 00 00       	call   8006bc <block_is_free>
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	84 c0                	test   %al,%al
  800377:	74 12                	je     80038b <bc_pgfault+0x117>
		panic("reading free block %08x\n", blockno);
  800379:	56                   	push   %esi
  80037a:	68 3d 3d 80 00       	push   $0x803d3d
  80037f:	6a 43                	push   $0x43
  800381:	68 14 3d 80 00       	push   $0x803d14
  800386:	e8 fc 15 00 00       	call   801987 <_panic>
}
  80038b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80039c:	85 c0                	test   %eax,%eax
  80039e:	74 0f                	je     8003af <diskaddr+0x1c>
  8003a0:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003a6:	85 d2                	test   %edx,%edx
  8003a8:	74 17                	je     8003c1 <diskaddr+0x2e>
  8003aa:	3b 42 04             	cmp    0x4(%edx),%eax
  8003ad:	72 12                	jb     8003c1 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003af:	50                   	push   %eax
  8003b0:	68 a8 3c 80 00       	push   $0x803ca8
  8003b5:	6a 09                	push   $0x9
  8003b7:	68 14 3d 80 00       	push   $0x803d14
  8003bc:	e8 c6 15 00 00       	call   801987 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c1:	05 00 00 01 00       	add    $0x10000,%eax
  8003c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c9:	c9                   	leave  
  8003ca:	c3                   	ret    

008003cb <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003d1:	89 d0                	mov    %edx,%eax
  8003d3:	c1 e8 16             	shr    $0x16,%eax
  8003d6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e2:	f6 c1 01             	test   $0x1,%cl
  8003e5:	74 0d                	je     8003f4 <va_is_mapped+0x29>
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003f1:	83 e0 01             	and    $0x1,%eax
  8003f4:	83 e0 01             	and    $0x1,%eax
}
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ff:	c1 e8 0c             	shr    $0xc,%eax
  800402:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800409:	c1 e8 06             	shr    $0x6,%eax
  80040c:	83 e0 01             	and    $0x1,%eax
}
  80040f:	5d                   	pop    %ebp
  800410:	c3                   	ret    

00800411 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	56                   	push   %esi
  800415:	53                   	push   %ebx
  800416:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	uint32_t sectno = blockno*BLKSECTS;
	int r;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800419:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041f:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800424:	76 12                	jbe    800438 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800426:	53                   	push   %ebx
  800427:	68 56 3d 80 00       	push   $0x803d56
  80042c:	6a 55                	push   $0x55
  80042e:	68 14 3d 80 00       	push   $0x803d14
  800433:	e8 4f 15 00 00       	call   801987 <_panic>

	// LAB 5: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800438:	89 de                	mov    %ebx,%esi
  80043a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if(!(va_is_mapped(addr)) || !(va_is_dirty(addr)));
  800440:	83 ec 0c             	sub    $0xc,%esp
  800443:	56                   	push   %esi
  800444:	e8 82 ff ff ff       	call   8003cb <va_is_mapped>
  800449:	83 c4 10             	add    $0x10,%esp
  80044c:	84 c0                	test   %al,%al
  80044e:	74 6d                	je     8004bd <flush_block+0xac>
  800450:	83 ec 0c             	sub    $0xc,%esp
  800453:	56                   	push   %esi
  800454:	e8 a0 ff ff ff       	call   8003f9 <va_is_dirty>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	84 c0                	test   %al,%al
  80045e:	74 5d                	je     8004bd <flush_block+0xac>
	else{
		if((r=ide_write(sectno, addr, BLKSECTS)))
  800460:	83 ec 04             	sub    $0x4,%esp
  800463:	6a 08                	push   $0x8
  800465:	56                   	push   %esi
  800466:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  80046c:	c1 eb 0c             	shr    $0xc,%ebx
  80046f:	c1 e3 03             	shl    $0x3,%ebx
  800472:	53                   	push   %ebx
  800473:	e8 38 fd ff ff       	call   8001b0 <ide_write>
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	85 c0                	test   %eax,%eax
  80047d:	74 12                	je     800491 <flush_block+0x80>
			panic("ide_write failed %e", r);
  80047f:	50                   	push   %eax
  800480:	68 71 3d 80 00       	push   $0x803d71
  800485:	6a 5c                	push   $0x5c
  800487:	68 14 3d 80 00       	push   $0x803d14
  80048c:	e8 f6 14 00 00       	call   801987 <_panic>
		if((r=sys_page_map(0, addr, 0, addr, PTE_SYSCALL)))
  800491:	83 ec 0c             	sub    $0xc,%esp
  800494:	68 07 0e 00 00       	push   $0xe07
  800499:	56                   	push   %esi
  80049a:	6a 00                	push   $0x0
  80049c:	56                   	push   %esi
  80049d:	6a 00                	push   $0x0
  80049f:	e8 a7 1f 00 00       	call   80244b <sys_page_map>
  8004a4:	83 c4 20             	add    $0x20,%esp
  8004a7:	85 c0                	test   %eax,%eax
  8004a9:	74 12                	je     8004bd <flush_block+0xac>
			panic("flush_block sys_page_mape failed %e", r);
  8004ab:	50                   	push   %eax
  8004ac:	68 cc 3c 80 00       	push   $0x803ccc
  8004b1:	6a 5e                	push   $0x5e
  8004b3:	68 14 3d 80 00       	push   $0x803d14
  8004b8:	e8 ca 14 00 00       	call   801987 <_panic>
	}
	//panic("flush_block not implemented");
}
  8004bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004c0:	5b                   	pop    %ebx
  8004c1:	5e                   	pop    %esi
  8004c2:	5d                   	pop    %ebp
  8004c3:	c3                   	ret    

008004c4 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004c4:	55                   	push   %ebp
  8004c5:	89 e5                	mov    %esp,%ebp
  8004c7:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004cd:	68 74 02 80 00       	push   $0x800274
  8004d2:	e8 41 21 00 00       	call   802618 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004de:	e8 b0 fe ff ff       	call   800393 <diskaddr>
  8004e3:	83 c4 0c             	add    $0xc,%esp
  8004e6:	68 08 01 00 00       	push   $0x108
  8004eb:	50                   	push   %eax
  8004ec:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004f2:	50                   	push   %eax
  8004f3:	e8 9f 1c 00 00       	call   802197 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ff:	e8 8f fe ff ff       	call   800393 <diskaddr>
  800504:	83 c4 08             	add    $0x8,%esp
  800507:	68 85 3d 80 00       	push   $0x803d85
  80050c:	50                   	push   %eax
  80050d:	e8 f3 1a 00 00       	call   802005 <strcpy>
	flush_block(diskaddr(1));
  800512:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800519:	e8 75 fe ff ff       	call   800393 <diskaddr>
  80051e:	89 04 24             	mov    %eax,(%esp)
  800521:	e8 eb fe ff ff       	call   800411 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800526:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80052d:	e8 61 fe ff ff       	call   800393 <diskaddr>
  800532:	89 04 24             	mov    %eax,(%esp)
  800535:	e8 91 fe ff ff       	call   8003cb <va_is_mapped>
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	84 c0                	test   %al,%al
  80053f:	75 16                	jne    800557 <bc_init+0x93>
  800541:	68 a7 3d 80 00       	push   $0x803da7
  800546:	68 1d 3c 80 00       	push   $0x803c1d
  80054b:	6a 70                	push   $0x70
  80054d:	68 14 3d 80 00       	push   $0x803d14
  800552:	e8 30 14 00 00       	call   801987 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	6a 01                	push   $0x1
  80055c:	e8 32 fe ff ff       	call   800393 <diskaddr>
  800561:	89 04 24             	mov    %eax,(%esp)
  800564:	e8 90 fe ff ff       	call   8003f9 <va_is_dirty>
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	84 c0                	test   %al,%al
  80056e:	74 16                	je     800586 <bc_init+0xc2>
  800570:	68 8c 3d 80 00       	push   $0x803d8c
  800575:	68 1d 3c 80 00       	push   $0x803c1d
  80057a:	6a 71                	push   $0x71
  80057c:	68 14 3d 80 00       	push   $0x803d14
  800581:	e8 01 14 00 00       	call   801987 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	6a 01                	push   $0x1
  80058b:	e8 03 fe ff ff       	call   800393 <diskaddr>
  800590:	83 c4 08             	add    $0x8,%esp
  800593:	50                   	push   %eax
  800594:	6a 00                	push   $0x0
  800596:	e8 f2 1e 00 00       	call   80248d <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80059b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a2:	e8 ec fd ff ff       	call   800393 <diskaddr>
  8005a7:	89 04 24             	mov    %eax,(%esp)
  8005aa:	e8 1c fe ff ff       	call   8003cb <va_is_mapped>
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	84 c0                	test   %al,%al
  8005b4:	74 16                	je     8005cc <bc_init+0x108>
  8005b6:	68 a6 3d 80 00       	push   $0x803da6
  8005bb:	68 1d 3c 80 00       	push   $0x803c1d
  8005c0:	6a 75                	push   $0x75
  8005c2:	68 14 3d 80 00       	push   $0x803d14
  8005c7:	e8 bb 13 00 00       	call   801987 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005cc:	83 ec 0c             	sub    $0xc,%esp
  8005cf:	6a 01                	push   $0x1
  8005d1:	e8 bd fd ff ff       	call   800393 <diskaddr>
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	68 85 3d 80 00       	push   $0x803d85
  8005de:	50                   	push   %eax
  8005df:	e8 cb 1a 00 00       	call   8020af <strcmp>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	74 16                	je     800601 <bc_init+0x13d>
  8005eb:	68 f0 3c 80 00       	push   $0x803cf0
  8005f0:	68 1d 3c 80 00       	push   $0x803c1d
  8005f5:	6a 78                	push   $0x78
  8005f7:	68 14 3d 80 00       	push   $0x803d14
  8005fc:	e8 86 13 00 00       	call   801987 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	6a 01                	push   $0x1
  800606:	e8 88 fd ff ff       	call   800393 <diskaddr>
  80060b:	83 c4 0c             	add    $0xc,%esp
  80060e:	68 08 01 00 00       	push   $0x108
  800613:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800619:	52                   	push   %edx
  80061a:	50                   	push   %eax
  80061b:	e8 77 1b 00 00       	call   802197 <memmove>
	flush_block(diskaddr(1));
  800620:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800627:	e8 67 fd ff ff       	call   800393 <diskaddr>
  80062c:	89 04 24             	mov    %eax,(%esp)
  80062f:	e8 dd fd ff ff       	call   800411 <flush_block>

	cprintf("block cache is good\n");
  800634:	c7 04 24 c1 3d 80 00 	movl   $0x803dc1,(%esp)
  80063b:	e8 20 14 00 00       	call   801a60 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800640:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800647:	e8 47 fd ff ff       	call   800393 <diskaddr>
  80064c:	83 c4 0c             	add    $0xc,%esp
  80064f:	68 08 01 00 00       	push   $0x108
  800654:	50                   	push   %eax
  800655:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	e8 36 1b 00 00       	call   802197 <memmove>
}
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	c9                   	leave  
  800665:	c3                   	ret    

00800666 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
  800669:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80066c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800671:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800677:	74 14                	je     80068d <check_super+0x27>
		panic("bad file system magic number");
  800679:	83 ec 04             	sub    $0x4,%esp
  80067c:	68 d6 3d 80 00       	push   $0x803dd6
  800681:	6a 0f                	push   $0xf
  800683:	68 f3 3d 80 00       	push   $0x803df3
  800688:	e8 fa 12 00 00       	call   801987 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80068d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800694:	76 14                	jbe    8006aa <check_super+0x44>
		panic("file system is too large");
  800696:	83 ec 04             	sub    $0x4,%esp
  800699:	68 fb 3d 80 00       	push   $0x803dfb
  80069e:	6a 12                	push   $0x12
  8006a0:	68 f3 3d 80 00       	push   $0x803df3
  8006a5:	e8 dd 12 00 00       	call   801987 <_panic>

	cprintf("superblock is good\n");
  8006aa:	83 ec 0c             	sub    $0xc,%esp
  8006ad:	68 14 3e 80 00       	push   $0x803e14
  8006b2:	e8 a9 13 00 00       	call   801a60 <cprintf>
}
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	53                   	push   %ebx
  8006c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006c3:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	74 24                	je     8006f1 <block_is_free+0x35>
		return 0;
  8006cd:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006d2:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006d5:	76 1f                	jbe    8006f6 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006d7:	89 cb                	mov    %ecx,%ebx
  8006d9:	c1 eb 05             	shr    $0x5,%ebx
  8006dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8006e1:	d3 e0                	shl    %cl,%eax
  8006e3:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006e9:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8006ec:	0f 95 c0             	setne  %al
  8006ef:	eb 05                	jmp    8006f6 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8006f1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8006f6:	5b                   	pop    %ebx
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	53                   	push   %ebx
  8006fd:	83 ec 04             	sub    $0x4,%esp
  800700:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800703:	85 c9                	test   %ecx,%ecx
  800705:	75 14                	jne    80071b <free_block+0x22>
		panic("attempt to free zero block");
  800707:	83 ec 04             	sub    $0x4,%esp
  80070a:	68 28 3e 80 00       	push   $0x803e28
  80070f:	6a 2d                	push   $0x2d
  800711:	68 f3 3d 80 00       	push   $0x803df3
  800716:	e8 6c 12 00 00       	call   801987 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80071b:	89 cb                	mov    %ecx,%ebx
  80071d:	c1 eb 05             	shr    $0x5,%ebx
  800720:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800726:	b8 01 00 00 00       	mov    $0x1,%eax
  80072b:	d3 e0                	shl    %cl,%eax
  80072d:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	57                   	push   %edi
  800739:	56                   	push   %esi
  80073a:	53                   	push   %ebx
  80073b:	83 ec 0c             	sub    $0xc,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	uint32_t blockno;
	// LAB 5: Your code here.
	for(blockno = 1; blockno < super->s_nblocks; blockno++){
  80073e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800743:	8b 70 04             	mov    0x4(%eax),%esi
		void *addr = (void *)((blockno*BLKSIZE)+DISKMAP);
		if (bitmap[blockno / 32] & (1 << (blockno % 32))){
  800746:	8b 3d 08 a0 80 00    	mov    0x80a008,%edi
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	uint32_t blockno;
	// LAB 5: Your code here.
	for(blockno = 1; blockno < super->s_nblocks; blockno++){
  80074c:	bb 01 00 00 00       	mov    $0x1,%ebx
  800751:	89 d9                	mov    %ebx,%ecx
  800753:	eb 39                	jmp    80078e <alloc_block+0x59>
		void *addr = (void *)((blockno*BLKSIZE)+DISKMAP);
		if (bitmap[blockno / 32] & (1 << (blockno % 32))){
  800755:	89 c8                	mov    %ecx,%eax
  800757:	c1 e8 05             	shr    $0x5,%eax
  80075a:	8d 14 87             	lea    (%edi,%eax,4),%edx
  80075d:	8b 02                	mov    (%edx),%eax
  80075f:	bb 01 00 00 00       	mov    $0x1,%ebx
  800764:	d3 e3                	shl    %cl,%ebx
  800766:	85 c3                	test   %eax,%ebx
  800768:	74 21                	je     80078b <alloc_block+0x56>
  80076a:	89 df                	mov    %ebx,%edi
  80076c:	89 cb                	mov    %ecx,%ebx
  80076e:	89 f9                	mov    %edi,%ecx
			bitmap[blockno/32] &= ~(1<<(blockno%32));
  800770:	f7 d1                	not    %ecx
  800772:	21 c8                	and    %ecx,%eax
  800774:	89 02                	mov    %eax,(%edx)
			flush_block(bitmap);
  800776:	83 ec 0c             	sub    $0xc,%esp
  800779:	ff 35 08 a0 80 00    	pushl  0x80a008
  80077f:	e8 8d fc ff ff       	call   800411 <flush_block>
			return blockno;
  800784:	89 d8                	mov    %ebx,%eax
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	eb 0c                	jmp    800797 <alloc_block+0x62>
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	uint32_t blockno;
	// LAB 5: Your code here.
	for(blockno = 1; blockno < super->s_nblocks; blockno++){
  80078b:	83 c1 01             	add    $0x1,%ecx
  80078e:	39 f1                	cmp    %esi,%ecx
  800790:	72 c3                	jb     800755 <alloc_block+0x20>
			return blockno;
		}
	}
		
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  800792:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  800797:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5f                   	pop    %edi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <file_block_walk>:
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.

static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	57                   	push   %edi
  8007a3:	56                   	push   %esi
  8007a4:	53                   	push   %ebx
  8007a5:	83 ec 1c             	sub    $0x1c,%esp
  8007a8:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 5: Your code here.
	if(filebno >= NDIRECT + NINDIRECT)
  8007ab:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007b1:	0f 87 ad 00 00 00    	ja     800864 <file_block_walk+0xc5>
  8007b7:	89 c6                	mov    %eax,%esi
       		return -E_INVAL;
       		
       	if(filebno < NDIRECT)
  8007b9:	83 fa 09             	cmp    $0x9,%edx
  8007bc:	77 13                	ja     8007d1 <file_block_walk+0x32>
       		*ppdiskbno = &(f->f_direct[filebno]);
  8007be:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007c5:	89 01                	mov    %eax,(%ecx)
       		}
       		else if(!(alloc) && !(f->f_indirect)){
       			return -E_NOT_FOUND;
       		}
       	}
        return 0;	
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	e9 98 00 00 00       	jmp    800869 <file_block_walk+0xca>
       		return -E_INVAL;
       		
       	if(filebno < NDIRECT)
       		*ppdiskbno = &(f->f_direct[filebno]);
       		
       	else if ((filebno >= NDIRECT) && (filebno < (NDIRECT + NINDIRECT))){
  8007d1:	8d 5a f6             	lea    -0xa(%edx),%ebx
       		}
       		else if(!(alloc) && !(f->f_indirect)){
       			return -E_NOT_FOUND;
       		}
       	}
        return 0;	
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
       		return -E_INVAL;
       		
       	if(filebno < NDIRECT)
       		*ppdiskbno = &(f->f_direct[filebno]);
       		
       	else if ((filebno >= NDIRECT) && (filebno < (NDIRECT + NINDIRECT))){
  8007d9:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  8007df:	0f 87 84 00 00 00    	ja     800869 <file_block_walk+0xca>
  8007e5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007e8:	89 d3                	mov    %edx,%ebx
       		if(f->f_indirect){
  8007ea:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	74 1c                	je     800810 <file_block_walk+0x71>
       			uint32_t *temp = (uint32_t *)diskaddr(f->f_indirect);
  8007f4:	83 ec 0c             	sub    $0xc,%esp
  8007f7:	50                   	push   %eax
  8007f8:	e8 96 fb ff ff       	call   800393 <diskaddr>
        		*ppdiskbno = &temp[filebno - NDIRECT];
  8007fd:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800804:	89 07                	mov    %eax,(%edi)
  800806:	83 c4 10             	add    $0x10,%esp
       		}
       		else if(!(alloc) && !(f->f_indirect)){
       			return -E_NOT_FOUND;
       		}
       	}
        return 0;	
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
  80080e:	eb 59                	jmp    800869 <file_block_walk+0xca>
			memset(diskaddr(block), 0, BLKSIZE);
			uint32_t *temp = (uint32_t *)diskaddr(f->f_indirect);
			*ppdiskbno = &temp[filebno - NDIRECT];
       		}
       		else if(!(alloc) && !(f->f_indirect)){
       			return -E_NOT_FOUND;
  800810:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
       	else if ((filebno >= NDIRECT) && (filebno < (NDIRECT + NINDIRECT))){
       		if(f->f_indirect){
       			uint32_t *temp = (uint32_t *)diskaddr(f->f_indirect);
        		*ppdiskbno = &temp[filebno - NDIRECT];
       		}
       		else if(alloc && !(f->f_indirect)){
  800815:	89 f9                	mov    %edi,%ecx
  800817:	84 c9                	test   %cl,%cl
  800819:	74 4e                	je     800869 <file_block_walk+0xca>
       			int block = alloc_block();
  80081b:	e8 15 ff ff ff       	call   800735 <alloc_block>
			if(block < 0)
  800820:	85 c0                	test   %eax,%eax
  800822:	78 45                	js     800869 <file_block_walk+0xca>
				return block;
			f->f_indirect = block;
  800824:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
			memset(diskaddr(block), 0, BLKSIZE);
  80082a:	83 ec 0c             	sub    $0xc,%esp
  80082d:	50                   	push   %eax
  80082e:	e8 60 fb ff ff       	call   800393 <diskaddr>
  800833:	83 c4 0c             	add    $0xc,%esp
  800836:	68 00 10 00 00       	push   $0x1000
  80083b:	6a 00                	push   $0x0
  80083d:	50                   	push   %eax
  80083e:	e8 07 19 00 00       	call   80214a <memset>
			uint32_t *temp = (uint32_t *)diskaddr(f->f_indirect);
  800843:	83 c4 04             	add    $0x4,%esp
  800846:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  80084c:	e8 42 fb ff ff       	call   800393 <diskaddr>
			*ppdiskbno = &temp[filebno - NDIRECT];
  800851:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800858:	89 07                	mov    %eax,(%edi)
       	else if ((filebno >= NDIRECT) && (filebno < (NDIRECT + NINDIRECT))){
       		if(f->f_indirect){
       			uint32_t *temp = (uint32_t *)diskaddr(f->f_indirect);
        		*ppdiskbno = &temp[filebno - NDIRECT];
       		}
       		else if(alloc && !(f->f_indirect)){
  80085a:	83 c4 10             	add    $0x10,%esp
       		}
       		else if(!(alloc) && !(f->f_indirect)){
       			return -E_NOT_FOUND;
       		}
       	}
        return 0;	
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
       	else if ((filebno >= NDIRECT) && (filebno < (NDIRECT + NINDIRECT))){
       		if(f->f_indirect){
       			uint32_t *temp = (uint32_t *)diskaddr(f->f_indirect);
        		*ppdiskbno = &temp[filebno - NDIRECT];
       		}
       		else if(alloc && !(f->f_indirect)){
  800862:	eb 05                	jmp    800869 <file_block_walk+0xca>
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
	// LAB 5: Your code here.
	if(filebno >= NDIRECT + NINDIRECT)
       		return -E_INVAL;
  800864:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
       			return -E_NOT_FOUND;
       		}
       	}
        return 0;	
       	//panic("file_block_walk not implemented");
}
  800869:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086c:	5b                   	pop    %ebx
  80086d:	5e                   	pop    %esi
  80086e:	5f                   	pop    %edi
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800876:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80087b:	8b 70 04             	mov    0x4(%eax),%esi
  80087e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800883:	eb 29                	jmp    8008ae <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800885:	8d 43 02             	lea    0x2(%ebx),%eax
  800888:	50                   	push   %eax
  800889:	e8 2e fe ff ff       	call   8006bc <block_is_free>
  80088e:	83 c4 04             	add    $0x4,%esp
  800891:	84 c0                	test   %al,%al
  800893:	74 16                	je     8008ab <check_bitmap+0x3a>
  800895:	68 43 3e 80 00       	push   $0x803e43
  80089a:	68 1d 3c 80 00       	push   $0x803c1d
  80089f:	6a 59                	push   $0x59
  8008a1:	68 f3 3d 80 00       	push   $0x803df3
  8008a6:	e8 dc 10 00 00       	call   801987 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8008ab:	83 c3 01             	add    $0x1,%ebx
  8008ae:	89 d8                	mov    %ebx,%eax
  8008b0:	c1 e0 0f             	shl    $0xf,%eax
  8008b3:	39 f0                	cmp    %esi,%eax
  8008b5:	72 ce                	jb     800885 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008b7:	83 ec 0c             	sub    $0xc,%esp
  8008ba:	6a 00                	push   $0x0
  8008bc:	e8 fb fd ff ff       	call   8006bc <block_is_free>
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	84 c0                	test   %al,%al
  8008c6:	74 16                	je     8008de <check_bitmap+0x6d>
  8008c8:	68 57 3e 80 00       	push   $0x803e57
  8008cd:	68 1d 3c 80 00       	push   $0x803c1d
  8008d2:	6a 5c                	push   $0x5c
  8008d4:	68 f3 3d 80 00       	push   $0x803df3
  8008d9:	e8 a9 10 00 00       	call   801987 <_panic>
	assert(!block_is_free(1));
  8008de:	83 ec 0c             	sub    $0xc,%esp
  8008e1:	6a 01                	push   $0x1
  8008e3:	e8 d4 fd ff ff       	call   8006bc <block_is_free>
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	84 c0                	test   %al,%al
  8008ed:	74 16                	je     800905 <check_bitmap+0x94>
  8008ef:	68 69 3e 80 00       	push   $0x803e69
  8008f4:	68 1d 3c 80 00       	push   $0x803c1d
  8008f9:	6a 5d                	push   $0x5d
  8008fb:	68 f3 3d 80 00       	push   $0x803df3
  800900:	e8 82 10 00 00       	call   801987 <_panic>

	cprintf("bitmap is good\n");
  800905:	83 ec 0c             	sub    $0xc,%esp
  800908:	68 7b 3e 80 00       	push   $0x803e7b
  80090d:	e8 4e 11 00 00       	call   801a60 <cprintf>
}
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  800922:	e8 38 f7 ff ff       	call   80005f <ide_probe_disk1>
  800927:	84 c0                	test   %al,%al
  800929:	74 0f                	je     80093a <fs_init+0x1e>
               ide_set_disk(1);
  80092b:	83 ec 0c             	sub    $0xc,%esp
  80092e:	6a 01                	push   $0x1
  800930:	e8 8e f7 ff ff       	call   8000c3 <ide_set_disk>
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	eb 0d                	jmp    800947 <fs_init+0x2b>
       else
               ide_set_disk(0);
  80093a:	83 ec 0c             	sub    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	e8 7f f7 ff ff       	call   8000c3 <ide_set_disk>
  800944:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800947:	e8 78 fb ff ff       	call   8004c4 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  80094c:	83 ec 0c             	sub    $0xc,%esp
  80094f:	6a 01                	push   $0x1
  800951:	e8 3d fa ff ff       	call   800393 <diskaddr>
  800956:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  80095b:	e8 06 fd ff ff       	call   800666 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800960:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800967:	e8 27 fa ff ff       	call   800393 <diskaddr>
  80096c:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800971:	e8 fb fe ff ff       	call   800871 <check_bitmap>
	
}
  800976:	83 c4 10             	add    $0x10,%esp
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{	
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	83 ec 14             	sub    $0x14,%esp
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	int r;
	uint32_t *ppdiskbno;
       	// LAB 5: Your code here.
       	if(filebno >= NDIRECT + NINDIRECT)
  800985:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  80098b:	77 42                	ja     8009cf <file_get_block+0x54>
       		return -E_INVAL;
       	if((r = file_block_walk(f, filebno, &ppdiskbno, 1)))
  80098d:	83 ec 0c             	sub    $0xc,%esp
  800990:	6a 01                	push   $0x1
  800992:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	e8 02 fe ff ff       	call   80079f <file_block_walk>
  80099d:	83 c4 10             	add    $0x10,%esp
  8009a0:	85 c0                	test   %eax,%eax
  8009a2:	75 30                	jne    8009d4 <file_get_block+0x59>
       		return r;
       	if(!(*ppdiskbno)){
  8009a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8009a7:	83 3b 00             	cmpl   $0x0,(%ebx)
  8009aa:	75 07                	jne    8009b3 <file_get_block+0x38>
       		*ppdiskbno = alloc_block();
  8009ac:	e8 84 fd ff ff       	call   800735 <alloc_block>
  8009b1:	89 03                	mov    %eax,(%ebx)
       		if(*ppdiskbno < 0)
       			return *ppdiskbno;
       	}	
       	*blk = (char *)diskaddr(*ppdiskbno);
  8009b3:	83 ec 0c             	sub    $0xc,%esp
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	ff 30                	pushl  (%eax)
  8009bb:	e8 d3 f9 ff ff       	call   800393 <diskaddr>
  8009c0:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c3:	89 02                	mov    %eax,(%edx)
       	//panic("file_get_block not implemented");
       	return 0;
  8009c5:	83 c4 10             	add    $0x10,%esp
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cd:	eb 05                	jmp    8009d4 <file_get_block+0x59>
{	
	int r;
	uint32_t *ppdiskbno;
       	// LAB 5: Your code here.
       	if(filebno >= NDIRECT + NINDIRECT)
       		return -E_INVAL;
  8009cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
       			return *ppdiskbno;
       	}	
       	*blk = (char *)diskaddr(*ppdiskbno);
       	//panic("file_get_block not implemented");
       	return 0;
}
  8009d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8009e5:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8009eb:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  8009f1:	eb 03                	jmp    8009f6 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8009f3:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8009f6:	80 38 2f             	cmpb   $0x2f,(%eax)
  8009f9:	74 f8                	je     8009f3 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8009fb:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800a01:	83 c1 08             	add    $0x8,%ecx
  800a04:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800a0a:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800a11:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800a17:	85 c9                	test   %ecx,%ecx
  800a19:	74 06                	je     800a21 <walk_path+0x48>
		*pdir = 0;
  800a1b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800a21:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800a27:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a32:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a38:	e9 5f 01 00 00       	jmp    800b9c <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a3d:	83 c7 01             	add    $0x1,%edi
  800a40:	eb 02                	jmp    800a44 <walk_path+0x6b>
  800a42:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a44:	0f b6 17             	movzbl (%edi),%edx
  800a47:	80 fa 2f             	cmp    $0x2f,%dl
  800a4a:	74 04                	je     800a50 <walk_path+0x77>
  800a4c:	84 d2                	test   %dl,%dl
  800a4e:	75 ed                	jne    800a3d <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a50:	89 fb                	mov    %edi,%ebx
  800a52:	29 c3                	sub    %eax,%ebx
  800a54:	83 fb 7f             	cmp    $0x7f,%ebx
  800a57:	0f 8f 69 01 00 00    	jg     800bc6 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a5d:	83 ec 04             	sub    $0x4,%esp
  800a60:	53                   	push   %ebx
  800a61:	50                   	push   %eax
  800a62:	56                   	push   %esi
  800a63:	e8 2f 17 00 00       	call   802197 <memmove>
		name[path - p] = '\0';
  800a68:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a6f:	00 
  800a70:	83 c4 10             	add    $0x10,%esp
  800a73:	eb 03                	jmp    800a78 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a75:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a78:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a7b:	74 f8                	je     800a75 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a7d:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a83:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a8a:	0f 85 3d 01 00 00    	jne    800bcd <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a90:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a96:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800a9b:	74 19                	je     800ab6 <walk_path+0xdd>
  800a9d:	68 8b 3e 80 00       	push   $0x803e8b
  800aa2:	68 1d 3c 80 00       	push   $0x803c1d
  800aa7:	68 db 00 00 00       	push   $0xdb
  800aac:	68 f3 3d 80 00       	push   $0x803df3
  800ab1:	e8 d1 0e 00 00       	call   801987 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800ab6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800abc:	85 c0                	test   %eax,%eax
  800abe:	0f 48 c2             	cmovs  %edx,%eax
  800ac1:	c1 f8 0c             	sar    $0xc,%eax
  800ac4:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800aca:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800ad1:	00 00 00 
  800ad4:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800ada:	eb 5e                	jmp    800b3a <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800adc:	83 ec 04             	sub    $0x4,%esp
  800adf:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800ae5:	50                   	push   %eax
  800ae6:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800aec:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800af2:	e8 84 fe ff ff       	call   80097b <file_get_block>
  800af7:	83 c4 10             	add    $0x10,%esp
  800afa:	85 c0                	test   %eax,%eax
  800afc:	0f 88 ee 00 00 00    	js     800bf0 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800b02:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800b08:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800b0e:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800b14:	83 ec 08             	sub    $0x8,%esp
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	e8 91 15 00 00       	call   8020af <strcmp>
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	85 c0                	test   %eax,%eax
  800b23:	0f 84 ab 00 00 00    	je     800bd4 <walk_path+0x1fb>
  800b29:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b2f:	39 fb                	cmp    %edi,%ebx
  800b31:	75 db                	jne    800b0e <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b33:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b3a:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b40:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b46:	75 94                	jne    800adc <walk_path+0x103>
  800b48:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b4e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b53:	80 3f 00             	cmpb   $0x0,(%edi)
  800b56:	0f 85 a3 00 00 00    	jne    800bff <walk_path+0x226>
				if (pdir)
  800b5c:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b62:	85 c0                	test   %eax,%eax
  800b64:	74 08                	je     800b6e <walk_path+0x195>
					*pdir = dir;
  800b66:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b6c:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b6e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b72:	74 15                	je     800b89 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b74:	83 ec 08             	sub    $0x8,%esp
  800b77:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b7d:	50                   	push   %eax
  800b7e:	ff 75 08             	pushl  0x8(%ebp)
  800b81:	e8 7f 14 00 00       	call   802005 <strcpy>
  800b86:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b89:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b95:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800b9a:	eb 63                	jmp    800bff <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b9c:	80 38 00             	cmpb   $0x0,(%eax)
  800b9f:	0f 85 9d fe ff ff    	jne    800a42 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800ba5:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800bab:	85 c0                	test   %eax,%eax
  800bad:	74 02                	je     800bb1 <walk_path+0x1d8>
		*pdir = dir;
  800baf:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800bb1:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bb7:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800bbd:	89 08                	mov    %ecx,(%eax)
	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	eb 39                	jmp    800bff <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800bc6:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800bcb:	eb 32                	jmp    800bff <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800bcd:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bd2:	eb 2b                	jmp    800bff <walk_path+0x226>
  800bd4:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bda:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800be0:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800be6:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800bec:	89 f8                	mov    %edi,%eax
  800bee:	eb ac                	jmp    800b9c <walk_path+0x1c3>
  800bf0:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800bf6:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800bf9:	0f 84 4f ff ff ff    	je     800b4e <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800c0d:	6a 00                	push   $0x0
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	ba 00 00 00 00       	mov    $0x0,%edx
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	e8 ba fd ff ff       	call   8009d9 <walk_path>
}
  800c1f:	c9                   	leave  
  800c20:	c3                   	ret    

00800c21 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 2c             	sub    $0x2c,%esp
  800c2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c2d:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c30:	8b 45 08             	mov    0x8(%ebp),%eax
  800c33:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c3e:	39 ca                	cmp    %ecx,%edx
  800c40:	7e 7c                	jle    800cbe <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c42:	29 ca                	sub    %ecx,%edx
  800c44:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c47:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c4b:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c4e:	89 ce                	mov    %ecx,%esi
  800c50:	01 d1                	add    %edx,%ecx
  800c52:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c55:	eb 5d                	jmp    800cb4 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c57:	83 ec 04             	sub    $0x4,%esp
  800c5a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c5d:	50                   	push   %eax
  800c5e:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c64:	85 f6                	test   %esi,%esi
  800c66:	0f 49 c6             	cmovns %esi,%eax
  800c69:	c1 f8 0c             	sar    $0xc,%eax
  800c6c:	50                   	push   %eax
  800c6d:	ff 75 08             	pushl  0x8(%ebp)
  800c70:	e8 06 fd ff ff       	call   80097b <file_get_block>
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	78 42                	js     800cbe <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c7c:	89 f2                	mov    %esi,%edx
  800c7e:	c1 fa 1f             	sar    $0x1f,%edx
  800c81:	c1 ea 14             	shr    $0x14,%edx
  800c84:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800c87:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c8c:	29 d0                	sub    %edx,%eax
  800c8e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800c91:	29 da                	sub    %ebx,%edx
  800c93:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800c98:	29 c3                	sub    %eax,%ebx
  800c9a:	39 da                	cmp    %ebx,%edx
  800c9c:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800c9f:	83 ec 04             	sub    $0x4,%esp
  800ca2:	53                   	push   %ebx
  800ca3:	03 45 e4             	add    -0x1c(%ebp),%eax
  800ca6:	50                   	push   %eax
  800ca7:	57                   	push   %edi
  800ca8:	e8 ea 14 00 00       	call   802197 <memmove>
		pos += bn;
  800cad:	01 de                	add    %ebx,%esi
		buf += bn;
  800caf:	01 df                	add    %ebx,%edi
  800cb1:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800cb4:	89 f3                	mov    %esi,%ebx
  800cb6:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800cb9:	77 9c                	ja     800c57 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800cbb:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 2c             	sub    $0x2c,%esp
  800ccf:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800cd2:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800cd8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800cdb:	0f 8e a7 00 00 00    	jle    800d88 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800ce1:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800ce7:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cec:	0f 49 f8             	cmovns %eax,%edi
  800cef:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf5:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800cfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfd:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800d03:	0f 49 c2             	cmovns %edx,%eax
  800d06:	c1 f8 0c             	sar    $0xc,%eax
  800d09:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d0c:	89 c3                	mov    %eax,%ebx
  800d0e:	eb 39                	jmp    800d49 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	6a 00                	push   $0x0
  800d15:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800d18:	89 da                	mov    %ebx,%edx
  800d1a:	89 f0                	mov    %esi,%eax
  800d1c:	e8 7e fa ff ff       	call   80079f <file_block_walk>
  800d21:	83 c4 10             	add    $0x10,%esp
  800d24:	85 c0                	test   %eax,%eax
  800d26:	78 4d                	js     800d75 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800d28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d2b:	8b 00                	mov    (%eax),%eax
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	74 15                	je     800d46 <file_set_size+0x80>
		free_block(*ptr);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	e8 bf f9 ff ff       	call   8006f9 <free_block>
		*ptr = 0;
  800d3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d3d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d43:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d46:	83 c3 01             	add    $0x1,%ebx
  800d49:	39 df                	cmp    %ebx,%edi
  800d4b:	77 c3                	ja     800d10 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d4d:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d51:	77 35                	ja     800d88 <file_set_size+0xc2>
  800d53:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	74 2b                	je     800d88 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d5d:	83 ec 0c             	sub    $0xc,%esp
  800d60:	50                   	push   %eax
  800d61:	e8 93 f9 ff ff       	call   8006f9 <free_block>
		f->f_indirect = 0;
  800d66:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d6d:	00 00 00 
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	eb 13                	jmp    800d88 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d75:	83 ec 08             	sub    $0x8,%esp
  800d78:	50                   	push   %eax
  800d79:	68 a8 3e 80 00       	push   $0x803ea8
  800d7e:	e8 dd 0c 00 00       	call   801a60 <cprintf>
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	eb be                	jmp    800d46 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8b:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	56                   	push   %esi
  800d95:	e8 77 f6 ff ff       	call   800411 <flush_block>
	return 0;
}
  800d9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
  800db0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800db3:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800db6:	89 f0                	mov    %esi,%eax
  800db8:	03 45 10             	add    0x10(%ebp),%eax
  800dbb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800dbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc1:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800dc7:	76 72                	jbe    800e3b <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800dc9:	83 ec 08             	sub    $0x8,%esp
  800dcc:	50                   	push   %eax
  800dcd:	51                   	push   %ecx
  800dce:	e8 f3 fe ff ff       	call   800cc6 <file_set_size>
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	79 61                	jns    800e3b <file_write+0x94>
  800dda:	eb 69                	jmp    800e45 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800de2:	50                   	push   %eax
  800de3:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800de9:	85 f6                	test   %esi,%esi
  800deb:	0f 49 c6             	cmovns %esi,%eax
  800dee:	c1 f8 0c             	sar    $0xc,%eax
  800df1:	50                   	push   %eax
  800df2:	ff 75 08             	pushl  0x8(%ebp)
  800df5:	e8 81 fb ff ff       	call   80097b <file_get_block>
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	78 44                	js     800e45 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e01:	89 f2                	mov    %esi,%edx
  800e03:	c1 fa 1f             	sar    $0x1f,%edx
  800e06:	c1 ea 14             	shr    $0x14,%edx
  800e09:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e0c:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e11:	29 d0                	sub    %edx,%eax
  800e13:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e16:	29 d9                	sub    %ebx,%ecx
  800e18:	89 cb                	mov    %ecx,%ebx
  800e1a:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e1f:	29 c2                	sub    %eax,%edx
  800e21:	39 d1                	cmp    %edx,%ecx
  800e23:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	53                   	push   %ebx
  800e2a:	57                   	push   %edi
  800e2b:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e2e:	50                   	push   %eax
  800e2f:	e8 63 13 00 00       	call   802197 <memmove>
		pos += bn;
  800e34:	01 de                	add    %ebx,%esi
		buf += bn;
  800e36:	01 df                	add    %ebx,%edi
  800e38:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e3b:	89 f3                	mov    %esi,%ebx
  800e3d:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e40:	77 9a                	ja     800ddc <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e42:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 10             	sub    $0x10,%esp
  800e55:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5d:	eb 3c                	jmp    800e9b <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	6a 00                	push   $0x0
  800e64:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e67:	89 da                	mov    %ebx,%edx
  800e69:	89 f0                	mov    %esi,%eax
  800e6b:	e8 2f f9 ff ff       	call   80079f <file_block_walk>
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	85 c0                	test   %eax,%eax
  800e75:	78 21                	js     800e98 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	74 1a                	je     800e98 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e7e:	8b 00                	mov    (%eax),%eax
  800e80:	85 c0                	test   %eax,%eax
  800e82:	74 14                	je     800e98 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	e8 06 f5 ff ff       	call   800393 <diskaddr>
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 7c f5 ff ff       	call   800411 <flush_block>
  800e95:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e98:	83 c3 01             	add    $0x1,%ebx
  800e9b:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800ea1:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800ea7:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800ead:	85 c9                	test   %ecx,%ecx
  800eaf:	0f 49 c1             	cmovns %ecx,%eax
  800eb2:	c1 f8 0c             	sar    $0xc,%eax
  800eb5:	39 c3                	cmp    %eax,%ebx
  800eb7:	7c a6                	jl     800e5f <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	56                   	push   %esi
  800ebd:	e8 4f f5 ff ff       	call   800411 <flush_block>
	if (f->f_indirect)
  800ec2:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800ec8:	83 c4 10             	add    $0x10,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	74 14                	je     800ee3 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	50                   	push   %eax
  800ed3:	e8 bb f4 ff ff       	call   800393 <diskaddr>
  800ed8:	89 04 24             	mov    %eax,(%esp)
  800edb:	e8 31 f5 ff ff       	call   800411 <flush_block>
  800ee0:	83 c4 10             	add    $0x10,%esp
}
  800ee3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee6:	5b                   	pop    %ebx
  800ee7:	5e                   	pop    %esi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    

00800eea <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
  800ef0:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800ef6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800efc:	50                   	push   %eax
  800efd:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800f03:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	e8 c8 fa ff ff       	call   8009d9 <walk_path>
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	0f 84 d1 00 00 00    	je     800fed <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800f1c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800f1f:	0f 85 0c 01 00 00    	jne    801031 <file_create+0x147>
  800f25:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f2b:	85 f6                	test   %esi,%esi
  800f2d:	0f 84 c1 00 00 00    	je     800ff4 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f33:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f39:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f3e:	74 19                	je     800f59 <file_create+0x6f>
  800f40:	68 8b 3e 80 00       	push   $0x803e8b
  800f45:	68 1d 3c 80 00       	push   $0x803c1d
  800f4a:	68 f4 00 00 00       	push   $0xf4
  800f4f:	68 f3 3d 80 00       	push   $0x803df3
  800f54:	e8 2e 0a 00 00       	call   801987 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f59:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	0f 48 c2             	cmovs  %edx,%eax
  800f64:	c1 f8 0c             	sar    $0xc,%eax
  800f67:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f72:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f78:	eb 3b                	jmp    800fb5 <file_create+0xcb>
  800f7a:	83 ec 04             	sub    $0x4,%esp
  800f7d:	57                   	push   %edi
  800f7e:	53                   	push   %ebx
  800f7f:	56                   	push   %esi
  800f80:	e8 f6 f9 ff ff       	call   80097b <file_get_block>
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	85 c0                	test   %eax,%eax
  800f8a:	0f 88 a1 00 00 00    	js     801031 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800f90:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f96:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800f9c:	80 38 00             	cmpb   $0x0,(%eax)
  800f9f:	75 08                	jne    800fa9 <file_create+0xbf>
				*file = &f[j];
  800fa1:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fa7:	eb 52                	jmp    800ffb <file_create+0x111>
  800fa9:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800fae:	39 d0                	cmp    %edx,%eax
  800fb0:	75 ea                	jne    800f9c <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800fb2:	83 c3 01             	add    $0x1,%ebx
  800fb5:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800fbb:	75 bd                	jne    800f7a <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800fbd:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800fc4:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800fd0:	50                   	push   %eax
  800fd1:	53                   	push   %ebx
  800fd2:	56                   	push   %esi
  800fd3:	e8 a3 f9 ff ff       	call   80097b <file_get_block>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 52                	js     801031 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800fdf:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fe5:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800feb:	eb 0e                	jmp    800ffb <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800fed:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800ff2:	eb 3d                	jmp    801031 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800ff4:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ff9:	eb 36                	jmp    801031 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  800ffb:	83 ec 08             	sub    $0x8,%esp
  800ffe:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  80100b:	e8 f5 0f 00 00       	call   802005 <strcpy>
	*pf = f;
  801010:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801016:	8b 45 0c             	mov    0xc(%ebp),%eax
  801019:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80101b:	83 c4 04             	add    $0x4,%esp
  80101e:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801024:	e8 24 fe ff ff       	call   800e4d <file_flush>
	return 0;
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801031:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	53                   	push   %ebx
  80103d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801040:	bb 01 00 00 00       	mov    $0x1,%ebx
  801045:	eb 17                	jmp    80105e <fs_sync+0x25>
		flush_block(diskaddr(i));
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	53                   	push   %ebx
  80104b:	e8 43 f3 ff ff       	call   800393 <diskaddr>
  801050:	89 04 24             	mov    %eax,(%esp)
  801053:	e8 b9 f3 ff ff       	call   800411 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801058:	83 c3 01             	add    $0x1,%ebx
  80105b:	83 c4 10             	add    $0x10,%esp
  80105e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  801063:	39 58 04             	cmp    %ebx,0x4(%eax)
  801066:	77 df                	ja     801047 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801068:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106b:	c9                   	leave  
  80106c:	c3                   	ret    

0080106d <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801073:	e8 c1 ff ff ff       	call   801039 <fs_sync>
	return 0;
}
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
  80107d:	c9                   	leave  
  80107e:	c3                   	ret    

0080107f <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  801087:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  80108c:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801091:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801093:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801096:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  80109c:	83 c0 01             	add    $0x1,%eax
  80109f:	83 c2 10             	add    $0x10,%edx
  8010a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010a7:	75 e8                	jne    801091 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
  8010b0:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	89 d8                	mov    %ebx,%eax
  8010bd:	c1 e0 04             	shl    $0x4,%eax
  8010c0:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010c6:	e8 f8 1e 00 00       	call   802fc3 <pageref>
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	74 07                	je     8010d9 <openfile_alloc+0x2e>
  8010d2:	83 f8 01             	cmp    $0x1,%eax
  8010d5:	74 20                	je     8010f7 <openfile_alloc+0x4c>
  8010d7:	eb 51                	jmp    80112a <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010d9:	83 ec 04             	sub    $0x4,%esp
  8010dc:	6a 07                	push   $0x7
  8010de:	89 d8                	mov    %ebx,%eax
  8010e0:	c1 e0 04             	shl    $0x4,%eax
  8010e3:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010e9:	6a 00                	push   $0x0
  8010eb:	e8 18 13 00 00       	call   802408 <sys_page_alloc>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 43                	js     80113a <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8010f7:	c1 e3 04             	shl    $0x4,%ebx
  8010fa:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801100:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801107:	04 00 00 
			*o = &opentab[i];
  80110a:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	68 00 10 00 00       	push   $0x1000
  801114:	6a 00                	push   $0x0
  801116:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  80111c:	e8 29 10 00 00       	call   80214a <memset>
			return (*o)->o_fileid;
  801121:	8b 06                	mov    (%esi),%eax
  801123:	8b 00                	mov    (%eax),%eax
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	eb 10                	jmp    80113a <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80112a:	83 c3 01             	add    $0x1,%ebx
  80112d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801133:	75 83                	jne    8010b8 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801135:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80113a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	57                   	push   %edi
  801145:	56                   	push   %esi
  801146:	53                   	push   %ebx
  801147:	83 ec 18             	sub    $0x18,%esp
  80114a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80114d:	89 fb                	mov    %edi,%ebx
  80114f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801155:	89 de                	mov    %ebx,%esi
  801157:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80115a:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801160:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801166:	e8 58 1e 00 00       	call   802fc3 <pageref>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	83 f8 01             	cmp    $0x1,%eax
  801171:	7e 17                	jle    80118a <openfile_lookup+0x49>
  801173:	c1 e3 04             	shl    $0x4,%ebx
  801176:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  80117c:	75 13                	jne    801191 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  80117e:	8b 45 10             	mov    0x10(%ebp),%eax
  801181:	89 30                	mov    %esi,(%eax)
	return 0;
  801183:	b8 00 00 00 00       	mov    $0x0,%eax
  801188:	eb 0c                	jmp    801196 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80118a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80118f:	eb 05                	jmp    801196 <openfile_lookup+0x55>
  801191:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  801196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 18             	sub    $0x18,%esp
  8011a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ab:	50                   	push   %eax
  8011ac:	ff 33                	pushl  (%ebx)
  8011ae:	ff 75 08             	pushl  0x8(%ebp)
  8011b1:	e8 8b ff ff ff       	call   801141 <openfile_lookup>
  8011b6:	83 c4 10             	add    $0x10,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 14                	js     8011d1 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	ff 73 04             	pushl  0x4(%ebx)
  8011c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c6:	ff 70 04             	pushl  0x4(%eax)
  8011c9:	e8 f8 fa ff ff       	call   800cc6 <file_set_size>
  8011ce:	83 c4 10             	add    $0x10,%esp
}
  8011d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 18             	sub    $0x18,%esp
  8011dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int check;
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	check = openfile_lookup(envid, req->req_fileid, &file);
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	ff 33                	pushl  (%ebx)
  8011e6:	ff 75 08             	pushl  0x8(%ebp)
  8011e9:	e8 53 ff ff ff       	call   801141 <openfile_lookup>
	
	if(check < 0)
  8011ee:	83 c4 10             	add    $0x10,%esp
		return check;
  8011f1:	89 c2                	mov    %eax,%edx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	check = openfile_lookup(envid, req->req_fileid, &file);
	
	if(check < 0)
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 2b                	js     801222 <serve_read+0x4c>
		return check;
		
	
	check = file_read(file->o_file, (void *) ret->ret_buf, (size_t) req->req_n, (off_t) file->o_fd->fd_offset);
  8011f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fa:	8b 50 0c             	mov    0xc(%eax),%edx
  8011fd:	ff 72 04             	pushl  0x4(%edx)
  801200:	ff 73 04             	pushl  0x4(%ebx)
  801203:	53                   	push   %ebx
  801204:	ff 70 04             	pushl  0x4(%eax)
  801207:	e8 15 fa ff ff       	call   800c21 <file_read>
	
	//cprintf("check =%d",check);
	if(check > 0)
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	7e 0d                	jle    801220 <serve_read+0x4a>
		file->o_fd->fd_offset += check;
  801213:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801216:	8b 52 0c             	mov    0xc(%edx),%edx
  801219:	01 42 04             	add    %eax,0x4(%edx)
	
	return check ;
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	eb 02                	jmp    801222 <serve_read+0x4c>
  801220:	89 c2                	mov    %eax,%edx
}
  801222:	89 d0                	mov    %edx,%eax
  801224:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801227:	c9                   	leave  
  801228:	c3                   	ret    

00801229 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{	
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	53                   	push   %ebx
  80122d:	83 ec 18             	sub    $0x18,%esp
  801230:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int check;
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	check = openfile_lookup(envid, req->req_fileid, &file);
  801233:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	ff 33                	pushl  (%ebx)
  801239:	ff 75 08             	pushl  0x8(%ebp)
  80123c:	e8 00 ff ff ff       	call   801141 <openfile_lookup>
	
	if(check < 0)
  801241:	83 c4 10             	add    $0x10,%esp
		return check;
  801244:	89 c2                	mov    %eax,%edx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	check = openfile_lookup(envid, req->req_fileid, &file);
	
	if(check < 0)
  801246:	85 c0                	test   %eax,%eax
  801248:	78 2e                	js     801278 <serve_write+0x4f>
		return check;
		
	
	check = file_write(file->o_file, (void *) req->req_buf, (size_t) req->req_n, (off_t) file->o_fd->fd_offset);
  80124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124d:	8b 50 0c             	mov    0xc(%eax),%edx
  801250:	ff 72 04             	pushl  0x4(%edx)
  801253:	ff 73 04             	pushl  0x4(%ebx)
  801256:	83 c3 08             	add    $0x8,%ebx
  801259:	53                   	push   %ebx
  80125a:	ff 70 04             	pushl  0x4(%eax)
  80125d:	e8 45 fb ff ff       	call   800da7 <file_write>
	
	//cprintf("check =%d",check);
	if(check > 0)
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	7e 0d                	jle    801276 <serve_write+0x4d>
		file->o_fd->fd_offset += check;
  801269:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80126c:	8b 52 0c             	mov    0xc(%edx),%edx
  80126f:	01 42 04             	add    %eax,0x4(%edx)
	return check;
  801272:	89 c2                	mov    %eax,%edx
  801274:	eb 02                	jmp    801278 <serve_write+0x4f>
  801276:	89 c2                	mov    %eax,%edx
	//panic("serve_write not implemented");
}
  801278:	89 d0                	mov    %edx,%eax
  80127a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	53                   	push   %ebx
  801283:	83 ec 18             	sub    $0x18,%esp
  801286:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801289:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128c:	50                   	push   %eax
  80128d:	ff 33                	pushl  (%ebx)
  80128f:	ff 75 08             	pushl  0x8(%ebp)
  801292:	e8 aa fe ff ff       	call   801141 <openfile_lookup>
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 3f                	js     8012dd <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80129e:	83 ec 08             	sub    $0x8,%esp
  8012a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a4:	ff 70 04             	pushl  0x4(%eax)
  8012a7:	53                   	push   %ebx
  8012a8:	e8 58 0d 00 00       	call   802005 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b0:	8b 50 04             	mov    0x4(%eax),%edx
  8012b3:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012b9:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012bf:	8b 40 04             	mov    0x4(%eax),%eax
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012cc:	0f 94 c0             	sete   %al
  8012cf:	0f b6 c0             	movzbl %al,%eax
  8012d2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    

008012e2 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ef:	ff 30                	pushl  (%eax)
  8012f1:	ff 75 08             	pushl  0x8(%ebp)
  8012f4:	e8 48 fe ff ff       	call   801141 <openfile_lookup>
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 16                	js     801316 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801300:	83 ec 0c             	sub    $0xc,%esp
  801303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801306:	ff 70 04             	pushl  0x4(%eax)
  801309:	e8 3f fb ff ff       	call   800e4d <file_flush>
	return 0;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801322:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801325:	68 00 04 00 00       	push   $0x400
  80132a:	53                   	push   %ebx
  80132b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	e8 60 0e 00 00       	call   802197 <memmove>
	path[MAXPATHLEN-1] = 0;
  801337:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80133b:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801341:	89 04 24             	mov    %eax,(%esp)
  801344:	e8 62 fd ff ff       	call   8010ab <openfile_alloc>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	0f 88 f0 00 00 00    	js     801444 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801354:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80135b:	74 33                	je     801390 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80136d:	50                   	push   %eax
  80136e:	e8 77 fb ff ff       	call   800eea <file_create>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	79 37                	jns    8013b1 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80137a:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801381:	0f 85 bd 00 00 00    	jne    801444 <serve_open+0x12c>
  801387:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80138a:	0f 85 b4 00 00 00    	jne    801444 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801399:	50                   	push   %eax
  80139a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	e8 61 f8 ff ff       	call   800c07 <file_open>
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	0f 88 93 00 00 00    	js     801444 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013b1:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013b8:	74 17                	je     8013d1 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013ba:	83 ec 08             	sub    $0x8,%esp
  8013bd:	6a 00                	push   $0x0
  8013bf:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013c5:	e8 fc f8 ff ff       	call   800cc6 <file_set_size>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	78 73                	js     801444 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013d1:	83 ec 08             	sub    $0x8,%esp
  8013d4:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	e8 20 f8 ff ff       	call   800c07 <file_open>
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	78 56                	js     801444 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8013ee:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8013f4:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8013fa:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8013fd:	8b 50 0c             	mov    0xc(%eax),%edx
  801400:	8b 08                	mov    (%eax),%ecx
  801402:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801405:	8b 48 0c             	mov    0xc(%eax),%ecx
  801408:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80140e:	83 e2 03             	and    $0x3,%edx
  801411:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80141d:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80141f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801425:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80142b:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80142e:	8b 50 0c             	mov    0xc(%eax),%edx
  801431:	8b 45 10             	mov    0x10(%ebp),%eax
  801434:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801436:	8b 45 14             	mov    0x14(%ebp),%eax
  801439:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80143f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801444:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	56                   	push   %esi
  80144d:	53                   	push   %ebx
  80144e:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801451:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801454:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801457:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	53                   	push   %ebx
  801462:	ff 35 44 50 80 00    	pushl  0x805044
  801468:	56                   	push   %esi
  801469:	e8 40 12 00 00       	call   8026ae <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801475:	75 15                	jne    80148c <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	ff 75 f4             	pushl  -0xc(%ebp)
  80147d:	68 c8 3e 80 00       	push   $0x803ec8
  801482:	e8 d9 05 00 00       	call   801a60 <cprintf>
				whom);
			continue; // just leave it hanging...
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	eb cb                	jmp    801457 <serve+0xe>
		}

		pg = NULL;
  80148c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801493:	83 f8 01             	cmp    $0x1,%eax
  801496:	75 18                	jne    8014b0 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801498:	53                   	push   %ebx
  801499:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	ff 35 44 50 80 00    	pushl  0x805044
  8014a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a6:	e8 6d fe ff ff       	call   801318 <serve_open>
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb 3c                	jmp    8014ec <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  8014b0:	83 f8 08             	cmp    $0x8,%eax
  8014b3:	77 1e                	ja     8014d3 <serve+0x8a>
  8014b5:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8014bc:	85 d2                	test   %edx,%edx
  8014be:	74 13                	je     8014d3 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	ff 35 44 50 80 00    	pushl  0x805044
  8014c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cc:	ff d2                	call   *%edx
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	eb 19                	jmp    8014ec <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d9:	50                   	push   %eax
  8014da:	68 f8 3e 80 00       	push   $0x803ef8
  8014df:	e8 7c 05 00 00       	call   801a60 <cprintf>
  8014e4:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8014e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8014ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8014ef:	ff 75 ec             	pushl  -0x14(%ebp)
  8014f2:	50                   	push   %eax
  8014f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f6:	e8 29 12 00 00       	call   802724 <ipc_send>
		sys_page_unmap(0, fsreq);
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	ff 35 44 50 80 00    	pushl  0x805044
  801504:	6a 00                	push   $0x0
  801506:	e8 82 0f 00 00       	call   80248d <sys_page_unmap>
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	e9 44 ff ff ff       	jmp    801457 <serve+0xe>

00801513 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801519:	c7 05 60 90 80 00 1b 	movl   $0x803f1b,0x809060
  801520:	3f 80 00 
	cprintf("FS is running\n");
  801523:	68 1e 3f 80 00       	push   $0x803f1e
  801528:	e8 33 05 00 00       	call   801a60 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80152d:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801532:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801537:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801539:	c7 04 24 2d 3f 80 00 	movl   $0x803f2d,(%esp)
  801540:	e8 1b 05 00 00       	call   801a60 <cprintf>

	serve_init();
  801545:	e8 35 fb ff ff       	call   80107f <serve_init>
	fs_init();
  80154a:	e8 cd f3 ff ff       	call   80091c <fs_init>
	serve();
  80154f:	e8 f5 fe ff ff       	call   801449 <serve>

00801554 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	53                   	push   %ebx
  801558:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80155b:	6a 07                	push   $0x7
  80155d:	68 00 10 00 00       	push   $0x1000
  801562:	6a 00                	push   $0x0
  801564:	e8 9f 0e 00 00       	call   802408 <sys_page_alloc>
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	85 c0                	test   %eax,%eax
  80156e:	79 12                	jns    801582 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801570:	50                   	push   %eax
  801571:	68 3c 3f 80 00       	push   $0x803f3c
  801576:	6a 12                	push   $0x12
  801578:	68 4f 3f 80 00       	push   $0x803f4f
  80157d:	e8 05 04 00 00       	call   801987 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801582:	83 ec 04             	sub    $0x4,%esp
  801585:	68 00 10 00 00       	push   $0x1000
  80158a:	ff 35 08 a0 80 00    	pushl  0x80a008
  801590:	68 00 10 00 00       	push   $0x1000
  801595:	e8 fd 0b 00 00       	call   802197 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80159a:	e8 96 f1 ff ff       	call   800735 <alloc_block>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	79 12                	jns    8015b8 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8015a6:	50                   	push   %eax
  8015a7:	68 59 3f 80 00       	push   $0x803f59
  8015ac:	6a 17                	push   $0x17
  8015ae:	68 4f 3f 80 00       	push   $0x803f4f
  8015b3:	e8 cf 03 00 00       	call   801987 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015b8:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	0f 49 d0             	cmovns %eax,%edx
  8015c0:	c1 fa 05             	sar    $0x5,%edx
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	c1 fb 1f             	sar    $0x1f,%ebx
  8015c8:	c1 eb 1b             	shr    $0x1b,%ebx
  8015cb:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015ce:	83 e1 1f             	and    $0x1f,%ecx
  8015d1:	29 d9                	sub    %ebx,%ecx
  8015d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d8:	d3 e0                	shl    %cl,%eax
  8015da:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8015e1:	75 16                	jne    8015f9 <fs_test+0xa5>
  8015e3:	68 69 3f 80 00       	push   $0x803f69
  8015e8:	68 1d 3c 80 00       	push   $0x803c1d
  8015ed:	6a 19                	push   $0x19
  8015ef:	68 4f 3f 80 00       	push   $0x803f4f
  8015f4:	e8 8e 03 00 00       	call   801987 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8015f9:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8015ff:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801602:	74 16                	je     80161a <fs_test+0xc6>
  801604:	68 e4 40 80 00       	push   $0x8040e4
  801609:	68 1d 3c 80 00       	push   $0x803c1d
  80160e:	6a 1b                	push   $0x1b
  801610:	68 4f 3f 80 00       	push   $0x803f4f
  801615:	e8 6d 03 00 00       	call   801987 <_panic>
	cprintf("alloc_block is good\n");
  80161a:	83 ec 0c             	sub    $0xc,%esp
  80161d:	68 84 3f 80 00       	push   $0x803f84
  801622:	e8 39 04 00 00       	call   801a60 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	68 99 3f 80 00       	push   $0x803f99
  801633:	e8 cf f5 ff ff       	call   800c07 <file_open>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80163e:	74 1b                	je     80165b <fs_test+0x107>
  801640:	89 c2                	mov    %eax,%edx
  801642:	c1 ea 1f             	shr    $0x1f,%edx
  801645:	84 d2                	test   %dl,%dl
  801647:	74 12                	je     80165b <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801649:	50                   	push   %eax
  80164a:	68 a4 3f 80 00       	push   $0x803fa4
  80164f:	6a 1f                	push   $0x1f
  801651:	68 4f 3f 80 00       	push   $0x803f4f
  801656:	e8 2c 03 00 00       	call   801987 <_panic>
	else if (r == 0)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	75 14                	jne    801673 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	68 04 41 80 00       	push   $0x804104
  801667:	6a 21                	push   $0x21
  801669:	68 4f 3f 80 00       	push   $0x803f4f
  80166e:	e8 14 03 00 00       	call   801987 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	68 bd 3f 80 00       	push   $0x803fbd
  80167f:	e8 83 f5 ff ff       	call   800c07 <file_open>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	79 12                	jns    80169d <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  80168b:	50                   	push   %eax
  80168c:	68 c6 3f 80 00       	push   $0x803fc6
  801691:	6a 23                	push   $0x23
  801693:	68 4f 3f 80 00       	push   $0x803f4f
  801698:	e8 ea 02 00 00       	call   801987 <_panic>
	cprintf("file_open is good\n");
  80169d:	83 ec 0c             	sub    $0xc,%esp
  8016a0:	68 dd 3f 80 00       	push   $0x803fdd
  8016a5:	e8 b6 03 00 00       	call   801a60 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016aa:	83 c4 0c             	add    $0xc,%esp
  8016ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b0:	50                   	push   %eax
  8016b1:	6a 00                	push   $0x0
  8016b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016b6:	e8 c0 f2 ff ff       	call   80097b <file_get_block>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	79 12                	jns    8016d4 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016c2:	50                   	push   %eax
  8016c3:	68 f0 3f 80 00       	push   $0x803ff0
  8016c8:	6a 27                	push   $0x27
  8016ca:	68 4f 3f 80 00       	push   $0x803f4f
  8016cf:	e8 b3 02 00 00       	call   801987 <_panic>
	if (strcmp(blk, msg) != 0)
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	68 24 41 80 00       	push   $0x804124
  8016dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8016df:	e8 cb 09 00 00       	call   8020af <strcmp>
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	74 14                	je     8016ff <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	68 4c 41 80 00       	push   $0x80414c
  8016f3:	6a 29                	push   $0x29
  8016f5:	68 4f 3f 80 00       	push   $0x803f4f
  8016fa:	e8 88 02 00 00       	call   801987 <_panic>
	cprintf("file_get_block is good\n");
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	68 03 40 80 00       	push   $0x804003
  801707:	e8 54 03 00 00       	call   801a60 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80170c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170f:	0f b6 10             	movzbl (%eax),%edx
  801712:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801714:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801717:	c1 e8 0c             	shr    $0xc,%eax
  80171a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	a8 40                	test   $0x40,%al
  801726:	75 16                	jne    80173e <fs_test+0x1ea>
  801728:	68 1c 40 80 00       	push   $0x80401c
  80172d:	68 1d 3c 80 00       	push   $0x803c1d
  801732:	6a 2d                	push   $0x2d
  801734:	68 4f 3f 80 00       	push   $0x803f4f
  801739:	e8 49 02 00 00       	call   801987 <_panic>
	file_flush(f);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	ff 75 f4             	pushl  -0xc(%ebp)
  801744:	e8 04 f7 ff ff       	call   800e4d <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174c:	c1 e8 0c             	shr    $0xc,%eax
  80174f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	a8 40                	test   $0x40,%al
  80175b:	74 16                	je     801773 <fs_test+0x21f>
  80175d:	68 1b 40 80 00       	push   $0x80401b
  801762:	68 1d 3c 80 00       	push   $0x803c1d
  801767:	6a 2f                	push   $0x2f
  801769:	68 4f 3f 80 00       	push   $0x803f4f
  80176e:	e8 14 02 00 00       	call   801987 <_panic>
	cprintf("file_flush is good\n");
  801773:	83 ec 0c             	sub    $0xc,%esp
  801776:	68 37 40 80 00       	push   $0x804037
  80177b:	e8 e0 02 00 00       	call   801a60 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801780:	83 c4 08             	add    $0x8,%esp
  801783:	6a 00                	push   $0x0
  801785:	ff 75 f4             	pushl  -0xc(%ebp)
  801788:	e8 39 f5 ff ff       	call   800cc6 <file_set_size>
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	85 c0                	test   %eax,%eax
  801792:	79 12                	jns    8017a6 <fs_test+0x252>
		panic("file_set_size: %e", r);
  801794:	50                   	push   %eax
  801795:	68 4b 40 80 00       	push   $0x80404b
  80179a:	6a 33                	push   $0x33
  80179c:	68 4f 3f 80 00       	push   $0x803f4f
  8017a1:	e8 e1 01 00 00       	call   801987 <_panic>
	assert(f->f_direct[0] == 0);
  8017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a9:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017b0:	74 16                	je     8017c8 <fs_test+0x274>
  8017b2:	68 5d 40 80 00       	push   $0x80405d
  8017b7:	68 1d 3c 80 00       	push   $0x803c1d
  8017bc:	6a 34                	push   $0x34
  8017be:	68 4f 3f 80 00       	push   $0x803f4f
  8017c3:	e8 bf 01 00 00       	call   801987 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017c8:	c1 e8 0c             	shr    $0xc,%eax
  8017cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017d2:	a8 40                	test   $0x40,%al
  8017d4:	74 16                	je     8017ec <fs_test+0x298>
  8017d6:	68 71 40 80 00       	push   $0x804071
  8017db:	68 1d 3c 80 00       	push   $0x803c1d
  8017e0:	6a 35                	push   $0x35
  8017e2:	68 4f 3f 80 00       	push   $0x803f4f
  8017e7:	e8 9b 01 00 00       	call   801987 <_panic>
	cprintf("file_truncate is good\n");
  8017ec:	83 ec 0c             	sub    $0xc,%esp
  8017ef:	68 8b 40 80 00       	push   $0x80408b
  8017f4:	e8 67 02 00 00       	call   801a60 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8017f9:	c7 04 24 24 41 80 00 	movl   $0x804124,(%esp)
  801800:	e8 c7 07 00 00       	call   801fcc <strlen>
  801805:	83 c4 08             	add    $0x8,%esp
  801808:	50                   	push   %eax
  801809:	ff 75 f4             	pushl  -0xc(%ebp)
  80180c:	e8 b5 f4 ff ff       	call   800cc6 <file_set_size>
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	85 c0                	test   %eax,%eax
  801816:	79 12                	jns    80182a <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  801818:	50                   	push   %eax
  801819:	68 a2 40 80 00       	push   $0x8040a2
  80181e:	6a 39                	push   $0x39
  801820:	68 4f 3f 80 00       	push   $0x803f4f
  801825:	e8 5d 01 00 00       	call   801987 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182d:	89 c2                	mov    %eax,%edx
  80182f:	c1 ea 0c             	shr    $0xc,%edx
  801832:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801839:	f6 c2 40             	test   $0x40,%dl
  80183c:	74 16                	je     801854 <fs_test+0x300>
  80183e:	68 71 40 80 00       	push   $0x804071
  801843:	68 1d 3c 80 00       	push   $0x803c1d
  801848:	6a 3a                	push   $0x3a
  80184a:	68 4f 3f 80 00       	push   $0x803f4f
  80184f:	e8 33 01 00 00       	call   801987 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801854:	83 ec 04             	sub    $0x4,%esp
  801857:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80185a:	52                   	push   %edx
  80185b:	6a 00                	push   $0x0
  80185d:	50                   	push   %eax
  80185e:	e8 18 f1 ff ff       	call   80097b <file_get_block>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	79 12                	jns    80187c <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80186a:	50                   	push   %eax
  80186b:	68 b6 40 80 00       	push   $0x8040b6
  801870:	6a 3c                	push   $0x3c
  801872:	68 4f 3f 80 00       	push   $0x803f4f
  801877:	e8 0b 01 00 00       	call   801987 <_panic>
	strcpy(blk, msg);
  80187c:	83 ec 08             	sub    $0x8,%esp
  80187f:	68 24 41 80 00       	push   $0x804124
  801884:	ff 75 f0             	pushl  -0x10(%ebp)
  801887:	e8 79 07 00 00       	call   802005 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188f:	c1 e8 0c             	shr    $0xc,%eax
  801892:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	a8 40                	test   $0x40,%al
  80189e:	75 16                	jne    8018b6 <fs_test+0x362>
  8018a0:	68 1c 40 80 00       	push   $0x80401c
  8018a5:	68 1d 3c 80 00       	push   $0x803c1d
  8018aa:	6a 3e                	push   $0x3e
  8018ac:	68 4f 3f 80 00       	push   $0x803f4f
  8018b1:	e8 d1 00 00 00       	call   801987 <_panic>
	file_flush(f);
  8018b6:	83 ec 0c             	sub    $0xc,%esp
  8018b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bc:	e8 8c f5 ff ff       	call   800e4d <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018c4:	c1 e8 0c             	shr    $0xc,%eax
  8018c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	a8 40                	test   $0x40,%al
  8018d3:	74 16                	je     8018eb <fs_test+0x397>
  8018d5:	68 1b 40 80 00       	push   $0x80401b
  8018da:	68 1d 3c 80 00       	push   $0x803c1d
  8018df:	6a 40                	push   $0x40
  8018e1:	68 4f 3f 80 00       	push   $0x803f4f
  8018e6:	e8 9c 00 00 00       	call   801987 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ee:	c1 e8 0c             	shr    $0xc,%eax
  8018f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f8:	a8 40                	test   $0x40,%al
  8018fa:	74 16                	je     801912 <fs_test+0x3be>
  8018fc:	68 71 40 80 00       	push   $0x804071
  801901:	68 1d 3c 80 00       	push   $0x803c1d
  801906:	6a 41                	push   $0x41
  801908:	68 4f 3f 80 00       	push   $0x803f4f
  80190d:	e8 75 00 00 00       	call   801987 <_panic>
	cprintf("file rewrite is good\n");
  801912:	83 ec 0c             	sub    $0xc,%esp
  801915:	68 cb 40 80 00       	push   $0x8040cb
  80191a:	e8 41 01 00 00       	call   801a60 <cprintf>
}
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80192f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  801932:	e8 93 0a 00 00       	call   8023ca <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  801937:	25 ff 03 00 00       	and    $0x3ff,%eax
  80193c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80193f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801944:	a3 10 a0 80 00       	mov    %eax,0x80a010
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801949:	85 db                	test   %ebx,%ebx
  80194b:	7e 07                	jle    801954 <libmain+0x2d>
		binaryname = argv[0];
  80194d:	8b 06                	mov    (%esi),%eax
  80194f:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	56                   	push   %esi
  801958:	53                   	push   %ebx
  801959:	e8 b5 fb ff ff       	call   801513 <umain>

	// exit gracefully
	exit();
  80195e:	e8 0a 00 00 00       	call   80196d <exit>
}
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801969:	5b                   	pop    %ebx
  80196a:	5e                   	pop    %esi
  80196b:	5d                   	pop    %ebp
  80196c:	c3                   	ret    

0080196d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801973:	e8 ff 0f 00 00       	call   802977 <close_all>
	sys_env_destroy(0);
  801978:	83 ec 0c             	sub    $0xc,%esp
  80197b:	6a 00                	push   $0x0
  80197d:	e8 07 0a 00 00       	call   802389 <sys_env_destroy>
}
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	c9                   	leave  
  801986:	c3                   	ret    

00801987 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	56                   	push   %esi
  80198b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80198c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80198f:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801995:	e8 30 0a 00 00       	call   8023ca <sys_getenvid>
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	ff 75 0c             	pushl  0xc(%ebp)
  8019a0:	ff 75 08             	pushl  0x8(%ebp)
  8019a3:	56                   	push   %esi
  8019a4:	50                   	push   %eax
  8019a5:	68 7c 41 80 00       	push   $0x80417c
  8019aa:	e8 b1 00 00 00       	call   801a60 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019af:	83 c4 18             	add    $0x18,%esp
  8019b2:	53                   	push   %ebx
  8019b3:	ff 75 10             	pushl  0x10(%ebp)
  8019b6:	e8 54 00 00 00       	call   801a0f <vcprintf>
	cprintf("\n");
  8019bb:	c7 04 24 8a 3d 80 00 	movl   $0x803d8a,(%esp)
  8019c2:	e8 99 00 00 00       	call   801a60 <cprintf>
  8019c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019ca:	cc                   	int3   
  8019cb:	eb fd                	jmp    8019ca <_panic+0x43>

008019cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	53                   	push   %ebx
  8019d1:	83 ec 04             	sub    $0x4,%esp
  8019d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019d7:	8b 13                	mov    (%ebx),%edx
  8019d9:	8d 42 01             	lea    0x1(%edx),%eax
  8019dc:	89 03                	mov    %eax,(%ebx)
  8019de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019ea:	75 1a                	jne    801a06 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	68 ff 00 00 00       	push   $0xff
  8019f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8019f7:	50                   	push   %eax
  8019f8:	e8 4f 09 00 00       	call   80234c <sys_cputs>
		b->idx = 0;
  8019fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a03:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a06:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a18:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a1f:	00 00 00 
	b.cnt = 0;
  801a22:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a29:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a2c:	ff 75 0c             	pushl  0xc(%ebp)
  801a2f:	ff 75 08             	pushl  0x8(%ebp)
  801a32:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a38:	50                   	push   %eax
  801a39:	68 cd 19 80 00       	push   $0x8019cd
  801a3e:	e8 54 01 00 00       	call   801b97 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a43:	83 c4 08             	add    $0x8,%esp
  801a46:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a4c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a52:	50                   	push   %eax
  801a53:	e8 f4 08 00 00       	call   80234c <sys_cputs>

	return b.cnt;
}
  801a58:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a66:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a69:	50                   	push   %eax
  801a6a:	ff 75 08             	pushl  0x8(%ebp)
  801a6d:	e8 9d ff ff ff       	call   801a0f <vcprintf>
	va_end(ap);

	return cnt;
}
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 1c             	sub    $0x1c,%esp
  801a7d:	89 c7                	mov    %eax,%edi
  801a7f:	89 d6                	mov    %edx,%esi
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a8a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a95:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a98:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a9b:	39 d3                	cmp    %edx,%ebx
  801a9d:	72 05                	jb     801aa4 <printnum+0x30>
  801a9f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801aa2:	77 45                	ja     801ae9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	ff 75 18             	pushl  0x18(%ebp)
  801aaa:	8b 45 14             	mov    0x14(%ebp),%eax
  801aad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801ab0:	53                   	push   %ebx
  801ab1:	ff 75 10             	pushl  0x10(%ebp)
  801ab4:	83 ec 08             	sub    $0x8,%esp
  801ab7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aba:	ff 75 e0             	pushl  -0x20(%ebp)
  801abd:	ff 75 dc             	pushl  -0x24(%ebp)
  801ac0:	ff 75 d8             	pushl  -0x28(%ebp)
  801ac3:	e8 88 1e 00 00       	call   803950 <__udivdi3>
  801ac8:	83 c4 18             	add    $0x18,%esp
  801acb:	52                   	push   %edx
  801acc:	50                   	push   %eax
  801acd:	89 f2                	mov    %esi,%edx
  801acf:	89 f8                	mov    %edi,%eax
  801ad1:	e8 9e ff ff ff       	call   801a74 <printnum>
  801ad6:	83 c4 20             	add    $0x20,%esp
  801ad9:	eb 18                	jmp    801af3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	56                   	push   %esi
  801adf:	ff 75 18             	pushl  0x18(%ebp)
  801ae2:	ff d7                	call   *%edi
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	eb 03                	jmp    801aec <printnum+0x78>
  801ae9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801aec:	83 eb 01             	sub    $0x1,%ebx
  801aef:	85 db                	test   %ebx,%ebx
  801af1:	7f e8                	jg     801adb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801af3:	83 ec 08             	sub    $0x8,%esp
  801af6:	56                   	push   %esi
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	ff 75 e4             	pushl  -0x1c(%ebp)
  801afd:	ff 75 e0             	pushl  -0x20(%ebp)
  801b00:	ff 75 dc             	pushl  -0x24(%ebp)
  801b03:	ff 75 d8             	pushl  -0x28(%ebp)
  801b06:	e8 75 1f 00 00       	call   803a80 <__umoddi3>
  801b0b:	83 c4 14             	add    $0x14,%esp
  801b0e:	0f be 80 9f 41 80 00 	movsbl 0x80419f(%eax),%eax
  801b15:	50                   	push   %eax
  801b16:	ff d7                	call   *%edi
}
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b26:	83 fa 01             	cmp    $0x1,%edx
  801b29:	7e 0e                	jle    801b39 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b2b:	8b 10                	mov    (%eax),%edx
  801b2d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b30:	89 08                	mov    %ecx,(%eax)
  801b32:	8b 02                	mov    (%edx),%eax
  801b34:	8b 52 04             	mov    0x4(%edx),%edx
  801b37:	eb 22                	jmp    801b5b <getuint+0x38>
	else if (lflag)
  801b39:	85 d2                	test   %edx,%edx
  801b3b:	74 10                	je     801b4d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b3d:	8b 10                	mov    (%eax),%edx
  801b3f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b42:	89 08                	mov    %ecx,(%eax)
  801b44:	8b 02                	mov    (%edx),%eax
  801b46:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4b:	eb 0e                	jmp    801b5b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b4d:	8b 10                	mov    (%eax),%edx
  801b4f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b52:	89 08                	mov    %ecx,(%eax)
  801b54:	8b 02                	mov    (%edx),%eax
  801b56:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b63:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b67:	8b 10                	mov    (%eax),%edx
  801b69:	3b 50 04             	cmp    0x4(%eax),%edx
  801b6c:	73 0a                	jae    801b78 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b6e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b71:	89 08                	mov    %ecx,(%eax)
  801b73:	8b 45 08             	mov    0x8(%ebp),%eax
  801b76:	88 02                	mov    %al,(%edx)
}
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b80:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b83:	50                   	push   %eax
  801b84:	ff 75 10             	pushl  0x10(%ebp)
  801b87:	ff 75 0c             	pushl  0xc(%ebp)
  801b8a:	ff 75 08             	pushl  0x8(%ebp)
  801b8d:	e8 05 00 00 00       	call   801b97 <vprintfmt>
	va_end(ap);
}
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    

00801b97 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	57                   	push   %edi
  801b9b:	56                   	push   %esi
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 2c             	sub    $0x2c,%esp
  801ba0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ba6:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ba9:	eb 12                	jmp    801bbd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801bab:	85 c0                	test   %eax,%eax
  801bad:	0f 84 a9 03 00 00    	je     801f5c <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  801bb3:	83 ec 08             	sub    $0x8,%esp
  801bb6:	53                   	push   %ebx
  801bb7:	50                   	push   %eax
  801bb8:	ff d6                	call   *%esi
  801bba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801bbd:	83 c7 01             	add    $0x1,%edi
  801bc0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bc4:	83 f8 25             	cmp    $0x25,%eax
  801bc7:	75 e2                	jne    801bab <vprintfmt+0x14>
  801bc9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bcd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bd4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bdb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801be2:	ba 00 00 00 00       	mov    $0x0,%edx
  801be7:	eb 07                	jmp    801bf0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801be9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801bec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bf0:	8d 47 01             	lea    0x1(%edi),%eax
  801bf3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bf6:	0f b6 07             	movzbl (%edi),%eax
  801bf9:	0f b6 c8             	movzbl %al,%ecx
  801bfc:	83 e8 23             	sub    $0x23,%eax
  801bff:	3c 55                	cmp    $0x55,%al
  801c01:	0f 87 3a 03 00 00    	ja     801f41 <vprintfmt+0x3aa>
  801c07:	0f b6 c0             	movzbl %al,%eax
  801c0a:	ff 24 85 e0 42 80 00 	jmp    *0x8042e0(,%eax,4)
  801c11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c14:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c18:	eb d6                	jmp    801bf0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c22:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c25:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c28:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c2c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c2f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c32:	83 fa 09             	cmp    $0x9,%edx
  801c35:	77 39                	ja     801c70 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c37:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c3a:	eb e9                	jmp    801c25 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c3f:	8d 48 04             	lea    0x4(%eax),%ecx
  801c42:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c45:	8b 00                	mov    (%eax),%eax
  801c47:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c4d:	eb 27                	jmp    801c76 <vprintfmt+0xdf>
  801c4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c52:	85 c0                	test   %eax,%eax
  801c54:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c59:	0f 49 c8             	cmovns %eax,%ecx
  801c5c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c62:	eb 8c                	jmp    801bf0 <vprintfmt+0x59>
  801c64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c67:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c6e:	eb 80                	jmp    801bf0 <vprintfmt+0x59>
  801c70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c73:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c7a:	0f 89 70 ff ff ff    	jns    801bf0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801c80:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c83:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c86:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c8d:	e9 5e ff ff ff       	jmp    801bf0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c92:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c98:	e9 53 ff ff ff       	jmp    801bf0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca0:	8d 50 04             	lea    0x4(%eax),%edx
  801ca3:	89 55 14             	mov    %edx,0x14(%ebp)
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	53                   	push   %ebx
  801caa:	ff 30                	pushl  (%eax)
  801cac:	ff d6                	call   *%esi
			break;
  801cae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cb4:	e9 04 ff ff ff       	jmp    801bbd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cb9:	8b 45 14             	mov    0x14(%ebp),%eax
  801cbc:	8d 50 04             	lea    0x4(%eax),%edx
  801cbf:	89 55 14             	mov    %edx,0x14(%ebp)
  801cc2:	8b 00                	mov    (%eax),%eax
  801cc4:	99                   	cltd   
  801cc5:	31 d0                	xor    %edx,%eax
  801cc7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801cc9:	83 f8 0f             	cmp    $0xf,%eax
  801ccc:	7f 0b                	jg     801cd9 <vprintfmt+0x142>
  801cce:	8b 14 85 40 44 80 00 	mov    0x804440(,%eax,4),%edx
  801cd5:	85 d2                	test   %edx,%edx
  801cd7:	75 18                	jne    801cf1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801cd9:	50                   	push   %eax
  801cda:	68 b7 41 80 00       	push   $0x8041b7
  801cdf:	53                   	push   %ebx
  801ce0:	56                   	push   %esi
  801ce1:	e8 94 fe ff ff       	call   801b7a <printfmt>
  801ce6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ce9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801cec:	e9 cc fe ff ff       	jmp    801bbd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cf1:	52                   	push   %edx
  801cf2:	68 2f 3c 80 00       	push   $0x803c2f
  801cf7:	53                   	push   %ebx
  801cf8:	56                   	push   %esi
  801cf9:	e8 7c fe ff ff       	call   801b7a <printfmt>
  801cfe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d04:	e9 b4 fe ff ff       	jmp    801bbd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d09:	8b 45 14             	mov    0x14(%ebp),%eax
  801d0c:	8d 50 04             	lea    0x4(%eax),%edx
  801d0f:	89 55 14             	mov    %edx,0x14(%ebp)
  801d12:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d14:	85 ff                	test   %edi,%edi
  801d16:	b8 b0 41 80 00       	mov    $0x8041b0,%eax
  801d1b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d1e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d22:	0f 8e 94 00 00 00    	jle    801dbc <vprintfmt+0x225>
  801d28:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d2c:	0f 84 98 00 00 00    	je     801dca <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d32:	83 ec 08             	sub    $0x8,%esp
  801d35:	ff 75 d0             	pushl  -0x30(%ebp)
  801d38:	57                   	push   %edi
  801d39:	e8 a6 02 00 00       	call   801fe4 <strnlen>
  801d3e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d41:	29 c1                	sub    %eax,%ecx
  801d43:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d46:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d49:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d50:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d53:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d55:	eb 0f                	jmp    801d66 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d57:	83 ec 08             	sub    $0x8,%esp
  801d5a:	53                   	push   %ebx
  801d5b:	ff 75 e0             	pushl  -0x20(%ebp)
  801d5e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d60:	83 ef 01             	sub    $0x1,%edi
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	85 ff                	test   %edi,%edi
  801d68:	7f ed                	jg     801d57 <vprintfmt+0x1c0>
  801d6a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d6d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d70:	85 c9                	test   %ecx,%ecx
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
  801d77:	0f 49 c1             	cmovns %ecx,%eax
  801d7a:	29 c1                	sub    %eax,%ecx
  801d7c:	89 75 08             	mov    %esi,0x8(%ebp)
  801d7f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d82:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d85:	89 cb                	mov    %ecx,%ebx
  801d87:	eb 4d                	jmp    801dd6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d89:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d8d:	74 1b                	je     801daa <vprintfmt+0x213>
  801d8f:	0f be c0             	movsbl %al,%eax
  801d92:	83 e8 20             	sub    $0x20,%eax
  801d95:	83 f8 5e             	cmp    $0x5e,%eax
  801d98:	76 10                	jbe    801daa <vprintfmt+0x213>
					putch('?', putdat);
  801d9a:	83 ec 08             	sub    $0x8,%esp
  801d9d:	ff 75 0c             	pushl  0xc(%ebp)
  801da0:	6a 3f                	push   $0x3f
  801da2:	ff 55 08             	call   *0x8(%ebp)
  801da5:	83 c4 10             	add    $0x10,%esp
  801da8:	eb 0d                	jmp    801db7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801daa:	83 ec 08             	sub    $0x8,%esp
  801dad:	ff 75 0c             	pushl  0xc(%ebp)
  801db0:	52                   	push   %edx
  801db1:	ff 55 08             	call   *0x8(%ebp)
  801db4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801db7:	83 eb 01             	sub    $0x1,%ebx
  801dba:	eb 1a                	jmp    801dd6 <vprintfmt+0x23f>
  801dbc:	89 75 08             	mov    %esi,0x8(%ebp)
  801dbf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dc2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dc5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dc8:	eb 0c                	jmp    801dd6 <vprintfmt+0x23f>
  801dca:	89 75 08             	mov    %esi,0x8(%ebp)
  801dcd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801dd0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801dd3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dd6:	83 c7 01             	add    $0x1,%edi
  801dd9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ddd:	0f be d0             	movsbl %al,%edx
  801de0:	85 d2                	test   %edx,%edx
  801de2:	74 23                	je     801e07 <vprintfmt+0x270>
  801de4:	85 f6                	test   %esi,%esi
  801de6:	78 a1                	js     801d89 <vprintfmt+0x1f2>
  801de8:	83 ee 01             	sub    $0x1,%esi
  801deb:	79 9c                	jns    801d89 <vprintfmt+0x1f2>
  801ded:	89 df                	mov    %ebx,%edi
  801def:	8b 75 08             	mov    0x8(%ebp),%esi
  801df2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801df5:	eb 18                	jmp    801e0f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801df7:	83 ec 08             	sub    $0x8,%esp
  801dfa:	53                   	push   %ebx
  801dfb:	6a 20                	push   $0x20
  801dfd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801dff:	83 ef 01             	sub    $0x1,%edi
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	eb 08                	jmp    801e0f <vprintfmt+0x278>
  801e07:	89 df                	mov    %ebx,%edi
  801e09:	8b 75 08             	mov    0x8(%ebp),%esi
  801e0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e0f:	85 ff                	test   %edi,%edi
  801e11:	7f e4                	jg     801df7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e16:	e9 a2 fd ff ff       	jmp    801bbd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e1b:	83 fa 01             	cmp    $0x1,%edx
  801e1e:	7e 16                	jle    801e36 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e20:	8b 45 14             	mov    0x14(%ebp),%eax
  801e23:	8d 50 08             	lea    0x8(%eax),%edx
  801e26:	89 55 14             	mov    %edx,0x14(%ebp)
  801e29:	8b 50 04             	mov    0x4(%eax),%edx
  801e2c:	8b 00                	mov    (%eax),%eax
  801e2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e31:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e34:	eb 32                	jmp    801e68 <vprintfmt+0x2d1>
	else if (lflag)
  801e36:	85 d2                	test   %edx,%edx
  801e38:	74 18                	je     801e52 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e3a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3d:	8d 50 04             	lea    0x4(%eax),%edx
  801e40:	89 55 14             	mov    %edx,0x14(%ebp)
  801e43:	8b 00                	mov    (%eax),%eax
  801e45:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e48:	89 c1                	mov    %eax,%ecx
  801e4a:	c1 f9 1f             	sar    $0x1f,%ecx
  801e4d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e50:	eb 16                	jmp    801e68 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e52:	8b 45 14             	mov    0x14(%ebp),%eax
  801e55:	8d 50 04             	lea    0x4(%eax),%edx
  801e58:	89 55 14             	mov    %edx,0x14(%ebp)
  801e5b:	8b 00                	mov    (%eax),%eax
  801e5d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e60:	89 c1                	mov    %eax,%ecx
  801e62:	c1 f9 1f             	sar    $0x1f,%ecx
  801e65:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e68:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e6b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e6e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e73:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e77:	0f 89 90 00 00 00    	jns    801f0d <vprintfmt+0x376>
				putch('-', putdat);
  801e7d:	83 ec 08             	sub    $0x8,%esp
  801e80:	53                   	push   %ebx
  801e81:	6a 2d                	push   $0x2d
  801e83:	ff d6                	call   *%esi
				num = -(long long) num;
  801e85:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e88:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801e8b:	f7 d8                	neg    %eax
  801e8d:	83 d2 00             	adc    $0x0,%edx
  801e90:	f7 da                	neg    %edx
  801e92:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e95:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801e9a:	eb 71                	jmp    801f0d <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801e9c:	8d 45 14             	lea    0x14(%ebp),%eax
  801e9f:	e8 7f fc ff ff       	call   801b23 <getuint>
			base = 10;
  801ea4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ea9:	eb 62                	jmp    801f0d <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801eab:	8d 45 14             	lea    0x14(%ebp),%eax
  801eae:	e8 70 fc ff ff       	call   801b23 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  801eba:	51                   	push   %ecx
  801ebb:	ff 75 e0             	pushl  -0x20(%ebp)
  801ebe:	6a 08                	push   $0x8
  801ec0:	52                   	push   %edx
  801ec1:	50                   	push   %eax
  801ec2:	89 da                	mov    %ebx,%edx
  801ec4:	89 f0                	mov    %esi,%eax
  801ec6:	e8 a9 fb ff ff       	call   801a74 <printnum>
			break;
  801ecb:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ece:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  801ed1:	e9 e7 fc ff ff       	jmp    801bbd <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801ed6:	83 ec 08             	sub    $0x8,%esp
  801ed9:	53                   	push   %ebx
  801eda:	6a 30                	push   $0x30
  801edc:	ff d6                	call   *%esi
			putch('x', putdat);
  801ede:	83 c4 08             	add    $0x8,%esp
  801ee1:	53                   	push   %ebx
  801ee2:	6a 78                	push   $0x78
  801ee4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ee6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ee9:	8d 50 04             	lea    0x4(%eax),%edx
  801eec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801eef:	8b 00                	mov    (%eax),%eax
  801ef1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ef6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ef9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801efe:	eb 0d                	jmp    801f0d <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f00:	8d 45 14             	lea    0x14(%ebp),%eax
  801f03:	e8 1b fc ff ff       	call   801b23 <getuint>
			base = 16;
  801f08:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f0d:	83 ec 0c             	sub    $0xc,%esp
  801f10:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f14:	57                   	push   %edi
  801f15:	ff 75 e0             	pushl  -0x20(%ebp)
  801f18:	51                   	push   %ecx
  801f19:	52                   	push   %edx
  801f1a:	50                   	push   %eax
  801f1b:	89 da                	mov    %ebx,%edx
  801f1d:	89 f0                	mov    %esi,%eax
  801f1f:	e8 50 fb ff ff       	call   801a74 <printnum>
			break;
  801f24:	83 c4 20             	add    $0x20,%esp
  801f27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f2a:	e9 8e fc ff ff       	jmp    801bbd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f2f:	83 ec 08             	sub    $0x8,%esp
  801f32:	53                   	push   %ebx
  801f33:	51                   	push   %ecx
  801f34:	ff d6                	call   *%esi
			break;
  801f36:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f39:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f3c:	e9 7c fc ff ff       	jmp    801bbd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f41:	83 ec 08             	sub    $0x8,%esp
  801f44:	53                   	push   %ebx
  801f45:	6a 25                	push   $0x25
  801f47:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	eb 03                	jmp    801f51 <vprintfmt+0x3ba>
  801f4e:	83 ef 01             	sub    $0x1,%edi
  801f51:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f55:	75 f7                	jne    801f4e <vprintfmt+0x3b7>
  801f57:	e9 61 fc ff ff       	jmp    801bbd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	83 ec 18             	sub    $0x18,%esp
  801f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f73:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f77:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f81:	85 c0                	test   %eax,%eax
  801f83:	74 26                	je     801fab <vsnprintf+0x47>
  801f85:	85 d2                	test   %edx,%edx
  801f87:	7e 22                	jle    801fab <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f89:	ff 75 14             	pushl  0x14(%ebp)
  801f8c:	ff 75 10             	pushl  0x10(%ebp)
  801f8f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f92:	50                   	push   %eax
  801f93:	68 5d 1b 80 00       	push   $0x801b5d
  801f98:	e8 fa fb ff ff       	call   801b97 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fa0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	eb 05                	jmp    801fb0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801fab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801fb0:	c9                   	leave  
  801fb1:	c3                   	ret    

00801fb2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fb2:	55                   	push   %ebp
  801fb3:	89 e5                	mov    %esp,%ebp
  801fb5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fb8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fbb:	50                   	push   %eax
  801fbc:	ff 75 10             	pushl  0x10(%ebp)
  801fbf:	ff 75 0c             	pushl  0xc(%ebp)
  801fc2:	ff 75 08             	pushl  0x8(%ebp)
  801fc5:	e8 9a ff ff ff       	call   801f64 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    

00801fcc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd7:	eb 03                	jmp    801fdc <strlen+0x10>
		n++;
  801fd9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fdc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fe0:	75 f7                	jne    801fd9 <strlen+0xd>
		n++;
	return n;
}
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fea:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fed:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff2:	eb 03                	jmp    801ff7 <strnlen+0x13>
		n++;
  801ff4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ff7:	39 c2                	cmp    %eax,%edx
  801ff9:	74 08                	je     802003 <strnlen+0x1f>
  801ffb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801fff:	75 f3                	jne    801ff4 <strnlen+0x10>
  802001:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	53                   	push   %ebx
  802009:	8b 45 08             	mov    0x8(%ebp),%eax
  80200c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80200f:	89 c2                	mov    %eax,%edx
  802011:	83 c2 01             	add    $0x1,%edx
  802014:	83 c1 01             	add    $0x1,%ecx
  802017:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80201b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80201e:	84 db                	test   %bl,%bl
  802020:	75 ef                	jne    802011 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802022:	5b                   	pop    %ebx
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    

00802025 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	53                   	push   %ebx
  802029:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80202c:	53                   	push   %ebx
  80202d:	e8 9a ff ff ff       	call   801fcc <strlen>
  802032:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802035:	ff 75 0c             	pushl  0xc(%ebp)
  802038:	01 d8                	add    %ebx,%eax
  80203a:	50                   	push   %eax
  80203b:	e8 c5 ff ff ff       	call   802005 <strcpy>
	return dst;
}
  802040:	89 d8                	mov    %ebx,%eax
  802042:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802045:	c9                   	leave  
  802046:	c3                   	ret    

00802047 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	56                   	push   %esi
  80204b:	53                   	push   %ebx
  80204c:	8b 75 08             	mov    0x8(%ebp),%esi
  80204f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802052:	89 f3                	mov    %esi,%ebx
  802054:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802057:	89 f2                	mov    %esi,%edx
  802059:	eb 0f                	jmp    80206a <strncpy+0x23>
		*dst++ = *src;
  80205b:	83 c2 01             	add    $0x1,%edx
  80205e:	0f b6 01             	movzbl (%ecx),%eax
  802061:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802064:	80 39 01             	cmpb   $0x1,(%ecx)
  802067:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80206a:	39 da                	cmp    %ebx,%edx
  80206c:	75 ed                	jne    80205b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80206e:	89 f0                	mov    %esi,%eax
  802070:	5b                   	pop    %ebx
  802071:	5e                   	pop    %esi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	56                   	push   %esi
  802078:	53                   	push   %ebx
  802079:	8b 75 08             	mov    0x8(%ebp),%esi
  80207c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80207f:	8b 55 10             	mov    0x10(%ebp),%edx
  802082:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802084:	85 d2                	test   %edx,%edx
  802086:	74 21                	je     8020a9 <strlcpy+0x35>
  802088:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80208c:	89 f2                	mov    %esi,%edx
  80208e:	eb 09                	jmp    802099 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802090:	83 c2 01             	add    $0x1,%edx
  802093:	83 c1 01             	add    $0x1,%ecx
  802096:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802099:	39 c2                	cmp    %eax,%edx
  80209b:	74 09                	je     8020a6 <strlcpy+0x32>
  80209d:	0f b6 19             	movzbl (%ecx),%ebx
  8020a0:	84 db                	test   %bl,%bl
  8020a2:	75 ec                	jne    802090 <strlcpy+0x1c>
  8020a4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8020a9:	29 f0                	sub    %esi,%eax
}
  8020ab:	5b                   	pop    %ebx
  8020ac:	5e                   	pop    %esi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    

008020af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8020b8:	eb 06                	jmp    8020c0 <strcmp+0x11>
		p++, q++;
  8020ba:	83 c1 01             	add    $0x1,%ecx
  8020bd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8020c0:	0f b6 01             	movzbl (%ecx),%eax
  8020c3:	84 c0                	test   %al,%al
  8020c5:	74 04                	je     8020cb <strcmp+0x1c>
  8020c7:	3a 02                	cmp    (%edx),%al
  8020c9:	74 ef                	je     8020ba <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020cb:	0f b6 c0             	movzbl %al,%eax
  8020ce:	0f b6 12             	movzbl (%edx),%edx
  8020d1:	29 d0                	sub    %edx,%eax
}
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    

008020d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020d5:	55                   	push   %ebp
  8020d6:	89 e5                	mov    %esp,%ebp
  8020d8:	53                   	push   %ebx
  8020d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020df:	89 c3                	mov    %eax,%ebx
  8020e1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020e4:	eb 06                	jmp    8020ec <strncmp+0x17>
		n--, p++, q++;
  8020e6:	83 c0 01             	add    $0x1,%eax
  8020e9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020ec:	39 d8                	cmp    %ebx,%eax
  8020ee:	74 15                	je     802105 <strncmp+0x30>
  8020f0:	0f b6 08             	movzbl (%eax),%ecx
  8020f3:	84 c9                	test   %cl,%cl
  8020f5:	74 04                	je     8020fb <strncmp+0x26>
  8020f7:	3a 0a                	cmp    (%edx),%cl
  8020f9:	74 eb                	je     8020e6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020fb:	0f b6 00             	movzbl (%eax),%eax
  8020fe:	0f b6 12             	movzbl (%edx),%edx
  802101:	29 d0                	sub    %edx,%eax
  802103:	eb 05                	jmp    80210a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80210a:	5b                   	pop    %ebx
  80210b:	5d                   	pop    %ebp
  80210c:	c3                   	ret    

0080210d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	8b 45 08             	mov    0x8(%ebp),%eax
  802113:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802117:	eb 07                	jmp    802120 <strchr+0x13>
		if (*s == c)
  802119:	38 ca                	cmp    %cl,%dl
  80211b:	74 0f                	je     80212c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80211d:	83 c0 01             	add    $0x1,%eax
  802120:	0f b6 10             	movzbl (%eax),%edx
  802123:	84 d2                	test   %dl,%dl
  802125:	75 f2                	jne    802119 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802127:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212c:	5d                   	pop    %ebp
  80212d:	c3                   	ret    

0080212e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80212e:	55                   	push   %ebp
  80212f:	89 e5                	mov    %esp,%ebp
  802131:	8b 45 08             	mov    0x8(%ebp),%eax
  802134:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802138:	eb 03                	jmp    80213d <strfind+0xf>
  80213a:	83 c0 01             	add    $0x1,%eax
  80213d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802140:	38 ca                	cmp    %cl,%dl
  802142:	74 04                	je     802148 <strfind+0x1a>
  802144:	84 d2                	test   %dl,%dl
  802146:	75 f2                	jne    80213a <strfind+0xc>
			break;
	return (char *) s;
}
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    

0080214a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80214a:	55                   	push   %ebp
  80214b:	89 e5                	mov    %esp,%ebp
  80214d:	57                   	push   %edi
  80214e:	56                   	push   %esi
  80214f:	53                   	push   %ebx
  802150:	8b 7d 08             	mov    0x8(%ebp),%edi
  802153:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802156:	85 c9                	test   %ecx,%ecx
  802158:	74 36                	je     802190 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80215a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802160:	75 28                	jne    80218a <memset+0x40>
  802162:	f6 c1 03             	test   $0x3,%cl
  802165:	75 23                	jne    80218a <memset+0x40>
		c &= 0xFF;
  802167:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80216b:	89 d3                	mov    %edx,%ebx
  80216d:	c1 e3 08             	shl    $0x8,%ebx
  802170:	89 d6                	mov    %edx,%esi
  802172:	c1 e6 18             	shl    $0x18,%esi
  802175:	89 d0                	mov    %edx,%eax
  802177:	c1 e0 10             	shl    $0x10,%eax
  80217a:	09 f0                	or     %esi,%eax
  80217c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80217e:	89 d8                	mov    %ebx,%eax
  802180:	09 d0                	or     %edx,%eax
  802182:	c1 e9 02             	shr    $0x2,%ecx
  802185:	fc                   	cld    
  802186:	f3 ab                	rep stos %eax,%es:(%edi)
  802188:	eb 06                	jmp    802190 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80218a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218d:	fc                   	cld    
  80218e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802190:	89 f8                	mov    %edi,%eax
  802192:	5b                   	pop    %ebx
  802193:	5e                   	pop    %esi
  802194:	5f                   	pop    %edi
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    

00802197 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	57                   	push   %edi
  80219b:	56                   	push   %esi
  80219c:	8b 45 08             	mov    0x8(%ebp),%eax
  80219f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021a5:	39 c6                	cmp    %eax,%esi
  8021a7:	73 35                	jae    8021de <memmove+0x47>
  8021a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8021ac:	39 d0                	cmp    %edx,%eax
  8021ae:	73 2e                	jae    8021de <memmove+0x47>
		s += n;
		d += n;
  8021b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b3:	89 d6                	mov    %edx,%esi
  8021b5:	09 fe                	or     %edi,%esi
  8021b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021bd:	75 13                	jne    8021d2 <memmove+0x3b>
  8021bf:	f6 c1 03             	test   $0x3,%cl
  8021c2:	75 0e                	jne    8021d2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8021c4:	83 ef 04             	sub    $0x4,%edi
  8021c7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021ca:	c1 e9 02             	shr    $0x2,%ecx
  8021cd:	fd                   	std    
  8021ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021d0:	eb 09                	jmp    8021db <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021d2:	83 ef 01             	sub    $0x1,%edi
  8021d5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021d8:	fd                   	std    
  8021d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021db:	fc                   	cld    
  8021dc:	eb 1d                	jmp    8021fb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021de:	89 f2                	mov    %esi,%edx
  8021e0:	09 c2                	or     %eax,%edx
  8021e2:	f6 c2 03             	test   $0x3,%dl
  8021e5:	75 0f                	jne    8021f6 <memmove+0x5f>
  8021e7:	f6 c1 03             	test   $0x3,%cl
  8021ea:	75 0a                	jne    8021f6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8021ec:	c1 e9 02             	shr    $0x2,%ecx
  8021ef:	89 c7                	mov    %eax,%edi
  8021f1:	fc                   	cld    
  8021f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021f4:	eb 05                	jmp    8021fb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021f6:	89 c7                	mov    %eax,%edi
  8021f8:	fc                   	cld    
  8021f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021fb:	5e                   	pop    %esi
  8021fc:	5f                   	pop    %edi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    

008021ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8021ff:	55                   	push   %ebp
  802200:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802202:	ff 75 10             	pushl  0x10(%ebp)
  802205:	ff 75 0c             	pushl  0xc(%ebp)
  802208:	ff 75 08             	pushl  0x8(%ebp)
  80220b:	e8 87 ff ff ff       	call   802197 <memmove>
}
  802210:	c9                   	leave  
  802211:	c3                   	ret    

00802212 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802212:	55                   	push   %ebp
  802213:	89 e5                	mov    %esp,%ebp
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	8b 45 08             	mov    0x8(%ebp),%eax
  80221a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221d:	89 c6                	mov    %eax,%esi
  80221f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802222:	eb 1a                	jmp    80223e <memcmp+0x2c>
		if (*s1 != *s2)
  802224:	0f b6 08             	movzbl (%eax),%ecx
  802227:	0f b6 1a             	movzbl (%edx),%ebx
  80222a:	38 d9                	cmp    %bl,%cl
  80222c:	74 0a                	je     802238 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80222e:	0f b6 c1             	movzbl %cl,%eax
  802231:	0f b6 db             	movzbl %bl,%ebx
  802234:	29 d8                	sub    %ebx,%eax
  802236:	eb 0f                	jmp    802247 <memcmp+0x35>
		s1++, s2++;
  802238:	83 c0 01             	add    $0x1,%eax
  80223b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80223e:	39 f0                	cmp    %esi,%eax
  802240:	75 e2                	jne    802224 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802242:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	53                   	push   %ebx
  80224f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802252:	89 c1                	mov    %eax,%ecx
  802254:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  802257:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80225b:	eb 0a                	jmp    802267 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80225d:	0f b6 10             	movzbl (%eax),%edx
  802260:	39 da                	cmp    %ebx,%edx
  802262:	74 07                	je     80226b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802264:	83 c0 01             	add    $0x1,%eax
  802267:	39 c8                	cmp    %ecx,%eax
  802269:	72 f2                	jb     80225d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80226b:	5b                   	pop    %ebx
  80226c:	5d                   	pop    %ebp
  80226d:	c3                   	ret    

0080226e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	57                   	push   %edi
  802272:	56                   	push   %esi
  802273:	53                   	push   %ebx
  802274:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802277:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80227a:	eb 03                	jmp    80227f <strtol+0x11>
		s++;
  80227c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80227f:	0f b6 01             	movzbl (%ecx),%eax
  802282:	3c 20                	cmp    $0x20,%al
  802284:	74 f6                	je     80227c <strtol+0xe>
  802286:	3c 09                	cmp    $0x9,%al
  802288:	74 f2                	je     80227c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80228a:	3c 2b                	cmp    $0x2b,%al
  80228c:	75 0a                	jne    802298 <strtol+0x2a>
		s++;
  80228e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802291:	bf 00 00 00 00       	mov    $0x0,%edi
  802296:	eb 11                	jmp    8022a9 <strtol+0x3b>
  802298:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80229d:	3c 2d                	cmp    $0x2d,%al
  80229f:	75 08                	jne    8022a9 <strtol+0x3b>
		s++, neg = 1;
  8022a1:	83 c1 01             	add    $0x1,%ecx
  8022a4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022a9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8022af:	75 15                	jne    8022c6 <strtol+0x58>
  8022b1:	80 39 30             	cmpb   $0x30,(%ecx)
  8022b4:	75 10                	jne    8022c6 <strtol+0x58>
  8022b6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8022ba:	75 7c                	jne    802338 <strtol+0xca>
		s += 2, base = 16;
  8022bc:	83 c1 02             	add    $0x2,%ecx
  8022bf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8022c4:	eb 16                	jmp    8022dc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8022c6:	85 db                	test   %ebx,%ebx
  8022c8:	75 12                	jne    8022dc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022ca:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022cf:	80 39 30             	cmpb   $0x30,(%ecx)
  8022d2:	75 08                	jne    8022dc <strtol+0x6e>
		s++, base = 8;
  8022d4:	83 c1 01             	add    $0x1,%ecx
  8022d7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022e4:	0f b6 11             	movzbl (%ecx),%edx
  8022e7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022ea:	89 f3                	mov    %esi,%ebx
  8022ec:	80 fb 09             	cmp    $0x9,%bl
  8022ef:	77 08                	ja     8022f9 <strtol+0x8b>
			dig = *s - '0';
  8022f1:	0f be d2             	movsbl %dl,%edx
  8022f4:	83 ea 30             	sub    $0x30,%edx
  8022f7:	eb 22                	jmp    80231b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8022f9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8022fc:	89 f3                	mov    %esi,%ebx
  8022fe:	80 fb 19             	cmp    $0x19,%bl
  802301:	77 08                	ja     80230b <strtol+0x9d>
			dig = *s - 'a' + 10;
  802303:	0f be d2             	movsbl %dl,%edx
  802306:	83 ea 57             	sub    $0x57,%edx
  802309:	eb 10                	jmp    80231b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80230b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80230e:	89 f3                	mov    %esi,%ebx
  802310:	80 fb 19             	cmp    $0x19,%bl
  802313:	77 16                	ja     80232b <strtol+0xbd>
			dig = *s - 'A' + 10;
  802315:	0f be d2             	movsbl %dl,%edx
  802318:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80231b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80231e:	7d 0b                	jge    80232b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802320:	83 c1 01             	add    $0x1,%ecx
  802323:	0f af 45 10          	imul   0x10(%ebp),%eax
  802327:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802329:	eb b9                	jmp    8022e4 <strtol+0x76>

	if (endptr)
  80232b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80232f:	74 0d                	je     80233e <strtol+0xd0>
		*endptr = (char *) s;
  802331:	8b 75 0c             	mov    0xc(%ebp),%esi
  802334:	89 0e                	mov    %ecx,(%esi)
  802336:	eb 06                	jmp    80233e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802338:	85 db                	test   %ebx,%ebx
  80233a:	74 98                	je     8022d4 <strtol+0x66>
  80233c:	eb 9e                	jmp    8022dc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80233e:	89 c2                	mov    %eax,%edx
  802340:	f7 da                	neg    %edx
  802342:	85 ff                	test   %edi,%edi
  802344:	0f 45 c2             	cmovne %edx,%eax
}
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    

0080234c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	57                   	push   %edi
  802350:	56                   	push   %esi
  802351:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802352:	b8 00 00 00 00       	mov    $0x0,%eax
  802357:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80235a:	8b 55 08             	mov    0x8(%ebp),%edx
  80235d:	89 c3                	mov    %eax,%ebx
  80235f:	89 c7                	mov    %eax,%edi
  802361:	89 c6                	mov    %eax,%esi
  802363:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802365:	5b                   	pop    %ebx
  802366:	5e                   	pop    %esi
  802367:	5f                   	pop    %edi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    

0080236a <sys_cgetc>:

int
sys_cgetc(void)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	57                   	push   %edi
  80236e:	56                   	push   %esi
  80236f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802370:	ba 00 00 00 00       	mov    $0x0,%edx
  802375:	b8 01 00 00 00       	mov    $0x1,%eax
  80237a:	89 d1                	mov    %edx,%ecx
  80237c:	89 d3                	mov    %edx,%ebx
  80237e:	89 d7                	mov    %edx,%edi
  802380:	89 d6                	mov    %edx,%esi
  802382:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    

00802389 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  802389:	55                   	push   %ebp
  80238a:	89 e5                	mov    %esp,%ebp
  80238c:	57                   	push   %edi
  80238d:	56                   	push   %esi
  80238e:	53                   	push   %ebx
  80238f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802392:	b9 00 00 00 00       	mov    $0x0,%ecx
  802397:	b8 03 00 00 00       	mov    $0x3,%eax
  80239c:	8b 55 08             	mov    0x8(%ebp),%edx
  80239f:	89 cb                	mov    %ecx,%ebx
  8023a1:	89 cf                	mov    %ecx,%edi
  8023a3:	89 ce                	mov    %ecx,%esi
  8023a5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	7e 17                	jle    8023c2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023ab:	83 ec 0c             	sub    $0xc,%esp
  8023ae:	50                   	push   %eax
  8023af:	6a 03                	push   $0x3
  8023b1:	68 9f 44 80 00       	push   $0x80449f
  8023b6:	6a 23                	push   $0x23
  8023b8:	68 bc 44 80 00       	push   $0x8044bc
  8023bd:	e8 c5 f5 ff ff       	call   801987 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8023c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023c5:	5b                   	pop    %ebx
  8023c6:	5e                   	pop    %esi
  8023c7:	5f                   	pop    %edi
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    

008023ca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	57                   	push   %edi
  8023ce:	56                   	push   %esi
  8023cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8023d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8023da:	89 d1                	mov    %edx,%ecx
  8023dc:	89 d3                	mov    %edx,%ebx
  8023de:	89 d7                	mov    %edx,%edi
  8023e0:	89 d6                	mov    %edx,%esi
  8023e2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023e4:	5b                   	pop    %ebx
  8023e5:	5e                   	pop    %esi
  8023e6:	5f                   	pop    %edi
  8023e7:	5d                   	pop    %ebp
  8023e8:	c3                   	ret    

008023e9 <sys_yield>:

void
sys_yield(void)
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	57                   	push   %edi
  8023ed:	56                   	push   %esi
  8023ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8023f9:	89 d1                	mov    %edx,%ecx
  8023fb:	89 d3                	mov    %edx,%ebx
  8023fd:	89 d7                	mov    %edx,%edi
  8023ff:	89 d6                	mov    %edx,%esi
  802401:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802403:	5b                   	pop    %ebx
  802404:	5e                   	pop    %esi
  802405:	5f                   	pop    %edi
  802406:	5d                   	pop    %ebp
  802407:	c3                   	ret    

00802408 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	57                   	push   %edi
  80240c:	56                   	push   %esi
  80240d:	53                   	push   %ebx
  80240e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802411:	be 00 00 00 00       	mov    $0x0,%esi
  802416:	b8 04 00 00 00       	mov    $0x4,%eax
  80241b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80241e:	8b 55 08             	mov    0x8(%ebp),%edx
  802421:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802424:	89 f7                	mov    %esi,%edi
  802426:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802428:	85 c0                	test   %eax,%eax
  80242a:	7e 17                	jle    802443 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80242c:	83 ec 0c             	sub    $0xc,%esp
  80242f:	50                   	push   %eax
  802430:	6a 04                	push   $0x4
  802432:	68 9f 44 80 00       	push   $0x80449f
  802437:	6a 23                	push   $0x23
  802439:	68 bc 44 80 00       	push   $0x8044bc
  80243e:	e8 44 f5 ff ff       	call   801987 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802443:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802446:	5b                   	pop    %ebx
  802447:	5e                   	pop    %esi
  802448:	5f                   	pop    %edi
  802449:	5d                   	pop    %ebp
  80244a:	c3                   	ret    

0080244b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80244b:	55                   	push   %ebp
  80244c:	89 e5                	mov    %esp,%ebp
  80244e:	57                   	push   %edi
  80244f:	56                   	push   %esi
  802450:	53                   	push   %ebx
  802451:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802454:	b8 05 00 00 00       	mov    $0x5,%eax
  802459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80245c:	8b 55 08             	mov    0x8(%ebp),%edx
  80245f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802462:	8b 7d 14             	mov    0x14(%ebp),%edi
  802465:	8b 75 18             	mov    0x18(%ebp),%esi
  802468:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80246a:	85 c0                	test   %eax,%eax
  80246c:	7e 17                	jle    802485 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80246e:	83 ec 0c             	sub    $0xc,%esp
  802471:	50                   	push   %eax
  802472:	6a 05                	push   $0x5
  802474:	68 9f 44 80 00       	push   $0x80449f
  802479:	6a 23                	push   $0x23
  80247b:	68 bc 44 80 00       	push   $0x8044bc
  802480:	e8 02 f5 ff ff       	call   801987 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802485:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    

0080248d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80248d:	55                   	push   %ebp
  80248e:	89 e5                	mov    %esp,%ebp
  802490:	57                   	push   %edi
  802491:	56                   	push   %esi
  802492:	53                   	push   %ebx
  802493:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802496:	bb 00 00 00 00       	mov    $0x0,%ebx
  80249b:	b8 06 00 00 00       	mov    $0x6,%eax
  8024a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8024a6:	89 df                	mov    %ebx,%edi
  8024a8:	89 de                	mov    %ebx,%esi
  8024aa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024ac:	85 c0                	test   %eax,%eax
  8024ae:	7e 17                	jle    8024c7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024b0:	83 ec 0c             	sub    $0xc,%esp
  8024b3:	50                   	push   %eax
  8024b4:	6a 06                	push   $0x6
  8024b6:	68 9f 44 80 00       	push   $0x80449f
  8024bb:	6a 23                	push   $0x23
  8024bd:	68 bc 44 80 00       	push   $0x8044bc
  8024c2:	e8 c0 f4 ff ff       	call   801987 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ca:	5b                   	pop    %ebx
  8024cb:	5e                   	pop    %esi
  8024cc:	5f                   	pop    %edi
  8024cd:	5d                   	pop    %ebp
  8024ce:	c3                   	ret    

008024cf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024cf:	55                   	push   %ebp
  8024d0:	89 e5                	mov    %esp,%ebp
  8024d2:	57                   	push   %edi
  8024d3:	56                   	push   %esi
  8024d4:	53                   	push   %ebx
  8024d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024dd:	b8 08 00 00 00       	mov    $0x8,%eax
  8024e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8024e8:	89 df                	mov    %ebx,%edi
  8024ea:	89 de                	mov    %ebx,%esi
  8024ec:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024ee:	85 c0                	test   %eax,%eax
  8024f0:	7e 17                	jle    802509 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024f2:	83 ec 0c             	sub    $0xc,%esp
  8024f5:	50                   	push   %eax
  8024f6:	6a 08                	push   $0x8
  8024f8:	68 9f 44 80 00       	push   $0x80449f
  8024fd:	6a 23                	push   $0x23
  8024ff:	68 bc 44 80 00       	push   $0x8044bc
  802504:	e8 7e f4 ff ff       	call   801987 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802509:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80250c:	5b                   	pop    %ebx
  80250d:	5e                   	pop    %esi
  80250e:	5f                   	pop    %edi
  80250f:	5d                   	pop    %ebp
  802510:	c3                   	ret    

00802511 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802511:	55                   	push   %ebp
  802512:	89 e5                	mov    %esp,%ebp
  802514:	57                   	push   %edi
  802515:	56                   	push   %esi
  802516:	53                   	push   %ebx
  802517:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80251a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80251f:	b8 09 00 00 00       	mov    $0x9,%eax
  802524:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802527:	8b 55 08             	mov    0x8(%ebp),%edx
  80252a:	89 df                	mov    %ebx,%edi
  80252c:	89 de                	mov    %ebx,%esi
  80252e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802530:	85 c0                	test   %eax,%eax
  802532:	7e 17                	jle    80254b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802534:	83 ec 0c             	sub    $0xc,%esp
  802537:	50                   	push   %eax
  802538:	6a 09                	push   $0x9
  80253a:	68 9f 44 80 00       	push   $0x80449f
  80253f:	6a 23                	push   $0x23
  802541:	68 bc 44 80 00       	push   $0x8044bc
  802546:	e8 3c f4 ff ff       	call   801987 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80254b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80254e:	5b                   	pop    %ebx
  80254f:	5e                   	pop    %esi
  802550:	5f                   	pop    %edi
  802551:	5d                   	pop    %ebp
  802552:	c3                   	ret    

00802553 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802553:	55                   	push   %ebp
  802554:	89 e5                	mov    %esp,%ebp
  802556:	57                   	push   %edi
  802557:	56                   	push   %esi
  802558:	53                   	push   %ebx
  802559:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80255c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802561:	b8 0a 00 00 00       	mov    $0xa,%eax
  802566:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802569:	8b 55 08             	mov    0x8(%ebp),%edx
  80256c:	89 df                	mov    %ebx,%edi
  80256e:	89 de                	mov    %ebx,%esi
  802570:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802572:	85 c0                	test   %eax,%eax
  802574:	7e 17                	jle    80258d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802576:	83 ec 0c             	sub    $0xc,%esp
  802579:	50                   	push   %eax
  80257a:	6a 0a                	push   $0xa
  80257c:	68 9f 44 80 00       	push   $0x80449f
  802581:	6a 23                	push   $0x23
  802583:	68 bc 44 80 00       	push   $0x8044bc
  802588:	e8 fa f3 ff ff       	call   801987 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80258d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802590:	5b                   	pop    %ebx
  802591:	5e                   	pop    %esi
  802592:	5f                   	pop    %edi
  802593:	5d                   	pop    %ebp
  802594:	c3                   	ret    

00802595 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802595:	55                   	push   %ebp
  802596:	89 e5                	mov    %esp,%ebp
  802598:	57                   	push   %edi
  802599:	56                   	push   %esi
  80259a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80259b:	be 00 00 00 00       	mov    $0x0,%esi
  8025a0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025b1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025b3:	5b                   	pop    %ebx
  8025b4:	5e                   	pop    %esi
  8025b5:	5f                   	pop    %edi
  8025b6:	5d                   	pop    %ebp
  8025b7:	c3                   	ret    

008025b8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	57                   	push   %edi
  8025bc:	56                   	push   %esi
  8025bd:	53                   	push   %ebx
  8025be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025c6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ce:	89 cb                	mov    %ecx,%ebx
  8025d0:	89 cf                	mov    %ecx,%edi
  8025d2:	89 ce                	mov    %ecx,%esi
  8025d4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025d6:	85 c0                	test   %eax,%eax
  8025d8:	7e 17                	jle    8025f1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025da:	83 ec 0c             	sub    $0xc,%esp
  8025dd:	50                   	push   %eax
  8025de:	6a 0d                	push   $0xd
  8025e0:	68 9f 44 80 00       	push   $0x80449f
  8025e5:	6a 23                	push   $0x23
  8025e7:	68 bc 44 80 00       	push   $0x8044bc
  8025ec:	e8 96 f3 ff ff       	call   801987 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    

008025f9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8025f9:	55                   	push   %ebp
  8025fa:	89 e5                	mov    %esp,%ebp
  8025fc:	57                   	push   %edi
  8025fd:	56                   	push   %esi
  8025fe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802604:	b8 0e 00 00 00       	mov    $0xe,%eax
  802609:	89 d1                	mov    %edx,%ecx
  80260b:	89 d3                	mov    %edx,%ebx
  80260d:	89 d7                	mov    %edx,%edi
  80260f:	89 d6                	mov    %edx,%esi
  802611:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  802613:	5b                   	pop    %ebx
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    

00802618 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802618:	55                   	push   %ebp
  802619:	89 e5                	mov    %esp,%ebp
  80261b:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  80261e:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  802625:	75 56                	jne    80267d <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802627:	83 ec 04             	sub    $0x4,%esp
  80262a:	6a 07                	push   $0x7
  80262c:	68 00 f0 bf ee       	push   $0xeebff000
  802631:	6a 00                	push   $0x0
  802633:	e8 d0 fd ff ff       	call   802408 <sys_page_alloc>
  802638:	83 c4 10             	add    $0x10,%esp
  80263b:	85 c0                	test   %eax,%eax
  80263d:	74 14                	je     802653 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  80263f:	83 ec 04             	sub    $0x4,%esp
  802642:	68 ca 44 80 00       	push   $0x8044ca
  802647:	6a 21                	push   $0x21
  802649:	68 df 44 80 00       	push   $0x8044df
  80264e:	e8 34 f3 ff ff       	call   801987 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  802653:	83 ec 08             	sub    $0x8,%esp
  802656:	68 87 26 80 00       	push   $0x802687
  80265b:	6a 00                	push   $0x0
  80265d:	e8 f1 fe ff ff       	call   802553 <sys_env_set_pgfault_upcall>
  802662:	83 c4 10             	add    $0x10,%esp
  802665:	85 c0                	test   %eax,%eax
  802667:	74 14                	je     80267d <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  802669:	83 ec 04             	sub    $0x4,%esp
  80266c:	68 ed 44 80 00       	push   $0x8044ed
  802671:	6a 23                	push   $0x23
  802673:	68 df 44 80 00       	push   $0x8044df
  802678:	e8 0a f3 ff ff       	call   801987 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80267d:	8b 45 08             	mov    0x8(%ebp),%eax
  802680:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  802685:	c9                   	leave  
  802686:	c3                   	ret    

00802687 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802687:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802688:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  80268d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80268f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  802692:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  802694:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  802698:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  80269c:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  80269d:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  80269f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8026a4:	83 c4 08             	add    $0x8,%esp
	popal
  8026a7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8026a8:	83 c4 04             	add    $0x4,%esp
	popfl
  8026ab:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8026ac:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026ad:	c3                   	ret    

008026ae <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026ae:	55                   	push   %ebp
  8026af:	89 e5                	mov    %esp,%ebp
  8026b1:	56                   	push   %esi
  8026b2:	53                   	push   %ebx
  8026b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8026b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8026bc:	85 c0                	test   %eax,%eax
  8026be:	74 0e                	je     8026ce <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8026c0:	83 ec 0c             	sub    $0xc,%esp
  8026c3:	50                   	push   %eax
  8026c4:	e8 ef fe ff ff       	call   8025b8 <sys_ipc_recv>
  8026c9:	83 c4 10             	add    $0x10,%esp
  8026cc:	eb 10                	jmp    8026de <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8026ce:	83 ec 0c             	sub    $0xc,%esp
  8026d1:	68 00 00 c0 ee       	push   $0xeec00000
  8026d6:	e8 dd fe ff ff       	call   8025b8 <sys_ipc_recv>
  8026db:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8026de:	85 c0                	test   %eax,%eax
  8026e0:	79 17                	jns    8026f9 <ipc_recv+0x4b>
		if(*from_env_store)
  8026e2:	83 3e 00             	cmpl   $0x0,(%esi)
  8026e5:	74 06                	je     8026ed <ipc_recv+0x3f>
			*from_env_store = 0;
  8026e7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8026ed:	85 db                	test   %ebx,%ebx
  8026ef:	74 2c                	je     80271d <ipc_recv+0x6f>
			*perm_store = 0;
  8026f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026f7:	eb 24                	jmp    80271d <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8026f9:	85 f6                	test   %esi,%esi
  8026fb:	74 0a                	je     802707 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8026fd:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802702:	8b 40 74             	mov    0x74(%eax),%eax
  802705:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802707:	85 db                	test   %ebx,%ebx
  802709:	74 0a                	je     802715 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80270b:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802710:	8b 40 78             	mov    0x78(%eax),%eax
  802713:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802715:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80271a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80271d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802720:	5b                   	pop    %ebx
  802721:	5e                   	pop    %esi
  802722:	5d                   	pop    %ebp
  802723:	c3                   	ret    

00802724 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802724:	55                   	push   %ebp
  802725:	89 e5                	mov    %esp,%ebp
  802727:	57                   	push   %edi
  802728:	56                   	push   %esi
  802729:	53                   	push   %ebx
  80272a:	83 ec 0c             	sub    $0xc,%esp
  80272d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802730:	8b 75 0c             	mov    0xc(%ebp),%esi
  802733:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802736:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802738:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  80273d:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802740:	e8 a4 fc ff ff       	call   8023e9 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802745:	ff 75 14             	pushl  0x14(%ebp)
  802748:	53                   	push   %ebx
  802749:	56                   	push   %esi
  80274a:	57                   	push   %edi
  80274b:	e8 45 fe ff ff       	call   802595 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802750:	89 c2                	mov    %eax,%edx
  802752:	f7 d2                	not    %edx
  802754:	c1 ea 1f             	shr    $0x1f,%edx
  802757:	83 c4 10             	add    $0x10,%esp
  80275a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80275d:	0f 94 c1             	sete   %cl
  802760:	09 ca                	or     %ecx,%edx
  802762:	85 c0                	test   %eax,%eax
  802764:	0f 94 c0             	sete   %al
  802767:	38 c2                	cmp    %al,%dl
  802769:	77 d5                	ja     802740 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  80276b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80276e:	5b                   	pop    %ebx
  80276f:	5e                   	pop    %esi
  802770:	5f                   	pop    %edi
  802771:	5d                   	pop    %ebp
  802772:	c3                   	ret    

00802773 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802773:	55                   	push   %ebp
  802774:	89 e5                	mov    %esp,%ebp
  802776:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802779:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80277e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802781:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802787:	8b 52 50             	mov    0x50(%edx),%edx
  80278a:	39 ca                	cmp    %ecx,%edx
  80278c:	75 0d                	jne    80279b <ipc_find_env+0x28>
			return envs[i].env_id;
  80278e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802791:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802796:	8b 40 48             	mov    0x48(%eax),%eax
  802799:	eb 0f                	jmp    8027aa <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80279b:	83 c0 01             	add    $0x1,%eax
  80279e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027a3:	75 d9                	jne    80277e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027aa:	5d                   	pop    %ebp
  8027ab:	c3                   	ret    

008027ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8027af:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8027b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8027ba:	5d                   	pop    %ebp
  8027bb:	c3                   	ret    

008027bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8027bc:	55                   	push   %ebp
  8027bd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8027bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8027c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8027c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8027cc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8027d1:	5d                   	pop    %ebp
  8027d2:	c3                   	ret    

008027d3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8027d3:	55                   	push   %ebp
  8027d4:	89 e5                	mov    %esp,%ebp
  8027d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027d9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8027de:	89 c2                	mov    %eax,%edx
  8027e0:	c1 ea 16             	shr    $0x16,%edx
  8027e3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027ea:	f6 c2 01             	test   $0x1,%dl
  8027ed:	74 11                	je     802800 <fd_alloc+0x2d>
  8027ef:	89 c2                	mov    %eax,%edx
  8027f1:	c1 ea 0c             	shr    $0xc,%edx
  8027f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8027fb:	f6 c2 01             	test   $0x1,%dl
  8027fe:	75 09                	jne    802809 <fd_alloc+0x36>
			*fd_store = fd;
  802800:	89 01                	mov    %eax,(%ecx)
			return 0;
  802802:	b8 00 00 00 00       	mov    $0x0,%eax
  802807:	eb 17                	jmp    802820 <fd_alloc+0x4d>
  802809:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80280e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802813:	75 c9                	jne    8027de <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802815:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80281b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802820:	5d                   	pop    %ebp
  802821:	c3                   	ret    

00802822 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802822:	55                   	push   %ebp
  802823:	89 e5                	mov    %esp,%ebp
  802825:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802828:	83 f8 1f             	cmp    $0x1f,%eax
  80282b:	77 36                	ja     802863 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80282d:	c1 e0 0c             	shl    $0xc,%eax
  802830:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802835:	89 c2                	mov    %eax,%edx
  802837:	c1 ea 16             	shr    $0x16,%edx
  80283a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802841:	f6 c2 01             	test   $0x1,%dl
  802844:	74 24                	je     80286a <fd_lookup+0x48>
  802846:	89 c2                	mov    %eax,%edx
  802848:	c1 ea 0c             	shr    $0xc,%edx
  80284b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802852:	f6 c2 01             	test   $0x1,%dl
  802855:	74 1a                	je     802871 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80285a:	89 02                	mov    %eax,(%edx)
	return 0;
  80285c:	b8 00 00 00 00       	mov    $0x0,%eax
  802861:	eb 13                	jmp    802876 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802863:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802868:	eb 0c                	jmp    802876 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80286a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80286f:	eb 05                	jmp    802876 <fd_lookup+0x54>
  802871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802876:	5d                   	pop    %ebp
  802877:	c3                   	ret    

00802878 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802878:	55                   	push   %ebp
  802879:	89 e5                	mov    %esp,%ebp
  80287b:	83 ec 08             	sub    $0x8,%esp
  80287e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802881:	ba 84 45 80 00       	mov    $0x804584,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802886:	eb 13                	jmp    80289b <dev_lookup+0x23>
  802888:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80288b:	39 08                	cmp    %ecx,(%eax)
  80288d:	75 0c                	jne    80289b <dev_lookup+0x23>
			*dev = devtab[i];
  80288f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802892:	89 01                	mov    %eax,(%ecx)
			return 0;
  802894:	b8 00 00 00 00       	mov    $0x0,%eax
  802899:	eb 2e                	jmp    8028c9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80289b:	8b 02                	mov    (%edx),%eax
  80289d:	85 c0                	test   %eax,%eax
  80289f:	75 e7                	jne    802888 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8028a1:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8028a6:	8b 40 48             	mov    0x48(%eax),%eax
  8028a9:	83 ec 04             	sub    $0x4,%esp
  8028ac:	51                   	push   %ecx
  8028ad:	50                   	push   %eax
  8028ae:	68 04 45 80 00       	push   $0x804504
  8028b3:	e8 a8 f1 ff ff       	call   801a60 <cprintf>
	*dev = 0;
  8028b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8028c1:	83 c4 10             	add    $0x10,%esp
  8028c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8028c9:	c9                   	leave  
  8028ca:	c3                   	ret    

008028cb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8028cb:	55                   	push   %ebp
  8028cc:	89 e5                	mov    %esp,%ebp
  8028ce:	56                   	push   %esi
  8028cf:	53                   	push   %ebx
  8028d0:	83 ec 10             	sub    $0x10,%esp
  8028d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8028d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8028d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028dc:	50                   	push   %eax
  8028dd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8028e3:	c1 e8 0c             	shr    $0xc,%eax
  8028e6:	50                   	push   %eax
  8028e7:	e8 36 ff ff ff       	call   802822 <fd_lookup>
  8028ec:	83 c4 08             	add    $0x8,%esp
  8028ef:	85 c0                	test   %eax,%eax
  8028f1:	78 05                	js     8028f8 <fd_close+0x2d>
	    || fd != fd2)
  8028f3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8028f6:	74 0c                	je     802904 <fd_close+0x39>
		return (must_exist ? r : 0);
  8028f8:	84 db                	test   %bl,%bl
  8028fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8028ff:	0f 44 c2             	cmove  %edx,%eax
  802902:	eb 41                	jmp    802945 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802904:	83 ec 08             	sub    $0x8,%esp
  802907:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80290a:	50                   	push   %eax
  80290b:	ff 36                	pushl  (%esi)
  80290d:	e8 66 ff ff ff       	call   802878 <dev_lookup>
  802912:	89 c3                	mov    %eax,%ebx
  802914:	83 c4 10             	add    $0x10,%esp
  802917:	85 c0                	test   %eax,%eax
  802919:	78 1a                	js     802935 <fd_close+0x6a>
		if (dev->dev_close)
  80291b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80291e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802921:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802926:	85 c0                	test   %eax,%eax
  802928:	74 0b                	je     802935 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80292a:	83 ec 0c             	sub    $0xc,%esp
  80292d:	56                   	push   %esi
  80292e:	ff d0                	call   *%eax
  802930:	89 c3                	mov    %eax,%ebx
  802932:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802935:	83 ec 08             	sub    $0x8,%esp
  802938:	56                   	push   %esi
  802939:	6a 00                	push   $0x0
  80293b:	e8 4d fb ff ff       	call   80248d <sys_page_unmap>
	return r;
  802940:	83 c4 10             	add    $0x10,%esp
  802943:	89 d8                	mov    %ebx,%eax
}
  802945:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802948:	5b                   	pop    %ebx
  802949:	5e                   	pop    %esi
  80294a:	5d                   	pop    %ebp
  80294b:	c3                   	ret    

0080294c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80294c:	55                   	push   %ebp
  80294d:	89 e5                	mov    %esp,%ebp
  80294f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802955:	50                   	push   %eax
  802956:	ff 75 08             	pushl  0x8(%ebp)
  802959:	e8 c4 fe ff ff       	call   802822 <fd_lookup>
  80295e:	83 c4 08             	add    $0x8,%esp
  802961:	85 c0                	test   %eax,%eax
  802963:	78 10                	js     802975 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802965:	83 ec 08             	sub    $0x8,%esp
  802968:	6a 01                	push   $0x1
  80296a:	ff 75 f4             	pushl  -0xc(%ebp)
  80296d:	e8 59 ff ff ff       	call   8028cb <fd_close>
  802972:	83 c4 10             	add    $0x10,%esp
}
  802975:	c9                   	leave  
  802976:	c3                   	ret    

00802977 <close_all>:

void
close_all(void)
{
  802977:	55                   	push   %ebp
  802978:	89 e5                	mov    %esp,%ebp
  80297a:	53                   	push   %ebx
  80297b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80297e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802983:	83 ec 0c             	sub    $0xc,%esp
  802986:	53                   	push   %ebx
  802987:	e8 c0 ff ff ff       	call   80294c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80298c:	83 c3 01             	add    $0x1,%ebx
  80298f:	83 c4 10             	add    $0x10,%esp
  802992:	83 fb 20             	cmp    $0x20,%ebx
  802995:	75 ec                	jne    802983 <close_all+0xc>
		close(i);
}
  802997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80299a:	c9                   	leave  
  80299b:	c3                   	ret    

0080299c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80299c:	55                   	push   %ebp
  80299d:	89 e5                	mov    %esp,%ebp
  80299f:	57                   	push   %edi
  8029a0:	56                   	push   %esi
  8029a1:	53                   	push   %ebx
  8029a2:	83 ec 2c             	sub    $0x2c,%esp
  8029a5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8029a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8029ab:	50                   	push   %eax
  8029ac:	ff 75 08             	pushl  0x8(%ebp)
  8029af:	e8 6e fe ff ff       	call   802822 <fd_lookup>
  8029b4:	83 c4 08             	add    $0x8,%esp
  8029b7:	85 c0                	test   %eax,%eax
  8029b9:	0f 88 c1 00 00 00    	js     802a80 <dup+0xe4>
		return r;
	close(newfdnum);
  8029bf:	83 ec 0c             	sub    $0xc,%esp
  8029c2:	56                   	push   %esi
  8029c3:	e8 84 ff ff ff       	call   80294c <close>

	newfd = INDEX2FD(newfdnum);
  8029c8:	89 f3                	mov    %esi,%ebx
  8029ca:	c1 e3 0c             	shl    $0xc,%ebx
  8029cd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8029d3:	83 c4 04             	add    $0x4,%esp
  8029d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8029d9:	e8 de fd ff ff       	call   8027bc <fd2data>
  8029de:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8029e0:	89 1c 24             	mov    %ebx,(%esp)
  8029e3:	e8 d4 fd ff ff       	call   8027bc <fd2data>
  8029e8:	83 c4 10             	add    $0x10,%esp
  8029eb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8029ee:	89 f8                	mov    %edi,%eax
  8029f0:	c1 e8 16             	shr    $0x16,%eax
  8029f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029fa:	a8 01                	test   $0x1,%al
  8029fc:	74 37                	je     802a35 <dup+0x99>
  8029fe:	89 f8                	mov    %edi,%eax
  802a00:	c1 e8 0c             	shr    $0xc,%eax
  802a03:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a0a:	f6 c2 01             	test   $0x1,%dl
  802a0d:	74 26                	je     802a35 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802a0f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a16:	83 ec 0c             	sub    $0xc,%esp
  802a19:	25 07 0e 00 00       	and    $0xe07,%eax
  802a1e:	50                   	push   %eax
  802a1f:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a22:	6a 00                	push   $0x0
  802a24:	57                   	push   %edi
  802a25:	6a 00                	push   $0x0
  802a27:	e8 1f fa ff ff       	call   80244b <sys_page_map>
  802a2c:	89 c7                	mov    %eax,%edi
  802a2e:	83 c4 20             	add    $0x20,%esp
  802a31:	85 c0                	test   %eax,%eax
  802a33:	78 2e                	js     802a63 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a35:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802a38:	89 d0                	mov    %edx,%eax
  802a3a:	c1 e8 0c             	shr    $0xc,%eax
  802a3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a44:	83 ec 0c             	sub    $0xc,%esp
  802a47:	25 07 0e 00 00       	and    $0xe07,%eax
  802a4c:	50                   	push   %eax
  802a4d:	53                   	push   %ebx
  802a4e:	6a 00                	push   $0x0
  802a50:	52                   	push   %edx
  802a51:	6a 00                	push   $0x0
  802a53:	e8 f3 f9 ff ff       	call   80244b <sys_page_map>
  802a58:	89 c7                	mov    %eax,%edi
  802a5a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802a5d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a5f:	85 ff                	test   %edi,%edi
  802a61:	79 1d                	jns    802a80 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802a63:	83 ec 08             	sub    $0x8,%esp
  802a66:	53                   	push   %ebx
  802a67:	6a 00                	push   $0x0
  802a69:	e8 1f fa ff ff       	call   80248d <sys_page_unmap>
	sys_page_unmap(0, nva);
  802a6e:	83 c4 08             	add    $0x8,%esp
  802a71:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a74:	6a 00                	push   $0x0
  802a76:	e8 12 fa ff ff       	call   80248d <sys_page_unmap>
	return r;
  802a7b:	83 c4 10             	add    $0x10,%esp
  802a7e:	89 f8                	mov    %edi,%eax
}
  802a80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a83:	5b                   	pop    %ebx
  802a84:	5e                   	pop    %esi
  802a85:	5f                   	pop    %edi
  802a86:	5d                   	pop    %ebp
  802a87:	c3                   	ret    

00802a88 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a88:	55                   	push   %ebp
  802a89:	89 e5                	mov    %esp,%ebp
  802a8b:	53                   	push   %ebx
  802a8c:	83 ec 14             	sub    $0x14,%esp
  802a8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a95:	50                   	push   %eax
  802a96:	53                   	push   %ebx
  802a97:	e8 86 fd ff ff       	call   802822 <fd_lookup>
  802a9c:	83 c4 08             	add    $0x8,%esp
  802a9f:	89 c2                	mov    %eax,%edx
  802aa1:	85 c0                	test   %eax,%eax
  802aa3:	78 6d                	js     802b12 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802aa5:	83 ec 08             	sub    $0x8,%esp
  802aa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802aab:	50                   	push   %eax
  802aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802aaf:	ff 30                	pushl  (%eax)
  802ab1:	e8 c2 fd ff ff       	call   802878 <dev_lookup>
  802ab6:	83 c4 10             	add    $0x10,%esp
  802ab9:	85 c0                	test   %eax,%eax
  802abb:	78 4c                	js     802b09 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802abd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ac0:	8b 42 08             	mov    0x8(%edx),%eax
  802ac3:	83 e0 03             	and    $0x3,%eax
  802ac6:	83 f8 01             	cmp    $0x1,%eax
  802ac9:	75 21                	jne    802aec <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802acb:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802ad0:	8b 40 48             	mov    0x48(%eax),%eax
  802ad3:	83 ec 04             	sub    $0x4,%esp
  802ad6:	53                   	push   %ebx
  802ad7:	50                   	push   %eax
  802ad8:	68 48 45 80 00       	push   $0x804548
  802add:	e8 7e ef ff ff       	call   801a60 <cprintf>
		return -E_INVAL;
  802ae2:	83 c4 10             	add    $0x10,%esp
  802ae5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802aea:	eb 26                	jmp    802b12 <read+0x8a>
	}
	if (!dev->dev_read)
  802aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802aef:	8b 40 08             	mov    0x8(%eax),%eax
  802af2:	85 c0                	test   %eax,%eax
  802af4:	74 17                	je     802b0d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802af6:	83 ec 04             	sub    $0x4,%esp
  802af9:	ff 75 10             	pushl  0x10(%ebp)
  802afc:	ff 75 0c             	pushl  0xc(%ebp)
  802aff:	52                   	push   %edx
  802b00:	ff d0                	call   *%eax
  802b02:	89 c2                	mov    %eax,%edx
  802b04:	83 c4 10             	add    $0x10,%esp
  802b07:	eb 09                	jmp    802b12 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b09:	89 c2                	mov    %eax,%edx
  802b0b:	eb 05                	jmp    802b12 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802b0d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802b12:	89 d0                	mov    %edx,%eax
  802b14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b17:	c9                   	leave  
  802b18:	c3                   	ret    

00802b19 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802b19:	55                   	push   %ebp
  802b1a:	89 e5                	mov    %esp,%ebp
  802b1c:	57                   	push   %edi
  802b1d:	56                   	push   %esi
  802b1e:	53                   	push   %ebx
  802b1f:	83 ec 0c             	sub    $0xc,%esp
  802b22:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b25:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b28:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b2d:	eb 21                	jmp    802b50 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802b2f:	83 ec 04             	sub    $0x4,%esp
  802b32:	89 f0                	mov    %esi,%eax
  802b34:	29 d8                	sub    %ebx,%eax
  802b36:	50                   	push   %eax
  802b37:	89 d8                	mov    %ebx,%eax
  802b39:	03 45 0c             	add    0xc(%ebp),%eax
  802b3c:	50                   	push   %eax
  802b3d:	57                   	push   %edi
  802b3e:	e8 45 ff ff ff       	call   802a88 <read>
		if (m < 0)
  802b43:	83 c4 10             	add    $0x10,%esp
  802b46:	85 c0                	test   %eax,%eax
  802b48:	78 10                	js     802b5a <readn+0x41>
			return m;
		if (m == 0)
  802b4a:	85 c0                	test   %eax,%eax
  802b4c:	74 0a                	je     802b58 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b4e:	01 c3                	add    %eax,%ebx
  802b50:	39 f3                	cmp    %esi,%ebx
  802b52:	72 db                	jb     802b2f <readn+0x16>
  802b54:	89 d8                	mov    %ebx,%eax
  802b56:	eb 02                	jmp    802b5a <readn+0x41>
  802b58:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b5d:	5b                   	pop    %ebx
  802b5e:	5e                   	pop    %esi
  802b5f:	5f                   	pop    %edi
  802b60:	5d                   	pop    %ebp
  802b61:	c3                   	ret    

00802b62 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802b62:	55                   	push   %ebp
  802b63:	89 e5                	mov    %esp,%ebp
  802b65:	53                   	push   %ebx
  802b66:	83 ec 14             	sub    $0x14,%esp
  802b69:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b6f:	50                   	push   %eax
  802b70:	53                   	push   %ebx
  802b71:	e8 ac fc ff ff       	call   802822 <fd_lookup>
  802b76:	83 c4 08             	add    $0x8,%esp
  802b79:	89 c2                	mov    %eax,%edx
  802b7b:	85 c0                	test   %eax,%eax
  802b7d:	78 68                	js     802be7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b7f:	83 ec 08             	sub    $0x8,%esp
  802b82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b85:	50                   	push   %eax
  802b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b89:	ff 30                	pushl  (%eax)
  802b8b:	e8 e8 fc ff ff       	call   802878 <dev_lookup>
  802b90:	83 c4 10             	add    $0x10,%esp
  802b93:	85 c0                	test   %eax,%eax
  802b95:	78 47                	js     802bde <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b9a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802b9e:	75 21                	jne    802bc1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802ba0:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802ba5:	8b 40 48             	mov    0x48(%eax),%eax
  802ba8:	83 ec 04             	sub    $0x4,%esp
  802bab:	53                   	push   %ebx
  802bac:	50                   	push   %eax
  802bad:	68 64 45 80 00       	push   $0x804564
  802bb2:	e8 a9 ee ff ff       	call   801a60 <cprintf>
		return -E_INVAL;
  802bb7:	83 c4 10             	add    $0x10,%esp
  802bba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802bbf:	eb 26                	jmp    802be7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802bc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802bc4:	8b 52 0c             	mov    0xc(%edx),%edx
  802bc7:	85 d2                	test   %edx,%edx
  802bc9:	74 17                	je     802be2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802bcb:	83 ec 04             	sub    $0x4,%esp
  802bce:	ff 75 10             	pushl  0x10(%ebp)
  802bd1:	ff 75 0c             	pushl  0xc(%ebp)
  802bd4:	50                   	push   %eax
  802bd5:	ff d2                	call   *%edx
  802bd7:	89 c2                	mov    %eax,%edx
  802bd9:	83 c4 10             	add    $0x10,%esp
  802bdc:	eb 09                	jmp    802be7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bde:	89 c2                	mov    %eax,%edx
  802be0:	eb 05                	jmp    802be7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802be2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802be7:	89 d0                	mov    %edx,%eax
  802be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bec:	c9                   	leave  
  802bed:	c3                   	ret    

00802bee <seek>:

int
seek(int fdnum, off_t offset)
{
  802bee:	55                   	push   %ebp
  802bef:	89 e5                	mov    %esp,%ebp
  802bf1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bf4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802bf7:	50                   	push   %eax
  802bf8:	ff 75 08             	pushl  0x8(%ebp)
  802bfb:	e8 22 fc ff ff       	call   802822 <fd_lookup>
  802c00:	83 c4 08             	add    $0x8,%esp
  802c03:	85 c0                	test   %eax,%eax
  802c05:	78 0e                	js     802c15 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c0d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802c10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c15:	c9                   	leave  
  802c16:	c3                   	ret    

00802c17 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802c17:	55                   	push   %ebp
  802c18:	89 e5                	mov    %esp,%ebp
  802c1a:	53                   	push   %ebx
  802c1b:	83 ec 14             	sub    $0x14,%esp
  802c1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c24:	50                   	push   %eax
  802c25:	53                   	push   %ebx
  802c26:	e8 f7 fb ff ff       	call   802822 <fd_lookup>
  802c2b:	83 c4 08             	add    $0x8,%esp
  802c2e:	89 c2                	mov    %eax,%edx
  802c30:	85 c0                	test   %eax,%eax
  802c32:	78 65                	js     802c99 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c34:	83 ec 08             	sub    $0x8,%esp
  802c37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c3a:	50                   	push   %eax
  802c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c3e:	ff 30                	pushl  (%eax)
  802c40:	e8 33 fc ff ff       	call   802878 <dev_lookup>
  802c45:	83 c4 10             	add    $0x10,%esp
  802c48:	85 c0                	test   %eax,%eax
  802c4a:	78 44                	js     802c90 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c4f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c53:	75 21                	jne    802c76 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c55:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802c5a:	8b 40 48             	mov    0x48(%eax),%eax
  802c5d:	83 ec 04             	sub    $0x4,%esp
  802c60:	53                   	push   %ebx
  802c61:	50                   	push   %eax
  802c62:	68 24 45 80 00       	push   $0x804524
  802c67:	e8 f4 ed ff ff       	call   801a60 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802c6c:	83 c4 10             	add    $0x10,%esp
  802c6f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c74:	eb 23                	jmp    802c99 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802c76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c79:	8b 52 18             	mov    0x18(%edx),%edx
  802c7c:	85 d2                	test   %edx,%edx
  802c7e:	74 14                	je     802c94 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802c80:	83 ec 08             	sub    $0x8,%esp
  802c83:	ff 75 0c             	pushl  0xc(%ebp)
  802c86:	50                   	push   %eax
  802c87:	ff d2                	call   *%edx
  802c89:	89 c2                	mov    %eax,%edx
  802c8b:	83 c4 10             	add    $0x10,%esp
  802c8e:	eb 09                	jmp    802c99 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c90:	89 c2                	mov    %eax,%edx
  802c92:	eb 05                	jmp    802c99 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802c94:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802c99:	89 d0                	mov    %edx,%eax
  802c9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c9e:	c9                   	leave  
  802c9f:	c3                   	ret    

00802ca0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802ca0:	55                   	push   %ebp
  802ca1:	89 e5                	mov    %esp,%ebp
  802ca3:	53                   	push   %ebx
  802ca4:	83 ec 14             	sub    $0x14,%esp
  802ca7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802caa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cad:	50                   	push   %eax
  802cae:	ff 75 08             	pushl  0x8(%ebp)
  802cb1:	e8 6c fb ff ff       	call   802822 <fd_lookup>
  802cb6:	83 c4 08             	add    $0x8,%esp
  802cb9:	89 c2                	mov    %eax,%edx
  802cbb:	85 c0                	test   %eax,%eax
  802cbd:	78 58                	js     802d17 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cbf:	83 ec 08             	sub    $0x8,%esp
  802cc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cc5:	50                   	push   %eax
  802cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cc9:	ff 30                	pushl  (%eax)
  802ccb:	e8 a8 fb ff ff       	call   802878 <dev_lookup>
  802cd0:	83 c4 10             	add    $0x10,%esp
  802cd3:	85 c0                	test   %eax,%eax
  802cd5:	78 37                	js     802d0e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cda:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802cde:	74 32                	je     802d12 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802ce0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802ce3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802cea:	00 00 00 
	stat->st_isdir = 0;
  802ced:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802cf4:	00 00 00 
	stat->st_dev = dev;
  802cf7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802cfd:	83 ec 08             	sub    $0x8,%esp
  802d00:	53                   	push   %ebx
  802d01:	ff 75 f0             	pushl  -0x10(%ebp)
  802d04:	ff 50 14             	call   *0x14(%eax)
  802d07:	89 c2                	mov    %eax,%edx
  802d09:	83 c4 10             	add    $0x10,%esp
  802d0c:	eb 09                	jmp    802d17 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d0e:	89 c2                	mov    %eax,%edx
  802d10:	eb 05                	jmp    802d17 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802d12:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802d17:	89 d0                	mov    %edx,%eax
  802d19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d1c:	c9                   	leave  
  802d1d:	c3                   	ret    

00802d1e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802d1e:	55                   	push   %ebp
  802d1f:	89 e5                	mov    %esp,%ebp
  802d21:	56                   	push   %esi
  802d22:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802d23:	83 ec 08             	sub    $0x8,%esp
  802d26:	6a 00                	push   $0x0
  802d28:	ff 75 08             	pushl  0x8(%ebp)
  802d2b:	e8 ef 01 00 00       	call   802f1f <open>
  802d30:	89 c3                	mov    %eax,%ebx
  802d32:	83 c4 10             	add    $0x10,%esp
  802d35:	85 c0                	test   %eax,%eax
  802d37:	78 1b                	js     802d54 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802d39:	83 ec 08             	sub    $0x8,%esp
  802d3c:	ff 75 0c             	pushl  0xc(%ebp)
  802d3f:	50                   	push   %eax
  802d40:	e8 5b ff ff ff       	call   802ca0 <fstat>
  802d45:	89 c6                	mov    %eax,%esi
	close(fd);
  802d47:	89 1c 24             	mov    %ebx,(%esp)
  802d4a:	e8 fd fb ff ff       	call   80294c <close>
	return r;
  802d4f:	83 c4 10             	add    $0x10,%esp
  802d52:	89 f0                	mov    %esi,%eax
}
  802d54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d57:	5b                   	pop    %ebx
  802d58:	5e                   	pop    %esi
  802d59:	5d                   	pop    %ebp
  802d5a:	c3                   	ret    

00802d5b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802d5b:	55                   	push   %ebp
  802d5c:	89 e5                	mov    %esp,%ebp
  802d5e:	56                   	push   %esi
  802d5f:	53                   	push   %ebx
  802d60:	89 c6                	mov    %eax,%esi
  802d62:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802d64:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d6b:	75 12                	jne    802d7f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802d6d:	83 ec 0c             	sub    $0xc,%esp
  802d70:	6a 01                	push   $0x1
  802d72:	e8 fc f9 ff ff       	call   802773 <ipc_find_env>
  802d77:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d7c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802d7f:	6a 07                	push   $0x7
  802d81:	68 00 b0 80 00       	push   $0x80b000
  802d86:	56                   	push   %esi
  802d87:	ff 35 00 a0 80 00    	pushl  0x80a000
  802d8d:	e8 92 f9 ff ff       	call   802724 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802d92:	83 c4 0c             	add    $0xc,%esp
  802d95:	6a 00                	push   $0x0
  802d97:	53                   	push   %ebx
  802d98:	6a 00                	push   $0x0
  802d9a:	e8 0f f9 ff ff       	call   8026ae <ipc_recv>
}
  802d9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802da2:	5b                   	pop    %ebx
  802da3:	5e                   	pop    %esi
  802da4:	5d                   	pop    %ebp
  802da5:	c3                   	ret    

00802da6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802da6:	55                   	push   %ebp
  802da7:	89 e5                	mov    %esp,%ebp
  802da9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802dac:	8b 45 08             	mov    0x8(%ebp),%eax
  802daf:	8b 40 0c             	mov    0xc(%eax),%eax
  802db2:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  802dba:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  802dc4:	b8 02 00 00 00       	mov    $0x2,%eax
  802dc9:	e8 8d ff ff ff       	call   802d5b <fsipc>
}
  802dce:	c9                   	leave  
  802dcf:	c3                   	ret    

00802dd0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802dd0:	55                   	push   %ebp
  802dd1:	89 e5                	mov    %esp,%ebp
  802dd3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  802dd9:	8b 40 0c             	mov    0xc(%eax),%eax
  802ddc:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802de1:	ba 00 00 00 00       	mov    $0x0,%edx
  802de6:	b8 06 00 00 00       	mov    $0x6,%eax
  802deb:	e8 6b ff ff ff       	call   802d5b <fsipc>
}
  802df0:	c9                   	leave  
  802df1:	c3                   	ret    

00802df2 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802df2:	55                   	push   %ebp
  802df3:	89 e5                	mov    %esp,%ebp
  802df5:	53                   	push   %ebx
  802df6:	83 ec 04             	sub    $0x4,%esp
  802df9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  802dff:	8b 40 0c             	mov    0xc(%eax),%eax
  802e02:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802e07:	ba 00 00 00 00       	mov    $0x0,%edx
  802e0c:	b8 05 00 00 00       	mov    $0x5,%eax
  802e11:	e8 45 ff ff ff       	call   802d5b <fsipc>
  802e16:	85 c0                	test   %eax,%eax
  802e18:	78 2c                	js     802e46 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802e1a:	83 ec 08             	sub    $0x8,%esp
  802e1d:	68 00 b0 80 00       	push   $0x80b000
  802e22:	53                   	push   %ebx
  802e23:	e8 dd f1 ff ff       	call   802005 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802e28:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802e2d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802e33:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802e38:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802e3e:	83 c4 10             	add    $0x10,%esp
  802e41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e49:	c9                   	leave  
  802e4a:	c3                   	ret    

00802e4b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e4b:	55                   	push   %ebp
  802e4c:	89 e5                	mov    %esp,%ebp
  802e4e:	53                   	push   %ebx
  802e4f:	83 ec 08             	sub    $0x8,%esp
  802e52:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802e55:	8b 55 08             	mov    0x8(%ebp),%edx
  802e58:	8b 52 0c             	mov    0xc(%edx),%edx
  802e5b:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802e61:	a3 04 b0 80 00       	mov    %eax,0x80b004
  802e66:	3d 08 b0 80 00       	cmp    $0x80b008,%eax
  802e6b:	bb 08 b0 80 00       	mov    $0x80b008,%ebx
  802e70:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  802e73:	53                   	push   %ebx
  802e74:	ff 75 0c             	pushl  0xc(%ebp)
  802e77:	68 08 b0 80 00       	push   $0x80b008
  802e7c:	e8 16 f3 ff ff       	call   802197 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802e81:	ba 00 00 00 00       	mov    $0x0,%edx
  802e86:	b8 04 00 00 00       	mov    $0x4,%eax
  802e8b:	e8 cb fe ff ff       	call   802d5b <fsipc>
  802e90:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  802e93:	85 c0                	test   %eax,%eax
  802e95:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  802e98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e9b:	c9                   	leave  
  802e9c:	c3                   	ret    

00802e9d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802e9d:	55                   	push   %ebp
  802e9e:	89 e5                	mov    %esp,%ebp
  802ea0:	56                   	push   %esi
  802ea1:	53                   	push   %ebx
  802ea2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  802ea8:	8b 40 0c             	mov    0xc(%eax),%eax
  802eab:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802eb0:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802eb6:	ba 00 00 00 00       	mov    $0x0,%edx
  802ebb:	b8 03 00 00 00       	mov    $0x3,%eax
  802ec0:	e8 96 fe ff ff       	call   802d5b <fsipc>
  802ec5:	89 c3                	mov    %eax,%ebx
  802ec7:	85 c0                	test   %eax,%eax
  802ec9:	78 4b                	js     802f16 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802ecb:	39 c6                	cmp    %eax,%esi
  802ecd:	73 16                	jae    802ee5 <devfile_read+0x48>
  802ecf:	68 98 45 80 00       	push   $0x804598
  802ed4:	68 1d 3c 80 00       	push   $0x803c1d
  802ed9:	6a 7c                	push   $0x7c
  802edb:	68 9f 45 80 00       	push   $0x80459f
  802ee0:	e8 a2 ea ff ff       	call   801987 <_panic>
	assert(r <= PGSIZE);
  802ee5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802eea:	7e 16                	jle    802f02 <devfile_read+0x65>
  802eec:	68 aa 45 80 00       	push   $0x8045aa
  802ef1:	68 1d 3c 80 00       	push   $0x803c1d
  802ef6:	6a 7d                	push   $0x7d
  802ef8:	68 9f 45 80 00       	push   $0x80459f
  802efd:	e8 85 ea ff ff       	call   801987 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802f02:	83 ec 04             	sub    $0x4,%esp
  802f05:	50                   	push   %eax
  802f06:	68 00 b0 80 00       	push   $0x80b000
  802f0b:	ff 75 0c             	pushl  0xc(%ebp)
  802f0e:	e8 84 f2 ff ff       	call   802197 <memmove>
	return r;
  802f13:	83 c4 10             	add    $0x10,%esp
}
  802f16:	89 d8                	mov    %ebx,%eax
  802f18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f1b:	5b                   	pop    %ebx
  802f1c:	5e                   	pop    %esi
  802f1d:	5d                   	pop    %ebp
  802f1e:	c3                   	ret    

00802f1f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f1f:	55                   	push   %ebp
  802f20:	89 e5                	mov    %esp,%ebp
  802f22:	53                   	push   %ebx
  802f23:	83 ec 20             	sub    $0x20,%esp
  802f26:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802f29:	53                   	push   %ebx
  802f2a:	e8 9d f0 ff ff       	call   801fcc <strlen>
  802f2f:	83 c4 10             	add    $0x10,%esp
  802f32:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f37:	7f 67                	jg     802fa0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f39:	83 ec 0c             	sub    $0xc,%esp
  802f3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f3f:	50                   	push   %eax
  802f40:	e8 8e f8 ff ff       	call   8027d3 <fd_alloc>
  802f45:	83 c4 10             	add    $0x10,%esp
		return r;
  802f48:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f4a:	85 c0                	test   %eax,%eax
  802f4c:	78 57                	js     802fa5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f4e:	83 ec 08             	sub    $0x8,%esp
  802f51:	53                   	push   %ebx
  802f52:	68 00 b0 80 00       	push   $0x80b000
  802f57:	e8 a9 f0 ff ff       	call   802005 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f5f:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f67:	b8 01 00 00 00       	mov    $0x1,%eax
  802f6c:	e8 ea fd ff ff       	call   802d5b <fsipc>
  802f71:	89 c3                	mov    %eax,%ebx
  802f73:	83 c4 10             	add    $0x10,%esp
  802f76:	85 c0                	test   %eax,%eax
  802f78:	79 14                	jns    802f8e <open+0x6f>
		fd_close(fd, 0);
  802f7a:	83 ec 08             	sub    $0x8,%esp
  802f7d:	6a 00                	push   $0x0
  802f7f:	ff 75 f4             	pushl  -0xc(%ebp)
  802f82:	e8 44 f9 ff ff       	call   8028cb <fd_close>
		return r;
  802f87:	83 c4 10             	add    $0x10,%esp
  802f8a:	89 da                	mov    %ebx,%edx
  802f8c:	eb 17                	jmp    802fa5 <open+0x86>
	}

	return fd2num(fd);
  802f8e:	83 ec 0c             	sub    $0xc,%esp
  802f91:	ff 75 f4             	pushl  -0xc(%ebp)
  802f94:	e8 13 f8 ff ff       	call   8027ac <fd2num>
  802f99:	89 c2                	mov    %eax,%edx
  802f9b:	83 c4 10             	add    $0x10,%esp
  802f9e:	eb 05                	jmp    802fa5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802fa0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802fa5:	89 d0                	mov    %edx,%eax
  802fa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802faa:	c9                   	leave  
  802fab:	c3                   	ret    

00802fac <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802fac:	55                   	push   %ebp
  802fad:	89 e5                	mov    %esp,%ebp
  802faf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802fb2:	ba 00 00 00 00       	mov    $0x0,%edx
  802fb7:	b8 08 00 00 00       	mov    $0x8,%eax
  802fbc:	e8 9a fd ff ff       	call   802d5b <fsipc>
}
  802fc1:	c9                   	leave  
  802fc2:	c3                   	ret    

00802fc3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fc3:	55                   	push   %ebp
  802fc4:	89 e5                	mov    %esp,%ebp
  802fc6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fc9:	89 d0                	mov    %edx,%eax
  802fcb:	c1 e8 16             	shr    $0x16,%eax
  802fce:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802fd5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fda:	f6 c1 01             	test   $0x1,%cl
  802fdd:	74 1d                	je     802ffc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802fdf:	c1 ea 0c             	shr    $0xc,%edx
  802fe2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fe9:	f6 c2 01             	test   $0x1,%dl
  802fec:	74 0e                	je     802ffc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fee:	c1 ea 0c             	shr    $0xc,%edx
  802ff1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802ff8:	ef 
  802ff9:	0f b7 c0             	movzwl %ax,%eax
}
  802ffc:	5d                   	pop    %ebp
  802ffd:	c3                   	ret    

00802ffe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802ffe:	55                   	push   %ebp
  802fff:	89 e5                	mov    %esp,%ebp
  803001:	56                   	push   %esi
  803002:	53                   	push   %ebx
  803003:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803006:	83 ec 0c             	sub    $0xc,%esp
  803009:	ff 75 08             	pushl  0x8(%ebp)
  80300c:	e8 ab f7 ff ff       	call   8027bc <fd2data>
  803011:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803013:	83 c4 08             	add    $0x8,%esp
  803016:	68 b6 45 80 00       	push   $0x8045b6
  80301b:	53                   	push   %ebx
  80301c:	e8 e4 ef ff ff       	call   802005 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803021:	8b 46 04             	mov    0x4(%esi),%eax
  803024:	2b 06                	sub    (%esi),%eax
  803026:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80302c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803033:	00 00 00 
	stat->st_dev = &devpipe;
  803036:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80303d:	90 80 00 
	return 0;
}
  803040:	b8 00 00 00 00       	mov    $0x0,%eax
  803045:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803048:	5b                   	pop    %ebx
  803049:	5e                   	pop    %esi
  80304a:	5d                   	pop    %ebp
  80304b:	c3                   	ret    

0080304c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80304c:	55                   	push   %ebp
  80304d:	89 e5                	mov    %esp,%ebp
  80304f:	53                   	push   %ebx
  803050:	83 ec 0c             	sub    $0xc,%esp
  803053:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803056:	53                   	push   %ebx
  803057:	6a 00                	push   $0x0
  803059:	e8 2f f4 ff ff       	call   80248d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80305e:	89 1c 24             	mov    %ebx,(%esp)
  803061:	e8 56 f7 ff ff       	call   8027bc <fd2data>
  803066:	83 c4 08             	add    $0x8,%esp
  803069:	50                   	push   %eax
  80306a:	6a 00                	push   $0x0
  80306c:	e8 1c f4 ff ff       	call   80248d <sys_page_unmap>
}
  803071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803074:	c9                   	leave  
  803075:	c3                   	ret    

00803076 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803076:	55                   	push   %ebp
  803077:	89 e5                	mov    %esp,%ebp
  803079:	57                   	push   %edi
  80307a:	56                   	push   %esi
  80307b:	53                   	push   %ebx
  80307c:	83 ec 1c             	sub    $0x1c,%esp
  80307f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803082:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803084:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803089:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80308c:	83 ec 0c             	sub    $0xc,%esp
  80308f:	ff 75 e0             	pushl  -0x20(%ebp)
  803092:	e8 2c ff ff ff       	call   802fc3 <pageref>
  803097:	89 c3                	mov    %eax,%ebx
  803099:	89 3c 24             	mov    %edi,(%esp)
  80309c:	e8 22 ff ff ff       	call   802fc3 <pageref>
  8030a1:	83 c4 10             	add    $0x10,%esp
  8030a4:	39 c3                	cmp    %eax,%ebx
  8030a6:	0f 94 c1             	sete   %cl
  8030a9:	0f b6 c9             	movzbl %cl,%ecx
  8030ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8030af:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  8030b5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8030b8:	39 ce                	cmp    %ecx,%esi
  8030ba:	74 1b                	je     8030d7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8030bc:	39 c3                	cmp    %eax,%ebx
  8030be:	75 c4                	jne    803084 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8030c0:	8b 42 58             	mov    0x58(%edx),%eax
  8030c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8030c6:	50                   	push   %eax
  8030c7:	56                   	push   %esi
  8030c8:	68 bd 45 80 00       	push   $0x8045bd
  8030cd:	e8 8e e9 ff ff       	call   801a60 <cprintf>
  8030d2:	83 c4 10             	add    $0x10,%esp
  8030d5:	eb ad                	jmp    803084 <_pipeisclosed+0xe>
	}
}
  8030d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8030da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030dd:	5b                   	pop    %ebx
  8030de:	5e                   	pop    %esi
  8030df:	5f                   	pop    %edi
  8030e0:	5d                   	pop    %ebp
  8030e1:	c3                   	ret    

008030e2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8030e2:	55                   	push   %ebp
  8030e3:	89 e5                	mov    %esp,%ebp
  8030e5:	57                   	push   %edi
  8030e6:	56                   	push   %esi
  8030e7:	53                   	push   %ebx
  8030e8:	83 ec 28             	sub    $0x28,%esp
  8030eb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8030ee:	56                   	push   %esi
  8030ef:	e8 c8 f6 ff ff       	call   8027bc <fd2data>
  8030f4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030f6:	83 c4 10             	add    $0x10,%esp
  8030f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8030fe:	eb 4b                	jmp    80314b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803100:	89 da                	mov    %ebx,%edx
  803102:	89 f0                	mov    %esi,%eax
  803104:	e8 6d ff ff ff       	call   803076 <_pipeisclosed>
  803109:	85 c0                	test   %eax,%eax
  80310b:	75 48                	jne    803155 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80310d:	e8 d7 f2 ff ff       	call   8023e9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803112:	8b 43 04             	mov    0x4(%ebx),%eax
  803115:	8b 0b                	mov    (%ebx),%ecx
  803117:	8d 51 20             	lea    0x20(%ecx),%edx
  80311a:	39 d0                	cmp    %edx,%eax
  80311c:	73 e2                	jae    803100 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80311e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803121:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803125:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803128:	89 c2                	mov    %eax,%edx
  80312a:	c1 fa 1f             	sar    $0x1f,%edx
  80312d:	89 d1                	mov    %edx,%ecx
  80312f:	c1 e9 1b             	shr    $0x1b,%ecx
  803132:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803135:	83 e2 1f             	and    $0x1f,%edx
  803138:	29 ca                	sub    %ecx,%edx
  80313a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80313e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803142:	83 c0 01             	add    $0x1,%eax
  803145:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803148:	83 c7 01             	add    $0x1,%edi
  80314b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80314e:	75 c2                	jne    803112 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803150:	8b 45 10             	mov    0x10(%ebp),%eax
  803153:	eb 05                	jmp    80315a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803155:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80315a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80315d:	5b                   	pop    %ebx
  80315e:	5e                   	pop    %esi
  80315f:	5f                   	pop    %edi
  803160:	5d                   	pop    %ebp
  803161:	c3                   	ret    

00803162 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803162:	55                   	push   %ebp
  803163:	89 e5                	mov    %esp,%ebp
  803165:	57                   	push   %edi
  803166:	56                   	push   %esi
  803167:	53                   	push   %ebx
  803168:	83 ec 18             	sub    $0x18,%esp
  80316b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80316e:	57                   	push   %edi
  80316f:	e8 48 f6 ff ff       	call   8027bc <fd2data>
  803174:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803176:	83 c4 10             	add    $0x10,%esp
  803179:	bb 00 00 00 00       	mov    $0x0,%ebx
  80317e:	eb 3d                	jmp    8031bd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803180:	85 db                	test   %ebx,%ebx
  803182:	74 04                	je     803188 <devpipe_read+0x26>
				return i;
  803184:	89 d8                	mov    %ebx,%eax
  803186:	eb 44                	jmp    8031cc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803188:	89 f2                	mov    %esi,%edx
  80318a:	89 f8                	mov    %edi,%eax
  80318c:	e8 e5 fe ff ff       	call   803076 <_pipeisclosed>
  803191:	85 c0                	test   %eax,%eax
  803193:	75 32                	jne    8031c7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803195:	e8 4f f2 ff ff       	call   8023e9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80319a:	8b 06                	mov    (%esi),%eax
  80319c:	3b 46 04             	cmp    0x4(%esi),%eax
  80319f:	74 df                	je     803180 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8031a1:	99                   	cltd   
  8031a2:	c1 ea 1b             	shr    $0x1b,%edx
  8031a5:	01 d0                	add    %edx,%eax
  8031a7:	83 e0 1f             	and    $0x1f,%eax
  8031aa:	29 d0                	sub    %edx,%eax
  8031ac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8031b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031b4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8031b7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8031ba:	83 c3 01             	add    $0x1,%ebx
  8031bd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8031c0:	75 d8                	jne    80319a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8031c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8031c5:	eb 05                	jmp    8031cc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8031c7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8031cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031cf:	5b                   	pop    %ebx
  8031d0:	5e                   	pop    %esi
  8031d1:	5f                   	pop    %edi
  8031d2:	5d                   	pop    %ebp
  8031d3:	c3                   	ret    

008031d4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8031d4:	55                   	push   %ebp
  8031d5:	89 e5                	mov    %esp,%ebp
  8031d7:	56                   	push   %esi
  8031d8:	53                   	push   %ebx
  8031d9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8031dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031df:	50                   	push   %eax
  8031e0:	e8 ee f5 ff ff       	call   8027d3 <fd_alloc>
  8031e5:	83 c4 10             	add    $0x10,%esp
  8031e8:	89 c2                	mov    %eax,%edx
  8031ea:	85 c0                	test   %eax,%eax
  8031ec:	0f 88 2c 01 00 00    	js     80331e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031f2:	83 ec 04             	sub    $0x4,%esp
  8031f5:	68 07 04 00 00       	push   $0x407
  8031fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8031fd:	6a 00                	push   $0x0
  8031ff:	e8 04 f2 ff ff       	call   802408 <sys_page_alloc>
  803204:	83 c4 10             	add    $0x10,%esp
  803207:	89 c2                	mov    %eax,%edx
  803209:	85 c0                	test   %eax,%eax
  80320b:	0f 88 0d 01 00 00    	js     80331e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803211:	83 ec 0c             	sub    $0xc,%esp
  803214:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803217:	50                   	push   %eax
  803218:	e8 b6 f5 ff ff       	call   8027d3 <fd_alloc>
  80321d:	89 c3                	mov    %eax,%ebx
  80321f:	83 c4 10             	add    $0x10,%esp
  803222:	85 c0                	test   %eax,%eax
  803224:	0f 88 e2 00 00 00    	js     80330c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80322a:	83 ec 04             	sub    $0x4,%esp
  80322d:	68 07 04 00 00       	push   $0x407
  803232:	ff 75 f0             	pushl  -0x10(%ebp)
  803235:	6a 00                	push   $0x0
  803237:	e8 cc f1 ff ff       	call   802408 <sys_page_alloc>
  80323c:	89 c3                	mov    %eax,%ebx
  80323e:	83 c4 10             	add    $0x10,%esp
  803241:	85 c0                	test   %eax,%eax
  803243:	0f 88 c3 00 00 00    	js     80330c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803249:	83 ec 0c             	sub    $0xc,%esp
  80324c:	ff 75 f4             	pushl  -0xc(%ebp)
  80324f:	e8 68 f5 ff ff       	call   8027bc <fd2data>
  803254:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803256:	83 c4 0c             	add    $0xc,%esp
  803259:	68 07 04 00 00       	push   $0x407
  80325e:	50                   	push   %eax
  80325f:	6a 00                	push   $0x0
  803261:	e8 a2 f1 ff ff       	call   802408 <sys_page_alloc>
  803266:	89 c3                	mov    %eax,%ebx
  803268:	83 c4 10             	add    $0x10,%esp
  80326b:	85 c0                	test   %eax,%eax
  80326d:	0f 88 89 00 00 00    	js     8032fc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803273:	83 ec 0c             	sub    $0xc,%esp
  803276:	ff 75 f0             	pushl  -0x10(%ebp)
  803279:	e8 3e f5 ff ff       	call   8027bc <fd2data>
  80327e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803285:	50                   	push   %eax
  803286:	6a 00                	push   $0x0
  803288:	56                   	push   %esi
  803289:	6a 00                	push   $0x0
  80328b:	e8 bb f1 ff ff       	call   80244b <sys_page_map>
  803290:	89 c3                	mov    %eax,%ebx
  803292:	83 c4 20             	add    $0x20,%esp
  803295:	85 c0                	test   %eax,%eax
  803297:	78 55                	js     8032ee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803299:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80329f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032a2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8032a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8032ae:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8032b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032b7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8032b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8032c3:	83 ec 0c             	sub    $0xc,%esp
  8032c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8032c9:	e8 de f4 ff ff       	call   8027ac <fd2num>
  8032ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032d1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8032d3:	83 c4 04             	add    $0x4,%esp
  8032d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8032d9:	e8 ce f4 ff ff       	call   8027ac <fd2num>
  8032de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032e1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8032e4:	83 c4 10             	add    $0x10,%esp
  8032e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8032ec:	eb 30                	jmp    80331e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8032ee:	83 ec 08             	sub    $0x8,%esp
  8032f1:	56                   	push   %esi
  8032f2:	6a 00                	push   $0x0
  8032f4:	e8 94 f1 ff ff       	call   80248d <sys_page_unmap>
  8032f9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8032fc:	83 ec 08             	sub    $0x8,%esp
  8032ff:	ff 75 f0             	pushl  -0x10(%ebp)
  803302:	6a 00                	push   $0x0
  803304:	e8 84 f1 ff ff       	call   80248d <sys_page_unmap>
  803309:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80330c:	83 ec 08             	sub    $0x8,%esp
  80330f:	ff 75 f4             	pushl  -0xc(%ebp)
  803312:	6a 00                	push   $0x0
  803314:	e8 74 f1 ff ff       	call   80248d <sys_page_unmap>
  803319:	83 c4 10             	add    $0x10,%esp
  80331c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80331e:	89 d0                	mov    %edx,%eax
  803320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803323:	5b                   	pop    %ebx
  803324:	5e                   	pop    %esi
  803325:	5d                   	pop    %ebp
  803326:	c3                   	ret    

00803327 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803327:	55                   	push   %ebp
  803328:	89 e5                	mov    %esp,%ebp
  80332a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80332d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803330:	50                   	push   %eax
  803331:	ff 75 08             	pushl  0x8(%ebp)
  803334:	e8 e9 f4 ff ff       	call   802822 <fd_lookup>
  803339:	83 c4 10             	add    $0x10,%esp
  80333c:	85 c0                	test   %eax,%eax
  80333e:	78 18                	js     803358 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803340:	83 ec 0c             	sub    $0xc,%esp
  803343:	ff 75 f4             	pushl  -0xc(%ebp)
  803346:	e8 71 f4 ff ff       	call   8027bc <fd2data>
	return _pipeisclosed(fd, p);
  80334b:	89 c2                	mov    %eax,%edx
  80334d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803350:	e8 21 fd ff ff       	call   803076 <_pipeisclosed>
  803355:	83 c4 10             	add    $0x10,%esp
}
  803358:	c9                   	leave  
  803359:	c3                   	ret    

0080335a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80335a:	55                   	push   %ebp
  80335b:	89 e5                	mov    %esp,%ebp
  80335d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  803360:	68 d5 45 80 00       	push   $0x8045d5
  803365:	ff 75 0c             	pushl  0xc(%ebp)
  803368:	e8 98 ec ff ff       	call   802005 <strcpy>
	return 0;
}
  80336d:	b8 00 00 00 00       	mov    $0x0,%eax
  803372:	c9                   	leave  
  803373:	c3                   	ret    

00803374 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803374:	55                   	push   %ebp
  803375:	89 e5                	mov    %esp,%ebp
  803377:	53                   	push   %ebx
  803378:	83 ec 10             	sub    $0x10,%esp
  80337b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80337e:	53                   	push   %ebx
  80337f:	e8 3f fc ff ff       	call   802fc3 <pageref>
  803384:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  803387:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80338c:	83 f8 01             	cmp    $0x1,%eax
  80338f:	75 10                	jne    8033a1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  803391:	83 ec 0c             	sub    $0xc,%esp
  803394:	ff 73 0c             	pushl  0xc(%ebx)
  803397:	e8 c0 02 00 00       	call   80365c <nsipc_close>
  80339c:	89 c2                	mov    %eax,%edx
  80339e:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8033a1:	89 d0                	mov    %edx,%eax
  8033a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8033a6:	c9                   	leave  
  8033a7:	c3                   	ret    

008033a8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8033a8:	55                   	push   %ebp
  8033a9:	89 e5                	mov    %esp,%ebp
  8033ab:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8033ae:	6a 00                	push   $0x0
  8033b0:	ff 75 10             	pushl  0x10(%ebp)
  8033b3:	ff 75 0c             	pushl  0xc(%ebp)
  8033b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8033b9:	ff 70 0c             	pushl  0xc(%eax)
  8033bc:	e8 78 03 00 00       	call   803739 <nsipc_send>
}
  8033c1:	c9                   	leave  
  8033c2:	c3                   	ret    

008033c3 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8033c3:	55                   	push   %ebp
  8033c4:	89 e5                	mov    %esp,%ebp
  8033c6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8033c9:	6a 00                	push   $0x0
  8033cb:	ff 75 10             	pushl  0x10(%ebp)
  8033ce:	ff 75 0c             	pushl  0xc(%ebp)
  8033d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8033d4:	ff 70 0c             	pushl  0xc(%eax)
  8033d7:	e8 f1 02 00 00       	call   8036cd <nsipc_recv>
}
  8033dc:	c9                   	leave  
  8033dd:	c3                   	ret    

008033de <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8033de:	55                   	push   %ebp
  8033df:	89 e5                	mov    %esp,%ebp
  8033e1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8033e4:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8033e7:	52                   	push   %edx
  8033e8:	50                   	push   %eax
  8033e9:	e8 34 f4 ff ff       	call   802822 <fd_lookup>
  8033ee:	83 c4 10             	add    $0x10,%esp
  8033f1:	85 c0                	test   %eax,%eax
  8033f3:	78 17                	js     80340c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8033f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033f8:	8b 0d 9c 90 80 00    	mov    0x80909c,%ecx
  8033fe:	39 08                	cmp    %ecx,(%eax)
  803400:	75 05                	jne    803407 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  803402:	8b 40 0c             	mov    0xc(%eax),%eax
  803405:	eb 05                	jmp    80340c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  803407:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80340c:	c9                   	leave  
  80340d:	c3                   	ret    

0080340e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80340e:	55                   	push   %ebp
  80340f:	89 e5                	mov    %esp,%ebp
  803411:	56                   	push   %esi
  803412:	53                   	push   %ebx
  803413:	83 ec 1c             	sub    $0x1c,%esp
  803416:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80341b:	50                   	push   %eax
  80341c:	e8 b2 f3 ff ff       	call   8027d3 <fd_alloc>
  803421:	89 c3                	mov    %eax,%ebx
  803423:	83 c4 10             	add    $0x10,%esp
  803426:	85 c0                	test   %eax,%eax
  803428:	78 1b                	js     803445 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80342a:	83 ec 04             	sub    $0x4,%esp
  80342d:	68 07 04 00 00       	push   $0x407
  803432:	ff 75 f4             	pushl  -0xc(%ebp)
  803435:	6a 00                	push   $0x0
  803437:	e8 cc ef ff ff       	call   802408 <sys_page_alloc>
  80343c:	89 c3                	mov    %eax,%ebx
  80343e:	83 c4 10             	add    $0x10,%esp
  803441:	85 c0                	test   %eax,%eax
  803443:	79 10                	jns    803455 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  803445:	83 ec 0c             	sub    $0xc,%esp
  803448:	56                   	push   %esi
  803449:	e8 0e 02 00 00       	call   80365c <nsipc_close>
		return r;
  80344e:	83 c4 10             	add    $0x10,%esp
  803451:	89 d8                	mov    %ebx,%eax
  803453:	eb 24                	jmp    803479 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803455:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80345b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80345e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803460:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803463:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80346a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80346d:	83 ec 0c             	sub    $0xc,%esp
  803470:	50                   	push   %eax
  803471:	e8 36 f3 ff ff       	call   8027ac <fd2num>
  803476:	83 c4 10             	add    $0x10,%esp
}
  803479:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80347c:	5b                   	pop    %ebx
  80347d:	5e                   	pop    %esi
  80347e:	5d                   	pop    %ebp
  80347f:	c3                   	ret    

00803480 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803480:	55                   	push   %ebp
  803481:	89 e5                	mov    %esp,%ebp
  803483:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803486:	8b 45 08             	mov    0x8(%ebp),%eax
  803489:	e8 50 ff ff ff       	call   8033de <fd2sockid>
		return r;
  80348e:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  803490:	85 c0                	test   %eax,%eax
  803492:	78 1f                	js     8034b3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803494:	83 ec 04             	sub    $0x4,%esp
  803497:	ff 75 10             	pushl  0x10(%ebp)
  80349a:	ff 75 0c             	pushl  0xc(%ebp)
  80349d:	50                   	push   %eax
  80349e:	e8 12 01 00 00       	call   8035b5 <nsipc_accept>
  8034a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8034a6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8034a8:	85 c0                	test   %eax,%eax
  8034aa:	78 07                	js     8034b3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8034ac:	e8 5d ff ff ff       	call   80340e <alloc_sockfd>
  8034b1:	89 c1                	mov    %eax,%ecx
}
  8034b3:	89 c8                	mov    %ecx,%eax
  8034b5:	c9                   	leave  
  8034b6:	c3                   	ret    

008034b7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8034b7:	55                   	push   %ebp
  8034b8:	89 e5                	mov    %esp,%ebp
  8034ba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8034bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8034c0:	e8 19 ff ff ff       	call   8033de <fd2sockid>
  8034c5:	85 c0                	test   %eax,%eax
  8034c7:	78 12                	js     8034db <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8034c9:	83 ec 04             	sub    $0x4,%esp
  8034cc:	ff 75 10             	pushl  0x10(%ebp)
  8034cf:	ff 75 0c             	pushl  0xc(%ebp)
  8034d2:	50                   	push   %eax
  8034d3:	e8 2d 01 00 00       	call   803605 <nsipc_bind>
  8034d8:	83 c4 10             	add    $0x10,%esp
}
  8034db:	c9                   	leave  
  8034dc:	c3                   	ret    

008034dd <shutdown>:

int
shutdown(int s, int how)
{
  8034dd:	55                   	push   %ebp
  8034de:	89 e5                	mov    %esp,%ebp
  8034e0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8034e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8034e6:	e8 f3 fe ff ff       	call   8033de <fd2sockid>
  8034eb:	85 c0                	test   %eax,%eax
  8034ed:	78 0f                	js     8034fe <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8034ef:	83 ec 08             	sub    $0x8,%esp
  8034f2:	ff 75 0c             	pushl  0xc(%ebp)
  8034f5:	50                   	push   %eax
  8034f6:	e8 3f 01 00 00       	call   80363a <nsipc_shutdown>
  8034fb:	83 c4 10             	add    $0x10,%esp
}
  8034fe:	c9                   	leave  
  8034ff:	c3                   	ret    

00803500 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803500:	55                   	push   %ebp
  803501:	89 e5                	mov    %esp,%ebp
  803503:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803506:	8b 45 08             	mov    0x8(%ebp),%eax
  803509:	e8 d0 fe ff ff       	call   8033de <fd2sockid>
  80350e:	85 c0                	test   %eax,%eax
  803510:	78 12                	js     803524 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  803512:	83 ec 04             	sub    $0x4,%esp
  803515:	ff 75 10             	pushl  0x10(%ebp)
  803518:	ff 75 0c             	pushl  0xc(%ebp)
  80351b:	50                   	push   %eax
  80351c:	e8 55 01 00 00       	call   803676 <nsipc_connect>
  803521:	83 c4 10             	add    $0x10,%esp
}
  803524:	c9                   	leave  
  803525:	c3                   	ret    

00803526 <listen>:

int
listen(int s, int backlog)
{
  803526:	55                   	push   %ebp
  803527:	89 e5                	mov    %esp,%ebp
  803529:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80352c:	8b 45 08             	mov    0x8(%ebp),%eax
  80352f:	e8 aa fe ff ff       	call   8033de <fd2sockid>
  803534:	85 c0                	test   %eax,%eax
  803536:	78 0f                	js     803547 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803538:	83 ec 08             	sub    $0x8,%esp
  80353b:	ff 75 0c             	pushl  0xc(%ebp)
  80353e:	50                   	push   %eax
  80353f:	e8 67 01 00 00       	call   8036ab <nsipc_listen>
  803544:	83 c4 10             	add    $0x10,%esp
}
  803547:	c9                   	leave  
  803548:	c3                   	ret    

00803549 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  803549:	55                   	push   %ebp
  80354a:	89 e5                	mov    %esp,%ebp
  80354c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80354f:	ff 75 10             	pushl  0x10(%ebp)
  803552:	ff 75 0c             	pushl  0xc(%ebp)
  803555:	ff 75 08             	pushl  0x8(%ebp)
  803558:	e8 3a 02 00 00       	call   803797 <nsipc_socket>
  80355d:	83 c4 10             	add    $0x10,%esp
  803560:	85 c0                	test   %eax,%eax
  803562:	78 05                	js     803569 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  803564:	e8 a5 fe ff ff       	call   80340e <alloc_sockfd>
}
  803569:	c9                   	leave  
  80356a:	c3                   	ret    

0080356b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80356b:	55                   	push   %ebp
  80356c:	89 e5                	mov    %esp,%ebp
  80356e:	53                   	push   %ebx
  80356f:	83 ec 04             	sub    $0x4,%esp
  803572:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  803574:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  80357b:	75 12                	jne    80358f <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80357d:	83 ec 0c             	sub    $0xc,%esp
  803580:	6a 02                	push   $0x2
  803582:	e8 ec f1 ff ff       	call   802773 <ipc_find_env>
  803587:	a3 04 a0 80 00       	mov    %eax,0x80a004
  80358c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80358f:	6a 07                	push   $0x7
  803591:	68 00 c0 80 00       	push   $0x80c000
  803596:	53                   	push   %ebx
  803597:	ff 35 04 a0 80 00    	pushl  0x80a004
  80359d:	e8 82 f1 ff ff       	call   802724 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8035a2:	83 c4 0c             	add    $0xc,%esp
  8035a5:	6a 00                	push   $0x0
  8035a7:	6a 00                	push   $0x0
  8035a9:	6a 00                	push   $0x0
  8035ab:	e8 fe f0 ff ff       	call   8026ae <ipc_recv>
}
  8035b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8035b3:	c9                   	leave  
  8035b4:	c3                   	ret    

008035b5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8035b5:	55                   	push   %ebp
  8035b6:	89 e5                	mov    %esp,%ebp
  8035b8:	56                   	push   %esi
  8035b9:	53                   	push   %ebx
  8035ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8035bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8035c0:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8035c5:	8b 06                	mov    (%esi),%eax
  8035c7:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8035cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8035d1:	e8 95 ff ff ff       	call   80356b <nsipc>
  8035d6:	89 c3                	mov    %eax,%ebx
  8035d8:	85 c0                	test   %eax,%eax
  8035da:	78 20                	js     8035fc <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8035dc:	83 ec 04             	sub    $0x4,%esp
  8035df:	ff 35 10 c0 80 00    	pushl  0x80c010
  8035e5:	68 00 c0 80 00       	push   $0x80c000
  8035ea:	ff 75 0c             	pushl  0xc(%ebp)
  8035ed:	e8 a5 eb ff ff       	call   802197 <memmove>
		*addrlen = ret->ret_addrlen;
  8035f2:	a1 10 c0 80 00       	mov    0x80c010,%eax
  8035f7:	89 06                	mov    %eax,(%esi)
  8035f9:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8035fc:	89 d8                	mov    %ebx,%eax
  8035fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803601:	5b                   	pop    %ebx
  803602:	5e                   	pop    %esi
  803603:	5d                   	pop    %ebp
  803604:	c3                   	ret    

00803605 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803605:	55                   	push   %ebp
  803606:	89 e5                	mov    %esp,%ebp
  803608:	53                   	push   %ebx
  803609:	83 ec 08             	sub    $0x8,%esp
  80360c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80360f:	8b 45 08             	mov    0x8(%ebp),%eax
  803612:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  803617:	53                   	push   %ebx
  803618:	ff 75 0c             	pushl  0xc(%ebp)
  80361b:	68 04 c0 80 00       	push   $0x80c004
  803620:	e8 72 eb ff ff       	call   802197 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  803625:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  80362b:	b8 02 00 00 00       	mov    $0x2,%eax
  803630:	e8 36 ff ff ff       	call   80356b <nsipc>
}
  803635:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803638:	c9                   	leave  
  803639:	c3                   	ret    

0080363a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80363a:	55                   	push   %ebp
  80363b:	89 e5                	mov    %esp,%ebp
  80363d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803640:	8b 45 08             	mov    0x8(%ebp),%eax
  803643:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  803648:	8b 45 0c             	mov    0xc(%ebp),%eax
  80364b:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  803650:	b8 03 00 00 00       	mov    $0x3,%eax
  803655:	e8 11 ff ff ff       	call   80356b <nsipc>
}
  80365a:	c9                   	leave  
  80365b:	c3                   	ret    

0080365c <nsipc_close>:

int
nsipc_close(int s)
{
  80365c:	55                   	push   %ebp
  80365d:	89 e5                	mov    %esp,%ebp
  80365f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803662:	8b 45 08             	mov    0x8(%ebp),%eax
  803665:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  80366a:	b8 04 00 00 00       	mov    $0x4,%eax
  80366f:	e8 f7 fe ff ff       	call   80356b <nsipc>
}
  803674:	c9                   	leave  
  803675:	c3                   	ret    

00803676 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803676:	55                   	push   %ebp
  803677:	89 e5                	mov    %esp,%ebp
  803679:	53                   	push   %ebx
  80367a:	83 ec 08             	sub    $0x8,%esp
  80367d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803680:	8b 45 08             	mov    0x8(%ebp),%eax
  803683:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803688:	53                   	push   %ebx
  803689:	ff 75 0c             	pushl  0xc(%ebp)
  80368c:	68 04 c0 80 00       	push   $0x80c004
  803691:	e8 01 eb ff ff       	call   802197 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  803696:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  80369c:	b8 05 00 00 00       	mov    $0x5,%eax
  8036a1:	e8 c5 fe ff ff       	call   80356b <nsipc>
}
  8036a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8036a9:	c9                   	leave  
  8036aa:	c3                   	ret    

008036ab <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8036ab:	55                   	push   %ebp
  8036ac:	89 e5                	mov    %esp,%ebp
  8036ae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8036b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8036b4:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  8036b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8036bc:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  8036c1:	b8 06 00 00 00       	mov    $0x6,%eax
  8036c6:	e8 a0 fe ff ff       	call   80356b <nsipc>
}
  8036cb:	c9                   	leave  
  8036cc:	c3                   	ret    

008036cd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8036cd:	55                   	push   %ebp
  8036ce:	89 e5                	mov    %esp,%ebp
  8036d0:	56                   	push   %esi
  8036d1:	53                   	push   %ebx
  8036d2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8036d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8036d8:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  8036dd:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  8036e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8036e6:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8036eb:	b8 07 00 00 00       	mov    $0x7,%eax
  8036f0:	e8 76 fe ff ff       	call   80356b <nsipc>
  8036f5:	89 c3                	mov    %eax,%ebx
  8036f7:	85 c0                	test   %eax,%eax
  8036f9:	78 35                	js     803730 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8036fb:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  803700:	7f 04                	jg     803706 <nsipc_recv+0x39>
  803702:	39 c6                	cmp    %eax,%esi
  803704:	7d 16                	jge    80371c <nsipc_recv+0x4f>
  803706:	68 e1 45 80 00       	push   $0x8045e1
  80370b:	68 1d 3c 80 00       	push   $0x803c1d
  803710:	6a 62                	push   $0x62
  803712:	68 f6 45 80 00       	push   $0x8045f6
  803717:	e8 6b e2 ff ff       	call   801987 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80371c:	83 ec 04             	sub    $0x4,%esp
  80371f:	50                   	push   %eax
  803720:	68 00 c0 80 00       	push   $0x80c000
  803725:	ff 75 0c             	pushl  0xc(%ebp)
  803728:	e8 6a ea ff ff       	call   802197 <memmove>
  80372d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  803730:	89 d8                	mov    %ebx,%eax
  803732:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803735:	5b                   	pop    %ebx
  803736:	5e                   	pop    %esi
  803737:	5d                   	pop    %ebp
  803738:	c3                   	ret    

00803739 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803739:	55                   	push   %ebp
  80373a:	89 e5                	mov    %esp,%ebp
  80373c:	53                   	push   %ebx
  80373d:	83 ec 04             	sub    $0x4,%esp
  803740:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803743:	8b 45 08             	mov    0x8(%ebp),%eax
  803746:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  80374b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803751:	7e 16                	jle    803769 <nsipc_send+0x30>
  803753:	68 02 46 80 00       	push   $0x804602
  803758:	68 1d 3c 80 00       	push   $0x803c1d
  80375d:	6a 6d                	push   $0x6d
  80375f:	68 f6 45 80 00       	push   $0x8045f6
  803764:	e8 1e e2 ff ff       	call   801987 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803769:	83 ec 04             	sub    $0x4,%esp
  80376c:	53                   	push   %ebx
  80376d:	ff 75 0c             	pushl  0xc(%ebp)
  803770:	68 0c c0 80 00       	push   $0x80c00c
  803775:	e8 1d ea ff ff       	call   802197 <memmove>
	nsipcbuf.send.req_size = size;
  80377a:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  803780:	8b 45 14             	mov    0x14(%ebp),%eax
  803783:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  803788:	b8 08 00 00 00       	mov    $0x8,%eax
  80378d:	e8 d9 fd ff ff       	call   80356b <nsipc>
}
  803792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803795:	c9                   	leave  
  803796:	c3                   	ret    

00803797 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803797:	55                   	push   %ebp
  803798:	89 e5                	mov    %esp,%ebp
  80379a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80379d:	8b 45 08             	mov    0x8(%ebp),%eax
  8037a0:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  8037a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037a8:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  8037ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8037b0:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  8037b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8037ba:	e8 ac fd ff ff       	call   80356b <nsipc>
}
  8037bf:	c9                   	leave  
  8037c0:	c3                   	ret    

008037c1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8037c1:	55                   	push   %ebp
  8037c2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8037c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8037c9:	5d                   	pop    %ebp
  8037ca:	c3                   	ret    

008037cb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8037cb:	55                   	push   %ebp
  8037cc:	89 e5                	mov    %esp,%ebp
  8037ce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8037d1:	68 0e 46 80 00       	push   $0x80460e
  8037d6:	ff 75 0c             	pushl  0xc(%ebp)
  8037d9:	e8 27 e8 ff ff       	call   802005 <strcpy>
	return 0;
}
  8037de:	b8 00 00 00 00       	mov    $0x0,%eax
  8037e3:	c9                   	leave  
  8037e4:	c3                   	ret    

008037e5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8037e5:	55                   	push   %ebp
  8037e6:	89 e5                	mov    %esp,%ebp
  8037e8:	57                   	push   %edi
  8037e9:	56                   	push   %esi
  8037ea:	53                   	push   %ebx
  8037eb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037f1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8037f6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037fc:	eb 2d                	jmp    80382b <devcons_write+0x46>
		m = n - tot;
  8037fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803801:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  803803:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  803806:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80380b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80380e:	83 ec 04             	sub    $0x4,%esp
  803811:	53                   	push   %ebx
  803812:	03 45 0c             	add    0xc(%ebp),%eax
  803815:	50                   	push   %eax
  803816:	57                   	push   %edi
  803817:	e8 7b e9 ff ff       	call   802197 <memmove>
		sys_cputs(buf, m);
  80381c:	83 c4 08             	add    $0x8,%esp
  80381f:	53                   	push   %ebx
  803820:	57                   	push   %edi
  803821:	e8 26 eb ff ff       	call   80234c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803826:	01 de                	add    %ebx,%esi
  803828:	83 c4 10             	add    $0x10,%esp
  80382b:	89 f0                	mov    %esi,%eax
  80382d:	3b 75 10             	cmp    0x10(%ebp),%esi
  803830:	72 cc                	jb     8037fe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803832:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803835:	5b                   	pop    %ebx
  803836:	5e                   	pop    %esi
  803837:	5f                   	pop    %edi
  803838:	5d                   	pop    %ebp
  803839:	c3                   	ret    

0080383a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80383a:	55                   	push   %ebp
  80383b:	89 e5                	mov    %esp,%ebp
  80383d:	83 ec 08             	sub    $0x8,%esp
  803840:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803845:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803849:	74 2a                	je     803875 <devcons_read+0x3b>
  80384b:	eb 05                	jmp    803852 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80384d:	e8 97 eb ff ff       	call   8023e9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803852:	e8 13 eb ff ff       	call   80236a <sys_cgetc>
  803857:	85 c0                	test   %eax,%eax
  803859:	74 f2                	je     80384d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80385b:	85 c0                	test   %eax,%eax
  80385d:	78 16                	js     803875 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80385f:	83 f8 04             	cmp    $0x4,%eax
  803862:	74 0c                	je     803870 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803864:	8b 55 0c             	mov    0xc(%ebp),%edx
  803867:	88 02                	mov    %al,(%edx)
	return 1;
  803869:	b8 01 00 00 00       	mov    $0x1,%eax
  80386e:	eb 05                	jmp    803875 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803870:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803875:	c9                   	leave  
  803876:	c3                   	ret    

00803877 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803877:	55                   	push   %ebp
  803878:	89 e5                	mov    %esp,%ebp
  80387a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80387d:	8b 45 08             	mov    0x8(%ebp),%eax
  803880:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803883:	6a 01                	push   $0x1
  803885:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803888:	50                   	push   %eax
  803889:	e8 be ea ff ff       	call   80234c <sys_cputs>
}
  80388e:	83 c4 10             	add    $0x10,%esp
  803891:	c9                   	leave  
  803892:	c3                   	ret    

00803893 <getchar>:

int
getchar(void)
{
  803893:	55                   	push   %ebp
  803894:	89 e5                	mov    %esp,%ebp
  803896:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803899:	6a 01                	push   $0x1
  80389b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80389e:	50                   	push   %eax
  80389f:	6a 00                	push   $0x0
  8038a1:	e8 e2 f1 ff ff       	call   802a88 <read>
	if (r < 0)
  8038a6:	83 c4 10             	add    $0x10,%esp
  8038a9:	85 c0                	test   %eax,%eax
  8038ab:	78 0f                	js     8038bc <getchar+0x29>
		return r;
	if (r < 1)
  8038ad:	85 c0                	test   %eax,%eax
  8038af:	7e 06                	jle    8038b7 <getchar+0x24>
		return -E_EOF;
	return c;
  8038b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8038b5:	eb 05                	jmp    8038bc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8038b7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8038bc:	c9                   	leave  
  8038bd:	c3                   	ret    

008038be <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8038be:	55                   	push   %ebp
  8038bf:	89 e5                	mov    %esp,%ebp
  8038c1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8038c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038c7:	50                   	push   %eax
  8038c8:	ff 75 08             	pushl  0x8(%ebp)
  8038cb:	e8 52 ef ff ff       	call   802822 <fd_lookup>
  8038d0:	83 c4 10             	add    $0x10,%esp
  8038d3:	85 c0                	test   %eax,%eax
  8038d5:	78 11                	js     8038e8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8038d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038da:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  8038e0:	39 10                	cmp    %edx,(%eax)
  8038e2:	0f 94 c0             	sete   %al
  8038e5:	0f b6 c0             	movzbl %al,%eax
}
  8038e8:	c9                   	leave  
  8038e9:	c3                   	ret    

008038ea <opencons>:

int
opencons(void)
{
  8038ea:	55                   	push   %ebp
  8038eb:	89 e5                	mov    %esp,%ebp
  8038ed:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038f3:	50                   	push   %eax
  8038f4:	e8 da ee ff ff       	call   8027d3 <fd_alloc>
  8038f9:	83 c4 10             	add    $0x10,%esp
		return r;
  8038fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038fe:	85 c0                	test   %eax,%eax
  803900:	78 3e                	js     803940 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803902:	83 ec 04             	sub    $0x4,%esp
  803905:	68 07 04 00 00       	push   $0x407
  80390a:	ff 75 f4             	pushl  -0xc(%ebp)
  80390d:	6a 00                	push   $0x0
  80390f:	e8 f4 ea ff ff       	call   802408 <sys_page_alloc>
  803914:	83 c4 10             	add    $0x10,%esp
		return r;
  803917:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803919:	85 c0                	test   %eax,%eax
  80391b:	78 23                	js     803940 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80391d:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803926:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803928:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80392b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803932:	83 ec 0c             	sub    $0xc,%esp
  803935:	50                   	push   %eax
  803936:	e8 71 ee ff ff       	call   8027ac <fd2num>
  80393b:	89 c2                	mov    %eax,%edx
  80393d:	83 c4 10             	add    $0x10,%esp
}
  803940:	89 d0                	mov    %edx,%eax
  803942:	c9                   	leave  
  803943:	c3                   	ret    
  803944:	66 90                	xchg   %ax,%ax
  803946:	66 90                	xchg   %ax,%ax
  803948:	66 90                	xchg   %ax,%ax
  80394a:	66 90                	xchg   %ax,%ax
  80394c:	66 90                	xchg   %ax,%ax
  80394e:	66 90                	xchg   %ax,%ax

00803950 <__udivdi3>:
  803950:	55                   	push   %ebp
  803951:	57                   	push   %edi
  803952:	56                   	push   %esi
  803953:	53                   	push   %ebx
  803954:	83 ec 1c             	sub    $0x1c,%esp
  803957:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80395b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80395f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803963:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803967:	85 f6                	test   %esi,%esi
  803969:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80396d:	89 ca                	mov    %ecx,%edx
  80396f:	89 f8                	mov    %edi,%eax
  803971:	75 3d                	jne    8039b0 <__udivdi3+0x60>
  803973:	39 cf                	cmp    %ecx,%edi
  803975:	0f 87 c5 00 00 00    	ja     803a40 <__udivdi3+0xf0>
  80397b:	85 ff                	test   %edi,%edi
  80397d:	89 fd                	mov    %edi,%ebp
  80397f:	75 0b                	jne    80398c <__udivdi3+0x3c>
  803981:	b8 01 00 00 00       	mov    $0x1,%eax
  803986:	31 d2                	xor    %edx,%edx
  803988:	f7 f7                	div    %edi
  80398a:	89 c5                	mov    %eax,%ebp
  80398c:	89 c8                	mov    %ecx,%eax
  80398e:	31 d2                	xor    %edx,%edx
  803990:	f7 f5                	div    %ebp
  803992:	89 c1                	mov    %eax,%ecx
  803994:	89 d8                	mov    %ebx,%eax
  803996:	89 cf                	mov    %ecx,%edi
  803998:	f7 f5                	div    %ebp
  80399a:	89 c3                	mov    %eax,%ebx
  80399c:	89 d8                	mov    %ebx,%eax
  80399e:	89 fa                	mov    %edi,%edx
  8039a0:	83 c4 1c             	add    $0x1c,%esp
  8039a3:	5b                   	pop    %ebx
  8039a4:	5e                   	pop    %esi
  8039a5:	5f                   	pop    %edi
  8039a6:	5d                   	pop    %ebp
  8039a7:	c3                   	ret    
  8039a8:	90                   	nop
  8039a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8039b0:	39 ce                	cmp    %ecx,%esi
  8039b2:	77 74                	ja     803a28 <__udivdi3+0xd8>
  8039b4:	0f bd fe             	bsr    %esi,%edi
  8039b7:	83 f7 1f             	xor    $0x1f,%edi
  8039ba:	0f 84 98 00 00 00    	je     803a58 <__udivdi3+0x108>
  8039c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8039c5:	89 f9                	mov    %edi,%ecx
  8039c7:	89 c5                	mov    %eax,%ebp
  8039c9:	29 fb                	sub    %edi,%ebx
  8039cb:	d3 e6                	shl    %cl,%esi
  8039cd:	89 d9                	mov    %ebx,%ecx
  8039cf:	d3 ed                	shr    %cl,%ebp
  8039d1:	89 f9                	mov    %edi,%ecx
  8039d3:	d3 e0                	shl    %cl,%eax
  8039d5:	09 ee                	or     %ebp,%esi
  8039d7:	89 d9                	mov    %ebx,%ecx
  8039d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8039dd:	89 d5                	mov    %edx,%ebp
  8039df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8039e3:	d3 ed                	shr    %cl,%ebp
  8039e5:	89 f9                	mov    %edi,%ecx
  8039e7:	d3 e2                	shl    %cl,%edx
  8039e9:	89 d9                	mov    %ebx,%ecx
  8039eb:	d3 e8                	shr    %cl,%eax
  8039ed:	09 c2                	or     %eax,%edx
  8039ef:	89 d0                	mov    %edx,%eax
  8039f1:	89 ea                	mov    %ebp,%edx
  8039f3:	f7 f6                	div    %esi
  8039f5:	89 d5                	mov    %edx,%ebp
  8039f7:	89 c3                	mov    %eax,%ebx
  8039f9:	f7 64 24 0c          	mull   0xc(%esp)
  8039fd:	39 d5                	cmp    %edx,%ebp
  8039ff:	72 10                	jb     803a11 <__udivdi3+0xc1>
  803a01:	8b 74 24 08          	mov    0x8(%esp),%esi
  803a05:	89 f9                	mov    %edi,%ecx
  803a07:	d3 e6                	shl    %cl,%esi
  803a09:	39 c6                	cmp    %eax,%esi
  803a0b:	73 07                	jae    803a14 <__udivdi3+0xc4>
  803a0d:	39 d5                	cmp    %edx,%ebp
  803a0f:	75 03                	jne    803a14 <__udivdi3+0xc4>
  803a11:	83 eb 01             	sub    $0x1,%ebx
  803a14:	31 ff                	xor    %edi,%edi
  803a16:	89 d8                	mov    %ebx,%eax
  803a18:	89 fa                	mov    %edi,%edx
  803a1a:	83 c4 1c             	add    $0x1c,%esp
  803a1d:	5b                   	pop    %ebx
  803a1e:	5e                   	pop    %esi
  803a1f:	5f                   	pop    %edi
  803a20:	5d                   	pop    %ebp
  803a21:	c3                   	ret    
  803a22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803a28:	31 ff                	xor    %edi,%edi
  803a2a:	31 db                	xor    %ebx,%ebx
  803a2c:	89 d8                	mov    %ebx,%eax
  803a2e:	89 fa                	mov    %edi,%edx
  803a30:	83 c4 1c             	add    $0x1c,%esp
  803a33:	5b                   	pop    %ebx
  803a34:	5e                   	pop    %esi
  803a35:	5f                   	pop    %edi
  803a36:	5d                   	pop    %ebp
  803a37:	c3                   	ret    
  803a38:	90                   	nop
  803a39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a40:	89 d8                	mov    %ebx,%eax
  803a42:	f7 f7                	div    %edi
  803a44:	31 ff                	xor    %edi,%edi
  803a46:	89 c3                	mov    %eax,%ebx
  803a48:	89 d8                	mov    %ebx,%eax
  803a4a:	89 fa                	mov    %edi,%edx
  803a4c:	83 c4 1c             	add    $0x1c,%esp
  803a4f:	5b                   	pop    %ebx
  803a50:	5e                   	pop    %esi
  803a51:	5f                   	pop    %edi
  803a52:	5d                   	pop    %ebp
  803a53:	c3                   	ret    
  803a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a58:	39 ce                	cmp    %ecx,%esi
  803a5a:	72 0c                	jb     803a68 <__udivdi3+0x118>
  803a5c:	31 db                	xor    %ebx,%ebx
  803a5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803a62:	0f 87 34 ff ff ff    	ja     80399c <__udivdi3+0x4c>
  803a68:	bb 01 00 00 00       	mov    $0x1,%ebx
  803a6d:	e9 2a ff ff ff       	jmp    80399c <__udivdi3+0x4c>
  803a72:	66 90                	xchg   %ax,%ax
  803a74:	66 90                	xchg   %ax,%ax
  803a76:	66 90                	xchg   %ax,%ax
  803a78:	66 90                	xchg   %ax,%ax
  803a7a:	66 90                	xchg   %ax,%ax
  803a7c:	66 90                	xchg   %ax,%ax
  803a7e:	66 90                	xchg   %ax,%ax

00803a80 <__umoddi3>:
  803a80:	55                   	push   %ebp
  803a81:	57                   	push   %edi
  803a82:	56                   	push   %esi
  803a83:	53                   	push   %ebx
  803a84:	83 ec 1c             	sub    $0x1c,%esp
  803a87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803a8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803a8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803a93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803a97:	85 d2                	test   %edx,%edx
  803a99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803aa1:	89 f3                	mov    %esi,%ebx
  803aa3:	89 3c 24             	mov    %edi,(%esp)
  803aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  803aaa:	75 1c                	jne    803ac8 <__umoddi3+0x48>
  803aac:	39 f7                	cmp    %esi,%edi
  803aae:	76 50                	jbe    803b00 <__umoddi3+0x80>
  803ab0:	89 c8                	mov    %ecx,%eax
  803ab2:	89 f2                	mov    %esi,%edx
  803ab4:	f7 f7                	div    %edi
  803ab6:	89 d0                	mov    %edx,%eax
  803ab8:	31 d2                	xor    %edx,%edx
  803aba:	83 c4 1c             	add    $0x1c,%esp
  803abd:	5b                   	pop    %ebx
  803abe:	5e                   	pop    %esi
  803abf:	5f                   	pop    %edi
  803ac0:	5d                   	pop    %ebp
  803ac1:	c3                   	ret    
  803ac2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ac8:	39 f2                	cmp    %esi,%edx
  803aca:	89 d0                	mov    %edx,%eax
  803acc:	77 52                	ja     803b20 <__umoddi3+0xa0>
  803ace:	0f bd ea             	bsr    %edx,%ebp
  803ad1:	83 f5 1f             	xor    $0x1f,%ebp
  803ad4:	75 5a                	jne    803b30 <__umoddi3+0xb0>
  803ad6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803ada:	0f 82 e0 00 00 00    	jb     803bc0 <__umoddi3+0x140>
  803ae0:	39 0c 24             	cmp    %ecx,(%esp)
  803ae3:	0f 86 d7 00 00 00    	jbe    803bc0 <__umoddi3+0x140>
  803ae9:	8b 44 24 08          	mov    0x8(%esp),%eax
  803aed:	8b 54 24 04          	mov    0x4(%esp),%edx
  803af1:	83 c4 1c             	add    $0x1c,%esp
  803af4:	5b                   	pop    %ebx
  803af5:	5e                   	pop    %esi
  803af6:	5f                   	pop    %edi
  803af7:	5d                   	pop    %ebp
  803af8:	c3                   	ret    
  803af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803b00:	85 ff                	test   %edi,%edi
  803b02:	89 fd                	mov    %edi,%ebp
  803b04:	75 0b                	jne    803b11 <__umoddi3+0x91>
  803b06:	b8 01 00 00 00       	mov    $0x1,%eax
  803b0b:	31 d2                	xor    %edx,%edx
  803b0d:	f7 f7                	div    %edi
  803b0f:	89 c5                	mov    %eax,%ebp
  803b11:	89 f0                	mov    %esi,%eax
  803b13:	31 d2                	xor    %edx,%edx
  803b15:	f7 f5                	div    %ebp
  803b17:	89 c8                	mov    %ecx,%eax
  803b19:	f7 f5                	div    %ebp
  803b1b:	89 d0                	mov    %edx,%eax
  803b1d:	eb 99                	jmp    803ab8 <__umoddi3+0x38>
  803b1f:	90                   	nop
  803b20:	89 c8                	mov    %ecx,%eax
  803b22:	89 f2                	mov    %esi,%edx
  803b24:	83 c4 1c             	add    $0x1c,%esp
  803b27:	5b                   	pop    %ebx
  803b28:	5e                   	pop    %esi
  803b29:	5f                   	pop    %edi
  803b2a:	5d                   	pop    %ebp
  803b2b:	c3                   	ret    
  803b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b30:	8b 34 24             	mov    (%esp),%esi
  803b33:	bf 20 00 00 00       	mov    $0x20,%edi
  803b38:	89 e9                	mov    %ebp,%ecx
  803b3a:	29 ef                	sub    %ebp,%edi
  803b3c:	d3 e0                	shl    %cl,%eax
  803b3e:	89 f9                	mov    %edi,%ecx
  803b40:	89 f2                	mov    %esi,%edx
  803b42:	d3 ea                	shr    %cl,%edx
  803b44:	89 e9                	mov    %ebp,%ecx
  803b46:	09 c2                	or     %eax,%edx
  803b48:	89 d8                	mov    %ebx,%eax
  803b4a:	89 14 24             	mov    %edx,(%esp)
  803b4d:	89 f2                	mov    %esi,%edx
  803b4f:	d3 e2                	shl    %cl,%edx
  803b51:	89 f9                	mov    %edi,%ecx
  803b53:	89 54 24 04          	mov    %edx,0x4(%esp)
  803b57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803b5b:	d3 e8                	shr    %cl,%eax
  803b5d:	89 e9                	mov    %ebp,%ecx
  803b5f:	89 c6                	mov    %eax,%esi
  803b61:	d3 e3                	shl    %cl,%ebx
  803b63:	89 f9                	mov    %edi,%ecx
  803b65:	89 d0                	mov    %edx,%eax
  803b67:	d3 e8                	shr    %cl,%eax
  803b69:	89 e9                	mov    %ebp,%ecx
  803b6b:	09 d8                	or     %ebx,%eax
  803b6d:	89 d3                	mov    %edx,%ebx
  803b6f:	89 f2                	mov    %esi,%edx
  803b71:	f7 34 24             	divl   (%esp)
  803b74:	89 d6                	mov    %edx,%esi
  803b76:	d3 e3                	shl    %cl,%ebx
  803b78:	f7 64 24 04          	mull   0x4(%esp)
  803b7c:	39 d6                	cmp    %edx,%esi
  803b7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803b82:	89 d1                	mov    %edx,%ecx
  803b84:	89 c3                	mov    %eax,%ebx
  803b86:	72 08                	jb     803b90 <__umoddi3+0x110>
  803b88:	75 11                	jne    803b9b <__umoddi3+0x11b>
  803b8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803b8e:	73 0b                	jae    803b9b <__umoddi3+0x11b>
  803b90:	2b 44 24 04          	sub    0x4(%esp),%eax
  803b94:	1b 14 24             	sbb    (%esp),%edx
  803b97:	89 d1                	mov    %edx,%ecx
  803b99:	89 c3                	mov    %eax,%ebx
  803b9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803b9f:	29 da                	sub    %ebx,%edx
  803ba1:	19 ce                	sbb    %ecx,%esi
  803ba3:	89 f9                	mov    %edi,%ecx
  803ba5:	89 f0                	mov    %esi,%eax
  803ba7:	d3 e0                	shl    %cl,%eax
  803ba9:	89 e9                	mov    %ebp,%ecx
  803bab:	d3 ea                	shr    %cl,%edx
  803bad:	89 e9                	mov    %ebp,%ecx
  803baf:	d3 ee                	shr    %cl,%esi
  803bb1:	09 d0                	or     %edx,%eax
  803bb3:	89 f2                	mov    %esi,%edx
  803bb5:	83 c4 1c             	add    $0x1c,%esp
  803bb8:	5b                   	pop    %ebx
  803bb9:	5e                   	pop    %esi
  803bba:	5f                   	pop    %edi
  803bbb:	5d                   	pop    %ebp
  803bbc:	c3                   	ret    
  803bbd:	8d 76 00             	lea    0x0(%esi),%esi
  803bc0:	29 f9                	sub    %edi,%ecx
  803bc2:	19 d6                	sbb    %edx,%esi
  803bc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  803bc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803bcc:	e9 18 ff ff ff       	jmp    803ae9 <__umoddi3+0x69>
