
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 c0 27 80 00       	push   $0x8027c0
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 8f 1b 00 00       	call   801be0 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 0e 28 80 00       	push   $0x80280e
  80005e:	6a 0d                	push   $0xd
  800060:	68 17 28 80 00       	push   $0x802817
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 4c 0f 00 00       	call   800fbb <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 2c 28 80 00       	push   $0x80282c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 17 28 80 00       	push   $0x802817
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 fd 12 00 00       	call   801393 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 35 28 80 00       	push   $0x802835
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 0b 13 00 00       	call   8013e3 <dup>
			sys_yield();
  8000d8:	e8 bb 0b 00 00       	call   800c98 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 aa 12 00 00       	call   801393 <close>
			sys_yield();
  8000e9:	e8 aa 0b 00 00       	call   800c98 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 11 1c 00 00       	call   801d33 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 39 28 80 00       	push   $0x802839
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 fa 0a 00 00       	call   800c38 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 55 28 80 00       	push   $0x802855
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 c2 1b 00 00       	call   801d33 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 e4 27 80 00       	push   $0x8027e4
  800180:	6a 40                	push   $0x40
  800182:	68 17 28 80 00       	push   $0x802817
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 ce 10 00 00       	call   801269 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 6b 28 80 00       	push   $0x80286b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 17 28 80 00       	push   $0x802817
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 44 10 00 00       	call   801203 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 83 28 80 00 	movl   $0x802883,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8001e1:	e8 93 0a 00 00       	call   800c79 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 97 11 00 00       	call   8013be <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 07 0a 00 00       	call   800c38 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 30 0a 00 00       	call   800c79 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 a4 28 80 00       	push   $0x8028a4
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 9f 2d 80 00 	movl   $0x802d9f,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 4f 09 00 00       	call   800bfb <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 f4 08 00 00       	call   800bfb <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 a9 21 00 00       	call   802520 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 96 22 00 00       	call   802650 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 c7 28 80 00 	movsbl 0x8028c7(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 a9 03 00 00    	je     80080b <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 3a 03 00 00    	ja     8007f0 <vprintfmt+0x3aa>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 00 2a 80 00 	jmp    *0x802a00(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 60 2b 80 00 	mov    0x802b60(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 df 28 80 00       	push   $0x8028df
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 6d 2d 80 00       	push   $0x802d6d
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 d8 28 80 00       	mov    $0x8028d8,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 a6 02 00 00       	call   800893 <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800726:	0f 89 90 00 00 00    	jns    8007bc <vprintfmt+0x376>
				putch('-', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 2d                	push   $0x2d
  800732:	ff d6                	call   *%esi
				num = -(long long) num;
  800734:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800737:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80073a:	f7 d8                	neg    %eax
  80073c:	83 d2 00             	adc    $0x0,%edx
  80073f:	f7 da                	neg    %edx
  800741:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800744:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800749:	eb 71                	jmp    8007bc <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 7f fc ff ff       	call   8003d2 <getuint>
			base = 10;
  800753:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800758:	eb 62                	jmp    8007bc <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80075a:	8d 45 14             	lea    0x14(%ebp),%eax
  80075d:	e8 70 fc ff ff       	call   8003d2 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800762:	83 ec 0c             	sub    $0xc,%esp
  800765:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800769:	51                   	push   %ecx
  80076a:	ff 75 e0             	pushl  -0x20(%ebp)
  80076d:	6a 08                	push   $0x8
  80076f:	52                   	push   %edx
  800770:	50                   	push   %eax
  800771:	89 da                	mov    %ebx,%edx
  800773:	89 f0                	mov    %esi,%eax
  800775:	e8 a9 fb ff ff       	call   800323 <printnum>
			break;
  80077a:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800780:	e9 e7 fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 30                	push   $0x30
  80078b:	ff d6                	call   *%esi
			putch('x', putdat);
  80078d:	83 c4 08             	add    $0x8,%esp
  800790:	53                   	push   %ebx
  800791:	6a 78                	push   $0x78
  800793:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 04             	lea    0x4(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079e:	8b 00                	mov    (%eax),%eax
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007a8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007ad:	eb 0d                	jmp    8007bc <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007af:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b2:	e8 1b fc ff ff       	call   8003d2 <getuint>
			base = 16;
  8007b7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bc:	83 ec 0c             	sub    $0xc,%esp
  8007bf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c3:	57                   	push   %edi
  8007c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c7:	51                   	push   %ecx
  8007c8:	52                   	push   %edx
  8007c9:	50                   	push   %eax
  8007ca:	89 da                	mov    %ebx,%edx
  8007cc:	89 f0                	mov    %esi,%eax
  8007ce:	e8 50 fb ff ff       	call   800323 <printnum>
			break;
  8007d3:	83 c4 20             	add    $0x20,%esp
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d9:	e9 8e fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	51                   	push   %ecx
  8007e3:	ff d6                	call   *%esi
			break;
  8007e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007eb:	e9 7c fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	53                   	push   %ebx
  8007f4:	6a 25                	push   $0x25
  8007f6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	eb 03                	jmp    800800 <vprintfmt+0x3ba>
  8007fd:	83 ef 01             	sub    $0x1,%edi
  800800:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800804:	75 f7                	jne    8007fd <vprintfmt+0x3b7>
  800806:	e9 61 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80080b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5f                   	pop    %edi
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	83 ec 18             	sub    $0x18,%esp
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80081f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800822:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800826:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800829:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800830:	85 c0                	test   %eax,%eax
  800832:	74 26                	je     80085a <vsnprintf+0x47>
  800834:	85 d2                	test   %edx,%edx
  800836:	7e 22                	jle    80085a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800838:	ff 75 14             	pushl  0x14(%ebp)
  80083b:	ff 75 10             	pushl  0x10(%ebp)
  80083e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800841:	50                   	push   %eax
  800842:	68 0c 04 80 00       	push   $0x80040c
  800847:	e8 fa fb ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80084f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800852:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	eb 05                	jmp    80085f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800867:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086a:	50                   	push   %eax
  80086b:	ff 75 10             	pushl  0x10(%ebp)
  80086e:	ff 75 0c             	pushl  0xc(%ebp)
  800871:	ff 75 08             	pushl  0x8(%ebp)
  800874:	e8 9a ff ff ff       	call   800813 <vsnprintf>
	va_end(ap);

	return rc;
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	eb 03                	jmp    80088b <strlen+0x10>
		n++;
  800888:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80088f:	75 f7                	jne    800888 <strlen+0xd>
		n++;
	return n;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a1:	eb 03                	jmp    8008a6 <strnlen+0x13>
		n++;
  8008a3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a6:	39 c2                	cmp    %eax,%edx
  8008a8:	74 08                	je     8008b2 <strnlen+0x1f>
  8008aa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ae:	75 f3                	jne    8008a3 <strnlen+0x10>
  8008b0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008be:	89 c2                	mov    %eax,%edx
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	83 c1 01             	add    $0x1,%ecx
  8008c6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ca:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008cd:	84 db                	test   %bl,%bl
  8008cf:	75 ef                	jne    8008c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	53                   	push   %ebx
  8008d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008db:	53                   	push   %ebx
  8008dc:	e8 9a ff ff ff       	call   80087b <strlen>
  8008e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	01 d8                	add    %ebx,%eax
  8008e9:	50                   	push   %eax
  8008ea:	e8 c5 ff ff ff       	call   8008b4 <strcpy>
	return dst;
}
  8008ef:	89 d8                	mov    %ebx,%eax
  8008f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800901:	89 f3                	mov    %esi,%ebx
  800903:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800906:	89 f2                	mov    %esi,%edx
  800908:	eb 0f                	jmp    800919 <strncpy+0x23>
		*dst++ = *src;
  80090a:	83 c2 01             	add    $0x1,%edx
  80090d:	0f b6 01             	movzbl (%ecx),%eax
  800910:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800913:	80 39 01             	cmpb   $0x1,(%ecx)
  800916:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800919:	39 da                	cmp    %ebx,%edx
  80091b:	75 ed                	jne    80090a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 75 08             	mov    0x8(%ebp),%esi
  80092b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092e:	8b 55 10             	mov    0x10(%ebp),%edx
  800931:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800933:	85 d2                	test   %edx,%edx
  800935:	74 21                	je     800958 <strlcpy+0x35>
  800937:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093b:	89 f2                	mov    %esi,%edx
  80093d:	eb 09                	jmp    800948 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093f:	83 c2 01             	add    $0x1,%edx
  800942:	83 c1 01             	add    $0x1,%ecx
  800945:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800948:	39 c2                	cmp    %eax,%edx
  80094a:	74 09                	je     800955 <strlcpy+0x32>
  80094c:	0f b6 19             	movzbl (%ecx),%ebx
  80094f:	84 db                	test   %bl,%bl
  800951:	75 ec                	jne    80093f <strlcpy+0x1c>
  800953:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800955:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800958:	29 f0                	sub    %esi,%eax
}
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800964:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800967:	eb 06                	jmp    80096f <strcmp+0x11>
		p++, q++;
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096f:	0f b6 01             	movzbl (%ecx),%eax
  800972:	84 c0                	test   %al,%al
  800974:	74 04                	je     80097a <strcmp+0x1c>
  800976:	3a 02                	cmp    (%edx),%al
  800978:	74 ef                	je     800969 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097a:	0f b6 c0             	movzbl %al,%eax
  80097d:	0f b6 12             	movzbl (%edx),%edx
  800980:	29 d0                	sub    %edx,%eax
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098e:	89 c3                	mov    %eax,%ebx
  800990:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800993:	eb 06                	jmp    80099b <strncmp+0x17>
		n--, p++, q++;
  800995:	83 c0 01             	add    $0x1,%eax
  800998:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099b:	39 d8                	cmp    %ebx,%eax
  80099d:	74 15                	je     8009b4 <strncmp+0x30>
  80099f:	0f b6 08             	movzbl (%eax),%ecx
  8009a2:	84 c9                	test   %cl,%cl
  8009a4:	74 04                	je     8009aa <strncmp+0x26>
  8009a6:	3a 0a                	cmp    (%edx),%cl
  8009a8:	74 eb                	je     800995 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009aa:	0f b6 00             	movzbl (%eax),%eax
  8009ad:	0f b6 12             	movzbl (%edx),%edx
  8009b0:	29 d0                	sub    %edx,%eax
  8009b2:	eb 05                	jmp    8009b9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c6:	eb 07                	jmp    8009cf <strchr+0x13>
		if (*s == c)
  8009c8:	38 ca                	cmp    %cl,%dl
  8009ca:	74 0f                	je     8009db <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	0f b6 10             	movzbl (%eax),%edx
  8009d2:	84 d2                	test   %dl,%dl
  8009d4:	75 f2                	jne    8009c8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e7:	eb 03                	jmp    8009ec <strfind+0xf>
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ef:	38 ca                	cmp    %cl,%dl
  8009f1:	74 04                	je     8009f7 <strfind+0x1a>
  8009f3:	84 d2                	test   %dl,%dl
  8009f5:	75 f2                	jne    8009e9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	57                   	push   %edi
  8009fd:	56                   	push   %esi
  8009fe:	53                   	push   %ebx
  8009ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a05:	85 c9                	test   %ecx,%ecx
  800a07:	74 36                	je     800a3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0f:	75 28                	jne    800a39 <memset+0x40>
  800a11:	f6 c1 03             	test   $0x3,%cl
  800a14:	75 23                	jne    800a39 <memset+0x40>
		c &= 0xFF;
  800a16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1a:	89 d3                	mov    %edx,%ebx
  800a1c:	c1 e3 08             	shl    $0x8,%ebx
  800a1f:	89 d6                	mov    %edx,%esi
  800a21:	c1 e6 18             	shl    $0x18,%esi
  800a24:	89 d0                	mov    %edx,%eax
  800a26:	c1 e0 10             	shl    $0x10,%eax
  800a29:	09 f0                	or     %esi,%eax
  800a2b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a2d:	89 d8                	mov    %ebx,%eax
  800a2f:	09 d0                	or     %edx,%eax
  800a31:	c1 e9 02             	shr    $0x2,%ecx
  800a34:	fc                   	cld    
  800a35:	f3 ab                	rep stos %eax,%es:(%edi)
  800a37:	eb 06                	jmp    800a3f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	fc                   	cld    
  800a3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3f:	89 f8                	mov    %edi,%eax
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	57                   	push   %edi
  800a4a:	56                   	push   %esi
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a54:	39 c6                	cmp    %eax,%esi
  800a56:	73 35                	jae    800a8d <memmove+0x47>
  800a58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5b:	39 d0                	cmp    %edx,%eax
  800a5d:	73 2e                	jae    800a8d <memmove+0x47>
		s += n;
		d += n;
  800a5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a62:	89 d6                	mov    %edx,%esi
  800a64:	09 fe                	or     %edi,%esi
  800a66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6c:	75 13                	jne    800a81 <memmove+0x3b>
  800a6e:	f6 c1 03             	test   $0x3,%cl
  800a71:	75 0e                	jne    800a81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a73:	83 ef 04             	sub    $0x4,%edi
  800a76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a79:	c1 e9 02             	shr    $0x2,%ecx
  800a7c:	fd                   	std    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 09                	jmp    800a8a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a81:	83 ef 01             	sub    $0x1,%edi
  800a84:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a87:	fd                   	std    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8a:	fc                   	cld    
  800a8b:	eb 1d                	jmp    800aaa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8d:	89 f2                	mov    %esi,%edx
  800a8f:	09 c2                	or     %eax,%edx
  800a91:	f6 c2 03             	test   $0x3,%dl
  800a94:	75 0f                	jne    800aa5 <memmove+0x5f>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 0a                	jne    800aa5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
  800a9e:	89 c7                	mov    %eax,%edi
  800aa0:	fc                   	cld    
  800aa1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa3:	eb 05                	jmp    800aaa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa5:	89 c7                	mov    %eax,%edi
  800aa7:	fc                   	cld    
  800aa8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab1:	ff 75 10             	pushl  0x10(%ebp)
  800ab4:	ff 75 0c             	pushl  0xc(%ebp)
  800ab7:	ff 75 08             	pushl  0x8(%ebp)
  800aba:	e8 87 ff ff ff       	call   800a46 <memmove>
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acc:	89 c6                	mov    %eax,%esi
  800ace:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad1:	eb 1a                	jmp    800aed <memcmp+0x2c>
		if (*s1 != *s2)
  800ad3:	0f b6 08             	movzbl (%eax),%ecx
  800ad6:	0f b6 1a             	movzbl (%edx),%ebx
  800ad9:	38 d9                	cmp    %bl,%cl
  800adb:	74 0a                	je     800ae7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800add:	0f b6 c1             	movzbl %cl,%eax
  800ae0:	0f b6 db             	movzbl %bl,%ebx
  800ae3:	29 d8                	sub    %ebx,%eax
  800ae5:	eb 0f                	jmp    800af6 <memcmp+0x35>
		s1++, s2++;
  800ae7:	83 c0 01             	add    $0x1,%eax
  800aea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aed:	39 f0                	cmp    %esi,%eax
  800aef:	75 e2                	jne    800ad3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b01:	89 c1                	mov    %eax,%ecx
  800b03:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0a:	eb 0a                	jmp    800b16 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0c:	0f b6 10             	movzbl (%eax),%edx
  800b0f:	39 da                	cmp    %ebx,%edx
  800b11:	74 07                	je     800b1a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b13:	83 c0 01             	add    $0x1,%eax
  800b16:	39 c8                	cmp    %ecx,%eax
  800b18:	72 f2                	jb     800b0c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b29:	eb 03                	jmp    800b2e <strtol+0x11>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2e:	0f b6 01             	movzbl (%ecx),%eax
  800b31:	3c 20                	cmp    $0x20,%al
  800b33:	74 f6                	je     800b2b <strtol+0xe>
  800b35:	3c 09                	cmp    $0x9,%al
  800b37:	74 f2                	je     800b2b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b39:	3c 2b                	cmp    $0x2b,%al
  800b3b:	75 0a                	jne    800b47 <strtol+0x2a>
		s++;
  800b3d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b40:	bf 00 00 00 00       	mov    $0x0,%edi
  800b45:	eb 11                	jmp    800b58 <strtol+0x3b>
  800b47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4c:	3c 2d                	cmp    $0x2d,%al
  800b4e:	75 08                	jne    800b58 <strtol+0x3b>
		s++, neg = 1;
  800b50:	83 c1 01             	add    $0x1,%ecx
  800b53:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5e:	75 15                	jne    800b75 <strtol+0x58>
  800b60:	80 39 30             	cmpb   $0x30,(%ecx)
  800b63:	75 10                	jne    800b75 <strtol+0x58>
  800b65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b69:	75 7c                	jne    800be7 <strtol+0xca>
		s += 2, base = 16;
  800b6b:	83 c1 02             	add    $0x2,%ecx
  800b6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b73:	eb 16                	jmp    800b8b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b75:	85 db                	test   %ebx,%ebx
  800b77:	75 12                	jne    800b8b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b79:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b81:	75 08                	jne    800b8b <strtol+0x6e>
		s++, base = 8;
  800b83:	83 c1 01             	add    $0x1,%ecx
  800b86:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b93:	0f b6 11             	movzbl (%ecx),%edx
  800b96:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 09             	cmp    $0x9,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0x8b>
			dig = *s - '0';
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 30             	sub    $0x30,%edx
  800ba6:	eb 22                	jmp    800bca <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ba8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 08                	ja     800bba <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 57             	sub    $0x57,%edx
  800bb8:	eb 10                	jmp    800bca <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 19             	cmp    $0x19,%bl
  800bc2:	77 16                	ja     800bda <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc4:	0f be d2             	movsbl %dl,%edx
  800bc7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bca:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bcd:	7d 0b                	jge    800bda <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bcf:	83 c1 01             	add    $0x1,%ecx
  800bd2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd8:	eb b9                	jmp    800b93 <strtol+0x76>

	if (endptr)
  800bda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bde:	74 0d                	je     800bed <strtol+0xd0>
		*endptr = (char *) s;
  800be0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be3:	89 0e                	mov    %ecx,(%esi)
  800be5:	eb 06                	jmp    800bed <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be7:	85 db                	test   %ebx,%ebx
  800be9:	74 98                	je     800b83 <strtol+0x66>
  800beb:	eb 9e                	jmp    800b8b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	f7 da                	neg    %edx
  800bf1:	85 ff                	test   %edi,%edi
  800bf3:	0f 45 c2             	cmovne %edx,%eax
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	89 c3                	mov    %eax,%ebx
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	89 c6                	mov    %eax,%esi
  800c12:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 01 00 00 00       	mov    $0x1,%eax
  800c29:	89 d1                	mov    %edx,%ecx
  800c2b:	89 d3                	mov    %edx,%ebx
  800c2d:	89 d7                	mov    %edx,%edi
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c46:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 cb                	mov    %ecx,%ebx
  800c50:	89 cf                	mov    %ecx,%edi
  800c52:	89 ce                	mov    %ecx,%esi
  800c54:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c56:	85 c0                	test   %eax,%eax
  800c58:	7e 17                	jle    800c71 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 03                	push   $0x3
  800c60:	68 bf 2b 80 00       	push   $0x802bbf
  800c65:	6a 23                	push   $0x23
  800c67:	68 dc 2b 80 00       	push   $0x802bdc
  800c6c:	e8 c5 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c84:	b8 02 00 00 00       	mov    $0x2,%eax
  800c89:	89 d1                	mov    %edx,%ecx
  800c8b:	89 d3                	mov    %edx,%ebx
  800c8d:	89 d7                	mov    %edx,%edi
  800c8f:	89 d6                	mov    %edx,%esi
  800c91:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_yield>:

void
sys_yield(void)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca8:	89 d1                	mov    %edx,%ecx
  800caa:	89 d3                	mov    %edx,%ebx
  800cac:	89 d7                	mov    %edx,%edi
  800cae:	89 d6                	mov    %edx,%esi
  800cb0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	be 00 00 00 00       	mov    $0x0,%esi
  800cc5:	b8 04 00 00 00       	mov    $0x4,%eax
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd3:	89 f7                	mov    %esi,%edi
  800cd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 17                	jle    800cf2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 04                	push   $0x4
  800ce1:	68 bf 2b 80 00       	push   $0x802bbf
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 dc 2b 80 00       	push   $0x802bdc
  800ced:	e8 44 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	b8 05 00 00 00       	mov    $0x5,%eax
  800d08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d11:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d14:	8b 75 18             	mov    0x18(%ebp),%esi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 05                	push   $0x5
  800d23:	68 bf 2b 80 00       	push   $0x802bbf
  800d28:	6a 23                	push   $0x23
  800d2a:	68 dc 2b 80 00       	push   $0x802bdc
  800d2f:	e8 02 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	89 df                	mov    %ebx,%edi
  800d57:	89 de                	mov    %ebx,%esi
  800d59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 06                	push   $0x6
  800d65:	68 bf 2b 80 00       	push   $0x802bbf
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 dc 2b 80 00       	push   $0x802bdc
  800d71:	e8 c0 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 df                	mov    %ebx,%edi
  800d99:	89 de                	mov    %ebx,%esi
  800d9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	7e 17                	jle    800db8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 08                	push   $0x8
  800da7:	68 bf 2b 80 00       	push   $0x802bbf
  800dac:	6a 23                	push   $0x23
  800dae:	68 dc 2b 80 00       	push   $0x802bdc
  800db3:	e8 7e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbb:	5b                   	pop    %ebx
  800dbc:	5e                   	pop    %esi
  800dbd:	5f                   	pop    %edi
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dce:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 de                	mov    %ebx,%esi
  800ddd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	7e 17                	jle    800dfa <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	6a 09                	push   $0x9
  800de9:	68 bf 2b 80 00       	push   $0x802bbf
  800dee:	6a 23                	push   $0x23
  800df0:	68 dc 2b 80 00       	push   $0x802bdc
  800df5:	e8 3c f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	89 df                	mov    %ebx,%edi
  800e1d:	89 de                	mov    %ebx,%esi
  800e1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e21:	85 c0                	test   %eax,%eax
  800e23:	7e 17                	jle    800e3c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e25:	83 ec 0c             	sub    $0xc,%esp
  800e28:	50                   	push   %eax
  800e29:	6a 0a                	push   $0xa
  800e2b:	68 bf 2b 80 00       	push   $0x802bbf
  800e30:	6a 23                	push   $0x23
  800e32:	68 dc 2b 80 00       	push   $0x802bdc
  800e37:	e8 fa f3 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4a:	be 00 00 00 00       	mov    $0x0,%esi
  800e4f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e57:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e60:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e75:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7d:	89 cb                	mov    %ecx,%ebx
  800e7f:	89 cf                	mov    %ecx,%edi
  800e81:	89 ce                	mov    %ecx,%esi
  800e83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 17                	jle    800ea0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 0d                	push   $0xd
  800e8f:	68 bf 2b 80 00       	push   $0x802bbf
  800e94:	6a 23                	push   $0x23
  800e96:	68 dc 2b 80 00       	push   $0x802bdc
  800e9b:	e8 96 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eb8:	89 d1                	mov    %edx,%ecx
  800eba:	89 d3                	mov    %edx,%ebx
  800ebc:	89 d7                	mov    %edx,%edi
  800ebe:	89 d6                	mov    %edx,%esi
  800ec0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ec2:	5b                   	pop    %ebx
  800ec3:	5e                   	pop    %esi
  800ec4:	5f                   	pop    %edi
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	53                   	push   %ebx
  800ecb:	83 ec 04             	sub    $0x4,%esp
  800ece:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ed1:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800ed3:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ed6:	f6 c1 02             	test   $0x2,%cl
  800ed9:	74 2e                	je     800f09 <pgfault+0x42>
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	c1 ea 16             	shr    $0x16,%edx
  800ee0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee7:	f6 c2 01             	test   $0x1,%dl
  800eea:	74 1d                	je     800f09 <pgfault+0x42>
  800eec:	89 c2                	mov    %eax,%edx
  800eee:	c1 ea 0c             	shr    $0xc,%edx
  800ef1:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800ef8:	f6 c3 01             	test   $0x1,%bl
  800efb:	74 0c                	je     800f09 <pgfault+0x42>
  800efd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f04:	f6 c6 08             	test   $0x8,%dh
  800f07:	75 12                	jne    800f1b <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800f09:	51                   	push   %ecx
  800f0a:	68 ea 2b 80 00       	push   $0x802bea
  800f0f:	6a 1e                	push   $0x1e
  800f11:	68 03 2c 80 00       	push   $0x802c03
  800f16:	e8 1b f3 ff ff       	call   800236 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f20:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	6a 07                	push   $0x7
  800f27:	68 00 f0 7f 00       	push   $0x7ff000
  800f2c:	6a 00                	push   $0x0
  800f2e:	e8 84 fd ff ff       	call   800cb7 <sys_page_alloc>
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	79 12                	jns    800f4c <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800f3a:	50                   	push   %eax
  800f3b:	68 0e 2c 80 00       	push   $0x802c0e
  800f40:	6a 29                	push   $0x29
  800f42:	68 03 2c 80 00       	push   $0x802c03
  800f47:	e8 ea f2 ff ff       	call   800236 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	68 00 10 00 00       	push   $0x1000
  800f54:	53                   	push   %ebx
  800f55:	68 00 f0 7f 00       	push   $0x7ff000
  800f5a:	e8 4f fb ff ff       	call   800aae <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f5f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f66:	53                   	push   %ebx
  800f67:	6a 00                	push   $0x0
  800f69:	68 00 f0 7f 00       	push   $0x7ff000
  800f6e:	6a 00                	push   $0x0
  800f70:	e8 85 fd ff ff       	call   800cfa <sys_page_map>
  800f75:	83 c4 20             	add    $0x20,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	79 12                	jns    800f8e <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800f7c:	50                   	push   %eax
  800f7d:	68 29 2c 80 00       	push   $0x802c29
  800f82:	6a 2e                	push   $0x2e
  800f84:	68 03 2c 80 00       	push   $0x802c03
  800f89:	e8 a8 f2 ff ff       	call   800236 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800f8e:	83 ec 08             	sub    $0x8,%esp
  800f91:	68 00 f0 7f 00       	push   $0x7ff000
  800f96:	6a 00                	push   $0x0
  800f98:	e8 9f fd ff ff       	call   800d3c <sys_page_unmap>
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	79 12                	jns    800fb6 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800fa4:	50                   	push   %eax
  800fa5:	68 42 2c 80 00       	push   $0x802c42
  800faa:	6a 31                	push   $0x31
  800fac:	68 03 2c 80 00       	push   $0x802c03
  800fb1:	e8 80 f2 ff ff       	call   800236 <_panic>

}
  800fb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800fc4:	68 c7 0e 80 00       	push   $0x800ec7
  800fc9:	e8 82 13 00 00       	call   802350 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fce:	b8 07 00 00 00       	mov    $0x7,%eax
  800fd3:	cd 30                	int    $0x30
  800fd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fd8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	75 21                	jne    801008 <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fe7:	e8 8d fc ff ff       	call   800c79 <sys_getenvid>
  800fec:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ff1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ff4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ff9:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ffe:	b8 00 00 00 00       	mov    $0x0,%eax
  801003:	e9 c9 01 00 00       	jmp    8011d1 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	c1 e8 16             	shr    $0x16,%eax
  80100d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801014:	a8 01                	test   $0x1,%al
  801016:	0f 84 1b 01 00 00    	je     801137 <fork+0x17c>
  80101c:	89 de                	mov    %ebx,%esi
  80101e:	c1 ee 0c             	shr    $0xc,%esi
  801021:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801028:	a8 01                	test   $0x1,%al
  80102a:	0f 84 07 01 00 00    	je     801137 <fork+0x17c>
  801030:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801037:	a8 04                	test   $0x4,%al
  801039:	0f 84 f8 00 00 00    	je     801137 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  80103f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801046:	f6 c4 04             	test   $0x4,%ah
  801049:	74 3c                	je     801087 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  80104b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801052:	c1 e6 0c             	shl    $0xc,%esi
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	25 07 0e 00 00       	and    $0xe07,%eax
  80105d:	50                   	push   %eax
  80105e:	56                   	push   %esi
  80105f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801062:	56                   	push   %esi
  801063:	6a 00                	push   $0x0
  801065:	e8 90 fc ff ff       	call   800cfa <sys_page_map>
  80106a:	83 c4 20             	add    $0x20,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	0f 89 c2 00 00 00    	jns    801137 <fork+0x17c>
			panic("duppage: %e", r);
  801075:	50                   	push   %eax
  801076:	68 5d 2c 80 00       	push   $0x802c5d
  80107b:	6a 48                	push   $0x48
  80107d:	68 03 2c 80 00       	push   $0x802c03
  801082:	e8 af f1 ff ff       	call   800236 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801087:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108e:	f6 c4 08             	test   $0x8,%ah
  801091:	75 0b                	jne    80109e <fork+0xe3>
  801093:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109a:	a8 02                	test   $0x2,%al
  80109c:	74 6c                	je     80110a <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  80109e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a5:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  8010a8:	83 f8 01             	cmp    $0x1,%eax
  8010ab:	19 ff                	sbb    %edi,%edi
  8010ad:	83 e7 fc             	and    $0xfffffffc,%edi
  8010b0:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  8010b6:	c1 e6 0c             	shl    $0xc,%esi
  8010b9:	83 ec 0c             	sub    $0xc,%esp
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c1:	56                   	push   %esi
  8010c2:	6a 00                	push   $0x0
  8010c4:	e8 31 fc ff ff       	call   800cfa <sys_page_map>
  8010c9:	83 c4 20             	add    $0x20,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	79 12                	jns    8010e2 <fork+0x127>
			panic("duppage: %e", r);
  8010d0:	50                   	push   %eax
  8010d1:	68 5d 2c 80 00       	push   $0x802c5d
  8010d6:	6a 50                	push   $0x50
  8010d8:	68 03 2c 80 00       	push   $0x802c03
  8010dd:	e8 54 f1 ff ff       	call   800236 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	6a 00                	push   $0x0
  8010e9:	56                   	push   %esi
  8010ea:	6a 00                	push   $0x0
  8010ec:	e8 09 fc ff ff       	call   800cfa <sys_page_map>
  8010f1:	83 c4 20             	add    $0x20,%esp
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	79 3f                	jns    801137 <fork+0x17c>
			panic("duppage: %e", r);
  8010f8:	50                   	push   %eax
  8010f9:	68 5d 2c 80 00       	push   $0x802c5d
  8010fe:	6a 53                	push   $0x53
  801100:	68 03 2c 80 00       	push   $0x802c03
  801105:	e8 2c f1 ff ff       	call   800236 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  80110a:	c1 e6 0c             	shl    $0xc,%esi
  80110d:	83 ec 0c             	sub    $0xc,%esp
  801110:	6a 05                	push   $0x5
  801112:	56                   	push   %esi
  801113:	ff 75 e4             	pushl  -0x1c(%ebp)
  801116:	56                   	push   %esi
  801117:	6a 00                	push   $0x0
  801119:	e8 dc fb ff ff       	call   800cfa <sys_page_map>
  80111e:	83 c4 20             	add    $0x20,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 12                	jns    801137 <fork+0x17c>
			panic("duppage: %e", r);
  801125:	50                   	push   %eax
  801126:	68 5d 2c 80 00       	push   $0x802c5d
  80112b:	6a 57                	push   $0x57
  80112d:	68 03 2c 80 00       	push   $0x802c03
  801132:	e8 ff f0 ff ff       	call   800236 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801137:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80113d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801143:	0f 85 bf fe ff ff    	jne    801008 <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	6a 07                	push   $0x7
  80114e:	68 00 f0 bf ee       	push   $0xeebff000
  801153:	ff 75 e0             	pushl  -0x20(%ebp)
  801156:	e8 5c fb ff ff       	call   800cb7 <sys_page_alloc>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	74 17                	je     801179 <fork+0x1be>
		panic("sys_page_alloc Error");
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	68 69 2c 80 00       	push   $0x802c69
  80116a:	68 83 00 00 00       	push   $0x83
  80116f:	68 03 2c 80 00       	push   $0x802c03
  801174:	e8 bd f0 ff ff       	call   800236 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  801179:	83 ec 08             	sub    $0x8,%esp
  80117c:	68 bf 23 80 00       	push   $0x8023bf
  801181:	ff 75 e0             	pushl  -0x20(%ebp)
  801184:	e8 79 fc ff ff       	call   800e02 <sys_env_set_pgfault_upcall>
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	79 15                	jns    8011a5 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801190:	50                   	push   %eax
  801191:	68 7e 2c 80 00       	push   $0x802c7e
  801196:	68 86 00 00 00       	push   $0x86
  80119b:	68 03 2c 80 00       	push   $0x802c03
  8011a0:	e8 91 f0 ff ff       	call   800236 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	6a 02                	push   $0x2
  8011aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ad:	e8 cc fb ff ff       	call   800d7e <sys_env_set_status>
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	79 15                	jns    8011ce <fork+0x213>
		panic("fork set status: %e", r);
  8011b9:	50                   	push   %eax
  8011ba:	68 96 2c 80 00       	push   $0x802c96
  8011bf:	68 89 00 00 00       	push   $0x89
  8011c4:	68 03 2c 80 00       	push   $0x802c03
  8011c9:	e8 68 f0 ff ff       	call   800236 <_panic>
	
	return envid;
  8011ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8011d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    

008011d9 <sfork>:


// Challenge!
int
sfork(void)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011df:	68 aa 2c 80 00       	push   $0x802caa
  8011e4:	68 93 00 00 00       	push   $0x93
  8011e9:	68 03 2c 80 00       	push   $0x802c03
  8011ee:	e8 43 f0 ff ff       	call   800236 <_panic>

008011f3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fe:	c1 e8 0c             	shr    $0xc,%eax
}
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	05 00 00 00 30       	add    $0x30000000,%eax
  80120e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801213:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    

0080121a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801220:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801225:	89 c2                	mov    %eax,%edx
  801227:	c1 ea 16             	shr    $0x16,%edx
  80122a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801231:	f6 c2 01             	test   $0x1,%dl
  801234:	74 11                	je     801247 <fd_alloc+0x2d>
  801236:	89 c2                	mov    %eax,%edx
  801238:	c1 ea 0c             	shr    $0xc,%edx
  80123b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801242:	f6 c2 01             	test   $0x1,%dl
  801245:	75 09                	jne    801250 <fd_alloc+0x36>
			*fd_store = fd;
  801247:	89 01                	mov    %eax,(%ecx)
			return 0;
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	eb 17                	jmp    801267 <fd_alloc+0x4d>
  801250:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801255:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80125a:	75 c9                	jne    801225 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80125c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801262:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80126f:	83 f8 1f             	cmp    $0x1f,%eax
  801272:	77 36                	ja     8012aa <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801274:	c1 e0 0c             	shl    $0xc,%eax
  801277:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	c1 ea 16             	shr    $0x16,%edx
  801281:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801288:	f6 c2 01             	test   $0x1,%dl
  80128b:	74 24                	je     8012b1 <fd_lookup+0x48>
  80128d:	89 c2                	mov    %eax,%edx
  80128f:	c1 ea 0c             	shr    $0xc,%edx
  801292:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801299:	f6 c2 01             	test   $0x1,%dl
  80129c:	74 1a                	je     8012b8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80129e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a1:	89 02                	mov    %eax,(%edx)
	return 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a8:	eb 13                	jmp    8012bd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012af:	eb 0c                	jmp    8012bd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	eb 05                	jmp    8012bd <fd_lookup+0x54>
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c8:	ba 40 2d 80 00       	mov    $0x802d40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012cd:	eb 13                	jmp    8012e2 <dev_lookup+0x23>
  8012cf:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012d2:	39 08                	cmp    %ecx,(%eax)
  8012d4:	75 0c                	jne    8012e2 <dev_lookup+0x23>
			*dev = devtab[i];
  8012d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012db:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e0:	eb 2e                	jmp    801310 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e2:	8b 02                	mov    (%edx),%eax
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	75 e7                	jne    8012cf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ed:	8b 40 48             	mov    0x48(%eax),%eax
  8012f0:	83 ec 04             	sub    $0x4,%esp
  8012f3:	51                   	push   %ecx
  8012f4:	50                   	push   %eax
  8012f5:	68 c0 2c 80 00       	push   $0x802cc0
  8012fa:	e8 10 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  8012ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801302:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801310:	c9                   	leave  
  801311:	c3                   	ret    

00801312 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	56                   	push   %esi
  801316:	53                   	push   %ebx
  801317:	83 ec 10             	sub    $0x10,%esp
  80131a:	8b 75 08             	mov    0x8(%ebp),%esi
  80131d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80132a:	c1 e8 0c             	shr    $0xc,%eax
  80132d:	50                   	push   %eax
  80132e:	e8 36 ff ff ff       	call   801269 <fd_lookup>
  801333:	83 c4 08             	add    $0x8,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 05                	js     80133f <fd_close+0x2d>
	    || fd != fd2)
  80133a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80133d:	74 0c                	je     80134b <fd_close+0x39>
		return (must_exist ? r : 0);
  80133f:	84 db                	test   %bl,%bl
  801341:	ba 00 00 00 00       	mov    $0x0,%edx
  801346:	0f 44 c2             	cmove  %edx,%eax
  801349:	eb 41                	jmp    80138c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801351:	50                   	push   %eax
  801352:	ff 36                	pushl  (%esi)
  801354:	e8 66 ff ff ff       	call   8012bf <dev_lookup>
  801359:	89 c3                	mov    %eax,%ebx
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 1a                	js     80137c <fd_close+0x6a>
		if (dev->dev_close)
  801362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801365:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801368:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80136d:	85 c0                	test   %eax,%eax
  80136f:	74 0b                	je     80137c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801371:	83 ec 0c             	sub    $0xc,%esp
  801374:	56                   	push   %esi
  801375:	ff d0                	call   *%eax
  801377:	89 c3                	mov    %eax,%ebx
  801379:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	56                   	push   %esi
  801380:	6a 00                	push   $0x0
  801382:	e8 b5 f9 ff ff       	call   800d3c <sys_page_unmap>
	return r;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	89 d8                	mov    %ebx,%eax
}
  80138c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    

