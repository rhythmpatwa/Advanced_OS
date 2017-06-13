
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 0d 08 00 00       	call   800856 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 e0 0b 00 00       	call   800c59 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 96 31 80 00       	push   $0x803196
  800086:	6a 13                	push   $0x13
  800088:	68 8c 2d 80 00       	push   $0x802d8c
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 c6 0e 00 00       	call   800f5d <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 a0 2d 80 00       	push   $0x802da0
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 8c 2d 80 00       	push   $0x802d8c
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 90 07 00 00       	call   800856 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 fb 21 00 00       	call   8022d2 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 16 08 00 00       	call   800900 <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 86 2d 80 00       	mov    $0x802d86,%edx
  8000f4:	b8 80 2d 80 00       	mov    $0x802d80,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 a9 2d 80 00       	push   $0x802da9
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 c4 2d 80 00       	push   $0x802dc4
  80010e:	68 c9 2d 80 00       	push   $0x802dc9
  800113:	68 c8 2d 80 00       	push   $0x802dc8
  800118:	e8 e6 1d 00 00       	call   801f03 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 d6 2d 80 00       	push   $0x802dd6
  80012a:	6a 21                	push   $0x21
  80012c:	68 8c 2d 80 00       	push   $0x802d8c
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 93 21 00 00       	call   8022d2 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 ae 07 00 00       	call   800900 <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 86 2d 80 00       	mov    $0x802d86,%edx
  80015c:	b8 80 2d 80 00       	mov    $0x802d80,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 e0 2d 80 00       	push   $0x802de0
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800183:	e8 93 0a 00 00       	call   800c1b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 08 50 80 00       	mov    %eax,0x805008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 97 11 00 00       	call   801360 <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 07 0a 00 00       	call   800bda <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001e6:	e8 30 0a 00 00       	call   800c1b <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 24 2e 80 00       	push   $0x802e24
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 d0 33 80 00 	movl   $0x8033d0,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 4f 09 00 00       	call   800b9d <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 54 01 00 00       	call   8003e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 f4 08 00 00       	call   800b9d <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 c7 27 00 00       	call   802ae0 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 b4 28 00 00       	call   802c10 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 47 2e 80 00 	movsbl 0x802e47(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800377:	83 fa 01             	cmp    $0x1,%edx
  80037a:	7e 0e                	jle    80038a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037c:	8b 10                	mov    (%eax),%edx
  80037e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 02                	mov    (%edx),%eax
  800385:	8b 52 04             	mov    0x4(%edx),%edx
  800388:	eb 22                	jmp    8003ac <getuint+0x38>
	else if (lflag)
  80038a:	85 d2                	test   %edx,%edx
  80038c:	74 10                	je     80039e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80038e:	8b 10                	mov    (%eax),%edx
  800390:	8d 4a 04             	lea    0x4(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 02                	mov    (%edx),%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 0e                	jmp    8003ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b8:	8b 10                	mov    (%eax),%edx
  8003ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bd:	73 0a                	jae    8003c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c2:	89 08                	mov    %ecx,(%eax)
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	88 02                	mov    %al,(%edx)
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d4:	50                   	push   %eax
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
  8003db:	ff 75 08             	pushl  0x8(%ebp)
  8003de:	e8 05 00 00 00       	call   8003e8 <vprintfmt>
	va_end(ap);
}
  8003e3:	83 c4 10             	add    $0x10,%esp
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	57                   	push   %edi
  8003ec:	56                   	push   %esi
  8003ed:	53                   	push   %ebx
  8003ee:	83 ec 2c             	sub    $0x2c,%esp
  8003f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8003f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003fa:	eb 12                	jmp    80040e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	0f 84 a9 03 00 00    	je     8007ad <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	50                   	push   %eax
  800409:	ff d6                	call   *%esi
  80040b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040e:	83 c7 01             	add    $0x1,%edi
  800411:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800415:	83 f8 25             	cmp    $0x25,%eax
  800418:	75 e2                	jne    8003fc <vprintfmt+0x14>
  80041a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80041e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800425:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800433:	ba 00 00 00 00       	mov    $0x0,%edx
  800438:	eb 07                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80043d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8d 47 01             	lea    0x1(%edi),%eax
  800444:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800447:	0f b6 07             	movzbl (%edi),%eax
  80044a:	0f b6 c8             	movzbl %al,%ecx
  80044d:	83 e8 23             	sub    $0x23,%eax
  800450:	3c 55                	cmp    $0x55,%al
  800452:	0f 87 3a 03 00 00    	ja     800792 <vprintfmt+0x3aa>
  800458:	0f b6 c0             	movzbl %al,%eax
  80045b:	ff 24 85 80 2f 80 00 	jmp    *0x802f80(,%eax,4)
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800465:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800469:	eb d6                	jmp    800441 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800476:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800479:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80047d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800480:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800483:	83 fa 09             	cmp    $0x9,%edx
  800486:	77 39                	ja     8004c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800488:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80048b:	eb e9                	jmp    800476 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 48 04             	lea    0x4(%eax),%ecx
  800493:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80049e:	eb 27                	jmp    8004c7 <vprintfmt+0xdf>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004aa:	0f 49 c8             	cmovns %eax,%ecx
  8004ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b3:	eb 8c                	jmp    800441 <vprintfmt+0x59>
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bf:	eb 80                	jmp    800441 <vprintfmt+0x59>
  8004c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004cb:	0f 89 70 ff ff ff    	jns    800441 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004de:	e9 5e ff ff ff       	jmp    800441 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004e9:	e9 53 ff ff ff       	jmp    800441 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8d 50 04             	lea    0x4(%eax),%edx
  8004f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 30                	pushl  (%eax)
  8004fd:	ff d6                	call   *%esi
			break;
  8004ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800505:	e9 04 ff ff ff       	jmp    80040e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 50 04             	lea    0x4(%eax),%edx
  800510:	89 55 14             	mov    %edx,0x14(%ebp)
  800513:	8b 00                	mov    (%eax),%eax
  800515:	99                   	cltd   
  800516:	31 d0                	xor    %edx,%eax
  800518:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051a:	83 f8 0f             	cmp    $0xf,%eax
  80051d:	7f 0b                	jg     80052a <vprintfmt+0x142>
  80051f:	8b 14 85 e0 30 80 00 	mov    0x8030e0(,%eax,4),%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	75 18                	jne    800542 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80052a:	50                   	push   %eax
  80052b:	68 5f 2e 80 00       	push   $0x802e5f
  800530:	53                   	push   %ebx
  800531:	56                   	push   %esi
  800532:	e8 94 fe ff ff       	call   8003cb <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80053d:	e9 cc fe ff ff       	jmp    80040e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800542:	52                   	push   %edx
  800543:	68 e9 32 80 00       	push   $0x8032e9
  800548:	53                   	push   %ebx
  800549:	56                   	push   %esi
  80054a:	e8 7c fe ff ff       	call   8003cb <printfmt>
  80054f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800555:	e9 b4 fe ff ff       	jmp    80040e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800565:	85 ff                	test   %edi,%edi
  800567:	b8 58 2e 80 00       	mov    $0x802e58,%eax
  80056c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80056f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800573:	0f 8e 94 00 00 00    	jle    80060d <vprintfmt+0x225>
  800579:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80057d:	0f 84 98 00 00 00    	je     80061b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 d0             	pushl  -0x30(%ebp)
  800589:	57                   	push   %edi
  80058a:	e8 a6 02 00 00       	call   800835 <strnlen>
  80058f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800592:	29 c1                	sub    %eax,%ecx
  800594:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a6:	eb 0f                	jmp    8005b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f ed                	jg     8005a8 <vprintfmt+0x1c0>
  8005bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005c1:	85 c9                	test   %ecx,%ecx
  8005c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c8:	0f 49 c1             	cmovns %ecx,%eax
  8005cb:	29 c1                	sub    %eax,%ecx
  8005cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d6:	89 cb                	mov    %ecx,%ebx
  8005d8:	eb 4d                	jmp    800627 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005de:	74 1b                	je     8005fb <vprintfmt+0x213>
  8005e0:	0f be c0             	movsbl %al,%eax
  8005e3:	83 e8 20             	sub    $0x20,%eax
  8005e6:	83 f8 5e             	cmp    $0x5e,%eax
  8005e9:	76 10                	jbe    8005fb <vprintfmt+0x213>
					putch('?', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	ff 75 0c             	pushl  0xc(%ebp)
  8005f1:	6a 3f                	push   $0x3f
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	eb 0d                	jmp    800608 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	52                   	push   %edx
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 eb 01             	sub    $0x1,%ebx
  80060b:	eb 1a                	jmp    800627 <vprintfmt+0x23f>
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800619:	eb 0c                	jmp    800627 <vprintfmt+0x23f>
  80061b:	89 75 08             	mov    %esi,0x8(%ebp)
  80061e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800621:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800624:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800627:	83 c7 01             	add    $0x1,%edi
  80062a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80062e:	0f be d0             	movsbl %al,%edx
  800631:	85 d2                	test   %edx,%edx
  800633:	74 23                	je     800658 <vprintfmt+0x270>
  800635:	85 f6                	test   %esi,%esi
  800637:	78 a1                	js     8005da <vprintfmt+0x1f2>
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	79 9c                	jns    8005da <vprintfmt+0x1f2>
  80063e:	89 df                	mov    %ebx,%edi
  800640:	8b 75 08             	mov    0x8(%ebp),%esi
  800643:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800646:	eb 18                	jmp    800660 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 20                	push   $0x20
  80064e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb 08                	jmp    800660 <vprintfmt+0x278>
  800658:	89 df                	mov    %ebx,%edi
  80065a:	8b 75 08             	mov    0x8(%ebp),%esi
  80065d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800660:	85 ff                	test   %edi,%edi
  800662:	7f e4                	jg     800648 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800667:	e9 a2 fd ff ff       	jmp    80040e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 fa 01             	cmp    $0x1,%edx
  80066f:	7e 16                	jle    800687 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 50 04             	mov    0x4(%eax),%edx
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800685:	eb 32                	jmp    8006b9 <vprintfmt+0x2d1>
	else if (lflag)
  800687:	85 d2                	test   %edx,%edx
  800689:	74 18                	je     8006a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 c1                	mov    %eax,%ecx
  80069b:	c1 f9 1f             	sar    $0x1f,%ecx
  80069e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a1:	eb 16                	jmp    8006b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b1:	89 c1                	mov    %eax,%ecx
  8006b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c8:	0f 89 90 00 00 00    	jns    80075e <vprintfmt+0x376>
				putch('-', putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 2d                	push   $0x2d
  8006d4:	ff d6                	call   *%esi
				num = -(long long) num;
  8006d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006dc:	f7 d8                	neg    %eax
  8006de:	83 d2 00             	adc    $0x0,%edx
  8006e1:	f7 da                	neg    %edx
  8006e3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006eb:	eb 71                	jmp    80075e <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f0:	e8 7f fc ff ff       	call   800374 <getuint>
			base = 10;
  8006f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006fa:	eb 62                	jmp    80075e <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ff:	e8 70 fc ff ff       	call   800374 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800704:	83 ec 0c             	sub    $0xc,%esp
  800707:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80070b:	51                   	push   %ecx
  80070c:	ff 75 e0             	pushl  -0x20(%ebp)
  80070f:	6a 08                	push   $0x8
  800711:	52                   	push   %edx
  800712:	50                   	push   %eax
  800713:	89 da                	mov    %ebx,%edx
  800715:	89 f0                	mov    %esi,%eax
  800717:	e8 a9 fb ff ff       	call   8002c5 <printnum>
			break;
  80071c:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800722:	e9 e7 fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 30                	push   $0x30
  80072d:	ff d6                	call   *%esi
			putch('x', putdat);
  80072f:	83 c4 08             	add    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 78                	push   $0x78
  800735:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8d 50 04             	lea    0x4(%eax),%edx
  80073d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800740:	8b 00                	mov    (%eax),%eax
  800742:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800747:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80074a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80074f:	eb 0d                	jmp    80075e <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 1b fc ff ff       	call   800374 <getuint>
			base = 16;
  800759:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80075e:	83 ec 0c             	sub    $0xc,%esp
  800761:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800765:	57                   	push   %edi
  800766:	ff 75 e0             	pushl  -0x20(%ebp)
  800769:	51                   	push   %ecx
  80076a:	52                   	push   %edx
  80076b:	50                   	push   %eax
  80076c:	89 da                	mov    %ebx,%edx
  80076e:	89 f0                	mov    %esi,%eax
  800770:	e8 50 fb ff ff       	call   8002c5 <printnum>
			break;
  800775:	83 c4 20             	add    $0x20,%esp
  800778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077b:	e9 8e fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	53                   	push   %ebx
  800784:	51                   	push   %ecx
  800785:	ff d6                	call   *%esi
			break;
  800787:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078d:	e9 7c fc ff ff       	jmp    80040e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 25                	push   $0x25
  800798:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	eb 03                	jmp    8007a2 <vprintfmt+0x3ba>
  80079f:	83 ef 01             	sub    $0x1,%edi
  8007a2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a6:	75 f7                	jne    80079f <vprintfmt+0x3b7>
  8007a8:	e9 61 fc ff ff       	jmp    80040e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5f                   	pop    %edi
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 18             	sub    $0x18,%esp
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	74 26                	je     8007fc <vsnprintf+0x47>
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	7e 22                	jle    8007fc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007da:	ff 75 14             	pushl  0x14(%ebp)
  8007dd:	ff 75 10             	pushl  0x10(%ebp)
  8007e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e3:	50                   	push   %eax
  8007e4:	68 ae 03 80 00       	push   $0x8003ae
  8007e9:	e8 fa fb ff ff       	call   8003e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f7:	83 c4 10             	add    $0x10,%esp
  8007fa:	eb 05                	jmp    800801 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800809:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080c:	50                   	push   %eax
  80080d:	ff 75 10             	pushl  0x10(%ebp)
  800810:	ff 75 0c             	pushl  0xc(%ebp)
  800813:	ff 75 08             	pushl  0x8(%ebp)
  800816:	e8 9a ff ff ff       	call   8007b5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800823:	b8 00 00 00 00       	mov    $0x0,%eax
  800828:	eb 03                	jmp    80082d <strlen+0x10>
		n++;
  80082a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800831:	75 f7                	jne    80082a <strlen+0xd>
		n++;
	return n;
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083e:	ba 00 00 00 00       	mov    $0x0,%edx
  800843:	eb 03                	jmp    800848 <strnlen+0x13>
		n++;
  800845:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800848:	39 c2                	cmp    %eax,%edx
  80084a:	74 08                	je     800854 <strnlen+0x1f>
  80084c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800850:	75 f3                	jne    800845 <strnlen+0x10>
  800852:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800860:	89 c2                	mov    %eax,%edx
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	83 c1 01             	add    $0x1,%ecx
  800868:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086f:	84 db                	test   %bl,%bl
  800871:	75 ef                	jne    800862 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800873:	5b                   	pop    %ebx
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	53                   	push   %ebx
  80087a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087d:	53                   	push   %ebx
  80087e:	e8 9a ff ff ff       	call   80081d <strlen>
  800883:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800886:	ff 75 0c             	pushl  0xc(%ebp)
  800889:	01 d8                	add    %ebx,%eax
  80088b:	50                   	push   %eax
  80088c:	e8 c5 ff ff ff       	call   800856 <strcpy>
	return dst;
}
  800891:	89 d8                	mov    %ebx,%eax
  800893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	56                   	push   %esi
  80089c:	53                   	push   %ebx
  80089d:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a3:	89 f3                	mov    %esi,%ebx
  8008a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a8:	89 f2                	mov    %esi,%edx
  8008aa:	eb 0f                	jmp    8008bb <strncpy+0x23>
		*dst++ = *src;
  8008ac:	83 c2 01             	add    $0x1,%edx
  8008af:	0f b6 01             	movzbl (%ecx),%eax
  8008b2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b5:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008bb:	39 da                	cmp    %ebx,%edx
  8008bd:	75 ed                	jne    8008ac <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008bf:	89 f0                	mov    %esi,%eax
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d5:	85 d2                	test   %edx,%edx
  8008d7:	74 21                	je     8008fa <strlcpy+0x35>
  8008d9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008dd:	89 f2                	mov    %esi,%edx
  8008df:	eb 09                	jmp    8008ea <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e1:	83 c2 01             	add    $0x1,%edx
  8008e4:	83 c1 01             	add    $0x1,%ecx
  8008e7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ea:	39 c2                	cmp    %eax,%edx
  8008ec:	74 09                	je     8008f7 <strlcpy+0x32>
  8008ee:	0f b6 19             	movzbl (%ecx),%ebx
  8008f1:	84 db                	test   %bl,%bl
  8008f3:	75 ec                	jne    8008e1 <strlcpy+0x1c>
  8008f5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fa:	29 f0                	sub    %esi,%eax
}
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800906:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800909:	eb 06                	jmp    800911 <strcmp+0x11>
		p++, q++;
  80090b:	83 c1 01             	add    $0x1,%ecx
  80090e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800911:	0f b6 01             	movzbl (%ecx),%eax
  800914:	84 c0                	test   %al,%al
  800916:	74 04                	je     80091c <strcmp+0x1c>
  800918:	3a 02                	cmp    (%edx),%al
  80091a:	74 ef                	je     80090b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091c:	0f b6 c0             	movzbl %al,%eax
  80091f:	0f b6 12             	movzbl (%edx),%edx
  800922:	29 d0                	sub    %edx,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 c3                	mov    %eax,%ebx
  800932:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800935:	eb 06                	jmp    80093d <strncmp+0x17>
		n--, p++, q++;
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093d:	39 d8                	cmp    %ebx,%eax
  80093f:	74 15                	je     800956 <strncmp+0x30>
  800941:	0f b6 08             	movzbl (%eax),%ecx
  800944:	84 c9                	test   %cl,%cl
  800946:	74 04                	je     80094c <strncmp+0x26>
  800948:	3a 0a                	cmp    (%edx),%cl
  80094a:	74 eb                	je     800937 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094c:	0f b6 00             	movzbl (%eax),%eax
  80094f:	0f b6 12             	movzbl (%edx),%edx
  800952:	29 d0                	sub    %edx,%eax
  800954:	eb 05                	jmp    80095b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800968:	eb 07                	jmp    800971 <strchr+0x13>
		if (*s == c)
  80096a:	38 ca                	cmp    %cl,%dl
  80096c:	74 0f                	je     80097d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096e:	83 c0 01             	add    $0x1,%eax
  800971:	0f b6 10             	movzbl (%eax),%edx
  800974:	84 d2                	test   %dl,%dl
  800976:	75 f2                	jne    80096a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800989:	eb 03                	jmp    80098e <strfind+0xf>
  80098b:	83 c0 01             	add    $0x1,%eax
  80098e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800991:	38 ca                	cmp    %cl,%dl
  800993:	74 04                	je     800999 <strfind+0x1a>
  800995:	84 d2                	test   %dl,%dl
  800997:	75 f2                	jne    80098b <strfind+0xc>
			break;
	return (char *) s;
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a7:	85 c9                	test   %ecx,%ecx
  8009a9:	74 36                	je     8009e1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b1:	75 28                	jne    8009db <memset+0x40>
  8009b3:	f6 c1 03             	test   $0x3,%cl
  8009b6:	75 23                	jne    8009db <memset+0x40>
		c &= 0xFF;
  8009b8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bc:	89 d3                	mov    %edx,%ebx
  8009be:	c1 e3 08             	shl    $0x8,%ebx
  8009c1:	89 d6                	mov    %edx,%esi
  8009c3:	c1 e6 18             	shl    $0x18,%esi
  8009c6:	89 d0                	mov    %edx,%eax
  8009c8:	c1 e0 10             	shl    $0x10,%eax
  8009cb:	09 f0                	or     %esi,%eax
  8009cd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009cf:	89 d8                	mov    %ebx,%eax
  8009d1:	09 d0                	or     %edx,%eax
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
  8009d6:	fc                   	cld    
  8009d7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d9:	eb 06                	jmp    8009e1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009de:	fc                   	cld    
  8009df:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e1:	89 f8                	mov    %edi,%eax
  8009e3:	5b                   	pop    %ebx
  8009e4:	5e                   	pop    %esi
  8009e5:	5f                   	pop    %edi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	57                   	push   %edi
  8009ec:	56                   	push   %esi
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f6:	39 c6                	cmp    %eax,%esi
  8009f8:	73 35                	jae    800a2f <memmove+0x47>
  8009fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fd:	39 d0                	cmp    %edx,%eax
  8009ff:	73 2e                	jae    800a2f <memmove+0x47>
		s += n;
		d += n;
  800a01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	09 fe                	or     %edi,%esi
  800a08:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0e:	75 13                	jne    800a23 <memmove+0x3b>
  800a10:	f6 c1 03             	test   $0x3,%cl
  800a13:	75 0e                	jne    800a23 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a15:	83 ef 04             	sub    $0x4,%edi
  800a18:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1b:	c1 e9 02             	shr    $0x2,%ecx
  800a1e:	fd                   	std    
  800a1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a21:	eb 09                	jmp    800a2c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a23:	83 ef 01             	sub    $0x1,%edi
  800a26:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a29:	fd                   	std    
  800a2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2c:	fc                   	cld    
  800a2d:	eb 1d                	jmp    800a4c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2f:	89 f2                	mov    %esi,%edx
  800a31:	09 c2                	or     %eax,%edx
  800a33:	f6 c2 03             	test   $0x3,%dl
  800a36:	75 0f                	jne    800a47 <memmove+0x5f>
  800a38:	f6 c1 03             	test   $0x3,%cl
  800a3b:	75 0a                	jne    800a47 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
  800a40:	89 c7                	mov    %eax,%edi
  800a42:	fc                   	cld    
  800a43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a45:	eb 05                	jmp    800a4c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	fc                   	cld    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a53:	ff 75 10             	pushl  0x10(%ebp)
  800a56:	ff 75 0c             	pushl  0xc(%ebp)
  800a59:	ff 75 08             	pushl  0x8(%ebp)
  800a5c:	e8 87 ff ff ff       	call   8009e8 <memmove>
}
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a73:	eb 1a                	jmp    800a8f <memcmp+0x2c>
		if (*s1 != *s2)
  800a75:	0f b6 08             	movzbl (%eax),%ecx
  800a78:	0f b6 1a             	movzbl (%edx),%ebx
  800a7b:	38 d9                	cmp    %bl,%cl
  800a7d:	74 0a                	je     800a89 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a7f:	0f b6 c1             	movzbl %cl,%eax
  800a82:	0f b6 db             	movzbl %bl,%ebx
  800a85:	29 d8                	sub    %ebx,%eax
  800a87:	eb 0f                	jmp    800a98 <memcmp+0x35>
		s1++, s2++;
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8f:	39 f0                	cmp    %esi,%eax
  800a91:	75 e2                	jne    800a75 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa3:	89 c1                	mov    %eax,%ecx
  800aa5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aac:	eb 0a                	jmp    800ab8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aae:	0f b6 10             	movzbl (%eax),%edx
  800ab1:	39 da                	cmp    %ebx,%edx
  800ab3:	74 07                	je     800abc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	39 c8                	cmp    %ecx,%eax
  800aba:	72 f2                	jb     800aae <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abc:	5b                   	pop    %ebx
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acb:	eb 03                	jmp    800ad0 <strtol+0x11>
		s++;
  800acd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad0:	0f b6 01             	movzbl (%ecx),%eax
  800ad3:	3c 20                	cmp    $0x20,%al
  800ad5:	74 f6                	je     800acd <strtol+0xe>
  800ad7:	3c 09                	cmp    $0x9,%al
  800ad9:	74 f2                	je     800acd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800adb:	3c 2b                	cmp    $0x2b,%al
  800add:	75 0a                	jne    800ae9 <strtol+0x2a>
		s++;
  800adf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae7:	eb 11                	jmp    800afa <strtol+0x3b>
  800ae9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aee:	3c 2d                	cmp    $0x2d,%al
  800af0:	75 08                	jne    800afa <strtol+0x3b>
		s++, neg = 1;
  800af2:	83 c1 01             	add    $0x1,%ecx
  800af5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b00:	75 15                	jne    800b17 <strtol+0x58>
  800b02:	80 39 30             	cmpb   $0x30,(%ecx)
  800b05:	75 10                	jne    800b17 <strtol+0x58>
  800b07:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0b:	75 7c                	jne    800b89 <strtol+0xca>
		s += 2, base = 16;
  800b0d:	83 c1 02             	add    $0x2,%ecx
  800b10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b15:	eb 16                	jmp    800b2d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	75 12                	jne    800b2d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b20:	80 39 30             	cmpb   $0x30,(%ecx)
  800b23:	75 08                	jne    800b2d <strtol+0x6e>
		s++, base = 8;
  800b25:	83 c1 01             	add    $0x1,%ecx
  800b28:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b35:	0f b6 11             	movzbl (%ecx),%edx
  800b38:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3b:	89 f3                	mov    %esi,%ebx
  800b3d:	80 fb 09             	cmp    $0x9,%bl
  800b40:	77 08                	ja     800b4a <strtol+0x8b>
			dig = *s - '0';
  800b42:	0f be d2             	movsbl %dl,%edx
  800b45:	83 ea 30             	sub    $0x30,%edx
  800b48:	eb 22                	jmp    800b6c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b4a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	80 fb 19             	cmp    $0x19,%bl
  800b52:	77 08                	ja     800b5c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b54:	0f be d2             	movsbl %dl,%edx
  800b57:	83 ea 57             	sub    $0x57,%edx
  800b5a:	eb 10                	jmp    800b6c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b5c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5f:	89 f3                	mov    %esi,%ebx
  800b61:	80 fb 19             	cmp    $0x19,%bl
  800b64:	77 16                	ja     800b7c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b66:	0f be d2             	movsbl %dl,%edx
  800b69:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b6c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6f:	7d 0b                	jge    800b7c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b78:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b7a:	eb b9                	jmp    800b35 <strtol+0x76>

	if (endptr)
  800b7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b80:	74 0d                	je     800b8f <strtol+0xd0>
		*endptr = (char *) s;
  800b82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b85:	89 0e                	mov    %ecx,(%esi)
  800b87:	eb 06                	jmp    800b8f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b89:	85 db                	test   %ebx,%ebx
  800b8b:	74 98                	je     800b25 <strtol+0x66>
  800b8d:	eb 9e                	jmp    800b2d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b8f:	89 c2                	mov    %eax,%edx
  800b91:	f7 da                	neg    %edx
  800b93:	85 ff                	test   %edi,%edi
  800b95:	0f 45 c2             	cmovne %edx,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	89 c3                	mov    %eax,%ebx
  800bb0:	89 c7                	mov    %eax,%edi
  800bb2:	89 c6                	mov    %eax,%esi
  800bb4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_cgetc>:

