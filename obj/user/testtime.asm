
obj/user/testtime.debug:     file format elf32-i386


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
  80002c:	e8 c8 00 00 00       	call   8000f9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
#include <inc/lib.h>
#include <inc/x86.h>

void
sleep(int sec)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
	unsigned now = sys_time_msec();
  80003a:	e8 8c 0d 00 00       	call   800dcb <sys_time_msec>
	unsigned end = now + sec * 1000;
  80003f:	69 5d 08 e8 03 00 00 	imul   $0x3e8,0x8(%ebp),%ebx
  800046:	01 c3                	add    %eax,%ebx

	if ((int)now < 0 && (int)now > -MAXERROR)
  800048:	89 c2                	mov    %eax,%edx
  80004a:	c1 ea 1f             	shr    $0x1f,%edx
  80004d:	84 d2                	test   %dl,%dl
  80004f:	74 17                	je     800068 <sleep+0x35>
  800051:	83 f8 f1             	cmp    $0xfffffff1,%eax
  800054:	7c 12                	jl     800068 <sleep+0x35>
		panic("sys_time_msec: %e", (int)now);
  800056:	50                   	push   %eax
  800057:	68 20 23 80 00       	push   $0x802320
  80005c:	6a 0b                	push   $0xb
  80005e:	68 32 23 80 00       	push   $0x802332
  800063:	e8 f1 00 00 00       	call   800159 <_panic>
	if (end < now)
  800068:	39 d8                	cmp    %ebx,%eax
  80006a:	76 19                	jbe    800085 <sleep+0x52>
		panic("sleep: wrap");
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 42 23 80 00       	push   $0x802342
  800074:	6a 0d                	push   $0xd
  800076:	68 32 23 80 00       	push   $0x802332
  80007b:	e8 d9 00 00 00       	call   800159 <_panic>

	while (sys_time_msec() < end)
		sys_yield();
  800080:	e8 36 0b 00 00       	call   800bbb <sys_yield>
	if ((int)now < 0 && (int)now > -MAXERROR)
		panic("sys_time_msec: %e", (int)now);
	if (end < now)
		panic("sleep: wrap");

	while (sys_time_msec() < end)
  800085:	e8 41 0d 00 00       	call   800dcb <sys_time_msec>
  80008a:	39 c3                	cmp    %eax,%ebx
  80008c:	77 f2                	ja     800080 <sleep+0x4d>
		sys_yield();
}
  80008e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800091:	c9                   	leave  
  800092:	c3                   	ret    

00800093 <umain>:

void
umain(int argc, char **argv)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	53                   	push   %ebx
  800097:	83 ec 04             	sub    $0x4,%esp
  80009a:	bb 32 00 00 00       	mov    $0x32,%ebx
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();
  80009f:	e8 17 0b 00 00       	call   800bbb <sys_yield>
