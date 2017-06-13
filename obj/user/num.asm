
obj/user/num.debug:     file format elf32-i386


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
  80002c:	e8 54 01 00 00       	call   800185 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <num>:
int bol = 1;
int line = 0;

void
num(int f, const char *s)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  80003e:	8d 5d f7             	lea    -0x9(%ebp),%ebx
  800041:	eb 6e                	jmp    8000b1 <num+0x7e>
		if (bol) {
  800043:	83 3d 00 30 80 00 00 	cmpl   $0x0,0x803000
  80004a:	74 28                	je     800074 <num+0x41>
			printf("%5d ", ++line);
  80004c:	a1 00 40 80 00       	mov    0x804000,%eax
  800051:	83 c0 01             	add    $0x1,%eax
  800054:	a3 00 40 80 00       	mov    %eax,0x804000
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	50                   	push   %eax
  80005d:	68 c0 24 80 00       	push   $0x8024c0
  800062:	e8 20 17 00 00       	call   801787 <printf>
			bol = 0;
  800067:	c7 05 00 30 80 00 00 	movl   $0x0,0x803000
  80006e:	00 00 00 
  800071:	83 c4 10             	add    $0x10,%esp
		}
		if ((r = write(1, &c, 1)) != 1)
  800074:	83 ec 04             	sub    $0x4,%esp
  800077:	6a 01                	push   $0x1
  800079:	53                   	push   %ebx
  80007a:	6a 01                	push   $0x1
  80007c:	e8 ab 11 00 00       	call   80122c <write>
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	83 f8 01             	cmp    $0x1,%eax
  800087:	74 18                	je     8000a1 <num+0x6e>
			panic("write error copying %s: %e", s, r);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	50                   	push   %eax
  80008d:	ff 75 0c             	pushl  0xc(%ebp)
  800090:	68 c5 24 80 00       	push   $0x8024c5
  800095:	6a 13                	push   $0x13
  800097:	68 e0 24 80 00       	push   $0x8024e0
  80009c:	e8 44 01 00 00       	call   8001e5 <_panic>
		if (c == '\n')
  8000a1:	80 7d f7 0a          	cmpb   $0xa,-0x9(%ebp)
  8000a5:	75 0a                	jne    8000b1 <num+0x7e>
			bol = 1;
  8000a7:	c7 05 00 30 80 00 01 	movl   $0x1,0x803000
  8000ae:	00 00 00 
{
	long n;
	int r;
	char c;

	while ((n = read(f, &c, 1)) > 0) {
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	6a 01                	push   $0x1
  8000b6:	53                   	push   %ebx
  8000b7:	56                   	push   %esi
  8000b8:	e8 95 10 00 00       	call   801152 <read>
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	85 c0                	test   %eax,%eax
  8000c2:	0f 8f 7b ff ff ff    	jg     800043 <num+0x10>
		if ((r = write(1, &c, 1)) != 1)
			panic("write error copying %s: %e", s, r);
		if (c == '\n')
			bol = 1;
	}
	if (n < 0)
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	79 18                	jns    8000e4 <num+0xb1>
		panic("error reading %s: %e", s, n);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	50                   	push   %eax
  8000d0:	ff 75 0c             	pushl  0xc(%ebp)
  8000d3:	68 eb 24 80 00       	push   $0x8024eb
  8000d8:	6a 18                	push   $0x18
  8000da:	68 e0 24 80 00       	push   $0x8024e0
  8000df:	e8 01 01 00 00       	call   8001e5 <_panic>
}
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
	int f, i;

	binaryname = "num";
  8000f4:	c7 05 04 30 80 00 00 	movl   $0x802500,0x803004
  8000fb:	25 80 00 
	if (argc == 1)
  8000fe:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  800102:	74 0d                	je     800111 <umain+0x26>
  800104:	8b 45 0c             	mov    0xc(%ebp),%eax
  800107:	8d 58 04             	lea    0x4(%eax),%ebx
  80010a:	bf 01 00 00 00       	mov    $0x1,%edi
  80010f:	eb 62                	jmp    800173 <umain+0x88>
		num(0, "<stdin>");
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 04 25 80 00       	push   $0x802504
  800119:	6a 00                	push   $0x0
  80011b:	e8 13 ff ff ff       	call   800033 <num>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 53                	jmp    800178 <umain+0x8d>
	else
		for (i = 1; i < argc; i++) {
			f = open(argv[i], O_RDONLY);
  800125:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 00                	push   $0x0
  80012d:	ff 33                	pushl  (%ebx)
  80012f:	e8 b5 14 00 00       	call   8015e9 <open>
  800134:	89 c6                	mov    %eax,%esi
			if (f < 0)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	85 c0                	test   %eax,%eax
  80013b:	79 1a                	jns    800157 <umain+0x6c>
				panic("can't open %s: %e", argv[i], f);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800144:	ff 30                	pushl  (%eax)
  800146:	68 0c 25 80 00       	push   $0x80250c
  80014b:	6a 27                	push   $0x27
  80014d:	68 e0 24 80 00       	push   $0x8024e0
  800152:	e8 8e 00 00 00       	call   8001e5 <_panic>
			else {
				num(f, argv[i]);
  800157:	83 ec 08             	sub    $0x8,%esp
  80015a:	ff 33                	pushl  (%ebx)
  80015c:	50                   	push   %eax
  80015d:	e8 d1 fe ff ff       	call   800033 <num>
				close(f);
  800162:	89 34 24             	mov    %esi,(%esp)
  800165:	e8 ac 0e 00 00       	call   801016 <close>

	binaryname = "num";
	if (argc == 1)
		num(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  80016a:	83 c7 01             	add    $0x1,%edi
  80016d:	83 c3 04             	add    $0x4,%ebx
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	3b 7d 08             	cmp    0x8(%ebp),%edi
  800176:	7c ad                	jl     800125 <umain+0x3a>
			else {
				num(f, argv[i]);
				close(f);
			}
		}
	exit();
  800178:	e8 4e 00 00 00       	call   8001cb <exit>
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80018d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800190:	e8 93 0a 00 00       	call   800c28 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800195:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a2:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a7:	85 db                	test   %ebx,%ebx
  8001a9:	7e 07                	jle    8001b2 <libmain+0x2d>
		binaryname = argv[0];
  8001ab:	8b 06                	mov    (%esi),%eax
  8001ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	56                   	push   %esi
  8001b6:	53                   	push   %ebx
  8001b7:	e8 2f ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8001bc:	e8 0a 00 00 00       	call   8001cb <exit>
}
  8001c1:	83 c4 10             	add    $0x10,%esp
  8001c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001d1:	e8 6b 0e 00 00       	call   801041 <close_all>
	sys_env_destroy(0);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	6a 00                	push   $0x0
  8001db:	e8 07 0a 00 00       	call   800be7 <sys_env_destroy>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8001f3:	e8 30 0a 00 00       	call   800c28 <sys_getenvid>
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 0c             	pushl  0xc(%ebp)
  8001fe:	ff 75 08             	pushl  0x8(%ebp)
  800201:	56                   	push   %esi
  800202:	50                   	push   %eax
  800203:	68 28 25 80 00       	push   $0x802528
  800208:	e8 b1 00 00 00       	call   8002be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	53                   	push   %ebx
  800211:	ff 75 10             	pushl  0x10(%ebp)
  800214:	e8 54 00 00 00       	call   80026d <vcprintf>
	cprintf("\n");
  800219:	c7 04 24 4b 29 80 00 	movl   $0x80294b,(%esp)
  800220:	e8 99 00 00 00       	call   8002be <cprintf>
  800225:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800228:	cc                   	int3   
  800229:	eb fd                	jmp    800228 <_panic+0x43>

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 13                	mov    (%ebx),%edx
  800237:	8d 42 01             	lea    0x1(%edx),%eax
  80023a:	89 03                	mov    %eax,(%ebx)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 1a                	jne    800264 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	68 ff 00 00 00       	push   $0xff
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	50                   	push   %eax
  800256:	e8 4f 09 00 00       	call   800baa <sys_cputs>
		b->idx = 0;
  80025b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800261:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800264:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800268:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800276:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027d:	00 00 00 
	b.cnt = 0;
  800280:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800287:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80028a:	ff 75 0c             	pushl  0xc(%ebp)
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800296:	50                   	push   %eax
  800297:	68 2b 02 80 00       	push   $0x80022b
  80029c:	e8 54 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a1:	83 c4 08             	add    $0x8,%esp
  8002a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002b0:	50                   	push   %eax
  8002b1:	e8 f4 08 00 00       	call   800baa <sys_cputs>

	return b.cnt;
}
  8002b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 08             	pushl  0x8(%ebp)
  8002cb:	e8 9d ff ff ff       	call   80026d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 1c             	sub    $0x1c,%esp
  8002db:	89 c7                	mov    %eax,%edi
  8002dd:	89 d6                	mov    %edx,%esi
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002f6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002f9:	39 d3                	cmp    %edx,%ebx
  8002fb:	72 05                	jb     800302 <printnum+0x30>
  8002fd:	39 45 10             	cmp    %eax,0x10(%ebp)
  800300:	77 45                	ja     800347 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	ff 75 18             	pushl  0x18(%ebp)
  800308:	8b 45 14             	mov    0x14(%ebp),%eax
  80030b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80030e:	53                   	push   %ebx
  80030f:	ff 75 10             	pushl  0x10(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	ff 75 e4             	pushl  -0x1c(%ebp)
  800318:	ff 75 e0             	pushl  -0x20(%ebp)
  80031b:	ff 75 dc             	pushl  -0x24(%ebp)
  80031e:	ff 75 d8             	pushl  -0x28(%ebp)
  800321:	e8 fa 1e 00 00       	call   802220 <__udivdi3>
  800326:	83 c4 18             	add    $0x18,%esp
  800329:	52                   	push   %edx
  80032a:	50                   	push   %eax
  80032b:	89 f2                	mov    %esi,%edx
  80032d:	89 f8                	mov    %edi,%eax
  80032f:	e8 9e ff ff ff       	call   8002d2 <printnum>
  800334:	83 c4 20             	add    $0x20,%esp
  800337:	eb 18                	jmp    800351 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	ff 75 18             	pushl  0x18(%ebp)
  800340:	ff d7                	call   *%edi
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	eb 03                	jmp    80034a <printnum+0x78>
  800347:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	85 db                	test   %ebx,%ebx
  80034f:	7f e8                	jg     800339 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	56                   	push   %esi
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	ff 75 e4             	pushl  -0x1c(%ebp)
  80035b:	ff 75 e0             	pushl  -0x20(%ebp)
  80035e:	ff 75 dc             	pushl  -0x24(%ebp)
  800361:	ff 75 d8             	pushl  -0x28(%ebp)
  800364:	e8 e7 1f 00 00       	call   802350 <__umoddi3>
  800369:	83 c4 14             	add    $0x14,%esp
  80036c:	0f be 80 4b 25 80 00 	movsbl 0x80254b(%eax),%eax
  800373:	50                   	push   %eax
  800374:	ff d7                	call   *%edi
}
  800376:	83 c4 10             	add    $0x10,%esp
  800379:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800384:	83 fa 01             	cmp    $0x1,%edx
  800387:	7e 0e                	jle    800397 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	8b 52 04             	mov    0x4(%edx),%edx
  800395:	eb 22                	jmp    8003b9 <getuint+0x38>
	else if (lflag)
  800397:	85 d2                	test   %edx,%edx
  800399:	74 10                	je     8003ab <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80039b:	8b 10                	mov    (%eax),%edx
  80039d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a0:	89 08                	mov    %ecx,(%eax)
  8003a2:	8b 02                	mov    (%edx),%eax
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a9:	eb 0e                	jmp    8003b9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003ab:	8b 10                	mov    (%eax),%edx
  8003ad:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b0:	89 08                	mov    %ecx,(%eax)
  8003b2:	8b 02                	mov    (%edx),%eax
  8003b4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 02                	mov    %al,(%edx)
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	pushl  0x10(%ebp)
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
	va_end(ap);
}
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 2c             	sub    $0x2c,%esp
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800404:	8b 7d 10             	mov    0x10(%ebp),%edi
  800407:	eb 12                	jmp    80041b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800409:	85 c0                	test   %eax,%eax
  80040b:	0f 84 a9 03 00 00    	je     8007ba <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	50                   	push   %eax
  800416:	ff d6                	call   *%esi
  800418:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	83 c7 01             	add    $0x1,%edi
  80041e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800422:	83 f8 25             	cmp    $0x25,%eax
  800425:	75 e2                	jne    800409 <vprintfmt+0x14>
  800427:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80042b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800432:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800439:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800440:	ba 00 00 00 00       	mov    $0x0,%edx
  800445:	eb 07                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80044a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8d 47 01             	lea    0x1(%edi),%eax
  800451:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800454:	0f b6 07             	movzbl (%edi),%eax
  800457:	0f b6 c8             	movzbl %al,%ecx
  80045a:	83 e8 23             	sub    $0x23,%eax
  80045d:	3c 55                	cmp    $0x55,%al
  80045f:	0f 87 3a 03 00 00    	ja     80079f <vprintfmt+0x3aa>
  800465:	0f b6 c0             	movzbl %al,%eax
  800468:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800472:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800476:	eb d6                	jmp    80044e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800483:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800486:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80048a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80048d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800490:	83 fa 09             	cmp    $0x9,%edx
  800493:	77 39                	ja     8004ce <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800495:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800498:	eb e9                	jmp    800483 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 48 04             	lea    0x4(%eax),%ecx
  8004a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ab:	eb 27                	jmp    8004d4 <vprintfmt+0xdf>
  8004ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	0f 49 c8             	cmovns %eax,%ecx
  8004ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c0:	eb 8c                	jmp    80044e <vprintfmt+0x59>
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004cc:	eb 80                	jmp    80044e <vprintfmt+0x59>
  8004ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d8:	0f 89 70 ff ff ff    	jns    80044e <vprintfmt+0x59>
				width = precision, precision = -1;
  8004de:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004eb:	e9 5e ff ff ff       	jmp    80044e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f6:	e9 53 ff ff ff       	jmp    80044e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 04             	lea    0x4(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	ff 30                	pushl  (%eax)
  80050a:	ff d6                	call   *%esi
			break;
  80050c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800512:	e9 04 ff ff ff       	jmp    80041b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 00                	mov    (%eax),%eax
  800522:	99                   	cltd   
  800523:	31 d0                	xor    %edx,%eax
  800525:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800527:	83 f8 0f             	cmp    $0xf,%eax
  80052a:	7f 0b                	jg     800537 <vprintfmt+0x142>
  80052c:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	75 18                	jne    80054f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800537:	50                   	push   %eax
  800538:	68 63 25 80 00       	push   $0x802563
  80053d:	53                   	push   %ebx
  80053e:	56                   	push   %esi
  80053f:	e8 94 fe ff ff       	call   8003d8 <printfmt>
  800544:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80054a:	e9 cc fe ff ff       	jmp    80041b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054f:	52                   	push   %edx
  800550:	68 19 29 80 00       	push   $0x802919
  800555:	53                   	push   %ebx
  800556:	56                   	push   %esi
  800557:	e8 7c fe ff ff       	call   8003d8 <printfmt>
  80055c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 b4 fe ff ff       	jmp    80041b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800572:	85 ff                	test   %edi,%edi
  800574:	b8 5c 25 80 00       	mov    $0x80255c,%eax
  800579:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80057c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800580:	0f 8e 94 00 00 00    	jle    80061a <vprintfmt+0x225>
  800586:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058a:	0f 84 98 00 00 00    	je     800628 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	ff 75 d0             	pushl  -0x30(%ebp)
  800596:	57                   	push   %edi
  800597:	e8 a6 02 00 00       	call   800842 <strnlen>
  80059c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ae:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	eb 0f                	jmp    8005c4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	83 ef 01             	sub    $0x1,%edi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f ed                	jg     8005b5 <vprintfmt+0x1c0>
  8005c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005cb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	0f 49 c1             	cmovns %ecx,%eax
  8005d8:	29 c1                	sub    %eax,%ecx
  8005da:	89 75 08             	mov    %esi,0x8(%ebp)
  8005dd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e3:	89 cb                	mov    %ecx,%ebx
  8005e5:	eb 4d                	jmp    800634 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005eb:	74 1b                	je     800608 <vprintfmt+0x213>
  8005ed:	0f be c0             	movsbl %al,%eax
  8005f0:	83 e8 20             	sub    $0x20,%eax
  8005f3:	83 f8 5e             	cmp    $0x5e,%eax
  8005f6:	76 10                	jbe    800608 <vprintfmt+0x213>
					putch('?', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 0c             	pushl  0xc(%ebp)
  8005fe:	6a 3f                	push   $0x3f
  800600:	ff 55 08             	call   *0x8(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	eb 0d                	jmp    800615 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	ff 75 0c             	pushl  0xc(%ebp)
  80060e:	52                   	push   %edx
  80060f:	ff 55 08             	call   *0x8(%ebp)
  800612:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800615:	83 eb 01             	sub    $0x1,%ebx
  800618:	eb 1a                	jmp    800634 <vprintfmt+0x23f>
  80061a:	89 75 08             	mov    %esi,0x8(%ebp)
  80061d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800620:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800623:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800626:	eb 0c                	jmp    800634 <vprintfmt+0x23f>
  800628:	89 75 08             	mov    %esi,0x8(%ebp)
  80062b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800631:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800634:	83 c7 01             	add    $0x1,%edi
  800637:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063b:	0f be d0             	movsbl %al,%edx
  80063e:	85 d2                	test   %edx,%edx
  800640:	74 23                	je     800665 <vprintfmt+0x270>
  800642:	85 f6                	test   %esi,%esi
  800644:	78 a1                	js     8005e7 <vprintfmt+0x1f2>
  800646:	83 ee 01             	sub    $0x1,%esi
  800649:	79 9c                	jns    8005e7 <vprintfmt+0x1f2>
  80064b:	89 df                	mov    %ebx,%edi
  80064d:	8b 75 08             	mov    0x8(%ebp),%esi
  800650:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800653:	eb 18                	jmp    80066d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	53                   	push   %ebx
  800659:	6a 20                	push   $0x20
  80065b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065d:	83 ef 01             	sub    $0x1,%edi
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 08                	jmp    80066d <vprintfmt+0x278>
  800665:	89 df                	mov    %ebx,%edi
  800667:	8b 75 08             	mov    0x8(%ebp),%esi
  80066a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80066d:	85 ff                	test   %edi,%edi
  80066f:	7f e4                	jg     800655 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800674:	e9 a2 fd ff ff       	jmp    80041b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800679:	83 fa 01             	cmp    $0x1,%edx
  80067c:	7e 16                	jle    800694 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 08             	lea    0x8(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 50 04             	mov    0x4(%eax),%edx
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	eb 32                	jmp    8006c6 <vprintfmt+0x2d1>
	else if (lflag)
  800694:	85 d2                	test   %edx,%edx
  800696:	74 18                	je     8006b0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 50 04             	lea    0x4(%eax),%edx
  80069e:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a6:	89 c1                	mov    %eax,%ecx
  8006a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ae:	eb 16                	jmp    8006c6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 50 04             	lea    0x4(%eax),%edx
  8006b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006be:	89 c1                	mov    %eax,%ecx
  8006c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d5:	0f 89 90 00 00 00    	jns    80076b <vprintfmt+0x376>
				putch('-', putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	6a 2d                	push   $0x2d
  8006e1:	ff d6                	call   *%esi
				num = -(long long) num;
  8006e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e9:	f7 d8                	neg    %eax
  8006eb:	83 d2 00             	adc    $0x0,%edx
  8006ee:	f7 da                	neg    %edx
  8006f0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006f8:	eb 71                	jmp    80076b <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006fa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fd:	e8 7f fc ff ff       	call   800381 <getuint>
			base = 10;
  800702:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800707:	eb 62                	jmp    80076b <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
  80070c:	e8 70 fc ff ff       	call   800381 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800718:	51                   	push   %ecx
  800719:	ff 75 e0             	pushl  -0x20(%ebp)
  80071c:	6a 08                	push   $0x8
  80071e:	52                   	push   %edx
  80071f:	50                   	push   %eax
  800720:	89 da                	mov    %ebx,%edx
  800722:	89 f0                	mov    %esi,%eax
  800724:	e8 a9 fb ff ff       	call   8002d2 <printnum>
			break;
  800729:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  80072f:	e9 e7 fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 30                	push   $0x30
  80073a:	ff d6                	call   *%esi
			putch('x', putdat);
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 78                	push   $0x78
  800742:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 50 04             	lea    0x4(%eax),%edx
  80074a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800754:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800757:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80075c:	eb 0d                	jmp    80076b <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80075e:	8d 45 14             	lea    0x14(%ebp),%eax
  800761:	e8 1b fc ff ff       	call   800381 <getuint>
			base = 16;
  800766:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80076b:	83 ec 0c             	sub    $0xc,%esp
  80076e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800772:	57                   	push   %edi
  800773:	ff 75 e0             	pushl  -0x20(%ebp)
  800776:	51                   	push   %ecx
  800777:	52                   	push   %edx
  800778:	50                   	push   %eax
  800779:	89 da                	mov    %ebx,%edx
  80077b:	89 f0                	mov    %esi,%eax
  80077d:	e8 50 fb ff ff       	call   8002d2 <printnum>
			break;
  800782:	83 c4 20             	add    $0x20,%esp
  800785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800788:	e9 8e fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80078d:	83 ec 08             	sub    $0x8,%esp
  800790:	53                   	push   %ebx
  800791:	51                   	push   %ecx
  800792:	ff d6                	call   *%esi
			break;
  800794:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800797:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80079a:	e9 7c fc ff ff       	jmp    80041b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	53                   	push   %ebx
  8007a3:	6a 25                	push   $0x25
  8007a5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 03                	jmp    8007af <vprintfmt+0x3ba>
  8007ac:	83 ef 01             	sub    $0x1,%edi
  8007af:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007b3:	75 f7                	jne    8007ac <vprintfmt+0x3b7>
  8007b5:	e9 61 fc ff ff       	jmp    80041b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5f                   	pop    %edi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	83 ec 18             	sub    $0x18,%esp
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	74 26                	je     800809 <vsnprintf+0x47>
  8007e3:	85 d2                	test   %edx,%edx
  8007e5:	7e 22                	jle    800809 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e7:	ff 75 14             	pushl  0x14(%ebp)
  8007ea:	ff 75 10             	pushl  0x10(%ebp)
  8007ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f0:	50                   	push   %eax
  8007f1:	68 bb 03 80 00       	push   $0x8003bb
  8007f6:	e8 fa fb ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	eb 05                	jmp    80080e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800809:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80080e:	c9                   	leave  
  80080f:	c3                   	ret    

00800810 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800819:	50                   	push   %eax
  80081a:	ff 75 10             	pushl  0x10(%ebp)
  80081d:	ff 75 0c             	pushl  0xc(%ebp)
  800820:	ff 75 08             	pushl  0x8(%ebp)
  800823:	e8 9a ff ff ff       	call   8007c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800828:	c9                   	leave  
  800829:	c3                   	ret    

0080082a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
  800835:	eb 03                	jmp    80083a <strlen+0x10>
		n++;
  800837:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80083a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80083e:	75 f7                	jne    800837 <strlen+0xd>
		n++;
	return n;
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	ba 00 00 00 00       	mov    $0x0,%edx
  800850:	eb 03                	jmp    800855 <strnlen+0x13>
		n++;
  800852:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800855:	39 c2                	cmp    %eax,%edx
  800857:	74 08                	je     800861 <strnlen+0x1f>
  800859:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80085d:	75 f3                	jne    800852 <strnlen+0x10>
  80085f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	83 c2 01             	add    $0x1,%edx
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800879:	88 5a ff             	mov    %bl,-0x1(%edx)
  80087c:	84 db                	test   %bl,%bl
  80087e:	75 ef                	jne    80086f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800880:	5b                   	pop    %ebx
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088a:	53                   	push   %ebx
  80088b:	e8 9a ff ff ff       	call   80082a <strlen>
  800890:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800893:	ff 75 0c             	pushl  0xc(%ebp)
  800896:	01 d8                	add    %ebx,%eax
  800898:	50                   	push   %eax
  800899:	e8 c5 ff ff ff       	call   800863 <strcpy>
	return dst;
}
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b0:	89 f3                	mov    %esi,%ebx
  8008b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b5:	89 f2                	mov    %esi,%edx
  8008b7:	eb 0f                	jmp    8008c8 <strncpy+0x23>
		*dst++ = *src;
  8008b9:	83 c2 01             	add    $0x1,%edx
  8008bc:	0f b6 01             	movzbl (%ecx),%eax
  8008bf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	39 da                	cmp    %ebx,%edx
  8008ca:	75 ed                	jne    8008b9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008cc:	89 f0                	mov    %esi,%eax
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	74 21                	je     800907 <strlcpy+0x35>
  8008e6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ea:	89 f2                	mov    %esi,%edx
  8008ec:	eb 09                	jmp    8008f7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ee:	83 c2 01             	add    $0x1,%edx
  8008f1:	83 c1 01             	add    $0x1,%ecx
  8008f4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f7:	39 c2                	cmp    %eax,%edx
  8008f9:	74 09                	je     800904 <strlcpy+0x32>
  8008fb:	0f b6 19             	movzbl (%ecx),%ebx
  8008fe:	84 db                	test   %bl,%bl
  800900:	75 ec                	jne    8008ee <strlcpy+0x1c>
  800902:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800904:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800907:	29 f0                	sub    %esi,%eax
}
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800916:	eb 06                	jmp    80091e <strcmp+0x11>
		p++, q++;
  800918:	83 c1 01             	add    $0x1,%ecx
  80091b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091e:	0f b6 01             	movzbl (%ecx),%eax
  800921:	84 c0                	test   %al,%al
  800923:	74 04                	je     800929 <strcmp+0x1c>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	74 ef                	je     800918 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 c0             	movzbl %al,%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 c3                	mov    %eax,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800942:	eb 06                	jmp    80094a <strncmp+0x17>
		n--, p++, q++;
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80094a:	39 d8                	cmp    %ebx,%eax
  80094c:	74 15                	je     800963 <strncmp+0x30>
  80094e:	0f b6 08             	movzbl (%eax),%ecx
  800951:	84 c9                	test   %cl,%cl
  800953:	74 04                	je     800959 <strncmp+0x26>
  800955:	3a 0a                	cmp    (%edx),%cl
  800957:	74 eb                	je     800944 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 00             	movzbl (%eax),%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
  800961:	eb 05                	jmp    800968 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	eb 07                	jmp    80097e <strchr+0x13>
		if (*s == c)
  800977:	38 ca                	cmp    %cl,%dl
  800979:	74 0f                	je     80098a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	0f b6 10             	movzbl (%eax),%edx
  800981:	84 d2                	test   %dl,%dl
  800983:	75 f2                	jne    800977 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800996:	eb 03                	jmp    80099b <strfind+0xf>
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 04                	je     8009a6 <strfind+0x1a>
  8009a2:	84 d2                	test   %dl,%dl
  8009a4:	75 f2                	jne    800998 <strfind+0xc>
			break;
	return (char *) s;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 36                	je     8009ee <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009be:	75 28                	jne    8009e8 <memset+0x40>
  8009c0:	f6 c1 03             	test   $0x3,%cl
  8009c3:	75 23                	jne    8009e8 <memset+0x40>
		c &= 0xFF;
  8009c5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c9:	89 d3                	mov    %edx,%ebx
  8009cb:	c1 e3 08             	shl    $0x8,%ebx
  8009ce:	89 d6                	mov    %edx,%esi
  8009d0:	c1 e6 18             	shl    $0x18,%esi
  8009d3:	89 d0                	mov    %edx,%eax
  8009d5:	c1 e0 10             	shl    $0x10,%eax
  8009d8:	09 f0                	or     %esi,%eax
  8009da:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009dc:	89 d8                	mov    %ebx,%eax
  8009de:	09 d0                	or     %edx,%eax
  8009e0:	c1 e9 02             	shr    $0x2,%ecx
  8009e3:	fc                   	cld    
  8009e4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e6:	eb 06                	jmp    8009ee <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009eb:	fc                   	cld    
  8009ec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ee:	89 f8                	mov    %edi,%eax
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a03:	39 c6                	cmp    %eax,%esi
  800a05:	73 35                	jae    800a3c <memmove+0x47>
  800a07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0a:	39 d0                	cmp    %edx,%eax
  800a0c:	73 2e                	jae    800a3c <memmove+0x47>
		s += n;
		d += n;
  800a0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a11:	89 d6                	mov    %edx,%esi
  800a13:	09 fe                	or     %edi,%esi
  800a15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1b:	75 13                	jne    800a30 <memmove+0x3b>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 0e                	jne    800a30 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a22:	83 ef 04             	sub    $0x4,%edi
  800a25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a28:	c1 e9 02             	shr    $0x2,%ecx
  800a2b:	fd                   	std    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb 09                	jmp    800a39 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a30:	83 ef 01             	sub    $0x1,%edi
  800a33:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a36:	fd                   	std    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a39:	fc                   	cld    
  800a3a:	eb 1d                	jmp    800a59 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3c:	89 f2                	mov    %esi,%edx
  800a3e:	09 c2                	or     %eax,%edx
  800a40:	f6 c2 03             	test   $0x3,%dl
  800a43:	75 0f                	jne    800a54 <memmove+0x5f>
  800a45:	f6 c1 03             	test   $0x3,%cl
  800a48:	75 0a                	jne    800a54 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
  800a4d:	89 c7                	mov    %eax,%edi
  800a4f:	fc                   	cld    
  800a50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a52:	eb 05                	jmp    800a59 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a54:	89 c7                	mov    %eax,%edi
  800a56:	fc                   	cld    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a60:	ff 75 10             	pushl  0x10(%ebp)
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	ff 75 08             	pushl  0x8(%ebp)
  800a69:	e8 87 ff ff ff       	call   8009f5 <memmove>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7b:	89 c6                	mov    %eax,%esi
  800a7d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a80:	eb 1a                	jmp    800a9c <memcmp+0x2c>
		if (*s1 != *s2)
  800a82:	0f b6 08             	movzbl (%eax),%ecx
  800a85:	0f b6 1a             	movzbl (%edx),%ebx
  800a88:	38 d9                	cmp    %bl,%cl
  800a8a:	74 0a                	je     800a96 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a8c:	0f b6 c1             	movzbl %cl,%eax
  800a8f:	0f b6 db             	movzbl %bl,%ebx
  800a92:	29 d8                	sub    %ebx,%eax
  800a94:	eb 0f                	jmp    800aa5 <memcmp+0x35>
		s1++, s2++;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9c:	39 f0                	cmp    %esi,%eax
  800a9e:	75 e2                	jne    800a82 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	53                   	push   %ebx
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ab0:	89 c1                	mov    %eax,%ecx
  800ab2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab9:	eb 0a                	jmp    800ac5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abb:	0f b6 10             	movzbl (%eax),%edx
  800abe:	39 da                	cmp    %ebx,%edx
  800ac0:	74 07                	je     800ac9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac2:	83 c0 01             	add    $0x1,%eax
  800ac5:	39 c8                	cmp    %ecx,%eax
  800ac7:	72 f2                	jb     800abb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad8:	eb 03                	jmp    800add <strtol+0x11>
		s++;
  800ada:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800add:	0f b6 01             	movzbl (%ecx),%eax
  800ae0:	3c 20                	cmp    $0x20,%al
  800ae2:	74 f6                	je     800ada <strtol+0xe>
  800ae4:	3c 09                	cmp    $0x9,%al
  800ae6:	74 f2                	je     800ada <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae8:	3c 2b                	cmp    $0x2b,%al
  800aea:	75 0a                	jne    800af6 <strtol+0x2a>
		s++;
  800aec:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800aef:	bf 00 00 00 00       	mov    $0x0,%edi
  800af4:	eb 11                	jmp    800b07 <strtol+0x3b>
  800af6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800afb:	3c 2d                	cmp    $0x2d,%al
  800afd:	75 08                	jne    800b07 <strtol+0x3b>
		s++, neg = 1;
  800aff:	83 c1 01             	add    $0x1,%ecx
  800b02:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b0d:	75 15                	jne    800b24 <strtol+0x58>
  800b0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b12:	75 10                	jne    800b24 <strtol+0x58>
  800b14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b18:	75 7c                	jne    800b96 <strtol+0xca>
		s += 2, base = 16;
  800b1a:	83 c1 02             	add    $0x2,%ecx
  800b1d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b22:	eb 16                	jmp    800b3a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b24:	85 db                	test   %ebx,%ebx
  800b26:	75 12                	jne    800b3a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b28:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b30:	75 08                	jne    800b3a <strtol+0x6e>
		s++, base = 8;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b42:	0f b6 11             	movzbl (%ecx),%edx
  800b45:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b48:	89 f3                	mov    %esi,%ebx
  800b4a:	80 fb 09             	cmp    $0x9,%bl
  800b4d:	77 08                	ja     800b57 <strtol+0x8b>
			dig = *s - '0';
  800b4f:	0f be d2             	movsbl %dl,%edx
  800b52:	83 ea 30             	sub    $0x30,%edx
  800b55:	eb 22                	jmp    800b79 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b57:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b5a:	89 f3                	mov    %esi,%ebx
  800b5c:	80 fb 19             	cmp    $0x19,%bl
  800b5f:	77 08                	ja     800b69 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b61:	0f be d2             	movsbl %dl,%edx
  800b64:	83 ea 57             	sub    $0x57,%edx
  800b67:	eb 10                	jmp    800b79 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b69:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	80 fb 19             	cmp    $0x19,%bl
  800b71:	77 16                	ja     800b89 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b73:	0f be d2             	movsbl %dl,%edx
  800b76:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b79:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b7c:	7d 0b                	jge    800b89 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b7e:	83 c1 01             	add    $0x1,%ecx
  800b81:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b85:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b87:	eb b9                	jmp    800b42 <strtol+0x76>

	if (endptr)
  800b89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8d:	74 0d                	je     800b9c <strtol+0xd0>
		*endptr = (char *) s;
  800b8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b92:	89 0e                	mov    %ecx,(%esi)
  800b94:	eb 06                	jmp    800b9c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b96:	85 db                	test   %ebx,%ebx
  800b98:	74 98                	je     800b32 <strtol+0x66>
  800b9a:	eb 9e                	jmp    800b3a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b9c:	89 c2                	mov    %eax,%edx
  800b9e:	f7 da                	neg    %edx
  800ba0:	85 ff                	test   %edi,%edi
  800ba2:	0f 45 c2             	cmovne %edx,%eax
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	89 c3                	mov    %eax,%ebx
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	89 c6                	mov    %eax,%esi
  800bc1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd8:	89 d1                	mov    %edx,%ecx
  800bda:	89 d3                	mov    %edx,%ebx
  800bdc:	89 d7                	mov    %edx,%edi
  800bde:	89 d6                	mov    %edx,%esi
  800be0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 cb                	mov    %ecx,%ebx
  800bff:	89 cf                	mov    %ecx,%edi
  800c01:	89 ce                	mov    %ecx,%esi
  800c03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7e 17                	jle    800c20 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 03                	push   $0x3
  800c0f:	68 3f 28 80 00       	push   $0x80283f
  800c14:	6a 23                	push   $0x23
  800c16:	68 5c 28 80 00       	push   $0x80285c
  800c1b:	e8 c5 f5 ff ff       	call   8001e5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c33:	b8 02 00 00 00       	mov    $0x2,%eax
  800c38:	89 d1                	mov    %edx,%ecx
  800c3a:	89 d3                	mov    %edx,%ebx
  800c3c:	89 d7                	mov    %edx,%edi
  800c3e:	89 d6                	mov    %edx,%esi
  800c40:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <sys_yield>:

void
sys_yield(void)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c52:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c57:	89 d1                	mov    %edx,%ecx
  800c59:	89 d3                	mov    %edx,%ebx
  800c5b:	89 d7                	mov    %edx,%edi
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6f:	be 00 00 00 00       	mov    $0x0,%esi
  800c74:	b8 04 00 00 00       	mov    $0x4,%eax
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c82:	89 f7                	mov    %esi,%edi
  800c84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 04                	push   $0x4
  800c90:	68 3f 28 80 00       	push   $0x80283f
  800c95:	6a 23                	push   $0x23
  800c97:	68 5c 28 80 00       	push   $0x80285c
  800c9c:	e8 44 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc3:	8b 75 18             	mov    0x18(%ebp),%esi
  800cc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 17                	jle    800ce3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	50                   	push   %eax
  800cd0:	6a 05                	push   $0x5
  800cd2:	68 3f 28 80 00       	push   $0x80283f
  800cd7:	6a 23                	push   $0x23
  800cd9:	68 5c 28 80 00       	push   $0x80285c
  800cde:	e8 02 f5 ff ff       	call   8001e5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf9:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	89 df                	mov    %ebx,%edi
  800d06:	89 de                	mov    %ebx,%esi
  800d08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 06                	push   $0x6
  800d14:	68 3f 28 80 00       	push   $0x80283f
  800d19:	6a 23                	push   $0x23
  800d1b:	68 5c 28 80 00       	push   $0x80285c
  800d20:	e8 c0 f4 ff ff       	call   8001e5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	89 df                	mov    %ebx,%edi
  800d48:	89 de                	mov    %ebx,%esi
  800d4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7e 17                	jle    800d67 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 08                	push   $0x8
  800d56:	68 3f 28 80 00       	push   $0x80283f
  800d5b:	6a 23                	push   $0x23
  800d5d:	68 5c 28 80 00       	push   $0x80285c
  800d62:	e8 7e f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	57                   	push   %edi
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	89 df                	mov    %ebx,%edi
  800d8a:	89 de                	mov    %ebx,%esi
  800d8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	7e 17                	jle    800da9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 09                	push   $0x9
  800d98:	68 3f 28 80 00       	push   $0x80283f
  800d9d:	6a 23                	push   $0x23
  800d9f:	68 5c 28 80 00       	push   $0x80285c
  800da4:	e8 3c f4 ff ff       	call   8001e5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7e 17                	jle    800deb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 0a                	push   $0xa
  800dda:	68 3f 28 80 00       	push   $0x80283f
  800ddf:	6a 23                	push   $0x23
  800de1:	68 5c 28 80 00       	push   $0x80285c
  800de6:	e8 fa f3 ff ff       	call   8001e5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	57                   	push   %edi
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	be 00 00 00 00       	mov    $0x0,%esi
  800dfe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	57                   	push   %edi
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e24:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e29:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2c:	89 cb                	mov    %ecx,%ebx
  800e2e:	89 cf                	mov    %ecx,%edi
  800e30:	89 ce                	mov    %ecx,%esi
  800e32:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e34:	85 c0                	test   %eax,%eax
  800e36:	7e 17                	jle    800e4f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	50                   	push   %eax
  800e3c:	6a 0d                	push   $0xd
  800e3e:	68 3f 28 80 00       	push   $0x80283f
  800e43:	6a 23                	push   $0x23
  800e45:	68 5c 28 80 00       	push   $0x80285c
  800e4a:	e8 96 f3 ff ff       	call   8001e5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5f                   	pop    %edi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e62:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e67:	89 d1                	mov    %edx,%ecx
  800e69:	89 d3                	mov    %edx,%ebx
  800e6b:	89 d7                	mov    %edx,%edi
  800e6d:	89 d6                	mov    %edx,%esi
  800e6f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e81:	c1 e8 0c             	shr    $0xc,%eax
}
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e96:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	c1 ea 16             	shr    $0x16,%edx
  800ead:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eb4:	f6 c2 01             	test   $0x1,%dl
  800eb7:	74 11                	je     800eca <fd_alloc+0x2d>
  800eb9:	89 c2                	mov    %eax,%edx
  800ebb:	c1 ea 0c             	shr    $0xc,%edx
  800ebe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ec5:	f6 c2 01             	test   $0x1,%dl
  800ec8:	75 09                	jne    800ed3 <fd_alloc+0x36>
			*fd_store = fd;
  800eca:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed1:	eb 17                	jmp    800eea <fd_alloc+0x4d>
  800ed3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ed8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800edd:	75 c9                	jne    800ea8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800edf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ee5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ef2:	83 f8 1f             	cmp    $0x1f,%eax
  800ef5:	77 36                	ja     800f2d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ef7:	c1 e0 0c             	shl    $0xc,%eax
  800efa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eff:	89 c2                	mov    %eax,%edx
  800f01:	c1 ea 16             	shr    $0x16,%edx
  800f04:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f0b:	f6 c2 01             	test   $0x1,%dl
  800f0e:	74 24                	je     800f34 <fd_lookup+0x48>
  800f10:	89 c2                	mov    %eax,%edx
  800f12:	c1 ea 0c             	shr    $0xc,%edx
  800f15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1c:	f6 c2 01             	test   $0x1,%dl
  800f1f:	74 1a                	je     800f3b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f24:	89 02                	mov    %eax,(%edx)
	return 0;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	eb 13                	jmp    800f40 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f32:	eb 0c                	jmp    800f40 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f34:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f39:	eb 05                	jmp    800f40 <fd_lookup+0x54>
  800f3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f4b:	ba ec 28 80 00       	mov    $0x8028ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f50:	eb 13                	jmp    800f65 <dev_lookup+0x23>
  800f52:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f55:	39 08                	cmp    %ecx,(%eax)
  800f57:	75 0c                	jne    800f65 <dev_lookup+0x23>
			*dev = devtab[i];
  800f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	eb 2e                	jmp    800f93 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f65:	8b 02                	mov    (%edx),%eax
  800f67:	85 c0                	test   %eax,%eax
  800f69:	75 e7                	jne    800f52 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f6b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800f70:	8b 40 48             	mov    0x48(%eax),%eax
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	51                   	push   %ecx
  800f77:	50                   	push   %eax
  800f78:	68 6c 28 80 00       	push   $0x80286c
  800f7d:	e8 3c f3 ff ff       	call   8002be <cprintf>
	*dev = 0;
  800f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f85:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 10             	sub    $0x10,%esp
  800f9d:	8b 75 08             	mov    0x8(%ebp),%esi
  800fa0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fad:	c1 e8 0c             	shr    $0xc,%eax
  800fb0:	50                   	push   %eax
  800fb1:	e8 36 ff ff ff       	call   800eec <fd_lookup>
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 05                	js     800fc2 <fd_close+0x2d>
	    || fd != fd2)
  800fbd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fc0:	74 0c                	je     800fce <fd_close+0x39>
		return (must_exist ? r : 0);
  800fc2:	84 db                	test   %bl,%bl
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	0f 44 c2             	cmove  %edx,%eax
  800fcc:	eb 41                	jmp    80100f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fd4:	50                   	push   %eax
  800fd5:	ff 36                	pushl  (%esi)
  800fd7:	e8 66 ff ff ff       	call   800f42 <dev_lookup>
  800fdc:	89 c3                	mov    %eax,%ebx
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	78 1a                	js     800fff <fd_close+0x6a>
		if (dev->dev_close)
  800fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fe8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800feb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	74 0b                	je     800fff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	56                   	push   %esi
  800ff8:	ff d0                	call   *%eax
  800ffa:	89 c3                	mov    %eax,%ebx
  800ffc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fff:	83 ec 08             	sub    $0x8,%esp
  801002:	56                   	push   %esi
  801003:	6a 00                	push   $0x0
  801005:	e8 e1 fc ff ff       	call   800ceb <sys_page_unmap>
	return r;
  80100a:	83 c4 10             	add    $0x10,%esp
  80100d:	89 d8                	mov    %ebx,%eax
}
  80100f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80101c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101f:	50                   	push   %eax
  801020:	ff 75 08             	pushl  0x8(%ebp)
  801023:	e8 c4 fe ff ff       	call   800eec <fd_lookup>
  801028:	83 c4 08             	add    $0x8,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 10                	js     80103f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	6a 01                	push   $0x1
  801034:	ff 75 f4             	pushl  -0xc(%ebp)
  801037:	e8 59 ff ff ff       	call   800f95 <fd_close>
  80103c:	83 c4 10             	add    $0x10,%esp
}
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <close_all>:

void
close_all(void)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	53                   	push   %ebx
  801045:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801048:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	53                   	push   %ebx
  801051:	e8 c0 ff ff ff       	call   801016 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801056:	83 c3 01             	add    $0x1,%ebx
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	83 fb 20             	cmp    $0x20,%ebx
  80105f:	75 ec                	jne    80104d <close_all+0xc>
		close(i);
}
  801061:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
  80106c:	83 ec 2c             	sub    $0x2c,%esp
  80106f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801072:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	ff 75 08             	pushl  0x8(%ebp)
  801079:	e8 6e fe ff ff       	call   800eec <fd_lookup>
  80107e:	83 c4 08             	add    $0x8,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	0f 88 c1 00 00 00    	js     80114a <dup+0xe4>
		return r;
	close(newfdnum);
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	56                   	push   %esi
  80108d:	e8 84 ff ff ff       	call   801016 <close>

	newfd = INDEX2FD(newfdnum);
  801092:	89 f3                	mov    %esi,%ebx
  801094:	c1 e3 0c             	shl    $0xc,%ebx
  801097:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80109d:	83 c4 04             	add    $0x4,%esp
  8010a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a3:	e8 de fd ff ff       	call   800e86 <fd2data>
  8010a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010aa:	89 1c 24             	mov    %ebx,(%esp)
  8010ad:	e8 d4 fd ff ff       	call   800e86 <fd2data>
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010b8:	89 f8                	mov    %edi,%eax
  8010ba:	c1 e8 16             	shr    $0x16,%eax
  8010bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c4:	a8 01                	test   $0x1,%al
  8010c6:	74 37                	je     8010ff <dup+0x99>
  8010c8:	89 f8                	mov    %edi,%eax
  8010ca:	c1 e8 0c             	shr    $0xc,%eax
  8010cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010d4:	f6 c2 01             	test   $0x1,%dl
  8010d7:	74 26                	je     8010ff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010e8:	50                   	push   %eax
  8010e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ec:	6a 00                	push   $0x0
  8010ee:	57                   	push   %edi
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 b3 fb ff ff       	call   800ca9 <sys_page_map>
  8010f6:	89 c7                	mov    %eax,%edi
  8010f8:	83 c4 20             	add    $0x20,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 2e                	js     80112d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801102:	89 d0                	mov    %edx,%eax
  801104:	c1 e8 0c             	shr    $0xc,%eax
  801107:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	25 07 0e 00 00       	and    $0xe07,%eax
  801116:	50                   	push   %eax
  801117:	53                   	push   %ebx
  801118:	6a 00                	push   $0x0
  80111a:	52                   	push   %edx
  80111b:	6a 00                	push   $0x0
  80111d:	e8 87 fb ff ff       	call   800ca9 <sys_page_map>
  801122:	89 c7                	mov    %eax,%edi
  801124:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801127:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801129:	85 ff                	test   %edi,%edi
  80112b:	79 1d                	jns    80114a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80112d:	83 ec 08             	sub    $0x8,%esp
  801130:	53                   	push   %ebx
  801131:	6a 00                	push   $0x0
  801133:	e8 b3 fb ff ff       	call   800ceb <sys_page_unmap>
	sys_page_unmap(0, nva);
  801138:	83 c4 08             	add    $0x8,%esp
  80113b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80113e:	6a 00                	push   $0x0
  801140:	e8 a6 fb ff ff       	call   800ceb <sys_page_unmap>
	return r;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	89 f8                	mov    %edi,%eax
}
  80114a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5f                   	pop    %edi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    

