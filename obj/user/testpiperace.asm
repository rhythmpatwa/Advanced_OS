
obj/user/testpiperace.debug:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 c0 27 80 00       	push   $0x8027c0
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 d7 1c 00 00       	call   801d27 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 d9 27 80 00       	push   $0x8027d9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 e2 27 80 00       	push   $0x8027e2
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 5b 0f 00 00       	call   800fc9 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 f6 27 80 00       	push   $0x8027f6
  80007a:	6a 10                	push   $0x10
  80007c:	68 e2 27 80 00       	push   $0x8027e2
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 0a 14 00 00       	call   80149f <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 d2 1d 00 00       	call   801e7a <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 ff 27 80 00       	push   $0x8027ff
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 dd 0b 00 00       	call   800ca6 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 25 11 00 00       	call   801201 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 1a 28 80 00       	push   $0x80281a
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 25 28 80 00       	push   $0x802825
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 d5 13 00 00       	call   8014ef <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 ba 13 00 00       	call   8014ef <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 30 28 80 00       	push   $0x802830
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 22 1d 00 00       	call   801e7a <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 8c 28 80 00       	push   $0x80288c
  800167:	6a 3a                	push   $0x3a
  800169:	68 e2 27 80 00       	push   $0x8027e2
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 f3 11 00 00       	call   801375 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 46 28 80 00       	push   $0x802846
  80018f:	6a 3c                	push   $0x3c
  800191:	68 e2 27 80 00       	push   $0x8027e2
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 69 11 00 00       	call   80130f <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 68 19 00 00       	call   801b16 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 5e 28 80 00       	push   $0x80285e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 74 28 80 00       	push   $0x802874
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8001ef:	e8 93 0a 00 00       	call   800c87 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 95 12 00 00       	call   8014ca <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 07 0a 00 00       	call   800c46 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 30 0a 00 00       	call   800c87 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 c0 28 80 00       	push   $0x8028c0
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 d7 27 80 00 	movl   $0x8027d7,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 4f 09 00 00       	call   800c09 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 f4 08 00 00       	call   800c09 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 ab 21 00 00       	call   802530 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 98 22 00 00       	call   802660 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 e3 28 80 00 	movsbl 0x8028e3(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 a9 03 00 00    	je     800819 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 3a 03 00 00    	ja     8007fe <vprintfmt+0x3aa>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 20 2a 80 00 	jmp    *0x802a20(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 39                	ja     80052d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050a:	eb 27                	jmp    800533 <vprintfmt+0xdf>
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	0f 49 c8             	cmovns %eax,%ecx
  800519:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	eb 8c                	jmp    8004ad <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	eb 80                	jmp    8004ad <vprintfmt+0x59>
  80052d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800530:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 89 70 ff ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80053d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800543:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800555:	e9 53 ff ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 30                	pushl  (%eax)
  800569:	ff d6                	call   *%esi
			break;
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 04 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	99                   	cltd   
  800582:	31 d0                	xor    %edx,%eax
  800584:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	83 f8 0f             	cmp    $0xf,%eax
  800589:	7f 0b                	jg     800596 <vprintfmt+0x142>
  80058b:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 fb 28 80 00       	push   $0x8028fb
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 94 fe ff ff       	call   800437 <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a9:	e9 cc fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ae:	52                   	push   %edx
  8005af:	68 8d 2d 80 00       	push   $0x802d8d
  8005b4:	53                   	push   %ebx
  8005b5:	56                   	push   %esi
  8005b6:	e8 7c fe ff ff       	call   800437 <printfmt>
  8005bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 b4 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	b8 f4 28 80 00       	mov    $0x8028f4,%eax
  8005d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005df:	0f 8e 94 00 00 00    	jle    800679 <vprintfmt+0x225>
  8005e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e9:	0f 84 98 00 00 00    	je     800687 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	e8 a6 02 00 00       	call   8008a1 <strnlen>
  8005fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c0>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	0f 49 c1             	cmovns %ecx,%eax
  800637:	29 c1                	sub    %eax,%ecx
  800639:	89 75 08             	mov    %esi,0x8(%ebp)
  80063c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800642:	89 cb                	mov    %ecx,%ebx
  800644:	eb 4d                	jmp    800693 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	74 1b                	je     800667 <vprintfmt+0x213>
  80064c:	0f be c0             	movsbl %al,%eax
  80064f:	83 e8 20             	sub    $0x20,%eax
  800652:	83 f8 5e             	cmp    $0x5e,%eax
  800655:	76 10                	jbe    800667 <vprintfmt+0x213>
					putch('?', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 3f                	push   $0x3f
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	52                   	push   %edx
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 1a                	jmp    800693 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	eb 0c                	jmp    800693 <vprintfmt+0x23f>
  800687:	89 75 08             	mov    %esi,0x8(%ebp)
  80068a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800690:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	0f be d0             	movsbl %al,%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 23                	je     8006c4 <vprintfmt+0x270>
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	78 a1                	js     800646 <vprintfmt+0x1f2>
  8006a5:	83 ee 01             	sub    $0x1,%esi
  8006a8:	79 9c                	jns    800646 <vprintfmt+0x1f2>
  8006aa:	89 df                	mov    %ebx,%edi
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	eb 18                	jmp    8006cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 20                	push   $0x20
  8006ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x278>
  8006c4:	89 df                	mov    %ebx,%edi
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f e4                	jg     8006b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 a2 fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 16                	jle    8006f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 08             	lea    0x8(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f1:	eb 32                	jmp    800725 <vprintfmt+0x2d1>
	else if (lflag)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 18                	je     80070f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800728:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800730:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800734:	0f 89 90 00 00 00    	jns    8007ca <vprintfmt+0x376>
				putch('-', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	6a 2d                	push   $0x2d
  800740:	ff d6                	call   *%esi
				num = -(long long) num;
  800742:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800745:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800748:	f7 d8                	neg    %eax
  80074a:	83 d2 00             	adc    $0x0,%edx
  80074d:	f7 da                	neg    %edx
  80074f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800752:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800757:	eb 71                	jmp    8007ca <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800759:	8d 45 14             	lea    0x14(%ebp),%eax
  80075c:	e8 7f fc ff ff       	call   8003e0 <getuint>
			base = 10;
  800761:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800766:	eb 62                	jmp    8007ca <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
  80076b:	e8 70 fc ff ff       	call   8003e0 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800770:	83 ec 0c             	sub    $0xc,%esp
  800773:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800777:	51                   	push   %ecx
  800778:	ff 75 e0             	pushl  -0x20(%ebp)
  80077b:	6a 08                	push   $0x8
  80077d:	52                   	push   %edx
  80077e:	50                   	push   %eax
  80077f:	89 da                	mov    %ebx,%edx
  800781:	89 f0                	mov    %esi,%eax
  800783:	e8 a9 fb ff ff       	call   800331 <printnum>
			break;
  800788:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  80078e:	e9 e7 fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	53                   	push   %ebx
  800797:	6a 30                	push   $0x30
  800799:	ff d6                	call   *%esi
			putch('x', putdat);
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	53                   	push   %ebx
  80079f:	6a 78                	push   $0x78
  8007a1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 04             	lea    0x4(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007b3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007b6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8007bb:	eb 0d                	jmp    8007ca <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c0:	e8 1b fc ff ff       	call   8003e0 <getuint>
			base = 16;
  8007c5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007ca:	83 ec 0c             	sub    $0xc,%esp
  8007cd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007d1:	57                   	push   %edi
  8007d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d5:	51                   	push   %ecx
  8007d6:	52                   	push   %edx
  8007d7:	50                   	push   %eax
  8007d8:	89 da                	mov    %ebx,%edx
  8007da:	89 f0                	mov    %esi,%eax
  8007dc:	e8 50 fb ff ff       	call   800331 <printnum>
			break;
  8007e1:	83 c4 20             	add    $0x20,%esp
  8007e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e7:	e9 8e fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	53                   	push   %ebx
  8007f0:	51                   	push   %ecx
  8007f1:	ff d6                	call   *%esi
			break;
  8007f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f9:	e9 7c fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	53                   	push   %ebx
  800802:	6a 25                	push   $0x25
  800804:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	eb 03                	jmp    80080e <vprintfmt+0x3ba>
  80080b:	83 ef 01             	sub    $0x1,%edi
  80080e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800812:	75 f7                	jne    80080b <vprintfmt+0x3b7>
  800814:	e9 61 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800819:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081c:	5b                   	pop    %ebx
  80081d:	5e                   	pop    %esi
  80081e:	5f                   	pop    %edi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	83 ec 18             	sub    $0x18,%esp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800830:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800834:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800837:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083e:	85 c0                	test   %eax,%eax
  800840:	74 26                	je     800868 <vsnprintf+0x47>
  800842:	85 d2                	test   %edx,%edx
  800844:	7e 22                	jle    800868 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800846:	ff 75 14             	pushl  0x14(%ebp)
  800849:	ff 75 10             	pushl  0x10(%ebp)
  80084c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	68 1a 04 80 00       	push   $0x80041a
  800855:	e8 fa fb ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	eb 05                	jmp    80086d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800868:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800878:	50                   	push   %eax
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	ff 75 0c             	pushl  0xc(%ebp)
  80087f:	ff 75 08             	pushl  0x8(%ebp)
  800882:	e8 9a ff ff ff       	call   800821 <vsnprintf>
	va_end(ap);

	return rc;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
  800894:	eb 03                	jmp    800899 <strlen+0x10>
		n++;
  800896:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800899:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089d:	75 f7                	jne    800896 <strlen+0xd>
		n++;
	return n;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8008af:	eb 03                	jmp    8008b4 <strnlen+0x13>
		n++;
  8008b1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b4:	39 c2                	cmp    %eax,%edx
  8008b6:	74 08                	je     8008c0 <strnlen+0x1f>
  8008b8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008bc:	75 f3                	jne    8008b1 <strnlen+0x10>
  8008be:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	83 c2 01             	add    $0x1,%edx
  8008d1:	83 c1 01             	add    $0x1,%ecx
  8008d4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008db:	84 db                	test   %bl,%bl
  8008dd:	75 ef                	jne    8008ce <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008df:	5b                   	pop    %ebx
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e9:	53                   	push   %ebx
  8008ea:	e8 9a ff ff ff       	call   800889 <strlen>
  8008ef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	01 d8                	add    %ebx,%eax
  8008f7:	50                   	push   %eax
  8008f8:	e8 c5 ff ff ff       	call   8008c2 <strcpy>
	return dst;
}
  8008fd:	89 d8                	mov    %ebx,%eax
  8008ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 75 08             	mov    0x8(%ebp),%esi
  80090c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090f:	89 f3                	mov    %esi,%ebx
  800911:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800914:	89 f2                	mov    %esi,%edx
  800916:	eb 0f                	jmp    800927 <strncpy+0x23>
		*dst++ = *src;
  800918:	83 c2 01             	add    $0x1,%edx
  80091b:	0f b6 01             	movzbl (%ecx),%eax
  80091e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800921:	80 39 01             	cmpb   $0x1,(%ecx)
  800924:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800927:	39 da                	cmp    %ebx,%edx
  800929:	75 ed                	jne    800918 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80092b:	89 f0                	mov    %esi,%eax
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 75 08             	mov    0x8(%ebp),%esi
  800939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093c:	8b 55 10             	mov    0x10(%ebp),%edx
  80093f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800941:	85 d2                	test   %edx,%edx
  800943:	74 21                	je     800966 <strlcpy+0x35>
  800945:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800949:	89 f2                	mov    %esi,%edx
  80094b:	eb 09                	jmp    800956 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094d:	83 c2 01             	add    $0x1,%edx
  800950:	83 c1 01             	add    $0x1,%ecx
  800953:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800956:	39 c2                	cmp    %eax,%edx
  800958:	74 09                	je     800963 <strlcpy+0x32>
  80095a:	0f b6 19             	movzbl (%ecx),%ebx
  80095d:	84 db                	test   %bl,%bl
  80095f:	75 ec                	jne    80094d <strlcpy+0x1c>
  800961:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800963:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800966:	29 f0                	sub    %esi,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800975:	eb 06                	jmp    80097d <strcmp+0x11>
		p++, q++;
  800977:	83 c1 01             	add    $0x1,%ecx
  80097a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	84 c0                	test   %al,%al
  800982:	74 04                	je     800988 <strcmp+0x1c>
  800984:	3a 02                	cmp    (%edx),%al
  800986:	74 ef                	je     800977 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 c0             	movzbl %al,%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 c3                	mov    %eax,%ebx
  80099e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a1:	eb 06                	jmp    8009a9 <strncmp+0x17>
		n--, p++, q++;
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a9:	39 d8                	cmp    %ebx,%eax
  8009ab:	74 15                	je     8009c2 <strncmp+0x30>
  8009ad:	0f b6 08             	movzbl (%eax),%ecx
  8009b0:	84 c9                	test   %cl,%cl
  8009b2:	74 04                	je     8009b8 <strncmp+0x26>
  8009b4:	3a 0a                	cmp    (%edx),%cl
  8009b6:	74 eb                	je     8009a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
  8009c0:	eb 05                	jmp    8009c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c7:	5b                   	pop    %ebx
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	eb 07                	jmp    8009dd <strchr+0x13>
		if (*s == c)
  8009d6:	38 ca                	cmp    %cl,%dl
  8009d8:	74 0f                	je     8009e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 f2                	jne    8009d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	eb 03                	jmp    8009fa <strfind+0xf>
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fd:	38 ca                	cmp    %cl,%dl
  8009ff:	74 04                	je     800a05 <strfind+0x1a>
  800a01:	84 d2                	test   %dl,%dl
  800a03:	75 f2                	jne    8009f7 <strfind+0xc>
			break;
	return (char *) s;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a13:	85 c9                	test   %ecx,%ecx
  800a15:	74 36                	je     800a4d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1d:	75 28                	jne    800a47 <memset+0x40>
  800a1f:	f6 c1 03             	test   $0x3,%cl
  800a22:	75 23                	jne    800a47 <memset+0x40>
		c &= 0xFF;
  800a24:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a28:	89 d3                	mov    %edx,%ebx
  800a2a:	c1 e3 08             	shl    $0x8,%ebx
  800a2d:	89 d6                	mov    %edx,%esi
  800a2f:	c1 e6 18             	shl    $0x18,%esi
  800a32:	89 d0                	mov    %edx,%eax
  800a34:	c1 e0 10             	shl    $0x10,%eax
  800a37:	09 f0                	or     %esi,%eax
  800a39:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a3b:	89 d8                	mov    %ebx,%eax
  800a3d:	09 d0                	or     %edx,%eax
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
  800a42:	fc                   	cld    
  800a43:	f3 ab                	rep stos %eax,%es:(%edi)
  800a45:	eb 06                	jmp    800a4d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4a:	fc                   	cld    
  800a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4d:	89 f8                	mov    %edi,%eax
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 35                	jae    800a9b <memmove+0x47>
  800a66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a69:	39 d0                	cmp    %edx,%eax
  800a6b:	73 2e                	jae    800a9b <memmove+0x47>
		s += n;
		d += n;
  800a6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a70:	89 d6                	mov    %edx,%esi
  800a72:	09 fe                	or     %edi,%esi
  800a74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7a:	75 13                	jne    800a8f <memmove+0x3b>
  800a7c:	f6 c1 03             	test   $0x3,%cl
  800a7f:	75 0e                	jne    800a8f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a81:	83 ef 04             	sub    $0x4,%edi
  800a84:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a87:	c1 e9 02             	shr    $0x2,%ecx
  800a8a:	fd                   	std    
  800a8b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8d:	eb 09                	jmp    800a98 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8f:	83 ef 01             	sub    $0x1,%edi
  800a92:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a95:	fd                   	std    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a98:	fc                   	cld    
  800a99:	eb 1d                	jmp    800ab8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	89 f2                	mov    %esi,%edx
  800a9d:	09 c2                	or     %eax,%edx
  800a9f:	f6 c2 03             	test   $0x3,%dl
  800aa2:	75 0f                	jne    800ab3 <memmove+0x5f>
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 0a                	jne    800ab3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
  800aac:	89 c7                	mov    %eax,%edi
  800aae:	fc                   	cld    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab1:	eb 05                	jmp    800ab8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	fc                   	cld    
  800ab6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abf:	ff 75 10             	pushl  0x10(%ebp)
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	ff 75 08             	pushl  0x8(%ebp)
  800ac8:	e8 87 ff ff ff       	call   800a54 <memmove>
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ada:	89 c6                	mov    %eax,%esi
  800adc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adf:	eb 1a                	jmp    800afb <memcmp+0x2c>
		if (*s1 != *s2)
  800ae1:	0f b6 08             	movzbl (%eax),%ecx
  800ae4:	0f b6 1a             	movzbl (%edx),%ebx
  800ae7:	38 d9                	cmp    %bl,%cl
  800ae9:	74 0a                	je     800af5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aeb:	0f b6 c1             	movzbl %cl,%eax
  800aee:	0f b6 db             	movzbl %bl,%ebx
  800af1:	29 d8                	sub    %ebx,%eax
  800af3:	eb 0f                	jmp    800b04 <memcmp+0x35>
		s1++, s2++;
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	39 f0                	cmp    %esi,%eax
  800afd:	75 e2                	jne    800ae1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	53                   	push   %ebx
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0f:	89 c1                	mov    %eax,%ecx
  800b11:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b14:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b18:	eb 0a                	jmp    800b24 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1a:	0f b6 10             	movzbl (%eax),%edx
  800b1d:	39 da                	cmp    %ebx,%edx
  800b1f:	74 07                	je     800b28 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	39 c8                	cmp    %ecx,%eax
  800b26:	72 f2                	jb     800b1a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b28:	5b                   	pop    %ebx
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b37:	eb 03                	jmp    800b3c <strtol+0x11>
		s++;
  800b39:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3c:	0f b6 01             	movzbl (%ecx),%eax
  800b3f:	3c 20                	cmp    $0x20,%al
  800b41:	74 f6                	je     800b39 <strtol+0xe>
  800b43:	3c 09                	cmp    $0x9,%al
  800b45:	74 f2                	je     800b39 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b47:	3c 2b                	cmp    $0x2b,%al
  800b49:	75 0a                	jne    800b55 <strtol+0x2a>
		s++;
  800b4b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b53:	eb 11                	jmp    800b66 <strtol+0x3b>
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b5a:	3c 2d                	cmp    $0x2d,%al
  800b5c:	75 08                	jne    800b66 <strtol+0x3b>
		s++, neg = 1;
  800b5e:	83 c1 01             	add    $0x1,%ecx
  800b61:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b66:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6c:	75 15                	jne    800b83 <strtol+0x58>
  800b6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b71:	75 10                	jne    800b83 <strtol+0x58>
  800b73:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b77:	75 7c                	jne    800bf5 <strtol+0xca>
		s += 2, base = 16;
  800b79:	83 c1 02             	add    $0x2,%ecx
  800b7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b81:	eb 16                	jmp    800b99 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b83:	85 db                	test   %ebx,%ebx
  800b85:	75 12                	jne    800b99 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b87:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8f:	75 08                	jne    800b99 <strtol+0x6e>
		s++, base = 8;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b99:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba1:	0f b6 11             	movzbl (%ecx),%edx
  800ba4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba7:	89 f3                	mov    %esi,%ebx
  800ba9:	80 fb 09             	cmp    $0x9,%bl
  800bac:	77 08                	ja     800bb6 <strtol+0x8b>
			dig = *s - '0';
  800bae:	0f be d2             	movsbl %dl,%edx
  800bb1:	83 ea 30             	sub    $0x30,%edx
  800bb4:	eb 22                	jmp    800bd8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb9:	89 f3                	mov    %esi,%ebx
  800bbb:	80 fb 19             	cmp    $0x19,%bl
  800bbe:	77 08                	ja     800bc8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bc0:	0f be d2             	movsbl %dl,%edx
  800bc3:	83 ea 57             	sub    $0x57,%edx
  800bc6:	eb 10                	jmp    800bd8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 16                	ja     800be8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd2:	0f be d2             	movsbl %dl,%edx
  800bd5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bdb:	7d 0b                	jge    800be8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bdd:	83 c1 01             	add    $0x1,%ecx
  800be0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be6:	eb b9                	jmp    800ba1 <strtol+0x76>

	if (endptr)
  800be8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bec:	74 0d                	je     800bfb <strtol+0xd0>
		*endptr = (char *) s;
  800bee:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf1:	89 0e                	mov    %ecx,(%esi)
  800bf3:	eb 06                	jmp    800bfb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf5:	85 db                	test   %ebx,%ebx
  800bf7:	74 98                	je     800b91 <strtol+0x66>
  800bf9:	eb 9e                	jmp    800b99 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bfb:	89 c2                	mov    %eax,%edx
  800bfd:	f7 da                	neg    %edx
  800bff:	85 ff                	test   %edi,%edi
  800c01:	0f 45 c2             	cmovne %edx,%eax
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	89 c7                	mov    %eax,%edi
  800c1e:	89 c6                	mov    %eax,%esi
  800c20:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 01 00 00 00       	mov    $0x1,%eax
  800c37:	89 d1                	mov    %edx,%ecx
  800c39:	89 d3                	mov    %edx,%ebx
  800c3b:	89 d7                	mov    %edx,%edi
  800c3d:	89 d6                	mov    %edx,%esi
  800c3f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c54:	b8 03 00 00 00       	mov    $0x3,%eax
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 cb                	mov    %ecx,%ebx
  800c5e:	89 cf                	mov    %ecx,%edi
  800c60:	89 ce                	mov    %ecx,%esi
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 03                	push   $0x3
  800c6e:	68 df 2b 80 00       	push   $0x802bdf
  800c73:	6a 23                	push   $0x23
  800c75:	68 fc 2b 80 00       	push   $0x802bfc
  800c7a:	e8 c5 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c92:	b8 02 00 00 00       	mov    $0x2,%eax
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	89 d3                	mov    %edx,%ebx
  800c9b:	89 d7                	mov    %edx,%edi
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_yield>:

void
sys_yield(void)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb6:	89 d1                	mov    %edx,%ecx
  800cb8:	89 d3                	mov    %edx,%ebx
  800cba:	89 d7                	mov    %edx,%edi
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce1:	89 f7                	mov    %esi,%edi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 04                	push   $0x4
  800cef:	68 df 2b 80 00       	push   $0x802bdf
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 fc 2b 80 00       	push   $0x802bfc
  800cfb:	e8 44 f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b8 05 00 00 00       	mov    $0x5,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d22:	8b 75 18             	mov    0x18(%ebp),%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 05                	push   $0x5
  800d31:	68 df 2b 80 00       	push   $0x802bdf
  800d36:	6a 23                	push   $0x23
  800d38:	68 fc 2b 80 00       	push   $0x802bfc
  800d3d:	e8 02 f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
  800d50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	8b 55 08             	mov    0x8(%ebp),%edx
  800d63:	89 df                	mov    %ebx,%edi
  800d65:	89 de                	mov    %ebx,%esi
  800d67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 06                	push   $0x6
  800d73:	68 df 2b 80 00       	push   $0x802bdf
  800d78:	6a 23                	push   $0x23
  800d7a:	68 fc 2b 80 00       	push   $0x802bfc
  800d7f:	e8 c0 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 17                	jle    800dc6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	50                   	push   %eax
  800db3:	6a 08                	push   $0x8
  800db5:	68 df 2b 80 00       	push   $0x802bdf
  800dba:	6a 23                	push   $0x23
  800dbc:	68 fc 2b 80 00       	push   $0x802bfc
  800dc1:	e8 7e f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddc:	b8 09 00 00 00       	mov    $0x9,%eax
  800de1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	89 df                	mov    %ebx,%edi
  800de9:	89 de                	mov    %ebx,%esi
  800deb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 17                	jle    800e08 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	50                   	push   %eax
  800df5:	6a 09                	push   $0x9
  800df7:	68 df 2b 80 00       	push   $0x802bdf
  800dfc:	6a 23                	push   $0x23
  800dfe:	68 fc 2b 80 00       	push   $0x802bfc
  800e03:	e8 3c f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 df                	mov    %ebx,%edi
  800e2b:	89 de                	mov    %ebx,%esi
  800e2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 17                	jle    800e4a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	50                   	push   %eax
  800e37:	6a 0a                	push   $0xa
  800e39:	68 df 2b 80 00       	push   $0x802bdf
  800e3e:	6a 23                	push   $0x23
  800e40:	68 fc 2b 80 00       	push   $0x802bfc
  800e45:	e8 fa f3 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e58:	be 00 00 00 00       	mov    $0x0,%esi
  800e5d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
  800e7b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	89 cb                	mov    %ecx,%ebx
  800e8d:	89 cf                	mov    %ecx,%edi
  800e8f:	89 ce                	mov    %ecx,%esi
  800e91:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e93:	85 c0                	test   %eax,%eax
  800e95:	7e 17                	jle    800eae <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	6a 0d                	push   $0xd
  800e9d:	68 df 2b 80 00       	push   $0x802bdf
  800ea2:	6a 23                	push   $0x23
  800ea4:	68 fc 2b 80 00       	push   $0x802bfc
  800ea9:	e8 96 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec6:	89 d1                	mov    %edx,%ecx
  800ec8:	89 d3                	mov    %edx,%ebx
  800eca:	89 d7                	mov    %edx,%edi
  800ecc:	89 d6                	mov    %edx,%esi
  800ece:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800edf:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800ee1:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ee4:	f6 c1 02             	test   $0x2,%cl
  800ee7:	74 2e                	je     800f17 <pgfault+0x42>
  800ee9:	89 c2                	mov    %eax,%edx
  800eeb:	c1 ea 16             	shr    $0x16,%edx
  800eee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ef5:	f6 c2 01             	test   $0x1,%dl
  800ef8:	74 1d                	je     800f17 <pgfault+0x42>
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	c1 ea 0c             	shr    $0xc,%edx
  800eff:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800f06:	f6 c3 01             	test   $0x1,%bl
  800f09:	74 0c                	je     800f17 <pgfault+0x42>
  800f0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f12:	f6 c6 08             	test   $0x8,%dh
  800f15:	75 12                	jne    800f29 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800f17:	51                   	push   %ecx
  800f18:	68 0a 2c 80 00       	push   $0x802c0a
  800f1d:	6a 1e                	push   $0x1e
  800f1f:	68 23 2c 80 00       	push   $0x802c23
  800f24:	e8 1b f3 ff ff       	call   800244 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800f29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2e:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	6a 07                	push   $0x7
  800f35:	68 00 f0 7f 00       	push   $0x7ff000
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 84 fd ff ff       	call   800cc5 <sys_page_alloc>
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 12                	jns    800f5a <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800f48:	50                   	push   %eax
  800f49:	68 2e 2c 80 00       	push   $0x802c2e
  800f4e:	6a 29                	push   $0x29
  800f50:	68 23 2c 80 00       	push   $0x802c23
  800f55:	e8 ea f2 ff ff       	call   800244 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	68 00 10 00 00       	push   $0x1000
  800f62:	53                   	push   %ebx
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	e8 4f fb ff ff       	call   800abc <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f6d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f74:	53                   	push   %ebx
  800f75:	6a 00                	push   $0x0
  800f77:	68 00 f0 7f 00       	push   $0x7ff000
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 85 fd ff ff       	call   800d08 <sys_page_map>
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 12                	jns    800f9c <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800f8a:	50                   	push   %eax
  800f8b:	68 49 2c 80 00       	push   $0x802c49
  800f90:	6a 2e                	push   $0x2e
  800f92:	68 23 2c 80 00       	push   $0x802c23
  800f97:	e8 a8 f2 ff ff       	call   800244 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800f9c:	83 ec 08             	sub    $0x8,%esp
  800f9f:	68 00 f0 7f 00       	push   $0x7ff000
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 9f fd ff ff       	call   800d4a <sys_page_unmap>
  800fab:	83 c4 10             	add    $0x10,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 12                	jns    800fc4 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800fb2:	50                   	push   %eax
  800fb3:	68 62 2c 80 00       	push   $0x802c62
  800fb8:	6a 31                	push   $0x31
  800fba:	68 23 2c 80 00       	push   $0x802c23
  800fbf:	e8 80 f2 ff ff       	call   800244 <_panic>

}
  800fc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	57                   	push   %edi
  800fcd:	56                   	push   %esi
  800fce:	53                   	push   %ebx
  800fcf:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800fd2:	68 d5 0e 80 00       	push   $0x800ed5
  800fd7:	e8 bb 14 00 00       	call   802497 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fdc:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe1:	cd 30                	int    $0x30
  800fe3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fe6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	75 21                	jne    801016 <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ff5:	e8 8d fc ff ff       	call   800c87 <sys_getenvid>
  800ffa:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801002:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801007:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80100c:	b8 00 00 00 00       	mov    $0x0,%eax
  801011:	e9 c9 01 00 00       	jmp    8011df <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  801016:	89 d8                	mov    %ebx,%eax
  801018:	c1 e8 16             	shr    $0x16,%eax
  80101b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801022:	a8 01                	test   $0x1,%al
  801024:	0f 84 1b 01 00 00    	je     801145 <fork+0x17c>
  80102a:	89 de                	mov    %ebx,%esi
  80102c:	c1 ee 0c             	shr    $0xc,%esi
  80102f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801036:	a8 01                	test   $0x1,%al
  801038:	0f 84 07 01 00 00    	je     801145 <fork+0x17c>
  80103e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801045:	a8 04                	test   $0x4,%al
  801047:	0f 84 f8 00 00 00    	je     801145 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  80104d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801054:	f6 c4 04             	test   $0x4,%ah
  801057:	74 3c                	je     801095 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  801059:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801060:	c1 e6 0c             	shl    $0xc,%esi
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	25 07 0e 00 00       	and    $0xe07,%eax
  80106b:	50                   	push   %eax
  80106c:	56                   	push   %esi
  80106d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801070:	56                   	push   %esi
  801071:	6a 00                	push   $0x0
  801073:	e8 90 fc ff ff       	call   800d08 <sys_page_map>
  801078:	83 c4 20             	add    $0x20,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	0f 89 c2 00 00 00    	jns    801145 <fork+0x17c>
			panic("duppage: %e", r);
  801083:	50                   	push   %eax
  801084:	68 7d 2c 80 00       	push   $0x802c7d
  801089:	6a 48                	push   $0x48
  80108b:	68 23 2c 80 00       	push   $0x802c23
  801090:	e8 af f1 ff ff       	call   800244 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801095:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109c:	f6 c4 08             	test   $0x8,%ah
  80109f:	75 0b                	jne    8010ac <fork+0xe3>
  8010a1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010a8:	a8 02                	test   $0x2,%al
  8010aa:	74 6c                	je     801118 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  8010ac:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010b3:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  8010b6:	83 f8 01             	cmp    $0x1,%eax
  8010b9:	19 ff                	sbb    %edi,%edi
  8010bb:	83 e7 fc             	and    $0xfffffffc,%edi
  8010be:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  8010c4:	c1 e6 0c             	shl    $0xc,%esi
  8010c7:	83 ec 0c             	sub    $0xc,%esp
  8010ca:	57                   	push   %edi
  8010cb:	56                   	push   %esi
  8010cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cf:	56                   	push   %esi
  8010d0:	6a 00                	push   $0x0
  8010d2:	e8 31 fc ff ff       	call   800d08 <sys_page_map>
  8010d7:	83 c4 20             	add    $0x20,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	79 12                	jns    8010f0 <fork+0x127>
			panic("duppage: %e", r);
  8010de:	50                   	push   %eax
  8010df:	68 7d 2c 80 00       	push   $0x802c7d
  8010e4:	6a 50                	push   $0x50
  8010e6:	68 23 2c 80 00       	push   $0x802c23
  8010eb:	e8 54 f1 ff ff       	call   800244 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	6a 00                	push   $0x0
  8010f7:	56                   	push   %esi
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 09 fc ff ff       	call   800d08 <sys_page_map>
  8010ff:	83 c4 20             	add    $0x20,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	79 3f                	jns    801145 <fork+0x17c>
			panic("duppage: %e", r);
  801106:	50                   	push   %eax
  801107:	68 7d 2c 80 00       	push   $0x802c7d
  80110c:	6a 53                	push   $0x53
  80110e:	68 23 2c 80 00       	push   $0x802c23
  801113:	e8 2c f1 ff ff       	call   800244 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  801118:	c1 e6 0c             	shl    $0xc,%esi
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	6a 05                	push   $0x5
  801120:	56                   	push   %esi
  801121:	ff 75 e4             	pushl  -0x1c(%ebp)
  801124:	56                   	push   %esi
  801125:	6a 00                	push   $0x0
  801127:	e8 dc fb ff ff       	call   800d08 <sys_page_map>
  80112c:	83 c4 20             	add    $0x20,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	79 12                	jns    801145 <fork+0x17c>
			panic("duppage: %e", r);
  801133:	50                   	push   %eax
  801134:	68 7d 2c 80 00       	push   $0x802c7d
  801139:	6a 57                	push   $0x57
  80113b:	68 23 2c 80 00       	push   $0x802c23
  801140:	e8 ff f0 ff ff       	call   800244 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801145:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80114b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801151:	0f 85 bf fe ff ff    	jne    801016 <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  801157:	83 ec 04             	sub    $0x4,%esp
  80115a:	6a 07                	push   $0x7
  80115c:	68 00 f0 bf ee       	push   $0xeebff000
  801161:	ff 75 e0             	pushl  -0x20(%ebp)
  801164:	e8 5c fb ff ff       	call   800cc5 <sys_page_alloc>
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	85 c0                	test   %eax,%eax
  80116e:	74 17                	je     801187 <fork+0x1be>
		panic("sys_page_alloc Error");
  801170:	83 ec 04             	sub    $0x4,%esp
  801173:	68 89 2c 80 00       	push   $0x802c89
  801178:	68 83 00 00 00       	push   $0x83
  80117d:	68 23 2c 80 00       	push   $0x802c23
  801182:	e8 bd f0 ff ff       	call   800244 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	68 06 25 80 00       	push   $0x802506
  80118f:	ff 75 e0             	pushl  -0x20(%ebp)
  801192:	e8 79 fc ff ff       	call   800e10 <sys_env_set_pgfault_upcall>
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	79 15                	jns    8011b3 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  80119e:	50                   	push   %eax
  80119f:	68 9e 2c 80 00       	push   $0x802c9e
  8011a4:	68 86 00 00 00       	push   $0x86
  8011a9:	68 23 2c 80 00       	push   $0x802c23
  8011ae:	e8 91 f0 ff ff       	call   800244 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	6a 02                	push   $0x2
  8011b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bb:	e8 cc fb ff ff       	call   800d8c <sys_env_set_status>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	79 15                	jns    8011dc <fork+0x213>
		panic("fork set status: %e", r);
  8011c7:	50                   	push   %eax
  8011c8:	68 b6 2c 80 00       	push   $0x802cb6
  8011cd:	68 89 00 00 00       	push   $0x89
  8011d2:	68 23 2c 80 00       	push   $0x802c23
  8011d7:	e8 68 f0 ff ff       	call   800244 <_panic>
	
	return envid;
  8011dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <sfork>:


// Challenge!
int
sfork(void)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ed:	68 ca 2c 80 00       	push   $0x802cca
  8011f2:	68 93 00 00 00       	push   $0x93
  8011f7:	68 23 2c 80 00       	push   $0x802c23
  8011fc:	e8 43 f0 ff ff       	call   800244 <_panic>

00801201 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	56                   	push   %esi
  801205:	53                   	push   %ebx
  801206:	8b 75 08             	mov    0x8(%ebp),%esi
  801209:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  80120f:	85 c0                	test   %eax,%eax
  801211:	74 0e                	je     801221 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	50                   	push   %eax
  801217:	e8 59 fc ff ff       	call   800e75 <sys_ipc_recv>
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	eb 10                	jmp    801231 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	68 00 00 c0 ee       	push   $0xeec00000
  801229:	e8 47 fc ff ff       	call   800e75 <sys_ipc_recv>
  80122e:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801231:	85 c0                	test   %eax,%eax
  801233:	79 17                	jns    80124c <ipc_recv+0x4b>
		if(*from_env_store)
  801235:	83 3e 00             	cmpl   $0x0,(%esi)
  801238:	74 06                	je     801240 <ipc_recv+0x3f>
			*from_env_store = 0;
  80123a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801240:	85 db                	test   %ebx,%ebx
  801242:	74 2c                	je     801270 <ipc_recv+0x6f>
			*perm_store = 0;
  801244:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80124a:	eb 24                	jmp    801270 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  80124c:	85 f6                	test   %esi,%esi
  80124e:	74 0a                	je     80125a <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801250:	a1 08 40 80 00       	mov    0x804008,%eax
  801255:	8b 40 74             	mov    0x74(%eax),%eax
  801258:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80125a:	85 db                	test   %ebx,%ebx
  80125c:	74 0a                	je     801268 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80125e:	a1 08 40 80 00       	mov    0x804008,%eax
  801263:	8b 40 78             	mov    0x78(%eax),%eax
  801266:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801268:	a1 08 40 80 00       	mov    0x804008,%eax
  80126d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801270:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	57                   	push   %edi
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	8b 7d 08             	mov    0x8(%ebp),%edi
  801283:	8b 75 0c             	mov    0xc(%ebp),%esi
  801286:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801289:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80128b:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801290:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801293:	e8 0e fa ff ff       	call   800ca6 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801298:	ff 75 14             	pushl  0x14(%ebp)
  80129b:	53                   	push   %ebx
  80129c:	56                   	push   %esi
  80129d:	57                   	push   %edi
  80129e:	e8 af fb ff ff       	call   800e52 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	f7 d2                	not    %edx
  8012a7:	c1 ea 1f             	shr    $0x1f,%edx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012b0:	0f 94 c1             	sete   %cl
  8012b3:	09 ca                	or     %ecx,%edx
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	0f 94 c0             	sete   %al
  8012ba:	38 c2                	cmp    %al,%dl
  8012bc:	77 d5                	ja     801293 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8012be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012d1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012d4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012da:	8b 52 50             	mov    0x50(%edx),%edx
  8012dd:	39 ca                	cmp    %ecx,%edx
  8012df:	75 0d                	jne    8012ee <ipc_find_env+0x28>
			return envs[i].env_id;
  8012e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012e9:	8b 40 48             	mov    0x48(%eax),%eax
  8012ec:	eb 0f                	jmp    8012fd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012ee:	83 c0 01             	add    $0x1,%eax
  8012f1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012f6:	75 d9                	jne    8012d1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	05 00 00 00 30       	add    $0x30000000,%eax
  80130a:	c1 e8 0c             	shr    $0xc,%eax
}
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	05 00 00 00 30       	add    $0x30000000,%eax
  80131a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80131f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 16             	shr    $0x16,%edx
  801336:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	74 11                	je     801353 <fd_alloc+0x2d>
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 0c             	shr    $0xc,%edx
  801347:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	75 09                	jne    80135c <fd_alloc+0x36>
			*fd_store = fd;
  801353:	89 01                	mov    %eax,(%ecx)
			return 0;
  801355:	b8 00 00 00 00       	mov    $0x0,%eax
  80135a:	eb 17                	jmp    801373 <fd_alloc+0x4d>
  80135c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801361:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801366:	75 c9                	jne    801331 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801368:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80136e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80137b:	83 f8 1f             	cmp    $0x1f,%eax
  80137e:	77 36                	ja     8013b6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801380:	c1 e0 0c             	shl    $0xc,%eax
  801383:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801388:	89 c2                	mov    %eax,%edx
  80138a:	c1 ea 16             	shr    $0x16,%edx
  80138d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801394:	f6 c2 01             	test   $0x1,%dl
  801397:	74 24                	je     8013bd <fd_lookup+0x48>
  801399:	89 c2                	mov    %eax,%edx
  80139b:	c1 ea 0c             	shr    $0xc,%edx
  80139e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a5:	f6 c2 01             	test   $0x1,%dl
  8013a8:	74 1a                	je     8013c4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8013af:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b4:	eb 13                	jmp    8013c9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bb:	eb 0c                	jmp    8013c9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c2:	eb 05                	jmp    8013c9 <fd_lookup+0x54>
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d4:	ba 60 2d 80 00       	mov    $0x802d60,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013d9:	eb 13                	jmp    8013ee <dev_lookup+0x23>
  8013db:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013de:	39 08                	cmp    %ecx,(%eax)
  8013e0:	75 0c                	jne    8013ee <dev_lookup+0x23>
			*dev = devtab[i];
  8013e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ec:	eb 2e                	jmp    80141c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ee:	8b 02                	mov    (%edx),%eax
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	75 e7                	jne    8013db <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013f4:	a1 08 40 80 00       	mov    0x804008,%eax
  8013f9:	8b 40 48             	mov    0x48(%eax),%eax
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	51                   	push   %ecx
  801400:	50                   	push   %eax
  801401:	68 e0 2c 80 00       	push   $0x802ce0
  801406:	e8 12 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  80140b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	83 ec 10             	sub    $0x10,%esp
  801426:	8b 75 08             	mov    0x8(%ebp),%esi
  801429:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80142c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801436:	c1 e8 0c             	shr    $0xc,%eax
  801439:	50                   	push   %eax
  80143a:	e8 36 ff ff ff       	call   801375 <fd_lookup>
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 05                	js     80144b <fd_close+0x2d>
	    || fd != fd2)
  801446:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801449:	74 0c                	je     801457 <fd_close+0x39>
		return (must_exist ? r : 0);
  80144b:	84 db                	test   %bl,%bl
  80144d:	ba 00 00 00 00       	mov    $0x0,%edx
  801452:	0f 44 c2             	cmove  %edx,%eax
  801455:	eb 41                	jmp    801498 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	ff 36                	pushl  (%esi)
  801460:	e8 66 ff ff ff       	call   8013cb <dev_lookup>
  801465:	89 c3                	mov    %eax,%ebx
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	85 c0                	test   %eax,%eax
  80146c:	78 1a                	js     801488 <fd_close+0x6a>
		if (dev->dev_close)
  80146e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801471:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801474:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801479:	85 c0                	test   %eax,%eax
  80147b:	74 0b                	je     801488 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	56                   	push   %esi
  801481:	ff d0                	call   *%eax
  801483:	89 c3                	mov    %eax,%ebx
  801485:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	56                   	push   %esi
  80148c:	6a 00                	push   $0x0
  80148e:	e8 b7 f8 ff ff       	call   800d4a <sys_page_unmap>
	return r;
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	89 d8                	mov    %ebx,%eax
}
  801498:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149b:	5b                   	pop    %ebx
  80149c:	5e                   	pop    %esi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a8:	50                   	push   %eax
  8014a9:	ff 75 08             	pushl  0x8(%ebp)
  8014ac:	e8 c4 fe ff ff       	call   801375 <fd_lookup>
  8014b1:	83 c4 08             	add    $0x8,%esp
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 10                	js     8014c8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	6a 01                	push   $0x1
  8014bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c0:	e8 59 ff ff ff       	call   80141e <fd_close>
  8014c5:	83 c4 10             	add    $0x10,%esp
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <close_all>:

void
close_all(void)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	53                   	push   %ebx
  8014da:	e8 c0 ff ff ff       	call   80149f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014df:	83 c3 01             	add    $0x1,%ebx
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	83 fb 20             	cmp    $0x20,%ebx
  8014e8:	75 ec                	jne    8014d6 <close_all+0xc>
		close(i);
}
  8014ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	57                   	push   %edi
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 2c             	sub    $0x2c,%esp
  8014f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	ff 75 08             	pushl  0x8(%ebp)
  801502:	e8 6e fe ff ff       	call   801375 <fd_lookup>
  801507:	83 c4 08             	add    $0x8,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	0f 88 c1 00 00 00    	js     8015d3 <dup+0xe4>
		return r;
	close(newfdnum);
  801512:	83 ec 0c             	sub    $0xc,%esp
  801515:	56                   	push   %esi
  801516:	e8 84 ff ff ff       	call   80149f <close>

	newfd = INDEX2FD(newfdnum);
  80151b:	89 f3                	mov    %esi,%ebx
  80151d:	c1 e3 0c             	shl    $0xc,%ebx
  801520:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801526:	83 c4 04             	add    $0x4,%esp
  801529:	ff 75 e4             	pushl  -0x1c(%ebp)
  80152c:	e8 de fd ff ff       	call   80130f <fd2data>
  801531:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801533:	89 1c 24             	mov    %ebx,(%esp)
  801536:	e8 d4 fd ff ff       	call   80130f <fd2data>
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801541:	89 f8                	mov    %edi,%eax
  801543:	c1 e8 16             	shr    $0x16,%eax
  801546:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80154d:	a8 01                	test   $0x1,%al
  80154f:	74 37                	je     801588 <dup+0x99>
  801551:	89 f8                	mov    %edi,%eax
  801553:	c1 e8 0c             	shr    $0xc,%eax
  801556:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80155d:	f6 c2 01             	test   $0x1,%dl
  801560:	74 26                	je     801588 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801562:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	25 07 0e 00 00       	and    $0xe07,%eax
  801571:	50                   	push   %eax
  801572:	ff 75 d4             	pushl  -0x2c(%ebp)
  801575:	6a 00                	push   $0x0
  801577:	57                   	push   %edi
  801578:	6a 00                	push   $0x0
  80157a:	e8 89 f7 ff ff       	call   800d08 <sys_page_map>
  80157f:	89 c7                	mov    %eax,%edi
  801581:	83 c4 20             	add    $0x20,%esp
  801584:	85 c0                	test   %eax,%eax
  801586:	78 2e                	js     8015b6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801588:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80158b:	89 d0                	mov    %edx,%eax
  80158d:	c1 e8 0c             	shr    $0xc,%eax
  801590:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	25 07 0e 00 00       	and    $0xe07,%eax
  80159f:	50                   	push   %eax
  8015a0:	53                   	push   %ebx
  8015a1:	6a 00                	push   $0x0
  8015a3:	52                   	push   %edx
  8015a4:	6a 00                	push   $0x0
  8015a6:	e8 5d f7 ff ff       	call   800d08 <sys_page_map>
  8015ab:	89 c7                	mov    %eax,%edi
  8015ad:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015b0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b2:	85 ff                	test   %edi,%edi
  8015b4:	79 1d                	jns    8015d3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	53                   	push   %ebx
  8015ba:	6a 00                	push   $0x0
  8015bc:	e8 89 f7 ff ff       	call   800d4a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015c1:	83 c4 08             	add    $0x8,%esp
  8015c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015c7:	6a 00                	push   $0x0
  8015c9:	e8 7c f7 ff ff       	call   800d4a <sys_page_unmap>
	return r;
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	89 f8                	mov    %edi,%eax
}
  8015d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	83 ec 14             	sub    $0x14,%esp
  8015e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	53                   	push   %ebx
  8015ea:	e8 86 fd ff ff       	call   801375 <fd_lookup>
  8015ef:	83 c4 08             	add    $0x8,%esp
  8015f2:	89 c2                	mov    %eax,%edx
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 6d                	js     801665 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801602:	ff 30                	pushl  (%eax)
  801604:	e8 c2 fd ff ff       	call   8013cb <dev_lookup>
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 4c                	js     80165c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801610:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801613:	8b 42 08             	mov    0x8(%edx),%eax
  801616:	83 e0 03             	and    $0x3,%eax
  801619:	83 f8 01             	cmp    $0x1,%eax
  80161c:	75 21                	jne    80163f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80161e:	a1 08 40 80 00       	mov    0x804008,%eax
  801623:	8b 40 48             	mov    0x48(%eax),%eax
  801626:	83 ec 04             	sub    $0x4,%esp
  801629:	53                   	push   %ebx
  80162a:	50                   	push   %eax
  80162b:	68 24 2d 80 00       	push   $0x802d24
  801630:	e8 e8 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80163d:	eb 26                	jmp    801665 <read+0x8a>
	}
	if (!dev->dev_read)
  80163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801642:	8b 40 08             	mov    0x8(%eax),%eax
  801645:	85 c0                	test   %eax,%eax
  801647:	74 17                	je     801660 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801649:	83 ec 04             	sub    $0x4,%esp
  80164c:	ff 75 10             	pushl  0x10(%ebp)
  80164f:	ff 75 0c             	pushl  0xc(%ebp)
  801652:	52                   	push   %edx
  801653:	ff d0                	call   *%eax
  801655:	89 c2                	mov    %eax,%edx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	eb 09                	jmp    801665 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	eb 05                	jmp    801665 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801660:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801665:	89 d0                	mov    %edx,%eax
  801667:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    