umain(int argc, char **argv)
{
	int i;

	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
  8000a4:	83 eb 01             	sub    $0x1,%ebx
  8000a7:	75 f6                	jne    80009f <umain+0xc>
		sys_yield();

	cprintf("starting count down: ");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 4e 23 80 00       	push   $0x80234e
  8000b1:	e8 7c 01 00 00       	call   800232 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
	for (i = 5; i >= 0; i--) {
  8000b9:	bb 05 00 00 00       	mov    $0x5,%ebx
		cprintf("%d ", i);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	53                   	push   %ebx
  8000c2:	68 64 23 80 00       	push   $0x802364
  8000c7:	e8 66 01 00 00       	call   800232 <cprintf>
		sleep(1);
  8000cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000d3:	e8 5b ff ff ff       	call   800033 <sleep>
	// Wait for the console to calm down
	for (i = 0; i < 50; i++)
		sys_yield();

	cprintf("starting count down: ");
	for (i = 5; i >= 0; i--) {
  8000d8:	83 eb 01             	sub    $0x1,%ebx
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	83 fb ff             	cmp    $0xffffffff,%ebx
  8000e1:	75 db                	jne    8000be <umain+0x2b>
		cprintf("%d ", i);
		sleep(1);
	}
	cprintf("\n");
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	68 ab 27 80 00       	push   $0x8027ab
  8000eb:	e8 42 01 00 00       	call   800232 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  8000f0:	cc                   	int3   
	breakpoint();
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800101:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800104:	e8 93 0a 00 00       	call   800b9c <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800109:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800111:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800116:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011b:	85 db                	test   %ebx,%ebx
  80011d:	7e 07                	jle    800126 <libmain+0x2d>
		binaryname = argv[0];
  80011f:	8b 06                	mov    (%esi),%eax
  800121:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	e8 63 ff ff ff       	call   800093 <umain>

	// exit gracefully
	exit();
  800130:	e8 0a 00 00 00       	call   80013f <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800145:	e8 6b 0e 00 00       	call   800fb5 <close_all>
	sys_env_destroy(0);
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	6a 00                	push   $0x0
  80014f:	e8 07 0a 00 00       	call   800b5b <sys_env_destroy>
}
  800154:	83 c4 10             	add    $0x10,%esp
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800161:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800167:	e8 30 0a 00 00       	call   800b9c <sys_getenvid>
  80016c:	83 ec 0c             	sub    $0xc,%esp
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	56                   	push   %esi
  800176:	50                   	push   %eax
  800177:	68 74 23 80 00       	push   $0x802374
  80017c:	e8 b1 00 00 00       	call   800232 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800181:	83 c4 18             	add    $0x18,%esp
  800184:	53                   	push   %ebx
  800185:	ff 75 10             	pushl  0x10(%ebp)
  800188:	e8 54 00 00 00       	call   8001e1 <vcprintf>
	cprintf("\n");
  80018d:	c7 04 24 ab 27 80 00 	movl   $0x8027ab,(%esp)
  800194:	e8 99 00 00 00       	call   800232 <cprintf>
  800199:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019c:	cc                   	int3   
  80019d:	eb fd                	jmp    80019c <_panic+0x43>

0080019f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a9:	8b 13                	mov    (%ebx),%edx
  8001ab:	8d 42 01             	lea    0x1(%edx),%eax
  8001ae:	89 03                	mov    %eax,(%ebx)
  8001b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bc:	75 1a                	jne    8001d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	68 ff 00 00 00       	push   $0xff
  8001c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c9:	50                   	push   %eax
  8001ca:	e8 4f 09 00 00       	call   800b1e <sys_cputs>
		b->idx = 0;
  8001cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    

008001e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f1:	00 00 00 
	b.cnt = 0;
  8001f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fe:	ff 75 0c             	pushl  0xc(%ebp)
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	68 9f 01 80 00       	push   $0x80019f
  800210:	e8 54 01 00 00       	call   800369 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800215:	83 c4 08             	add    $0x8,%esp
  800218:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	50                   	push   %eax
  800225:	e8 f4 08 00 00       	call   800b1e <sys_cputs>

	return b.cnt;
}
  80022a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800238:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023b:	50                   	push   %eax
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	e8 9d ff ff ff       	call   8001e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	57                   	push   %edi
  80024a:	56                   	push   %esi
  80024b:	53                   	push   %ebx
  80024c:	83 ec 1c             	sub    $0x1c,%esp
  80024f:	89 c7                	mov    %eax,%edi
  800251:	89 d6                	mov    %edx,%esi
  800253:	8b 45 08             	mov    0x8(%ebp),%eax
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800262:	bb 00 00 00 00       	mov    $0x0,%ebx
  800267:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026d:	39 d3                	cmp    %edx,%ebx
  80026f:	72 05                	jb     800276 <printnum+0x30>
  800271:	39 45 10             	cmp    %eax,0x10(%ebp)
  800274:	77 45                	ja     8002bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	ff 75 18             	pushl  0x18(%ebp)
  80027c:	8b 45 14             	mov    0x14(%ebp),%eax
  80027f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800282:	53                   	push   %ebx
  800283:	ff 75 10             	pushl  0x10(%ebp)
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028c:	ff 75 e0             	pushl  -0x20(%ebp)
  80028f:	ff 75 dc             	pushl  -0x24(%ebp)
  800292:	ff 75 d8             	pushl  -0x28(%ebp)
  800295:	e8 e6 1d 00 00       	call   802080 <__udivdi3>
  80029a:	83 c4 18             	add    $0x18,%esp
  80029d:	52                   	push   %edx
  80029e:	50                   	push   %eax
  80029f:	89 f2                	mov    %esi,%edx
  8002a1:	89 f8                	mov    %edi,%eax
  8002a3:	e8 9e ff ff ff       	call   800246 <printnum>
  8002a8:	83 c4 20             	add    $0x20,%esp
  8002ab:	eb 18                	jmp    8002c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	ff 75 18             	pushl  0x18(%ebp)
  8002b4:	ff d7                	call   *%edi
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	eb 03                	jmp    8002be <printnum+0x78>
  8002bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	85 db                	test   %ebx,%ebx
  8002c3:	7f e8                	jg     8002ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	56                   	push   %esi
  8002c9:	83 ec 04             	sub    $0x4,%esp
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d8:	e8 d3 1e 00 00       	call   8021b0 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 97 23 80 00 	movsbl 0x802397(%eax),%eax
  8002e7:	50                   	push   %eax
  8002e8:	ff d7                	call   *%edi
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f8:	83 fa 01             	cmp    $0x1,%edx
  8002fb:	7e 0e                	jle    80030b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 08             	lea    0x8(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	8b 52 04             	mov    0x4(%edx),%edx
  800309:	eb 22                	jmp    80032d <getuint+0x38>
	else if (lflag)
  80030b:	85 d2                	test   %edx,%edx
  80030d:	74 10                	je     80031f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
  80031d:	eb 0e                	jmp    80032d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031f:	8b 10                	mov    (%eax),%edx
  800321:	8d 4a 04             	lea    0x4(%edx),%ecx
  800324:	89 08                	mov    %ecx,(%eax)
  800326:	8b 02                	mov    (%edx),%eax
  800328:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800335:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800339:	8b 10                	mov    (%eax),%edx
  80033b:	3b 50 04             	cmp    0x4(%eax),%edx
  80033e:	73 0a                	jae    80034a <sprintputch+0x1b>
		*b->buf++ = ch;
  800340:	8d 4a 01             	lea    0x1(%edx),%ecx
  800343:	89 08                	mov    %ecx,(%eax)
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	88 02                	mov    %al,(%edx)
}
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800355:	50                   	push   %eax
  800356:	ff 75 10             	pushl  0x10(%ebp)
  800359:	ff 75 0c             	pushl  0xc(%ebp)
  80035c:	ff 75 08             	pushl  0x8(%ebp)
  80035f:	e8 05 00 00 00       	call   800369 <vprintfmt>
	va_end(ap);
}
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 2c             	sub    $0x2c,%esp
  800372:	8b 75 08             	mov    0x8(%ebp),%esi
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800378:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037b:	eb 12                	jmp    80038f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037d:	85 c0                	test   %eax,%eax
  80037f:	0f 84 a9 03 00 00    	je     80072e <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	53                   	push   %ebx
  800389:	50                   	push   %eax
  80038a:	ff d6                	call   *%esi
  80038c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038f:	83 c7 01             	add    $0x1,%edi
  800392:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800396:	83 f8 25             	cmp    $0x25,%eax
  800399:	75 e2                	jne    80037d <vprintfmt+0x14>
  80039b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b9:	eb 07                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003be:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8d 47 01             	lea    0x1(%edi),%eax
  8003c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c8:	0f b6 07             	movzbl (%edi),%eax
  8003cb:	0f b6 c8             	movzbl %al,%ecx
  8003ce:	83 e8 23             	sub    $0x23,%eax
  8003d1:	3c 55                	cmp    $0x55,%al
  8003d3:	0f 87 3a 03 00 00    	ja     800713 <vprintfmt+0x3aa>
  8003d9:	0f b6 c0             	movzbl %al,%eax
  8003dc:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ea:	eb d6                	jmp    8003c2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fa:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fe:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800401:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800404:	83 fa 09             	cmp    $0x9,%edx
  800407:	77 39                	ja     800442 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040c:	eb e9                	jmp    8003f7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	8d 48 04             	lea    0x4(%eax),%ecx
  800414:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800417:	8b 00                	mov    (%eax),%eax
  800419:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041f:	eb 27                	jmp    800448 <vprintfmt+0xdf>
  800421:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800424:	85 c0                	test   %eax,%eax
  800426:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042b:	0f 49 c8             	cmovns %eax,%ecx
  80042e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	eb 8c                	jmp    8003c2 <vprintfmt+0x59>
  800436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800439:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800440:	eb 80                	jmp    8003c2 <vprintfmt+0x59>
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800448:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044c:	0f 89 70 ff ff ff    	jns    8003c2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800452:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800455:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800458:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045f:	e9 5e ff ff ff       	jmp    8003c2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800464:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046a:	e9 53 ff ff ff       	jmp    8003c2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	ff 30                	pushl  (%eax)
  80047e:	ff d6                	call   *%esi
			break;
  800480:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800486:	e9 04 ff ff ff       	jmp    80038f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 50 04             	lea    0x4(%eax),%edx
  800491:	89 55 14             	mov    %edx,0x14(%ebp)
  800494:	8b 00                	mov    (%eax),%eax
  800496:	99                   	cltd   
  800497:	31 d0                	xor    %edx,%eax
  800499:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049b:	83 f8 0f             	cmp    $0xf,%eax
  80049e:	7f 0b                	jg     8004ab <vprintfmt+0x142>
  8004a0:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	75 18                	jne    8004c3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	50                   	push   %eax
  8004ac:	68 af 23 80 00       	push   $0x8023af
  8004b1:	53                   	push   %ebx
  8004b2:	56                   	push   %esi
  8004b3:	e8 94 fe ff ff       	call   80034c <printfmt>
  8004b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004be:	e9 cc fe ff ff       	jmp    80038f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c3:	52                   	push   %edx
  8004c4:	68 79 27 80 00       	push   $0x802779
  8004c9:	53                   	push   %ebx
  8004ca:	56                   	push   %esi
  8004cb:	e8 7c fe ff ff       	call   80034c <printfmt>
  8004d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d6:	e9 b4 fe ff ff       	jmp    80038f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 50 04             	lea    0x4(%eax),%edx
  8004e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e6:	85 ff                	test   %edi,%edi
  8004e8:	b8 a8 23 80 00       	mov    $0x8023a8,%eax
  8004ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f4:	0f 8e 94 00 00 00    	jle    80058e <vprintfmt+0x225>
  8004fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fe:	0f 84 98 00 00 00    	je     80059c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	ff 75 d0             	pushl  -0x30(%ebp)
  80050a:	57                   	push   %edi
  80050b:	e8 a6 02 00 00       	call   8007b6 <strnlen>
  800510:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800513:	29 c1                	sub    %eax,%ecx
  800515:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800518:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800522:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800525:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	eb 0f                	jmp    800538 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	ff 75 e0             	pushl  -0x20(%ebp)
  800530:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800532:	83 ef 01             	sub    $0x1,%edi
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	85 ff                	test   %edi,%edi
  80053a:	7f ed                	jg     800529 <vprintfmt+0x1c0>
  80053c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800542:	85 c9                	test   %ecx,%ecx
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
  800549:	0f 49 c1             	cmovns %ecx,%eax
  80054c:	29 c1                	sub    %eax,%ecx
  80054e:	89 75 08             	mov    %esi,0x8(%ebp)
  800551:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800554:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800557:	89 cb                	mov    %ecx,%ebx
  800559:	eb 4d                	jmp    8005a8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055f:	74 1b                	je     80057c <vprintfmt+0x213>
  800561:	0f be c0             	movsbl %al,%eax
  800564:	83 e8 20             	sub    $0x20,%eax
  800567:	83 f8 5e             	cmp    $0x5e,%eax
  80056a:	76 10                	jbe    80057c <vprintfmt+0x213>
					putch('?', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	ff 75 0c             	pushl  0xc(%ebp)
  800572:	6a 3f                	push   $0x3f
  800574:	ff 55 08             	call   *0x8(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 0d                	jmp    800589 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	ff 75 0c             	pushl  0xc(%ebp)
  800582:	52                   	push   %edx
  800583:	ff 55 08             	call   *0x8(%ebp)
  800586:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800589:	83 eb 01             	sub    $0x1,%ebx
  80058c:	eb 1a                	jmp    8005a8 <vprintfmt+0x23f>
  80058e:	89 75 08             	mov    %esi,0x8(%ebp)
  800591:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800594:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800597:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059a:	eb 0c                	jmp    8005a8 <vprintfmt+0x23f>
  80059c:	89 75 08             	mov    %esi,0x8(%ebp)
  80059f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a8:	83 c7 01             	add    $0x1,%edi
  8005ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005af:	0f be d0             	movsbl %al,%edx
  8005b2:	85 d2                	test   %edx,%edx
  8005b4:	74 23                	je     8005d9 <vprintfmt+0x270>
  8005b6:	85 f6                	test   %esi,%esi
  8005b8:	78 a1                	js     80055b <vprintfmt+0x1f2>
  8005ba:	83 ee 01             	sub    $0x1,%esi
  8005bd:	79 9c                	jns    80055b <vprintfmt+0x1f2>
  8005bf:	89 df                	mov    %ebx,%edi
  8005c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c7:	eb 18                	jmp    8005e1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 20                	push   $0x20
  8005cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d1:	83 ef 01             	sub    $0x1,%edi
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb 08                	jmp    8005e1 <vprintfmt+0x278>
  8005d9:	89 df                	mov    %ebx,%edi
  8005db:	8b 75 08             	mov    0x8(%ebp),%esi
  8005de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e1:	85 ff                	test   %edi,%edi
  8005e3:	7f e4                	jg     8005c9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e8:	e9 a2 fd ff ff       	jmp    80038f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ed:	83 fa 01             	cmp    $0x1,%edx
  8005f0:	7e 16                	jle    800608 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 08             	lea    0x8(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 50 04             	mov    0x4(%eax),%edx
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800606:	eb 32                	jmp    80063a <vprintfmt+0x2d1>
	else if (lflag)
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 18                	je     800624 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 c1                	mov    %eax,%ecx
  80061c:	c1 f9 1f             	sar    $0x1f,%ecx
  80061f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800622:	eb 16                	jmp    80063a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 50 04             	lea    0x4(%eax),%edx
  80062a:	89 55 14             	mov    %edx,0x14(%ebp)
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	89 c1                	mov    %eax,%ecx
  800634:	c1 f9 1f             	sar    $0x1f,%ecx
  800637:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800640:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800645:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800649:	0f 89 90 00 00 00    	jns    8006df <vprintfmt+0x376>
				putch('-', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 2d                	push   $0x2d
  800655:	ff d6                	call   *%esi
				num = -(long long) num;
  800657:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065d:	f7 d8                	neg    %eax
  80065f:	83 d2 00             	adc    $0x0,%edx
  800662:	f7 da                	neg    %edx
  800664:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800667:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066c:	eb 71                	jmp    8006df <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066e:	8d 45 14             	lea    0x14(%ebp),%eax
  800671:	e8 7f fc ff ff       	call   8002f5 <getuint>
			base = 10;
  800676:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067b:	eb 62                	jmp    8006df <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
  800680:	e8 70 fc ff ff       	call   8002f5 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800685:	83 ec 0c             	sub    $0xc,%esp
  800688:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80068c:	51                   	push   %ecx
  80068d:	ff 75 e0             	pushl  -0x20(%ebp)
  800690:	6a 08                	push   $0x8
  800692:	52                   	push   %edx
  800693:	50                   	push   %eax
  800694:	89 da                	mov    %ebx,%edx
  800696:	89 f0                	mov    %esi,%eax
  800698:	e8 a9 fb ff ff       	call   800246 <printnum>
			break;
  80069d:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8006a3:	e9 e7 fc ff ff       	jmp    80038f <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	6a 30                	push   $0x30
  8006ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b0:	83 c4 08             	add    $0x8,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	6a 78                	push   $0x78
  8006b6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006cb:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006d0:	eb 0d                	jmp    8006df <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d5:	e8 1b fc ff ff       	call   8002f5 <getuint>
			base = 16;
  8006da:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006df:	83 ec 0c             	sub    $0xc,%esp
  8006e2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e6:	57                   	push   %edi
  8006e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ea:	51                   	push   %ecx
  8006eb:	52                   	push   %edx
  8006ec:	50                   	push   %eax
  8006ed:	89 da                	mov    %ebx,%edx
  8006ef:	89 f0                	mov    %esi,%eax
  8006f1:	e8 50 fb ff ff       	call   800246 <printnum>
			break;
  8006f6:	83 c4 20             	add    $0x20,%esp
  8006f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fc:	e9 8e fc ff ff       	jmp    80038f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	51                   	push   %ecx
  800706:	ff d6                	call   *%esi
			break;
  800708:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070e:	e9 7c fc ff ff       	jmp    80038f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 25                	push   $0x25
  800719:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	eb 03                	jmp    800723 <vprintfmt+0x3ba>
  800720:	83 ef 01             	sub    $0x1,%edi
  800723:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800727:	75 f7                	jne    800720 <vprintfmt+0x3b7>
  800729:	e9 61 fc ff ff       	jmp    80038f <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	83 ec 18             	sub    $0x18,%esp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 26                	je     80077d <vsnprintf+0x47>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 22                	jle    80077d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	ff 75 14             	pushl  0x14(%ebp)
  80075e:	ff 75 10             	pushl  0x10(%ebp)
  800761:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	68 2f 03 80 00       	push   $0x80032f
  80076a:	e8 fa fb ff ff       	call   800369 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800772:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 05                	jmp    800782 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    

00800784 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078d:	50                   	push   %eax
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	ff 75 0c             	pushl  0xc(%ebp)
  800794:	ff 75 08             	pushl  0x8(%ebp)
  800797:	e8 9a ff ff ff       	call   800736 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a9:	eb 03                	jmp    8007ae <strlen+0x10>
		n++;
  8007ab:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b2:	75 f7                	jne    8007ab <strlen+0xd>
		n++;
	return n;
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c4:	eb 03                	jmp    8007c9 <strnlen+0x13>
		n++;
  8007c6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	39 c2                	cmp    %eax,%edx
  8007cb:	74 08                	je     8007d5 <strnlen+0x1f>
  8007cd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d1:	75 f3                	jne    8007c6 <strnlen+0x10>
  8007d3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e1:	89 c2                	mov    %eax,%edx
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	83 c1 01             	add    $0x1,%ecx
  8007e9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f0:	84 db                	test   %bl,%bl
  8007f2:	75 ef                	jne    8007e3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fe:	53                   	push   %ebx
  8007ff:	e8 9a ff ff ff       	call   80079e <strlen>
  800804:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800807:	ff 75 0c             	pushl  0xc(%ebp)
  80080a:	01 d8                	add    %ebx,%eax
  80080c:	50                   	push   %eax
  80080d:	e8 c5 ff ff ff       	call   8007d7 <strcpy>
	return dst;
}
  800812:	89 d8                	mov    %ebx,%eax
  800814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	56                   	push   %esi
  80081d:	53                   	push   %ebx
  80081e:	8b 75 08             	mov    0x8(%ebp),%esi
  800821:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800824:	89 f3                	mov    %esi,%ebx
  800826:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800829:	89 f2                	mov    %esi,%edx
  80082b:	eb 0f                	jmp    80083c <strncpy+0x23>
		*dst++ = *src;
  80082d:	83 c2 01             	add    $0x1,%edx
  800830:	0f b6 01             	movzbl (%ecx),%eax
  800833:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800836:	80 39 01             	cmpb   $0x1,(%ecx)
  800839:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	39 da                	cmp    %ebx,%edx
  80083e:	75 ed                	jne    80082d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800840:	89 f0                	mov    %esi,%eax
  800842:	5b                   	pop    %ebx
  800843:	5e                   	pop    %esi
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 75 08             	mov    0x8(%ebp),%esi
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	8b 55 10             	mov    0x10(%ebp),%edx
  800854:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800856:	85 d2                	test   %edx,%edx
  800858:	74 21                	je     80087b <strlcpy+0x35>
  80085a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085e:	89 f2                	mov    %esi,%edx
  800860:	eb 09                	jmp    80086b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	83 c1 01             	add    $0x1,%ecx
  800868:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086b:	39 c2                	cmp    %eax,%edx
  80086d:	74 09                	je     800878 <strlcpy+0x32>
  80086f:	0f b6 19             	movzbl (%ecx),%ebx
  800872:	84 db                	test   %bl,%bl
  800874:	75 ec                	jne    800862 <strlcpy+0x1c>
  800876:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800878:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087b:	29 f0                	sub    %esi,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strcmp+0x11>
		p++, q++;
  80088c:	83 c1 01             	add    $0x1,%ecx
  80088f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800892:	0f b6 01             	movzbl (%ecx),%eax
  800895:	84 c0                	test   %al,%al
  800897:	74 04                	je     80089d <strcmp+0x1c>
  800899:	3a 02                	cmp    (%edx),%al
  80089b:	74 ef                	je     80088c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 c0             	movzbl %al,%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	89 c3                	mov    %eax,%ebx
  8008b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b6:	eb 06                	jmp    8008be <strncmp+0x17>
		n--, p++, q++;
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008be:	39 d8                	cmp    %ebx,%eax
  8008c0:	74 15                	je     8008d7 <strncmp+0x30>
  8008c2:	0f b6 08             	movzbl (%eax),%ecx
  8008c5:	84 c9                	test   %cl,%cl
  8008c7:	74 04                	je     8008cd <strncmp+0x26>
  8008c9:	3a 0a                	cmp    (%edx),%cl
  8008cb:	74 eb                	je     8008b8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 00             	movzbl (%eax),%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
  8008d5:	eb 05                	jmp    8008dc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	eb 07                	jmp    8008f2 <strchr+0x13>
		if (*s == c)
  8008eb:	38 ca                	cmp    %cl,%dl
  8008ed:	74 0f                	je     8008fe <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	0f b6 10             	movzbl (%eax),%edx
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	75 f2                	jne    8008eb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090a:	eb 03                	jmp    80090f <strfind+0xf>
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800912:	38 ca                	cmp    %cl,%dl
  800914:	74 04                	je     80091a <strfind+0x1a>
  800916:	84 d2                	test   %dl,%dl
  800918:	75 f2                	jne    80090c <strfind+0xc>
			break;
	return (char *) s;
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 36                	je     800962 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800932:	75 28                	jne    80095c <memset+0x40>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 23                	jne    80095c <memset+0x40>
		c &= 0xFF;
  800939:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093d:	89 d3                	mov    %edx,%ebx
  80093f:	c1 e3 08             	shl    $0x8,%ebx
  800942:	89 d6                	mov    %edx,%esi
  800944:	c1 e6 18             	shl    $0x18,%esi
  800947:	89 d0                	mov    %edx,%eax
  800949:	c1 e0 10             	shl    $0x10,%eax
  80094c:	09 f0                	or     %esi,%eax
  80094e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800950:	89 d8                	mov    %ebx,%eax
  800952:	09 d0                	or     %edx,%eax
  800954:	c1 e9 02             	shr    $0x2,%ecx
  800957:	fc                   	cld    
  800958:	f3 ab                	rep stos %eax,%es:(%edi)
  80095a:	eb 06                	jmp    800962 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095f:	fc                   	cld    
  800960:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800962:	89 f8                	mov    %edi,%eax
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 75 0c             	mov    0xc(%ebp),%esi
  800974:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800977:	39 c6                	cmp    %eax,%esi
  800979:	73 35                	jae    8009b0 <memmove+0x47>
  80097b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097e:	39 d0                	cmp    %edx,%eax
  800980:	73 2e                	jae    8009b0 <memmove+0x47>
		s += n;
		d += n;
  800982:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 d6                	mov    %edx,%esi
  800987:	09 fe                	or     %edi,%esi
  800989:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098f:	75 13                	jne    8009a4 <memmove+0x3b>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 0e                	jne    8009a4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800996:	83 ef 04             	sub    $0x4,%edi
  800999:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099c:	c1 e9 02             	shr    $0x2,%ecx
  80099f:	fd                   	std    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 09                	jmp    8009ad <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a4:	83 ef 01             	sub    $0x1,%edi
  8009a7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009aa:	fd                   	std    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ad:	fc                   	cld    
  8009ae:	eb 1d                	jmp    8009cd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	89 f2                	mov    %esi,%edx
  8009b2:	09 c2                	or     %eax,%edx
  8009b4:	f6 c2 03             	test   $0x3,%dl
  8009b7:	75 0f                	jne    8009c8 <memmove+0x5f>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 0a                	jne    8009c8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009be:	c1 e9 02             	shr    $0x2,%ecx
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 05                	jmp    8009cd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c8:	89 c7                	mov    %eax,%edi
  8009ca:	fc                   	cld    
  8009cb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cd:	5e                   	pop    %esi
  8009ce:	5f                   	pop    %edi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d4:	ff 75 10             	pushl  0x10(%ebp)
  8009d7:	ff 75 0c             	pushl  0xc(%ebp)
  8009da:	ff 75 08             	pushl  0x8(%ebp)
  8009dd:	e8 87 ff ff ff       	call   800969 <memmove>
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	89 c6                	mov    %eax,%esi
  8009f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f4:	eb 1a                	jmp    800a10 <memcmp+0x2c>
		if (*s1 != *s2)
  8009f6:	0f b6 08             	movzbl (%eax),%ecx
  8009f9:	0f b6 1a             	movzbl (%edx),%ebx
  8009fc:	38 d9                	cmp    %bl,%cl
  8009fe:	74 0a                	je     800a0a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a00:	0f b6 c1             	movzbl %cl,%eax
  800a03:	0f b6 db             	movzbl %bl,%ebx
  800a06:	29 d8                	sub    %ebx,%eax
  800a08:	eb 0f                	jmp    800a19 <memcmp+0x35>
		s1++, s2++;
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	39 f0                	cmp    %esi,%eax
  800a12:	75 e2                	jne    8009f6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	53                   	push   %ebx
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a24:	89 c1                	mov    %eax,%ecx
  800a26:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2d:	eb 0a                	jmp    800a39 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2f:	0f b6 10             	movzbl (%eax),%edx
  800a32:	39 da                	cmp    %ebx,%edx
  800a34:	74 07                	je     800a3d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	39 c8                	cmp    %ecx,%eax
  800a3b:	72 f2                	jb     800a2f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4c:	eb 03                	jmp    800a51 <strtol+0x11>
		s++;
  800a4e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a51:	0f b6 01             	movzbl (%ecx),%eax
  800a54:	3c 20                	cmp    $0x20,%al
  800a56:	74 f6                	je     800a4e <strtol+0xe>
  800a58:	3c 09                	cmp    $0x9,%al
  800a5a:	74 f2                	je     800a4e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5c:	3c 2b                	cmp    $0x2b,%al
  800a5e:	75 0a                	jne    800a6a <strtol+0x2a>
		s++;
  800a60:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
  800a68:	eb 11                	jmp    800a7b <strtol+0x3b>
  800a6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6f:	3c 2d                	cmp    $0x2d,%al
  800a71:	75 08                	jne    800a7b <strtol+0x3b>
		s++, neg = 1;
  800a73:	83 c1 01             	add    $0x1,%ecx
  800a76:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a81:	75 15                	jne    800a98 <strtol+0x58>
  800a83:	80 39 30             	cmpb   $0x30,(%ecx)
  800a86:	75 10                	jne    800a98 <strtol+0x58>
  800a88:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8c:	75 7c                	jne    800b0a <strtol+0xca>
		s += 2, base = 16;
  800a8e:	83 c1 02             	add    $0x2,%ecx
  800a91:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a96:	eb 16                	jmp    800aae <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	75 12                	jne    800aae <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	75 08                	jne    800aae <strtol+0x6e>
		s++, base = 8;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aae:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab6:	0f b6 11             	movzbl (%ecx),%edx
  800ab9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abc:	89 f3                	mov    %esi,%ebx
  800abe:	80 fb 09             	cmp    $0x9,%bl
  800ac1:	77 08                	ja     800acb <strtol+0x8b>
			dig = *s - '0';
  800ac3:	0f be d2             	movsbl %dl,%edx
  800ac6:	83 ea 30             	sub    $0x30,%edx
  800ac9:	eb 22                	jmp    800aed <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 19             	cmp    $0x19,%bl
  800ad3:	77 08                	ja     800add <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad5:	0f be d2             	movsbl %dl,%edx
  800ad8:	83 ea 57             	sub    $0x57,%edx
  800adb:	eb 10                	jmp    800aed <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800add:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 16                	ja     800afd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae7:	0f be d2             	movsbl %dl,%edx
  800aea:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aed:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af0:	7d 0b                	jge    800afd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af2:	83 c1 01             	add    $0x1,%ecx
  800af5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afb:	eb b9                	jmp    800ab6 <strtol+0x76>

	if (endptr)
  800afd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b01:	74 0d                	je     800b10 <strtol+0xd0>
		*endptr = (char *) s;
  800b03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b06:	89 0e                	mov    %ecx,(%esi)
  800b08:	eb 06                	jmp    800b10 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0a:	85 db                	test   %ebx,%ebx
  800b0c:	74 98                	je     800aa6 <strtol+0x66>
  800b0e:	eb 9e                	jmp    800aae <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	f7 da                	neg    %edx
  800b14:	85 ff                	test   %edi,%edi
  800b16:	0f 45 c2             	cmovne %edx,%eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
  800b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	89 c3                	mov    %eax,%ebx
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	89 c6                	mov    %eax,%esi
  800b35:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b69:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 cb                	mov    %ecx,%ebx
  800b73:	89 cf                	mov    %ecx,%edi
  800b75:	89 ce                	mov    %ecx,%esi
  800b77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	7e 17                	jle    800b94 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	50                   	push   %eax
  800b81:	6a 03                	push   $0x3
  800b83:	68 9f 26 80 00       	push   $0x80269f
  800b88:	6a 23                	push   $0x23
  800b8a:	68 bc 26 80 00       	push   $0x8026bc
  800b8f:	e8 c5 f5 ff ff       	call   800159 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bac:	89 d1                	mov    %edx,%ecx
  800bae:	89 d3                	mov    %edx,%ebx
  800bb0:	89 d7                	mov    %edx,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_yield>:

void
sys_yield(void)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	be 00 00 00 00       	mov    $0x0,%esi
  800be8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf6:	89 f7                	mov    %esi,%edi
  800bf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	7e 17                	jle    800c15 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 04                	push   $0x4
  800c04:	68 9f 26 80 00       	push   $0x80269f
  800c09:	6a 23                	push   $0x23
  800c0b:	68 bc 26 80 00       	push   $0x8026bc
  800c10:	e8 44 f5 ff ff       	call   800159 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c37:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 05                	push   $0x5
  800c46:	68 9f 26 80 00       	push   $0x80269f
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 bc 26 80 00       	push   $0x8026bc
  800c52:	e8 02 f5 ff ff       	call   800159 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	89 df                	mov    %ebx,%edi
  800c7a:	89 de                	mov    %ebx,%esi
  800c7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 06                	push   $0x6
  800c88:	68 9f 26 80 00       	push   $0x80269f
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 bc 26 80 00       	push   $0x8026bc
  800c94:	e8 c0 f4 ff ff       	call   800159 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 17                	jle    800cdb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 08                	push   $0x8
  800cca:	68 9f 26 80 00       	push   $0x80269f
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 bc 26 80 00       	push   $0x8026bc
  800cd6:	e8 7e f4 ff ff       	call   800159 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	89 df                	mov    %ebx,%edi
  800cfe:	89 de                	mov    %ebx,%esi
  800d00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7e 17                	jle    800d1d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d06:	83 ec 0c             	sub    $0xc,%esp
  800d09:	50                   	push   %eax
  800d0a:	6a 09                	push   $0x9
  800d0c:	68 9f 26 80 00       	push   $0x80269f
  800d11:	6a 23                	push   $0x23
  800d13:	68 bc 26 80 00       	push   $0x8026bc
  800d18:	e8 3c f4 ff ff       	call   800159 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7e 17                	jle    800d5f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	50                   	push   %eax
  800d4c:	6a 0a                	push   $0xa
  800d4e:	68 9f 26 80 00       	push   $0x80269f
  800d53:	6a 23                	push   $0x23
  800d55:	68 bc 26 80 00       	push   $0x8026bc
  800d5a:	e8 fa f3 ff ff       	call   800159 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6d:	be 00 00 00 00       	mov    $0x0,%esi
  800d72:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d83:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d98:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	89 cb                	mov    %ecx,%ebx
  800da2:	89 cf                	mov    %ecx,%edi
  800da4:	89 ce                	mov    %ecx,%esi
  800da6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7e 17                	jle    800dc3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	50                   	push   %eax
  800db0:	6a 0d                	push   $0xd
  800db2:	68 9f 26 80 00       	push   $0x80269f
  800db7:	6a 23                	push   $0x23
  800db9:	68 bc 26 80 00       	push   $0x8026bc
  800dbe:	e8 96 f3 ff ff       	call   800159 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ddb:	89 d1                	mov    %edx,%ecx
  800ddd:	89 d3                	mov    %edx,%ebx
  800ddf:	89 d7                	mov    %edx,%edi
  800de1:	89 d6                	mov    %edx,%esi
  800de3:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	05 00 00 00 30       	add    $0x30000000,%eax
  800df5:	c1 e8 0c             	shr    $0xc,%eax
}
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	05 00 00 00 30       	add    $0x30000000,%eax
  800e05:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e17:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e1c:	89 c2                	mov    %eax,%edx
  800e1e:	c1 ea 16             	shr    $0x16,%edx
  800e21:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e28:	f6 c2 01             	test   $0x1,%dl
  800e2b:	74 11                	je     800e3e <fd_alloc+0x2d>
  800e2d:	89 c2                	mov    %eax,%edx
  800e2f:	c1 ea 0c             	shr    $0xc,%edx
  800e32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e39:	f6 c2 01             	test   $0x1,%dl
  800e3c:	75 09                	jne    800e47 <fd_alloc+0x36>
			*fd_store = fd;
  800e3e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e40:	b8 00 00 00 00       	mov    $0x0,%eax
  800e45:	eb 17                	jmp    800e5e <fd_alloc+0x4d>
  800e47:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e4c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e51:	75 c9                	jne    800e1c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e53:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e59:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e66:	83 f8 1f             	cmp    $0x1f,%eax
  800e69:	77 36                	ja     800ea1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e6b:	c1 e0 0c             	shl    $0xc,%eax
  800e6e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e73:	89 c2                	mov    %eax,%edx
  800e75:	c1 ea 16             	shr    $0x16,%edx
  800e78:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e7f:	f6 c2 01             	test   $0x1,%dl
  800e82:	74 24                	je     800ea8 <fd_lookup+0x48>
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	c1 ea 0c             	shr    $0xc,%edx
  800e89:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e90:	f6 c2 01             	test   $0x1,%dl
  800e93:	74 1a                	je     800eaf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e98:	89 02                	mov    %eax,(%edx)
	return 0;
  800e9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9f:	eb 13                	jmp    800eb4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea6:	eb 0c                	jmp    800eb4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ead:	eb 05                	jmp    800eb4 <fd_lookup+0x54>
  800eaf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebf:	ba 4c 27 80 00       	mov    $0x80274c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec4:	eb 13                	jmp    800ed9 <dev_lookup+0x23>
  800ec6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ec9:	39 08                	cmp    %ecx,(%eax)
  800ecb:	75 0c                	jne    800ed9 <dev_lookup+0x23>
			*dev = devtab[i];
  800ecd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed7:	eb 2e                	jmp    800f07 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ed9:	8b 02                	mov    (%edx),%eax
  800edb:	85 c0                	test   %eax,%eax
  800edd:	75 e7                	jne    800ec6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800edf:	a1 08 40 80 00       	mov    0x804008,%eax
  800ee4:	8b 40 48             	mov    0x48(%eax),%eax
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	51                   	push   %ecx
  800eeb:	50                   	push   %eax
  800eec:	68 cc 26 80 00       	push   $0x8026cc
  800ef1:	e8 3c f3 ff ff       	call   800232 <cprintf>
	*dev = 0;
  800ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	56                   	push   %esi
  800f0d:	53                   	push   %ebx
  800f0e:	83 ec 10             	sub    $0x10,%esp
  800f11:	8b 75 08             	mov    0x8(%ebp),%esi
  800f14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1a:	50                   	push   %eax
  800f1b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f21:	c1 e8 0c             	shr    $0xc,%eax
  800f24:	50                   	push   %eax
  800f25:	e8 36 ff ff ff       	call   800e60 <fd_lookup>
  800f2a:	83 c4 08             	add    $0x8,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 05                	js     800f36 <fd_close+0x2d>
	    || fd != fd2)
  800f31:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f34:	74 0c                	je     800f42 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f36:	84 db                	test   %bl,%bl
  800f38:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3d:	0f 44 c2             	cmove  %edx,%eax
  800f40:	eb 41                	jmp    800f83 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	ff 36                	pushl  (%esi)
  800f4b:	e8 66 ff ff ff       	call   800eb6 <dev_lookup>
  800f50:	89 c3                	mov    %eax,%ebx
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 1a                	js     800f73 <fd_close+0x6a>
		if (dev->dev_close)
  800f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f5c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f5f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f64:	85 c0                	test   %eax,%eax
  800f66:	74 0b                	je     800f73 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f68:	83 ec 0c             	sub    $0xc,%esp
  800f6b:	56                   	push   %esi
  800f6c:	ff d0                	call   *%eax
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	56                   	push   %esi
  800f77:	6a 00                	push   $0x0
  800f79:	e8 e1 fc ff ff       	call   800c5f <sys_page_unmap>
	return r;
  800f7e:	83 c4 10             	add    $0x10,%esp
  800f81:	89 d8                	mov    %ebx,%eax
}
  800f83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	ff 75 08             	pushl  0x8(%ebp)
  800f97:	e8 c4 fe ff ff       	call   800e60 <fd_lookup>
  800f9c:	83 c4 08             	add    $0x8,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	78 10                	js     800fb3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	6a 01                	push   $0x1
  800fa8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fab:	e8 59 ff ff ff       	call   800f09 <fd_close>
  800fb0:	83 c4 10             	add    $0x10,%esp
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <close_all>:

void
close_all(void)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	53                   	push   %ebx
  800fc5:	e8 c0 ff ff ff       	call   800f8a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fca:	83 c3 01             	add    $0x1,%ebx
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	83 fb 20             	cmp    $0x20,%ebx
  800fd3:	75 ec                	jne    800fc1 <close_all+0xc>
		close(i);
}
  800fd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd8:	c9                   	leave  
  800fd9:	c3                   	ret    

00800fda <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 2c             	sub    $0x2c,%esp
  800fe3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	ff 75 08             	pushl  0x8(%ebp)
  800fed:	e8 6e fe ff ff       	call   800e60 <fd_lookup>
  800ff2:	83 c4 08             	add    $0x8,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	0f 88 c1 00 00 00    	js     8010be <dup+0xe4>
		return r;
	close(newfdnum);
  800ffd:	83 ec 0c             	sub    $0xc,%esp
  801000:	56                   	push   %esi
  801001:	e8 84 ff ff ff       	call   800f8a <close>

	newfd = INDEX2FD(newfdnum);
  801006:	89 f3                	mov    %esi,%ebx
  801008:	c1 e3 0c             	shl    $0xc,%ebx
  80100b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801011:	83 c4 04             	add    $0x4,%esp
  801014:	ff 75 e4             	pushl  -0x1c(%ebp)
  801017:	e8 de fd ff ff       	call   800dfa <fd2data>
  80101c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80101e:	89 1c 24             	mov    %ebx,(%esp)
  801021:	e8 d4 fd ff ff       	call   800dfa <fd2data>
  801026:	83 c4 10             	add    $0x10,%esp
  801029:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80102c:	89 f8                	mov    %edi,%eax
  80102e:	c1 e8 16             	shr    $0x16,%eax
  801031:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801038:	a8 01                	test   $0x1,%al
  80103a:	74 37                	je     801073 <dup+0x99>
  80103c:	89 f8                	mov    %edi,%eax
  80103e:	c1 e8 0c             	shr    $0xc,%eax
  801041:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801048:	f6 c2 01             	test   $0x1,%dl
  80104b:	74 26                	je     801073 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80104d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	25 07 0e 00 00       	and    $0xe07,%eax
  80105c:	50                   	push   %eax
  80105d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801060:	6a 00                	push   $0x0
  801062:	57                   	push   %edi
  801063:	6a 00                	push   $0x0
  801065:	e8 b3 fb ff ff       	call   800c1d <sys_page_map>
  80106a:	89 c7                	mov    %eax,%edi
  80106c:	83 c4 20             	add    $0x20,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 2e                	js     8010a1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801073:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801076:	89 d0                	mov    %edx,%eax
  801078:	c1 e8 0c             	shr    $0xc,%eax
  80107b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	25 07 0e 00 00       	and    $0xe07,%eax
  80108a:	50                   	push   %eax
  80108b:	53                   	push   %ebx
  80108c:	6a 00                	push   $0x0
  80108e:	52                   	push   %edx
  80108f:	6a 00                	push   $0x0
  801091:	e8 87 fb ff ff       	call   800c1d <sys_page_map>
  801096:	89 c7                	mov    %eax,%edi
  801098:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80109b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80109d:	85 ff                	test   %edi,%edi
  80109f:	79 1d                	jns    8010be <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a1:	83 ec 08             	sub    $0x8,%esp
  8010a4:	53                   	push   %ebx
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 b3 fb ff ff       	call   800c5f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ac:	83 c4 08             	add    $0x8,%esp
  8010af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b2:	6a 00                	push   $0x0
  8010b4:	e8 a6 fb ff ff       	call   800c5f <sys_page_unmap>
	return r;
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	89 f8                	mov    %edi,%eax
}
  8010be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5f                   	pop    %edi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 14             	sub    $0x14,%esp
  8010cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d3:	50                   	push   %eax
  8010d4:	53                   	push   %ebx
  8010d5:	e8 86 fd ff ff       	call   800e60 <fd_lookup>
  8010da:	83 c4 08             	add    $0x8,%esp
  8010dd:	89 c2                	mov    %eax,%edx
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 6d                	js     801150 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ed:	ff 30                	pushl  (%eax)
  8010ef:	e8 c2 fd ff ff       	call   800eb6 <dev_lookup>
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 4c                	js     801147 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fe:	8b 42 08             	mov    0x8(%edx),%eax
  801101:	83 e0 03             	and    $0x3,%eax
  801104:	83 f8 01             	cmp    $0x1,%eax
  801107:	75 21                	jne    80112a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801109:	a1 08 40 80 00       	mov    0x804008,%eax
  80110e:	8b 40 48             	mov    0x48(%eax),%eax
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	53                   	push   %ebx
  801115:	50                   	push   %eax
  801116:	68 10 27 80 00       	push   $0x802710
  80111b:	e8 12 f1 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801128:	eb 26                	jmp    801150 <read+0x8a>
	}
	if (!dev->dev_read)
  80112a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112d:	8b 40 08             	mov    0x8(%eax),%eax
  801130:	85 c0                	test   %eax,%eax
  801132:	74 17                	je     80114b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	ff 75 10             	pushl  0x10(%ebp)
  80113a:	ff 75 0c             	pushl  0xc(%ebp)
  80113d:	52                   	push   %edx
  80113e:	ff d0                	call   *%eax
  801140:	89 c2                	mov    %eax,%edx
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	eb 09                	jmp    801150 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801147:	89 c2                	mov    %eax,%edx
  801149:	eb 05                	jmp    801150 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80114b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801150:	89 d0                	mov    %edx,%eax
  801152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	8b 7d 08             	mov    0x8(%ebp),%edi
  801163:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801166:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116b:	eb 21                	jmp    80118e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80116d:	83 ec 04             	sub    $0x4,%esp
  801170:	89 f0                	mov    %esi,%eax
  801172:	29 d8                	sub    %ebx,%eax
  801174:	50                   	push   %eax
  801175:	89 d8                	mov    %ebx,%eax
  801177:	03 45 0c             	add    0xc(%ebp),%eax
  80117a:	50                   	push   %eax
  80117b:	57                   	push   %edi
  80117c:	e8 45 ff ff ff       	call   8010c6 <read>
		if (m < 0)
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	85 c0                	test   %eax,%eax
  801186:	78 10                	js     801198 <readn+0x41>
			return m;
		if (m == 0)
  801188:	85 c0                	test   %eax,%eax
  80118a:	74 0a                	je     801196 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118c:	01 c3                	add    %eax,%ebx
  80118e:	39 f3                	cmp    %esi,%ebx
  801190:	72 db                	jb     80116d <readn+0x16>
  801192:	89 d8                	mov    %ebx,%eax
  801194:	eb 02                	jmp    801198 <readn+0x41>
  801196:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119b:	5b                   	pop    %ebx
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    