00801393 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801399:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139c:	50                   	push   %eax
  80139d:	ff 75 08             	pushl  0x8(%ebp)
  8013a0:	e8 c4 fe ff ff       	call   801269 <fd_lookup>
  8013a5:	83 c4 08             	add    $0x8,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 10                	js     8013bc <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	6a 01                	push   $0x1
  8013b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b4:	e8 59 ff ff ff       	call   801312 <fd_close>
  8013b9:	83 c4 10             	add    $0x10,%esp
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <close_all>:

void
close_all(void)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	53                   	push   %ebx
  8013ce:	e8 c0 ff ff ff       	call   801393 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d3:	83 c3 01             	add    $0x1,%ebx
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	83 fb 20             	cmp    $0x20,%ebx
  8013dc:	75 ec                	jne    8013ca <close_all+0xc>
		close(i);
}
  8013de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	57                   	push   %edi
  8013e7:	56                   	push   %esi
  8013e8:	53                   	push   %ebx
  8013e9:	83 ec 2c             	sub    $0x2c,%esp
  8013ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f2:	50                   	push   %eax
  8013f3:	ff 75 08             	pushl  0x8(%ebp)
  8013f6:	e8 6e fe ff ff       	call   801269 <fd_lookup>
  8013fb:	83 c4 08             	add    $0x8,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	0f 88 c1 00 00 00    	js     8014c7 <dup+0xe4>
		return r;
	close(newfdnum);
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	56                   	push   %esi
  80140a:	e8 84 ff ff ff       	call   801393 <close>

	newfd = INDEX2FD(newfdnum);
  80140f:	89 f3                	mov    %esi,%ebx
  801411:	c1 e3 0c             	shl    $0xc,%ebx
  801414:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80141a:	83 c4 04             	add    $0x4,%esp
  80141d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801420:	e8 de fd ff ff       	call   801203 <fd2data>
  801425:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801427:	89 1c 24             	mov    %ebx,(%esp)
  80142a:	e8 d4 fd ff ff       	call   801203 <fd2data>
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801435:	89 f8                	mov    %edi,%eax
  801437:	c1 e8 16             	shr    $0x16,%eax
  80143a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801441:	a8 01                	test   $0x1,%al
  801443:	74 37                	je     80147c <dup+0x99>
  801445:	89 f8                	mov    %edi,%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
  80144a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801451:	f6 c2 01             	test   $0x1,%dl
  801454:	74 26                	je     80147c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801456:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145d:	83 ec 0c             	sub    $0xc,%esp
  801460:	25 07 0e 00 00       	and    $0xe07,%eax
  801465:	50                   	push   %eax
  801466:	ff 75 d4             	pushl  -0x2c(%ebp)
  801469:	6a 00                	push   $0x0
  80146b:	57                   	push   %edi
  80146c:	6a 00                	push   $0x0
  80146e:	e8 87 f8 ff ff       	call   800cfa <sys_page_map>
  801473:	89 c7                	mov    %eax,%edi
  801475:	83 c4 20             	add    $0x20,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 2e                	js     8014aa <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80147c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80147f:	89 d0                	mov    %edx,%eax
  801481:	c1 e8 0c             	shr    $0xc,%eax
  801484:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	25 07 0e 00 00       	and    $0xe07,%eax
  801493:	50                   	push   %eax
  801494:	53                   	push   %ebx
  801495:	6a 00                	push   $0x0
  801497:	52                   	push   %edx
  801498:	6a 00                	push   $0x0
  80149a:	e8 5b f8 ff ff       	call   800cfa <sys_page_map>
  80149f:	89 c7                	mov    %eax,%edi
  8014a1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014a4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014a6:	85 ff                	test   %edi,%edi
  8014a8:	79 1d                	jns    8014c7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014aa:	83 ec 08             	sub    $0x8,%esp
  8014ad:	53                   	push   %ebx
  8014ae:	6a 00                	push   $0x0
  8014b0:	e8 87 f8 ff ff       	call   800d3c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014b5:	83 c4 08             	add    $0x8,%esp
  8014b8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014bb:	6a 00                	push   $0x0
  8014bd:	e8 7a f8 ff ff       	call   800d3c <sys_page_unmap>
	return r;
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	89 f8                	mov    %edi,%eax
}
  8014c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ca:	5b                   	pop    %ebx
  8014cb:	5e                   	pop    %esi
  8014cc:	5f                   	pop    %edi
  8014cd:	5d                   	pop    %ebp
  8014ce:	c3                   	ret    

