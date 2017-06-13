
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003e:	c7 05 00 30 80 00 20 	movl   $0x802920,0x803000
  800045:	29 80 00 

	cprintf("icode startup\n");
  800048:	68 26 29 80 00       	push   $0x802926
  80004d:	e8 1b 02 00 00       	call   80026d <cprintf>

	cprintf("icode: open /motd\n");
  800052:	c7 04 24 35 29 80 00 	movl   $0x802935,(%esp)
  800059:	e8 0f 02 00 00       	call   80026d <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  80005e:	83 c4 08             	add    $0x8,%esp
  800061:	6a 00                	push   $0x0
  800063:	68 48 29 80 00       	push   $0x802948
  800068:	e8 2b 15 00 00       	call   801598 <open>
  80006d:	89 c6                	mov    %eax,%esi
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	85 c0                	test   %eax,%eax
  800074:	79 12                	jns    800088 <umain+0x55>
		panic("icode: open /motd: %e", fd);
  800076:	50                   	push   %eax
  800077:	68 4e 29 80 00       	push   $0x80294e
  80007c:	6a 0f                	push   $0xf
  80007e:	68 64 29 80 00       	push   $0x802964
  800083:	e8 0c 01 00 00       	call   800194 <_panic>

	cprintf("icode: read /motd\n");
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	68 71 29 80 00       	push   $0x802971
  800090:	e8 d8 01 00 00       	call   80026d <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  80009e:	eb 0d                	jmp    8000ad <umain+0x7a>
		sys_cputs(buf, n);
  8000a0:	83 ec 08             	sub    $0x8,%esp
  8000a3:	50                   	push   %eax
  8000a4:	53                   	push   %ebx
  8000a5:	e8 af 0a 00 00       	call   800b59 <sys_cputs>
  8000aa:	83 c4 10             	add    $0x10,%esp
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	68 00 02 00 00       	push   $0x200
  8000b5:	53                   	push   %ebx
  8000b6:	56                   	push   %esi
  8000b7:	e8 45 10 00 00       	call   801101 <read>
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	7f dd                	jg     8000a0 <umain+0x6d>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	68 84 29 80 00       	push   $0x802984
  8000cb:	e8 9d 01 00 00       	call   80026d <cprintf>
	close(fd);
  8000d0:	89 34 24             	mov    %esi,(%esp)
  8000d3:	e8 ed 0e 00 00       	call   800fc5 <close>

	cprintf("icode: spawn /init\n");
  8000d8:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  8000df:	e8 89 01 00 00       	call   80026d <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000eb:	68 ac 29 80 00       	push   $0x8029ac
  8000f0:	68 b5 29 80 00       	push   $0x8029b5
  8000f5:	68 bf 29 80 00       	push   $0x8029bf
  8000fa:	68 be 29 80 00       	push   $0x8029be
  8000ff:	e8 8f 1a 00 00       	call   801b93 <spawnl>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	79 12                	jns    80011d <umain+0xea>
		panic("icode: spawn /init: %e", r);
  80010b:	50                   	push   %eax
  80010c:	68 c4 29 80 00       	push   $0x8029c4
  800111:	6a 1a                	push   $0x1a
  800113:	68 64 29 80 00       	push   $0x802964
  800118:	e8 77 00 00 00       	call   800194 <_panic>

	cprintf("icode: exiting\n");
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	68 db 29 80 00       	push   $0x8029db
  800125:	e8 43 01 00 00       	call   80026d <cprintf>
}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80013f:	e8 93 0a 00 00       	call   800bd7 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800144:	25 ff 03 00 00       	and    $0x3ff,%eax
  800149:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800151:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800156:	85 db                	test   %ebx,%ebx
  800158:	7e 07                	jle    800161 <libmain+0x2d>
		binaryname = argv[0];
  80015a:	8b 06                	mov    (%esi),%eax
  80015c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	e8 c8 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80016b:	e8 0a 00 00 00       	call   80017a <exit>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800180:	e8 6b 0e 00 00       	call   800ff0 <close_all>
	sys_env_destroy(0);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	6a 00                	push   $0x0
  80018a:	e8 07 0a 00 00       	call   800b96 <sys_env_destroy>
}
  80018f:	83 c4 10             	add    $0x10,%esp
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800199:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a2:	e8 30 0a 00 00       	call   800bd7 <sys_getenvid>
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 0c             	pushl  0xc(%ebp)
  8001ad:	ff 75 08             	pushl  0x8(%ebp)
  8001b0:	56                   	push   %esi
  8001b1:	50                   	push   %eax
  8001b2:	68 f8 29 80 00       	push   $0x8029f8
  8001b7:	e8 b1 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bc:	83 c4 18             	add    $0x18,%esp
  8001bf:	53                   	push   %ebx
  8001c0:	ff 75 10             	pushl  0x10(%ebp)
  8001c3:	e8 54 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001c8:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  8001cf:	e8 99 00 00 00       	call   80026d <cprintf>
  8001d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d7:	cc                   	int3   
  8001d8:	eb fd                	jmp    8001d7 <_panic+0x43>

008001da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 04             	sub    $0x4,%esp
  8001e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e4:	8b 13                	mov    (%ebx),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 03                	mov    %eax,(%ebx)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	75 1a                	jne    800213 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	68 ff 00 00 00       	push   $0xff
  800201:	8d 43 08             	lea    0x8(%ebx),%eax
  800204:	50                   	push   %eax
  800205:	e8 4f 09 00 00       	call   800b59 <sys_cputs>
		b->idx = 0;
  80020a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800210:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800213:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800217:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800225:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022c:	00 00 00 
	b.cnt = 0;
  80022f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800236:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800239:	ff 75 0c             	pushl  0xc(%ebp)
  80023c:	ff 75 08             	pushl  0x8(%ebp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	50                   	push   %eax
  800246:	68 da 01 80 00       	push   $0x8001da
  80024b:	e8 54 01 00 00       	call   8003a4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	83 c4 08             	add    $0x8,%esp
  800253:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800259:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025f:	50                   	push   %eax
  800260:	e8 f4 08 00 00       	call   800b59 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 9d ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 1c             	sub    $0x1c,%esp
  80028a:	89 c7                	mov    %eax,%edi
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	8b 55 0c             	mov    0xc(%ebp),%edx
  800294:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80029a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a8:	39 d3                	cmp    %edx,%ebx
  8002aa:	72 05                	jb     8002b1 <printnum+0x30>
  8002ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002af:	77 45                	ja     8002f6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b1:	83 ec 0c             	sub    $0xc,%esp
  8002b4:	ff 75 18             	pushl  0x18(%ebp)
  8002b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bd:	53                   	push   %ebx
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d0:	e8 bb 23 00 00       	call   802690 <__udivdi3>
  8002d5:	83 c4 18             	add    $0x18,%esp
  8002d8:	52                   	push   %edx
  8002d9:	50                   	push   %eax
  8002da:	89 f2                	mov    %esi,%edx
  8002dc:	89 f8                	mov    %edi,%eax
  8002de:	e8 9e ff ff ff       	call   800281 <printnum>
  8002e3:	83 c4 20             	add    $0x20,%esp
  8002e6:	eb 18                	jmp    800300 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	ff d7                	call   *%edi
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	eb 03                	jmp    8002f9 <printnum+0x78>
  8002f6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f9:	83 eb 01             	sub    $0x1,%ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f e8                	jg     8002e8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	56                   	push   %esi
  800304:	83 ec 04             	sub    $0x4,%esp
  800307:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030a:	ff 75 e0             	pushl  -0x20(%ebp)
  80030d:	ff 75 dc             	pushl  -0x24(%ebp)
  800310:	ff 75 d8             	pushl  -0x28(%ebp)
  800313:	e8 a8 24 00 00       	call   8027c0 <__umoddi3>
  800318:	83 c4 14             	add    $0x14,%esp
  80031b:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
  800322:	50                   	push   %eax
  800323:	ff d7                	call   *%edi
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800333:	83 fa 01             	cmp    $0x1,%edx
  800336:	7e 0e                	jle    800346 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	8b 52 04             	mov    0x4(%edx),%edx
  800344:	eb 22                	jmp    800368 <getuint+0x38>
	else if (lflag)
  800346:	85 d2                	test   %edx,%edx
  800348:	74 10                	je     80035a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	ba 00 00 00 00       	mov    $0x0,%edx
  800358:	eb 0e                	jmp    800368 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035a:	8b 10                	mov    (%eax),%edx
  80035c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035f:	89 08                	mov    %ecx,(%eax)
  800361:	8b 02                	mov    (%edx),%eax
  800363:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800370:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800374:	8b 10                	mov    (%eax),%edx
  800376:	3b 50 04             	cmp    0x4(%eax),%edx
  800379:	73 0a                	jae    800385 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	88 02                	mov    %al,(%edx)
}
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800390:	50                   	push   %eax
  800391:	ff 75 10             	pushl  0x10(%ebp)
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	e8 05 00 00 00       	call   8003a4 <vprintfmt>
	va_end(ap);
}
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 2c             	sub    $0x2c,%esp
  8003ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8003b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b6:	eb 12                	jmp    8003ca <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 a9 03 00 00    	je     800769 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	ff d6                	call   *%esi
  8003c7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	83 c7 01             	add    $0x1,%edi
  8003cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e2                	jne    8003b8 <vprintfmt+0x14>
  8003d6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003da:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	eb 07                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 47 01             	lea    0x1(%edi),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 07             	movzbl (%edi),%eax
  800406:	0f b6 c8             	movzbl %al,%ecx
  800409:	83 e8 23             	sub    $0x23,%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 3a 03 00 00    	ja     80074e <vprintfmt+0x3aa>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800421:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800425:	eb d6                	jmp    8003fd <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800432:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800435:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800439:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043f:	83 fa 09             	cmp    $0x9,%edx
  800442:	77 39                	ja     80047d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800444:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800447:	eb e9                	jmp    800432 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 48 04             	lea    0x4(%eax),%ecx
  80044f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80045a:	eb 27                	jmp    800483 <vprintfmt+0xdf>
  80045c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	b9 00 00 00 00       	mov    $0x0,%ecx
  800466:	0f 49 c8             	cmovns %eax,%ecx
  800469:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046f:	eb 8c                	jmp    8003fd <vprintfmt+0x59>
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800474:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047b:	eb 80                	jmp    8003fd <vprintfmt+0x59>
  80047d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800480:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	0f 89 70 ff ff ff    	jns    8003fd <vprintfmt+0x59>
				width = precision, precision = -1;
  80048d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800490:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800493:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80049a:	e9 5e ff ff ff       	jmp    8003fd <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a5:	e9 53 ff ff ff       	jmp    8003fd <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 30                	pushl  (%eax)
  8004b9:	ff d6                	call   *%esi
			break;
  8004bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c1:	e9 04 ff ff ff       	jmp    8003ca <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	99                   	cltd   
  8004d2:	31 d0                	xor    %edx,%eax
  8004d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 0f             	cmp    $0xf,%eax
  8004d9:	7f 0b                	jg     8004e6 <vprintfmt+0x142>
  8004db:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 18                	jne    8004fe <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	50                   	push   %eax
  8004e7:	68 33 2a 80 00       	push   $0x802a33
  8004ec:	53                   	push   %ebx
  8004ed:	56                   	push   %esi
  8004ee:	e8 94 fe ff ff       	call   800387 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f9:	e9 cc fe ff ff       	jmp    8003ca <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fe:	52                   	push   %edx
  8004ff:	68 f5 2d 80 00       	push   $0x802df5
  800504:	53                   	push   %ebx
  800505:	56                   	push   %esi
  800506:	e8 7c fe ff ff       	call   800387 <printfmt>
  80050b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	e9 b4 fe ff ff       	jmp    8003ca <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 04             	lea    0x4(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800521:	85 ff                	test   %edi,%edi
  800523:	b8 2c 2a 80 00       	mov    $0x802a2c,%eax
  800528:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052f:	0f 8e 94 00 00 00    	jle    8005c9 <vprintfmt+0x225>
  800535:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800539:	0f 84 98 00 00 00    	je     8005d7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 d0             	pushl  -0x30(%ebp)
  800545:	57                   	push   %edi
  800546:	e8 a6 02 00 00       	call   8007f1 <strnlen>
  80054b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054e:	29 c1                	sub    %eax,%ecx
  800550:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800556:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800560:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	eb 0f                	jmp    800573 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	ff 75 e0             	pushl  -0x20(%ebp)
  80056b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 ef 01             	sub    $0x1,%edi
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	85 ff                	test   %edi,%edi
  800575:	7f ed                	jg     800564 <vprintfmt+0x1c0>
  800577:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	b8 00 00 00 00       	mov    $0x0,%eax
  800584:	0f 49 c1             	cmovns %ecx,%eax
  800587:	29 c1                	sub    %eax,%ecx
  800589:	89 75 08             	mov    %esi,0x8(%ebp)
  80058c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800592:	89 cb                	mov    %ecx,%ebx
  800594:	eb 4d                	jmp    8005e3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80059a:	74 1b                	je     8005b7 <vprintfmt+0x213>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 10                	jbe    8005b7 <vprintfmt+0x213>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 0c             	pushl  0xc(%ebp)
  8005ad:	6a 3f                	push   $0x3f
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	eb 0d                	jmp    8005c4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	ff 75 0c             	pushl  0xc(%ebp)
  8005bd:	52                   	push   %edx
  8005be:	ff 55 08             	call   *0x8(%ebp)
  8005c1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c4:	83 eb 01             	sub    $0x1,%ebx
  8005c7:	eb 1a                	jmp    8005e3 <vprintfmt+0x23f>
  8005c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d5:	eb 0c                	jmp    8005e3 <vprintfmt+0x23f>
  8005d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e3:	83 c7 01             	add    $0x1,%edi
  8005e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ea:	0f be d0             	movsbl %al,%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	74 23                	je     800614 <vprintfmt+0x270>
  8005f1:	85 f6                	test   %esi,%esi
  8005f3:	78 a1                	js     800596 <vprintfmt+0x1f2>
  8005f5:	83 ee 01             	sub    $0x1,%esi
  8005f8:	79 9c                	jns    800596 <vprintfmt+0x1f2>
  8005fa:	89 df                	mov    %ebx,%edi
  8005fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	eb 18                	jmp    80061c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800604:	83 ec 08             	sub    $0x8,%esp
  800607:	53                   	push   %ebx
  800608:	6a 20                	push   $0x20
  80060a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb 08                	jmp    80061c <vprintfmt+0x278>
  800614:	89 df                	mov    %ebx,%edi
  800616:	8b 75 08             	mov    0x8(%ebp),%esi
  800619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f e4                	jg     800604 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800623:	e9 a2 fd ff ff       	jmp    8003ca <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800628:	83 fa 01             	cmp    $0x1,%edx
  80062b:	7e 16                	jle    800643 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 08             	lea    0x8(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 50 04             	mov    0x4(%eax),%edx
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800641:	eb 32                	jmp    800675 <vprintfmt+0x2d1>
	else if (lflag)
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 50 04             	lea    0x4(%eax),%edx
  80064d:	89 55 14             	mov    %edx,0x14(%ebp)
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 c1                	mov    %eax,%ecx
  800657:	c1 f9 1f             	sar    $0x1f,%ecx
  80065a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065d:	eb 16                	jmp    800675 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066d:	89 c1                	mov    %eax,%ecx
  80066f:	c1 f9 1f             	sar    $0x1f,%ecx
  800672:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800678:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	0f 89 90 00 00 00    	jns    80071a <vprintfmt+0x376>
				putch('-', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 2d                	push   $0x2d
  800690:	ff d6                	call   *%esi
				num = -(long long) num;
  800692:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800695:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800698:	f7 d8                	neg    %eax
  80069a:	83 d2 00             	adc    $0x0,%edx
  80069d:	f7 da                	neg    %edx
  80069f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a7:	eb 71                	jmp    80071a <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ac:	e8 7f fc ff ff       	call   800330 <getuint>
			base = 10;
  8006b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b6:	eb 62                	jmp    80071a <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bb:	e8 70 fc ff ff       	call   800330 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006c7:	51                   	push   %ecx
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	6a 08                	push   $0x8
  8006cd:	52                   	push   %edx
  8006ce:	50                   	push   %eax
  8006cf:	89 da                	mov    %ebx,%edx
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	e8 a9 fb ff ff       	call   800281 <printnum>
			break;
  8006d8:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8006de:	e9 e7 fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	6a 30                	push   $0x30
  8006e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8006eb:	83 c4 08             	add    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	6a 78                	push   $0x78
  8006f1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 50 04             	lea    0x4(%eax),%edx
  8006f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fc:	8b 00                	mov    (%eax),%eax
  8006fe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800703:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800706:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070b:	eb 0d                	jmp    80071a <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070d:	8d 45 14             	lea    0x14(%ebp),%eax
  800710:	e8 1b fc ff ff       	call   800330 <getuint>
			base = 16;
  800715:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80071a:	83 ec 0c             	sub    $0xc,%esp
  80071d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800721:	57                   	push   %edi
  800722:	ff 75 e0             	pushl  -0x20(%ebp)
  800725:	51                   	push   %ecx
  800726:	52                   	push   %edx
  800727:	50                   	push   %eax
  800728:	89 da                	mov    %ebx,%edx
  80072a:	89 f0                	mov    %esi,%eax
  80072c:	e8 50 fb ff ff       	call   800281 <printnum>
			break;
  800731:	83 c4 20             	add    $0x20,%esp
  800734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800737:	e9 8e fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	51                   	push   %ecx
  800741:	ff d6                	call   *%esi
			break;
  800743:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800749:	e9 7c fc ff ff       	jmp    8003ca <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 25                	push   $0x25
  800754:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 03                	jmp    80075e <vprintfmt+0x3ba>
  80075b:	83 ef 01             	sub    $0x1,%edi
  80075e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800762:	75 f7                	jne    80075b <vprintfmt+0x3b7>
  800764:	e9 61 fc ff ff       	jmp    8003ca <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800769:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076c:	5b                   	pop    %ebx
  80076d:	5e                   	pop    %esi
  80076e:	5f                   	pop    %edi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 18             	sub    $0x18,%esp
  800777:	8b 45 08             	mov    0x8(%ebp),%eax
  80077a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800780:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800784:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800787:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078e:	85 c0                	test   %eax,%eax
  800790:	74 26                	je     8007b8 <vsnprintf+0x47>
  800792:	85 d2                	test   %edx,%edx
  800794:	7e 22                	jle    8007b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800796:	ff 75 14             	pushl  0x14(%ebp)
  800799:	ff 75 10             	pushl  0x10(%ebp)
  80079c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	68 6a 03 80 00       	push   $0x80036a
  8007a5:	e8 fa fb ff ff       	call   8003a4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	eb 05                	jmp    8007bd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c8:	50                   	push   %eax
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	ff 75 08             	pushl  0x8(%ebp)
  8007d2:	e8 9a ff ff ff       	call   800771 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	eb 03                	jmp    8007e9 <strlen+0x10>
		n++;
  8007e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ed:	75 f7                	jne    8007e6 <strlen+0xd>
		n++;
	return n;
}
  8007ef:	5d                   	pop    %ebp
  8007f0:	c3                   	ret    

008007f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ff:	eb 03                	jmp    800804 <strnlen+0x13>
		n++;
  800801:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800804:	39 c2                	cmp    %eax,%edx
  800806:	74 08                	je     800810 <strnlen+0x1f>
  800808:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080c:	75 f3                	jne    800801 <strnlen+0x10>
  80080e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081c:	89 c2                	mov    %eax,%edx
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	83 c1 01             	add    $0x1,%ecx
  800824:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082b:	84 db                	test   %bl,%bl
  80082d:	75 ef                	jne    80081e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082f:	5b                   	pop    %ebx
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	53                   	push   %ebx
  800836:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800839:	53                   	push   %ebx
  80083a:	e8 9a ff ff ff       	call   8007d9 <strlen>
  80083f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800842:	ff 75 0c             	pushl  0xc(%ebp)
  800845:	01 d8                	add    %ebx,%eax
  800847:	50                   	push   %eax
  800848:	e8 c5 ff ff ff       	call   800812 <strcpy>
	return dst;
}
  80084d:	89 d8                	mov    %ebx,%eax
  80084f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800852:	c9                   	leave  
  800853:	c3                   	ret    

00800854 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	8b 75 08             	mov    0x8(%ebp),%esi
  80085c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085f:	89 f3                	mov    %esi,%ebx
  800861:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800864:	89 f2                	mov    %esi,%edx
  800866:	eb 0f                	jmp    800877 <strncpy+0x23>
		*dst++ = *src;
  800868:	83 c2 01             	add    $0x1,%edx
  80086b:	0f b6 01             	movzbl (%ecx),%eax
  80086e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800871:	80 39 01             	cmpb   $0x1,(%ecx)
  800874:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	39 da                	cmp    %ebx,%edx
  800879:	75 ed                	jne    800868 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087b:	89 f0                	mov    %esi,%eax
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	56                   	push   %esi
  800885:	53                   	push   %ebx
  800886:	8b 75 08             	mov    0x8(%ebp),%esi
  800889:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088c:	8b 55 10             	mov    0x10(%ebp),%edx
  80088f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800891:	85 d2                	test   %edx,%edx
  800893:	74 21                	je     8008b6 <strlcpy+0x35>
  800895:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800899:	89 f2                	mov    %esi,%edx
  80089b:	eb 09                	jmp    8008a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089d:	83 c2 01             	add    $0x1,%edx
  8008a0:	83 c1 01             	add    $0x1,%ecx
  8008a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a6:	39 c2                	cmp    %eax,%edx
  8008a8:	74 09                	je     8008b3 <strlcpy+0x32>
  8008aa:	0f b6 19             	movzbl (%ecx),%ebx
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ec                	jne    80089d <strlcpy+0x1c>
  8008b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b6:	29 f0                	sub    %esi,%eax
}
  8008b8:	5b                   	pop    %ebx
  8008b9:	5e                   	pop    %esi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c5:	eb 06                	jmp    8008cd <strcmp+0x11>
		p++, q++;
  8008c7:	83 c1 01             	add    $0x1,%ecx
  8008ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cd:	0f b6 01             	movzbl (%ecx),%eax
  8008d0:	84 c0                	test   %al,%al
  8008d2:	74 04                	je     8008d8 <strcmp+0x1c>
  8008d4:	3a 02                	cmp    (%edx),%al
  8008d6:	74 ef                	je     8008c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d8:	0f b6 c0             	movzbl %al,%eax
  8008db:	0f b6 12             	movzbl (%edx),%edx
  8008de:	29 d0                	sub    %edx,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 c3                	mov    %eax,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strncmp+0x17>
		n--, p++, q++;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f9:	39 d8                	cmp    %ebx,%eax
  8008fb:	74 15                	je     800912 <strncmp+0x30>
  8008fd:	0f b6 08             	movzbl (%eax),%ecx
  800900:	84 c9                	test   %cl,%cl
  800902:	74 04                	je     800908 <strncmp+0x26>
  800904:	3a 0a                	cmp    (%edx),%cl
  800906:	74 eb                	je     8008f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
  800910:	eb 05                	jmp    800917 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800917:	5b                   	pop    %ebx
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800924:	eb 07                	jmp    80092d <strchr+0x13>
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	74 0f                	je     800939 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f2                	jne    800926 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800945:	eb 03                	jmp    80094a <strfind+0xf>
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 04                	je     800955 <strfind+0x1a>
  800951:	84 d2                	test   %dl,%dl
  800953:	75 f2                	jne    800947 <strfind+0xc>
			break;
	return (char *) s;
}
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	57                   	push   %edi
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800960:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800963:	85 c9                	test   %ecx,%ecx
  800965:	74 36                	je     80099d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800967:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096d:	75 28                	jne    800997 <memset+0x40>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 23                	jne    800997 <memset+0x40>
		c &= 0xFF;
  800974:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800978:	89 d3                	mov    %edx,%ebx
  80097a:	c1 e3 08             	shl    $0x8,%ebx
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	c1 e6 18             	shl    $0x18,%esi
  800982:	89 d0                	mov    %edx,%eax
  800984:	c1 e0 10             	shl    $0x10,%eax
  800987:	09 f0                	or     %esi,%eax
  800989:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098b:	89 d8                	mov    %ebx,%eax
  80098d:	09 d0                	or     %edx,%eax
  80098f:	c1 e9 02             	shr    $0x2,%ecx
  800992:	fc                   	cld    
  800993:	f3 ab                	rep stos %eax,%es:(%edi)
  800995:	eb 06                	jmp    80099d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099a:	fc                   	cld    
  80099b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099d:	89 f8                	mov    %edi,%eax
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	57                   	push   %edi
  8009a8:	56                   	push   %esi
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b2:	39 c6                	cmp    %eax,%esi
  8009b4:	73 35                	jae    8009eb <memmove+0x47>
  8009b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b9:	39 d0                	cmp    %edx,%eax
  8009bb:	73 2e                	jae    8009eb <memmove+0x47>
		s += n;
		d += n;
  8009bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c0:	89 d6                	mov    %edx,%esi
  8009c2:	09 fe                	or     %edi,%esi
  8009c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ca:	75 13                	jne    8009df <memmove+0x3b>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0e                	jne    8009df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d1:	83 ef 04             	sub    $0x4,%edi
  8009d4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
  8009da:	fd                   	std    
  8009db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dd:	eb 09                	jmp    8009e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009df:	83 ef 01             	sub    $0x1,%edi
  8009e2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e5:	fd                   	std    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e8:	fc                   	cld    
  8009e9:	eb 1d                	jmp    800a08 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009eb:	89 f2                	mov    %esi,%edx
  8009ed:	09 c2                	or     %eax,%edx
  8009ef:	f6 c2 03             	test   $0x3,%dl
  8009f2:	75 0f                	jne    800a03 <memmove+0x5f>
  8009f4:	f6 c1 03             	test   $0x3,%cl
  8009f7:	75 0a                	jne    800a03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f9:	c1 e9 02             	shr    $0x2,%ecx
  8009fc:	89 c7                	mov    %eax,%edi
  8009fe:	fc                   	cld    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 05                	jmp    800a08 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0f:	ff 75 10             	pushl  0x10(%ebp)
  800a12:	ff 75 0c             	pushl  0xc(%ebp)
  800a15:	ff 75 08             	pushl  0x8(%ebp)
  800a18:	e8 87 ff ff ff       	call   8009a4 <memmove>
}
  800a1d:	c9                   	leave  
  800a1e:	c3                   	ret    

