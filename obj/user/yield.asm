
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 08 40 80 00       	mov    0x804008,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 c0 22 80 00       	push   $0x8022c0
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 bc 0a 00 00       	call   800b16 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 08 40 80 00       	mov    0x804008,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 e0 22 80 00       	push   $0x8022e0
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 08 40 80 00       	mov    0x804008,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 0c 23 80 00       	push   $0x80230c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000a5:	e8 4d 0a 00 00       	call   800af7 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 25 0e 00 00       	call   800f10 <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 c1 09 00 00       	call   800ab6 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 4f 09 00 00       	call   800a79 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 f4 08 00 00       	call   800a79 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 3b 1e 00 00       	call   802030 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 28 1f 00 00       	call   802160 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 35 23 80 00 	movsbl 0x802335(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 a9 03 00 00    	je     800689 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 07                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800319:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8d 47 01             	lea    0x1(%edi),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	0f b6 07             	movzbl (%edi),%eax
  800326:	0f b6 c8             	movzbl %al,%ecx
  800329:	83 e8 23             	sub    $0x23,%eax
  80032c:	3c 55                	cmp    $0x55,%al
  80032e:	0f 87 3a 03 00 00    	ja     80066e <vprintfmt+0x3aa>
  800334:	0f b6 c0             	movzbl %al,%eax
  800337:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb d6                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035f:	83 fa 09             	cmp    $0x9,%edx
  800362:	77 39                	ja     80039d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800364:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800367:	eb e9                	jmp    800352 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 48 04             	lea    0x4(%eax),%ecx
  80036f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 27                	jmp    8003a3 <vprintfmt+0xdf>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	0f 49 c8             	cmovns %eax,%ecx
  800389:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	eb 8c                	jmp    80031d <vprintfmt+0x59>
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039b:	eb 80                	jmp    80031d <vprintfmt+0x59>
  80039d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a7:	0f 89 70 ff ff ff    	jns    80031d <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ad:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ba:	e9 5e ff ff ff       	jmp    80031d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c5:	e9 53 ff ff ff       	jmp    80031d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	53                   	push   %ebx
  8003d7:	ff 30                	pushl  (%eax)
  8003d9:	ff d6                	call   *%esi
			break;
  8003db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e1:	e9 04 ff ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	99                   	cltd   
  8003f2:	31 d0                	xor    %edx,%eax
  8003f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 0f             	cmp    $0xf,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0x142>
  8003fb:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 18                	jne    80041e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 4d 23 80 00       	push   $0x80234d
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 94 fe ff ff       	call   8002a7 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800419:	e9 cc fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041e:	52                   	push   %edx
  80041f:	68 15 27 80 00       	push   $0x802715
  800424:	53                   	push   %ebx
  800425:	56                   	push   %esi
  800426:	e8 7c fe ff ff       	call   8002a7 <printfmt>
  80042b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	e9 b4 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800441:	85 ff                	test   %edi,%edi
  800443:	b8 46 23 80 00       	mov    $0x802346,%eax
  800448:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	0f 8e 94 00 00 00    	jle    8004e9 <vprintfmt+0x225>
  800455:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800459:	0f 84 98 00 00 00    	je     8004f7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 d0             	pushl  -0x30(%ebp)
  800465:	57                   	push   %edi
  800466:	e8 a6 02 00 00       	call   800711 <strnlen>
  80046b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800476:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	eb 0f                	jmp    800493 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ed                	jg     800484 <vprintfmt+0x1c0>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	29 c1                	sub    %eax,%ecx
  8004a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b2:	89 cb                	mov    %ecx,%ebx
  8004b4:	eb 4d                	jmp    800503 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ba:	74 1b                	je     8004d7 <vprintfmt+0x213>
  8004bc:	0f be c0             	movsbl %al,%eax
  8004bf:	83 e8 20             	sub    $0x20,%eax
  8004c2:	83 f8 5e             	cmp    $0x5e,%eax
  8004c5:	76 10                	jbe    8004d7 <vprintfmt+0x213>
					putch('?', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	6a 3f                	push   $0x3f
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	52                   	push   %edx
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	eb 1a                	jmp    800503 <vprintfmt+0x23f>
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	eb 0c                	jmp    800503 <vprintfmt+0x23f>
  8004f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800503:	83 c7 01             	add    $0x1,%edi
  800506:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050a:	0f be d0             	movsbl %al,%edx
  80050d:	85 d2                	test   %edx,%edx
  80050f:	74 23                	je     800534 <vprintfmt+0x270>
  800511:	85 f6                	test   %esi,%esi
  800513:	78 a1                	js     8004b6 <vprintfmt+0x1f2>
  800515:	83 ee 01             	sub    $0x1,%esi
  800518:	79 9c                	jns    8004b6 <vprintfmt+0x1f2>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	eb 18                	jmp    80053c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	6a 20                	push   $0x20
  80052a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052c:	83 ef 01             	sub    $0x1,%edi
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb 08                	jmp    80053c <vprintfmt+0x278>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f e4                	jg     800524 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800543:	e9 a2 fd ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800548:	83 fa 01             	cmp    $0x1,%edx
  80054b:	7e 16                	jle    800563 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 08             	lea    0x8(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 50 04             	mov    0x4(%eax),%edx
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800561:	eb 32                	jmp    800595 <vprintfmt+0x2d1>
	else if (lflag)
  800563:	85 d2                	test   %edx,%edx
  800565:	74 18                	je     80057f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057d:	eb 16                	jmp    800595 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	89 c1                	mov    %eax,%ecx
  80058f:	c1 f9 1f             	sar    $0x1f,%ecx
  800592:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a4:	0f 89 90 00 00 00    	jns    80063a <vprintfmt+0x376>
				putch('-', putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	53                   	push   %ebx
  8005ae:	6a 2d                	push   $0x2d
  8005b0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b8:	f7 d8                	neg    %eax
  8005ba:	83 d2 00             	adc    $0x0,%edx
  8005bd:	f7 da                	neg    %edx
  8005bf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c7:	eb 71                	jmp    80063a <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 7f fc ff ff       	call   800250 <getuint>
			base = 10;
  8005d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d6:	eb 62                	jmp    80063a <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005db:	e8 70 fc ff ff       	call   800250 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005e7:	51                   	push   %ecx
  8005e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8005eb:	6a 08                	push   $0x8
  8005ed:	52                   	push   %edx
  8005ee:	50                   	push   %eax
  8005ef:	89 da                	mov    %ebx,%edx
  8005f1:	89 f0                	mov    %esi,%eax
  8005f3:	e8 a9 fb ff ff       	call   8001a1 <printnum>
			break;
  8005f8:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8005fe:	e9 e7 fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 30                	push   $0x30
  800609:	ff d6                	call   *%esi
			putch('x', putdat);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 78                	push   $0x78
  800611:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 50 04             	lea    0x4(%eax),%edx
  800619:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800623:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800626:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80062b:	eb 0d                	jmp    80063a <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 1b fc ff ff       	call   800250 <getuint>
			base = 16;
  800635:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063a:	83 ec 0c             	sub    $0xc,%esp
  80063d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800641:	57                   	push   %edi
  800642:	ff 75 e0             	pushl  -0x20(%ebp)
  800645:	51                   	push   %ecx
  800646:	52                   	push   %edx
  800647:	50                   	push   %eax
  800648:	89 da                	mov    %ebx,%edx
  80064a:	89 f0                	mov    %esi,%eax
  80064c:	e8 50 fb ff ff       	call   8001a1 <printnum>
			break;
  800651:	83 c4 20             	add    $0x20,%esp
  800654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800657:	e9 8e fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	51                   	push   %ecx
  800661:	ff d6                	call   *%esi
			break;
  800663:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800669:	e9 7c fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 25                	push   $0x25
  800674:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	eb 03                	jmp    80067e <vprintfmt+0x3ba>
  80067b:	83 ef 01             	sub    $0x1,%edi
  80067e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800682:	75 f7                	jne    80067b <vprintfmt+0x3b7>
  800684:	e9 61 fc ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068c:	5b                   	pop    %ebx
  80068d:	5e                   	pop    %esi
  80068e:	5f                   	pop    %edi
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
  800694:	83 ec 18             	sub    $0x18,%esp
  800697:	8b 45 08             	mov    0x8(%ebp),%eax
  80069a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80069d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	74 26                	je     8006d8 <vsnprintf+0x47>
  8006b2:	85 d2                	test   %edx,%edx
  8006b4:	7e 22                	jle    8006d8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b6:	ff 75 14             	pushl  0x14(%ebp)
  8006b9:	ff 75 10             	pushl  0x10(%ebp)
  8006bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bf:	50                   	push   %eax
  8006c0:	68 8a 02 80 00       	push   $0x80028a
  8006c5:	e8 fa fb ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	eb 05                	jmp    8006dd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e8:	50                   	push   %eax
  8006e9:	ff 75 10             	pushl  0x10(%ebp)
  8006ec:	ff 75 0c             	pushl  0xc(%ebp)
  8006ef:	ff 75 08             	pushl  0x8(%ebp)
  8006f2:	e8 9a ff ff ff       	call   800691 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f7:	c9                   	leave  
  8006f8:	c3                   	ret    

008006f9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	eb 03                	jmp    800709 <strlen+0x10>
		n++;
  800706:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800709:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80070d:	75 f7                	jne    800706 <strlen+0xd>
		n++;
	return n;
}
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800717:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071a:	ba 00 00 00 00       	mov    $0x0,%edx
  80071f:	eb 03                	jmp    800724 <strnlen+0x13>
		n++;
  800721:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800724:	39 c2                	cmp    %eax,%edx
  800726:	74 08                	je     800730 <strnlen+0x1f>
  800728:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80072c:	75 f3                	jne    800721 <strnlen+0x10>
  80072e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	53                   	push   %ebx
  800736:	8b 45 08             	mov    0x8(%ebp),%eax
  800739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80073c:	89 c2                	mov    %eax,%edx
  80073e:	83 c2 01             	add    $0x1,%edx
  800741:	83 c1 01             	add    $0x1,%ecx
  800744:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800748:	88 5a ff             	mov    %bl,-0x1(%edx)
  80074b:	84 db                	test   %bl,%bl
  80074d:	75 ef                	jne    80073e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074f:	5b                   	pop    %ebx
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800759:	53                   	push   %ebx
  80075a:	e8 9a ff ff ff       	call   8006f9 <strlen>
  80075f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	01 d8                	add    %ebx,%eax
  800767:	50                   	push   %eax
  800768:	e8 c5 ff ff ff       	call   800732 <strcpy>
	return dst;
}
  80076d:	89 d8                	mov    %ebx,%eax
  80076f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	56                   	push   %esi
  800778:	53                   	push   %ebx
  800779:	8b 75 08             	mov    0x8(%ebp),%esi
  80077c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077f:	89 f3                	mov    %esi,%ebx
  800781:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800784:	89 f2                	mov    %esi,%edx
  800786:	eb 0f                	jmp    800797 <strncpy+0x23>
		*dst++ = *src;
  800788:	83 c2 01             	add    $0x1,%edx
  80078b:	0f b6 01             	movzbl (%ecx),%eax
  80078e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800791:	80 39 01             	cmpb   $0x1,(%ecx)
  800794:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	39 da                	cmp    %ebx,%edx
  800799:	75 ed                	jne    800788 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80079b:	89 f0                	mov    %esi,%eax
  80079d:	5b                   	pop    %ebx
  80079e:	5e                   	pop    %esi
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	56                   	push   %esi
  8007a5:	53                   	push   %ebx
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ac:	8b 55 10             	mov    0x10(%ebp),%edx
  8007af:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	74 21                	je     8007d6 <strlcpy+0x35>
  8007b5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b9:	89 f2                	mov    %esi,%edx
  8007bb:	eb 09                	jmp    8007c6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007bd:	83 c2 01             	add    $0x1,%edx
  8007c0:	83 c1 01             	add    $0x1,%ecx
  8007c3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c6:	39 c2                	cmp    %eax,%edx
  8007c8:	74 09                	je     8007d3 <strlcpy+0x32>
  8007ca:	0f b6 19             	movzbl (%ecx),%ebx
  8007cd:	84 db                	test   %bl,%bl
  8007cf:	75 ec                	jne    8007bd <strlcpy+0x1c>
  8007d1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007d3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d6:	29 f0                	sub    %esi,%eax
}
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e5:	eb 06                	jmp    8007ed <strcmp+0x11>
		p++, q++;
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ed:	0f b6 01             	movzbl (%ecx),%eax
  8007f0:	84 c0                	test   %al,%al
  8007f2:	74 04                	je     8007f8 <strcmp+0x1c>
  8007f4:	3a 02                	cmp    (%edx),%al
  8007f6:	74 ef                	je     8007e7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f8:	0f b6 c0             	movzbl %al,%eax
  8007fb:	0f b6 12             	movzbl (%edx),%edx
  8007fe:	29 d0                	sub    %edx,%eax
}
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080c:	89 c3                	mov    %eax,%ebx
  80080e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800811:	eb 06                	jmp    800819 <strncmp+0x17>
		n--, p++, q++;
  800813:	83 c0 01             	add    $0x1,%eax
  800816:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800819:	39 d8                	cmp    %ebx,%eax
  80081b:	74 15                	je     800832 <strncmp+0x30>
  80081d:	0f b6 08             	movzbl (%eax),%ecx
  800820:	84 c9                	test   %cl,%cl
  800822:	74 04                	je     800828 <strncmp+0x26>
  800824:	3a 0a                	cmp    (%edx),%cl
  800826:	74 eb                	je     800813 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800828:	0f b6 00             	movzbl (%eax),%eax
  80082b:	0f b6 12             	movzbl (%edx),%edx
  80082e:	29 d0                	sub    %edx,%eax
  800830:	eb 05                	jmp    800837 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800844:	eb 07                	jmp    80084d <strchr+0x13>
		if (*s == c)
  800846:	38 ca                	cmp    %cl,%dl
  800848:	74 0f                	je     800859 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80084a:	83 c0 01             	add    $0x1,%eax
  80084d:	0f b6 10             	movzbl (%eax),%edx
  800850:	84 d2                	test   %dl,%dl
  800852:	75 f2                	jne    800846 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800865:	eb 03                	jmp    80086a <strfind+0xf>
  800867:	83 c0 01             	add    $0x1,%eax
  80086a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80086d:	38 ca                	cmp    %cl,%dl
  80086f:	74 04                	je     800875 <strfind+0x1a>
  800871:	84 d2                	test   %dl,%dl
  800873:	75 f2                	jne    800867 <strfind+0xc>
			break;
	return (char *) s;
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	57                   	push   %edi
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800880:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800883:	85 c9                	test   %ecx,%ecx
  800885:	74 36                	je     8008bd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800887:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80088d:	75 28                	jne    8008b7 <memset+0x40>
  80088f:	f6 c1 03             	test   $0x3,%cl
  800892:	75 23                	jne    8008b7 <memset+0x40>
		c &= 0xFF;
  800894:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800898:	89 d3                	mov    %edx,%ebx
  80089a:	c1 e3 08             	shl    $0x8,%ebx
  80089d:	89 d6                	mov    %edx,%esi
  80089f:	c1 e6 18             	shl    $0x18,%esi
  8008a2:	89 d0                	mov    %edx,%eax
  8008a4:	c1 e0 10             	shl    $0x10,%eax
  8008a7:	09 f0                	or     %esi,%eax
  8008a9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ab:	89 d8                	mov    %ebx,%eax
  8008ad:	09 d0                	or     %edx,%eax
  8008af:	c1 e9 02             	shr    $0x2,%ecx
  8008b2:	fc                   	cld    
  8008b3:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b5:	eb 06                	jmp    8008bd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ba:	fc                   	cld    
  8008bb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008bd:	89 f8                	mov    %edi,%eax
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5f                   	pop    %edi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	57                   	push   %edi
  8008c8:	56                   	push   %esi
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d2:	39 c6                	cmp    %eax,%esi
  8008d4:	73 35                	jae    80090b <memmove+0x47>
  8008d6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d9:	39 d0                	cmp    %edx,%eax
  8008db:	73 2e                	jae    80090b <memmove+0x47>
		s += n;
		d += n;
  8008dd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e0:	89 d6                	mov    %edx,%esi
  8008e2:	09 fe                	or     %edi,%esi
  8008e4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ea:	75 13                	jne    8008ff <memmove+0x3b>
  8008ec:	f6 c1 03             	test   $0x3,%cl
  8008ef:	75 0e                	jne    8008ff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f1:	83 ef 04             	sub    $0x4,%edi
  8008f4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f7:	c1 e9 02             	shr    $0x2,%ecx
  8008fa:	fd                   	std    
  8008fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fd:	eb 09                	jmp    800908 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ff:	83 ef 01             	sub    $0x1,%edi
  800902:	8d 72 ff             	lea    -0x1(%edx),%esi
  800905:	fd                   	std    
  800906:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800908:	fc                   	cld    
  800909:	eb 1d                	jmp    800928 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090b:	89 f2                	mov    %esi,%edx
  80090d:	09 c2                	or     %eax,%edx
  80090f:	f6 c2 03             	test   $0x3,%dl
  800912:	75 0f                	jne    800923 <memmove+0x5f>
  800914:	f6 c1 03             	test   $0x3,%cl
  800917:	75 0a                	jne    800923 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800919:	c1 e9 02             	shr    $0x2,%ecx
  80091c:	89 c7                	mov    %eax,%edi
  80091e:	fc                   	cld    
  80091f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800921:	eb 05                	jmp    800928 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800923:	89 c7                	mov    %eax,%edi
  800925:	fc                   	cld    
  800926:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800928:	5e                   	pop    %esi
  800929:	5f                   	pop    %edi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092f:	ff 75 10             	pushl  0x10(%ebp)
  800932:	ff 75 0c             	pushl  0xc(%ebp)
  800935:	ff 75 08             	pushl  0x8(%ebp)
  800938:	e8 87 ff ff ff       	call   8008c4 <memmove>
}
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094a:	89 c6                	mov    %eax,%esi
  80094c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094f:	eb 1a                	jmp    80096b <memcmp+0x2c>
		if (*s1 != *s2)
  800951:	0f b6 08             	movzbl (%eax),%ecx
  800954:	0f b6 1a             	movzbl (%edx),%ebx
  800957:	38 d9                	cmp    %bl,%cl
  800959:	74 0a                	je     800965 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80095b:	0f b6 c1             	movzbl %cl,%eax
  80095e:	0f b6 db             	movzbl %bl,%ebx
  800961:	29 d8                	sub    %ebx,%eax
  800963:	eb 0f                	jmp    800974 <memcmp+0x35>
		s1++, s2++;
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096b:	39 f0                	cmp    %esi,%eax
  80096d:	75 e2                	jne    800951 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	53                   	push   %ebx
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097f:	89 c1                	mov    %eax,%ecx
  800981:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800984:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800988:	eb 0a                	jmp    800994 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80098a:	0f b6 10             	movzbl (%eax),%edx
  80098d:	39 da                	cmp    %ebx,%edx
  80098f:	74 07                	je     800998 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800991:	83 c0 01             	add    $0x1,%eax
  800994:	39 c8                	cmp    %ecx,%eax
  800996:	72 f2                	jb     80098a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800998:	5b                   	pop    %ebx
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a7:	eb 03                	jmp    8009ac <strtol+0x11>
		s++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	3c 20                	cmp    $0x20,%al
  8009b1:	74 f6                	je     8009a9 <strtol+0xe>
  8009b3:	3c 09                	cmp    $0x9,%al
  8009b5:	74 f2                	je     8009a9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b7:	3c 2b                	cmp    $0x2b,%al
  8009b9:	75 0a                	jne    8009c5 <strtol+0x2a>
		s++;
  8009bb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009be:	bf 00 00 00 00       	mov    $0x0,%edi
  8009c3:	eb 11                	jmp    8009d6 <strtol+0x3b>
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ca:	3c 2d                	cmp    $0x2d,%al
  8009cc:	75 08                	jne    8009d6 <strtol+0x3b>
		s++, neg = 1;
  8009ce:	83 c1 01             	add    $0x1,%ecx
  8009d1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009dc:	75 15                	jne    8009f3 <strtol+0x58>
  8009de:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e1:	75 10                	jne    8009f3 <strtol+0x58>
  8009e3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e7:	75 7c                	jne    800a65 <strtol+0xca>
		s += 2, base = 16;
  8009e9:	83 c1 02             	add    $0x2,%ecx
  8009ec:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f1:	eb 16                	jmp    800a09 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009f3:	85 db                	test   %ebx,%ebx
  8009f5:	75 12                	jne    800a09 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ff:	75 08                	jne    800a09 <strtol+0x6e>
		s++, base = 8;
  800a01:	83 c1 01             	add    $0x1,%ecx
  800a04:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a11:	0f b6 11             	movzbl (%ecx),%edx
  800a14:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	80 fb 09             	cmp    $0x9,%bl
  800a1c:	77 08                	ja     800a26 <strtol+0x8b>
			dig = *s - '0';
  800a1e:	0f be d2             	movsbl %dl,%edx
  800a21:	83 ea 30             	sub    $0x30,%edx
  800a24:	eb 22                	jmp    800a48 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a26:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a29:	89 f3                	mov    %esi,%ebx
  800a2b:	80 fb 19             	cmp    $0x19,%bl
  800a2e:	77 08                	ja     800a38 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a30:	0f be d2             	movsbl %dl,%edx
  800a33:	83 ea 57             	sub    $0x57,%edx
  800a36:	eb 10                	jmp    800a48 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a38:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 19             	cmp    $0x19,%bl
  800a40:	77 16                	ja     800a58 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a42:	0f be d2             	movsbl %dl,%edx
  800a45:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a48:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4b:	7d 0b                	jge    800a58 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a4d:	83 c1 01             	add    $0x1,%ecx
  800a50:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a54:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a56:	eb b9                	jmp    800a11 <strtol+0x76>

	if (endptr)
  800a58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a5c:	74 0d                	je     800a6b <strtol+0xd0>
		*endptr = (char *) s;
  800a5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a61:	89 0e                	mov    %ecx,(%esi)
  800a63:	eb 06                	jmp    800a6b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a65:	85 db                	test   %ebx,%ebx
  800a67:	74 98                	je     800a01 <strtol+0x66>
  800a69:	eb 9e                	jmp    800a09 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a6b:	89 c2                	mov    %eax,%edx
  800a6d:	f7 da                	neg    %edx
  800a6f:	85 ff                	test   %edi,%edi
  800a71:	0f 45 c2             	cmovne %edx,%eax
}
  800a74:	5b                   	pop    %ebx
  800a75:	5e                   	pop    %esi
  800a76:	5f                   	pop    %edi
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	57                   	push   %edi
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a87:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	89 c6                	mov    %eax,%esi
  800a90:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa7:	89 d1                	mov    %edx,%ecx
  800aa9:	89 d3                	mov    %edx,%ebx
  800aab:	89 d7                	mov    %edx,%edi
  800aad:	89 d6                	mov    %edx,%esi
  800aaf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac9:	8b 55 08             	mov    0x8(%ebp),%edx
  800acc:	89 cb                	mov    %ecx,%ebx
  800ace:	89 cf                	mov    %ecx,%edi
  800ad0:	89 ce                	mov    %ecx,%esi
  800ad2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ad4:	85 c0                	test   %eax,%eax
  800ad6:	7e 17                	jle    800aef <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad8:	83 ec 0c             	sub    $0xc,%esp
  800adb:	50                   	push   %eax
  800adc:	6a 03                	push   $0x3
  800ade:	68 3f 26 80 00       	push   $0x80263f
  800ae3:	6a 23                	push   $0x23
  800ae5:	68 5c 26 80 00       	push   $0x80265c
  800aea:	e8 b3 13 00 00       	call   801ea2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5f                   	pop    %edi
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	57                   	push   %edi
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afd:	ba 00 00 00 00       	mov    $0x0,%edx
  800b02:	b8 02 00 00 00       	mov    $0x2,%eax
  800b07:	89 d1                	mov    %edx,%ecx
  800b09:	89 d3                	mov    %edx,%ebx
  800b0b:	89 d7                	mov    %edx,%edi
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_yield>:

void
sys_yield(void)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b21:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b26:	89 d1                	mov    %edx,%ecx
  800b28:	89 d3                	mov    %edx,%ebx
  800b2a:	89 d7                	mov    %edx,%edi
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3e:	be 00 00 00 00       	mov    $0x0,%esi
  800b43:	b8 04 00 00 00       	mov    $0x4,%eax
  800b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b51:	89 f7                	mov    %esi,%edi
  800b53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7e 17                	jle    800b70 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 04                	push   $0x4
  800b5f:	68 3f 26 80 00       	push   $0x80263f
  800b64:	6a 23                	push   $0x23
  800b66:	68 5c 26 80 00       	push   $0x80265c
  800b6b:	e8 32 13 00 00       	call   801ea2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	b8 05 00 00 00       	mov    $0x5,%eax
  800b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b92:	8b 75 18             	mov    0x18(%ebp),%esi
  800b95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 05                	push   $0x5
  800ba1:	68 3f 26 80 00       	push   $0x80263f
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 5c 26 80 00       	push   $0x80265c
  800bad:	e8 f0 12 00 00       	call   801ea2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	89 df                	mov    %ebx,%edi
  800bd5:	89 de                	mov    %ebx,%esi
  800bd7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 06                	push   $0x6
  800be3:	68 3f 26 80 00       	push   $0x80263f
  800be8:	6a 23                	push   $0x23
  800bea:	68 5c 26 80 00       	push   $0x80265c
  800bef:	e8 ae 12 00 00       	call   801ea2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 08                	push   $0x8
  800c25:	68 3f 26 80 00       	push   $0x80263f
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 5c 26 80 00       	push   $0x80265c
  800c31:	e8 6c 12 00 00       	call   801ea2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 df                	mov    %ebx,%edi
  800c59:	89 de                	mov    %ebx,%esi
  800c5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 09                	push   $0x9
  800c67:	68 3f 26 80 00       	push   $0x80263f
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 5c 26 80 00       	push   $0x80265c
  800c73:	e8 2a 12 00 00       	call   801ea2 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 0a                	push   $0xa
  800ca9:	68 3f 26 80 00       	push   $0x80263f
  800cae:	6a 23                	push   $0x23
  800cb0:	68 5c 26 80 00       	push   $0x80265c
  800cb5:	e8 e8 11 00 00       	call   801ea2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	be 00 00 00 00       	mov    $0x0,%esi
  800ccd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cde:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	89 cb                	mov    %ecx,%ebx
  800cfd:	89 cf                	mov    %ecx,%edi
  800cff:	89 ce                	mov    %ecx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 0d                	push   $0xd
  800d0d:	68 3f 26 80 00       	push   $0x80263f
  800d12:	6a 23                	push   $0x23
  800d14:	68 5c 26 80 00       	push   $0x80265c
  800d19:	e8 84 11 00 00       	call   801ea2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d31:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d36:	89 d1                	mov    %edx,%ecx
  800d38:	89 d3                	mov    %edx,%ebx
  800d3a:	89 d7                	mov    %edx,%edi
  800d3c:	89 d6                	mov    %edx,%esi
  800d3e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d50:	c1 e8 0c             	shr    $0xc,%eax
}
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	05 00 00 00 30       	add    $0x30000000,%eax
  800d60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d65:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d72:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d77:	89 c2                	mov    %eax,%edx
  800d79:	c1 ea 16             	shr    $0x16,%edx
  800d7c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d83:	f6 c2 01             	test   $0x1,%dl
  800d86:	74 11                	je     800d99 <fd_alloc+0x2d>
  800d88:	89 c2                	mov    %eax,%edx
  800d8a:	c1 ea 0c             	shr    $0xc,%edx
  800d8d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d94:	f6 c2 01             	test   $0x1,%dl
  800d97:	75 09                	jne    800da2 <fd_alloc+0x36>
			*fd_store = fd;
  800d99:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800da0:	eb 17                	jmp    800db9 <fd_alloc+0x4d>
  800da2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800da7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dac:	75 c9                	jne    800d77 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800db4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc1:	83 f8 1f             	cmp    $0x1f,%eax
  800dc4:	77 36                	ja     800dfc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dc6:	c1 e0 0c             	shl    $0xc,%eax
  800dc9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dce:	89 c2                	mov    %eax,%edx
  800dd0:	c1 ea 16             	shr    $0x16,%edx
  800dd3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dda:	f6 c2 01             	test   $0x1,%dl
  800ddd:	74 24                	je     800e03 <fd_lookup+0x48>
  800ddf:	89 c2                	mov    %eax,%edx
  800de1:	c1 ea 0c             	shr    $0xc,%edx
  800de4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800deb:	f6 c2 01             	test   $0x1,%dl
  800dee:	74 1a                	je     800e0a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df3:	89 02                	mov    %eax,(%edx)
	return 0;
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfa:	eb 13                	jmp    800e0f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dfc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e01:	eb 0c                	jmp    800e0f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e08:	eb 05                	jmp    800e0f <fd_lookup+0x54>
  800e0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 08             	sub    $0x8,%esp
  800e17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1a:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e1f:	eb 13                	jmp    800e34 <dev_lookup+0x23>
  800e21:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e24:	39 08                	cmp    %ecx,(%eax)
  800e26:	75 0c                	jne    800e34 <dev_lookup+0x23>
			*dev = devtab[i];
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e32:	eb 2e                	jmp    800e62 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e34:	8b 02                	mov    (%edx),%eax
  800e36:	85 c0                	test   %eax,%eax
  800e38:	75 e7                	jne    800e21 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e3a:	a1 08 40 80 00       	mov    0x804008,%eax
  800e3f:	8b 40 48             	mov    0x48(%eax),%eax
  800e42:	83 ec 04             	sub    $0x4,%esp
  800e45:	51                   	push   %ecx
  800e46:	50                   	push   %eax
  800e47:	68 6c 26 80 00       	push   $0x80266c
  800e4c:	e8 3c f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e54:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 10             	sub    $0x10,%esp
  800e6c:	8b 75 08             	mov    0x8(%ebp),%esi
  800e6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e75:	50                   	push   %eax
  800e76:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e7c:	c1 e8 0c             	shr    $0xc,%eax
  800e7f:	50                   	push   %eax
  800e80:	e8 36 ff ff ff       	call   800dbb <fd_lookup>
  800e85:	83 c4 08             	add    $0x8,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	78 05                	js     800e91 <fd_close+0x2d>
	    || fd != fd2)
  800e8c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e8f:	74 0c                	je     800e9d <fd_close+0x39>
		return (must_exist ? r : 0);
  800e91:	84 db                	test   %bl,%bl
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	0f 44 c2             	cmove  %edx,%eax
  800e9b:	eb 41                	jmp    800ede <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ea3:	50                   	push   %eax
  800ea4:	ff 36                	pushl  (%esi)
  800ea6:	e8 66 ff ff ff       	call   800e11 <dev_lookup>
  800eab:	89 c3                	mov    %eax,%ebx
  800ead:	83 c4 10             	add    $0x10,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 1a                	js     800ece <fd_close+0x6a>
		if (dev->dev_close)
  800eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eba:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	74 0b                	je     800ece <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	56                   	push   %esi
  800ec7:	ff d0                	call   *%eax
  800ec9:	89 c3                	mov    %eax,%ebx
  800ecb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	56                   	push   %esi
  800ed2:	6a 00                	push   $0x0
  800ed4:	e8 e1 fc ff ff       	call   800bba <sys_page_unmap>
	return r;
  800ed9:	83 c4 10             	add    $0x10,%esp
  800edc:	89 d8                	mov    %ebx,%eax
}
  800ede:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eee:	50                   	push   %eax
  800eef:	ff 75 08             	pushl  0x8(%ebp)
  800ef2:	e8 c4 fe ff ff       	call   800dbb <fd_lookup>
  800ef7:	83 c4 08             	add    $0x8,%esp
  800efa:	85 c0                	test   %eax,%eax
  800efc:	78 10                	js     800f0e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	6a 01                	push   $0x1
  800f03:	ff 75 f4             	pushl  -0xc(%ebp)
  800f06:	e8 59 ff ff ff       	call   800e64 <fd_close>
  800f0b:	83 c4 10             	add    $0x10,%esp
}
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <close_all>:

void
close_all(void)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	53                   	push   %ebx
  800f14:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f17:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	53                   	push   %ebx
  800f20:	e8 c0 ff ff ff       	call   800ee5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f25:	83 c3 01             	add    $0x1,%ebx
  800f28:	83 c4 10             	add    $0x10,%esp
  800f2b:	83 fb 20             	cmp    $0x20,%ebx
  800f2e:	75 ec                	jne    800f1c <close_all+0xc>
		close(i);
}
  800f30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f33:	c9                   	leave  
  800f34:	c3                   	ret    

00800f35 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 2c             	sub    $0x2c,%esp
  800f3e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f41:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f44:	50                   	push   %eax
  800f45:	ff 75 08             	pushl  0x8(%ebp)
  800f48:	e8 6e fe ff ff       	call   800dbb <fd_lookup>
  800f4d:	83 c4 08             	add    $0x8,%esp
  800f50:	85 c0                	test   %eax,%eax
  800f52:	0f 88 c1 00 00 00    	js     801019 <dup+0xe4>
		return r;
	close(newfdnum);
  800f58:	83 ec 0c             	sub    $0xc,%esp
  800f5b:	56                   	push   %esi
  800f5c:	e8 84 ff ff ff       	call   800ee5 <close>

	newfd = INDEX2FD(newfdnum);
  800f61:	89 f3                	mov    %esi,%ebx
  800f63:	c1 e3 0c             	shl    $0xc,%ebx
  800f66:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f6c:	83 c4 04             	add    $0x4,%esp
  800f6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f72:	e8 de fd ff ff       	call   800d55 <fd2data>
  800f77:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f79:	89 1c 24             	mov    %ebx,(%esp)
  800f7c:	e8 d4 fd ff ff       	call   800d55 <fd2data>
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f87:	89 f8                	mov    %edi,%eax
  800f89:	c1 e8 16             	shr    $0x16,%eax
  800f8c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f93:	a8 01                	test   $0x1,%al
  800f95:	74 37                	je     800fce <dup+0x99>
  800f97:	89 f8                	mov    %edi,%eax
  800f99:	c1 e8 0c             	shr    $0xc,%eax
  800f9c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa3:	f6 c2 01             	test   $0x1,%dl
  800fa6:	74 26                	je     800fce <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fa8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb7:	50                   	push   %eax
  800fb8:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fbb:	6a 00                	push   $0x0
  800fbd:	57                   	push   %edi
  800fbe:	6a 00                	push   $0x0
  800fc0:	e8 b3 fb ff ff       	call   800b78 <sys_page_map>
  800fc5:	89 c7                	mov    %eax,%edi
  800fc7:	83 c4 20             	add    $0x20,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	78 2e                	js     800ffc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd1:	89 d0                	mov    %edx,%eax
  800fd3:	c1 e8 0c             	shr    $0xc,%eax
  800fd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdd:	83 ec 0c             	sub    $0xc,%esp
  800fe0:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe5:	50                   	push   %eax
  800fe6:	53                   	push   %ebx
  800fe7:	6a 00                	push   $0x0
  800fe9:	52                   	push   %edx
  800fea:	6a 00                	push   $0x0
  800fec:	e8 87 fb ff ff       	call   800b78 <sys_page_map>
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ff6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff8:	85 ff                	test   %edi,%edi
  800ffa:	79 1d                	jns    801019 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ffc:	83 ec 08             	sub    $0x8,%esp
  800fff:	53                   	push   %ebx
  801000:	6a 00                	push   $0x0
  801002:	e8 b3 fb ff ff       	call   800bba <sys_page_unmap>
	sys_page_unmap(0, nva);
  801007:	83 c4 08             	add    $0x8,%esp
  80100a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80100d:	6a 00                	push   $0x0
  80100f:	e8 a6 fb ff ff       	call   800bba <sys_page_unmap>
	return r;
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	89 f8                	mov    %edi,%eax
}
  801019:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	53                   	push   %ebx
  801025:	83 ec 14             	sub    $0x14,%esp
  801028:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80102b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80102e:	50                   	push   %eax
  80102f:	53                   	push   %ebx
  801030:	e8 86 fd ff ff       	call   800dbb <fd_lookup>
  801035:	83 c4 08             	add    $0x8,%esp
  801038:	89 c2                	mov    %eax,%edx
  80103a:	85 c0                	test   %eax,%eax
  80103c:	78 6d                	js     8010ab <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801044:	50                   	push   %eax
  801045:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801048:	ff 30                	pushl  (%eax)
  80104a:	e8 c2 fd ff ff       	call   800e11 <dev_lookup>
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	78 4c                	js     8010a2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801056:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801059:	8b 42 08             	mov    0x8(%edx),%eax
  80105c:	83 e0 03             	and    $0x3,%eax
  80105f:	83 f8 01             	cmp    $0x1,%eax
  801062:	75 21                	jne    801085 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801064:	a1 08 40 80 00       	mov    0x804008,%eax
  801069:	8b 40 48             	mov    0x48(%eax),%eax
  80106c:	83 ec 04             	sub    $0x4,%esp
  80106f:	53                   	push   %ebx
  801070:	50                   	push   %eax
  801071:	68 ad 26 80 00       	push   $0x8026ad
  801076:	e8 12 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801083:	eb 26                	jmp    8010ab <read+0x8a>
	}
	if (!dev->dev_read)
  801085:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801088:	8b 40 08             	mov    0x8(%eax),%eax
  80108b:	85 c0                	test   %eax,%eax
  80108d:	74 17                	je     8010a6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80108f:	83 ec 04             	sub    $0x4,%esp
  801092:	ff 75 10             	pushl  0x10(%ebp)
  801095:	ff 75 0c             	pushl  0xc(%ebp)
  801098:	52                   	push   %edx
  801099:	ff d0                	call   *%eax
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	eb 09                	jmp    8010ab <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a2:	89 c2                	mov    %eax,%edx
  8010a4:	eb 05                	jmp    8010ab <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010a6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010ab:	89 d0                	mov    %edx,%eax
  8010ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	57                   	push   %edi
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010be:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c6:	eb 21                	jmp    8010e9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010c8:	83 ec 04             	sub    $0x4,%esp
  8010cb:	89 f0                	mov    %esi,%eax
  8010cd:	29 d8                	sub    %ebx,%eax
  8010cf:	50                   	push   %eax
  8010d0:	89 d8                	mov    %ebx,%eax
  8010d2:	03 45 0c             	add    0xc(%ebp),%eax
  8010d5:	50                   	push   %eax
  8010d6:	57                   	push   %edi
  8010d7:	e8 45 ff ff ff       	call   801021 <read>
		if (m < 0)
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	78 10                	js     8010f3 <readn+0x41>
			return m;
		if (m == 0)
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	74 0a                	je     8010f1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e7:	01 c3                	add    %eax,%ebx
  8010e9:	39 f3                	cmp    %esi,%ebx
  8010eb:	72 db                	jb     8010c8 <readn+0x16>
  8010ed:	89 d8                	mov    %ebx,%eax
  8010ef:	eb 02                	jmp    8010f3 <readn+0x41>
  8010f1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f6:	5b                   	pop    %ebx
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 14             	sub    $0x14,%esp
  801102:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801105:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801108:	50                   	push   %eax
  801109:	53                   	push   %ebx
  80110a:	e8 ac fc ff ff       	call   800dbb <fd_lookup>
  80110f:	83 c4 08             	add    $0x8,%esp
  801112:	89 c2                	mov    %eax,%edx
  801114:	85 c0                	test   %eax,%eax
  801116:	78 68                	js     801180 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801118:	83 ec 08             	sub    $0x8,%esp
  80111b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801122:	ff 30                	pushl  (%eax)
  801124:	e8 e8 fc ff ff       	call   800e11 <dev_lookup>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 47                	js     801177 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801130:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801133:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801137:	75 21                	jne    80115a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801139:	a1 08 40 80 00       	mov    0x804008,%eax
  80113e:	8b 40 48             	mov    0x48(%eax),%eax
  801141:	83 ec 04             	sub    $0x4,%esp
  801144:	53                   	push   %ebx
  801145:	50                   	push   %eax
  801146:	68 c9 26 80 00       	push   $0x8026c9
  80114b:	e8 3d f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801158:	eb 26                	jmp    801180 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80115a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80115d:	8b 52 0c             	mov    0xc(%edx),%edx
  801160:	85 d2                	test   %edx,%edx
  801162:	74 17                	je     80117b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	ff 75 10             	pushl  0x10(%ebp)
  80116a:	ff 75 0c             	pushl  0xc(%ebp)
  80116d:	50                   	push   %eax
  80116e:	ff d2                	call   *%edx
  801170:	89 c2                	mov    %eax,%edx
  801172:	83 c4 10             	add    $0x10,%esp
  801175:	eb 09                	jmp    801180 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801177:	89 c2                	mov    %eax,%edx
  801179:	eb 05                	jmp    801180 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80117b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801180:	89 d0                	mov    %edx,%eax
  801182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801185:	c9                   	leave  
  801186:	c3                   	ret    