008014cf <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 14             	sub    $0x14,%esp
  8014d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014dc:	50                   	push   %eax
  8014dd:	53                   	push   %ebx
  8014de:	e8 86 fd ff ff       	call   801269 <fd_lookup>
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 6d                	js     801559 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f6:	ff 30                	pushl  (%eax)
  8014f8:	e8 c2 fd ff ff       	call   8012bf <dev_lookup>
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 4c                	js     801550 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801504:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801507:	8b 42 08             	mov    0x8(%edx),%eax
  80150a:	83 e0 03             	and    $0x3,%eax
  80150d:	83 f8 01             	cmp    $0x1,%eax
  801510:	75 21                	jne    801533 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801512:	a1 08 40 80 00       	mov    0x804008,%eax
  801517:	8b 40 48             	mov    0x48(%eax),%eax
  80151a:	83 ec 04             	sub    $0x4,%esp
  80151d:	53                   	push   %ebx
  80151e:	50                   	push   %eax
  80151f:	68 04 2d 80 00       	push   $0x802d04
  801524:	e8 e6 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801531:	eb 26                	jmp    801559 <read+0x8a>
	}
	if (!dev->dev_read)
  801533:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801536:	8b 40 08             	mov    0x8(%eax),%eax
  801539:	85 c0                	test   %eax,%eax
  80153b:	74 17                	je     801554 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	ff 75 10             	pushl  0x10(%ebp)
  801543:	ff 75 0c             	pushl  0xc(%ebp)
  801546:	52                   	push   %edx
  801547:	ff d0                	call   *%eax
  801549:	89 c2                	mov    %eax,%edx
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	eb 09                	jmp    801559 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	89 c2                	mov    %eax,%edx
  801552:	eb 05                	jmp    801559 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801554:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801559:	89 d0                	mov    %edx,%eax
  80155b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	57                   	push   %edi
  801564:	56                   	push   %esi
  801565:	53                   	push   %ebx
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	8b 7d 08             	mov    0x8(%ebp),%edi
  80156c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80156f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801574:	eb 21                	jmp    801597 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	89 f0                	mov    %esi,%eax
  80157b:	29 d8                	sub    %ebx,%eax
  80157d:	50                   	push   %eax
  80157e:	89 d8                	mov    %ebx,%eax
  801580:	03 45 0c             	add    0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	57                   	push   %edi
  801585:	e8 45 ff ff ff       	call   8014cf <read>
		if (m < 0)
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 10                	js     8015a1 <readn+0x41>
			return m;
		if (m == 0)
  801591:	85 c0                	test   %eax,%eax
  801593:	74 0a                	je     80159f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801595:	01 c3                	add    %eax,%ebx
  801597:	39 f3                	cmp    %esi,%ebx
  801599:	72 db                	jb     801576 <readn+0x16>
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	eb 02                	jmp    8015a1 <readn+0x41>
  80159f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5e                   	pop    %esi
  8015a6:	5f                   	pop    %edi
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 14             	sub    $0x14,%esp
  8015b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	53                   	push   %ebx
  8015b8:	e8 ac fc ff ff       	call   801269 <fd_lookup>
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 68                	js     80162e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d0:	ff 30                	pushl  (%eax)
  8015d2:	e8 e8 fc ff ff       	call   8012bf <dev_lookup>
  8015d7:	83 c4 10             	add    $0x10,%esp
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 47                	js     801625 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e5:	75 21                	jne    801608 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ec:	8b 40 48             	mov    0x48(%eax),%eax
  8015ef:	83 ec 04             	sub    $0x4,%esp
  8015f2:	53                   	push   %ebx
  8015f3:	50                   	push   %eax
  8015f4:	68 20 2d 80 00       	push   $0x802d20
  8015f9:	e8 11 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801606:	eb 26                	jmp    80162e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801608:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160b:	8b 52 0c             	mov    0xc(%edx),%edx
  80160e:	85 d2                	test   %edx,%edx
  801610:	74 17                	je     801629 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801612:	83 ec 04             	sub    $0x4,%esp
  801615:	ff 75 10             	pushl  0x10(%ebp)
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	50                   	push   %eax
  80161c:	ff d2                	call   *%edx
  80161e:	89 c2                	mov    %eax,%edx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	eb 09                	jmp    80162e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	89 c2                	mov    %eax,%edx
  801627:	eb 05                	jmp    80162e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801629:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80162e:	89 d0                	mov    %edx,%eax
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <seek>:

int
seek(int fdnum, off_t offset)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80163b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	ff 75 08             	pushl  0x8(%ebp)
  801642:	e8 22 fc ff ff       	call   801269 <fd_lookup>
  801647:	83 c4 08             	add    $0x8,%esp
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 0e                	js     80165c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80164e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801651:	8b 55 0c             	mov    0xc(%ebp),%edx
  801654:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801657:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	53                   	push   %ebx
  801662:	83 ec 14             	sub    $0x14,%esp
  801665:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801668:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	53                   	push   %ebx
  80166d:	e8 f7 fb ff ff       	call   801269 <fd_lookup>
  801672:	83 c4 08             	add    $0x8,%esp
  801675:	89 c2                	mov    %eax,%edx
  801677:	85 c0                	test   %eax,%eax
  801679:	78 65                	js     8016e0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167b:	83 ec 08             	sub    $0x8,%esp
  80167e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801681:	50                   	push   %eax
  801682:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801685:	ff 30                	pushl  (%eax)
  801687:	e8 33 fc ff ff       	call   8012bf <dev_lookup>
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 44                	js     8016d7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801693:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801696:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80169a:	75 21                	jne    8016bd <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80169c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a1:	8b 40 48             	mov    0x48(%eax),%eax
  8016a4:	83 ec 04             	sub    $0x4,%esp
  8016a7:	53                   	push   %ebx
  8016a8:	50                   	push   %eax
  8016a9:	68 e0 2c 80 00       	push   $0x802ce0
  8016ae:	e8 5c ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016bb:	eb 23                	jmp    8016e0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c0:	8b 52 18             	mov    0x18(%edx),%edx
  8016c3:	85 d2                	test   %edx,%edx
  8016c5:	74 14                	je     8016db <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	ff 75 0c             	pushl  0xc(%ebp)
  8016cd:	50                   	push   %eax
  8016ce:	ff d2                	call   *%edx
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	eb 09                	jmp    8016e0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	eb 05                	jmp    8016e0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016e0:	89 d0                	mov    %edx,%eax
  8016e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    

008016e7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 14             	sub    $0x14,%esp
  8016ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f4:	50                   	push   %eax
  8016f5:	ff 75 08             	pushl  0x8(%ebp)
  8016f8:	e8 6c fb ff ff       	call   801269 <fd_lookup>
  8016fd:	83 c4 08             	add    $0x8,%esp
  801700:	89 c2                	mov    %eax,%edx
  801702:	85 c0                	test   %eax,%eax
  801704:	78 58                	js     80175e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80170c:	50                   	push   %eax
  80170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801710:	ff 30                	pushl  (%eax)
  801712:	e8 a8 fb ff ff       	call   8012bf <dev_lookup>
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 37                	js     801755 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80171e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801721:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801725:	74 32                	je     801759 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801727:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80172a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801731:	00 00 00 
	stat->st_isdir = 0;
  801734:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80173b:	00 00 00 
	stat->st_dev = dev;
  80173e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801744:	83 ec 08             	sub    $0x8,%esp
  801747:	53                   	push   %ebx
  801748:	ff 75 f0             	pushl  -0x10(%ebp)
  80174b:	ff 50 14             	call   *0x14(%eax)
  80174e:	89 c2                	mov    %eax,%edx
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	eb 09                	jmp    80175e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801755:	89 c2                	mov    %eax,%edx
  801757:	eb 05                	jmp    80175e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801759:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80175e:	89 d0                	mov    %edx,%eax
  801760:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	56                   	push   %esi
  801769:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	6a 00                	push   $0x0
  80176f:	ff 75 08             	pushl  0x8(%ebp)
  801772:	e8 ef 01 00 00       	call   801966 <open>
  801777:	89 c3                	mov    %eax,%ebx
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 1b                	js     80179b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	ff 75 0c             	pushl  0xc(%ebp)
  801786:	50                   	push   %eax
  801787:	e8 5b ff ff ff       	call   8016e7 <fstat>
  80178c:	89 c6                	mov    %eax,%esi
	close(fd);
  80178e:	89 1c 24             	mov    %ebx,(%esp)
  801791:	e8 fd fb ff ff       	call   801393 <close>
	return r;
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	89 f0                	mov    %esi,%eax
}
  80179b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	56                   	push   %esi
  8017a6:	53                   	push   %ebx
  8017a7:	89 c6                	mov    %eax,%esi
  8017a9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017ab:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b2:	75 12                	jne    8017c6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	6a 01                	push   $0x1
  8017b9:	e8 ed 0c 00 00       	call   8024ab <ipc_find_env>
  8017be:	a3 00 40 80 00       	mov    %eax,0x804000
  8017c3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c6:	6a 07                	push   $0x7
  8017c8:	68 00 50 80 00       	push   $0x805000
  8017cd:	56                   	push   %esi
  8017ce:	ff 35 00 40 80 00    	pushl  0x804000
  8017d4:	e8 83 0c 00 00       	call   80245c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017d9:	83 c4 0c             	add    $0xc,%esp
  8017dc:	6a 00                	push   $0x0
  8017de:	53                   	push   %ebx
  8017df:	6a 00                	push   $0x0
  8017e1:	e8 00 0c 00 00       	call   8023e6 <ipc_recv>
}
  8017e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e9:	5b                   	pop    %ebx
  8017ea:	5e                   	pop    %esi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801801:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801806:	ba 00 00 00 00       	mov    $0x0,%edx
  80180b:	b8 02 00 00 00       	mov    $0x2,%eax
  801810:	e8 8d ff ff ff       	call   8017a2 <fsipc>
}
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80181d:	8b 45 08             	mov    0x8(%ebp),%eax
  801820:	8b 40 0c             	mov    0xc(%eax),%eax
  801823:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 06 00 00 00       	mov    $0x6,%eax
  801832:	e8 6b ff ff ff       	call   8017a2 <fsipc>
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	53                   	push   %ebx
  80183d:	83 ec 04             	sub    $0x4,%esp
  801840:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	8b 40 0c             	mov    0xc(%eax),%eax
  801849:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80184e:	ba 00 00 00 00       	mov    $0x0,%edx
  801853:	b8 05 00 00 00       	mov    $0x5,%eax
  801858:	e8 45 ff ff ff       	call   8017a2 <fsipc>
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 2c                	js     80188d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	68 00 50 80 00       	push   $0x805000
  801869:	53                   	push   %ebx
  80186a:	e8 45 f0 ff ff       	call   8008b4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80186f:	a1 80 50 80 00       	mov    0x805080,%eax
  801874:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80187a:	a1 84 50 80 00       	mov    0x805084,%eax
  80187f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80189c:	8b 55 08             	mov    0x8(%ebp),%edx
  80189f:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018a8:	a3 04 50 80 00       	mov    %eax,0x805004
  8018ad:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8018b2:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8018b7:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018ba:	53                   	push   %ebx
  8018bb:	ff 75 0c             	pushl  0xc(%ebp)
  8018be:	68 08 50 80 00       	push   $0x805008
  8018c3:	e8 7e f1 ff ff       	call   800a46 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cd:	b8 04 00 00 00       	mov    $0x4,%eax
  8018d2:	e8 cb fe ff ff       	call   8017a2 <fsipc>
  8018d7:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8018df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 03 00 00 00       	mov    $0x3,%eax
  801907:	e8 96 fe ff ff       	call   8017a2 <fsipc>
  80190c:	89 c3                	mov    %eax,%ebx
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 4b                	js     80195d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801912:	39 c6                	cmp    %eax,%esi
  801914:	73 16                	jae    80192c <devfile_read+0x48>
  801916:	68 54 2d 80 00       	push   $0x802d54
  80191b:	68 5b 2d 80 00       	push   $0x802d5b
  801920:	6a 7c                	push   $0x7c
  801922:	68 70 2d 80 00       	push   $0x802d70
  801927:	e8 0a e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  80192c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801931:	7e 16                	jle    801949 <devfile_read+0x65>
  801933:	68 7b 2d 80 00       	push   $0x802d7b
  801938:	68 5b 2d 80 00       	push   $0x802d5b
  80193d:	6a 7d                	push   $0x7d
  80193f:	68 70 2d 80 00       	push   $0x802d70
  801944:	e8 ed e8 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801949:	83 ec 04             	sub    $0x4,%esp
  80194c:	50                   	push   %eax
  80194d:	68 00 50 80 00       	push   $0x805000
  801952:	ff 75 0c             	pushl  0xc(%ebp)
  801955:	e8 ec f0 ff ff       	call   800a46 <memmove>
	return r;
  80195a:	83 c4 10             	add    $0x10,%esp
}
  80195d:	89 d8                	mov    %ebx,%eax
  80195f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801962:	5b                   	pop    %ebx
  801963:	5e                   	pop    %esi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	53                   	push   %ebx
  80196a:	83 ec 20             	sub    $0x20,%esp
  80196d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801970:	53                   	push   %ebx
  801971:	e8 05 ef ff ff       	call   80087b <strlen>
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197e:	7f 67                	jg     8019e7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801980:	83 ec 0c             	sub    $0xc,%esp
  801983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801986:	50                   	push   %eax
  801987:	e8 8e f8 ff ff       	call   80121a <fd_alloc>
  80198c:	83 c4 10             	add    $0x10,%esp
		return r;
  80198f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801991:	85 c0                	test   %eax,%eax
  801993:	78 57                	js     8019ec <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801995:	83 ec 08             	sub    $0x8,%esp
  801998:	53                   	push   %ebx
  801999:	68 00 50 80 00       	push   $0x805000
  80199e:	e8 11 ef ff ff       	call   8008b4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b3:	e8 ea fd ff ff       	call   8017a2 <fsipc>
  8019b8:	89 c3                	mov    %eax,%ebx
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	79 14                	jns    8019d5 <open+0x6f>
		fd_close(fd, 0);
  8019c1:	83 ec 08             	sub    $0x8,%esp
  8019c4:	6a 00                	push   $0x0
  8019c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c9:	e8 44 f9 ff ff       	call   801312 <fd_close>
		return r;
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	89 da                	mov    %ebx,%edx
  8019d3:	eb 17                	jmp    8019ec <open+0x86>
	}

	return fd2num(fd);
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019db:	e8 13 f8 ff ff       	call   8011f3 <fd2num>
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	eb 05                	jmp    8019ec <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019e7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019ec:	89 d0                	mov    %edx,%eax
  8019ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801a03:	e8 9a fd ff ff       	call   8017a2 <fsipc>
}
  801a08:	c9                   	leave  
  801a09:	c3                   	ret    