0080166c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	8b 7d 08             	mov    0x8(%ebp),%edi
  801678:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801680:	eb 21                	jmp    8016a3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	89 f0                	mov    %esi,%eax
  801687:	29 d8                	sub    %ebx,%eax
  801689:	50                   	push   %eax
  80168a:	89 d8                	mov    %ebx,%eax
  80168c:	03 45 0c             	add    0xc(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	57                   	push   %edi
  801691:	e8 45 ff ff ff       	call   8015db <read>
		if (m < 0)
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 10                	js     8016ad <readn+0x41>
			return m;
		if (m == 0)
  80169d:	85 c0                	test   %eax,%eax
  80169f:	74 0a                	je     8016ab <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a1:	01 c3                	add    %eax,%ebx
  8016a3:	39 f3                	cmp    %esi,%ebx
  8016a5:	72 db                	jb     801682 <readn+0x16>
  8016a7:	89 d8                	mov    %ebx,%eax
  8016a9:	eb 02                	jmp    8016ad <readn+0x41>
  8016ab:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8016ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5e                   	pop    %esi
  8016b2:	5f                   	pop    %edi
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 14             	sub    $0x14,%esp
  8016bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c2:	50                   	push   %eax
  8016c3:	53                   	push   %ebx
  8016c4:	e8 ac fc ff ff       	call   801375 <fd_lookup>
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	89 c2                	mov    %eax,%edx
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 68                	js     80173a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d8:	50                   	push   %eax
  8016d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dc:	ff 30                	pushl  (%eax)
  8016de:	e8 e8 fc ff ff       	call   8013cb <dev_lookup>
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 47                	js     801731 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f1:	75 21                	jne    801714 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f3:	a1 08 40 80 00       	mov    0x804008,%eax
  8016f8:	8b 40 48             	mov    0x48(%eax),%eax
  8016fb:	83 ec 04             	sub    $0x4,%esp
  8016fe:	53                   	push   %ebx
  8016ff:	50                   	push   %eax
  801700:	68 40 2d 80 00       	push   $0x802d40
  801705:	e8 13 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801712:	eb 26                	jmp    80173a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801714:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801717:	8b 52 0c             	mov    0xc(%edx),%edx
  80171a:	85 d2                	test   %edx,%edx
  80171c:	74 17                	je     801735 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80171e:	83 ec 04             	sub    $0x4,%esp
  801721:	ff 75 10             	pushl  0x10(%ebp)
  801724:	ff 75 0c             	pushl  0xc(%ebp)
  801727:	50                   	push   %eax
  801728:	ff d2                	call   *%edx
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	83 c4 10             	add    $0x10,%esp
  80172f:	eb 09                	jmp    80173a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801731:	89 c2                	mov    %eax,%edx
  801733:	eb 05                	jmp    80173a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801735:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80173a:	89 d0                	mov    %edx,%eax
  80173c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <seek>:

int
seek(int fdnum, off_t offset)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801747:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80174a:	50                   	push   %eax
  80174b:	ff 75 08             	pushl  0x8(%ebp)
  80174e:	e8 22 fc ff ff       	call   801375 <fd_lookup>
  801753:	83 c4 08             	add    $0x8,%esp
  801756:	85 c0                	test   %eax,%eax
  801758:	78 0e                	js     801768 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80175a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80175d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801760:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801763:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 14             	sub    $0x14,%esp
  801771:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	53                   	push   %ebx
  801779:	e8 f7 fb ff ff       	call   801375 <fd_lookup>
  80177e:	83 c4 08             	add    $0x8,%esp
  801781:	89 c2                	mov    %eax,%edx
  801783:	85 c0                	test   %eax,%eax
  801785:	78 65                	js     8017ec <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	ff 30                	pushl  (%eax)
  801793:	e8 33 fc ff ff       	call   8013cb <dev_lookup>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 44                	js     8017e3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a6:	75 21                	jne    8017c9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017a8:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017ad:	8b 40 48             	mov    0x48(%eax),%eax
  8017b0:	83 ec 04             	sub    $0x4,%esp
  8017b3:	53                   	push   %ebx
  8017b4:	50                   	push   %eax
  8017b5:	68 00 2d 80 00       	push   $0x802d00
  8017ba:	e8 5e eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c7:	eb 23                	jmp    8017ec <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cc:	8b 52 18             	mov    0x18(%edx),%edx
  8017cf:	85 d2                	test   %edx,%edx
  8017d1:	74 14                	je     8017e7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	ff 75 0c             	pushl  0xc(%ebp)
  8017d9:	50                   	push   %eax
  8017da:	ff d2                	call   *%edx
  8017dc:	89 c2                	mov    %eax,%edx
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	eb 09                	jmp    8017ec <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e3:	89 c2                	mov    %eax,%edx
  8017e5:	eb 05                	jmp    8017ec <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017ec:	89 d0                	mov    %edx,%eax
  8017ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f1:	c9                   	leave  
  8017f2:	c3                   	ret    

008017f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	53                   	push   %ebx
  8017f7:	83 ec 14             	sub    $0x14,%esp
  8017fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	ff 75 08             	pushl  0x8(%ebp)
  801804:	e8 6c fb ff ff       	call   801375 <fd_lookup>
  801809:	83 c4 08             	add    $0x8,%esp
  80180c:	89 c2                	mov    %eax,%edx
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 58                	js     80186a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801818:	50                   	push   %eax
  801819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181c:	ff 30                	pushl  (%eax)
  80181e:	e8 a8 fb ff ff       	call   8013cb <dev_lookup>
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	85 c0                	test   %eax,%eax
  801828:	78 37                	js     801861 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80182a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801831:	74 32                	je     801865 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801833:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801836:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80183d:	00 00 00 
	stat->st_isdir = 0;
  801840:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801847:	00 00 00 
	stat->st_dev = dev;
  80184a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	53                   	push   %ebx
  801854:	ff 75 f0             	pushl  -0x10(%ebp)
  801857:	ff 50 14             	call   *0x14(%eax)
  80185a:	89 c2                	mov    %eax,%edx
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	eb 09                	jmp    80186a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801861:	89 c2                	mov    %eax,%edx
  801863:	eb 05                	jmp    80186a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801865:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80186a:	89 d0                	mov    %edx,%eax
  80186c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	6a 00                	push   $0x0
  80187b:	ff 75 08             	pushl  0x8(%ebp)
  80187e:	e8 ef 01 00 00       	call   801a72 <open>
  801883:	89 c3                	mov    %eax,%ebx
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 1b                	js     8018a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80188c:	83 ec 08             	sub    $0x8,%esp
  80188f:	ff 75 0c             	pushl  0xc(%ebp)
  801892:	50                   	push   %eax
  801893:	e8 5b ff ff ff       	call   8017f3 <fstat>
  801898:	89 c6                	mov    %eax,%esi
	close(fd);
  80189a:	89 1c 24             	mov    %ebx,(%esp)
  80189d:	e8 fd fb ff ff       	call   80149f <close>
	return r;
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	89 f0                	mov    %esi,%eax
}
  8018a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	56                   	push   %esi
  8018b2:	53                   	push   %ebx
  8018b3:	89 c6                	mov    %eax,%esi
  8018b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018b7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018be:	75 12                	jne    8018d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018c0:	83 ec 0c             	sub    $0xc,%esp
  8018c3:	6a 01                	push   $0x1
  8018c5:	e8 fc f9 ff ff       	call   8012c6 <ipc_find_env>
  8018ca:	a3 00 40 80 00       	mov    %eax,0x804000
  8018cf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d2:	6a 07                	push   $0x7
  8018d4:	68 00 50 80 00       	push   $0x805000
  8018d9:	56                   	push   %esi
  8018da:	ff 35 00 40 80 00    	pushl  0x804000
  8018e0:	e8 92 f9 ff ff       	call   801277 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018e5:	83 c4 0c             	add    $0xc,%esp
  8018e8:	6a 00                	push   $0x0
  8018ea:	53                   	push   %ebx
  8018eb:	6a 00                	push   $0x0
  8018ed:	e8 0f f9 ff ff       	call   801201 <ipc_recv>
}
  8018f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f5:	5b                   	pop    %ebx
  8018f6:	5e                   	pop    %esi
  8018f7:	5d                   	pop    %ebp
  8018f8:	c3                   	ret    