00801187 <seek>:

int
seek(int fdnum, off_t offset)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80118d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	ff 75 08             	pushl  0x8(%ebp)
  801194:	e8 22 fc ff ff       	call   800dbb <fd_lookup>
  801199:	83 c4 08             	add    $0x8,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 0e                	js     8011ae <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ae:	c9                   	leave  
  8011af:	c3                   	ret    

008011b0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 14             	sub    $0x14,%esp
  8011b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bd:	50                   	push   %eax
  8011be:	53                   	push   %ebx
  8011bf:	e8 f7 fb ff ff       	call   800dbb <fd_lookup>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 65                	js     801232 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d7:	ff 30                	pushl  (%eax)
  8011d9:	e8 33 fc ff ff       	call   800e11 <dev_lookup>
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 44                	js     801229 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ec:	75 21                	jne    80120f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ee:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011f3:	8b 40 48             	mov    0x48(%eax),%eax
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	53                   	push   %ebx
  8011fa:	50                   	push   %eax
  8011fb:	68 8c 26 80 00       	push   $0x80268c
  801200:	e8 88 ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80120d:	eb 23                	jmp    801232 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80120f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801212:	8b 52 18             	mov    0x18(%edx),%edx
  801215:	85 d2                	test   %edx,%edx
  801217:	74 14                	je     80122d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801219:	83 ec 08             	sub    $0x8,%esp
  80121c:	ff 75 0c             	pushl  0xc(%ebp)
  80121f:	50                   	push   %eax
  801220:	ff d2                	call   *%edx
  801222:	89 c2                	mov    %eax,%edx
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	eb 09                	jmp    801232 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801229:	89 c2                	mov    %eax,%edx
  80122b:	eb 05                	jmp    801232 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80122d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801232:	89 d0                	mov    %edx,%eax
  801234:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801237:	c9                   	leave  
  801238:	c3                   	ret    