00801a0a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
  801a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 75 08             	pushl  0x8(%ebp)
  801a18:	e8 e6 f7 ff ff       	call   801203 <fd2data>
  801a1d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1f:	83 c4 08             	add    $0x8,%esp
  801a22:	68 87 2d 80 00       	push   $0x802d87
  801a27:	53                   	push   %ebx
  801a28:	e8 87 ee ff ff       	call   8008b4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2d:	8b 46 04             	mov    0x4(%esi),%eax
  801a30:	2b 06                	sub    (%esi),%eax
  801a32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a38:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3f:	00 00 00 
	stat->st_dev = &devpipe;
  801a42:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a49:	30 80 00 
	return 0;
}
  801a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	53                   	push   %ebx
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a62:	53                   	push   %ebx
  801a63:	6a 00                	push   $0x0
  801a65:	e8 d2 f2 ff ff       	call   800d3c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a6a:	89 1c 24             	mov    %ebx,(%esp)
  801a6d:	e8 91 f7 ff ff       	call   801203 <fd2data>
  801a72:	83 c4 08             	add    $0x8,%esp
  801a75:	50                   	push   %eax
  801a76:	6a 00                	push   $0x0
  801a78:	e8 bf f2 ff ff       	call   800d3c <sys_page_unmap>
}
  801a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	57                   	push   %edi
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	83 ec 1c             	sub    $0x1c,%esp
  801a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a8e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a90:	a1 08 40 80 00       	mov    0x804008,%eax
  801a95:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9e:	e8 41 0a 00 00       	call   8024e4 <pageref>
  801aa3:	89 c3                	mov    %eax,%ebx
  801aa5:	89 3c 24             	mov    %edi,(%esp)
  801aa8:	e8 37 0a 00 00       	call   8024e4 <pageref>
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	39 c3                	cmp    %eax,%ebx
  801ab2:	0f 94 c1             	sete   %cl
  801ab5:	0f b6 c9             	movzbl %cl,%ecx
  801ab8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801abb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ac1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ac4:	39 ce                	cmp    %ecx,%esi
  801ac6:	74 1b                	je     801ae3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ac8:	39 c3                	cmp    %eax,%ebx
  801aca:	75 c4                	jne    801a90 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801acc:	8b 42 58             	mov    0x58(%edx),%eax
  801acf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ad2:	50                   	push   %eax
  801ad3:	56                   	push   %esi
  801ad4:	68 8e 2d 80 00       	push   $0x802d8e
  801ad9:	e8 31 e8 ff ff       	call   80030f <cprintf>
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	eb ad                	jmp    801a90 <_pipeisclosed+0xe>
	}
}
  801ae3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5f                   	pop    %edi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 28             	sub    $0x28,%esp
  801af7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801afa:	56                   	push   %esi
  801afb:	e8 03 f7 ff ff       	call   801203 <fd2data>
  801b00:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	bf 00 00 00 00       	mov    $0x0,%edi
  801b0a:	eb 4b                	jmp    801b57 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b0c:	89 da                	mov    %ebx,%edx
  801b0e:	89 f0                	mov    %esi,%eax
  801b10:	e8 6d ff ff ff       	call   801a82 <_pipeisclosed>
  801b15:	85 c0                	test   %eax,%eax
  801b17:	75 48                	jne    801b61 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b19:	e8 7a f1 ff ff       	call   800c98 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b1e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b21:	8b 0b                	mov    (%ebx),%ecx
  801b23:	8d 51 20             	lea    0x20(%ecx),%edx
  801b26:	39 d0                	cmp    %edx,%eax
  801b28:	73 e2                	jae    801b0c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b31:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b34:	89 c2                	mov    %eax,%edx
  801b36:	c1 fa 1f             	sar    $0x1f,%edx
  801b39:	89 d1                	mov    %edx,%ecx
  801b3b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b3e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b41:	83 e2 1f             	and    $0x1f,%edx
  801b44:	29 ca                	sub    %ecx,%edx
  801b46:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b4a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b4e:	83 c0 01             	add    $0x1,%eax
  801b51:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b54:	83 c7 01             	add    $0x1,%edi
  801b57:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b5a:	75 c2                	jne    801b1e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5f:	eb 05                	jmp    801b66 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b69:	5b                   	pop    %ebx
  801b6a:	5e                   	pop    %esi
  801b6b:	5f                   	pop    %edi
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 18             	sub    $0x18,%esp
  801b77:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b7a:	57                   	push   %edi
  801b7b:	e8 83 f6 ff ff       	call   801203 <fd2data>
  801b80:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b82:	83 c4 10             	add    $0x10,%esp
  801b85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b8a:	eb 3d                	jmp    801bc9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b8c:	85 db                	test   %ebx,%ebx
  801b8e:	74 04                	je     801b94 <devpipe_read+0x26>
				return i;
  801b90:	89 d8                	mov    %ebx,%eax
  801b92:	eb 44                	jmp    801bd8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b94:	89 f2                	mov    %esi,%edx
  801b96:	89 f8                	mov    %edi,%eax
  801b98:	e8 e5 fe ff ff       	call   801a82 <_pipeisclosed>
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	75 32                	jne    801bd3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ba1:	e8 f2 f0 ff ff       	call   800c98 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ba6:	8b 06                	mov    (%esi),%eax
  801ba8:	3b 46 04             	cmp    0x4(%esi),%eax
  801bab:	74 df                	je     801b8c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bad:	99                   	cltd   
  801bae:	c1 ea 1b             	shr    $0x1b,%edx
  801bb1:	01 d0                	add    %edx,%eax
  801bb3:	83 e0 1f             	and    $0x1f,%eax
  801bb6:	29 d0                	sub    %edx,%eax
  801bb8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bc3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc6:	83 c3 01             	add    $0x1,%ebx
  801bc9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bcc:	75 d8                	jne    801ba6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bce:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd1:	eb 05                	jmp    801bd8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5f                   	pop    %edi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    

00801be0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	56                   	push   %esi
  801be4:	53                   	push   %ebx
  801be5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801beb:	50                   	push   %eax
  801bec:	e8 29 f6 ff ff       	call   80121a <fd_alloc>
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	89 c2                	mov    %eax,%edx
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	0f 88 2c 01 00 00    	js     801d2a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfe:	83 ec 04             	sub    $0x4,%esp
  801c01:	68 07 04 00 00       	push   $0x407
  801c06:	ff 75 f4             	pushl  -0xc(%ebp)
  801c09:	6a 00                	push   $0x0
  801c0b:	e8 a7 f0 ff ff       	call   800cb7 <sys_page_alloc>
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	89 c2                	mov    %eax,%edx
  801c15:	85 c0                	test   %eax,%eax
  801c17:	0f 88 0d 01 00 00    	js     801d2a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c1d:	83 ec 0c             	sub    $0xc,%esp
  801c20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c23:	50                   	push   %eax
  801c24:	e8 f1 f5 ff ff       	call   80121a <fd_alloc>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	0f 88 e2 00 00 00    	js     801d18 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c36:	83 ec 04             	sub    $0x4,%esp
  801c39:	68 07 04 00 00       	push   $0x407
  801c3e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c41:	6a 00                	push   $0x0
  801c43:	e8 6f f0 ff ff       	call   800cb7 <sys_page_alloc>
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	83 c4 10             	add    $0x10,%esp
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	0f 88 c3 00 00 00    	js     801d18 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5b:	e8 a3 f5 ff ff       	call   801203 <fd2data>
  801c60:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c62:	83 c4 0c             	add    $0xc,%esp
  801c65:	68 07 04 00 00       	push   $0x407
  801c6a:	50                   	push   %eax
  801c6b:	6a 00                	push   $0x0
  801c6d:	e8 45 f0 ff ff       	call   800cb7 <sys_page_alloc>
  801c72:	89 c3                	mov    %eax,%ebx
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	85 c0                	test   %eax,%eax
  801c79:	0f 88 89 00 00 00    	js     801d08 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7f:	83 ec 0c             	sub    $0xc,%esp
  801c82:	ff 75 f0             	pushl  -0x10(%ebp)
  801c85:	e8 79 f5 ff ff       	call   801203 <fd2data>
  801c8a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c91:	50                   	push   %eax
  801c92:	6a 00                	push   $0x0
  801c94:	56                   	push   %esi
  801c95:	6a 00                	push   $0x0
  801c97:	e8 5e f0 ff ff       	call   800cfa <sys_page_map>
  801c9c:	89 c3                	mov    %eax,%ebx
  801c9e:	83 c4 20             	add    $0x20,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	78 55                	js     801cfa <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ca5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cae:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cba:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ccf:	83 ec 0c             	sub    $0xc,%esp
  801cd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd5:	e8 19 f5 ff ff       	call   8011f3 <fd2num>
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cdf:	83 c4 04             	add    $0x4,%esp
  801ce2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce5:	e8 09 f5 ff ff       	call   8011f3 <fd2num>
  801cea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ced:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf0:	83 c4 10             	add    $0x10,%esp
  801cf3:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf8:	eb 30                	jmp    801d2a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cfa:	83 ec 08             	sub    $0x8,%esp
  801cfd:	56                   	push   %esi
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 37 f0 ff ff       	call   800d3c <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 27 f0 ff ff       	call   800d3c <sys_page_unmap>
  801d15:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d18:	83 ec 08             	sub    $0x8,%esp
  801d1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1e:	6a 00                	push   $0x0
  801d20:	e8 17 f0 ff ff       	call   800d3c <sys_page_unmap>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3c:	50                   	push   %eax
  801d3d:	ff 75 08             	pushl  0x8(%ebp)
  801d40:	e8 24 f5 ff ff       	call   801269 <fd_lookup>
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	85 c0                	test   %eax,%eax
  801d4a:	78 18                	js     801d64 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d4c:	83 ec 0c             	sub    $0xc,%esp
  801d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d52:	e8 ac f4 ff ff       	call   801203 <fd2data>
	return _pipeisclosed(fd, p);
  801d57:	89 c2                	mov    %eax,%edx
  801d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5c:	e8 21 fd ff ff       	call   801a82 <_pipeisclosed>
  801d61:	83 c4 10             	add    $0x10,%esp
}
  801d64:	c9                   	leave  
  801d65:	c3                   	ret    