00800a1f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2a:	89 c6                	mov    %eax,%esi
  800a2c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2f:	eb 1a                	jmp    800a4b <memcmp+0x2c>
		if (*s1 != *s2)
  800a31:	0f b6 08             	movzbl (%eax),%ecx
  800a34:	0f b6 1a             	movzbl (%edx),%ebx
  800a37:	38 d9                	cmp    %bl,%cl
  800a39:	74 0a                	je     800a45 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3b:	0f b6 c1             	movzbl %cl,%eax
  800a3e:	0f b6 db             	movzbl %bl,%ebx
  800a41:	29 d8                	sub    %ebx,%eax
  800a43:	eb 0f                	jmp    800a54 <memcmp+0x35>
		s1++, s2++;
  800a45:	83 c0 01             	add    $0x1,%eax
  800a48:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4b:	39 f0                	cmp    %esi,%eax
  800a4d:	75 e2                	jne    800a31 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5e                   	pop    %esi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5f:	89 c1                	mov    %eax,%ecx
  800a61:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a64:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a68:	eb 0a                	jmp    800a74 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6a:	0f b6 10             	movzbl (%eax),%edx
  800a6d:	39 da                	cmp    %ebx,%edx
  800a6f:	74 07                	je     800a78 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a71:	83 c0 01             	add    $0x1,%eax
  800a74:	39 c8                	cmp    %ecx,%eax
  800a76:	72 f2                	jb     800a6a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a87:	eb 03                	jmp    800a8c <strtol+0x11>
		s++;
  800a89:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8c:	0f b6 01             	movzbl (%ecx),%eax
  800a8f:	3c 20                	cmp    $0x20,%al
  800a91:	74 f6                	je     800a89 <strtol+0xe>
  800a93:	3c 09                	cmp    $0x9,%al
  800a95:	74 f2                	je     800a89 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a97:	3c 2b                	cmp    $0x2b,%al
  800a99:	75 0a                	jne    800aa5 <strtol+0x2a>
		s++;
  800a9b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9e:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa3:	eb 11                	jmp    800ab6 <strtol+0x3b>
  800aa5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aaa:	3c 2d                	cmp    $0x2d,%al
  800aac:	75 08                	jne    800ab6 <strtol+0x3b>
		s++, neg = 1;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abc:	75 15                	jne    800ad3 <strtol+0x58>
  800abe:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac1:	75 10                	jne    800ad3 <strtol+0x58>
  800ac3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac7:	75 7c                	jne    800b45 <strtol+0xca>
		s += 2, base = 16;
  800ac9:	83 c1 02             	add    $0x2,%ecx
  800acc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad1:	eb 16                	jmp    800ae9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad3:	85 db                	test   %ebx,%ebx
  800ad5:	75 12                	jne    800ae9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adc:	80 39 30             	cmpb   $0x30,(%ecx)
  800adf:	75 08                	jne    800ae9 <strtol+0x6e>
		s++, base = 8;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af1:	0f b6 11             	movzbl (%ecx),%edx
  800af4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af7:	89 f3                	mov    %esi,%ebx
  800af9:	80 fb 09             	cmp    $0x9,%bl
  800afc:	77 08                	ja     800b06 <strtol+0x8b>
			dig = *s - '0';
  800afe:	0f be d2             	movsbl %dl,%edx
  800b01:	83 ea 30             	sub    $0x30,%edx
  800b04:	eb 22                	jmp    800b28 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b09:	89 f3                	mov    %esi,%ebx
  800b0b:	80 fb 19             	cmp    $0x19,%bl
  800b0e:	77 08                	ja     800b18 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b10:	0f be d2             	movsbl %dl,%edx
  800b13:	83 ea 57             	sub    $0x57,%edx
  800b16:	eb 10                	jmp    800b28 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b18:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1b:	89 f3                	mov    %esi,%ebx
  800b1d:	80 fb 19             	cmp    $0x19,%bl
  800b20:	77 16                	ja     800b38 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b22:	0f be d2             	movsbl %dl,%edx
  800b25:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b28:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2b:	7d 0b                	jge    800b38 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2d:	83 c1 01             	add    $0x1,%ecx
  800b30:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b34:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b36:	eb b9                	jmp    800af1 <strtol+0x76>

	if (endptr)
  800b38:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3c:	74 0d                	je     800b4b <strtol+0xd0>
		*endptr = (char *) s;
  800b3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b41:	89 0e                	mov    %ecx,(%esi)
  800b43:	eb 06                	jmp    800b4b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b45:	85 db                	test   %ebx,%ebx
  800b47:	74 98                	je     800ae1 <strtol+0x66>
  800b49:	eb 9e                	jmp    800ae9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	f7 da                	neg    %edx
  800b4f:	85 ff                	test   %edi,%edi
  800b51:	0f 45 c2             	cmovne %edx,%eax
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	89 c3                	mov    %eax,%ebx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	89 c6                	mov    %eax,%esi
  800b70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 01 00 00 00       	mov    $0x1,%eax
  800b87:	89 d1                	mov    %edx,%ecx
  800b89:	89 d3                	mov    %edx,%ebx
  800b8b:	89 d7                	mov    %edx,%edi
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bac:	89 cb                	mov    %ecx,%ebx
  800bae:	89 cf                	mov    %ecx,%edi
  800bb0:	89 ce                	mov    %ecx,%esi
  800bb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7e 17                	jle    800bcf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	50                   	push   %eax
  800bbc:	6a 03                	push   $0x3
  800bbe:	68 1f 2d 80 00       	push   $0x802d1f
  800bc3:	6a 23                	push   $0x23
  800bc5:	68 3c 2d 80 00       	push   $0x802d3c
  800bca:	e8 c5 f5 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 02 00 00 00       	mov    $0x2,%eax
  800be7:	89 d1                	mov    %edx,%ecx
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	89 d6                	mov    %edx,%esi
  800bef:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_yield>:

