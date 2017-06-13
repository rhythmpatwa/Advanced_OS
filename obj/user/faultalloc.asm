
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 80 23 80 00       	push   $0x802380
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 4d 0b 00 00       	call   800bab <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 a0 23 80 00       	push   $0x8023a0
  80006f:	6a 0e                	push   $0xe
  800071:	68 8a 23 80 00       	push   $0x80238a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 cc 23 80 00       	push   $0x8023cc
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 cc 06 00 00       	call   800755 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 1a 0d 00 00       	call   800dbb <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 9c 23 80 00       	push   $0x80239c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 9c 23 80 00       	push   $0x80239c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000d5:	e8 93 0a 00 00       	call   800b6d <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 01 0f 00 00       	call   80101c <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 07 0a 00 00       	call   800b2c <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 30 0a 00 00       	call   800b6d <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 f8 23 80 00       	push   $0x8023f8
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 63 28 80 00 	movl   $0x802863,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 4f 09 00 00       	call   800aef <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 54 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 f4 08 00 00       	call   800aef <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 85 1e 00 00       	call   8020f0 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 72 1f 00 00       	call   802220 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 1b 24 80 00 	movsbl 0x80241b(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800323:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 05 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 2c             	sub    $0x2c,%esp
  800343:	8b 75 08             	mov    0x8(%ebp),%esi
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 a9 03 00 00    	je     8006ff <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	ff d6                	call   *%esi
  80035d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800360:	83 c7 01             	add    $0x1,%edi
  800363:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e2                	jne    80034e <vprintfmt+0x14>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 07                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8d 47 01             	lea    0x1(%edi),%eax
  800396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800399:	0f b6 07             	movzbl (%edi),%eax
  80039c:	0f b6 c8             	movzbl %al,%ecx
  80039f:	83 e8 23             	sub    $0x23,%eax
  8003a2:	3c 55                	cmp    $0x55,%al
  8003a4:	0f 87 3a 03 00 00    	ja     8006e4 <vprintfmt+0x3aa>
  8003aa:	0f b6 c0             	movzbl %al,%eax
  8003ad:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bb:	eb d6                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	77 39                	ja     800413 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003da:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003dd:	eb e9                	jmp    8003c8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f0:	eb 27                	jmp    800419 <vprintfmt+0xdf>
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	0f 49 c8             	cmovns %eax,%ecx
  8003ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800405:	eb 8c                	jmp    800393 <vprintfmt+0x59>
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800411:	eb 80                	jmp    800393 <vprintfmt+0x59>
  800413:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800416:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041d:	0f 89 70 ff ff ff    	jns    800393 <vprintfmt+0x59>
				width = precision, precision = -1;
  800423:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800429:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800430:	e9 5e ff ff ff       	jmp    800393 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800435:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043b:	e9 53 ff ff ff       	jmp    800393 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	53                   	push   %ebx
  80044d:	ff 30                	pushl  (%eax)
  80044f:	ff d6                	call   *%esi
			break;
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800457:	e9 04 ff ff ff       	jmp    800360 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	99                   	cltd   
  800468:	31 d0                	xor    %edx,%eax
  80046a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046c:	83 f8 0f             	cmp    $0xf,%eax
  80046f:	7f 0b                	jg     80047c <vprintfmt+0x142>
  800471:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	75 18                	jne    800494 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 33 24 80 00       	push   $0x802433
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 94 fe ff ff       	call   80031d <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048f:	e9 cc fe ff ff       	jmp    800360 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800494:	52                   	push   %edx
  800495:	68 31 28 80 00       	push   $0x802831
  80049a:	53                   	push   %ebx
  80049b:	56                   	push   %esi
  80049c:	e8 7c fe ff ff       	call   80031d <printfmt>
  8004a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a7:	e9 b4 fe ff ff       	jmp    800360 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 50 04             	lea    0x4(%eax),%edx
  8004b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 2c 24 80 00       	mov    $0x80242c,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x225>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 a6 02 00 00       	call   800787 <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1c0>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x213>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x213>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x23f>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x23f>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x270>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1f2>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1f2>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x278>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	e9 a2 fd ff ff       	jmp    800360 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005be:	83 fa 01             	cmp    $0x1,%edx
  8005c1:	7e 16                	jle    8005d9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 08             	lea    0x8(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	eb 32                	jmp    80060b <vprintfmt+0x2d1>
	else if (lflag)
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 18                	je     8005f5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005eb:	89 c1                	mov    %eax,%ecx
  8005ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f3:	eb 16                	jmp    80060b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800611:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800616:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061a:	0f 89 90 00 00 00    	jns    8006b0 <vprintfmt+0x376>
				putch('-', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 2d                	push   $0x2d
  800626:	ff d6                	call   *%esi
				num = -(long long) num;
  800628:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062e:	f7 d8                	neg    %eax
  800630:	83 d2 00             	adc    $0x0,%edx
  800633:	f7 da                	neg    %edx
  800635:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063d:	eb 71                	jmp    8006b0 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 7f fc ff ff       	call   8002c6 <getuint>
			base = 10;
  800647:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80064c:	eb 62                	jmp    8006b0 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 70 fc ff ff       	call   8002c6 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800656:	83 ec 0c             	sub    $0xc,%esp
  800659:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80065d:	51                   	push   %ecx
  80065e:	ff 75 e0             	pushl  -0x20(%ebp)
  800661:	6a 08                	push   $0x8
  800663:	52                   	push   %edx
  800664:	50                   	push   %eax
  800665:	89 da                	mov    %ebx,%edx
  800667:	89 f0                	mov    %esi,%eax
  800669:	e8 a9 fb ff ff       	call   800217 <printnum>
			break;
  80066e:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800674:	e9 e7 fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 30                	push   $0x30
  80067f:	ff d6                	call   *%esi
			putch('x', putdat);
  800681:	83 c4 08             	add    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 78                	push   $0x78
  800687:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800692:	8b 00                	mov    (%eax),%eax
  800694:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800699:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80069c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a1:	eb 0d                	jmp    8006b0 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 1b fc ff ff       	call   8002c6 <getuint>
			base = 16;
  8006ab:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b7:	57                   	push   %edi
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	51                   	push   %ecx
  8006bc:	52                   	push   %edx
  8006bd:	50                   	push   %eax
  8006be:	89 da                	mov    %ebx,%edx
  8006c0:	89 f0                	mov    %esi,%eax
  8006c2:	e8 50 fb ff ff       	call   800217 <printnum>
			break;
  8006c7:	83 c4 20             	add    $0x20,%esp
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cd:	e9 8e fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	51                   	push   %ecx
  8006d7:	ff d6                	call   *%esi
			break;
  8006d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006df:	e9 7c fc ff ff       	jmp    800360 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	6a 25                	push   $0x25
  8006ea:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 03                	jmp    8006f4 <vprintfmt+0x3ba>
  8006f1:	83 ef 01             	sub    $0x1,%edi
  8006f4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f8:	75 f7                	jne    8006f1 <vprintfmt+0x3b7>
  8006fa:	e9 61 fc ff ff       	jmp    800360 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 26                	je     80074e <vsnprintf+0x47>
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e 22                	jle    80074e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072c:	ff 75 14             	pushl  0x14(%ebp)
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	68 00 03 80 00       	push   $0x800300
  80073b:	e8 fa fb ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 05                	jmp    800753 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	50                   	push   %eax
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	ff 75 08             	pushl  0x8(%ebp)
  800768:	e8 9a ff ff ff       	call   800707 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	eb 03                	jmp    80077f <strlen+0x10>
		n++;
  80077c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800783:	75 f7                	jne    80077c <strlen+0xd>
		n++;
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800790:	ba 00 00 00 00       	mov    $0x0,%edx
  800795:	eb 03                	jmp    80079a <strnlen+0x13>
		n++;
  800797:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079a:	39 c2                	cmp    %eax,%edx
  80079c:	74 08                	je     8007a6 <strnlen+0x1f>
  80079e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a2:	75 f3                	jne    800797 <strnlen+0x10>
  8007a4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	83 c2 01             	add    $0x1,%edx
  8007b7:	83 c1 01             	add    $0x1,%ecx
  8007ba:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007be:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c1:	84 db                	test   %bl,%bl
  8007c3:	75 ef                	jne    8007b4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cf:	53                   	push   %ebx
  8007d0:	e8 9a ff ff ff       	call   80076f <strlen>
  8007d5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	01 d8                	add    %ebx,%eax
  8007dd:	50                   	push   %eax
  8007de:	e8 c5 ff ff ff       	call   8007a8 <strcpy>
	return dst;
}
  8007e3:	89 d8                	mov    %ebx,%eax
  8007e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    

008007ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	56                   	push   %esi
  8007ee:	53                   	push   %ebx
  8007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f5:	89 f3                	mov    %esi,%ebx
  8007f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fa:	89 f2                	mov    %esi,%edx
  8007fc:	eb 0f                	jmp    80080d <strncpy+0x23>
		*dst++ = *src;
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	0f b6 01             	movzbl (%ecx),%eax
  800804:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800807:	80 39 01             	cmpb   $0x1,(%ecx)
  80080a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080d:	39 da                	cmp    %ebx,%edx
  80080f:	75 ed                	jne    8007fe <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800811:	89 f0                	mov    %esi,%eax
  800813:	5b                   	pop    %ebx
  800814:	5e                   	pop    %esi
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800817:	55                   	push   %ebp
  800818:	89 e5                	mov    %esp,%ebp
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	8b 75 08             	mov    0x8(%ebp),%esi
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	8b 55 10             	mov    0x10(%ebp),%edx
  800825:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800827:	85 d2                	test   %edx,%edx
  800829:	74 21                	je     80084c <strlcpy+0x35>
  80082b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082f:	89 f2                	mov    %esi,%edx
  800831:	eb 09                	jmp    80083c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800833:	83 c2 01             	add    $0x1,%edx
  800836:	83 c1 01             	add    $0x1,%ecx
  800839:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80083c:	39 c2                	cmp    %eax,%edx
  80083e:	74 09                	je     800849 <strlcpy+0x32>
  800840:	0f b6 19             	movzbl (%ecx),%ebx
  800843:	84 db                	test   %bl,%bl
  800845:	75 ec                	jne    800833 <strlcpy+0x1c>
  800847:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800849:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084c:	29 f0                	sub    %esi,%eax
}
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085b:	eb 06                	jmp    800863 <strcmp+0x11>
		p++, q++;
  80085d:	83 c1 01             	add    $0x1,%ecx
  800860:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800863:	0f b6 01             	movzbl (%ecx),%eax
  800866:	84 c0                	test   %al,%al
  800868:	74 04                	je     80086e <strcmp+0x1c>
  80086a:	3a 02                	cmp    (%edx),%al
  80086c:	74 ef                	je     80085d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086e:	0f b6 c0             	movzbl %al,%eax
  800871:	0f b6 12             	movzbl (%edx),%edx
  800874:	29 d0                	sub    %edx,%eax
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	53                   	push   %ebx
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800882:	89 c3                	mov    %eax,%ebx
  800884:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800887:	eb 06                	jmp    80088f <strncmp+0x17>
		n--, p++, q++;
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088f:	39 d8                	cmp    %ebx,%eax
  800891:	74 15                	je     8008a8 <strncmp+0x30>
  800893:	0f b6 08             	movzbl (%eax),%ecx
  800896:	84 c9                	test   %cl,%cl
  800898:	74 04                	je     80089e <strncmp+0x26>
  80089a:	3a 0a                	cmp    (%edx),%cl
  80089c:	74 eb                	je     800889 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 00             	movzbl (%eax),%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
  8008a6:	eb 05                	jmp    8008ad <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ba:	eb 07                	jmp    8008c3 <strchr+0x13>
		if (*s == c)
  8008bc:	38 ca                	cmp    %cl,%dl
  8008be:	74 0f                	je     8008cf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c0:	83 c0 01             	add    $0x1,%eax
  8008c3:	0f b6 10             	movzbl (%eax),%edx
  8008c6:	84 d2                	test   %dl,%dl
  8008c8:	75 f2                	jne    8008bc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008db:	eb 03                	jmp    8008e0 <strfind+0xf>
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e3:	38 ca                	cmp    %cl,%dl
  8008e5:	74 04                	je     8008eb <strfind+0x1a>
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	75 f2                	jne    8008dd <strfind+0xc>
			break;
	return (char *) s;
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f9:	85 c9                	test   %ecx,%ecx
  8008fb:	74 36                	je     800933 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800903:	75 28                	jne    80092d <memset+0x40>
  800905:	f6 c1 03             	test   $0x3,%cl
  800908:	75 23                	jne    80092d <memset+0x40>
		c &= 0xFF;
  80090a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090e:	89 d3                	mov    %edx,%ebx
  800910:	c1 e3 08             	shl    $0x8,%ebx
  800913:	89 d6                	mov    %edx,%esi
  800915:	c1 e6 18             	shl    $0x18,%esi
  800918:	89 d0                	mov    %edx,%eax
  80091a:	c1 e0 10             	shl    $0x10,%eax
  80091d:	09 f0                	or     %esi,%eax
  80091f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800921:	89 d8                	mov    %ebx,%eax
  800923:	09 d0                	or     %edx,%eax
  800925:	c1 e9 02             	shr    $0x2,%ecx
  800928:	fc                   	cld    
  800929:	f3 ab                	rep stos %eax,%es:(%edi)
  80092b:	eb 06                	jmp    800933 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800930:	fc                   	cld    
  800931:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800933:	89 f8                	mov    %edi,%eax
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5f                   	pop    %edi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	8b 45 08             	mov    0x8(%ebp),%eax
  800942:	8b 75 0c             	mov    0xc(%ebp),%esi
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800948:	39 c6                	cmp    %eax,%esi
  80094a:	73 35                	jae    800981 <memmove+0x47>
  80094c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094f:	39 d0                	cmp    %edx,%eax
  800951:	73 2e                	jae    800981 <memmove+0x47>
		s += n;
		d += n;
  800953:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	89 d6                	mov    %edx,%esi
  800958:	09 fe                	or     %edi,%esi
  80095a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800960:	75 13                	jne    800975 <memmove+0x3b>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0e                	jne    800975 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800967:	83 ef 04             	sub    $0x4,%edi
  80096a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096d:	c1 e9 02             	shr    $0x2,%ecx
  800970:	fd                   	std    
  800971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800973:	eb 09                	jmp    80097e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800975:	83 ef 01             	sub    $0x1,%edi
  800978:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097b:	fd                   	std    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097e:	fc                   	cld    
  80097f:	eb 1d                	jmp    80099e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	89 f2                	mov    %esi,%edx
  800983:	09 c2                	or     %eax,%edx
  800985:	f6 c2 03             	test   $0x3,%dl
  800988:	75 0f                	jne    800999 <memmove+0x5f>
  80098a:	f6 c1 03             	test   $0x3,%cl
  80098d:	75 0a                	jne    800999 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098f:	c1 e9 02             	shr    $0x2,%ecx
  800992:	89 c7                	mov    %eax,%edi
  800994:	fc                   	cld    
  800995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800997:	eb 05                	jmp    80099e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800999:	89 c7                	mov    %eax,%edi
  80099b:	fc                   	cld    
  80099c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099e:	5e                   	pop    %esi
  80099f:	5f                   	pop    %edi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a5:	ff 75 10             	pushl  0x10(%ebp)
  8009a8:	ff 75 0c             	pushl  0xc(%ebp)
  8009ab:	ff 75 08             	pushl  0x8(%ebp)
  8009ae:	e8 87 ff ff ff       	call   80093a <memmove>
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c0:	89 c6                	mov    %eax,%esi
  8009c2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c5:	eb 1a                	jmp    8009e1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009c7:	0f b6 08             	movzbl (%eax),%ecx
  8009ca:	0f b6 1a             	movzbl (%edx),%ebx
  8009cd:	38 d9                	cmp    %bl,%cl
  8009cf:	74 0a                	je     8009db <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d1:	0f b6 c1             	movzbl %cl,%eax
  8009d4:	0f b6 db             	movzbl %bl,%ebx
  8009d7:	29 d8                	sub    %ebx,%eax
  8009d9:	eb 0f                	jmp    8009ea <memcmp+0x35>
		s1++, s2++;
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e1:	39 f0                	cmp    %esi,%eax
  8009e3:	75 e2                	jne    8009c7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f5:	89 c1                	mov    %eax,%ecx
  8009f7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fa:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fe:	eb 0a                	jmp    800a0a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a00:	0f b6 10             	movzbl (%eax),%edx
  800a03:	39 da                	cmp    %ebx,%edx
  800a05:	74 07                	je     800a0e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	39 c8                	cmp    %ecx,%eax
  800a0c:	72 f2                	jb     800a00 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	57                   	push   %edi
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1d:	eb 03                	jmp    800a22 <strtol+0x11>
		s++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a22:	0f b6 01             	movzbl (%ecx),%eax
  800a25:	3c 20                	cmp    $0x20,%al
  800a27:	74 f6                	je     800a1f <strtol+0xe>
  800a29:	3c 09                	cmp    $0x9,%al
  800a2b:	74 f2                	je     800a1f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2d:	3c 2b                	cmp    $0x2b,%al
  800a2f:	75 0a                	jne    800a3b <strtol+0x2a>
		s++;
  800a31:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
  800a39:	eb 11                	jmp    800a4c <strtol+0x3b>
  800a3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a40:	3c 2d                	cmp    $0x2d,%al
  800a42:	75 08                	jne    800a4c <strtol+0x3b>
		s++, neg = 1;
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a52:	75 15                	jne    800a69 <strtol+0x58>
  800a54:	80 39 30             	cmpb   $0x30,(%ecx)
  800a57:	75 10                	jne    800a69 <strtol+0x58>
  800a59:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5d:	75 7c                	jne    800adb <strtol+0xca>
		s += 2, base = 16;
  800a5f:	83 c1 02             	add    $0x2,%ecx
  800a62:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a67:	eb 16                	jmp    800a7f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a69:	85 db                	test   %ebx,%ebx
  800a6b:	75 12                	jne    800a7f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a72:	80 39 30             	cmpb   $0x30,(%ecx)
  800a75:	75 08                	jne    800a7f <strtol+0x6e>
		s++, base = 8;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a87:	0f b6 11             	movzbl (%ecx),%edx
  800a8a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 09             	cmp    $0x9,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x8b>
			dig = *s - '0';
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 30             	sub    $0x30,%edx
  800a9a:	eb 22                	jmp    800abe <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a9c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 57             	sub    $0x57,%edx
  800aac:	eb 10                	jmp    800abe <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aae:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 16                	ja     800ace <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abe:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac1:	7d 0b                	jge    800ace <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac3:	83 c1 01             	add    $0x1,%ecx
  800ac6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aca:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800acc:	eb b9                	jmp    800a87 <strtol+0x76>

	if (endptr)
  800ace:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad2:	74 0d                	je     800ae1 <strtol+0xd0>
		*endptr = (char *) s;
  800ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad7:	89 0e                	mov    %ecx,(%esi)
  800ad9:	eb 06                	jmp    800ae1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adb:	85 db                	test   %ebx,%ebx
  800add:	74 98                	je     800a77 <strtol+0x66>
  800adf:	eb 9e                	jmp    800a7f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae1:	89 c2                	mov    %eax,%edx
  800ae3:	f7 da                	neg    %edx
  800ae5:	85 ff                	test   %edi,%edi
  800ae7:	0f 45 c2             	cmovne %edx,%eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	89 c6                	mov    %eax,%esi
  800b06:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b13:	ba 00 00 00 00       	mov    $0x0,%edx
  800b18:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1d:	89 d1                	mov    %edx,%ecx
  800b1f:	89 d3                	mov    %edx,%ebx
  800b21:	89 d7                	mov    %edx,%edi
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b42:	89 cb                	mov    %ecx,%ebx
  800b44:	89 cf                	mov    %ecx,%edi
  800b46:	89 ce                	mov    %ecx,%esi
  800b48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4a:	85 c0                	test   %eax,%eax
  800b4c:	7e 17                	jle    800b65 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	50                   	push   %eax
  800b52:	6a 03                	push   $0x3
  800b54:	68 1f 27 80 00       	push   $0x80271f
  800b59:	6a 23                	push   $0x23
  800b5b:	68 3c 27 80 00       	push   $0x80273c
  800b60:	e8 c5 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b68:	5b                   	pop    %ebx
  800b69:	5e                   	pop    %esi
  800b6a:	5f                   	pop    %edi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7d:	89 d1                	mov    %edx,%ecx
  800b7f:	89 d3                	mov    %edx,%ebx
  800b81:	89 d7                	mov    %edx,%edi
  800b83:	89 d6                	mov    %edx,%esi
  800b85:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <sys_yield>:

void
sys_yield(void)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9c:	89 d1                	mov    %edx,%ecx
  800b9e:	89 d3                	mov    %edx,%ebx
  800ba0:	89 d7                	mov    %edx,%edi
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	be 00 00 00 00       	mov    $0x0,%esi
  800bb9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc7:	89 f7                	mov    %esi,%edi
  800bc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	7e 17                	jle    800be6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	50                   	push   %eax
  800bd3:	6a 04                	push   $0x4
  800bd5:	68 1f 27 80 00       	push   $0x80271f
  800bda:	6a 23                	push   $0x23
  800bdc:	68 3c 27 80 00       	push   $0x80273c
  800be1:	e8 44 f5 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	8b 55 08             	mov    0x8(%ebp),%edx
  800c02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c08:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7e 17                	jle    800c28 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	50                   	push   %eax
  800c15:	6a 05                	push   $0x5
  800c17:	68 1f 27 80 00       	push   $0x80271f
  800c1c:	6a 23                	push   $0x23
  800c1e:	68 3c 27 80 00       	push   $0x80273c
  800c23:	e8 02 f5 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 df                	mov    %ebx,%edi
  800c4b:	89 de                	mov    %ebx,%esi
  800c4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 17                	jle    800c6a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 06                	push   $0x6
  800c59:	68 1f 27 80 00       	push   $0x80271f
  800c5e:	6a 23                	push   $0x23
  800c60:	68 3c 27 80 00       	push   $0x80273c
  800c65:	e8 c0 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6d:	5b                   	pop    %ebx
  800c6e:	5e                   	pop    %esi
  800c6f:	5f                   	pop    %edi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	57                   	push   %edi
  800c76:	56                   	push   %esi
  800c77:	53                   	push   %ebx
  800c78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c80:	b8 08 00 00 00       	mov    $0x8,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 df                	mov    %ebx,%edi
  800c8d:	89 de                	mov    %ebx,%esi
  800c8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c91:	85 c0                	test   %eax,%eax
  800c93:	7e 17                	jle    800cac <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 08                	push   $0x8
  800c9b:	68 1f 27 80 00       	push   $0x80271f
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 3c 27 80 00       	push   $0x80273c
  800ca7:	e8 7e f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 df                	mov    %ebx,%edi
  800ccf:	89 de                	mov    %ebx,%esi
  800cd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	7e 17                	jle    800cee <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 09                	push   $0x9
  800cdd:	68 1f 27 80 00       	push   $0x80271f
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 3c 27 80 00       	push   $0x80273c
  800ce9:	e8 3c f4 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	57                   	push   %edi
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 df                	mov    %ebx,%edi
  800d11:	89 de                	mov    %ebx,%esi
  800d13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7e 17                	jle    800d30 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 0a                	push   $0xa
  800d1f:	68 1f 27 80 00       	push   $0x80271f
  800d24:	6a 23                	push   $0x23
  800d26:	68 3c 27 80 00       	push   $0x80273c
  800d2b:	e8 fa f3 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3e:	be 00 00 00 00       	mov    $0x0,%esi
  800d43:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d51:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d54:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d69:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	89 cb                	mov    %ecx,%ebx
  800d73:	89 cf                	mov    %ecx,%edi
  800d75:	89 ce                	mov    %ecx,%esi
  800d77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 0d                	push   $0xd
  800d83:	68 1f 27 80 00       	push   $0x80271f
  800d88:	6a 23                	push   $0x23
  800d8a:	68 3c 27 80 00       	push   $0x80273c
  800d8f:	e8 96 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da2:	ba 00 00 00 00       	mov    $0x0,%edx
  800da7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dac:	89 d1                	mov    %edx,%ecx
  800dae:	89 d3                	mov    %edx,%ebx
  800db0:	89 d7                	mov    %edx,%edi
  800db2:	89 d6                	mov    %edx,%esi
  800db4:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  800dc1:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800dc8:	75 56                	jne    800e20 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	6a 07                	push   $0x7
  800dcf:	68 00 f0 bf ee       	push   $0xeebff000
  800dd4:	6a 00                	push   $0x0
  800dd6:	e8 d0 fd ff ff       	call   800bab <sys_page_alloc>
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	74 14                	je     800df6 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	68 4a 27 80 00       	push   $0x80274a
  800dea:	6a 21                	push   $0x21
  800dec:	68 5f 27 80 00       	push   $0x80275f
  800df1:	e8 34 f3 ff ff       	call   80012a <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  800df6:	83 ec 08             	sub    $0x8,%esp
  800df9:	68 2a 0e 80 00       	push   $0x800e2a
  800dfe:	6a 00                	push   $0x0
  800e00:	e8 f1 fe ff ff       	call   800cf6 <sys_env_set_pgfault_upcall>
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	74 14                	je     800e20 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	68 6d 27 80 00       	push   $0x80276d
  800e14:	6a 23                	push   $0x23
  800e16:	68 5f 27 80 00       	push   $0x80275f
  800e1b:	e8 0a f3 ff ff       	call   80012a <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e2a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e2b:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e30:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e32:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  800e35:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  800e37:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  800e3b:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800e3f:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  800e40:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  800e42:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  800e47:	83 c4 08             	add    $0x8,%esp
	popal
  800e4a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800e4b:	83 c4 04             	add    $0x4,%esp
	popfl
  800e4e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e4f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e50:	c3                   	ret    

00800e51 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e71:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	c1 ea 16             	shr    $0x16,%edx
  800e88:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8f:	f6 c2 01             	test   $0x1,%dl
  800e92:	74 11                	je     800ea5 <fd_alloc+0x2d>
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 ea 0c             	shr    $0xc,%edx
  800e99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea0:	f6 c2 01             	test   $0x1,%dl
  800ea3:	75 09                	jne    800eae <fd_alloc+0x36>
			*fd_store = fd;
  800ea5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	eb 17                	jmp    800ec5 <fd_alloc+0x4d>
  800eae:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb8:	75 c9                	jne    800e83 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eba:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ecd:	83 f8 1f             	cmp    $0x1f,%eax
  800ed0:	77 36                	ja     800f08 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed2:	c1 e0 0c             	shl    $0xc,%eax
  800ed5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	c1 ea 16             	shr    $0x16,%edx
  800edf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee6:	f6 c2 01             	test   $0x1,%dl
  800ee9:	74 24                	je     800f0f <fd_lookup+0x48>
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	c1 ea 0c             	shr    $0xc,%edx
  800ef0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef7:	f6 c2 01             	test   $0x1,%dl
  800efa:	74 1a                	je     800f16 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800efc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eff:	89 02                	mov    %eax,(%edx)
	return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	eb 13                	jmp    800f1b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0d:	eb 0c                	jmp    800f1b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f14:	eb 05                	jmp    800f1b <fd_lookup+0x54>
  800f16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f26:	ba 04 28 80 00       	mov    $0x802804,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2b:	eb 13                	jmp    800f40 <dev_lookup+0x23>
  800f2d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f30:	39 08                	cmp    %ecx,(%eax)
  800f32:	75 0c                	jne    800f40 <dev_lookup+0x23>
			*dev = devtab[i];
  800f34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f37:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 2e                	jmp    800f6e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f40:	8b 02                	mov    (%edx),%eax
  800f42:	85 c0                	test   %eax,%eax
  800f44:	75 e7                	jne    800f2d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f46:	a1 08 40 80 00       	mov    0x804008,%eax
  800f4b:	8b 40 48             	mov    0x48(%eax),%eax
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	51                   	push   %ecx
  800f52:	50                   	push   %eax
  800f53:	68 84 27 80 00       	push   $0x802784
  800f58:	e8 a6 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 10             	sub    $0x10,%esp
  800f78:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f88:	c1 e8 0c             	shr    $0xc,%eax
  800f8b:	50                   	push   %eax
  800f8c:	e8 36 ff ff ff       	call   800ec7 <fd_lookup>
  800f91:	83 c4 08             	add    $0x8,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 05                	js     800f9d <fd_close+0x2d>
	    || fd != fd2)
  800f98:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f9b:	74 0c                	je     800fa9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f9d:	84 db                	test   %bl,%bl
  800f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa4:	0f 44 c2             	cmove  %edx,%eax
  800fa7:	eb 41                	jmp    800fea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	ff 36                	pushl  (%esi)
  800fb2:	e8 66 ff ff ff       	call   800f1d <dev_lookup>
  800fb7:	89 c3                	mov    %eax,%ebx
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 1a                	js     800fda <fd_close+0x6a>
		if (dev->dev_close)
  800fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	74 0b                	je     800fda <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	56                   	push   %esi
  800fd3:	ff d0                	call   *%eax
  800fd5:	89 c3                	mov    %eax,%ebx
  800fd7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	56                   	push   %esi
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 4b fc ff ff       	call   800c30 <sys_page_unmap>
	return r;
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	89 d8                	mov    %ebx,%eax
}
  800fea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 08             	pushl  0x8(%ebp)
  800ffe:	e8 c4 fe ff ff       	call   800ec7 <fd_lookup>
  801003:	83 c4 08             	add    $0x8,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 10                	js     80101a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80100a:	83 ec 08             	sub    $0x8,%esp
  80100d:	6a 01                	push   $0x1
  80100f:	ff 75 f4             	pushl  -0xc(%ebp)
  801012:	e8 59 ff ff ff       	call   800f70 <fd_close>
  801017:	83 c4 10             	add    $0x10,%esp
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <close_all>:

void
close_all(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801023:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	53                   	push   %ebx
  80102c:	e8 c0 ff ff ff       	call   800ff1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801031:	83 c3 01             	add    $0x1,%ebx
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	83 fb 20             	cmp    $0x20,%ebx
  80103a:	75 ec                	jne    801028 <close_all+0xc>
		close(i);
}
  80103c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 2c             	sub    $0x2c,%esp
  80104a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	ff 75 08             	pushl  0x8(%ebp)
  801054:	e8 6e fe ff ff       	call   800ec7 <fd_lookup>
  801059:	83 c4 08             	add    $0x8,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	0f 88 c1 00 00 00    	js     801125 <dup+0xe4>
		return r;
	close(newfdnum);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	56                   	push   %esi
  801068:	e8 84 ff ff ff       	call   800ff1 <close>

	newfd = INDEX2FD(newfdnum);
  80106d:	89 f3                	mov    %esi,%ebx
  80106f:	c1 e3 0c             	shl    $0xc,%ebx
  801072:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801078:	83 c4 04             	add    $0x4,%esp
  80107b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107e:	e8 de fd ff ff       	call   800e61 <fd2data>
  801083:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801085:	89 1c 24             	mov    %ebx,(%esp)
  801088:	e8 d4 fd ff ff       	call   800e61 <fd2data>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801093:	89 f8                	mov    %edi,%eax
  801095:	c1 e8 16             	shr    $0x16,%eax
  801098:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109f:	a8 01                	test   $0x1,%al
  8010a1:	74 37                	je     8010da <dup+0x99>
  8010a3:	89 f8                	mov    %edi,%eax
  8010a5:	c1 e8 0c             	shr    $0xc,%eax
  8010a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 26                	je     8010da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c3:	50                   	push   %eax
  8010c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c7:	6a 00                	push   $0x0
  8010c9:	57                   	push   %edi
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 1d fb ff ff       	call   800bee <sys_page_map>
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	83 c4 20             	add    $0x20,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 2e                	js     801108 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010dd:	89 d0                	mov    %edx,%eax
  8010df:	c1 e8 0c             	shr    $0xc,%eax
  8010e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f1:	50                   	push   %eax
  8010f2:	53                   	push   %ebx
  8010f3:	6a 00                	push   $0x0
  8010f5:	52                   	push   %edx
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 f1 fa ff ff       	call   800bee <sys_page_map>
  8010fd:	89 c7                	mov    %eax,%edi
  8010ff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801102:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801104:	85 ff                	test   %edi,%edi
  801106:	79 1d                	jns    801125 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801108:	83 ec 08             	sub    $0x8,%esp
  80110b:	53                   	push   %ebx
  80110c:	6a 00                	push   $0x0
  80110e:	e8 1d fb ff ff       	call   800c30 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801113:	83 c4 08             	add    $0x8,%esp
  801116:	ff 75 d4             	pushl  -0x2c(%ebp)
  801119:	6a 00                	push   $0x0
  80111b:	e8 10 fb ff ff       	call   800c30 <sys_page_unmap>
	return r;
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	89 f8                	mov    %edi,%eax
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	53                   	push   %ebx
  801131:	83 ec 14             	sub    $0x14,%esp
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801137:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	53                   	push   %ebx
  80113c:	e8 86 fd ff ff       	call   800ec7 <fd_lookup>
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	89 c2                	mov    %eax,%edx
  801146:	85 c0                	test   %eax,%eax
  801148:	78 6d                	js     8011b7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801154:	ff 30                	pushl  (%eax)
  801156:	e8 c2 fd ff ff       	call   800f1d <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 4c                	js     8011ae <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801162:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801165:	8b 42 08             	mov    0x8(%edx),%eax
  801168:	83 e0 03             	and    $0x3,%eax
  80116b:	83 f8 01             	cmp    $0x1,%eax
  80116e:	75 21                	jne    801191 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801170:	a1 08 40 80 00       	mov    0x804008,%eax
  801175:	8b 40 48             	mov    0x48(%eax),%eax
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	53                   	push   %ebx
  80117c:	50                   	push   %eax
  80117d:	68 c8 27 80 00       	push   $0x8027c8
  801182:	e8 7c f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118f:	eb 26                	jmp    8011b7 <read+0x8a>
	}
	if (!dev->dev_read)
  801191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801194:	8b 40 08             	mov    0x8(%eax),%eax
  801197:	85 c0                	test   %eax,%eax
  801199:	74 17                	je     8011b2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	ff 75 10             	pushl  0x10(%ebp)
  8011a1:	ff 75 0c             	pushl  0xc(%ebp)
  8011a4:	52                   	push   %edx
  8011a5:	ff d0                	call   *%eax
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	eb 09                	jmp    8011b7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	eb 05                	jmp    8011b7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011b7:	89 d0                	mov    %edx,%eax
  8011b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d2:	eb 21                	jmp    8011f5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	89 f0                	mov    %esi,%eax
  8011d9:	29 d8                	sub    %ebx,%eax
  8011db:	50                   	push   %eax
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	03 45 0c             	add    0xc(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	57                   	push   %edi
  8011e3:	e8 45 ff ff ff       	call   80112d <read>
		if (m < 0)
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 10                	js     8011ff <readn+0x41>
			return m;
		if (m == 0)
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	74 0a                	je     8011fd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f3:	01 c3                	add    %eax,%ebx
  8011f5:	39 f3                	cmp    %esi,%ebx
  8011f7:	72 db                	jb     8011d4 <readn+0x16>
  8011f9:	89 d8                	mov    %ebx,%eax
  8011fb:	eb 02                	jmp    8011ff <readn+0x41>
  8011fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	53                   	push   %ebx
  80120b:	83 ec 14             	sub    $0x14,%esp
  80120e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801211:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	53                   	push   %ebx
  801216:	e8 ac fc ff ff       	call   800ec7 <fd_lookup>
  80121b:	83 c4 08             	add    $0x8,%esp
  80121e:	89 c2                	mov    %eax,%edx
  801220:	85 c0                	test   %eax,%eax
  801222:	78 68                	js     80128c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	ff 30                	pushl  (%eax)
  801230:	e8 e8 fc ff ff       	call   800f1d <dev_lookup>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 47                	js     801283 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801243:	75 21                	jne    801266 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801245:	a1 08 40 80 00       	mov    0x804008,%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	53                   	push   %ebx
  801251:	50                   	push   %eax
  801252:	68 e4 27 80 00       	push   $0x8027e4
  801257:	e8 a7 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801264:	eb 26                	jmp    80128c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801266:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801269:	8b 52 0c             	mov    0xc(%edx),%edx
  80126c:	85 d2                	test   %edx,%edx
  80126e:	74 17                	je     801287 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	ff 75 10             	pushl  0x10(%ebp)
  801276:	ff 75 0c             	pushl  0xc(%ebp)
  801279:	50                   	push   %eax
  80127a:	ff d2                	call   *%edx
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	eb 09                	jmp    80128c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	89 c2                	mov    %eax,%edx
  801285:	eb 05                	jmp    80128c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801287:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80128c:	89 d0                	mov    %edx,%eax
  80128e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <seek>:

int
seek(int fdnum, off_t offset)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801299:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	ff 75 08             	pushl  0x8(%ebp)
  8012a0:	e8 22 fc ff ff       	call   800ec7 <fd_lookup>
  8012a5:	83 c4 08             	add    $0x8,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 0e                	js     8012ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 14             	sub    $0x14,%esp
  8012c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	53                   	push   %ebx
  8012cb:	e8 f7 fb ff ff       	call   800ec7 <fd_lookup>
  8012d0:	83 c4 08             	add    $0x8,%esp
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 65                	js     80133e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e3:	ff 30                	pushl  (%eax)
  8012e5:	e8 33 fc ff ff       	call   800f1d <dev_lookup>
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 44                	js     801335 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f8:	75 21                	jne    80131b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fa:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ff:	8b 40 48             	mov    0x48(%eax),%eax
  801302:	83 ec 04             	sub    $0x4,%esp
  801305:	53                   	push   %ebx
  801306:	50                   	push   %eax
  801307:	68 a4 27 80 00       	push   $0x8027a4
  80130c:	e8 f2 ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801319:	eb 23                	jmp    80133e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80131b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131e:	8b 52 18             	mov    0x18(%edx),%edx
  801321:	85 d2                	test   %edx,%edx
  801323:	74 14                	je     801339 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	ff 75 0c             	pushl  0xc(%ebp)
  80132b:	50                   	push   %eax
  80132c:	ff d2                	call   *%edx
  80132e:	89 c2                	mov    %eax,%edx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	eb 09                	jmp    80133e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801335:	89 c2                	mov    %eax,%edx
  801337:	eb 05                	jmp    80133e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801339:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80133e:	89 d0                	mov    %edx,%eax
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 14             	sub    $0x14,%esp
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 6c fb ff ff       	call   800ec7 <fd_lookup>
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	89 c2                	mov    %eax,%edx
  801360:	85 c0                	test   %eax,%eax
  801362:	78 58                	js     8013bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	ff 30                	pushl  (%eax)
  801370:	e8 a8 fb ff ff       	call   800f1d <dev_lookup>
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 37                	js     8013b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801383:	74 32                	je     8013b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801385:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801388:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138f:	00 00 00 
	stat->st_isdir = 0;
  801392:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801399:	00 00 00 
	stat->st_dev = dev;
  80139c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	53                   	push   %ebx
  8013a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a9:	ff 50 14             	call   *0x14(%eax)
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	eb 09                	jmp    8013bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	eb 05                	jmp    8013bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013bc:	89 d0                	mov    %edx,%eax
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	6a 00                	push   $0x0
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 ef 01 00 00       	call   8015c4 <open>
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 1b                	js     8013f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	ff 75 0c             	pushl  0xc(%ebp)
  8013e4:	50                   	push   %eax
  8013e5:	e8 5b ff ff ff       	call   801345 <fstat>
  8013ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ec:	89 1c 24             	mov    %ebx,(%esp)
  8013ef:	e8 fd fb ff ff       	call   800ff1 <close>
	return r;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	89 f0                	mov    %esi,%eax
}
  8013f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	56                   	push   %esi
  801404:	53                   	push   %ebx
  801405:	89 c6                	mov    %eax,%esi
  801407:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801409:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801410:	75 12                	jne    801424 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	6a 01                	push   $0x1
  801417:	e8 57 0c 00 00       	call   802073 <ipc_find_env>
  80141c:	a3 00 40 80 00       	mov    %eax,0x804000
  801421:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801424:	6a 07                	push   $0x7
  801426:	68 00 50 80 00       	push   $0x805000
  80142b:	56                   	push   %esi
  80142c:	ff 35 00 40 80 00    	pushl  0x804000
  801432:	e8 ed 0b 00 00       	call   802024 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801437:	83 c4 0c             	add    $0xc,%esp
  80143a:	6a 00                	push   $0x0
  80143c:	53                   	push   %ebx
  80143d:	6a 00                	push   $0x0
  80143f:	e8 6a 0b 00 00       	call   801fae <ipc_recv>
}
  801444:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	8b 40 0c             	mov    0xc(%eax),%eax
  801457:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 02 00 00 00       	mov    $0x2,%eax
  80146e:	e8 8d ff ff ff       	call   801400 <fsipc>
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	8b 40 0c             	mov    0xc(%eax),%eax
  801481:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801486:	ba 00 00 00 00       	mov    $0x0,%edx
  80148b:	b8 06 00 00 00       	mov    $0x6,%eax
  801490:	e8 6b ff ff ff       	call   801400 <fsipc>
}
  801495:	c9                   	leave  
  801496:	c3                   	ret    