int
sys_cgetc(void)
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
  800bc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bcb:	89 d1                	mov    %edx,%ecx
  800bcd:	89 d3                	mov    %edx,%ebx
  800bcf:	89 d7                	mov    %edx,%edi
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800be3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	89 cb                	mov    %ecx,%ebx
  800bf2:	89 cf                	mov    %ecx,%edi
  800bf4:	89 ce                	mov    %ecx,%esi
  800bf6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7e 17                	jle    800c13 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	50                   	push   %eax
  800c00:	6a 03                	push   $0x3
  800c02:	68 3f 31 80 00       	push   $0x80313f
  800c07:	6a 23                	push   $0x23
  800c09:	68 5c 31 80 00       	push   $0x80315c
  800c0e:	e8 c5 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	ba 00 00 00 00       	mov    $0x0,%edx
  800c26:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2b:	89 d1                	mov    %edx,%ecx
  800c2d:	89 d3                	mov    %edx,%ebx
  800c2f:	89 d7                	mov    %edx,%edi
  800c31:	89 d6                	mov    %edx,%esi
  800c33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_yield>:

void
sys_yield(void)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c40:	ba 00 00 00 00       	mov    $0x0,%edx
  800c45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4a:	89 d1                	mov    %edx,%ecx
  800c4c:	89 d3                	mov    %edx,%ebx
  800c4e:	89 d7                	mov    %edx,%edi
  800c50:	89 d6                	mov    %edx,%esi
  800c52:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	be 00 00 00 00       	mov    $0x0,%esi
  800c67:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c75:	89 f7                	mov    %esi,%edi
  800c77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 17                	jle    800c94 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	50                   	push   %eax
  800c81:	6a 04                	push   $0x4
  800c83:	68 3f 31 80 00       	push   $0x80313f
  800c88:	6a 23                	push   $0x23
  800c8a:	68 5c 31 80 00       	push   $0x80315c
  800c8f:	e8 44 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	b8 05 00 00 00       	mov    $0x5,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb6:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 17                	jle    800cd6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 05                	push   $0x5
  800cc5:	68 3f 31 80 00       	push   $0x80313f
  800cca:	6a 23                	push   $0x23
  800ccc:	68 5c 31 80 00       	push   $0x80315c
  800cd1:	e8 02 f5 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cec:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf7:	89 df                	mov    %ebx,%edi
  800cf9:	89 de                	mov    %ebx,%esi
  800cfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	7e 17                	jle    800d18 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 06                	push   $0x6
  800d07:	68 3f 31 80 00       	push   $0x80313f
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 5c 31 80 00       	push   $0x80315c
  800d13:	e8 c0 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1b:	5b                   	pop    %ebx
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7e 17                	jle    800d5a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 08                	push   $0x8
  800d49:	68 3f 31 80 00       	push   $0x80313f
  800d4e:	6a 23                	push   $0x23
  800d50:	68 5c 31 80 00       	push   $0x80315c
  800d55:	e8 7e f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d70:	b8 09 00 00 00       	mov    $0x9,%eax
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 df                	mov    %ebx,%edi
  800d7d:	89 de                	mov    %ebx,%esi
  800d7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d81:	85 c0                	test   %eax,%eax
  800d83:	7e 17                	jle    800d9c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	50                   	push   %eax
  800d89:	6a 09                	push   $0x9
  800d8b:	68 3f 31 80 00       	push   $0x80313f
  800d90:	6a 23                	push   $0x23
  800d92:	68 5c 31 80 00       	push   $0x80315c
  800d97:	e8 3c f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	57                   	push   %edi
  800da8:	56                   	push   %esi
  800da9:	53                   	push   %ebx
  800daa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	89 df                	mov    %ebx,%edi
  800dbf:	89 de                	mov    %ebx,%esi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0a                	push   $0xa
  800dcd:	68 3f 31 80 00       	push   $0x80313f
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 5c 31 80 00       	push   $0x80315c
  800dd9:	e8 fa f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dec:	be 00 00 00 00       	mov    $0x0,%esi
  800df1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e02:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	57                   	push   %edi
  800e0d:	56                   	push   %esi
  800e0e:	53                   	push   %ebx
  800e0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e17:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1f:	89 cb                	mov    %ecx,%ebx
  800e21:	89 cf                	mov    %ecx,%edi
  800e23:	89 ce                	mov    %ecx,%esi
  800e25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7e 17                	jle    800e42 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	50                   	push   %eax
  800e2f:	6a 0d                	push   $0xd
  800e31:	68 3f 31 80 00       	push   $0x80313f
  800e36:	6a 23                	push   $0x23
  800e38:	68 5c 31 80 00       	push   $0x80315c
  800e3d:	e8 96 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	ba 00 00 00 00       	mov    $0x0,%edx
  800e55:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e5a:	89 d1                	mov    %edx,%ecx
  800e5c:	89 d3                	mov    %edx,%ebx
  800e5e:	89 d7                	mov    %edx,%edi
  800e60:	89 d6                	mov    %edx,%esi
  800e62:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 04             	sub    $0x4,%esp
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e73:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800e75:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e78:	f6 c1 02             	test   $0x2,%cl
  800e7b:	74 2e                	je     800eab <pgfault+0x42>
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	c1 ea 16             	shr    $0x16,%edx
  800e82:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e89:	f6 c2 01             	test   $0x1,%dl
  800e8c:	74 1d                	je     800eab <pgfault+0x42>
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	c1 ea 0c             	shr    $0xc,%edx
  800e93:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800e9a:	f6 c3 01             	test   $0x1,%bl
  800e9d:	74 0c                	je     800eab <pgfault+0x42>
  800e9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea6:	f6 c6 08             	test   $0x8,%dh
  800ea9:	75 12                	jne    800ebd <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800eab:	51                   	push   %ecx
  800eac:	68 6a 31 80 00       	push   $0x80316a
  800eb1:	6a 1e                	push   $0x1e
  800eb3:	68 83 31 80 00       	push   $0x803183
  800eb8:	e8 1b f3 ff ff       	call   8001d8 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800ebd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ec2:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800ec4:	83 ec 04             	sub    $0x4,%esp
  800ec7:	6a 07                	push   $0x7
  800ec9:	68 00 f0 7f 00       	push   $0x7ff000
  800ece:	6a 00                	push   $0x0
  800ed0:	e8 84 fd ff ff       	call   800c59 <sys_page_alloc>
  800ed5:	83 c4 10             	add    $0x10,%esp
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	79 12                	jns    800eee <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800edc:	50                   	push   %eax
  800edd:	68 8e 31 80 00       	push   $0x80318e
  800ee2:	6a 29                	push   $0x29
  800ee4:	68 83 31 80 00       	push   $0x803183
  800ee9:	e8 ea f2 ff ff       	call   8001d8 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	68 00 10 00 00       	push   $0x1000
  800ef6:	53                   	push   %ebx
  800ef7:	68 00 f0 7f 00       	push   $0x7ff000
  800efc:	e8 4f fb ff ff       	call   800a50 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800f01:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f08:	53                   	push   %ebx
  800f09:	6a 00                	push   $0x0
  800f0b:	68 00 f0 7f 00       	push   $0x7ff000
  800f10:	6a 00                	push   $0x0
  800f12:	e8 85 fd ff ff       	call   800c9c <sys_page_map>
  800f17:	83 c4 20             	add    $0x20,%esp
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	79 12                	jns    800f30 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800f1e:	50                   	push   %eax
  800f1f:	68 a9 31 80 00       	push   $0x8031a9
  800f24:	6a 2e                	push   $0x2e
  800f26:	68 83 31 80 00       	push   $0x803183
  800f2b:	e8 a8 f2 ff ff       	call   8001d8 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	68 00 f0 7f 00       	push   $0x7ff000
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 9f fd ff ff       	call   800cde <sys_page_unmap>
  800f3f:	83 c4 10             	add    $0x10,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	79 12                	jns    800f58 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800f46:	50                   	push   %eax
  800f47:	68 c2 31 80 00       	push   $0x8031c2
  800f4c:	6a 31                	push   $0x31
  800f4e:	68 83 31 80 00       	push   $0x803183
  800f53:	e8 80 f2 ff ff       	call   8001d8 <_panic>

}
  800f58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    

