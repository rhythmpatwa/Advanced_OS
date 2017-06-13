
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 c9 10 00 00       	call   801115 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 08 40 80 00       	mov    0x804008,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 e0 26 80 00       	push   $0x8026e0
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 73 0e 00 00       	call   800edd <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 ec 26 80 00       	push   $0x8026ec
  800079:	6a 1a                	push   $0x1a
  80007b:	68 f5 26 80 00       	push   $0x8026f5
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 7c 10 00 00       	call   801115 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 db 10 00 00       	call   80118b <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 1e 0e 00 00       	call   800edd <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 ec 26 80 00       	push   $0x8026ec
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 f5 26 80 00       	push   $0x8026f5
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 9b 10 00 00       	call   80118b <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800103:	e8 93 0a 00 00       	call   800b9b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 95 12 00 00       	call   8013de <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 07 0a 00 00       	call   800b5a <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 30 0a 00 00       	call   800b9b <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 10 27 80 00       	push   $0x802710
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 1f 2c 80 00 	movl   $0x802c1f,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 4f 09 00 00       	call   800b1d <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 54 01 00 00       	call   800368 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 f4 08 00 00       	call   800b1d <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 b7 21 00 00       	call   802450 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 a4 22 00 00       	call   802580 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 33 27 80 00 	movsbl 0x802733(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f7:	83 fa 01             	cmp    $0x1,%edx
  8002fa:	7e 0e                	jle    80030a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 08             	lea    0x8(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	8b 52 04             	mov    0x4(%edx),%edx
  800308:	eb 22                	jmp    80032c <getuint+0x38>
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 10                	je     80031e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	eb 0e                	jmp    80032c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 04             	lea    0x4(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800334:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	3b 50 04             	cmp    0x4(%eax),%edx
  80033d:	73 0a                	jae    800349 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800342:	89 08                	mov    %ecx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	88 02                	mov    %al,(%edx)
}
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800351:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800354:	50                   	push   %eax
  800355:	ff 75 10             	pushl  0x10(%ebp)
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	e8 05 00 00 00       	call   800368 <vprintfmt>
	va_end(ap);
}
  800363:	83 c4 10             	add    $0x10,%esp
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 2c             	sub    $0x2c,%esp
  800371:	8b 75 08             	mov    0x8(%ebp),%esi
  800374:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800377:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037a:	eb 12                	jmp    80038e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037c:	85 c0                	test   %eax,%eax
  80037e:	0f 84 a9 03 00 00    	je     80072d <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	53                   	push   %ebx
  800388:	50                   	push   %eax
  800389:	ff d6                	call   *%esi
  80038b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	83 c7 01             	add    $0x1,%edi
  800391:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800395:	83 f8 25             	cmp    $0x25,%eax
  800398:	75 e2                	jne    80037c <vprintfmt+0x14>
  80039a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b8:	eb 07                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 07             	movzbl (%edi),%eax
  8003ca:	0f b6 c8             	movzbl %al,%ecx
  8003cd:	83 e8 23             	sub    $0x23,%eax
  8003d0:	3c 55                	cmp    $0x55,%al
  8003d2:	0f 87 3a 03 00 00    	ja     800712 <vprintfmt+0x3aa>
  8003d8:	0f b6 c0             	movzbl %al,%eax
  8003db:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e9:	eb d6                	jmp    8003c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800400:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800403:	83 fa 09             	cmp    $0x9,%edx
  800406:	77 39                	ja     800441 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800408:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040b:	eb e9                	jmp    8003f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 48 04             	lea    0x4(%eax),%ecx
  800413:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041e:	eb 27                	jmp    800447 <vprintfmt+0xdf>
  800420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	0f 49 c8             	cmovns %eax,%ecx
  80042d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800433:	eb 8c                	jmp    8003c1 <vprintfmt+0x59>
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800438:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043f:	eb 80                	jmp    8003c1 <vprintfmt+0x59>
  800441:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800444:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800447:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044b:	0f 89 70 ff ff ff    	jns    8003c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800451:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800454:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800457:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045e:	e9 5e ff ff ff       	jmp    8003c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800463:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800469:	e9 53 ff ff ff       	jmp    8003c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	ff 30                	pushl  (%eax)
  80047d:	ff d6                	call   *%esi
			break;
  80047f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800485:	e9 04 ff ff ff       	jmp    80038e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 50 04             	lea    0x4(%eax),%edx
  800490:	89 55 14             	mov    %edx,0x14(%ebp)
  800493:	8b 00                	mov    (%eax),%eax
  800495:	99                   	cltd   
  800496:	31 d0                	xor    %edx,%eax
  800498:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049a:	83 f8 0f             	cmp    $0xf,%eax
  80049d:	7f 0b                	jg     8004aa <vprintfmt+0x142>
  80049f:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  8004a6:	85 d2                	test   %edx,%edx
  8004a8:	75 18                	jne    8004c2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004aa:	50                   	push   %eax
  8004ab:	68 4b 27 80 00       	push   $0x80274b
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 94 fe ff ff       	call   80034b <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bd:	e9 cc fe ff ff       	jmp    80038e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	68 ed 2b 80 00       	push   $0x802bed
  8004c8:	53                   	push   %ebx
  8004c9:	56                   	push   %esi
  8004ca:	e8 7c fe ff ff       	call   80034b <printfmt>
  8004cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d5:	e9 b4 fe ff ff       	jmp    80038e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	b8 44 27 80 00       	mov    $0x802744,%eax
  8004ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f3:	0f 8e 94 00 00 00    	jle    80058d <vprintfmt+0x225>
  8004f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fd:	0f 84 98 00 00 00    	je     80059b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	ff 75 d0             	pushl  -0x30(%ebp)
  800509:	57                   	push   %edi
  80050a:	e8 a6 02 00 00       	call   8007b5 <strnlen>
  80050f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800521:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800524:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800526:	eb 0f                	jmp    800537 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	ff 75 e0             	pushl  -0x20(%ebp)
  80052f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	85 ff                	test   %edi,%edi
  800539:	7f ed                	jg     800528 <vprintfmt+0x1c0>
  80053b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800541:	85 c9                	test   %ecx,%ecx
  800543:	b8 00 00 00 00       	mov    $0x0,%eax
  800548:	0f 49 c1             	cmovns %ecx,%eax
  80054b:	29 c1                	sub    %eax,%ecx
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	89 cb                	mov    %ecx,%ebx
  800558:	eb 4d                	jmp    8005a7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055e:	74 1b                	je     80057b <vprintfmt+0x213>
  800560:	0f be c0             	movsbl %al,%eax
  800563:	83 e8 20             	sub    $0x20,%eax
  800566:	83 f8 5e             	cmp    $0x5e,%eax
  800569:	76 10                	jbe    80057b <vprintfmt+0x213>
					putch('?', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	6a 3f                	push   $0x3f
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 0d                	jmp    800588 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	52                   	push   %edx
  800582:	ff 55 08             	call   *0x8(%ebp)
  800585:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800588:	83 eb 01             	sub    $0x1,%ebx
  80058b:	eb 1a                	jmp    8005a7 <vprintfmt+0x23f>
  80058d:	89 75 08             	mov    %esi,0x8(%ebp)
  800590:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800593:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800596:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800599:	eb 0c                	jmp    8005a7 <vprintfmt+0x23f>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	83 c7 01             	add    $0x1,%edi
  8005aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ae:	0f be d0             	movsbl %al,%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	74 23                	je     8005d8 <vprintfmt+0x270>
  8005b5:	85 f6                	test   %esi,%esi
  8005b7:	78 a1                	js     80055a <vprintfmt+0x1f2>
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	79 9c                	jns    80055a <vprintfmt+0x1f2>
  8005be:	89 df                	mov    %ebx,%edi
  8005c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c6:	eb 18                	jmp    8005e0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 20                	push   $0x20
  8005ce:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 08                	jmp    8005e0 <vprintfmt+0x278>
  8005d8:	89 df                	mov    %ebx,%edi
  8005da:	8b 75 08             	mov    0x8(%ebp),%esi
  8005dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e0:	85 ff                	test   %edi,%edi
  8005e2:	7f e4                	jg     8005c8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a2 fd ff ff       	jmp    80038e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 fa 01             	cmp    $0x1,%edx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x2d1>
	else if (lflag)
  800607:	85 d2                	test   %edx,%edx
  800609:	74 18                	je     800623 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c1                	mov    %eax,%ecx
  800633:	c1 f9 1f             	sar    $0x1f,%ecx
  800636:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	0f 89 90 00 00 00    	jns    8006de <vprintfmt+0x376>
				putch('-', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 2d                	push   $0x2d
  800654:	ff d6                	call   *%esi
				num = -(long long) num;
  800656:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800659:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065c:	f7 d8                	neg    %eax
  80065e:	83 d2 00             	adc    $0x0,%edx
  800661:	f7 da                	neg    %edx
  800663:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800666:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066b:	eb 71                	jmp    8006de <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 7f fc ff ff       	call   8002f4 <getuint>
			base = 10;
  800675:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067a:	eb 62                	jmp    8006de <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067c:	8d 45 14             	lea    0x14(%ebp),%eax
  80067f:	e8 70 fc ff ff       	call   8002f4 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800684:	83 ec 0c             	sub    $0xc,%esp
  800687:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80068b:	51                   	push   %ecx
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	6a 08                	push   $0x8
  800691:	52                   	push   %edx
  800692:	50                   	push   %eax
  800693:	89 da                	mov    %ebx,%edx
  800695:	89 f0                	mov    %esi,%eax
  800697:	e8 a9 fb ff ff       	call   800245 <printnum>
			break;
  80069c:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8006a2:	e9 e7 fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 30                	push   $0x30
  8006ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 78                	push   $0x78
  8006b5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8d 50 04             	lea    0x4(%eax),%edx
  8006bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ca:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006cf:	eb 0d                	jmp    8006de <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 1b fc ff ff       	call   8002f4 <getuint>
			base = 16;
  8006d9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006de:	83 ec 0c             	sub    $0xc,%esp
  8006e1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e5:	57                   	push   %edi
  8006e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e9:	51                   	push   %ecx
  8006ea:	52                   	push   %edx
  8006eb:	50                   	push   %eax
  8006ec:	89 da                	mov    %ebx,%edx
  8006ee:	89 f0                	mov    %esi,%eax
  8006f0:	e8 50 fb ff ff       	call   800245 <printnum>
			break;
  8006f5:	83 c4 20             	add    $0x20,%esp
  8006f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fb:	e9 8e fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	51                   	push   %ecx
  800705:	ff d6                	call   *%esi
			break;
  800707:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070d:	e9 7c fc ff ff       	jmp    80038e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 25                	push   $0x25
  800718:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 03                	jmp    800722 <vprintfmt+0x3ba>
  80071f:	83 ef 01             	sub    $0x1,%edi
  800722:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800726:	75 f7                	jne    80071f <vprintfmt+0x3b7>
  800728:	e9 61 fc ff ff       	jmp    80038e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800730:	5b                   	pop    %ebx
  800731:	5e                   	pop    %esi
  800732:	5f                   	pop    %edi
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 18             	sub    $0x18,%esp
  80073b:	8b 45 08             	mov    0x8(%ebp),%eax
  80073e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800741:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800744:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800748:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800752:	85 c0                	test   %eax,%eax
  800754:	74 26                	je     80077c <vsnprintf+0x47>
  800756:	85 d2                	test   %edx,%edx
  800758:	7e 22                	jle    80077c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075a:	ff 75 14             	pushl  0x14(%ebp)
  80075d:	ff 75 10             	pushl  0x10(%ebp)
  800760:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	68 2e 03 80 00       	push   $0x80032e
  800769:	e8 fa fb ff ff       	call   800368 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800771:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	eb 05                	jmp    800781 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800781:	c9                   	leave  
  800782:	c3                   	ret    

00800783 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800789:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078c:	50                   	push   %eax
  80078d:	ff 75 10             	pushl  0x10(%ebp)
  800790:	ff 75 0c             	pushl  0xc(%ebp)
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 9a ff ff ff       	call   800735 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a8:	eb 03                	jmp    8007ad <strlen+0x10>
		n++;
  8007aa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b1:	75 f7                	jne    8007aa <strlen+0xd>
		n++;
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c3:	eb 03                	jmp    8007c8 <strnlen+0x13>
		n++;
  8007c5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	39 c2                	cmp    %eax,%edx
  8007ca:	74 08                	je     8007d4 <strnlen+0x1f>
  8007cc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d0:	75 f3                	jne    8007c5 <strnlen+0x10>
  8007d2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e0:	89 c2                	mov    %eax,%edx
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ef                	jne    8007e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f3:	5b                   	pop    %ebx
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	53                   	push   %ebx
  8007fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fd:	53                   	push   %ebx
  8007fe:	e8 9a ff ff ff       	call   80079d <strlen>
  800803:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800806:	ff 75 0c             	pushl  0xc(%ebp)
  800809:	01 d8                	add    %ebx,%eax
  80080b:	50                   	push   %eax
  80080c:	e8 c5 ff ff ff       	call   8007d6 <strcpy>
	return dst;
}
  800811:	89 d8                	mov    %ebx,%eax
  800813:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	56                   	push   %esi
  80081c:	53                   	push   %ebx
  80081d:	8b 75 08             	mov    0x8(%ebp),%esi
  800820:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800823:	89 f3                	mov    %esi,%ebx
  800825:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	89 f2                	mov    %esi,%edx
  80082a:	eb 0f                	jmp    80083b <strncpy+0x23>
		*dst++ = *src;
  80082c:	83 c2 01             	add    $0x1,%edx
  80082f:	0f b6 01             	movzbl (%ecx),%eax
  800832:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800835:	80 39 01             	cmpb   $0x1,(%ecx)
  800838:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	39 da                	cmp    %ebx,%edx
  80083d:	75 ed                	jne    80082c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083f:	89 f0                	mov    %esi,%eax
  800841:	5b                   	pop    %ebx
  800842:	5e                   	pop    %esi
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	8b 75 08             	mov    0x8(%ebp),%esi
  80084d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800850:	8b 55 10             	mov    0x10(%ebp),%edx
  800853:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800855:	85 d2                	test   %edx,%edx
  800857:	74 21                	je     80087a <strlcpy+0x35>
  800859:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085d:	89 f2                	mov    %esi,%edx
  80085f:	eb 09                	jmp    80086a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	83 c1 01             	add    $0x1,%ecx
  800867:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086a:	39 c2                	cmp    %eax,%edx
  80086c:	74 09                	je     800877 <strlcpy+0x32>
  80086e:	0f b6 19             	movzbl (%ecx),%ebx
  800871:	84 db                	test   %bl,%bl
  800873:	75 ec                	jne    800861 <strlcpy+0x1c>
  800875:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800877:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087a:	29 f0                	sub    %esi,%eax
}
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800889:	eb 06                	jmp    800891 <strcmp+0x11>
		p++, q++;
  80088b:	83 c1 01             	add    $0x1,%ecx
  80088e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800891:	0f b6 01             	movzbl (%ecx),%eax
  800894:	84 c0                	test   %al,%al
  800896:	74 04                	je     80089c <strcmp+0x1c>
  800898:	3a 02                	cmp    (%edx),%al
  80089a:	74 ef                	je     80088b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089c:	0f b6 c0             	movzbl %al,%eax
  80089f:	0f b6 12             	movzbl (%edx),%edx
  8008a2:	29 d0                	sub    %edx,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b0:	89 c3                	mov    %eax,%ebx
  8008b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b5:	eb 06                	jmp    8008bd <strncmp+0x17>
		n--, p++, q++;
  8008b7:	83 c0 01             	add    $0x1,%eax
  8008ba:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bd:	39 d8                	cmp    %ebx,%eax
  8008bf:	74 15                	je     8008d6 <strncmp+0x30>
  8008c1:	0f b6 08             	movzbl (%eax),%ecx
  8008c4:	84 c9                	test   %cl,%cl
  8008c6:	74 04                	je     8008cc <strncmp+0x26>
  8008c8:	3a 0a                	cmp    (%edx),%cl
  8008ca:	74 eb                	je     8008b7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cc:	0f b6 00             	movzbl (%eax),%eax
  8008cf:	0f b6 12             	movzbl (%edx),%edx
  8008d2:	29 d0                	sub    %edx,%eax
  8008d4:	eb 05                	jmp    8008db <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008db:	5b                   	pop    %ebx
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	eb 07                	jmp    8008f1 <strchr+0x13>
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 0f                	je     8008fd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	0f b6 10             	movzbl (%eax),%edx
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	75 f2                	jne    8008ea <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800909:	eb 03                	jmp    80090e <strfind+0xf>
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 04                	je     800919 <strfind+0x1a>
  800915:	84 d2                	test   %dl,%dl
  800917:	75 f2                	jne    80090b <strfind+0xc>
			break;
	return (char *) s;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	57                   	push   %edi
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	8b 7d 08             	mov    0x8(%ebp),%edi
  800924:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800927:	85 c9                	test   %ecx,%ecx
  800929:	74 36                	je     800961 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800931:	75 28                	jne    80095b <memset+0x40>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 23                	jne    80095b <memset+0x40>
		c &= 0xFF;
  800938:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093c:	89 d3                	mov    %edx,%ebx
  80093e:	c1 e3 08             	shl    $0x8,%ebx
  800941:	89 d6                	mov    %edx,%esi
  800943:	c1 e6 18             	shl    $0x18,%esi
  800946:	89 d0                	mov    %edx,%eax
  800948:	c1 e0 10             	shl    $0x10,%eax
  80094b:	09 f0                	or     %esi,%eax
  80094d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80094f:	89 d8                	mov    %ebx,%eax
  800951:	09 d0                	or     %edx,%eax
  800953:	c1 e9 02             	shr    $0x2,%ecx
  800956:	fc                   	cld    
  800957:	f3 ab                	rep stos %eax,%es:(%edi)
  800959:	eb 06                	jmp    800961 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	fc                   	cld    
  80095f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800961:	89 f8                	mov    %edi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 35                	jae    8009af <memmove+0x47>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 d0                	cmp    %edx,%eax
  80097f:	73 2e                	jae    8009af <memmove+0x47>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 d6                	mov    %edx,%esi
  800986:	09 fe                	or     %edi,%esi
  800988:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098e:	75 13                	jne    8009a3 <memmove+0x3b>
  800990:	f6 c1 03             	test   $0x3,%cl
  800993:	75 0e                	jne    8009a3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800995:	83 ef 04             	sub    $0x4,%edi
  800998:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099b:	c1 e9 02             	shr    $0x2,%ecx
  80099e:	fd                   	std    
  80099f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a1:	eb 09                	jmp    8009ac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a3:	83 ef 01             	sub    $0x1,%edi
  8009a6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a9:	fd                   	std    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ac:	fc                   	cld    
  8009ad:	eb 1d                	jmp    8009cc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	89 f2                	mov    %esi,%edx
  8009b1:	09 c2                	or     %eax,%edx
  8009b3:	f6 c2 03             	test   $0x3,%dl
  8009b6:	75 0f                	jne    8009c7 <memmove+0x5f>
  8009b8:	f6 c1 03             	test   $0x3,%cl
  8009bb:	75 0a                	jne    8009c7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
  8009c0:	89 c7                	mov    %eax,%edi
  8009c2:	fc                   	cld    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb 05                	jmp    8009cc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c7:	89 c7                	mov    %eax,%edi
  8009c9:	fc                   	cld    
  8009ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009cc:	5e                   	pop    %esi
  8009cd:	5f                   	pop    %edi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d3:	ff 75 10             	pushl  0x10(%ebp)
  8009d6:	ff 75 0c             	pushl  0xc(%ebp)
  8009d9:	ff 75 08             	pushl  0x8(%ebp)
  8009dc:	e8 87 ff ff ff       	call   800968 <memmove>
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ee:	89 c6                	mov    %eax,%esi
  8009f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f3:	eb 1a                	jmp    800a0f <memcmp+0x2c>
		if (*s1 != *s2)
  8009f5:	0f b6 08             	movzbl (%eax),%ecx
  8009f8:	0f b6 1a             	movzbl (%edx),%ebx
  8009fb:	38 d9                	cmp    %bl,%cl
  8009fd:	74 0a                	je     800a09 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ff:	0f b6 c1             	movzbl %cl,%eax
  800a02:	0f b6 db             	movzbl %bl,%ebx
  800a05:	29 d8                	sub    %ebx,%eax
  800a07:	eb 0f                	jmp    800a18 <memcmp+0x35>
		s1++, s2++;
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	39 f0                	cmp    %esi,%eax
  800a11:	75 e2                	jne    8009f5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	53                   	push   %ebx
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a23:	89 c1                	mov    %eax,%ecx
  800a25:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2c:	eb 0a                	jmp    800a38 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2e:	0f b6 10             	movzbl (%eax),%edx
  800a31:	39 da                	cmp    %ebx,%edx
  800a33:	74 07                	je     800a3c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	39 c8                	cmp    %ecx,%eax
  800a3a:	72 f2                	jb     800a2e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4b:	eb 03                	jmp    800a50 <strtol+0x11>
		s++;
  800a4d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a50:	0f b6 01             	movzbl (%ecx),%eax
  800a53:	3c 20                	cmp    $0x20,%al
  800a55:	74 f6                	je     800a4d <strtol+0xe>
  800a57:	3c 09                	cmp    $0x9,%al
  800a59:	74 f2                	je     800a4d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5b:	3c 2b                	cmp    $0x2b,%al
  800a5d:	75 0a                	jne    800a69 <strtol+0x2a>
		s++;
  800a5f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
  800a67:	eb 11                	jmp    800a7a <strtol+0x3b>
  800a69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6e:	3c 2d                	cmp    $0x2d,%al
  800a70:	75 08                	jne    800a7a <strtol+0x3b>
		s++, neg = 1;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a80:	75 15                	jne    800a97 <strtol+0x58>
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	75 10                	jne    800a97 <strtol+0x58>
  800a87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8b:	75 7c                	jne    800b09 <strtol+0xca>
		s += 2, base = 16;
  800a8d:	83 c1 02             	add    $0x2,%ecx
  800a90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a95:	eb 16                	jmp    800aad <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a97:	85 db                	test   %ebx,%ebx
  800a99:	75 12                	jne    800aad <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa0:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa3:	75 08                	jne    800aad <strtol+0x6e>
		s++, base = 8;
  800aa5:	83 c1 01             	add    $0x1,%ecx
  800aa8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab5:	0f b6 11             	movzbl (%ecx),%edx
  800ab8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abb:	89 f3                	mov    %esi,%ebx
  800abd:	80 fb 09             	cmp    $0x9,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x8b>
			dig = *s - '0';
  800ac2:	0f be d2             	movsbl %dl,%edx
  800ac5:	83 ea 30             	sub    $0x30,%edx
  800ac8:	eb 22                	jmp    800aec <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aca:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acd:	89 f3                	mov    %esi,%ebx
  800acf:	80 fb 19             	cmp    $0x19,%bl
  800ad2:	77 08                	ja     800adc <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad4:	0f be d2             	movsbl %dl,%edx
  800ad7:	83 ea 57             	sub    $0x57,%edx
  800ada:	eb 10                	jmp    800aec <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800adc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 16                	ja     800afc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aec:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aef:	7d 0b                	jge    800afc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afa:	eb b9                	jmp    800ab5 <strtol+0x76>

	if (endptr)
  800afc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b00:	74 0d                	je     800b0f <strtol+0xd0>
		*endptr = (char *) s;
  800b02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b05:	89 0e                	mov    %ecx,(%esi)
  800b07:	eb 06                	jmp    800b0f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b09:	85 db                	test   %ebx,%ebx
  800b0b:	74 98                	je     800aa5 <strtol+0x66>
  800b0d:	eb 9e                	jmp    800aad <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	f7 da                	neg    %edx
  800b13:	85 ff                	test   %edi,%edi
  800b15:	0f 45 c2             	cmovne %edx,%eax
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	89 c3                	mov    %eax,%ebx
  800b30:	89 c7                	mov    %eax,%edi
  800b32:	89 c6                	mov    %eax,%esi
  800b34:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b68:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	89 cb                	mov    %ecx,%ebx
  800b72:	89 cf                	mov    %ecx,%edi
  800b74:	89 ce                	mov    %ecx,%esi
  800b76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 17                	jle    800b93 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	50                   	push   %eax
  800b80:	6a 03                	push   $0x3
  800b82:	68 3f 2a 80 00       	push   $0x802a3f
  800b87:	6a 23                	push   $0x23
  800b89:	68 5c 2a 80 00       	push   $0x802a5c
  800b8e:	e8 c5 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 02 00 00 00       	mov    $0x2,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_yield>:

void
sys_yield(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	be 00 00 00 00       	mov    $0x0,%esi
  800be7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf5:	89 f7                	mov    %esi,%edi
  800bf7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 17                	jle    800c14 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 04                	push   $0x4
  800c03:	68 3f 2a 80 00       	push   $0x802a3f
  800c08:	6a 23                	push   $0x23
  800c0a:	68 5c 2a 80 00       	push   $0x802a5c
  800c0f:	e8 44 f5 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c25:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c36:	8b 75 18             	mov    0x18(%ebp),%esi
  800c39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 05                	push   $0x5
  800c45:	68 3f 2a 80 00       	push   $0x802a3f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 5c 2a 80 00       	push   $0x802a5c
  800c51:	e8 02 f5 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 17                	jle    800c98 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 06                	push   $0x6
  800c87:	68 3f 2a 80 00       	push   $0x802a3f
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 5c 2a 80 00       	push   $0x802a5c
  800c93:	e8 c0 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cae:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	89 df                	mov    %ebx,%edi
  800cbb:	89 de                	mov    %ebx,%esi
  800cbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	7e 17                	jle    800cda <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 08                	push   $0x8
  800cc9:	68 3f 2a 80 00       	push   $0x802a3f
  800cce:	6a 23                	push   $0x23
  800cd0:	68 5c 2a 80 00       	push   $0x802a5c
  800cd5:	e8 7e f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 df                	mov    %ebx,%edi
  800cfd:	89 de                	mov    %ebx,%esi
  800cff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	7e 17                	jle    800d1c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 09                	push   $0x9
  800d0b:	68 3f 2a 80 00       	push   $0x802a3f
  800d10:	6a 23                	push   $0x23
  800d12:	68 5c 2a 80 00       	push   $0x802a5c
  800d17:	e8 3c f4 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d32:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	89 df                	mov    %ebx,%edi
  800d3f:	89 de                	mov    %ebx,%esi
  800d41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d43:	85 c0                	test   %eax,%eax
  800d45:	7e 17                	jle    800d5e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 0a                	push   $0xa
  800d4d:	68 3f 2a 80 00       	push   $0x802a3f
  800d52:	6a 23                	push   $0x23
  800d54:	68 5c 2a 80 00       	push   $0x802a5c
  800d59:	e8 fa f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
  800d8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d97:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9f:	89 cb                	mov    %ecx,%ebx
  800da1:	89 cf                	mov    %ecx,%edi
  800da3:	89 ce                	mov    %ecx,%esi
  800da5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7e 17                	jle    800dc2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 0d                	push   $0xd
  800db1:	68 3f 2a 80 00       	push   $0x802a3f
  800db6:	6a 23                	push   $0x23
  800db8:	68 5c 2a 80 00       	push   $0x802a5c
  800dbd:	e8 96 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dda:	89 d1                	mov    %edx,%ecx
  800ddc:	89 d3                	mov    %edx,%ebx
  800dde:	89 d7                	mov    %edx,%edi
  800de0:	89 d6                	mov    %edx,%esi
  800de2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	53                   	push   %ebx
  800ded:	83 ec 04             	sub    $0x4,%esp
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800df3:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800df5:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800df8:	f6 c1 02             	test   $0x2,%cl
  800dfb:	74 2e                	je     800e2b <pgfault+0x42>
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	c1 ea 16             	shr    $0x16,%edx
  800e02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e09:	f6 c2 01             	test   $0x1,%dl
  800e0c:	74 1d                	je     800e2b <pgfault+0x42>
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	c1 ea 0c             	shr    $0xc,%edx
  800e13:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800e1a:	f6 c3 01             	test   $0x1,%bl
  800e1d:	74 0c                	je     800e2b <pgfault+0x42>
  800e1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e26:	f6 c6 08             	test   $0x8,%dh
  800e29:	75 12                	jne    800e3d <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800e2b:	51                   	push   %ecx
  800e2c:	68 6a 2a 80 00       	push   $0x802a6a
  800e31:	6a 1e                	push   $0x1e
  800e33:	68 83 2a 80 00       	push   $0x802a83
  800e38:	e8 1b f3 ff ff       	call   800158 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800e3d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e42:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800e44:	83 ec 04             	sub    $0x4,%esp
  800e47:	6a 07                	push   $0x7
  800e49:	68 00 f0 7f 00       	push   $0x7ff000
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 84 fd ff ff       	call   800bd9 <sys_page_alloc>
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	79 12                	jns    800e6e <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800e5c:	50                   	push   %eax
  800e5d:	68 8e 2a 80 00       	push   $0x802a8e
  800e62:	6a 29                	push   $0x29
  800e64:	68 83 2a 80 00       	push   $0x802a83
  800e69:	e8 ea f2 ff ff       	call   800158 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800e6e:	83 ec 04             	sub    $0x4,%esp
  800e71:	68 00 10 00 00       	push   $0x1000
  800e76:	53                   	push   %ebx
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	e8 4f fb ff ff       	call   8009d0 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e81:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e88:	53                   	push   %ebx
  800e89:	6a 00                	push   $0x0
  800e8b:	68 00 f0 7f 00       	push   $0x7ff000
  800e90:	6a 00                	push   $0x0
  800e92:	e8 85 fd ff ff       	call   800c1c <sys_page_map>
  800e97:	83 c4 20             	add    $0x20,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 12                	jns    800eb0 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800e9e:	50                   	push   %eax
  800e9f:	68 a9 2a 80 00       	push   $0x802aa9
  800ea4:	6a 2e                	push   $0x2e
  800ea6:	68 83 2a 80 00       	push   $0x802a83
  800eab:	e8 a8 f2 ff ff       	call   800158 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	68 00 f0 7f 00       	push   $0x7ff000
  800eb8:	6a 00                	push   $0x0
  800eba:	e8 9f fd ff ff       	call   800c5e <sys_page_unmap>
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	79 12                	jns    800ed8 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800ec6:	50                   	push   %eax
  800ec7:	68 c2 2a 80 00       	push   $0x802ac2
  800ecc:	6a 31                	push   $0x31
  800ece:	68 83 2a 80 00       	push   $0x802a83
  800ed3:	e8 80 f2 ff ff       	call   800158 <_panic>

}
  800ed8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800ee6:	68 e9 0d 80 00       	push   $0x800de9
  800eeb:	e8 80 14 00 00       	call   802370 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ef0:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef5:	cd 30                	int    $0x30
  800ef7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f05:	85 c0                	test   %eax,%eax
  800f07:	75 21                	jne    800f2a <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f09:	e8 8d fc ff ff       	call   800b9b <sys_getenvid>
  800f0e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f13:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f16:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f1b:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	e9 c9 01 00 00       	jmp    8010f3 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800f2a:	89 d8                	mov    %ebx,%eax
  800f2c:	c1 e8 16             	shr    $0x16,%eax
  800f2f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f36:	a8 01                	test   $0x1,%al
  800f38:	0f 84 1b 01 00 00    	je     801059 <fork+0x17c>
  800f3e:	89 de                	mov    %ebx,%esi
  800f40:	c1 ee 0c             	shr    $0xc,%esi
  800f43:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f4a:	a8 01                	test   $0x1,%al
  800f4c:	0f 84 07 01 00 00    	je     801059 <fork+0x17c>
  800f52:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f59:	a8 04                	test   $0x4,%al
  800f5b:	0f 84 f8 00 00 00    	je     801059 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800f61:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f68:	f6 c4 04             	test   $0x4,%ah
  800f6b:	74 3c                	je     800fa9 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800f6d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f74:	c1 e6 0c             	shl    $0xc,%esi
  800f77:	83 ec 0c             	sub    $0xc,%esp
  800f7a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7f:	50                   	push   %eax
  800f80:	56                   	push   %esi
  800f81:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f84:	56                   	push   %esi
  800f85:	6a 00                	push   $0x0
  800f87:	e8 90 fc ff ff       	call   800c1c <sys_page_map>
  800f8c:	83 c4 20             	add    $0x20,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	0f 89 c2 00 00 00    	jns    801059 <fork+0x17c>
			panic("duppage: %e", r);
  800f97:	50                   	push   %eax
  800f98:	68 dd 2a 80 00       	push   $0x802add
  800f9d:	6a 48                	push   $0x48
  800f9f:	68 83 2a 80 00       	push   $0x802a83
  800fa4:	e8 af f1 ff ff       	call   800158 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  800fa9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb0:	f6 c4 08             	test   $0x8,%ah
  800fb3:	75 0b                	jne    800fc0 <fork+0xe3>
  800fb5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fbc:	a8 02                	test   $0x2,%al
  800fbe:	74 6c                	je     80102c <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  800fc0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc7:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  800fca:	83 f8 01             	cmp    $0x1,%eax
  800fcd:	19 ff                	sbb    %edi,%edi
  800fcf:	83 e7 fc             	and    $0xfffffffc,%edi
  800fd2:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  800fd8:	c1 e6 0c             	shl    $0xc,%esi
  800fdb:	83 ec 0c             	sub    $0xc,%esp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fe3:	56                   	push   %esi
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 31 fc ff ff       	call   800c1c <sys_page_map>
  800feb:	83 c4 20             	add    $0x20,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	79 12                	jns    801004 <fork+0x127>
			panic("duppage: %e", r);
  800ff2:	50                   	push   %eax
  800ff3:	68 dd 2a 80 00       	push   $0x802add
  800ff8:	6a 50                	push   $0x50
  800ffa:	68 83 2a 80 00       	push   $0x802a83
  800fff:	e8 54 f1 ff ff       	call   800158 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	6a 00                	push   $0x0
  80100b:	56                   	push   %esi
  80100c:	6a 00                	push   $0x0
  80100e:	e8 09 fc ff ff       	call   800c1c <sys_page_map>
  801013:	83 c4 20             	add    $0x20,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	79 3f                	jns    801059 <fork+0x17c>
			panic("duppage: %e", r);
  80101a:	50                   	push   %eax
  80101b:	68 dd 2a 80 00       	push   $0x802add
  801020:	6a 53                	push   $0x53
  801022:	68 83 2a 80 00       	push   $0x802a83
  801027:	e8 2c f1 ff ff       	call   800158 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  80102c:	c1 e6 0c             	shl    $0xc,%esi
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	6a 05                	push   $0x5
  801034:	56                   	push   %esi
  801035:	ff 75 e4             	pushl  -0x1c(%ebp)
  801038:	56                   	push   %esi
  801039:	6a 00                	push   $0x0
  80103b:	e8 dc fb ff ff       	call   800c1c <sys_page_map>
  801040:	83 c4 20             	add    $0x20,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	79 12                	jns    801059 <fork+0x17c>
			panic("duppage: %e", r);
  801047:	50                   	push   %eax
  801048:	68 dd 2a 80 00       	push   $0x802add
  80104d:	6a 57                	push   $0x57
  80104f:	68 83 2a 80 00       	push   $0x802a83
  801054:	e8 ff f0 ff ff       	call   800158 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801059:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80105f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801065:	0f 85 bf fe ff ff    	jne    800f2a <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80106b:	83 ec 04             	sub    $0x4,%esp
  80106e:	6a 07                	push   $0x7
  801070:	68 00 f0 bf ee       	push   $0xeebff000
  801075:	ff 75 e0             	pushl  -0x20(%ebp)
  801078:	e8 5c fb ff ff       	call   800bd9 <sys_page_alloc>
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	85 c0                	test   %eax,%eax
  801082:	74 17                	je     80109b <fork+0x1be>
		panic("sys_page_alloc Error");
  801084:	83 ec 04             	sub    $0x4,%esp
  801087:	68 e9 2a 80 00       	push   $0x802ae9
  80108c:	68 83 00 00 00       	push   $0x83
  801091:	68 83 2a 80 00       	push   $0x802a83
  801096:	e8 bd f0 ff ff       	call   800158 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  80109b:	83 ec 08             	sub    $0x8,%esp
  80109e:	68 df 23 80 00       	push   $0x8023df
  8010a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a6:	e8 79 fc ff ff       	call   800d24 <sys_env_set_pgfault_upcall>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	79 15                	jns    8010c7 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  8010b2:	50                   	push   %eax
  8010b3:	68 fe 2a 80 00       	push   $0x802afe
  8010b8:	68 86 00 00 00       	push   $0x86
  8010bd:	68 83 2a 80 00       	push   $0x802a83
  8010c2:	e8 91 f0 ff ff       	call   800158 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	6a 02                	push   $0x2
  8010cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8010cf:	e8 cc fb ff ff       	call   800ca0 <sys_env_set_status>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	79 15                	jns    8010f0 <fork+0x213>
		panic("fork set status: %e", r);
  8010db:	50                   	push   %eax
  8010dc:	68 16 2b 80 00       	push   $0x802b16
  8010e1:	68 89 00 00 00       	push   $0x89
  8010e6:	68 83 2a 80 00       	push   $0x802a83
  8010eb:	e8 68 f0 ff ff       	call   800158 <_panic>
	
	return envid;
  8010f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8010f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <sfork>:


// Challenge!
int
sfork(void)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801101:	68 2a 2b 80 00       	push   $0x802b2a
  801106:	68 93 00 00 00       	push   $0x93
  80110b:	68 83 2a 80 00       	push   $0x802a83
  801110:	e8 43 f0 ff ff       	call   800158 <_panic>

00801115 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	8b 75 08             	mov    0x8(%ebp),%esi
  80111d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801120:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801123:	85 c0                	test   %eax,%eax
  801125:	74 0e                	je     801135 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	50                   	push   %eax
  80112b:	e8 59 fc ff ff       	call   800d89 <sys_ipc_recv>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	eb 10                	jmp    801145 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	68 00 00 c0 ee       	push   $0xeec00000
  80113d:	e8 47 fc ff ff       	call   800d89 <sys_ipc_recv>
  801142:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801145:	85 c0                	test   %eax,%eax
  801147:	79 17                	jns    801160 <ipc_recv+0x4b>
		if(*from_env_store)
  801149:	83 3e 00             	cmpl   $0x0,(%esi)
  80114c:	74 06                	je     801154 <ipc_recv+0x3f>
			*from_env_store = 0;
  80114e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801154:	85 db                	test   %ebx,%ebx
  801156:	74 2c                	je     801184 <ipc_recv+0x6f>
			*perm_store = 0;
  801158:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80115e:	eb 24                	jmp    801184 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801160:	85 f6                	test   %esi,%esi
  801162:	74 0a                	je     80116e <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801164:	a1 08 40 80 00       	mov    0x804008,%eax
  801169:	8b 40 74             	mov    0x74(%eax),%eax
  80116c:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80116e:	85 db                	test   %ebx,%ebx
  801170:	74 0a                	je     80117c <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801172:	a1 08 40 80 00       	mov    0x804008,%eax
  801177:	8b 40 78             	mov    0x78(%eax),%eax
  80117a:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80117c:	a1 08 40 80 00       	mov    0x804008,%eax
  801181:	8b 40 70             	mov    0x70(%eax),%eax
}
  801184:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	57                   	push   %edi
  80118f:	56                   	push   %esi
  801190:	53                   	push   %ebx
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	8b 7d 08             	mov    0x8(%ebp),%edi
  801197:	8b 75 0c             	mov    0xc(%ebp),%esi
  80119a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80119d:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80119f:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8011a4:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8011a7:	e8 0e fa ff ff       	call   800bba <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8011ac:	ff 75 14             	pushl  0x14(%ebp)
  8011af:	53                   	push   %ebx
  8011b0:	56                   	push   %esi
  8011b1:	57                   	push   %edi
  8011b2:	e8 af fb ff ff       	call   800d66 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8011b7:	89 c2                	mov    %eax,%edx
  8011b9:	f7 d2                	not    %edx
  8011bb:	c1 ea 1f             	shr    $0x1f,%edx
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011c4:	0f 94 c1             	sete   %cl
  8011c7:	09 ca                	or     %ecx,%edx
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	0f 94 c0             	sete   %al
  8011ce:	38 c2                	cmp    %al,%dl
  8011d0:	77 d5                	ja     8011a7 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011e5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011e8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ee:	8b 52 50             	mov    0x50(%edx),%edx
  8011f1:	39 ca                	cmp    %ecx,%edx
  8011f3:	75 0d                	jne    801202 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011f5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011f8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011fd:	8b 40 48             	mov    0x48(%eax),%eax
  801200:	eb 0f                	jmp    801211 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801202:	83 c0 01             	add    $0x1,%eax
  801205:	3d 00 04 00 00       	cmp    $0x400,%eax
  80120a:	75 d9                	jne    8011e5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801216:	8b 45 08             	mov    0x8(%ebp),%eax
  801219:	05 00 00 00 30       	add    $0x30000000,%eax
  80121e:	c1 e8 0c             	shr    $0xc,%eax
}
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	05 00 00 00 30       	add    $0x30000000,%eax
  80122e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801233:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
  80123d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801240:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801245:	89 c2                	mov    %eax,%edx
  801247:	c1 ea 16             	shr    $0x16,%edx
  80124a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801251:	f6 c2 01             	test   $0x1,%dl
  801254:	74 11                	je     801267 <fd_alloc+0x2d>
  801256:	89 c2                	mov    %eax,%edx
  801258:	c1 ea 0c             	shr    $0xc,%edx
  80125b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801262:	f6 c2 01             	test   $0x1,%dl
  801265:	75 09                	jne    801270 <fd_alloc+0x36>
			*fd_store = fd;
  801267:	89 01                	mov    %eax,(%ecx)
			return 0;
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
  80126e:	eb 17                	jmp    801287 <fd_alloc+0x4d>
  801270:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801275:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127a:	75 c9                	jne    801245 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80127c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801282:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80128f:	83 f8 1f             	cmp    $0x1f,%eax
  801292:	77 36                	ja     8012ca <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801294:	c1 e0 0c             	shl    $0xc,%eax
  801297:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	c1 ea 16             	shr    $0x16,%edx
  8012a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a8:	f6 c2 01             	test   $0x1,%dl
  8012ab:	74 24                	je     8012d1 <fd_lookup+0x48>
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	c1 ea 0c             	shr    $0xc,%edx
  8012b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	74 1a                	je     8012d8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c8:	eb 13                	jmp    8012dd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cf:	eb 0c                	jmp    8012dd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d6:	eb 05                	jmp    8012dd <fd_lookup+0x54>
  8012d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	ba c0 2b 80 00       	mov    $0x802bc0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ed:	eb 13                	jmp    801302 <dev_lookup+0x23>
  8012ef:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012f2:	39 08                	cmp    %ecx,(%eax)
  8012f4:	75 0c                	jne    801302 <dev_lookup+0x23>
			*dev = devtab[i];
  8012f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801300:	eb 2e                	jmp    801330 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801302:	8b 02                	mov    (%edx),%eax
  801304:	85 c0                	test   %eax,%eax
  801306:	75 e7                	jne    8012ef <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801308:	a1 08 40 80 00       	mov    0x804008,%eax
  80130d:	8b 40 48             	mov    0x48(%eax),%eax
  801310:	83 ec 04             	sub    $0x4,%esp
  801313:	51                   	push   %ecx
  801314:	50                   	push   %eax
  801315:	68 40 2b 80 00       	push   $0x802b40
  80131a:	e8 12 ef ff ff       	call   800231 <cprintf>
	*dev = 0;
  80131f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801322:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	56                   	push   %esi
  801336:	53                   	push   %ebx
  801337:	83 ec 10             	sub    $0x10,%esp
  80133a:	8b 75 08             	mov    0x8(%ebp),%esi
  80133d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134a:	c1 e8 0c             	shr    $0xc,%eax
  80134d:	50                   	push   %eax
  80134e:	e8 36 ff ff ff       	call   801289 <fd_lookup>
  801353:	83 c4 08             	add    $0x8,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 05                	js     80135f <fd_close+0x2d>
	    || fd != fd2)
  80135a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80135d:	74 0c                	je     80136b <fd_close+0x39>
		return (must_exist ? r : 0);
  80135f:	84 db                	test   %bl,%bl
  801361:	ba 00 00 00 00       	mov    $0x0,%edx
  801366:	0f 44 c2             	cmove  %edx,%eax
  801369:	eb 41                	jmp    8013ac <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80136b:	83 ec 08             	sub    $0x8,%esp
  80136e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	ff 36                	pushl  (%esi)
  801374:	e8 66 ff ff ff       	call   8012df <dev_lookup>
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 1a                	js     80139c <fd_close+0x6a>
		if (dev->dev_close)
  801382:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801385:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801388:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80138d:	85 c0                	test   %eax,%eax
  80138f:	74 0b                	je     80139c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801391:	83 ec 0c             	sub    $0xc,%esp
  801394:	56                   	push   %esi
  801395:	ff d0                	call   *%eax
  801397:	89 c3                	mov    %eax,%ebx
  801399:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	56                   	push   %esi
  8013a0:	6a 00                	push   $0x0
  8013a2:	e8 b7 f8 ff ff       	call   800c5e <sys_page_unmap>
	return r;
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	89 d8                	mov    %ebx,%eax
}
  8013ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	ff 75 08             	pushl  0x8(%ebp)
  8013c0:	e8 c4 fe ff ff       	call   801289 <fd_lookup>
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 10                	js     8013dc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	6a 01                	push   $0x1
  8013d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d4:	e8 59 ff ff ff       	call   801332 <fd_close>
  8013d9:	83 c4 10             	add    $0x10,%esp
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    