00801152 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	53                   	push   %ebx
  801156:	83 ec 14             	sub    $0x14,%esp
  801159:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80115c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	53                   	push   %ebx
  801161:	e8 86 fd ff ff       	call   800eec <fd_lookup>
  801166:	83 c4 08             	add    $0x8,%esp
  801169:	89 c2                	mov    %eax,%edx
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 6d                	js     8011dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116f:	83 ec 08             	sub    $0x8,%esp
  801172:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801179:	ff 30                	pushl  (%eax)
  80117b:	e8 c2 fd ff ff       	call   800f42 <dev_lookup>
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	85 c0                	test   %eax,%eax
  801185:	78 4c                	js     8011d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801187:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80118a:	8b 42 08             	mov    0x8(%edx),%eax
  80118d:	83 e0 03             	and    $0x3,%eax
  801190:	83 f8 01             	cmp    $0x1,%eax
  801193:	75 21                	jne    8011b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801195:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80119a:	8b 40 48             	mov    0x48(%eax),%eax
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	53                   	push   %ebx
  8011a1:	50                   	push   %eax
  8011a2:	68 b0 28 80 00       	push   $0x8028b0
  8011a7:	e8 12 f1 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011b4:	eb 26                	jmp    8011dc <read+0x8a>
	}
	if (!dev->dev_read)
  8011b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b9:	8b 40 08             	mov    0x8(%eax),%eax
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	74 17                	je     8011d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	ff 75 10             	pushl  0x10(%ebp)
  8011c6:	ff 75 0c             	pushl  0xc(%ebp)
  8011c9:	52                   	push   %edx
  8011ca:	ff d0                	call   *%eax
  8011cc:	89 c2                	mov    %eax,%edx
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	eb 09                	jmp    8011dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	eb 05                	jmp    8011dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011dc:	89 d0                	mov    %edx,%eax
  8011de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	57                   	push   %edi
  8011e7:	56                   	push   %esi
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f7:	eb 21                	jmp    80121a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	29 d8                	sub    %ebx,%eax
  801200:	50                   	push   %eax
  801201:	89 d8                	mov    %ebx,%eax
  801203:	03 45 0c             	add    0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	57                   	push   %edi
  801208:	e8 45 ff ff ff       	call   801152 <read>
		if (m < 0)
  80120d:	83 c4 10             	add    $0x10,%esp
  801210:	85 c0                	test   %eax,%eax
  801212:	78 10                	js     801224 <readn+0x41>
			return m;
		if (m == 0)
  801214:	85 c0                	test   %eax,%eax
  801216:	74 0a                	je     801222 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801218:	01 c3                	add    %eax,%ebx
  80121a:	39 f3                	cmp    %esi,%ebx
  80121c:	72 db                	jb     8011f9 <readn+0x16>
  80121e:	89 d8                	mov    %ebx,%eax
  801220:	eb 02                	jmp    801224 <readn+0x41>
  801222:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	53                   	push   %ebx
  801230:	83 ec 14             	sub    $0x14,%esp
  801233:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801236:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	53                   	push   %ebx
  80123b:	e8 ac fc ff ff       	call   800eec <fd_lookup>
  801240:	83 c4 08             	add    $0x8,%esp
  801243:	89 c2                	mov    %eax,%edx
  801245:	85 c0                	test   %eax,%eax
  801247:	78 68                	js     8012b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801253:	ff 30                	pushl  (%eax)
  801255:	e8 e8 fc ff ff       	call   800f42 <dev_lookup>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 47                	js     8012a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801268:	75 21                	jne    80128b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80126a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80126f:	8b 40 48             	mov    0x48(%eax),%eax
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	53                   	push   %ebx
  801276:	50                   	push   %eax
  801277:	68 cc 28 80 00       	push   $0x8028cc
  80127c:	e8 3d f0 ff ff       	call   8002be <cprintf>
		return -E_INVAL;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801289:	eb 26                	jmp    8012b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80128b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128e:	8b 52 0c             	mov    0xc(%edx),%edx
  801291:	85 d2                	test   %edx,%edx
  801293:	74 17                	je     8012ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	ff 75 10             	pushl  0x10(%ebp)
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	50                   	push   %eax
  80129f:	ff d2                	call   *%edx
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	eb 09                	jmp    8012b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a8:	89 c2                	mov    %eax,%edx
  8012aa:	eb 05                	jmp    8012b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012b1:	89 d0                	mov    %edx,%eax
  8012b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012c1:	50                   	push   %eax
  8012c2:	ff 75 08             	pushl  0x8(%ebp)
  8012c5:	e8 22 fc ff ff       	call   800eec <fd_lookup>
  8012ca:	83 c4 08             	add    $0x8,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 0e                	js     8012df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 14             	sub    $0x14,%esp
  8012e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	53                   	push   %ebx
  8012f0:	e8 f7 fb ff ff       	call   800eec <fd_lookup>
  8012f5:	83 c4 08             	add    $0x8,%esp
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 65                	js     801363 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	ff 30                	pushl  (%eax)
  80130a:	e8 33 fc ff ff       	call   800f42 <dev_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 44                	js     80135a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80131d:	75 21                	jne    801340 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80131f:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	53                   	push   %ebx
  80132b:	50                   	push   %eax
  80132c:	68 8c 28 80 00       	push   $0x80288c
  801331:	e8 88 ef ff ff       	call   8002be <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80133e:	eb 23                	jmp    801363 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801340:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801343:	8b 52 18             	mov    0x18(%edx),%edx
  801346:	85 d2                	test   %edx,%edx
  801348:	74 14                	je     80135e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	ff 75 0c             	pushl  0xc(%ebp)
  801350:	50                   	push   %eax
  801351:	ff d2                	call   *%edx
  801353:	89 c2                	mov    %eax,%edx
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	eb 09                	jmp    801363 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135a:	89 c2                	mov    %eax,%edx
  80135c:	eb 05                	jmp    801363 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80135e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801363:	89 d0                	mov    %edx,%eax
  801365:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	53                   	push   %ebx
  80136e:	83 ec 14             	sub    $0x14,%esp
  801371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801374:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801377:	50                   	push   %eax
  801378:	ff 75 08             	pushl  0x8(%ebp)
  80137b:	e8 6c fb ff ff       	call   800eec <fd_lookup>
  801380:	83 c4 08             	add    $0x8,%esp
  801383:	89 c2                	mov    %eax,%edx
  801385:	85 c0                	test   %eax,%eax
  801387:	78 58                	js     8013e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801389:	83 ec 08             	sub    $0x8,%esp
  80138c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801393:	ff 30                	pushl  (%eax)
  801395:	e8 a8 fb ff ff       	call   800f42 <dev_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 37                	js     8013d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013a8:	74 32                	je     8013dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013b4:	00 00 00 
	stat->st_isdir = 0;
  8013b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013be:	00 00 00 
	stat->st_dev = dev;
  8013c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	53                   	push   %ebx
  8013cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ce:	ff 50 14             	call   *0x14(%eax)
  8013d1:	89 c2                	mov    %eax,%edx
  8013d3:	83 c4 10             	add    $0x10,%esp
  8013d6:	eb 09                	jmp    8013e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d8:	89 c2                	mov    %eax,%edx
  8013da:	eb 05                	jmp    8013e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013e1:	89 d0                	mov    %edx,%eax
  8013e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	6a 00                	push   $0x0
  8013f2:	ff 75 08             	pushl  0x8(%ebp)
  8013f5:	e8 ef 01 00 00       	call   8015e9 <open>
  8013fa:	89 c3                	mov    %eax,%ebx
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 1b                	js     80141e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	ff 75 0c             	pushl  0xc(%ebp)
  801409:	50                   	push   %eax
  80140a:	e8 5b ff ff ff       	call   80136a <fstat>
  80140f:	89 c6                	mov    %eax,%esi
	close(fd);
  801411:	89 1c 24             	mov    %ebx,(%esp)
  801414:	e8 fd fb ff ff       	call   801016 <close>
	return r;
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	89 f0                	mov    %esi,%eax
}
  80141e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    

