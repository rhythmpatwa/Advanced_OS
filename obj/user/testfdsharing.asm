
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 e0 27 80 00       	push   $0x8027e0
  800043:	e8 00 19 00 00       	call   801948 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 e5 27 80 00       	push   $0x8027e5
  800057:	6a 0c                	push   $0xc
  800059:	68 f3 27 80 00       	push   $0x8027f3
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 a9 15 00 00       	call   801617 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 c1 14 00 00       	call   801542 <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 08 28 80 00       	push   $0x802808
  800090:	6a 0f                	push   $0xf
  800092:	68 f3 27 80 00       	push   $0x8027f3
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 fc 0e 00 00       	call   800f9d <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 12 28 80 00       	push   $0x802812
  8000ad:	6a 12                	push   $0x12
  8000af:	68 f3 27 80 00       	push   $0x8027f3
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 4b 15 00 00       	call   801617 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 57 14 00 00       	call   801542 <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 94 28 80 00       	push   $0x802894
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 f3 27 80 00       	push   $0x8027f3
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 88 09 00 00       	call   800aa3 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 c0 28 80 00       	push   $0x8028c0
  80012a:	6a 19                	push   $0x19
  80012c:	68 f3 27 80 00       	push   $0x8027f3
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 1b 28 80 00       	push   $0x80281b
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 c9 14 00 00       	call   801617 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 1f 12 00 00       	call   801375 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 e1 1b 00 00       	call   801d48 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 c8 13 00 00       	call   801542 <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 f8 28 80 00       	push   $0x8028f8
  80018b:	6a 21                	push   $0x21
  80018d:	68 f3 27 80 00       	push   $0x8027f3
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 34 28 80 00       	push   $0x802834
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 c9 11 00 00       	call   801375 <close>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8001c3:	e8 93 0a 00 00       	call   800c5b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 97 11 00 00       	call   8013a0 <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 07 0a 00 00       	call   800c1a <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 30 0a 00 00       	call   800c5b <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 28 29 80 00       	push   $0x802928
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 32 28 80 00 	movl   $0x802832,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 4f 09 00 00       	call   800bdd <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 f4 08 00 00       	call   800bdd <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 f7 21 00 00       	call   802550 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 e4 22 00 00       	call   802680 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 4b 29 80 00 	movsbl 0x80294b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 a9 03 00 00    	je     8007ed <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 3a 03 00 00    	ja     8007d2 <vprintfmt+0x3aa>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 80 2a 80 00 	jmp    *0x802a80(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 63 29 80 00       	push   $0x802963
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 ed 2d 80 00       	push   $0x802ded
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 5c 29 80 00       	mov    $0x80295c,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 a6 02 00 00       	call   800875 <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800704:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800708:	0f 89 90 00 00 00    	jns    80079e <vprintfmt+0x376>
				putch('-', putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 2d                	push   $0x2d
  800714:	ff d6                	call   *%esi
				num = -(long long) num;
  800716:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800719:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80071c:	f7 d8                	neg    %eax
  80071e:	83 d2 00             	adc    $0x0,%edx
  800721:	f7 da                	neg    %edx
  800723:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800726:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80072b:	eb 71                	jmp    80079e <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
  800730:	e8 7f fc ff ff       	call   8003b4 <getuint>
			base = 10;
  800735:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80073a:	eb 62                	jmp    80079e <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80073c:	8d 45 14             	lea    0x14(%ebp),%eax
  80073f:	e8 70 fc ff ff       	call   8003b4 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800744:	83 ec 0c             	sub    $0xc,%esp
  800747:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80074b:	51                   	push   %ecx
  80074c:	ff 75 e0             	pushl  -0x20(%ebp)
  80074f:	6a 08                	push   $0x8
  800751:	52                   	push   %edx
  800752:	50                   	push   %eax
  800753:	89 da                	mov    %ebx,%edx
  800755:	89 f0                	mov    %esi,%eax
  800757:	e8 a9 fb ff ff       	call   800305 <printnum>
			break;
  80075c:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800762:	e9 e7 fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 30                	push   $0x30
  80076d:	ff d6                	call   *%esi
			putch('x', putdat);
  80076f:	83 c4 08             	add    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 78                	push   $0x78
  800775:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 50 04             	lea    0x4(%eax),%edx
  80077d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800780:	8b 00                	mov    (%eax),%eax
  800782:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800787:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80078a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078f:	eb 0d                	jmp    80079e <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
  800794:	e8 1b fc ff ff       	call   8003b4 <getuint>
			base = 16;
  800799:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079e:	83 ec 0c             	sub    $0xc,%esp
  8007a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a5:	57                   	push   %edi
  8007a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a9:	51                   	push   %ecx
  8007aa:	52                   	push   %edx
  8007ab:	50                   	push   %eax
  8007ac:	89 da                	mov    %ebx,%edx
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	e8 50 fb ff ff       	call   800305 <printnum>
			break;
  8007b5:	83 c4 20             	add    $0x20,%esp
  8007b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bb:	e9 8e fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	51                   	push   %ecx
  8007c5:	ff d6                	call   *%esi
			break;
  8007c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cd:	e9 7c fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	53                   	push   %ebx
  8007d6:	6a 25                	push   $0x25
  8007d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb 03                	jmp    8007e2 <vprintfmt+0x3ba>
  8007df:	83 ef 01             	sub    $0x1,%edi
  8007e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e6:	75 f7                	jne    8007df <vprintfmt+0x3b7>
  8007e8:	e9 61 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 18             	sub    $0x18,%esp
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800801:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800804:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800808:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800812:	85 c0                	test   %eax,%eax
  800814:	74 26                	je     80083c <vsnprintf+0x47>
  800816:	85 d2                	test   %edx,%edx
  800818:	7e 22                	jle    80083c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081a:	ff 75 14             	pushl  0x14(%ebp)
  80081d:	ff 75 10             	pushl  0x10(%ebp)
  800820:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	68 ee 03 80 00       	push   $0x8003ee
  800829:	e8 fa fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800831:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	eb 05                	jmp    800841 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800849:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084c:	50                   	push   %eax
  80084d:	ff 75 10             	pushl  0x10(%ebp)
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	ff 75 08             	pushl  0x8(%ebp)
  800856:	e8 9a ff ff ff       	call   8007f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb 03                	jmp    80086d <strlen+0x10>
		n++;
  80086a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800871:	75 f7                	jne    80086a <strlen+0xd>
		n++;
	return n;
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087e:	ba 00 00 00 00       	mov    $0x0,%edx
  800883:	eb 03                	jmp    800888 <strnlen+0x13>
		n++;
  800885:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800888:	39 c2                	cmp    %eax,%edx
  80088a:	74 08                	je     800894 <strnlen+0x1f>
  80088c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800890:	75 f3                	jne    800885 <strnlen+0x10>
  800892:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	83 c2 01             	add    $0x1,%edx
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008af:	84 db                	test   %bl,%bl
  8008b1:	75 ef                	jne    8008a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bd:	53                   	push   %ebx
  8008be:	e8 9a ff ff ff       	call   80085d <strlen>
  8008c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c6:	ff 75 0c             	pushl  0xc(%ebp)
  8008c9:	01 d8                	add    %ebx,%eax
  8008cb:	50                   	push   %eax
  8008cc:	e8 c5 ff ff ff       	call   800896 <strcpy>
	return dst;
}
  8008d1:	89 d8                	mov    %ebx,%eax
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e3:	89 f3                	mov    %esi,%ebx
  8008e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e8:	89 f2                	mov    %esi,%edx
  8008ea:	eb 0f                	jmp    8008fb <strncpy+0x23>
		*dst++ = *src;
  8008ec:	83 c2 01             	add    $0x1,%edx
  8008ef:	0f b6 01             	movzbl (%ecx),%eax
  8008f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008fb:	39 da                	cmp    %ebx,%edx
  8008fd:	75 ed                	jne    8008ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ff:	89 f0                	mov    %esi,%eax
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 75 08             	mov    0x8(%ebp),%esi
  80090d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800910:	8b 55 10             	mov    0x10(%ebp),%edx
  800913:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800915:	85 d2                	test   %edx,%edx
  800917:	74 21                	je     80093a <strlcpy+0x35>
  800919:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091d:	89 f2                	mov    %esi,%edx
  80091f:	eb 09                	jmp    80092a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800921:	83 c2 01             	add    $0x1,%edx
  800924:	83 c1 01             	add    $0x1,%ecx
  800927:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80092a:	39 c2                	cmp    %eax,%edx
  80092c:	74 09                	je     800937 <strlcpy+0x32>
  80092e:	0f b6 19             	movzbl (%ecx),%ebx
  800931:	84 db                	test   %bl,%bl
  800933:	75 ec                	jne    800921 <strlcpy+0x1c>
  800935:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800937:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80093a:	29 f0                	sub    %esi,%eax
}
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800949:	eb 06                	jmp    800951 <strcmp+0x11>
		p++, q++;
  80094b:	83 c1 01             	add    $0x1,%ecx
  80094e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800951:	0f b6 01             	movzbl (%ecx),%eax
  800954:	84 c0                	test   %al,%al
  800956:	74 04                	je     80095c <strcmp+0x1c>
  800958:	3a 02                	cmp    (%edx),%al
  80095a:	74 ef                	je     80094b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095c:	0f b6 c0             	movzbl %al,%eax
  80095f:	0f b6 12             	movzbl (%edx),%edx
  800962:	29 d0                	sub    %edx,%eax
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800970:	89 c3                	mov    %eax,%ebx
  800972:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800975:	eb 06                	jmp    80097d <strncmp+0x17>
		n--, p++, q++;
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097d:	39 d8                	cmp    %ebx,%eax
  80097f:	74 15                	je     800996 <strncmp+0x30>
  800981:	0f b6 08             	movzbl (%eax),%ecx
  800984:	84 c9                	test   %cl,%cl
  800986:	74 04                	je     80098c <strncmp+0x26>
  800988:	3a 0a                	cmp    (%edx),%cl
  80098a:	74 eb                	je     800977 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098c:	0f b6 00             	movzbl (%eax),%eax
  80098f:	0f b6 12             	movzbl (%edx),%edx
  800992:	29 d0                	sub    %edx,%eax
  800994:	eb 05                	jmp    80099b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099b:	5b                   	pop    %ebx
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a8:	eb 07                	jmp    8009b1 <strchr+0x13>
		if (*s == c)
  8009aa:	38 ca                	cmp    %cl,%dl
  8009ac:	74 0f                	je     8009bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ae:	83 c0 01             	add    $0x1,%eax
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	84 d2                	test   %dl,%dl
  8009b6:	75 f2                	jne    8009aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c9:	eb 03                	jmp    8009ce <strfind+0xf>
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009d1:	38 ca                	cmp    %cl,%dl
  8009d3:	74 04                	je     8009d9 <strfind+0x1a>
  8009d5:	84 d2                	test   %dl,%dl
  8009d7:	75 f2                	jne    8009cb <strfind+0xc>
			break;
	return (char *) s;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	57                   	push   %edi
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e7:	85 c9                	test   %ecx,%ecx
  8009e9:	74 36                	je     800a21 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f1:	75 28                	jne    800a1b <memset+0x40>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 23                	jne    800a1b <memset+0x40>
		c &= 0xFF;
  8009f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fc:	89 d3                	mov    %edx,%ebx
  8009fe:	c1 e3 08             	shl    $0x8,%ebx
  800a01:	89 d6                	mov    %edx,%esi
  800a03:	c1 e6 18             	shl    $0x18,%esi
  800a06:	89 d0                	mov    %edx,%eax
  800a08:	c1 e0 10             	shl    $0x10,%eax
  800a0b:	09 f0                	or     %esi,%eax
  800a0d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0f:	89 d8                	mov    %ebx,%eax
  800a11:	09 d0                	or     %edx,%eax
  800a13:	c1 e9 02             	shr    $0x2,%ecx
  800a16:	fc                   	cld    
  800a17:	f3 ab                	rep stos %eax,%es:(%edi)
  800a19:	eb 06                	jmp    800a21 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1e:	fc                   	cld    
  800a1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a21:	89 f8                	mov    %edi,%eax
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5f                   	pop    %edi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a36:	39 c6                	cmp    %eax,%esi
  800a38:	73 35                	jae    800a6f <memmove+0x47>
  800a3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	73 2e                	jae    800a6f <memmove+0x47>
		s += n;
		d += n;
  800a41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a44:	89 d6                	mov    %edx,%esi
  800a46:	09 fe                	or     %edi,%esi
  800a48:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4e:	75 13                	jne    800a63 <memmove+0x3b>
  800a50:	f6 c1 03             	test   $0x3,%cl
  800a53:	75 0e                	jne    800a63 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a55:	83 ef 04             	sub    $0x4,%edi
  800a58:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
  800a5e:	fd                   	std    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a61:	eb 09                	jmp    800a6c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a63:	83 ef 01             	sub    $0x1,%edi
  800a66:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a69:	fd                   	std    
  800a6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6c:	fc                   	cld    
  800a6d:	eb 1d                	jmp    800a8c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	89 f2                	mov    %esi,%edx
  800a71:	09 c2                	or     %eax,%edx
  800a73:	f6 c2 03             	test   $0x3,%dl
  800a76:	75 0f                	jne    800a87 <memmove+0x5f>
  800a78:	f6 c1 03             	test   $0x3,%cl
  800a7b:	75 0a                	jne    800a87 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7d:	c1 e9 02             	shr    $0x2,%ecx
  800a80:	89 c7                	mov    %eax,%edi
  800a82:	fc                   	cld    
  800a83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a85:	eb 05                	jmp    800a8c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a87:	89 c7                	mov    %eax,%edi
  800a89:	fc                   	cld    
  800a8a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8c:	5e                   	pop    %esi
  800a8d:	5f                   	pop    %edi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a93:	ff 75 10             	pushl  0x10(%ebp)
  800a96:	ff 75 0c             	pushl  0xc(%ebp)
  800a99:	ff 75 08             	pushl  0x8(%ebp)
  800a9c:	e8 87 ff ff ff       	call   800a28 <memmove>
}
  800aa1:	c9                   	leave  
  800aa2:	c3                   	ret    