008018f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	8b 40 0c             	mov    0xc(%eax),%eax
  801905:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80190a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 02 00 00 00       	mov    $0x2,%eax
  80191c:	e8 8d ff ff ff       	call   8018ae <fsipc>
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	8b 40 0c             	mov    0xc(%eax),%eax
  80192f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
  801939:	b8 06 00 00 00       	mov    $0x6,%eax
  80193e:	e8 6b ff ff ff       	call   8018ae <fsipc>
}
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	53                   	push   %ebx
  801949:	83 ec 04             	sub    $0x4,%esp
  80194c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	8b 40 0c             	mov    0xc(%eax),%eax
  801955:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	b8 05 00 00 00       	mov    $0x5,%eax
  801964:	e8 45 ff ff ff       	call   8018ae <fsipc>
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 2c                	js     801999 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	68 00 50 80 00       	push   $0x805000
  801975:	53                   	push   %ebx
  801976:	e8 47 ef ff ff       	call   8008c2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80197b:	a1 80 50 80 00       	mov    0x805080,%eax
  801980:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801986:	a1 84 50 80 00       	mov    0x805084,%eax
  80198b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801999:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8019ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8019ae:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019b4:	a3 04 50 80 00       	mov    %eax,0x805004
  8019b9:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8019be:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8019c3:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8019c6:	53                   	push   %ebx
  8019c7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ca:	68 08 50 80 00       	push   $0x805008
  8019cf:	e8 80 f0 ff ff       	call   800a54 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d9:	b8 04 00 00 00       	mov    $0x4,%eax
  8019de:	e8 cb fe ff ff       	call   8018ae <fsipc>
  8019e3:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8019eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ee:	c9                   	leave  
  8019ef:	c3                   	ret    