00800f5d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f66:	68 69 0e 80 00       	push   $0x800e69
  800f6b:	e8 9b 19 00 00       	call   80290b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f70:	b8 07 00 00 00       	mov    $0x7,%eax
  800f75:	cd 30                	int    $0x30
  800f77:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f85:	85 c0                	test   %eax,%eax
  800f87:	75 21                	jne    800faa <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f89:	e8 8d fc ff ff       	call   800c1b <sys_getenvid>
  800f8e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f93:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f9b:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa5:	e9 c9 01 00 00       	jmp    801173 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800faa:	89 d8                	mov    %ebx,%eax
  800fac:	c1 e8 16             	shr    $0x16,%eax
  800faf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb6:	a8 01                	test   $0x1,%al
  800fb8:	0f 84 1b 01 00 00    	je     8010d9 <fork+0x17c>
  800fbe:	89 de                	mov    %ebx,%esi
  800fc0:	c1 ee 0c             	shr    $0xc,%esi
  800fc3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fca:	a8 01                	test   $0x1,%al
  800fcc:	0f 84 07 01 00 00    	je     8010d9 <fork+0x17c>
  800fd2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fd9:	a8 04                	test   $0x4,%al
  800fdb:	0f 84 f8 00 00 00    	je     8010d9 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800fe1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe8:	f6 c4 04             	test   $0x4,%ah
  800feb:	74 3c                	je     801029 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800fed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff4:	c1 e6 0c             	shl    $0xc,%esi
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	25 07 0e 00 00       	and    $0xe07,%eax
  800fff:	50                   	push   %eax
  801000:	56                   	push   %esi
  801001:	ff 75 e4             	pushl  -0x1c(%ebp)
  801004:	56                   	push   %esi
  801005:	6a 00                	push   $0x0
  801007:	e8 90 fc ff ff       	call   800c9c <sys_page_map>
  80100c:	83 c4 20             	add    $0x20,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	0f 89 c2 00 00 00    	jns    8010d9 <fork+0x17c>
			panic("duppage: %e", r);
  801017:	50                   	push   %eax
  801018:	68 dd 31 80 00       	push   $0x8031dd
  80101d:	6a 48                	push   $0x48
  80101f:	68 83 31 80 00       	push   $0x803183
  801024:	e8 af f1 ff ff       	call   8001d8 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801029:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801030:	f6 c4 08             	test   $0x8,%ah
  801033:	75 0b                	jne    801040 <fork+0xe3>
  801035:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80103c:	a8 02                	test   $0x2,%al
  80103e:	74 6c                	je     8010ac <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  801040:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801047:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  80104a:	83 f8 01             	cmp    $0x1,%eax
  80104d:	19 ff                	sbb    %edi,%edi
  80104f:	83 e7 fc             	and    $0xfffffffc,%edi
  801052:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  801058:	c1 e6 0c             	shl    $0xc,%esi
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	ff 75 e4             	pushl  -0x1c(%ebp)
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 31 fc ff ff       	call   800c9c <sys_page_map>
  80106b:	83 c4 20             	add    $0x20,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 12                	jns    801084 <fork+0x127>
			panic("duppage: %e", r);
  801072:	50                   	push   %eax
  801073:	68 dd 31 80 00       	push   $0x8031dd
  801078:	6a 50                	push   $0x50
  80107a:	68 83 31 80 00       	push   $0x803183
  80107f:	e8 54 f1 ff ff       	call   8001d8 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	6a 00                	push   $0x0
  80108b:	56                   	push   %esi
  80108c:	6a 00                	push   $0x0
  80108e:	e8 09 fc ff ff       	call   800c9c <sys_page_map>
  801093:	83 c4 20             	add    $0x20,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	79 3f                	jns    8010d9 <fork+0x17c>
			panic("duppage: %e", r);
  80109a:	50                   	push   %eax
  80109b:	68 dd 31 80 00       	push   $0x8031dd
  8010a0:	6a 53                	push   $0x53
  8010a2:	68 83 31 80 00       	push   $0x803183
  8010a7:	e8 2c f1 ff ff       	call   8001d8 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  8010ac:	c1 e6 0c             	shl    $0xc,%esi
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	6a 05                	push   $0x5
  8010b4:	56                   	push   %esi
  8010b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b8:	56                   	push   %esi
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 dc fb ff ff       	call   800c9c <sys_page_map>
  8010c0:	83 c4 20             	add    $0x20,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	79 12                	jns    8010d9 <fork+0x17c>
			panic("duppage: %e", r);
  8010c7:	50                   	push   %eax
  8010c8:	68 dd 31 80 00       	push   $0x8031dd
  8010cd:	6a 57                	push   $0x57
  8010cf:	68 83 31 80 00       	push   $0x803183
  8010d4:	e8 ff f0 ff ff       	call   8001d8 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  8010d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010df:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010e5:	0f 85 bf fe ff ff    	jne    800faa <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	6a 07                	push   $0x7
  8010f0:	68 00 f0 bf ee       	push   $0xeebff000
  8010f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f8:	e8 5c fb ff ff       	call   800c59 <sys_page_alloc>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	85 c0                	test   %eax,%eax
  801102:	74 17                	je     80111b <fork+0x1be>
		panic("sys_page_alloc Error");
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	68 e9 31 80 00       	push   $0x8031e9
  80110c:	68 83 00 00 00       	push   $0x83
  801111:	68 83 31 80 00       	push   $0x803183
  801116:	e8 bd f0 ff ff       	call   8001d8 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  80111b:	83 ec 08             	sub    $0x8,%esp
  80111e:	68 7a 29 80 00       	push   $0x80297a
  801123:	ff 75 e0             	pushl  -0x20(%ebp)
  801126:	e8 79 fc ff ff       	call   800da4 <sys_env_set_pgfault_upcall>
  80112b:	83 c4 10             	add    $0x10,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	79 15                	jns    801147 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801132:	50                   	push   %eax
  801133:	68 fe 31 80 00       	push   $0x8031fe
  801138:	68 86 00 00 00       	push   $0x86
  80113d:	68 83 31 80 00       	push   $0x803183
  801142:	e8 91 f0 ff ff       	call   8001d8 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	6a 02                	push   $0x2
  80114c:	ff 75 e0             	pushl  -0x20(%ebp)
  80114f:	e8 cc fb ff ff       	call   800d20 <sys_env_set_status>
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	79 15                	jns    801170 <fork+0x213>
		panic("fork set status: %e", r);
  80115b:	50                   	push   %eax
  80115c:	68 16 32 80 00       	push   $0x803216
  801161:	68 89 00 00 00       	push   $0x89
  801166:	68 83 31 80 00       	push   $0x803183
  80116b:	e8 68 f0 ff ff       	call   8001d8 <_panic>
	
	return envid;
  801170:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <sfork>:


// Challenge!
int
sfork(void)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801181:	68 2a 32 80 00       	push   $0x80322a
  801186:	68 93 00 00 00       	push   $0x93
  80118b:	68 83 31 80 00       	push   $0x803183
  801190:	e8 43 f0 ff ff       	call   8001d8 <_panic>

00801195 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
  80119b:	05 00 00 00 30       	add    $0x30000000,%eax
  8011a0:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ab:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011ba:	5d                   	pop    %ebp
  8011bb:	c3                   	ret    

008011bc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	c1 ea 16             	shr    $0x16,%edx
  8011cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d3:	f6 c2 01             	test   $0x1,%dl
  8011d6:	74 11                	je     8011e9 <fd_alloc+0x2d>
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	c1 ea 0c             	shr    $0xc,%edx
  8011dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e4:	f6 c2 01             	test   $0x1,%dl
  8011e7:	75 09                	jne    8011f2 <fd_alloc+0x36>
			*fd_store = fd;
  8011e9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f0:	eb 17                	jmp    801209 <fd_alloc+0x4d>
  8011f2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011fc:	75 c9                	jne    8011c7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011fe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801204:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801211:	83 f8 1f             	cmp    $0x1f,%eax
  801214:	77 36                	ja     80124c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801216:	c1 e0 0c             	shl    $0xc,%eax
  801219:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121e:	89 c2                	mov    %eax,%edx
  801220:	c1 ea 16             	shr    $0x16,%edx
  801223:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122a:	f6 c2 01             	test   $0x1,%dl
  80122d:	74 24                	je     801253 <fd_lookup+0x48>
  80122f:	89 c2                	mov    %eax,%edx
  801231:	c1 ea 0c             	shr    $0xc,%edx
  801234:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123b:	f6 c2 01             	test   $0x1,%dl
  80123e:	74 1a                	je     80125a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801240:	8b 55 0c             	mov    0xc(%ebp),%edx
  801243:	89 02                	mov    %eax,(%edx)
	return 0;
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	eb 13                	jmp    80125f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801251:	eb 0c                	jmp    80125f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801253:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801258:	eb 05                	jmp    80125f <fd_lookup+0x54>
  80125a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	83 ec 08             	sub    $0x8,%esp
  801267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126a:	ba bc 32 80 00       	mov    $0x8032bc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80126f:	eb 13                	jmp    801284 <dev_lookup+0x23>
  801271:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801274:	39 08                	cmp    %ecx,(%eax)
  801276:	75 0c                	jne    801284 <dev_lookup+0x23>
			*dev = devtab[i];
  801278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80127b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
  801282:	eb 2e                	jmp    8012b2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801284:	8b 02                	mov    (%edx),%eax
  801286:	85 c0                	test   %eax,%eax
  801288:	75 e7                	jne    801271 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80128a:	a1 08 50 80 00       	mov    0x805008,%eax
  80128f:	8b 40 48             	mov    0x48(%eax),%eax
  801292:	83 ec 04             	sub    $0x4,%esp
  801295:	51                   	push   %ecx
  801296:	50                   	push   %eax
  801297:	68 40 32 80 00       	push   $0x803240
  80129c:	e8 10 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8012a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 10             	sub    $0x10,%esp
  8012bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012cc:	c1 e8 0c             	shr    $0xc,%eax
  8012cf:	50                   	push   %eax
  8012d0:	e8 36 ff ff ff       	call   80120b <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	78 05                	js     8012e1 <fd_close+0x2d>
	    || fd != fd2)
  8012dc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012df:	74 0c                	je     8012ed <fd_close+0x39>
		return (must_exist ? r : 0);
  8012e1:	84 db                	test   %bl,%bl
  8012e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e8:	0f 44 c2             	cmove  %edx,%eax
  8012eb:	eb 41                	jmp    80132e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012ed:	83 ec 08             	sub    $0x8,%esp
  8012f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 36                	pushl  (%esi)
  8012f6:	e8 66 ff ff ff       	call   801261 <dev_lookup>
  8012fb:	89 c3                	mov    %eax,%ebx
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 1a                	js     80131e <fd_close+0x6a>
		if (dev->dev_close)
  801304:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801307:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80130a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80130f:	85 c0                	test   %eax,%eax
  801311:	74 0b                	je     80131e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801313:	83 ec 0c             	sub    $0xc,%esp
  801316:	56                   	push   %esi
  801317:	ff d0                	call   *%eax
  801319:	89 c3                	mov    %eax,%ebx
  80131b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	56                   	push   %esi
  801322:	6a 00                	push   $0x0
  801324:	e8 b5 f9 ff ff       	call   800cde <sys_page_unmap>
	return r;
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	89 d8                	mov    %ebx,%eax
}
  80132e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	ff 75 08             	pushl  0x8(%ebp)
  801342:	e8 c4 fe ff ff       	call   80120b <fd_lookup>
  801347:	83 c4 08             	add    $0x8,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 10                	js     80135e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	6a 01                	push   $0x1
  801353:	ff 75 f4             	pushl  -0xc(%ebp)
  801356:	e8 59 ff ff ff       	call   8012b4 <fd_close>
  80135b:	83 c4 10             	add    $0x10,%esp
}
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <close_all>:

void
close_all(void)
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	53                   	push   %ebx
  801364:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801367:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136c:	83 ec 0c             	sub    $0xc,%esp
  80136f:	53                   	push   %ebx
  801370:	e8 c0 ff ff ff       	call   801335 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801375:	83 c3 01             	add    $0x1,%ebx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	83 fb 20             	cmp    $0x20,%ebx
  80137e:	75 ec                	jne    80136c <close_all+0xc>
		close(i);
}
  801380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	57                   	push   %edi
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
  80138b:	83 ec 2c             	sub    $0x2c,%esp
  80138e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801391:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	ff 75 08             	pushl  0x8(%ebp)
  801398:	e8 6e fe ff ff       	call   80120b <fd_lookup>
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	0f 88 c1 00 00 00    	js     801469 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	56                   	push   %esi
  8013ac:	e8 84 ff ff ff       	call   801335 <close>

	newfd = INDEX2FD(newfdnum);
  8013b1:	89 f3                	mov    %esi,%ebx
  8013b3:	c1 e3 0c             	shl    $0xc,%ebx
  8013b6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013bc:	83 c4 04             	add    $0x4,%esp
  8013bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c2:	e8 de fd ff ff       	call   8011a5 <fd2data>
  8013c7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c9:	89 1c 24             	mov    %ebx,(%esp)
  8013cc:	e8 d4 fd ff ff       	call   8011a5 <fd2data>
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d7:	89 f8                	mov    %edi,%eax
  8013d9:	c1 e8 16             	shr    $0x16,%eax
  8013dc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e3:	a8 01                	test   $0x1,%al
  8013e5:	74 37                	je     80141e <dup+0x99>
  8013e7:	89 f8                	mov    %edi,%eax
  8013e9:	c1 e8 0c             	shr    $0xc,%eax
  8013ec:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f3:	f6 c2 01             	test   $0x1,%dl
  8013f6:	74 26                	je     80141e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	25 07 0e 00 00       	and    $0xe07,%eax
  801407:	50                   	push   %eax
  801408:	ff 75 d4             	pushl  -0x2c(%ebp)
  80140b:	6a 00                	push   $0x0
  80140d:	57                   	push   %edi
  80140e:	6a 00                	push   $0x0
  801410:	e8 87 f8 ff ff       	call   800c9c <sys_page_map>
  801415:	89 c7                	mov    %eax,%edi
  801417:	83 c4 20             	add    $0x20,%esp
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 2e                	js     80144c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801421:	89 d0                	mov    %edx,%eax
  801423:	c1 e8 0c             	shr    $0xc,%eax
  801426:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142d:	83 ec 0c             	sub    $0xc,%esp
  801430:	25 07 0e 00 00       	and    $0xe07,%eax
  801435:	50                   	push   %eax
  801436:	53                   	push   %ebx
  801437:	6a 00                	push   $0x0
  801439:	52                   	push   %edx
  80143a:	6a 00                	push   $0x0
  80143c:	e8 5b f8 ff ff       	call   800c9c <sys_page_map>
  801441:	89 c7                	mov    %eax,%edi
  801443:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801446:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801448:	85 ff                	test   %edi,%edi
  80144a:	79 1d                	jns    801469 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144c:	83 ec 08             	sub    $0x8,%esp
  80144f:	53                   	push   %ebx
  801450:	6a 00                	push   $0x0
  801452:	e8 87 f8 ff ff       	call   800cde <sys_page_unmap>
	sys_page_unmap(0, nva);
  801457:	83 c4 08             	add    $0x8,%esp
  80145a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145d:	6a 00                	push   $0x0
  80145f:	e8 7a f8 ff ff       	call   800cde <sys_page_unmap>
	return r;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	89 f8                	mov    %edi,%eax
}
  801469:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5f                   	pop    %edi
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	53                   	push   %ebx
  801475:	83 ec 14             	sub    $0x14,%esp
  801478:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147e:	50                   	push   %eax
  80147f:	53                   	push   %ebx
  801480:	e8 86 fd ff ff       	call   80120b <fd_lookup>
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	89 c2                	mov    %eax,%edx
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 6d                	js     8014fb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801498:	ff 30                	pushl  (%eax)
  80149a:	e8 c2 fd ff ff       	call   801261 <dev_lookup>
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 4c                	js     8014f2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a9:	8b 42 08             	mov    0x8(%edx),%eax
  8014ac:	83 e0 03             	and    $0x3,%eax
  8014af:	83 f8 01             	cmp    $0x1,%eax
  8014b2:	75 21                	jne    8014d5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b4:	a1 08 50 80 00       	mov    0x805008,%eax
  8014b9:	8b 40 48             	mov    0x48(%eax),%eax
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	53                   	push   %ebx
  8014c0:	50                   	push   %eax
  8014c1:	68 81 32 80 00       	push   $0x803281
  8014c6:	e8 e6 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d3:	eb 26                	jmp    8014fb <read+0x8a>
	}
	if (!dev->dev_read)
  8014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d8:	8b 40 08             	mov    0x8(%eax),%eax
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	74 17                	je     8014f6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014df:	83 ec 04             	sub    $0x4,%esp
  8014e2:	ff 75 10             	pushl  0x10(%ebp)
  8014e5:	ff 75 0c             	pushl  0xc(%ebp)
  8014e8:	52                   	push   %edx
  8014e9:	ff d0                	call   *%eax
  8014eb:	89 c2                	mov    %eax,%edx
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	eb 09                	jmp    8014fb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	eb 05                	jmp    8014fb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014fb:	89 d0                	mov    %edx,%eax
  8014fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	57                   	push   %edi
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801511:	bb 00 00 00 00       	mov    $0x0,%ebx
  801516:	eb 21                	jmp    801539 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801518:	83 ec 04             	sub    $0x4,%esp
  80151b:	89 f0                	mov    %esi,%eax
  80151d:	29 d8                	sub    %ebx,%eax
  80151f:	50                   	push   %eax
  801520:	89 d8                	mov    %ebx,%eax
  801522:	03 45 0c             	add    0xc(%ebp),%eax
  801525:	50                   	push   %eax
  801526:	57                   	push   %edi
  801527:	e8 45 ff ff ff       	call   801471 <read>
		if (m < 0)
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 10                	js     801543 <readn+0x41>
			return m;
		if (m == 0)
  801533:	85 c0                	test   %eax,%eax
  801535:	74 0a                	je     801541 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801537:	01 c3                	add    %eax,%ebx
  801539:	39 f3                	cmp    %esi,%ebx
  80153b:	72 db                	jb     801518 <readn+0x16>
  80153d:	89 d8                	mov    %ebx,%eax
  80153f:	eb 02                	jmp    801543 <readn+0x41>
  801541:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801546:	5b                   	pop    %ebx
  801547:	5e                   	pop    %esi
  801548:	5f                   	pop    %edi
  801549:	5d                   	pop    %ebp
  80154a:	c3                   	ret    