00801497 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	53                   	push   %ebx
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b6:	e8 45 ff ff ff       	call   801400 <fsipc>
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 2c                	js     8014eb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	68 00 50 80 00       	push   $0x805000
  8014c7:	53                   	push   %ebx
  8014c8:	e8 db f2 ff ff       	call   8007a8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014cd:	a1 80 50 80 00       	mov    0x805080,%eax
  8014d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d8:	a1 84 50 80 00       	mov    0x805084,%eax
  8014dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8014fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801500:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801506:	a3 04 50 80 00       	mov    %eax,0x805004
  80150b:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801510:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801515:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801518:	53                   	push   %ebx
  801519:	ff 75 0c             	pushl  0xc(%ebp)
  80151c:	68 08 50 80 00       	push   $0x805008
  801521:	e8 14 f4 ff ff       	call   80093a <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 04 00 00 00       	mov    $0x4,%eax
  801530:	e8 cb fe ff ff       	call   801400 <fsipc>
  801535:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801538:	85 c0                	test   %eax,%eax
  80153a:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  80153d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154a:	8b 45 08             	mov    0x8(%ebp),%eax
  80154d:	8b 40 0c             	mov    0xc(%eax),%eax
  801550:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801555:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80155b:	ba 00 00 00 00       	mov    $0x0,%edx
  801560:	b8 03 00 00 00       	mov    $0x3,%eax
  801565:	e8 96 fe ff ff       	call   801400 <fsipc>
  80156a:	89 c3                	mov    %eax,%ebx
  80156c:	85 c0                	test   %eax,%eax
  80156e:	78 4b                	js     8015bb <devfile_read+0x79>
		return r;
	assert(r <= n);
  801570:	39 c6                	cmp    %eax,%esi
  801572:	73 16                	jae    80158a <devfile_read+0x48>
  801574:	68 18 28 80 00       	push   $0x802818
  801579:	68 1f 28 80 00       	push   $0x80281f
  80157e:	6a 7c                	push   $0x7c
  801580:	68 34 28 80 00       	push   $0x802834
  801585:	e8 a0 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  80158a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80158f:	7e 16                	jle    8015a7 <devfile_read+0x65>
  801591:	68 3f 28 80 00       	push   $0x80283f
  801596:	68 1f 28 80 00       	push   $0x80281f
  80159b:	6a 7d                	push   $0x7d
  80159d:	68 34 28 80 00       	push   $0x802834
  8015a2:	e8 83 eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a7:	83 ec 04             	sub    $0x4,%esp
  8015aa:	50                   	push   %eax
  8015ab:	68 00 50 80 00       	push   $0x805000
  8015b0:	ff 75 0c             	pushl  0xc(%ebp)
  8015b3:	e8 82 f3 ff ff       	call   80093a <memmove>
	return r;
  8015b8:	83 c4 10             	add    $0x10,%esp
}
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5e                   	pop    %esi
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 20             	sub    $0x20,%esp
  8015cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ce:	53                   	push   %ebx
  8015cf:	e8 9b f1 ff ff       	call   80076f <strlen>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015dc:	7f 67                	jg     801645 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e4:	50                   	push   %eax
  8015e5:	e8 8e f8 ff ff       	call   800e78 <fd_alloc>
  8015ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8015ed:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 57                	js     80164a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	68 00 50 80 00       	push   $0x805000
  8015fc:	e8 a7 f1 ff ff       	call   8007a8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801601:	8b 45 0c             	mov    0xc(%ebp),%eax
  801604:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801609:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160c:	b8 01 00 00 00       	mov    $0x1,%eax
  801611:	e8 ea fd ff ff       	call   801400 <fsipc>
  801616:	89 c3                	mov    %eax,%ebx
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	79 14                	jns    801633 <open+0x6f>
		fd_close(fd, 0);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	6a 00                	push   $0x0
  801624:	ff 75 f4             	pushl  -0xc(%ebp)
  801627:	e8 44 f9 ff ff       	call   800f70 <fd_close>
		return r;
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	89 da                	mov    %ebx,%edx
  801631:	eb 17                	jmp    80164a <open+0x86>
	}

	return fd2num(fd);
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	ff 75 f4             	pushl  -0xc(%ebp)
  801639:	e8 13 f8 ff ff       	call   800e51 <fd2num>
  80163e:	89 c2                	mov    %eax,%edx
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	eb 05                	jmp    80164a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801645:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80164a:	89 d0                	mov    %edx,%eax
  80164c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164f:	c9                   	leave  
  801650:	c3                   	ret    