00801425 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	89 c6                	mov    %eax,%esi
  80142c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80142e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801435:	75 12                	jne    801449 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801437:	83 ec 0c             	sub    $0xc,%esp
  80143a:	6a 01                	push   $0x1
  80143c:	e8 67 0d 00 00       	call   8021a8 <ipc_find_env>
  801441:	a3 04 40 80 00       	mov    %eax,0x804004
  801446:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801449:	6a 07                	push   $0x7
  80144b:	68 00 50 80 00       	push   $0x805000
  801450:	56                   	push   %esi
  801451:	ff 35 04 40 80 00    	pushl  0x804004
  801457:	e8 fd 0c 00 00       	call   802159 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80145c:	83 c4 0c             	add    $0xc,%esp
  80145f:	6a 00                	push   $0x0
  801461:	53                   	push   %ebx
  801462:	6a 00                	push   $0x0
  801464:	e8 7a 0c 00 00       	call   8020e3 <ipc_recv>
}
  801469:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	8b 40 0c             	mov    0xc(%eax),%eax
  80147c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801481:	8b 45 0c             	mov    0xc(%ebp),%eax
  801484:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801489:	ba 00 00 00 00       	mov    $0x0,%edx
  80148e:	b8 02 00 00 00       	mov    $0x2,%eax
  801493:	e8 8d ff ff ff       	call   801425 <fsipc>
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014b5:	e8 6b ff ff ff       	call   801425 <fsipc>
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014db:	e8 45 ff ff ff       	call   801425 <fsipc>
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 2c                	js     801510 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	68 00 50 80 00       	push   $0x805000
  8014ec:	53                   	push   %ebx
  8014ed:	e8 71 f3 ff ff       	call   800863 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801502:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151f:	8b 55 08             	mov    0x8(%ebp),%edx
  801522:	8b 52 0c             	mov    0xc(%edx),%edx
  801525:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80152b:	a3 04 50 80 00       	mov    %eax,0x805004
  801530:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801535:	bb 08 50 80 00       	mov    $0x805008,%ebx
  80153a:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80153d:	53                   	push   %ebx
  80153e:	ff 75 0c             	pushl  0xc(%ebp)
  801541:	68 08 50 80 00       	push   $0x805008
  801546:	e8 aa f4 ff ff       	call   8009f5 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80154b:	ba 00 00 00 00       	mov    $0x0,%edx
  801550:	b8 04 00 00 00       	mov    $0x4,%eax
  801555:	e8 cb fe ff ff       	call   801425 <fsipc>
  80155a:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80155d:	85 c0                	test   %eax,%eax
  80155f:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	56                   	push   %esi
  80156b:	53                   	push   %ebx
  80156c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80156f:	8b 45 08             	mov    0x8(%ebp),%eax
  801572:	8b 40 0c             	mov    0xc(%eax),%eax
  801575:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80157a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	b8 03 00 00 00       	mov    $0x3,%eax
  80158a:	e8 96 fe ff ff       	call   801425 <fsipc>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	85 c0                	test   %eax,%eax
  801593:	78 4b                	js     8015e0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801595:	39 c6                	cmp    %eax,%esi
  801597:	73 16                	jae    8015af <devfile_read+0x48>
  801599:	68 00 29 80 00       	push   $0x802900
  80159e:	68 07 29 80 00       	push   $0x802907
  8015a3:	6a 7c                	push   $0x7c
  8015a5:	68 1c 29 80 00       	push   $0x80291c
  8015aa:	e8 36 ec ff ff       	call   8001e5 <_panic>
	assert(r <= PGSIZE);
  8015af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015b4:	7e 16                	jle    8015cc <devfile_read+0x65>
  8015b6:	68 27 29 80 00       	push   $0x802927
  8015bb:	68 07 29 80 00       	push   $0x802907
  8015c0:	6a 7d                	push   $0x7d
  8015c2:	68 1c 29 80 00       	push   $0x80291c
  8015c7:	e8 19 ec ff ff       	call   8001e5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	50                   	push   %eax
  8015d0:	68 00 50 80 00       	push   $0x805000
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	e8 18 f4 ff ff       	call   8009f5 <memmove>
	return r;
  8015dd:	83 c4 10             	add    $0x10,%esp
}
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e5:	5b                   	pop    %ebx
  8015e6:	5e                   	pop    %esi
  8015e7:	5d                   	pop    %ebp
  8015e8:	c3                   	ret    