0080154b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	83 ec 14             	sub    $0x14,%esp
  801552:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801555:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	53                   	push   %ebx
  80155a:	e8 ac fc ff ff       	call   80120b <fd_lookup>
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	89 c2                	mov    %eax,%edx
  801564:	85 c0                	test   %eax,%eax
  801566:	78 68                	js     8015d0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156e:	50                   	push   %eax
  80156f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801572:	ff 30                	pushl  (%eax)
  801574:	e8 e8 fc ff ff       	call   801261 <dev_lookup>
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 47                	js     8015c7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801580:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801583:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801587:	75 21                	jne    8015aa <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801589:	a1 08 50 80 00       	mov    0x805008,%eax
  80158e:	8b 40 48             	mov    0x48(%eax),%eax
  801591:	83 ec 04             	sub    $0x4,%esp
  801594:	53                   	push   %ebx
  801595:	50                   	push   %eax
  801596:	68 9d 32 80 00       	push   $0x80329d
  80159b:	e8 11 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8015a0:	83 c4 10             	add    $0x10,%esp
  8015a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a8:	eb 26                	jmp    8015d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015aa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8015b0:	85 d2                	test   %edx,%edx
  8015b2:	74 17                	je     8015cb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b4:	83 ec 04             	sub    $0x4,%esp
  8015b7:	ff 75 10             	pushl  0x10(%ebp)
  8015ba:	ff 75 0c             	pushl  0xc(%ebp)
  8015bd:	50                   	push   %eax
  8015be:	ff d2                	call   *%edx
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	eb 09                	jmp    8015d0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	eb 05                	jmp    8015d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015d0:	89 d0                	mov    %edx,%eax
  8015d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015dd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	ff 75 08             	pushl  0x8(%ebp)
  8015e4:	e8 22 fc ff ff       	call   80120b <fd_lookup>
  8015e9:	83 c4 08             	add    $0x8,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 0e                	js     8015fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	53                   	push   %ebx
  801604:	83 ec 14             	sub    $0x14,%esp
  801607:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	53                   	push   %ebx
  80160f:	e8 f7 fb ff ff       	call   80120b <fd_lookup>
  801614:	83 c4 08             	add    $0x8,%esp
  801617:	89 c2                	mov    %eax,%edx
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 65                	js     801682 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801627:	ff 30                	pushl  (%eax)
  801629:	e8 33 fc ff ff       	call   801261 <dev_lookup>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	85 c0                	test   %eax,%eax
  801633:	78 44                	js     801679 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801638:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163c:	75 21                	jne    80165f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163e:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801643:	8b 40 48             	mov    0x48(%eax),%eax
  801646:	83 ec 04             	sub    $0x4,%esp
  801649:	53                   	push   %ebx
  80164a:	50                   	push   %eax
  80164b:	68 60 32 80 00       	push   $0x803260
  801650:	e8 5c ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165d:	eb 23                	jmp    801682 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80165f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801662:	8b 52 18             	mov    0x18(%edx),%edx
  801665:	85 d2                	test   %edx,%edx
  801667:	74 14                	je     80167d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	50                   	push   %eax
  801670:	ff d2                	call   *%edx
  801672:	89 c2                	mov    %eax,%edx
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	eb 09                	jmp    801682 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801679:	89 c2                	mov    %eax,%edx
  80167b:	eb 05                	jmp    801682 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80167d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801682:	89 d0                	mov    %edx,%eax
  801684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801687:	c9                   	leave  
  801688:	c3                   	ret    

00801689 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
  80168c:	53                   	push   %ebx
  80168d:	83 ec 14             	sub    $0x14,%esp
  801690:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801693:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	ff 75 08             	pushl  0x8(%ebp)
  80169a:	e8 6c fb ff ff       	call   80120b <fd_lookup>
  80169f:	83 c4 08             	add    $0x8,%esp
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 58                	js     801700 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b2:	ff 30                	pushl  (%eax)
  8016b4:	e8 a8 fb ff ff       	call   801261 <dev_lookup>
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 37                	js     8016f7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c7:	74 32                	je     8016fb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016cc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d3:	00 00 00 
	stat->st_isdir = 0;
  8016d6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016dd:	00 00 00 
	stat->st_dev = dev;
  8016e0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	53                   	push   %ebx
  8016ea:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ed:	ff 50 14             	call   *0x14(%eax)
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	83 c4 10             	add    $0x10,%esp
  8016f5:	eb 09                	jmp    801700 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	eb 05                	jmp    801700 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801700:	89 d0                	mov    %edx,%eax
  801702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801705:	c9                   	leave  
  801706:	c3                   	ret    

00801707 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	6a 00                	push   $0x0
  801711:	ff 75 08             	pushl  0x8(%ebp)
  801714:	e8 ef 01 00 00       	call   801908 <open>
  801719:	89 c3                	mov    %eax,%ebx
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 1b                	js     80173d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801722:	83 ec 08             	sub    $0x8,%esp
  801725:	ff 75 0c             	pushl  0xc(%ebp)
  801728:	50                   	push   %eax
  801729:	e8 5b ff ff ff       	call   801689 <fstat>
  80172e:	89 c6                	mov    %eax,%esi
	close(fd);
  801730:	89 1c 24             	mov    %ebx,(%esp)
  801733:	e8 fd fb ff ff       	call   801335 <close>
	return r;
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	89 f0                	mov    %esi,%eax
}
  80173d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
  801749:	89 c6                	mov    %eax,%esi
  80174b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801754:	75 12                	jne    801768 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801756:	83 ec 0c             	sub    $0xc,%esp
  801759:	6a 01                	push   $0x1
  80175b:	e8 06 13 00 00       	call   802a66 <ipc_find_env>
  801760:	a3 00 50 80 00       	mov    %eax,0x805000
  801765:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801768:	6a 07                	push   $0x7
  80176a:	68 00 60 80 00       	push   $0x806000
  80176f:	56                   	push   %esi
  801770:	ff 35 00 50 80 00    	pushl  0x805000
  801776:	e8 9c 12 00 00       	call   802a17 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80177b:	83 c4 0c             	add    $0xc,%esp
  80177e:	6a 00                	push   $0x0
  801780:	53                   	push   %ebx
  801781:	6a 00                	push   $0x0
  801783:	e8 19 12 00 00       	call   8029a1 <ipc_recv>
}
  801788:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801795:	8b 45 08             	mov    0x8(%ebp),%eax
  801798:	8b 40 0c             	mov    0xc(%eax),%eax
  80179b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a3:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ad:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b2:	e8 8d ff ff ff       	call   801744 <fsipc>
}
  8017b7:	c9                   	leave  
  8017b8:	c3                   	ret    

008017b9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c5:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cf:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d4:	e8 6b ff ff ff       	call   801744 <fsipc>
}
  8017d9:	c9                   	leave  
  8017da:	c3                   	ret    