void
sys_yield(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	be 00 00 00 00       	mov    $0x0,%esi
  800c23:	b8 04 00 00 00       	mov    $0x4,%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c31:	89 f7                	mov    %esi,%edi
  800c33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 17                	jle    800c50 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	50                   	push   %eax
  800c3d:	6a 04                	push   $0x4
  800c3f:	68 1f 2d 80 00       	push   $0x802d1f
  800c44:	6a 23                	push   $0x23
  800c46:	68 3c 2d 80 00       	push   $0x802d3c
  800c4b:	e8 44 f5 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	b8 05 00 00 00       	mov    $0x5,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c72:	8b 75 18             	mov    0x18(%ebp),%esi
  800c75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 17                	jle    800c92 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	6a 05                	push   $0x5
  800c81:	68 1f 2d 80 00       	push   $0x802d1f
  800c86:	6a 23                	push   $0x23
  800c88:	68 3c 2d 80 00       	push   $0x802d3c
  800c8d:	e8 02 f5 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7e 17                	jle    800cd4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	6a 06                	push   $0x6
  800cc3:	68 1f 2d 80 00       	push   $0x802d1f
  800cc8:	6a 23                	push   $0x23
  800cca:	68 3c 2d 80 00       	push   $0x802d3c
  800ccf:	e8 c0 f4 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	b8 08 00 00 00       	mov    $0x8,%eax
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 17                	jle    800d16 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 08                	push   $0x8
  800d05:	68 1f 2d 80 00       	push   $0x802d1f
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 3c 2d 80 00       	push   $0x802d3c
  800d11:	e8 7e f4 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d2c:	b8 09 00 00 00       	mov    $0x9,%eax
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
  800d3f:	7e 17                	jle    800d58 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 09                	push   $0x9
  800d47:	68 1f 2d 80 00       	push   $0x802d1f
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 3c 2d 80 00       	push   $0x802d3c
  800d53:	e8 3c f4 ff ff       	call   800194 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800d6e:	b8 0a 00 00 00       	mov    $0xa,%eax
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
  800d81:	7e 17                	jle    800d9a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	50                   	push   %eax
  800d87:	6a 0a                	push   $0xa
  800d89:	68 1f 2d 80 00       	push   $0x802d1f
  800d8e:	6a 23                	push   $0x23
  800d90:	68 3c 2d 80 00       	push   $0x802d3c
  800d95:	e8 fa f3 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	be 00 00 00 00       	mov    $0x0,%esi
  800dad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	89 cb                	mov    %ecx,%ebx
  800ddd:	89 cf                	mov    %ecx,%edi
  800ddf:	89 ce                	mov    %ecx,%esi
  800de1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 17                	jle    800dfe <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 0d                	push   $0xd
  800ded:	68 1f 2d 80 00       	push   $0x802d1f
  800df2:	6a 23                	push   $0x23
  800df4:	68 3c 2d 80 00       	push   $0x802d3c
  800df9:	e8 96 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e11:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e16:	89 d1                	mov    %edx,%ecx
  800e18:	89 d3                	mov    %edx,%ebx
  800e1a:	89 d7                	mov    %edx,%edi
  800e1c:	89 d6                	mov    %edx,%esi
  800e1e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e30:	c1 e8 0c             	shr    $0xc,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e40:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e45:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e52:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e57:	89 c2                	mov    %eax,%edx
  800e59:	c1 ea 16             	shr    $0x16,%edx
  800e5c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e63:	f6 c2 01             	test   $0x1,%dl
  800e66:	74 11                	je     800e79 <fd_alloc+0x2d>
  800e68:	89 c2                	mov    %eax,%edx
  800e6a:	c1 ea 0c             	shr    $0xc,%edx
  800e6d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e74:	f6 c2 01             	test   $0x1,%dl
  800e77:	75 09                	jne    800e82 <fd_alloc+0x36>
			*fd_store = fd;
  800e79:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	eb 17                	jmp    800e99 <fd_alloc+0x4d>
  800e82:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e87:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e8c:	75 c9                	jne    800e57 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e8e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e94:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea1:	83 f8 1f             	cmp    $0x1f,%eax
  800ea4:	77 36                	ja     800edc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea6:	c1 e0 0c             	shl    $0xc,%eax
  800ea9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eae:	89 c2                	mov    %eax,%edx
  800eb0:	c1 ea 16             	shr    $0x16,%edx
  800eb3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eba:	f6 c2 01             	test   $0x1,%dl
  800ebd:	74 24                	je     800ee3 <fd_lookup+0x48>
  800ebf:	89 c2                	mov    %eax,%edx
  800ec1:	c1 ea 0c             	shr    $0xc,%edx
  800ec4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ecb:	f6 c2 01             	test   $0x1,%dl
  800ece:	74 1a                	je     800eea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed3:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	eb 13                	jmp    800eef <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee1:	eb 0c                	jmp    800eef <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee8:	eb 05                	jmp    800eef <fd_lookup+0x54>
  800eea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 08             	sub    $0x8,%esp
  800ef7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800efa:	ba c8 2d 80 00       	mov    $0x802dc8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eff:	eb 13                	jmp    800f14 <dev_lookup+0x23>
  800f01:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f04:	39 08                	cmp    %ecx,(%eax)
  800f06:	75 0c                	jne    800f14 <dev_lookup+0x23>
			*dev = devtab[i];
  800f08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f12:	eb 2e                	jmp    800f42 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f14:	8b 02                	mov    (%edx),%eax
  800f16:	85 c0                	test   %eax,%eax
  800f18:	75 e7                	jne    800f01 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f1a:	a1 08 40 80 00       	mov    0x804008,%eax
  800f1f:	8b 40 48             	mov    0x48(%eax),%eax
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	51                   	push   %ecx
  800f26:	50                   	push   %eax
  800f27:	68 4c 2d 80 00       	push   $0x802d4c
  800f2c:	e8 3c f3 ff ff       	call   80026d <cprintf>
	*dev = 0;
  800f31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f34:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	83 ec 10             	sub    $0x10,%esp
  800f4c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f55:	50                   	push   %eax
  800f56:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f5c:	c1 e8 0c             	shr    $0xc,%eax
  800f5f:	50                   	push   %eax
  800f60:	e8 36 ff ff ff       	call   800e9b <fd_lookup>
  800f65:	83 c4 08             	add    $0x8,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	78 05                	js     800f71 <fd_close+0x2d>
	    || fd != fd2)
  800f6c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f6f:	74 0c                	je     800f7d <fd_close+0x39>
		return (must_exist ? r : 0);
  800f71:	84 db                	test   %bl,%bl
  800f73:	ba 00 00 00 00       	mov    $0x0,%edx
  800f78:	0f 44 c2             	cmove  %edx,%eax
  800f7b:	eb 41                	jmp    800fbe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7d:	83 ec 08             	sub    $0x8,%esp
  800f80:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	ff 36                	pushl  (%esi)
  800f86:	e8 66 ff ff ff       	call   800ef1 <dev_lookup>
  800f8b:	89 c3                	mov    %eax,%ebx
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 1a                	js     800fae <fd_close+0x6a>
		if (dev->dev_close)
  800f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f97:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f9a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	74 0b                	je     800fae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	56                   	push   %esi
  800fa7:	ff d0                	call   *%eax
  800fa9:	89 c3                	mov    %eax,%ebx
  800fab:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	56                   	push   %esi
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 e1 fc ff ff       	call   800c9a <sys_page_unmap>
	return r;
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	89 d8                	mov    %ebx,%eax
}
  800fbe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fce:	50                   	push   %eax
  800fcf:	ff 75 08             	pushl  0x8(%ebp)
  800fd2:	e8 c4 fe ff ff       	call   800e9b <fd_lookup>
  800fd7:	83 c4 08             	add    $0x8,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 10                	js     800fee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fde:	83 ec 08             	sub    $0x8,%esp
  800fe1:	6a 01                	push   $0x1
  800fe3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe6:	e8 59 ff ff ff       	call   800f44 <fd_close>
  800feb:	83 c4 10             	add    $0x10,%esp
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <close_all>:

void
close_all(void)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	53                   	push   %ebx
  801000:	e8 c0 ff ff ff       	call   800fc5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801005:	83 c3 01             	add    $0x1,%ebx
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	83 fb 20             	cmp    $0x20,%ebx
  80100e:	75 ec                	jne    800ffc <close_all+0xc>
		close(i);
}
  801010:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
  80101b:	83 ec 2c             	sub    $0x2c,%esp
  80101e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801021:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801024:	50                   	push   %eax
  801025:	ff 75 08             	pushl  0x8(%ebp)
  801028:	e8 6e fe ff ff       	call   800e9b <fd_lookup>
  80102d:	83 c4 08             	add    $0x8,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	0f 88 c1 00 00 00    	js     8010f9 <dup+0xe4>
		return r;
	close(newfdnum);
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	56                   	push   %esi
  80103c:	e8 84 ff ff ff       	call   800fc5 <close>

	newfd = INDEX2FD(newfdnum);
  801041:	89 f3                	mov    %esi,%ebx
  801043:	c1 e3 0c             	shl    $0xc,%ebx
  801046:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80104c:	83 c4 04             	add    $0x4,%esp
  80104f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801052:	e8 de fd ff ff       	call   800e35 <fd2data>
  801057:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801059:	89 1c 24             	mov    %ebx,(%esp)
  80105c:	e8 d4 fd ff ff       	call   800e35 <fd2data>
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801067:	89 f8                	mov    %edi,%eax
  801069:	c1 e8 16             	shr    $0x16,%eax
  80106c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801073:	a8 01                	test   $0x1,%al
  801075:	74 37                	je     8010ae <dup+0x99>
  801077:	89 f8                	mov    %edi,%eax
  801079:	c1 e8 0c             	shr    $0xc,%eax
  80107c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801083:	f6 c2 01             	test   $0x1,%dl
  801086:	74 26                	je     8010ae <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801088:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	25 07 0e 00 00       	and    $0xe07,%eax
  801097:	50                   	push   %eax
  801098:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109b:	6a 00                	push   $0x0
  80109d:	57                   	push   %edi
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 b3 fb ff ff       	call   800c58 <sys_page_map>
  8010a5:	89 c7                	mov    %eax,%edi
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 2e                	js     8010dc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010b1:	89 d0                	mov    %edx,%eax
  8010b3:	c1 e8 0c             	shr    $0xc,%eax
  8010b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c5:	50                   	push   %eax
  8010c6:	53                   	push   %ebx
  8010c7:	6a 00                	push   $0x0
  8010c9:	52                   	push   %edx
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 87 fb ff ff       	call   800c58 <sys_page_map>
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010d6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d8:	85 ff                	test   %edi,%edi
  8010da:	79 1d                	jns    8010f9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	53                   	push   %ebx
  8010e0:	6a 00                	push   $0x0
  8010e2:	e8 b3 fb ff ff       	call   800c9a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e7:	83 c4 08             	add    $0x8,%esp
  8010ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ed:	6a 00                	push   $0x0
  8010ef:	e8 a6 fb ff ff       	call   800c9a <sys_page_unmap>
	return r;
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	89 f8                	mov    %edi,%eax
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	53                   	push   %ebx
  801105:	83 ec 14             	sub    $0x14,%esp
  801108:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	53                   	push   %ebx
  801110:	e8 86 fd ff ff       	call   800e9b <fd_lookup>
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	89 c2                	mov    %eax,%edx
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 6d                	js     80118b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801128:	ff 30                	pushl  (%eax)
  80112a:	e8 c2 fd ff ff       	call   800ef1 <dev_lookup>
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	78 4c                	js     801182 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801136:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801139:	8b 42 08             	mov    0x8(%edx),%eax
  80113c:	83 e0 03             	and    $0x3,%eax
  80113f:	83 f8 01             	cmp    $0x1,%eax
  801142:	75 21                	jne    801165 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801144:	a1 08 40 80 00       	mov    0x804008,%eax
  801149:	8b 40 48             	mov    0x48(%eax),%eax
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	53                   	push   %ebx
  801150:	50                   	push   %eax
  801151:	68 8d 2d 80 00       	push   $0x802d8d
  801156:	e8 12 f1 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801163:	eb 26                	jmp    80118b <read+0x8a>
	}
	if (!dev->dev_read)
  801165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801168:	8b 40 08             	mov    0x8(%eax),%eax
  80116b:	85 c0                	test   %eax,%eax
  80116d:	74 17                	je     801186 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 10             	pushl  0x10(%ebp)
  801175:	ff 75 0c             	pushl  0xc(%ebp)
  801178:	52                   	push   %edx
  801179:	ff d0                	call   *%eax
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	eb 09                	jmp    80118b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801182:	89 c2                	mov    %eax,%edx
  801184:	eb 05                	jmp    80118b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801186:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80118b:	89 d0                	mov    %edx,%eax
  80118d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a6:	eb 21                	jmp    8011c9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	89 f0                	mov    %esi,%eax
  8011ad:	29 d8                	sub    %ebx,%eax
  8011af:	50                   	push   %eax
  8011b0:	89 d8                	mov    %ebx,%eax
  8011b2:	03 45 0c             	add    0xc(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	57                   	push   %edi
  8011b7:	e8 45 ff ff ff       	call   801101 <read>
		if (m < 0)
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 10                	js     8011d3 <readn+0x41>
			return m;
		if (m == 0)
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	74 0a                	je     8011d1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c7:	01 c3                	add    %eax,%ebx
  8011c9:	39 f3                	cmp    %esi,%ebx
  8011cb:	72 db                	jb     8011a8 <readn+0x16>
  8011cd:	89 d8                	mov    %ebx,%eax
  8011cf:	eb 02                	jmp    8011d3 <readn+0x41>
  8011d1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	53                   	push   %ebx
  8011df:	83 ec 14             	sub    $0x14,%esp
  8011e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	53                   	push   %ebx
  8011ea:	e8 ac fc ff ff       	call   800e9b <fd_lookup>
  8011ef:	83 c4 08             	add    $0x8,%esp
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 68                	js     801260 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801202:	ff 30                	pushl  (%eax)
  801204:	e8 e8 fc ff ff       	call   800ef1 <dev_lookup>
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 47                	js     801257 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801210:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801213:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801217:	75 21                	jne    80123a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801219:	a1 08 40 80 00       	mov    0x804008,%eax
  80121e:	8b 40 48             	mov    0x48(%eax),%eax
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	53                   	push   %ebx
  801225:	50                   	push   %eax
  801226:	68 a9 2d 80 00       	push   $0x802da9
  80122b:	e8 3d f0 ff ff       	call   80026d <cprintf>
		return -E_INVAL;
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801238:	eb 26                	jmp    801260 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80123a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123d:	8b 52 0c             	mov    0xc(%edx),%edx
  801240:	85 d2                	test   %edx,%edx
  801242:	74 17                	je     80125b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	ff 75 10             	pushl  0x10(%ebp)
  80124a:	ff 75 0c             	pushl  0xc(%ebp)
  80124d:	50                   	push   %eax
  80124e:	ff d2                	call   *%edx
  801250:	89 c2                	mov    %eax,%edx
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	eb 09                	jmp    801260 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801257:	89 c2                	mov    %eax,%edx
  801259:	eb 05                	jmp    801260 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80125b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801260:	89 d0                	mov    %edx,%eax
  801262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <seek>:

int
seek(int fdnum, off_t offset)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801270:	50                   	push   %eax
  801271:	ff 75 08             	pushl  0x8(%ebp)
  801274:	e8 22 fc ff ff       	call   800e9b <fd_lookup>
  801279:	83 c4 08             	add    $0x8,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	78 0e                	js     80128e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801280:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801283:	8b 55 0c             	mov    0xc(%ebp),%edx
  801286:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128e:	c9                   	leave  
  80128f:	c3                   	ret    

00801290 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	53                   	push   %ebx
  801294:	83 ec 14             	sub    $0x14,%esp
  801297:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129d:	50                   	push   %eax
  80129e:	53                   	push   %ebx
  80129f:	e8 f7 fb ff ff       	call   800e9b <fd_lookup>
  8012a4:	83 c4 08             	add    $0x8,%esp
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	85 c0                	test   %eax,%eax
  8012ab:	78 65                	js     801312 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b7:	ff 30                	pushl  (%eax)
  8012b9:	e8 33 fc ff ff       	call   800ef1 <dev_lookup>
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	85 c0                	test   %eax,%eax
  8012c3:	78 44                	js     801309 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012cc:	75 21                	jne    8012ef <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ce:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d3:	8b 40 48             	mov    0x48(%eax),%eax
  8012d6:	83 ec 04             	sub    $0x4,%esp
  8012d9:	53                   	push   %ebx
  8012da:	50                   	push   %eax
  8012db:	68 6c 2d 80 00       	push   $0x802d6c
  8012e0:	e8 88 ef ff ff       	call   80026d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ed:	eb 23                	jmp    801312 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f2:	8b 52 18             	mov    0x18(%edx),%edx
  8012f5:	85 d2                	test   %edx,%edx
  8012f7:	74 14                	je     80130d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	ff 75 0c             	pushl  0xc(%ebp)
  8012ff:	50                   	push   %eax
  801300:	ff d2                	call   *%edx
  801302:	89 c2                	mov    %eax,%edx
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	eb 09                	jmp    801312 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801309:	89 c2                	mov    %eax,%edx
  80130b:	eb 05                	jmp    801312 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80130d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801312:	89 d0                	mov    %edx,%eax
  801314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	53                   	push   %ebx
  80131d:	83 ec 14             	sub    $0x14,%esp
  801320:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801323:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	ff 75 08             	pushl  0x8(%ebp)
  80132a:	e8 6c fb ff ff       	call   800e9b <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	89 c2                	mov    %eax,%edx
  801334:	85 c0                	test   %eax,%eax
  801336:	78 58                	js     801390 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801342:	ff 30                	pushl  (%eax)
  801344:	e8 a8 fb ff ff       	call   800ef1 <dev_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 37                	js     801387 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801350:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801353:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801357:	74 32                	je     80138b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801359:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80135c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801363:	00 00 00 
	stat->st_isdir = 0;
  801366:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136d:	00 00 00 
	stat->st_dev = dev;
  801370:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	53                   	push   %ebx
  80137a:	ff 75 f0             	pushl  -0x10(%ebp)
  80137d:	ff 50 14             	call   *0x14(%eax)
  801380:	89 c2                	mov    %eax,%edx
  801382:	83 c4 10             	add    $0x10,%esp
  801385:	eb 09                	jmp    801390 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801387:	89 c2                	mov    %eax,%edx
  801389:	eb 05                	jmp    801390 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80138b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801390:	89 d0                	mov    %edx,%eax
  801392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	56                   	push   %esi
  80139b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	6a 00                	push   $0x0
  8013a1:	ff 75 08             	pushl  0x8(%ebp)
  8013a4:	e8 ef 01 00 00       	call   801598 <open>
  8013a9:	89 c3                	mov    %eax,%ebx
  8013ab:	83 c4 10             	add    $0x10,%esp
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	78 1b                	js     8013cd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	ff 75 0c             	pushl  0xc(%ebp)
  8013b8:	50                   	push   %eax
  8013b9:	e8 5b ff ff ff       	call   801319 <fstat>
  8013be:	89 c6                	mov    %eax,%esi
	close(fd);
  8013c0:	89 1c 24             	mov    %ebx,(%esp)
  8013c3:	e8 fd fb ff ff       	call   800fc5 <close>
	return r;
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	89 f0                	mov    %esi,%eax
}
  8013cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	56                   	push   %esi
  8013d8:	53                   	push   %ebx
  8013d9:	89 c6                	mov    %eax,%esi
  8013db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e4:	75 12                	jne    8013f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	6a 01                	push   $0x1
  8013eb:	e8 21 12 00 00       	call   802611 <ipc_find_env>
  8013f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f8:	6a 07                	push   $0x7
  8013fa:	68 00 50 80 00       	push   $0x805000
  8013ff:	56                   	push   %esi
  801400:	ff 35 00 40 80 00    	pushl  0x804000
  801406:	e8 b7 11 00 00       	call   8025c2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80140b:	83 c4 0c             	add    $0xc,%esp
  80140e:	6a 00                	push   $0x0
  801410:	53                   	push   %ebx
  801411:	6a 00                	push   $0x0
  801413:	e8 34 11 00 00       	call   80254c <ipc_recv>
}
  801418:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801425:	8b 45 08             	mov    0x8(%ebp),%eax
  801428:	8b 40 0c             	mov    0xc(%eax),%eax
  80142b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801430:	8b 45 0c             	mov    0xc(%ebp),%eax
  801433:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801438:	ba 00 00 00 00       	mov    $0x0,%edx
  80143d:	b8 02 00 00 00       	mov    $0x2,%eax
  801442:	e8 8d ff ff ff       	call   8013d4 <fsipc>
}
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	8b 40 0c             	mov    0xc(%eax),%eax
  801455:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80145a:	ba 00 00 00 00       	mov    $0x0,%edx
  80145f:	b8 06 00 00 00       	mov    $0x6,%eax
  801464:	e8 6b ff ff ff       	call   8013d4 <fsipc>
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	53                   	push   %ebx
  80146f:	83 ec 04             	sub    $0x4,%esp
  801472:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801475:	8b 45 08             	mov    0x8(%ebp),%eax
  801478:	8b 40 0c             	mov    0xc(%eax),%eax
  80147b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801480:	ba 00 00 00 00       	mov    $0x0,%edx
  801485:	b8 05 00 00 00       	mov    $0x5,%eax
  80148a:	e8 45 ff ff ff       	call   8013d4 <fsipc>
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 2c                	js     8014bf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	68 00 50 80 00       	push   $0x805000
  80149b:	53                   	push   %ebx
  80149c:	e8 71 f3 ff ff       	call   800812 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8014a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8014b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	53                   	push   %ebx
  8014c8:	83 ec 08             	sub    $0x8,%esp
  8014cb:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014da:	a3 04 50 80 00       	mov    %eax,0x805004
  8014df:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8014e4:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8014e9:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014ec:	53                   	push   %ebx
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	68 08 50 80 00       	push   $0x805008
  8014f5:	e8 aa f4 ff ff       	call   8009a4 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 04 00 00 00       	mov    $0x4,%eax
  801504:	e8 cb fe ff ff       	call   8013d4 <fsipc>
  801509:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80150c:	85 c0                	test   %eax,%eax
  80150e:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801511:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151e:	8b 45 08             	mov    0x8(%ebp),%eax
  801521:	8b 40 0c             	mov    0xc(%eax),%eax
  801524:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801529:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152f:	ba 00 00 00 00       	mov    $0x0,%edx
  801534:	b8 03 00 00 00       	mov    $0x3,%eax
  801539:	e8 96 fe ff ff       	call   8013d4 <fsipc>
  80153e:	89 c3                	mov    %eax,%ebx
  801540:	85 c0                	test   %eax,%eax
  801542:	78 4b                	js     80158f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801544:	39 c6                	cmp    %eax,%esi
  801546:	73 16                	jae    80155e <devfile_read+0x48>
  801548:	68 dc 2d 80 00       	push   $0x802ddc
  80154d:	68 e3 2d 80 00       	push   $0x802de3
  801552:	6a 7c                	push   $0x7c
  801554:	68 f8 2d 80 00       	push   $0x802df8
  801559:	e8 36 ec ff ff       	call   800194 <_panic>
	assert(r <= PGSIZE);
  80155e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801563:	7e 16                	jle    80157b <devfile_read+0x65>
  801565:	68 03 2e 80 00       	push   $0x802e03
  80156a:	68 e3 2d 80 00       	push   $0x802de3
  80156f:	6a 7d                	push   $0x7d
  801571:	68 f8 2d 80 00       	push   $0x802df8
  801576:	e8 19 ec ff ff       	call   800194 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	50                   	push   %eax
  80157f:	68 00 50 80 00       	push   $0x805000
  801584:	ff 75 0c             	pushl  0xc(%ebp)
  801587:	e8 18 f4 ff ff       	call   8009a4 <memmove>
	return r;
  80158c:	83 c4 10             	add    $0x10,%esp
}
  80158f:	89 d8                	mov    %ebx,%eax
  801591:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 20             	sub    $0x20,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a2:	53                   	push   %ebx
  8015a3:	e8 31 f2 ff ff       	call   8007d9 <strlen>
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b0:	7f 67                	jg     801619 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	e8 8e f8 ff ff       	call   800e4c <fd_alloc>
  8015be:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 57                	js     80161e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	68 00 50 80 00       	push   $0x805000
  8015d0:	e8 3d f2 ff ff       	call   800812 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e5:	e8 ea fd ff ff       	call   8013d4 <fsipc>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	79 14                	jns    801607 <open+0x6f>
		fd_close(fd, 0);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	6a 00                	push   $0x0
  8015f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fb:	e8 44 f9 ff ff       	call   800f44 <fd_close>
		return r;
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	89 da                	mov    %ebx,%edx
  801605:	eb 17                	jmp    80161e <open+0x86>
	}

	return fd2num(fd);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	ff 75 f4             	pushl  -0xc(%ebp)
  80160d:	e8 13 f8 ff ff       	call   800e25 <fd2num>
  801612:	89 c2                	mov    %eax,%edx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb 05                	jmp    80161e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801619:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161e:	89 d0                	mov    %edx,%eax
  801620:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162b:	ba 00 00 00 00       	mov    $0x0,%edx
  801630:	b8 08 00 00 00       	mov    $0x8,%eax
  801635:	e8 9a fd ff ff       	call   8013d4 <fsipc>
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	57                   	push   %edi
  801640:	56                   	push   %esi
  801641:	53                   	push   %ebx
  801642:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801648:	6a 00                	push   $0x0
  80164a:	ff 75 08             	pushl  0x8(%ebp)
  80164d:	e8 46 ff ff ff       	call   801598 <open>
  801652:	89 c7                	mov    %eax,%edi
  801654:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	85 c0                	test   %eax,%eax
  80165f:	0f 88 81 04 00 00    	js     801ae6 <spawn+0x4aa>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	68 00 02 00 00       	push   $0x200
  80166d:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801673:	50                   	push   %eax
  801674:	57                   	push   %edi
  801675:	e8 18 fb ff ff       	call   801192 <readn>
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	3d 00 02 00 00       	cmp    $0x200,%eax
  801682:	75 0c                	jne    801690 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801684:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80168b:	45 4c 46 
  80168e:	74 33                	je     8016c3 <spawn+0x87>
		close(fd);
  801690:	83 ec 0c             	sub    $0xc,%esp
  801693:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801699:	e8 27 f9 ff ff       	call   800fc5 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80169e:	83 c4 0c             	add    $0xc,%esp
  8016a1:	68 7f 45 4c 46       	push   $0x464c457f
  8016a6:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8016ac:	68 0f 2e 80 00       	push   $0x802e0f
  8016b1:	e8 b7 eb ff ff       	call   80026d <cprintf>
		return -E_NOT_EXEC;
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8016be:	e9 c6 04 00 00       	jmp    801b89 <spawn+0x54d>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8016c3:	b8 07 00 00 00       	mov    $0x7,%eax
  8016c8:	cd 30                	int    $0x30
  8016ca:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8016d0:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	0f 88 13 04 00 00    	js     801af1 <spawn+0x4b5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8016de:	89 c6                	mov    %eax,%esi
  8016e0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016e6:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016e9:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016ef:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016f5:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016fc:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801702:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801708:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80170d:	be 00 00 00 00       	mov    $0x0,%esi
  801712:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801715:	eb 13                	jmp    80172a <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801717:	83 ec 0c             	sub    $0xc,%esp
  80171a:	50                   	push   %eax
  80171b:	e8 b9 f0 ff ff       	call   8007d9 <strlen>
  801720:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801724:	83 c3 01             	add    $0x1,%ebx
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801731:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801734:	85 c0                	test   %eax,%eax
  801736:	75 df                	jne    801717 <spawn+0xdb>
  801738:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80173e:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801744:	bf 00 10 40 00       	mov    $0x401000,%edi
  801749:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80174b:	89 fa                	mov    %edi,%edx
  80174d:	83 e2 fc             	and    $0xfffffffc,%edx
  801750:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801757:	29 c2                	sub    %eax,%edx
  801759:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80175f:	8d 42 f8             	lea    -0x8(%edx),%eax
  801762:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801767:	0f 86 9a 03 00 00    	jbe    801b07 <spawn+0x4cb>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	6a 07                	push   $0x7
  801772:	68 00 00 40 00       	push   $0x400000
  801777:	6a 00                	push   $0x0
  801779:	e8 97 f4 ff ff       	call   800c15 <sys_page_alloc>
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	85 c0                	test   %eax,%eax
  801783:	0f 88 85 03 00 00    	js     801b0e <spawn+0x4d2>
  801789:	be 00 00 00 00       	mov    $0x0,%esi
  80178e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801794:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801797:	eb 30                	jmp    8017c9 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801799:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80179f:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8017a5:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8017a8:	83 ec 08             	sub    $0x8,%esp
  8017ab:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ae:	57                   	push   %edi
  8017af:	e8 5e f0 ff ff       	call   800812 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8017b4:	83 c4 04             	add    $0x4,%esp
  8017b7:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8017ba:	e8 1a f0 ff ff       	call   8007d9 <strlen>
  8017bf:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8017c3:	83 c6 01             	add    $0x1,%esi
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  8017cf:	7f c8                	jg     801799 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  8017d1:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8017d7:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  8017dd:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8017e4:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017ea:	74 19                	je     801805 <spawn+0x1c9>
  8017ec:	68 9c 2e 80 00       	push   $0x802e9c
  8017f1:	68 e3 2d 80 00       	push   $0x802de3
  8017f6:	68 f1 00 00 00       	push   $0xf1
  8017fb:	68 29 2e 80 00       	push   $0x802e29
  801800:	e8 8f e9 ff ff       	call   800194 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801805:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80180b:	89 f8                	mov    %edi,%eax
  80180d:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801812:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801815:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80181b:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80181e:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801824:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80182a:	83 ec 0c             	sub    $0xc,%esp
  80182d:	6a 07                	push   $0x7
  80182f:	68 00 d0 bf ee       	push   $0xeebfd000
  801834:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80183a:	68 00 00 40 00       	push   $0x400000
  80183f:	6a 00                	push   $0x0
  801841:	e8 12 f4 ff ff       	call   800c58 <sys_page_map>
  801846:	89 c3                	mov    %eax,%ebx
  801848:	83 c4 20             	add    $0x20,%esp
  80184b:	85 c0                	test   %eax,%eax
  80184d:	0f 88 24 03 00 00    	js     801b77 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	68 00 00 40 00       	push   $0x400000
  80185b:	6a 00                	push   $0x0
  80185d:	e8 38 f4 ff ff       	call   800c9a <sys_page_unmap>
  801862:	89 c3                	mov    %eax,%ebx
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 88 08 03 00 00    	js     801b77 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80186f:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801875:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80187c:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801882:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801889:	00 00 00 
  80188c:	e9 8a 01 00 00       	jmp    801a1b <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801891:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801897:	83 38 01             	cmpl   $0x1,(%eax)
  80189a:	0f 85 6d 01 00 00    	jne    801a0d <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8018a0:	89 c7                	mov    %eax,%edi
  8018a2:	8b 40 18             	mov    0x18(%eax),%eax
  8018a5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8018ab:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8018ae:	83 f8 01             	cmp    $0x1,%eax
  8018b1:	19 c0                	sbb    %eax,%eax
  8018b3:	83 e0 fe             	and    $0xfffffffe,%eax
  8018b6:	83 c0 07             	add    $0x7,%eax
  8018b9:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8018bf:	89 f8                	mov    %edi,%eax
  8018c1:	8b 7f 04             	mov    0x4(%edi),%edi
  8018c4:	89 f9                	mov    %edi,%ecx
  8018c6:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  8018cc:	8b 78 10             	mov    0x10(%eax),%edi
  8018cf:	8b 70 14             	mov    0x14(%eax),%esi
  8018d2:	89 f2                	mov    %esi,%edx
  8018d4:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8018da:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  8018dd:	89 f0                	mov    %esi,%eax
  8018df:	25 ff 0f 00 00       	and    $0xfff,%eax
  8018e4:	74 14                	je     8018fa <spawn+0x2be>
		va -= i;
  8018e6:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018e8:	01 c2                	add    %eax,%edx
  8018ea:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018f0:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018f2:	29 c1                	sub    %eax,%ecx
  8018f4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ff:	e9 f7 00 00 00       	jmp    8019fb <spawn+0x3bf>
		if (i >= filesz) {
  801904:	39 df                	cmp    %ebx,%edi
  801906:	77 27                	ja     80192f <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801908:	83 ec 04             	sub    $0x4,%esp
  80190b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801911:	56                   	push   %esi
  801912:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801918:	e8 f8 f2 ff ff       	call   800c15 <sys_page_alloc>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	0f 89 c7 00 00 00    	jns    8019ef <spawn+0x3b3>
  801928:	89 c3                	mov    %eax,%ebx
  80192a:	e9 ed 01 00 00       	jmp    801b1c <spawn+0x4e0>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80192f:	83 ec 04             	sub    $0x4,%esp
  801932:	6a 07                	push   $0x7
  801934:	68 00 00 40 00       	push   $0x400000
  801939:	6a 00                	push   $0x0
  80193b:	e8 d5 f2 ff ff       	call   800c15 <sys_page_alloc>
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	0f 88 c7 01 00 00    	js     801b12 <spawn+0x4d6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80194b:	83 ec 08             	sub    $0x8,%esp
  80194e:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801954:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  80195a:	50                   	push   %eax
  80195b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801961:	e8 01 f9 ff ff       	call   801267 <seek>
  801966:	83 c4 10             	add    $0x10,%esp
  801969:	85 c0                	test   %eax,%eax
  80196b:	0f 88 a5 01 00 00    	js     801b16 <spawn+0x4da>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801971:	83 ec 04             	sub    $0x4,%esp
  801974:	89 f8                	mov    %edi,%eax
  801976:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80197c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801981:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801986:	0f 47 c1             	cmova  %ecx,%eax
  801989:	50                   	push   %eax
  80198a:	68 00 00 40 00       	push   $0x400000
  80198f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801995:	e8 f8 f7 ff ff       	call   801192 <readn>
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	0f 88 75 01 00 00    	js     801b1a <spawn+0x4de>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8019ae:	56                   	push   %esi
  8019af:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8019b5:	68 00 00 40 00       	push   $0x400000
  8019ba:	6a 00                	push   $0x0
  8019bc:	e8 97 f2 ff ff       	call   800c58 <sys_page_map>
  8019c1:	83 c4 20             	add    $0x20,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	79 15                	jns    8019dd <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  8019c8:	50                   	push   %eax
  8019c9:	68 35 2e 80 00       	push   $0x802e35
  8019ce:	68 24 01 00 00       	push   $0x124
  8019d3:	68 29 2e 80 00       	push   $0x802e29
  8019d8:	e8 b7 e7 ff ff       	call   800194 <_panic>
			sys_page_unmap(0, UTEMP);
  8019dd:	83 ec 08             	sub    $0x8,%esp
  8019e0:	68 00 00 40 00       	push   $0x400000
  8019e5:	6a 00                	push   $0x0
  8019e7:	e8 ae f2 ff ff       	call   800c9a <sys_page_unmap>
  8019ec:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019ef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019f5:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019fb:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801a01:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801a07:	0f 87 f7 fe ff ff    	ja     801904 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a0d:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801a14:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801a1b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a22:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801a28:	0f 8c 63 fe ff ff    	jl     801891 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a37:	e8 89 f5 ff ff       	call   800fc5 <close>
  801a3c:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  801a3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a44:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801a4a:	89 d8                	mov    %ebx,%eax
  801a4c:	c1 e0 0c             	shl    $0xc,%eax
		if (((uvpd[PDX(pgnum*PGSIZE)] & PTE_P) && (uvpt[pgnum] & PTE_P) && (uvpt[pgnum] & PTE_SHARE))){
  801a4f:	89 c2                	mov    %eax,%edx
  801a51:	c1 ea 16             	shr    $0x16,%edx
  801a54:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801a5b:	f6 c2 01             	test   $0x1,%dl
  801a5e:	74 35                	je     801a95 <spawn+0x459>
  801a60:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801a67:	f6 c2 01             	test   $0x1,%dl
  801a6a:	74 29                	je     801a95 <spawn+0x459>
  801a6c:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801a73:	f6 c6 04             	test   $0x4,%dh
  801a76:	74 1d                	je     801a95 <spawn+0x459>
			if((r=sys_page_map(0, (void *)(pgnum*PGSIZE), child, (void *)(pgnum*PGSIZE), PTE_SYSCALL))<0)
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	68 07 0e 00 00       	push   $0xe07
  801a80:	50                   	push   %eax
  801a81:	56                   	push   %esi
  801a82:	50                   	push   %eax
  801a83:	6a 00                	push   $0x0
  801a85:	e8 ce f1 ff ff       	call   800c58 <sys_page_map>
  801a8a:	83 c4 20             	add    $0x20,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	0f 88 a8 00 00 00    	js     801b3d <spawn+0x501>
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  801a95:	83 c3 01             	add    $0x1,%ebx
  801a98:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801a9e:	75 aa                	jne    801a4a <spawn+0x40e>
  801aa0:	e9 ad 00 00 00       	jmp    801b52 <spawn+0x516>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801aa5:	50                   	push   %eax
  801aa6:	68 52 2e 80 00       	push   $0x802e52
  801aab:	68 85 00 00 00       	push   $0x85
  801ab0:	68 29 2e 80 00       	push   $0x802e29
  801ab5:	e8 da e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801aba:	83 ec 08             	sub    $0x8,%esp
  801abd:	6a 02                	push   $0x2
  801abf:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ac5:	e8 12 f2 ff ff       	call   800cdc <sys_env_set_status>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	79 2b                	jns    801afc <spawn+0x4c0>
		panic("sys_env_set_status: %e", r);
  801ad1:	50                   	push   %eax
  801ad2:	68 6c 2e 80 00       	push   $0x802e6c
  801ad7:	68 88 00 00 00       	push   $0x88
  801adc:	68 29 2e 80 00       	push   $0x802e29
  801ae1:	e8 ae e6 ff ff       	call   800194 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801ae6:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801aec:	e9 98 00 00 00       	jmp    801b89 <spawn+0x54d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801af1:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801af7:	e9 8d 00 00 00       	jmp    801b89 <spawn+0x54d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801afc:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801b02:	e9 82 00 00 00       	jmp    801b89 <spawn+0x54d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801b07:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801b0c:	eb 7b                	jmp    801b89 <spawn+0x54d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801b0e:	89 c3                	mov    %eax,%ebx
  801b10:	eb 77                	jmp    801b89 <spawn+0x54d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b12:	89 c3                	mov    %eax,%ebx
  801b14:	eb 06                	jmp    801b1c <spawn+0x4e0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b16:	89 c3                	mov    %eax,%ebx
  801b18:	eb 02                	jmp    801b1c <spawn+0x4e0>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801b1a:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801b1c:	83 ec 0c             	sub    $0xc,%esp
  801b1f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b25:	e8 6c f0 ff ff       	call   800b96 <sys_env_destroy>
	close(fd);
  801b2a:	83 c4 04             	add    $0x4,%esp
  801b2d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801b33:	e8 8d f4 ff ff       	call   800fc5 <close>
	return r;
  801b38:	83 c4 10             	add    $0x10,%esp
  801b3b:	eb 4c                	jmp    801b89 <spawn+0x54d>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801b3d:	50                   	push   %eax
  801b3e:	68 83 2e 80 00       	push   $0x802e83
  801b43:	68 82 00 00 00       	push   $0x82
  801b48:	68 29 2e 80 00       	push   $0x802e29
  801b4d:	e8 42 e6 ff ff       	call   800194 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b5b:	50                   	push   %eax
  801b5c:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b62:	e8 b7 f1 ff ff       	call   800d1e <sys_env_set_trapframe>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	85 c0                	test   %eax,%eax
  801b6c:	0f 89 48 ff ff ff    	jns    801aba <spawn+0x47e>
  801b72:	e9 2e ff ff ff       	jmp    801aa5 <spawn+0x469>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b77:	83 ec 08             	sub    $0x8,%esp
  801b7a:	68 00 00 40 00       	push   $0x400000
  801b7f:	6a 00                	push   $0x0
  801b81:	e8 14 f1 ff ff       	call   800c9a <sys_page_unmap>
  801b86:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8e:	5b                   	pop    %ebx
  801b8f:	5e                   	pop    %esi
  801b90:	5f                   	pop    %edi
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b98:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ba0:	eb 03                	jmp    801ba5 <spawnl+0x12>
		argc++;
  801ba2:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ba5:	83 c2 04             	add    $0x4,%edx
  801ba8:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801bac:	75 f4                	jne    801ba2 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bae:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801bb5:	83 e2 f0             	and    $0xfffffff0,%edx
  801bb8:	29 d4                	sub    %edx,%esp
  801bba:	8d 54 24 03          	lea    0x3(%esp),%edx
  801bbe:	c1 ea 02             	shr    $0x2,%edx
  801bc1:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801bc8:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcd:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801bd4:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801bdb:	00 
  801bdc:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
  801be3:	eb 0a                	jmp    801bef <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801be5:	83 c0 01             	add    $0x1,%eax
  801be8:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bec:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bef:	39 d0                	cmp    %edx,%eax
  801bf1:	75 f2                	jne    801be5 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bf3:	83 ec 08             	sub    $0x8,%esp
  801bf6:	56                   	push   %esi
  801bf7:	ff 75 08             	pushl  0x8(%ebp)
  801bfa:	e8 3d fa ff ff       	call   80163c <spawn>
}
  801bff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	56                   	push   %esi
  801c0a:	53                   	push   %ebx
  801c0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c0e:	83 ec 0c             	sub    $0xc,%esp
  801c11:	ff 75 08             	pushl  0x8(%ebp)
  801c14:	e8 1c f2 ff ff       	call   800e35 <fd2data>
  801c19:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c1b:	83 c4 08             	add    $0x8,%esp
  801c1e:	68 c4 2e 80 00       	push   $0x802ec4
  801c23:	53                   	push   %ebx
  801c24:	e8 e9 eb ff ff       	call   800812 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c29:	8b 46 04             	mov    0x4(%esi),%eax
  801c2c:	2b 06                	sub    (%esi),%eax
  801c2e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c34:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c3b:	00 00 00 
	stat->st_dev = &devpipe;
  801c3e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c45:	30 80 00 
	return 0;
}
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
  801c4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c50:	5b                   	pop    %ebx
  801c51:	5e                   	pop    %esi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    

