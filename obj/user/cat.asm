
obj/user/cat.debug:     file format elf32-i386


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
  80002c:	e8 02 01 00 00       	call   800133 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003b:	eb 2f                	jmp    80006c <cat+0x39>
		if ((r = write(1, buf, n)) != n)
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	53                   	push   %ebx
  800041:	68 20 40 80 00       	push   $0x804020
  800046:	6a 01                	push   $0x1
  800048:	e8 8d 11 00 00       	call   8011da <write>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	39 c3                	cmp    %eax,%ebx
  800052:	74 18                	je     80006c <cat+0x39>
			panic("write error copying %s: %e", s, r);
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	50                   	push   %eax
  800058:	ff 75 0c             	pushl  0xc(%ebp)
  80005b:	68 60 24 80 00       	push   $0x802460
  800060:	6a 0d                	push   $0xd
  800062:	68 7b 24 80 00       	push   $0x80247b
  800067:	e8 27 01 00 00       	call   800193 <_panic>
cat(int f, char *s)
{
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80006c:	83 ec 04             	sub    $0x4,%esp
  80006f:	68 00 20 00 00       	push   $0x2000
  800074:	68 20 40 80 00       	push   $0x804020
  800079:	56                   	push   %esi
  80007a:	e8 81 10 00 00       	call   801100 <read>
  80007f:	89 c3                	mov    %eax,%ebx
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	85 c0                	test   %eax,%eax
  800086:	7f b5                	jg     80003d <cat+0xa>
		if ((r = write(1, buf, n)) != n)
			panic("write error copying %s: %e", s, r);
	if (n < 0)
  800088:	85 c0                	test   %eax,%eax
  80008a:	79 18                	jns    8000a4 <cat+0x71>
		panic("error reading %s: %e", s, n);
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	50                   	push   %eax
  800090:	ff 75 0c             	pushl  0xc(%ebp)
  800093:	68 86 24 80 00       	push   $0x802486
  800098:	6a 0f                	push   $0xf
  80009a:	68 7b 24 80 00       	push   $0x80247b
  80009f:	e8 ef 00 00 00       	call   800193 <_panic>
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000b7:	c7 05 00 30 80 00 9b 	movl   $0x80249b,0x803000
  8000be:	24 80 00 
  8000c1:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  8000c6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ca:	75 5a                	jne    800126 <umain+0x7b>
		cat(0, "<stdin>");
  8000cc:	83 ec 08             	sub    $0x8,%esp
  8000cf:	68 9f 24 80 00       	push   $0x80249f
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 58 ff ff ff       	call   800033 <cat>
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	eb 4b                	jmp    80012b <umain+0x80>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000e8:	e8 aa 14 00 00       	call   801597 <open>
  8000ed:	89 c6                	mov    %eax,%esi
			if (f < 0)
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	79 16                	jns    80010c <umain+0x61>
				printf("can't open %s: %e\n", argv[i], f);
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	50                   	push   %eax
  8000fa:	ff 34 9f             	pushl  (%edi,%ebx,4)
  8000fd:	68 a7 24 80 00       	push   $0x8024a7
  800102:	e8 2e 16 00 00       	call   801735 <printf>
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	eb 17                	jmp    800123 <umain+0x78>
			else {
				cat(f, argv[i]);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	ff 34 9f             	pushl  (%edi,%ebx,4)
  800112:	50                   	push   %eax
  800113:	e8 1b ff ff ff       	call   800033 <cat>
				close(f);
  800118:	89 34 24             	mov    %esi,(%esp)
  80011b:	e8 a4 0e 00 00       	call   800fc4 <close>
  800120:	83 c4 10             	add    $0x10,%esp

	binaryname = "cat";
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  800123:	83 c3 01             	add    $0x1,%ebx
  800126:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  800129:	7c b5                	jl     8000e0 <umain+0x35>
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  80012b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80013b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80013e:	e8 93 0a 00 00       	call   800bd6 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800143:	25 ff 03 00 00       	and    $0x3ff,%eax
  800148:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80014b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800150:	a3 20 60 80 00       	mov    %eax,0x806020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800155:	85 db                	test   %ebx,%ebx
  800157:	7e 07                	jle    800160 <libmain+0x2d>
		binaryname = argv[0];
  800159:	8b 06                	mov    (%esi),%eax
  80015b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	e8 41 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  80016a:	e8 0a 00 00 00       	call   800179 <exit>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80017f:	e8 6b 0e 00 00       	call   800fef <close_all>
	sys_env_destroy(0);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	6a 00                	push   $0x0
  800189:	e8 07 0a 00 00       	call   800b95 <sys_env_destroy>
}
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a1:	e8 30 0a 00 00       	call   800bd6 <sys_getenvid>
  8001a6:	83 ec 0c             	sub    $0xc,%esp
  8001a9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	56                   	push   %esi
  8001b0:	50                   	push   %eax
  8001b1:	68 c4 24 80 00       	push   $0x8024c4
  8001b6:	e8 b1 00 00 00       	call   80026c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	53                   	push   %ebx
  8001bf:	ff 75 10             	pushl  0x10(%ebp)
  8001c2:	e8 54 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001c7:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  8001ce:	e8 99 00 00 00       	call   80026c <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x43>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 1a                	jne    800212 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	68 ff 00 00 00       	push   $0xff
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	50                   	push   %eax
  800204:	e8 4f 09 00 00       	call   800b58 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80020f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800212:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	68 d9 01 80 00       	push   $0x8001d9
  80024a:	e8 54 01 00 00       	call   8003a3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 f4 08 00 00       	call   800b58 <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800272:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800275:	50                   	push   %eax
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 9d ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 1c             	sub    $0x1c,%esp
  800289:	89 c7                	mov    %eax,%edi
  80028b:	89 d6                	mov    %edx,%esi
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	8b 55 0c             	mov    0xc(%ebp),%edx
  800293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800296:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800299:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002a7:	39 d3                	cmp    %edx,%ebx
  8002a9:	72 05                	jb     8002b0 <printnum+0x30>
  8002ab:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ae:	77 45                	ja     8002f5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002b9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002bc:	53                   	push   %ebx
  8002bd:	ff 75 10             	pushl  0x10(%ebp)
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 fc 1e 00 00       	call   8021d0 <__udivdi3>
  8002d4:	83 c4 18             	add    $0x18,%esp
  8002d7:	52                   	push   %edx
  8002d8:	50                   	push   %eax
  8002d9:	89 f2                	mov    %esi,%edx
  8002db:	89 f8                	mov    %edi,%eax
  8002dd:	e8 9e ff ff ff       	call   800280 <printnum>
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 18                	jmp    8002ff <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	56                   	push   %esi
  8002eb:	ff 75 18             	pushl  0x18(%ebp)
  8002ee:	ff d7                	call   *%edi
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	eb 03                	jmp    8002f8 <printnum+0x78>
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f e8                	jg     8002e7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	pushl  -0x1c(%ebp)
  800309:	ff 75 e0             	pushl  -0x20(%ebp)
  80030c:	ff 75 dc             	pushl  -0x24(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	e8 e9 1f 00 00       	call   802300 <__umoddi3>
  800317:	83 c4 14             	add    $0x14,%esp
  80031a:	0f be 80 e7 24 80 00 	movsbl 0x8024e7(%eax),%eax
  800321:	50                   	push   %eax
  800322:	ff d7                	call   *%edi
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800332:	83 fa 01             	cmp    $0x1,%edx
  800335:	7e 0e                	jle    800345 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800337:	8b 10                	mov    (%eax),%edx
  800339:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033c:	89 08                	mov    %ecx,(%eax)
  80033e:	8b 02                	mov    (%edx),%eax
  800340:	8b 52 04             	mov    0x4(%edx),%edx
  800343:	eb 22                	jmp    800367 <getuint+0x38>
	else if (lflag)
  800345:	85 d2                	test   %edx,%edx
  800347:	74 10                	je     800359 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800349:	8b 10                	mov    (%eax),%edx
  80034b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034e:	89 08                	mov    %ecx,(%eax)
  800350:	8b 02                	mov    (%edx),%eax
  800352:	ba 00 00 00 00       	mov    $0x0,%edx
  800357:	eb 0e                	jmp    800367 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800373:	8b 10                	mov    (%eax),%edx
  800375:	3b 50 04             	cmp    0x4(%eax),%edx
  800378:	73 0a                	jae    800384 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037d:	89 08                	mov    %ecx,(%eax)
  80037f:	8b 45 08             	mov    0x8(%ebp),%eax
  800382:	88 02                	mov    %al,(%edx)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	50                   	push   %eax
  800390:	ff 75 10             	pushl  0x10(%ebp)
  800393:	ff 75 0c             	pushl  0xc(%ebp)
  800396:	ff 75 08             	pushl  0x8(%ebp)
  800399:	e8 05 00 00 00       	call   8003a3 <vprintfmt>
	va_end(ap);
}
  80039e:	83 c4 10             	add    $0x10,%esp
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
  8003ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8003af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	eb 12                	jmp    8003c9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b7:	85 c0                	test   %eax,%eax
  8003b9:	0f 84 a9 03 00 00    	je     800768 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	50                   	push   %eax
  8003c4:	ff d6                	call   *%esi
  8003c6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	83 c7 01             	add    $0x1,%edi
  8003cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003d0:	83 f8 25             	cmp    $0x25,%eax
  8003d3:	75 e2                	jne    8003b7 <vprintfmt+0x14>
  8003d5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003d9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	eb 07                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 47 01             	lea    0x1(%edi),%eax
  8003ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800402:	0f b6 07             	movzbl (%edi),%eax
  800405:	0f b6 c8             	movzbl %al,%ecx
  800408:	83 e8 23             	sub    $0x23,%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 3a 03 00 00    	ja     80074d <vprintfmt+0x3aa>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800420:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800424:	eb d6                	jmp    8003fc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	b8 00 00 00 00       	mov    $0x0,%eax
  80042e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800431:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800434:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800438:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80043b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80043e:	83 fa 09             	cmp    $0x9,%edx
  800441:	77 39                	ja     80047c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800443:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb e9                	jmp    800431 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 48 04             	lea    0x4(%eax),%ecx
  80044e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800451:	8b 00                	mov    (%eax),%eax
  800453:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800459:	eb 27                	jmp    800482 <vprintfmt+0xdf>
  80045b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045e:	85 c0                	test   %eax,%eax
  800460:	b9 00 00 00 00       	mov    $0x0,%ecx
  800465:	0f 49 c8             	cmovns %eax,%ecx
  800468:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046e:	eb 8c                	jmp    8003fc <vprintfmt+0x59>
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800473:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047a:	eb 80                	jmp    8003fc <vprintfmt+0x59>
  80047c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80047f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800482:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800486:	0f 89 70 ff ff ff    	jns    8003fc <vprintfmt+0x59>
				width = precision, precision = -1;
  80048c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800499:	e9 5e ff ff ff       	jmp    8003fc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004a4:	e9 53 ff ff ff       	jmp    8003fc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	ff 30                	pushl  (%eax)
  8004b8:	ff d6                	call   *%esi
			break;
  8004ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004c0:	e9 04 ff ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	99                   	cltd   
  8004d1:	31 d0                	xor    %edx,%eax
  8004d3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d5:	83 f8 0f             	cmp    $0xf,%eax
  8004d8:	7f 0b                	jg     8004e5 <vprintfmt+0x142>
  8004da:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	75 18                	jne    8004fd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	50                   	push   %eax
  8004e6:	68 ff 24 80 00       	push   $0x8024ff
  8004eb:	53                   	push   %ebx
  8004ec:	56                   	push   %esi
  8004ed:	e8 94 fe ff ff       	call   800386 <printfmt>
  8004f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004f8:	e9 cc fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004fd:	52                   	push   %edx
  8004fe:	68 b9 28 80 00       	push   $0x8028b9
  800503:	53                   	push   %ebx
  800504:	56                   	push   %esi
  800505:	e8 7c fe ff ff       	call   800386 <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800510:	e9 b4 fe ff ff       	jmp    8003c9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800520:	85 ff                	test   %edi,%edi
  800522:	b8 f8 24 80 00       	mov    $0x8024f8,%eax
  800527:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80052a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052e:	0f 8e 94 00 00 00    	jle    8005c8 <vprintfmt+0x225>
  800534:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800538:	0f 84 98 00 00 00    	je     8005d6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	ff 75 d0             	pushl  -0x30(%ebp)
  800544:	57                   	push   %edi
  800545:	e8 a6 02 00 00       	call   8007f0 <strnlen>
  80054a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800552:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800555:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800559:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	eb 0f                	jmp    800572 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 75 e0             	pushl  -0x20(%ebp)
  80056a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056c:	83 ef 01             	sub    $0x1,%edi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 ff                	test   %edi,%edi
  800574:	7f ed                	jg     800563 <vprintfmt+0x1c0>
  800576:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800579:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	b8 00 00 00 00       	mov    $0x0,%eax
  800583:	0f 49 c1             	cmovns %ecx,%eax
  800586:	29 c1                	sub    %eax,%ecx
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	89 cb                	mov    %ecx,%ebx
  800593:	eb 4d                	jmp    8005e2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	74 1b                	je     8005b6 <vprintfmt+0x213>
  80059b:	0f be c0             	movsbl %al,%eax
  80059e:	83 e8 20             	sub    $0x20,%eax
  8005a1:	83 f8 5e             	cmp    $0x5e,%eax
  8005a4:	76 10                	jbe    8005b6 <vprintfmt+0x213>
					putch('?', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ac:	6a 3f                	push   $0x3f
  8005ae:	ff 55 08             	call   *0x8(%ebp)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb 0d                	jmp    8005c3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	ff 75 0c             	pushl  0xc(%ebp)
  8005bc:	52                   	push   %edx
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c3:	83 eb 01             	sub    $0x1,%ebx
  8005c6:	eb 1a                	jmp    8005e2 <vprintfmt+0x23f>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	eb 0c                	jmp    8005e2 <vprintfmt+0x23f>
  8005d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005e2:	83 c7 01             	add    $0x1,%edi
  8005e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e9:	0f be d0             	movsbl %al,%edx
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	74 23                	je     800613 <vprintfmt+0x270>
  8005f0:	85 f6                	test   %esi,%esi
  8005f2:	78 a1                	js     800595 <vprintfmt+0x1f2>
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	79 9c                	jns    800595 <vprintfmt+0x1f2>
  8005f9:	89 df                	mov    %ebx,%edi
  8005fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800601:	eb 18                	jmp    80061b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 20                	push   $0x20
  800609:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb 08                	jmp    80061b <vprintfmt+0x278>
  800613:	89 df                	mov    %ebx,%edi
  800615:	8b 75 08             	mov    0x8(%ebp),%esi
  800618:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061b:	85 ff                	test   %edi,%edi
  80061d:	7f e4                	jg     800603 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800622:	e9 a2 fd ff ff       	jmp    8003c9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800627:	83 fa 01             	cmp    $0x1,%edx
  80062a:	7e 16                	jle    800642 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 08             	lea    0x8(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	eb 32                	jmp    800674 <vprintfmt+0x2d1>
	else if (lflag)
  800642:	85 d2                	test   %edx,%edx
  800644:	74 18                	je     80065e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 c1                	mov    %eax,%ecx
  800656:	c1 f9 1f             	sar    $0x1f,%ecx
  800659:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80065c:	eb 16                	jmp    800674 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066c:	89 c1                	mov    %eax,%ecx
  80066e:	c1 f9 1f             	sar    $0x1f,%ecx
  800671:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800674:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800677:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80067f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800683:	0f 89 90 00 00 00    	jns    800719 <vprintfmt+0x376>
				putch('-', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 2d                	push   $0x2d
  80068f:	ff d6                	call   *%esi
				num = -(long long) num;
  800691:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800694:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800697:	f7 d8                	neg    %eax
  800699:	83 d2 00             	adc    $0x0,%edx
  80069c:	f7 da                	neg    %edx
  80069e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006a6:	eb 71                	jmp    800719 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ab:	e8 7f fc ff ff       	call   80032f <getuint>
			base = 10;
  8006b0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006b5:	eb 62                	jmp    800719 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ba:	e8 70 fc ff ff       	call   80032f <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006c6:	51                   	push   %ecx
  8006c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ca:	6a 08                	push   $0x8
  8006cc:	52                   	push   %edx
  8006cd:	50                   	push   %eax
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 a9 fb ff ff       	call   800280 <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8006dd:	e9 e7 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	6a 30                	push   $0x30
  8006e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ea:	83 c4 08             	add    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	6a 78                	push   $0x78
  8006f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800702:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800705:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80070a:	eb 0d                	jmp    800719 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
  80070f:	e8 1b fc ff ff       	call   80032f <getuint>
			base = 16;
  800714:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800720:	57                   	push   %edi
  800721:	ff 75 e0             	pushl  -0x20(%ebp)
  800724:	51                   	push   %ecx
  800725:	52                   	push   %edx
  800726:	50                   	push   %eax
  800727:	89 da                	mov    %ebx,%edx
  800729:	89 f0                	mov    %esi,%eax
  80072b:	e8 50 fb ff ff       	call   800280 <printnum>
			break;
  800730:	83 c4 20             	add    $0x20,%esp
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800736:	e9 8e fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	51                   	push   %ecx
  800740:	ff d6                	call   *%esi
			break;
  800742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800748:	e9 7c fc ff ff       	jmp    8003c9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 25                	push   $0x25
  800753:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800755:	83 c4 10             	add    $0x10,%esp
  800758:	eb 03                	jmp    80075d <vprintfmt+0x3ba>
  80075a:	83 ef 01             	sub    $0x1,%edi
  80075d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800761:	75 f7                	jne    80075a <vprintfmt+0x3b7>
  800763:	e9 61 fc ff ff       	jmp    8003c9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 18             	sub    $0x18,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800783:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800786:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80078d:	85 c0                	test   %eax,%eax
  80078f:	74 26                	je     8007b7 <vsnprintf+0x47>
  800791:	85 d2                	test   %edx,%edx
  800793:	7e 22                	jle    8007b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800795:	ff 75 14             	pushl  0x14(%ebp)
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079e:	50                   	push   %eax
  80079f:	68 69 03 80 00       	push   $0x800369
  8007a4:	e8 fa fb ff ff       	call   8003a3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 05                	jmp    8007bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    

008007be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 10             	pushl  0x10(%ebp)
  8007cb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ce:	ff 75 08             	pushl  0x8(%ebp)
  8007d1:	e8 9a ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e3:	eb 03                	jmp    8007e8 <strlen+0x10>
		n++;
  8007e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ec:	75 f7                	jne    8007e5 <strlen+0xd>
		n++;
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007fe:	eb 03                	jmp    800803 <strnlen+0x13>
		n++;
  800800:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 08                	je     80080f <strnlen+0x1f>
  800807:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80080b:	75 f3                	jne    800800 <strnlen+0x10>
  80080d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081b:	89 c2                	mov    %eax,%edx
  80081d:	83 c2 01             	add    $0x1,%edx
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082a:	84 db                	test   %bl,%bl
  80082c:	75 ef                	jne    80081d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80082e:	5b                   	pop    %ebx
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800838:	53                   	push   %ebx
  800839:	e8 9a ff ff ff       	call   8007d8 <strlen>
  80083e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	01 d8                	add    %ebx,%eax
  800846:	50                   	push   %eax
  800847:	e8 c5 ff ff ff       	call   800811 <strcpy>
	return dst;
}
  80084c:	89 d8                	mov    %ebx,%eax
  80084e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800851:	c9                   	leave  
  800852:	c3                   	ret    

00800853 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	89 f3                	mov    %esi,%ebx
  800860:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 0f                	jmp    800876 <strncpy+0x23>
		*dst++ = *src;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	0f b6 01             	movzbl (%ecx),%eax
  80086d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800870:	80 39 01             	cmpb   $0x1,(%ecx)
  800873:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800876:	39 da                	cmp    %ebx,%edx
  800878:	75 ed                	jne    800867 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	5b                   	pop    %ebx
  80087d:	5e                   	pop    %esi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 75 08             	mov    0x8(%ebp),%esi
  800888:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80088b:	8b 55 10             	mov    0x10(%ebp),%edx
  80088e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800890:	85 d2                	test   %edx,%edx
  800892:	74 21                	je     8008b5 <strlcpy+0x35>
  800894:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800898:	89 f2                	mov    %esi,%edx
  80089a:	eb 09                	jmp    8008a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a5:	39 c2                	cmp    %eax,%edx
  8008a7:	74 09                	je     8008b2 <strlcpy+0x32>
  8008a9:	0f b6 19             	movzbl (%ecx),%ebx
  8008ac:	84 db                	test   %bl,%bl
  8008ae:	75 ec                	jne    80089c <strlcpy+0x1c>
  8008b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b5:	29 f0                	sub    %esi,%eax
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5e                   	pop    %esi
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c4:	eb 06                	jmp    8008cc <strcmp+0x11>
		p++, q++;
  8008c6:	83 c1 01             	add    $0x1,%ecx
  8008c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cc:	0f b6 01             	movzbl (%ecx),%eax
  8008cf:	84 c0                	test   %al,%al
  8008d1:	74 04                	je     8008d7 <strcmp+0x1c>
  8008d3:	3a 02                	cmp    (%edx),%al
  8008d5:	74 ef                	je     8008c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 c0             	movzbl %al,%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008eb:	89 c3                	mov    %eax,%ebx
  8008ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f0:	eb 06                	jmp    8008f8 <strncmp+0x17>
		n--, p++, q++;
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008f8:	39 d8                	cmp    %ebx,%eax
  8008fa:	74 15                	je     800911 <strncmp+0x30>
  8008fc:	0f b6 08             	movzbl (%eax),%ecx
  8008ff:	84 c9                	test   %cl,%cl
  800901:	74 04                	je     800907 <strncmp+0x26>
  800903:	3a 0a                	cmp    (%edx),%cl
  800905:	74 eb                	je     8008f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800907:	0f b6 00             	movzbl (%eax),%eax
  80090a:	0f b6 12             	movzbl (%edx),%edx
  80090d:	29 d0                	sub    %edx,%eax
  80090f:	eb 05                	jmp    800916 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800923:	eb 07                	jmp    80092c <strchr+0x13>
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 0f                	je     800938 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f2                	jne    800925 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	eb 03                	jmp    800949 <strfind+0xf>
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	74 04                	je     800954 <strfind+0x1a>
  800950:	84 d2                	test   %dl,%dl
  800952:	75 f2                	jne    800946 <strfind+0xc>
			break;
	return (char *) s;
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	53                   	push   %ebx
  80095c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800962:	85 c9                	test   %ecx,%ecx
  800964:	74 36                	je     80099c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800966:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80096c:	75 28                	jne    800996 <memset+0x40>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 23                	jne    800996 <memset+0x40>
		c &= 0xFF;
  800973:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800977:	89 d3                	mov    %edx,%ebx
  800979:	c1 e3 08             	shl    $0x8,%ebx
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	c1 e6 18             	shl    $0x18,%esi
  800981:	89 d0                	mov    %edx,%eax
  800983:	c1 e0 10             	shl    $0x10,%eax
  800986:	09 f0                	or     %esi,%eax
  800988:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80098a:	89 d8                	mov    %ebx,%eax
  80098c:	09 d0                	or     %edx,%eax
  80098e:	c1 e9 02             	shr    $0x2,%ecx
  800991:	fc                   	cld    
  800992:	f3 ab                	rep stos %eax,%es:(%edi)
  800994:	eb 06                	jmp    80099c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	fc                   	cld    
  80099a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099c:	89 f8                	mov    %edi,%eax
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5f                   	pop    %edi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b1:	39 c6                	cmp    %eax,%esi
  8009b3:	73 35                	jae    8009ea <memmove+0x47>
  8009b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009b8:	39 d0                	cmp    %edx,%eax
  8009ba:	73 2e                	jae    8009ea <memmove+0x47>
		s += n;
		d += n;
  8009bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bf:	89 d6                	mov    %edx,%esi
  8009c1:	09 fe                	or     %edi,%esi
  8009c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c9:	75 13                	jne    8009de <memmove+0x3b>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 0e                	jne    8009de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009d0:	83 ef 04             	sub    $0x4,%edi
  8009d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fd                   	std    
  8009da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009dc:	eb 09                	jmp    8009e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009de:	83 ef 01             	sub    $0x1,%edi
  8009e1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009e4:	fd                   	std    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e7:	fc                   	cld    
  8009e8:	eb 1d                	jmp    800a07 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	89 f2                	mov    %esi,%edx
  8009ec:	09 c2                	or     %eax,%edx
  8009ee:	f6 c2 03             	test   $0x3,%dl
  8009f1:	75 0f                	jne    800a02 <memmove+0x5f>
  8009f3:	f6 c1 03             	test   $0x3,%cl
  8009f6:	75 0a                	jne    800a02 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009f8:	c1 e9 02             	shr    $0x2,%ecx
  8009fb:	89 c7                	mov    %eax,%edi
  8009fd:	fc                   	cld    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 05                	jmp    800a07 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a02:	89 c7                	mov    %eax,%edi
  800a04:	fc                   	cld    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a07:	5e                   	pop    %esi
  800a08:	5f                   	pop    %edi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a0e:	ff 75 10             	pushl  0x10(%ebp)
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	ff 75 08             	pushl  0x8(%ebp)
  800a17:	e8 87 ff ff ff       	call   8009a3 <memmove>
}
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 c6                	mov    %eax,%esi
  800a2b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	eb 1a                	jmp    800a4a <memcmp+0x2c>
		if (*s1 != *s2)
  800a30:	0f b6 08             	movzbl (%eax),%ecx
  800a33:	0f b6 1a             	movzbl (%edx),%ebx
  800a36:	38 d9                	cmp    %bl,%cl
  800a38:	74 0a                	je     800a44 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a3a:	0f b6 c1             	movzbl %cl,%eax
  800a3d:	0f b6 db             	movzbl %bl,%ebx
  800a40:	29 d8                	sub    %ebx,%eax
  800a42:	eb 0f                	jmp    800a53 <memcmp+0x35>
		s1++, s2++;
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4a:	39 f0                	cmp    %esi,%eax
  800a4c:	75 e2                	jne    800a30 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a5e:	89 c1                	mov    %eax,%ecx
  800a60:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a63:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a67:	eb 0a                	jmp    800a73 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a69:	0f b6 10             	movzbl (%eax),%edx
  800a6c:	39 da                	cmp    %ebx,%edx
  800a6e:	74 07                	je     800a77 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	39 c8                	cmp    %ecx,%eax
  800a75:	72 f2                	jb     800a69 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a86:	eb 03                	jmp    800a8b <strtol+0x11>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	3c 20                	cmp    $0x20,%al
  800a90:	74 f6                	je     800a88 <strtol+0xe>
  800a92:	3c 09                	cmp    $0x9,%al
  800a94:	74 f2                	je     800a88 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a96:	3c 2b                	cmp    $0x2b,%al
  800a98:	75 0a                	jne    800aa4 <strtol+0x2a>
		s++;
  800a9a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa2:	eb 11                	jmp    800ab5 <strtol+0x3b>
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	75 08                	jne    800ab5 <strtol+0x3b>
		s++, neg = 1;
  800aad:	83 c1 01             	add    $0x1,%ecx
  800ab0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abb:	75 15                	jne    800ad2 <strtol+0x58>
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 10                	jne    800ad2 <strtol+0x58>
  800ac2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac6:	75 7c                	jne    800b44 <strtol+0xca>
		s += 2, base = 16;
  800ac8:	83 c1 02             	add    $0x2,%ecx
  800acb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad0:	eb 16                	jmp    800ae8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ad2:	85 db                	test   %ebx,%ebx
  800ad4:	75 12                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adb:	80 39 30             	cmpb   $0x30,(%ecx)
  800ade:	75 08                	jne    800ae8 <strtol+0x6e>
		s++, base = 8;
  800ae0:	83 c1 01             	add    $0x1,%ecx
  800ae3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800af0:	0f b6 11             	movzbl (%ecx),%edx
  800af3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 09             	cmp    $0x9,%bl
  800afb:	77 08                	ja     800b05 <strtol+0x8b>
			dig = *s - '0';
  800afd:	0f be d2             	movsbl %dl,%edx
  800b00:	83 ea 30             	sub    $0x30,%edx
  800b03:	eb 22                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b08:	89 f3                	mov    %esi,%ebx
  800b0a:	80 fb 19             	cmp    $0x19,%bl
  800b0d:	77 08                	ja     800b17 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b0f:	0f be d2             	movsbl %dl,%edx
  800b12:	83 ea 57             	sub    $0x57,%edx
  800b15:	eb 10                	jmp    800b27 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b17:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 19             	cmp    $0x19,%bl
  800b1f:	77 16                	ja     800b37 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2a:	7d 0b                	jge    800b37 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b33:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b35:	eb b9                	jmp    800af0 <strtol+0x76>

	if (endptr)
  800b37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b3b:	74 0d                	je     800b4a <strtol+0xd0>
		*endptr = (char *) s;
  800b3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b40:	89 0e                	mov    %ecx,(%esi)
  800b42:	eb 06                	jmp    800b4a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	74 98                	je     800ae0 <strtol+0x66>
  800b48:	eb 9e                	jmp    800ae8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	f7 da                	neg    %edx
  800b4e:	85 ff                	test   %edi,%edi
  800b50:	0f 45 c2             	cmovne %edx,%eax
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	89 c7                	mov    %eax,%edi
  800b6d:	89 c6                	mov    %eax,%esi
  800b6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	89 d7                	mov    %edx,%edi
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
  800b9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 cb                	mov    %ecx,%ebx
  800bad:	89 cf                	mov    %ecx,%edi
  800baf:	89 ce                	mov    %ecx,%esi
  800bb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 03                	push   $0x3
  800bbd:	68 df 27 80 00       	push   $0x8027df
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 fc 27 80 00       	push   $0x8027fc
  800bc9:	e8 c5 f5 ff ff       	call   800193 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 02 00 00 00       	mov    $0x2,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_yield>:

void
sys_yield(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	b8 04 00 00 00       	mov    $0x4,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7e 17                	jle    800c4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	50                   	push   %eax
  800c3c:	6a 04                	push   $0x4
  800c3e:	68 df 27 80 00       	push   $0x8027df
  800c43:	6a 23                	push   $0x23
  800c45:	68 fc 27 80 00       	push   $0x8027fc
  800c4a:	e8 44 f5 ff ff       	call   800193 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 05 00 00 00       	mov    $0x5,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c71:	8b 75 18             	mov    0x18(%ebp),%esi
  800c74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c76:	85 c0                	test   %eax,%eax
  800c78:	7e 17                	jle    800c91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7a:	83 ec 0c             	sub    $0xc,%esp
  800c7d:	50                   	push   %eax
  800c7e:	6a 05                	push   $0x5
  800c80:	68 df 27 80 00       	push   $0x8027df
  800c85:	6a 23                	push   $0x23
  800c87:	68 fc 27 80 00       	push   $0x8027fc
  800c8c:	e8 02 f5 ff ff       	call   800193 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800ca2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 df                	mov    %ebx,%edi
  800cb4:	89 de                	mov    %ebx,%esi
  800cb6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7e 17                	jle    800cd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbc:	83 ec 0c             	sub    $0xc,%esp
  800cbf:	50                   	push   %eax
  800cc0:	6a 06                	push   $0x6
  800cc2:	68 df 27 80 00       	push   $0x8027df
  800cc7:	6a 23                	push   $0x23
  800cc9:	68 fc 27 80 00       	push   $0x8027fc
  800cce:	e8 c0 f4 ff ff       	call   800193 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
  800ce1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	89 df                	mov    %ebx,%edi
  800cf6:	89 de                	mov    %ebx,%esi
  800cf8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 08                	push   $0x8
  800d04:	68 df 27 80 00       	push   $0x8027df
  800d09:	6a 23                	push   $0x23
  800d0b:	68 fc 27 80 00       	push   $0x8027fc
  800d10:	e8 7e f4 ff ff       	call   800193 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	57                   	push   %edi
  800d21:	56                   	push   %esi
  800d22:	53                   	push   %ebx
  800d23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	89 df                	mov    %ebx,%edi
  800d38:	89 de                	mov    %ebx,%esi
  800d3a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	7e 17                	jle    800d57 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	50                   	push   %eax
  800d44:	6a 09                	push   $0x9
  800d46:	68 df 27 80 00       	push   $0x8027df
  800d4b:	6a 23                	push   $0x23
  800d4d:	68 fc 27 80 00       	push   $0x8027fc
  800d52:	e8 3c f4 ff ff       	call   800193 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	89 df                	mov    %ebx,%edi
  800d7a:	89 de                	mov    %ebx,%esi
  800d7c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	7e 17                	jle    800d99 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 0a                	push   $0xa
  800d88:	68 df 27 80 00       	push   $0x8027df
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 fc 27 80 00       	push   $0x8027fc
  800d94:	e8 fa f3 ff ff       	call   800193 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	be 00 00 00 00       	mov    $0x0,%esi
  800dac:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 cb                	mov    %ecx,%ebx
  800ddc:	89 cf                	mov    %ecx,%edi
  800dde:	89 ce                	mov    %ecx,%esi
  800de0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de2:	85 c0                	test   %eax,%eax
  800de4:	7e 17                	jle    800dfd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 0d                	push   $0xd
  800dec:	68 df 27 80 00       	push   $0x8027df
  800df1:	6a 23                	push   $0x23
  800df3:	68 fc 27 80 00       	push   $0x8027fc
  800df8:	e8 96 f3 ff ff       	call   800193 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	57                   	push   %edi
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e10:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e15:	89 d1                	mov    %edx,%ecx
  800e17:	89 d3                	mov    %edx,%ebx
  800e19:	89 d7                	mov    %edx,%edi
  800e1b:	89 d6                	mov    %edx,%esi
  800e1d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e44:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e51:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	c1 ea 16             	shr    $0x16,%edx
  800e5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e62:	f6 c2 01             	test   $0x1,%dl
  800e65:	74 11                	je     800e78 <fd_alloc+0x2d>
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	c1 ea 0c             	shr    $0xc,%edx
  800e6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e73:	f6 c2 01             	test   $0x1,%dl
  800e76:	75 09                	jne    800e81 <fd_alloc+0x36>
			*fd_store = fd;
  800e78:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	eb 17                	jmp    800e98 <fd_alloc+0x4d>
  800e81:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e86:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e8b:	75 c9                	jne    800e56 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e8d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e93:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea0:	83 f8 1f             	cmp    $0x1f,%eax
  800ea3:	77 36                	ja     800edb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ea5:	c1 e0 0c             	shl    $0xc,%eax
  800ea8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	c1 ea 16             	shr    $0x16,%edx
  800eb2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb9:	f6 c2 01             	test   $0x1,%dl
  800ebc:	74 24                	je     800ee2 <fd_lookup+0x48>
  800ebe:	89 c2                	mov    %eax,%edx
  800ec0:	c1 ea 0c             	shr    $0xc,%edx
  800ec3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eca:	f6 c2 01             	test   $0x1,%dl
  800ecd:	74 1a                	je     800ee9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ecf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed2:	89 02                	mov    %eax,(%edx)
	return 0;
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	eb 13                	jmp    800eee <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee0:	eb 0c                	jmp    800eee <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee7:	eb 05                	jmp    800eee <fd_lookup+0x54>
  800ee9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 08             	sub    $0x8,%esp
  800ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef9:	ba 8c 28 80 00       	mov    $0x80288c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800efe:	eb 13                	jmp    800f13 <dev_lookup+0x23>
  800f00:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f03:	39 08                	cmp    %ecx,(%eax)
  800f05:	75 0c                	jne    800f13 <dev_lookup+0x23>
			*dev = devtab[i];
  800f07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f11:	eb 2e                	jmp    800f41 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f13:	8b 02                	mov    (%edx),%eax
  800f15:	85 c0                	test   %eax,%eax
  800f17:	75 e7                	jne    800f00 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f19:	a1 20 60 80 00       	mov    0x806020,%eax
  800f1e:	8b 40 48             	mov    0x48(%eax),%eax
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	51                   	push   %ecx
  800f25:	50                   	push   %eax
  800f26:	68 0c 28 80 00       	push   $0x80280c
  800f2b:	e8 3c f3 ff ff       	call   80026c <cprintf>
	*dev = 0;
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f39:	83 c4 10             	add    $0x10,%esp
  800f3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	56                   	push   %esi
  800f47:	53                   	push   %ebx
  800f48:	83 ec 10             	sub    $0x10,%esp
  800f4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f54:	50                   	push   %eax
  800f55:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f5b:	c1 e8 0c             	shr    $0xc,%eax
  800f5e:	50                   	push   %eax
  800f5f:	e8 36 ff ff ff       	call   800e9a <fd_lookup>
  800f64:	83 c4 08             	add    $0x8,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 05                	js     800f70 <fd_close+0x2d>
	    || fd != fd2)
  800f6b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f6e:	74 0c                	je     800f7c <fd_close+0x39>
		return (must_exist ? r : 0);
  800f70:	84 db                	test   %bl,%bl
  800f72:	ba 00 00 00 00       	mov    $0x0,%edx
  800f77:	0f 44 c2             	cmove  %edx,%eax
  800f7a:	eb 41                	jmp    800fbd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f7c:	83 ec 08             	sub    $0x8,%esp
  800f7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	ff 36                	pushl  (%esi)
  800f85:	e8 66 ff ff ff       	call   800ef0 <dev_lookup>
  800f8a:	89 c3                	mov    %eax,%ebx
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 1a                	js     800fad <fd_close+0x6a>
		if (dev->dev_close)
  800f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f96:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f99:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	74 0b                	je     800fad <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	56                   	push   %esi
  800fa6:	ff d0                	call   *%eax
  800fa8:	89 c3                	mov    %eax,%ebx
  800faa:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fad:	83 ec 08             	sub    $0x8,%esp
  800fb0:	56                   	push   %esi
  800fb1:	6a 00                	push   $0x0
  800fb3:	e8 e1 fc ff ff       	call   800c99 <sys_page_unmap>
	return r;
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	89 d8                	mov    %ebx,%eax
}
  800fbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcd:	50                   	push   %eax
  800fce:	ff 75 08             	pushl  0x8(%ebp)
  800fd1:	e8 c4 fe ff ff       	call   800e9a <fd_lookup>
  800fd6:	83 c4 08             	add    $0x8,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 10                	js     800fed <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fdd:	83 ec 08             	sub    $0x8,%esp
  800fe0:	6a 01                	push   $0x1
  800fe2:	ff 75 f4             	pushl  -0xc(%ebp)
  800fe5:	e8 59 ff ff ff       	call   800f43 <fd_close>
  800fea:	83 c4 10             	add    $0x10,%esp
}
  800fed:	c9                   	leave  
  800fee:	c3                   	ret    