008017db <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	53                   	push   %ebx
  8017df:	83 ec 04             	sub    $0x4,%esp
  8017e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017eb:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8017fa:	e8 45 ff ff ff       	call   801744 <fsipc>
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 2c                	js     80182f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	68 00 60 80 00       	push   $0x806000
  80180b:	53                   	push   %ebx
  80180c:	e8 45 f0 ff ff       	call   800856 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801811:	a1 80 60 80 00       	mov    0x806080,%eax
  801816:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181c:	a1 84 60 80 00       	mov    0x806084,%eax
  801821:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	53                   	push   %ebx
  801838:	83 ec 08             	sub    $0x8,%esp
  80183b:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80183e:	8b 55 08             	mov    0x8(%ebp),%edx
  801841:	8b 52 0c             	mov    0xc(%edx),%edx
  801844:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  80184a:	a3 04 60 80 00       	mov    %eax,0x806004
  80184f:	3d 08 60 80 00       	cmp    $0x806008,%eax
  801854:	bb 08 60 80 00       	mov    $0x806008,%ebx
  801859:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80185c:	53                   	push   %ebx
  80185d:	ff 75 0c             	pushl  0xc(%ebp)
  801860:	68 08 60 80 00       	push   $0x806008
  801865:	e8 7e f1 ff ff       	call   8009e8 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80186a:	ba 00 00 00 00       	mov    $0x0,%edx
  80186f:	b8 04 00 00 00       	mov    $0x4,%eax
  801874:	e8 cb fe ff ff       	call   801744 <fsipc>
  801879:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80187c:	85 c0                	test   %eax,%eax
  80187e:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	8b 40 0c             	mov    0xc(%eax),%eax
  801894:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801899:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a9:	e8 96 fe ff ff       	call   801744 <fsipc>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 4b                	js     8018ff <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018b4:	39 c6                	cmp    %eax,%esi
  8018b6:	73 16                	jae    8018ce <devfile_read+0x48>
  8018b8:	68 d0 32 80 00       	push   $0x8032d0
  8018bd:	68 d7 32 80 00       	push   $0x8032d7
  8018c2:	6a 7c                	push   $0x7c
  8018c4:	68 ec 32 80 00       	push   $0x8032ec
  8018c9:	e8 0a e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8018ce:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d3:	7e 16                	jle    8018eb <devfile_read+0x65>
  8018d5:	68 f7 32 80 00       	push   $0x8032f7
  8018da:	68 d7 32 80 00       	push   $0x8032d7
  8018df:	6a 7d                	push   $0x7d
  8018e1:	68 ec 32 80 00       	push   $0x8032ec
  8018e6:	e8 ed e8 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	50                   	push   %eax
  8018ef:	68 00 60 80 00       	push   $0x806000
  8018f4:	ff 75 0c             	pushl  0xc(%ebp)
  8018f7:	e8 ec f0 ff ff       	call   8009e8 <memmove>
	return r;
  8018fc:	83 c4 10             	add    $0x10,%esp
}
  8018ff:	89 d8                	mov    %ebx,%eax
  801901:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801904:	5b                   	pop    %ebx
  801905:	5e                   	pop    %esi
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	53                   	push   %ebx
  80190c:	83 ec 20             	sub    $0x20,%esp
  80190f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801912:	53                   	push   %ebx
  801913:	e8 05 ef ff ff       	call   80081d <strlen>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801920:	7f 67                	jg     801989 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801928:	50                   	push   %eax
  801929:	e8 8e f8 ff ff       	call   8011bc <fd_alloc>
  80192e:	83 c4 10             	add    $0x10,%esp
		return r;
  801931:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801933:	85 c0                	test   %eax,%eax
  801935:	78 57                	js     80198e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	53                   	push   %ebx
  80193b:	68 00 60 80 00       	push   $0x806000
  801940:	e8 11 ef ff ff       	call   800856 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801945:	8b 45 0c             	mov    0xc(%ebp),%eax
  801948:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80194d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801950:	b8 01 00 00 00       	mov    $0x1,%eax
  801955:	e8 ea fd ff ff       	call   801744 <fsipc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	79 14                	jns    801977 <open+0x6f>
		fd_close(fd, 0);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	6a 00                	push   $0x0
  801968:	ff 75 f4             	pushl  -0xc(%ebp)
  80196b:	e8 44 f9 ff ff       	call   8012b4 <fd_close>
		return r;
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	89 da                	mov    %ebx,%edx
  801975:	eb 17                	jmp    80198e <open+0x86>
	}

	return fd2num(fd);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	ff 75 f4             	pushl  -0xc(%ebp)
  80197d:	e8 13 f8 ff ff       	call   801195 <fd2num>
  801982:	89 c2                	mov    %eax,%edx
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	eb 05                	jmp    80198e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801989:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80198e:	89 d0                	mov    %edx,%eax
  801990:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80199b:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a5:	e8 9a fd ff ff       	call   801744 <fsipc>
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	57                   	push   %edi
  8019b0:	56                   	push   %esi
  8019b1:	53                   	push   %ebx
  8019b2:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019b8:	6a 00                	push   $0x0
  8019ba:	ff 75 08             	pushl  0x8(%ebp)
  8019bd:	e8 46 ff ff ff       	call   801908 <open>
  8019c2:	89 c7                	mov    %eax,%edi
  8019c4:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	0f 88 81 04 00 00    	js     801e56 <spawn+0x4aa>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	68 00 02 00 00       	push   $0x200
  8019dd:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	57                   	push   %edi
  8019e5:	e8 18 fb ff ff       	call   801502 <readn>
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019f2:	75 0c                	jne    801a00 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019f4:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019fb:	45 4c 46 
  8019fe:	74 33                	je     801a33 <spawn+0x87>
		close(fd);
  801a00:	83 ec 0c             	sub    $0xc,%esp
  801a03:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a09:	e8 27 f9 ff ff       	call   801335 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a0e:	83 c4 0c             	add    $0xc,%esp
  801a11:	68 7f 45 4c 46       	push   $0x464c457f
  801a16:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a1c:	68 03 33 80 00       	push   $0x803303
  801a21:	e8 8b e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a2e:	e9 c6 04 00 00       	jmp    801ef9 <spawn+0x54d>
  801a33:	b8 07 00 00 00       	mov    $0x7,%eax
  801a38:	cd 30                	int    $0x30
  801a3a:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a40:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a46:	85 c0                	test   %eax,%eax
  801a48:	0f 88 13 04 00 00    	js     801e61 <spawn+0x4b5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a4e:	89 c6                	mov    %eax,%esi
  801a50:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a56:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a59:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a5f:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a65:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a6c:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a72:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a78:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a7d:	be 00 00 00 00       	mov    $0x0,%esi
  801a82:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a85:	eb 13                	jmp    801a9a <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	50                   	push   %eax
  801a8b:	e8 8d ed ff ff       	call   80081d <strlen>
  801a90:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a94:	83 c3 01             	add    $0x1,%ebx
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801aa1:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	75 df                	jne    801a87 <spawn+0xdb>
  801aa8:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801aae:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801ab4:	bf 00 10 40 00       	mov    $0x401000,%edi
  801ab9:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801abb:	89 fa                	mov    %edi,%edx
  801abd:	83 e2 fc             	and    $0xfffffffc,%edx
  801ac0:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801ac7:	29 c2                	sub    %eax,%edx
  801ac9:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801acf:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ad2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801ad7:	0f 86 9a 03 00 00    	jbe    801e77 <spawn+0x4cb>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801add:	83 ec 04             	sub    $0x4,%esp
  801ae0:	6a 07                	push   $0x7
  801ae2:	68 00 00 40 00       	push   $0x400000
  801ae7:	6a 00                	push   $0x0
  801ae9:	e8 6b f1 ff ff       	call   800c59 <sys_page_alloc>
  801aee:	83 c4 10             	add    $0x10,%esp
  801af1:	85 c0                	test   %eax,%eax
  801af3:	0f 88 85 03 00 00    	js     801e7e <spawn+0x4d2>
  801af9:	be 00 00 00 00       	mov    $0x0,%esi
  801afe:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b07:	eb 30                	jmp    801b39 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b09:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b0f:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b15:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801b18:	83 ec 08             	sub    $0x8,%esp
  801b1b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b1e:	57                   	push   %edi
  801b1f:	e8 32 ed ff ff       	call   800856 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b24:	83 c4 04             	add    $0x4,%esp
  801b27:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b2a:	e8 ee ec ff ff       	call   80081d <strlen>
  801b2f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b33:	83 c6 01             	add    $0x1,%esi
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b3f:	7f c8                	jg     801b09 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b41:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b47:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801b4d:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b54:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b5a:	74 19                	je     801b75 <spawn+0x1c9>
  801b5c:	68 90 33 80 00       	push   $0x803390
  801b61:	68 d7 32 80 00       	push   $0x8032d7
  801b66:	68 f1 00 00 00       	push   $0xf1
  801b6b:	68 1d 33 80 00       	push   $0x80331d
  801b70:	e8 63 e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b75:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b7b:	89 f8                	mov    %edi,%eax
  801b7d:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b82:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b85:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b8b:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b8e:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b94:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b9a:	83 ec 0c             	sub    $0xc,%esp
  801b9d:	6a 07                	push   $0x7
  801b9f:	68 00 d0 bf ee       	push   $0xeebfd000
  801ba4:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801baa:	68 00 00 40 00       	push   $0x400000
  801baf:	6a 00                	push   $0x0
  801bb1:	e8 e6 f0 ff ff       	call   800c9c <sys_page_map>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	83 c4 20             	add    $0x20,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	0f 88 24 03 00 00    	js     801ee7 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bc3:	83 ec 08             	sub    $0x8,%esp
  801bc6:	68 00 00 40 00       	push   $0x400000
  801bcb:	6a 00                	push   $0x0
  801bcd:	e8 0c f1 ff ff       	call   800cde <sys_page_unmap>
  801bd2:	89 c3                	mov    %eax,%ebx
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	0f 88 08 03 00 00    	js     801ee7 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bdf:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801be5:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bec:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bf2:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bf9:	00 00 00 
  801bfc:	e9 8a 01 00 00       	jmp    801d8b <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  801c01:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c07:	83 38 01             	cmpl   $0x1,(%eax)
  801c0a:	0f 85 6d 01 00 00    	jne    801d7d <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c10:	89 c7                	mov    %eax,%edi
  801c12:	8b 40 18             	mov    0x18(%eax),%eax
  801c15:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c1b:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c1e:	83 f8 01             	cmp    $0x1,%eax
  801c21:	19 c0                	sbb    %eax,%eax
  801c23:	83 e0 fe             	and    $0xfffffffe,%eax
  801c26:	83 c0 07             	add    $0x7,%eax
  801c29:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	8b 7f 04             	mov    0x4(%edi),%edi
  801c34:	89 f9                	mov    %edi,%ecx
  801c36:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c3c:	8b 78 10             	mov    0x10(%eax),%edi
  801c3f:	8b 70 14             	mov    0x14(%eax),%esi
  801c42:	89 f2                	mov    %esi,%edx
  801c44:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801c4a:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c4d:	89 f0                	mov    %esi,%eax
  801c4f:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c54:	74 14                	je     801c6a <spawn+0x2be>
		va -= i;
  801c56:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c58:	01 c2                	add    %eax,%edx
  801c5a:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801c60:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c62:	29 c1                	sub    %eax,%ecx
  801c64:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6f:	e9 f7 00 00 00       	jmp    801d6b <spawn+0x3bf>
		if (i >= filesz) {
  801c74:	39 df                	cmp    %ebx,%edi
  801c76:	77 27                	ja     801c9f <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c78:	83 ec 04             	sub    $0x4,%esp
  801c7b:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c81:	56                   	push   %esi
  801c82:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c88:	e8 cc ef ff ff       	call   800c59 <sys_page_alloc>
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 89 c7 00 00 00    	jns    801d5f <spawn+0x3b3>
  801c98:	89 c3                	mov    %eax,%ebx
  801c9a:	e9 ed 01 00 00       	jmp    801e8c <spawn+0x4e0>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c9f:	83 ec 04             	sub    $0x4,%esp
  801ca2:	6a 07                	push   $0x7
  801ca4:	68 00 00 40 00       	push   $0x400000
  801ca9:	6a 00                	push   $0x0
  801cab:	e8 a9 ef ff ff       	call   800c59 <sys_page_alloc>
  801cb0:	83 c4 10             	add    $0x10,%esp
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	0f 88 c7 01 00 00    	js     801e82 <spawn+0x4d6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cbb:	83 ec 08             	sub    $0x8,%esp
  801cbe:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cc4:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801cca:	50                   	push   %eax
  801ccb:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cd1:	e8 01 f9 ff ff       	call   8015d7 <seek>
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	85 c0                	test   %eax,%eax
  801cdb:	0f 88 a5 01 00 00    	js     801e86 <spawn+0x4da>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ce1:	83 ec 04             	sub    $0x4,%esp
  801ce4:	89 f8                	mov    %edi,%eax
  801ce6:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801cec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cf1:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801cf6:	0f 47 c1             	cmova  %ecx,%eax
  801cf9:	50                   	push   %eax
  801cfa:	68 00 00 40 00       	push   $0x400000
  801cff:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d05:	e8 f8 f7 ff ff       	call   801502 <readn>
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	0f 88 75 01 00 00    	js     801e8a <spawn+0x4de>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d15:	83 ec 0c             	sub    $0xc,%esp
  801d18:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d1e:	56                   	push   %esi
  801d1f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d25:	68 00 00 40 00       	push   $0x400000
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 6b ef ff ff       	call   800c9c <sys_page_map>
  801d31:	83 c4 20             	add    $0x20,%esp
  801d34:	85 c0                	test   %eax,%eax
  801d36:	79 15                	jns    801d4d <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  801d38:	50                   	push   %eax
  801d39:	68 29 33 80 00       	push   $0x803329
  801d3e:	68 24 01 00 00       	push   $0x124
  801d43:	68 1d 33 80 00       	push   $0x80331d
  801d48:	e8 8b e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801d4d:	83 ec 08             	sub    $0x8,%esp
  801d50:	68 00 00 40 00       	push   $0x400000
  801d55:	6a 00                	push   $0x0
  801d57:	e8 82 ef ff ff       	call   800cde <sys_page_unmap>
  801d5c:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d5f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d65:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d6b:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d71:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801d77:	0f 87 f7 fe ff ff    	ja     801c74 <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d7d:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d84:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d8b:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d92:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d98:	0f 8c 63 fe ff ff    	jl     801c01 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801da7:	e8 89 f5 ff ff       	call   801335 <close>
  801dac:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  801daf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801db4:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801dba:	89 d8                	mov    %ebx,%eax
  801dbc:	c1 e0 0c             	shl    $0xc,%eax
		if (((uvpd[PDX(pgnum*PGSIZE)] & PTE_P) && (uvpt[pgnum] & PTE_P) && (uvpt[pgnum] & PTE_SHARE))){
  801dbf:	89 c2                	mov    %eax,%edx
  801dc1:	c1 ea 16             	shr    $0x16,%edx
  801dc4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dcb:	f6 c2 01             	test   $0x1,%dl
  801dce:	74 35                	je     801e05 <spawn+0x459>
  801dd0:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801dd7:	f6 c2 01             	test   $0x1,%dl
  801dda:	74 29                	je     801e05 <spawn+0x459>
  801ddc:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  801de3:	f6 c6 04             	test   $0x4,%dh
  801de6:	74 1d                	je     801e05 <spawn+0x459>
			if((r=sys_page_map(0, (void *)(pgnum*PGSIZE), child, (void *)(pgnum*PGSIZE), PTE_SYSCALL))<0)
  801de8:	83 ec 0c             	sub    $0xc,%esp
  801deb:	68 07 0e 00 00       	push   $0xe07
  801df0:	50                   	push   %eax
  801df1:	56                   	push   %esi
  801df2:	50                   	push   %eax
  801df3:	6a 00                	push   $0x0
  801df5:	e8 a2 ee ff ff       	call   800c9c <sys_page_map>
  801dfa:	83 c4 20             	add    $0x20,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	0f 88 a8 00 00 00    	js     801ead <spawn+0x501>
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  801e05:	83 c3 01             	add    $0x1,%ebx
  801e08:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  801e0e:	75 aa                	jne    801dba <spawn+0x40e>
  801e10:	e9 ad 00 00 00       	jmp    801ec2 <spawn+0x516>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801e15:	50                   	push   %eax
  801e16:	68 46 33 80 00       	push   $0x803346
  801e1b:	68 85 00 00 00       	push   $0x85
  801e20:	68 1d 33 80 00       	push   $0x80331d
  801e25:	e8 ae e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e2a:	83 ec 08             	sub    $0x8,%esp
  801e2d:	6a 02                	push   $0x2
  801e2f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e35:	e8 e6 ee ff ff       	call   800d20 <sys_env_set_status>
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	79 2b                	jns    801e6c <spawn+0x4c0>
		panic("sys_env_set_status: %e", r);
  801e41:	50                   	push   %eax
  801e42:	68 60 33 80 00       	push   $0x803360
  801e47:	68 88 00 00 00       	push   $0x88
  801e4c:	68 1d 33 80 00       	push   $0x80331d
  801e51:	e8 82 e3 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e56:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e5c:	e9 98 00 00 00       	jmp    801ef9 <spawn+0x54d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e61:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e67:	e9 8d 00 00 00       	jmp    801ef9 <spawn+0x54d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e6c:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e72:	e9 82 00 00 00       	jmp    801ef9 <spawn+0x54d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e77:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e7c:	eb 7b                	jmp    801ef9 <spawn+0x54d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	eb 77                	jmp    801ef9 <spawn+0x54d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	eb 06                	jmp    801e8c <spawn+0x4e0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e86:	89 c3                	mov    %eax,%ebx
  801e88:	eb 02                	jmp    801e8c <spawn+0x4e0>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e8a:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801e8c:	83 ec 0c             	sub    $0xc,%esp
  801e8f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e95:	e8 40 ed ff ff       	call   800bda <sys_env_destroy>
	close(fd);
  801e9a:	83 c4 04             	add    $0x4,%esp
  801e9d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ea3:	e8 8d f4 ff ff       	call   801335 <close>
	return r;
  801ea8:	83 c4 10             	add    $0x10,%esp
  801eab:	eb 4c                	jmp    801ef9 <spawn+0x54d>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ead:	50                   	push   %eax
  801eae:	68 77 33 80 00       	push   $0x803377
  801eb3:	68 82 00 00 00       	push   $0x82
  801eb8:	68 1d 33 80 00       	push   $0x80331d
  801ebd:	e8 16 e3 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801ec2:	83 ec 08             	sub    $0x8,%esp
  801ec5:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ecb:	50                   	push   %eax
  801ecc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ed2:	e8 8b ee ff ff       	call   800d62 <sys_env_set_trapframe>
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	0f 89 48 ff ff ff    	jns    801e2a <spawn+0x47e>
  801ee2:	e9 2e ff ff ff       	jmp    801e15 <spawn+0x469>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ee7:	83 ec 08             	sub    $0x8,%esp
  801eea:	68 00 00 40 00       	push   $0x400000
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 e8 ed ff ff       	call   800cde <sys_page_unmap>
  801ef6:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ef9:	89 d8                	mov    %ebx,%eax
  801efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5f                   	pop    %edi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f08:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f0b:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f10:	eb 03                	jmp    801f15 <spawnl+0x12>
		argc++;
  801f12:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f15:	83 c2 04             	add    $0x4,%edx
  801f18:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f1c:	75 f4                	jne    801f12 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f1e:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f25:	83 e2 f0             	and    $0xfffffff0,%edx
  801f28:	29 d4                	sub    %edx,%esp
  801f2a:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f2e:	c1 ea 02             	shr    $0x2,%edx
  801f31:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f38:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f3d:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f44:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f4b:	00 
  801f4c:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801f53:	eb 0a                	jmp    801f5f <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f55:	83 c0 01             	add    $0x1,%eax
  801f58:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f5c:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f5f:	39 d0                	cmp    %edx,%eax
  801f61:	75 f2                	jne    801f55 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f63:	83 ec 08             	sub    $0x8,%esp
  801f66:	56                   	push   %esi
  801f67:	ff 75 08             	pushl  0x8(%ebp)
  801f6a:	e8 3d fa ff ff       	call   8019ac <spawn>
}
  801f6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f72:	5b                   	pop    %ebx
  801f73:	5e                   	pop    %esi
  801f74:	5d                   	pop    %ebp
  801f75:	c3                   	ret    

00801f76 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	56                   	push   %esi
  801f7a:	53                   	push   %ebx
  801f7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	ff 75 08             	pushl  0x8(%ebp)
  801f84:	e8 1c f2 ff ff       	call   8011a5 <fd2data>
  801f89:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f8b:	83 c4 08             	add    $0x8,%esp
  801f8e:	68 b8 33 80 00       	push   $0x8033b8
  801f93:	53                   	push   %ebx
  801f94:	e8 bd e8 ff ff       	call   800856 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f99:	8b 46 04             	mov    0x4(%esi),%eax
  801f9c:	2b 06                	sub    (%esi),%eax
  801f9e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fa4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fab:	00 00 00 
	stat->st_dev = &devpipe;
  801fae:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  801fb5:	40 80 00 
	return 0;
}
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc0:	5b                   	pop    %ebx
  801fc1:	5e                   	pop    %esi
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 0c             	sub    $0xc,%esp
  801fcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fce:	53                   	push   %ebx
  801fcf:	6a 00                	push   $0x0
  801fd1:	e8 08 ed ff ff       	call   800cde <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fd6:	89 1c 24             	mov    %ebx,(%esp)
  801fd9:	e8 c7 f1 ff ff       	call   8011a5 <fd2data>
  801fde:	83 c4 08             	add    $0x8,%esp
  801fe1:	50                   	push   %eax
  801fe2:	6a 00                	push   $0x0
  801fe4:	e8 f5 ec ff ff       	call   800cde <sys_page_unmap>
}
  801fe9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ffa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ffc:	a1 08 50 80 00       	mov    0x805008,%eax
  802001:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802004:	83 ec 0c             	sub    $0xc,%esp
  802007:	ff 75 e0             	pushl  -0x20(%ebp)
  80200a:	e8 90 0a 00 00       	call   802a9f <pageref>
  80200f:	89 c3                	mov    %eax,%ebx
  802011:	89 3c 24             	mov    %edi,(%esp)
  802014:	e8 86 0a 00 00       	call   802a9f <pageref>
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	39 c3                	cmp    %eax,%ebx
  80201e:	0f 94 c1             	sete   %cl
  802021:	0f b6 c9             	movzbl %cl,%ecx
  802024:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802027:	8b 15 08 50 80 00    	mov    0x805008,%edx
  80202d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	74 1b                	je     80204f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802034:	39 c3                	cmp    %eax,%ebx
  802036:	75 c4                	jne    801ffc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802038:	8b 42 58             	mov    0x58(%edx),%eax
  80203b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80203e:	50                   	push   %eax
  80203f:	56                   	push   %esi
  802040:	68 bf 33 80 00       	push   $0x8033bf
  802045:	e8 67 e2 ff ff       	call   8002b1 <cprintf>
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	eb ad                	jmp    801ffc <_pipeisclosed+0xe>
	}
}
  80204f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802052:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    

0080205a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80205a:	55                   	push   %ebp
  80205b:	89 e5                	mov    %esp,%ebp
  80205d:	57                   	push   %edi
  80205e:	56                   	push   %esi
  80205f:	53                   	push   %ebx
  802060:	83 ec 28             	sub    $0x28,%esp
  802063:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802066:	56                   	push   %esi
  802067:	e8 39 f1 ff ff       	call   8011a5 <fd2data>
  80206c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	bf 00 00 00 00       	mov    $0x0,%edi
  802076:	eb 4b                	jmp    8020c3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802078:	89 da                	mov    %ebx,%edx
  80207a:	89 f0                	mov    %esi,%eax
  80207c:	e8 6d ff ff ff       	call   801fee <_pipeisclosed>
  802081:	85 c0                	test   %eax,%eax
  802083:	75 48                	jne    8020cd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802085:	e8 b0 eb ff ff       	call   800c3a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80208a:	8b 43 04             	mov    0x4(%ebx),%eax
  80208d:	8b 0b                	mov    (%ebx),%ecx
  80208f:	8d 51 20             	lea    0x20(%ecx),%edx
  802092:	39 d0                	cmp    %edx,%eax
  802094:	73 e2                	jae    802078 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802099:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80209d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a0:	89 c2                	mov    %eax,%edx
  8020a2:	c1 fa 1f             	sar    $0x1f,%edx
  8020a5:	89 d1                	mov    %edx,%ecx
  8020a7:	c1 e9 1b             	shr    $0x1b,%ecx
  8020aa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020ad:	83 e2 1f             	and    $0x1f,%edx
  8020b0:	29 ca                	sub    %ecx,%edx
  8020b2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020ba:	83 c0 01             	add    $0x1,%eax
  8020bd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c0:	83 c7 01             	add    $0x1,%edi
  8020c3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020c6:	75 c2                	jne    80208a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cb:	eb 05                	jmp    8020d2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020cd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d5:	5b                   	pop    %ebx
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	5d                   	pop    %ebp
  8020d9:	c3                   	ret    

008020da <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020da:	55                   	push   %ebp
  8020db:	89 e5                	mov    %esp,%ebp
  8020dd:	57                   	push   %edi
  8020de:	56                   	push   %esi
  8020df:	53                   	push   %ebx
  8020e0:	83 ec 18             	sub    $0x18,%esp
  8020e3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020e6:	57                   	push   %edi
  8020e7:	e8 b9 f0 ff ff       	call   8011a5 <fd2data>
  8020ec:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020ee:	83 c4 10             	add    $0x10,%esp
  8020f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f6:	eb 3d                	jmp    802135 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020f8:	85 db                	test   %ebx,%ebx
  8020fa:	74 04                	je     802100 <devpipe_read+0x26>
				return i;
  8020fc:	89 d8                	mov    %ebx,%eax
  8020fe:	eb 44                	jmp    802144 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802100:	89 f2                	mov    %esi,%edx
  802102:	89 f8                	mov    %edi,%eax
  802104:	e8 e5 fe ff ff       	call   801fee <_pipeisclosed>
  802109:	85 c0                	test   %eax,%eax
  80210b:	75 32                	jne    80213f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80210d:	e8 28 eb ff ff       	call   800c3a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802112:	8b 06                	mov    (%esi),%eax
  802114:	3b 46 04             	cmp    0x4(%esi),%eax
  802117:	74 df                	je     8020f8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802119:	99                   	cltd   
  80211a:	c1 ea 1b             	shr    $0x1b,%edx
  80211d:	01 d0                	add    %edx,%eax
  80211f:	83 e0 1f             	and    $0x1f,%eax
  802122:	29 d0                	sub    %edx,%eax
  802124:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80212f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802132:	83 c3 01             	add    $0x1,%ebx
  802135:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802138:	75 d8                	jne    802112 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80213a:	8b 45 10             	mov    0x10(%ebp),%eax
  80213d:	eb 05                	jmp    802144 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80213f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802144:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    