00801651 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 08 00 00 00       	mov    $0x8,%eax
  801661:	e8 9a fd ff ff       	call   801400 <fsipc>
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	56                   	push   %esi
  80166c:	53                   	push   %ebx
  80166d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801670:	83 ec 0c             	sub    $0xc,%esp
  801673:	ff 75 08             	pushl  0x8(%ebp)
  801676:	e8 e6 f7 ff ff       	call   800e61 <fd2data>
  80167b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80167d:	83 c4 08             	add    $0x8,%esp
  801680:	68 4b 28 80 00       	push   $0x80284b
  801685:	53                   	push   %ebx
  801686:	e8 1d f1 ff ff       	call   8007a8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80168b:	8b 46 04             	mov    0x4(%esi),%eax
  80168e:	2b 06                	sub    (%esi),%eax
  801690:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801696:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80169d:	00 00 00 
	stat->st_dev = &devpipe;
  8016a0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016a7:	30 80 00 
	return 0;
}
  8016aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8016af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b2:	5b                   	pop    %ebx
  8016b3:	5e                   	pop    %esi
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016c0:	53                   	push   %ebx
  8016c1:	6a 00                	push   $0x0
  8016c3:	e8 68 f5 ff ff       	call   800c30 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016c8:	89 1c 24             	mov    %ebx,(%esp)
  8016cb:	e8 91 f7 ff ff       	call   800e61 <fd2data>
  8016d0:	83 c4 08             	add    $0x8,%esp
  8016d3:	50                   	push   %eax
  8016d4:	6a 00                	push   $0x0
  8016d6:	e8 55 f5 ff ff       	call   800c30 <sys_page_unmap>
}
  8016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	57                   	push   %edi
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 1c             	sub    $0x1c,%esp
  8016e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016ec:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016ee:	a1 08 40 80 00       	mov    0x804008,%eax
  8016f3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016f6:	83 ec 0c             	sub    $0xc,%esp
  8016f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8016fc:	e8 ab 09 00 00       	call   8020ac <pageref>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	89 3c 24             	mov    %edi,(%esp)
  801706:	e8 a1 09 00 00       	call   8020ac <pageref>
  80170b:	83 c4 10             	add    $0x10,%esp
  80170e:	39 c3                	cmp    %eax,%ebx
  801710:	0f 94 c1             	sete   %cl
  801713:	0f b6 c9             	movzbl %cl,%ecx
  801716:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801719:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80171f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801722:	39 ce                	cmp    %ecx,%esi
  801724:	74 1b                	je     801741 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801726:	39 c3                	cmp    %eax,%ebx
  801728:	75 c4                	jne    8016ee <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80172a:	8b 42 58             	mov    0x58(%edx),%eax
  80172d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801730:	50                   	push   %eax
  801731:	56                   	push   %esi
  801732:	68 52 28 80 00       	push   $0x802852
  801737:	e8 c7 ea ff ff       	call   800203 <cprintf>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	eb ad                	jmp    8016ee <_pipeisclosed+0xe>
	}
}
  801741:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5f                   	pop    %edi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	57                   	push   %edi
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 28             	sub    $0x28,%esp
  801755:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801758:	56                   	push   %esi
  801759:	e8 03 f7 ff ff       	call   800e61 <fd2data>
  80175e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	bf 00 00 00 00       	mov    $0x0,%edi
  801768:	eb 4b                	jmp    8017b5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80176a:	89 da                	mov    %ebx,%edx
  80176c:	89 f0                	mov    %esi,%eax
  80176e:	e8 6d ff ff ff       	call   8016e0 <_pipeisclosed>
  801773:	85 c0                	test   %eax,%eax
  801775:	75 48                	jne    8017bf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801777:	e8 10 f4 ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80177c:	8b 43 04             	mov    0x4(%ebx),%eax
  80177f:	8b 0b                	mov    (%ebx),%ecx
  801781:	8d 51 20             	lea    0x20(%ecx),%edx
  801784:	39 d0                	cmp    %edx,%eax
  801786:	73 e2                	jae    80176a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80178f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801792:	89 c2                	mov    %eax,%edx
  801794:	c1 fa 1f             	sar    $0x1f,%edx
  801797:	89 d1                	mov    %edx,%ecx
  801799:	c1 e9 1b             	shr    $0x1b,%ecx
  80179c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80179f:	83 e2 1f             	and    $0x1f,%edx
  8017a2:	29 ca                	sub    %ecx,%edx
  8017a4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017ac:	83 c0 01             	add    $0x1,%eax
  8017af:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b2:	83 c7 01             	add    $0x1,%edi
  8017b5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017b8:	75 c2                	jne    80177c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8017bd:	eb 05                	jmp    8017c4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017bf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c7:	5b                   	pop    %ebx
  8017c8:	5e                   	pop    %esi
  8017c9:	5f                   	pop    %edi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	57                   	push   %edi
  8017d0:	56                   	push   %esi
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 18             	sub    $0x18,%esp
  8017d5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017d8:	57                   	push   %edi
  8017d9:	e8 83 f6 ff ff       	call   800e61 <fd2data>
  8017de:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e8:	eb 3d                	jmp    801827 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017ea:	85 db                	test   %ebx,%ebx
  8017ec:	74 04                	je     8017f2 <devpipe_read+0x26>
				return i;
  8017ee:	89 d8                	mov    %ebx,%eax
  8017f0:	eb 44                	jmp    801836 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017f2:	89 f2                	mov    %esi,%edx
  8017f4:	89 f8                	mov    %edi,%eax
  8017f6:	e8 e5 fe ff ff       	call   8016e0 <_pipeisclosed>
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	75 32                	jne    801831 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017ff:	e8 88 f3 ff ff       	call   800b8c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801804:	8b 06                	mov    (%esi),%eax
  801806:	3b 46 04             	cmp    0x4(%esi),%eax
  801809:	74 df                	je     8017ea <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80180b:	99                   	cltd   
  80180c:	c1 ea 1b             	shr    $0x1b,%edx
  80180f:	01 d0                	add    %edx,%eax
  801811:	83 e0 1f             	and    $0x1f,%eax
  801814:	29 d0                	sub    %edx,%eax
  801816:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80181b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80181e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801821:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801824:	83 c3 01             	add    $0x1,%ebx
  801827:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80182a:	75 d8                	jne    801804 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80182c:	8b 45 10             	mov    0x10(%ebp),%eax
  80182f:	eb 05                	jmp    801836 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801831:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801836:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5f                   	pop    %edi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801849:	50                   	push   %eax
  80184a:	e8 29 f6 ff ff       	call   800e78 <fd_alloc>
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	89 c2                	mov    %eax,%edx
  801854:	85 c0                	test   %eax,%eax
  801856:	0f 88 2c 01 00 00    	js     801988 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80185c:	83 ec 04             	sub    $0x4,%esp
  80185f:	68 07 04 00 00       	push   $0x407
  801864:	ff 75 f4             	pushl  -0xc(%ebp)
  801867:	6a 00                	push   $0x0
  801869:	e8 3d f3 ff ff       	call   800bab <sys_page_alloc>
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	89 c2                	mov    %eax,%edx
  801873:	85 c0                	test   %eax,%eax
  801875:	0f 88 0d 01 00 00    	js     801988 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80187b:	83 ec 0c             	sub    $0xc,%esp
  80187e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801881:	50                   	push   %eax
  801882:	e8 f1 f5 ff ff       	call   800e78 <fd_alloc>
  801887:	89 c3                	mov    %eax,%ebx
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	0f 88 e2 00 00 00    	js     801976 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801894:	83 ec 04             	sub    $0x4,%esp
  801897:	68 07 04 00 00       	push   $0x407
  80189c:	ff 75 f0             	pushl  -0x10(%ebp)
  80189f:	6a 00                	push   $0x0
  8018a1:	e8 05 f3 ff ff       	call   800bab <sys_page_alloc>
  8018a6:	89 c3                	mov    %eax,%ebx
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	0f 88 c3 00 00 00    	js     801976 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b9:	e8 a3 f5 ff ff       	call   800e61 <fd2data>
  8018be:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c0:	83 c4 0c             	add    $0xc,%esp
  8018c3:	68 07 04 00 00       	push   $0x407
  8018c8:	50                   	push   %eax
  8018c9:	6a 00                	push   $0x0
  8018cb:	e8 db f2 ff ff       	call   800bab <sys_page_alloc>
  8018d0:	89 c3                	mov    %eax,%ebx
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	0f 88 89 00 00 00    	js     801966 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e3:	e8 79 f5 ff ff       	call   800e61 <fd2data>
  8018e8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018ef:	50                   	push   %eax
  8018f0:	6a 00                	push   $0x0
  8018f2:	56                   	push   %esi
  8018f3:	6a 00                	push   $0x0
  8018f5:	e8 f4 f2 ff ff       	call   800bee <sys_page_map>
  8018fa:	89 c3                	mov    %eax,%ebx
  8018fc:	83 c4 20             	add    $0x20,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	78 55                	js     801958 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801903:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801909:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801911:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801918:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80191e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801921:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801923:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801926:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80192d:	83 ec 0c             	sub    $0xc,%esp
  801930:	ff 75 f4             	pushl  -0xc(%ebp)
  801933:	e8 19 f5 ff ff       	call   800e51 <fd2num>
  801938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80193d:	83 c4 04             	add    $0x4,%esp
  801940:	ff 75 f0             	pushl  -0x10(%ebp)
  801943:	e8 09 f5 ff ff       	call   800e51 <fd2num>
  801948:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	ba 00 00 00 00       	mov    $0x0,%edx
  801956:	eb 30                	jmp    801988 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	56                   	push   %esi
  80195c:	6a 00                	push   $0x0
  80195e:	e8 cd f2 ff ff       	call   800c30 <sys_page_unmap>
  801963:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801966:	83 ec 08             	sub    $0x8,%esp
  801969:	ff 75 f0             	pushl  -0x10(%ebp)
  80196c:	6a 00                	push   $0x0
  80196e:	e8 bd f2 ff ff       	call   800c30 <sys_page_unmap>
  801973:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	ff 75 f4             	pushl  -0xc(%ebp)
  80197c:	6a 00                	push   $0x0
  80197e:	e8 ad f2 ff ff       	call   800c30 <sys_page_unmap>
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801988:	89 d0                	mov    %edx,%eax
  80198a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5e                   	pop    %esi
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801997:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199a:	50                   	push   %eax
  80199b:	ff 75 08             	pushl  0x8(%ebp)
  80199e:	e8 24 f5 ff ff       	call   800ec7 <fd_lookup>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 18                	js     8019c2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b0:	e8 ac f4 ff ff       	call   800e61 <fd2data>
	return _pipeisclosed(fd, p);
  8019b5:	89 c2                	mov    %eax,%edx
  8019b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ba:	e8 21 fd ff ff       	call   8016e0 <_pipeisclosed>
  8019bf:	83 c4 10             	add    $0x10,%esp
}
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019ca:	68 6a 28 80 00       	push   $0x80286a
  8019cf:	ff 75 0c             	pushl  0xc(%ebp)
  8019d2:	e8 d1 ed ff ff       	call   8007a8 <strcpy>
	return 0;
}
  8019d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019dc:	c9                   	leave  
  8019dd:	c3                   	ret    