008013de <close_all>:

void
close_all(void)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013e5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	53                   	push   %ebx
  8013ee:	e8 c0 ff ff ff       	call   8013b3 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	83 c3 01             	add    $0x1,%ebx
  8013f6:	83 c4 10             	add    $0x10,%esp
  8013f9:	83 fb 20             	cmp    $0x20,%ebx
  8013fc:	75 ec                	jne    8013ea <close_all+0xc>
		close(i);
}
  8013fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801401:	c9                   	leave  
  801402:	c3                   	ret    

00801403 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	57                   	push   %edi
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	83 ec 2c             	sub    $0x2c,%esp
  80140c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80140f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801412:	50                   	push   %eax
  801413:	ff 75 08             	pushl  0x8(%ebp)
  801416:	e8 6e fe ff ff       	call   801289 <fd_lookup>
  80141b:	83 c4 08             	add    $0x8,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	0f 88 c1 00 00 00    	js     8014e7 <dup+0xe4>
		return r;
	close(newfdnum);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	56                   	push   %esi
  80142a:	e8 84 ff ff ff       	call   8013b3 <close>

	newfd = INDEX2FD(newfdnum);
  80142f:	89 f3                	mov    %esi,%ebx
  801431:	c1 e3 0c             	shl    $0xc,%ebx
  801434:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80143a:	83 c4 04             	add    $0x4,%esp
  80143d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801440:	e8 de fd ff ff       	call   801223 <fd2data>
  801445:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801447:	89 1c 24             	mov    %ebx,(%esp)
  80144a:	e8 d4 fd ff ff       	call   801223 <fd2data>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801455:	89 f8                	mov    %edi,%eax
  801457:	c1 e8 16             	shr    $0x16,%eax
  80145a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801461:	a8 01                	test   $0x1,%al
  801463:	74 37                	je     80149c <dup+0x99>
  801465:	89 f8                	mov    %edi,%eax
  801467:	c1 e8 0c             	shr    $0xc,%eax
  80146a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801471:	f6 c2 01             	test   $0x1,%dl
  801474:	74 26                	je     80149c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801476:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	25 07 0e 00 00       	and    $0xe07,%eax
  801485:	50                   	push   %eax
  801486:	ff 75 d4             	pushl  -0x2c(%ebp)
  801489:	6a 00                	push   $0x0
  80148b:	57                   	push   %edi
  80148c:	6a 00                	push   $0x0
  80148e:	e8 89 f7 ff ff       	call   800c1c <sys_page_map>
  801493:	89 c7                	mov    %eax,%edi
  801495:	83 c4 20             	add    $0x20,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 2e                	js     8014ca <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80149f:	89 d0                	mov    %edx,%eax
  8014a1:	c1 e8 0c             	shr    $0xc,%eax
  8014a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b3:	50                   	push   %eax
  8014b4:	53                   	push   %ebx
  8014b5:	6a 00                	push   $0x0
  8014b7:	52                   	push   %edx
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 5d f7 ff ff       	call   800c1c <sys_page_map>
  8014bf:	89 c7                	mov    %eax,%edi
  8014c1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014c4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c6:	85 ff                	test   %edi,%edi
  8014c8:	79 1d                	jns    8014e7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 89 f7 ff ff       	call   800c5e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014d5:	83 c4 08             	add    $0x8,%esp
  8014d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014db:	6a 00                	push   $0x0
  8014dd:	e8 7c f7 ff ff       	call   800c5e <sys_page_unmap>
	return r;
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	89 f8                	mov    %edi,%eax
}
  8014e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	5f                   	pop    %edi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    