008015e9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 20             	sub    $0x20,%esp
  8015f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015f3:	53                   	push   %ebx
  8015f4:	e8 31 f2 ff ff       	call   80082a <strlen>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801601:	7f 67                	jg     80166a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	e8 8e f8 ff ff       	call   800e9d <fd_alloc>
  80160f:	83 c4 10             	add    $0x10,%esp
		return r;
  801612:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801614:	85 c0                	test   %eax,%eax
  801616:	78 57                	js     80166f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	53                   	push   %ebx
  80161c:	68 00 50 80 00       	push   $0x805000
  801621:	e8 3d f2 ff ff       	call   800863 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801626:	8b 45 0c             	mov    0xc(%ebp),%eax
  801629:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80162e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801631:	b8 01 00 00 00       	mov    $0x1,%eax
  801636:	e8 ea fd ff ff       	call   801425 <fsipc>
  80163b:	89 c3                	mov    %eax,%ebx
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	85 c0                	test   %eax,%eax
  801642:	79 14                	jns    801658 <open+0x6f>
		fd_close(fd, 0);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	6a 00                	push   $0x0
  801649:	ff 75 f4             	pushl  -0xc(%ebp)
  80164c:	e8 44 f9 ff ff       	call   800f95 <fd_close>
		return r;
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	89 da                	mov    %ebx,%edx
  801656:	eb 17                	jmp    80166f <open+0x86>
	}

	return fd2num(fd);
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	ff 75 f4             	pushl  -0xc(%ebp)
  80165e:	e8 13 f8 ff ff       	call   800e76 <fd2num>
  801663:	89 c2                	mov    %eax,%edx
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	eb 05                	jmp    80166f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80166a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80166f:	89 d0                	mov    %edx,%eax
  801671:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80167c:	ba 00 00 00 00       	mov    $0x0,%edx
  801681:	b8 08 00 00 00       	mov    $0x8,%eax
  801686:	e8 9a fd ff ff       	call   801425 <fsipc>
}
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80168d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801691:	7e 37                	jle    8016ca <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80169c:	ff 70 04             	pushl  0x4(%eax)
  80169f:	8d 40 10             	lea    0x10(%eax),%eax
  8016a2:	50                   	push   %eax
  8016a3:	ff 33                	pushl  (%ebx)
  8016a5:	e8 82 fb ff ff       	call   80122c <write>
		if (result > 0)
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	7e 03                	jle    8016b4 <writebuf+0x27>
			b->result += result;
  8016b1:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8016b4:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016b7:	74 0d                	je     8016c6 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	0f 4f c2             	cmovg  %edx,%eax
  8016c3:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8016c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c9:	c9                   	leave  
  8016ca:	f3 c3                	repz ret 

008016cc <putch>:

static void
putch(int ch, void *thunk)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 04             	sub    $0x4,%esp
  8016d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8016d6:	8b 53 04             	mov    0x4(%ebx),%edx
  8016d9:	8d 42 01             	lea    0x1(%edx),%eax
  8016dc:	89 43 04             	mov    %eax,0x4(%ebx)
  8016df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e2:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8016e6:	3d 00 01 00 00       	cmp    $0x100,%eax
  8016eb:	75 0e                	jne    8016fb <putch+0x2f>
		writebuf(b);
  8016ed:	89 d8                	mov    %ebx,%eax
  8016ef:	e8 99 ff ff ff       	call   80168d <writebuf>
		b->idx = 0;
  8016f4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8016fb:	83 c4 04             	add    $0x4,%esp
  8016fe:	5b                   	pop    %ebx
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    

00801701 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80170a:	8b 45 08             	mov    0x8(%ebp),%eax
  80170d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801713:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80171a:	00 00 00 
	b.result = 0;
  80171d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801724:	00 00 00 
	b.error = 1;
  801727:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80172e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801731:	ff 75 10             	pushl  0x10(%ebp)
  801734:	ff 75 0c             	pushl  0xc(%ebp)
  801737:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	68 cc 16 80 00       	push   $0x8016cc
  801743:	e8 ad ec ff ff       	call   8003f5 <vprintfmt>
	if (b.idx > 0)
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801752:	7e 0b                	jle    80175f <vfprintf+0x5e>
		writebuf(&b);
  801754:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80175a:	e8 2e ff ff ff       	call   80168d <writebuf>

	return (b.result ? b.result : b.error);
  80175f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801765:	85 c0                	test   %eax,%eax
  801767:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801776:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801779:	50                   	push   %eax
  80177a:	ff 75 0c             	pushl  0xc(%ebp)
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 7c ff ff ff       	call   801701 <vfprintf>
	va_end(ap);

	return cnt;
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <printf>:

int
printf(const char *fmt, ...)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80178d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801790:	50                   	push   %eax
  801791:	ff 75 08             	pushl  0x8(%ebp)
  801794:	6a 01                	push   $0x1
  801796:	e8 66 ff ff ff       	call   801701 <vfprintf>
	va_end(ap);

	return cnt;
}
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	56                   	push   %esi
  8017a1:	53                   	push   %ebx
  8017a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	ff 75 08             	pushl  0x8(%ebp)
  8017ab:	e8 d6 f6 ff ff       	call   800e86 <fd2data>
  8017b0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8017b2:	83 c4 08             	add    $0x8,%esp
  8017b5:	68 33 29 80 00       	push   $0x802933
  8017ba:	53                   	push   %ebx
  8017bb:	e8 a3 f0 ff ff       	call   800863 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8017c0:	8b 46 04             	mov    0x4(%esi),%eax
  8017c3:	2b 06                	sub    (%esi),%eax
  8017c5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8017cb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d2:	00 00 00 
	stat->st_dev = &devpipe;
  8017d5:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  8017dc:	30 80 00 
	return 0;
}
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 0c             	sub    $0xc,%esp
  8017f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8017f5:	53                   	push   %ebx
  8017f6:	6a 00                	push   $0x0
  8017f8:	e8 ee f4 ff ff       	call   800ceb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8017fd:	89 1c 24             	mov    %ebx,(%esp)
  801800:	e8 81 f6 ff ff       	call   800e86 <fd2data>
  801805:	83 c4 08             	add    $0x8,%esp
  801808:	50                   	push   %eax
  801809:	6a 00                	push   $0x0
  80180b:	e8 db f4 ff ff       	call   800ceb <sys_page_unmap>
}
  801810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801813:	c9                   	leave  
  801814:	c3                   	ret    

00801815 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	57                   	push   %edi
  801819:	56                   	push   %esi
  80181a:	53                   	push   %ebx
  80181b:	83 ec 1c             	sub    $0x1c,%esp
  80181e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801821:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801823:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801828:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80182b:	83 ec 0c             	sub    $0xc,%esp
  80182e:	ff 75 e0             	pushl  -0x20(%ebp)
  801831:	e8 ab 09 00 00       	call   8021e1 <pageref>
  801836:	89 c3                	mov    %eax,%ebx
  801838:	89 3c 24             	mov    %edi,(%esp)
  80183b:	e8 a1 09 00 00       	call   8021e1 <pageref>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	39 c3                	cmp    %eax,%ebx
  801845:	0f 94 c1             	sete   %cl
  801848:	0f b6 c9             	movzbl %cl,%ecx
  80184b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80184e:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801854:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801857:	39 ce                	cmp    %ecx,%esi
  801859:	74 1b                	je     801876 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80185b:	39 c3                	cmp    %eax,%ebx
  80185d:	75 c4                	jne    801823 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80185f:	8b 42 58             	mov    0x58(%edx),%eax
  801862:	ff 75 e4             	pushl  -0x1c(%ebp)
  801865:	50                   	push   %eax
  801866:	56                   	push   %esi
  801867:	68 3a 29 80 00       	push   $0x80293a
  80186c:	e8 4d ea ff ff       	call   8002be <cprintf>
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	eb ad                	jmp    801823 <_pipeisclosed+0xe>
	}
}
  801876:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801879:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5f                   	pop    %edi
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    