00800aa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aae:	89 c6                	mov    %eax,%esi
  800ab0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab3:	eb 1a                	jmp    800acf <memcmp+0x2c>
		if (*s1 != *s2)
  800ab5:	0f b6 08             	movzbl (%eax),%ecx
  800ab8:	0f b6 1a             	movzbl (%edx),%ebx
  800abb:	38 d9                	cmp    %bl,%cl
  800abd:	74 0a                	je     800ac9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abf:	0f b6 c1             	movzbl %cl,%eax
  800ac2:	0f b6 db             	movzbl %bl,%ebx
  800ac5:	29 d8                	sub    %ebx,%eax
  800ac7:	eb 0f                	jmp    800ad8 <memcmp+0x35>
		s1++, s2++;
  800ac9:	83 c0 01             	add    $0x1,%eax
  800acc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	39 f0                	cmp    %esi,%eax
  800ad1:	75 e2                	jne    800ab5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	53                   	push   %ebx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae3:	89 c1                	mov    %eax,%ecx
  800ae5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aec:	eb 0a                	jmp    800af8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aee:	0f b6 10             	movzbl (%eax),%edx
  800af1:	39 da                	cmp    %ebx,%edx
  800af3:	74 07                	je     800afc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	39 c8                	cmp    %ecx,%eax
  800afa:	72 f2                	jb     800aee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afc:	5b                   	pop    %ebx
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
  800b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0b:	eb 03                	jmp    800b10 <strtol+0x11>
		s++;
  800b0d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b10:	0f b6 01             	movzbl (%ecx),%eax
  800b13:	3c 20                	cmp    $0x20,%al
  800b15:	74 f6                	je     800b0d <strtol+0xe>
  800b17:	3c 09                	cmp    $0x9,%al
  800b19:	74 f2                	je     800b0d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b1b:	3c 2b                	cmp    $0x2b,%al
  800b1d:	75 0a                	jne    800b29 <strtol+0x2a>
		s++;
  800b1f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b22:	bf 00 00 00 00       	mov    $0x0,%edi
  800b27:	eb 11                	jmp    800b3a <strtol+0x3b>
  800b29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2e:	3c 2d                	cmp    $0x2d,%al
  800b30:	75 08                	jne    800b3a <strtol+0x3b>
		s++, neg = 1;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b40:	75 15                	jne    800b57 <strtol+0x58>
  800b42:	80 39 30             	cmpb   $0x30,(%ecx)
  800b45:	75 10                	jne    800b57 <strtol+0x58>
  800b47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4b:	75 7c                	jne    800bc9 <strtol+0xca>
		s += 2, base = 16;
  800b4d:	83 c1 02             	add    $0x2,%ecx
  800b50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b55:	eb 16                	jmp    800b6d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b57:	85 db                	test   %ebx,%ebx
  800b59:	75 12                	jne    800b6d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b60:	80 39 30             	cmpb   $0x30,(%ecx)
  800b63:	75 08                	jne    800b6d <strtol+0x6e>
		s++, base = 8;
  800b65:	83 c1 01             	add    $0x1,%ecx
  800b68:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b75:	0f b6 11             	movzbl (%ecx),%edx
  800b78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b7b:	89 f3                	mov    %esi,%ebx
  800b7d:	80 fb 09             	cmp    $0x9,%bl
  800b80:	77 08                	ja     800b8a <strtol+0x8b>
			dig = *s - '0';
  800b82:	0f be d2             	movsbl %dl,%edx
  800b85:	83 ea 30             	sub    $0x30,%edx
  800b88:	eb 22                	jmp    800bac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8d:	89 f3                	mov    %esi,%ebx
  800b8f:	80 fb 19             	cmp    $0x19,%bl
  800b92:	77 08                	ja     800b9c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b94:	0f be d2             	movsbl %dl,%edx
  800b97:	83 ea 57             	sub    $0x57,%edx
  800b9a:	eb 10                	jmp    800bac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9f:	89 f3                	mov    %esi,%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 16                	ja     800bbc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba6:	0f be d2             	movsbl %dl,%edx
  800ba9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800baf:	7d 0b                	jge    800bbc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bb1:	83 c1 01             	add    $0x1,%ecx
  800bb4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bba:	eb b9                	jmp    800b75 <strtol+0x76>

	if (endptr)
  800bbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc0:	74 0d                	je     800bcf <strtol+0xd0>
		*endptr = (char *) s;
  800bc2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc5:	89 0e                	mov    %ecx,(%esi)
  800bc7:	eb 06                	jmp    800bcf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc9:	85 db                	test   %ebx,%ebx
  800bcb:	74 98                	je     800b65 <strtol+0x66>
  800bcd:	eb 9e                	jmp    800b6d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	f7 da                	neg    %edx
  800bd3:	85 ff                	test   %edi,%edi
  800bd5:	0f 45 c2             	cmovne %edx,%eax
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
  800be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	89 c3                	mov    %eax,%ebx
  800bf0:	89 c7                	mov    %eax,%edi
  800bf2:	89 c6                	mov    %eax,%esi
  800bf4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0b:	89 d1                	mov    %edx,%ecx
  800c0d:	89 d3                	mov    %edx,%ebx
  800c0f:	89 d7                	mov    %edx,%edi
  800c11:	89 d6                	mov    %edx,%esi
  800c13:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c28:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	89 cb                	mov    %ecx,%ebx
  800c32:	89 cf                	mov    %ecx,%edi
  800c34:	89 ce                	mov    %ecx,%esi
  800c36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	7e 17                	jle    800c53 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 03                	push   $0x3
  800c42:	68 3f 2c 80 00       	push   $0x802c3f
  800c47:	6a 23                	push   $0x23
  800c49:	68 5c 2c 80 00       	push   $0x802c5c
  800c4e:	e8 c5 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	ba 00 00 00 00       	mov    $0x0,%edx
  800c66:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6b:	89 d1                	mov    %edx,%ecx
  800c6d:	89 d3                	mov    %edx,%ebx
  800c6f:	89 d7                	mov    %edx,%edi
  800c71:	89 d6                	mov    %edx,%esi
  800c73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_yield>:

void
sys_yield(void)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	be 00 00 00 00       	mov    $0x0,%esi
  800ca7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb5:	89 f7                	mov    %esi,%edi
  800cb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 04                	push   $0x4
  800cc3:	68 3f 2c 80 00       	push   $0x802c3f
  800cc8:	6a 23                	push   $0x23
  800cca:	68 5c 2c 80 00       	push   $0x802c5c
  800ccf:	e8 44 f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ced:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 05                	push   $0x5
  800d05:	68 3f 2c 80 00       	push   $0x802c3f
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 5c 2c 80 00       	push   $0x802c5c
  800d11:	e8 02 f5 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	89 df                	mov    %ebx,%edi
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7e 17                	jle    800d58 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 06                	push   $0x6
  800d47:	68 3f 2c 80 00       	push   $0x802c3f
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 5c 2c 80 00       	push   $0x802c5c
  800d53:	e8 c0 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
  800d66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	89 df                	mov    %ebx,%edi
  800d7b:	89 de                	mov    %ebx,%esi
  800d7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7e 17                	jle    800d9a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	50                   	push   %eax
  800d87:	6a 08                	push   $0x8
  800d89:	68 3f 2c 80 00       	push   $0x802c3f
  800d8e:	6a 23                	push   $0x23
  800d90:	68 5c 2c 80 00       	push   $0x802c5c
  800d95:	e8 7e f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db0:	b8 09 00 00 00       	mov    $0x9,%eax
  800db5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 df                	mov    %ebx,%edi
  800dbd:	89 de                	mov    %ebx,%esi
  800dbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	7e 17                	jle    800ddc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 09                	push   $0x9
  800dcb:	68 3f 2c 80 00       	push   $0x802c3f
  800dd0:	6a 23                	push   $0x23
  800dd2:	68 5c 2c 80 00       	push   $0x802c5c
  800dd7:	e8 3c f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ded:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	89 df                	mov    %ebx,%edi
  800dff:	89 de                	mov    %ebx,%esi
  800e01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7e 17                	jle    800e1e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	50                   	push   %eax
  800e0b:	6a 0a                	push   $0xa
  800e0d:	68 3f 2c 80 00       	push   $0x802c3f
  800e12:	6a 23                	push   $0x23
  800e14:	68 5c 2c 80 00       	push   $0x802c5c
  800e19:	e8 fa f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2c:	be 00 00 00 00       	mov    $0x0,%esi
  800e31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	89 cb                	mov    %ecx,%ebx
  800e61:	89 cf                	mov    %ecx,%edi
  800e63:	89 ce                	mov    %ecx,%esi
  800e65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e67:	85 c0                	test   %eax,%eax
  800e69:	7e 17                	jle    800e82 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	50                   	push   %eax
  800e6f:	6a 0d                	push   $0xd
  800e71:	68 3f 2c 80 00       	push   $0x802c3f
  800e76:	6a 23                	push   $0x23
  800e78:	68 5c 2c 80 00       	push   $0x802c5c
  800e7d:	e8 96 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	57                   	push   %edi
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e90:	ba 00 00 00 00       	mov    $0x0,%edx
  800e95:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9a:	89 d1                	mov    %edx,%ecx
  800e9c:	89 d3                	mov    %edx,%ebx
  800e9e:	89 d7                	mov    %edx,%edi
  800ea0:	89 d6                	mov    %edx,%esi
  800ea2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	53                   	push   %ebx
  800ead:	83 ec 04             	sub    $0x4,%esp
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800eb3:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800eb5:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800eb8:	f6 c1 02             	test   $0x2,%cl
  800ebb:	74 2e                	je     800eeb <pgfault+0x42>
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	c1 ea 16             	shr    $0x16,%edx
  800ec2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec9:	f6 c2 01             	test   $0x1,%dl
  800ecc:	74 1d                	je     800eeb <pgfault+0x42>
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	c1 ea 0c             	shr    $0xc,%edx
  800ed3:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800eda:	f6 c3 01             	test   $0x1,%bl
  800edd:	74 0c                	je     800eeb <pgfault+0x42>
  800edf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee6:	f6 c6 08             	test   $0x8,%dh
  800ee9:	75 12                	jne    800efd <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800eeb:	51                   	push   %ecx
  800eec:	68 6a 2c 80 00       	push   $0x802c6a
  800ef1:	6a 1e                	push   $0x1e
  800ef3:	68 83 2c 80 00       	push   $0x802c83
  800ef8:	e8 1b f3 ff ff       	call   800218 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800efd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f02:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	6a 07                	push   $0x7
  800f09:	68 00 f0 7f 00       	push   $0x7ff000
  800f0e:	6a 00                	push   $0x0
  800f10:	e8 84 fd ff ff       	call   800c99 <sys_page_alloc>
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	79 12                	jns    800f2e <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800f1c:	50                   	push   %eax
  800f1d:	68 8e 2c 80 00       	push   $0x802c8e
  800f22:	6a 29                	push   $0x29
  800f24:	68 83 2c 80 00       	push   $0x802c83
  800f29:	e8 ea f2 ff ff       	call   800218 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	68 00 10 00 00       	push   $0x1000
  800f36:	53                   	push   %ebx
  800f37:	68 00 f0 7f 00       	push   $0x7ff000
  800f3c:	e8 4f fb ff ff       	call   800a90 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f41:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f48:	53                   	push   %ebx
  800f49:	6a 00                	push   $0x0
  800f4b:	68 00 f0 7f 00       	push   $0x7ff000
  800f50:	6a 00                	push   $0x0
  800f52:	e8 85 fd ff ff       	call   800cdc <sys_page_map>
  800f57:	83 c4 20             	add    $0x20,%esp
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	79 12                	jns    800f70 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800f5e:	50                   	push   %eax
  800f5f:	68 a9 2c 80 00       	push   $0x802ca9
  800f64:	6a 2e                	push   $0x2e
  800f66:	68 83 2c 80 00       	push   $0x802c83
  800f6b:	e8 a8 f2 ff ff       	call   800218 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800f70:	83 ec 08             	sub    $0x8,%esp
  800f73:	68 00 f0 7f 00       	push   $0x7ff000
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 9f fd ff ff       	call   800d1e <sys_page_unmap>
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	79 12                	jns    800f98 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800f86:	50                   	push   %eax
  800f87:	68 c2 2c 80 00       	push   $0x802cc2
  800f8c:	6a 31                	push   $0x31
  800f8e:	68 83 2c 80 00       	push   $0x802c83
  800f93:	e8 80 f2 ff ff       	call   800218 <_panic>

}
  800f98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800fa6:	68 a9 0e 80 00       	push   $0x800ea9
  800fab:	e8 d1 13 00 00       	call   802381 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fb0:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb5:	cd 30                	int    $0x30
  800fb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	75 21                	jne    800fea <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc9:	e8 8d fc ff ff       	call   800c5b <sys_getenvid>
  800fce:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fd6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fdb:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	e9 c9 01 00 00       	jmp    8011b3 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800fea:	89 d8                	mov    %ebx,%eax
  800fec:	c1 e8 16             	shr    $0x16,%eax
  800fef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff6:	a8 01                	test   $0x1,%al
  800ff8:	0f 84 1b 01 00 00    	je     801119 <fork+0x17c>
  800ffe:	89 de                	mov    %ebx,%esi
  801000:	c1 ee 0c             	shr    $0xc,%esi
  801003:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100a:	a8 01                	test   $0x1,%al
  80100c:	0f 84 07 01 00 00    	je     801119 <fork+0x17c>
  801012:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801019:	a8 04                	test   $0x4,%al
  80101b:	0f 84 f8 00 00 00    	je     801119 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  801021:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801028:	f6 c4 04             	test   $0x4,%ah
  80102b:	74 3c                	je     801069 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  80102d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801034:	c1 e6 0c             	shl    $0xc,%esi
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	25 07 0e 00 00       	and    $0xe07,%eax
  80103f:	50                   	push   %eax
  801040:	56                   	push   %esi
  801041:	ff 75 e4             	pushl  -0x1c(%ebp)
  801044:	56                   	push   %esi
  801045:	6a 00                	push   $0x0
  801047:	e8 90 fc ff ff       	call   800cdc <sys_page_map>
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	0f 89 c2 00 00 00    	jns    801119 <fork+0x17c>
			panic("duppage: %e", r);
  801057:	50                   	push   %eax
  801058:	68 dd 2c 80 00       	push   $0x802cdd
  80105d:	6a 48                	push   $0x48
  80105f:	68 83 2c 80 00       	push   $0x802c83
  801064:	e8 af f1 ff ff       	call   800218 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801069:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801070:	f6 c4 08             	test   $0x8,%ah
  801073:	75 0b                	jne    801080 <fork+0xe3>
  801075:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107c:	a8 02                	test   $0x2,%al
  80107e:	74 6c                	je     8010ec <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  801080:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801087:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  80108a:	83 f8 01             	cmp    $0x1,%eax
  80108d:	19 ff                	sbb    %edi,%edi
  80108f:	83 e7 fc             	and    $0xfffffffc,%edi
  801092:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  801098:	c1 e6 0c             	shl    $0xc,%esi
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a3:	56                   	push   %esi
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 31 fc ff ff       	call   800cdc <sys_page_map>
  8010ab:	83 c4 20             	add    $0x20,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	79 12                	jns    8010c4 <fork+0x127>
			panic("duppage: %e", r);
  8010b2:	50                   	push   %eax
  8010b3:	68 dd 2c 80 00       	push   $0x802cdd
  8010b8:	6a 50                	push   $0x50
  8010ba:	68 83 2c 80 00       	push   $0x802c83
  8010bf:	e8 54 f1 ff ff       	call   800218 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	6a 00                	push   $0x0
  8010cb:	56                   	push   %esi
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 09 fc ff ff       	call   800cdc <sys_page_map>
  8010d3:	83 c4 20             	add    $0x20,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	79 3f                	jns    801119 <fork+0x17c>
			panic("duppage: %e", r);
  8010da:	50                   	push   %eax
  8010db:	68 dd 2c 80 00       	push   $0x802cdd
  8010e0:	6a 53                	push   $0x53
  8010e2:	68 83 2c 80 00       	push   $0x802c83
  8010e7:	e8 2c f1 ff ff       	call   800218 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  8010ec:	c1 e6 0c             	shl    $0xc,%esi
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	6a 05                	push   $0x5
  8010f4:	56                   	push   %esi
  8010f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f8:	56                   	push   %esi
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 dc fb ff ff       	call   800cdc <sys_page_map>
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	79 12                	jns    801119 <fork+0x17c>
			panic("duppage: %e", r);
  801107:	50                   	push   %eax
  801108:	68 dd 2c 80 00       	push   $0x802cdd
  80110d:	6a 57                	push   $0x57
  80110f:	68 83 2c 80 00       	push   $0x802c83
  801114:	e8 ff f0 ff ff       	call   800218 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801119:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80111f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801125:	0f 85 bf fe ff ff    	jne    800fea <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80112b:	83 ec 04             	sub    $0x4,%esp
  80112e:	6a 07                	push   $0x7
  801130:	68 00 f0 bf ee       	push   $0xeebff000
  801135:	ff 75 e0             	pushl  -0x20(%ebp)
  801138:	e8 5c fb ff ff       	call   800c99 <sys_page_alloc>
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	74 17                	je     80115b <fork+0x1be>
		panic("sys_page_alloc Error");
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	68 e9 2c 80 00       	push   $0x802ce9
  80114c:	68 83 00 00 00       	push   $0x83
  801151:	68 83 2c 80 00       	push   $0x802c83
  801156:	e8 bd f0 ff ff       	call   800218 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	68 f0 23 80 00       	push   $0x8023f0
  801163:	ff 75 e0             	pushl  -0x20(%ebp)
  801166:	e8 79 fc ff ff       	call   800de4 <sys_env_set_pgfault_upcall>
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	85 c0                	test   %eax,%eax
  801170:	79 15                	jns    801187 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801172:	50                   	push   %eax
  801173:	68 fe 2c 80 00       	push   $0x802cfe
  801178:	68 86 00 00 00       	push   $0x86
  80117d:	68 83 2c 80 00       	push   $0x802c83
  801182:	e8 91 f0 ff ff       	call   800218 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	6a 02                	push   $0x2
  80118c:	ff 75 e0             	pushl  -0x20(%ebp)
  80118f:	e8 cc fb ff ff       	call   800d60 <sys_env_set_status>
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	85 c0                	test   %eax,%eax
  801199:	79 15                	jns    8011b0 <fork+0x213>
		panic("fork set status: %e", r);
  80119b:	50                   	push   %eax
  80119c:	68 16 2d 80 00       	push   $0x802d16
  8011a1:	68 89 00 00 00       	push   $0x89
  8011a6:	68 83 2c 80 00       	push   $0x802c83
  8011ab:	e8 68 f0 ff ff       	call   800218 <_panic>
	
	return envid;
  8011b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <sfork>:


// Challenge!
int
sfork(void)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c1:	68 2a 2d 80 00       	push   $0x802d2a
  8011c6:	68 93 00 00 00       	push   $0x93
  8011cb:	68 83 2c 80 00       	push   $0x802c83
  8011d0:	e8 43 f0 ff ff       	call   800218 <_panic>

008011d5 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011db:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e0:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011eb:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801202:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 ea 16             	shr    $0x16,%edx
  80120c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801213:	f6 c2 01             	test   $0x1,%dl
  801216:	74 11                	je     801229 <fd_alloc+0x2d>
  801218:	89 c2                	mov    %eax,%edx
  80121a:	c1 ea 0c             	shr    $0xc,%edx
  80121d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801224:	f6 c2 01             	test   $0x1,%dl
  801227:	75 09                	jne    801232 <fd_alloc+0x36>
			*fd_store = fd;
  801229:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
  801230:	eb 17                	jmp    801249 <fd_alloc+0x4d>
  801232:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801237:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123c:	75 c9                	jne    801207 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801244:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801251:	83 f8 1f             	cmp    $0x1f,%eax
  801254:	77 36                	ja     80128c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801256:	c1 e0 0c             	shl    $0xc,%eax
  801259:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125e:	89 c2                	mov    %eax,%edx
  801260:	c1 ea 16             	shr    $0x16,%edx
  801263:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126a:	f6 c2 01             	test   $0x1,%dl
  80126d:	74 24                	je     801293 <fd_lookup+0x48>
  80126f:	89 c2                	mov    %eax,%edx
  801271:	c1 ea 0c             	shr    $0xc,%edx
  801274:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127b:	f6 c2 01             	test   $0x1,%dl
  80127e:	74 1a                	je     80129a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801280:	8b 55 0c             	mov    0xc(%ebp),%edx
  801283:	89 02                	mov    %eax,(%edx)
	return 0;
  801285:	b8 00 00 00 00       	mov    $0x0,%eax
  80128a:	eb 13                	jmp    80129f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801291:	eb 0c                	jmp    80129f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801293:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801298:	eb 05                	jmp    80129f <fd_lookup+0x54>
  80129a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012aa:	ba c0 2d 80 00       	mov    $0x802dc0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012af:	eb 13                	jmp    8012c4 <dev_lookup+0x23>
  8012b1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b4:	39 08                	cmp    %ecx,(%eax)
  8012b6:	75 0c                	jne    8012c4 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012bb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c2:	eb 2e                	jmp    8012f2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c4:	8b 02                	mov    (%edx),%eax
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	75 e7                	jne    8012b1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ca:	a1 20 44 80 00       	mov    0x804420,%eax
  8012cf:	8b 40 48             	mov    0x48(%eax),%eax
  8012d2:	83 ec 04             	sub    $0x4,%esp
  8012d5:	51                   	push   %ecx
  8012d6:	50                   	push   %eax
  8012d7:	68 40 2d 80 00       	push   $0x802d40
  8012dc:	e8 10 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  8012e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f2:	c9                   	leave  
  8012f3:	c3                   	ret    

008012f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 10             	sub    $0x10,%esp
  8012fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801302:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801305:	50                   	push   %eax
  801306:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130c:	c1 e8 0c             	shr    $0xc,%eax
  80130f:	50                   	push   %eax
  801310:	e8 36 ff ff ff       	call   80124b <fd_lookup>
  801315:	83 c4 08             	add    $0x8,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 05                	js     801321 <fd_close+0x2d>
	    || fd != fd2)
  80131c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131f:	74 0c                	je     80132d <fd_close+0x39>
		return (must_exist ? r : 0);
  801321:	84 db                	test   %bl,%bl
  801323:	ba 00 00 00 00       	mov    $0x0,%edx
  801328:	0f 44 c2             	cmove  %edx,%eax
  80132b:	eb 41                	jmp    80136e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801333:	50                   	push   %eax
  801334:	ff 36                	pushl  (%esi)
  801336:	e8 66 ff ff ff       	call   8012a1 <dev_lookup>
  80133b:	89 c3                	mov    %eax,%ebx
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	85 c0                	test   %eax,%eax
  801342:	78 1a                	js     80135e <fd_close+0x6a>
		if (dev->dev_close)
  801344:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801347:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80134a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134f:	85 c0                	test   %eax,%eax
  801351:	74 0b                	je     80135e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	56                   	push   %esi
  801357:	ff d0                	call   *%eax
  801359:	89 c3                	mov    %eax,%ebx
  80135b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	56                   	push   %esi
  801362:	6a 00                	push   $0x0
  801364:	e8 b5 f9 ff ff       	call   800d1e <sys_page_unmap>
	return r;
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	89 d8                	mov    %ebx,%eax
}
  80136e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	ff 75 08             	pushl  0x8(%ebp)
  801382:	e8 c4 fe ff ff       	call   80124b <fd_lookup>
  801387:	83 c4 08             	add    $0x8,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 10                	js     80139e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138e:	83 ec 08             	sub    $0x8,%esp
  801391:	6a 01                	push   $0x1
  801393:	ff 75 f4             	pushl  -0xc(%ebp)
  801396:	e8 59 ff ff ff       	call   8012f4 <fd_close>
  80139b:	83 c4 10             	add    $0x10,%esp
}
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <close_all>:

void
close_all(void)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	53                   	push   %ebx
  8013a4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	53                   	push   %ebx
  8013b0:	e8 c0 ff ff ff       	call   801375 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b5:	83 c3 01             	add    $0x1,%ebx
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	83 fb 20             	cmp    $0x20,%ebx
  8013be:	75 ec                	jne    8013ac <close_all+0xc>
		close(i);
}
  8013c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	57                   	push   %edi
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 2c             	sub    $0x2c,%esp
  8013ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	ff 75 08             	pushl  0x8(%ebp)
  8013d8:	e8 6e fe ff ff       	call   80124b <fd_lookup>
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	0f 88 c1 00 00 00    	js     8014a9 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e8:	83 ec 0c             	sub    $0xc,%esp
  8013eb:	56                   	push   %esi
  8013ec:	e8 84 ff ff ff       	call   801375 <close>

	newfd = INDEX2FD(newfdnum);
  8013f1:	89 f3                	mov    %esi,%ebx
  8013f3:	c1 e3 0c             	shl    $0xc,%ebx
  8013f6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013fc:	83 c4 04             	add    $0x4,%esp
  8013ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801402:	e8 de fd ff ff       	call   8011e5 <fd2data>
  801407:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801409:	89 1c 24             	mov    %ebx,(%esp)
  80140c:	e8 d4 fd ff ff       	call   8011e5 <fd2data>
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801417:	89 f8                	mov    %edi,%eax
  801419:	c1 e8 16             	shr    $0x16,%eax
  80141c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801423:	a8 01                	test   $0x1,%al
  801425:	74 37                	je     80145e <dup+0x99>
  801427:	89 f8                	mov    %edi,%eax
  801429:	c1 e8 0c             	shr    $0xc,%eax
  80142c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801433:	f6 c2 01             	test   $0x1,%dl
  801436:	74 26                	je     80145e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801438:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143f:	83 ec 0c             	sub    $0xc,%esp
  801442:	25 07 0e 00 00       	and    $0xe07,%eax
  801447:	50                   	push   %eax
  801448:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144b:	6a 00                	push   $0x0
  80144d:	57                   	push   %edi
  80144e:	6a 00                	push   $0x0
  801450:	e8 87 f8 ff ff       	call   800cdc <sys_page_map>
  801455:	89 c7                	mov    %eax,%edi
  801457:	83 c4 20             	add    $0x20,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 2e                	js     80148c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801461:	89 d0                	mov    %edx,%eax
  801463:	c1 e8 0c             	shr    $0xc,%eax
  801466:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	25 07 0e 00 00       	and    $0xe07,%eax
  801475:	50                   	push   %eax
  801476:	53                   	push   %ebx
  801477:	6a 00                	push   $0x0
  801479:	52                   	push   %edx
  80147a:	6a 00                	push   $0x0
  80147c:	e8 5b f8 ff ff       	call   800cdc <sys_page_map>
  801481:	89 c7                	mov    %eax,%edi
  801483:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801486:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801488:	85 ff                	test   %edi,%edi
  80148a:	79 1d                	jns    8014a9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	53                   	push   %ebx
  801490:	6a 00                	push   $0x0
  801492:	e8 87 f8 ff ff       	call   800d1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801497:	83 c4 08             	add    $0x8,%esp
  80149a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149d:	6a 00                	push   $0x0
  80149f:	e8 7a f8 ff ff       	call   800d1e <sys_page_unmap>
	return r;
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	89 f8                	mov    %edi,%eax
}
  8014a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5f                   	pop    %edi
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 14             	sub    $0x14,%esp
  8014b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	53                   	push   %ebx
  8014c0:	e8 86 fd ff ff       	call   80124b <fd_lookup>
  8014c5:	83 c4 08             	add    $0x8,%esp
  8014c8:	89 c2                	mov    %eax,%edx
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 6d                	js     80153b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d8:	ff 30                	pushl  (%eax)
  8014da:	e8 c2 fd ff ff       	call   8012a1 <dev_lookup>
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 4c                	js     801532 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e9:	8b 42 08             	mov    0x8(%edx),%eax
  8014ec:	83 e0 03             	and    $0x3,%eax
  8014ef:	83 f8 01             	cmp    $0x1,%eax
  8014f2:	75 21                	jne    801515 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f4:	a1 20 44 80 00       	mov    0x804420,%eax
  8014f9:	8b 40 48             	mov    0x48(%eax),%eax
  8014fc:	83 ec 04             	sub    $0x4,%esp
  8014ff:	53                   	push   %ebx
  801500:	50                   	push   %eax
  801501:	68 84 2d 80 00       	push   $0x802d84
  801506:	e8 e6 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801513:	eb 26                	jmp    80153b <read+0x8a>
	}
	if (!dev->dev_read)
  801515:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801518:	8b 40 08             	mov    0x8(%eax),%eax
  80151b:	85 c0                	test   %eax,%eax
  80151d:	74 17                	je     801536 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151f:	83 ec 04             	sub    $0x4,%esp
  801522:	ff 75 10             	pushl  0x10(%ebp)
  801525:	ff 75 0c             	pushl  0xc(%ebp)
  801528:	52                   	push   %edx
  801529:	ff d0                	call   *%eax
  80152b:	89 c2                	mov    %eax,%edx
  80152d:	83 c4 10             	add    $0x10,%esp
  801530:	eb 09                	jmp    80153b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	89 c2                	mov    %eax,%edx
  801534:	eb 05                	jmp    80153b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801536:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80153b:	89 d0                	mov    %edx,%eax
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	57                   	push   %edi
  801546:	56                   	push   %esi
  801547:	53                   	push   %ebx
  801548:	83 ec 0c             	sub    $0xc,%esp
  80154b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801551:	bb 00 00 00 00       	mov    $0x0,%ebx
  801556:	eb 21                	jmp    801579 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801558:	83 ec 04             	sub    $0x4,%esp
  80155b:	89 f0                	mov    %esi,%eax
  80155d:	29 d8                	sub    %ebx,%eax
  80155f:	50                   	push   %eax
  801560:	89 d8                	mov    %ebx,%eax
  801562:	03 45 0c             	add    0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	57                   	push   %edi
  801567:	e8 45 ff ff ff       	call   8014b1 <read>
		if (m < 0)
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	85 c0                	test   %eax,%eax
  801571:	78 10                	js     801583 <readn+0x41>
			return m;
		if (m == 0)
  801573:	85 c0                	test   %eax,%eax
  801575:	74 0a                	je     801581 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801577:	01 c3                	add    %eax,%ebx
  801579:	39 f3                	cmp    %esi,%ebx
  80157b:	72 db                	jb     801558 <readn+0x16>
  80157d:	89 d8                	mov    %ebx,%eax
  80157f:	eb 02                	jmp    801583 <readn+0x41>
  801581:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801583:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801586:	5b                   	pop    %ebx
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    

0080158b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	53                   	push   %ebx
  80158f:	83 ec 14             	sub    $0x14,%esp
  801592:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801595:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	53                   	push   %ebx
  80159a:	e8 ac fc ff ff       	call   80124b <fd_lookup>
  80159f:	83 c4 08             	add    $0x8,%esp
  8015a2:	89 c2                	mov    %eax,%edx
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	78 68                	js     801610 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a8:	83 ec 08             	sub    $0x8,%esp
  8015ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b2:	ff 30                	pushl  (%eax)
  8015b4:	e8 e8 fc ff ff       	call   8012a1 <dev_lookup>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 47                	js     801607 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c7:	75 21                	jne    8015ea <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c9:	a1 20 44 80 00       	mov    0x804420,%eax
  8015ce:	8b 40 48             	mov    0x48(%eax),%eax
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	50                   	push   %eax
  8015d6:	68 a0 2d 80 00       	push   $0x802da0
  8015db:	e8 11 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e8:	eb 26                	jmp    801610 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f0:	85 d2                	test   %edx,%edx
  8015f2:	74 17                	je     80160b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f4:	83 ec 04             	sub    $0x4,%esp
  8015f7:	ff 75 10             	pushl  0x10(%ebp)
  8015fa:	ff 75 0c             	pushl  0xc(%ebp)
  8015fd:	50                   	push   %eax
  8015fe:	ff d2                	call   *%edx
  801600:	89 c2                	mov    %eax,%edx
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	eb 09                	jmp    801610 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801607:	89 c2                	mov    %eax,%edx
  801609:	eb 05                	jmp    801610 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80160b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801610:	89 d0                	mov    %edx,%eax
  801612:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <seek>:

int
seek(int fdnum, off_t offset)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	ff 75 08             	pushl  0x8(%ebp)
  801624:	e8 22 fc ff ff       	call   80124b <fd_lookup>
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 0e                	js     80163e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801630:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801633:	8b 55 0c             	mov    0xc(%ebp),%edx
  801636:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163e:	c9                   	leave  
  80163f:	c3                   	ret    

00801640 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	53                   	push   %ebx
  801644:	83 ec 14             	sub    $0x14,%esp
  801647:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80164a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	53                   	push   %ebx
  80164f:	e8 f7 fb ff ff       	call   80124b <fd_lookup>
  801654:	83 c4 08             	add    $0x8,%esp
  801657:	89 c2                	mov    %eax,%edx
  801659:	85 c0                	test   %eax,%eax
  80165b:	78 65                	js     8016c2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165d:	83 ec 08             	sub    $0x8,%esp
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801667:	ff 30                	pushl  (%eax)
  801669:	e8 33 fc ff ff       	call   8012a1 <dev_lookup>
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	85 c0                	test   %eax,%eax
  801673:	78 44                	js     8016b9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801675:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801678:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167c:	75 21                	jne    80169f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167e:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801683:	8b 40 48             	mov    0x48(%eax),%eax
  801686:	83 ec 04             	sub    $0x4,%esp
  801689:	53                   	push   %ebx
  80168a:	50                   	push   %eax
  80168b:	68 60 2d 80 00       	push   $0x802d60
  801690:	e8 5c ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801695:	83 c4 10             	add    $0x10,%esp
  801698:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169d:	eb 23                	jmp    8016c2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a2:	8b 52 18             	mov    0x18(%edx),%edx
  8016a5:	85 d2                	test   %edx,%edx
  8016a7:	74 14                	je     8016bd <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	ff 75 0c             	pushl  0xc(%ebp)
  8016af:	50                   	push   %eax
  8016b0:	ff d2                	call   *%edx
  8016b2:	89 c2                	mov    %eax,%edx
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	eb 09                	jmp    8016c2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b9:	89 c2                	mov    %eax,%edx
  8016bb:	eb 05                	jmp    8016c2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c2:	89 d0                	mov    %edx,%eax
  8016c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 14             	sub    $0x14,%esp
  8016d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d6:	50                   	push   %eax
  8016d7:	ff 75 08             	pushl  0x8(%ebp)
  8016da:	e8 6c fb ff ff       	call   80124b <fd_lookup>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	89 c2                	mov    %eax,%edx
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 58                	js     801740 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ee:	50                   	push   %eax
  8016ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f2:	ff 30                	pushl  (%eax)
  8016f4:	e8 a8 fb ff ff       	call   8012a1 <dev_lookup>
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 37                	js     801737 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801700:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801703:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801707:	74 32                	je     80173b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801709:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801713:	00 00 00 
	stat->st_isdir = 0;
  801716:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171d:	00 00 00 
	stat->st_dev = dev;
  801720:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	53                   	push   %ebx
  80172a:	ff 75 f0             	pushl  -0x10(%ebp)
  80172d:	ff 50 14             	call   *0x14(%eax)
  801730:	89 c2                	mov    %eax,%edx
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	eb 09                	jmp    801740 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801737:	89 c2                	mov    %eax,%edx
  801739:	eb 05                	jmp    801740 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80173b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801740:	89 d0                	mov    %edx,%eax
  801742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	56                   	push   %esi
  80174b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	6a 00                	push   $0x0
  801751:	ff 75 08             	pushl  0x8(%ebp)
  801754:	e8 ef 01 00 00       	call   801948 <open>
  801759:	89 c3                	mov    %eax,%ebx
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 1b                	js     80177d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801762:	83 ec 08             	sub    $0x8,%esp
  801765:	ff 75 0c             	pushl  0xc(%ebp)
  801768:	50                   	push   %eax
  801769:	e8 5b ff ff ff       	call   8016c9 <fstat>
  80176e:	89 c6                	mov    %eax,%esi
	close(fd);
  801770:	89 1c 24             	mov    %ebx,(%esp)
  801773:	e8 fd fb ff ff       	call   801375 <close>
	return r;
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	89 f0                	mov    %esi,%eax
}
  80177d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	89 c6                	mov    %eax,%esi
  80178b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80178d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801794:	75 12                	jne    8017a8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801796:	83 ec 0c             	sub    $0xc,%esp
  801799:	6a 01                	push   $0x1
  80179b:	e8 3c 0d 00 00       	call   8024dc <ipc_find_env>
  8017a0:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a8:	6a 07                	push   $0x7
  8017aa:	68 00 50 80 00       	push   $0x805000
  8017af:	56                   	push   %esi
  8017b0:	ff 35 00 40 80 00    	pushl  0x804000
  8017b6:	e8 d2 0c 00 00       	call   80248d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017bb:	83 c4 0c             	add    $0xc,%esp
  8017be:	6a 00                	push   $0x0
  8017c0:	53                   	push   %ebx
  8017c1:	6a 00                	push   $0x0
  8017c3:	e8 4f 0c 00 00       	call   802417 <ipc_recv>
}
  8017c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017db:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ed:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f2:	e8 8d ff ff ff       	call   801784 <fsipc>
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 40 0c             	mov    0xc(%eax),%eax
  801805:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80180a:	ba 00 00 00 00       	mov    $0x0,%edx
  80180f:	b8 06 00 00 00       	mov    $0x6,%eax
  801814:	e8 6b ff ff ff       	call   801784 <fsipc>
}
  801819:	c9                   	leave  
  80181a:	c3                   	ret    