008014ef <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 14             	sub    $0x14,%esp
  8014f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	53                   	push   %ebx
  8014fe:	e8 86 fd ff ff       	call   801289 <fd_lookup>
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	89 c2                	mov    %eax,%edx
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 6d                	js     801579 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	ff 30                	pushl  (%eax)
  801518:	e8 c2 fd ff ff       	call   8012df <dev_lookup>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 4c                	js     801570 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801524:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801527:	8b 42 08             	mov    0x8(%edx),%eax
  80152a:	83 e0 03             	and    $0x3,%eax
  80152d:	83 f8 01             	cmp    $0x1,%eax
  801530:	75 21                	jne    801553 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801532:	a1 08 40 80 00       	mov    0x804008,%eax
  801537:	8b 40 48             	mov    0x48(%eax),%eax
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	53                   	push   %ebx
  80153e:	50                   	push   %eax
  80153f:	68 84 2b 80 00       	push   $0x802b84
  801544:	e8 e8 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801551:	eb 26                	jmp    801579 <read+0x8a>
	}
	if (!dev->dev_read)
  801553:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801556:	8b 40 08             	mov    0x8(%eax),%eax
  801559:	85 c0                	test   %eax,%eax
  80155b:	74 17                	je     801574 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	ff 75 10             	pushl  0x10(%ebp)
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	52                   	push   %edx
  801567:	ff d0                	call   *%eax
  801569:	89 c2                	mov    %eax,%edx
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	eb 09                	jmp    801579 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	89 c2                	mov    %eax,%edx
  801572:	eb 05                	jmp    801579 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801574:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801579:	89 d0                	mov    %edx,%eax
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	83 ec 0c             	sub    $0xc,%esp
  801589:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80158f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801594:	eb 21                	jmp    8015b7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801596:	83 ec 04             	sub    $0x4,%esp
  801599:	89 f0                	mov    %esi,%eax
  80159b:	29 d8                	sub    %ebx,%eax
  80159d:	50                   	push   %eax
  80159e:	89 d8                	mov    %ebx,%eax
  8015a0:	03 45 0c             	add    0xc(%ebp),%eax
  8015a3:	50                   	push   %eax
  8015a4:	57                   	push   %edi
  8015a5:	e8 45 ff ff ff       	call   8014ef <read>
		if (m < 0)
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	78 10                	js     8015c1 <readn+0x41>
			return m;
		if (m == 0)
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	74 0a                	je     8015bf <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b5:	01 c3                	add    %eax,%ebx
  8015b7:	39 f3                	cmp    %esi,%ebx
  8015b9:	72 db                	jb     801596 <readn+0x16>
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	eb 02                	jmp    8015c1 <readn+0x41>
  8015bf:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 14             	sub    $0x14,%esp
  8015d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	53                   	push   %ebx
  8015d8:	e8 ac fc ff ff       	call   801289 <fd_lookup>
  8015dd:	83 c4 08             	add    $0x8,%esp
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 68                	js     80164e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f0:	ff 30                	pushl  (%eax)
  8015f2:	e8 e8 fc ff ff       	call   8012df <dev_lookup>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 47                	js     801645 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801605:	75 21                	jne    801628 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801607:	a1 08 40 80 00       	mov    0x804008,%eax
  80160c:	8b 40 48             	mov    0x48(%eax),%eax
  80160f:	83 ec 04             	sub    $0x4,%esp
  801612:	53                   	push   %ebx
  801613:	50                   	push   %eax
  801614:	68 a0 2b 80 00       	push   $0x802ba0
  801619:	e8 13 ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801626:	eb 26                	jmp    80164e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801628:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162b:	8b 52 0c             	mov    0xc(%edx),%edx
  80162e:	85 d2                	test   %edx,%edx
  801630:	74 17                	je     801649 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	ff 75 10             	pushl  0x10(%ebp)
  801638:	ff 75 0c             	pushl  0xc(%ebp)
  80163b:	50                   	push   %eax
  80163c:	ff d2                	call   *%edx
  80163e:	89 c2                	mov    %eax,%edx
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	eb 09                	jmp    80164e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801645:	89 c2                	mov    %eax,%edx
  801647:	eb 05                	jmp    80164e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801649:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80164e:	89 d0                	mov    %edx,%eax
  801650:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <seek>:

int
seek(int fdnum, off_t offset)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	ff 75 08             	pushl  0x8(%ebp)
  801662:	e8 22 fc ff ff       	call   801289 <fd_lookup>
  801667:	83 c4 08             	add    $0x8,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 0e                	js     80167c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80166e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801671:	8b 55 0c             	mov    0xc(%ebp),%edx
  801674:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 14             	sub    $0x14,%esp
  801685:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801688:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	53                   	push   %ebx
  80168d:	e8 f7 fb ff ff       	call   801289 <fd_lookup>
  801692:	83 c4 08             	add    $0x8,%esp
  801695:	89 c2                	mov    %eax,%edx
  801697:	85 c0                	test   %eax,%eax
  801699:	78 65                	js     801700 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	50                   	push   %eax
  8016a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a5:	ff 30                	pushl  (%eax)
  8016a7:	e8 33 fc ff ff       	call   8012df <dev_lookup>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	78 44                	js     8016f7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ba:	75 21                	jne    8016dd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016bc:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016c1:	8b 40 48             	mov    0x48(%eax),%eax
  8016c4:	83 ec 04             	sub    $0x4,%esp
  8016c7:	53                   	push   %ebx
  8016c8:	50                   	push   %eax
  8016c9:	68 60 2b 80 00       	push   $0x802b60
  8016ce:	e8 5e eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016db:	eb 23                	jmp    801700 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016e0:	8b 52 18             	mov    0x18(%edx),%edx
  8016e3:	85 d2                	test   %edx,%edx
  8016e5:	74 14                	je     8016fb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	50                   	push   %eax
  8016ee:	ff d2                	call   *%edx
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	eb 09                	jmp    801700 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	eb 05                	jmp    801700 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801700:	89 d0                	mov    %edx,%eax
  801702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	53                   	push   %ebx
  80170b:	83 ec 14             	sub    $0x14,%esp
  80170e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801711:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	ff 75 08             	pushl  0x8(%ebp)
  801718:	e8 6c fb ff ff       	call   801289 <fd_lookup>
  80171d:	83 c4 08             	add    $0x8,%esp
  801720:	89 c2                	mov    %eax,%edx
  801722:	85 c0                	test   %eax,%eax
  801724:	78 58                	js     80177e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172c:	50                   	push   %eax
  80172d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801730:	ff 30                	pushl  (%eax)
  801732:	e8 a8 fb ff ff       	call   8012df <dev_lookup>
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 37                	js     801775 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801741:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801745:	74 32                	je     801779 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801747:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80174a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801751:	00 00 00 
	stat->st_isdir = 0;
  801754:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80175b:	00 00 00 
	stat->st_dev = dev;
  80175e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801764:	83 ec 08             	sub    $0x8,%esp
  801767:	53                   	push   %ebx
  801768:	ff 75 f0             	pushl  -0x10(%ebp)
  80176b:	ff 50 14             	call   *0x14(%eax)
  80176e:	89 c2                	mov    %eax,%edx
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	eb 09                	jmp    80177e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801775:	89 c2                	mov    %eax,%edx
  801777:	eb 05                	jmp    80177e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801779:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80177e:	89 d0                	mov    %edx,%eax
  801780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	6a 00                	push   $0x0
  80178f:	ff 75 08             	pushl  0x8(%ebp)
  801792:	e8 ef 01 00 00       	call   801986 <open>
  801797:	89 c3                	mov    %eax,%ebx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	85 c0                	test   %eax,%eax
  80179e:	78 1b                	js     8017bb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017a0:	83 ec 08             	sub    $0x8,%esp
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	50                   	push   %eax
  8017a7:	e8 5b ff ff ff       	call   801707 <fstat>
  8017ac:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ae:	89 1c 24             	mov    %ebx,(%esp)
  8017b1:	e8 fd fb ff ff       	call   8013b3 <close>
	return r;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	89 f0                	mov    %esi,%eax
}
  8017bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	56                   	push   %esi
  8017c6:	53                   	push   %ebx
  8017c7:	89 c6                	mov    %eax,%esi
  8017c9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017cb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017d2:	75 12                	jne    8017e6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	6a 01                	push   $0x1
  8017d9:	e8 fc f9 ff ff       	call   8011da <ipc_find_env>
  8017de:	a3 00 40 80 00       	mov    %eax,0x804000
  8017e3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017e6:	6a 07                	push   $0x7
  8017e8:	68 00 50 80 00       	push   $0x805000
  8017ed:	56                   	push   %esi
  8017ee:	ff 35 00 40 80 00    	pushl  0x804000
  8017f4:	e8 92 f9 ff ff       	call   80118b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f9:	83 c4 0c             	add    $0xc,%esp
  8017fc:	6a 00                	push   $0x0
  8017fe:	53                   	push   %ebx
  8017ff:	6a 00                	push   $0x0
  801801:	e8 0f f9 ff ff       	call   801115 <ipc_recv>
}
  801806:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	8b 40 0c             	mov    0xc(%eax),%eax
  801819:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80181e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801821:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801826:	ba 00 00 00 00       	mov    $0x0,%edx
  80182b:	b8 02 00 00 00       	mov    $0x2,%eax
  801830:	e8 8d ff ff ff       	call   8017c2 <fsipc>
}
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80183d:	8b 45 08             	mov    0x8(%ebp),%eax
  801840:	8b 40 0c             	mov    0xc(%eax),%eax
  801843:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801848:	ba 00 00 00 00       	mov    $0x0,%edx
  80184d:	b8 06 00 00 00       	mov    $0x6,%eax
  801852:	e8 6b ff ff ff       	call   8017c2 <fsipc>
}
  801857:	c9                   	leave  
  801858:	c3                   	ret    