0080214c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	56                   	push   %esi
  802150:	53                   	push   %ebx
  802151:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802154:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802157:	50                   	push   %eax
  802158:	e8 5f f0 ff ff       	call   8011bc <fd_alloc>
  80215d:	83 c4 10             	add    $0x10,%esp
  802160:	89 c2                	mov    %eax,%edx
  802162:	85 c0                	test   %eax,%eax
  802164:	0f 88 2c 01 00 00    	js     802296 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80216a:	83 ec 04             	sub    $0x4,%esp
  80216d:	68 07 04 00 00       	push   $0x407
  802172:	ff 75 f4             	pushl  -0xc(%ebp)
  802175:	6a 00                	push   $0x0
  802177:	e8 dd ea ff ff       	call   800c59 <sys_page_alloc>
  80217c:	83 c4 10             	add    $0x10,%esp
  80217f:	89 c2                	mov    %eax,%edx
  802181:	85 c0                	test   %eax,%eax
  802183:	0f 88 0d 01 00 00    	js     802296 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802189:	83 ec 0c             	sub    $0xc,%esp
  80218c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80218f:	50                   	push   %eax
  802190:	e8 27 f0 ff ff       	call   8011bc <fd_alloc>
  802195:	89 c3                	mov    %eax,%ebx
  802197:	83 c4 10             	add    $0x10,%esp
  80219a:	85 c0                	test   %eax,%eax
  80219c:	0f 88 e2 00 00 00    	js     802284 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021a2:	83 ec 04             	sub    $0x4,%esp
  8021a5:	68 07 04 00 00       	push   $0x407
  8021aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ad:	6a 00                	push   $0x0
  8021af:	e8 a5 ea ff ff       	call   800c59 <sys_page_alloc>
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	0f 88 c3 00 00 00    	js     802284 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021c1:	83 ec 0c             	sub    $0xc,%esp
  8021c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c7:	e8 d9 ef ff ff       	call   8011a5 <fd2data>
  8021cc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ce:	83 c4 0c             	add    $0xc,%esp
  8021d1:	68 07 04 00 00       	push   $0x407
  8021d6:	50                   	push   %eax
  8021d7:	6a 00                	push   $0x0
  8021d9:	e8 7b ea ff ff       	call   800c59 <sys_page_alloc>
  8021de:	89 c3                	mov    %eax,%ebx
  8021e0:	83 c4 10             	add    $0x10,%esp
  8021e3:	85 c0                	test   %eax,%eax
  8021e5:	0f 88 89 00 00 00    	js     802274 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021eb:	83 ec 0c             	sub    $0xc,%esp
  8021ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f1:	e8 af ef ff ff       	call   8011a5 <fd2data>
  8021f6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021fd:	50                   	push   %eax
  8021fe:	6a 00                	push   $0x0
  802200:	56                   	push   %esi
  802201:	6a 00                	push   $0x0
  802203:	e8 94 ea ff ff       	call   800c9c <sys_page_map>
  802208:	89 c3                	mov    %eax,%ebx
  80220a:	83 c4 20             	add    $0x20,%esp
  80220d:	85 c0                	test   %eax,%eax
  80220f:	78 55                	js     802266 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802211:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802217:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80221c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802226:	8b 15 28 40 80 00    	mov    0x804028,%edx
  80222c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80222f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802231:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802234:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80223b:	83 ec 0c             	sub    $0xc,%esp
  80223e:	ff 75 f4             	pushl  -0xc(%ebp)
  802241:	e8 4f ef ff ff       	call   801195 <fd2num>
  802246:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802249:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80224b:	83 c4 04             	add    $0x4,%esp
  80224e:	ff 75 f0             	pushl  -0x10(%ebp)
  802251:	e8 3f ef ff ff       	call   801195 <fd2num>
  802256:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802259:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80225c:	83 c4 10             	add    $0x10,%esp
  80225f:	ba 00 00 00 00       	mov    $0x0,%edx
  802264:	eb 30                	jmp    802296 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802266:	83 ec 08             	sub    $0x8,%esp
  802269:	56                   	push   %esi
  80226a:	6a 00                	push   $0x0
  80226c:	e8 6d ea ff ff       	call   800cde <sys_page_unmap>
  802271:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802274:	83 ec 08             	sub    $0x8,%esp
  802277:	ff 75 f0             	pushl  -0x10(%ebp)
  80227a:	6a 00                	push   $0x0
  80227c:	e8 5d ea ff ff       	call   800cde <sys_page_unmap>
  802281:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802284:	83 ec 08             	sub    $0x8,%esp
  802287:	ff 75 f4             	pushl  -0xc(%ebp)
  80228a:	6a 00                	push   $0x0
  80228c:	e8 4d ea ff ff       	call   800cde <sys_page_unmap>
  802291:	83 c4 10             	add    $0x10,%esp
  802294:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802296:	89 d0                	mov    %edx,%eax
  802298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80229b:	5b                   	pop    %ebx
  80229c:	5e                   	pop    %esi
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    

0080229f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a8:	50                   	push   %eax
  8022a9:	ff 75 08             	pushl  0x8(%ebp)
  8022ac:	e8 5a ef ff ff       	call   80120b <fd_lookup>
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	78 18                	js     8022d0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022b8:	83 ec 0c             	sub    $0xc,%esp
  8022bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8022be:	e8 e2 ee ff ff       	call   8011a5 <fd2data>
	return _pipeisclosed(fd, p);
  8022c3:	89 c2                	mov    %eax,%edx
  8022c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c8:	e8 21 fd ff ff       	call   801fee <_pipeisclosed>
  8022cd:	83 c4 10             	add    $0x10,%esp
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	56                   	push   %esi
  8022d6:	53                   	push   %ebx
  8022d7:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022da:	85 f6                	test   %esi,%esi
  8022dc:	75 16                	jne    8022f4 <wait+0x22>
  8022de:	68 d7 33 80 00       	push   $0x8033d7
  8022e3:	68 d7 32 80 00       	push   $0x8032d7
  8022e8:	6a 09                	push   $0x9
  8022ea:	68 e2 33 80 00       	push   $0x8033e2
  8022ef:	e8 e4 de ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  8022f4:	89 f3                	mov    %esi,%ebx
  8022f6:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022fc:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022ff:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802305:	eb 05                	jmp    80230c <wait+0x3a>
		sys_yield();
  802307:	e8 2e e9 ff ff       	call   800c3a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80230c:	8b 43 48             	mov    0x48(%ebx),%eax
  80230f:	39 c6                	cmp    %eax,%esi
  802311:	75 07                	jne    80231a <wait+0x48>
  802313:	8b 43 54             	mov    0x54(%ebx),%eax
  802316:	85 c0                	test   %eax,%eax
  802318:	75 ed                	jne    802307 <wait+0x35>
		sys_yield();
}
  80231a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80231d:	5b                   	pop    %ebx
  80231e:	5e                   	pop    %esi
  80231f:	5d                   	pop    %ebp
  802320:	c3                   	ret    

00802321 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802327:	68 ed 33 80 00       	push   $0x8033ed
  80232c:	ff 75 0c             	pushl  0xc(%ebp)
  80232f:	e8 22 e5 ff ff       	call   800856 <strcpy>
	return 0;
}
  802334:	b8 00 00 00 00       	mov    $0x0,%eax
  802339:	c9                   	leave  
  80233a:	c3                   	ret    

0080233b <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	53                   	push   %ebx
  80233f:	83 ec 10             	sub    $0x10,%esp
  802342:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802345:	53                   	push   %ebx
  802346:	e8 54 07 00 00       	call   802a9f <pageref>
  80234b:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80234e:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802353:	83 f8 01             	cmp    $0x1,%eax
  802356:	75 10                	jne    802368 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802358:	83 ec 0c             	sub    $0xc,%esp
  80235b:	ff 73 0c             	pushl  0xc(%ebx)
  80235e:	e8 c0 02 00 00       	call   802623 <nsipc_close>
  802363:	89 c2                	mov    %eax,%edx
  802365:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802368:	89 d0                	mov    %edx,%eax
  80236a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80236d:	c9                   	leave  
  80236e:	c3                   	ret    

0080236f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802375:	6a 00                	push   $0x0
  802377:	ff 75 10             	pushl  0x10(%ebp)
  80237a:	ff 75 0c             	pushl  0xc(%ebp)
  80237d:	8b 45 08             	mov    0x8(%ebp),%eax
  802380:	ff 70 0c             	pushl  0xc(%eax)
  802383:	e8 78 03 00 00       	call   802700 <nsipc_send>
}
  802388:	c9                   	leave  
  802389:	c3                   	ret    

0080238a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80238a:	55                   	push   %ebp
  80238b:	89 e5                	mov    %esp,%ebp
  80238d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802390:	6a 00                	push   $0x0
  802392:	ff 75 10             	pushl  0x10(%ebp)
  802395:	ff 75 0c             	pushl  0xc(%ebp)
  802398:	8b 45 08             	mov    0x8(%ebp),%eax
  80239b:	ff 70 0c             	pushl  0xc(%eax)
  80239e:	e8 f1 02 00 00       	call   802694 <nsipc_recv>
}
  8023a3:	c9                   	leave  
  8023a4:	c3                   	ret    

008023a5 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8023a5:	55                   	push   %ebp
  8023a6:	89 e5                	mov    %esp,%ebp
  8023a8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8023ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8023ae:	52                   	push   %edx
  8023af:	50                   	push   %eax
  8023b0:	e8 56 ee ff ff       	call   80120b <fd_lookup>
  8023b5:	83 c4 10             	add    $0x10,%esp
  8023b8:	85 c0                	test   %eax,%eax
  8023ba:	78 17                	js     8023d3 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8023bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bf:	8b 0d 44 40 80 00    	mov    0x804044,%ecx
  8023c5:	39 08                	cmp    %ecx,(%eax)
  8023c7:	75 05                	jne    8023ce <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8023c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8023cc:	eb 05                	jmp    8023d3 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8023ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8023d3:	c9                   	leave  
  8023d4:	c3                   	ret    

008023d5 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	56                   	push   %esi
  8023d9:	53                   	push   %ebx
  8023da:	83 ec 1c             	sub    $0x1c,%esp
  8023dd:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8023df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023e2:	50                   	push   %eax
  8023e3:	e8 d4 ed ff ff       	call   8011bc <fd_alloc>
  8023e8:	89 c3                	mov    %eax,%ebx
  8023ea:	83 c4 10             	add    $0x10,%esp
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	78 1b                	js     80240c <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8023f1:	83 ec 04             	sub    $0x4,%esp
  8023f4:	68 07 04 00 00       	push   $0x407
  8023f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8023fc:	6a 00                	push   $0x0
  8023fe:	e8 56 e8 ff ff       	call   800c59 <sys_page_alloc>
  802403:	89 c3                	mov    %eax,%ebx
  802405:	83 c4 10             	add    $0x10,%esp
  802408:	85 c0                	test   %eax,%eax
  80240a:	79 10                	jns    80241c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80240c:	83 ec 0c             	sub    $0xc,%esp
  80240f:	56                   	push   %esi
  802410:	e8 0e 02 00 00       	call   802623 <nsipc_close>
		return r;
  802415:	83 c4 10             	add    $0x10,%esp
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	eb 24                	jmp    802440 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80241c:	8b 15 44 40 80 00    	mov    0x804044,%edx
  802422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802425:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802427:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802431:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802434:	83 ec 0c             	sub    $0xc,%esp
  802437:	50                   	push   %eax
  802438:	e8 58 ed ff ff       	call   801195 <fd2num>
  80243d:	83 c4 10             	add    $0x10,%esp
}
  802440:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802443:	5b                   	pop    %ebx
  802444:	5e                   	pop    %esi
  802445:	5d                   	pop    %ebp
  802446:	c3                   	ret    

00802447 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802447:	55                   	push   %ebp
  802448:	89 e5                	mov    %esp,%ebp
  80244a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80244d:	8b 45 08             	mov    0x8(%ebp),%eax
  802450:	e8 50 ff ff ff       	call   8023a5 <fd2sockid>
		return r;
  802455:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802457:	85 c0                	test   %eax,%eax
  802459:	78 1f                	js     80247a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80245b:	83 ec 04             	sub    $0x4,%esp
  80245e:	ff 75 10             	pushl  0x10(%ebp)
  802461:	ff 75 0c             	pushl  0xc(%ebp)
  802464:	50                   	push   %eax
  802465:	e8 12 01 00 00       	call   80257c <nsipc_accept>
  80246a:	83 c4 10             	add    $0x10,%esp
		return r;
  80246d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80246f:	85 c0                	test   %eax,%eax
  802471:	78 07                	js     80247a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802473:	e8 5d ff ff ff       	call   8023d5 <alloc_sockfd>
  802478:	89 c1                	mov    %eax,%ecx
}
  80247a:	89 c8                	mov    %ecx,%eax
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802484:	8b 45 08             	mov    0x8(%ebp),%eax
  802487:	e8 19 ff ff ff       	call   8023a5 <fd2sockid>
  80248c:	85 c0                	test   %eax,%eax
  80248e:	78 12                	js     8024a2 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802490:	83 ec 04             	sub    $0x4,%esp
  802493:	ff 75 10             	pushl  0x10(%ebp)
  802496:	ff 75 0c             	pushl  0xc(%ebp)
  802499:	50                   	push   %eax
  80249a:	e8 2d 01 00 00       	call   8025cc <nsipc_bind>
  80249f:	83 c4 10             	add    $0x10,%esp
}
  8024a2:	c9                   	leave  
  8024a3:	c3                   	ret    

008024a4 <shutdown>:

int
shutdown(int s, int how)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ad:	e8 f3 fe ff ff       	call   8023a5 <fd2sockid>
  8024b2:	85 c0                	test   %eax,%eax
  8024b4:	78 0f                	js     8024c5 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8024b6:	83 ec 08             	sub    $0x8,%esp
  8024b9:	ff 75 0c             	pushl  0xc(%ebp)
  8024bc:	50                   	push   %eax
  8024bd:	e8 3f 01 00 00       	call   802601 <nsipc_shutdown>
  8024c2:	83 c4 10             	add    $0x10,%esp
}
  8024c5:	c9                   	leave  
  8024c6:	c3                   	ret    

008024c7 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8024c7:	55                   	push   %ebp
  8024c8:	89 e5                	mov    %esp,%ebp
  8024ca:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d0:	e8 d0 fe ff ff       	call   8023a5 <fd2sockid>
  8024d5:	85 c0                	test   %eax,%eax
  8024d7:	78 12                	js     8024eb <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8024d9:	83 ec 04             	sub    $0x4,%esp
  8024dc:	ff 75 10             	pushl  0x10(%ebp)
  8024df:	ff 75 0c             	pushl  0xc(%ebp)
  8024e2:	50                   	push   %eax
  8024e3:	e8 55 01 00 00       	call   80263d <nsipc_connect>
  8024e8:	83 c4 10             	add    $0x10,%esp
}
  8024eb:	c9                   	leave  
  8024ec:	c3                   	ret    

008024ed <listen>:

int
listen(int s, int backlog)
{
  8024ed:	55                   	push   %ebp
  8024ee:	89 e5                	mov    %esp,%ebp
  8024f0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8024f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f6:	e8 aa fe ff ff       	call   8023a5 <fd2sockid>
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	78 0f                	js     80250e <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8024ff:	83 ec 08             	sub    $0x8,%esp
  802502:	ff 75 0c             	pushl  0xc(%ebp)
  802505:	50                   	push   %eax
  802506:	e8 67 01 00 00       	call   802672 <nsipc_listen>
  80250b:	83 c4 10             	add    $0x10,%esp
}
  80250e:	c9                   	leave  
  80250f:	c3                   	ret    

00802510 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802516:	ff 75 10             	pushl  0x10(%ebp)
  802519:	ff 75 0c             	pushl  0xc(%ebp)
  80251c:	ff 75 08             	pushl  0x8(%ebp)
  80251f:	e8 3a 02 00 00       	call   80275e <nsipc_socket>
  802524:	83 c4 10             	add    $0x10,%esp
  802527:	85 c0                	test   %eax,%eax
  802529:	78 05                	js     802530 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80252b:	e8 a5 fe ff ff       	call   8023d5 <alloc_sockfd>
}
  802530:	c9                   	leave  
  802531:	c3                   	ret    

00802532 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802532:	55                   	push   %ebp
  802533:	89 e5                	mov    %esp,%ebp
  802535:	53                   	push   %ebx
  802536:	83 ec 04             	sub    $0x4,%esp
  802539:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80253b:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802542:	75 12                	jne    802556 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802544:	83 ec 0c             	sub    $0xc,%esp
  802547:	6a 02                	push   $0x2
  802549:	e8 18 05 00 00       	call   802a66 <ipc_find_env>
  80254e:	a3 04 50 80 00       	mov    %eax,0x805004
  802553:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802556:	6a 07                	push   $0x7
  802558:	68 00 70 80 00       	push   $0x807000
  80255d:	53                   	push   %ebx
  80255e:	ff 35 04 50 80 00    	pushl  0x805004
  802564:	e8 ae 04 00 00       	call   802a17 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802569:	83 c4 0c             	add    $0xc,%esp
  80256c:	6a 00                	push   $0x0
  80256e:	6a 00                	push   $0x0
  802570:	6a 00                	push   $0x0
  802572:	e8 2a 04 00 00       	call   8029a1 <ipc_recv>
}
  802577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80257a:	c9                   	leave  
  80257b:	c3                   	ret    

0080257c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80257c:	55                   	push   %ebp
  80257d:	89 e5                	mov    %esp,%ebp
  80257f:	56                   	push   %esi
  802580:	53                   	push   %ebx
  802581:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802584:	8b 45 08             	mov    0x8(%ebp),%eax
  802587:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80258c:	8b 06                	mov    (%esi),%eax
  80258e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802593:	b8 01 00 00 00       	mov    $0x1,%eax
  802598:	e8 95 ff ff ff       	call   802532 <nsipc>
  80259d:	89 c3                	mov    %eax,%ebx
  80259f:	85 c0                	test   %eax,%eax
  8025a1:	78 20                	js     8025c3 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8025a3:	83 ec 04             	sub    $0x4,%esp
  8025a6:	ff 35 10 70 80 00    	pushl  0x807010
  8025ac:	68 00 70 80 00       	push   $0x807000
  8025b1:	ff 75 0c             	pushl  0xc(%ebp)
  8025b4:	e8 2f e4 ff ff       	call   8009e8 <memmove>
		*addrlen = ret->ret_addrlen;
  8025b9:	a1 10 70 80 00       	mov    0x807010,%eax
  8025be:	89 06                	mov    %eax,(%esi)
  8025c0:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8025c3:	89 d8                	mov    %ebx,%eax
  8025c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025c8:	5b                   	pop    %ebx
  8025c9:	5e                   	pop    %esi
  8025ca:	5d                   	pop    %ebp
  8025cb:	c3                   	ret    