00800fef <close_all>:

void
close_all(void)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ff6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	53                   	push   %ebx
  800fff:	e8 c0 ff ff ff       	call   800fc4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801004:	83 c3 01             	add    $0x1,%ebx
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	83 fb 20             	cmp    $0x20,%ebx
  80100d:	75 ec                	jne    800ffb <close_all+0xc>
		close(i);
}
  80100f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	83 ec 2c             	sub    $0x2c,%esp
  80101d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801020:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801023:	50                   	push   %eax
  801024:	ff 75 08             	pushl  0x8(%ebp)
  801027:	e8 6e fe ff ff       	call   800e9a <fd_lookup>
  80102c:	83 c4 08             	add    $0x8,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	0f 88 c1 00 00 00    	js     8010f8 <dup+0xe4>
		return r;
	close(newfdnum);
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	56                   	push   %esi
  80103b:	e8 84 ff ff ff       	call   800fc4 <close>

	newfd = INDEX2FD(newfdnum);
  801040:	89 f3                	mov    %esi,%ebx
  801042:	c1 e3 0c             	shl    $0xc,%ebx
  801045:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80104b:	83 c4 04             	add    $0x4,%esp
  80104e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801051:	e8 de fd ff ff       	call   800e34 <fd2data>
  801056:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801058:	89 1c 24             	mov    %ebx,(%esp)
  80105b:	e8 d4 fd ff ff       	call   800e34 <fd2data>
  801060:	83 c4 10             	add    $0x10,%esp
  801063:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801066:	89 f8                	mov    %edi,%eax
  801068:	c1 e8 16             	shr    $0x16,%eax
  80106b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801072:	a8 01                	test   $0x1,%al
  801074:	74 37                	je     8010ad <dup+0x99>
  801076:	89 f8                	mov    %edi,%eax
  801078:	c1 e8 0c             	shr    $0xc,%eax
  80107b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801082:	f6 c2 01             	test   $0x1,%dl
  801085:	74 26                	je     8010ad <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801087:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	25 07 0e 00 00       	and    $0xe07,%eax
  801096:	50                   	push   %eax
  801097:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109a:	6a 00                	push   $0x0
  80109c:	57                   	push   %edi
  80109d:	6a 00                	push   $0x0
  80109f:	e8 b3 fb ff ff       	call   800c57 <sys_page_map>
  8010a4:	89 c7                	mov    %eax,%edi
  8010a6:	83 c4 20             	add    $0x20,%esp
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	78 2e                	js     8010db <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010b0:	89 d0                	mov    %edx,%eax
  8010b2:	c1 e8 0c             	shr    $0xc,%eax
  8010b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c4:	50                   	push   %eax
  8010c5:	53                   	push   %ebx
  8010c6:	6a 00                	push   $0x0
  8010c8:	52                   	push   %edx
  8010c9:	6a 00                	push   $0x0
  8010cb:	e8 87 fb ff ff       	call   800c57 <sys_page_map>
  8010d0:	89 c7                	mov    %eax,%edi
  8010d2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010d5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d7:	85 ff                	test   %edi,%edi
  8010d9:	79 1d                	jns    8010f8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	53                   	push   %ebx
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 b3 fb ff ff       	call   800c99 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010e6:	83 c4 08             	add    $0x8,%esp
  8010e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 a6 fb ff ff       	call   800c99 <sys_page_unmap>
	return r;
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	89 f8                	mov    %edi,%eax
}
  8010f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	53                   	push   %ebx
  801104:	83 ec 14             	sub    $0x14,%esp
  801107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	53                   	push   %ebx
  80110f:	e8 86 fd ff ff       	call   800e9a <fd_lookup>
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	89 c2                	mov    %eax,%edx
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 6d                	js     80118a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801127:	ff 30                	pushl  (%eax)
  801129:	e8 c2 fd ff ff       	call   800ef0 <dev_lookup>
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 4c                	js     801181 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801135:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801138:	8b 42 08             	mov    0x8(%edx),%eax
  80113b:	83 e0 03             	and    $0x3,%eax
  80113e:	83 f8 01             	cmp    $0x1,%eax
  801141:	75 21                	jne    801164 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801143:	a1 20 60 80 00       	mov    0x806020,%eax
  801148:	8b 40 48             	mov    0x48(%eax),%eax
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	53                   	push   %ebx
  80114f:	50                   	push   %eax
  801150:	68 50 28 80 00       	push   $0x802850
  801155:	e8 12 f1 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801162:	eb 26                	jmp    80118a <read+0x8a>
	}
	if (!dev->dev_read)
  801164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801167:	8b 40 08             	mov    0x8(%eax),%eax
  80116a:	85 c0                	test   %eax,%eax
  80116c:	74 17                	je     801185 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	ff 75 10             	pushl  0x10(%ebp)
  801174:	ff 75 0c             	pushl  0xc(%ebp)
  801177:	52                   	push   %edx
  801178:	ff d0                	call   *%eax
  80117a:	89 c2                	mov    %eax,%edx
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	eb 09                	jmp    80118a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801181:	89 c2                	mov    %eax,%edx
  801183:	eb 05                	jmp    80118a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801185:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80118a:	89 d0                	mov    %edx,%eax
  80118c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80119d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a5:	eb 21                	jmp    8011c8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	89 f0                	mov    %esi,%eax
  8011ac:	29 d8                	sub    %ebx,%eax
  8011ae:	50                   	push   %eax
  8011af:	89 d8                	mov    %ebx,%eax
  8011b1:	03 45 0c             	add    0xc(%ebp),%eax
  8011b4:	50                   	push   %eax
  8011b5:	57                   	push   %edi
  8011b6:	e8 45 ff ff ff       	call   801100 <read>
		if (m < 0)
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 10                	js     8011d2 <readn+0x41>
			return m;
		if (m == 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	74 0a                	je     8011d0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c6:	01 c3                	add    %eax,%ebx
  8011c8:	39 f3                	cmp    %esi,%ebx
  8011ca:	72 db                	jb     8011a7 <readn+0x16>
  8011cc:	89 d8                	mov    %ebx,%eax
  8011ce:	eb 02                	jmp    8011d2 <readn+0x41>
  8011d0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 14             	sub    $0x14,%esp
  8011e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	53                   	push   %ebx
  8011e9:	e8 ac fc ff ff       	call   800e9a <fd_lookup>
  8011ee:	83 c4 08             	add    $0x8,%esp
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	78 68                	js     80125f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fd:	50                   	push   %eax
  8011fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801201:	ff 30                	pushl  (%eax)
  801203:	e8 e8 fc ff ff       	call   800ef0 <dev_lookup>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 47                	js     801256 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801212:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801216:	75 21                	jne    801239 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801218:	a1 20 60 80 00       	mov    0x806020,%eax
  80121d:	8b 40 48             	mov    0x48(%eax),%eax
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	53                   	push   %ebx
  801224:	50                   	push   %eax
  801225:	68 6c 28 80 00       	push   $0x80286c
  80122a:	e8 3d f0 ff ff       	call   80026c <cprintf>
		return -E_INVAL;
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801237:	eb 26                	jmp    80125f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801239:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123c:	8b 52 0c             	mov    0xc(%edx),%edx
  80123f:	85 d2                	test   %edx,%edx
  801241:	74 17                	je     80125a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	ff 75 10             	pushl  0x10(%ebp)
  801249:	ff 75 0c             	pushl  0xc(%ebp)
  80124c:	50                   	push   %eax
  80124d:	ff d2                	call   *%edx
  80124f:	89 c2                	mov    %eax,%edx
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	eb 09                	jmp    80125f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801256:	89 c2                	mov    %eax,%edx
  801258:	eb 05                	jmp    80125f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80125a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80125f:	89 d0                	mov    %edx,%eax
  801261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <seek>:

int
seek(int fdnum, off_t offset)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	ff 75 08             	pushl  0x8(%ebp)
  801273:	e8 22 fc ff ff       	call   800e9a <fd_lookup>
  801278:	83 c4 08             	add    $0x8,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 0e                	js     80128d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80127f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801282:	8b 55 0c             	mov    0xc(%ebp),%edx
  801285:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801288:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	53                   	push   %ebx
  801293:	83 ec 14             	sub    $0x14,%esp
  801296:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801299:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	53                   	push   %ebx
  80129e:	e8 f7 fb ff ff       	call   800e9a <fd_lookup>
  8012a3:	83 c4 08             	add    $0x8,%esp
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 65                	js     801311 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ac:	83 ec 08             	sub    $0x8,%esp
  8012af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b2:	50                   	push   %eax
  8012b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b6:	ff 30                	pushl  (%eax)
  8012b8:	e8 33 fc ff ff       	call   800ef0 <dev_lookup>
  8012bd:	83 c4 10             	add    $0x10,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 44                	js     801308 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012cb:	75 21                	jne    8012ee <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012cd:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012d2:	8b 40 48             	mov    0x48(%eax),%eax
  8012d5:	83 ec 04             	sub    $0x4,%esp
  8012d8:	53                   	push   %ebx
  8012d9:	50                   	push   %eax
  8012da:	68 2c 28 80 00       	push   $0x80282c
  8012df:	e8 88 ef ff ff       	call   80026c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ec:	eb 23                	jmp    801311 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012f1:	8b 52 18             	mov    0x18(%edx),%edx
  8012f4:	85 d2                	test   %edx,%edx
  8012f6:	74 14                	je     80130c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	ff 75 0c             	pushl  0xc(%ebp)
  8012fe:	50                   	push   %eax
  8012ff:	ff d2                	call   *%edx
  801301:	89 c2                	mov    %eax,%edx
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	eb 09                	jmp    801311 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801308:	89 c2                	mov    %eax,%edx
  80130a:	eb 05                	jmp    801311 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80130c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801311:	89 d0                	mov    %edx,%eax
  801313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801316:	c9                   	leave  
  801317:	c3                   	ret    

00801318 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 14             	sub    $0x14,%esp
  80131f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801322:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 75 08             	pushl  0x8(%ebp)
  801329:	e8 6c fb ff ff       	call   800e9a <fd_lookup>
  80132e:	83 c4 08             	add    $0x8,%esp
  801331:	89 c2                	mov    %eax,%edx
  801333:	85 c0                	test   %eax,%eax
  801335:	78 58                	js     80138f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801341:	ff 30                	pushl  (%eax)
  801343:	e8 a8 fb ff ff       	call   800ef0 <dev_lookup>
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 37                	js     801386 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801352:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801356:	74 32                	je     80138a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801358:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80135b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801362:	00 00 00 
	stat->st_isdir = 0;
  801365:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80136c:	00 00 00 
	stat->st_dev = dev;
  80136f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	53                   	push   %ebx
  801379:	ff 75 f0             	pushl  -0x10(%ebp)
  80137c:	ff 50 14             	call   *0x14(%eax)
  80137f:	89 c2                	mov    %eax,%edx
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	eb 09                	jmp    80138f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801386:	89 c2                	mov    %eax,%edx
  801388:	eb 05                	jmp    80138f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80138a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80138f:	89 d0                	mov    %edx,%eax
  801391:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	56                   	push   %esi
  80139a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	6a 00                	push   $0x0
  8013a0:	ff 75 08             	pushl  0x8(%ebp)
  8013a3:	e8 ef 01 00 00       	call   801597 <open>
  8013a8:	89 c3                	mov    %eax,%ebx
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 1b                	js     8013cc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	ff 75 0c             	pushl  0xc(%ebp)
  8013b7:	50                   	push   %eax
  8013b8:	e8 5b ff ff ff       	call   801318 <fstat>
  8013bd:	89 c6                	mov    %eax,%esi
	close(fd);
  8013bf:	89 1c 24             	mov    %ebx,(%esp)
  8013c2:	e8 fd fb ff ff       	call   800fc4 <close>
	return r;
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	89 f0                	mov    %esi,%eax
}
  8013cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    