00801859 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	53                   	push   %ebx
  80185d:	83 ec 04             	sub    $0x4,%esp
  801860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 40 0c             	mov    0xc(%eax),%eax
  801869:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 05 00 00 00       	mov    $0x5,%eax
  801878:	e8 45 ff ff ff       	call   8017c2 <fsipc>
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 2c                	js     8018ad <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	68 00 50 80 00       	push   $0x805000
  801889:	53                   	push   %ebx
  80188a:	e8 47 ef ff ff       	call   8007d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80188f:	a1 80 50 80 00       	mov    0x805080,%eax
  801894:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80189a:	a1 84 50 80 00       	mov    0x805084,%eax
  80189f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018a5:	83 c4 10             	add    $0x10,%esp
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
  8018b5:	53                   	push   %ebx
  8018b6:	83 ec 08             	sub    $0x8,%esp
  8018b9:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8018bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018c8:	a3 04 50 80 00       	mov    %eax,0x805004
  8018cd:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8018d2:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8018d7:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018da:	53                   	push   %ebx
  8018db:	ff 75 0c             	pushl  0xc(%ebp)
  8018de:	68 08 50 80 00       	push   $0x805008
  8018e3:	e8 80 f0 ff ff       	call   800968 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ed:	b8 04 00 00 00       	mov    $0x4,%eax
  8018f2:	e8 cb fe ff ff       	call   8017c2 <fsipc>
  8018f7:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8018ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801902:	c9                   	leave  
  801903:	c3                   	ret    

00801904 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	56                   	push   %esi
  801908:	53                   	push   %ebx
  801909:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80190c:	8b 45 08             	mov    0x8(%ebp),%eax
  80190f:	8b 40 0c             	mov    0xc(%eax),%eax
  801912:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801917:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80191d:	ba 00 00 00 00       	mov    $0x0,%edx
  801922:	b8 03 00 00 00       	mov    $0x3,%eax
  801927:	e8 96 fe ff ff       	call   8017c2 <fsipc>
  80192c:	89 c3                	mov    %eax,%ebx
  80192e:	85 c0                	test   %eax,%eax
  801930:	78 4b                	js     80197d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801932:	39 c6                	cmp    %eax,%esi
  801934:	73 16                	jae    80194c <devfile_read+0x48>
  801936:	68 d4 2b 80 00       	push   $0x802bd4
  80193b:	68 db 2b 80 00       	push   $0x802bdb
  801940:	6a 7c                	push   $0x7c
  801942:	68 f0 2b 80 00       	push   $0x802bf0
  801947:	e8 0c e8 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  80194c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801951:	7e 16                	jle    801969 <devfile_read+0x65>
  801953:	68 fb 2b 80 00       	push   $0x802bfb
  801958:	68 db 2b 80 00       	push   $0x802bdb
  80195d:	6a 7d                	push   $0x7d
  80195f:	68 f0 2b 80 00       	push   $0x802bf0
  801964:	e8 ef e7 ff ff       	call   800158 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801969:	83 ec 04             	sub    $0x4,%esp
  80196c:	50                   	push   %eax
  80196d:	68 00 50 80 00       	push   $0x805000
  801972:	ff 75 0c             	pushl  0xc(%ebp)
  801975:	e8 ee ef ff ff       	call   800968 <memmove>
	return r;
  80197a:	83 c4 10             	add    $0x10,%esp
}
  80197d:	89 d8                	mov    %ebx,%eax
  80197f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5d                   	pop    %ebp
  801985:	c3                   	ret    

00801986 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	53                   	push   %ebx
  80198a:	83 ec 20             	sub    $0x20,%esp
  80198d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801990:	53                   	push   %ebx
  801991:	e8 07 ee ff ff       	call   80079d <strlen>
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80199e:	7f 67                	jg     801a07 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019a0:	83 ec 0c             	sub    $0xc,%esp
  8019a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a6:	50                   	push   %eax
  8019a7:	e8 8e f8 ff ff       	call   80123a <fd_alloc>
  8019ac:	83 c4 10             	add    $0x10,%esp
		return r;
  8019af:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 57                	js     801a0c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019b5:	83 ec 08             	sub    $0x8,%esp
  8019b8:	53                   	push   %ebx
  8019b9:	68 00 50 80 00       	push   $0x805000
  8019be:	e8 13 ee ff ff       	call   8007d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d3:	e8 ea fd ff ff       	call   8017c2 <fsipc>
  8019d8:	89 c3                	mov    %eax,%ebx
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	79 14                	jns    8019f5 <open+0x6f>
		fd_close(fd, 0);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	6a 00                	push   $0x0
  8019e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e9:	e8 44 f9 ff ff       	call   801332 <fd_close>
		return r;
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	89 da                	mov    %ebx,%edx
  8019f3:	eb 17                	jmp    801a0c <open+0x86>
	}

	return fd2num(fd);
  8019f5:	83 ec 0c             	sub    $0xc,%esp
  8019f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fb:	e8 13 f8 ff ff       	call   801213 <fd2num>
  801a00:	89 c2                	mov    %eax,%edx
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	eb 05                	jmp    801a0c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a07:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a0c:	89 d0                	mov    %edx,%eax
  801a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	b8 08 00 00 00       	mov    $0x8,%eax
  801a23:	e8 9a fd ff ff       	call   8017c2 <fsipc>
}
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	56                   	push   %esi
  801a2e:	53                   	push   %ebx
  801a2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	ff 75 08             	pushl  0x8(%ebp)
  801a38:	e8 e6 f7 ff ff       	call   801223 <fd2data>
  801a3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a3f:	83 c4 08             	add    $0x8,%esp
  801a42:	68 07 2c 80 00       	push   $0x802c07
  801a47:	53                   	push   %ebx
  801a48:	e8 89 ed ff ff       	call   8007d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a4d:	8b 46 04             	mov    0x4(%esi),%eax
  801a50:	2b 06                	sub    (%esi),%eax
  801a52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a58:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a5f:	00 00 00 
	stat->st_dev = &devpipe;
  801a62:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a69:	30 80 00 
	return 0;
}
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 0c             	sub    $0xc,%esp
  801a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a82:	53                   	push   %ebx
  801a83:	6a 00                	push   $0x0
  801a85:	e8 d4 f1 ff ff       	call   800c5e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a8a:	89 1c 24             	mov    %ebx,(%esp)
  801a8d:	e8 91 f7 ff ff       	call   801223 <fd2data>
  801a92:	83 c4 08             	add    $0x8,%esp
  801a95:	50                   	push   %eax
  801a96:	6a 00                	push   $0x0
  801a98:	e8 c1 f1 ff ff       	call   800c5e <sys_page_unmap>
}
  801a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa0:	c9                   	leave  
  801aa1:	c3                   	ret    