0080181b <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	53                   	push   %ebx
  80181f:	83 ec 04             	sub    $0x4,%esp
  801822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801825:	8b 45 08             	mov    0x8(%ebp),%eax
  801828:	8b 40 0c             	mov    0xc(%eax),%eax
  80182b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801830:	ba 00 00 00 00       	mov    $0x0,%edx
  801835:	b8 05 00 00 00       	mov    $0x5,%eax
  80183a:	e8 45 ff ff ff       	call   801784 <fsipc>
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 2c                	js     80186f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	68 00 50 80 00       	push   $0x805000
  80184b:	53                   	push   %ebx
  80184c:	e8 45 f0 ff ff       	call   800896 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801851:	a1 80 50 80 00       	mov    0x805080,%eax
  801856:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185c:	a1 84 50 80 00       	mov    0x805084,%eax
  801861:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	53                   	push   %ebx
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187e:	8b 55 08             	mov    0x8(%ebp),%edx
  801881:	8b 52 0c             	mov    0xc(%edx),%edx
  801884:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80188a:	a3 04 50 80 00       	mov    %eax,0x805004
  80188f:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801894:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801899:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80189c:	53                   	push   %ebx
  80189d:	ff 75 0c             	pushl  0xc(%ebp)
  8018a0:	68 08 50 80 00       	push   $0x805008
  8018a5:	e8 7e f1 ff ff       	call   800a28 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b4:	e8 cb fe ff ff       	call   801784 <fsipc>
  8018b9:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8018c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	56                   	push   %esi
  8018ca:	53                   	push   %ebx
  8018cb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e9:	e8 96 fe ff ff       	call   801784 <fsipc>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 4b                	js     80193f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f4:	39 c6                	cmp    %eax,%esi
  8018f6:	73 16                	jae    80190e <devfile_read+0x48>
  8018f8:	68 d4 2d 80 00       	push   $0x802dd4
  8018fd:	68 db 2d 80 00       	push   $0x802ddb
  801902:	6a 7c                	push   $0x7c
  801904:	68 f0 2d 80 00       	push   $0x802df0
  801909:	e8 0a e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  80190e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801913:	7e 16                	jle    80192b <devfile_read+0x65>
  801915:	68 fb 2d 80 00       	push   $0x802dfb
  80191a:	68 db 2d 80 00       	push   $0x802ddb
  80191f:	6a 7d                	push   $0x7d
  801921:	68 f0 2d 80 00       	push   $0x802df0
  801926:	e8 ed e8 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80192b:	83 ec 04             	sub    $0x4,%esp
  80192e:	50                   	push   %eax
  80192f:	68 00 50 80 00       	push   $0x805000
  801934:	ff 75 0c             	pushl  0xc(%ebp)
  801937:	e8 ec f0 ff ff       	call   800a28 <memmove>
	return r;
  80193c:	83 c4 10             	add    $0x10,%esp
}
  80193f:	89 d8                	mov    %ebx,%eax
  801941:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	83 ec 20             	sub    $0x20,%esp
  80194f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801952:	53                   	push   %ebx
  801953:	e8 05 ef ff ff       	call   80085d <strlen>
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801960:	7f 67                	jg     8019c9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801962:	83 ec 0c             	sub    $0xc,%esp
  801965:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801968:	50                   	push   %eax
  801969:	e8 8e f8 ff ff       	call   8011fc <fd_alloc>
  80196e:	83 c4 10             	add    $0x10,%esp
		return r;
  801971:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801973:	85 c0                	test   %eax,%eax
  801975:	78 57                	js     8019ce <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801977:	83 ec 08             	sub    $0x8,%esp
  80197a:	53                   	push   %ebx
  80197b:	68 00 50 80 00       	push   $0x805000
  801980:	e8 11 ef ff ff       	call   800896 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801985:	8b 45 0c             	mov    0xc(%ebp),%eax
  801988:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80198d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801990:	b8 01 00 00 00       	mov    $0x1,%eax
  801995:	e8 ea fd ff ff       	call   801784 <fsipc>
  80199a:	89 c3                	mov    %eax,%ebx
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	79 14                	jns    8019b7 <open+0x6f>
		fd_close(fd, 0);
  8019a3:	83 ec 08             	sub    $0x8,%esp
  8019a6:	6a 00                	push   $0x0
  8019a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ab:	e8 44 f9 ff ff       	call   8012f4 <fd_close>
		return r;
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	89 da                	mov    %ebx,%edx
  8019b5:	eb 17                	jmp    8019ce <open+0x86>
	}

	return fd2num(fd);
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bd:	e8 13 f8 ff ff       	call   8011d5 <fd2num>
  8019c2:	89 c2                	mov    %eax,%edx
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	eb 05                	jmp    8019ce <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ce:	89 d0                	mov    %edx,%eax
  8019d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d3:	c9                   	leave  
  8019d4:	c3                   	ret    

008019d5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019db:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e5:	e8 9a fd ff ff       	call   801784 <fsipc>
}
  8019ea:	c9                   	leave  
  8019eb:	c3                   	ret    

008019ec <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	56                   	push   %esi
  8019f0:	53                   	push   %ebx
  8019f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	ff 75 08             	pushl  0x8(%ebp)
  8019fa:	e8 e6 f7 ff ff       	call   8011e5 <fd2data>
  8019ff:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a01:	83 c4 08             	add    $0x8,%esp
  801a04:	68 07 2e 80 00       	push   $0x802e07
  801a09:	53                   	push   %ebx
  801a0a:	e8 87 ee ff ff       	call   800896 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0f:	8b 46 04             	mov    0x4(%esi),%eax
  801a12:	2b 06                	sub    (%esi),%eax
  801a14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a1a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a21:	00 00 00 
	stat->st_dev = &devpipe;
  801a24:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a2b:	30 80 00 
	return 0;
}
  801a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a36:	5b                   	pop    %ebx
  801a37:	5e                   	pop    %esi
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	53                   	push   %ebx
  801a3e:	83 ec 0c             	sub    $0xc,%esp
  801a41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a44:	53                   	push   %ebx
  801a45:	6a 00                	push   $0x0
  801a47:	e8 d2 f2 ff ff       	call   800d1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a4c:	89 1c 24             	mov    %ebx,(%esp)
  801a4f:	e8 91 f7 ff ff       	call   8011e5 <fd2data>
  801a54:	83 c4 08             	add    $0x8,%esp
  801a57:	50                   	push   %eax
  801a58:	6a 00                	push   $0x0
  801a5a:	e8 bf f2 ff ff       	call   800d1e <sys_page_unmap>
}
  801a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	57                   	push   %edi
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 1c             	sub    $0x1c,%esp
  801a6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a70:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a72:	a1 20 44 80 00       	mov    0x804420,%eax
  801a77:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a80:	e8 90 0a 00 00       	call   802515 <pageref>
  801a85:	89 c3                	mov    %eax,%ebx
  801a87:	89 3c 24             	mov    %edi,(%esp)
  801a8a:	e8 86 0a 00 00       	call   802515 <pageref>
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	39 c3                	cmp    %eax,%ebx
  801a94:	0f 94 c1             	sete   %cl
  801a97:	0f b6 c9             	movzbl %cl,%ecx
  801a9a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a9d:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801aa3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aa6:	39 ce                	cmp    %ecx,%esi
  801aa8:	74 1b                	je     801ac5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aaa:	39 c3                	cmp    %eax,%ebx
  801aac:	75 c4                	jne    801a72 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aae:	8b 42 58             	mov    0x58(%edx),%eax
  801ab1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab4:	50                   	push   %eax
  801ab5:	56                   	push   %esi
  801ab6:	68 0e 2e 80 00       	push   $0x802e0e
  801abb:	e8 31 e8 ff ff       	call   8002f1 <cprintf>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	eb ad                	jmp    801a72 <_pipeisclosed+0xe>
	}
}
  801ac5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5f                   	pop    %edi
  801ace:	5d                   	pop    %ebp
  801acf:	c3                   	ret    

00801ad0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	53                   	push   %ebx
  801ad6:	83 ec 28             	sub    $0x28,%esp
  801ad9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801adc:	56                   	push   %esi
  801add:	e8 03 f7 ff ff       	call   8011e5 <fd2data>
  801ae2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	bf 00 00 00 00       	mov    $0x0,%edi
  801aec:	eb 4b                	jmp    801b39 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aee:	89 da                	mov    %ebx,%edx
  801af0:	89 f0                	mov    %esi,%eax
  801af2:	e8 6d ff ff ff       	call   801a64 <_pipeisclosed>
  801af7:	85 c0                	test   %eax,%eax
  801af9:	75 48                	jne    801b43 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801afb:	e8 7a f1 ff ff       	call   800c7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b00:	8b 43 04             	mov    0x4(%ebx),%eax
  801b03:	8b 0b                	mov    (%ebx),%ecx
  801b05:	8d 51 20             	lea    0x20(%ecx),%edx
  801b08:	39 d0                	cmp    %edx,%eax
  801b0a:	73 e2                	jae    801aee <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b13:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b16:	89 c2                	mov    %eax,%edx
  801b18:	c1 fa 1f             	sar    $0x1f,%edx
  801b1b:	89 d1                	mov    %edx,%ecx
  801b1d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b20:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b23:	83 e2 1f             	and    $0x1f,%edx
  801b26:	29 ca                	sub    %ecx,%edx
  801b28:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b2c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b30:	83 c0 01             	add    $0x1,%eax
  801b33:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b36:	83 c7 01             	add    $0x1,%edi
  801b39:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b3c:	75 c2                	jne    801b00 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b41:	eb 05                	jmp    801b48 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4b:	5b                   	pop    %ebx
  801b4c:	5e                   	pop    %esi
  801b4d:	5f                   	pop    %edi
  801b4e:	5d                   	pop    %ebp
  801b4f:	c3                   	ret    

00801b50 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	83 ec 18             	sub    $0x18,%esp
  801b59:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b5c:	57                   	push   %edi
  801b5d:	e8 83 f6 ff ff       	call   8011e5 <fd2data>
  801b62:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6c:	eb 3d                	jmp    801bab <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b6e:	85 db                	test   %ebx,%ebx
  801b70:	74 04                	je     801b76 <devpipe_read+0x26>
				return i;
  801b72:	89 d8                	mov    %ebx,%eax
  801b74:	eb 44                	jmp    801bba <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b76:	89 f2                	mov    %esi,%edx
  801b78:	89 f8                	mov    %edi,%eax
  801b7a:	e8 e5 fe ff ff       	call   801a64 <_pipeisclosed>
  801b7f:	85 c0                	test   %eax,%eax
  801b81:	75 32                	jne    801bb5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b83:	e8 f2 f0 ff ff       	call   800c7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b88:	8b 06                	mov    (%esi),%eax
  801b8a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b8d:	74 df                	je     801b6e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8f:	99                   	cltd   
  801b90:	c1 ea 1b             	shr    $0x1b,%edx
  801b93:	01 d0                	add    %edx,%eax
  801b95:	83 e0 1f             	and    $0x1f,%eax
  801b98:	29 d0                	sub    %edx,%eax
  801b9a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ba5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba8:	83 c3 01             	add    $0x1,%ebx
  801bab:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bae:	75 d8                	jne    801b88 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb3:	eb 05                	jmp    801bba <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5f                   	pop    %edi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	56                   	push   %esi
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcd:	50                   	push   %eax
  801bce:	e8 29 f6 ff ff       	call   8011fc <fd_alloc>
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 2c 01 00 00    	js     801d0c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	83 ec 04             	sub    $0x4,%esp
  801be3:	68 07 04 00 00       	push   $0x407
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	6a 00                	push   $0x0
  801bed:	e8 a7 f0 ff ff       	call   800c99 <sys_page_alloc>
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	89 c2                	mov    %eax,%edx
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	0f 88 0d 01 00 00    	js     801d0c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c05:	50                   	push   %eax
  801c06:	e8 f1 f5 ff ff       	call   8011fc <fd_alloc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	85 c0                	test   %eax,%eax
  801c12:	0f 88 e2 00 00 00    	js     801cfa <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	68 07 04 00 00       	push   $0x407
  801c20:	ff 75 f0             	pushl  -0x10(%ebp)
  801c23:	6a 00                	push   $0x0
  801c25:	e8 6f f0 ff ff       	call   800c99 <sys_page_alloc>
  801c2a:	89 c3                	mov    %eax,%ebx
  801c2c:	83 c4 10             	add    $0x10,%esp
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	0f 88 c3 00 00 00    	js     801cfa <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3d:	e8 a3 f5 ff ff       	call   8011e5 <fd2data>
  801c42:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c44:	83 c4 0c             	add    $0xc,%esp
  801c47:	68 07 04 00 00       	push   $0x407
  801c4c:	50                   	push   %eax
  801c4d:	6a 00                	push   $0x0
  801c4f:	e8 45 f0 ff ff       	call   800c99 <sys_page_alloc>
  801c54:	89 c3                	mov    %eax,%ebx
  801c56:	83 c4 10             	add    $0x10,%esp
  801c59:	85 c0                	test   %eax,%eax
  801c5b:	0f 88 89 00 00 00    	js     801cea <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c61:	83 ec 0c             	sub    $0xc,%esp
  801c64:	ff 75 f0             	pushl  -0x10(%ebp)
  801c67:	e8 79 f5 ff ff       	call   8011e5 <fd2data>
  801c6c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c73:	50                   	push   %eax
  801c74:	6a 00                	push   $0x0
  801c76:	56                   	push   %esi
  801c77:	6a 00                	push   $0x0
  801c79:	e8 5e f0 ff ff       	call   800cdc <sys_page_map>
  801c7e:	89 c3                	mov    %eax,%ebx
  801c80:	83 c4 20             	add    $0x20,%esp
  801c83:	85 c0                	test   %eax,%eax
  801c85:	78 55                	js     801cdc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c87:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801caa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cb1:	83 ec 0c             	sub    $0xc,%esp
  801cb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb7:	e8 19 f5 ff ff       	call   8011d5 <fd2num>
  801cbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cc1:	83 c4 04             	add    $0x4,%esp
  801cc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc7:	e8 09 f5 ff ff       	call   8011d5 <fd2num>
  801ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cda:	eb 30                	jmp    801d0c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cdc:	83 ec 08             	sub    $0x8,%esp
  801cdf:	56                   	push   %esi
  801ce0:	6a 00                	push   $0x0
  801ce2:	e8 37 f0 ff ff       	call   800d1e <sys_page_unmap>
  801ce7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 27 f0 ff ff       	call   800d1e <sys_page_unmap>
  801cf7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cfa:	83 ec 08             	sub    $0x8,%esp
  801cfd:	ff 75 f4             	pushl  -0xc(%ebp)
  801d00:	6a 00                	push   $0x0
  801d02:	e8 17 f0 ff ff       	call   800d1e <sys_page_unmap>
  801d07:	83 c4 10             	add    $0x10,%esp
  801d0a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d0c:	89 d0                	mov    %edx,%eax
  801d0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1e:	50                   	push   %eax
  801d1f:	ff 75 08             	pushl  0x8(%ebp)
  801d22:	e8 24 f5 ff ff       	call   80124b <fd_lookup>
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 18                	js     801d46 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	ff 75 f4             	pushl  -0xc(%ebp)
  801d34:	e8 ac f4 ff ff       	call   8011e5 <fd2data>
	return _pipeisclosed(fd, p);
  801d39:	89 c2                	mov    %eax,%edx
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	e8 21 fd ff ff       	call   801a64 <_pipeisclosed>
  801d43:	83 c4 10             	add    $0x10,%esp
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	56                   	push   %esi
  801d4c:	53                   	push   %ebx
  801d4d:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d50:	85 f6                	test   %esi,%esi
  801d52:	75 16                	jne    801d6a <wait+0x22>
  801d54:	68 26 2e 80 00       	push   $0x802e26
  801d59:	68 db 2d 80 00       	push   $0x802ddb
  801d5e:	6a 09                	push   $0x9
  801d60:	68 31 2e 80 00       	push   $0x802e31
  801d65:	e8 ae e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d6a:	89 f3                	mov    %esi,%ebx
  801d6c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d72:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d75:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d7b:	eb 05                	jmp    801d82 <wait+0x3a>
		sys_yield();
  801d7d:	e8 f8 ee ff ff       	call   800c7a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d82:	8b 43 48             	mov    0x48(%ebx),%eax
  801d85:	39 c6                	cmp    %eax,%esi
  801d87:	75 07                	jne    801d90 <wait+0x48>
  801d89:	8b 43 54             	mov    0x54(%ebx),%eax
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	75 ed                	jne    801d7d <wait+0x35>
		sys_yield();
}
  801d90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5d                   	pop    %ebp
  801d96:	c3                   	ret    