00801c54 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	53                   	push   %ebx
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c5e:	53                   	push   %ebx
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 34 f0 ff ff       	call   800c9a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c66:	89 1c 24             	mov    %ebx,(%esp)
  801c69:	e8 c7 f1 ff ff       	call   800e35 <fd2data>
  801c6e:	83 c4 08             	add    $0x8,%esp
  801c71:	50                   	push   %eax
  801c72:	6a 00                	push   $0x0
  801c74:	e8 21 f0 ff ff       	call   800c9a <sys_page_unmap>
}
  801c79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c8a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c8c:	a1 08 40 80 00       	mov    0x804008,%eax
  801c91:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801c94:	83 ec 0c             	sub    $0xc,%esp
  801c97:	ff 75 e0             	pushl  -0x20(%ebp)
  801c9a:	e8 ab 09 00 00       	call   80264a <pageref>
  801c9f:	89 c3                	mov    %eax,%ebx
  801ca1:	89 3c 24             	mov    %edi,(%esp)
  801ca4:	e8 a1 09 00 00       	call   80264a <pageref>
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	39 c3                	cmp    %eax,%ebx
  801cae:	0f 94 c1             	sete   %cl
  801cb1:	0f b6 c9             	movzbl %cl,%ecx
  801cb4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801cb7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801cbd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cc0:	39 ce                	cmp    %ecx,%esi
  801cc2:	74 1b                	je     801cdf <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801cc4:	39 c3                	cmp    %eax,%ebx
  801cc6:	75 c4                	jne    801c8c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cc8:	8b 42 58             	mov    0x58(%edx),%eax
  801ccb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801cce:	50                   	push   %eax
  801ccf:	56                   	push   %esi
  801cd0:	68 cb 2e 80 00       	push   $0x802ecb
  801cd5:	e8 93 e5 ff ff       	call   80026d <cprintf>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	eb ad                	jmp    801c8c <_pipeisclosed+0xe>
	}
}
  801cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	57                   	push   %edi
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	83 ec 28             	sub    $0x28,%esp
  801cf3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801cf6:	56                   	push   %esi
  801cf7:	e8 39 f1 ff ff       	call   800e35 <fd2data>
  801cfc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	bf 00 00 00 00       	mov    $0x0,%edi
  801d06:	eb 4b                	jmp    801d53 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d08:	89 da                	mov    %ebx,%edx
  801d0a:	89 f0                	mov    %esi,%eax
  801d0c:	e8 6d ff ff ff       	call   801c7e <_pipeisclosed>
  801d11:	85 c0                	test   %eax,%eax
  801d13:	75 48                	jne    801d5d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d15:	e8 dc ee ff ff       	call   800bf6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d1a:	8b 43 04             	mov    0x4(%ebx),%eax
  801d1d:	8b 0b                	mov    (%ebx),%ecx
  801d1f:	8d 51 20             	lea    0x20(%ecx),%edx
  801d22:	39 d0                	cmp    %edx,%eax
  801d24:	73 e2                	jae    801d08 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d29:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d2d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d30:	89 c2                	mov    %eax,%edx
  801d32:	c1 fa 1f             	sar    $0x1f,%edx
  801d35:	89 d1                	mov    %edx,%ecx
  801d37:	c1 e9 1b             	shr    $0x1b,%ecx
  801d3a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d3d:	83 e2 1f             	and    $0x1f,%edx
  801d40:	29 ca                	sub    %ecx,%edx
  801d42:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d46:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d4a:	83 c0 01             	add    $0x1,%eax
  801d4d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d50:	83 c7 01             	add    $0x1,%edi
  801d53:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d56:	75 c2                	jne    801d1a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d58:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5b:	eb 05                	jmp    801d62 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d5d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d65:	5b                   	pop    %ebx
  801d66:	5e                   	pop    %esi
  801d67:	5f                   	pop    %edi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	57                   	push   %edi
  801d6e:	56                   	push   %esi
  801d6f:	53                   	push   %ebx
  801d70:	83 ec 18             	sub    $0x18,%esp
  801d73:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d76:	57                   	push   %edi
  801d77:	e8 b9 f0 ff ff       	call   800e35 <fd2data>
  801d7c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d86:	eb 3d                	jmp    801dc5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d88:	85 db                	test   %ebx,%ebx
  801d8a:	74 04                	je     801d90 <devpipe_read+0x26>
				return i;
  801d8c:	89 d8                	mov    %ebx,%eax
  801d8e:	eb 44                	jmp    801dd4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	89 f8                	mov    %edi,%eax
  801d94:	e8 e5 fe ff ff       	call   801c7e <_pipeisclosed>
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	75 32                	jne    801dcf <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d9d:	e8 54 ee ff ff       	call   800bf6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801da2:	8b 06                	mov    (%esi),%eax
  801da4:	3b 46 04             	cmp    0x4(%esi),%eax
  801da7:	74 df                	je     801d88 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da9:	99                   	cltd   
  801daa:	c1 ea 1b             	shr    $0x1b,%edx
  801dad:	01 d0                	add    %edx,%eax
  801daf:	83 e0 1f             	and    $0x1f,%eax
  801db2:	29 d0                	sub    %edx,%eax
  801db4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dbc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801dbf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dc2:	83 c3 01             	add    $0x1,%ebx
  801dc5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dc8:	75 d8                	jne    801da2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801dca:	8b 45 10             	mov    0x10(%ebp),%eax
  801dcd:	eb 05                	jmp    801dd4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dcf:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801de4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de7:	50                   	push   %eax
  801de8:	e8 5f f0 ff ff       	call   800e4c <fd_alloc>
  801ded:	83 c4 10             	add    $0x10,%esp
  801df0:	89 c2                	mov    %eax,%edx
  801df2:	85 c0                	test   %eax,%eax
  801df4:	0f 88 2c 01 00 00    	js     801f26 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dfa:	83 ec 04             	sub    $0x4,%esp
  801dfd:	68 07 04 00 00       	push   $0x407
  801e02:	ff 75 f4             	pushl  -0xc(%ebp)
  801e05:	6a 00                	push   $0x0
  801e07:	e8 09 ee ff ff       	call   800c15 <sys_page_alloc>
  801e0c:	83 c4 10             	add    $0x10,%esp
  801e0f:	89 c2                	mov    %eax,%edx
  801e11:	85 c0                	test   %eax,%eax
  801e13:	0f 88 0d 01 00 00    	js     801f26 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e1f:	50                   	push   %eax
  801e20:	e8 27 f0 ff ff       	call   800e4c <fd_alloc>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	0f 88 e2 00 00 00    	js     801f14 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e32:	83 ec 04             	sub    $0x4,%esp
  801e35:	68 07 04 00 00       	push   $0x407
  801e3a:	ff 75 f0             	pushl  -0x10(%ebp)
  801e3d:	6a 00                	push   $0x0
  801e3f:	e8 d1 ed ff ff       	call   800c15 <sys_page_alloc>
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	0f 88 c3 00 00 00    	js     801f14 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	ff 75 f4             	pushl  -0xc(%ebp)
  801e57:	e8 d9 ef ff ff       	call   800e35 <fd2data>
  801e5c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e5e:	83 c4 0c             	add    $0xc,%esp
  801e61:	68 07 04 00 00       	push   $0x407
  801e66:	50                   	push   %eax
  801e67:	6a 00                	push   $0x0
  801e69:	e8 a7 ed ff ff       	call   800c15 <sys_page_alloc>
  801e6e:	89 c3                	mov    %eax,%ebx
  801e70:	83 c4 10             	add    $0x10,%esp
  801e73:	85 c0                	test   %eax,%eax
  801e75:	0f 88 89 00 00 00    	js     801f04 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e81:	e8 af ef ff ff       	call   800e35 <fd2data>
  801e86:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e8d:	50                   	push   %eax
  801e8e:	6a 00                	push   $0x0
  801e90:	56                   	push   %esi
  801e91:	6a 00                	push   $0x0
  801e93:	e8 c0 ed ff ff       	call   800c58 <sys_page_map>
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	83 c4 20             	add    $0x20,%esp
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 55                	js     801ef6 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ea1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eaf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801eb6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ec4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ecb:	83 ec 0c             	sub    $0xc,%esp
  801ece:	ff 75 f4             	pushl  -0xc(%ebp)
  801ed1:	e8 4f ef ff ff       	call   800e25 <fd2num>
  801ed6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801edb:	83 c4 04             	add    $0x4,%esp
  801ede:	ff 75 f0             	pushl  -0x10(%ebp)
  801ee1:	e8 3f ef ff ff       	call   800e25 <fd2num>
  801ee6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ee9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef4:	eb 30                	jmp    801f26 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	56                   	push   %esi
  801efa:	6a 00                	push   $0x0
  801efc:	e8 99 ed ff ff       	call   800c9a <sys_page_unmap>
  801f01:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801f04:	83 ec 08             	sub    $0x8,%esp
  801f07:	ff 75 f0             	pushl  -0x10(%ebp)
  801f0a:	6a 00                	push   $0x0
  801f0c:	e8 89 ed ff ff       	call   800c9a <sys_page_unmap>
  801f11:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801f14:	83 ec 08             	sub    $0x8,%esp
  801f17:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1a:	6a 00                	push   $0x0
  801f1c:	e8 79 ed ff ff       	call   800c9a <sys_page_unmap>
  801f21:	83 c4 10             	add    $0x10,%esp
  801f24:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f26:	89 d0                	mov    %edx,%eax
  801f28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2b:	5b                   	pop    %ebx
  801f2c:	5e                   	pop    %esi
  801f2d:	5d                   	pop    %ebp
  801f2e:	c3                   	ret    