00801aa2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	57                   	push   %edi
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	83 ec 1c             	sub    $0x1c,%esp
  801aab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aae:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ab0:	a1 08 40 80 00       	mov    0x804008,%eax
  801ab5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ab8:	83 ec 0c             	sub    $0xc,%esp
  801abb:	ff 75 e0             	pushl  -0x20(%ebp)
  801abe:	e8 43 09 00 00       	call   802406 <pageref>
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	89 3c 24             	mov    %edi,(%esp)
  801ac8:	e8 39 09 00 00       	call   802406 <pageref>
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	39 c3                	cmp    %eax,%ebx
  801ad2:	0f 94 c1             	sete   %cl
  801ad5:	0f b6 c9             	movzbl %cl,%ecx
  801ad8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801adb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ae1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ae4:	39 ce                	cmp    %ecx,%esi
  801ae6:	74 1b                	je     801b03 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ae8:	39 c3                	cmp    %eax,%ebx
  801aea:	75 c4                	jne    801ab0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aec:	8b 42 58             	mov    0x58(%edx),%eax
  801aef:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af2:	50                   	push   %eax
  801af3:	56                   	push   %esi
  801af4:	68 0e 2c 80 00       	push   $0x802c0e
  801af9:	e8 33 e7 ff ff       	call   800231 <cprintf>
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	eb ad                	jmp    801ab0 <_pipeisclosed+0xe>
	}
}
  801b03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5e                   	pop    %esi
  801b0b:	5f                   	pop    %edi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 28             	sub    $0x28,%esp
  801b17:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b1a:	56                   	push   %esi
  801b1b:	e8 03 f7 ff ff       	call   801223 <fd2data>
  801b20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2a:	eb 4b                	jmp    801b77 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b2c:	89 da                	mov    %ebx,%edx
  801b2e:	89 f0                	mov    %esi,%eax
  801b30:	e8 6d ff ff ff       	call   801aa2 <_pipeisclosed>
  801b35:	85 c0                	test   %eax,%eax
  801b37:	75 48                	jne    801b81 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b39:	e8 7c f0 ff ff       	call   800bba <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b3e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b41:	8b 0b                	mov    (%ebx),%ecx
  801b43:	8d 51 20             	lea    0x20(%ecx),%edx
  801b46:	39 d0                	cmp    %edx,%eax
  801b48:	73 e2                	jae    801b2c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b51:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b54:	89 c2                	mov    %eax,%edx
  801b56:	c1 fa 1f             	sar    $0x1f,%edx
  801b59:	89 d1                	mov    %edx,%ecx
  801b5b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b5e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b61:	83 e2 1f             	and    $0x1f,%edx
  801b64:	29 ca                	sub    %ecx,%edx
  801b66:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b6a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b6e:	83 c0 01             	add    $0x1,%eax
  801b71:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b74:	83 c7 01             	add    $0x1,%edi
  801b77:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b7a:	75 c2                	jne    801b3e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7f:	eb 05                	jmp    801b86 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b89:	5b                   	pop    %ebx
  801b8a:	5e                   	pop    %esi
  801b8b:	5f                   	pop    %edi
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 18             	sub    $0x18,%esp
  801b97:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b9a:	57                   	push   %edi
  801b9b:	e8 83 f6 ff ff       	call   801223 <fd2data>
  801ba0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba2:	83 c4 10             	add    $0x10,%esp
  801ba5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801baa:	eb 3d                	jmp    801be9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bac:	85 db                	test   %ebx,%ebx
  801bae:	74 04                	je     801bb4 <devpipe_read+0x26>
				return i;
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	eb 44                	jmp    801bf8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bb4:	89 f2                	mov    %esi,%edx
  801bb6:	89 f8                	mov    %edi,%eax
  801bb8:	e8 e5 fe ff ff       	call   801aa2 <_pipeisclosed>
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	75 32                	jne    801bf3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bc1:	e8 f4 ef ff ff       	call   800bba <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bc6:	8b 06                	mov    (%esi),%eax
  801bc8:	3b 46 04             	cmp    0x4(%esi),%eax
  801bcb:	74 df                	je     801bac <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bcd:	99                   	cltd   
  801bce:	c1 ea 1b             	shr    $0x1b,%edx
  801bd1:	01 d0                	add    %edx,%eax
  801bd3:	83 e0 1f             	and    $0x1f,%eax
  801bd6:	29 d0                	sub    %edx,%eax
  801bd8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801be3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801be6:	83 c3 01             	add    $0x1,%ebx
  801be9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bec:	75 d8                	jne    801bc6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bee:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf1:	eb 05                	jmp    801bf8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bf3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfb:	5b                   	pop    %ebx
  801bfc:	5e                   	pop    %esi
  801bfd:	5f                   	pop    %edi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	56                   	push   %esi
  801c04:	53                   	push   %ebx
  801c05:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	e8 29 f6 ff ff       	call   80123a <fd_alloc>
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	89 c2                	mov    %eax,%edx
  801c16:	85 c0                	test   %eax,%eax
  801c18:	0f 88 2c 01 00 00    	js     801d4a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1e:	83 ec 04             	sub    $0x4,%esp
  801c21:	68 07 04 00 00       	push   $0x407
  801c26:	ff 75 f4             	pushl  -0xc(%ebp)
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 a9 ef ff ff       	call   800bd9 <sys_page_alloc>
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	89 c2                	mov    %eax,%edx
  801c35:	85 c0                	test   %eax,%eax
  801c37:	0f 88 0d 01 00 00    	js     801d4a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c43:	50                   	push   %eax
  801c44:	e8 f1 f5 ff ff       	call   80123a <fd_alloc>
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	0f 88 e2 00 00 00    	js     801d38 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c56:	83 ec 04             	sub    $0x4,%esp
  801c59:	68 07 04 00 00       	push   $0x407
  801c5e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c61:	6a 00                	push   $0x0
  801c63:	e8 71 ef ff ff       	call   800bd9 <sys_page_alloc>
  801c68:	89 c3                	mov    %eax,%ebx
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	0f 88 c3 00 00 00    	js     801d38 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7b:	e8 a3 f5 ff ff       	call   801223 <fd2data>
  801c80:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c82:	83 c4 0c             	add    $0xc,%esp
  801c85:	68 07 04 00 00       	push   $0x407
  801c8a:	50                   	push   %eax
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 47 ef ff ff       	call   800bd9 <sys_page_alloc>
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	0f 88 89 00 00 00    	js     801d28 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9f:	83 ec 0c             	sub    $0xc,%esp
  801ca2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca5:	e8 79 f5 ff ff       	call   801223 <fd2data>
  801caa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cb1:	50                   	push   %eax
  801cb2:	6a 00                	push   $0x0
  801cb4:	56                   	push   %esi
  801cb5:	6a 00                	push   $0x0
  801cb7:	e8 60 ef ff ff       	call   800c1c <sys_page_map>
  801cbc:	89 c3                	mov    %eax,%ebx
  801cbe:	83 c4 20             	add    $0x20,%esp
  801cc1:	85 c0                	test   %eax,%eax
  801cc3:	78 55                	js     801d1a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cc5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cce:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cef:	83 ec 0c             	sub    $0xc,%esp
  801cf2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf5:	e8 19 f5 ff ff       	call   801213 <fd2num>
  801cfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cff:	83 c4 04             	add    $0x4,%esp
  801d02:	ff 75 f0             	pushl  -0x10(%ebp)
  801d05:	e8 09 f5 ff ff       	call   801213 <fd2num>
  801d0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d10:	83 c4 10             	add    $0x10,%esp
  801d13:	ba 00 00 00 00       	mov    $0x0,%edx
  801d18:	eb 30                	jmp    801d4a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d1a:	83 ec 08             	sub    $0x8,%esp
  801d1d:	56                   	push   %esi
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 39 ef ff ff       	call   800c5e <sys_page_unmap>
  801d25:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d28:	83 ec 08             	sub    $0x8,%esp
  801d2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 29 ef ff ff       	call   800c5e <sys_page_unmap>
  801d35:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d38:	83 ec 08             	sub    $0x8,%esp
  801d3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3e:	6a 00                	push   $0x0
  801d40:	e8 19 ef ff ff       	call   800c5e <sys_page_unmap>
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5c:	50                   	push   %eax
  801d5d:	ff 75 08             	pushl  0x8(%ebp)
  801d60:	e8 24 f5 ff ff       	call   801289 <fd_lookup>
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	85 c0                	test   %eax,%eax
  801d6a:	78 18                	js     801d84 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d6c:	83 ec 0c             	sub    $0xc,%esp
  801d6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d72:	e8 ac f4 ff ff       	call   801223 <fd2data>
	return _pipeisclosed(fd, p);
  801d77:	89 c2                	mov    %eax,%edx
  801d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d7c:	e8 21 fd ff ff       	call   801aa2 <_pipeisclosed>
  801d81:	83 c4 10             	add    $0x10,%esp
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d8c:	68 26 2c 80 00       	push   $0x802c26
  801d91:	ff 75 0c             	pushl  0xc(%ebp)
  801d94:	e8 3d ea ff ff       	call   8007d6 <strcpy>
	return 0;
}
  801d99:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	53                   	push   %ebx
  801da4:	83 ec 10             	sub    $0x10,%esp
  801da7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801daa:	53                   	push   %ebx
  801dab:	e8 56 06 00 00       	call   802406 <pageref>
  801db0:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801db3:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801db8:	83 f8 01             	cmp    $0x1,%eax
  801dbb:	75 10                	jne    801dcd <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801dbd:	83 ec 0c             	sub    $0xc,%esp
  801dc0:	ff 73 0c             	pushl  0xc(%ebx)
  801dc3:	e8 c0 02 00 00       	call   802088 <nsipc_close>
  801dc8:	89 c2                	mov    %eax,%edx
  801dca:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801dcd:	89 d0                	mov    %edx,%eax
  801dcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd2:	c9                   	leave  
  801dd3:	c3                   	ret    

00801dd4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801dda:	6a 00                	push   $0x0
  801ddc:	ff 75 10             	pushl  0x10(%ebp)
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	8b 45 08             	mov    0x8(%ebp),%eax
  801de5:	ff 70 0c             	pushl  0xc(%eax)
  801de8:	e8 78 03 00 00       	call   802165 <nsipc_send>
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801df5:	6a 00                	push   $0x0
  801df7:	ff 75 10             	pushl  0x10(%ebp)
  801dfa:	ff 75 0c             	pushl  0xc(%ebp)
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	ff 70 0c             	pushl  0xc(%eax)
  801e03:	e8 f1 02 00 00       	call   8020f9 <nsipc_recv>
}
  801e08:	c9                   	leave  
  801e09:	c3                   	ret    

00801e0a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e10:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e13:	52                   	push   %edx
  801e14:	50                   	push   %eax
  801e15:	e8 6f f4 ff ff       	call   801289 <fd_lookup>
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	85 c0                	test   %eax,%eax
  801e1f:	78 17                	js     801e38 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e24:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801e2a:	39 08                	cmp    %ecx,(%eax)
  801e2c:	75 05                	jne    801e33 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e2e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e31:	eb 05                	jmp    801e38 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e33:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e38:	c9                   	leave  
  801e39:	c3                   	ret    

00801e3a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	56                   	push   %esi
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 1c             	sub    $0x1c,%esp
  801e42:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e47:	50                   	push   %eax
  801e48:	e8 ed f3 ff ff       	call   80123a <fd_alloc>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	83 c4 10             	add    $0x10,%esp
  801e52:	85 c0                	test   %eax,%eax
  801e54:	78 1b                	js     801e71 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e56:	83 ec 04             	sub    $0x4,%esp
  801e59:	68 07 04 00 00       	push   $0x407
  801e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e61:	6a 00                	push   $0x0
  801e63:	e8 71 ed ff ff       	call   800bd9 <sys_page_alloc>
  801e68:	89 c3                	mov    %eax,%ebx
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	79 10                	jns    801e81 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	56                   	push   %esi
  801e75:	e8 0e 02 00 00       	call   802088 <nsipc_close>
		return r;
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	89 d8                	mov    %ebx,%eax
  801e7f:	eb 24                	jmp    801ea5 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e96:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e99:	83 ec 0c             	sub    $0xc,%esp
  801e9c:	50                   	push   %eax
  801e9d:	e8 71 f3 ff ff       	call   801213 <fd2num>
  801ea2:	83 c4 10             	add    $0x10,%esp
}
  801ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    

00801eac <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb5:	e8 50 ff ff ff       	call   801e0a <fd2sockid>
		return r;
  801eba:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 1f                	js     801edf <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ec0:	83 ec 04             	sub    $0x4,%esp
  801ec3:	ff 75 10             	pushl  0x10(%ebp)
  801ec6:	ff 75 0c             	pushl  0xc(%ebp)
  801ec9:	50                   	push   %eax
  801eca:	e8 12 01 00 00       	call   801fe1 <nsipc_accept>
  801ecf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 07                	js     801edf <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ed8:	e8 5d ff ff ff       	call   801e3a <alloc_sockfd>
  801edd:	89 c1                	mov    %eax,%ecx
}
  801edf:	89 c8                	mov    %ecx,%eax
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ee9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eec:	e8 19 ff ff ff       	call   801e0a <fd2sockid>
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 12                	js     801f07 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ef5:	83 ec 04             	sub    $0x4,%esp
  801ef8:	ff 75 10             	pushl  0x10(%ebp)
  801efb:	ff 75 0c             	pushl  0xc(%ebp)
  801efe:	50                   	push   %eax
  801eff:	e8 2d 01 00 00       	call   802031 <nsipc_bind>
  801f04:	83 c4 10             	add    $0x10,%esp
}
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <shutdown>:

int
shutdown(int s, int how)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	e8 f3 fe ff ff       	call   801e0a <fd2sockid>
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 0f                	js     801f2a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f1b:	83 ec 08             	sub    $0x8,%esp
  801f1e:	ff 75 0c             	pushl  0xc(%ebp)
  801f21:	50                   	push   %eax
  801f22:	e8 3f 01 00 00       	call   802066 <nsipc_shutdown>
  801f27:	83 c4 10             	add    $0x10,%esp
}
  801f2a:	c9                   	leave  
  801f2b:	c3                   	ret    