008019f0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	56                   	push   %esi
  8019f4:	53                   	push   %ebx
  8019f5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a03:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a09:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0e:	b8 03 00 00 00       	mov    $0x3,%eax
  801a13:	e8 96 fe ff ff       	call   8018ae <fsipc>
  801a18:	89 c3                	mov    %eax,%ebx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 4b                	js     801a69 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a1e:	39 c6                	cmp    %eax,%esi
  801a20:	73 16                	jae    801a38 <devfile_read+0x48>
  801a22:	68 74 2d 80 00       	push   $0x802d74
  801a27:	68 7b 2d 80 00       	push   $0x802d7b
  801a2c:	6a 7c                	push   $0x7c
  801a2e:	68 90 2d 80 00       	push   $0x802d90
  801a33:	e8 0c e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801a38:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a3d:	7e 16                	jle    801a55 <devfile_read+0x65>
  801a3f:	68 9b 2d 80 00       	push   $0x802d9b
  801a44:	68 7b 2d 80 00       	push   $0x802d7b
  801a49:	6a 7d                	push   $0x7d
  801a4b:	68 90 2d 80 00       	push   $0x802d90
  801a50:	e8 ef e7 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a55:	83 ec 04             	sub    $0x4,%esp
  801a58:	50                   	push   %eax
  801a59:	68 00 50 80 00       	push   $0x805000
  801a5e:	ff 75 0c             	pushl  0xc(%ebp)
  801a61:	e8 ee ef ff ff       	call   800a54 <memmove>
	return r;
  801a66:	83 c4 10             	add    $0x10,%esp
}
  801a69:	89 d8                	mov    %ebx,%eax
  801a6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	53                   	push   %ebx
  801a76:	83 ec 20             	sub    $0x20,%esp
  801a79:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a7c:	53                   	push   %ebx
  801a7d:	e8 07 ee ff ff       	call   800889 <strlen>
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a8a:	7f 67                	jg     801af3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	e8 8e f8 ff ff       	call   801326 <fd_alloc>
  801a98:	83 c4 10             	add    $0x10,%esp
		return r;
  801a9b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 57                	js     801af8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	53                   	push   %ebx
  801aa5:	68 00 50 80 00       	push   $0x805000
  801aaa:	e8 13 ee ff ff       	call   8008c2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ab7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aba:	b8 01 00 00 00       	mov    $0x1,%eax
  801abf:	e8 ea fd ff ff       	call   8018ae <fsipc>
  801ac4:	89 c3                	mov    %eax,%ebx
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	79 14                	jns    801ae1 <open+0x6f>
		fd_close(fd, 0);
  801acd:	83 ec 08             	sub    $0x8,%esp
  801ad0:	6a 00                	push   $0x0
  801ad2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad5:	e8 44 f9 ff ff       	call   80141e <fd_close>
		return r;
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	89 da                	mov    %ebx,%edx
  801adf:	eb 17                	jmp    801af8 <open+0x86>
	}

	return fd2num(fd);
  801ae1:	83 ec 0c             	sub    $0xc,%esp
  801ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae7:	e8 13 f8 ff ff       	call   8012ff <fd2num>
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	eb 05                	jmp    801af8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801af3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801af8:	89 d0                	mov    %edx,%eax
  801afa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b05:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0a:	b8 08 00 00 00       	mov    $0x8,%eax
  801b0f:	e8 9a fd ff ff       	call   8018ae <fsipc>
}
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1c:	89 d0                	mov    %edx,%eax
  801b1e:	c1 e8 16             	shr    $0x16,%eax
  801b21:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2d:	f6 c1 01             	test   $0x1,%cl
  801b30:	74 1d                	je     801b4f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b32:	c1 ea 0c             	shr    $0xc,%edx
  801b35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b3c:	f6 c2 01             	test   $0x1,%dl
  801b3f:	74 0e                	je     801b4f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b41:	c1 ea 0c             	shr    $0xc,%edx
  801b44:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b4b:	ef 
  801b4c:	0f b7 c0             	movzwl %ax,%eax
}
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	56                   	push   %esi
  801b55:	53                   	push   %ebx
  801b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b59:	83 ec 0c             	sub    $0xc,%esp
  801b5c:	ff 75 08             	pushl  0x8(%ebp)
  801b5f:	e8 ab f7 ff ff       	call   80130f <fd2data>
  801b64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b66:	83 c4 08             	add    $0x8,%esp
  801b69:	68 a7 2d 80 00       	push   $0x802da7
  801b6e:	53                   	push   %ebx
  801b6f:	e8 4e ed ff ff       	call   8008c2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b74:	8b 46 04             	mov    0x4(%esi),%eax
  801b77:	2b 06                	sub    (%esi),%eax
  801b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b86:	00 00 00 
	stat->st_dev = &devpipe;
  801b89:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b90:	30 80 00 
	return 0;
}
  801b93:	b8 00 00 00 00       	mov    $0x0,%eax
  801b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5e                   	pop    %esi
  801b9d:	5d                   	pop    %ebp
  801b9e:	c3                   	ret    