00801f2f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f38:	50                   	push   %eax
  801f39:	ff 75 08             	pushl  0x8(%ebp)
  801f3c:	e8 5a ef ff ff       	call   800e9b <fd_lookup>
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 18                	js     801f60 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f48:	83 ec 0c             	sub    $0xc,%esp
  801f4b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4e:	e8 e2 ee ff ff       	call   800e35 <fd2data>
	return _pipeisclosed(fd, p);
  801f53:	89 c2                	mov    %eax,%edx
  801f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f58:	e8 21 fd ff ff       	call   801c7e <_pipeisclosed>
  801f5d:	83 c4 10             	add    $0x10,%esp
}
  801f60:	c9                   	leave  
  801f61:	c3                   	ret    

00801f62 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801f68:	68 e3 2e 80 00       	push   $0x802ee3
  801f6d:	ff 75 0c             	pushl  0xc(%ebp)
  801f70:	e8 9d e8 ff ff       	call   800812 <strcpy>
	return 0;
}
  801f75:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	53                   	push   %ebx
  801f80:	83 ec 10             	sub    $0x10,%esp
  801f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f86:	53                   	push   %ebx
  801f87:	e8 be 06 00 00       	call   80264a <pageref>
  801f8c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801f8f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801f94:	83 f8 01             	cmp    $0x1,%eax
  801f97:	75 10                	jne    801fa9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801f99:	83 ec 0c             	sub    $0xc,%esp
  801f9c:	ff 73 0c             	pushl  0xc(%ebx)
  801f9f:	e8 c0 02 00 00       	call   802264 <nsipc_close>
  801fa4:	89 c2                	mov    %eax,%edx
  801fa6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801fa9:	89 d0                	mov    %edx,%eax
  801fab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fb6:	6a 00                	push   $0x0
  801fb8:	ff 75 10             	pushl  0x10(%ebp)
  801fbb:	ff 75 0c             	pushl  0xc(%ebp)
  801fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc1:	ff 70 0c             	pushl  0xc(%eax)
  801fc4:	e8 78 03 00 00       	call   802341 <nsipc_send>
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801fd1:	6a 00                	push   $0x0
  801fd3:	ff 75 10             	pushl  0x10(%ebp)
  801fd6:	ff 75 0c             	pushl  0xc(%ebp)
  801fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdc:	ff 70 0c             	pushl  0xc(%eax)
  801fdf:	e8 f1 02 00 00       	call   8022d5 <nsipc_recv>
}
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801fec:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801fef:	52                   	push   %edx
  801ff0:	50                   	push   %eax
  801ff1:	e8 a5 ee ff ff       	call   800e9b <fd_lookup>
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	78 17                	js     802014 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802000:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  802006:	39 08                	cmp    %ecx,(%eax)
  802008:	75 05                	jne    80200f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80200a:	8b 40 0c             	mov    0xc(%eax),%eax
  80200d:	eb 05                	jmp    802014 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80200f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	56                   	push   %esi
  80201a:	53                   	push   %ebx
  80201b:	83 ec 1c             	sub    $0x1c,%esp
  80201e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802020:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802023:	50                   	push   %eax
  802024:	e8 23 ee ff ff       	call   800e4c <fd_alloc>
  802029:	89 c3                	mov    %eax,%ebx
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 1b                	js     80204d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802032:	83 ec 04             	sub    $0x4,%esp
  802035:	68 07 04 00 00       	push   $0x407
  80203a:	ff 75 f4             	pushl  -0xc(%ebp)
  80203d:	6a 00                	push   $0x0
  80203f:	e8 d1 eb ff ff       	call   800c15 <sys_page_alloc>
  802044:	89 c3                	mov    %eax,%ebx
  802046:	83 c4 10             	add    $0x10,%esp
  802049:	85 c0                	test   %eax,%eax
  80204b:	79 10                	jns    80205d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80204d:	83 ec 0c             	sub    $0xc,%esp
  802050:	56                   	push   %esi
  802051:	e8 0e 02 00 00       	call   802264 <nsipc_close>
		return r;
  802056:	83 c4 10             	add    $0x10,%esp
  802059:	89 d8                	mov    %ebx,%eax
  80205b:	eb 24                	jmp    802081 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80205d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802063:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802066:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802072:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802075:	83 ec 0c             	sub    $0xc,%esp
  802078:	50                   	push   %eax
  802079:	e8 a7 ed ff ff       	call   800e25 <fd2num>
  80207e:	83 c4 10             	add    $0x10,%esp
}
  802081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    

00802088 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802088:	55                   	push   %ebp
  802089:	89 e5                	mov    %esp,%ebp
  80208b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80208e:	8b 45 08             	mov    0x8(%ebp),%eax
  802091:	e8 50 ff ff ff       	call   801fe6 <fd2sockid>
		return r;
  802096:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802098:	85 c0                	test   %eax,%eax
  80209a:	78 1f                	js     8020bb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80209c:	83 ec 04             	sub    $0x4,%esp
  80209f:	ff 75 10             	pushl  0x10(%ebp)
  8020a2:	ff 75 0c             	pushl  0xc(%ebp)
  8020a5:	50                   	push   %eax
  8020a6:	e8 12 01 00 00       	call   8021bd <nsipc_accept>
  8020ab:	83 c4 10             	add    $0x10,%esp
		return r;
  8020ae:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	78 07                	js     8020bb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8020b4:	e8 5d ff ff ff       	call   802016 <alloc_sockfd>
  8020b9:	89 c1                	mov    %eax,%ecx
}
  8020bb:	89 c8                	mov    %ecx,%eax
  8020bd:	c9                   	leave  
  8020be:	c3                   	ret    

008020bf <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c8:	e8 19 ff ff ff       	call   801fe6 <fd2sockid>
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 12                	js     8020e3 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8020d1:	83 ec 04             	sub    $0x4,%esp
  8020d4:	ff 75 10             	pushl  0x10(%ebp)
  8020d7:	ff 75 0c             	pushl  0xc(%ebp)
  8020da:	50                   	push   %eax
  8020db:	e8 2d 01 00 00       	call   80220d <nsipc_bind>
  8020e0:	83 c4 10             	add    $0x10,%esp
}
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <shutdown>:

int
shutdown(int s, int how)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ee:	e8 f3 fe ff ff       	call   801fe6 <fd2sockid>
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	78 0f                	js     802106 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020f7:	83 ec 08             	sub    $0x8,%esp
  8020fa:	ff 75 0c             	pushl  0xc(%ebp)
  8020fd:	50                   	push   %eax
  8020fe:	e8 3f 01 00 00       	call   802242 <nsipc_shutdown>
  802103:	83 c4 10             	add    $0x10,%esp
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	e8 d0 fe ff ff       	call   801fe6 <fd2sockid>
  802116:	85 c0                	test   %eax,%eax
  802118:	78 12                	js     80212c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80211a:	83 ec 04             	sub    $0x4,%esp
  80211d:	ff 75 10             	pushl  0x10(%ebp)
  802120:	ff 75 0c             	pushl  0xc(%ebp)
  802123:	50                   	push   %eax
  802124:	e8 55 01 00 00       	call   80227e <nsipc_connect>
  802129:	83 c4 10             	add    $0x10,%esp
}
  80212c:	c9                   	leave  
  80212d:	c3                   	ret    

0080212e <listen>:

int
listen(int s, int backlog)
{
  80212e:	55                   	push   %ebp
  80212f:	89 e5                	mov    %esp,%ebp
  802131:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802134:	8b 45 08             	mov    0x8(%ebp),%eax
  802137:	e8 aa fe ff ff       	call   801fe6 <fd2sockid>
  80213c:	85 c0                	test   %eax,%eax
  80213e:	78 0f                	js     80214f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802140:	83 ec 08             	sub    $0x8,%esp
  802143:	ff 75 0c             	pushl  0xc(%ebp)
  802146:	50                   	push   %eax
  802147:	e8 67 01 00 00       	call   8022b3 <nsipc_listen>
  80214c:	83 c4 10             	add    $0x10,%esp
}
  80214f:	c9                   	leave  
  802150:	c3                   	ret    

00802151 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802157:	ff 75 10             	pushl  0x10(%ebp)
  80215a:	ff 75 0c             	pushl  0xc(%ebp)
  80215d:	ff 75 08             	pushl  0x8(%ebp)
  802160:	e8 3a 02 00 00       	call   80239f <nsipc_socket>
  802165:	83 c4 10             	add    $0x10,%esp
  802168:	85 c0                	test   %eax,%eax
  80216a:	78 05                	js     802171 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80216c:	e8 a5 fe ff ff       	call   802016 <alloc_sockfd>
}
  802171:	c9                   	leave  
  802172:	c3                   	ret    

00802173 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802173:	55                   	push   %ebp
  802174:	89 e5                	mov    %esp,%ebp
  802176:	53                   	push   %ebx
  802177:	83 ec 04             	sub    $0x4,%esp
  80217a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80217c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802183:	75 12                	jne    802197 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802185:	83 ec 0c             	sub    $0xc,%esp
  802188:	6a 02                	push   $0x2
  80218a:	e8 82 04 00 00       	call   802611 <ipc_find_env>
  80218f:	a3 04 40 80 00       	mov    %eax,0x804004
  802194:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802197:	6a 07                	push   $0x7
  802199:	68 00 60 80 00       	push   $0x806000
  80219e:	53                   	push   %ebx
  80219f:	ff 35 04 40 80 00    	pushl  0x804004
  8021a5:	e8 18 04 00 00       	call   8025c2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8021aa:	83 c4 0c             	add    $0xc,%esp
  8021ad:	6a 00                	push   $0x0
  8021af:	6a 00                	push   $0x0
  8021b1:	6a 00                	push   $0x0
  8021b3:	e8 94 03 00 00       	call   80254c <ipc_recv>
}
  8021b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    