008013d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013d3:	55                   	push   %ebp
  8013d4:	89 e5                	mov    %esp,%ebp
  8013d6:	56                   	push   %esi
  8013d7:	53                   	push   %ebx
  8013d8:	89 c6                	mov    %eax,%esi
  8013da:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013e3:	75 12                	jne    8013f7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	6a 01                	push   $0x1
  8013ea:	e8 67 0d 00 00       	call   802156 <ipc_find_env>
  8013ef:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013f7:	6a 07                	push   $0x7
  8013f9:	68 00 70 80 00       	push   $0x807000
  8013fe:	56                   	push   %esi
  8013ff:	ff 35 00 40 80 00    	pushl  0x804000
  801405:	e8 fd 0c 00 00       	call   802107 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80140a:	83 c4 0c             	add    $0xc,%esp
  80140d:	6a 00                	push   $0x0
  80140f:	53                   	push   %ebx
  801410:	6a 00                	push   $0x0
  801412:	e8 7a 0c 00 00       	call   802091 <ipc_recv>
}
  801417:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141a:	5b                   	pop    %ebx
  80141b:	5e                   	pop    %esi
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	8b 40 0c             	mov    0xc(%eax),%eax
  80142a:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  80142f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801432:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	b8 02 00 00 00       	mov    $0x2,%eax
  801441:	e8 8d ff ff ff       	call   8013d3 <fsipc>
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	8b 40 0c             	mov    0xc(%eax),%eax
  801454:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  801459:	ba 00 00 00 00       	mov    $0x0,%edx
  80145e:	b8 06 00 00 00       	mov    $0x6,%eax
  801463:	e8 6b ff ff ff       	call   8013d3 <fsipc>
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	8b 40 0c             	mov    0xc(%eax),%eax
  80147a:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80147f:	ba 00 00 00 00       	mov    $0x0,%edx
  801484:	b8 05 00 00 00       	mov    $0x5,%eax
  801489:	e8 45 ff ff ff       	call   8013d3 <fsipc>
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 2c                	js     8014be <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	68 00 70 80 00       	push   $0x807000
  80149a:	53                   	push   %ebx
  80149b:	e8 71 f3 ff ff       	call   800811 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014a0:	a1 80 70 80 00       	mov    0x807080,%eax
  8014a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ab:	a1 84 70 80 00       	mov    0x807084,%eax
  8014b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c1:	c9                   	leave  
  8014c2:	c3                   	ret    