00801d66 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d6c:	68 a6 2d 80 00       	push   $0x802da6
  801d71:	ff 75 0c             	pushl  0xc(%ebp)
  801d74:	e8 3b eb ff ff       	call   8008b4 <strcpy>
	return 0;
}
  801d79:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	53                   	push   %ebx
  801d84:	83 ec 10             	sub    $0x10,%esp
  801d87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d8a:	53                   	push   %ebx
  801d8b:	e8 54 07 00 00       	call   8024e4 <pageref>
  801d90:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d93:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d98:	83 f8 01             	cmp    $0x1,%eax
  801d9b:	75 10                	jne    801dad <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d9d:	83 ec 0c             	sub    $0xc,%esp
  801da0:	ff 73 0c             	pushl  0xc(%ebx)
  801da3:	e8 c0 02 00 00       	call   802068 <nsipc_close>
  801da8:	89 c2                	mov    %eax,%edx
  801daa:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801dad:	89 d0                	mov    %edx,%eax
  801daf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801dba:	6a 00                	push   $0x0
  801dbc:	ff 75 10             	pushl  0x10(%ebp)
  801dbf:	ff 75 0c             	pushl  0xc(%ebp)
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	ff 70 0c             	pushl  0xc(%eax)
  801dc8:	e8 78 03 00 00       	call   802145 <nsipc_send>
}
  801dcd:	c9                   	leave  
  801dce:	c3                   	ret    

00801dcf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801dd5:	6a 00                	push   $0x0
  801dd7:	ff 75 10             	pushl  0x10(%ebp)
  801dda:	ff 75 0c             	pushl  0xc(%ebp)
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	ff 70 0c             	pushl  0xc(%eax)
  801de3:	e8 f1 02 00 00       	call   8020d9 <nsipc_recv>
}
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801df0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801df3:	52                   	push   %edx
  801df4:	50                   	push   %eax
  801df5:	e8 6f f4 ff ff       	call   801269 <fd_lookup>
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 17                	js     801e18 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e04:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801e0a:	39 08                	cmp    %ecx,(%eax)
  801e0c:	75 05                	jne    801e13 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e0e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e11:	eb 05                	jmp    801e18 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e13:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	56                   	push   %esi
  801e1e:	53                   	push   %ebx
  801e1f:	83 ec 1c             	sub    $0x1c,%esp
  801e22:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e27:	50                   	push   %eax
  801e28:	e8 ed f3 ff ff       	call   80121a <fd_alloc>
  801e2d:	89 c3                	mov    %eax,%ebx
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	85 c0                	test   %eax,%eax
  801e34:	78 1b                	js     801e51 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e36:	83 ec 04             	sub    $0x4,%esp
  801e39:	68 07 04 00 00       	push   $0x407
  801e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e41:	6a 00                	push   $0x0
  801e43:	e8 6f ee ff ff       	call   800cb7 <sys_page_alloc>
  801e48:	89 c3                	mov    %eax,%ebx
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	79 10                	jns    801e61 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e51:	83 ec 0c             	sub    $0xc,%esp
  801e54:	56                   	push   %esi
  801e55:	e8 0e 02 00 00       	call   802068 <nsipc_close>
		return r;
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	89 d8                	mov    %ebx,%eax
  801e5f:	eb 24                	jmp    801e85 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e76:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	50                   	push   %eax
  801e7d:	e8 71 f3 ff ff       	call   8011f3 <fd2num>
  801e82:	83 c4 10             	add    $0x10,%esp
}
  801e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e92:	8b 45 08             	mov    0x8(%ebp),%eax
  801e95:	e8 50 ff ff ff       	call   801dea <fd2sockid>
		return r;
  801e9a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	78 1f                	js     801ebf <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ea0:	83 ec 04             	sub    $0x4,%esp
  801ea3:	ff 75 10             	pushl  0x10(%ebp)
  801ea6:	ff 75 0c             	pushl  0xc(%ebp)
  801ea9:	50                   	push   %eax
  801eaa:	e8 12 01 00 00       	call   801fc1 <nsipc_accept>
  801eaf:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb2:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	78 07                	js     801ebf <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801eb8:	e8 5d ff ff ff       	call   801e1a <alloc_sockfd>
  801ebd:	89 c1                	mov    %eax,%ecx
}
  801ebf:	89 c8                	mov    %ecx,%eax
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	e8 19 ff ff ff       	call   801dea <fd2sockid>
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 12                	js     801ee7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801ed5:	83 ec 04             	sub    $0x4,%esp
  801ed8:	ff 75 10             	pushl  0x10(%ebp)
  801edb:	ff 75 0c             	pushl  0xc(%ebp)
  801ede:	50                   	push   %eax
  801edf:	e8 2d 01 00 00       	call   802011 <nsipc_bind>
  801ee4:	83 c4 10             	add    $0x10,%esp
}
  801ee7:	c9                   	leave  
  801ee8:	c3                   	ret    

00801ee9 <shutdown>:

int
shutdown(int s, int how)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef2:	e8 f3 fe ff ff       	call   801dea <fd2sockid>
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	78 0f                	js     801f0a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801efb:	83 ec 08             	sub    $0x8,%esp
  801efe:	ff 75 0c             	pushl  0xc(%ebp)
  801f01:	50                   	push   %eax
  801f02:	e8 3f 01 00 00       	call   802046 <nsipc_shutdown>
  801f07:	83 c4 10             	add    $0x10,%esp
}
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f12:	8b 45 08             	mov    0x8(%ebp),%eax
  801f15:	e8 d0 fe ff ff       	call   801dea <fd2sockid>
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	78 12                	js     801f30 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f1e:	83 ec 04             	sub    $0x4,%esp
  801f21:	ff 75 10             	pushl  0x10(%ebp)
  801f24:	ff 75 0c             	pushl  0xc(%ebp)
  801f27:	50                   	push   %eax
  801f28:	e8 55 01 00 00       	call   802082 <nsipc_connect>
  801f2d:	83 c4 10             	add    $0x10,%esp
}
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <listen>:

int
listen(int s, int backlog)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f38:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3b:	e8 aa fe ff ff       	call   801dea <fd2sockid>
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 0f                	js     801f53 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f44:	83 ec 08             	sub    $0x8,%esp
  801f47:	ff 75 0c             	pushl  0xc(%ebp)
  801f4a:	50                   	push   %eax
  801f4b:	e8 67 01 00 00       	call   8020b7 <nsipc_listen>
  801f50:	83 c4 10             	add    $0x10,%esp
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f5b:	ff 75 10             	pushl  0x10(%ebp)
  801f5e:	ff 75 0c             	pushl  0xc(%ebp)
  801f61:	ff 75 08             	pushl  0x8(%ebp)
  801f64:	e8 3a 02 00 00       	call   8021a3 <nsipc_socket>
  801f69:	83 c4 10             	add    $0x10,%esp
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	78 05                	js     801f75 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f70:	e8 a5 fe ff ff       	call   801e1a <alloc_sockfd>
}
  801f75:	c9                   	leave  
  801f76:	c3                   	ret    

00801f77 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	53                   	push   %ebx
  801f7b:	83 ec 04             	sub    $0x4,%esp
  801f7e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f80:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801f87:	75 12                	jne    801f9b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	6a 02                	push   $0x2
  801f8e:	e8 18 05 00 00       	call   8024ab <ipc_find_env>
  801f93:	a3 04 40 80 00       	mov    %eax,0x804004
  801f98:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f9b:	6a 07                	push   $0x7
  801f9d:	68 00 60 80 00       	push   $0x806000
  801fa2:	53                   	push   %ebx
  801fa3:	ff 35 04 40 80 00    	pushl  0x804004
  801fa9:	e8 ae 04 00 00       	call   80245c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801fae:	83 c4 0c             	add    $0xc,%esp
  801fb1:	6a 00                	push   $0x0
  801fb3:	6a 00                	push   $0x0
  801fb5:	6a 00                	push   $0x0
  801fb7:	e8 2a 04 00 00       	call   8023e6 <ipc_recv>
}
  801fbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fbf:	c9                   	leave  
  801fc0:	c3                   	ret    

00801fc1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	56                   	push   %esi
  801fc5:	53                   	push   %ebx
  801fc6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fd1:	8b 06                	mov    (%esi),%eax
  801fd3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fd8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdd:	e8 95 ff ff ff       	call   801f77 <nsipc>
  801fe2:	89 c3                	mov    %eax,%ebx
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	78 20                	js     802008 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fe8:	83 ec 04             	sub    $0x4,%esp
  801feb:	ff 35 10 60 80 00    	pushl  0x806010
  801ff1:	68 00 60 80 00       	push   $0x806000
  801ff6:	ff 75 0c             	pushl  0xc(%ebp)
  801ff9:	e8 48 ea ff ff       	call   800a46 <memmove>
		*addrlen = ret->ret_addrlen;
  801ffe:	a1 10 60 80 00       	mov    0x806010,%eax
  802003:	89 06                	mov    %eax,(%esi)
  802005:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	53                   	push   %ebx
  802015:	83 ec 08             	sub    $0x8,%esp
  802018:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80201b:	8b 45 08             	mov    0x8(%ebp),%eax
  80201e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802023:	53                   	push   %ebx
  802024:	ff 75 0c             	pushl  0xc(%ebp)
  802027:	68 04 60 80 00       	push   $0x806004
  80202c:	e8 15 ea ff ff       	call   800a46 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802031:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  802037:	b8 02 00 00 00       	mov    $0x2,%eax
  80203c:	e8 36 ff ff ff       	call   801f77 <nsipc>
}
  802041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
  80204f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802054:	8b 45 0c             	mov    0xc(%ebp),%eax
  802057:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80205c:	b8 03 00 00 00       	mov    $0x3,%eax
  802061:	e8 11 ff ff ff       	call   801f77 <nsipc>
}
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <nsipc_close>:

int
nsipc_close(int s)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80206e:	8b 45 08             	mov    0x8(%ebp),%eax
  802071:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802076:	b8 04 00 00 00       	mov    $0x4,%eax
  80207b:	e8 f7 fe ff ff       	call   801f77 <nsipc>
}
  802080:	c9                   	leave  
  802081:	c3                   	ret    

00802082 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802082:	55                   	push   %ebp
  802083:	89 e5                	mov    %esp,%ebp
  802085:	53                   	push   %ebx
  802086:	83 ec 08             	sub    $0x8,%esp
  802089:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80208c:	8b 45 08             	mov    0x8(%ebp),%eax
  80208f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802094:	53                   	push   %ebx
  802095:	ff 75 0c             	pushl  0xc(%ebp)
  802098:	68 04 60 80 00       	push   $0x806004
  80209d:	e8 a4 e9 ff ff       	call   800a46 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020a2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8020a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8020ad:	e8 c5 fe ff ff       	call   801f77 <nsipc>
}
  8020b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020b5:	c9                   	leave  
  8020b6:	c3                   	ret    

008020b7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8020b7:	55                   	push   %ebp
  8020b8:	89 e5                	mov    %esp,%ebp
  8020ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8020cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8020d2:	e8 a0 fe ff ff       	call   801f77 <nsipc>
}
  8020d7:	c9                   	leave  
  8020d8:	c3                   	ret    

008020d9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	56                   	push   %esi
  8020dd:	53                   	push   %ebx
  8020de:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8020e9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8020ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8020f2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020f7:	b8 07 00 00 00       	mov    $0x7,%eax
  8020fc:	e8 76 fe ff ff       	call   801f77 <nsipc>
  802101:	89 c3                	mov    %eax,%ebx
  802103:	85 c0                	test   %eax,%eax
  802105:	78 35                	js     80213c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802107:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80210c:	7f 04                	jg     802112 <nsipc_recv+0x39>
  80210e:	39 c6                	cmp    %eax,%esi
  802110:	7d 16                	jge    802128 <nsipc_recv+0x4f>
  802112:	68 b2 2d 80 00       	push   $0x802db2
  802117:	68 5b 2d 80 00       	push   $0x802d5b
  80211c:	6a 62                	push   $0x62
  80211e:	68 c7 2d 80 00       	push   $0x802dc7
  802123:	e8 0e e1 ff ff       	call   800236 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802128:	83 ec 04             	sub    $0x4,%esp
  80212b:	50                   	push   %eax
  80212c:	68 00 60 80 00       	push   $0x806000
  802131:	ff 75 0c             	pushl  0xc(%ebp)
  802134:	e8 0d e9 ff ff       	call   800a46 <memmove>
  802139:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802141:	5b                   	pop    %ebx
  802142:	5e                   	pop    %esi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	53                   	push   %ebx
  802149:	83 ec 04             	sub    $0x4,%esp
  80214c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80214f:	8b 45 08             	mov    0x8(%ebp),%eax
  802152:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802157:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80215d:	7e 16                	jle    802175 <nsipc_send+0x30>
  80215f:	68 d3 2d 80 00       	push   $0x802dd3
  802164:	68 5b 2d 80 00       	push   $0x802d5b
  802169:	6a 6d                	push   $0x6d
  80216b:	68 c7 2d 80 00       	push   $0x802dc7
  802170:	e8 c1 e0 ff ff       	call   800236 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802175:	83 ec 04             	sub    $0x4,%esp
  802178:	53                   	push   %ebx
  802179:	ff 75 0c             	pushl  0xc(%ebp)
  80217c:	68 0c 60 80 00       	push   $0x80600c
  802181:	e8 c0 e8 ff ff       	call   800a46 <memmove>
	nsipcbuf.send.req_size = size;
  802186:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80218c:	8b 45 14             	mov    0x14(%ebp),%eax
  80218f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802194:	b8 08 00 00 00       	mov    $0x8,%eax
  802199:	e8 d9 fd ff ff       	call   801f77 <nsipc>
}
  80219e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a1:	c9                   	leave  
  8021a2:	c3                   	ret    