00801d97 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d97:	55                   	push   %ebp
  801d98:	89 e5                	mov    %esp,%ebp
  801d9a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d9d:	68 3c 2e 80 00       	push   $0x802e3c
  801da2:	ff 75 0c             	pushl  0xc(%ebp)
  801da5:	e8 ec ea ff ff       	call   800896 <strcpy>
	return 0;
}
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	53                   	push   %ebx
  801db5:	83 ec 10             	sub    $0x10,%esp
  801db8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801dbb:	53                   	push   %ebx
  801dbc:	e8 54 07 00 00       	call   802515 <pageref>
  801dc1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801dc4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801dc9:	83 f8 01             	cmp    $0x1,%eax
  801dcc:	75 10                	jne    801dde <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 73 0c             	pushl  0xc(%ebx)
  801dd4:	e8 c0 02 00 00       	call   802099 <nsipc_close>
  801dd9:	89 c2                	mov    %eax,%edx
  801ddb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801dde:	89 d0                	mov    %edx,%eax
  801de0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801deb:	6a 00                	push   $0x0
  801ded:	ff 75 10             	pushl  0x10(%ebp)
  801df0:	ff 75 0c             	pushl  0xc(%ebp)
  801df3:	8b 45 08             	mov    0x8(%ebp),%eax
  801df6:	ff 70 0c             	pushl  0xc(%eax)
  801df9:	e8 78 03 00 00       	call   802176 <nsipc_send>
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e06:	6a 00                	push   $0x0
  801e08:	ff 75 10             	pushl  0x10(%ebp)
  801e0b:	ff 75 0c             	pushl  0xc(%ebp)
  801e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e11:	ff 70 0c             	pushl  0xc(%eax)
  801e14:	e8 f1 02 00 00       	call   80210a <nsipc_recv>
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e21:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e24:	52                   	push   %edx
  801e25:	50                   	push   %eax
  801e26:	e8 20 f4 ff ff       	call   80124b <fd_lookup>
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 17                	js     801e49 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e35:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801e3b:	39 08                	cmp    %ecx,(%eax)
  801e3d:	75 05                	jne    801e44 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801e42:	eb 05                	jmp    801e49 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e44:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	56                   	push   %esi
  801e4f:	53                   	push   %ebx
  801e50:	83 ec 1c             	sub    $0x1c,%esp
  801e53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e58:	50                   	push   %eax
  801e59:	e8 9e f3 ff ff       	call   8011fc <fd_alloc>
  801e5e:	89 c3                	mov    %eax,%ebx
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 1b                	js     801e82 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e67:	83 ec 04             	sub    $0x4,%esp
  801e6a:	68 07 04 00 00       	push   $0x407
  801e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e72:	6a 00                	push   $0x0
  801e74:	e8 20 ee ff ff       	call   800c99 <sys_page_alloc>
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	83 c4 10             	add    $0x10,%esp
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	79 10                	jns    801e92 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e82:	83 ec 0c             	sub    $0xc,%esp
  801e85:	56                   	push   %esi
  801e86:	e8 0e 02 00 00       	call   802099 <nsipc_close>
		return r;
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	89 d8                	mov    %ebx,%eax
  801e90:	eb 24                	jmp    801eb6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e92:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9b:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ea7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	50                   	push   %eax
  801eae:	e8 22 f3 ff ff       	call   8011d5 <fd2num>
  801eb3:	83 c4 10             	add    $0x10,%esp
}
  801eb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    

00801ebd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec6:	e8 50 ff ff ff       	call   801e1b <fd2sockid>
		return r;
  801ecb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	78 1f                	js     801ef0 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ed1:	83 ec 04             	sub    $0x4,%esp
  801ed4:	ff 75 10             	pushl  0x10(%ebp)
  801ed7:	ff 75 0c             	pushl  0xc(%ebp)
  801eda:	50                   	push   %eax
  801edb:	e8 12 01 00 00       	call   801ff2 <nsipc_accept>
  801ee0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 07                	js     801ef0 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ee9:	e8 5d ff ff ff       	call   801e4b <alloc_sockfd>
  801eee:	89 c1                	mov    %eax,%ecx
}
  801ef0:	89 c8                	mov    %ecx,%eax
  801ef2:	c9                   	leave  
  801ef3:	c3                   	ret    

00801ef4 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801efa:	8b 45 08             	mov    0x8(%ebp),%eax
  801efd:	e8 19 ff ff ff       	call   801e1b <fd2sockid>
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 12                	js     801f18 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801f06:	83 ec 04             	sub    $0x4,%esp
  801f09:	ff 75 10             	pushl  0x10(%ebp)
  801f0c:	ff 75 0c             	pushl  0xc(%ebp)
  801f0f:	50                   	push   %eax
  801f10:	e8 2d 01 00 00       	call   802042 <nsipc_bind>
  801f15:	83 c4 10             	add    $0x10,%esp
}
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <shutdown>:

int
shutdown(int s, int how)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f20:	8b 45 08             	mov    0x8(%ebp),%eax
  801f23:	e8 f3 fe ff ff       	call   801e1b <fd2sockid>
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 0f                	js     801f3b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f2c:	83 ec 08             	sub    $0x8,%esp
  801f2f:	ff 75 0c             	pushl  0xc(%ebp)
  801f32:	50                   	push   %eax
  801f33:	e8 3f 01 00 00       	call   802077 <nsipc_shutdown>
  801f38:	83 c4 10             	add    $0x10,%esp
}
  801f3b:	c9                   	leave  
  801f3c:	c3                   	ret    

00801f3d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f43:	8b 45 08             	mov    0x8(%ebp),%eax
  801f46:	e8 d0 fe ff ff       	call   801e1b <fd2sockid>
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	78 12                	js     801f61 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f4f:	83 ec 04             	sub    $0x4,%esp
  801f52:	ff 75 10             	pushl  0x10(%ebp)
  801f55:	ff 75 0c             	pushl  0xc(%ebp)
  801f58:	50                   	push   %eax
  801f59:	e8 55 01 00 00       	call   8020b3 <nsipc_connect>
  801f5e:	83 c4 10             	add    $0x10,%esp
}
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <listen>:

int
listen(int s, int backlog)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f69:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6c:	e8 aa fe ff ff       	call   801e1b <fd2sockid>
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 0f                	js     801f84 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f75:	83 ec 08             	sub    $0x8,%esp
  801f78:	ff 75 0c             	pushl  0xc(%ebp)
  801f7b:	50                   	push   %eax
  801f7c:	e8 67 01 00 00       	call   8020e8 <nsipc_listen>
  801f81:	83 c4 10             	add    $0x10,%esp
}
  801f84:	c9                   	leave  
  801f85:	c3                   	ret    

00801f86 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f8c:	ff 75 10             	pushl  0x10(%ebp)
  801f8f:	ff 75 0c             	pushl  0xc(%ebp)
  801f92:	ff 75 08             	pushl  0x8(%ebp)
  801f95:	e8 3a 02 00 00       	call   8021d4 <nsipc_socket>
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 05                	js     801fa6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801fa1:	e8 a5 fe ff ff       	call   801e4b <alloc_sockfd>
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	53                   	push   %ebx
  801fac:	83 ec 04             	sub    $0x4,%esp
  801faf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fb1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801fb8:	75 12                	jne    801fcc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	6a 02                	push   $0x2
  801fbf:	e8 18 05 00 00       	call   8024dc <ipc_find_env>
  801fc4:	a3 04 40 80 00       	mov    %eax,0x804004
  801fc9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fcc:	6a 07                	push   $0x7
  801fce:	68 00 60 80 00       	push   $0x806000
  801fd3:	53                   	push   %ebx
  801fd4:	ff 35 04 40 80 00    	pushl  0x804004
  801fda:	e8 ae 04 00 00       	call   80248d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fdf:	83 c4 0c             	add    $0xc,%esp
  801fe2:	6a 00                	push   $0x0
  801fe4:	6a 00                	push   $0x0
  801fe6:	6a 00                	push   $0x0
  801fe8:	e8 2a 04 00 00       	call   802417 <ipc_recv>
}
  801fed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff0:	c9                   	leave  
  801ff1:	c3                   	ret    

00801ff2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	56                   	push   %esi
  801ff6:	53                   	push   %ebx
  801ff7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ffa:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802002:	8b 06                	mov    (%esi),%eax
  802004:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802009:	b8 01 00 00 00       	mov    $0x1,%eax
  80200e:	e8 95 ff ff ff       	call   801fa8 <nsipc>
  802013:	89 c3                	mov    %eax,%ebx
  802015:	85 c0                	test   %eax,%eax
  802017:	78 20                	js     802039 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802019:	83 ec 04             	sub    $0x4,%esp
  80201c:	ff 35 10 60 80 00    	pushl  0x806010
  802022:	68 00 60 80 00       	push   $0x806000
  802027:	ff 75 0c             	pushl  0xc(%ebp)
  80202a:	e8 f9 e9 ff ff       	call   800a28 <memmove>
		*addrlen = ret->ret_addrlen;
  80202f:	a1 10 60 80 00       	mov    0x806010,%eax
  802034:	89 06                	mov    %eax,(%esi)
  802036:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802039:	89 d8                	mov    %ebx,%eax
  80203b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80203e:	5b                   	pop    %ebx
  80203f:	5e                   	pop    %esi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    

00802042 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	53                   	push   %ebx
  802046:	83 ec 08             	sub    $0x8,%esp
  802049:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
  80204f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802054:	53                   	push   %ebx
  802055:	ff 75 0c             	pushl  0xc(%ebp)
  802058:	68 04 60 80 00       	push   $0x806004
  80205d:	e8 c6 e9 ff ff       	call   800a28 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802062:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  802068:	b8 02 00 00 00       	mov    $0x2,%eax
  80206d:	e8 36 ff ff ff       	call   801fa8 <nsipc>
}
  802072:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802075:	c9                   	leave  
  802076:	c3                   	ret    

00802077 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80207d:	8b 45 08             	mov    0x8(%ebp),%eax
  802080:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802085:	8b 45 0c             	mov    0xc(%ebp),%eax
  802088:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80208d:	b8 03 00 00 00       	mov    $0x3,%eax
  802092:	e8 11 ff ff ff       	call   801fa8 <nsipc>
}
  802097:	c9                   	leave  
  802098:	c3                   	ret    

00802099 <nsipc_close>:

int
nsipc_close(int s)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80209f:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8020a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8020ac:	e8 f7 fe ff ff       	call   801fa8 <nsipc>
}
  8020b1:	c9                   	leave  
  8020b2:	c3                   	ret    

008020b3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	53                   	push   %ebx
  8020b7:	83 ec 08             	sub    $0x8,%esp
  8020ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020c5:	53                   	push   %ebx
  8020c6:	ff 75 0c             	pushl  0xc(%ebp)
  8020c9:	68 04 60 80 00       	push   $0x806004
  8020ce:	e8 55 e9 ff ff       	call   800a28 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020d3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8020d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8020de:	e8 c5 fe ff ff       	call   801fa8 <nsipc>
}
  8020e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020e6:	c9                   	leave  
  8020e7:	c3                   	ret    

008020e8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8020fe:	b8 06 00 00 00       	mov    $0x6,%eax
  802103:	e8 a0 fe ff ff       	call   801fa8 <nsipc>
}
  802108:	c9                   	leave  
  802109:	c3                   	ret    