008019de <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 10             	sub    $0x10,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019e8:	53                   	push   %ebx
  8019e9:	e8 be 06 00 00       	call   8020ac <pageref>
  8019ee:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019f1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019f6:	83 f8 01             	cmp    $0x1,%eax
  8019f9:	75 10                	jne    801a0b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	ff 73 0c             	pushl  0xc(%ebx)
  801a01:	e8 c0 02 00 00       	call   801cc6 <nsipc_close>
  801a06:	89 c2                	mov    %eax,%edx
  801a08:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a0b:	89 d0                	mov    %edx,%eax
  801a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a18:	6a 00                	push   $0x0
  801a1a:	ff 75 10             	pushl  0x10(%ebp)
  801a1d:	ff 75 0c             	pushl  0xc(%ebp)
  801a20:	8b 45 08             	mov    0x8(%ebp),%eax
  801a23:	ff 70 0c             	pushl  0xc(%eax)
  801a26:	e8 78 03 00 00       	call   801da3 <nsipc_send>
}
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a33:	6a 00                	push   $0x0
  801a35:	ff 75 10             	pushl  0x10(%ebp)
  801a38:	ff 75 0c             	pushl  0xc(%ebp)
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	ff 70 0c             	pushl  0xc(%eax)
  801a41:	e8 f1 02 00 00       	call   801d37 <nsipc_recv>
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a4e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a51:	52                   	push   %edx
  801a52:	50                   	push   %eax
  801a53:	e8 6f f4 ff ff       	call   800ec7 <fd_lookup>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 17                	js     801a76 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a62:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a68:	39 08                	cmp    %ecx,(%eax)
  801a6a:	75 05                	jne    801a71 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6f:	eb 05                	jmp    801a76 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a71:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 1c             	sub    $0x1c,%esp
  801a80:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a85:	50                   	push   %eax
  801a86:	e8 ed f3 ff ff       	call   800e78 <fd_alloc>
  801a8b:	89 c3                	mov    %eax,%ebx
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	78 1b                	js     801aaf <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a94:	83 ec 04             	sub    $0x4,%esp
  801a97:	68 07 04 00 00       	push   $0x407
  801a9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9f:	6a 00                	push   $0x0
  801aa1:	e8 05 f1 ff ff       	call   800bab <sys_page_alloc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	85 c0                	test   %eax,%eax
  801aad:	79 10                	jns    801abf <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	56                   	push   %esi
  801ab3:	e8 0e 02 00 00       	call   801cc6 <nsipc_close>
		return r;
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	89 d8                	mov    %ebx,%eax
  801abd:	eb 24                	jmp    801ae3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801abf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ad4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	50                   	push   %eax
  801adb:	e8 71 f3 ff ff       	call   800e51 <fd2num>
  801ae0:	83 c4 10             	add    $0x10,%esp
}
  801ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	e8 50 ff ff ff       	call   801a48 <fd2sockid>
		return r;
  801af8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 1f                	js     801b1d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	ff 75 10             	pushl  0x10(%ebp)
  801b04:	ff 75 0c             	pushl  0xc(%ebp)
  801b07:	50                   	push   %eax
  801b08:	e8 12 01 00 00       	call   801c1f <nsipc_accept>
  801b0d:	83 c4 10             	add    $0x10,%esp
		return r;
  801b10:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 07                	js     801b1d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b16:	e8 5d ff ff ff       	call   801a78 <alloc_sockfd>
  801b1b:	89 c1                	mov    %eax,%ecx
}
  801b1d:	89 c8                	mov    %ecx,%eax
  801b1f:	c9                   	leave  
  801b20:	c3                   	ret    