008014c3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014c3:	55                   	push   %ebp
  8014c4:	89 e5                	mov    %esp,%ebp
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d3:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8014d9:	a3 04 70 80 00       	mov    %eax,0x807004
  8014de:	3d 08 70 80 00       	cmp    $0x807008,%eax
  8014e3:	bb 08 70 80 00       	mov    $0x807008,%ebx
  8014e8:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014eb:	53                   	push   %ebx
  8014ec:	ff 75 0c             	pushl  0xc(%ebp)
  8014ef:	68 08 70 80 00       	push   $0x807008
  8014f4:	e8 aa f4 ff ff       	call   8009a3 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801503:	e8 cb fe ff ff       	call   8013d3 <fsipc>
  801508:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80150b:	85 c0                	test   %eax,%eax
  80150d:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
  80151a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151d:	8b 45 08             	mov    0x8(%ebp),%eax
  801520:	8b 40 0c             	mov    0xc(%eax),%eax
  801523:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801528:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152e:	ba 00 00 00 00       	mov    $0x0,%edx
  801533:	b8 03 00 00 00       	mov    $0x3,%eax
  801538:	e8 96 fe ff ff       	call   8013d3 <fsipc>
  80153d:	89 c3                	mov    %eax,%ebx
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 4b                	js     80158e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801543:	39 c6                	cmp    %eax,%esi
  801545:	73 16                	jae    80155d <devfile_read+0x48>
  801547:	68 a0 28 80 00       	push   $0x8028a0
  80154c:	68 a7 28 80 00       	push   $0x8028a7
  801551:	6a 7c                	push   $0x7c
  801553:	68 bc 28 80 00       	push   $0x8028bc
  801558:	e8 36 ec ff ff       	call   800193 <_panic>
	assert(r <= PGSIZE);
  80155d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801562:	7e 16                	jle    80157a <devfile_read+0x65>
  801564:	68 c7 28 80 00       	push   $0x8028c7
  801569:	68 a7 28 80 00       	push   $0x8028a7
  80156e:	6a 7d                	push   $0x7d
  801570:	68 bc 28 80 00       	push   $0x8028bc
  801575:	e8 19 ec ff ff       	call   800193 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	50                   	push   %eax
  80157e:	68 00 70 80 00       	push   $0x807000
  801583:	ff 75 0c             	pushl  0xc(%ebp)
  801586:	e8 18 f4 ff ff       	call   8009a3 <memmove>
	return r;
  80158b:	83 c4 10             	add    $0x10,%esp
}
  80158e:	89 d8                	mov    %ebx,%eax
  801590:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801593:	5b                   	pop    %ebx
  801594:	5e                   	pop    %esi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 20             	sub    $0x20,%esp
  80159e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a1:	53                   	push   %ebx
  8015a2:	e8 31 f2 ff ff       	call   8007d8 <strlen>
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015af:	7f 67                	jg     801618 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b1:	83 ec 0c             	sub    $0xc,%esp
  8015b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b7:	50                   	push   %eax
  8015b8:	e8 8e f8 ff ff       	call   800e4b <fd_alloc>
  8015bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	78 57                	js     80161d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	53                   	push   %ebx
  8015ca:	68 00 70 80 00       	push   $0x807000
  8015cf:	e8 3d f2 ff ff       	call   800811 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d7:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015df:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e4:	e8 ea fd ff ff       	call   8013d3 <fsipc>
  8015e9:	89 c3                	mov    %eax,%ebx
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	79 14                	jns    801606 <open+0x6f>
		fd_close(fd, 0);
  8015f2:	83 ec 08             	sub    $0x8,%esp
  8015f5:	6a 00                	push   $0x0
  8015f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fa:	e8 44 f9 ff ff       	call   800f43 <fd_close>
		return r;
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	89 da                	mov    %ebx,%edx
  801604:	eb 17                	jmp    80161d <open+0x86>
	}

	return fd2num(fd);
  801606:	83 ec 0c             	sub    $0xc,%esp
  801609:	ff 75 f4             	pushl  -0xc(%ebp)
  80160c:	e8 13 f8 ff ff       	call   800e24 <fd2num>
  801611:	89 c2                	mov    %eax,%edx
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	eb 05                	jmp    80161d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801618:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161d:	89 d0                	mov    %edx,%eax
  80161f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801622:	c9                   	leave  
  801623:	c3                   	ret    