00801881 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	57                   	push   %edi
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	83 ec 28             	sub    $0x28,%esp
  80188a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80188d:	56                   	push   %esi
  80188e:	e8 f3 f5 ff ff       	call   800e86 <fd2data>
  801893:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	bf 00 00 00 00       	mov    $0x0,%edi
  80189d:	eb 4b                	jmp    8018ea <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80189f:	89 da                	mov    %ebx,%edx
  8018a1:	89 f0                	mov    %esi,%eax
  8018a3:	e8 6d ff ff ff       	call   801815 <_pipeisclosed>
  8018a8:	85 c0                	test   %eax,%eax
  8018aa:	75 48                	jne    8018f4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8018ac:	e8 96 f3 ff ff       	call   800c47 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8018b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8018b4:	8b 0b                	mov    (%ebx),%ecx
  8018b6:	8d 51 20             	lea    0x20(%ecx),%edx
  8018b9:	39 d0                	cmp    %edx,%eax
  8018bb:	73 e2                	jae    80189f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8018bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018c0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8018c4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	c1 fa 1f             	sar    $0x1f,%edx
  8018cc:	89 d1                	mov    %edx,%ecx
  8018ce:	c1 e9 1b             	shr    $0x1b,%ecx
  8018d1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8018d4:	83 e2 1f             	and    $0x1f,%edx
  8018d7:	29 ca                	sub    %ecx,%edx
  8018d9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8018dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8018e1:	83 c0 01             	add    $0x1,%eax
  8018e4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018e7:	83 c7 01             	add    $0x1,%edi
  8018ea:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018ed:	75 c2                	jne    8018b1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8018ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f2:	eb 05                	jmp    8018f9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018f4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8018f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018fc:	5b                   	pop    %ebx
  8018fd:	5e                   	pop    %esi
  8018fe:	5f                   	pop    %edi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	57                   	push   %edi
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	83 ec 18             	sub    $0x18,%esp
  80190a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80190d:	57                   	push   %edi
  80190e:	e8 73 f5 ff ff       	call   800e86 <fd2data>
  801913:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801915:	83 c4 10             	add    $0x10,%esp
  801918:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191d:	eb 3d                	jmp    80195c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80191f:	85 db                	test   %ebx,%ebx
  801921:	74 04                	je     801927 <devpipe_read+0x26>
				return i;
  801923:	89 d8                	mov    %ebx,%eax
  801925:	eb 44                	jmp    80196b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801927:	89 f2                	mov    %esi,%edx
  801929:	89 f8                	mov    %edi,%eax
  80192b:	e8 e5 fe ff ff       	call   801815 <_pipeisclosed>
  801930:	85 c0                	test   %eax,%eax
  801932:	75 32                	jne    801966 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801934:	e8 0e f3 ff ff       	call   800c47 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801939:	8b 06                	mov    (%esi),%eax
  80193b:	3b 46 04             	cmp    0x4(%esi),%eax
  80193e:	74 df                	je     80191f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801940:	99                   	cltd   
  801941:	c1 ea 1b             	shr    $0x1b,%edx
  801944:	01 d0                	add    %edx,%eax
  801946:	83 e0 1f             	and    $0x1f,%eax
  801949:	29 d0                	sub    %edx,%eax
  80194b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801953:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801956:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801959:	83 c3 01             	add    $0x1,%ebx
  80195c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80195f:	75 d8                	jne    801939 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801961:	8b 45 10             	mov    0x10(%ebp),%eax
  801964:	eb 05                	jmp    80196b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80196b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	5f                   	pop    %edi
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80197b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	e8 19 f5 ff ff       	call   800e9d <fd_alloc>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	89 c2                	mov    %eax,%edx
  801989:	85 c0                	test   %eax,%eax
  80198b:	0f 88 2c 01 00 00    	js     801abd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	68 07 04 00 00       	push   $0x407
  801999:	ff 75 f4             	pushl  -0xc(%ebp)
  80199c:	6a 00                	push   $0x0
  80199e:	e8 c3 f2 ff ff       	call   800c66 <sys_page_alloc>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	89 c2                	mov    %eax,%edx
  8019a8:	85 c0                	test   %eax,%eax
  8019aa:	0f 88 0d 01 00 00    	js     801abd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8019b0:	83 ec 0c             	sub    $0xc,%esp
  8019b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b6:	50                   	push   %eax
  8019b7:	e8 e1 f4 ff ff       	call   800e9d <fd_alloc>
  8019bc:	89 c3                	mov    %eax,%ebx
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	0f 88 e2 00 00 00    	js     801aab <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019c9:	83 ec 04             	sub    $0x4,%esp
  8019cc:	68 07 04 00 00       	push   $0x407
  8019d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d4:	6a 00                	push   $0x0
  8019d6:	e8 8b f2 ff ff       	call   800c66 <sys_page_alloc>
  8019db:	89 c3                	mov    %eax,%ebx
  8019dd:	83 c4 10             	add    $0x10,%esp
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	0f 88 c3 00 00 00    	js     801aab <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ee:	e8 93 f4 ff ff       	call   800e86 <fd2data>
  8019f3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f5:	83 c4 0c             	add    $0xc,%esp
  8019f8:	68 07 04 00 00       	push   $0x407
  8019fd:	50                   	push   %eax
  8019fe:	6a 00                	push   $0x0
  801a00:	e8 61 f2 ff ff       	call   800c66 <sys_page_alloc>
  801a05:	89 c3                	mov    %eax,%ebx
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	0f 88 89 00 00 00    	js     801a9b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 75 f0             	pushl  -0x10(%ebp)
  801a18:	e8 69 f4 ff ff       	call   800e86 <fd2data>
  801a1d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a24:	50                   	push   %eax
  801a25:	6a 00                	push   $0x0
  801a27:	56                   	push   %esi
  801a28:	6a 00                	push   $0x0
  801a2a:	e8 7a f2 ff ff       	call   800ca9 <sys_page_map>
  801a2f:	89 c3                	mov    %eax,%ebx
  801a31:	83 c4 20             	add    $0x20,%esp
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 55                	js     801a8d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a38:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a41:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a46:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801a4d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a56:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a5b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	ff 75 f4             	pushl  -0xc(%ebp)
  801a68:	e8 09 f4 ff ff       	call   800e76 <fd2num>
  801a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a70:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a72:	83 c4 04             	add    $0x4,%esp
  801a75:	ff 75 f0             	pushl  -0x10(%ebp)
  801a78:	e8 f9 f3 ff ff       	call   800e76 <fd2num>
  801a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a80:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8b:	eb 30                	jmp    801abd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a8d:	83 ec 08             	sub    $0x8,%esp
  801a90:	56                   	push   %esi
  801a91:	6a 00                	push   $0x0
  801a93:	e8 53 f2 ff ff       	call   800ceb <sys_page_unmap>
  801a98:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a9b:	83 ec 08             	sub    $0x8,%esp
  801a9e:	ff 75 f0             	pushl  -0x10(%ebp)
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 43 f2 ff ff       	call   800ceb <sys_page_unmap>
  801aa8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801aab:	83 ec 08             	sub    $0x8,%esp
  801aae:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab1:	6a 00                	push   $0x0
  801ab3:	e8 33 f2 ff ff       	call   800ceb <sys_page_unmap>
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801abd:	89 d0                	mov    %edx,%eax
  801abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801acc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	ff 75 08             	pushl  0x8(%ebp)
  801ad3:	e8 14 f4 ff ff       	call   800eec <fd_lookup>
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 18                	js     801af7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ae5:	e8 9c f3 ff ff       	call   800e86 <fd2data>
	return _pipeisclosed(fd, p);
  801aea:	89 c2                	mov    %eax,%edx
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	e8 21 fd ff ff       	call   801815 <_pipeisclosed>
  801af4:	83 c4 10             	add    $0x10,%esp
}
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aff:	68 52 29 80 00       	push   $0x802952
  801b04:	ff 75 0c             	pushl  0xc(%ebp)
  801b07:	e8 57 ed ff ff       	call   800863 <strcpy>
	return 0;
}
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	53                   	push   %ebx
  801b17:	83 ec 10             	sub    $0x10,%esp
  801b1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b1d:	53                   	push   %ebx
  801b1e:	e8 be 06 00 00       	call   8021e1 <pageref>
  801b23:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b26:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b2b:	83 f8 01             	cmp    $0x1,%eax
  801b2e:	75 10                	jne    801b40 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b30:	83 ec 0c             	sub    $0xc,%esp
  801b33:	ff 73 0c             	pushl  0xc(%ebx)
  801b36:	e8 c0 02 00 00       	call   801dfb <nsipc_close>
  801b3b:	89 c2                	mov    %eax,%edx
  801b3d:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b40:	89 d0                	mov    %edx,%eax
  801b42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
  801b4a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b4d:	6a 00                	push   $0x0
  801b4f:	ff 75 10             	pushl  0x10(%ebp)
  801b52:	ff 75 0c             	pushl  0xc(%ebp)
  801b55:	8b 45 08             	mov    0x8(%ebp),%eax
  801b58:	ff 70 0c             	pushl  0xc(%eax)
  801b5b:	e8 78 03 00 00       	call   801ed8 <nsipc_send>
}
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b68:	6a 00                	push   $0x0
  801b6a:	ff 75 10             	pushl  0x10(%ebp)
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	8b 45 08             	mov    0x8(%ebp),%eax
  801b73:	ff 70 0c             	pushl  0xc(%eax)
  801b76:	e8 f1 02 00 00       	call   801e6c <nsipc_recv>
}
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b83:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b86:	52                   	push   %edx
  801b87:	50                   	push   %eax
  801b88:	e8 5f f3 ff ff       	call   800eec <fd_lookup>
  801b8d:	83 c4 10             	add    $0x10,%esp
  801b90:	85 c0                	test   %eax,%eax
  801b92:	78 17                	js     801bab <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b97:	8b 0d 40 30 80 00    	mov    0x803040,%ecx
  801b9d:	39 08                	cmp    %ecx,(%eax)
  801b9f:	75 05                	jne    801ba6 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ba1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba4:	eb 05                	jmp    801bab <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ba6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801bab:	c9                   	leave  
  801bac:	c3                   	ret    

00801bad <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	56                   	push   %esi
  801bb1:	53                   	push   %ebx
  801bb2:	83 ec 1c             	sub    $0x1c,%esp
  801bb5:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bba:	50                   	push   %eax
  801bbb:	e8 dd f2 ff ff       	call   800e9d <fd_alloc>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	85 c0                	test   %eax,%eax
  801bc7:	78 1b                	js     801be4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bc9:	83 ec 04             	sub    $0x4,%esp
  801bcc:	68 07 04 00 00       	push   $0x407
  801bd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd4:	6a 00                	push   $0x0
  801bd6:	e8 8b f0 ff ff       	call   800c66 <sys_page_alloc>
  801bdb:	89 c3                	mov    %eax,%ebx
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	79 10                	jns    801bf4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801be4:	83 ec 0c             	sub    $0xc,%esp
  801be7:	56                   	push   %esi
  801be8:	e8 0e 02 00 00       	call   801dfb <nsipc_close>
		return r;
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	eb 24                	jmp    801c18 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bf4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c09:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	50                   	push   %eax
  801c10:	e8 61 f2 ff ff       	call   800e76 <fd2num>
  801c15:	83 c4 10             	add    $0x10,%esp
}
  801c18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	e8 50 ff ff ff       	call   801b7d <fd2sockid>
		return r;
  801c2d:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	78 1f                	js     801c52 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c33:	83 ec 04             	sub    $0x4,%esp
  801c36:	ff 75 10             	pushl  0x10(%ebp)
  801c39:	ff 75 0c             	pushl  0xc(%ebp)
  801c3c:	50                   	push   %eax
  801c3d:	e8 12 01 00 00       	call   801d54 <nsipc_accept>
  801c42:	83 c4 10             	add    $0x10,%esp
		return r;
  801c45:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c47:	85 c0                	test   %eax,%eax
  801c49:	78 07                	js     801c52 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c4b:	e8 5d ff ff ff       	call   801bad <alloc_sockfd>
  801c50:	89 c1                	mov    %eax,%ecx
}
  801c52:	89 c8                	mov    %ecx,%eax
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	e8 19 ff ff ff       	call   801b7d <fd2sockid>
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 12                	js     801c7a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c68:	83 ec 04             	sub    $0x4,%esp
  801c6b:	ff 75 10             	pushl  0x10(%ebp)
  801c6e:	ff 75 0c             	pushl  0xc(%ebp)
  801c71:	50                   	push   %eax
  801c72:	e8 2d 01 00 00       	call   801da4 <nsipc_bind>
  801c77:	83 c4 10             	add    $0x10,%esp
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <shutdown>:

int
shutdown(int s, int how)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	e8 f3 fe ff ff       	call   801b7d <fd2sockid>
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 0f                	js     801c9d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	50                   	push   %eax
  801c95:	e8 3f 01 00 00       	call   801dd9 <nsipc_shutdown>
  801c9a:	83 c4 10             	add    $0x10,%esp
}
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca8:	e8 d0 fe ff ff       	call   801b7d <fd2sockid>
  801cad:	85 c0                	test   %eax,%eax
  801caf:	78 12                	js     801cc3 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801cb1:	83 ec 04             	sub    $0x4,%esp
  801cb4:	ff 75 10             	pushl  0x10(%ebp)
  801cb7:	ff 75 0c             	pushl  0xc(%ebp)
  801cba:	50                   	push   %eax
  801cbb:	e8 55 01 00 00       	call   801e15 <nsipc_connect>
  801cc0:	83 c4 10             	add    $0x10,%esp
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <listen>:

int
listen(int s, int backlog)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	e8 aa fe ff ff       	call   801b7d <fd2sockid>
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 0f                	js     801ce6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801cd7:	83 ec 08             	sub    $0x8,%esp
  801cda:	ff 75 0c             	pushl  0xc(%ebp)
  801cdd:	50                   	push   %eax
  801cde:	e8 67 01 00 00       	call   801e4a <nsipc_listen>
  801ce3:	83 c4 10             	add    $0x10,%esp
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cee:	ff 75 10             	pushl  0x10(%ebp)
  801cf1:	ff 75 0c             	pushl  0xc(%ebp)
  801cf4:	ff 75 08             	pushl  0x8(%ebp)
  801cf7:	e8 3a 02 00 00       	call   801f36 <nsipc_socket>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 05                	js     801d08 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d03:	e8 a5 fe ff ff       	call   801bad <alloc_sockfd>
}
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	53                   	push   %ebx
  801d0e:	83 ec 04             	sub    $0x4,%esp
  801d11:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d13:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801d1a:	75 12                	jne    801d2e <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	6a 02                	push   $0x2
  801d21:	e8 82 04 00 00       	call   8021a8 <ipc_find_env>
  801d26:	a3 08 40 80 00       	mov    %eax,0x804008
  801d2b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d2e:	6a 07                	push   $0x7
  801d30:	68 00 60 80 00       	push   $0x806000
  801d35:	53                   	push   %ebx
  801d36:	ff 35 08 40 80 00    	pushl  0x804008
  801d3c:	e8 18 04 00 00       	call   802159 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d41:	83 c4 0c             	add    $0xc,%esp
  801d44:	6a 00                	push   $0x0
  801d46:	6a 00                	push   $0x0
  801d48:	6a 00                	push   $0x0
  801d4a:	e8 94 03 00 00       	call   8020e3 <ipc_recv>
}
  801d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	56                   	push   %esi
  801d58:	53                   	push   %ebx
  801d59:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d64:	8b 06                	mov    (%esi),%eax
  801d66:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d6b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d70:	e8 95 ff ff ff       	call   801d0a <nsipc>
  801d75:	89 c3                	mov    %eax,%ebx
  801d77:	85 c0                	test   %eax,%eax
  801d79:	78 20                	js     801d9b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	ff 35 10 60 80 00    	pushl  0x806010
  801d84:	68 00 60 80 00       	push   $0x806000
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	e8 64 ec ff ff       	call   8009f5 <memmove>
		*addrlen = ret->ret_addrlen;
  801d91:	a1 10 60 80 00       	mov    0x806010,%eax
  801d96:	89 06                	mov    %eax,(%esi)
  801d98:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d9b:	89 d8                	mov    %ebx,%eax
  801d9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	53                   	push   %ebx
  801da8:	83 ec 08             	sub    $0x8,%esp
  801dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801db6:	53                   	push   %ebx
  801db7:	ff 75 0c             	pushl  0xc(%ebp)
  801dba:	68 04 60 80 00       	push   $0x806004
  801dbf:	e8 31 ec ff ff       	call   8009f5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dc4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801dca:	b8 02 00 00 00       	mov    $0x2,%eax
  801dcf:	e8 36 ff ff ff       	call   801d0a <nsipc>
}
  801dd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd7:	c9                   	leave  
  801dd8:	c3                   	ret    

00801dd9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
  801ddc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  801de2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dea:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801def:	b8 03 00 00 00       	mov    $0x3,%eax
  801df4:	e8 11 ff ff ff       	call   801d0a <nsipc>
}
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <nsipc_close>:

int
nsipc_close(int s)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e01:	8b 45 08             	mov    0x8(%ebp),%eax
  801e04:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e09:	b8 04 00 00 00       	mov    $0x4,%eax
  801e0e:	e8 f7 fe ff ff       	call   801d0a <nsipc>
}
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	53                   	push   %ebx
  801e19:	83 ec 08             	sub    $0x8,%esp
  801e1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e22:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e27:	53                   	push   %ebx
  801e28:	ff 75 0c             	pushl  0xc(%ebp)
  801e2b:	68 04 60 80 00       	push   $0x806004
  801e30:	e8 c0 eb ff ff       	call   8009f5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e35:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e3b:	b8 05 00 00 00       	mov    $0x5,%eax
  801e40:	e8 c5 fe ff ff       	call   801d0a <nsipc>
}
  801e45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e50:	8b 45 08             	mov    0x8(%ebp),%eax
  801e53:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e60:	b8 06 00 00 00       	mov    $0x6,%eax
  801e65:	e8 a0 fe ff ff       	call   801d0a <nsipc>
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e74:	8b 45 08             	mov    0x8(%ebp),%eax
  801e77:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e7c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e82:	8b 45 14             	mov    0x14(%ebp),%eax
  801e85:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e8a:	b8 07 00 00 00       	mov    $0x7,%eax
  801e8f:	e8 76 fe ff ff       	call   801d0a <nsipc>
  801e94:	89 c3                	mov    %eax,%ebx
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 35                	js     801ecf <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e9a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e9f:	7f 04                	jg     801ea5 <nsipc_recv+0x39>
  801ea1:	39 c6                	cmp    %eax,%esi
  801ea3:	7d 16                	jge    801ebb <nsipc_recv+0x4f>
  801ea5:	68 5e 29 80 00       	push   $0x80295e
  801eaa:	68 07 29 80 00       	push   $0x802907
  801eaf:	6a 62                	push   $0x62
  801eb1:	68 73 29 80 00       	push   $0x802973
  801eb6:	e8 2a e3 ff ff       	call   8001e5 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ebb:	83 ec 04             	sub    $0x4,%esp
  801ebe:	50                   	push   %eax
  801ebf:	68 00 60 80 00       	push   $0x806000
  801ec4:	ff 75 0c             	pushl  0xc(%ebp)
  801ec7:	e8 29 eb ff ff       	call   8009f5 <memmove>
  801ecc:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ecf:	89 d8                	mov    %ebx,%eax
  801ed1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5d                   	pop    %ebp
  801ed7:	c3                   	ret    

00801ed8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	53                   	push   %ebx
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801eea:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ef0:	7e 16                	jle    801f08 <nsipc_send+0x30>
  801ef2:	68 7f 29 80 00       	push   $0x80297f
  801ef7:	68 07 29 80 00       	push   $0x802907
  801efc:	6a 6d                	push   $0x6d
  801efe:	68 73 29 80 00       	push   $0x802973
  801f03:	e8 dd e2 ff ff       	call   8001e5 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f08:	83 ec 04             	sub    $0x4,%esp
  801f0b:	53                   	push   %ebx
  801f0c:	ff 75 0c             	pushl  0xc(%ebp)
  801f0f:	68 0c 60 80 00       	push   $0x80600c
  801f14:	e8 dc ea ff ff       	call   8009f5 <memmove>
	nsipcbuf.send.req_size = size;
  801f19:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f22:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f27:	b8 08 00 00 00       	mov    $0x8,%eax
  801f2c:	e8 d9 fd ff ff       	call   801d0a <nsipc>
}
  801f31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f34:	c9                   	leave  
  801f35:	c3                   	ret    

00801f36 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f36:	55                   	push   %ebp
  801f37:	89 e5                	mov    %esp,%ebp
  801f39:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f47:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f54:	b8 09 00 00 00       	mov    $0x9,%eax
  801f59:	e8 ac fd ff ff       	call   801d0a <nsipc>
}
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f63:	b8 00 00 00 00       	mov    $0x0,%eax
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    

00801f6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f70:	68 8b 29 80 00       	push   $0x80298b
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	e8 e6 e8 ff ff       	call   800863 <strcpy>
	return 0;
}
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    

00801f84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	57                   	push   %edi
  801f88:	56                   	push   %esi
  801f89:	53                   	push   %ebx
  801f8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f90:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f95:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f9b:	eb 2d                	jmp    801fca <devcons_write+0x46>
		m = n - tot;
  801f9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fa0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801fa2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801fa5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801faa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801fad:	83 ec 04             	sub    $0x4,%esp
  801fb0:	53                   	push   %ebx
  801fb1:	03 45 0c             	add    0xc(%ebp),%eax
  801fb4:	50                   	push   %eax
  801fb5:	57                   	push   %edi
  801fb6:	e8 3a ea ff ff       	call   8009f5 <memmove>
		sys_cputs(buf, m);
  801fbb:	83 c4 08             	add    $0x8,%esp
  801fbe:	53                   	push   %ebx
  801fbf:	57                   	push   %edi
  801fc0:	e8 e5 eb ff ff       	call   800baa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fc5:	01 de                	add    %ebx,%esi
  801fc7:	83 c4 10             	add    $0x10,%esp
  801fca:	89 f0                	mov    %esi,%eax
  801fcc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fcf:	72 cc                	jb     801f9d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	83 ec 08             	sub    $0x8,%esp
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801fe4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fe8:	74 2a                	je     802014 <devcons_read+0x3b>
  801fea:	eb 05                	jmp    801ff1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fec:	e8 56 ec ff ff       	call   800c47 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ff1:	e8 d2 eb ff ff       	call   800bc8 <sys_cgetc>
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	74 f2                	je     801fec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	78 16                	js     802014 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ffe:	83 f8 04             	cmp    $0x4,%eax
  802001:	74 0c                	je     80200f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802003:	8b 55 0c             	mov    0xc(%ebp),%edx
  802006:	88 02                	mov    %al,(%edx)
	return 1;
  802008:	b8 01 00 00 00       	mov    $0x1,%eax
  80200d:	eb 05                	jmp    802014 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802014:	c9                   	leave  
  802015:	c3                   	ret    

00802016 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80201c:	8b 45 08             	mov    0x8(%ebp),%eax
  80201f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802022:	6a 01                	push   $0x1
  802024:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802027:	50                   	push   %eax
  802028:	e8 7d eb ff ff       	call   800baa <sys_cputs>
}
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <getchar>:

int
getchar(void)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802038:	6a 01                	push   $0x1
  80203a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	6a 00                	push   $0x0
  802040:	e8 0d f1 ff ff       	call   801152 <read>
	if (r < 0)
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	85 c0                	test   %eax,%eax
  80204a:	78 0f                	js     80205b <getchar+0x29>
		return r;
	if (r < 1)
  80204c:	85 c0                	test   %eax,%eax
  80204e:	7e 06                	jle    802056 <getchar+0x24>
		return -E_EOF;
	return c;
  802050:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802054:	eb 05                	jmp    80205b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802056:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    

0080205d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80205d:	55                   	push   %ebp
  80205e:	89 e5                	mov    %esp,%ebp
  802060:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802066:	50                   	push   %eax
  802067:	ff 75 08             	pushl  0x8(%ebp)
  80206a:	e8 7d ee ff ff       	call   800eec <fd_lookup>
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	85 c0                	test   %eax,%eax
  802074:	78 11                	js     802087 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802076:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802079:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80207f:	39 10                	cmp    %edx,(%eax)
  802081:	0f 94 c0             	sete   %al
  802084:	0f b6 c0             	movzbl %al,%eax
}
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <opencons>:

int
opencons(void)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80208f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	e8 05 ee ff ff       	call   800e9d <fd_alloc>
  802098:	83 c4 10             	add    $0x10,%esp
		return r;
  80209b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80209d:	85 c0                	test   %eax,%eax
  80209f:	78 3e                	js     8020df <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020a1:	83 ec 04             	sub    $0x4,%esp
  8020a4:	68 07 04 00 00       	push   $0x407
  8020a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ac:	6a 00                	push   $0x0
  8020ae:	e8 b3 eb ff ff       	call   800c66 <sys_page_alloc>
  8020b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8020b6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	78 23                	js     8020df <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020bc:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8020c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	50                   	push   %eax
  8020d5:	e8 9c ed ff ff       	call   800e76 <fd2num>
  8020da:	89 c2                	mov    %eax,%edx
  8020dc:	83 c4 10             	add    $0x10,%esp
}
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	c9                   	leave  
  8020e2:	c3                   	ret    

008020e3 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	56                   	push   %esi
  8020e7:	53                   	push   %ebx
  8020e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8020eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8020f1:	85 c0                	test   %eax,%eax
  8020f3:	74 0e                	je     802103 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8020f5:	83 ec 0c             	sub    $0xc,%esp
  8020f8:	50                   	push   %eax
  8020f9:	e8 18 ed ff ff       	call   800e16 <sys_ipc_recv>
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	eb 10                	jmp    802113 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802103:	83 ec 0c             	sub    $0xc,%esp
  802106:	68 00 00 c0 ee       	push   $0xeec00000
  80210b:	e8 06 ed ff ff       	call   800e16 <sys_ipc_recv>
  802110:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802113:	85 c0                	test   %eax,%eax
  802115:	79 17                	jns    80212e <ipc_recv+0x4b>
		if(*from_env_store)
  802117:	83 3e 00             	cmpl   $0x0,(%esi)
  80211a:	74 06                	je     802122 <ipc_recv+0x3f>
			*from_env_store = 0;
  80211c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802122:	85 db                	test   %ebx,%ebx
  802124:	74 2c                	je     802152 <ipc_recv+0x6f>
			*perm_store = 0;
  802126:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80212c:	eb 24                	jmp    802152 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  80212e:	85 f6                	test   %esi,%esi
  802130:	74 0a                	je     80213c <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802132:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802137:	8b 40 74             	mov    0x74(%eax),%eax
  80213a:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80213c:	85 db                	test   %ebx,%ebx
  80213e:	74 0a                	je     80214a <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802140:	a1 0c 40 80 00       	mov    0x80400c,%eax
  802145:	8b 40 78             	mov    0x78(%eax),%eax
  802148:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80214a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80214f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802152:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    