00801239 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	53                   	push   %ebx
  80123d:	83 ec 14             	sub    $0x14,%esp
  801240:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801243:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801246:	50                   	push   %eax
  801247:	ff 75 08             	pushl  0x8(%ebp)
  80124a:	e8 6c fb ff ff       	call   800dbb <fd_lookup>
  80124f:	83 c4 08             	add    $0x8,%esp
  801252:	89 c2                	mov    %eax,%edx
  801254:	85 c0                	test   %eax,%eax
  801256:	78 58                	js     8012b0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125e:	50                   	push   %eax
  80125f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801262:	ff 30                	pushl  (%eax)
  801264:	e8 a8 fb ff ff       	call   800e11 <dev_lookup>
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 37                	js     8012a7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801270:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801273:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801277:	74 32                	je     8012ab <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801279:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80127c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801283:	00 00 00 
	stat->st_isdir = 0;
  801286:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80128d:	00 00 00 
	stat->st_dev = dev;
  801290:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	53                   	push   %ebx
  80129a:	ff 75 f0             	pushl  -0x10(%ebp)
  80129d:	ff 50 14             	call   *0x14(%eax)
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	83 c4 10             	add    $0x10,%esp
  8012a5:	eb 09                	jmp    8012b0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a7:	89 c2                	mov    %eax,%edx
  8012a9:	eb 05                	jmp    8012b0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b0:	89 d0                	mov    %edx,%eax
  8012b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b5:	c9                   	leave  
  8012b6:	c3                   	ret    

008012b7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012b7:	55                   	push   %ebp
  8012b8:	89 e5                	mov    %esp,%ebp
  8012ba:	56                   	push   %esi
  8012bb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012bc:	83 ec 08             	sub    $0x8,%esp
  8012bf:	6a 00                	push   $0x0
  8012c1:	ff 75 08             	pushl  0x8(%ebp)
  8012c4:	e8 ef 01 00 00       	call   8014b8 <open>
  8012c9:	89 c3                	mov    %eax,%ebx
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 1b                	js     8012ed <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	ff 75 0c             	pushl  0xc(%ebp)
  8012d8:	50                   	push   %eax
  8012d9:	e8 5b ff ff ff       	call   801239 <fstat>
  8012de:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e0:	89 1c 24             	mov    %ebx,(%esp)
  8012e3:	e8 fd fb ff ff       	call   800ee5 <close>
	return r;
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	89 f0                	mov    %esi,%eax
}
  8012ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	89 c6                	mov    %eax,%esi
  8012fb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012fd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801304:	75 12                	jne    801318 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801306:	83 ec 0c             	sub    $0xc,%esp
  801309:	6a 01                	push   $0x1
  80130b:	e8 9d 0c 00 00       	call   801fad <ipc_find_env>
  801310:	a3 00 40 80 00       	mov    %eax,0x804000
  801315:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801318:	6a 07                	push   $0x7
  80131a:	68 00 50 80 00       	push   $0x805000
  80131f:	56                   	push   %esi
  801320:	ff 35 00 40 80 00    	pushl  0x804000
  801326:	e8 33 0c 00 00       	call   801f5e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80132b:	83 c4 0c             	add    $0xc,%esp
  80132e:	6a 00                	push   $0x0
  801330:	53                   	push   %ebx
  801331:	6a 00                	push   $0x0
  801333:	e8 b0 0b 00 00       	call   801ee8 <ipc_recv>
}
  801338:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	8b 40 0c             	mov    0xc(%eax),%eax
  80134b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801350:	8b 45 0c             	mov    0xc(%ebp),%eax
  801353:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801358:	ba 00 00 00 00       	mov    $0x0,%edx
  80135d:	b8 02 00 00 00       	mov    $0x2,%eax
  801362:	e8 8d ff ff ff       	call   8012f4 <fsipc>
}
  801367:	c9                   	leave  
  801368:	c3                   	ret    

00801369 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80136f:	8b 45 08             	mov    0x8(%ebp),%eax
  801372:	8b 40 0c             	mov    0xc(%eax),%eax
  801375:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80137a:	ba 00 00 00 00       	mov    $0x0,%edx
  80137f:	b8 06 00 00 00       	mov    $0x6,%eax
  801384:	e8 6b ff ff ff       	call   8012f4 <fsipc>
}
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	53                   	push   %ebx
  80138f:	83 ec 04             	sub    $0x4,%esp
  801392:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801395:	8b 45 08             	mov    0x8(%ebp),%eax
  801398:	8b 40 0c             	mov    0xc(%eax),%eax
  80139b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a5:	b8 05 00 00 00       	mov    $0x5,%eax
  8013aa:	e8 45 ff ff ff       	call   8012f4 <fsipc>
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 2c                	js     8013df <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	68 00 50 80 00       	push   $0x805000
  8013bb:	53                   	push   %ebx
  8013bc:	e8 71 f3 ff ff       	call   800732 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c1:	a1 80 50 80 00       	mov    0x805080,%eax
  8013c6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013cc:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	53                   	push   %ebx
  8013e8:	83 ec 08             	sub    $0x8,%esp
  8013eb:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8013f4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013fa:	a3 04 50 80 00       	mov    %eax,0x805004
  8013ff:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801404:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801409:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80140c:	53                   	push   %ebx
  80140d:	ff 75 0c             	pushl  0xc(%ebp)
  801410:	68 08 50 80 00       	push   $0x805008
  801415:	e8 aa f4 ff ff       	call   8008c4 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80141a:	ba 00 00 00 00       	mov    $0x0,%edx
  80141f:	b8 04 00 00 00       	mov    $0x4,%eax
  801424:	e8 cb fe ff ff       	call   8012f4 <fsipc>
  801429:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80142c:	85 c0                	test   %eax,%eax
  80142e:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	56                   	push   %esi
  80143a:	53                   	push   %ebx
  80143b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80143e:	8b 45 08             	mov    0x8(%ebp),%eax
  801441:	8b 40 0c             	mov    0xc(%eax),%eax
  801444:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801449:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80144f:	ba 00 00 00 00       	mov    $0x0,%edx
  801454:	b8 03 00 00 00       	mov    $0x3,%eax
  801459:	e8 96 fe ff ff       	call   8012f4 <fsipc>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	85 c0                	test   %eax,%eax
  801462:	78 4b                	js     8014af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801464:	39 c6                	cmp    %eax,%esi
  801466:	73 16                	jae    80147e <devfile_read+0x48>
  801468:	68 fc 26 80 00       	push   $0x8026fc
  80146d:	68 03 27 80 00       	push   $0x802703
  801472:	6a 7c                	push   $0x7c
  801474:	68 18 27 80 00       	push   $0x802718
  801479:	e8 24 0a 00 00       	call   801ea2 <_panic>
	assert(r <= PGSIZE);
  80147e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801483:	7e 16                	jle    80149b <devfile_read+0x65>
  801485:	68 23 27 80 00       	push   $0x802723
  80148a:	68 03 27 80 00       	push   $0x802703
  80148f:	6a 7d                	push   $0x7d
  801491:	68 18 27 80 00       	push   $0x802718
  801496:	e8 07 0a 00 00       	call   801ea2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	50                   	push   %eax
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	ff 75 0c             	pushl  0xc(%ebp)
  8014a7:	e8 18 f4 ff ff       	call   8008c4 <memmove>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
}
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 20             	sub    $0x20,%esp
  8014bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c2:	53                   	push   %ebx
  8014c3:	e8 31 f2 ff ff       	call   8006f9 <strlen>
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d0:	7f 67                	jg     801539 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	e8 8e f8 ff ff       	call   800d6c <fd_alloc>
  8014de:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 57                	js     80153e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	53                   	push   %ebx
  8014eb:	68 00 50 80 00       	push   $0x805000
  8014f0:	e8 3d f2 ff ff       	call   800732 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801500:	b8 01 00 00 00       	mov    $0x1,%eax
  801505:	e8 ea fd ff ff       	call   8012f4 <fsipc>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	79 14                	jns    801527 <open+0x6f>
		fd_close(fd, 0);
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	6a 00                	push   $0x0
  801518:	ff 75 f4             	pushl  -0xc(%ebp)
  80151b:	e8 44 f9 ff ff       	call   800e64 <fd_close>
		return r;
  801520:	83 c4 10             	add    $0x10,%esp
  801523:	89 da                	mov    %ebx,%edx
  801525:	eb 17                	jmp    80153e <open+0x86>
	}

	return fd2num(fd);
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	ff 75 f4             	pushl  -0xc(%ebp)
  80152d:	e8 13 f8 ff ff       	call   800d45 <fd2num>
  801532:	89 c2                	mov    %eax,%edx
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	eb 05                	jmp    80153e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801539:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80153e:	89 d0                	mov    %edx,%eax
  801540:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801543:	c9                   	leave  
  801544:	c3                   	ret    