008011a0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 14             	sub    $0x14,%esp
  8011a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	53                   	push   %ebx
  8011af:	e8 ac fc ff ff       	call   800e60 <fd_lookup>
  8011b4:	83 c4 08             	add    $0x8,%esp
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 68                	js     801225 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c7:	ff 30                	pushl  (%eax)
  8011c9:	e8 e8 fc ff ff       	call   800eb6 <dev_lookup>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 47                	js     80121c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011dc:	75 21                	jne    8011ff <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011de:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e3:	8b 40 48             	mov    0x48(%eax),%eax
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	53                   	push   %ebx
  8011ea:	50                   	push   %eax
  8011eb:	68 2c 27 80 00       	push   $0x80272c
  8011f0:	e8 3d f0 ff ff       	call   800232 <cprintf>
		return -E_INVAL;
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011fd:	eb 26                	jmp    801225 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801202:	8b 52 0c             	mov    0xc(%edx),%edx
  801205:	85 d2                	test   %edx,%edx
  801207:	74 17                	je     801220 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	ff 75 10             	pushl  0x10(%ebp)
  80120f:	ff 75 0c             	pushl  0xc(%ebp)
  801212:	50                   	push   %eax
  801213:	ff d2                	call   *%edx
  801215:	89 c2                	mov    %eax,%edx
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	eb 09                	jmp    801225 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	eb 05                	jmp    801225 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801220:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801225:	89 d0                	mov    %edx,%eax
  801227:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122a:	c9                   	leave  
  80122b:	c3                   	ret    

0080122c <seek>:

int
seek(int fdnum, off_t offset)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801232:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	ff 75 08             	pushl  0x8(%ebp)
  801239:	e8 22 fc ff ff       	call   800e60 <fd_lookup>
  80123e:	83 c4 08             	add    $0x8,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 0e                	js     801253 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801245:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80124e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 14             	sub    $0x14,%esp
  80125c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	53                   	push   %ebx
  801264:	e8 f7 fb ff ff       	call   800e60 <fd_lookup>
  801269:	83 c4 08             	add    $0x8,%esp
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	85 c0                	test   %eax,%eax
  801270:	78 65                	js     8012d7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	ff 30                	pushl  (%eax)
  80127e:	e8 33 fc ff ff       	call   800eb6 <dev_lookup>
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	85 c0                	test   %eax,%eax
  801288:	78 44                	js     8012ce <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801291:	75 21                	jne    8012b4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801293:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801298:	8b 40 48             	mov    0x48(%eax),%eax
  80129b:	83 ec 04             	sub    $0x4,%esp
  80129e:	53                   	push   %ebx
  80129f:	50                   	push   %eax
  8012a0:	68 ec 26 80 00       	push   $0x8026ec
  8012a5:	e8 88 ef ff ff       	call   800232 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b2:	eb 23                	jmp    8012d7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b7:	8b 52 18             	mov    0x18(%edx),%edx
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	74 14                	je     8012d2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012be:	83 ec 08             	sub    $0x8,%esp
  8012c1:	ff 75 0c             	pushl  0xc(%ebp)
  8012c4:	50                   	push   %eax
  8012c5:	ff d2                	call   *%edx
  8012c7:	89 c2                	mov    %eax,%edx
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	eb 09                	jmp    8012d7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	eb 05                	jmp    8012d7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d7:	89 d0                	mov    %edx,%eax
  8012d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 14             	sub    $0x14,%esp
  8012e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 75 08             	pushl  0x8(%ebp)
  8012ef:	e8 6c fb ff ff       	call   800e60 <fd_lookup>
  8012f4:	83 c4 08             	add    $0x8,%esp
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 58                	js     801355 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	ff 30                	pushl  (%eax)
  801309:	e8 a8 fb ff ff       	call   800eb6 <dev_lookup>
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 37                	js     80134c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801318:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80131c:	74 32                	je     801350 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80131e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801321:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801328:	00 00 00 
	stat->st_isdir = 0;
  80132b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801332:	00 00 00 
	stat->st_dev = dev;
  801335:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	53                   	push   %ebx
  80133f:	ff 75 f0             	pushl  -0x10(%ebp)
  801342:	ff 50 14             	call   *0x14(%eax)
  801345:	89 c2                	mov    %eax,%edx
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	eb 09                	jmp    801355 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	eb 05                	jmp    801355 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801350:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801355:	89 d0                	mov    %edx,%eax
  801357:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	56                   	push   %esi
  801360:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801361:	83 ec 08             	sub    $0x8,%esp
  801364:	6a 00                	push   $0x0
  801366:	ff 75 08             	pushl  0x8(%ebp)
  801369:	e8 ef 01 00 00       	call   80155d <open>
  80136e:	89 c3                	mov    %eax,%ebx
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 1b                	js     801392 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	ff 75 0c             	pushl  0xc(%ebp)
  80137d:	50                   	push   %eax
  80137e:	e8 5b ff ff ff       	call   8012de <fstat>
  801383:	89 c6                	mov    %eax,%esi
	close(fd);
  801385:	89 1c 24             	mov    %ebx,(%esp)
  801388:	e8 fd fb ff ff       	call   800f8a <close>
	return r;
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	89 f0                	mov    %esi,%eax
}
  801392:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801395:	5b                   	pop    %ebx
  801396:	5e                   	pop    %esi
  801397:	5d                   	pop    %ebp
  801398:	c3                   	ret    

00801399 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801399:	55                   	push   %ebp
  80139a:	89 e5                	mov    %esp,%ebp
  80139c:	56                   	push   %esi
  80139d:	53                   	push   %ebx
  80139e:	89 c6                	mov    %eax,%esi
  8013a0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013a9:	75 12                	jne    8013bd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	6a 01                	push   $0x1
  8013b0:	e8 57 0c 00 00       	call   80200c <ipc_find_env>
  8013b5:	a3 00 40 80 00       	mov    %eax,0x804000
  8013ba:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013bd:	6a 07                	push   $0x7
  8013bf:	68 00 50 80 00       	push   $0x805000
  8013c4:	56                   	push   %esi
  8013c5:	ff 35 00 40 80 00    	pushl  0x804000
  8013cb:	e8 ed 0b 00 00       	call   801fbd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d0:	83 c4 0c             	add    $0xc,%esp
  8013d3:	6a 00                	push   $0x0
  8013d5:	53                   	push   %ebx
  8013d6:	6a 00                	push   $0x0
  8013d8:	e8 6a 0b 00 00       	call   801f47 <ipc_recv>
}
  8013dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801402:	b8 02 00 00 00       	mov    $0x2,%eax
  801407:	e8 8d ff ff ff       	call   801399 <fsipc>
}
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801414:	8b 45 08             	mov    0x8(%ebp),%eax
  801417:	8b 40 0c             	mov    0xc(%eax),%eax
  80141a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	b8 06 00 00 00       	mov    $0x6,%eax
  801429:	e8 6b ff ff ff       	call   801399 <fsipc>
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	53                   	push   %ebx
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143a:	8b 45 08             	mov    0x8(%ebp),%eax
  80143d:	8b 40 0c             	mov    0xc(%eax),%eax
  801440:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801445:	ba 00 00 00 00       	mov    $0x0,%edx
  80144a:	b8 05 00 00 00       	mov    $0x5,%eax
  80144f:	e8 45 ff ff ff       	call   801399 <fsipc>
  801454:	85 c0                	test   %eax,%eax
  801456:	78 2c                	js     801484 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	68 00 50 80 00       	push   $0x805000
  801460:	53                   	push   %ebx
  801461:	e8 71 f3 ff ff       	call   8007d7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801466:	a1 80 50 80 00       	mov    0x805080,%eax
  80146b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801471:	a1 84 50 80 00       	mov    0x805084,%eax
  801476:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801484:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801493:	8b 55 08             	mov    0x8(%ebp),%edx
  801496:	8b 52 0c             	mov    0xc(%edx),%edx
  801499:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80149f:	a3 04 50 80 00       	mov    %eax,0x805004
  8014a4:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8014a9:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8014ae:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b1:	53                   	push   %ebx
  8014b2:	ff 75 0c             	pushl  0xc(%ebp)
  8014b5:	68 08 50 80 00       	push   $0x805008
  8014ba:	e8 aa f4 ff ff       	call   800969 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c9:	e8 cb fe ff ff       	call   801399 <fsipc>
  8014ce:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8014d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	56                   	push   %esi
  8014df:	53                   	push   %ebx
  8014e0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014ee:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fe:	e8 96 fe ff ff       	call   801399 <fsipc>
  801503:	89 c3                	mov    %eax,%ebx
  801505:	85 c0                	test   %eax,%eax
  801507:	78 4b                	js     801554 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801509:	39 c6                	cmp    %eax,%esi
  80150b:	73 16                	jae    801523 <devfile_read+0x48>
  80150d:	68 60 27 80 00       	push   $0x802760
  801512:	68 67 27 80 00       	push   $0x802767
  801517:	6a 7c                	push   $0x7c
  801519:	68 7c 27 80 00       	push   $0x80277c
  80151e:	e8 36 ec ff ff       	call   800159 <_panic>
	assert(r <= PGSIZE);
  801523:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801528:	7e 16                	jle    801540 <devfile_read+0x65>
  80152a:	68 87 27 80 00       	push   $0x802787
  80152f:	68 67 27 80 00       	push   $0x802767
  801534:	6a 7d                	push   $0x7d
  801536:	68 7c 27 80 00       	push   $0x80277c
  80153b:	e8 19 ec ff ff       	call   800159 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	50                   	push   %eax
  801544:	68 00 50 80 00       	push   $0x805000
  801549:	ff 75 0c             	pushl  0xc(%ebp)
  80154c:	e8 18 f4 ff ff       	call   800969 <memmove>
	return r;
  801551:	83 c4 10             	add    $0x10,%esp
}
  801554:	89 d8                	mov    %ebx,%eax
  801556:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801559:	5b                   	pop    %ebx
  80155a:	5e                   	pop    %esi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	53                   	push   %ebx
  801561:	83 ec 20             	sub    $0x20,%esp
  801564:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801567:	53                   	push   %ebx
  801568:	e8 31 f2 ff ff       	call   80079e <strlen>
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801575:	7f 67                	jg     8015de <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	e8 8e f8 ff ff       	call   800e11 <fd_alloc>
  801583:	83 c4 10             	add    $0x10,%esp
		return r;
  801586:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 57                	js     8015e3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	53                   	push   %ebx
  801590:	68 00 50 80 00       	push   $0x805000
  801595:	e8 3d f2 ff ff       	call   8007d7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80159a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015aa:	e8 ea fd ff ff       	call   801399 <fsipc>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	79 14                	jns    8015cc <open+0x6f>
		fd_close(fd, 0);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	6a 00                	push   $0x0
  8015bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c0:	e8 44 f9 ff ff       	call   800f09 <fd_close>
		return r;
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	89 da                	mov    %ebx,%edx
  8015ca:	eb 17                	jmp    8015e3 <open+0x86>
	}

	return fd2num(fd);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d2:	e8 13 f8 ff ff       	call   800dea <fd2num>
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	eb 05                	jmp    8015e3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015de:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015e3:	89 d0                	mov    %edx,%eax
  8015e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8015fa:	e8 9a fd ff ff       	call   801399 <fsipc>
}
  8015ff:	c9                   	leave  
  801600:	c3                   	ret    

00801601 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	56                   	push   %esi
  801605:	53                   	push   %ebx
  801606:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801609:	83 ec 0c             	sub    $0xc,%esp
  80160c:	ff 75 08             	pushl  0x8(%ebp)
  80160f:	e8 e6 f7 ff ff       	call   800dfa <fd2data>
  801614:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801616:	83 c4 08             	add    $0x8,%esp
  801619:	68 93 27 80 00       	push   $0x802793
  80161e:	53                   	push   %ebx
  80161f:	e8 b3 f1 ff ff       	call   8007d7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801624:	8b 46 04             	mov    0x4(%esi),%eax
  801627:	2b 06                	sub    (%esi),%eax
  801629:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80162f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801636:	00 00 00 
	stat->st_dev = &devpipe;
  801639:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801640:	30 80 00 
	return 0;
}
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
  801648:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	53                   	push   %ebx
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801659:	53                   	push   %ebx
  80165a:	6a 00                	push   $0x0
  80165c:	e8 fe f5 ff ff       	call   800c5f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801661:	89 1c 24             	mov    %ebx,(%esp)
  801664:	e8 91 f7 ff ff       	call   800dfa <fd2data>
  801669:	83 c4 08             	add    $0x8,%esp
  80166c:	50                   	push   %eax
  80166d:	6a 00                	push   $0x0
  80166f:	e8 eb f5 ff ff       	call   800c5f <sys_page_unmap>
}
  801674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801677:	c9                   	leave  
  801678:	c3                   	ret    

00801679 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	57                   	push   %edi
  80167d:	56                   	push   %esi
  80167e:	53                   	push   %ebx
  80167f:	83 ec 1c             	sub    $0x1c,%esp
  801682:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801685:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801687:	a1 08 40 80 00       	mov    0x804008,%eax
  80168c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80168f:	83 ec 0c             	sub    $0xc,%esp
  801692:	ff 75 e0             	pushl  -0x20(%ebp)
  801695:	e8 ab 09 00 00       	call   802045 <pageref>
  80169a:	89 c3                	mov    %eax,%ebx
  80169c:	89 3c 24             	mov    %edi,(%esp)
  80169f:	e8 a1 09 00 00       	call   802045 <pageref>
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	39 c3                	cmp    %eax,%ebx
  8016a9:	0f 94 c1             	sete   %cl
  8016ac:	0f b6 c9             	movzbl %cl,%ecx
  8016af:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016b2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016b8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016bb:	39 ce                	cmp    %ecx,%esi
  8016bd:	74 1b                	je     8016da <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016bf:	39 c3                	cmp    %eax,%ebx
  8016c1:	75 c4                	jne    801687 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016c3:	8b 42 58             	mov    0x58(%edx),%eax
  8016c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016c9:	50                   	push   %eax
  8016ca:	56                   	push   %esi
  8016cb:	68 9a 27 80 00       	push   $0x80279a
  8016d0:	e8 5d eb ff ff       	call   800232 <cprintf>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	eb ad                	jmp    801687 <_pipeisclosed+0xe>
	}
}
  8016da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5f                   	pop    %edi
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	57                   	push   %edi
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 28             	sub    $0x28,%esp
  8016ee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016f1:	56                   	push   %esi
  8016f2:	e8 03 f7 ff ff       	call   800dfa <fd2data>
  8016f7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801701:	eb 4b                	jmp    80174e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801703:	89 da                	mov    %ebx,%edx
  801705:	89 f0                	mov    %esi,%eax
  801707:	e8 6d ff ff ff       	call   801679 <_pipeisclosed>
  80170c:	85 c0                	test   %eax,%eax
  80170e:	75 48                	jne    801758 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801710:	e8 a6 f4 ff ff       	call   800bbb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801715:	8b 43 04             	mov    0x4(%ebx),%eax
  801718:	8b 0b                	mov    (%ebx),%ecx
  80171a:	8d 51 20             	lea    0x20(%ecx),%edx
  80171d:	39 d0                	cmp    %edx,%eax
  80171f:	73 e2                	jae    801703 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801724:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801728:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80172b:	89 c2                	mov    %eax,%edx
  80172d:	c1 fa 1f             	sar    $0x1f,%edx
  801730:	89 d1                	mov    %edx,%ecx
  801732:	c1 e9 1b             	shr    $0x1b,%ecx
  801735:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801738:	83 e2 1f             	and    $0x1f,%edx
  80173b:	29 ca                	sub    %ecx,%edx
  80173d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801741:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801745:	83 c0 01             	add    $0x1,%eax
  801748:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80174b:	83 c7 01             	add    $0x1,%edi
  80174e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801751:	75 c2                	jne    801715 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801753:	8b 45 10             	mov    0x10(%ebp),%eax
  801756:	eb 05                	jmp    80175d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801758:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80175d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5f                   	pop    %edi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    