0080210a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80210a:	55                   	push   %ebp
  80210b:	89 e5                	mov    %esp,%ebp
  80210d:	56                   	push   %esi
  80210e:	53                   	push   %ebx
  80210f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802112:	8b 45 08             	mov    0x8(%ebp),%eax
  802115:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80211a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802120:	8b 45 14             	mov    0x14(%ebp),%eax
  802123:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802128:	b8 07 00 00 00       	mov    $0x7,%eax
  80212d:	e8 76 fe ff ff       	call   801fa8 <nsipc>
  802132:	89 c3                	mov    %eax,%ebx
  802134:	85 c0                	test   %eax,%eax
  802136:	78 35                	js     80216d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802138:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80213d:	7f 04                	jg     802143 <nsipc_recv+0x39>
  80213f:	39 c6                	cmp    %eax,%esi
  802141:	7d 16                	jge    802159 <nsipc_recv+0x4f>
  802143:	68 48 2e 80 00       	push   $0x802e48
  802148:	68 db 2d 80 00       	push   $0x802ddb
  80214d:	6a 62                	push   $0x62
  80214f:	68 5d 2e 80 00       	push   $0x802e5d
  802154:	e8 bf e0 ff ff       	call   800218 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802159:	83 ec 04             	sub    $0x4,%esp
  80215c:	50                   	push   %eax
  80215d:	68 00 60 80 00       	push   $0x806000
  802162:	ff 75 0c             	pushl  0xc(%ebp)
  802165:	e8 be e8 ff ff       	call   800a28 <memmove>
  80216a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80216d:	89 d8                	mov    %ebx,%eax
  80216f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802172:	5b                   	pop    %ebx
  802173:	5e                   	pop    %esi
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    

00802176 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	53                   	push   %ebx
  80217a:	83 ec 04             	sub    $0x4,%esp
  80217d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802180:	8b 45 08             	mov    0x8(%ebp),%eax
  802183:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802188:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80218e:	7e 16                	jle    8021a6 <nsipc_send+0x30>
  802190:	68 69 2e 80 00       	push   $0x802e69
  802195:	68 db 2d 80 00       	push   $0x802ddb
  80219a:	6a 6d                	push   $0x6d
  80219c:	68 5d 2e 80 00       	push   $0x802e5d
  8021a1:	e8 72 e0 ff ff       	call   800218 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021a6:	83 ec 04             	sub    $0x4,%esp
  8021a9:	53                   	push   %ebx
  8021aa:	ff 75 0c             	pushl  0xc(%ebp)
  8021ad:	68 0c 60 80 00       	push   $0x80600c
  8021b2:	e8 71 e8 ff ff       	call   800a28 <memmove>
	nsipcbuf.send.req_size = size;
  8021b7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8021c0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8021ca:	e8 d9 fd ff ff       	call   801fa8 <nsipc>
}
  8021cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021d2:	c9                   	leave  
  8021d3:	c3                   	ret    

008021d4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021d4:	55                   	push   %ebp
  8021d5:	89 e5                	mov    %esp,%ebp
  8021d7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021da:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8021e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8021ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ed:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021f2:	b8 09 00 00 00       	mov    $0x9,%eax
  8021f7:	e8 ac fd ff ff       	call   801fa8 <nsipc>
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    

00802208 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80220e:	68 75 2e 80 00       	push   $0x802e75
  802213:	ff 75 0c             	pushl  0xc(%ebp)
  802216:	e8 7b e6 ff ff       	call   800896 <strcpy>
	return 0;
}
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
  802220:	c9                   	leave  
  802221:	c3                   	ret    

00802222 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	57                   	push   %edi
  802226:	56                   	push   %esi
  802227:	53                   	push   %ebx
  802228:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802233:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802239:	eb 2d                	jmp    802268 <devcons_write+0x46>
		m = n - tot;
  80223b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80223e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802240:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802243:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802248:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80224b:	83 ec 04             	sub    $0x4,%esp
  80224e:	53                   	push   %ebx
  80224f:	03 45 0c             	add    0xc(%ebp),%eax
  802252:	50                   	push   %eax
  802253:	57                   	push   %edi
  802254:	e8 cf e7 ff ff       	call   800a28 <memmove>
		sys_cputs(buf, m);
  802259:	83 c4 08             	add    $0x8,%esp
  80225c:	53                   	push   %ebx
  80225d:	57                   	push   %edi
  80225e:	e8 7a e9 ff ff       	call   800bdd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802263:	01 de                	add    %ebx,%esi
  802265:	83 c4 10             	add    $0x10,%esp
  802268:	89 f0                	mov    %esi,%eax
  80226a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80226d:	72 cc                	jb     80223b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80226f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802272:	5b                   	pop    %ebx
  802273:	5e                   	pop    %esi
  802274:	5f                   	pop    %edi
  802275:	5d                   	pop    %ebp
  802276:	c3                   	ret    

00802277 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
  80227a:	83 ec 08             	sub    $0x8,%esp
  80227d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802282:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802286:	74 2a                	je     8022b2 <devcons_read+0x3b>
  802288:	eb 05                	jmp    80228f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80228a:	e8 eb e9 ff ff       	call   800c7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80228f:	e8 67 e9 ff ff       	call   800bfb <sys_cgetc>
  802294:	85 c0                	test   %eax,%eax
  802296:	74 f2                	je     80228a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 16                	js     8022b2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80229c:	83 f8 04             	cmp    $0x4,%eax
  80229f:	74 0c                	je     8022ad <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022a4:	88 02                	mov    %al,(%edx)
	return 1;
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	eb 05                	jmp    8022b2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022ad:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022c0:	6a 01                	push   $0x1
  8022c2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022c5:	50                   	push   %eax
  8022c6:	e8 12 e9 ff ff       	call   800bdd <sys_cputs>
}
  8022cb:	83 c4 10             	add    $0x10,%esp
  8022ce:	c9                   	leave  
  8022cf:	c3                   	ret    

008022d0 <getchar>:

int
getchar(void)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022d6:	6a 01                	push   $0x1
  8022d8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022db:	50                   	push   %eax
  8022dc:	6a 00                	push   $0x0
  8022de:	e8 ce f1 ff ff       	call   8014b1 <read>
	if (r < 0)
  8022e3:	83 c4 10             	add    $0x10,%esp
  8022e6:	85 c0                	test   %eax,%eax
  8022e8:	78 0f                	js     8022f9 <getchar+0x29>
		return r;
	if (r < 1)
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	7e 06                	jle    8022f4 <getchar+0x24>
		return -E_EOF;
	return c;
  8022ee:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022f2:	eb 05                	jmp    8022f9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022f4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022f9:	c9                   	leave  
  8022fa:	c3                   	ret    

008022fb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802304:	50                   	push   %eax
  802305:	ff 75 08             	pushl  0x8(%ebp)
  802308:	e8 3e ef ff ff       	call   80124b <fd_lookup>
  80230d:	83 c4 10             	add    $0x10,%esp
  802310:	85 c0                	test   %eax,%eax
  802312:	78 11                	js     802325 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802314:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802317:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80231d:	39 10                	cmp    %edx,(%eax)
  80231f:	0f 94 c0             	sete   %al
  802322:	0f b6 c0             	movzbl %al,%eax
}
  802325:	c9                   	leave  
  802326:	c3                   	ret    

00802327 <opencons>:

int
opencons(void)
{
  802327:	55                   	push   %ebp
  802328:	89 e5                	mov    %esp,%ebp
  80232a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80232d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802330:	50                   	push   %eax
  802331:	e8 c6 ee ff ff       	call   8011fc <fd_alloc>
  802336:	83 c4 10             	add    $0x10,%esp
		return r;
  802339:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80233b:	85 c0                	test   %eax,%eax
  80233d:	78 3e                	js     80237d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80233f:	83 ec 04             	sub    $0x4,%esp
  802342:	68 07 04 00 00       	push   $0x407
  802347:	ff 75 f4             	pushl  -0xc(%ebp)
  80234a:	6a 00                	push   $0x0
  80234c:	e8 48 e9 ff ff       	call   800c99 <sys_page_alloc>
  802351:	83 c4 10             	add    $0x10,%esp
		return r;
  802354:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802356:	85 c0                	test   %eax,%eax
  802358:	78 23                	js     80237d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80235a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802363:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802368:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80236f:	83 ec 0c             	sub    $0xc,%esp
  802372:	50                   	push   %eax
  802373:	e8 5d ee ff ff       	call   8011d5 <fd2num>
  802378:	89 c2                	mov    %eax,%edx
  80237a:	83 c4 10             	add    $0x10,%esp
}
  80237d:	89 d0                	mov    %edx,%eax
  80237f:	c9                   	leave  
  802380:	c3                   	ret    

00802381 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802387:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80238e:	75 56                	jne    8023e6 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802390:	83 ec 04             	sub    $0x4,%esp
  802393:	6a 07                	push   $0x7
  802395:	68 00 f0 bf ee       	push   $0xeebff000
  80239a:	6a 00                	push   $0x0
  80239c:	e8 f8 e8 ff ff       	call   800c99 <sys_page_alloc>
  8023a1:	83 c4 10             	add    $0x10,%esp
  8023a4:	85 c0                	test   %eax,%eax
  8023a6:	74 14                	je     8023bc <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  8023a8:	83 ec 04             	sub    $0x4,%esp
  8023ab:	68 e9 2c 80 00       	push   $0x802ce9
  8023b0:	6a 21                	push   $0x21
  8023b2:	68 81 2e 80 00       	push   $0x802e81
  8023b7:	e8 5c de ff ff       	call   800218 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8023bc:	83 ec 08             	sub    $0x8,%esp
  8023bf:	68 f0 23 80 00       	push   $0x8023f0
  8023c4:	6a 00                	push   $0x0
  8023c6:	e8 19 ea ff ff       	call   800de4 <sys_env_set_pgfault_upcall>
  8023cb:	83 c4 10             	add    $0x10,%esp
  8023ce:	85 c0                	test   %eax,%eax
  8023d0:	74 14                	je     8023e6 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8023d2:	83 ec 04             	sub    $0x4,%esp
  8023d5:	68 8f 2e 80 00       	push   $0x802e8f
  8023da:	6a 23                	push   $0x23
  8023dc:	68 81 2e 80 00       	push   $0x802e81
  8023e1:	e8 32 de ff ff       	call   800218 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e9:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023ee:	c9                   	leave  
  8023ef:	c3                   	ret    

008023f0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023f0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023f1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023f6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023f8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8023fb:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8023fd:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  802401:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802405:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  802406:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  802408:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  80240d:	83 c4 08             	add    $0x8,%esp
	popal
  802410:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802411:	83 c4 04             	add    $0x4,%esp
	popfl
  802414:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802415:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802416:	c3                   	ret    

00802417 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802417:	55                   	push   %ebp
  802418:	89 e5                	mov    %esp,%ebp
  80241a:	56                   	push   %esi
  80241b:	53                   	push   %ebx
  80241c:	8b 75 08             	mov    0x8(%ebp),%esi
  80241f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802422:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  802425:	85 c0                	test   %eax,%eax
  802427:	74 0e                	je     802437 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802429:	83 ec 0c             	sub    $0xc,%esp
  80242c:	50                   	push   %eax
  80242d:	e8 17 ea ff ff       	call   800e49 <sys_ipc_recv>
  802432:	83 c4 10             	add    $0x10,%esp
  802435:	eb 10                	jmp    802447 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802437:	83 ec 0c             	sub    $0xc,%esp
  80243a:	68 00 00 c0 ee       	push   $0xeec00000
  80243f:	e8 05 ea ff ff       	call   800e49 <sys_ipc_recv>
  802444:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802447:	85 c0                	test   %eax,%eax
  802449:	79 17                	jns    802462 <ipc_recv+0x4b>
		if(*from_env_store)
  80244b:	83 3e 00             	cmpl   $0x0,(%esi)
  80244e:	74 06                	je     802456 <ipc_recv+0x3f>
			*from_env_store = 0;
  802450:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802456:	85 db                	test   %ebx,%ebx
  802458:	74 2c                	je     802486 <ipc_recv+0x6f>
			*perm_store = 0;
  80245a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802460:	eb 24                	jmp    802486 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802462:	85 f6                	test   %esi,%esi
  802464:	74 0a                	je     802470 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802466:	a1 20 44 80 00       	mov    0x804420,%eax
  80246b:	8b 40 74             	mov    0x74(%eax),%eax
  80246e:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802470:	85 db                	test   %ebx,%ebx
  802472:	74 0a                	je     80247e <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802474:	a1 20 44 80 00       	mov    0x804420,%eax
  802479:	8b 40 78             	mov    0x78(%eax),%eax
  80247c:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80247e:	a1 20 44 80 00       	mov    0x804420,%eax
  802483:	8b 40 70             	mov    0x70(%eax),%eax
}
  802486:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802489:	5b                   	pop    %ebx
  80248a:	5e                   	pop    %esi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    

0080248d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80248d:	55                   	push   %ebp
  80248e:	89 e5                	mov    %esp,%ebp
  802490:	57                   	push   %edi
  802491:	56                   	push   %esi
  802492:	53                   	push   %ebx
  802493:	83 ec 0c             	sub    $0xc,%esp
  802496:	8b 7d 08             	mov    0x8(%ebp),%edi
  802499:	8b 75 0c             	mov    0xc(%ebp),%esi
  80249c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80249f:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8024a1:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8024a6:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8024a9:	e8 cc e7 ff ff       	call   800c7a <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8024ae:	ff 75 14             	pushl  0x14(%ebp)
  8024b1:	53                   	push   %ebx
  8024b2:	56                   	push   %esi
  8024b3:	57                   	push   %edi
  8024b4:	e8 6d e9 ff ff       	call   800e26 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8024b9:	89 c2                	mov    %eax,%edx
  8024bb:	f7 d2                	not    %edx
  8024bd:	c1 ea 1f             	shr    $0x1f,%edx
  8024c0:	83 c4 10             	add    $0x10,%esp
  8024c3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024c6:	0f 94 c1             	sete   %cl
  8024c9:	09 ca                	or     %ecx,%edx
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	0f 94 c0             	sete   %al
  8024d0:	38 c2                	cmp    %al,%dl
  8024d2:	77 d5                	ja     8024a9 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8024d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    