00801b21 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b27:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2a:	e8 19 ff ff ff       	call   801a48 <fd2sockid>
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 12                	js     801b45 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b33:	83 ec 04             	sub    $0x4,%esp
  801b36:	ff 75 10             	pushl  0x10(%ebp)
  801b39:	ff 75 0c             	pushl  0xc(%ebp)
  801b3c:	50                   	push   %eax
  801b3d:	e8 2d 01 00 00       	call   801c6f <nsipc_bind>
  801b42:	83 c4 10             	add    $0x10,%esp
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <shutdown>:

int
shutdown(int s, int how)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	e8 f3 fe ff ff       	call   801a48 <fd2sockid>
  801b55:	85 c0                	test   %eax,%eax
  801b57:	78 0f                	js     801b68 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b59:	83 ec 08             	sub    $0x8,%esp
  801b5c:	ff 75 0c             	pushl  0xc(%ebp)
  801b5f:	50                   	push   %eax
  801b60:	e8 3f 01 00 00       	call   801ca4 <nsipc_shutdown>
  801b65:	83 c4 10             	add    $0x10,%esp
}
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    

00801b6a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b70:	8b 45 08             	mov    0x8(%ebp),%eax
  801b73:	e8 d0 fe ff ff       	call   801a48 <fd2sockid>
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	78 12                	js     801b8e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b7c:	83 ec 04             	sub    $0x4,%esp
  801b7f:	ff 75 10             	pushl  0x10(%ebp)
  801b82:	ff 75 0c             	pushl  0xc(%ebp)
  801b85:	50                   	push   %eax
  801b86:	e8 55 01 00 00       	call   801ce0 <nsipc_connect>
  801b8b:	83 c4 10             	add    $0x10,%esp
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <listen>:

int
listen(int s, int backlog)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b96:	8b 45 08             	mov    0x8(%ebp),%eax
  801b99:	e8 aa fe ff ff       	call   801a48 <fd2sockid>
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	78 0f                	js     801bb1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ba2:	83 ec 08             	sub    $0x8,%esp
  801ba5:	ff 75 0c             	pushl  0xc(%ebp)
  801ba8:	50                   	push   %eax
  801ba9:	e8 67 01 00 00       	call   801d15 <nsipc_listen>
  801bae:	83 c4 10             	add    $0x10,%esp
}
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bb9:	ff 75 10             	pushl  0x10(%ebp)
  801bbc:	ff 75 0c             	pushl  0xc(%ebp)
  801bbf:	ff 75 08             	pushl  0x8(%ebp)
  801bc2:	e8 3a 02 00 00       	call   801e01 <nsipc_socket>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	85 c0                	test   %eax,%eax
  801bcc:	78 05                	js     801bd3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bce:	e8 a5 fe ff ff       	call   801a78 <alloc_sockfd>
}
  801bd3:	c9                   	leave  
  801bd4:	c3                   	ret    

00801bd5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bde:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801be5:	75 12                	jne    801bf9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801be7:	83 ec 0c             	sub    $0xc,%esp
  801bea:	6a 02                	push   $0x2
  801bec:	e8 82 04 00 00       	call   802073 <ipc_find_env>
  801bf1:	a3 04 40 80 00       	mov    %eax,0x804004
  801bf6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bf9:	6a 07                	push   $0x7
  801bfb:	68 00 60 80 00       	push   $0x806000
  801c00:	53                   	push   %ebx
  801c01:	ff 35 04 40 80 00    	pushl  0x804004
  801c07:	e8 18 04 00 00       	call   802024 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c0c:	83 c4 0c             	add    $0xc,%esp
  801c0f:	6a 00                	push   $0x0
  801c11:	6a 00                	push   $0x0
  801c13:	6a 00                	push   $0x0
  801c15:	e8 94 03 00 00       	call   801fae <ipc_recv>
}
  801c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    

00801c1f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	56                   	push   %esi
  801c23:	53                   	push   %ebx
  801c24:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c2f:	8b 06                	mov    (%esi),%eax
  801c31:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c36:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3b:	e8 95 ff ff ff       	call   801bd5 <nsipc>
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 20                	js     801c66 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c46:	83 ec 04             	sub    $0x4,%esp
  801c49:	ff 35 10 60 80 00    	pushl  0x806010
  801c4f:	68 00 60 80 00       	push   $0x806000
  801c54:	ff 75 0c             	pushl  0xc(%ebp)
  801c57:	e8 de ec ff ff       	call   80093a <memmove>
		*addrlen = ret->ret_addrlen;
  801c5c:	a1 10 60 80 00       	mov    0x806010,%eax
  801c61:	89 06                	mov    %eax,(%esi)
  801c63:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	53                   	push   %ebx
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c79:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c81:	53                   	push   %ebx
  801c82:	ff 75 0c             	pushl  0xc(%ebp)
  801c85:	68 04 60 80 00       	push   $0x806004
  801c8a:	e8 ab ec ff ff       	call   80093a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c8f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c95:	b8 02 00 00 00       	mov    $0x2,%eax
  801c9a:	e8 36 ff ff ff       	call   801bd5 <nsipc>
}
  801c9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cba:	b8 03 00 00 00       	mov    $0x3,%eax
  801cbf:	e8 11 ff ff ff       	call   801bd5 <nsipc>
}
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <nsipc_close>:

int
nsipc_close(int s)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cd4:	b8 04 00 00 00       	mov    $0x4,%eax
  801cd9:	e8 f7 fe ff ff       	call   801bd5 <nsipc>
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 08             	sub    $0x8,%esp
  801ce7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cf2:	53                   	push   %ebx
  801cf3:	ff 75 0c             	pushl  0xc(%ebp)
  801cf6:	68 04 60 80 00       	push   $0x806004
  801cfb:	e8 3a ec ff ff       	call   80093a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d00:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d06:	b8 05 00 00 00       	mov    $0x5,%eax
  801d0b:	e8 c5 fe ff ff       	call   801bd5 <nsipc>
}
  801d10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    

00801d15 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d26:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d2b:	b8 06 00 00 00       	mov    $0x6,%eax
  801d30:	e8 a0 fe ff ff       	call   801bd5 <nsipc>
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	56                   	push   %esi
  801d3b:	53                   	push   %ebx
  801d3c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d42:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d47:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d4d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d50:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d55:	b8 07 00 00 00       	mov    $0x7,%eax
  801d5a:	e8 76 fe ff ff       	call   801bd5 <nsipc>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 35                	js     801d9a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d65:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d6a:	7f 04                	jg     801d70 <nsipc_recv+0x39>
  801d6c:	39 c6                	cmp    %eax,%esi
  801d6e:	7d 16                	jge    801d86 <nsipc_recv+0x4f>
  801d70:	68 76 28 80 00       	push   $0x802876
  801d75:	68 1f 28 80 00       	push   $0x80281f
  801d7a:	6a 62                	push   $0x62
  801d7c:	68 8b 28 80 00       	push   $0x80288b
  801d81:	e8 a4 e3 ff ff       	call   80012a <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d86:	83 ec 04             	sub    $0x4,%esp
  801d89:	50                   	push   %eax
  801d8a:	68 00 60 80 00       	push   $0x806000
  801d8f:	ff 75 0c             	pushl  0xc(%ebp)
  801d92:	e8 a3 eb ff ff       	call   80093a <memmove>
  801d97:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d9a:	89 d8                	mov    %ebx,%eax
  801d9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9f:	5b                   	pop    %ebx
  801da0:	5e                   	pop    %esi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	53                   	push   %ebx
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dad:	8b 45 08             	mov    0x8(%ebp),%eax
  801db0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801db5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dbb:	7e 16                	jle    801dd3 <nsipc_send+0x30>
  801dbd:	68 97 28 80 00       	push   $0x802897
  801dc2:	68 1f 28 80 00       	push   $0x80281f
  801dc7:	6a 6d                	push   $0x6d
  801dc9:	68 8b 28 80 00       	push   $0x80288b
  801dce:	e8 57 e3 ff ff       	call   80012a <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dd3:	83 ec 04             	sub    $0x4,%esp
  801dd6:	53                   	push   %ebx
  801dd7:	ff 75 0c             	pushl  0xc(%ebp)
  801dda:	68 0c 60 80 00       	push   $0x80600c
  801ddf:	e8 56 eb ff ff       	call   80093a <memmove>
	nsipcbuf.send.req_size = size;
  801de4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dea:	8b 45 14             	mov    0x14(%ebp),%eax
  801ded:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801df2:	b8 08 00 00 00       	mov    $0x8,%eax
  801df7:	e8 d9 fd ff ff       	call   801bd5 <nsipc>
}
  801dfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    

00801e01 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e01:	55                   	push   %ebp
  801e02:	89 e5                	mov    %esp,%ebp
  801e04:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e07:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e12:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e17:	8b 45 10             	mov    0x10(%ebp),%eax
  801e1a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e1f:	b8 09 00 00 00       	mov    $0x9,%eax
  801e24:	e8 ac fd ff ff       	call   801bd5 <nsipc>
}
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e3b:	68 a3 28 80 00       	push   $0x8028a3
  801e40:	ff 75 0c             	pushl  0xc(%ebp)
  801e43:	e8 60 e9 ff ff       	call   8007a8 <strcpy>
	return 0;
}
  801e48:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4d:	c9                   	leave  
  801e4e:	c3                   	ret    

00801e4f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	57                   	push   %edi
  801e53:	56                   	push   %esi
  801e54:	53                   	push   %ebx
  801e55:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e60:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e66:	eb 2d                	jmp    801e95 <devcons_write+0x46>
		m = n - tot;
  801e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e6b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e6d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e70:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e75:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e78:	83 ec 04             	sub    $0x4,%esp
  801e7b:	53                   	push   %ebx
  801e7c:	03 45 0c             	add    0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	57                   	push   %edi
  801e81:	e8 b4 ea ff ff       	call   80093a <memmove>
		sys_cputs(buf, m);
  801e86:	83 c4 08             	add    $0x8,%esp
  801e89:	53                   	push   %ebx
  801e8a:	57                   	push   %edi
  801e8b:	e8 5f ec ff ff       	call   800aef <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e90:	01 de                	add    %ebx,%esi
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e9a:	72 cc                	jb     801e68 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9f:	5b                   	pop    %ebx
  801ea0:	5e                   	pop    %esi
  801ea1:	5f                   	pop    %edi
  801ea2:	5d                   	pop    %ebp
  801ea3:	c3                   	ret    

00801ea4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 08             	sub    $0x8,%esp
  801eaa:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801eaf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eb3:	74 2a                	je     801edf <devcons_read+0x3b>
  801eb5:	eb 05                	jmp    801ebc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eb7:	e8 d0 ec ff ff       	call   800b8c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ebc:	e8 4c ec ff ff       	call   800b0d <sys_cgetc>
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	74 f2                	je     801eb7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ec5:	85 c0                	test   %eax,%eax
  801ec7:	78 16                	js     801edf <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec9:	83 f8 04             	cmp    $0x4,%eax
  801ecc:	74 0c                	je     801eda <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ed1:	88 02                	mov    %al,(%edx)
	return 1;
  801ed3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed8:	eb 05                	jmp    801edf <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eda:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801edf:	c9                   	leave  
  801ee0:	c3                   	ret    

00801ee1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ee1:	55                   	push   %ebp
  801ee2:	89 e5                	mov    %esp,%ebp
  801ee4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eed:	6a 01                	push   $0x1
  801eef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ef2:	50                   	push   %eax
  801ef3:	e8 f7 eb ff ff       	call   800aef <sys_cputs>
}
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	c9                   	leave  
  801efc:	c3                   	ret    

00801efd <getchar>:

int
getchar(void)
{
  801efd:	55                   	push   %ebp
  801efe:	89 e5                	mov    %esp,%ebp
  801f00:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f03:	6a 01                	push   $0x1
  801f05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f08:	50                   	push   %eax
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 1d f2 ff ff       	call   80112d <read>
	if (r < 0)
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 0f                	js     801f26 <getchar+0x29>
		return r;
	if (r < 1)
  801f17:	85 c0                	test   %eax,%eax
  801f19:	7e 06                	jle    801f21 <getchar+0x24>
		return -E_EOF;
	return c;
  801f1b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f1f:	eb 05                	jmp    801f26 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f21:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	ff 75 08             	pushl  0x8(%ebp)
  801f35:	e8 8d ef ff ff       	call   800ec7 <fd_lookup>
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 11                	js     801f52 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f44:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f4a:	39 10                	cmp    %edx,(%eax)
  801f4c:	0f 94 c0             	sete   %al
  801f4f:	0f b6 c0             	movzbl %al,%eax
}
  801f52:	c9                   	leave  
  801f53:	c3                   	ret    

00801f54 <opencons>:

int
opencons(void)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5d:	50                   	push   %eax
  801f5e:	e8 15 ef ff ff       	call   800e78 <fd_alloc>
  801f63:	83 c4 10             	add    $0x10,%esp
		return r;
  801f66:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 3e                	js     801faa <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f6c:	83 ec 04             	sub    $0x4,%esp
  801f6f:	68 07 04 00 00       	push   $0x407
  801f74:	ff 75 f4             	pushl  -0xc(%ebp)
  801f77:	6a 00                	push   $0x0
  801f79:	e8 2d ec ff ff       	call   800bab <sys_page_alloc>
  801f7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801f81:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f83:	85 c0                	test   %eax,%eax
  801f85:	78 23                	js     801faa <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f87:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f90:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f95:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	50                   	push   %eax
  801fa0:	e8 ac ee ff ff       	call   800e51 <fd2num>
  801fa5:	89 c2                	mov    %eax,%edx
  801fa7:	83 c4 10             	add    $0x10,%esp
}
  801faa:	89 d0                	mov    %edx,%eax
  801fac:	c9                   	leave  
  801fad:	c3                   	ret    

00801fae <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	56                   	push   %esi
  801fb2:	53                   	push   %ebx
  801fb3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	74 0e                	je     801fce <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	50                   	push   %eax
  801fc4:	e8 92 ed ff ff       	call   800d5b <sys_ipc_recv>
  801fc9:	83 c4 10             	add    $0x10,%esp
  801fcc:	eb 10                	jmp    801fde <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	68 00 00 c0 ee       	push   $0xeec00000
  801fd6:	e8 80 ed ff ff       	call   800d5b <sys_ipc_recv>
  801fdb:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	79 17                	jns    801ff9 <ipc_recv+0x4b>
		if(*from_env_store)
  801fe2:	83 3e 00             	cmpl   $0x0,(%esi)
  801fe5:	74 06                	je     801fed <ipc_recv+0x3f>
			*from_env_store = 0;
  801fe7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801fed:	85 db                	test   %ebx,%ebx
  801fef:	74 2c                	je     80201d <ipc_recv+0x6f>
			*perm_store = 0;
  801ff1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ff7:	eb 24                	jmp    80201d <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ff9:	85 f6                	test   %esi,%esi
  801ffb:	74 0a                	je     802007 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801ffd:	a1 08 40 80 00       	mov    0x804008,%eax
  802002:	8b 40 74             	mov    0x74(%eax),%eax
  802005:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802007:	85 db                	test   %ebx,%ebx
  802009:	74 0a                	je     802015 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80200b:	a1 08 40 80 00       	mov    0x804008,%eax
  802010:	8b 40 78             	mov    0x78(%eax),%eax
  802013:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802015:	a1 08 40 80 00       	mov    0x804008,%eax
  80201a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80201d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    

00802024 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	57                   	push   %edi
  802028:	56                   	push   %esi
  802029:	53                   	push   %ebx
  80202a:	83 ec 0c             	sub    $0xc,%esp
  80202d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802030:	8b 75 0c             	mov    0xc(%ebp),%esi
  802033:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802036:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802038:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  80203d:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802040:	e8 47 eb ff ff       	call   800b8c <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802045:	ff 75 14             	pushl  0x14(%ebp)
  802048:	53                   	push   %ebx
  802049:	56                   	push   %esi
  80204a:	57                   	push   %edi
  80204b:	e8 e8 ec ff ff       	call   800d38 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802050:	89 c2                	mov    %eax,%edx
  802052:	f7 d2                	not    %edx
  802054:	c1 ea 1f             	shr    $0x1f,%edx
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80205d:	0f 94 c1             	sete   %cl
  802060:	09 ca                	or     %ecx,%edx
  802062:	85 c0                	test   %eax,%eax
  802064:	0f 94 c0             	sete   %al
  802067:	38 c2                	cmp    %al,%dl
  802069:	77 d5                	ja     802040 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  80206b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206e:	5b                   	pop    %ebx
  80206f:	5e                   	pop    %esi
  802070:	5f                   	pop    %edi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80207e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802081:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802087:	8b 52 50             	mov    0x50(%edx),%edx
  80208a:	39 ca                	cmp    %ecx,%edx
  80208c:	75 0d                	jne    80209b <ipc_find_env+0x28>
			return envs[i].env_id;
  80208e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802091:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802096:	8b 40 48             	mov    0x48(%eax),%eax
  802099:	eb 0f                	jmp    8020aa <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80209b:	83 c0 01             	add    $0x1,%eax
  80209e:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a3:	75 d9                	jne    80207e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    