00801765 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	57                   	push   %edi
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	83 ec 18             	sub    $0x18,%esp
  80176e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801771:	57                   	push   %edi
  801772:	e8 83 f6 ff ff       	call   800dfa <fd2data>
  801777:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801781:	eb 3d                	jmp    8017c0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801783:	85 db                	test   %ebx,%ebx
  801785:	74 04                	je     80178b <devpipe_read+0x26>
				return i;
  801787:	89 d8                	mov    %ebx,%eax
  801789:	eb 44                	jmp    8017cf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80178b:	89 f2                	mov    %esi,%edx
  80178d:	89 f8                	mov    %edi,%eax
  80178f:	e8 e5 fe ff ff       	call   801679 <_pipeisclosed>
  801794:	85 c0                	test   %eax,%eax
  801796:	75 32                	jne    8017ca <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801798:	e8 1e f4 ff ff       	call   800bbb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80179d:	8b 06                	mov    (%esi),%eax
  80179f:	3b 46 04             	cmp    0x4(%esi),%eax
  8017a2:	74 df                	je     801783 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017a4:	99                   	cltd   
  8017a5:	c1 ea 1b             	shr    $0x1b,%edx
  8017a8:	01 d0                	add    %edx,%eax
  8017aa:	83 e0 1f             	and    $0x1f,%eax
  8017ad:	29 d0                	sub    %edx,%eax
  8017af:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017ba:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bd:	83 c3 01             	add    $0x1,%ebx
  8017c0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017c3:	75 d8                	jne    80179d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c8:	eb 05                	jmp    8017cf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5f                   	pop    %edi
  8017d5:	5d                   	pop    %ebp
  8017d6:	c3                   	ret    

008017d7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	56                   	push   %esi
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e2:	50                   	push   %eax
  8017e3:	e8 29 f6 ff ff       	call   800e11 <fd_alloc>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	0f 88 2c 01 00 00    	js     801921 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f5:	83 ec 04             	sub    $0x4,%esp
  8017f8:	68 07 04 00 00       	push   $0x407
  8017fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801800:	6a 00                	push   $0x0
  801802:	e8 d3 f3 ff ff       	call   800bda <sys_page_alloc>
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	85 c0                	test   %eax,%eax
  80180e:	0f 88 0d 01 00 00    	js     801921 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801814:	83 ec 0c             	sub    $0xc,%esp
  801817:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181a:	50                   	push   %eax
  80181b:	e8 f1 f5 ff ff       	call   800e11 <fd_alloc>
  801820:	89 c3                	mov    %eax,%ebx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	0f 88 e2 00 00 00    	js     80190f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80182d:	83 ec 04             	sub    $0x4,%esp
  801830:	68 07 04 00 00       	push   $0x407
  801835:	ff 75 f0             	pushl  -0x10(%ebp)
  801838:	6a 00                	push   $0x0
  80183a:	e8 9b f3 ff ff       	call   800bda <sys_page_alloc>
  80183f:	89 c3                	mov    %eax,%ebx
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	85 c0                	test   %eax,%eax
  801846:	0f 88 c3 00 00 00    	js     80190f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80184c:	83 ec 0c             	sub    $0xc,%esp
  80184f:	ff 75 f4             	pushl  -0xc(%ebp)
  801852:	e8 a3 f5 ff ff       	call   800dfa <fd2data>
  801857:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801859:	83 c4 0c             	add    $0xc,%esp
  80185c:	68 07 04 00 00       	push   $0x407
  801861:	50                   	push   %eax
  801862:	6a 00                	push   $0x0
  801864:	e8 71 f3 ff ff       	call   800bda <sys_page_alloc>
  801869:	89 c3                	mov    %eax,%ebx
  80186b:	83 c4 10             	add    $0x10,%esp
  80186e:	85 c0                	test   %eax,%eax
  801870:	0f 88 89 00 00 00    	js     8018ff <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	ff 75 f0             	pushl  -0x10(%ebp)
  80187c:	e8 79 f5 ff ff       	call   800dfa <fd2data>
  801881:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801888:	50                   	push   %eax
  801889:	6a 00                	push   $0x0
  80188b:	56                   	push   %esi
  80188c:	6a 00                	push   $0x0
  80188e:	e8 8a f3 ff ff       	call   800c1d <sys_page_map>
  801893:	89 c3                	mov    %eax,%ebx
  801895:	83 c4 20             	add    $0x20,%esp
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 55                	js     8018f1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80189c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018aa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018b1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ba:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018c6:	83 ec 0c             	sub    $0xc,%esp
  8018c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cc:	e8 19 f5 ff ff       	call   800dea <fd2num>
  8018d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018d6:	83 c4 04             	add    $0x4,%esp
  8018d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018dc:	e8 09 f5 ff ff       	call   800dea <fd2num>
  8018e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	eb 30                	jmp    801921 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	56                   	push   %esi
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 63 f3 ff ff       	call   800c5f <sys_page_unmap>
  8018fc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	ff 75 f0             	pushl  -0x10(%ebp)
  801905:	6a 00                	push   $0x0
  801907:	e8 53 f3 ff ff       	call   800c5f <sys_page_unmap>
  80190c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	ff 75 f4             	pushl  -0xc(%ebp)
  801915:	6a 00                	push   $0x0
  801917:	e8 43 f3 ff ff       	call   800c5f <sys_page_unmap>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801921:	89 d0                	mov    %edx,%eax
  801923:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801930:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801933:	50                   	push   %eax
  801934:	ff 75 08             	pushl  0x8(%ebp)
  801937:	e8 24 f5 ff ff       	call   800e60 <fd_lookup>
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 18                	js     80195b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801943:	83 ec 0c             	sub    $0xc,%esp
  801946:	ff 75 f4             	pushl  -0xc(%ebp)
  801949:	e8 ac f4 ff ff       	call   800dfa <fd2data>
	return _pipeisclosed(fd, p);
  80194e:	89 c2                	mov    %eax,%edx
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	e8 21 fd ff ff       	call   801679 <_pipeisclosed>
  801958:	83 c4 10             	add    $0x10,%esp
}
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801963:	68 b2 27 80 00       	push   $0x8027b2
  801968:	ff 75 0c             	pushl  0xc(%ebp)
  80196b:	e8 67 ee ff ff       	call   8007d7 <strcpy>
	return 0;
}
  801970:	b8 00 00 00 00       	mov    $0x0,%eax
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 10             	sub    $0x10,%esp
  80197e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801981:	53                   	push   %ebx
  801982:	e8 be 06 00 00       	call   802045 <pageref>
  801987:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80198f:	83 f8 01             	cmp    $0x1,%eax
  801992:	75 10                	jne    8019a4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801994:	83 ec 0c             	sub    $0xc,%esp
  801997:	ff 73 0c             	pushl  0xc(%ebx)
  80199a:	e8 c0 02 00 00       	call   801c5f <nsipc_close>
  80199f:	89 c2                	mov    %eax,%edx
  8019a1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019a4:	89 d0                	mov    %edx,%eax
  8019a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019b1:	6a 00                	push   $0x0
  8019b3:	ff 75 10             	pushl  0x10(%ebp)
  8019b6:	ff 75 0c             	pushl  0xc(%ebp)
  8019b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bc:	ff 70 0c             	pushl  0xc(%eax)
  8019bf:	e8 78 03 00 00       	call   801d3c <nsipc_send>
}
  8019c4:	c9                   	leave  
  8019c5:	c3                   	ret    

008019c6 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019c6:	55                   	push   %ebp
  8019c7:	89 e5                	mov    %esp,%ebp
  8019c9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019cc:	6a 00                	push   $0x0
  8019ce:	ff 75 10             	pushl  0x10(%ebp)
  8019d1:	ff 75 0c             	pushl  0xc(%ebp)
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	ff 70 0c             	pushl  0xc(%eax)
  8019da:	e8 f1 02 00 00       	call   801cd0 <nsipc_recv>
}
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019e7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019ea:	52                   	push   %edx
  8019eb:	50                   	push   %eax
  8019ec:	e8 6f f4 ff ff       	call   800e60 <fd_lookup>
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 17                	js     801a0f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fb:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a01:	39 08                	cmp    %ecx,(%eax)
  801a03:	75 05                	jne    801a0a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a05:	8b 40 0c             	mov    0xc(%eax),%eax
  801a08:	eb 05                	jmp    801a0f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a0a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	83 ec 1c             	sub    $0x1c,%esp
  801a19:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1e:	50                   	push   %eax
  801a1f:	e8 ed f3 ff ff       	call   800e11 <fd_alloc>
  801a24:	89 c3                	mov    %eax,%ebx
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 1b                	js     801a48 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a2d:	83 ec 04             	sub    $0x4,%esp
  801a30:	68 07 04 00 00       	push   $0x407
  801a35:	ff 75 f4             	pushl  -0xc(%ebp)
  801a38:	6a 00                	push   $0x0
  801a3a:	e8 9b f1 ff ff       	call   800bda <sys_page_alloc>
  801a3f:	89 c3                	mov    %eax,%ebx
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	85 c0                	test   %eax,%eax
  801a46:	79 10                	jns    801a58 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	56                   	push   %esi
  801a4c:	e8 0e 02 00 00       	call   801c5f <nsipc_close>
		return r;
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	89 d8                	mov    %ebx,%eax
  801a56:	eb 24                	jmp    801a7c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a58:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a61:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a66:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a6d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	50                   	push   %eax
  801a74:	e8 71 f3 ff ff       	call   800dea <fd2num>
  801a79:	83 c4 10             	add    $0x10,%esp
}
  801a7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	e8 50 ff ff ff       	call   8019e1 <fd2sockid>
		return r;
  801a91:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 1f                	js     801ab6 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a97:	83 ec 04             	sub    $0x4,%esp
  801a9a:	ff 75 10             	pushl  0x10(%ebp)
  801a9d:	ff 75 0c             	pushl  0xc(%ebp)
  801aa0:	50                   	push   %eax
  801aa1:	e8 12 01 00 00       	call   801bb8 <nsipc_accept>
  801aa6:	83 c4 10             	add    $0x10,%esp
		return r;
  801aa9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 07                	js     801ab6 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801aaf:	e8 5d ff ff ff       	call   801a11 <alloc_sockfd>
  801ab4:	89 c1                	mov    %eax,%ecx
}
  801ab6:	89 c8                	mov    %ecx,%eax
  801ab8:	c9                   	leave  
  801ab9:	c3                   	ret    

00801aba <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac3:	e8 19 ff ff ff       	call   8019e1 <fd2sockid>
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	78 12                	js     801ade <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801acc:	83 ec 04             	sub    $0x4,%esp
  801acf:	ff 75 10             	pushl  0x10(%ebp)
  801ad2:	ff 75 0c             	pushl  0xc(%ebp)
  801ad5:	50                   	push   %eax
  801ad6:	e8 2d 01 00 00       	call   801c08 <nsipc_bind>
  801adb:	83 c4 10             	add    $0x10,%esp
}
  801ade:	c9                   	leave  
  801adf:	c3                   	ret    

00801ae0 <shutdown>:

int
shutdown(int s, int how)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae9:	e8 f3 fe ff ff       	call   8019e1 <fd2sockid>
  801aee:	85 c0                	test   %eax,%eax
  801af0:	78 0f                	js     801b01 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	ff 75 0c             	pushl  0xc(%ebp)
  801af8:	50                   	push   %eax
  801af9:	e8 3f 01 00 00       	call   801c3d <nsipc_shutdown>
  801afe:	83 c4 10             	add    $0x10,%esp
}
  801b01:	c9                   	leave  
  801b02:	c3                   	ret    