00801b9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	53                   	push   %ebx
  801ba3:	83 ec 0c             	sub    $0xc,%esp
  801ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ba9:	53                   	push   %ebx
  801baa:	6a 00                	push   $0x0
  801bac:	e8 99 f1 ff ff       	call   800d4a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb1:	89 1c 24             	mov    %ebx,(%esp)
  801bb4:	e8 56 f7 ff ff       	call   80130f <fd2data>
  801bb9:	83 c4 08             	add    $0x8,%esp
  801bbc:	50                   	push   %eax
  801bbd:	6a 00                	push   $0x0
  801bbf:	e8 86 f1 ff ff       	call   800d4a <sys_page_unmap>
}
  801bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	57                   	push   %edi
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 1c             	sub    $0x1c,%esp
  801bd2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bd7:	a1 08 40 80 00       	mov    0x804008,%eax
  801bdc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bdf:	83 ec 0c             	sub    $0xc,%esp
  801be2:	ff 75 e0             	pushl  -0x20(%ebp)
  801be5:	e8 2c ff ff ff       	call   801b16 <pageref>
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	89 3c 24             	mov    %edi,(%esp)
  801bef:	e8 22 ff ff ff       	call   801b16 <pageref>
  801bf4:	83 c4 10             	add    $0x10,%esp
  801bf7:	39 c3                	cmp    %eax,%ebx
  801bf9:	0f 94 c1             	sete   %cl
  801bfc:	0f b6 c9             	movzbl %cl,%ecx
  801bff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c02:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c08:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c0b:	39 ce                	cmp    %ecx,%esi
  801c0d:	74 1b                	je     801c2a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c0f:	39 c3                	cmp    %eax,%ebx
  801c11:	75 c4                	jne    801bd7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c13:	8b 42 58             	mov    0x58(%edx),%eax
  801c16:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c19:	50                   	push   %eax
  801c1a:	56                   	push   %esi
  801c1b:	68 ae 2d 80 00       	push   $0x802dae
  801c20:	e8 f8 e6 ff ff       	call   80031d <cprintf>
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	eb ad                	jmp    801bd7 <_pipeisclosed+0xe>
	}
}
  801c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	57                   	push   %edi
  801c39:	56                   	push   %esi
  801c3a:	53                   	push   %ebx
  801c3b:	83 ec 28             	sub    $0x28,%esp
  801c3e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c41:	56                   	push   %esi
  801c42:	e8 c8 f6 ff ff       	call   80130f <fd2data>
  801c47:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	bf 00 00 00 00       	mov    $0x0,%edi
  801c51:	eb 4b                	jmp    801c9e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c53:	89 da                	mov    %ebx,%edx
  801c55:	89 f0                	mov    %esi,%eax
  801c57:	e8 6d ff ff ff       	call   801bc9 <_pipeisclosed>
  801c5c:	85 c0                	test   %eax,%eax
  801c5e:	75 48                	jne    801ca8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c60:	e8 41 f0 ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c65:	8b 43 04             	mov    0x4(%ebx),%eax
  801c68:	8b 0b                	mov    (%ebx),%ecx
  801c6a:	8d 51 20             	lea    0x20(%ecx),%edx
  801c6d:	39 d0                	cmp    %edx,%eax
  801c6f:	73 e2                	jae    801c53 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c74:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c78:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c7b:	89 c2                	mov    %eax,%edx
  801c7d:	c1 fa 1f             	sar    $0x1f,%edx
  801c80:	89 d1                	mov    %edx,%ecx
  801c82:	c1 e9 1b             	shr    $0x1b,%ecx
  801c85:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c88:	83 e2 1f             	and    $0x1f,%edx
  801c8b:	29 ca                	sub    %ecx,%edx
  801c8d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c91:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c95:	83 c0 01             	add    $0x1,%eax
  801c98:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9b:	83 c7 01             	add    $0x1,%edi
  801c9e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ca1:	75 c2                	jne    801c65 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ca3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca6:	eb 05                	jmp    801cad <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	57                   	push   %edi
  801cb9:	56                   	push   %esi
  801cba:	53                   	push   %ebx
  801cbb:	83 ec 18             	sub    $0x18,%esp
  801cbe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cc1:	57                   	push   %edi
  801cc2:	e8 48 f6 ff ff       	call   80130f <fd2data>
  801cc7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc9:	83 c4 10             	add    $0x10,%esp
  801ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd1:	eb 3d                	jmp    801d10 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cd3:	85 db                	test   %ebx,%ebx
  801cd5:	74 04                	je     801cdb <devpipe_read+0x26>
				return i;
  801cd7:	89 d8                	mov    %ebx,%eax
  801cd9:	eb 44                	jmp    801d1f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cdb:	89 f2                	mov    %esi,%edx
  801cdd:	89 f8                	mov    %edi,%eax
  801cdf:	e8 e5 fe ff ff       	call   801bc9 <_pipeisclosed>
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	75 32                	jne    801d1a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ce8:	e8 b9 ef ff ff       	call   800ca6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ced:	8b 06                	mov    (%esi),%eax
  801cef:	3b 46 04             	cmp    0x4(%esi),%eax
  801cf2:	74 df                	je     801cd3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf4:	99                   	cltd   
  801cf5:	c1 ea 1b             	shr    $0x1b,%edx
  801cf8:	01 d0                	add    %edx,%eax
  801cfa:	83 e0 1f             	and    $0x1f,%eax
  801cfd:	29 d0                	sub    %edx,%eax
  801cff:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d07:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d0a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0d:	83 c3 01             	add    $0x1,%ebx
  801d10:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d13:	75 d8                	jne    801ced <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d15:	8b 45 10             	mov    0x10(%ebp),%eax
  801d18:	eb 05                	jmp    801d1f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d1a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d22:	5b                   	pop    %ebx
  801d23:	5e                   	pop    %esi
  801d24:	5f                   	pop    %edi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	56                   	push   %esi
  801d2b:	53                   	push   %ebx
  801d2c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d32:	50                   	push   %eax
  801d33:	e8 ee f5 ff ff       	call   801326 <fd_alloc>
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	89 c2                	mov    %eax,%edx
  801d3d:	85 c0                	test   %eax,%eax
  801d3f:	0f 88 2c 01 00 00    	js     801e71 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	68 07 04 00 00       	push   $0x407
  801d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d50:	6a 00                	push   $0x0
  801d52:	e8 6e ef ff ff       	call   800cc5 <sys_page_alloc>
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	89 c2                	mov    %eax,%edx
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	0f 88 0d 01 00 00    	js     801e71 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d64:	83 ec 0c             	sub    $0xc,%esp
  801d67:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6a:	50                   	push   %eax
  801d6b:	e8 b6 f5 ff ff       	call   801326 <fd_alloc>
  801d70:	89 c3                	mov    %eax,%ebx
  801d72:	83 c4 10             	add    $0x10,%esp
  801d75:	85 c0                	test   %eax,%eax
  801d77:	0f 88 e2 00 00 00    	js     801e5f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	68 07 04 00 00       	push   $0x407
  801d85:	ff 75 f0             	pushl  -0x10(%ebp)
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 36 ef ff ff       	call   800cc5 <sys_page_alloc>
  801d8f:	89 c3                	mov    %eax,%ebx
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	85 c0                	test   %eax,%eax
  801d96:	0f 88 c3 00 00 00    	js     801e5f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d9c:	83 ec 0c             	sub    $0xc,%esp
  801d9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801da2:	e8 68 f5 ff ff       	call   80130f <fd2data>
  801da7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da9:	83 c4 0c             	add    $0xc,%esp
  801dac:	68 07 04 00 00       	push   $0x407
  801db1:	50                   	push   %eax
  801db2:	6a 00                	push   $0x0
  801db4:	e8 0c ef ff ff       	call   800cc5 <sys_page_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 89 00 00 00    	js     801e4f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc6:	83 ec 0c             	sub    $0xc,%esp
  801dc9:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcc:	e8 3e f5 ff ff       	call   80130f <fd2data>
  801dd1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dd8:	50                   	push   %eax
  801dd9:	6a 00                	push   $0x0
  801ddb:	56                   	push   %esi
  801ddc:	6a 00                	push   $0x0
  801dde:	e8 25 ef ff ff       	call   800d08 <sys_page_map>
  801de3:	89 c3                	mov    %eax,%ebx
  801de5:	83 c4 20             	add    $0x20,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	78 55                	js     801e41 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dec:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e01:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e16:	83 ec 0c             	sub    $0xc,%esp
  801e19:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1c:	e8 de f4 ff ff       	call   8012ff <fd2num>
  801e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e24:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e26:	83 c4 04             	add    $0x4,%esp
  801e29:	ff 75 f0             	pushl  -0x10(%ebp)
  801e2c:	e8 ce f4 ff ff       	call   8012ff <fd2num>
  801e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e34:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e3f:	eb 30                	jmp    801e71 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	56                   	push   %esi
  801e45:	6a 00                	push   $0x0
  801e47:	e8 fe ee ff ff       	call   800d4a <sys_page_unmap>
  801e4c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e4f:	83 ec 08             	sub    $0x8,%esp
  801e52:	ff 75 f0             	pushl  -0x10(%ebp)
  801e55:	6a 00                	push   $0x0
  801e57:	e8 ee ee ff ff       	call   800d4a <sys_page_unmap>
  801e5c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e5f:	83 ec 08             	sub    $0x8,%esp
  801e62:	ff 75 f4             	pushl  -0xc(%ebp)
  801e65:	6a 00                	push   $0x0
  801e67:	e8 de ee ff ff       	call   800d4a <sys_page_unmap>
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e71:	89 d0                	mov    %edx,%eax
  801e73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e76:	5b                   	pop    %ebx
  801e77:	5e                   	pop    %esi
  801e78:	5d                   	pop    %ebp
  801e79:	c3                   	ret    