00801624 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162a:	ba 00 00 00 00       	mov    $0x0,%edx
  80162f:	b8 08 00 00 00       	mov    $0x8,%eax
  801634:	e8 9a fd ff ff       	call   8013d3 <fsipc>
}
  801639:	c9                   	leave  
  80163a:	c3                   	ret    

0080163b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80163b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80163f:	7e 37                	jle    801678 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	53                   	push   %ebx
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80164a:	ff 70 04             	pushl  0x4(%eax)
  80164d:	8d 40 10             	lea    0x10(%eax),%eax
  801650:	50                   	push   %eax
  801651:	ff 33                	pushl  (%ebx)
  801653:	e8 82 fb ff ff       	call   8011da <write>
		if (result > 0)
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	7e 03                	jle    801662 <writebuf+0x27>
			b->result += result;
  80165f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801662:	3b 43 04             	cmp    0x4(%ebx),%eax
  801665:	74 0d                	je     801674 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801667:	85 c0                	test   %eax,%eax
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
  80166e:	0f 4f c2             	cmovg  %edx,%eax
  801671:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801677:	c9                   	leave  
  801678:	f3 c3                	repz ret 

0080167a <putch>:

static void
putch(int ch, void *thunk)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801684:	8b 53 04             	mov    0x4(%ebx),%edx
  801687:	8d 42 01             	lea    0x1(%edx),%eax
  80168a:	89 43 04             	mov    %eax,0x4(%ebx)
  80168d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801690:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801694:	3d 00 01 00 00       	cmp    $0x100,%eax
  801699:	75 0e                	jne    8016a9 <putch+0x2f>
		writebuf(b);
  80169b:	89 d8                	mov    %ebx,%eax
  80169d:	e8 99 ff ff ff       	call   80163b <writebuf>
		b->idx = 0;
  8016a2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016a9:	83 c4 04             	add    $0x4,%esp
  8016ac:	5b                   	pop    %ebx
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8016c1:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8016c8:	00 00 00 
	b.result = 0;
  8016cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016d2:	00 00 00 
	b.error = 1;
  8016d5:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016dc:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016eb:	50                   	push   %eax
  8016ec:	68 7a 16 80 00       	push   $0x80167a
  8016f1:	e8 ad ec ff ff       	call   8003a3 <vprintfmt>
	if (b.idx > 0)
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801700:	7e 0b                	jle    80170d <vfprintf+0x5e>
		writebuf(&b);
  801702:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801708:	e8 2e ff ff ff       	call   80163b <writebuf>

	return (b.result ? b.result : b.error);
  80170d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801713:	85 c0                	test   %eax,%eax
  801715:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801724:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801727:	50                   	push   %eax
  801728:	ff 75 0c             	pushl  0xc(%ebp)
  80172b:	ff 75 08             	pushl  0x8(%ebp)
  80172e:	e8 7c ff ff ff       	call   8016af <vfprintf>
	va_end(ap);

	return cnt;
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <printf>:

int
printf(const char *fmt, ...)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80173b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80173e:	50                   	push   %eax
  80173f:	ff 75 08             	pushl  0x8(%ebp)
  801742:	6a 01                	push   $0x1
  801744:	e8 66 ff ff ff       	call   8016af <vfprintf>
	va_end(ap);

	return cnt;
}
  801749:	c9                   	leave  
  80174a:	c3                   	ret    