00801b03 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b03:	55                   	push   %ebp
  801b04:	89 e5                	mov    %esp,%ebp
  801b06:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	e8 d0 fe ff ff       	call   8019e1 <fd2sockid>
  801b11:	85 c0                	test   %eax,%eax
  801b13:	78 12                	js     801b27 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b15:	83 ec 04             	sub    $0x4,%esp
  801b18:	ff 75 10             	pushl  0x10(%ebp)
  801b1b:	ff 75 0c             	pushl  0xc(%ebp)
  801b1e:	50                   	push   %eax
  801b1f:	e8 55 01 00 00       	call   801c79 <nsipc_connect>
  801b24:	83 c4 10             	add    $0x10,%esp
}
  801b27:	c9                   	leave  
  801b28:	c3                   	ret    

00801b29 <listen>:

int
listen(int s, int backlog)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	e8 aa fe ff ff       	call   8019e1 <fd2sockid>
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 0f                	js     801b4a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	ff 75 0c             	pushl  0xc(%ebp)
  801b41:	50                   	push   %eax
  801b42:	e8 67 01 00 00       	call   801cae <nsipc_listen>
  801b47:	83 c4 10             	add    $0x10,%esp
}
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b52:	ff 75 10             	pushl  0x10(%ebp)
  801b55:	ff 75 0c             	pushl  0xc(%ebp)
  801b58:	ff 75 08             	pushl  0x8(%ebp)
  801b5b:	e8 3a 02 00 00       	call   801d9a <nsipc_socket>
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 05                	js     801b6c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b67:	e8 a5 fe ff ff       	call   801a11 <alloc_sockfd>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	83 ec 04             	sub    $0x4,%esp
  801b75:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b77:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b7e:	75 12                	jne    801b92 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	6a 02                	push   $0x2
  801b85:	e8 82 04 00 00       	call   80200c <ipc_find_env>
  801b8a:	a3 04 40 80 00       	mov    %eax,0x804004
  801b8f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b92:	6a 07                	push   $0x7
  801b94:	68 00 60 80 00       	push   $0x806000
  801b99:	53                   	push   %ebx
  801b9a:	ff 35 04 40 80 00    	pushl  0x804004
  801ba0:	e8 18 04 00 00       	call   801fbd <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ba5:	83 c4 0c             	add    $0xc,%esp
  801ba8:	6a 00                	push   $0x0
  801baa:	6a 00                	push   $0x0
  801bac:	6a 00                	push   $0x0
  801bae:	e8 94 03 00 00       	call   801f47 <ipc_recv>
}
  801bb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	56                   	push   %esi
  801bbc:	53                   	push   %ebx
  801bbd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bc8:	8b 06                	mov    (%esi),%eax
  801bca:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bcf:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd4:	e8 95 ff ff ff       	call   801b6e <nsipc>
  801bd9:	89 c3                	mov    %eax,%ebx
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 20                	js     801bff <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bdf:	83 ec 04             	sub    $0x4,%esp
  801be2:	ff 35 10 60 80 00    	pushl  0x806010
  801be8:	68 00 60 80 00       	push   $0x806000
  801bed:	ff 75 0c             	pushl  0xc(%ebp)
  801bf0:	e8 74 ed ff ff       	call   800969 <memmove>
		*addrlen = ret->ret_addrlen;
  801bf5:	a1 10 60 80 00       	mov    0x806010,%eax
  801bfa:	89 06                	mov    %eax,(%esi)
  801bfc:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bff:	89 d8                	mov    %ebx,%eax
  801c01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 08             	sub    $0x8,%esp
  801c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c1a:	53                   	push   %ebx
  801c1b:	ff 75 0c             	pushl  0xc(%ebp)
  801c1e:	68 04 60 80 00       	push   $0x806004
  801c23:	e8 41 ed ff ff       	call   800969 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c28:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c2e:	b8 02 00 00 00       	mov    $0x2,%eax
  801c33:	e8 36 ff ff ff       	call   801b6e <nsipc>
}
  801c38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3b:	c9                   	leave  
  801c3c:	c3                   	ret    

00801c3d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c43:	8b 45 08             	mov    0x8(%ebp),%eax
  801c46:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c53:	b8 03 00 00 00       	mov    $0x3,%eax
  801c58:	e8 11 ff ff ff       	call   801b6e <nsipc>
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <nsipc_close>:

int
nsipc_close(int s)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c6d:	b8 04 00 00 00       	mov    $0x4,%eax
  801c72:	e8 f7 fe ff ff       	call   801b6e <nsipc>
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	53                   	push   %ebx
  801c7d:	83 ec 08             	sub    $0x8,%esp
  801c80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c83:	8b 45 08             	mov    0x8(%ebp),%eax
  801c86:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c8b:	53                   	push   %ebx
  801c8c:	ff 75 0c             	pushl  0xc(%ebp)
  801c8f:	68 04 60 80 00       	push   $0x806004
  801c94:	e8 d0 ec ff ff       	call   800969 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c99:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c9f:	b8 05 00 00 00       	mov    $0x5,%eax
  801ca4:	e8 c5 fe ff ff       	call   801b6e <nsipc>
}
  801ca9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cac:	c9                   	leave  
  801cad:	c3                   	ret    

00801cae <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbf:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cc4:	b8 06 00 00 00       	mov    $0x6,%eax
  801cc9:	e8 a0 fe ff ff       	call   801b6e <nsipc>
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ce0:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801ce6:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce9:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cee:	b8 07 00 00 00       	mov    $0x7,%eax
  801cf3:	e8 76 fe ff ff       	call   801b6e <nsipc>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 35                	js     801d33 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cfe:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d03:	7f 04                	jg     801d09 <nsipc_recv+0x39>
  801d05:	39 c6                	cmp    %eax,%esi
  801d07:	7d 16                	jge    801d1f <nsipc_recv+0x4f>
  801d09:	68 be 27 80 00       	push   $0x8027be
  801d0e:	68 67 27 80 00       	push   $0x802767
  801d13:	6a 62                	push   $0x62
  801d15:	68 d3 27 80 00       	push   $0x8027d3
  801d1a:	e8 3a e4 ff ff       	call   800159 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	50                   	push   %eax
  801d23:	68 00 60 80 00       	push   $0x806000
  801d28:	ff 75 0c             	pushl  0xc(%ebp)
  801d2b:	e8 39 ec ff ff       	call   800969 <memmove>
  801d30:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d33:	89 d8                	mov    %ebx,%eax
  801d35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d38:	5b                   	pop    %ebx
  801d39:	5e                   	pop    %esi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	53                   	push   %ebx
  801d40:	83 ec 04             	sub    $0x4,%esp
  801d43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d4e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d54:	7e 16                	jle    801d6c <nsipc_send+0x30>
  801d56:	68 df 27 80 00       	push   $0x8027df
  801d5b:	68 67 27 80 00       	push   $0x802767
  801d60:	6a 6d                	push   $0x6d
  801d62:	68 d3 27 80 00       	push   $0x8027d3
  801d67:	e8 ed e3 ff ff       	call   800159 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d6c:	83 ec 04             	sub    $0x4,%esp
  801d6f:	53                   	push   %ebx
  801d70:	ff 75 0c             	pushl  0xc(%ebp)
  801d73:	68 0c 60 80 00       	push   $0x80600c
  801d78:	e8 ec eb ff ff       	call   800969 <memmove>
	nsipcbuf.send.req_size = size;
  801d7d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d83:	8b 45 14             	mov    0x14(%ebp),%eax
  801d86:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d8b:	b8 08 00 00 00       	mov    $0x8,%eax
  801d90:	e8 d9 fd ff ff       	call   801b6e <nsipc>
}
  801d95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
  801d9d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801da0:	8b 45 08             	mov    0x8(%ebp),%eax
  801da3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dab:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801db0:	8b 45 10             	mov    0x10(%ebp),%eax
  801db3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801db8:	b8 09 00 00 00       	mov    $0x9,%eax
  801dbd:	e8 ac fd ff ff       	call   801b6e <nsipc>
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dd4:	68 eb 27 80 00       	push   $0x8027eb
  801dd9:	ff 75 0c             	pushl  0xc(%ebp)
  801ddc:	e8 f6 e9 ff ff       	call   8007d7 <strcpy>
	return 0;
}
  801de1:	b8 00 00 00 00       	mov    $0x0,%eax
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	57                   	push   %edi
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801df4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dff:	eb 2d                	jmp    801e2e <devcons_write+0x46>
		m = n - tot;
  801e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e04:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e06:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e09:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e0e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e11:	83 ec 04             	sub    $0x4,%esp
  801e14:	53                   	push   %ebx
  801e15:	03 45 0c             	add    0xc(%ebp),%eax
  801e18:	50                   	push   %eax
  801e19:	57                   	push   %edi
  801e1a:	e8 4a eb ff ff       	call   800969 <memmove>
		sys_cputs(buf, m);
  801e1f:	83 c4 08             	add    $0x8,%esp
  801e22:	53                   	push   %ebx
  801e23:	57                   	push   %edi
  801e24:	e8 f5 ec ff ff       	call   800b1e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e29:	01 de                	add    %ebx,%esi
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	89 f0                	mov    %esi,%eax
  801e30:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e33:	72 cc                	jb     801e01 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    

00801e3d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	83 ec 08             	sub    $0x8,%esp
  801e43:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e4c:	74 2a                	je     801e78 <devcons_read+0x3b>
  801e4e:	eb 05                	jmp    801e55 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e50:	e8 66 ed ff ff       	call   800bbb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e55:	e8 e2 ec ff ff       	call   800b3c <sys_cgetc>
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	74 f2                	je     801e50 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 16                	js     801e78 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e62:	83 f8 04             	cmp    $0x4,%eax
  801e65:	74 0c                	je     801e73 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6a:	88 02                	mov    %al,(%edx)
	return 1;
  801e6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e71:	eb 05                	jmp    801e78 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e73:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e78:	c9                   	leave  
  801e79:	c3                   	ret    

00801e7a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e80:	8b 45 08             	mov    0x8(%ebp),%eax
  801e83:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e86:	6a 01                	push   $0x1
  801e88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8b:	50                   	push   %eax
  801e8c:	e8 8d ec ff ff       	call   800b1e <sys_cputs>
}
  801e91:	83 c4 10             	add    $0x10,%esp
  801e94:	c9                   	leave  
  801e95:	c3                   	ret    

00801e96 <getchar>:

int
getchar(void)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e9c:	6a 01                	push   $0x1
  801e9e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea1:	50                   	push   %eax
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 1d f2 ff ff       	call   8010c6 <read>
	if (r < 0)
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	85 c0                	test   %eax,%eax
  801eae:	78 0f                	js     801ebf <getchar+0x29>
		return r;
	if (r < 1)
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	7e 06                	jle    801eba <getchar+0x24>
		return -E_EOF;
	return c;
  801eb4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801eb8:	eb 05                	jmp    801ebf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801eba:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ebf:	c9                   	leave  
  801ec0:	c3                   	ret    

00801ec1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eca:	50                   	push   %eax
  801ecb:	ff 75 08             	pushl  0x8(%ebp)
  801ece:	e8 8d ef ff ff       	call   800e60 <fd_lookup>
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 11                	js     801eeb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ee3:	39 10                	cmp    %edx,(%eax)
  801ee5:	0f 94 c0             	sete   %al
  801ee8:	0f b6 c0             	movzbl %al,%eax
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <opencons>:

int
opencons(void)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ef3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef6:	50                   	push   %eax
  801ef7:	e8 15 ef ff ff       	call   800e11 <fd_alloc>
  801efc:	83 c4 10             	add    $0x10,%esp
		return r;
  801eff:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f01:	85 c0                	test   %eax,%eax
  801f03:	78 3e                	js     801f43 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f05:	83 ec 04             	sub    $0x4,%esp
  801f08:	68 07 04 00 00       	push   $0x407
  801f0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f10:	6a 00                	push   $0x0
  801f12:	e8 c3 ec ff ff       	call   800bda <sys_page_alloc>
  801f17:	83 c4 10             	add    $0x10,%esp
		return r;
  801f1a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	78 23                	js     801f43 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f20:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f29:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f35:	83 ec 0c             	sub    $0xc,%esp
  801f38:	50                   	push   %eax
  801f39:	e8 ac ee ff ff       	call   800dea <fd2num>
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	83 c4 10             	add    $0x10,%esp
}
  801f43:	89 d0                	mov    %edx,%eax
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	56                   	push   %esi
  801f4b:	53                   	push   %ebx
  801f4c:	8b 75 08             	mov    0x8(%ebp),%esi
  801f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801f55:	85 c0                	test   %eax,%eax
  801f57:	74 0e                	je     801f67 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801f59:	83 ec 0c             	sub    $0xc,%esp
  801f5c:	50                   	push   %eax
  801f5d:	e8 28 ee ff ff       	call   800d8a <sys_ipc_recv>
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	eb 10                	jmp    801f77 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801f67:	83 ec 0c             	sub    $0xc,%esp
  801f6a:	68 00 00 c0 ee       	push   $0xeec00000
  801f6f:	e8 16 ee ff ff       	call   800d8a <sys_ipc_recv>
  801f74:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801f77:	85 c0                	test   %eax,%eax
  801f79:	79 17                	jns    801f92 <ipc_recv+0x4b>
		if(*from_env_store)
  801f7b:	83 3e 00             	cmpl   $0x0,(%esi)
  801f7e:	74 06                	je     801f86 <ipc_recv+0x3f>
			*from_env_store = 0;
  801f80:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801f86:	85 db                	test   %ebx,%ebx
  801f88:	74 2c                	je     801fb6 <ipc_recv+0x6f>
			*perm_store = 0;
  801f8a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f90:	eb 24                	jmp    801fb6 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801f92:	85 f6                	test   %esi,%esi
  801f94:	74 0a                	je     801fa0 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801f96:	a1 08 40 80 00       	mov    0x804008,%eax
  801f9b:	8b 40 74             	mov    0x74(%eax),%eax
  801f9e:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801fa0:	85 db                	test   %ebx,%ebx
  801fa2:	74 0a                	je     801fae <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801fa4:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa9:	8b 40 78             	mov    0x78(%eax),%eax
  801fac:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fae:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb3:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb9:	5b                   	pop    %ebx
  801fba:	5e                   	pop    %esi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    