008021bd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	56                   	push   %esi
  8021c1:	53                   	push   %ebx
  8021c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021cd:	8b 06                	mov    (%esi),%eax
  8021cf:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d9:	e8 95 ff ff ff       	call   802173 <nsipc>
  8021de:	89 c3                	mov    %eax,%ebx
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	78 20                	js     802204 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021e4:	83 ec 04             	sub    $0x4,%esp
  8021e7:	ff 35 10 60 80 00    	pushl  0x806010
  8021ed:	68 00 60 80 00       	push   $0x806000
  8021f2:	ff 75 0c             	pushl  0xc(%ebp)
  8021f5:	e8 aa e7 ff ff       	call   8009a4 <memmove>
		*addrlen = ret->ret_addrlen;
  8021fa:	a1 10 60 80 00       	mov    0x806010,%eax
  8021ff:	89 06                	mov    %eax,(%esi)
  802201:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802204:	89 d8                	mov    %ebx,%eax
  802206:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802209:	5b                   	pop    %ebx
  80220a:	5e                   	pop    %esi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    

0080220d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	53                   	push   %ebx
  802211:	83 ec 08             	sub    $0x8,%esp
  802214:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802217:	8b 45 08             	mov    0x8(%ebp),%eax
  80221a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80221f:	53                   	push   %ebx
  802220:	ff 75 0c             	pushl  0xc(%ebp)
  802223:	68 04 60 80 00       	push   $0x806004
  802228:	e8 77 e7 ff ff       	call   8009a4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80222d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  802233:	b8 02 00 00 00       	mov    $0x2,%eax
  802238:	e8 36 ff ff ff       	call   802173 <nsipc>
}
  80223d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802240:	c9                   	leave  
  802241:	c3                   	ret    

00802242 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802248:	8b 45 08             	mov    0x8(%ebp),%eax
  80224b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802250:	8b 45 0c             	mov    0xc(%ebp),%eax
  802253:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802258:	b8 03 00 00 00       	mov    $0x3,%eax
  80225d:	e8 11 ff ff ff       	call   802173 <nsipc>
}
  802262:	c9                   	leave  
  802263:	c3                   	ret    

00802264 <nsipc_close>:

int
nsipc_close(int s)
{
  802264:	55                   	push   %ebp
  802265:	89 e5                	mov    %esp,%ebp
  802267:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80226a:	8b 45 08             	mov    0x8(%ebp),%eax
  80226d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802272:	b8 04 00 00 00       	mov    $0x4,%eax
  802277:	e8 f7 fe ff ff       	call   802173 <nsipc>
}
  80227c:	c9                   	leave  
  80227d:	c3                   	ret    

0080227e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80227e:	55                   	push   %ebp
  80227f:	89 e5                	mov    %esp,%ebp
  802281:	53                   	push   %ebx
  802282:	83 ec 08             	sub    $0x8,%esp
  802285:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802288:	8b 45 08             	mov    0x8(%ebp),%eax
  80228b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802290:	53                   	push   %ebx
  802291:	ff 75 0c             	pushl  0xc(%ebp)
  802294:	68 04 60 80 00       	push   $0x806004
  802299:	e8 06 e7 ff ff       	call   8009a4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80229e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8022a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8022a9:	e8 c5 fe ff ff       	call   802173 <nsipc>
}
  8022ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022b1:	c9                   	leave  
  8022b2:	c3                   	ret    

008022b3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8022c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8022c9:	b8 06 00 00 00       	mov    $0x6,%eax
  8022ce:	e8 a0 fe ff ff       	call   802173 <nsipc>
}
  8022d3:	c9                   	leave  
  8022d4:	c3                   	ret    

008022d5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	56                   	push   %esi
  8022d9:	53                   	push   %ebx
  8022da:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8022e5:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8022eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8022ee:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022f3:	b8 07 00 00 00       	mov    $0x7,%eax
  8022f8:	e8 76 fe ff ff       	call   802173 <nsipc>
  8022fd:	89 c3                	mov    %eax,%ebx
  8022ff:	85 c0                	test   %eax,%eax
  802301:	78 35                	js     802338 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802303:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802308:	7f 04                	jg     80230e <nsipc_recv+0x39>
  80230a:	39 c6                	cmp    %eax,%esi
  80230c:	7d 16                	jge    802324 <nsipc_recv+0x4f>
  80230e:	68 ef 2e 80 00       	push   $0x802eef
  802313:	68 e3 2d 80 00       	push   $0x802de3
  802318:	6a 62                	push   $0x62
  80231a:	68 04 2f 80 00       	push   $0x802f04
  80231f:	e8 70 de ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802324:	83 ec 04             	sub    $0x4,%esp
  802327:	50                   	push   %eax
  802328:	68 00 60 80 00       	push   $0x806000
  80232d:	ff 75 0c             	pushl  0xc(%ebp)
  802330:	e8 6f e6 ff ff       	call   8009a4 <memmove>
  802335:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802338:	89 d8                	mov    %ebx,%eax
  80233a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	53                   	push   %ebx
  802345:	83 ec 04             	sub    $0x4,%esp
  802348:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80234b:	8b 45 08             	mov    0x8(%ebp),%eax
  80234e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802353:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802359:	7e 16                	jle    802371 <nsipc_send+0x30>
  80235b:	68 10 2f 80 00       	push   $0x802f10
  802360:	68 e3 2d 80 00       	push   $0x802de3
  802365:	6a 6d                	push   $0x6d
  802367:	68 04 2f 80 00       	push   $0x802f04
  80236c:	e8 23 de ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802371:	83 ec 04             	sub    $0x4,%esp
  802374:	53                   	push   %ebx
  802375:	ff 75 0c             	pushl  0xc(%ebp)
  802378:	68 0c 60 80 00       	push   $0x80600c
  80237d:	e8 22 e6 ff ff       	call   8009a4 <memmove>
	nsipcbuf.send.req_size = size;
  802382:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802388:	8b 45 14             	mov    0x14(%ebp),%eax
  80238b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802390:	b8 08 00 00 00       	mov    $0x8,%eax
  802395:	e8 d9 fd ff ff       	call   802173 <nsipc>
}
  80239a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80239d:	c9                   	leave  
  80239e:	c3                   	ret    

0080239f <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80239f:	55                   	push   %ebp
  8023a0:	89 e5                	mov    %esp,%ebp
  8023a2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8023ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8023b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8023b8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8023bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8023c2:	e8 ac fd ff ff       	call   802173 <nsipc>
}
  8023c7:	c9                   	leave  
  8023c8:	c3                   	ret    

008023c9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023c9:	55                   	push   %ebp
  8023ca:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    

008023d3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023d3:	55                   	push   %ebp
  8023d4:	89 e5                	mov    %esp,%ebp
  8023d6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023d9:	68 1c 2f 80 00       	push   $0x802f1c
  8023de:	ff 75 0c             	pushl  0xc(%ebp)
  8023e1:	e8 2c e4 ff ff       	call   800812 <strcpy>
	return 0;
}
  8023e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8023eb:	c9                   	leave  
  8023ec:	c3                   	ret    

008023ed <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023ed:	55                   	push   %ebp
  8023ee:	89 e5                	mov    %esp,%ebp
  8023f0:	57                   	push   %edi
  8023f1:	56                   	push   %esi
  8023f2:	53                   	push   %ebx
  8023f3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023f9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023fe:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802404:	eb 2d                	jmp    802433 <devcons_write+0x46>
		m = n - tot;
  802406:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802409:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80240b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80240e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802413:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802416:	83 ec 04             	sub    $0x4,%esp
  802419:	53                   	push   %ebx
  80241a:	03 45 0c             	add    0xc(%ebp),%eax
  80241d:	50                   	push   %eax
  80241e:	57                   	push   %edi
  80241f:	e8 80 e5 ff ff       	call   8009a4 <memmove>
		sys_cputs(buf, m);
  802424:	83 c4 08             	add    $0x8,%esp
  802427:	53                   	push   %ebx
  802428:	57                   	push   %edi
  802429:	e8 2b e7 ff ff       	call   800b59 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80242e:	01 de                	add    %ebx,%esi
  802430:	83 c4 10             	add    $0x10,%esp
  802433:	89 f0                	mov    %esi,%eax
  802435:	3b 75 10             	cmp    0x10(%ebp),%esi
  802438:	72 cc                	jb     802406 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80243a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5e                   	pop    %esi
  80243f:	5f                   	pop    %edi
  802440:	5d                   	pop    %ebp
  802441:	c3                   	ret    

00802442 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802442:	55                   	push   %ebp
  802443:	89 e5                	mov    %esp,%ebp
  802445:	83 ec 08             	sub    $0x8,%esp
  802448:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80244d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802451:	74 2a                	je     80247d <devcons_read+0x3b>
  802453:	eb 05                	jmp    80245a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802455:	e8 9c e7 ff ff       	call   800bf6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80245a:	e8 18 e7 ff ff       	call   800b77 <sys_cgetc>
  80245f:	85 c0                	test   %eax,%eax
  802461:	74 f2                	je     802455 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802463:	85 c0                	test   %eax,%eax
  802465:	78 16                	js     80247d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802467:	83 f8 04             	cmp    $0x4,%eax
  80246a:	74 0c                	je     802478 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80246c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80246f:	88 02                	mov    %al,(%edx)
	return 1;
  802471:	b8 01 00 00 00       	mov    $0x1,%eax
  802476:	eb 05                	jmp    80247d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802478:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80247d:	c9                   	leave  
  80247e:	c3                   	ret    

0080247f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80247f:	55                   	push   %ebp
  802480:	89 e5                	mov    %esp,%ebp
  802482:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802485:	8b 45 08             	mov    0x8(%ebp),%eax
  802488:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80248b:	6a 01                	push   $0x1
  80248d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802490:	50                   	push   %eax
  802491:	e8 c3 e6 ff ff       	call   800b59 <sys_cputs>
}
  802496:	83 c4 10             	add    $0x10,%esp
  802499:	c9                   	leave  
  80249a:	c3                   	ret    

0080249b <getchar>:

int
getchar(void)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024a1:	6a 01                	push   $0x1
  8024a3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024a6:	50                   	push   %eax
  8024a7:	6a 00                	push   $0x0
  8024a9:	e8 53 ec ff ff       	call   801101 <read>
	if (r < 0)
  8024ae:	83 c4 10             	add    $0x10,%esp
  8024b1:	85 c0                	test   %eax,%eax
  8024b3:	78 0f                	js     8024c4 <getchar+0x29>
		return r;
	if (r < 1)
  8024b5:	85 c0                	test   %eax,%eax
  8024b7:	7e 06                	jle    8024bf <getchar+0x24>
		return -E_EOF;
	return c;
  8024b9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024bd:	eb 05                	jmp    8024c4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024bf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024c4:	c9                   	leave  
  8024c5:	c3                   	ret    

008024c6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024cf:	50                   	push   %eax
  8024d0:	ff 75 08             	pushl  0x8(%ebp)
  8024d3:	e8 c3 e9 ff ff       	call   800e9b <fd_lookup>
  8024d8:	83 c4 10             	add    $0x10,%esp
  8024db:	85 c0                	test   %eax,%eax
  8024dd:	78 11                	js     8024f0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024e8:	39 10                	cmp    %edx,(%eax)
  8024ea:	0f 94 c0             	sete   %al
  8024ed:	0f b6 c0             	movzbl %al,%eax
}
  8024f0:	c9                   	leave  
  8024f1:	c3                   	ret    

008024f2 <opencons>:

int
opencons(void)
{
  8024f2:	55                   	push   %ebp
  8024f3:	89 e5                	mov    %esp,%ebp
  8024f5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024fb:	50                   	push   %eax
  8024fc:	e8 4b e9 ff ff       	call   800e4c <fd_alloc>
  802501:	83 c4 10             	add    $0x10,%esp
		return r;
  802504:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802506:	85 c0                	test   %eax,%eax
  802508:	78 3e                	js     802548 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80250a:	83 ec 04             	sub    $0x4,%esp
  80250d:	68 07 04 00 00       	push   $0x407
  802512:	ff 75 f4             	pushl  -0xc(%ebp)
  802515:	6a 00                	push   $0x0
  802517:	e8 f9 e6 ff ff       	call   800c15 <sys_page_alloc>
  80251c:	83 c4 10             	add    $0x10,%esp
		return r;
  80251f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802521:	85 c0                	test   %eax,%eax
  802523:	78 23                	js     802548 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802525:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80252b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80252e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802530:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802533:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80253a:	83 ec 0c             	sub    $0xc,%esp
  80253d:	50                   	push   %eax
  80253e:	e8 e2 e8 ff ff       	call   800e25 <fd2num>
  802543:	89 c2                	mov    %eax,%edx
  802545:	83 c4 10             	add    $0x10,%esp
}
  802548:	89 d0                	mov    %edx,%eax
  80254a:	c9                   	leave  
  80254b:	c3                   	ret    

0080254c <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80254c:	55                   	push   %ebp
  80254d:	89 e5                	mov    %esp,%ebp
  80254f:	56                   	push   %esi
  802550:	53                   	push   %ebx
  802551:	8b 75 08             	mov    0x8(%ebp),%esi
  802554:	8b 45 0c             	mov    0xc(%ebp),%eax
  802557:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  80255a:	85 c0                	test   %eax,%eax
  80255c:	74 0e                	je     80256c <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  80255e:	83 ec 0c             	sub    $0xc,%esp
  802561:	50                   	push   %eax
  802562:	e8 5e e8 ff ff       	call   800dc5 <sys_ipc_recv>
  802567:	83 c4 10             	add    $0x10,%esp
  80256a:	eb 10                	jmp    80257c <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  80256c:	83 ec 0c             	sub    $0xc,%esp
  80256f:	68 00 00 c0 ee       	push   $0xeec00000
  802574:	e8 4c e8 ff ff       	call   800dc5 <sys_ipc_recv>
  802579:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  80257c:	85 c0                	test   %eax,%eax
  80257e:	79 17                	jns    802597 <ipc_recv+0x4b>
		if(*from_env_store)
  802580:	83 3e 00             	cmpl   $0x0,(%esi)
  802583:	74 06                	je     80258b <ipc_recv+0x3f>
			*from_env_store = 0;
  802585:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  80258b:	85 db                	test   %ebx,%ebx
  80258d:	74 2c                	je     8025bb <ipc_recv+0x6f>
			*perm_store = 0;
  80258f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802595:	eb 24                	jmp    8025bb <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802597:	85 f6                	test   %esi,%esi
  802599:	74 0a                	je     8025a5 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  80259b:	a1 08 40 80 00       	mov    0x804008,%eax
  8025a0:	8b 40 74             	mov    0x74(%eax),%eax
  8025a3:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8025a5:	85 db                	test   %ebx,%ebx
  8025a7:	74 0a                	je     8025b3 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8025a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8025ae:	8b 40 78             	mov    0x78(%eax),%eax
  8025b1:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8025b3:	a1 08 40 80 00       	mov    0x804008,%eax
  8025b8:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025be:	5b                   	pop    %ebx
  8025bf:	5e                   	pop    %esi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    

008025c2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025c2:	55                   	push   %ebp
  8025c3:	89 e5                	mov    %esp,%ebp
  8025c5:	57                   	push   %edi
  8025c6:	56                   	push   %esi
  8025c7:	53                   	push   %ebx
  8025c8:	83 ec 0c             	sub    $0xc,%esp
  8025cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8025d4:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8025d6:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8025db:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  8025de:	e8 13 e6 ff ff       	call   800bf6 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  8025e3:	ff 75 14             	pushl  0x14(%ebp)
  8025e6:	53                   	push   %ebx
  8025e7:	56                   	push   %esi
  8025e8:	57                   	push   %edi
  8025e9:	e8 b4 e7 ff ff       	call   800da2 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8025ee:	89 c2                	mov    %eax,%edx
  8025f0:	f7 d2                	not    %edx
  8025f2:	c1 ea 1f             	shr    $0x1f,%edx
  8025f5:	83 c4 10             	add    $0x10,%esp
  8025f8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025fb:	0f 94 c1             	sete   %cl
  8025fe:	09 ca                	or     %ecx,%edx
  802600:	85 c0                	test   %eax,%eax
  802602:	0f 94 c0             	sete   %al
  802605:	38 c2                	cmp    %al,%dl
  802607:	77 d5                	ja     8025de <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802609:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80260c:	5b                   	pop    %ebx
  80260d:	5e                   	pop    %esi
  80260e:	5f                   	pop    %edi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    