008021a3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8021a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8021b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8021b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8021bc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021c1:	b8 09 00 00 00       	mov    $0x9,%eax
  8021c6:	e8 ac fd ff ff       	call   801f77 <nsipc>
}
  8021cb:	c9                   	leave  
  8021cc:	c3                   	ret    

008021cd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021cd:	55                   	push   %ebp
  8021ce:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d5:	5d                   	pop    %ebp
  8021d6:	c3                   	ret    

008021d7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021d7:	55                   	push   %ebp
  8021d8:	89 e5                	mov    %esp,%ebp
  8021da:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021dd:	68 df 2d 80 00       	push   $0x802ddf
  8021e2:	ff 75 0c             	pushl  0xc(%ebp)
  8021e5:	e8 ca e6 ff ff       	call   8008b4 <strcpy>
	return 0;
}
  8021ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    

008021f1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	57                   	push   %edi
  8021f5:	56                   	push   %esi
  8021f6:	53                   	push   %ebx
  8021f7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021fd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802202:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802208:	eb 2d                	jmp    802237 <devcons_write+0x46>
		m = n - tot;
  80220a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80220d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80220f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802212:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802217:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80221a:	83 ec 04             	sub    $0x4,%esp
  80221d:	53                   	push   %ebx
  80221e:	03 45 0c             	add    0xc(%ebp),%eax
  802221:	50                   	push   %eax
  802222:	57                   	push   %edi
  802223:	e8 1e e8 ff ff       	call   800a46 <memmove>
		sys_cputs(buf, m);
  802228:	83 c4 08             	add    $0x8,%esp
  80222b:	53                   	push   %ebx
  80222c:	57                   	push   %edi
  80222d:	e8 c9 e9 ff ff       	call   800bfb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802232:	01 de                	add    %ebx,%esi
  802234:	83 c4 10             	add    $0x10,%esp
  802237:	89 f0                	mov    %esi,%eax
  802239:	3b 75 10             	cmp    0x10(%ebp),%esi
  80223c:	72 cc                	jb     80220a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80223e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802241:	5b                   	pop    %ebx
  802242:	5e                   	pop    %esi
  802243:	5f                   	pop    %edi
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    

00802246 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 08             	sub    $0x8,%esp
  80224c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802251:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802255:	74 2a                	je     802281 <devcons_read+0x3b>
  802257:	eb 05                	jmp    80225e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802259:	e8 3a ea ff ff       	call   800c98 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80225e:	e8 b6 e9 ff ff       	call   800c19 <sys_cgetc>
  802263:	85 c0                	test   %eax,%eax
  802265:	74 f2                	je     802259 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802267:	85 c0                	test   %eax,%eax
  802269:	78 16                	js     802281 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80226b:	83 f8 04             	cmp    $0x4,%eax
  80226e:	74 0c                	je     80227c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802270:	8b 55 0c             	mov    0xc(%ebp),%edx
  802273:	88 02                	mov    %al,(%edx)
	return 1;
  802275:	b8 01 00 00 00       	mov    $0x1,%eax
  80227a:	eb 05                	jmp    802281 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80227c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802281:	c9                   	leave  
  802282:	c3                   	ret    

00802283 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802289:	8b 45 08             	mov    0x8(%ebp),%eax
  80228c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80228f:	6a 01                	push   $0x1
  802291:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802294:	50                   	push   %eax
  802295:	e8 61 e9 ff ff       	call   800bfb <sys_cputs>
}
  80229a:	83 c4 10             	add    $0x10,%esp
  80229d:	c9                   	leave  
  80229e:	c3                   	ret    

0080229f <getchar>:

int
getchar(void)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022a5:	6a 01                	push   $0x1
  8022a7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022aa:	50                   	push   %eax
  8022ab:	6a 00                	push   $0x0
  8022ad:	e8 1d f2 ff ff       	call   8014cf <read>
	if (r < 0)
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	85 c0                	test   %eax,%eax
  8022b7:	78 0f                	js     8022c8 <getchar+0x29>
		return r;
	if (r < 1)
  8022b9:	85 c0                	test   %eax,%eax
  8022bb:	7e 06                	jle    8022c3 <getchar+0x24>
		return -E_EOF;
	return c;
  8022bd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022c1:	eb 05                	jmp    8022c8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022c3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022c8:	c9                   	leave  
  8022c9:	c3                   	ret    

008022ca <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022ca:	55                   	push   %ebp
  8022cb:	89 e5                	mov    %esp,%ebp
  8022cd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d3:	50                   	push   %eax
  8022d4:	ff 75 08             	pushl  0x8(%ebp)
  8022d7:	e8 8d ef ff ff       	call   801269 <fd_lookup>
  8022dc:	83 c4 10             	add    $0x10,%esp
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 11                	js     8022f4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ec:	39 10                	cmp    %edx,(%eax)
  8022ee:	0f 94 c0             	sete   %al
  8022f1:	0f b6 c0             	movzbl %al,%eax
}
  8022f4:	c9                   	leave  
  8022f5:	c3                   	ret    

008022f6 <opencons>:

int
opencons(void)
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ff:	50                   	push   %eax
  802300:	e8 15 ef ff ff       	call   80121a <fd_alloc>
  802305:	83 c4 10             	add    $0x10,%esp
		return r;
  802308:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80230a:	85 c0                	test   %eax,%eax
  80230c:	78 3e                	js     80234c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80230e:	83 ec 04             	sub    $0x4,%esp
  802311:	68 07 04 00 00       	push   $0x407
  802316:	ff 75 f4             	pushl  -0xc(%ebp)
  802319:	6a 00                	push   $0x0
  80231b:	e8 97 e9 ff ff       	call   800cb7 <sys_page_alloc>
  802320:	83 c4 10             	add    $0x10,%esp
		return r;
  802323:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802325:	85 c0                	test   %eax,%eax
  802327:	78 23                	js     80234c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802329:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80232f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802332:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802337:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80233e:	83 ec 0c             	sub    $0xc,%esp
  802341:	50                   	push   %eax
  802342:	e8 ac ee ff ff       	call   8011f3 <fd2num>
  802347:	89 c2                	mov    %eax,%edx
  802349:	83 c4 10             	add    $0x10,%esp
}
  80234c:	89 d0                	mov    %edx,%eax
  80234e:	c9                   	leave  
  80234f:	c3                   	ret    

00802350 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
  802353:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802356:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80235d:	75 56                	jne    8023b5 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80235f:	83 ec 04             	sub    $0x4,%esp
  802362:	6a 07                	push   $0x7
  802364:	68 00 f0 bf ee       	push   $0xeebff000
  802369:	6a 00                	push   $0x0
  80236b:	e8 47 e9 ff ff       	call   800cb7 <sys_page_alloc>
  802370:	83 c4 10             	add    $0x10,%esp
  802373:	85 c0                	test   %eax,%eax
  802375:	74 14                	je     80238b <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  802377:	83 ec 04             	sub    $0x4,%esp
  80237a:	68 69 2c 80 00       	push   $0x802c69
  80237f:	6a 21                	push   $0x21
  802381:	68 eb 2d 80 00       	push   $0x802deb
  802386:	e8 ab de ff ff       	call   800236 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  80238b:	83 ec 08             	sub    $0x8,%esp
  80238e:	68 bf 23 80 00       	push   $0x8023bf
  802393:	6a 00                	push   $0x0
  802395:	e8 68 ea ff ff       	call   800e02 <sys_env_set_pgfault_upcall>
  80239a:	83 c4 10             	add    $0x10,%esp
  80239d:	85 c0                	test   %eax,%eax
  80239f:	74 14                	je     8023b5 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8023a1:	83 ec 04             	sub    $0x4,%esp
  8023a4:	68 f9 2d 80 00       	push   $0x802df9
  8023a9:	6a 23                	push   $0x23
  8023ab:	68 eb 2d 80 00       	push   $0x802deb
  8023b0:	e8 81 de ff ff       	call   800236 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023bd:	c9                   	leave  
  8023be:	c3                   	ret    

008023bf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023bf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023c0:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023c5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023c7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8023ca:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8023cc:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8023d0:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8023d4:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8023d5:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8023d7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8023dc:	83 c4 08             	add    $0x8,%esp
	popal
  8023df:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8023e0:	83 c4 04             	add    $0x4,%esp
	popfl
  8023e3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023e4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023e5:	c3                   	ret    

008023e6 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023e6:	55                   	push   %ebp
  8023e7:	89 e5                	mov    %esp,%ebp
  8023e9:	56                   	push   %esi
  8023ea:	53                   	push   %ebx
  8023eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8023ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	74 0e                	je     802406 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8023f8:	83 ec 0c             	sub    $0xc,%esp
  8023fb:	50                   	push   %eax
  8023fc:	e8 66 ea ff ff       	call   800e67 <sys_ipc_recv>
  802401:	83 c4 10             	add    $0x10,%esp
  802404:	eb 10                	jmp    802416 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802406:	83 ec 0c             	sub    $0xc,%esp
  802409:	68 00 00 c0 ee       	push   $0xeec00000
  80240e:	e8 54 ea ff ff       	call   800e67 <sys_ipc_recv>
  802413:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802416:	85 c0                	test   %eax,%eax
  802418:	79 17                	jns    802431 <ipc_recv+0x4b>
		if(*from_env_store)
  80241a:	83 3e 00             	cmpl   $0x0,(%esi)
  80241d:	74 06                	je     802425 <ipc_recv+0x3f>
			*from_env_store = 0;
  80241f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802425:	85 db                	test   %ebx,%ebx
  802427:	74 2c                	je     802455 <ipc_recv+0x6f>
			*perm_store = 0;
  802429:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80242f:	eb 24                	jmp    802455 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802431:	85 f6                	test   %esi,%esi
  802433:	74 0a                	je     80243f <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802435:	a1 08 40 80 00       	mov    0x804008,%eax
  80243a:	8b 40 74             	mov    0x74(%eax),%eax
  80243d:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80243f:	85 db                	test   %ebx,%ebx
  802441:	74 0a                	je     80244d <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802443:	a1 08 40 80 00       	mov    0x804008,%eax
  802448:	8b 40 78             	mov    0x78(%eax),%eax
  80244b:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80244d:	a1 08 40 80 00       	mov    0x804008,%eax
  802452:	8b 40 70             	mov    0x70(%eax),%eax
}
  802455:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802458:	5b                   	pop    %ebx
  802459:	5e                   	pop    %esi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    

0080245c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
  80245f:	57                   	push   %edi
  802460:	56                   	push   %esi
  802461:	53                   	push   %ebx
  802462:	83 ec 0c             	sub    $0xc,%esp
  802465:	8b 7d 08             	mov    0x8(%ebp),%edi
  802468:	8b 75 0c             	mov    0xc(%ebp),%esi
  80246b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80246e:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802470:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802475:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802478:	e8 1b e8 ff ff       	call   800c98 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80247d:	ff 75 14             	pushl  0x14(%ebp)
  802480:	53                   	push   %ebx
  802481:	56                   	push   %esi
  802482:	57                   	push   %edi
  802483:	e8 bc e9 ff ff       	call   800e44 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802488:	89 c2                	mov    %eax,%edx
  80248a:	f7 d2                	not    %edx
  80248c:	c1 ea 1f             	shr    $0x1f,%edx
  80248f:	83 c4 10             	add    $0x10,%esp
  802492:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802495:	0f 94 c1             	sete   %cl
  802498:	09 ca                	or     %ecx,%edx
  80249a:	85 c0                	test   %eax,%eax
  80249c:	0f 94 c0             	sete   %al
  80249f:	38 c2                	cmp    %al,%dl
  8024a1:	77 d5                	ja     802478 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8024a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024a6:	5b                   	pop    %ebx
  8024a7:	5e                   	pop    %esi
  8024a8:	5f                   	pop    %edi
  8024a9:	5d                   	pop    %ebp
  8024aa:	c3                   	ret    

008024ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024ab:	55                   	push   %ebp
  8024ac:	89 e5                	mov    %esp,%ebp
  8024ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8024b1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024b6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024bf:	8b 52 50             	mov    0x50(%edx),%edx
  8024c2:	39 ca                	cmp    %ecx,%edx
  8024c4:	75 0d                	jne    8024d3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8024c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ce:	8b 40 48             	mov    0x48(%eax),%eax
  8024d1:	eb 0f                	jmp    8024e2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024d3:	83 c0 01             	add    $0x1,%eax
  8024d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024db:	75 d9                	jne    8024b6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    

008024e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024e4:	55                   	push   %ebp
  8024e5:	89 e5                	mov    %esp,%ebp
  8024e7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024ea:	89 d0                	mov    %edx,%eax
  8024ec:	c1 e8 16             	shr    $0x16,%eax
  8024ef:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024f6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024fb:	f6 c1 01             	test   $0x1,%cl
  8024fe:	74 1d                	je     80251d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802500:	c1 ea 0c             	shr    $0xc,%edx
  802503:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80250a:	f6 c2 01             	test   $0x1,%dl
  80250d:	74 0e                	je     80251d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80250f:	c1 ea 0c             	shr    $0xc,%edx
  802512:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802519:	ef 
  80251a:	0f b7 c0             	movzwl %ax,%eax
}
  80251d:	5d                   	pop    %ebp
  80251e:	c3                   	ret    
  80251f:	90                   	nop