008020ac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020b2:	89 d0                	mov    %edx,%eax
  8020b4:	c1 e8 16             	shr    $0x16,%eax
  8020b7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020be:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c3:	f6 c1 01             	test   $0x1,%cl
  8020c6:	74 1d                	je     8020e5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020c8:	c1 ea 0c             	shr    $0xc,%edx
  8020cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020d2:	f6 c2 01             	test   $0x1,%dl
  8020d5:	74 0e                	je     8020e5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d7:	c1 ea 0c             	shr    $0xc,%edx
  8020da:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020e1:	ef 
  8020e2:	0f b7 c0             	movzwl %ax,%eax
}
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    
  8020e7:	66 90                	xchg   %ax,%ax
  8020e9:	66 90                	xchg   %ax,%ax
  8020eb:	66 90                	xchg   %ax,%ax
  8020ed:	66 90                	xchg   %ax,%ax
  8020ef:	90                   	nop

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 f6                	test   %esi,%esi
  802109:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80210d:	89 ca                	mov    %ecx,%edx
  80210f:	89 f8                	mov    %edi,%eax
  802111:	75 3d                	jne    802150 <__udivdi3+0x60>
  802113:	39 cf                	cmp    %ecx,%edi
  802115:	0f 87 c5 00 00 00    	ja     8021e0 <__udivdi3+0xf0>
  80211b:	85 ff                	test   %edi,%edi
  80211d:	89 fd                	mov    %edi,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f7                	div    %edi
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 c8                	mov    %ecx,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c1                	mov    %eax,%ecx
  802134:	89 d8                	mov    %ebx,%eax
  802136:	89 cf                	mov    %ecx,%edi
  802138:	f7 f5                	div    %ebp
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	39 ce                	cmp    %ecx,%esi
  802152:	77 74                	ja     8021c8 <__udivdi3+0xd8>
  802154:	0f bd fe             	bsr    %esi,%edi
  802157:	83 f7 1f             	xor    $0x1f,%edi
  80215a:	0f 84 98 00 00 00    	je     8021f8 <__udivdi3+0x108>
  802160:	bb 20 00 00 00       	mov    $0x20,%ebx
  802165:	89 f9                	mov    %edi,%ecx
  802167:	89 c5                	mov    %eax,%ebp
  802169:	29 fb                	sub    %edi,%ebx
  80216b:	d3 e6                	shl    %cl,%esi
  80216d:	89 d9                	mov    %ebx,%ecx
  80216f:	d3 ed                	shr    %cl,%ebp
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e0                	shl    %cl,%eax
  802175:	09 ee                	or     %ebp,%esi
  802177:	89 d9                	mov    %ebx,%ecx
  802179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217d:	89 d5                	mov    %edx,%ebp
  80217f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802183:	d3 ed                	shr    %cl,%ebp
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e2                	shl    %cl,%edx
  802189:	89 d9                	mov    %ebx,%ecx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	09 c2                	or     %eax,%edx
  80218f:	89 d0                	mov    %edx,%eax
  802191:	89 ea                	mov    %ebp,%edx
  802193:	f7 f6                	div    %esi
  802195:	89 d5                	mov    %edx,%ebp
  802197:	89 c3                	mov    %eax,%ebx
  802199:	f7 64 24 0c          	mull   0xc(%esp)
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	72 10                	jb     8021b1 <__udivdi3+0xc1>
  8021a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e6                	shl    %cl,%esi
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 07                	jae    8021b4 <__udivdi3+0xc4>
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	75 03                	jne    8021b4 <__udivdi3+0xc4>
  8021b1:	83 eb 01             	sub    $0x1,%ebx
  8021b4:	31 ff                	xor    %edi,%edi
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	89 fa                	mov    %edi,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	31 ff                	xor    %edi,%edi
  8021ca:	31 db                	xor    %ebx,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d8                	mov    %ebx,%eax
  8021e2:	f7 f7                	div    %edi
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 c3                	mov    %eax,%ebx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 fa                	mov    %edi,%edx
  8021ec:	83 c4 1c             	add    $0x1c,%esp
  8021ef:	5b                   	pop    %ebx
  8021f0:	5e                   	pop    %esi
  8021f1:	5f                   	pop    %edi
  8021f2:	5d                   	pop    %ebp
  8021f3:	c3                   	ret    
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	39 ce                	cmp    %ecx,%esi
  8021fa:	72 0c                	jb     802208 <__udivdi3+0x118>
  8021fc:	31 db                	xor    %ebx,%ebx
  8021fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802202:	0f 87 34 ff ff ff    	ja     80213c <__udivdi3+0x4c>
  802208:	bb 01 00 00 00       	mov    $0x1,%ebx
  80220d:	e9 2a ff ff ff       	jmp    80213c <__udivdi3+0x4c>
  802212:	66 90                	xchg   %ax,%ax
  802214:	66 90                	xchg   %ax,%ax
  802216:	66 90                	xchg   %ax,%ax
  802218:	66 90                	xchg   %ax,%ax
  80221a:	66 90                	xchg   %ax,%ax
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80222b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 d2                	test   %edx,%edx
  802239:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80223d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802241:	89 f3                	mov    %esi,%ebx
  802243:	89 3c 24             	mov    %edi,(%esp)
  802246:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224a:	75 1c                	jne    802268 <__umoddi3+0x48>
  80224c:	39 f7                	cmp    %esi,%edi
  80224e:	76 50                	jbe    8022a0 <__umoddi3+0x80>
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	f7 f7                	div    %edi
  802256:	89 d0                	mov    %edx,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	39 f2                	cmp    %esi,%edx
  80226a:	89 d0                	mov    %edx,%eax
  80226c:	77 52                	ja     8022c0 <__umoddi3+0xa0>
  80226e:	0f bd ea             	bsr    %edx,%ebp
  802271:	83 f5 1f             	xor    $0x1f,%ebp
  802274:	75 5a                	jne    8022d0 <__umoddi3+0xb0>
  802276:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80227a:	0f 82 e0 00 00 00    	jb     802360 <__umoddi3+0x140>
  802280:	39 0c 24             	cmp    %ecx,(%esp)
  802283:	0f 86 d7 00 00 00    	jbe    802360 <__umoddi3+0x140>
  802289:	8b 44 24 08          	mov    0x8(%esp),%eax
  80228d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802291:	83 c4 1c             	add    $0x1c,%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
  802299:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	89 fd                	mov    %edi,%ebp
  8022a4:	75 0b                	jne    8022b1 <__umoddi3+0x91>
  8022a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f7                	div    %edi
  8022af:	89 c5                	mov    %eax,%ebp
  8022b1:	89 f0                	mov    %esi,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f5                	div    %ebp
  8022b7:	89 c8                	mov    %ecx,%eax
  8022b9:	f7 f5                	div    %ebp
  8022bb:	89 d0                	mov    %edx,%eax
  8022bd:	eb 99                	jmp    802258 <__umoddi3+0x38>
  8022bf:	90                   	nop
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 1c             	add    $0x1c,%esp
  8022c7:	5b                   	pop    %ebx
  8022c8:	5e                   	pop    %esi
  8022c9:	5f                   	pop    %edi
  8022ca:	5d                   	pop    %ebp
  8022cb:	c3                   	ret    
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	8b 34 24             	mov    (%esp),%esi
  8022d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022d8:	89 e9                	mov    %ebp,%ecx
  8022da:	29 ef                	sub    %ebp,%edi
  8022dc:	d3 e0                	shl    %cl,%eax
  8022de:	89 f9                	mov    %edi,%ecx
  8022e0:	89 f2                	mov    %esi,%edx
  8022e2:	d3 ea                	shr    %cl,%edx
  8022e4:	89 e9                	mov    %ebp,%ecx
  8022e6:	09 c2                	or     %eax,%edx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 14 24             	mov    %edx,(%esp)
  8022ed:	89 f2                	mov    %esi,%edx
  8022ef:	d3 e2                	shl    %cl,%edx
  8022f1:	89 f9                	mov    %edi,%ecx
  8022f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022fb:	d3 e8                	shr    %cl,%eax
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	89 c6                	mov    %eax,%esi
  802301:	d3 e3                	shl    %cl,%ebx
  802303:	89 f9                	mov    %edi,%ecx
  802305:	89 d0                	mov    %edx,%eax
  802307:	d3 e8                	shr    %cl,%eax
  802309:	89 e9                	mov    %ebp,%ecx
  80230b:	09 d8                	or     %ebx,%eax
  80230d:	89 d3                	mov    %edx,%ebx
  80230f:	89 f2                	mov    %esi,%edx
  802311:	f7 34 24             	divl   (%esp)
  802314:	89 d6                	mov    %edx,%esi
  802316:	d3 e3                	shl    %cl,%ebx
  802318:	f7 64 24 04          	mull   0x4(%esp)
  80231c:	39 d6                	cmp    %edx,%esi
  80231e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802322:	89 d1                	mov    %edx,%ecx
  802324:	89 c3                	mov    %eax,%ebx
  802326:	72 08                	jb     802330 <__umoddi3+0x110>
  802328:	75 11                	jne    80233b <__umoddi3+0x11b>
  80232a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80232e:	73 0b                	jae    80233b <__umoddi3+0x11b>
  802330:	2b 44 24 04          	sub    0x4(%esp),%eax
  802334:	1b 14 24             	sbb    (%esp),%edx
  802337:	89 d1                	mov    %edx,%ecx
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80233f:	29 da                	sub    %ebx,%edx
  802341:	19 ce                	sbb    %ecx,%esi
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 f0                	mov    %esi,%eax
  802347:	d3 e0                	shl    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	d3 ea                	shr    %cl,%edx
  80234d:	89 e9                	mov    %ebp,%ecx
  80234f:	d3 ee                	shr    %cl,%esi
  802351:	09 d0                	or     %edx,%eax
  802353:	89 f2                	mov    %esi,%edx
  802355:	83 c4 1c             	add    $0x1c,%esp
  802358:	5b                   	pop    %ebx
  802359:	5e                   	pop    %esi
  80235a:	5f                   	pop    %edi
  80235b:	5d                   	pop    %ebp
  80235c:	c3                   	ret    
  80235d:	8d 76 00             	lea    0x0(%esi),%esi
  802360:	29 f9                	sub    %edi,%ecx
  802362:	19 d6                	sbb    %edx,%esi
  802364:	89 74 24 04          	mov    %esi,0x4(%esp)
  802368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80236c:	e9 18 ff ff ff       	jmp    802289 <__umoddi3+0x69>