00801fbd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	57                   	push   %edi
  801fc1:	56                   	push   %esi
  801fc2:	53                   	push   %ebx
  801fc3:	83 ec 0c             	sub    $0xc,%esp
  801fc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801fcf:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801fd1:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801fd6:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801fd9:	e8 dd eb ff ff       	call   800bbb <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801fde:	ff 75 14             	pushl  0x14(%ebp)
  801fe1:	53                   	push   %ebx
  801fe2:	56                   	push   %esi
  801fe3:	57                   	push   %edi
  801fe4:	e8 7e ed ff ff       	call   800d67 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801fe9:	89 c2                	mov    %eax,%edx
  801feb:	f7 d2                	not    %edx
  801fed:	c1 ea 1f             	shr    $0x1f,%edx
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff6:	0f 94 c1             	sete   %cl
  801ff9:	09 ca                	or     %ecx,%edx
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	0f 94 c0             	sete   %al
  802000:	38 c2                	cmp    %al,%dl
  802002:	77 d5                	ja     801fd9 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802007:	5b                   	pop    %ebx
  802008:	5e                   	pop    %esi
  802009:	5f                   	pop    %edi
  80200a:	5d                   	pop    %ebp
  80200b:	c3                   	ret    

0080200c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802012:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802017:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80201a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802020:	8b 52 50             	mov    0x50(%edx),%edx
  802023:	39 ca                	cmp    %ecx,%edx
  802025:	75 0d                	jne    802034 <ipc_find_env+0x28>
			return envs[i].env_id;
  802027:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80202a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80202f:	8b 40 48             	mov    0x48(%eax),%eax
  802032:	eb 0f                	jmp    802043 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802034:	83 c0 01             	add    $0x1,%eax
  802037:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203c:	75 d9                	jne    802017 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80203e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204b:	89 d0                	mov    %edx,%eax
  80204d:	c1 e8 16             	shr    $0x16,%eax
  802050:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802057:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205c:	f6 c1 01             	test   $0x1,%cl
  80205f:	74 1d                	je     80207e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802061:	c1 ea 0c             	shr    $0xc,%edx
  802064:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80206b:	f6 c2 01             	test   $0x1,%dl
  80206e:	74 0e                	je     80207e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802070:	c1 ea 0c             	shr    $0xc,%edx
  802073:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80207a:	ef 
  80207b:	0f b7 c0             	movzwl %ax,%eax
}
  80207e:	5d                   	pop    %ebp
  80207f:	c3                   	ret    

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80208b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80208f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 f6                	test   %esi,%esi
  802099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80209d:	89 ca                	mov    %ecx,%edx
  80209f:	89 f8                	mov    %edi,%eax
  8020a1:	75 3d                	jne    8020e0 <__udivdi3+0x60>
  8020a3:	39 cf                	cmp    %ecx,%edi
  8020a5:	0f 87 c5 00 00 00    	ja     802170 <__udivdi3+0xf0>
  8020ab:	85 ff                	test   %edi,%edi
  8020ad:	89 fd                	mov    %edi,%ebp
  8020af:	75 0b                	jne    8020bc <__udivdi3+0x3c>
  8020b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b6:	31 d2                	xor    %edx,%edx
  8020b8:	f7 f7                	div    %edi
  8020ba:	89 c5                	mov    %eax,%ebp
  8020bc:	89 c8                	mov    %ecx,%eax
  8020be:	31 d2                	xor    %edx,%edx
  8020c0:	f7 f5                	div    %ebp
  8020c2:	89 c1                	mov    %eax,%ecx
  8020c4:	89 d8                	mov    %ebx,%eax
  8020c6:	89 cf                	mov    %ecx,%edi
  8020c8:	f7 f5                	div    %ebp
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	39 ce                	cmp    %ecx,%esi
  8020e2:	77 74                	ja     802158 <__udivdi3+0xd8>
  8020e4:	0f bd fe             	bsr    %esi,%edi
  8020e7:	83 f7 1f             	xor    $0x1f,%edi
  8020ea:	0f 84 98 00 00 00    	je     802188 <__udivdi3+0x108>
  8020f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	89 c5                	mov    %eax,%ebp
  8020f9:	29 fb                	sub    %edi,%ebx
  8020fb:	d3 e6                	shl    %cl,%esi
  8020fd:	89 d9                	mov    %ebx,%ecx
  8020ff:	d3 ed                	shr    %cl,%ebp
  802101:	89 f9                	mov    %edi,%ecx
  802103:	d3 e0                	shl    %cl,%eax
  802105:	09 ee                	or     %ebp,%esi
  802107:	89 d9                	mov    %ebx,%ecx
  802109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210d:	89 d5                	mov    %edx,%ebp
  80210f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802113:	d3 ed                	shr    %cl,%ebp
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e2                	shl    %cl,%edx
  802119:	89 d9                	mov    %ebx,%ecx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	09 c2                	or     %eax,%edx
  80211f:	89 d0                	mov    %edx,%eax
  802121:	89 ea                	mov    %ebp,%edx
  802123:	f7 f6                	div    %esi
  802125:	89 d5                	mov    %edx,%ebp
  802127:	89 c3                	mov    %eax,%ebx
  802129:	f7 64 24 0c          	mull   0xc(%esp)
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	72 10                	jb     802141 <__udivdi3+0xc1>
  802131:	8b 74 24 08          	mov    0x8(%esp),%esi
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e6                	shl    %cl,%esi
  802139:	39 c6                	cmp    %eax,%esi
  80213b:	73 07                	jae    802144 <__udivdi3+0xc4>
  80213d:	39 d5                	cmp    %edx,%ebp
  80213f:	75 03                	jne    802144 <__udivdi3+0xc4>
  802141:	83 eb 01             	sub    $0x1,%ebx
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 d8                	mov    %ebx,%eax
  802148:	89 fa                	mov    %edi,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	31 db                	xor    %ebx,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	89 d8                	mov    %ebx,%eax
  802172:	f7 f7                	div    %edi
  802174:	31 ff                	xor    %edi,%edi
  802176:	89 c3                	mov    %eax,%ebx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 fa                	mov    %edi,%edx
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	39 ce                	cmp    %ecx,%esi
  80218a:	72 0c                	jb     802198 <__udivdi3+0x118>
  80218c:	31 db                	xor    %ebx,%ebx
  80218e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802192:	0f 87 34 ff ff ff    	ja     8020cc <__udivdi3+0x4c>
  802198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80219d:	e9 2a ff ff ff       	jmp    8020cc <__udivdi3+0x4c>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f3                	mov    %esi,%ebx
  8021d3:	89 3c 24             	mov    %edi,(%esp)
  8021d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021da:	75 1c                	jne    8021f8 <__umoddi3+0x48>
  8021dc:	39 f7                	cmp    %esi,%edi
  8021de:	76 50                	jbe    802230 <__umoddi3+0x80>
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	f7 f7                	div    %edi
  8021e6:	89 d0                	mov    %edx,%eax
  8021e8:	31 d2                	xor    %edx,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	39 f2                	cmp    %esi,%edx
  8021fa:	89 d0                	mov    %edx,%eax
  8021fc:	77 52                	ja     802250 <__umoddi3+0xa0>
  8021fe:	0f bd ea             	bsr    %edx,%ebp
  802201:	83 f5 1f             	xor    $0x1f,%ebp
  802204:	75 5a                	jne    802260 <__umoddi3+0xb0>
  802206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80220a:	0f 82 e0 00 00 00    	jb     8022f0 <__umoddi3+0x140>
  802210:	39 0c 24             	cmp    %ecx,(%esp)
  802213:	0f 86 d7 00 00 00    	jbe    8022f0 <__umoddi3+0x140>
  802219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80221d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	85 ff                	test   %edi,%edi
  802232:	89 fd                	mov    %edi,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x91>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f7                	div    %edi
  80223f:	89 c5                	mov    %eax,%ebp
  802241:	89 f0                	mov    %esi,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f5                	div    %ebp
  802247:	89 c8                	mov    %ecx,%eax
  802249:	f7 f5                	div    %ebp
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	eb 99                	jmp    8021e8 <__umoddi3+0x38>
  80224f:	90                   	nop
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 1c             	add    $0x1c,%esp
  802257:	5b                   	pop    %ebx
  802258:	5e                   	pop    %esi
  802259:	5f                   	pop    %edi
  80225a:	5d                   	pop    %ebp
  80225b:	c3                   	ret    
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	8b 34 24             	mov    (%esp),%esi
  802263:	bf 20 00 00 00       	mov    $0x20,%edi
  802268:	89 e9                	mov    %ebp,%ecx
  80226a:	29 ef                	sub    %ebp,%edi
  80226c:	d3 e0                	shl    %cl,%eax
  80226e:	89 f9                	mov    %edi,%ecx
  802270:	89 f2                	mov    %esi,%edx
  802272:	d3 ea                	shr    %cl,%edx
  802274:	89 e9                	mov    %ebp,%ecx
  802276:	09 c2                	or     %eax,%edx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 14 24             	mov    %edx,(%esp)
  80227d:	89 f2                	mov    %esi,%edx
  80227f:	d3 e2                	shl    %cl,%edx
  802281:	89 f9                	mov    %edi,%ecx
  802283:	89 54 24 04          	mov    %edx,0x4(%esp)
  802287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	89 c6                	mov    %eax,%esi
  802291:	d3 e3                	shl    %cl,%ebx
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 d0                	mov    %edx,%eax
  802297:	d3 e8                	shr    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	09 d8                	or     %ebx,%eax
  80229d:	89 d3                	mov    %edx,%ebx
  80229f:	89 f2                	mov    %esi,%edx
  8022a1:	f7 34 24             	divl   (%esp)
  8022a4:	89 d6                	mov    %edx,%esi
  8022a6:	d3 e3                	shl    %cl,%ebx
  8022a8:	f7 64 24 04          	mull   0x4(%esp)
  8022ac:	39 d6                	cmp    %edx,%esi
  8022ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022b2:	89 d1                	mov    %edx,%ecx
  8022b4:	89 c3                	mov    %eax,%ebx
  8022b6:	72 08                	jb     8022c0 <__umoddi3+0x110>
  8022b8:	75 11                	jne    8022cb <__umoddi3+0x11b>
  8022ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022be:	73 0b                	jae    8022cb <__umoddi3+0x11b>
  8022c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022c4:	1b 14 24             	sbb    (%esp),%edx
  8022c7:	89 d1                	mov    %edx,%ecx
  8022c9:	89 c3                	mov    %eax,%ebx
  8022cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022cf:	29 da                	sub    %ebx,%edx
  8022d1:	19 ce                	sbb    %ecx,%esi
  8022d3:	89 f9                	mov    %edi,%ecx
  8022d5:	89 f0                	mov    %esi,%eax
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	89 e9                	mov    %ebp,%ecx
  8022db:	d3 ea                	shr    %cl,%edx
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	d3 ee                	shr    %cl,%esi
  8022e1:	09 d0                	or     %edx,%eax
  8022e3:	89 f2                	mov    %esi,%edx
  8022e5:	83 c4 1c             	add    $0x1c,%esp
  8022e8:	5b                   	pop    %ebx
  8022e9:	5e                   	pop    %esi
  8022ea:	5f                   	pop    %edi
  8022eb:	5d                   	pop    %ebp
  8022ec:	c3                   	ret    
  8022ed:	8d 76 00             	lea    0x0(%esi),%esi
  8022f0:	29 f9                	sub    %edi,%ecx
  8022f2:	19 d6                	sbb    %edx,%esi
  8022f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022fc:	e9 18 ff ff ff       	jmp    802219 <__umoddi3+0x69>