0080174b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80174b:	55                   	push   %ebp
  80174c:	89 e5                	mov    %esp,%ebp
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	ff 75 08             	pushl  0x8(%ebp)
  801759:	e8 d6 f6 ff ff       	call   800e34 <fd2data>
  80175e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801760:	83 c4 08             	add    $0x8,%esp
  801763:	68 d3 28 80 00       	push   $0x8028d3
  801768:	53                   	push   %ebx
  801769:	e8 a3 f0 ff ff       	call   800811 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80176e:	8b 46 04             	mov    0x4(%esi),%eax
  801771:	2b 06                	sub    (%esi),%eax
  801773:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801779:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801780:	00 00 00 
	stat->st_dev = &devpipe;
  801783:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80178a:	30 80 00 
	return 0;
}
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
  801792:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	53                   	push   %ebx
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017a3:	53                   	push   %ebx
  8017a4:	6a 00                	push   $0x0
  8017a6:	e8 ee f4 ff ff       	call   800c99 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017ab:	89 1c 24             	mov    %ebx,(%esp)
  8017ae:	e8 81 f6 ff ff       	call   800e34 <fd2data>
  8017b3:	83 c4 08             	add    $0x8,%esp
  8017b6:	50                   	push   %eax
  8017b7:	6a 00                	push   $0x0
  8017b9:	e8 db f4 ff ff       	call   800c99 <sys_page_unmap>
}
  8017be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	57                   	push   %edi
  8017c7:	56                   	push   %esi
  8017c8:	53                   	push   %ebx
  8017c9:	83 ec 1c             	sub    $0x1c,%esp
  8017cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017cf:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017d1:	a1 20 60 80 00       	mov    0x806020,%eax
  8017d6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8017df:	e8 ab 09 00 00       	call   80218f <pageref>
  8017e4:	89 c3                	mov    %eax,%ebx
  8017e6:	89 3c 24             	mov    %edi,(%esp)
  8017e9:	e8 a1 09 00 00       	call   80218f <pageref>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	39 c3                	cmp    %eax,%ebx
  8017f3:	0f 94 c1             	sete   %cl
  8017f6:	0f b6 c9             	movzbl %cl,%ecx
  8017f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017fc:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801802:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801805:	39 ce                	cmp    %ecx,%esi
  801807:	74 1b                	je     801824 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801809:	39 c3                	cmp    %eax,%ebx
  80180b:	75 c4                	jne    8017d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80180d:	8b 42 58             	mov    0x58(%edx),%eax
  801810:	ff 75 e4             	pushl  -0x1c(%ebp)
  801813:	50                   	push   %eax
  801814:	56                   	push   %esi
  801815:	68 da 28 80 00       	push   $0x8028da
  80181a:	e8 4d ea ff ff       	call   80026c <cprintf>
  80181f:	83 c4 10             	add    $0x10,%esp
  801822:	eb ad                	jmp    8017d1 <_pipeisclosed+0xe>
	}
}
  801824:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801827:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5f                   	pop    %edi
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	57                   	push   %edi
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	83 ec 28             	sub    $0x28,%esp
  801838:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80183b:	56                   	push   %esi
  80183c:	e8 f3 f5 ff ff       	call   800e34 <fd2data>
  801841:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	bf 00 00 00 00       	mov    $0x0,%edi
  80184b:	eb 4b                	jmp    801898 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80184d:	89 da                	mov    %ebx,%edx
  80184f:	89 f0                	mov    %esi,%eax
  801851:	e8 6d ff ff ff       	call   8017c3 <_pipeisclosed>
  801856:	85 c0                	test   %eax,%eax
  801858:	75 48                	jne    8018a2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80185a:	e8 96 f3 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80185f:	8b 43 04             	mov    0x4(%ebx),%eax
  801862:	8b 0b                	mov    (%ebx),%ecx
  801864:	8d 51 20             	lea    0x20(%ecx),%edx
  801867:	39 d0                	cmp    %edx,%eax
  801869:	73 e2                	jae    80184d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80186b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80186e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801872:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801875:	89 c2                	mov    %eax,%edx
  801877:	c1 fa 1f             	sar    $0x1f,%edx
  80187a:	89 d1                	mov    %edx,%ecx
  80187c:	c1 e9 1b             	shr    $0x1b,%ecx
  80187f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801882:	83 e2 1f             	and    $0x1f,%edx
  801885:	29 ca                	sub    %ecx,%edx
  801887:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80188b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80188f:	83 c0 01             	add    $0x1,%eax
  801892:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801895:	83 c7 01             	add    $0x1,%edi
  801898:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80189b:	75 c2                	jne    80185f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80189d:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a0:	eb 05                	jmp    8018a7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018a2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018aa:	5b                   	pop    %ebx
  8018ab:	5e                   	pop    %esi
  8018ac:	5f                   	pop    %edi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	57                   	push   %edi
  8018b3:	56                   	push   %esi
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 18             	sub    $0x18,%esp
  8018b8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8018bb:	57                   	push   %edi
  8018bc:	e8 73 f5 ff ff       	call   800e34 <fd2data>
  8018c1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018cb:	eb 3d                	jmp    80190a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8018cd:	85 db                	test   %ebx,%ebx
  8018cf:	74 04                	je     8018d5 <devpipe_read+0x26>
				return i;
  8018d1:	89 d8                	mov    %ebx,%eax
  8018d3:	eb 44                	jmp    801919 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018d5:	89 f2                	mov    %esi,%edx
  8018d7:	89 f8                	mov    %edi,%eax
  8018d9:	e8 e5 fe ff ff       	call   8017c3 <_pipeisclosed>
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	75 32                	jne    801914 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018e2:	e8 0e f3 ff ff       	call   800bf5 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018e7:	8b 06                	mov    (%esi),%eax
  8018e9:	3b 46 04             	cmp    0x4(%esi),%eax
  8018ec:	74 df                	je     8018cd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018ee:	99                   	cltd   
  8018ef:	c1 ea 1b             	shr    $0x1b,%edx
  8018f2:	01 d0                	add    %edx,%eax
  8018f4:	83 e0 1f             	and    $0x1f,%eax
  8018f7:	29 d0                	sub    %edx,%eax
  8018f9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801901:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801904:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801907:	83 c3 01             	add    $0x1,%ebx
  80190a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80190d:	75 d8                	jne    8018e7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80190f:	8b 45 10             	mov    0x10(%ebp),%eax
  801912:	eb 05                	jmp    801919 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801914:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801919:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80191c:	5b                   	pop    %ebx
  80191d:	5e                   	pop    %esi
  80191e:	5f                   	pop    %edi
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	e8 19 f5 ff ff       	call   800e4b <fd_alloc>
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	89 c2                	mov    %eax,%edx
  801937:	85 c0                	test   %eax,%eax
  801939:	0f 88 2c 01 00 00    	js     801a6b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80193f:	83 ec 04             	sub    $0x4,%esp
  801942:	68 07 04 00 00       	push   $0x407
  801947:	ff 75 f4             	pushl  -0xc(%ebp)
  80194a:	6a 00                	push   $0x0
  80194c:	e8 c3 f2 ff ff       	call   800c14 <sys_page_alloc>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	89 c2                	mov    %eax,%edx
  801956:	85 c0                	test   %eax,%eax
  801958:	0f 88 0d 01 00 00    	js     801a6b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801964:	50                   	push   %eax
  801965:	e8 e1 f4 ff ff       	call   800e4b <fd_alloc>
  80196a:	89 c3                	mov    %eax,%ebx
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	85 c0                	test   %eax,%eax
  801971:	0f 88 e2 00 00 00    	js     801a59 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801977:	83 ec 04             	sub    $0x4,%esp
  80197a:	68 07 04 00 00       	push   $0x407
  80197f:	ff 75 f0             	pushl  -0x10(%ebp)
  801982:	6a 00                	push   $0x0
  801984:	e8 8b f2 ff ff       	call   800c14 <sys_page_alloc>
  801989:	89 c3                	mov    %eax,%ebx
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	0f 88 c3 00 00 00    	js     801a59 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801996:	83 ec 0c             	sub    $0xc,%esp
  801999:	ff 75 f4             	pushl  -0xc(%ebp)
  80199c:	e8 93 f4 ff ff       	call   800e34 <fd2data>
  8019a1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019a3:	83 c4 0c             	add    $0xc,%esp
  8019a6:	68 07 04 00 00       	push   $0x407
  8019ab:	50                   	push   %eax
  8019ac:	6a 00                	push   $0x0
  8019ae:	e8 61 f2 ff ff       	call   800c14 <sys_page_alloc>
  8019b3:	89 c3                	mov    %eax,%ebx
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	0f 88 89 00 00 00    	js     801a49 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019c6:	e8 69 f4 ff ff       	call   800e34 <fd2data>
  8019cb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019d2:	50                   	push   %eax
  8019d3:	6a 00                	push   $0x0
  8019d5:	56                   	push   %esi
  8019d6:	6a 00                	push   $0x0
  8019d8:	e8 7a f2 ff ff       	call   800c57 <sys_page_map>
  8019dd:	89 c3                	mov    %eax,%ebx
  8019df:	83 c4 20             	add    $0x20,%esp
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	78 55                	js     801a3b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019e6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ef:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019fb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a04:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a09:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a10:	83 ec 0c             	sub    $0xc,%esp
  801a13:	ff 75 f4             	pushl  -0xc(%ebp)
  801a16:	e8 09 f4 ff ff       	call   800e24 <fd2num>
  801a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a1e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a20:	83 c4 04             	add    $0x4,%esp
  801a23:	ff 75 f0             	pushl  -0x10(%ebp)
  801a26:	e8 f9 f3 ff ff       	call   800e24 <fd2num>
  801a2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a2e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	ba 00 00 00 00       	mov    $0x0,%edx
  801a39:	eb 30                	jmp    801a6b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a3b:	83 ec 08             	sub    $0x8,%esp
  801a3e:	56                   	push   %esi
  801a3f:	6a 00                	push   $0x0
  801a41:	e8 53 f2 ff ff       	call   800c99 <sys_page_unmap>
  801a46:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a49:	83 ec 08             	sub    $0x8,%esp
  801a4c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a4f:	6a 00                	push   $0x0
  801a51:	e8 43 f2 ff ff       	call   800c99 <sys_page_unmap>
  801a56:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a59:	83 ec 08             	sub    $0x8,%esp
  801a5c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5f:	6a 00                	push   $0x0
  801a61:	e8 33 f2 ff ff       	call   800c99 <sys_page_unmap>
  801a66:	83 c4 10             	add    $0x10,%esp
  801a69:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a6b:	89 d0                	mov    %edx,%eax
  801a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7d:	50                   	push   %eax
  801a7e:	ff 75 08             	pushl  0x8(%ebp)
  801a81:	e8 14 f4 ff ff       	call   800e9a <fd_lookup>
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 18                	js     801aa5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	ff 75 f4             	pushl  -0xc(%ebp)
  801a93:	e8 9c f3 ff ff       	call   800e34 <fd2data>
	return _pipeisclosed(fd, p);
  801a98:	89 c2                	mov    %eax,%edx
  801a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9d:	e8 21 fd ff ff       	call   8017c3 <_pipeisclosed>
  801aa2:	83 c4 10             	add    $0x10,%esp
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aad:	68 f2 28 80 00       	push   $0x8028f2
  801ab2:	ff 75 0c             	pushl  0xc(%ebp)
  801ab5:	e8 57 ed ff ff       	call   800811 <strcpy>
	return 0;
}
  801aba:	b8 00 00 00 00       	mov    $0x0,%eax
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 10             	sub    $0x10,%esp
  801ac8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801acb:	53                   	push   %ebx
  801acc:	e8 be 06 00 00       	call   80218f <pageref>
  801ad1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ad4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ad9:	83 f8 01             	cmp    $0x1,%eax
  801adc:	75 10                	jne    801aee <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ade:	83 ec 0c             	sub    $0xc,%esp
  801ae1:	ff 73 0c             	pushl  0xc(%ebx)
  801ae4:	e8 c0 02 00 00       	call   801da9 <nsipc_close>
  801ae9:	89 c2                	mov    %eax,%edx
  801aeb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801aee:	89 d0                	mov    %edx,%eax
  801af0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801afb:	6a 00                	push   $0x0
  801afd:	ff 75 10             	pushl  0x10(%ebp)
  801b00:	ff 75 0c             	pushl  0xc(%ebp)
  801b03:	8b 45 08             	mov    0x8(%ebp),%eax
  801b06:	ff 70 0c             	pushl  0xc(%eax)
  801b09:	e8 78 03 00 00       	call   801e86 <nsipc_send>
}
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b16:	6a 00                	push   $0x0
  801b18:	ff 75 10             	pushl  0x10(%ebp)
  801b1b:	ff 75 0c             	pushl  0xc(%ebp)
  801b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b21:	ff 70 0c             	pushl  0xc(%eax)
  801b24:	e8 f1 02 00 00       	call   801e1a <nsipc_recv>
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b31:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b34:	52                   	push   %edx
  801b35:	50                   	push   %eax
  801b36:	e8 5f f3 ff ff       	call   800e9a <fd_lookup>
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 17                	js     801b59 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b45:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801b4b:	39 08                	cmp    %ecx,(%eax)
  801b4d:	75 05                	jne    801b54 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b4f:	8b 40 0c             	mov    0xc(%eax),%eax
  801b52:	eb 05                	jmp    801b59 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b54:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	56                   	push   %esi
  801b5f:	53                   	push   %ebx
  801b60:	83 ec 1c             	sub    $0x1c,%esp
  801b63:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b68:	50                   	push   %eax
  801b69:	e8 dd f2 ff ff       	call   800e4b <fd_alloc>
  801b6e:	89 c3                	mov    %eax,%ebx
  801b70:	83 c4 10             	add    $0x10,%esp
  801b73:	85 c0                	test   %eax,%eax
  801b75:	78 1b                	js     801b92 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b77:	83 ec 04             	sub    $0x4,%esp
  801b7a:	68 07 04 00 00       	push   $0x407
  801b7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b82:	6a 00                	push   $0x0
  801b84:	e8 8b f0 ff ff       	call   800c14 <sys_page_alloc>
  801b89:	89 c3                	mov    %eax,%ebx
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	79 10                	jns    801ba2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b92:	83 ec 0c             	sub    $0xc,%esp
  801b95:	56                   	push   %esi
  801b96:	e8 0e 02 00 00       	call   801da9 <nsipc_close>
		return r;
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	89 d8                	mov    %ebx,%eax
  801ba0:	eb 24                	jmp    801bc6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ba2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bab:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bb7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bba:	83 ec 0c             	sub    $0xc,%esp
  801bbd:	50                   	push   %eax
  801bbe:	e8 61 f2 ff ff       	call   800e24 <fd2num>
  801bc3:	83 c4 10             	add    $0x10,%esp
}
  801bc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc9:	5b                   	pop    %ebx
  801bca:	5e                   	pop    %esi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	e8 50 ff ff ff       	call   801b2b <fd2sockid>
		return r;
  801bdb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 1f                	js     801c00 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801be1:	83 ec 04             	sub    $0x4,%esp
  801be4:	ff 75 10             	pushl  0x10(%ebp)
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	50                   	push   %eax
  801beb:	e8 12 01 00 00       	call   801d02 <nsipc_accept>
  801bf0:	83 c4 10             	add    $0x10,%esp
		return r;
  801bf3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	78 07                	js     801c00 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bf9:	e8 5d ff ff ff       	call   801b5b <alloc_sockfd>
  801bfe:	89 c1                	mov    %eax,%ecx
}
  801c00:	89 c8                	mov    %ecx,%eax
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0d:	e8 19 ff ff ff       	call   801b2b <fd2sockid>
  801c12:	85 c0                	test   %eax,%eax
  801c14:	78 12                	js     801c28 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	ff 75 10             	pushl  0x10(%ebp)
  801c1c:	ff 75 0c             	pushl  0xc(%ebp)
  801c1f:	50                   	push   %eax
  801c20:	e8 2d 01 00 00       	call   801d52 <nsipc_bind>
  801c25:	83 c4 10             	add    $0x10,%esp
}
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    

00801c2a <shutdown>:

int
shutdown(int s, int how)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	e8 f3 fe ff ff       	call   801b2b <fd2sockid>
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	78 0f                	js     801c4b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	ff 75 0c             	pushl  0xc(%ebp)
  801c42:	50                   	push   %eax
  801c43:	e8 3f 01 00 00       	call   801d87 <nsipc_shutdown>
  801c48:	83 c4 10             	add    $0x10,%esp
}
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	e8 d0 fe ff ff       	call   801b2b <fd2sockid>
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 12                	js     801c71 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	ff 75 10             	pushl  0x10(%ebp)
  801c65:	ff 75 0c             	pushl  0xc(%ebp)
  801c68:	50                   	push   %eax
  801c69:	e8 55 01 00 00       	call   801dc3 <nsipc_connect>
  801c6e:	83 c4 10             	add    $0x10,%esp
}
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    

00801c73 <listen>:

int
listen(int s, int backlog)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c79:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7c:	e8 aa fe ff ff       	call   801b2b <fd2sockid>
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 0f                	js     801c94 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c85:	83 ec 08             	sub    $0x8,%esp
  801c88:	ff 75 0c             	pushl  0xc(%ebp)
  801c8b:	50                   	push   %eax
  801c8c:	e8 67 01 00 00       	call   801df8 <nsipc_listen>
  801c91:	83 c4 10             	add    $0x10,%esp
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c9c:	ff 75 10             	pushl  0x10(%ebp)
  801c9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ca2:	ff 75 08             	pushl  0x8(%ebp)
  801ca5:	e8 3a 02 00 00       	call   801ee4 <nsipc_socket>
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	85 c0                	test   %eax,%eax
  801caf:	78 05                	js     801cb6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cb1:	e8 a5 fe ff ff       	call   801b5b <alloc_sockfd>
}
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    