00802611 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802611:	55                   	push   %ebp
  802612:	89 e5                	mov    %esp,%ebp
  802614:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802617:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80261c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80261f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802625:	8b 52 50             	mov    0x50(%edx),%edx
  802628:	39 ca                	cmp    %ecx,%edx
  80262a:	75 0d                	jne    802639 <ipc_find_env+0x28>
			return envs[i].env_id;
  80262c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80262f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802634:	8b 40 48             	mov    0x48(%eax),%eax
  802637:	eb 0f                	jmp    802648 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802639:	83 c0 01             	add    $0x1,%eax
  80263c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802641:	75 d9                	jne    80261c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802643:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802648:	5d                   	pop    %ebp
  802649:	c3                   	ret    

0080264a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80264a:	55                   	push   %ebp
  80264b:	89 e5                	mov    %esp,%ebp
  80264d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802650:	89 d0                	mov    %edx,%eax
  802652:	c1 e8 16             	shr    $0x16,%eax
  802655:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80265c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802661:	f6 c1 01             	test   $0x1,%cl
  802664:	74 1d                	je     802683 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802666:	c1 ea 0c             	shr    $0xc,%edx
  802669:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802670:	f6 c2 01             	test   $0x1,%dl
  802673:	74 0e                	je     802683 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802675:	c1 ea 0c             	shr    $0xc,%edx
  802678:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80267f:	ef 
  802680:	0f b7 c0             	movzwl %ax,%eax
}
  802683:	5d                   	pop    %ebp
  802684:	c3                   	ret    
  802685:	66 90                	xchg   %ax,%ax
  802687:	66 90                	xchg   %ax,%ax
  802689:	66 90                	xchg   %ax,%ax
  80268b:	66 90                	xchg   %ax,%ax
  80268d:	66 90                	xchg   %ax,%ax
  80268f:	90                   	nop

00802690 <__udivdi3>:
  802690:	55                   	push   %ebp
  802691:	57                   	push   %edi
  802692:	56                   	push   %esi
  802693:	53                   	push   %ebx
  802694:	83 ec 1c             	sub    $0x1c,%esp
  802697:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80269b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80269f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026a7:	85 f6                	test   %esi,%esi
  8026a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026ad:	89 ca                	mov    %ecx,%edx
  8026af:	89 f8                	mov    %edi,%eax
  8026b1:	75 3d                	jne    8026f0 <__udivdi3+0x60>
  8026b3:	39 cf                	cmp    %ecx,%edi
  8026b5:	0f 87 c5 00 00 00    	ja     802780 <__udivdi3+0xf0>
  8026bb:	85 ff                	test   %edi,%edi
  8026bd:	89 fd                	mov    %edi,%ebp
  8026bf:	75 0b                	jne    8026cc <__udivdi3+0x3c>
  8026c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026c6:	31 d2                	xor    %edx,%edx
  8026c8:	f7 f7                	div    %edi
  8026ca:	89 c5                	mov    %eax,%ebp
  8026cc:	89 c8                	mov    %ecx,%eax
  8026ce:	31 d2                	xor    %edx,%edx
  8026d0:	f7 f5                	div    %ebp
  8026d2:	89 c1                	mov    %eax,%ecx
  8026d4:	89 d8                	mov    %ebx,%eax
  8026d6:	89 cf                	mov    %ecx,%edi
  8026d8:	f7 f5                	div    %ebp
  8026da:	89 c3                	mov    %eax,%ebx
  8026dc:	89 d8                	mov    %ebx,%eax
  8026de:	89 fa                	mov    %edi,%edx
  8026e0:	83 c4 1c             	add    $0x1c,%esp
  8026e3:	5b                   	pop    %ebx
  8026e4:	5e                   	pop    %esi
  8026e5:	5f                   	pop    %edi
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    
  8026e8:	90                   	nop
  8026e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026f0:	39 ce                	cmp    %ecx,%esi
  8026f2:	77 74                	ja     802768 <__udivdi3+0xd8>
  8026f4:	0f bd fe             	bsr    %esi,%edi
  8026f7:	83 f7 1f             	xor    $0x1f,%edi
  8026fa:	0f 84 98 00 00 00    	je     802798 <__udivdi3+0x108>
  802700:	bb 20 00 00 00       	mov    $0x20,%ebx
  802705:	89 f9                	mov    %edi,%ecx
  802707:	89 c5                	mov    %eax,%ebp
  802709:	29 fb                	sub    %edi,%ebx
  80270b:	d3 e6                	shl    %cl,%esi
  80270d:	89 d9                	mov    %ebx,%ecx
  80270f:	d3 ed                	shr    %cl,%ebp
  802711:	89 f9                	mov    %edi,%ecx
  802713:	d3 e0                	shl    %cl,%eax
  802715:	09 ee                	or     %ebp,%esi
  802717:	89 d9                	mov    %ebx,%ecx
  802719:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80271d:	89 d5                	mov    %edx,%ebp
  80271f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802723:	d3 ed                	shr    %cl,%ebp
  802725:	89 f9                	mov    %edi,%ecx
  802727:	d3 e2                	shl    %cl,%edx
  802729:	89 d9                	mov    %ebx,%ecx
  80272b:	d3 e8                	shr    %cl,%eax
  80272d:	09 c2                	or     %eax,%edx
  80272f:	89 d0                	mov    %edx,%eax
  802731:	89 ea                	mov    %ebp,%edx
  802733:	f7 f6                	div    %esi
  802735:	89 d5                	mov    %edx,%ebp
  802737:	89 c3                	mov    %eax,%ebx
  802739:	f7 64 24 0c          	mull   0xc(%esp)
  80273d:	39 d5                	cmp    %edx,%ebp
  80273f:	72 10                	jb     802751 <__udivdi3+0xc1>
  802741:	8b 74 24 08          	mov    0x8(%esp),%esi
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e6                	shl    %cl,%esi
  802749:	39 c6                	cmp    %eax,%esi
  80274b:	73 07                	jae    802754 <__udivdi3+0xc4>
  80274d:	39 d5                	cmp    %edx,%ebp
  80274f:	75 03                	jne    802754 <__udivdi3+0xc4>
  802751:	83 eb 01             	sub    $0x1,%ebx
  802754:	31 ff                	xor    %edi,%edi
  802756:	89 d8                	mov    %ebx,%eax
  802758:	89 fa                	mov    %edi,%edx
  80275a:	83 c4 1c             	add    $0x1c,%esp
  80275d:	5b                   	pop    %ebx
  80275e:	5e                   	pop    %esi
  80275f:	5f                   	pop    %edi
  802760:	5d                   	pop    %ebp
  802761:	c3                   	ret    
  802762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802768:	31 ff                	xor    %edi,%edi
  80276a:	31 db                	xor    %ebx,%ebx
  80276c:	89 d8                	mov    %ebx,%eax
  80276e:	89 fa                	mov    %edi,%edx
  802770:	83 c4 1c             	add    $0x1c,%esp
  802773:	5b                   	pop    %ebx
  802774:	5e                   	pop    %esi
  802775:	5f                   	pop    %edi
  802776:	5d                   	pop    %ebp
  802777:	c3                   	ret    
  802778:	90                   	nop
  802779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802780:	89 d8                	mov    %ebx,%eax
  802782:	f7 f7                	div    %edi
  802784:	31 ff                	xor    %edi,%edi
  802786:	89 c3                	mov    %eax,%ebx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 fa                	mov    %edi,%edx
  80278c:	83 c4 1c             	add    $0x1c,%esp
  80278f:	5b                   	pop    %ebx
  802790:	5e                   	pop    %esi
  802791:	5f                   	pop    %edi
  802792:	5d                   	pop    %ebp
  802793:	c3                   	ret    
  802794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802798:	39 ce                	cmp    %ecx,%esi
  80279a:	72 0c                	jb     8027a8 <__udivdi3+0x118>
  80279c:	31 db                	xor    %ebx,%ebx
  80279e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027a2:	0f 87 34 ff ff ff    	ja     8026dc <__udivdi3+0x4c>
  8027a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027ad:	e9 2a ff ff ff       	jmp    8026dc <__udivdi3+0x4c>
  8027b2:	66 90                	xchg   %ax,%ax
  8027b4:	66 90                	xchg   %ax,%ax
  8027b6:	66 90                	xchg   %ax,%ax
  8027b8:	66 90                	xchg   %ax,%ax
  8027ba:	66 90                	xchg   %ax,%ax
  8027bc:	66 90                	xchg   %ax,%ax
  8027be:	66 90                	xchg   %ax,%ax

008027c0 <__umoddi3>:
  8027c0:	55                   	push   %ebp
  8027c1:	57                   	push   %edi
  8027c2:	56                   	push   %esi
  8027c3:	53                   	push   %ebx
  8027c4:	83 ec 1c             	sub    $0x1c,%esp
  8027c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027d7:	85 d2                	test   %edx,%edx
  8027d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027e1:	89 f3                	mov    %esi,%ebx
  8027e3:	89 3c 24             	mov    %edi,(%esp)
  8027e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ea:	75 1c                	jne    802808 <__umoddi3+0x48>
  8027ec:	39 f7                	cmp    %esi,%edi
  8027ee:	76 50                	jbe    802840 <__umoddi3+0x80>
  8027f0:	89 c8                	mov    %ecx,%eax
  8027f2:	89 f2                	mov    %esi,%edx
  8027f4:	f7 f7                	div    %edi
  8027f6:	89 d0                	mov    %edx,%eax
  8027f8:	31 d2                	xor    %edx,%edx
  8027fa:	83 c4 1c             	add    $0x1c,%esp
  8027fd:	5b                   	pop    %ebx
  8027fe:	5e                   	pop    %esi
  8027ff:	5f                   	pop    %edi
  802800:	5d                   	pop    %ebp
  802801:	c3                   	ret    
  802802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802808:	39 f2                	cmp    %esi,%edx
  80280a:	89 d0                	mov    %edx,%eax
  80280c:	77 52                	ja     802860 <__umoddi3+0xa0>
  80280e:	0f bd ea             	bsr    %edx,%ebp
  802811:	83 f5 1f             	xor    $0x1f,%ebp
  802814:	75 5a                	jne    802870 <__umoddi3+0xb0>
  802816:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80281a:	0f 82 e0 00 00 00    	jb     802900 <__umoddi3+0x140>
  802820:	39 0c 24             	cmp    %ecx,(%esp)
  802823:	0f 86 d7 00 00 00    	jbe    802900 <__umoddi3+0x140>
  802829:	8b 44 24 08          	mov    0x8(%esp),%eax
  80282d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802831:	83 c4 1c             	add    $0x1c,%esp
  802834:	5b                   	pop    %ebx
  802835:	5e                   	pop    %esi
  802836:	5f                   	pop    %edi
  802837:	5d                   	pop    %ebp
  802838:	c3                   	ret    
  802839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802840:	85 ff                	test   %edi,%edi
  802842:	89 fd                	mov    %edi,%ebp
  802844:	75 0b                	jne    802851 <__umoddi3+0x91>
  802846:	b8 01 00 00 00       	mov    $0x1,%eax
  80284b:	31 d2                	xor    %edx,%edx
  80284d:	f7 f7                	div    %edi
  80284f:	89 c5                	mov    %eax,%ebp
  802851:	89 f0                	mov    %esi,%eax
  802853:	31 d2                	xor    %edx,%edx
  802855:	f7 f5                	div    %ebp
  802857:	89 c8                	mov    %ecx,%eax
  802859:	f7 f5                	div    %ebp
  80285b:	89 d0                	mov    %edx,%eax
  80285d:	eb 99                	jmp    8027f8 <__umoddi3+0x38>
  80285f:	90                   	nop
  802860:	89 c8                	mov    %ecx,%eax
  802862:	89 f2                	mov    %esi,%edx
  802864:	83 c4 1c             	add    $0x1c,%esp
  802867:	5b                   	pop    %ebx
  802868:	5e                   	pop    %esi
  802869:	5f                   	pop    %edi
  80286a:	5d                   	pop    %ebp
  80286b:	c3                   	ret    
  80286c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802870:	8b 34 24             	mov    (%esp),%esi
  802873:	bf 20 00 00 00       	mov    $0x20,%edi
  802878:	89 e9                	mov    %ebp,%ecx
  80287a:	29 ef                	sub    %ebp,%edi
  80287c:	d3 e0                	shl    %cl,%eax
  80287e:	89 f9                	mov    %edi,%ecx
  802880:	89 f2                	mov    %esi,%edx
  802882:	d3 ea                	shr    %cl,%edx
  802884:	89 e9                	mov    %ebp,%ecx
  802886:	09 c2                	or     %eax,%edx
  802888:	89 d8                	mov    %ebx,%eax
  80288a:	89 14 24             	mov    %edx,(%esp)
  80288d:	89 f2                	mov    %esi,%edx
  80288f:	d3 e2                	shl    %cl,%edx
  802891:	89 f9                	mov    %edi,%ecx
  802893:	89 54 24 04          	mov    %edx,0x4(%esp)
  802897:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80289b:	d3 e8                	shr    %cl,%eax
  80289d:	89 e9                	mov    %ebp,%ecx
  80289f:	89 c6                	mov    %eax,%esi
  8028a1:	d3 e3                	shl    %cl,%ebx
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 d0                	mov    %edx,%eax
  8028a7:	d3 e8                	shr    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	09 d8                	or     %ebx,%eax
  8028ad:	89 d3                	mov    %edx,%ebx
  8028af:	89 f2                	mov    %esi,%edx
  8028b1:	f7 34 24             	divl   (%esp)
  8028b4:	89 d6                	mov    %edx,%esi
  8028b6:	d3 e3                	shl    %cl,%ebx
  8028b8:	f7 64 24 04          	mull   0x4(%esp)
  8028bc:	39 d6                	cmp    %edx,%esi
  8028be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028c2:	89 d1                	mov    %edx,%ecx
  8028c4:	89 c3                	mov    %eax,%ebx
  8028c6:	72 08                	jb     8028d0 <__umoddi3+0x110>
  8028c8:	75 11                	jne    8028db <__umoddi3+0x11b>
  8028ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ce:	73 0b                	jae    8028db <__umoddi3+0x11b>
  8028d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028d4:	1b 14 24             	sbb    (%esp),%edx
  8028d7:	89 d1                	mov    %edx,%ecx
  8028d9:	89 c3                	mov    %eax,%ebx
  8028db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028df:	29 da                	sub    %ebx,%edx
  8028e1:	19 ce                	sbb    %ecx,%esi
  8028e3:	89 f9                	mov    %edi,%ecx
  8028e5:	89 f0                	mov    %esi,%eax
  8028e7:	d3 e0                	shl    %cl,%eax
  8028e9:	89 e9                	mov    %ebp,%ecx
  8028eb:	d3 ea                	shr    %cl,%edx
  8028ed:	89 e9                	mov    %ebp,%ecx
  8028ef:	d3 ee                	shr    %cl,%esi
  8028f1:	09 d0                	or     %edx,%eax
  8028f3:	89 f2                	mov    %esi,%edx
  8028f5:	83 c4 1c             	add    $0x1c,%esp
  8028f8:	5b                   	pop    %ebx
  8028f9:	5e                   	pop    %esi
  8028fa:	5f                   	pop    %edi
  8028fb:	5d                   	pop    %ebp
  8028fc:	c3                   	ret    
  8028fd:	8d 76 00             	lea    0x0(%esi),%esi
  802900:	29 f9                	sub    %edi,%ecx
  802902:	19 d6                	sbb    %edx,%esi
  802904:	89 74 24 04          	mov    %esi,0x4(%esp)
  802908:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80290c:	e9 18 ff ff ff       	jmp    802829 <__umoddi3+0x69>