00801e7a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e83:	50                   	push   %eax
  801e84:	ff 75 08             	pushl  0x8(%ebp)
  801e87:	e8 e9 f4 ff ff       	call   801375 <fd_lookup>
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 18                	js     801eab <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e93:	83 ec 0c             	sub    $0xc,%esp
  801e96:	ff 75 f4             	pushl  -0xc(%ebp)
  801e99:	e8 71 f4 ff ff       	call   80130f <fd2data>
	return _pipeisclosed(fd, p);
  801e9e:	89 c2                	mov    %eax,%edx
  801ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea3:	e8 21 fd ff ff       	call   801bc9 <_pipeisclosed>
  801ea8:	83 c4 10             	add    $0x10,%esp
}
  801eab:	c9                   	leave  
  801eac:	c3                   	ret    

00801ead <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801eb3:	68 c6 2d 80 00       	push   $0x802dc6
  801eb8:	ff 75 0c             	pushl  0xc(%ebp)
  801ebb:	e8 02 ea ff ff       	call   8008c2 <strcpy>
	return 0;
}
  801ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 10             	sub    $0x10,%esp
  801ece:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ed1:	53                   	push   %ebx
  801ed2:	e8 3f fc ff ff       	call   801b16 <pageref>
  801ed7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801eda:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801edf:	83 f8 01             	cmp    $0x1,%eax
  801ee2:	75 10                	jne    801ef4 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ee4:	83 ec 0c             	sub    $0xc,%esp
  801ee7:	ff 73 0c             	pushl  0xc(%ebx)
  801eea:	e8 c0 02 00 00       	call   8021af <nsipc_close>
  801eef:	89 c2                	mov    %eax,%edx
  801ef1:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f01:	6a 00                	push   $0x0
  801f03:	ff 75 10             	pushl  0x10(%ebp)
  801f06:	ff 75 0c             	pushl  0xc(%ebp)
  801f09:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0c:	ff 70 0c             	pushl  0xc(%eax)
  801f0f:	e8 78 03 00 00       	call   80228c <nsipc_send>
}
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
  801f19:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f1c:	6a 00                	push   $0x0
  801f1e:	ff 75 10             	pushl  0x10(%ebp)
  801f21:	ff 75 0c             	pushl  0xc(%ebp)
  801f24:	8b 45 08             	mov    0x8(%ebp),%eax
  801f27:	ff 70 0c             	pushl  0xc(%eax)
  801f2a:	e8 f1 02 00 00       	call   802220 <nsipc_recv>
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f37:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f3a:	52                   	push   %edx
  801f3b:	50                   	push   %eax
  801f3c:	e8 34 f4 ff ff       	call   801375 <fd_lookup>
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 17                	js     801f5f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4b:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801f51:	39 08                	cmp    %ecx,(%eax)
  801f53:	75 05                	jne    801f5a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f55:	8b 40 0c             	mov    0xc(%eax),%eax
  801f58:	eb 05                	jmp    801f5f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f5a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
  801f66:	83 ec 1c             	sub    $0x1c,%esp
  801f69:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6e:	50                   	push   %eax
  801f6f:	e8 b2 f3 ff ff       	call   801326 <fd_alloc>
  801f74:	89 c3                	mov    %eax,%ebx
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	78 1b                	js     801f98 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f7d:	83 ec 04             	sub    $0x4,%esp
  801f80:	68 07 04 00 00       	push   $0x407
  801f85:	ff 75 f4             	pushl  -0xc(%ebp)
  801f88:	6a 00                	push   $0x0
  801f8a:	e8 36 ed ff ff       	call   800cc5 <sys_page_alloc>
  801f8f:	89 c3                	mov    %eax,%ebx
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	85 c0                	test   %eax,%eax
  801f96:	79 10                	jns    801fa8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f98:	83 ec 0c             	sub    $0xc,%esp
  801f9b:	56                   	push   %esi
  801f9c:	e8 0e 02 00 00       	call   8021af <nsipc_close>
		return r;
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	89 d8                	mov    %ebx,%eax
  801fa6:	eb 24                	jmp    801fcc <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fa8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fbd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	50                   	push   %eax
  801fc4:	e8 36 f3 ff ff       	call   8012ff <fd2num>
  801fc9:	83 c4 10             	add    $0x10,%esp
}
  801fcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5d                   	pop    %ebp
  801fd2:	c3                   	ret    

00801fd3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fd3:	55                   	push   %ebp
  801fd4:	89 e5                	mov    %esp,%ebp
  801fd6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdc:	e8 50 ff ff ff       	call   801f31 <fd2sockid>
		return r;
  801fe1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	78 1f                	js     802006 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fe7:	83 ec 04             	sub    $0x4,%esp
  801fea:	ff 75 10             	pushl  0x10(%ebp)
  801fed:	ff 75 0c             	pushl  0xc(%ebp)
  801ff0:	50                   	push   %eax
  801ff1:	e8 12 01 00 00       	call   802108 <nsipc_accept>
  801ff6:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff9:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	78 07                	js     802006 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801fff:	e8 5d ff ff ff       	call   801f61 <alloc_sockfd>
  802004:	89 c1                	mov    %eax,%ecx
}
  802006:	89 c8                	mov    %ecx,%eax
  802008:	c9                   	leave  
  802009:	c3                   	ret    

0080200a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802010:	8b 45 08             	mov    0x8(%ebp),%eax
  802013:	e8 19 ff ff ff       	call   801f31 <fd2sockid>
  802018:	85 c0                	test   %eax,%eax
  80201a:	78 12                	js     80202e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80201c:	83 ec 04             	sub    $0x4,%esp
  80201f:	ff 75 10             	pushl  0x10(%ebp)
  802022:	ff 75 0c             	pushl  0xc(%ebp)
  802025:	50                   	push   %eax
  802026:	e8 2d 01 00 00       	call   802158 <nsipc_bind>
  80202b:	83 c4 10             	add    $0x10,%esp
}
  80202e:	c9                   	leave  
  80202f:	c3                   	ret    

00802030 <shutdown>:

int
shutdown(int s, int how)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802036:	8b 45 08             	mov    0x8(%ebp),%eax
  802039:	e8 f3 fe ff ff       	call   801f31 <fd2sockid>
  80203e:	85 c0                	test   %eax,%eax
  802040:	78 0f                	js     802051 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802042:	83 ec 08             	sub    $0x8,%esp
  802045:	ff 75 0c             	pushl  0xc(%ebp)
  802048:	50                   	push   %eax
  802049:	e8 3f 01 00 00       	call   80218d <nsipc_shutdown>
  80204e:	83 c4 10             	add    $0x10,%esp
}
  802051:	c9                   	leave  
  802052:	c3                   	ret    

00802053 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802059:	8b 45 08             	mov    0x8(%ebp),%eax
  80205c:	e8 d0 fe ff ff       	call   801f31 <fd2sockid>
  802061:	85 c0                	test   %eax,%eax
  802063:	78 12                	js     802077 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802065:	83 ec 04             	sub    $0x4,%esp
  802068:	ff 75 10             	pushl  0x10(%ebp)
  80206b:	ff 75 0c             	pushl  0xc(%ebp)
  80206e:	50                   	push   %eax
  80206f:	e8 55 01 00 00       	call   8021c9 <nsipc_connect>
  802074:	83 c4 10             	add    $0x10,%esp
}
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <listen>:

int
listen(int s, int backlog)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80207f:	8b 45 08             	mov    0x8(%ebp),%eax
  802082:	e8 aa fe ff ff       	call   801f31 <fd2sockid>
  802087:	85 c0                	test   %eax,%eax
  802089:	78 0f                	js     80209a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80208b:	83 ec 08             	sub    $0x8,%esp
  80208e:	ff 75 0c             	pushl  0xc(%ebp)
  802091:	50                   	push   %eax
  802092:	e8 67 01 00 00       	call   8021fe <nsipc_listen>
  802097:	83 c4 10             	add    $0x10,%esp
}
  80209a:	c9                   	leave  
  80209b:	c3                   	ret    

0080209c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020a2:	ff 75 10             	pushl  0x10(%ebp)
  8020a5:	ff 75 0c             	pushl  0xc(%ebp)
  8020a8:	ff 75 08             	pushl  0x8(%ebp)
  8020ab:	e8 3a 02 00 00       	call   8022ea <nsipc_socket>
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	78 05                	js     8020bc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020b7:	e8 a5 fe ff ff       	call   801f61 <alloc_sockfd>
}
  8020bc:	c9                   	leave  
  8020bd:	c3                   	ret    