00801cb8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	53                   	push   %ebx
  801cbc:	83 ec 04             	sub    $0x4,%esp
  801cbf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cc1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cc8:	75 12                	jne    801cdc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	6a 02                	push   $0x2
  801ccf:	e8 82 04 00 00       	call   802156 <ipc_find_env>
  801cd4:	a3 04 40 80 00       	mov    %eax,0x804004
  801cd9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cdc:	6a 07                	push   $0x7
  801cde:	68 00 80 80 00       	push   $0x808000
  801ce3:	53                   	push   %ebx
  801ce4:	ff 35 04 40 80 00    	pushl  0x804004
  801cea:	e8 18 04 00 00       	call   802107 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cef:	83 c4 0c             	add    $0xc,%esp
  801cf2:	6a 00                	push   $0x0
  801cf4:	6a 00                	push   $0x0
  801cf6:	6a 00                	push   $0x0
  801cf8:	e8 94 03 00 00       	call   802091 <ipc_recv>
}
  801cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	56                   	push   %esi
  801d06:	53                   	push   %ebx
  801d07:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0d:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d12:	8b 06                	mov    (%esi),%eax
  801d14:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d19:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1e:	e8 95 ff ff ff       	call   801cb8 <nsipc>
  801d23:	89 c3                	mov    %eax,%ebx
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 20                	js     801d49 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d29:	83 ec 04             	sub    $0x4,%esp
  801d2c:	ff 35 10 80 80 00    	pushl  0x808010
  801d32:	68 00 80 80 00       	push   $0x808000
  801d37:	ff 75 0c             	pushl  0xc(%ebp)
  801d3a:	e8 64 ec ff ff       	call   8009a3 <memmove>
		*addrlen = ret->ret_addrlen;
  801d3f:	a1 10 80 80 00       	mov    0x808010,%eax
  801d44:	89 06                	mov    %eax,(%esi)
  801d46:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d49:	89 d8                	mov    %ebx,%eax
  801d4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4e:	5b                   	pop    %ebx
  801d4f:	5e                   	pop    %esi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    

00801d52 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	53                   	push   %ebx
  801d56:	83 ec 08             	sub    $0x8,%esp
  801d59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d64:	53                   	push   %ebx
  801d65:	ff 75 0c             	pushl  0xc(%ebp)
  801d68:	68 04 80 80 00       	push   $0x808004
  801d6d:	e8 31 ec ff ff       	call   8009a3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d72:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  801d78:	b8 02 00 00 00       	mov    $0x2,%eax
  801d7d:	e8 36 ff ff ff       	call   801cb8 <nsipc>
}
  801d82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d90:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  801d95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d98:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  801d9d:	b8 03 00 00 00       	mov    $0x3,%eax
  801da2:	e8 11 ff ff ff       	call   801cb8 <nsipc>
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <nsipc_close>:

int
nsipc_close(int s)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801daf:	8b 45 08             	mov    0x8(%ebp),%eax
  801db2:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801db7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dbc:	e8 f7 fe ff ff       	call   801cb8 <nsipc>
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	53                   	push   %ebx
  801dc7:	83 ec 08             	sub    $0x8,%esp
  801dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd0:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dd5:	53                   	push   %ebx
  801dd6:	ff 75 0c             	pushl  0xc(%ebp)
  801dd9:	68 04 80 80 00       	push   $0x808004
  801dde:	e8 c0 eb ff ff       	call   8009a3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801de3:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  801de9:	b8 05 00 00 00       	mov    $0x5,%eax
  801dee:	e8 c5 fe ff ff       	call   801cb8 <nsipc>
}
  801df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801e01:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  801e06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e09:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801e0e:	b8 06 00 00 00       	mov    $0x6,%eax
  801e13:	e8 a0 fe ff ff       	call   801cb8 <nsipc>
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	56                   	push   %esi
  801e1e:	53                   	push   %ebx
  801e1f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801e2a:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  801e30:	8b 45 14             	mov    0x14(%ebp),%eax
  801e33:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e38:	b8 07 00 00 00       	mov    $0x7,%eax
  801e3d:	e8 76 fe ff ff       	call   801cb8 <nsipc>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	85 c0                	test   %eax,%eax
  801e46:	78 35                	js     801e7d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e48:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e4d:	7f 04                	jg     801e53 <nsipc_recv+0x39>
  801e4f:	39 c6                	cmp    %eax,%esi
  801e51:	7d 16                	jge    801e69 <nsipc_recv+0x4f>
  801e53:	68 fe 28 80 00       	push   $0x8028fe
  801e58:	68 a7 28 80 00       	push   $0x8028a7
  801e5d:	6a 62                	push   $0x62
  801e5f:	68 13 29 80 00       	push   $0x802913
  801e64:	e8 2a e3 ff ff       	call   800193 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e69:	83 ec 04             	sub    $0x4,%esp
  801e6c:	50                   	push   %eax
  801e6d:	68 00 80 80 00       	push   $0x808000
  801e72:	ff 75 0c             	pushl  0xc(%ebp)
  801e75:	e8 29 eb ff ff       	call   8009a3 <memmove>
  801e7a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e7d:	89 d8                	mov    %ebx,%eax
  801e7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e82:	5b                   	pop    %ebx
  801e83:	5e                   	pop    %esi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	53                   	push   %ebx
  801e8a:	83 ec 04             	sub    $0x4,%esp
  801e8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  801e98:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e9e:	7e 16                	jle    801eb6 <nsipc_send+0x30>
  801ea0:	68 1f 29 80 00       	push   $0x80291f
  801ea5:	68 a7 28 80 00       	push   $0x8028a7
  801eaa:	6a 6d                	push   $0x6d
  801eac:	68 13 29 80 00       	push   $0x802913
  801eb1:	e8 dd e2 ff ff       	call   800193 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801eb6:	83 ec 04             	sub    $0x4,%esp
  801eb9:	53                   	push   %ebx
  801eba:	ff 75 0c             	pushl  0xc(%ebp)
  801ebd:	68 0c 80 80 00       	push   $0x80800c
  801ec2:	e8 dc ea ff ff       	call   8009a3 <memmove>
	nsipcbuf.send.req_size = size;
  801ec7:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801ecd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ed0:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801ed5:	b8 08 00 00 00       	mov    $0x8,%eax
  801eda:	e8 d9 fd ff ff       	call   801cb8 <nsipc>
}
  801edf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eea:	8b 45 08             	mov    0x8(%ebp),%eax
  801eed:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef5:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  801efa:	8b 45 10             	mov    0x10(%ebp),%eax
  801efd:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801f02:	b8 09 00 00 00       	mov    $0x9,%eax
  801f07:	e8 ac fd ff ff       	call   801cb8 <nsipc>
}
  801f0c:	c9                   	leave  
  801f0d:	c3                   	ret    

00801f0e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f11:	b8 00 00 00 00       	mov    $0x0,%eax
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f1e:	68 2b 29 80 00       	push   $0x80292b
  801f23:	ff 75 0c             	pushl  0xc(%ebp)
  801f26:	e8 e6 e8 ff ff       	call   800811 <strcpy>
	return 0;
}
  801f2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f30:	c9                   	leave  
  801f31:	c3                   	ret    

00801f32 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f3e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f43:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f49:	eb 2d                	jmp    801f78 <devcons_write+0x46>
		m = n - tot;
  801f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f4e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801f50:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f53:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801f58:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f5b:	83 ec 04             	sub    $0x4,%esp
  801f5e:	53                   	push   %ebx
  801f5f:	03 45 0c             	add    0xc(%ebp),%eax
  801f62:	50                   	push   %eax
  801f63:	57                   	push   %edi
  801f64:	e8 3a ea ff ff       	call   8009a3 <memmove>
		sys_cputs(buf, m);
  801f69:	83 c4 08             	add    $0x8,%esp
  801f6c:	53                   	push   %ebx
  801f6d:	57                   	push   %edi
  801f6e:	e8 e5 eb ff ff       	call   800b58 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f73:	01 de                	add    %ebx,%esi
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	89 f0                	mov    %esi,%eax
  801f7a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f7d:	72 cc                	jb     801f4b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f82:	5b                   	pop    %ebx
  801f83:	5e                   	pop    %esi
  801f84:	5f                   	pop    %edi
  801f85:	5d                   	pop    %ebp
  801f86:	c3                   	ret    

00801f87 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 08             	sub    $0x8,%esp
  801f8d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f92:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f96:	74 2a                	je     801fc2 <devcons_read+0x3b>
  801f98:	eb 05                	jmp    801f9f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f9a:	e8 56 ec ff ff       	call   800bf5 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f9f:	e8 d2 eb ff ff       	call   800b76 <sys_cgetc>
  801fa4:	85 c0                	test   %eax,%eax
  801fa6:	74 f2                	je     801f9a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fa8:	85 c0                	test   %eax,%eax
  801faa:	78 16                	js     801fc2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fac:	83 f8 04             	cmp    $0x4,%eax
  801faf:	74 0c                	je     801fbd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801fb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb4:	88 02                	mov    %al,(%edx)
	return 1;
  801fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbb:	eb 05                	jmp    801fc2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801fc2:	c9                   	leave  
  801fc3:	c3                   	ret    

00801fc4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fca:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801fd0:	6a 01                	push   $0x1
  801fd2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fd5:	50                   	push   %eax
  801fd6:	e8 7d eb ff ff       	call   800b58 <sys_cputs>
}
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	c9                   	leave  
  801fdf:	c3                   	ret    

00801fe0 <getchar>:

int
getchar(void)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801fe6:	6a 01                	push   $0x1
  801fe8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801feb:	50                   	push   %eax
  801fec:	6a 00                	push   $0x0
  801fee:	e8 0d f1 ff ff       	call   801100 <read>
	if (r < 0)
  801ff3:	83 c4 10             	add    $0x10,%esp
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 0f                	js     802009 <getchar+0x29>
		return r;
	if (r < 1)
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	7e 06                	jle    802004 <getchar+0x24>
		return -E_EOF;
	return c;
  801ffe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802002:	eb 05                	jmp    802009 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802004:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802011:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802014:	50                   	push   %eax
  802015:	ff 75 08             	pushl  0x8(%ebp)
  802018:	e8 7d ee ff ff       	call   800e9a <fd_lookup>
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	85 c0                	test   %eax,%eax
  802022:	78 11                	js     802035 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802027:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80202d:	39 10                	cmp    %edx,(%eax)
  80202f:	0f 94 c0             	sete   %al
  802032:	0f b6 c0             	movzbl %al,%eax
}
  802035:	c9                   	leave  
  802036:	c3                   	ret    

00802037 <opencons>:

int
opencons(void)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80203d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802040:	50                   	push   %eax
  802041:	e8 05 ee ff ff       	call   800e4b <fd_alloc>
  802046:	83 c4 10             	add    $0x10,%esp
		return r;
  802049:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 3e                	js     80208d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80204f:	83 ec 04             	sub    $0x4,%esp
  802052:	68 07 04 00 00       	push   $0x407
  802057:	ff 75 f4             	pushl  -0xc(%ebp)
  80205a:	6a 00                	push   $0x0
  80205c:	e8 b3 eb ff ff       	call   800c14 <sys_page_alloc>
  802061:	83 c4 10             	add    $0x10,%esp
		return r;
  802064:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802066:	85 c0                	test   %eax,%eax
  802068:	78 23                	js     80208d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80206a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802070:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802073:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802075:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802078:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80207f:	83 ec 0c             	sub    $0xc,%esp
  802082:	50                   	push   %eax
  802083:	e8 9c ed ff ff       	call   800e24 <fd2num>
  802088:	89 c2                	mov    %eax,%edx
  80208a:	83 c4 10             	add    $0x10,%esp
}
  80208d:	89 d0                	mov    %edx,%eax
  80208f:	c9                   	leave  
  802090:	c3                   	ret    

00802091 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802091:	55                   	push   %ebp
  802092:	89 e5                	mov    %esp,%ebp
  802094:	56                   	push   %esi
  802095:	53                   	push   %ebx
  802096:	8b 75 08             	mov    0x8(%ebp),%esi
  802099:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	74 0e                	je     8020b1 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	50                   	push   %eax
  8020a7:	e8 18 ed ff ff       	call   800dc4 <sys_ipc_recv>
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	eb 10                	jmp    8020c1 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	68 00 00 c0 ee       	push   $0xeec00000
  8020b9:	e8 06 ed ff ff       	call   800dc4 <sys_ipc_recv>
  8020be:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	79 17                	jns    8020dc <ipc_recv+0x4b>
		if(*from_env_store)
  8020c5:	83 3e 00             	cmpl   $0x0,(%esi)
  8020c8:	74 06                	je     8020d0 <ipc_recv+0x3f>
			*from_env_store = 0;
  8020ca:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8020d0:	85 db                	test   %ebx,%ebx
  8020d2:	74 2c                	je     802100 <ipc_recv+0x6f>
			*perm_store = 0;
  8020d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8020da:	eb 24                	jmp    802100 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8020dc:	85 f6                	test   %esi,%esi
  8020de:	74 0a                	je     8020ea <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8020e0:	a1 20 60 80 00       	mov    0x806020,%eax
  8020e5:	8b 40 74             	mov    0x74(%eax),%eax
  8020e8:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8020ea:	85 db                	test   %ebx,%ebx
  8020ec:	74 0a                	je     8020f8 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8020ee:	a1 20 60 80 00       	mov    0x806020,%eax
  8020f3:	8b 40 78             	mov    0x78(%eax),%eax
  8020f6:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020f8:	a1 20 60 80 00       	mov    0x806020,%eax
  8020fd:	8b 40 70             	mov    0x70(%eax),%eax
}
  802100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802103:	5b                   	pop    %ebx
  802104:	5e                   	pop    %esi
  802105:	5d                   	pop    %ebp
  802106:	c3                   	ret    