00801545 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801545:	55                   	push   %ebp
  801546:	89 e5                	mov    %esp,%ebp
  801548:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80154b:	ba 00 00 00 00       	mov    $0x0,%edx
  801550:	b8 08 00 00 00       	mov    $0x8,%eax
  801555:	e8 9a fd ff ff       	call   8012f4 <fsipc>
}
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801564:	83 ec 0c             	sub    $0xc,%esp
  801567:	ff 75 08             	pushl  0x8(%ebp)
  80156a:	e8 e6 f7 ff ff       	call   800d55 <fd2data>
  80156f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801571:	83 c4 08             	add    $0x8,%esp
  801574:	68 2f 27 80 00       	push   $0x80272f
  801579:	53                   	push   %ebx
  80157a:	e8 b3 f1 ff ff       	call   800732 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80157f:	8b 46 04             	mov    0x4(%esi),%eax
  801582:	2b 06                	sub    (%esi),%eax
  801584:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80158a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801591:	00 00 00 
	stat->st_dev = &devpipe;
  801594:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80159b:	30 80 00 
	return 0;
}
  80159e:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015b4:	53                   	push   %ebx
  8015b5:	6a 00                	push   $0x0
  8015b7:	e8 fe f5 ff ff       	call   800bba <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015bc:	89 1c 24             	mov    %ebx,(%esp)
  8015bf:	e8 91 f7 ff ff       	call   800d55 <fd2data>
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	50                   	push   %eax
  8015c8:	6a 00                	push   $0x0
  8015ca:	e8 eb f5 ff ff       	call   800bba <sys_page_unmap>
}
  8015cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	57                   	push   %edi
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 1c             	sub    $0x1c,%esp
  8015dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015e0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f0:	e8 f1 09 00 00       	call   801fe6 <pageref>
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	89 3c 24             	mov    %edi,(%esp)
  8015fa:	e8 e7 09 00 00       	call   801fe6 <pageref>
  8015ff:	83 c4 10             	add    $0x10,%esp
  801602:	39 c3                	cmp    %eax,%ebx
  801604:	0f 94 c1             	sete   %cl
  801607:	0f b6 c9             	movzbl %cl,%ecx
  80160a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80160d:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801613:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801616:	39 ce                	cmp    %ecx,%esi
  801618:	74 1b                	je     801635 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80161a:	39 c3                	cmp    %eax,%ebx
  80161c:	75 c4                	jne    8015e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80161e:	8b 42 58             	mov    0x58(%edx),%eax
  801621:	ff 75 e4             	pushl  -0x1c(%ebp)
  801624:	50                   	push   %eax
  801625:	56                   	push   %esi
  801626:	68 36 27 80 00       	push   $0x802736
  80162b:	e8 5d eb ff ff       	call   80018d <cprintf>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb ad                	jmp    8015e2 <_pipeisclosed+0xe>
	}
}
  801635:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    

00801640 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801640:	55                   	push   %ebp
  801641:	89 e5                	mov    %esp,%ebp
  801643:	57                   	push   %edi
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	83 ec 28             	sub    $0x28,%esp
  801649:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80164c:	56                   	push   %esi
  80164d:	e8 03 f7 ff ff       	call   800d55 <fd2data>
  801652:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	bf 00 00 00 00       	mov    $0x0,%edi
  80165c:	eb 4b                	jmp    8016a9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80165e:	89 da                	mov    %ebx,%edx
  801660:	89 f0                	mov    %esi,%eax
  801662:	e8 6d ff ff ff       	call   8015d4 <_pipeisclosed>
  801667:	85 c0                	test   %eax,%eax
  801669:	75 48                	jne    8016b3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80166b:	e8 a6 f4 ff ff       	call   800b16 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801670:	8b 43 04             	mov    0x4(%ebx),%eax
  801673:	8b 0b                	mov    (%ebx),%ecx
  801675:	8d 51 20             	lea    0x20(%ecx),%edx
  801678:	39 d0                	cmp    %edx,%eax
  80167a:	73 e2                	jae    80165e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80167c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801683:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801686:	89 c2                	mov    %eax,%edx
  801688:	c1 fa 1f             	sar    $0x1f,%edx
  80168b:	89 d1                	mov    %edx,%ecx
  80168d:	c1 e9 1b             	shr    $0x1b,%ecx
  801690:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801693:	83 e2 1f             	and    $0x1f,%edx
  801696:	29 ca                	sub    %ecx,%edx
  801698:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80169c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016a0:	83 c0 01             	add    $0x1,%eax
  8016a3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a6:	83 c7 01             	add    $0x1,%edi
  8016a9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016ac:	75 c2                	jne    801670 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b1:	eb 05                	jmp    8016b8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5f                   	pop    %edi
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	57                   	push   %edi
  8016c4:	56                   	push   %esi
  8016c5:	53                   	push   %ebx
  8016c6:	83 ec 18             	sub    $0x18,%esp
  8016c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016cc:	57                   	push   %edi
  8016cd:	e8 83 f6 ff ff       	call   800d55 <fd2data>
  8016d2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016dc:	eb 3d                	jmp    80171b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016de:	85 db                	test   %ebx,%ebx
  8016e0:	74 04                	je     8016e6 <devpipe_read+0x26>
				return i;
  8016e2:	89 d8                	mov    %ebx,%eax
  8016e4:	eb 44                	jmp    80172a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016e6:	89 f2                	mov    %esi,%edx
  8016e8:	89 f8                	mov    %edi,%eax
  8016ea:	e8 e5 fe ff ff       	call   8015d4 <_pipeisclosed>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	75 32                	jne    801725 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016f3:	e8 1e f4 ff ff       	call   800b16 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f8:	8b 06                	mov    (%esi),%eax
  8016fa:	3b 46 04             	cmp    0x4(%esi),%eax
  8016fd:	74 df                	je     8016de <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ff:	99                   	cltd   
  801700:	c1 ea 1b             	shr    $0x1b,%edx
  801703:	01 d0                	add    %edx,%eax
  801705:	83 e0 1f             	and    $0x1f,%eax
  801708:	29 d0                	sub    %edx,%eax
  80170a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80170f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801712:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801715:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801718:	83 c3 01             	add    $0x1,%ebx
  80171b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80171e:	75 d8                	jne    8016f8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801720:	8b 45 10             	mov    0x10(%ebp),%eax
  801723:	eb 05                	jmp    80172a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801725:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80172a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172d:	5b                   	pop    %ebx
  80172e:	5e                   	pop    %esi
  80172f:	5f                   	pop    %edi
  801730:	5d                   	pop    %ebp
  801731:	c3                   	ret    

00801732 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	e8 29 f6 ff ff       	call   800d6c <fd_alloc>
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	89 c2                	mov    %eax,%edx
  801748:	85 c0                	test   %eax,%eax
  80174a:	0f 88 2c 01 00 00    	js     80187c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801750:	83 ec 04             	sub    $0x4,%esp
  801753:	68 07 04 00 00       	push   $0x407
  801758:	ff 75 f4             	pushl  -0xc(%ebp)
  80175b:	6a 00                	push   $0x0
  80175d:	e8 d3 f3 ff ff       	call   800b35 <sys_page_alloc>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	89 c2                	mov    %eax,%edx
  801767:	85 c0                	test   %eax,%eax
  801769:	0f 88 0d 01 00 00    	js     80187c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801775:	50                   	push   %eax
  801776:	e8 f1 f5 ff ff       	call   800d6c <fd_alloc>
  80177b:	89 c3                	mov    %eax,%ebx
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	85 c0                	test   %eax,%eax
  801782:	0f 88 e2 00 00 00    	js     80186a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801788:	83 ec 04             	sub    $0x4,%esp
  80178b:	68 07 04 00 00       	push   $0x407
  801790:	ff 75 f0             	pushl  -0x10(%ebp)
  801793:	6a 00                	push   $0x0
  801795:	e8 9b f3 ff ff       	call   800b35 <sys_page_alloc>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	0f 88 c3 00 00 00    	js     80186a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017a7:	83 ec 0c             	sub    $0xc,%esp
  8017aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ad:	e8 a3 f5 ff ff       	call   800d55 <fd2data>
  8017b2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b4:	83 c4 0c             	add    $0xc,%esp
  8017b7:	68 07 04 00 00       	push   $0x407
  8017bc:	50                   	push   %eax
  8017bd:	6a 00                	push   $0x0
  8017bf:	e8 71 f3 ff ff       	call   800b35 <sys_page_alloc>
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	83 c4 10             	add    $0x10,%esp
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	0f 88 89 00 00 00    	js     80185a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d1:	83 ec 0c             	sub    $0xc,%esp
  8017d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d7:	e8 79 f5 ff ff       	call   800d55 <fd2data>
  8017dc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017e3:	50                   	push   %eax
  8017e4:	6a 00                	push   $0x0
  8017e6:	56                   	push   %esi
  8017e7:	6a 00                	push   $0x0
  8017e9:	e8 8a f3 ff ff       	call   800b78 <sys_page_map>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 20             	add    $0x20,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 55                	js     80184c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017f7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801802:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801805:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80180c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801815:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801821:	83 ec 0c             	sub    $0xc,%esp
  801824:	ff 75 f4             	pushl  -0xc(%ebp)
  801827:	e8 19 f5 ff ff       	call   800d45 <fd2num>
  80182c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801831:	83 c4 04             	add    $0x4,%esp
  801834:	ff 75 f0             	pushl  -0x10(%ebp)
  801837:	e8 09 f5 ff ff       	call   800d45 <fd2num>
  80183c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	ba 00 00 00 00       	mov    $0x0,%edx
  80184a:	eb 30                	jmp    80187c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	56                   	push   %esi
  801850:	6a 00                	push   $0x0
  801852:	e8 63 f3 ff ff       	call   800bba <sys_page_unmap>
  801857:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	ff 75 f0             	pushl  -0x10(%ebp)
  801860:	6a 00                	push   $0x0
  801862:	e8 53 f3 ff ff       	call   800bba <sys_page_unmap>
  801867:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80186a:	83 ec 08             	sub    $0x8,%esp
  80186d:	ff 75 f4             	pushl  -0xc(%ebp)
  801870:	6a 00                	push   $0x0
  801872:	e8 43 f3 ff ff       	call   800bba <sys_page_unmap>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80187c:	89 d0                	mov    %edx,%eax
  80187e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801881:	5b                   	pop    %ebx
  801882:	5e                   	pop    %esi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80188b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188e:	50                   	push   %eax
  80188f:	ff 75 08             	pushl  0x8(%ebp)
  801892:	e8 24 f5 ff ff       	call   800dbb <fd_lookup>
  801897:	83 c4 10             	add    $0x10,%esp
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 18                	js     8018b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a4:	e8 ac f4 ff ff       	call   800d55 <fd2data>
	return _pipeisclosed(fd, p);
  8018a9:	89 c2                	mov    %eax,%edx
  8018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ae:	e8 21 fd ff ff       	call   8015d4 <_pipeisclosed>
  8018b3:	83 c4 10             	add    $0x10,%esp
}
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8018be:	68 4e 27 80 00       	push   $0x80274e
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	e8 67 ee ff ff       	call   800732 <strcpy>
	return 0;
}
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	53                   	push   %ebx
  8018d6:	83 ec 10             	sub    $0x10,%esp
  8018d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018dc:	53                   	push   %ebx
  8018dd:	e8 04 07 00 00       	call   801fe6 <pageref>
  8018e2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018e5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018ea:	83 f8 01             	cmp    $0x1,%eax
  8018ed:	75 10                	jne    8018ff <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018ef:	83 ec 0c             	sub    $0xc,%esp
  8018f2:	ff 73 0c             	pushl  0xc(%ebx)
  8018f5:	e8 c0 02 00 00       	call   801bba <nsipc_close>
  8018fa:	89 c2                	mov    %eax,%edx
  8018fc:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018ff:	89 d0                	mov    %edx,%eax
  801901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80190c:	6a 00                	push   $0x0
  80190e:	ff 75 10             	pushl  0x10(%ebp)
  801911:	ff 75 0c             	pushl  0xc(%ebp)
  801914:	8b 45 08             	mov    0x8(%ebp),%eax
  801917:	ff 70 0c             	pushl  0xc(%eax)
  80191a:	e8 78 03 00 00       	call   801c97 <nsipc_send>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801927:	6a 00                	push   $0x0
  801929:	ff 75 10             	pushl  0x10(%ebp)
  80192c:	ff 75 0c             	pushl  0xc(%ebp)
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	ff 70 0c             	pushl  0xc(%eax)
  801935:	e8 f1 02 00 00       	call   801c2b <nsipc_recv>
}
  80193a:	c9                   	leave  
  80193b:	c3                   	ret    