00802159 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	57                   	push   %edi
  80215d:	56                   	push   %esi
  80215e:	53                   	push   %ebx
  80215f:	83 ec 0c             	sub    $0xc,%esp
  802162:	8b 7d 08             	mov    0x8(%ebp),%edi
  802165:	8b 75 0c             	mov    0xc(%ebp),%esi
  802168:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80216b:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80216d:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802172:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802175:	e8 cd ea ff ff       	call   800c47 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80217a:	ff 75 14             	pushl  0x14(%ebp)
  80217d:	53                   	push   %ebx
  80217e:	56                   	push   %esi
  80217f:	57                   	push   %edi
  802180:	e8 6e ec ff ff       	call   800df3 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802185:	89 c2                	mov    %eax,%edx
  802187:	f7 d2                	not    %edx
  802189:	c1 ea 1f             	shr    $0x1f,%edx
  80218c:	83 c4 10             	add    $0x10,%esp
  80218f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802192:	0f 94 c1             	sete   %cl
  802195:	09 ca                	or     %ecx,%edx
  802197:	85 c0                	test   %eax,%eax
  802199:	0f 94 c0             	sete   %al
  80219c:	38 c2                	cmp    %al,%dl
  80219e:	77 d5                	ja     802175 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8021a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021ae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021b3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021b6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021bc:	8b 52 50             	mov    0x50(%edx),%edx
  8021bf:	39 ca                	cmp    %ecx,%edx
  8021c1:	75 0d                	jne    8021d0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8021c3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8021c6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021cb:	8b 40 48             	mov    0x48(%eax),%eax
  8021ce:	eb 0f                	jmp    8021df <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021d0:	83 c0 01             	add    $0x1,%eax
  8021d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021d8:	75 d9                	jne    8021b3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    

008021e1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021e7:	89 d0                	mov    %edx,%eax
  8021e9:	c1 e8 16             	shr    $0x16,%eax
  8021ec:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021f3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f8:	f6 c1 01             	test   $0x1,%cl
  8021fb:	74 1d                	je     80221a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021fd:	c1 ea 0c             	shr    $0xc,%edx
  802200:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802207:	f6 c2 01             	test   $0x1,%dl
  80220a:	74 0e                	je     80221a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220c:	c1 ea 0c             	shr    $0xc,%edx
  80220f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802216:	ef 
  802217:	0f b7 c0             	movzwl %ax,%eax
}
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	66 90                	xchg   %ax,%ax
  80221e:	66 90                	xchg   %ax,%ax

00802220 <__udivdi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	53                   	push   %ebx
  802224:	83 ec 1c             	sub    $0x1c,%esp
  802227:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80222b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80222f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802233:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802237:	85 f6                	test   %esi,%esi
  802239:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80223d:	89 ca                	mov    %ecx,%edx
  80223f:	89 f8                	mov    %edi,%eax
  802241:	75 3d                	jne    802280 <__udivdi3+0x60>
  802243:	39 cf                	cmp    %ecx,%edi
  802245:	0f 87 c5 00 00 00    	ja     802310 <__udivdi3+0xf0>
  80224b:	85 ff                	test   %edi,%edi
  80224d:	89 fd                	mov    %edi,%ebp
  80224f:	75 0b                	jne    80225c <__udivdi3+0x3c>
  802251:	b8 01 00 00 00       	mov    $0x1,%eax
  802256:	31 d2                	xor    %edx,%edx
  802258:	f7 f7                	div    %edi
  80225a:	89 c5                	mov    %eax,%ebp
  80225c:	89 c8                	mov    %ecx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	f7 f5                	div    %ebp
  802262:	89 c1                	mov    %eax,%ecx
  802264:	89 d8                	mov    %ebx,%eax
  802266:	89 cf                	mov    %ecx,%edi
  802268:	f7 f5                	div    %ebp
  80226a:	89 c3                	mov    %eax,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	39 ce                	cmp    %ecx,%esi
  802282:	77 74                	ja     8022f8 <__udivdi3+0xd8>
  802284:	0f bd fe             	bsr    %esi,%edi
  802287:	83 f7 1f             	xor    $0x1f,%edi
  80228a:	0f 84 98 00 00 00    	je     802328 <__udivdi3+0x108>
  802290:	bb 20 00 00 00       	mov    $0x20,%ebx
  802295:	89 f9                	mov    %edi,%ecx
  802297:	89 c5                	mov    %eax,%ebp
  802299:	29 fb                	sub    %edi,%ebx
  80229b:	d3 e6                	shl    %cl,%esi
  80229d:	89 d9                	mov    %ebx,%ecx
  80229f:	d3 ed                	shr    %cl,%ebp
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	d3 e0                	shl    %cl,%eax
  8022a5:	09 ee                	or     %ebp,%esi
  8022a7:	89 d9                	mov    %ebx,%ecx
  8022a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022ad:	89 d5                	mov    %edx,%ebp
  8022af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022b3:	d3 ed                	shr    %cl,%ebp
  8022b5:	89 f9                	mov    %edi,%ecx
  8022b7:	d3 e2                	shl    %cl,%edx
  8022b9:	89 d9                	mov    %ebx,%ecx
  8022bb:	d3 e8                	shr    %cl,%eax
  8022bd:	09 c2                	or     %eax,%edx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	89 ea                	mov    %ebp,%edx
  8022c3:	f7 f6                	div    %esi
  8022c5:	89 d5                	mov    %edx,%ebp
  8022c7:	89 c3                	mov    %eax,%ebx
  8022c9:	f7 64 24 0c          	mull   0xc(%esp)
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	72 10                	jb     8022e1 <__udivdi3+0xc1>
  8022d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022d5:	89 f9                	mov    %edi,%ecx
  8022d7:	d3 e6                	shl    %cl,%esi
  8022d9:	39 c6                	cmp    %eax,%esi
  8022db:	73 07                	jae    8022e4 <__udivdi3+0xc4>
  8022dd:	39 d5                	cmp    %edx,%ebp
  8022df:	75 03                	jne    8022e4 <__udivdi3+0xc4>
  8022e1:	83 eb 01             	sub    $0x1,%ebx
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 d8                	mov    %ebx,%eax
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	31 ff                	xor    %edi,%edi
  8022fa:	31 db                	xor    %ebx,%ebx
  8022fc:	89 d8                	mov    %ebx,%eax
  8022fe:	89 fa                	mov    %edi,%edx
  802300:	83 c4 1c             	add    $0x1c,%esp
  802303:	5b                   	pop    %ebx
  802304:	5e                   	pop    %esi
  802305:	5f                   	pop    %edi
  802306:	5d                   	pop    %ebp
  802307:	c3                   	ret    
  802308:	90                   	nop
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d8                	mov    %ebx,%eax
  802312:	f7 f7                	div    %edi
  802314:	31 ff                	xor    %edi,%edi
  802316:	89 c3                	mov    %eax,%ebx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 fa                	mov    %edi,%edx
  80231c:	83 c4 1c             	add    $0x1c,%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    
  802324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802328:	39 ce                	cmp    %ecx,%esi
  80232a:	72 0c                	jb     802338 <__udivdi3+0x118>
  80232c:	31 db                	xor    %ebx,%ebx
  80232e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802332:	0f 87 34 ff ff ff    	ja     80226c <__udivdi3+0x4c>
  802338:	bb 01 00 00 00       	mov    $0x1,%ebx
  80233d:	e9 2a ff ff ff       	jmp    80226c <__udivdi3+0x4c>
  802342:	66 90                	xchg   %ax,%ax
  802344:	66 90                	xchg   %ax,%ax
  802346:	66 90                	xchg   %ax,%ax
  802348:	66 90                	xchg   %ax,%ax
  80234a:	66 90                	xchg   %ax,%ax
  80234c:	66 90                	xchg   %ax,%ax
  80234e:	66 90                	xchg   %ax,%ax

00802350 <__umoddi3>:
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	53                   	push   %ebx
  802354:	83 ec 1c             	sub    $0x1c,%esp
  802357:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80235b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80235f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802363:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802367:	85 d2                	test   %edx,%edx
  802369:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802371:	89 f3                	mov    %esi,%ebx
  802373:	89 3c 24             	mov    %edi,(%esp)
  802376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80237a:	75 1c                	jne    802398 <__umoddi3+0x48>
  80237c:	39 f7                	cmp    %esi,%edi
  80237e:	76 50                	jbe    8023d0 <__umoddi3+0x80>
  802380:	89 c8                	mov    %ecx,%eax
  802382:	89 f2                	mov    %esi,%edx
  802384:	f7 f7                	div    %edi
  802386:	89 d0                	mov    %edx,%eax
  802388:	31 d2                	xor    %edx,%edx
  80238a:	83 c4 1c             	add    $0x1c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    
  802392:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802398:	39 f2                	cmp    %esi,%edx
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	77 52                	ja     8023f0 <__umoddi3+0xa0>
  80239e:	0f bd ea             	bsr    %edx,%ebp
  8023a1:	83 f5 1f             	xor    $0x1f,%ebp
  8023a4:	75 5a                	jne    802400 <__umoddi3+0xb0>
  8023a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8023aa:	0f 82 e0 00 00 00    	jb     802490 <__umoddi3+0x140>
  8023b0:	39 0c 24             	cmp    %ecx,(%esp)
  8023b3:	0f 86 d7 00 00 00    	jbe    802490 <__umoddi3+0x140>
  8023b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	85 ff                	test   %edi,%edi
  8023d2:	89 fd                	mov    %edi,%ebp
  8023d4:	75 0b                	jne    8023e1 <__umoddi3+0x91>
  8023d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f7                	div    %edi
  8023df:	89 c5                	mov    %eax,%ebp
  8023e1:	89 f0                	mov    %esi,%eax
  8023e3:	31 d2                	xor    %edx,%edx
  8023e5:	f7 f5                	div    %ebp
  8023e7:	89 c8                	mov    %ecx,%eax
  8023e9:	f7 f5                	div    %ebp
  8023eb:	89 d0                	mov    %edx,%eax
  8023ed:	eb 99                	jmp    802388 <__umoddi3+0x38>
  8023ef:	90                   	nop
  8023f0:	89 c8                	mov    %ecx,%eax
  8023f2:	89 f2                	mov    %esi,%edx
  8023f4:	83 c4 1c             	add    $0x1c,%esp
  8023f7:	5b                   	pop    %ebx
  8023f8:	5e                   	pop    %esi
  8023f9:	5f                   	pop    %edi
  8023fa:	5d                   	pop    %ebp
  8023fb:	c3                   	ret    
  8023fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802400:	8b 34 24             	mov    (%esp),%esi
  802403:	bf 20 00 00 00       	mov    $0x20,%edi
  802408:	89 e9                	mov    %ebp,%ecx
  80240a:	29 ef                	sub    %ebp,%edi
  80240c:	d3 e0                	shl    %cl,%eax
  80240e:	89 f9                	mov    %edi,%ecx
  802410:	89 f2                	mov    %esi,%edx
  802412:	d3 ea                	shr    %cl,%edx
  802414:	89 e9                	mov    %ebp,%ecx
  802416:	09 c2                	or     %eax,%edx
  802418:	89 d8                	mov    %ebx,%eax
  80241a:	89 14 24             	mov    %edx,(%esp)
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	d3 e2                	shl    %cl,%edx
  802421:	89 f9                	mov    %edi,%ecx
  802423:	89 54 24 04          	mov    %edx,0x4(%esp)
  802427:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	89 e9                	mov    %ebp,%ecx
  80242f:	89 c6                	mov    %eax,%esi
  802431:	d3 e3                	shl    %cl,%ebx
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 d0                	mov    %edx,%eax
  802437:	d3 e8                	shr    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	09 d8                	or     %ebx,%eax
  80243d:	89 d3                	mov    %edx,%ebx
  80243f:	89 f2                	mov    %esi,%edx
  802441:	f7 34 24             	divl   (%esp)
  802444:	89 d6                	mov    %edx,%esi
  802446:	d3 e3                	shl    %cl,%ebx
  802448:	f7 64 24 04          	mull   0x4(%esp)
  80244c:	39 d6                	cmp    %edx,%esi
  80244e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802452:	89 d1                	mov    %edx,%ecx
  802454:	89 c3                	mov    %eax,%ebx
  802456:	72 08                	jb     802460 <__umoddi3+0x110>
  802458:	75 11                	jne    80246b <__umoddi3+0x11b>
  80245a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80245e:	73 0b                	jae    80246b <__umoddi3+0x11b>
  802460:	2b 44 24 04          	sub    0x4(%esp),%eax
  802464:	1b 14 24             	sbb    (%esp),%edx
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 c3                	mov    %eax,%ebx
  80246b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80246f:	29 da                	sub    %ebx,%edx
  802471:	19 ce                	sbb    %ecx,%esi
  802473:	89 f9                	mov    %edi,%ecx
  802475:	89 f0                	mov    %esi,%eax
  802477:	d3 e0                	shl    %cl,%eax
  802479:	89 e9                	mov    %ebp,%ecx
  80247b:	d3 ea                	shr    %cl,%edx
  80247d:	89 e9                	mov    %ebp,%ecx
  80247f:	d3 ee                	shr    %cl,%esi
  802481:	09 d0                	or     %edx,%eax
  802483:	89 f2                	mov    %esi,%edx
  802485:	83 c4 1c             	add    $0x1c,%esp
  802488:	5b                   	pop    %ebx
  802489:	5e                   	pop    %esi
  80248a:	5f                   	pop    %edi
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	29 f9                	sub    %edi,%ecx
  802492:	19 d6                	sbb    %edx,%esi
  802494:	89 74 24 04          	mov    %esi,0x4(%esp)
  802498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80249c:	e9 18 ff ff ff       	jmp    8023b9 <__umoddi3+0x69>