00801f2c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f32:	8b 45 08             	mov    0x8(%ebp),%eax
  801f35:	e8 d0 fe ff ff       	call   801e0a <fd2sockid>
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	78 12                	js     801f50 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f3e:	83 ec 04             	sub    $0x4,%esp
  801f41:	ff 75 10             	pushl  0x10(%ebp)
  801f44:	ff 75 0c             	pushl  0xc(%ebp)
  801f47:	50                   	push   %eax
  801f48:	e8 55 01 00 00       	call   8020a2 <nsipc_connect>
  801f4d:	83 c4 10             	add    $0x10,%esp
}
  801f50:	c9                   	leave  
  801f51:	c3                   	ret    

00801f52 <listen>:

int
listen(int s, int backlog)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f58:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5b:	e8 aa fe ff ff       	call   801e0a <fd2sockid>
  801f60:	85 c0                	test   %eax,%eax
  801f62:	78 0f                	js     801f73 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f64:	83 ec 08             	sub    $0x8,%esp
  801f67:	ff 75 0c             	pushl  0xc(%ebp)
  801f6a:	50                   	push   %eax
  801f6b:	e8 67 01 00 00       	call   8020d7 <nsipc_listen>
  801f70:	83 c4 10             	add    $0x10,%esp
}
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f7b:	ff 75 10             	pushl  0x10(%ebp)
  801f7e:	ff 75 0c             	pushl  0xc(%ebp)
  801f81:	ff 75 08             	pushl  0x8(%ebp)
  801f84:	e8 3a 02 00 00       	call   8021c3 <nsipc_socket>
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	78 05                	js     801f95 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f90:	e8 a5 fe ff ff       	call   801e3a <alloc_sockfd>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	53                   	push   %ebx
  801f9b:	83 ec 04             	sub    $0x4,%esp
  801f9e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801fa0:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801fa7:	75 12                	jne    801fbb <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801fa9:	83 ec 0c             	sub    $0xc,%esp
  801fac:	6a 02                	push   $0x2
  801fae:	e8 27 f2 ff ff       	call   8011da <ipc_find_env>
  801fb3:	a3 04 40 80 00       	mov    %eax,0x804004
  801fb8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801fbb:	6a 07                	push   $0x7
  801fbd:	68 00 60 80 00       	push   $0x806000
  801fc2:	53                   	push   %ebx
  801fc3:	ff 35 04 40 80 00    	pushl  0x804004
  801fc9:	e8 bd f1 ff ff       	call   80118b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fce:	83 c4 0c             	add    $0xc,%esp
  801fd1:	6a 00                	push   $0x0
  801fd3:	6a 00                	push   $0x0
  801fd5:	6a 00                	push   $0x0
  801fd7:	e8 39 f1 ff ff       	call   801115 <ipc_recv>
}
  801fdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fdf:	c9                   	leave  
  801fe0:	c3                   	ret    

00801fe1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	56                   	push   %esi
  801fe5:	53                   	push   %ebx
  801fe6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fec:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ff1:	8b 06                	mov    (%esi),%eax
  801ff3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ff8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffd:	e8 95 ff ff ff       	call   801f97 <nsipc>
  802002:	89 c3                	mov    %eax,%ebx
  802004:	85 c0                	test   %eax,%eax
  802006:	78 20                	js     802028 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802008:	83 ec 04             	sub    $0x4,%esp
  80200b:	ff 35 10 60 80 00    	pushl  0x806010
  802011:	68 00 60 80 00       	push   $0x806000
  802016:	ff 75 0c             	pushl  0xc(%ebp)
  802019:	e8 4a e9 ff ff       	call   800968 <memmove>
		*addrlen = ret->ret_addrlen;
  80201e:	a1 10 60 80 00       	mov    0x806010,%eax
  802023:	89 06                	mov    %eax,(%esi)
  802025:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5d                   	pop    %ebp
  802030:	c3                   	ret    

00802031 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	53                   	push   %ebx
  802035:	83 ec 08             	sub    $0x8,%esp
  802038:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80203b:	8b 45 08             	mov    0x8(%ebp),%eax
  80203e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802043:	53                   	push   %ebx
  802044:	ff 75 0c             	pushl  0xc(%ebp)
  802047:	68 04 60 80 00       	push   $0x806004
  80204c:	e8 17 e9 ff ff       	call   800968 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802051:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  802057:	b8 02 00 00 00       	mov    $0x2,%eax
  80205c:	e8 36 ff ff ff       	call   801f97 <nsipc>
}
  802061:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802064:	c9                   	leave  
  802065:	c3                   	ret    

00802066 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
  802069:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80206c:	8b 45 08             	mov    0x8(%ebp),%eax
  80206f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802074:	8b 45 0c             	mov    0xc(%ebp),%eax
  802077:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80207c:	b8 03 00 00 00       	mov    $0x3,%eax
  802081:	e8 11 ff ff ff       	call   801f97 <nsipc>
}
  802086:	c9                   	leave  
  802087:	c3                   	ret    

00802088 <nsipc_close>:

int
nsipc_close(int s)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802096:	b8 04 00 00 00       	mov    $0x4,%eax
  80209b:	e8 f7 fe ff ff       	call   801f97 <nsipc>
}
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	53                   	push   %ebx
  8020a6:	83 ec 08             	sub    $0x8,%esp
  8020a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8020af:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020b4:	53                   	push   %ebx
  8020b5:	ff 75 0c             	pushl  0xc(%ebp)
  8020b8:	68 04 60 80 00       	push   $0x806004
  8020bd:	e8 a6 e8 ff ff       	call   800968 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020c2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8020c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8020cd:	e8 c5 fe ff ff       	call   801f97 <nsipc>
}
  8020d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    

008020d7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8020ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8020f2:	e8 a0 fe ff ff       	call   801f97 <nsipc>
}
  8020f7:	c9                   	leave  
  8020f8:	c3                   	ret    

008020f9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	56                   	push   %esi
  8020fd:	53                   	push   %ebx
  8020fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802101:	8b 45 08             	mov    0x8(%ebp),%eax
  802104:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802109:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80210f:	8b 45 14             	mov    0x14(%ebp),%eax
  802112:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802117:	b8 07 00 00 00       	mov    $0x7,%eax
  80211c:	e8 76 fe ff ff       	call   801f97 <nsipc>
  802121:	89 c3                	mov    %eax,%ebx
  802123:	85 c0                	test   %eax,%eax
  802125:	78 35                	js     80215c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802127:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80212c:	7f 04                	jg     802132 <nsipc_recv+0x39>
  80212e:	39 c6                	cmp    %eax,%esi
  802130:	7d 16                	jge    802148 <nsipc_recv+0x4f>
  802132:	68 32 2c 80 00       	push   $0x802c32
  802137:	68 db 2b 80 00       	push   $0x802bdb
  80213c:	6a 62                	push   $0x62
  80213e:	68 47 2c 80 00       	push   $0x802c47
  802143:	e8 10 e0 ff ff       	call   800158 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802148:	83 ec 04             	sub    $0x4,%esp
  80214b:	50                   	push   %eax
  80214c:	68 00 60 80 00       	push   $0x806000
  802151:	ff 75 0c             	pushl  0xc(%ebp)
  802154:	e8 0f e8 ff ff       	call   800968 <memmove>
  802159:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    

00802165 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	53                   	push   %ebx
  802169:	83 ec 04             	sub    $0x4,%esp
  80216c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80216f:	8b 45 08             	mov    0x8(%ebp),%eax
  802172:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802177:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80217d:	7e 16                	jle    802195 <nsipc_send+0x30>
  80217f:	68 53 2c 80 00       	push   $0x802c53
  802184:	68 db 2b 80 00       	push   $0x802bdb
  802189:	6a 6d                	push   $0x6d
  80218b:	68 47 2c 80 00       	push   $0x802c47
  802190:	e8 c3 df ff ff       	call   800158 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802195:	83 ec 04             	sub    $0x4,%esp
  802198:	53                   	push   %ebx
  802199:	ff 75 0c             	pushl  0xc(%ebp)
  80219c:	68 0c 60 80 00       	push   $0x80600c
  8021a1:	e8 c2 e7 ff ff       	call   800968 <memmove>
	nsipcbuf.send.req_size = size;
  8021a6:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8021af:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8021b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8021b9:	e8 d9 fd ff ff       	call   801f97 <nsipc>
}
  8021be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c1:	c9                   	leave  
  8021c2:	c3                   	ret    

008021c3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8021d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8021d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8021dc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021e1:	b8 09 00 00 00       	mov    $0x9,%eax
  8021e6:	e8 ac fd ff ff       	call   801f97 <nsipc>
}
  8021eb:	c9                   	leave  
  8021ec:	c3                   	ret    

008021ed <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ed:	55                   	push   %ebp
  8021ee:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f5:	5d                   	pop    %ebp
  8021f6:	c3                   	ret    

008021f7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021f7:	55                   	push   %ebp
  8021f8:	89 e5                	mov    %esp,%ebp
  8021fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021fd:	68 5f 2c 80 00       	push   $0x802c5f
  802202:	ff 75 0c             	pushl  0xc(%ebp)
  802205:	e8 cc e5 ff ff       	call   8007d6 <strcpy>
	return 0;
}
  80220a:	b8 00 00 00 00       	mov    $0x0,%eax
  80220f:	c9                   	leave  
  802210:	c3                   	ret    

00802211 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	57                   	push   %edi
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802222:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802228:	eb 2d                	jmp    802257 <devcons_write+0x46>
		m = n - tot;
  80222a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80222d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80222f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802232:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802237:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80223a:	83 ec 04             	sub    $0x4,%esp
  80223d:	53                   	push   %ebx
  80223e:	03 45 0c             	add    0xc(%ebp),%eax
  802241:	50                   	push   %eax
  802242:	57                   	push   %edi
  802243:	e8 20 e7 ff ff       	call   800968 <memmove>
		sys_cputs(buf, m);
  802248:	83 c4 08             	add    $0x8,%esp
  80224b:	53                   	push   %ebx
  80224c:	57                   	push   %edi
  80224d:	e8 cb e8 ff ff       	call   800b1d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802252:	01 de                	add    %ebx,%esi
  802254:	83 c4 10             	add    $0x10,%esp
  802257:	89 f0                	mov    %esi,%eax
  802259:	3b 75 10             	cmp    0x10(%ebp),%esi
  80225c:	72 cc                	jb     80222a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80225e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802261:	5b                   	pop    %ebx
  802262:	5e                   	pop    %esi
  802263:	5f                   	pop    %edi
  802264:	5d                   	pop    %ebp
  802265:	c3                   	ret    

00802266 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	83 ec 08             	sub    $0x8,%esp
  80226c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802271:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802275:	74 2a                	je     8022a1 <devcons_read+0x3b>
  802277:	eb 05                	jmp    80227e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802279:	e8 3c e9 ff ff       	call   800bba <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80227e:	e8 b8 e8 ff ff       	call   800b3b <sys_cgetc>
  802283:	85 c0                	test   %eax,%eax
  802285:	74 f2                	je     802279 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802287:	85 c0                	test   %eax,%eax
  802289:	78 16                	js     8022a1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80228b:	83 f8 04             	cmp    $0x4,%eax
  80228e:	74 0c                	je     80229c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802290:	8b 55 0c             	mov    0xc(%ebp),%edx
  802293:	88 02                	mov    %al,(%edx)
	return 1;
  802295:	b8 01 00 00 00       	mov    $0x1,%eax
  80229a:	eb 05                	jmp    8022a1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80229c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022a1:	c9                   	leave  
  8022a2:	c3                   	ret    

008022a3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ac:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022af:	6a 01                	push   $0x1
  8022b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022b4:	50                   	push   %eax
  8022b5:	e8 63 e8 ff ff       	call   800b1d <sys_cputs>
}
  8022ba:	83 c4 10             	add    $0x10,%esp
  8022bd:	c9                   	leave  
  8022be:	c3                   	ret    

008022bf <getchar>:

int
getchar(void)
{
  8022bf:	55                   	push   %ebp
  8022c0:	89 e5                	mov    %esp,%ebp
  8022c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022c5:	6a 01                	push   $0x1
  8022c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ca:	50                   	push   %eax
  8022cb:	6a 00                	push   $0x0
  8022cd:	e8 1d f2 ff ff       	call   8014ef <read>
	if (r < 0)
  8022d2:	83 c4 10             	add    $0x10,%esp
  8022d5:	85 c0                	test   %eax,%eax
  8022d7:	78 0f                	js     8022e8 <getchar+0x29>
		return r;
	if (r < 1)
  8022d9:	85 c0                	test   %eax,%eax
  8022db:	7e 06                	jle    8022e3 <getchar+0x24>
		return -E_EOF;
	return c;
  8022dd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e1:	eb 05                	jmp    8022e8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022e8:	c9                   	leave  
  8022e9:	c3                   	ret    

008022ea <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f3:	50                   	push   %eax
  8022f4:	ff 75 08             	pushl  0x8(%ebp)
  8022f7:	e8 8d ef ff ff       	call   801289 <fd_lookup>
  8022fc:	83 c4 10             	add    $0x10,%esp
  8022ff:	85 c0                	test   %eax,%eax
  802301:	78 11                	js     802314 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802306:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80230c:	39 10                	cmp    %edx,(%eax)
  80230e:	0f 94 c0             	sete   %al
  802311:	0f b6 c0             	movzbl %al,%eax
}
  802314:	c9                   	leave  
  802315:	c3                   	ret    

00802316 <opencons>:

int
opencons(void)
{
  802316:	55                   	push   %ebp
  802317:	89 e5                	mov    %esp,%ebp
  802319:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80231f:	50                   	push   %eax
  802320:	e8 15 ef ff ff       	call   80123a <fd_alloc>
  802325:	83 c4 10             	add    $0x10,%esp
		return r;
  802328:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80232a:	85 c0                	test   %eax,%eax
  80232c:	78 3e                	js     80236c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80232e:	83 ec 04             	sub    $0x4,%esp
  802331:	68 07 04 00 00       	push   $0x407
  802336:	ff 75 f4             	pushl  -0xc(%ebp)
  802339:	6a 00                	push   $0x0
  80233b:	e8 99 e8 ff ff       	call   800bd9 <sys_page_alloc>
  802340:	83 c4 10             	add    $0x10,%esp
		return r;
  802343:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802345:	85 c0                	test   %eax,%eax
  802347:	78 23                	js     80236c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802349:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802352:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802357:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80235e:	83 ec 0c             	sub    $0xc,%esp
  802361:	50                   	push   %eax
  802362:	e8 ac ee ff ff       	call   801213 <fd2num>
  802367:	89 c2                	mov    %eax,%edx
  802369:	83 c4 10             	add    $0x10,%esp
}
  80236c:	89 d0                	mov    %edx,%eax
  80236e:	c9                   	leave  
  80236f:	c3                   	ret    

00802370 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802376:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80237d:	75 56                	jne    8023d5 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80237f:	83 ec 04             	sub    $0x4,%esp
  802382:	6a 07                	push   $0x7
  802384:	68 00 f0 bf ee       	push   $0xeebff000
  802389:	6a 00                	push   $0x0
  80238b:	e8 49 e8 ff ff       	call   800bd9 <sys_page_alloc>
  802390:	83 c4 10             	add    $0x10,%esp
  802393:	85 c0                	test   %eax,%eax
  802395:	74 14                	je     8023ab <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  802397:	83 ec 04             	sub    $0x4,%esp
  80239a:	68 e9 2a 80 00       	push   $0x802ae9
  80239f:	6a 21                	push   $0x21
  8023a1:	68 6b 2c 80 00       	push   $0x802c6b
  8023a6:	e8 ad dd ff ff       	call   800158 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8023ab:	83 ec 08             	sub    $0x8,%esp
  8023ae:	68 df 23 80 00       	push   $0x8023df
  8023b3:	6a 00                	push   $0x0
  8023b5:	e8 6a e9 ff ff       	call   800d24 <sys_env_set_pgfault_upcall>
  8023ba:	83 c4 10             	add    $0x10,%esp
  8023bd:	85 c0                	test   %eax,%eax
  8023bf:	74 14                	je     8023d5 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8023c1:	83 ec 04             	sub    $0x4,%esp
  8023c4:	68 79 2c 80 00       	push   $0x802c79
  8023c9:	6a 23                	push   $0x23
  8023cb:	68 6b 2c 80 00       	push   $0x802c6b
  8023d0:	e8 83 dd ff ff       	call   800158 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023dd:	c9                   	leave  
  8023de:	c3                   	ret    

008023df <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023df:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023e0:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023e5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023e7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8023ea:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8023ec:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8023f0:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8023f4:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8023f5:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8023f7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8023fc:	83 c4 08             	add    $0x8,%esp
	popal
  8023ff:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802400:	83 c4 04             	add    $0x4,%esp
	popfl
  802403:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802404:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802405:	c3                   	ret    

00802406 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802406:	55                   	push   %ebp
  802407:	89 e5                	mov    %esp,%ebp
  802409:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80240c:	89 d0                	mov    %edx,%eax
  80240e:	c1 e8 16             	shr    $0x16,%eax
  802411:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802418:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80241d:	f6 c1 01             	test   $0x1,%cl
  802420:	74 1d                	je     80243f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802422:	c1 ea 0c             	shr    $0xc,%edx
  802425:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80242c:	f6 c2 01             	test   $0x1,%dl
  80242f:	74 0e                	je     80243f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802431:	c1 ea 0c             	shr    $0xc,%edx
  802434:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80243b:	ef 
  80243c:	0f b7 c0             	movzwl %ax,%eax
}
  80243f:	5d                   	pop    %ebp
  802440:	c3                   	ret    
  802441:	66 90                	xchg   %ax,%ax
  802443:	66 90                	xchg   %ax,%ax
  802445:	66 90                	xchg   %ax,%ax
  802447:	66 90                	xchg   %ax,%ax
  802449:	66 90                	xchg   %ax,%ax
  80244b:	66 90                	xchg   %ax,%ax
  80244d:	66 90                	xchg   %ax,%ax
  80244f:	90                   	nop

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	53                   	push   %ebx
  802454:	83 ec 1c             	sub    $0x1c,%esp
  802457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80245b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80245f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802467:	85 f6                	test   %esi,%esi
  802469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80246d:	89 ca                	mov    %ecx,%edx
  80246f:	89 f8                	mov    %edi,%eax
  802471:	75 3d                	jne    8024b0 <__udivdi3+0x60>
  802473:	39 cf                	cmp    %ecx,%edi
  802475:	0f 87 c5 00 00 00    	ja     802540 <__udivdi3+0xf0>
  80247b:	85 ff                	test   %edi,%edi
  80247d:	89 fd                	mov    %edi,%ebp
  80247f:	75 0b                	jne    80248c <__udivdi3+0x3c>
  802481:	b8 01 00 00 00       	mov    $0x1,%eax
  802486:	31 d2                	xor    %edx,%edx
  802488:	f7 f7                	div    %edi
  80248a:	89 c5                	mov    %eax,%ebp
  80248c:	89 c8                	mov    %ecx,%eax
  80248e:	31 d2                	xor    %edx,%edx
  802490:	f7 f5                	div    %ebp
  802492:	89 c1                	mov    %eax,%ecx
  802494:	89 d8                	mov    %ebx,%eax
  802496:	89 cf                	mov    %ecx,%edi
  802498:	f7 f5                	div    %ebp
  80249a:	89 c3                	mov    %eax,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	39 ce                	cmp    %ecx,%esi
  8024b2:	77 74                	ja     802528 <__udivdi3+0xd8>
  8024b4:	0f bd fe             	bsr    %esi,%edi
  8024b7:	83 f7 1f             	xor    $0x1f,%edi
  8024ba:	0f 84 98 00 00 00    	je     802558 <__udivdi3+0x108>
  8024c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	89 c5                	mov    %eax,%ebp
  8024c9:	29 fb                	sub    %edi,%ebx
  8024cb:	d3 e6                	shl    %cl,%esi
  8024cd:	89 d9                	mov    %ebx,%ecx
  8024cf:	d3 ed                	shr    %cl,%ebp
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e0                	shl    %cl,%eax
  8024d5:	09 ee                	or     %ebp,%esi
  8024d7:	89 d9                	mov    %ebx,%ecx
  8024d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024dd:	89 d5                	mov    %edx,%ebp
  8024df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e3:	d3 ed                	shr    %cl,%ebp
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e2                	shl    %cl,%edx
  8024e9:	89 d9                	mov    %ebx,%ecx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	09 c2                	or     %eax,%edx
  8024ef:	89 d0                	mov    %edx,%eax
  8024f1:	89 ea                	mov    %ebp,%edx
  8024f3:	f7 f6                	div    %esi
  8024f5:	89 d5                	mov    %edx,%ebp
  8024f7:	89 c3                	mov    %eax,%ebx
  8024f9:	f7 64 24 0c          	mull   0xc(%esp)
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	72 10                	jb     802511 <__udivdi3+0xc1>
  802501:	8b 74 24 08          	mov    0x8(%esp),%esi
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e6                	shl    %cl,%esi
  802509:	39 c6                	cmp    %eax,%esi
  80250b:	73 07                	jae    802514 <__udivdi3+0xc4>
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	75 03                	jne    802514 <__udivdi3+0xc4>
  802511:	83 eb 01             	sub    $0x1,%ebx
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 d8                	mov    %ebx,%eax
  802518:	89 fa                	mov    %edi,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	31 ff                	xor    %edi,%edi
  80252a:	31 db                	xor    %ebx,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d8                	mov    %ebx,%eax
  802542:	f7 f7                	div    %edi
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 c3                	mov    %eax,%ebx
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	89 fa                	mov    %edi,%edx
  80254c:	83 c4 1c             	add    $0x1c,%esp
  80254f:	5b                   	pop    %ebx
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
  802554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802558:	39 ce                	cmp    %ecx,%esi
  80255a:	72 0c                	jb     802568 <__udivdi3+0x118>
  80255c:	31 db                	xor    %ebx,%ebx
  80255e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802562:	0f 87 34 ff ff ff    	ja     80249c <__udivdi3+0x4c>
  802568:	bb 01 00 00 00       	mov    $0x1,%ebx
  80256d:	e9 2a ff ff ff       	jmp    80249c <__udivdi3+0x4c>
  802572:	66 90                	xchg   %ax,%ax
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80258b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80258f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 d2                	test   %edx,%edx
  802599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f3                	mov    %esi,%ebx
  8025a3:	89 3c 24             	mov    %edi,(%esp)
  8025a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025aa:	75 1c                	jne    8025c8 <__umoddi3+0x48>
  8025ac:	39 f7                	cmp    %esi,%edi
  8025ae:	76 50                	jbe    802600 <__umoddi3+0x80>
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	f7 f7                	div    %edi
  8025b6:	89 d0                	mov    %edx,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	89 d0                	mov    %edx,%eax
  8025cc:	77 52                	ja     802620 <__umoddi3+0xa0>
  8025ce:	0f bd ea             	bsr    %edx,%ebp
  8025d1:	83 f5 1f             	xor    $0x1f,%ebp
  8025d4:	75 5a                	jne    802630 <__umoddi3+0xb0>
  8025d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025da:	0f 82 e0 00 00 00    	jb     8026c0 <__umoddi3+0x140>
  8025e0:	39 0c 24             	cmp    %ecx,(%esp)
  8025e3:	0f 86 d7 00 00 00    	jbe    8026c0 <__umoddi3+0x140>
  8025e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025f1:	83 c4 1c             	add    $0x1c,%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	85 ff                	test   %edi,%edi
  802602:	89 fd                	mov    %edi,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x91>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f7                	div    %edi
  80260f:	89 c5                	mov    %eax,%ebp
  802611:	89 f0                	mov    %esi,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f5                	div    %ebp
  802617:	89 c8                	mov    %ecx,%eax
  802619:	f7 f5                	div    %ebp
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	eb 99                	jmp    8025b8 <__umoddi3+0x38>
  80261f:	90                   	nop
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	83 c4 1c             	add    $0x1c,%esp
  802627:	5b                   	pop    %ebx
  802628:	5e                   	pop    %esi
  802629:	5f                   	pop    %edi
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
  80262c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802630:	8b 34 24             	mov    (%esp),%esi
  802633:	bf 20 00 00 00       	mov    $0x20,%edi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	29 ef                	sub    %ebp,%edi
  80263c:	d3 e0                	shl    %cl,%eax
  80263e:	89 f9                	mov    %edi,%ecx
  802640:	89 f2                	mov    %esi,%edx
  802642:	d3 ea                	shr    %cl,%edx
  802644:	89 e9                	mov    %ebp,%ecx
  802646:	09 c2                	or     %eax,%edx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 14 24             	mov    %edx,(%esp)
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	d3 e2                	shl    %cl,%edx
  802651:	89 f9                	mov    %edi,%ecx
  802653:	89 54 24 04          	mov    %edx,0x4(%esp)
  802657:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	89 c6                	mov    %eax,%esi
  802661:	d3 e3                	shl    %cl,%ebx
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 d0                	mov    %edx,%eax
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	09 d8                	or     %ebx,%eax
  80266d:	89 d3                	mov    %edx,%ebx
  80266f:	89 f2                	mov    %esi,%edx
  802671:	f7 34 24             	divl   (%esp)
  802674:	89 d6                	mov    %edx,%esi
  802676:	d3 e3                	shl    %cl,%ebx
  802678:	f7 64 24 04          	mull   0x4(%esp)
  80267c:	39 d6                	cmp    %edx,%esi
  80267e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802682:	89 d1                	mov    %edx,%ecx
  802684:	89 c3                	mov    %eax,%ebx
  802686:	72 08                	jb     802690 <__umoddi3+0x110>
  802688:	75 11                	jne    80269b <__umoddi3+0x11b>
  80268a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80268e:	73 0b                	jae    80269b <__umoddi3+0x11b>
  802690:	2b 44 24 04          	sub    0x4(%esp),%eax
  802694:	1b 14 24             	sbb    (%esp),%edx
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 c3                	mov    %eax,%ebx
  80269b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80269f:	29 da                	sub    %ebx,%edx
  8026a1:	19 ce                	sbb    %ecx,%esi
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 f0                	mov    %esi,%eax
  8026a7:	d3 e0                	shl    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	d3 ea                	shr    %cl,%edx
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	d3 ee                	shr    %cl,%esi
  8026b1:	09 d0                	or     %edx,%eax
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	83 c4 1c             	add    $0x1c,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5e                   	pop    %esi
  8026ba:	5f                   	pop    %edi
  8026bb:	5d                   	pop    %ebp
  8026bc:	c3                   	ret    
  8026bd:	8d 76 00             	lea    0x0(%esi),%esi
  8026c0:	29 f9                	sub    %edi,%ecx
  8026c2:	19 d6                	sbb    %edx,%esi
  8026c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cc:	e9 18 ff ff ff       	jmp    8025e9 <__umoddi3+0x69>