008025cc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8025cc:	55                   	push   %ebp
  8025cd:	89 e5                	mov    %esp,%ebp
  8025cf:	53                   	push   %ebx
  8025d0:	83 ec 08             	sub    $0x8,%esp
  8025d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8025d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d9:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8025de:	53                   	push   %ebx
  8025df:	ff 75 0c             	pushl  0xc(%ebp)
  8025e2:	68 04 70 80 00       	push   $0x807004
  8025e7:	e8 fc e3 ff ff       	call   8009e8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8025ec:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8025f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8025f7:	e8 36 ff ff ff       	call   802532 <nsipc>
}
  8025fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025ff:	c9                   	leave  
  802600:	c3                   	ret    

00802601 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802601:	55                   	push   %ebp
  802602:	89 e5                	mov    %esp,%ebp
  802604:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802607:	8b 45 08             	mov    0x8(%ebp),%eax
  80260a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80260f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802612:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802617:	b8 03 00 00 00       	mov    $0x3,%eax
  80261c:	e8 11 ff ff ff       	call   802532 <nsipc>
}
  802621:	c9                   	leave  
  802622:	c3                   	ret    

00802623 <nsipc_close>:

int
nsipc_close(int s)
{
  802623:	55                   	push   %ebp
  802624:	89 e5                	mov    %esp,%ebp
  802626:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802629:	8b 45 08             	mov    0x8(%ebp),%eax
  80262c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802631:	b8 04 00 00 00       	mov    $0x4,%eax
  802636:	e8 f7 fe ff ff       	call   802532 <nsipc>
}
  80263b:	c9                   	leave  
  80263c:	c3                   	ret    

0080263d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80263d:	55                   	push   %ebp
  80263e:	89 e5                	mov    %esp,%ebp
  802640:	53                   	push   %ebx
  802641:	83 ec 08             	sub    $0x8,%esp
  802644:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802647:	8b 45 08             	mov    0x8(%ebp),%eax
  80264a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80264f:	53                   	push   %ebx
  802650:	ff 75 0c             	pushl  0xc(%ebp)
  802653:	68 04 70 80 00       	push   $0x807004
  802658:	e8 8b e3 ff ff       	call   8009e8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80265d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802663:	b8 05 00 00 00       	mov    $0x5,%eax
  802668:	e8 c5 fe ff ff       	call   802532 <nsipc>
}
  80266d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802670:	c9                   	leave  
  802671:	c3                   	ret    

00802672 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802672:	55                   	push   %ebp
  802673:	89 e5                	mov    %esp,%ebp
  802675:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802678:	8b 45 08             	mov    0x8(%ebp),%eax
  80267b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802680:	8b 45 0c             	mov    0xc(%ebp),%eax
  802683:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802688:	b8 06 00 00 00       	mov    $0x6,%eax
  80268d:	e8 a0 fe ff ff       	call   802532 <nsipc>
}
  802692:	c9                   	leave  
  802693:	c3                   	ret    

00802694 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802694:	55                   	push   %ebp
  802695:	89 e5                	mov    %esp,%ebp
  802697:	56                   	push   %esi
  802698:	53                   	push   %ebx
  802699:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80269c:	8b 45 08             	mov    0x8(%ebp),%eax
  80269f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8026a4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8026aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8026ad:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8026b2:	b8 07 00 00 00       	mov    $0x7,%eax
  8026b7:	e8 76 fe ff ff       	call   802532 <nsipc>
  8026bc:	89 c3                	mov    %eax,%ebx
  8026be:	85 c0                	test   %eax,%eax
  8026c0:	78 35                	js     8026f7 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8026c2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8026c7:	7f 04                	jg     8026cd <nsipc_recv+0x39>
  8026c9:	39 c6                	cmp    %eax,%esi
  8026cb:	7d 16                	jge    8026e3 <nsipc_recv+0x4f>
  8026cd:	68 f9 33 80 00       	push   $0x8033f9
  8026d2:	68 d7 32 80 00       	push   $0x8032d7
  8026d7:	6a 62                	push   $0x62
  8026d9:	68 0e 34 80 00       	push   $0x80340e
  8026de:	e8 f5 da ff ff       	call   8001d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8026e3:	83 ec 04             	sub    $0x4,%esp
  8026e6:	50                   	push   %eax
  8026e7:	68 00 70 80 00       	push   $0x807000
  8026ec:	ff 75 0c             	pushl  0xc(%ebp)
  8026ef:	e8 f4 e2 ff ff       	call   8009e8 <memmove>
  8026f4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8026f7:	89 d8                	mov    %ebx,%eax
  8026f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026fc:	5b                   	pop    %ebx
  8026fd:	5e                   	pop    %esi
  8026fe:	5d                   	pop    %ebp
  8026ff:	c3                   	ret    

00802700 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802700:	55                   	push   %ebp
  802701:	89 e5                	mov    %esp,%ebp
  802703:	53                   	push   %ebx
  802704:	83 ec 04             	sub    $0x4,%esp
  802707:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80270a:	8b 45 08             	mov    0x8(%ebp),%eax
  80270d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802712:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802718:	7e 16                	jle    802730 <nsipc_send+0x30>
  80271a:	68 1a 34 80 00       	push   $0x80341a
  80271f:	68 d7 32 80 00       	push   $0x8032d7
  802724:	6a 6d                	push   $0x6d
  802726:	68 0e 34 80 00       	push   $0x80340e
  80272b:	e8 a8 da ff ff       	call   8001d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802730:	83 ec 04             	sub    $0x4,%esp
  802733:	53                   	push   %ebx
  802734:	ff 75 0c             	pushl  0xc(%ebp)
  802737:	68 0c 70 80 00       	push   $0x80700c
  80273c:	e8 a7 e2 ff ff       	call   8009e8 <memmove>
	nsipcbuf.send.req_size = size;
  802741:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802747:	8b 45 14             	mov    0x14(%ebp),%eax
  80274a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  80274f:	b8 08 00 00 00       	mov    $0x8,%eax
  802754:	e8 d9 fd ff ff       	call   802532 <nsipc>
}
  802759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80275c:	c9                   	leave  
  80275d:	c3                   	ret    

0080275e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80275e:	55                   	push   %ebp
  80275f:	89 e5                	mov    %esp,%ebp
  802761:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802764:	8b 45 08             	mov    0x8(%ebp),%eax
  802767:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80276c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80276f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802774:	8b 45 10             	mov    0x10(%ebp),%eax
  802777:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80277c:	b8 09 00 00 00       	mov    $0x9,%eax
  802781:	e8 ac fd ff ff       	call   802532 <nsipc>
}
  802786:	c9                   	leave  
  802787:	c3                   	ret    

00802788 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802788:	55                   	push   %ebp
  802789:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80278b:	b8 00 00 00 00       	mov    $0x0,%eax
  802790:	5d                   	pop    %ebp
  802791:	c3                   	ret    

00802792 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802792:	55                   	push   %ebp
  802793:	89 e5                	mov    %esp,%ebp
  802795:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802798:	68 26 34 80 00       	push   $0x803426
  80279d:	ff 75 0c             	pushl  0xc(%ebp)
  8027a0:	e8 b1 e0 ff ff       	call   800856 <strcpy>
	return 0;
}
  8027a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8027aa:	c9                   	leave  
  8027ab:	c3                   	ret    

008027ac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027ac:	55                   	push   %ebp
  8027ad:	89 e5                	mov    %esp,%ebp
  8027af:	57                   	push   %edi
  8027b0:	56                   	push   %esi
  8027b1:	53                   	push   %ebx
  8027b2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027b8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027bd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027c3:	eb 2d                	jmp    8027f2 <devcons_write+0x46>
		m = n - tot;
  8027c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027c8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8027ca:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8027cd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8027d2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027d5:	83 ec 04             	sub    $0x4,%esp
  8027d8:	53                   	push   %ebx
  8027d9:	03 45 0c             	add    0xc(%ebp),%eax
  8027dc:	50                   	push   %eax
  8027dd:	57                   	push   %edi
  8027de:	e8 05 e2 ff ff       	call   8009e8 <memmove>
		sys_cputs(buf, m);
  8027e3:	83 c4 08             	add    $0x8,%esp
  8027e6:	53                   	push   %ebx
  8027e7:	57                   	push   %edi
  8027e8:	e8 b0 e3 ff ff       	call   800b9d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027ed:	01 de                	add    %ebx,%esi
  8027ef:	83 c4 10             	add    $0x10,%esp
  8027f2:	89 f0                	mov    %esi,%eax
  8027f4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8027f7:	72 cc                	jb     8027c5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027fc:	5b                   	pop    %ebx
  8027fd:	5e                   	pop    %esi
  8027fe:	5f                   	pop    %edi
  8027ff:	5d                   	pop    %ebp
  802800:	c3                   	ret    

00802801 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802801:	55                   	push   %ebp
  802802:	89 e5                	mov    %esp,%ebp
  802804:	83 ec 08             	sub    $0x8,%esp
  802807:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80280c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802810:	74 2a                	je     80283c <devcons_read+0x3b>
  802812:	eb 05                	jmp    802819 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802814:	e8 21 e4 ff ff       	call   800c3a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802819:	e8 9d e3 ff ff       	call   800bbb <sys_cgetc>
  80281e:	85 c0                	test   %eax,%eax
  802820:	74 f2                	je     802814 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802822:	85 c0                	test   %eax,%eax
  802824:	78 16                	js     80283c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802826:	83 f8 04             	cmp    $0x4,%eax
  802829:	74 0c                	je     802837 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80282b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80282e:	88 02                	mov    %al,(%edx)
	return 1;
  802830:	b8 01 00 00 00       	mov    $0x1,%eax
  802835:	eb 05                	jmp    80283c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802837:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80283c:	c9                   	leave  
  80283d:	c3                   	ret    

0080283e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80283e:	55                   	push   %ebp
  80283f:	89 e5                	mov    %esp,%ebp
  802841:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802844:	8b 45 08             	mov    0x8(%ebp),%eax
  802847:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80284a:	6a 01                	push   $0x1
  80284c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80284f:	50                   	push   %eax
  802850:	e8 48 e3 ff ff       	call   800b9d <sys_cputs>
}
  802855:	83 c4 10             	add    $0x10,%esp
  802858:	c9                   	leave  
  802859:	c3                   	ret    

0080285a <getchar>:

int
getchar(void)
{
  80285a:	55                   	push   %ebp
  80285b:	89 e5                	mov    %esp,%ebp
  80285d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802860:	6a 01                	push   $0x1
  802862:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802865:	50                   	push   %eax
  802866:	6a 00                	push   $0x0
  802868:	e8 04 ec ff ff       	call   801471 <read>
	if (r < 0)
  80286d:	83 c4 10             	add    $0x10,%esp
  802870:	85 c0                	test   %eax,%eax
  802872:	78 0f                	js     802883 <getchar+0x29>
		return r;
	if (r < 1)
  802874:	85 c0                	test   %eax,%eax
  802876:	7e 06                	jle    80287e <getchar+0x24>
		return -E_EOF;
	return c;
  802878:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80287c:	eb 05                	jmp    802883 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80287e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802883:	c9                   	leave  
  802884:	c3                   	ret    

00802885 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802885:	55                   	push   %ebp
  802886:	89 e5                	mov    %esp,%ebp
  802888:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80288b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80288e:	50                   	push   %eax
  80288f:	ff 75 08             	pushl  0x8(%ebp)
  802892:	e8 74 e9 ff ff       	call   80120b <fd_lookup>
  802897:	83 c4 10             	add    $0x10,%esp
  80289a:	85 c0                	test   %eax,%eax
  80289c:	78 11                	js     8028af <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80289e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a1:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8028a7:	39 10                	cmp    %edx,(%eax)
  8028a9:	0f 94 c0             	sete   %al
  8028ac:	0f b6 c0             	movzbl %al,%eax
}
  8028af:	c9                   	leave  
  8028b0:	c3                   	ret    

008028b1 <opencons>:

int
opencons(void)
{
  8028b1:	55                   	push   %ebp
  8028b2:	89 e5                	mov    %esp,%ebp
  8028b4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028ba:	50                   	push   %eax
  8028bb:	e8 fc e8 ff ff       	call   8011bc <fd_alloc>
  8028c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8028c3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028c5:	85 c0                	test   %eax,%eax
  8028c7:	78 3e                	js     802907 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028c9:	83 ec 04             	sub    $0x4,%esp
  8028cc:	68 07 04 00 00       	push   $0x407
  8028d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8028d4:	6a 00                	push   $0x0
  8028d6:	e8 7e e3 ff ff       	call   800c59 <sys_page_alloc>
  8028db:	83 c4 10             	add    $0x10,%esp
		return r;
  8028de:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028e0:	85 c0                	test   %eax,%eax
  8028e2:	78 23                	js     802907 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028e4:	8b 15 60 40 80 00    	mov    0x804060,%edx
  8028ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028f2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028f9:	83 ec 0c             	sub    $0xc,%esp
  8028fc:	50                   	push   %eax
  8028fd:	e8 93 e8 ff ff       	call   801195 <fd2num>
  802902:	89 c2                	mov    %eax,%edx
  802904:	83 c4 10             	add    $0x10,%esp
}
  802907:	89 d0                	mov    %edx,%eax
  802909:	c9                   	leave  
  80290a:	c3                   	ret    

0080290b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80290b:	55                   	push   %ebp
  80290c:	89 e5                	mov    %esp,%ebp
  80290e:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802911:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802918:	75 56                	jne    802970 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80291a:	83 ec 04             	sub    $0x4,%esp
  80291d:	6a 07                	push   $0x7
  80291f:	68 00 f0 bf ee       	push   $0xeebff000
  802924:	6a 00                	push   $0x0
  802926:	e8 2e e3 ff ff       	call   800c59 <sys_page_alloc>
  80292b:	83 c4 10             	add    $0x10,%esp
  80292e:	85 c0                	test   %eax,%eax
  802930:	74 14                	je     802946 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  802932:	83 ec 04             	sub    $0x4,%esp
  802935:	68 e9 31 80 00       	push   $0x8031e9
  80293a:	6a 21                	push   $0x21
  80293c:	68 32 34 80 00       	push   $0x803432
  802941:	e8 92 d8 ff ff       	call   8001d8 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  802946:	83 ec 08             	sub    $0x8,%esp
  802949:	68 7a 29 80 00       	push   $0x80297a
  80294e:	6a 00                	push   $0x0
  802950:	e8 4f e4 ff ff       	call   800da4 <sys_env_set_pgfault_upcall>
  802955:	83 c4 10             	add    $0x10,%esp
  802958:	85 c0                	test   %eax,%eax
  80295a:	74 14                	je     802970 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  80295c:	83 ec 04             	sub    $0x4,%esp
  80295f:	68 40 34 80 00       	push   $0x803440
  802964:	6a 23                	push   $0x23
  802966:	68 32 34 80 00       	push   $0x803432
  80296b:	e8 68 d8 ff ff       	call   8001d8 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802970:	8b 45 08             	mov    0x8(%ebp),%eax
  802973:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802978:	c9                   	leave  
  802979:	c3                   	ret    

0080297a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80297a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80297b:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802980:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802982:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  802985:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  802987:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  80298b:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  80298f:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  802990:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  802992:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  802997:	83 c4 08             	add    $0x8,%esp
	popal
  80299a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80299b:	83 c4 04             	add    $0x4,%esp
	popfl
  80299e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80299f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8029a0:	c3                   	ret    

008029a1 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8029a1:	55                   	push   %ebp
  8029a2:	89 e5                	mov    %esp,%ebp
  8029a4:	56                   	push   %esi
  8029a5:	53                   	push   %ebx
  8029a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8029a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8029af:	85 c0                	test   %eax,%eax
  8029b1:	74 0e                	je     8029c1 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8029b3:	83 ec 0c             	sub    $0xc,%esp
  8029b6:	50                   	push   %eax
  8029b7:	e8 4d e4 ff ff       	call   800e09 <sys_ipc_recv>
  8029bc:	83 c4 10             	add    $0x10,%esp
  8029bf:	eb 10                	jmp    8029d1 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8029c1:	83 ec 0c             	sub    $0xc,%esp
  8029c4:	68 00 00 c0 ee       	push   $0xeec00000
  8029c9:	e8 3b e4 ff ff       	call   800e09 <sys_ipc_recv>
  8029ce:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8029d1:	85 c0                	test   %eax,%eax
  8029d3:	79 17                	jns    8029ec <ipc_recv+0x4b>
		if(*from_env_store)
  8029d5:	83 3e 00             	cmpl   $0x0,(%esi)
  8029d8:	74 06                	je     8029e0 <ipc_recv+0x3f>
			*from_env_store = 0;
  8029da:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8029e0:	85 db                	test   %ebx,%ebx
  8029e2:	74 2c                	je     802a10 <ipc_recv+0x6f>
			*perm_store = 0;
  8029e4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8029ea:	eb 24                	jmp    802a10 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8029ec:	85 f6                	test   %esi,%esi
  8029ee:	74 0a                	je     8029fa <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8029f0:	a1 08 50 80 00       	mov    0x805008,%eax
  8029f5:	8b 40 74             	mov    0x74(%eax),%eax
  8029f8:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8029fa:	85 db                	test   %ebx,%ebx
  8029fc:	74 0a                	je     802a08 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8029fe:	a1 08 50 80 00       	mov    0x805008,%eax
  802a03:	8b 40 78             	mov    0x78(%eax),%eax
  802a06:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802a08:	a1 08 50 80 00       	mov    0x805008,%eax
  802a0d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802a10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a13:	5b                   	pop    %ebx
  802a14:	5e                   	pop    %esi
  802a15:	5d                   	pop    %ebp
  802a16:	c3                   	ret    