0080193c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801942:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801945:	52                   	push   %edx
  801946:	50                   	push   %eax
  801947:	e8 6f f4 ff ff       	call   800dbb <fd_lookup>
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	85 c0                	test   %eax,%eax
  801951:	78 17                	js     80196a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801956:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  80195c:	39 08                	cmp    %ecx,(%eax)
  80195e:	75 05                	jne    801965 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801960:	8b 40 0c             	mov    0xc(%eax),%eax
  801963:	eb 05                	jmp    80196a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801965:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	83 ec 1c             	sub    $0x1c,%esp
  801974:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801976:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801979:	50                   	push   %eax
  80197a:	e8 ed f3 ff ff       	call   800d6c <fd_alloc>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 1b                	js     8019a3 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801988:	83 ec 04             	sub    $0x4,%esp
  80198b:	68 07 04 00 00       	push   $0x407
  801990:	ff 75 f4             	pushl  -0xc(%ebp)
  801993:	6a 00                	push   $0x0
  801995:	e8 9b f1 ff ff       	call   800b35 <sys_page_alloc>
  80199a:	89 c3                	mov    %eax,%ebx
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	79 10                	jns    8019b3 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	56                   	push   %esi
  8019a7:	e8 0e 02 00 00       	call   801bba <nsipc_close>
		return r;
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	89 d8                	mov    %ebx,%eax
  8019b1:	eb 24                	jmp    8019d7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8019b3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019c8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019cb:	83 ec 0c             	sub    $0xc,%esp
  8019ce:	50                   	push   %eax
  8019cf:	e8 71 f3 ff ff       	call   800d45 <fd2num>
  8019d4:	83 c4 10             	add    $0x10,%esp
}
  8019d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019da:	5b                   	pop    %ebx
  8019db:	5e                   	pop    %esi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	e8 50 ff ff ff       	call   80193c <fd2sockid>
		return r;
  8019ec:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 1f                	js     801a11 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019f2:	83 ec 04             	sub    $0x4,%esp
  8019f5:	ff 75 10             	pushl  0x10(%ebp)
  8019f8:	ff 75 0c             	pushl  0xc(%ebp)
  8019fb:	50                   	push   %eax
  8019fc:	e8 12 01 00 00       	call   801b13 <nsipc_accept>
  801a01:	83 c4 10             	add    $0x10,%esp
		return r;
  801a04:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 07                	js     801a11 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a0a:	e8 5d ff ff ff       	call   80196c <alloc_sockfd>
  801a0f:	89 c1                	mov    %eax,%ecx
}
  801a11:	89 c8                	mov    %ecx,%eax
  801a13:	c9                   	leave  
  801a14:	c3                   	ret    

00801a15 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1e:	e8 19 ff ff ff       	call   80193c <fd2sockid>
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 12                	js     801a39 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801a27:	83 ec 04             	sub    $0x4,%esp
  801a2a:	ff 75 10             	pushl  0x10(%ebp)
  801a2d:	ff 75 0c             	pushl  0xc(%ebp)
  801a30:	50                   	push   %eax
  801a31:	e8 2d 01 00 00       	call   801b63 <nsipc_bind>
  801a36:	83 c4 10             	add    $0x10,%esp
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <shutdown>:

int
shutdown(int s, int how)
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a41:	8b 45 08             	mov    0x8(%ebp),%eax
  801a44:	e8 f3 fe ff ff       	call   80193c <fd2sockid>
  801a49:	85 c0                	test   %eax,%eax
  801a4b:	78 0f                	js     801a5c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a4d:	83 ec 08             	sub    $0x8,%esp
  801a50:	ff 75 0c             	pushl  0xc(%ebp)
  801a53:	50                   	push   %eax
  801a54:	e8 3f 01 00 00       	call   801b98 <nsipc_shutdown>
  801a59:	83 c4 10             	add    $0x10,%esp
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	e8 d0 fe ff ff       	call   80193c <fd2sockid>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 12                	js     801a82 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	ff 75 10             	pushl  0x10(%ebp)
  801a76:	ff 75 0c             	pushl  0xc(%ebp)
  801a79:	50                   	push   %eax
  801a7a:	e8 55 01 00 00       	call   801bd4 <nsipc_connect>
  801a7f:	83 c4 10             	add    $0x10,%esp
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <listen>:

int
listen(int s, int backlog)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	e8 aa fe ff ff       	call   80193c <fd2sockid>
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 0f                	js     801aa5 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a96:	83 ec 08             	sub    $0x8,%esp
  801a99:	ff 75 0c             	pushl  0xc(%ebp)
  801a9c:	50                   	push   %eax
  801a9d:	e8 67 01 00 00       	call   801c09 <nsipc_listen>
  801aa2:	83 c4 10             	add    $0x10,%esp
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801aad:	ff 75 10             	pushl  0x10(%ebp)
  801ab0:	ff 75 0c             	pushl  0xc(%ebp)
  801ab3:	ff 75 08             	pushl  0x8(%ebp)
  801ab6:	e8 3a 02 00 00       	call   801cf5 <nsipc_socket>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 05                	js     801ac7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ac2:	e8 a5 fe ff ff       	call   80196c <alloc_sockfd>
}
  801ac7:	c9                   	leave  
  801ac8:	c3                   	ret    

00801ac9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	53                   	push   %ebx
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ad2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ad9:	75 12                	jne    801aed <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	6a 02                	push   $0x2
  801ae0:	e8 c8 04 00 00       	call   801fad <ipc_find_env>
  801ae5:	a3 04 40 80 00       	mov    %eax,0x804004
  801aea:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801aed:	6a 07                	push   $0x7
  801aef:	68 00 60 80 00       	push   $0x806000
  801af4:	53                   	push   %ebx
  801af5:	ff 35 04 40 80 00    	pushl  0x804004
  801afb:	e8 5e 04 00 00       	call   801f5e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b00:	83 c4 0c             	add    $0xc,%esp
  801b03:	6a 00                	push   $0x0
  801b05:	6a 00                	push   $0x0
  801b07:	6a 00                	push   $0x0
  801b09:	e8 da 03 00 00       	call   801ee8 <ipc_recv>
}
  801b0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b11:	c9                   	leave  
  801b12:	c3                   	ret    

00801b13 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b23:	8b 06                	mov    (%esi),%eax
  801b25:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2f:	e8 95 ff ff ff       	call   801ac9 <nsipc>
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 20                	js     801b5a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b3a:	83 ec 04             	sub    $0x4,%esp
  801b3d:	ff 35 10 60 80 00    	pushl  0x806010
  801b43:	68 00 60 80 00       	push   $0x806000
  801b48:	ff 75 0c             	pushl  0xc(%ebp)
  801b4b:	e8 74 ed ff ff       	call   8008c4 <memmove>
		*addrlen = ret->ret_addrlen;
  801b50:	a1 10 60 80 00       	mov    0x806010,%eax
  801b55:	89 06                	mov    %eax,(%esi)
  801b57:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b5a:	89 d8                	mov    %ebx,%eax
  801b5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5f:	5b                   	pop    %ebx
  801b60:	5e                   	pop    %esi
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    

00801b63 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	53                   	push   %ebx
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b70:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b75:	53                   	push   %ebx
  801b76:	ff 75 0c             	pushl  0xc(%ebp)
  801b79:	68 04 60 80 00       	push   $0x806004
  801b7e:	e8 41 ed ff ff       	call   8008c4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b83:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b89:	b8 02 00 00 00       	mov    $0x2,%eax
  801b8e:	e8 36 ff ff ff       	call   801ac9 <nsipc>
}
  801b93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba9:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bae:	b8 03 00 00 00       	mov    $0x3,%eax
  801bb3:	e8 11 ff ff ff       	call   801ac9 <nsipc>
}
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <nsipc_close>:

int
nsipc_close(int s)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc3:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801bc8:	b8 04 00 00 00       	mov    $0x4,%eax
  801bcd:	e8 f7 fe ff ff       	call   801ac9 <nsipc>
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 08             	sub    $0x8,%esp
  801bdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801be6:	53                   	push   %ebx
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	68 04 60 80 00       	push   $0x806004
  801bef:	e8 d0 ec ff ff       	call   8008c4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bf4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bfa:	b8 05 00 00 00       	mov    $0x5,%eax
  801bff:	e8 c5 fe ff ff       	call   801ac9 <nsipc>
}
  801c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c1a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c1f:	b8 06 00 00 00       	mov    $0x6,%eax
  801c24:	e8 a0 fe ff ff       	call   801ac9 <nsipc>
}
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	56                   	push   %esi
  801c2f:	53                   	push   %ebx
  801c30:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c3b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c41:	8b 45 14             	mov    0x14(%ebp),%eax
  801c44:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c49:	b8 07 00 00 00       	mov    $0x7,%eax
  801c4e:	e8 76 fe ff ff       	call   801ac9 <nsipc>
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	85 c0                	test   %eax,%eax
  801c57:	78 35                	js     801c8e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c59:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c5e:	7f 04                	jg     801c64 <nsipc_recv+0x39>
  801c60:	39 c6                	cmp    %eax,%esi
  801c62:	7d 16                	jge    801c7a <nsipc_recv+0x4f>
  801c64:	68 5a 27 80 00       	push   $0x80275a
  801c69:	68 03 27 80 00       	push   $0x802703
  801c6e:	6a 62                	push   $0x62
  801c70:	68 6f 27 80 00       	push   $0x80276f
  801c75:	e8 28 02 00 00       	call   801ea2 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c7a:	83 ec 04             	sub    $0x4,%esp
  801c7d:	50                   	push   %eax
  801c7e:	68 00 60 80 00       	push   $0x806000
  801c83:	ff 75 0c             	pushl  0xc(%ebp)
  801c86:	e8 39 ec ff ff       	call   8008c4 <memmove>
  801c8b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c8e:	89 d8                	mov    %ebx,%eax
  801c90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	53                   	push   %ebx
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ca9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801caf:	7e 16                	jle    801cc7 <nsipc_send+0x30>
  801cb1:	68 7b 27 80 00       	push   $0x80277b
  801cb6:	68 03 27 80 00       	push   $0x802703
  801cbb:	6a 6d                	push   $0x6d
  801cbd:	68 6f 27 80 00       	push   $0x80276f
  801cc2:	e8 db 01 00 00       	call   801ea2 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cc7:	83 ec 04             	sub    $0x4,%esp
  801cca:	53                   	push   %ebx
  801ccb:	ff 75 0c             	pushl  0xc(%ebp)
  801cce:	68 0c 60 80 00       	push   $0x80600c
  801cd3:	e8 ec eb ff ff       	call   8008c4 <memmove>
	nsipcbuf.send.req_size = size;
  801cd8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cde:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ce6:	b8 08 00 00 00       	mov    $0x8,%eax
  801ceb:	e8 d9 fd ff ff       	call   801ac9 <nsipc>
}
  801cf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d06:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d13:	b8 09 00 00 00       	mov    $0x9,%eax
  801d18:	e8 ac fd ff ff       	call   801ac9 <nsipc>
}
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    