00802107 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802107:	55                   	push   %ebp
  802108:	89 e5                	mov    %esp,%ebp
  80210a:	57                   	push   %edi
  80210b:	56                   	push   %esi
  80210c:	53                   	push   %ebx
  80210d:	83 ec 0c             	sub    $0xc,%esp
  802110:	8b 7d 08             	mov    0x8(%ebp),%edi
  802113:	8b 75 0c             	mov    0xc(%ebp),%esi
  802116:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802119:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80211b:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802120:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802123:	e8 cd ea ff ff       	call   800bf5 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802128:	ff 75 14             	pushl  0x14(%ebp)
  80212b:	53                   	push   %ebx
  80212c:	56                   	push   %esi
  80212d:	57                   	push   %edi
  80212e:	e8 6e ec ff ff       	call   800da1 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802133:	89 c2                	mov    %eax,%edx
  802135:	f7 d2                	not    %edx
  802137:	c1 ea 1f             	shr    $0x1f,%edx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802140:	0f 94 c1             	sete   %cl
  802143:	09 ca                	or     %ecx,%edx
  802145:	85 c0                	test   %eax,%eax
  802147:	0f 94 c0             	sete   %al
  80214a:	38 c2                	cmp    %al,%dl
  80214c:	77 d5                	ja     802123 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  80214e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802151:	5b                   	pop    %ebx
  802152:	5e                   	pop    %esi
  802153:	5f                   	pop    %edi
  802154:	5d                   	pop    %ebp
  802155:	c3                   	ret    

00802156 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802161:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802164:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216a:	8b 52 50             	mov    0x50(%edx),%edx
  80216d:	39 ca                	cmp    %ecx,%edx
  80216f:	75 0d                	jne    80217e <ipc_find_env+0x28>
			return envs[i].env_id;
  802171:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802174:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802179:	8b 40 48             	mov    0x48(%eax),%eax
  80217c:	eb 0f                	jmp    80218d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80217e:	83 c0 01             	add    $0x1,%eax
  802181:	3d 00 04 00 00       	cmp    $0x400,%eax
  802186:	75 d9                	jne    802161 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802188:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    

0080218f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802195:	89 d0                	mov    %edx,%eax
  802197:	c1 e8 16             	shr    $0x16,%eax
  80219a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a6:	f6 c1 01             	test   $0x1,%cl
  8021a9:	74 1d                	je     8021c8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ab:	c1 ea 0c             	shr    $0xc,%edx
  8021ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021b5:	f6 c2 01             	test   $0x1,%dl
  8021b8:	74 0e                	je     8021c8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021ba:	c1 ea 0c             	shr    $0xc,%edx
  8021bd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c4:	ef 
  8021c5:	0f b7 c0             	movzwl %ax,%eax
}
  8021c8:	5d                   	pop    %ebp
  8021c9:	c3                   	ret    
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 f6                	test   %esi,%esi
  8021e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ed:	89 ca                	mov    %ecx,%edx
  8021ef:	89 f8                	mov    %edi,%eax
  8021f1:	75 3d                	jne    802230 <__udivdi3+0x60>
  8021f3:	39 cf                	cmp    %ecx,%edi
  8021f5:	0f 87 c5 00 00 00    	ja     8022c0 <__udivdi3+0xf0>
  8021fb:	85 ff                	test   %edi,%edi
  8021fd:	89 fd                	mov    %edi,%ebp
  8021ff:	75 0b                	jne    80220c <__udivdi3+0x3c>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	31 d2                	xor    %edx,%edx
  802208:	f7 f7                	div    %edi
  80220a:	89 c5                	mov    %eax,%ebp
  80220c:	89 c8                	mov    %ecx,%eax
  80220e:	31 d2                	xor    %edx,%edx
  802210:	f7 f5                	div    %ebp
  802212:	89 c1                	mov    %eax,%ecx
  802214:	89 d8                	mov    %ebx,%eax
  802216:	89 cf                	mov    %ecx,%edi
  802218:	f7 f5                	div    %ebp
  80221a:	89 c3                	mov    %eax,%ebx
  80221c:	89 d8                	mov    %ebx,%eax
  80221e:	89 fa                	mov    %edi,%edx
  802220:	83 c4 1c             	add    $0x1c,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
  802228:	90                   	nop
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	39 ce                	cmp    %ecx,%esi
  802232:	77 74                	ja     8022a8 <__udivdi3+0xd8>
  802234:	0f bd fe             	bsr    %esi,%edi
  802237:	83 f7 1f             	xor    $0x1f,%edi
  80223a:	0f 84 98 00 00 00    	je     8022d8 <__udivdi3+0x108>
  802240:	bb 20 00 00 00       	mov    $0x20,%ebx
  802245:	89 f9                	mov    %edi,%ecx
  802247:	89 c5                	mov    %eax,%ebp
  802249:	29 fb                	sub    %edi,%ebx
  80224b:	d3 e6                	shl    %cl,%esi
  80224d:	89 d9                	mov    %ebx,%ecx
  80224f:	d3 ed                	shr    %cl,%ebp
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e0                	shl    %cl,%eax
  802255:	09 ee                	or     %ebp,%esi
  802257:	89 d9                	mov    %ebx,%ecx
  802259:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225d:	89 d5                	mov    %edx,%ebp
  80225f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802263:	d3 ed                	shr    %cl,%ebp
  802265:	89 f9                	mov    %edi,%ecx
  802267:	d3 e2                	shl    %cl,%edx
  802269:	89 d9                	mov    %ebx,%ecx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	09 c2                	or     %eax,%edx
  80226f:	89 d0                	mov    %edx,%eax
  802271:	89 ea                	mov    %ebp,%edx
  802273:	f7 f6                	div    %esi
  802275:	89 d5                	mov    %edx,%ebp
  802277:	89 c3                	mov    %eax,%ebx
  802279:	f7 64 24 0c          	mull   0xc(%esp)
  80227d:	39 d5                	cmp    %edx,%ebp
  80227f:	72 10                	jb     802291 <__udivdi3+0xc1>
  802281:	8b 74 24 08          	mov    0x8(%esp),%esi
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e6                	shl    %cl,%esi
  802289:	39 c6                	cmp    %eax,%esi
  80228b:	73 07                	jae    802294 <__udivdi3+0xc4>
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	75 03                	jne    802294 <__udivdi3+0xc4>
  802291:	83 eb 01             	sub    $0x1,%ebx
  802294:	31 ff                	xor    %edi,%edi
  802296:	89 d8                	mov    %ebx,%eax
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 db                	xor    %ebx,%ebx
  8022ac:	89 d8                	mov    %ebx,%eax
  8022ae:	89 fa                	mov    %edi,%edx
  8022b0:	83 c4 1c             	add    $0x1c,%esp
  8022b3:	5b                   	pop    %ebx
  8022b4:	5e                   	pop    %esi
  8022b5:	5f                   	pop    %edi
  8022b6:	5d                   	pop    %ebp
  8022b7:	c3                   	ret    
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	f7 f7                	div    %edi
  8022c4:	31 ff                	xor    %edi,%edi
  8022c6:	89 c3                	mov    %eax,%ebx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 fa                	mov    %edi,%edx
  8022cc:	83 c4 1c             	add    $0x1c,%esp
  8022cf:	5b                   	pop    %ebx
  8022d0:	5e                   	pop    %esi
  8022d1:	5f                   	pop    %edi
  8022d2:	5d                   	pop    %ebp
  8022d3:	c3                   	ret    
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 ce                	cmp    %ecx,%esi
  8022da:	72 0c                	jb     8022e8 <__udivdi3+0x118>
  8022dc:	31 db                	xor    %ebx,%ebx
  8022de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022e2:	0f 87 34 ff ff ff    	ja     80221c <__udivdi3+0x4c>
  8022e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ed:	e9 2a ff ff ff       	jmp    80221c <__udivdi3+0x4c>
  8022f2:	66 90                	xchg   %ax,%ax
  8022f4:	66 90                	xchg   %ax,%ax
  8022f6:	66 90                	xchg   %ax,%ax
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80230b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80230f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 d2                	test   %edx,%edx
  802319:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f3                	mov    %esi,%ebx
  802323:	89 3c 24             	mov    %edi,(%esp)
  802326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80232a:	75 1c                	jne    802348 <__umoddi3+0x48>
  80232c:	39 f7                	cmp    %esi,%edi
  80232e:	76 50                	jbe    802380 <__umoddi3+0x80>
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	f7 f7                	div    %edi
  802336:	89 d0                	mov    %edx,%eax
  802338:	31 d2                	xor    %edx,%edx
  80233a:	83 c4 1c             	add    $0x1c,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5e                   	pop    %esi
  80233f:	5f                   	pop    %edi
  802340:	5d                   	pop    %ebp
  802341:	c3                   	ret    
  802342:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802348:	39 f2                	cmp    %esi,%edx
  80234a:	89 d0                	mov    %edx,%eax
  80234c:	77 52                	ja     8023a0 <__umoddi3+0xa0>
  80234e:	0f bd ea             	bsr    %edx,%ebp
  802351:	83 f5 1f             	xor    $0x1f,%ebp
  802354:	75 5a                	jne    8023b0 <__umoddi3+0xb0>
  802356:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	39 0c 24             	cmp    %ecx,(%esp)
  802363:	0f 86 d7 00 00 00    	jbe    802440 <__umoddi3+0x140>
  802369:	8b 44 24 08          	mov    0x8(%esp),%eax
  80236d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802371:	83 c4 1c             	add    $0x1c,%esp
  802374:	5b                   	pop    %ebx
  802375:	5e                   	pop    %esi
  802376:	5f                   	pop    %edi
  802377:	5d                   	pop    %ebp
  802378:	c3                   	ret    
  802379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802380:	85 ff                	test   %edi,%edi
  802382:	89 fd                	mov    %edi,%ebp
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 f0                	mov    %esi,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 c8                	mov    %ecx,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	eb 99                	jmp    802338 <__umoddi3+0x38>
  80239f:	90                   	nop
  8023a0:	89 c8                	mov    %ecx,%eax
  8023a2:	89 f2                	mov    %esi,%edx
  8023a4:	83 c4 1c             	add    $0x1c,%esp
  8023a7:	5b                   	pop    %ebx
  8023a8:	5e                   	pop    %esi
  8023a9:	5f                   	pop    %edi
  8023aa:	5d                   	pop    %ebp
  8023ab:	c3                   	ret    
  8023ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023b0:	8b 34 24             	mov    (%esp),%esi
  8023b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b8:	89 e9                	mov    %ebp,%ecx
  8023ba:	29 ef                	sub    %ebp,%edi
  8023bc:	d3 e0                	shl    %cl,%eax
  8023be:	89 f9                	mov    %edi,%ecx
  8023c0:	89 f2                	mov    %esi,%edx
  8023c2:	d3 ea                	shr    %cl,%edx
  8023c4:	89 e9                	mov    %ebp,%ecx
  8023c6:	09 c2                	or     %eax,%edx
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	89 14 24             	mov    %edx,(%esp)
  8023cd:	89 f2                	mov    %esi,%edx
  8023cf:	d3 e2                	shl    %cl,%edx
  8023d1:	89 f9                	mov    %edi,%ecx
  8023d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023db:	d3 e8                	shr    %cl,%eax
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	89 c6                	mov    %eax,%esi
  8023e1:	d3 e3                	shl    %cl,%ebx
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 d0                	mov    %edx,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	09 d8                	or     %ebx,%eax
  8023ed:	89 d3                	mov    %edx,%ebx
  8023ef:	89 f2                	mov    %esi,%edx
  8023f1:	f7 34 24             	divl   (%esp)
  8023f4:	89 d6                	mov    %edx,%esi
  8023f6:	d3 e3                	shl    %cl,%ebx
  8023f8:	f7 64 24 04          	mull   0x4(%esp)
  8023fc:	39 d6                	cmp    %edx,%esi
  8023fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802402:	89 d1                	mov    %edx,%ecx
  802404:	89 c3                	mov    %eax,%ebx
  802406:	72 08                	jb     802410 <__umoddi3+0x110>
  802408:	75 11                	jne    80241b <__umoddi3+0x11b>
  80240a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80240e:	73 0b                	jae    80241b <__umoddi3+0x11b>
  802410:	2b 44 24 04          	sub    0x4(%esp),%eax
  802414:	1b 14 24             	sbb    (%esp),%edx
  802417:	89 d1                	mov    %edx,%ecx
  802419:	89 c3                	mov    %eax,%ebx
  80241b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80241f:	29 da                	sub    %ebx,%edx
  802421:	19 ce                	sbb    %ecx,%esi
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 f0                	mov    %esi,%eax
  802427:	d3 e0                	shl    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	d3 ea                	shr    %cl,%edx
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	d3 ee                	shr    %cl,%esi
  802431:	09 d0                	or     %edx,%eax
  802433:	89 f2                	mov    %esi,%edx
  802435:	83 c4 1c             	add    $0x1c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 f9                	sub    %edi,%ecx
  802442:	19 d6                	sbb    %edx,%esi
  802444:	89 74 24 04          	mov    %esi,0x4(%esp)
  802448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80244c:	e9 18 ff ff ff       	jmp    802369 <__umoddi3+0x69>