00802a17 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802a17:	55                   	push   %ebp
  802a18:	89 e5                	mov    %esp,%ebp
  802a1a:	57                   	push   %edi
  802a1b:	56                   	push   %esi
  802a1c:	53                   	push   %ebx
  802a1d:	83 ec 0c             	sub    $0xc,%esp
  802a20:	8b 7d 08             	mov    0x8(%ebp),%edi
  802a23:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802a29:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802a2b:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802a30:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802a33:	e8 02 e2 ff ff       	call   800c3a <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802a38:	ff 75 14             	pushl  0x14(%ebp)
  802a3b:	53                   	push   %ebx
  802a3c:	56                   	push   %esi
  802a3d:	57                   	push   %edi
  802a3e:	e8 a3 e3 ff ff       	call   800de6 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802a43:	89 c2                	mov    %eax,%edx
  802a45:	f7 d2                	not    %edx
  802a47:	c1 ea 1f             	shr    $0x1f,%edx
  802a4a:	83 c4 10             	add    $0x10,%esp
  802a4d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802a50:	0f 94 c1             	sete   %cl
  802a53:	09 ca                	or     %ecx,%edx
  802a55:	85 c0                	test   %eax,%eax
  802a57:	0f 94 c0             	sete   %al
  802a5a:	38 c2                	cmp    %al,%dl
  802a5c:	77 d5                	ja     802a33 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a61:	5b                   	pop    %ebx
  802a62:	5e                   	pop    %esi
  802a63:	5f                   	pop    %edi
  802a64:	5d                   	pop    %ebp
  802a65:	c3                   	ret    

00802a66 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802a66:	55                   	push   %ebp
  802a67:	89 e5                	mov    %esp,%ebp
  802a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802a6c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802a71:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802a74:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802a7a:	8b 52 50             	mov    0x50(%edx),%edx
  802a7d:	39 ca                	cmp    %ecx,%edx
  802a7f:	75 0d                	jne    802a8e <ipc_find_env+0x28>
			return envs[i].env_id;
  802a81:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a84:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a89:	8b 40 48             	mov    0x48(%eax),%eax
  802a8c:	eb 0f                	jmp    802a9d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802a8e:	83 c0 01             	add    $0x1,%eax
  802a91:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a96:	75 d9                	jne    802a71 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802a98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a9d:	5d                   	pop    %ebp
  802a9e:	c3                   	ret    

00802a9f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a9f:	55                   	push   %ebp
  802aa0:	89 e5                	mov    %esp,%ebp
  802aa2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802aa5:	89 d0                	mov    %edx,%eax
  802aa7:	c1 e8 16             	shr    $0x16,%eax
  802aaa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802ab1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ab6:	f6 c1 01             	test   $0x1,%cl
  802ab9:	74 1d                	je     802ad8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802abb:	c1 ea 0c             	shr    $0xc,%edx
  802abe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802ac5:	f6 c2 01             	test   $0x1,%dl
  802ac8:	74 0e                	je     802ad8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802aca:	c1 ea 0c             	shr    $0xc,%edx
  802acd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802ad4:	ef 
  802ad5:	0f b7 c0             	movzwl %ax,%eax
}
  802ad8:	5d                   	pop    %ebp
  802ad9:	c3                   	ret    
  802ada:	66 90                	xchg   %ax,%ax
  802adc:	66 90                	xchg   %ax,%ax
  802ade:	66 90                	xchg   %ax,%ax

00802ae0 <__udivdi3>:
  802ae0:	55                   	push   %ebp
  802ae1:	57                   	push   %edi
  802ae2:	56                   	push   %esi
  802ae3:	53                   	push   %ebx
  802ae4:	83 ec 1c             	sub    $0x1c,%esp
  802ae7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802aeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802aef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802af3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802af7:	85 f6                	test   %esi,%esi
  802af9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802afd:	89 ca                	mov    %ecx,%edx
  802aff:	89 f8                	mov    %edi,%eax
  802b01:	75 3d                	jne    802b40 <__udivdi3+0x60>
  802b03:	39 cf                	cmp    %ecx,%edi
  802b05:	0f 87 c5 00 00 00    	ja     802bd0 <__udivdi3+0xf0>
  802b0b:	85 ff                	test   %edi,%edi
  802b0d:	89 fd                	mov    %edi,%ebp
  802b0f:	75 0b                	jne    802b1c <__udivdi3+0x3c>
  802b11:	b8 01 00 00 00       	mov    $0x1,%eax
  802b16:	31 d2                	xor    %edx,%edx
  802b18:	f7 f7                	div    %edi
  802b1a:	89 c5                	mov    %eax,%ebp
  802b1c:	89 c8                	mov    %ecx,%eax
  802b1e:	31 d2                	xor    %edx,%edx
  802b20:	f7 f5                	div    %ebp
  802b22:	89 c1                	mov    %eax,%ecx
  802b24:	89 d8                	mov    %ebx,%eax
  802b26:	89 cf                	mov    %ecx,%edi
  802b28:	f7 f5                	div    %ebp
  802b2a:	89 c3                	mov    %eax,%ebx
  802b2c:	89 d8                	mov    %ebx,%eax
  802b2e:	89 fa                	mov    %edi,%edx
  802b30:	83 c4 1c             	add    $0x1c,%esp
  802b33:	5b                   	pop    %ebx
  802b34:	5e                   	pop    %esi
  802b35:	5f                   	pop    %edi
  802b36:	5d                   	pop    %ebp
  802b37:	c3                   	ret    
  802b38:	90                   	nop
  802b39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b40:	39 ce                	cmp    %ecx,%esi
  802b42:	77 74                	ja     802bb8 <__udivdi3+0xd8>
  802b44:	0f bd fe             	bsr    %esi,%edi
  802b47:	83 f7 1f             	xor    $0x1f,%edi
  802b4a:	0f 84 98 00 00 00    	je     802be8 <__udivdi3+0x108>
  802b50:	bb 20 00 00 00       	mov    $0x20,%ebx
  802b55:	89 f9                	mov    %edi,%ecx
  802b57:	89 c5                	mov    %eax,%ebp
  802b59:	29 fb                	sub    %edi,%ebx
  802b5b:	d3 e6                	shl    %cl,%esi
  802b5d:	89 d9                	mov    %ebx,%ecx
  802b5f:	d3 ed                	shr    %cl,%ebp
  802b61:	89 f9                	mov    %edi,%ecx
  802b63:	d3 e0                	shl    %cl,%eax
  802b65:	09 ee                	or     %ebp,%esi
  802b67:	89 d9                	mov    %ebx,%ecx
  802b69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b6d:	89 d5                	mov    %edx,%ebp
  802b6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b73:	d3 ed                	shr    %cl,%ebp
  802b75:	89 f9                	mov    %edi,%ecx
  802b77:	d3 e2                	shl    %cl,%edx
  802b79:	89 d9                	mov    %ebx,%ecx
  802b7b:	d3 e8                	shr    %cl,%eax
  802b7d:	09 c2                	or     %eax,%edx
  802b7f:	89 d0                	mov    %edx,%eax
  802b81:	89 ea                	mov    %ebp,%edx
  802b83:	f7 f6                	div    %esi
  802b85:	89 d5                	mov    %edx,%ebp
  802b87:	89 c3                	mov    %eax,%ebx
  802b89:	f7 64 24 0c          	mull   0xc(%esp)
  802b8d:	39 d5                	cmp    %edx,%ebp
  802b8f:	72 10                	jb     802ba1 <__udivdi3+0xc1>
  802b91:	8b 74 24 08          	mov    0x8(%esp),%esi
  802b95:	89 f9                	mov    %edi,%ecx
  802b97:	d3 e6                	shl    %cl,%esi
  802b99:	39 c6                	cmp    %eax,%esi
  802b9b:	73 07                	jae    802ba4 <__udivdi3+0xc4>
  802b9d:	39 d5                	cmp    %edx,%ebp
  802b9f:	75 03                	jne    802ba4 <__udivdi3+0xc4>
  802ba1:	83 eb 01             	sub    $0x1,%ebx
  802ba4:	31 ff                	xor    %edi,%edi
  802ba6:	89 d8                	mov    %ebx,%eax
  802ba8:	89 fa                	mov    %edi,%edx
  802baa:	83 c4 1c             	add    $0x1c,%esp
  802bad:	5b                   	pop    %ebx
  802bae:	5e                   	pop    %esi
  802baf:	5f                   	pop    %edi
  802bb0:	5d                   	pop    %ebp
  802bb1:	c3                   	ret    
  802bb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bb8:	31 ff                	xor    %edi,%edi
  802bba:	31 db                	xor    %ebx,%ebx
  802bbc:	89 d8                	mov    %ebx,%eax
  802bbe:	89 fa                	mov    %edi,%edx
  802bc0:	83 c4 1c             	add    $0x1c,%esp
  802bc3:	5b                   	pop    %ebx
  802bc4:	5e                   	pop    %esi
  802bc5:	5f                   	pop    %edi
  802bc6:	5d                   	pop    %ebp
  802bc7:	c3                   	ret    
  802bc8:	90                   	nop
  802bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bd0:	89 d8                	mov    %ebx,%eax
  802bd2:	f7 f7                	div    %edi
  802bd4:	31 ff                	xor    %edi,%edi
  802bd6:	89 c3                	mov    %eax,%ebx
  802bd8:	89 d8                	mov    %ebx,%eax
  802bda:	89 fa                	mov    %edi,%edx
  802bdc:	83 c4 1c             	add    $0x1c,%esp
  802bdf:	5b                   	pop    %ebx
  802be0:	5e                   	pop    %esi
  802be1:	5f                   	pop    %edi
  802be2:	5d                   	pop    %ebp
  802be3:	c3                   	ret    
  802be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802be8:	39 ce                	cmp    %ecx,%esi
  802bea:	72 0c                	jb     802bf8 <__udivdi3+0x118>
  802bec:	31 db                	xor    %ebx,%ebx
  802bee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802bf2:	0f 87 34 ff ff ff    	ja     802b2c <__udivdi3+0x4c>
  802bf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  802bfd:	e9 2a ff ff ff       	jmp    802b2c <__udivdi3+0x4c>
  802c02:	66 90                	xchg   %ax,%ax
  802c04:	66 90                	xchg   %ax,%ax
  802c06:	66 90                	xchg   %ax,%ax
  802c08:	66 90                	xchg   %ax,%ax
  802c0a:	66 90                	xchg   %ax,%ax
  802c0c:	66 90                	xchg   %ax,%ax
  802c0e:	66 90                	xchg   %ax,%ax

00802c10 <__umoddi3>:
  802c10:	55                   	push   %ebp
  802c11:	57                   	push   %edi
  802c12:	56                   	push   %esi
  802c13:	53                   	push   %ebx
  802c14:	83 ec 1c             	sub    $0x1c,%esp
  802c17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802c1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802c1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802c27:	85 d2                	test   %edx,%edx
  802c29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c31:	89 f3                	mov    %esi,%ebx
  802c33:	89 3c 24             	mov    %edi,(%esp)
  802c36:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c3a:	75 1c                	jne    802c58 <__umoddi3+0x48>
  802c3c:	39 f7                	cmp    %esi,%edi
  802c3e:	76 50                	jbe    802c90 <__umoddi3+0x80>
  802c40:	89 c8                	mov    %ecx,%eax
  802c42:	89 f2                	mov    %esi,%edx
  802c44:	f7 f7                	div    %edi
  802c46:	89 d0                	mov    %edx,%eax
  802c48:	31 d2                	xor    %edx,%edx
  802c4a:	83 c4 1c             	add    $0x1c,%esp
  802c4d:	5b                   	pop    %ebx
  802c4e:	5e                   	pop    %esi
  802c4f:	5f                   	pop    %edi
  802c50:	5d                   	pop    %ebp
  802c51:	c3                   	ret    
  802c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c58:	39 f2                	cmp    %esi,%edx
  802c5a:	89 d0                	mov    %edx,%eax
  802c5c:	77 52                	ja     802cb0 <__umoddi3+0xa0>
  802c5e:	0f bd ea             	bsr    %edx,%ebp
  802c61:	83 f5 1f             	xor    $0x1f,%ebp
  802c64:	75 5a                	jne    802cc0 <__umoddi3+0xb0>
  802c66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802c6a:	0f 82 e0 00 00 00    	jb     802d50 <__umoddi3+0x140>
  802c70:	39 0c 24             	cmp    %ecx,(%esp)
  802c73:	0f 86 d7 00 00 00    	jbe    802d50 <__umoddi3+0x140>
  802c79:	8b 44 24 08          	mov    0x8(%esp),%eax
  802c7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c81:	83 c4 1c             	add    $0x1c,%esp
  802c84:	5b                   	pop    %ebx
  802c85:	5e                   	pop    %esi
  802c86:	5f                   	pop    %edi
  802c87:	5d                   	pop    %ebp
  802c88:	c3                   	ret    
  802c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c90:	85 ff                	test   %edi,%edi
  802c92:	89 fd                	mov    %edi,%ebp
  802c94:	75 0b                	jne    802ca1 <__umoddi3+0x91>
  802c96:	b8 01 00 00 00       	mov    $0x1,%eax
  802c9b:	31 d2                	xor    %edx,%edx
  802c9d:	f7 f7                	div    %edi
  802c9f:	89 c5                	mov    %eax,%ebp
  802ca1:	89 f0                	mov    %esi,%eax
  802ca3:	31 d2                	xor    %edx,%edx
  802ca5:	f7 f5                	div    %ebp
  802ca7:	89 c8                	mov    %ecx,%eax
  802ca9:	f7 f5                	div    %ebp
  802cab:	89 d0                	mov    %edx,%eax
  802cad:	eb 99                	jmp    802c48 <__umoddi3+0x38>
  802caf:	90                   	nop
  802cb0:	89 c8                	mov    %ecx,%eax
  802cb2:	89 f2                	mov    %esi,%edx
  802cb4:	83 c4 1c             	add    $0x1c,%esp
  802cb7:	5b                   	pop    %ebx
  802cb8:	5e                   	pop    %esi
  802cb9:	5f                   	pop    %edi
  802cba:	5d                   	pop    %ebp
  802cbb:	c3                   	ret    
  802cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802cc0:	8b 34 24             	mov    (%esp),%esi
  802cc3:	bf 20 00 00 00       	mov    $0x20,%edi
  802cc8:	89 e9                	mov    %ebp,%ecx
  802cca:	29 ef                	sub    %ebp,%edi
  802ccc:	d3 e0                	shl    %cl,%eax
  802cce:	89 f9                	mov    %edi,%ecx
  802cd0:	89 f2                	mov    %esi,%edx
  802cd2:	d3 ea                	shr    %cl,%edx
  802cd4:	89 e9                	mov    %ebp,%ecx
  802cd6:	09 c2                	or     %eax,%edx
  802cd8:	89 d8                	mov    %ebx,%eax
  802cda:	89 14 24             	mov    %edx,(%esp)
  802cdd:	89 f2                	mov    %esi,%edx
  802cdf:	d3 e2                	shl    %cl,%edx
  802ce1:	89 f9                	mov    %edi,%ecx
  802ce3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ce7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802ceb:	d3 e8                	shr    %cl,%eax
  802ced:	89 e9                	mov    %ebp,%ecx
  802cef:	89 c6                	mov    %eax,%esi
  802cf1:	d3 e3                	shl    %cl,%ebx
  802cf3:	89 f9                	mov    %edi,%ecx
  802cf5:	89 d0                	mov    %edx,%eax
  802cf7:	d3 e8                	shr    %cl,%eax
  802cf9:	89 e9                	mov    %ebp,%ecx
  802cfb:	09 d8                	or     %ebx,%eax
  802cfd:	89 d3                	mov    %edx,%ebx
  802cff:	89 f2                	mov    %esi,%edx
  802d01:	f7 34 24             	divl   (%esp)
  802d04:	89 d6                	mov    %edx,%esi
  802d06:	d3 e3                	shl    %cl,%ebx
  802d08:	f7 64 24 04          	mull   0x4(%esp)
  802d0c:	39 d6                	cmp    %edx,%esi
  802d0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d12:	89 d1                	mov    %edx,%ecx
  802d14:	89 c3                	mov    %eax,%ebx
  802d16:	72 08                	jb     802d20 <__umoddi3+0x110>
  802d18:	75 11                	jne    802d2b <__umoddi3+0x11b>
  802d1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802d1e:	73 0b                	jae    802d2b <__umoddi3+0x11b>
  802d20:	2b 44 24 04          	sub    0x4(%esp),%eax
  802d24:	1b 14 24             	sbb    (%esp),%edx
  802d27:	89 d1                	mov    %edx,%ecx
  802d29:	89 c3                	mov    %eax,%ebx
  802d2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802d2f:	29 da                	sub    %ebx,%edx
  802d31:	19 ce                	sbb    %ecx,%esi
  802d33:	89 f9                	mov    %edi,%ecx
  802d35:	89 f0                	mov    %esi,%eax
  802d37:	d3 e0                	shl    %cl,%eax
  802d39:	89 e9                	mov    %ebp,%ecx
  802d3b:	d3 ea                	shr    %cl,%edx
  802d3d:	89 e9                	mov    %ebp,%ecx
  802d3f:	d3 ee                	shr    %cl,%esi
  802d41:	09 d0                	or     %edx,%eax
  802d43:	89 f2                	mov    %esi,%edx
  802d45:	83 c4 1c             	add    $0x1c,%esp
  802d48:	5b                   	pop    %ebx
  802d49:	5e                   	pop    %esi
  802d4a:	5f                   	pop    %edi
  802d4b:	5d                   	pop    %ebp
  802d4c:	c3                   	ret    
  802d4d:	8d 76 00             	lea    0x0(%esi),%esi
  802d50:	29 f9                	sub    %edi,%ecx
  802d52:	19 d6                	sbb    %edx,%esi
  802d54:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d5c:	e9 18 ff ff ff       	jmp    802c79 <__umoddi3+0x69>