00802520 <__udivdi3>:
  802520:	55                   	push   %ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	53                   	push   %ebx
  802524:	83 ec 1c             	sub    $0x1c,%esp
  802527:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80252b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80252f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802533:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802537:	85 f6                	test   %esi,%esi
  802539:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80253d:	89 ca                	mov    %ecx,%edx
  80253f:	89 f8                	mov    %edi,%eax
  802541:	75 3d                	jne    802580 <__udivdi3+0x60>
  802543:	39 cf                	cmp    %ecx,%edi
  802545:	0f 87 c5 00 00 00    	ja     802610 <__udivdi3+0xf0>
  80254b:	85 ff                	test   %edi,%edi
  80254d:	89 fd                	mov    %edi,%ebp
  80254f:	75 0b                	jne    80255c <__udivdi3+0x3c>
  802551:	b8 01 00 00 00       	mov    $0x1,%eax
  802556:	31 d2                	xor    %edx,%edx
  802558:	f7 f7                	div    %edi
  80255a:	89 c5                	mov    %eax,%ebp
  80255c:	89 c8                	mov    %ecx,%eax
  80255e:	31 d2                	xor    %edx,%edx
  802560:	f7 f5                	div    %ebp
  802562:	89 c1                	mov    %eax,%ecx
  802564:	89 d8                	mov    %ebx,%eax
  802566:	89 cf                	mov    %ecx,%edi
  802568:	f7 f5                	div    %ebp
  80256a:	89 c3                	mov    %eax,%ebx
  80256c:	89 d8                	mov    %ebx,%eax
  80256e:	89 fa                	mov    %edi,%edx
  802570:	83 c4 1c             	add    $0x1c,%esp
  802573:	5b                   	pop    %ebx
  802574:	5e                   	pop    %esi
  802575:	5f                   	pop    %edi
  802576:	5d                   	pop    %ebp
  802577:	c3                   	ret    
  802578:	90                   	nop
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	39 ce                	cmp    %ecx,%esi
  802582:	77 74                	ja     8025f8 <__udivdi3+0xd8>
  802584:	0f bd fe             	bsr    %esi,%edi
  802587:	83 f7 1f             	xor    $0x1f,%edi
  80258a:	0f 84 98 00 00 00    	je     802628 <__udivdi3+0x108>
  802590:	bb 20 00 00 00       	mov    $0x20,%ebx
  802595:	89 f9                	mov    %edi,%ecx
  802597:	89 c5                	mov    %eax,%ebp
  802599:	29 fb                	sub    %edi,%ebx
  80259b:	d3 e6                	shl    %cl,%esi
  80259d:	89 d9                	mov    %ebx,%ecx
  80259f:	d3 ed                	shr    %cl,%ebp
  8025a1:	89 f9                	mov    %edi,%ecx
  8025a3:	d3 e0                	shl    %cl,%eax
  8025a5:	09 ee                	or     %ebp,%esi
  8025a7:	89 d9                	mov    %ebx,%ecx
  8025a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025ad:	89 d5                	mov    %edx,%ebp
  8025af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025b3:	d3 ed                	shr    %cl,%ebp
  8025b5:	89 f9                	mov    %edi,%ecx
  8025b7:	d3 e2                	shl    %cl,%edx
  8025b9:	89 d9                	mov    %ebx,%ecx
  8025bb:	d3 e8                	shr    %cl,%eax
  8025bd:	09 c2                	or     %eax,%edx
  8025bf:	89 d0                	mov    %edx,%eax
  8025c1:	89 ea                	mov    %ebp,%edx
  8025c3:	f7 f6                	div    %esi
  8025c5:	89 d5                	mov    %edx,%ebp
  8025c7:	89 c3                	mov    %eax,%ebx
  8025c9:	f7 64 24 0c          	mull   0xc(%esp)
  8025cd:	39 d5                	cmp    %edx,%ebp
  8025cf:	72 10                	jb     8025e1 <__udivdi3+0xc1>
  8025d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025d5:	89 f9                	mov    %edi,%ecx
  8025d7:	d3 e6                	shl    %cl,%esi
  8025d9:	39 c6                	cmp    %eax,%esi
  8025db:	73 07                	jae    8025e4 <__udivdi3+0xc4>
  8025dd:	39 d5                	cmp    %edx,%ebp
  8025df:	75 03                	jne    8025e4 <__udivdi3+0xc4>
  8025e1:	83 eb 01             	sub    $0x1,%ebx
  8025e4:	31 ff                	xor    %edi,%edi
  8025e6:	89 d8                	mov    %ebx,%eax
  8025e8:	89 fa                	mov    %edi,%edx
  8025ea:	83 c4 1c             	add    $0x1c,%esp
  8025ed:	5b                   	pop    %ebx
  8025ee:	5e                   	pop    %esi
  8025ef:	5f                   	pop    %edi
  8025f0:	5d                   	pop    %ebp
  8025f1:	c3                   	ret    
  8025f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025f8:	31 ff                	xor    %edi,%edi
  8025fa:	31 db                	xor    %ebx,%ebx
  8025fc:	89 d8                	mov    %ebx,%eax
  8025fe:	89 fa                	mov    %edi,%edx
  802600:	83 c4 1c             	add    $0x1c,%esp
  802603:	5b                   	pop    %ebx
  802604:	5e                   	pop    %esi
  802605:	5f                   	pop    %edi
  802606:	5d                   	pop    %ebp
  802607:	c3                   	ret    
  802608:	90                   	nop
  802609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802610:	89 d8                	mov    %ebx,%eax
  802612:	f7 f7                	div    %edi
  802614:	31 ff                	xor    %edi,%edi
  802616:	89 c3                	mov    %eax,%ebx
  802618:	89 d8                	mov    %ebx,%eax
  80261a:	89 fa                	mov    %edi,%edx
  80261c:	83 c4 1c             	add    $0x1c,%esp
  80261f:	5b                   	pop    %ebx
  802620:	5e                   	pop    %esi
  802621:	5f                   	pop    %edi
  802622:	5d                   	pop    %ebp
  802623:	c3                   	ret    
  802624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802628:	39 ce                	cmp    %ecx,%esi
  80262a:	72 0c                	jb     802638 <__udivdi3+0x118>
  80262c:	31 db                	xor    %ebx,%ebx
  80262e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802632:	0f 87 34 ff ff ff    	ja     80256c <__udivdi3+0x4c>
  802638:	bb 01 00 00 00       	mov    $0x1,%ebx
  80263d:	e9 2a ff ff ff       	jmp    80256c <__udivdi3+0x4c>
  802642:	66 90                	xchg   %ax,%ax
  802644:	66 90                	xchg   %ax,%ax
  802646:	66 90                	xchg   %ax,%ax
  802648:	66 90                	xchg   %ax,%ax
  80264a:	66 90                	xchg   %ax,%ax
  80264c:	66 90                	xchg   %ax,%ax
  80264e:	66 90                	xchg   %ax,%ax

00802650 <__umoddi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	53                   	push   %ebx
  802654:	83 ec 1c             	sub    $0x1c,%esp
  802657:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80265b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80265f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802663:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802667:	85 d2                	test   %edx,%edx
  802669:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80266d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802671:	89 f3                	mov    %esi,%ebx
  802673:	89 3c 24             	mov    %edi,(%esp)
  802676:	89 74 24 04          	mov    %esi,0x4(%esp)
  80267a:	75 1c                	jne    802698 <__umoddi3+0x48>
  80267c:	39 f7                	cmp    %esi,%edi
  80267e:	76 50                	jbe    8026d0 <__umoddi3+0x80>
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	f7 f7                	div    %edi
  802686:	89 d0                	mov    %edx,%eax
  802688:	31 d2                	xor    %edx,%edx
  80268a:	83 c4 1c             	add    $0x1c,%esp
  80268d:	5b                   	pop    %ebx
  80268e:	5e                   	pop    %esi
  80268f:	5f                   	pop    %edi
  802690:	5d                   	pop    %ebp
  802691:	c3                   	ret    
  802692:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802698:	39 f2                	cmp    %esi,%edx
  80269a:	89 d0                	mov    %edx,%eax
  80269c:	77 52                	ja     8026f0 <__umoddi3+0xa0>
  80269e:	0f bd ea             	bsr    %edx,%ebp
  8026a1:	83 f5 1f             	xor    $0x1f,%ebp
  8026a4:	75 5a                	jne    802700 <__umoddi3+0xb0>
  8026a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026aa:	0f 82 e0 00 00 00    	jb     802790 <__umoddi3+0x140>
  8026b0:	39 0c 24             	cmp    %ecx,(%esp)
  8026b3:	0f 86 d7 00 00 00    	jbe    802790 <__umoddi3+0x140>
  8026b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026c1:	83 c4 1c             	add    $0x1c,%esp
  8026c4:	5b                   	pop    %ebx
  8026c5:	5e                   	pop    %esi
  8026c6:	5f                   	pop    %edi
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	85 ff                	test   %edi,%edi
  8026d2:	89 fd                	mov    %edi,%ebp
  8026d4:	75 0b                	jne    8026e1 <__umoddi3+0x91>
  8026d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026db:	31 d2                	xor    %edx,%edx
  8026dd:	f7 f7                	div    %edi
  8026df:	89 c5                	mov    %eax,%ebp
  8026e1:	89 f0                	mov    %esi,%eax
  8026e3:	31 d2                	xor    %edx,%edx
  8026e5:	f7 f5                	div    %ebp
  8026e7:	89 c8                	mov    %ecx,%eax
  8026e9:	f7 f5                	div    %ebp
  8026eb:	89 d0                	mov    %edx,%eax
  8026ed:	eb 99                	jmp    802688 <__umoddi3+0x38>
  8026ef:	90                   	nop
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	83 c4 1c             	add    $0x1c,%esp
  8026f7:	5b                   	pop    %ebx
  8026f8:	5e                   	pop    %esi
  8026f9:	5f                   	pop    %edi
  8026fa:	5d                   	pop    %ebp
  8026fb:	c3                   	ret    
  8026fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802700:	8b 34 24             	mov    (%esp),%esi
  802703:	bf 20 00 00 00       	mov    $0x20,%edi
  802708:	89 e9                	mov    %ebp,%ecx
  80270a:	29 ef                	sub    %ebp,%edi
  80270c:	d3 e0                	shl    %cl,%eax
  80270e:	89 f9                	mov    %edi,%ecx
  802710:	89 f2                	mov    %esi,%edx
  802712:	d3 ea                	shr    %cl,%edx
  802714:	89 e9                	mov    %ebp,%ecx
  802716:	09 c2                	or     %eax,%edx
  802718:	89 d8                	mov    %ebx,%eax
  80271a:	89 14 24             	mov    %edx,(%esp)
  80271d:	89 f2                	mov    %esi,%edx
  80271f:	d3 e2                	shl    %cl,%edx
  802721:	89 f9                	mov    %edi,%ecx
  802723:	89 54 24 04          	mov    %edx,0x4(%esp)
  802727:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80272b:	d3 e8                	shr    %cl,%eax
  80272d:	89 e9                	mov    %ebp,%ecx
  80272f:	89 c6                	mov    %eax,%esi
  802731:	d3 e3                	shl    %cl,%ebx
  802733:	89 f9                	mov    %edi,%ecx
  802735:	89 d0                	mov    %edx,%eax
  802737:	d3 e8                	shr    %cl,%eax
  802739:	89 e9                	mov    %ebp,%ecx
  80273b:	09 d8                	or     %ebx,%eax
  80273d:	89 d3                	mov    %edx,%ebx
  80273f:	89 f2                	mov    %esi,%edx
  802741:	f7 34 24             	divl   (%esp)
  802744:	89 d6                	mov    %edx,%esi
  802746:	d3 e3                	shl    %cl,%ebx
  802748:	f7 64 24 04          	mull   0x4(%esp)
  80274c:	39 d6                	cmp    %edx,%esi
  80274e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802752:	89 d1                	mov    %edx,%ecx
  802754:	89 c3                	mov    %eax,%ebx
  802756:	72 08                	jb     802760 <__umoddi3+0x110>
  802758:	75 11                	jne    80276b <__umoddi3+0x11b>
  80275a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80275e:	73 0b                	jae    80276b <__umoddi3+0x11b>
  802760:	2b 44 24 04          	sub    0x4(%esp),%eax
  802764:	1b 14 24             	sbb    (%esp),%edx
  802767:	89 d1                	mov    %edx,%ecx
  802769:	89 c3                	mov    %eax,%ebx
  80276b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80276f:	29 da                	sub    %ebx,%edx
  802771:	19 ce                	sbb    %ecx,%esi
  802773:	89 f9                	mov    %edi,%ecx
  802775:	89 f0                	mov    %esi,%eax
  802777:	d3 e0                	shl    %cl,%eax
  802779:	89 e9                	mov    %ebp,%ecx
  80277b:	d3 ea                	shr    %cl,%edx
  80277d:	89 e9                	mov    %ebp,%ecx
  80277f:	d3 ee                	shr    %cl,%esi
  802781:	09 d0                	or     %edx,%eax
  802783:	89 f2                	mov    %esi,%edx
  802785:	83 c4 1c             	add    $0x1c,%esp
  802788:	5b                   	pop    %ebx
  802789:	5e                   	pop    %esi
  80278a:	5f                   	pop    %edi
  80278b:	5d                   	pop    %ebp
  80278c:	c3                   	ret    
  80278d:	8d 76 00             	lea    0x0(%esi),%esi
  802790:	29 f9                	sub    %edi,%ecx
  802792:	19 d6                	sbb    %edx,%esi
  802794:	89 74 24 04          	mov    %esi,0x4(%esp)
  802798:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80279c:	e9 18 ff ff ff       	jmp    8026b9 <__umoddi3+0x69>