008020be <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	53                   	push   %ebx
  8020c2:	83 ec 04             	sub    $0x4,%esp
  8020c5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020c7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8020ce:	75 12                	jne    8020e2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020d0:	83 ec 0c             	sub    $0xc,%esp
  8020d3:	6a 02                	push   $0x2
  8020d5:	e8 ec f1 ff ff       	call   8012c6 <ipc_find_env>
  8020da:	a3 04 40 80 00       	mov    %eax,0x804004
  8020df:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020e2:	6a 07                	push   $0x7
  8020e4:	68 00 60 80 00       	push   $0x806000
  8020e9:	53                   	push   %ebx
  8020ea:	ff 35 04 40 80 00    	pushl  0x804004
  8020f0:	e8 82 f1 ff ff       	call   801277 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020f5:	83 c4 0c             	add    $0xc,%esp
  8020f8:	6a 00                	push   $0x0
  8020fa:	6a 00                	push   $0x0
  8020fc:	6a 00                	push   $0x0
  8020fe:	e8 fe f0 ff ff       	call   801201 <ipc_recv>
}
  802103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	56                   	push   %esi
  80210c:	53                   	push   %ebx
  80210d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802110:	8b 45 08             	mov    0x8(%ebp),%eax
  802113:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802118:	8b 06                	mov    (%esi),%eax
  80211a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80211f:	b8 01 00 00 00       	mov    $0x1,%eax
  802124:	e8 95 ff ff ff       	call   8020be <nsipc>
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	85 c0                	test   %eax,%eax
  80212d:	78 20                	js     80214f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80212f:	83 ec 04             	sub    $0x4,%esp
  802132:	ff 35 10 60 80 00    	pushl  0x806010
  802138:	68 00 60 80 00       	push   $0x806000
  80213d:	ff 75 0c             	pushl  0xc(%ebp)
  802140:	e8 0f e9 ff ff       	call   800a54 <memmove>
		*addrlen = ret->ret_addrlen;
  802145:	a1 10 60 80 00       	mov    0x806010,%eax
  80214a:	89 06                	mov    %eax,(%esi)
  80214c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80214f:	89 d8                	mov    %ebx,%eax
  802151:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    

00802158 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	53                   	push   %ebx
  80215c:	83 ec 08             	sub    $0x8,%esp
  80215f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802162:	8b 45 08             	mov    0x8(%ebp),%eax
  802165:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80216a:	53                   	push   %ebx
  80216b:	ff 75 0c             	pushl  0xc(%ebp)
  80216e:	68 04 60 80 00       	push   $0x806004
  802173:	e8 dc e8 ff ff       	call   800a54 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802178:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80217e:	b8 02 00 00 00       	mov    $0x2,%eax
  802183:	e8 36 ff ff ff       	call   8020be <nsipc>
}
  802188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80218b:	c9                   	leave  
  80218c:	c3                   	ret    

0080218d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
  802190:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802193:	8b 45 08             	mov    0x8(%ebp),%eax
  802196:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80219b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8021a3:	b8 03 00 00 00       	mov    $0x3,%eax
  8021a8:	e8 11 ff ff ff       	call   8020be <nsipc>
}
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    

008021af <nsipc_close>:

int
nsipc_close(int s)
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8021bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8021c2:	e8 f7 fe ff ff       	call   8020be <nsipc>
}
  8021c7:	c9                   	leave  
  8021c8:	c3                   	ret    

008021c9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021c9:	55                   	push   %ebp
  8021ca:	89 e5                	mov    %esp,%ebp
  8021cc:	53                   	push   %ebx
  8021cd:	83 ec 08             	sub    $0x8,%esp
  8021d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021db:	53                   	push   %ebx
  8021dc:	ff 75 0c             	pushl  0xc(%ebp)
  8021df:	68 04 60 80 00       	push   $0x806004
  8021e4:	e8 6b e8 ff ff       	call   800a54 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021e9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8021ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8021f4:	e8 c5 fe ff ff       	call   8020be <nsipc>
}
  8021f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802204:	8b 45 08             	mov    0x8(%ebp),%eax
  802207:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80220c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802214:	b8 06 00 00 00       	mov    $0x6,%eax
  802219:	e8 a0 fe ff ff       	call   8020be <nsipc>
}
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    

00802220 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	56                   	push   %esi
  802224:	53                   	push   %ebx
  802225:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802228:	8b 45 08             	mov    0x8(%ebp),%eax
  80222b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802230:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802236:	8b 45 14             	mov    0x14(%ebp),%eax
  802239:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80223e:	b8 07 00 00 00       	mov    $0x7,%eax
  802243:	e8 76 fe ff ff       	call   8020be <nsipc>
  802248:	89 c3                	mov    %eax,%ebx
  80224a:	85 c0                	test   %eax,%eax
  80224c:	78 35                	js     802283 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80224e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802253:	7f 04                	jg     802259 <nsipc_recv+0x39>
  802255:	39 c6                	cmp    %eax,%esi
  802257:	7d 16                	jge    80226f <nsipc_recv+0x4f>
  802259:	68 d2 2d 80 00       	push   $0x802dd2
  80225e:	68 7b 2d 80 00       	push   $0x802d7b
  802263:	6a 62                	push   $0x62
  802265:	68 e7 2d 80 00       	push   $0x802de7
  80226a:	e8 d5 df ff ff       	call   800244 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80226f:	83 ec 04             	sub    $0x4,%esp
  802272:	50                   	push   %eax
  802273:	68 00 60 80 00       	push   $0x806000
  802278:	ff 75 0c             	pushl  0xc(%ebp)
  80227b:	e8 d4 e7 ff ff       	call   800a54 <memmove>
  802280:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802283:	89 d8                	mov    %ebx,%eax
  802285:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    

0080228c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	53                   	push   %ebx
  802290:	83 ec 04             	sub    $0x4,%esp
  802293:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802296:	8b 45 08             	mov    0x8(%ebp),%eax
  802299:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80229e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022a4:	7e 16                	jle    8022bc <nsipc_send+0x30>
  8022a6:	68 f3 2d 80 00       	push   $0x802df3
  8022ab:	68 7b 2d 80 00       	push   $0x802d7b
  8022b0:	6a 6d                	push   $0x6d
  8022b2:	68 e7 2d 80 00       	push   $0x802de7
  8022b7:	e8 88 df ff ff       	call   800244 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022bc:	83 ec 04             	sub    $0x4,%esp
  8022bf:	53                   	push   %ebx
  8022c0:	ff 75 0c             	pushl  0xc(%ebp)
  8022c3:	68 0c 60 80 00       	push   $0x80600c
  8022c8:	e8 87 e7 ff ff       	call   800a54 <memmove>
	nsipcbuf.send.req_size = size;
  8022cd:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8022d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8022d6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8022db:	b8 08 00 00 00       	mov    $0x8,%eax
  8022e0:	e8 d9 fd ff ff       	call   8020be <nsipc>
}
  8022e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022e8:	c9                   	leave  
  8022e9:	c3                   	ret    

008022ea <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8022f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fb:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802300:	8b 45 10             	mov    0x10(%ebp),%eax
  802303:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802308:	b8 09 00 00 00       	mov    $0x9,%eax
  80230d:	e8 ac fd ff ff       	call   8020be <nsipc>
}
  802312:	c9                   	leave  
  802313:	c3                   	ret    

00802314 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802317:	b8 00 00 00 00       	mov    $0x0,%eax
  80231c:	5d                   	pop    %ebp
  80231d:	c3                   	ret    

0080231e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802324:	68 ff 2d 80 00       	push   $0x802dff
  802329:	ff 75 0c             	pushl  0xc(%ebp)
  80232c:	e8 91 e5 ff ff       	call   8008c2 <strcpy>
	return 0;
}
  802331:	b8 00 00 00 00       	mov    $0x0,%eax
  802336:	c9                   	leave  
  802337:	c3                   	ret    

00802338 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	57                   	push   %edi
  80233c:	56                   	push   %esi
  80233d:	53                   	push   %ebx
  80233e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802344:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802349:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80234f:	eb 2d                	jmp    80237e <devcons_write+0x46>
		m = n - tot;
  802351:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802354:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802356:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802359:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80235e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802361:	83 ec 04             	sub    $0x4,%esp
  802364:	53                   	push   %ebx
  802365:	03 45 0c             	add    0xc(%ebp),%eax
  802368:	50                   	push   %eax
  802369:	57                   	push   %edi
  80236a:	e8 e5 e6 ff ff       	call   800a54 <memmove>
		sys_cputs(buf, m);
  80236f:	83 c4 08             	add    $0x8,%esp
  802372:	53                   	push   %ebx
  802373:	57                   	push   %edi
  802374:	e8 90 e8 ff ff       	call   800c09 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802379:	01 de                	add    %ebx,%esi
  80237b:	83 c4 10             	add    $0x10,%esp
  80237e:	89 f0                	mov    %esi,%eax
  802380:	3b 75 10             	cmp    0x10(%ebp),%esi
  802383:	72 cc                	jb     802351 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802385:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    

0080238d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	83 ec 08             	sub    $0x8,%esp
  802393:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802398:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80239c:	74 2a                	je     8023c8 <devcons_read+0x3b>
  80239e:	eb 05                	jmp    8023a5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023a0:	e8 01 e9 ff ff       	call   800ca6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023a5:	e8 7d e8 ff ff       	call   800c27 <sys_cgetc>
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	74 f2                	je     8023a0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	78 16                	js     8023c8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023b2:	83 f8 04             	cmp    $0x4,%eax
  8023b5:	74 0c                	je     8023c3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ba:	88 02                	mov    %al,(%edx)
	return 1;
  8023bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c1:	eb 05                	jmp    8023c8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023c3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023c8:	c9                   	leave  
  8023c9:	c3                   	ret    

008023ca <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023d3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023d6:	6a 01                	push   $0x1
  8023d8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023db:	50                   	push   %eax
  8023dc:	e8 28 e8 ff ff       	call   800c09 <sys_cputs>
}
  8023e1:	83 c4 10             	add    $0x10,%esp
  8023e4:	c9                   	leave  
  8023e5:	c3                   	ret    

008023e6 <getchar>:

int
getchar(void)
{
  8023e6:	55                   	push   %ebp
  8023e7:	89 e5                	mov    %esp,%ebp
  8023e9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023ec:	6a 01                	push   $0x1
  8023ee:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023f1:	50                   	push   %eax
  8023f2:	6a 00                	push   $0x0
  8023f4:	e8 e2 f1 ff ff       	call   8015db <read>
	if (r < 0)
  8023f9:	83 c4 10             	add    $0x10,%esp
  8023fc:	85 c0                	test   %eax,%eax
  8023fe:	78 0f                	js     80240f <getchar+0x29>
		return r;
	if (r < 1)
  802400:	85 c0                	test   %eax,%eax
  802402:	7e 06                	jle    80240a <getchar+0x24>
		return -E_EOF;
	return c;
  802404:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802408:	eb 05                	jmp    80240f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80240a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80240f:	c9                   	leave  
  802410:	c3                   	ret    

00802411 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802411:	55                   	push   %ebp
  802412:	89 e5                	mov    %esp,%ebp
  802414:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80241a:	50                   	push   %eax
  80241b:	ff 75 08             	pushl  0x8(%ebp)
  80241e:	e8 52 ef ff ff       	call   801375 <fd_lookup>
  802423:	83 c4 10             	add    $0x10,%esp
  802426:	85 c0                	test   %eax,%eax
  802428:	78 11                	js     80243b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802433:	39 10                	cmp    %edx,(%eax)
  802435:	0f 94 c0             	sete   %al
  802438:	0f b6 c0             	movzbl %al,%eax
}
  80243b:	c9                   	leave  
  80243c:	c3                   	ret    

0080243d <opencons>:

int
opencons(void)
{
  80243d:	55                   	push   %ebp
  80243e:	89 e5                	mov    %esp,%ebp
  802440:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802443:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802446:	50                   	push   %eax
  802447:	e8 da ee ff ff       	call   801326 <fd_alloc>
  80244c:	83 c4 10             	add    $0x10,%esp
		return r;
  80244f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802451:	85 c0                	test   %eax,%eax
  802453:	78 3e                	js     802493 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802455:	83 ec 04             	sub    $0x4,%esp
  802458:	68 07 04 00 00       	push   $0x407
  80245d:	ff 75 f4             	pushl  -0xc(%ebp)
  802460:	6a 00                	push   $0x0
  802462:	e8 5e e8 ff ff       	call   800cc5 <sys_page_alloc>
  802467:	83 c4 10             	add    $0x10,%esp
		return r;
  80246a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80246c:	85 c0                	test   %eax,%eax
  80246e:	78 23                	js     802493 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802470:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802476:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802479:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80247b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802485:	83 ec 0c             	sub    $0xc,%esp
  802488:	50                   	push   %eax
  802489:	e8 71 ee ff ff       	call   8012ff <fd2num>
  80248e:	89 c2                	mov    %eax,%edx
  802490:	83 c4 10             	add    $0x10,%esp
}
  802493:	89 d0                	mov    %edx,%eax
  802495:	c9                   	leave  
  802496:	c3                   	ret    

00802497 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802497:	55                   	push   %ebp
  802498:	89 e5                	mov    %esp,%ebp
  80249a:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  80249d:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024a4:	75 56                	jne    8024fc <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  8024a6:	83 ec 04             	sub    $0x4,%esp
  8024a9:	6a 07                	push   $0x7
  8024ab:	68 00 f0 bf ee       	push   $0xeebff000
  8024b0:	6a 00                	push   $0x0
  8024b2:	e8 0e e8 ff ff       	call   800cc5 <sys_page_alloc>
  8024b7:	83 c4 10             	add    $0x10,%esp
  8024ba:	85 c0                	test   %eax,%eax
  8024bc:	74 14                	je     8024d2 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  8024be:	83 ec 04             	sub    $0x4,%esp
  8024c1:	68 89 2c 80 00       	push   $0x802c89
  8024c6:	6a 21                	push   $0x21
  8024c8:	68 0b 2e 80 00       	push   $0x802e0b
  8024cd:	e8 72 dd ff ff       	call   800244 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8024d2:	83 ec 08             	sub    $0x8,%esp
  8024d5:	68 06 25 80 00       	push   $0x802506
  8024da:	6a 00                	push   $0x0
  8024dc:	e8 2f e9 ff ff       	call   800e10 <sys_env_set_pgfault_upcall>
  8024e1:	83 c4 10             	add    $0x10,%esp
  8024e4:	85 c0                	test   %eax,%eax
  8024e6:	74 14                	je     8024fc <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8024e8:	83 ec 04             	sub    $0x4,%esp
  8024eb:	68 19 2e 80 00       	push   $0x802e19
  8024f0:	6a 23                	push   $0x23
  8024f2:	68 0b 2e 80 00       	push   $0x802e0b
  8024f7:	e8 48 dd ff ff       	call   800244 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ff:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802504:	c9                   	leave  
  802505:	c3                   	ret    