008024dc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024dc:	55                   	push   %ebp
  8024dd:	89 e5                	mov    %esp,%ebp
  8024df:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024e2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024e7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024ea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024f0:	8b 52 50             	mov    0x50(%edx),%edx
  8024f3:	39 ca                	cmp    %ecx,%edx
  8024f5:	75 0d                	jne    802504 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024f7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ff:	8b 40 48             	mov    0x48(%eax),%eax
  802502:	eb 0f                	jmp    802513 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802504:	83 c0 01             	add    $0x1,%eax
  802507:	3d 00 04 00 00       	cmp    $0x400,%eax
  80250c:	75 d9                	jne    8024e7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80250e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    

00802515 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80251b:	89 d0                	mov    %edx,%eax
  80251d:	c1 e8 16             	shr    $0x16,%eax
  802520:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802527:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80252c:	f6 c1 01             	test   $0x1,%cl
  80252f:	74 1d                	je     80254e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802531:	c1 ea 0c             	shr    $0xc,%edx
  802534:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80253b:	f6 c2 01             	test   $0x1,%dl
  80253e:	74 0e                	je     80254e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802540:	c1 ea 0c             	shr    $0xc,%edx
  802543:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80254a:	ef 
  80254b:	0f b7 c0             	movzwl %ax,%eax
}
  80254e:	5d                   	pop    %ebp
  80254f:	c3                   	ret    

00802550 <__udivdi3>:
  802550:	55                   	push   %ebp
  802551:	57                   	push   %edi
  802552:	56                   	push   %esi
  802553:	53                   	push   %ebx
  802554:	83 ec 1c             	sub    $0x1c,%esp
  802557:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80255b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80255f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802563:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802567:	85 f6                	test   %esi,%esi
  802569:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80256d:	89 ca                	mov    %ecx,%edx
  80256f:	89 f8                	mov    %edi,%eax
  802571:	75 3d                	jne    8025b0 <__udivdi3+0x60>
  802573:	39 cf                	cmp    %ecx,%edi
  802575:	0f 87 c5 00 00 00    	ja     802640 <__udivdi3+0xf0>
  80257b:	85 ff                	test   %edi,%edi
  80257d:	89 fd                	mov    %edi,%ebp
  80257f:	75 0b                	jne    80258c <__udivdi3+0x3c>
  802581:	b8 01 00 00 00       	mov    $0x1,%eax
  802586:	31 d2                	xor    %edx,%edx
  802588:	f7 f7                	div    %edi
  80258a:	89 c5                	mov    %eax,%ebp
  80258c:	89 c8                	mov    %ecx,%eax
  80258e:	31 d2                	xor    %edx,%edx
  802590:	f7 f5                	div    %ebp
  802592:	89 c1                	mov    %eax,%ecx
  802594:	89 d8                	mov    %ebx,%eax
  802596:	89 cf                	mov    %ecx,%edi
  802598:	f7 f5                	div    %ebp
  80259a:	89 c3                	mov    %eax,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	39 ce                	cmp    %ecx,%esi
  8025b2:	77 74                	ja     802628 <__udivdi3+0xd8>
  8025b4:	0f bd fe             	bsr    %esi,%edi
  8025b7:	83 f7 1f             	xor    $0x1f,%edi
  8025ba:	0f 84 98 00 00 00    	je     802658 <__udivdi3+0x108>
  8025c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	89 c5                	mov    %eax,%ebp
  8025c9:	29 fb                	sub    %edi,%ebx
  8025cb:	d3 e6                	shl    %cl,%esi
  8025cd:	89 d9                	mov    %ebx,%ecx
  8025cf:	d3 ed                	shr    %cl,%ebp
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	d3 e0                	shl    %cl,%eax
  8025d5:	09 ee                	or     %ebp,%esi
  8025d7:	89 d9                	mov    %ebx,%ecx
  8025d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025dd:	89 d5                	mov    %edx,%ebp
  8025df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025e3:	d3 ed                	shr    %cl,%ebp
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e2                	shl    %cl,%edx
  8025e9:	89 d9                	mov    %ebx,%ecx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	09 c2                	or     %eax,%edx
  8025ef:	89 d0                	mov    %edx,%eax
  8025f1:	89 ea                	mov    %ebp,%edx
  8025f3:	f7 f6                	div    %esi
  8025f5:	89 d5                	mov    %edx,%ebp
  8025f7:	89 c3                	mov    %eax,%ebx
  8025f9:	f7 64 24 0c          	mull   0xc(%esp)
  8025fd:	39 d5                	cmp    %edx,%ebp
  8025ff:	72 10                	jb     802611 <__udivdi3+0xc1>
  802601:	8b 74 24 08          	mov    0x8(%esp),%esi
  802605:	89 f9                	mov    %edi,%ecx
  802607:	d3 e6                	shl    %cl,%esi
  802609:	39 c6                	cmp    %eax,%esi
  80260b:	73 07                	jae    802614 <__udivdi3+0xc4>
  80260d:	39 d5                	cmp    %edx,%ebp
  80260f:	75 03                	jne    802614 <__udivdi3+0xc4>
  802611:	83 eb 01             	sub    $0x1,%ebx
  802614:	31 ff                	xor    %edi,%edi
  802616:	89 d8                	mov    %ebx,%eax
  802618:	89 fa                	mov    %edi,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	31 ff                	xor    %edi,%edi
  80262a:	31 db                	xor    %ebx,%ebx
  80262c:	89 d8                	mov    %ebx,%eax
  80262e:	89 fa                	mov    %edi,%edx
  802630:	83 c4 1c             	add    $0x1c,%esp
  802633:	5b                   	pop    %ebx
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
  802638:	90                   	nop
  802639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802640:	89 d8                	mov    %ebx,%eax
  802642:	f7 f7                	div    %edi
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 c3                	mov    %eax,%ebx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 fa                	mov    %edi,%edx
  80264c:	83 c4 1c             	add    $0x1c,%esp
  80264f:	5b                   	pop    %ebx
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    
  802654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802658:	39 ce                	cmp    %ecx,%esi
  80265a:	72 0c                	jb     802668 <__udivdi3+0x118>
  80265c:	31 db                	xor    %ebx,%ebx
  80265e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802662:	0f 87 34 ff ff ff    	ja     80259c <__udivdi3+0x4c>
  802668:	bb 01 00 00 00       	mov    $0x1,%ebx
  80266d:	e9 2a ff ff ff       	jmp    80259c <__udivdi3+0x4c>
  802672:	66 90                	xchg   %ax,%ax
  802674:	66 90                	xchg   %ax,%ax
  802676:	66 90                	xchg   %ax,%ax
  802678:	66 90                	xchg   %ax,%ax
  80267a:	66 90                	xchg   %ax,%ax
  80267c:	66 90                	xchg   %ax,%ax
  80267e:	66 90                	xchg   %ax,%ax

00802680 <__umoddi3>:
  802680:	55                   	push   %ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	53                   	push   %ebx
  802684:	83 ec 1c             	sub    $0x1c,%esp
  802687:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80268b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80268f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802693:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802697:	85 d2                	test   %edx,%edx
  802699:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a1:	89 f3                	mov    %esi,%ebx
  8026a3:	89 3c 24             	mov    %edi,(%esp)
  8026a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026aa:	75 1c                	jne    8026c8 <__umoddi3+0x48>
  8026ac:	39 f7                	cmp    %esi,%edi
  8026ae:	76 50                	jbe    802700 <__umoddi3+0x80>
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	f7 f7                	div    %edi
  8026b6:	89 d0                	mov    %edx,%eax
  8026b8:	31 d2                	xor    %edx,%edx
  8026ba:	83 c4 1c             	add    $0x1c,%esp
  8026bd:	5b                   	pop    %ebx
  8026be:	5e                   	pop    %esi
  8026bf:	5f                   	pop    %edi
  8026c0:	5d                   	pop    %ebp
  8026c1:	c3                   	ret    
  8026c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026c8:	39 f2                	cmp    %esi,%edx
  8026ca:	89 d0                	mov    %edx,%eax
  8026cc:	77 52                	ja     802720 <__umoddi3+0xa0>
  8026ce:	0f bd ea             	bsr    %edx,%ebp
  8026d1:	83 f5 1f             	xor    $0x1f,%ebp
  8026d4:	75 5a                	jne    802730 <__umoddi3+0xb0>
  8026d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026da:	0f 82 e0 00 00 00    	jb     8027c0 <__umoddi3+0x140>
  8026e0:	39 0c 24             	cmp    %ecx,(%esp)
  8026e3:	0f 86 d7 00 00 00    	jbe    8027c0 <__umoddi3+0x140>
  8026e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026f1:	83 c4 1c             	add    $0x1c,%esp
  8026f4:	5b                   	pop    %ebx
  8026f5:	5e                   	pop    %esi
  8026f6:	5f                   	pop    %edi
  8026f7:	5d                   	pop    %ebp
  8026f8:	c3                   	ret    
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	85 ff                	test   %edi,%edi
  802702:	89 fd                	mov    %edi,%ebp
  802704:	75 0b                	jne    802711 <__umoddi3+0x91>
  802706:	b8 01 00 00 00       	mov    $0x1,%eax
  80270b:	31 d2                	xor    %edx,%edx
  80270d:	f7 f7                	div    %edi
  80270f:	89 c5                	mov    %eax,%ebp
  802711:	89 f0                	mov    %esi,%eax
  802713:	31 d2                	xor    %edx,%edx
  802715:	f7 f5                	div    %ebp
  802717:	89 c8                	mov    %ecx,%eax
  802719:	f7 f5                	div    %ebp
  80271b:	89 d0                	mov    %edx,%eax
  80271d:	eb 99                	jmp    8026b8 <__umoddi3+0x38>
  80271f:	90                   	nop
  802720:	89 c8                	mov    %ecx,%eax
  802722:	89 f2                	mov    %esi,%edx
  802724:	83 c4 1c             	add    $0x1c,%esp
  802727:	5b                   	pop    %ebx
  802728:	5e                   	pop    %esi
  802729:	5f                   	pop    %edi
  80272a:	5d                   	pop    %ebp
  80272b:	c3                   	ret    
  80272c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802730:	8b 34 24             	mov    (%esp),%esi
  802733:	bf 20 00 00 00       	mov    $0x20,%edi
  802738:	89 e9                	mov    %ebp,%ecx
  80273a:	29 ef                	sub    %ebp,%edi
  80273c:	d3 e0                	shl    %cl,%eax
  80273e:	89 f9                	mov    %edi,%ecx
  802740:	89 f2                	mov    %esi,%edx
  802742:	d3 ea                	shr    %cl,%edx
  802744:	89 e9                	mov    %ebp,%ecx
  802746:	09 c2                	or     %eax,%edx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 14 24             	mov    %edx,(%esp)
  80274d:	89 f2                	mov    %esi,%edx
  80274f:	d3 e2                	shl    %cl,%edx
  802751:	89 f9                	mov    %edi,%ecx
  802753:	89 54 24 04          	mov    %edx,0x4(%esp)
  802757:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80275b:	d3 e8                	shr    %cl,%eax
  80275d:	89 e9                	mov    %ebp,%ecx
  80275f:	89 c6                	mov    %eax,%esi
  802761:	d3 e3                	shl    %cl,%ebx
  802763:	89 f9                	mov    %edi,%ecx
  802765:	89 d0                	mov    %edx,%eax
  802767:	d3 e8                	shr    %cl,%eax
  802769:	89 e9                	mov    %ebp,%ecx
  80276b:	09 d8                	or     %ebx,%eax
  80276d:	89 d3                	mov    %edx,%ebx
  80276f:	89 f2                	mov    %esi,%edx
  802771:	f7 34 24             	divl   (%esp)
  802774:	89 d6                	mov    %edx,%esi
  802776:	d3 e3                	shl    %cl,%ebx
  802778:	f7 64 24 04          	mull   0x4(%esp)
  80277c:	39 d6                	cmp    %edx,%esi
  80277e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802782:	89 d1                	mov    %edx,%ecx
  802784:	89 c3                	mov    %eax,%ebx
  802786:	72 08                	jb     802790 <__umoddi3+0x110>
  802788:	75 11                	jne    80279b <__umoddi3+0x11b>
  80278a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80278e:	73 0b                	jae    80279b <__umoddi3+0x11b>
  802790:	2b 44 24 04          	sub    0x4(%esp),%eax
  802794:	1b 14 24             	sbb    (%esp),%edx
  802797:	89 d1                	mov    %edx,%ecx
  802799:	89 c3                	mov    %eax,%ebx
  80279b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80279f:	29 da                	sub    %ebx,%edx
  8027a1:	19 ce                	sbb    %ecx,%esi
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 f0                	mov    %esi,%eax
  8027a7:	d3 e0                	shl    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	d3 ea                	shr    %cl,%edx
  8027ad:	89 e9                	mov    %ebp,%ecx
  8027af:	d3 ee                	shr    %cl,%esi
  8027b1:	09 d0                	or     %edx,%eax
  8027b3:	89 f2                	mov    %esi,%edx
  8027b5:	83 c4 1c             	add    $0x1c,%esp
  8027b8:	5b                   	pop    %ebx
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    
  8027bd:	8d 76 00             	lea    0x0(%esi),%esi
  8027c0:	29 f9                	sub    %edi,%ecx
  8027c2:	19 d6                	sbb    %edx,%esi
  8027c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027cc:	e9 18 ff ff ff       	jmp    8026e9 <__umoddi3+0x69>