00801d1f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d22:	b8 00 00 00 00       	mov    $0x0,%eax
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2f:	68 87 27 80 00       	push   $0x802787
  801d34:	ff 75 0c             	pushl  0xc(%ebp)
  801d37:	e8 f6 e9 ff ff       	call   800732 <strcpy>
	return 0;
}
  801d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	57                   	push   %edi
  801d47:	56                   	push   %esi
  801d48:	53                   	push   %ebx
  801d49:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d54:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d5a:	eb 2d                	jmp    801d89 <devcons_write+0x46>
		m = n - tot;
  801d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d61:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d64:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d69:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6c:	83 ec 04             	sub    $0x4,%esp
  801d6f:	53                   	push   %ebx
  801d70:	03 45 0c             	add    0xc(%ebp),%eax
  801d73:	50                   	push   %eax
  801d74:	57                   	push   %edi
  801d75:	e8 4a eb ff ff       	call   8008c4 <memmove>
		sys_cputs(buf, m);
  801d7a:	83 c4 08             	add    $0x8,%esp
  801d7d:	53                   	push   %ebx
  801d7e:	57                   	push   %edi
  801d7f:	e8 f5 ec ff ff       	call   800a79 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d84:	01 de                	add    %ebx,%esi
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	89 f0                	mov    %esi,%eax
  801d8b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8e:	72 cc                	jb     801d5c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 08             	sub    $0x8,%esp
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da7:	74 2a                	je     801dd3 <devcons_read+0x3b>
  801da9:	eb 05                	jmp    801db0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dab:	e8 66 ed ff ff       	call   800b16 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801db0:	e8 e2 ec ff ff       	call   800a97 <sys_cgetc>
  801db5:	85 c0                	test   %eax,%eax
  801db7:	74 f2                	je     801dab <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	78 16                	js     801dd3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbd:	83 f8 04             	cmp    $0x4,%eax
  801dc0:	74 0c                	je     801dce <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc5:	88 02                	mov    %al,(%edx)
	return 1;
  801dc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcc:	eb 05                	jmp    801dd3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801de1:	6a 01                	push   $0x1
  801de3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de6:	50                   	push   %eax
  801de7:	e8 8d ec ff ff       	call   800a79 <sys_cputs>
}
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	c9                   	leave  
  801df0:	c3                   	ret    

00801df1 <getchar>:

int
getchar(void)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df7:	6a 01                	push   $0x1
  801df9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfc:	50                   	push   %eax
  801dfd:	6a 00                	push   $0x0
  801dff:	e8 1d f2 ff ff       	call   801021 <read>
	if (r < 0)
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	85 c0                	test   %eax,%eax
  801e09:	78 0f                	js     801e1a <getchar+0x29>
		return r;
	if (r < 1)
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	7e 06                	jle    801e15 <getchar+0x24>
		return -E_EOF;
	return c;
  801e0f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e13:	eb 05                	jmp    801e1a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e15:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e25:	50                   	push   %eax
  801e26:	ff 75 08             	pushl  0x8(%ebp)
  801e29:	e8 8d ef ff ff       	call   800dbb <fd_lookup>
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 11                	js     801e46 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e38:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e3e:	39 10                	cmp    %edx,(%eax)
  801e40:	0f 94 c0             	sete   %al
  801e43:	0f b6 c0             	movzbl %al,%eax
}
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <opencons>:

int
opencons(void)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e51:	50                   	push   %eax
  801e52:	e8 15 ef ff ff       	call   800d6c <fd_alloc>
  801e57:	83 c4 10             	add    $0x10,%esp
		return r;
  801e5a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 3e                	js     801e9e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e60:	83 ec 04             	sub    $0x4,%esp
  801e63:	68 07 04 00 00       	push   $0x407
  801e68:	ff 75 f4             	pushl  -0xc(%ebp)
  801e6b:	6a 00                	push   $0x0
  801e6d:	e8 c3 ec ff ff       	call   800b35 <sys_page_alloc>
  801e72:	83 c4 10             	add    $0x10,%esp
		return r;
  801e75:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e77:	85 c0                	test   %eax,%eax
  801e79:	78 23                	js     801e9e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e7b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e84:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e89:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e90:	83 ec 0c             	sub    $0xc,%esp
  801e93:	50                   	push   %eax
  801e94:	e8 ac ee ff ff       	call   800d45 <fd2num>
  801e99:	89 c2                	mov    %eax,%edx
  801e9b:	83 c4 10             	add    $0x10,%esp
}
  801e9e:	89 d0                	mov    %edx,%eax
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	56                   	push   %esi
  801ea6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ea7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801eaa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eb0:	e8 42 ec ff ff       	call   800af7 <sys_getenvid>
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	ff 75 0c             	pushl  0xc(%ebp)
  801ebb:	ff 75 08             	pushl  0x8(%ebp)
  801ebe:	56                   	push   %esi
  801ebf:	50                   	push   %eax
  801ec0:	68 94 27 80 00       	push   $0x802794
  801ec5:	e8 c3 e2 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eca:	83 c4 18             	add    $0x18,%esp
  801ecd:	53                   	push   %ebx
  801ece:	ff 75 10             	pushl  0x10(%ebp)
  801ed1:	e8 66 e2 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801ed6:	c7 04 24 47 27 80 00 	movl   $0x802747,(%esp)
  801edd:	e8 ab e2 ff ff       	call   80018d <cprintf>
  801ee2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee5:	cc                   	int3   
  801ee6:	eb fd                	jmp    801ee5 <_panic+0x43>

00801ee8 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
  801eed:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	74 0e                	je     801f08 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801efa:	83 ec 0c             	sub    $0xc,%esp
  801efd:	50                   	push   %eax
  801efe:	e8 e2 ed ff ff       	call   800ce5 <sys_ipc_recv>
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	eb 10                	jmp    801f18 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801f08:	83 ec 0c             	sub    $0xc,%esp
  801f0b:	68 00 00 c0 ee       	push   $0xeec00000
  801f10:	e8 d0 ed ff ff       	call   800ce5 <sys_ipc_recv>
  801f15:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	79 17                	jns    801f33 <ipc_recv+0x4b>
		if(*from_env_store)
  801f1c:	83 3e 00             	cmpl   $0x0,(%esi)
  801f1f:	74 06                	je     801f27 <ipc_recv+0x3f>
			*from_env_store = 0;
  801f21:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801f27:	85 db                	test   %ebx,%ebx
  801f29:	74 2c                	je     801f57 <ipc_recv+0x6f>
			*perm_store = 0;
  801f2b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f31:	eb 24                	jmp    801f57 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801f33:	85 f6                	test   %esi,%esi
  801f35:	74 0a                	je     801f41 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801f37:	a1 08 40 80 00       	mov    0x804008,%eax
  801f3c:	8b 40 74             	mov    0x74(%eax),%eax
  801f3f:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801f41:	85 db                	test   %ebx,%ebx
  801f43:	74 0a                	je     801f4f <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801f45:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4a:	8b 40 78             	mov    0x78(%eax),%eax
  801f4d:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f4f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f54:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5d                   	pop    %ebp
  801f5d:	c3                   	ret    

00801f5e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	53                   	push   %ebx
  801f64:	83 ec 0c             	sub    $0xc,%esp
  801f67:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f70:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f72:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f77:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f7a:	e8 97 eb ff ff       	call   800b16 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f7f:	ff 75 14             	pushl  0x14(%ebp)
  801f82:	53                   	push   %ebx
  801f83:	56                   	push   %esi
  801f84:	57                   	push   %edi
  801f85:	e8 38 ed ff ff       	call   800cc2 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f8a:	89 c2                	mov    %eax,%edx
  801f8c:	f7 d2                	not    %edx
  801f8e:	c1 ea 1f             	shr    $0x1f,%edx
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f97:	0f 94 c1             	sete   %cl
  801f9a:	09 ca                	or     %ecx,%edx
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	0f 94 c0             	sete   %al
  801fa1:	38 c2                	cmp    %al,%dl
  801fa3:	77 d5                	ja     801f7a <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801fa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa8:	5b                   	pop    %ebx
  801fa9:	5e                   	pop    %esi
  801faa:	5f                   	pop    %edi
  801fab:	5d                   	pop    %ebp
  801fac:	c3                   	ret    

00801fad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fbb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc1:	8b 52 50             	mov    0x50(%edx),%edx
  801fc4:	39 ca                	cmp    %ecx,%edx
  801fc6:	75 0d                	jne    801fd5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fc8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fcb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd0:	8b 40 48             	mov    0x48(%eax),%eax
  801fd3:	eb 0f                	jmp    801fe4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fd5:	83 c0 01             	add    $0x1,%eax
  801fd8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fdd:	75 d9                	jne    801fb8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    

00801fe6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fec:	89 d0                	mov    %edx,%eax
  801fee:	c1 e8 16             	shr    $0x16,%eax
  801ff1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ff8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ffd:	f6 c1 01             	test   $0x1,%cl
  802000:	74 1d                	je     80201f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802002:	c1 ea 0c             	shr    $0xc,%edx
  802005:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80200c:	f6 c2 01             	test   $0x1,%dl
  80200f:	74 0e                	je     80201f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802011:	c1 ea 0c             	shr    $0xc,%edx
  802014:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80201b:	ef 
  80201c:	0f b7 c0             	movzwl %ax,%eax
}
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    
  802021:	66 90                	xchg   %ax,%ax
  802023:	66 90                	xchg   %ax,%ax
  802025:	66 90                	xchg   %ax,%ax
  802027:	66 90                	xchg   %ax,%ax
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