00802506 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802506:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802507:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80250c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80250e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  802511:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  802513:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  802517:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  80251b:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  80251c:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  80251e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  802523:	83 c4 08             	add    $0x8,%esp
	popal
  802526:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802527:	83 c4 04             	add    $0x4,%esp
	popfl
  80252a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80252b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80252c:	c3                   	ret    
  80252d:	66 90                	xchg   %ax,%ax
  80252f:	90                   	nop

00802530 <__udivdi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 1c             	sub    $0x1c,%esp
  802537:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80253b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80253f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802547:	85 f6                	test   %esi,%esi
  802549:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80254d:	89 ca                	mov    %ecx,%edx
  80254f:	89 f8                	mov    %edi,%eax
  802551:	75 3d                	jne    802590 <__udivdi3+0x60>
  802553:	39 cf                	cmp    %ecx,%edi
  802555:	0f 87 c5 00 00 00    	ja     802620 <__udivdi3+0xf0>
  80255b:	85 ff                	test   %edi,%edi
  80255d:	89 fd                	mov    %edi,%ebp
  80255f:	75 0b                	jne    80256c <__udivdi3+0x3c>
  802561:	b8 01 00 00 00       	mov    $0x1,%eax
  802566:	31 d2                	xor    %edx,%edx
  802568:	f7 f7                	div    %edi
  80256a:	89 c5                	mov    %eax,%ebp
  80256c:	89 c8                	mov    %ecx,%eax
  80256e:	31 d2                	xor    %edx,%edx
  802570:	f7 f5                	div    %ebp
  802572:	89 c1                	mov    %eax,%ecx
  802574:	89 d8                	mov    %ebx,%eax
  802576:	89 cf                	mov    %ecx,%edi
  802578:	f7 f5                	div    %ebp
  80257a:	89 c3                	mov    %eax,%ebx
  80257c:	89 d8                	mov    %ebx,%eax
  80257e:	89 fa                	mov    %edi,%edx
  802580:	83 c4 1c             	add    $0x1c,%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	90                   	nop
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	39 ce                	cmp    %ecx,%esi
  802592:	77 74                	ja     802608 <__udivdi3+0xd8>
  802594:	0f bd fe             	bsr    %esi,%edi
  802597:	83 f7 1f             	xor    $0x1f,%edi
  80259a:	0f 84 98 00 00 00    	je     802638 <__udivdi3+0x108>
  8025a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	89 c5                	mov    %eax,%ebp
  8025a9:	29 fb                	sub    %edi,%ebx
  8025ab:	d3 e6                	shl    %cl,%esi
  8025ad:	89 d9                	mov    %ebx,%ecx
  8025af:	d3 ed                	shr    %cl,%ebp
  8025b1:	89 f9                	mov    %edi,%ecx
  8025b3:	d3 e0                	shl    %cl,%eax
  8025b5:	09 ee                	or     %ebp,%esi
  8025b7:	89 d9                	mov    %ebx,%ecx
  8025b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8025bd:	89 d5                	mov    %edx,%ebp
  8025bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025c3:	d3 ed                	shr    %cl,%ebp
  8025c5:	89 f9                	mov    %edi,%ecx
  8025c7:	d3 e2                	shl    %cl,%edx
  8025c9:	89 d9                	mov    %ebx,%ecx
  8025cb:	d3 e8                	shr    %cl,%eax
  8025cd:	09 c2                	or     %eax,%edx
  8025cf:	89 d0                	mov    %edx,%eax
  8025d1:	89 ea                	mov    %ebp,%edx
  8025d3:	f7 f6                	div    %esi
  8025d5:	89 d5                	mov    %edx,%ebp
  8025d7:	89 c3                	mov    %eax,%ebx
  8025d9:	f7 64 24 0c          	mull   0xc(%esp)
  8025dd:	39 d5                	cmp    %edx,%ebp
  8025df:	72 10                	jb     8025f1 <__udivdi3+0xc1>
  8025e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025e5:	89 f9                	mov    %edi,%ecx
  8025e7:	d3 e6                	shl    %cl,%esi
  8025e9:	39 c6                	cmp    %eax,%esi
  8025eb:	73 07                	jae    8025f4 <__udivdi3+0xc4>
  8025ed:	39 d5                	cmp    %edx,%ebp
  8025ef:	75 03                	jne    8025f4 <__udivdi3+0xc4>
  8025f1:	83 eb 01             	sub    $0x1,%ebx
  8025f4:	31 ff                	xor    %edi,%edi
  8025f6:	89 d8                	mov    %ebx,%eax
  8025f8:	89 fa                	mov    %edi,%edx
  8025fa:	83 c4 1c             	add    $0x1c,%esp
  8025fd:	5b                   	pop    %ebx
  8025fe:	5e                   	pop    %esi
  8025ff:	5f                   	pop    %edi
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
  802602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802608:	31 ff                	xor    %edi,%edi
  80260a:	31 db                	xor    %ebx,%ebx
  80260c:	89 d8                	mov    %ebx,%eax
  80260e:	89 fa                	mov    %edi,%edx
  802610:	83 c4 1c             	add    $0x1c,%esp
  802613:	5b                   	pop    %ebx
  802614:	5e                   	pop    %esi
  802615:	5f                   	pop    %edi
  802616:	5d                   	pop    %ebp
  802617:	c3                   	ret    
  802618:	90                   	nop
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	89 d8                	mov    %ebx,%eax
  802622:	f7 f7                	div    %edi
  802624:	31 ff                	xor    %edi,%edi
  802626:	89 c3                	mov    %eax,%ebx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 fa                	mov    %edi,%edx
  80262c:	83 c4 1c             	add    $0x1c,%esp
  80262f:	5b                   	pop    %ebx
  802630:	5e                   	pop    %esi
  802631:	5f                   	pop    %edi
  802632:	5d                   	pop    %ebp
  802633:	c3                   	ret    
  802634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802638:	39 ce                	cmp    %ecx,%esi
  80263a:	72 0c                	jb     802648 <__udivdi3+0x118>
  80263c:	31 db                	xor    %ebx,%ebx
  80263e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802642:	0f 87 34 ff ff ff    	ja     80257c <__udivdi3+0x4c>
  802648:	bb 01 00 00 00       	mov    $0x1,%ebx
  80264d:	e9 2a ff ff ff       	jmp    80257c <__udivdi3+0x4c>
  802652:	66 90                	xchg   %ax,%ax
  802654:	66 90                	xchg   %ax,%ax
  802656:	66 90                	xchg   %ax,%ax
  802658:	66 90                	xchg   %ax,%ax
  80265a:	66 90                	xchg   %ax,%ax
  80265c:	66 90                	xchg   %ax,%ax
  80265e:	66 90                	xchg   %ax,%ax

00802660 <__umoddi3>:
  802660:	55                   	push   %ebp
  802661:	57                   	push   %edi
  802662:	56                   	push   %esi
  802663:	53                   	push   %ebx
  802664:	83 ec 1c             	sub    $0x1c,%esp
  802667:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80266b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80266f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802673:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802677:	85 d2                	test   %edx,%edx
  802679:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80267d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802681:	89 f3                	mov    %esi,%ebx
  802683:	89 3c 24             	mov    %edi,(%esp)
  802686:	89 74 24 04          	mov    %esi,0x4(%esp)
  80268a:	75 1c                	jne    8026a8 <__umoddi3+0x48>
  80268c:	39 f7                	cmp    %esi,%edi
  80268e:	76 50                	jbe    8026e0 <__umoddi3+0x80>
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	f7 f7                	div    %edi
  802696:	89 d0                	mov    %edx,%eax
  802698:	31 d2                	xor    %edx,%edx
  80269a:	83 c4 1c             	add    $0x1c,%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5f                   	pop    %edi
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    
  8026a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026a8:	39 f2                	cmp    %esi,%edx
  8026aa:	89 d0                	mov    %edx,%eax
  8026ac:	77 52                	ja     802700 <__umoddi3+0xa0>
  8026ae:	0f bd ea             	bsr    %edx,%ebp
  8026b1:	83 f5 1f             	xor    $0x1f,%ebp
  8026b4:	75 5a                	jne    802710 <__umoddi3+0xb0>
  8026b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8026ba:	0f 82 e0 00 00 00    	jb     8027a0 <__umoddi3+0x140>
  8026c0:	39 0c 24             	cmp    %ecx,(%esp)
  8026c3:	0f 86 d7 00 00 00    	jbe    8027a0 <__umoddi3+0x140>
  8026c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8026d1:	83 c4 1c             	add    $0x1c,%esp
  8026d4:	5b                   	pop    %ebx
  8026d5:	5e                   	pop    %esi
  8026d6:	5f                   	pop    %edi
  8026d7:	5d                   	pop    %ebp
  8026d8:	c3                   	ret    
  8026d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026e0:	85 ff                	test   %edi,%edi
  8026e2:	89 fd                	mov    %edi,%ebp
  8026e4:	75 0b                	jne    8026f1 <__umoddi3+0x91>
  8026e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	f7 f7                	div    %edi
  8026ef:	89 c5                	mov    %eax,%ebp
  8026f1:	89 f0                	mov    %esi,%eax
  8026f3:	31 d2                	xor    %edx,%edx
  8026f5:	f7 f5                	div    %ebp
  8026f7:	89 c8                	mov    %ecx,%eax
  8026f9:	f7 f5                	div    %ebp
  8026fb:	89 d0                	mov    %edx,%eax
  8026fd:	eb 99                	jmp    802698 <__umoddi3+0x38>
  8026ff:	90                   	nop
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 f2                	mov    %esi,%edx
  802704:	83 c4 1c             	add    $0x1c,%esp
  802707:	5b                   	pop    %ebx
  802708:	5e                   	pop    %esi
  802709:	5f                   	pop    %edi
  80270a:	5d                   	pop    %ebp
  80270b:	c3                   	ret    
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	8b 34 24             	mov    (%esp),%esi
  802713:	bf 20 00 00 00       	mov    $0x20,%edi
  802718:	89 e9                	mov    %ebp,%ecx
  80271a:	29 ef                	sub    %ebp,%edi
  80271c:	d3 e0                	shl    %cl,%eax
  80271e:	89 f9                	mov    %edi,%ecx
  802720:	89 f2                	mov    %esi,%edx
  802722:	d3 ea                	shr    %cl,%edx
  802724:	89 e9                	mov    %ebp,%ecx
  802726:	09 c2                	or     %eax,%edx
  802728:	89 d8                	mov    %ebx,%eax
  80272a:	89 14 24             	mov    %edx,(%esp)
  80272d:	89 f2                	mov    %esi,%edx
  80272f:	d3 e2                	shl    %cl,%edx
  802731:	89 f9                	mov    %edi,%ecx
  802733:	89 54 24 04          	mov    %edx,0x4(%esp)
  802737:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80273b:	d3 e8                	shr    %cl,%eax
  80273d:	89 e9                	mov    %ebp,%ecx
  80273f:	89 c6                	mov    %eax,%esi
  802741:	d3 e3                	shl    %cl,%ebx
  802743:	89 f9                	mov    %edi,%ecx
  802745:	89 d0                	mov    %edx,%eax
  802747:	d3 e8                	shr    %cl,%eax
  802749:	89 e9                	mov    %ebp,%ecx
  80274b:	09 d8                	or     %ebx,%eax
  80274d:	89 d3                	mov    %edx,%ebx
  80274f:	89 f2                	mov    %esi,%edx
  802751:	f7 34 24             	divl   (%esp)
  802754:	89 d6                	mov    %edx,%esi
  802756:	d3 e3                	shl    %cl,%ebx
  802758:	f7 64 24 04          	mull   0x4(%esp)
  80275c:	39 d6                	cmp    %edx,%esi
  80275e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802762:	89 d1                	mov    %edx,%ecx
  802764:	89 c3                	mov    %eax,%ebx
  802766:	72 08                	jb     802770 <__umoddi3+0x110>
  802768:	75 11                	jne    80277b <__umoddi3+0x11b>
  80276a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80276e:	73 0b                	jae    80277b <__umoddi3+0x11b>
  802770:	2b 44 24 04          	sub    0x4(%esp),%eax
  802774:	1b 14 24             	sbb    (%esp),%edx
  802777:	89 d1                	mov    %edx,%ecx
  802779:	89 c3                	mov    %eax,%ebx
  80277b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80277f:	29 da                	sub    %ebx,%edx
  802781:	19 ce                	sbb    %ecx,%esi
  802783:	89 f9                	mov    %edi,%ecx
  802785:	89 f0                	mov    %esi,%eax
  802787:	d3 e0                	shl    %cl,%eax
  802789:	89 e9                	mov    %ebp,%ecx
  80278b:	d3 ea                	shr    %cl,%edx
  80278d:	89 e9                	mov    %ebp,%ecx
  80278f:	d3 ee                	shr    %cl,%esi
  802791:	09 d0                	or     %edx,%eax
  802793:	89 f2                	mov    %esi,%edx
  802795:	83 c4 1c             	add    $0x1c,%esp
  802798:	5b                   	pop    %ebx
  802799:	5e                   	pop    %esi
  80279a:	5f                   	pop    %edi
  80279b:	5d                   	pop    %ebp
  80279c:	c3                   	ret    
  80279d:	8d 76 00             	lea    0x0(%esi),%esi
  8027a0:	29 f9                	sub    %edi,%ecx
  8027a2:	19 d6                	sbb    %edx,%esi
  8027a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ac:	e9 18 ff ff ff       	jmp    8026c9 <__umoddi3+0x69>
