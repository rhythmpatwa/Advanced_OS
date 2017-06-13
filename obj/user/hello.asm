
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 80 22 80 00       	push   $0x802280
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 8e 22 80 00       	push   $0x80228e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800069:	e8 4d 0a 00 00       	call   800abb <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 25 0e 00 00       	call   800ed4 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 c1 09 00 00       	call   800a7a <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 4f 09 00 00       	call   800a3d <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 54 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 f4 08 00 00       	call   800a3d <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 37 1e 00 00       	call   801ff0 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 24 1f 00 00       	call   802120 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 af 22 80 00 	movsbl 0x8022af(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800217:	83 fa 01             	cmp    $0x1,%edx
  80021a:	7e 0e                	jle    80022a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	8b 52 04             	mov    0x4(%edx),%edx
  800228:	eb 22                	jmp    80024c <getuint+0x38>
	else if (lflag)
  80022a:	85 d2                	test   %edx,%edx
  80022c:	74 10                	je     80023e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	eb 0e                	jmp    80024c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 04             	lea    0x4(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	3b 50 04             	cmp    0x4(%eax),%edx
  80025d:	73 0a                	jae    800269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	88 02                	mov    %al,(%edx)
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
	va_end(ap);
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 2c             	sub    $0x2c,%esp
  800291:	8b 75 08             	mov    0x8(%ebp),%esi
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029a:	eb 12                	jmp    8002ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029c:	85 c0                	test   %eax,%eax
  80029e:	0f 84 a9 03 00 00    	je     80064d <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	53                   	push   %ebx
  8002a8:	50                   	push   %eax
  8002a9:	ff d6                	call   *%esi
  8002ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ae:	83 c7 01             	add    $0x1,%edi
  8002b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	75 e2                	jne    80029c <vprintfmt+0x14>
  8002ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	eb 07                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 07             	movzbl (%edi),%eax
  8002ea:	0f b6 c8             	movzbl %al,%ecx
  8002ed:	83 e8 23             	sub    $0x23,%eax
  8002f0:	3c 55                	cmp    $0x55,%al
  8002f2:	0f 87 3a 03 00 00    	ja     800632 <vprintfmt+0x3aa>
  8002f8:	0f b6 c0             	movzbl %al,%eax
  8002fb:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800305:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800309:	eb d6                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030e:	b8 00 00 00 00       	mov    $0x0,%eax
  800313:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800316:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800319:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800320:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800323:	83 fa 09             	cmp    $0x9,%edx
  800326:	77 39                	ja     800361 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800328:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032b:	eb e9                	jmp    800316 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032d:	8b 45 14             	mov    0x14(%ebp),%eax
  800330:	8d 48 04             	lea    0x4(%eax),%ecx
  800333:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800336:	8b 00                	mov    (%eax),%eax
  800338:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80033e:	eb 27                	jmp    800367 <vprintfmt+0xdf>
  800340:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	0f 49 c8             	cmovns %eax,%ecx
  80034d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	eb 8c                	jmp    8002e1 <vprintfmt+0x59>
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800358:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035f:	eb 80                	jmp    8002e1 <vprintfmt+0x59>
  800361:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800364:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036b:	0f 89 70 ff ff ff    	jns    8002e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800371:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800374:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	e9 5e ff ff ff       	jmp    8002e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800383:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800389:	e9 53 ff ff ff       	jmp    8002e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8d 50 04             	lea    0x4(%eax),%edx
  800394:	89 55 14             	mov    %edx,0x14(%ebp)
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	53                   	push   %ebx
  80039b:	ff 30                	pushl  (%eax)
  80039d:	ff d6                	call   *%esi
			break;
  80039f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a5:	e9 04 ff ff ff       	jmp    8002ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 50 04             	lea    0x4(%eax),%edx
  8003b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	99                   	cltd   
  8003b6:	31 d0                	xor    %edx,%eax
  8003b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 0b                	jg     8003ca <vprintfmt+0x142>
  8003bf:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	75 18                	jne    8003e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ca:	50                   	push   %eax
  8003cb:	68 c7 22 80 00       	push   $0x8022c7
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 94 fe ff ff       	call   80026b <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003dd:	e9 cc fe ff ff       	jmp    8002ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e2:	52                   	push   %edx
  8003e3:	68 95 26 80 00       	push   $0x802695
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 7c fe ff ff       	call   80026b <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	e9 b4 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800405:	85 ff                	test   %edi,%edi
  800407:	b8 c0 22 80 00       	mov    $0x8022c0,%eax
  80040c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80040f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800413:	0f 8e 94 00 00 00    	jle    8004ad <vprintfmt+0x225>
  800419:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041d:	0f 84 98 00 00 00    	je     8004bb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	ff 75 d0             	pushl  -0x30(%ebp)
  800429:	57                   	push   %edi
  80042a:	e8 a6 02 00 00       	call   8006d5 <strnlen>
  80042f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800432:	29 c1                	sub    %eax,%ecx
  800434:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800441:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800444:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	eb 0f                	jmp    800457 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	53                   	push   %ebx
  80044c:	ff 75 e0             	pushl  -0x20(%ebp)
  80044f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ef 01             	sub    $0x1,%edi
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	85 ff                	test   %edi,%edi
  800459:	7f ed                	jg     800448 <vprintfmt+0x1c0>
  80045b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800461:	85 c9                	test   %ecx,%ecx
  800463:	b8 00 00 00 00       	mov    $0x0,%eax
  800468:	0f 49 c1             	cmovns %ecx,%eax
  80046b:	29 c1                	sub    %eax,%ecx
  80046d:	89 75 08             	mov    %esi,0x8(%ebp)
  800470:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800473:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800476:	89 cb                	mov    %ecx,%ebx
  800478:	eb 4d                	jmp    8004c7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047e:	74 1b                	je     80049b <vprintfmt+0x213>
  800480:	0f be c0             	movsbl %al,%eax
  800483:	83 e8 20             	sub    $0x20,%eax
  800486:	83 f8 5e             	cmp    $0x5e,%eax
  800489:	76 10                	jbe    80049b <vprintfmt+0x213>
					putch('?', putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	6a 3f                	push   $0x3f
  800493:	ff 55 08             	call   *0x8(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	eb 0d                	jmp    8004a8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	52                   	push   %edx
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a8:	83 eb 01             	sub    $0x1,%ebx
  8004ab:	eb 1a                	jmp    8004c7 <vprintfmt+0x23f>
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b9:	eb 0c                	jmp    8004c7 <vprintfmt+0x23f>
  8004bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c7:	83 c7 01             	add    $0x1,%edi
  8004ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ce:	0f be d0             	movsbl %al,%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	74 23                	je     8004f8 <vprintfmt+0x270>
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	78 a1                	js     80047a <vprintfmt+0x1f2>
  8004d9:	83 ee 01             	sub    $0x1,%esi
  8004dc:	79 9c                	jns    80047a <vprintfmt+0x1f2>
  8004de:	89 df                	mov    %ebx,%edi
  8004e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e6:	eb 18                	jmp    800500 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	6a 20                	push   $0x20
  8004ee:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb 08                	jmp    800500 <vprintfmt+0x278>
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800500:	85 ff                	test   %edi,%edi
  800502:	7f e4                	jg     8004e8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	e9 a2 fd ff ff       	jmp    8002ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050c:	83 fa 01             	cmp    $0x1,%edx
  80050f:	7e 16                	jle    800527 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 08             	lea    0x8(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 50 04             	mov    0x4(%eax),%edx
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800522:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800525:	eb 32                	jmp    800559 <vprintfmt+0x2d1>
	else if (lflag)
  800527:	85 d2                	test   %edx,%edx
  800529:	74 18                	je     800543 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800539:	89 c1                	mov    %eax,%ecx
  80053b:	c1 f9 1f             	sar    $0x1f,%ecx
  80053e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800541:	eb 16                	jmp    800559 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800559:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800564:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800568:	0f 89 90 00 00 00    	jns    8005fe <vprintfmt+0x376>
				putch('-', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	6a 2d                	push   $0x2d
  800574:	ff d6                	call   *%esi
				num = -(long long) num;
  800576:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800579:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057c:	f7 d8                	neg    %eax
  80057e:	83 d2 00             	adc    $0x0,%edx
  800581:	f7 da                	neg    %edx
  800583:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800586:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058b:	eb 71                	jmp    8005fe <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058d:	8d 45 14             	lea    0x14(%ebp),%eax
  800590:	e8 7f fc ff ff       	call   800214 <getuint>
			base = 10;
  800595:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80059a:	eb 62                	jmp    8005fe <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80059c:	8d 45 14             	lea    0x14(%ebp),%eax
  80059f:	e8 70 fc ff ff       	call   800214 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005ab:	51                   	push   %ecx
  8005ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8005af:	6a 08                	push   $0x8
  8005b1:	52                   	push   %edx
  8005b2:	50                   	push   %eax
  8005b3:	89 da                	mov    %ebx,%edx
  8005b5:	89 f0                	mov    %esi,%eax
  8005b7:	e8 a9 fb ff ff       	call   800165 <printnum>
			break;
  8005bc:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8005c2:	e9 e7 fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 30                	push   $0x30
  8005cd:	ff d6                	call   *%esi
			putch('x', putdat);
  8005cf:	83 c4 08             	add    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 78                	push   $0x78
  8005d5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 04             	lea    0x4(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ea:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005ef:	eb 0d                	jmp    8005fe <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f4:	e8 1b fc ff ff       	call   800214 <getuint>
			base = 16;
  8005f9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800605:	57                   	push   %edi
  800606:	ff 75 e0             	pushl  -0x20(%ebp)
  800609:	51                   	push   %ecx
  80060a:	52                   	push   %edx
  80060b:	50                   	push   %eax
  80060c:	89 da                	mov    %ebx,%edx
  80060e:	89 f0                	mov    %esi,%eax
  800610:	e8 50 fb ff ff       	call   800165 <printnum>
			break;
  800615:	83 c4 20             	add    $0x20,%esp
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061b:	e9 8e fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	51                   	push   %ecx
  800625:	ff d6                	call   *%esi
			break;
  800627:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062d:	e9 7c fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 25                	push   $0x25
  800638:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063a:	83 c4 10             	add    $0x10,%esp
  80063d:	eb 03                	jmp    800642 <vprintfmt+0x3ba>
  80063f:	83 ef 01             	sub    $0x1,%edi
  800642:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800646:	75 f7                	jne    80063f <vprintfmt+0x3b7>
  800648:	e9 61 fc ff ff       	jmp    8002ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800650:	5b                   	pop    %ebx
  800651:	5e                   	pop    %esi
  800652:	5f                   	pop    %edi
  800653:	5d                   	pop    %ebp
  800654:	c3                   	ret    

00800655 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800655:	55                   	push   %ebp
  800656:	89 e5                	mov    %esp,%ebp
  800658:	83 ec 18             	sub    $0x18,%esp
  80065b:	8b 45 08             	mov    0x8(%ebp),%eax
  80065e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800661:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800664:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800668:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800672:	85 c0                	test   %eax,%eax
  800674:	74 26                	je     80069c <vsnprintf+0x47>
  800676:	85 d2                	test   %edx,%edx
  800678:	7e 22                	jle    80069c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067a:	ff 75 14             	pushl  0x14(%ebp)
  80067d:	ff 75 10             	pushl  0x10(%ebp)
  800680:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800683:	50                   	push   %eax
  800684:	68 4e 02 80 00       	push   $0x80024e
  800689:	e8 fa fb ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80068e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800691:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	eb 05                	jmp    8006a1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a1:	c9                   	leave  
  8006a2:	c3                   	ret    

008006a3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ac:	50                   	push   %eax
  8006ad:	ff 75 10             	pushl  0x10(%ebp)
  8006b0:	ff 75 0c             	pushl  0xc(%ebp)
  8006b3:	ff 75 08             	pushl  0x8(%ebp)
  8006b6:	e8 9a ff ff ff       	call   800655 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c8:	eb 03                	jmp    8006cd <strlen+0x10>
		n++;
  8006ca:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d1:	75 f7                	jne    8006ca <strlen+0xd>
		n++;
	return n;
}
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006db:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006de:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e3:	eb 03                	jmp    8006e8 <strnlen+0x13>
		n++;
  8006e5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e8:	39 c2                	cmp    %eax,%edx
  8006ea:	74 08                	je     8006f4 <strnlen+0x1f>
  8006ec:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f0:	75 f3                	jne    8006e5 <strnlen+0x10>
  8006f2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	53                   	push   %ebx
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800700:	89 c2                	mov    %eax,%edx
  800702:	83 c2 01             	add    $0x1,%edx
  800705:	83 c1 01             	add    $0x1,%ecx
  800708:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80070f:	84 db                	test   %bl,%bl
  800711:	75 ef                	jne    800702 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800713:	5b                   	pop    %ebx
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	53                   	push   %ebx
  80071a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071d:	53                   	push   %ebx
  80071e:	e8 9a ff ff ff       	call   8006bd <strlen>
  800723:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800726:	ff 75 0c             	pushl  0xc(%ebp)
  800729:	01 d8                	add    %ebx,%eax
  80072b:	50                   	push   %eax
  80072c:	e8 c5 ff ff ff       	call   8006f6 <strcpy>
	return dst;
}
  800731:	89 d8                	mov    %ebx,%eax
  800733:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800736:	c9                   	leave  
  800737:	c3                   	ret    

00800738 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	56                   	push   %esi
  80073c:	53                   	push   %ebx
  80073d:	8b 75 08             	mov    0x8(%ebp),%esi
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800743:	89 f3                	mov    %esi,%ebx
  800745:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800748:	89 f2                	mov    %esi,%edx
  80074a:	eb 0f                	jmp    80075b <strncpy+0x23>
		*dst++ = *src;
  80074c:	83 c2 01             	add    $0x1,%edx
  80074f:	0f b6 01             	movzbl (%ecx),%eax
  800752:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800755:	80 39 01             	cmpb   $0x1,(%ecx)
  800758:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075b:	39 da                	cmp    %ebx,%edx
  80075d:	75 ed                	jne    80074c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80075f:	89 f0                	mov    %esi,%eax
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	56                   	push   %esi
  800769:	53                   	push   %ebx
  80076a:	8b 75 08             	mov    0x8(%ebp),%esi
  80076d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800770:	8b 55 10             	mov    0x10(%ebp),%edx
  800773:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800775:	85 d2                	test   %edx,%edx
  800777:	74 21                	je     80079a <strlcpy+0x35>
  800779:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077d:	89 f2                	mov    %esi,%edx
  80077f:	eb 09                	jmp    80078a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800781:	83 c2 01             	add    $0x1,%edx
  800784:	83 c1 01             	add    $0x1,%ecx
  800787:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078a:	39 c2                	cmp    %eax,%edx
  80078c:	74 09                	je     800797 <strlcpy+0x32>
  80078e:	0f b6 19             	movzbl (%ecx),%ebx
  800791:	84 db                	test   %bl,%bl
  800793:	75 ec                	jne    800781 <strlcpy+0x1c>
  800795:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800797:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079a:	29 f0                	sub    %esi,%eax
}
  80079c:	5b                   	pop    %ebx
  80079d:	5e                   	pop    %esi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a9:	eb 06                	jmp    8007b1 <strcmp+0x11>
		p++, q++;
  8007ab:	83 c1 01             	add    $0x1,%ecx
  8007ae:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b1:	0f b6 01             	movzbl (%ecx),%eax
  8007b4:	84 c0                	test   %al,%al
  8007b6:	74 04                	je     8007bc <strcmp+0x1c>
  8007b8:	3a 02                	cmp    (%edx),%al
  8007ba:	74 ef                	je     8007ab <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007bc:	0f b6 c0             	movzbl %al,%eax
  8007bf:	0f b6 12             	movzbl (%edx),%edx
  8007c2:	29 d0                	sub    %edx,%eax
}
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 c3                	mov    %eax,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d5:	eb 06                	jmp    8007dd <strncmp+0x17>
		n--, p++, q++;
  8007d7:	83 c0 01             	add    $0x1,%eax
  8007da:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007dd:	39 d8                	cmp    %ebx,%eax
  8007df:	74 15                	je     8007f6 <strncmp+0x30>
  8007e1:	0f b6 08             	movzbl (%eax),%ecx
  8007e4:	84 c9                	test   %cl,%cl
  8007e6:	74 04                	je     8007ec <strncmp+0x26>
  8007e8:	3a 0a                	cmp    (%edx),%cl
  8007ea:	74 eb                	je     8007d7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ec:	0f b6 00             	movzbl (%eax),%eax
  8007ef:	0f b6 12             	movzbl (%edx),%edx
  8007f2:	29 d0                	sub    %edx,%eax
  8007f4:	eb 05                	jmp    8007fb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fb:	5b                   	pop    %ebx
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800808:	eb 07                	jmp    800811 <strchr+0x13>
		if (*s == c)
  80080a:	38 ca                	cmp    %cl,%dl
  80080c:	74 0f                	je     80081d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80080e:	83 c0 01             	add    $0x1,%eax
  800811:	0f b6 10             	movzbl (%eax),%edx
  800814:	84 d2                	test   %dl,%dl
  800816:	75 f2                	jne    80080a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800829:	eb 03                	jmp    80082e <strfind+0xf>
  80082b:	83 c0 01             	add    $0x1,%eax
  80082e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800831:	38 ca                	cmp    %cl,%dl
  800833:	74 04                	je     800839 <strfind+0x1a>
  800835:	84 d2                	test   %dl,%dl
  800837:	75 f2                	jne    80082b <strfind+0xc>
			break;
	return (char *) s;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	57                   	push   %edi
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 7d 08             	mov    0x8(%ebp),%edi
  800844:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800847:	85 c9                	test   %ecx,%ecx
  800849:	74 36                	je     800881 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800851:	75 28                	jne    80087b <memset+0x40>
  800853:	f6 c1 03             	test   $0x3,%cl
  800856:	75 23                	jne    80087b <memset+0x40>
		c &= 0xFF;
  800858:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085c:	89 d3                	mov    %edx,%ebx
  80085e:	c1 e3 08             	shl    $0x8,%ebx
  800861:	89 d6                	mov    %edx,%esi
  800863:	c1 e6 18             	shl    $0x18,%esi
  800866:	89 d0                	mov    %edx,%eax
  800868:	c1 e0 10             	shl    $0x10,%eax
  80086b:	09 f0                	or     %esi,%eax
  80086d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	09 d0                	or     %edx,%eax
  800873:	c1 e9 02             	shr    $0x2,%ecx
  800876:	fc                   	cld    
  800877:	f3 ab                	rep stos %eax,%es:(%edi)
  800879:	eb 06                	jmp    800881 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087e:	fc                   	cld    
  80087f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800881:	89 f8                	mov    %edi,%eax
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	57                   	push   %edi
  80088c:	56                   	push   %esi
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 75 0c             	mov    0xc(%ebp),%esi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800896:	39 c6                	cmp    %eax,%esi
  800898:	73 35                	jae    8008cf <memmove+0x47>
  80089a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089d:	39 d0                	cmp    %edx,%eax
  80089f:	73 2e                	jae    8008cf <memmove+0x47>
		s += n;
		d += n;
  8008a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a4:	89 d6                	mov    %edx,%esi
  8008a6:	09 fe                	or     %edi,%esi
  8008a8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ae:	75 13                	jne    8008c3 <memmove+0x3b>
  8008b0:	f6 c1 03             	test   $0x3,%cl
  8008b3:	75 0e                	jne    8008c3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b5:	83 ef 04             	sub    $0x4,%edi
  8008b8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bb:	c1 e9 02             	shr    $0x2,%ecx
  8008be:	fd                   	std    
  8008bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c1:	eb 09                	jmp    8008cc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c3:	83 ef 01             	sub    $0x1,%edi
  8008c6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c9:	fd                   	std    
  8008ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008cc:	fc                   	cld    
  8008cd:	eb 1d                	jmp    8008ec <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cf:	89 f2                	mov    %esi,%edx
  8008d1:	09 c2                	or     %eax,%edx
  8008d3:	f6 c2 03             	test   $0x3,%dl
  8008d6:	75 0f                	jne    8008e7 <memmove+0x5f>
  8008d8:	f6 c1 03             	test   $0x3,%cl
  8008db:	75 0a                	jne    8008e7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
  8008e0:	89 c7                	mov    %eax,%edi
  8008e2:	fc                   	cld    
  8008e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e5:	eb 05                	jmp    8008ec <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e7:	89 c7                	mov    %eax,%edi
  8008e9:	fc                   	cld    
  8008ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f3:	ff 75 10             	pushl  0x10(%ebp)
  8008f6:	ff 75 0c             	pushl  0xc(%ebp)
  8008f9:	ff 75 08             	pushl  0x8(%ebp)
  8008fc:	e8 87 ff ff ff       	call   800888 <memmove>
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 c6                	mov    %eax,%esi
  800910:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800913:	eb 1a                	jmp    80092f <memcmp+0x2c>
		if (*s1 != *s2)
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	0f b6 1a             	movzbl (%edx),%ebx
  80091b:	38 d9                	cmp    %bl,%cl
  80091d:	74 0a                	je     800929 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80091f:	0f b6 c1             	movzbl %cl,%eax
  800922:	0f b6 db             	movzbl %bl,%ebx
  800925:	29 d8                	sub    %ebx,%eax
  800927:	eb 0f                	jmp    800938 <memcmp+0x35>
		s1++, s2++;
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092f:	39 f0                	cmp    %esi,%eax
  800931:	75 e2                	jne    800915 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	5b                   	pop    %ebx
  800939:	5e                   	pop    %esi
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800943:	89 c1                	mov    %eax,%ecx
  800945:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800948:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094c:	eb 0a                	jmp    800958 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80094e:	0f b6 10             	movzbl (%eax),%edx
  800951:	39 da                	cmp    %ebx,%edx
  800953:	74 07                	je     80095c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	39 c8                	cmp    %ecx,%eax
  80095a:	72 f2                	jb     80094e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095c:	5b                   	pop    %ebx
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	57                   	push   %edi
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800968:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096b:	eb 03                	jmp    800970 <strtol+0x11>
		s++;
  80096d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800970:	0f b6 01             	movzbl (%ecx),%eax
  800973:	3c 20                	cmp    $0x20,%al
  800975:	74 f6                	je     80096d <strtol+0xe>
  800977:	3c 09                	cmp    $0x9,%al
  800979:	74 f2                	je     80096d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097b:	3c 2b                	cmp    $0x2b,%al
  80097d:	75 0a                	jne    800989 <strtol+0x2a>
		s++;
  80097f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800982:	bf 00 00 00 00       	mov    $0x0,%edi
  800987:	eb 11                	jmp    80099a <strtol+0x3b>
  800989:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80098e:	3c 2d                	cmp    $0x2d,%al
  800990:	75 08                	jne    80099a <strtol+0x3b>
		s++, neg = 1;
  800992:	83 c1 01             	add    $0x1,%ecx
  800995:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a0:	75 15                	jne    8009b7 <strtol+0x58>
  8009a2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a5:	75 10                	jne    8009b7 <strtol+0x58>
  8009a7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ab:	75 7c                	jne    800a29 <strtol+0xca>
		s += 2, base = 16;
  8009ad:	83 c1 02             	add    $0x2,%ecx
  8009b0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b5:	eb 16                	jmp    8009cd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b7:	85 db                	test   %ebx,%ebx
  8009b9:	75 12                	jne    8009cd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c3:	75 08                	jne    8009cd <strtol+0x6e>
		s++, base = 8;
  8009c5:	83 c1 01             	add    $0x1,%ecx
  8009c8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d5:	0f b6 11             	movzbl (%ecx),%edx
  8009d8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009db:	89 f3                	mov    %esi,%ebx
  8009dd:	80 fb 09             	cmp    $0x9,%bl
  8009e0:	77 08                	ja     8009ea <strtol+0x8b>
			dig = *s - '0';
  8009e2:	0f be d2             	movsbl %dl,%edx
  8009e5:	83 ea 30             	sub    $0x30,%edx
  8009e8:	eb 22                	jmp    800a0c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ea:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	80 fb 19             	cmp    $0x19,%bl
  8009f2:	77 08                	ja     8009fc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f4:	0f be d2             	movsbl %dl,%edx
  8009f7:	83 ea 57             	sub    $0x57,%edx
  8009fa:	eb 10                	jmp    800a0c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 16                	ja     800a1c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a0f:	7d 0b                	jge    800a1c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a18:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1a:	eb b9                	jmp    8009d5 <strtol+0x76>

	if (endptr)
  800a1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a20:	74 0d                	je     800a2f <strtol+0xd0>
		*endptr = (char *) s;
  800a22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a25:	89 0e                	mov    %ecx,(%esi)
  800a27:	eb 06                	jmp    800a2f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	74 98                	je     8009c5 <strtol+0x66>
  800a2d:	eb 9e                	jmp    8009cd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	f7 da                	neg    %edx
  800a33:	85 ff                	test   %edi,%edi
  800a35:	0f 45 c2             	cmovne %edx,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	5e                   	pop    %esi
  800a3a:	5f                   	pop    %edi
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
  800a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4e:	89 c3                	mov    %eax,%ebx
  800a50:	89 c7                	mov    %eax,%edi
  800a52:	89 c6                	mov    %eax,%esi
  800a54:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a61:	ba 00 00 00 00       	mov    $0x0,%edx
  800a66:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6b:	89 d1                	mov    %edx,%ecx
  800a6d:	89 d3                	mov    %edx,%ebx
  800a6f:	89 d7                	mov    %edx,%edi
  800a71:	89 d6                	mov    %edx,%esi
  800a73:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a88:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a90:	89 cb                	mov    %ecx,%ebx
  800a92:	89 cf                	mov    %ecx,%edi
  800a94:	89 ce                	mov    %ecx,%esi
  800a96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	7e 17                	jle    800ab3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	50                   	push   %eax
  800aa0:	6a 03                	push   $0x3
  800aa2:	68 bf 25 80 00       	push   $0x8025bf
  800aa7:	6a 23                	push   $0x23
  800aa9:	68 dc 25 80 00       	push   $0x8025dc
  800aae:	e8 b3 13 00 00       	call   801e66 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac6:	b8 02 00 00 00       	mov    $0x2,%eax
  800acb:	89 d1                	mov    %edx,%ecx
  800acd:	89 d3                	mov    %edx,%ebx
  800acf:	89 d7                	mov    %edx,%edi
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_yield>:

void
sys_yield(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	be 00 00 00 00       	mov    $0x0,%esi
  800b07:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b15:	89 f7                	mov    %esi,%edi
  800b17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 17                	jle    800b34 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	50                   	push   %eax
  800b21:	6a 04                	push   $0x4
  800b23:	68 bf 25 80 00       	push   $0x8025bf
  800b28:	6a 23                	push   $0x23
  800b2a:	68 dc 25 80 00       	push   $0x8025dc
  800b2f:	e8 32 13 00 00       	call   801e66 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b56:	8b 75 18             	mov    0x18(%ebp),%esi
  800b59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5b:	85 c0                	test   %eax,%eax
  800b5d:	7e 17                	jle    800b76 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	50                   	push   %eax
  800b63:	6a 05                	push   $0x5
  800b65:	68 bf 25 80 00       	push   $0x8025bf
  800b6a:	6a 23                	push   $0x23
  800b6c:	68 dc 25 80 00       	push   $0x8025dc
  800b71:	e8 f0 12 00 00       	call   801e66 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	89 df                	mov    %ebx,%edi
  800b99:	89 de                	mov    %ebx,%esi
  800b9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 06                	push   $0x6
  800ba7:	68 bf 25 80 00       	push   $0x8025bf
  800bac:	6a 23                	push   $0x23
  800bae:	68 dc 25 80 00       	push   $0x8025dc
  800bb3:	e8 ae 12 00 00       	call   801e66 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bce:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd9:	89 df                	mov    %ebx,%edi
  800bdb:	89 de                	mov    %ebx,%esi
  800bdd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 17                	jle    800bfa <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	50                   	push   %eax
  800be7:	6a 08                	push   $0x8
  800be9:	68 bf 25 80 00       	push   $0x8025bf
  800bee:	6a 23                	push   $0x23
  800bf0:	68 dc 25 80 00       	push   $0x8025dc
  800bf5:	e8 6c 12 00 00       	call   801e66 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c10:	b8 09 00 00 00       	mov    $0x9,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	89 df                	mov    %ebx,%edi
  800c1d:	89 de                	mov    %ebx,%esi
  800c1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 09                	push   $0x9
  800c2b:	68 bf 25 80 00       	push   $0x8025bf
  800c30:	6a 23                	push   $0x23
  800c32:	68 dc 25 80 00       	push   $0x8025dc
  800c37:	e8 2a 12 00 00       	call   801e66 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 df                	mov    %ebx,%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 0a                	push   $0xa
  800c6d:	68 bf 25 80 00       	push   $0x8025bf
  800c72:	6a 23                	push   $0x23
  800c74:	68 dc 25 80 00       	push   $0x8025dc
  800c79:	e8 e8 11 00 00       	call   801e66 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	be 00 00 00 00       	mov    $0x0,%esi
  800c91:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800cb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 cb                	mov    %ecx,%ebx
  800cc1:	89 cf                	mov    %ecx,%edi
  800cc3:	89 ce                	mov    %ecx,%esi
  800cc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 17                	jle    800ce2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	83 ec 0c             	sub    $0xc,%esp
  800cce:	50                   	push   %eax
  800ccf:	6a 0d                	push   $0xd
  800cd1:	68 bf 25 80 00       	push   $0x8025bf
  800cd6:	6a 23                	push   $0x23
  800cd8:	68 dc 25 80 00       	push   $0x8025dc
  800cdd:	e8 84 11 00 00       	call   801e66 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d14:	c1 e8 0c             	shr    $0xc,%eax
}
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d29:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d36:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	c1 ea 16             	shr    $0x16,%edx
  800d40:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d47:	f6 c2 01             	test   $0x1,%dl
  800d4a:	74 11                	je     800d5d <fd_alloc+0x2d>
  800d4c:	89 c2                	mov    %eax,%edx
  800d4e:	c1 ea 0c             	shr    $0xc,%edx
  800d51:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d58:	f6 c2 01             	test   $0x1,%dl
  800d5b:	75 09                	jne    800d66 <fd_alloc+0x36>
			*fd_store = fd;
  800d5d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d64:	eb 17                	jmp    800d7d <fd_alloc+0x4d>
  800d66:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d6b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d70:	75 c9                	jne    800d3b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d72:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d78:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d85:	83 f8 1f             	cmp    $0x1f,%eax
  800d88:	77 36                	ja     800dc0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d8a:	c1 e0 0c             	shl    $0xc,%eax
  800d8d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d92:	89 c2                	mov    %eax,%edx
  800d94:	c1 ea 16             	shr    $0x16,%edx
  800d97:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d9e:	f6 c2 01             	test   $0x1,%dl
  800da1:	74 24                	je     800dc7 <fd_lookup+0x48>
  800da3:	89 c2                	mov    %eax,%edx
  800da5:	c1 ea 0c             	shr    $0xc,%edx
  800da8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800daf:	f6 c2 01             	test   $0x1,%dl
  800db2:	74 1a                	je     800dce <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800db4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db7:	89 02                	mov    %eax,(%edx)
	return 0;
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	eb 13                	jmp    800dd3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc5:	eb 0c                	jmp    800dd3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dcc:	eb 05                	jmp    800dd3 <fd_lookup+0x54>
  800dce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dde:	ba 68 26 80 00       	mov    $0x802668,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800de3:	eb 13                	jmp    800df8 <dev_lookup+0x23>
  800de5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800de8:	39 08                	cmp    %ecx,(%eax)
  800dea:	75 0c                	jne    800df8 <dev_lookup+0x23>
			*dev = devtab[i];
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	89 01                	mov    %eax,(%ecx)
			return 0;
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
  800df6:	eb 2e                	jmp    800e26 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800df8:	8b 02                	mov    (%edx),%eax
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	75 e7                	jne    800de5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dfe:	a1 08 40 80 00       	mov    0x804008,%eax
  800e03:	8b 40 48             	mov    0x48(%eax),%eax
  800e06:	83 ec 04             	sub    $0x4,%esp
  800e09:	51                   	push   %ecx
  800e0a:	50                   	push   %eax
  800e0b:	68 ec 25 80 00       	push   $0x8025ec
  800e10:	e8 3c f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    

00800e28 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 10             	sub    $0x10,%esp
  800e30:	8b 75 08             	mov    0x8(%ebp),%esi
  800e33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e39:	50                   	push   %eax
  800e3a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e40:	c1 e8 0c             	shr    $0xc,%eax
  800e43:	50                   	push   %eax
  800e44:	e8 36 ff ff ff       	call   800d7f <fd_lookup>
  800e49:	83 c4 08             	add    $0x8,%esp
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 05                	js     800e55 <fd_close+0x2d>
	    || fd != fd2)
  800e50:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e53:	74 0c                	je     800e61 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e55:	84 db                	test   %bl,%bl
  800e57:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5c:	0f 44 c2             	cmove  %edx,%eax
  800e5f:	eb 41                	jmp    800ea2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e67:	50                   	push   %eax
  800e68:	ff 36                	pushl  (%esi)
  800e6a:	e8 66 ff ff ff       	call   800dd5 <dev_lookup>
  800e6f:	89 c3                	mov    %eax,%ebx
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 1a                	js     800e92 <fd_close+0x6a>
		if (dev->dev_close)
  800e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e7e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e83:	85 c0                	test   %eax,%eax
  800e85:	74 0b                	je     800e92 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	56                   	push   %esi
  800e8b:	ff d0                	call   *%eax
  800e8d:	89 c3                	mov    %eax,%ebx
  800e8f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	56                   	push   %esi
  800e96:	6a 00                	push   $0x0
  800e98:	e8 e1 fc ff ff       	call   800b7e <sys_page_unmap>
	return r;
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	89 d8                	mov    %ebx,%eax
}
  800ea2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb2:	50                   	push   %eax
  800eb3:	ff 75 08             	pushl  0x8(%ebp)
  800eb6:	e8 c4 fe ff ff       	call   800d7f <fd_lookup>
  800ebb:	83 c4 08             	add    $0x8,%esp
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	78 10                	js     800ed2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	6a 01                	push   $0x1
  800ec7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eca:	e8 59 ff ff ff       	call   800e28 <fd_close>
  800ecf:	83 c4 10             	add    $0x10,%esp
}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <close_all>:

void
close_all(void)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800edb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	53                   	push   %ebx
  800ee4:	e8 c0 ff ff ff       	call   800ea9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee9:	83 c3 01             	add    $0x1,%ebx
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	83 fb 20             	cmp    $0x20,%ebx
  800ef2:	75 ec                	jne    800ee0 <close_all+0xc>
		close(i);
}
  800ef4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	83 ec 2c             	sub    $0x2c,%esp
  800f02:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f08:	50                   	push   %eax
  800f09:	ff 75 08             	pushl  0x8(%ebp)
  800f0c:	e8 6e fe ff ff       	call   800d7f <fd_lookup>
  800f11:	83 c4 08             	add    $0x8,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	0f 88 c1 00 00 00    	js     800fdd <dup+0xe4>
		return r;
	close(newfdnum);
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	56                   	push   %esi
  800f20:	e8 84 ff ff ff       	call   800ea9 <close>

	newfd = INDEX2FD(newfdnum);
  800f25:	89 f3                	mov    %esi,%ebx
  800f27:	c1 e3 0c             	shl    $0xc,%ebx
  800f2a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f30:	83 c4 04             	add    $0x4,%esp
  800f33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f36:	e8 de fd ff ff       	call   800d19 <fd2data>
  800f3b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f3d:	89 1c 24             	mov    %ebx,(%esp)
  800f40:	e8 d4 fd ff ff       	call   800d19 <fd2data>
  800f45:	83 c4 10             	add    $0x10,%esp
  800f48:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f4b:	89 f8                	mov    %edi,%eax
  800f4d:	c1 e8 16             	shr    $0x16,%eax
  800f50:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f57:	a8 01                	test   $0x1,%al
  800f59:	74 37                	je     800f92 <dup+0x99>
  800f5b:	89 f8                	mov    %edi,%eax
  800f5d:	c1 e8 0c             	shr    $0xc,%eax
  800f60:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f67:	f6 c2 01             	test   $0x1,%dl
  800f6a:	74 26                	je     800f92 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f6c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f73:	83 ec 0c             	sub    $0xc,%esp
  800f76:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7b:	50                   	push   %eax
  800f7c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f7f:	6a 00                	push   $0x0
  800f81:	57                   	push   %edi
  800f82:	6a 00                	push   $0x0
  800f84:	e8 b3 fb ff ff       	call   800b3c <sys_page_map>
  800f89:	89 c7                	mov    %eax,%edi
  800f8b:	83 c4 20             	add    $0x20,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 2e                	js     800fc0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f95:	89 d0                	mov    %edx,%eax
  800f97:	c1 e8 0c             	shr    $0xc,%eax
  800f9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa9:	50                   	push   %eax
  800faa:	53                   	push   %ebx
  800fab:	6a 00                	push   $0x0
  800fad:	52                   	push   %edx
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 87 fb ff ff       	call   800b3c <sys_page_map>
  800fb5:	89 c7                	mov    %eax,%edi
  800fb7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fba:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fbc:	85 ff                	test   %edi,%edi
  800fbe:	79 1d                	jns    800fdd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	53                   	push   %ebx
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 b3 fb ff ff       	call   800b7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fcb:	83 c4 08             	add    $0x8,%esp
  800fce:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 a6 fb ff ff       	call   800b7e <sys_page_unmap>
	return r;
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	89 f8                	mov    %edi,%eax
}
  800fdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 14             	sub    $0x14,%esp
  800fec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff2:	50                   	push   %eax
  800ff3:	53                   	push   %ebx
  800ff4:	e8 86 fd ff ff       	call   800d7f <fd_lookup>
  800ff9:	83 c4 08             	add    $0x8,%esp
  800ffc:	89 c2                	mov    %eax,%edx
  800ffe:	85 c0                	test   %eax,%eax
  801000:	78 6d                	js     80106f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801002:	83 ec 08             	sub    $0x8,%esp
  801005:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801008:	50                   	push   %eax
  801009:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80100c:	ff 30                	pushl  (%eax)
  80100e:	e8 c2 fd ff ff       	call   800dd5 <dev_lookup>
  801013:	83 c4 10             	add    $0x10,%esp
  801016:	85 c0                	test   %eax,%eax
  801018:	78 4c                	js     801066 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80101a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101d:	8b 42 08             	mov    0x8(%edx),%eax
  801020:	83 e0 03             	and    $0x3,%eax
  801023:	83 f8 01             	cmp    $0x1,%eax
  801026:	75 21                	jne    801049 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801028:	a1 08 40 80 00       	mov    0x804008,%eax
  80102d:	8b 40 48             	mov    0x48(%eax),%eax
  801030:	83 ec 04             	sub    $0x4,%esp
  801033:	53                   	push   %ebx
  801034:	50                   	push   %eax
  801035:	68 2d 26 80 00       	push   $0x80262d
  80103a:	e8 12 f1 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80103f:	83 c4 10             	add    $0x10,%esp
  801042:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801047:	eb 26                	jmp    80106f <read+0x8a>
	}
	if (!dev->dev_read)
  801049:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104c:	8b 40 08             	mov    0x8(%eax),%eax
  80104f:	85 c0                	test   %eax,%eax
  801051:	74 17                	je     80106a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	ff 75 10             	pushl  0x10(%ebp)
  801059:	ff 75 0c             	pushl  0xc(%ebp)
  80105c:	52                   	push   %edx
  80105d:	ff d0                	call   *%eax
  80105f:	89 c2                	mov    %eax,%edx
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	eb 09                	jmp    80106f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801066:	89 c2                	mov    %eax,%edx
  801068:	eb 05                	jmp    80106f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80106a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80106f:	89 d0                	mov    %edx,%eax
  801071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801082:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801085:	bb 00 00 00 00       	mov    $0x0,%ebx
  80108a:	eb 21                	jmp    8010ad <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80108c:	83 ec 04             	sub    $0x4,%esp
  80108f:	89 f0                	mov    %esi,%eax
  801091:	29 d8                	sub    %ebx,%eax
  801093:	50                   	push   %eax
  801094:	89 d8                	mov    %ebx,%eax
  801096:	03 45 0c             	add    0xc(%ebp),%eax
  801099:	50                   	push   %eax
  80109a:	57                   	push   %edi
  80109b:	e8 45 ff ff ff       	call   800fe5 <read>
		if (m < 0)
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	78 10                	js     8010b7 <readn+0x41>
			return m;
		if (m == 0)
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	74 0a                	je     8010b5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ab:	01 c3                	add    %eax,%ebx
  8010ad:	39 f3                	cmp    %esi,%ebx
  8010af:	72 db                	jb     80108c <readn+0x16>
  8010b1:	89 d8                	mov    %ebx,%eax
  8010b3:	eb 02                	jmp    8010b7 <readn+0x41>
  8010b5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 14             	sub    $0x14,%esp
  8010c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cc:	50                   	push   %eax
  8010cd:	53                   	push   %ebx
  8010ce:	e8 ac fc ff ff       	call   800d7f <fd_lookup>
  8010d3:	83 c4 08             	add    $0x8,%esp
  8010d6:	89 c2                	mov    %eax,%edx
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 68                	js     801144 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010dc:	83 ec 08             	sub    $0x8,%esp
  8010df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e2:	50                   	push   %eax
  8010e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e6:	ff 30                	pushl  (%eax)
  8010e8:	e8 e8 fc ff ff       	call   800dd5 <dev_lookup>
  8010ed:	83 c4 10             	add    $0x10,%esp
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	78 47                	js     80113b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010fb:	75 21                	jne    80111e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fd:	a1 08 40 80 00       	mov    0x804008,%eax
  801102:	8b 40 48             	mov    0x48(%eax),%eax
  801105:	83 ec 04             	sub    $0x4,%esp
  801108:	53                   	push   %ebx
  801109:	50                   	push   %eax
  80110a:	68 49 26 80 00       	push   $0x802649
  80110f:	e8 3d f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80111c:	eb 26                	jmp    801144 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80111e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801121:	8b 52 0c             	mov    0xc(%edx),%edx
  801124:	85 d2                	test   %edx,%edx
  801126:	74 17                	je     80113f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801128:	83 ec 04             	sub    $0x4,%esp
  80112b:	ff 75 10             	pushl  0x10(%ebp)
  80112e:	ff 75 0c             	pushl  0xc(%ebp)
  801131:	50                   	push   %eax
  801132:	ff d2                	call   *%edx
  801134:	89 c2                	mov    %eax,%edx
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	eb 09                	jmp    801144 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	eb 05                	jmp    801144 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80113f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801144:	89 d0                	mov    %edx,%eax
  801146:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801149:	c9                   	leave  
  80114a:	c3                   	ret    

0080114b <seek>:

int
seek(int fdnum, off_t offset)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801151:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801154:	50                   	push   %eax
  801155:	ff 75 08             	pushl  0x8(%ebp)
  801158:	e8 22 fc ff ff       	call   800d7f <fd_lookup>
  80115d:	83 c4 08             	add    $0x8,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	78 0e                	js     801172 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801164:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80116d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	53                   	push   %ebx
  801178:	83 ec 14             	sub    $0x14,%esp
  80117b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80117e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	53                   	push   %ebx
  801183:	e8 f7 fb ff ff       	call   800d7f <fd_lookup>
  801188:	83 c4 08             	add    $0x8,%esp
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 65                	js     8011f6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801197:	50                   	push   %eax
  801198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119b:	ff 30                	pushl  (%eax)
  80119d:	e8 33 fc ff ff       	call   800dd5 <dev_lookup>
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 44                	js     8011ed <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ac:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b0:	75 21                	jne    8011d3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011b2:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	53                   	push   %ebx
  8011be:	50                   	push   %eax
  8011bf:	68 0c 26 80 00       	push   $0x80260c
  8011c4:	e8 88 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d1:	eb 23                	jmp    8011f6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d6:	8b 52 18             	mov    0x18(%edx),%edx
  8011d9:	85 d2                	test   %edx,%edx
  8011db:	74 14                	je     8011f1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	ff 75 0c             	pushl  0xc(%ebp)
  8011e3:	50                   	push   %eax
  8011e4:	ff d2                	call   *%edx
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	eb 09                	jmp    8011f6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	eb 05                	jmp    8011f6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011f6:	89 d0                	mov    %edx,%eax
  8011f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fb:	c9                   	leave  
  8011fc:	c3                   	ret    

008011fd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011fd:	55                   	push   %ebp
  8011fe:	89 e5                	mov    %esp,%ebp
  801200:	53                   	push   %ebx
  801201:	83 ec 14             	sub    $0x14,%esp
  801204:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801207:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	ff 75 08             	pushl  0x8(%ebp)
  80120e:	e8 6c fb ff ff       	call   800d7f <fd_lookup>
  801213:	83 c4 08             	add    $0x8,%esp
  801216:	89 c2                	mov    %eax,%edx
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 58                	js     801274 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121c:	83 ec 08             	sub    $0x8,%esp
  80121f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801226:	ff 30                	pushl  (%eax)
  801228:	e8 a8 fb ff ff       	call   800dd5 <dev_lookup>
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	78 37                	js     80126b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801234:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801237:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80123b:	74 32                	je     80126f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80123d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801240:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801247:	00 00 00 
	stat->st_isdir = 0;
  80124a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801251:	00 00 00 
	stat->st_dev = dev;
  801254:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	53                   	push   %ebx
  80125e:	ff 75 f0             	pushl  -0x10(%ebp)
  801261:	ff 50 14             	call   *0x14(%eax)
  801264:	89 c2                	mov    %eax,%edx
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	eb 09                	jmp    801274 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	eb 05                	jmp    801274 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80126f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801274:	89 d0                	mov    %edx,%eax
  801276:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	6a 00                	push   $0x0
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	e8 ef 01 00 00       	call   80147c <open>
  80128d:	89 c3                	mov    %eax,%ebx
  80128f:	83 c4 10             	add    $0x10,%esp
  801292:	85 c0                	test   %eax,%eax
  801294:	78 1b                	js     8012b1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	ff 75 0c             	pushl  0xc(%ebp)
  80129c:	50                   	push   %eax
  80129d:	e8 5b ff ff ff       	call   8011fd <fstat>
  8012a2:	89 c6                	mov    %eax,%esi
	close(fd);
  8012a4:	89 1c 24             	mov    %ebx,(%esp)
  8012a7:	e8 fd fb ff ff       	call   800ea9 <close>
	return r;
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	89 f0                	mov    %esi,%eax
}
  8012b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	56                   	push   %esi
  8012bc:	53                   	push   %ebx
  8012bd:	89 c6                	mov    %eax,%esi
  8012bf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012c1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012c8:	75 12                	jne    8012dc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	6a 01                	push   $0x1
  8012cf:	e8 9d 0c 00 00       	call   801f71 <ipc_find_env>
  8012d4:	a3 00 40 80 00       	mov    %eax,0x804000
  8012d9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012dc:	6a 07                	push   $0x7
  8012de:	68 00 50 80 00       	push   $0x805000
  8012e3:	56                   	push   %esi
  8012e4:	ff 35 00 40 80 00    	pushl  0x804000
  8012ea:	e8 33 0c 00 00       	call   801f22 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012ef:	83 c4 0c             	add    $0xc,%esp
  8012f2:	6a 00                	push   $0x0
  8012f4:	53                   	push   %ebx
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 b0 0b 00 00       	call   801eac <ipc_recv>
}
  8012fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801309:	8b 45 08             	mov    0x8(%ebp),%eax
  80130c:	8b 40 0c             	mov    0xc(%eax),%eax
  80130f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801314:	8b 45 0c             	mov    0xc(%ebp),%eax
  801317:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80131c:	ba 00 00 00 00       	mov    $0x0,%edx
  801321:	b8 02 00 00 00       	mov    $0x2,%eax
  801326:	e8 8d ff ff ff       	call   8012b8 <fsipc>
}
  80132b:	c9                   	leave  
  80132c:	c3                   	ret    

0080132d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
  801336:	8b 40 0c             	mov    0xc(%eax),%eax
  801339:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80133e:	ba 00 00 00 00       	mov    $0x0,%edx
  801343:	b8 06 00 00 00       	mov    $0x6,%eax
  801348:	e8 6b ff ff ff       	call   8012b8 <fsipc>
}
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	53                   	push   %ebx
  801353:	83 ec 04             	sub    $0x4,%esp
  801356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801359:	8b 45 08             	mov    0x8(%ebp),%eax
  80135c:	8b 40 0c             	mov    0xc(%eax),%eax
  80135f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801364:	ba 00 00 00 00       	mov    $0x0,%edx
  801369:	b8 05 00 00 00       	mov    $0x5,%eax
  80136e:	e8 45 ff ff ff       	call   8012b8 <fsipc>
  801373:	85 c0                	test   %eax,%eax
  801375:	78 2c                	js     8013a3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	68 00 50 80 00       	push   $0x805000
  80137f:	53                   	push   %ebx
  801380:	e8 71 f3 ff ff       	call   8006f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801385:	a1 80 50 80 00       	mov    0x805080,%eax
  80138a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801390:	a1 84 50 80 00       	mov    0x805084,%eax
  801395:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013b8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013be:	a3 04 50 80 00       	mov    %eax,0x805004
  8013c3:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8013c8:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8013cd:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013d0:	53                   	push   %ebx
  8013d1:	ff 75 0c             	pushl  0xc(%ebp)
  8013d4:	68 08 50 80 00       	push   $0x805008
  8013d9:	e8 aa f4 ff ff       	call   800888 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8013de:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e3:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e8:	e8 cb fe ff ff       	call   8012b8 <fsipc>
  8013ed:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8013f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801402:	8b 45 08             	mov    0x8(%ebp),%eax
  801405:	8b 40 0c             	mov    0xc(%eax),%eax
  801408:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80140d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801413:	ba 00 00 00 00       	mov    $0x0,%edx
  801418:	b8 03 00 00 00       	mov    $0x3,%eax
  80141d:	e8 96 fe ff ff       	call   8012b8 <fsipc>
  801422:	89 c3                	mov    %eax,%ebx
  801424:	85 c0                	test   %eax,%eax
  801426:	78 4b                	js     801473 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801428:	39 c6                	cmp    %eax,%esi
  80142a:	73 16                	jae    801442 <devfile_read+0x48>
  80142c:	68 7c 26 80 00       	push   $0x80267c
  801431:	68 83 26 80 00       	push   $0x802683
  801436:	6a 7c                	push   $0x7c
  801438:	68 98 26 80 00       	push   $0x802698
  80143d:	e8 24 0a 00 00       	call   801e66 <_panic>
	assert(r <= PGSIZE);
  801442:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801447:	7e 16                	jle    80145f <devfile_read+0x65>
  801449:	68 a3 26 80 00       	push   $0x8026a3
  80144e:	68 83 26 80 00       	push   $0x802683
  801453:	6a 7d                	push   $0x7d
  801455:	68 98 26 80 00       	push   $0x802698
  80145a:	e8 07 0a 00 00       	call   801e66 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80145f:	83 ec 04             	sub    $0x4,%esp
  801462:	50                   	push   %eax
  801463:	68 00 50 80 00       	push   $0x805000
  801468:	ff 75 0c             	pushl  0xc(%ebp)
  80146b:	e8 18 f4 ff ff       	call   800888 <memmove>
	return r;
  801470:	83 c4 10             	add    $0x10,%esp
}
  801473:	89 d8                	mov    %ebx,%eax
  801475:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	53                   	push   %ebx
  801480:	83 ec 20             	sub    $0x20,%esp
  801483:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801486:	53                   	push   %ebx
  801487:	e8 31 f2 ff ff       	call   8006bd <strlen>
  80148c:	83 c4 10             	add    $0x10,%esp
  80148f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801494:	7f 67                	jg     8014fd <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	e8 8e f8 ff ff       	call   800d30 <fd_alloc>
  8014a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 57                	js     801502 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ab:	83 ec 08             	sub    $0x8,%esp
  8014ae:	53                   	push   %ebx
  8014af:	68 00 50 80 00       	push   $0x805000
  8014b4:	e8 3d f2 ff ff       	call   8006f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014bc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014c9:	e8 ea fd ff ff       	call   8012b8 <fsipc>
  8014ce:	89 c3                	mov    %eax,%ebx
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	85 c0                	test   %eax,%eax
  8014d5:	79 14                	jns    8014eb <open+0x6f>
		fd_close(fd, 0);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	6a 00                	push   $0x0
  8014dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014df:	e8 44 f9 ff ff       	call   800e28 <fd_close>
		return r;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	89 da                	mov    %ebx,%edx
  8014e9:	eb 17                	jmp    801502 <open+0x86>
	}

	return fd2num(fd);
  8014eb:	83 ec 0c             	sub    $0xc,%esp
  8014ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f1:	e8 13 f8 ff ff       	call   800d09 <fd2num>
  8014f6:	89 c2                	mov    %eax,%edx
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	eb 05                	jmp    801502 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014fd:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801502:	89 d0                	mov    %edx,%eax
  801504:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801507:	c9                   	leave  
  801508:	c3                   	ret    

00801509 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 08 00 00 00       	mov    $0x8,%eax
  801519:	e8 9a fd ff ff       	call   8012b8 <fsipc>
}
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    

00801520 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	56                   	push   %esi
  801524:	53                   	push   %ebx
  801525:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	ff 75 08             	pushl  0x8(%ebp)
  80152e:	e8 e6 f7 ff ff       	call   800d19 <fd2data>
  801533:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801535:	83 c4 08             	add    $0x8,%esp
  801538:	68 af 26 80 00       	push   $0x8026af
  80153d:	53                   	push   %ebx
  80153e:	e8 b3 f1 ff ff       	call   8006f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801543:	8b 46 04             	mov    0x4(%esi),%eax
  801546:	2b 06                	sub    (%esi),%eax
  801548:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80154e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801555:	00 00 00 
	stat->st_dev = &devpipe;
  801558:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80155f:	30 80 00 
	return 0;
}
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
  801567:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5d                   	pop    %ebp
  80156d:	c3                   	ret    

0080156e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	53                   	push   %ebx
  801572:	83 ec 0c             	sub    $0xc,%esp
  801575:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801578:	53                   	push   %ebx
  801579:	6a 00                	push   $0x0
  80157b:	e8 fe f5 ff ff       	call   800b7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801580:	89 1c 24             	mov    %ebx,(%esp)
  801583:	e8 91 f7 ff ff       	call   800d19 <fd2data>
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	50                   	push   %eax
  80158c:	6a 00                	push   $0x0
  80158e:	e8 eb f5 ff ff       	call   800b7e <sys_page_unmap>
}
  801593:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	57                   	push   %edi
  80159c:	56                   	push   %esi
  80159d:	53                   	push   %ebx
  80159e:	83 ec 1c             	sub    $0x1c,%esp
  8015a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015a4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8015ab:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b4:	e8 f1 09 00 00       	call   801faa <pageref>
  8015b9:	89 c3                	mov    %eax,%ebx
  8015bb:	89 3c 24             	mov    %edi,(%esp)
  8015be:	e8 e7 09 00 00       	call   801faa <pageref>
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	39 c3                	cmp    %eax,%ebx
  8015c8:	0f 94 c1             	sete   %cl
  8015cb:	0f b6 c9             	movzbl %cl,%ecx
  8015ce:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015d1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015d7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015da:	39 ce                	cmp    %ecx,%esi
  8015dc:	74 1b                	je     8015f9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015de:	39 c3                	cmp    %eax,%ebx
  8015e0:	75 c4                	jne    8015a6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015e2:	8b 42 58             	mov    0x58(%edx),%eax
  8015e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e8:	50                   	push   %eax
  8015e9:	56                   	push   %esi
  8015ea:	68 b6 26 80 00       	push   $0x8026b6
  8015ef:	e8 5d eb ff ff       	call   800151 <cprintf>
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	eb ad                	jmp    8015a6 <_pipeisclosed+0xe>
	}
}
  8015f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	57                   	push   %edi
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
  80160a:	83 ec 28             	sub    $0x28,%esp
  80160d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801610:	56                   	push   %esi
  801611:	e8 03 f7 ff ff       	call   800d19 <fd2data>
  801616:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	bf 00 00 00 00       	mov    $0x0,%edi
  801620:	eb 4b                	jmp    80166d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801622:	89 da                	mov    %ebx,%edx
  801624:	89 f0                	mov    %esi,%eax
  801626:	e8 6d ff ff ff       	call   801598 <_pipeisclosed>
  80162b:	85 c0                	test   %eax,%eax
  80162d:	75 48                	jne    801677 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80162f:	e8 a6 f4 ff ff       	call   800ada <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801634:	8b 43 04             	mov    0x4(%ebx),%eax
  801637:	8b 0b                	mov    (%ebx),%ecx
  801639:	8d 51 20             	lea    0x20(%ecx),%edx
  80163c:	39 d0                	cmp    %edx,%eax
  80163e:	73 e2                	jae    801622 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801640:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801643:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801647:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	c1 fa 1f             	sar    $0x1f,%edx
  80164f:	89 d1                	mov    %edx,%ecx
  801651:	c1 e9 1b             	shr    $0x1b,%ecx
  801654:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801657:	83 e2 1f             	and    $0x1f,%edx
  80165a:	29 ca                	sub    %ecx,%edx
  80165c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801660:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801664:	83 c0 01             	add    $0x1,%eax
  801667:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166a:	83 c7 01             	add    $0x1,%edi
  80166d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801670:	75 c2                	jne    801634 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801672:	8b 45 10             	mov    0x10(%ebp),%eax
  801675:	eb 05                	jmp    80167c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80167c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	57                   	push   %edi
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
  80168a:	83 ec 18             	sub    $0x18,%esp
  80168d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801690:	57                   	push   %edi
  801691:	e8 83 f6 ff ff       	call   800d19 <fd2data>
  801696:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a0:	eb 3d                	jmp    8016df <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016a2:	85 db                	test   %ebx,%ebx
  8016a4:	74 04                	je     8016aa <devpipe_read+0x26>
				return i;
  8016a6:	89 d8                	mov    %ebx,%eax
  8016a8:	eb 44                	jmp    8016ee <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016aa:	89 f2                	mov    %esi,%edx
  8016ac:	89 f8                	mov    %edi,%eax
  8016ae:	e8 e5 fe ff ff       	call   801598 <_pipeisclosed>
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	75 32                	jne    8016e9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016b7:	e8 1e f4 ff ff       	call   800ada <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016bc:	8b 06                	mov    (%esi),%eax
  8016be:	3b 46 04             	cmp    0x4(%esi),%eax
  8016c1:	74 df                	je     8016a2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016c3:	99                   	cltd   
  8016c4:	c1 ea 1b             	shr    $0x1b,%edx
  8016c7:	01 d0                	add    %edx,%eax
  8016c9:	83 e0 1f             	and    $0x1f,%eax
  8016cc:	29 d0                	sub    %edx,%eax
  8016ce:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016d9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016dc:	83 c3 01             	add    $0x1,%ebx
  8016df:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016e2:	75 d8                	jne    8016bc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e7:	eb 05                	jmp    8016ee <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5f                   	pop    %edi
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	e8 29 f6 ff ff       	call   800d30 <fd_alloc>
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	85 c0                	test   %eax,%eax
  80170e:	0f 88 2c 01 00 00    	js     801840 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801714:	83 ec 04             	sub    $0x4,%esp
  801717:	68 07 04 00 00       	push   $0x407
  80171c:	ff 75 f4             	pushl  -0xc(%ebp)
  80171f:	6a 00                	push   $0x0
  801721:	e8 d3 f3 ff ff       	call   800af9 <sys_page_alloc>
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	89 c2                	mov    %eax,%edx
  80172b:	85 c0                	test   %eax,%eax
  80172d:	0f 88 0d 01 00 00    	js     801840 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801733:	83 ec 0c             	sub    $0xc,%esp
  801736:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801739:	50                   	push   %eax
  80173a:	e8 f1 f5 ff ff       	call   800d30 <fd_alloc>
  80173f:	89 c3                	mov    %eax,%ebx
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	85 c0                	test   %eax,%eax
  801746:	0f 88 e2 00 00 00    	js     80182e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174c:	83 ec 04             	sub    $0x4,%esp
  80174f:	68 07 04 00 00       	push   $0x407
  801754:	ff 75 f0             	pushl  -0x10(%ebp)
  801757:	6a 00                	push   $0x0
  801759:	e8 9b f3 ff ff       	call   800af9 <sys_page_alloc>
  80175e:	89 c3                	mov    %eax,%ebx
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	0f 88 c3 00 00 00    	js     80182e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80176b:	83 ec 0c             	sub    $0xc,%esp
  80176e:	ff 75 f4             	pushl  -0xc(%ebp)
  801771:	e8 a3 f5 ff ff       	call   800d19 <fd2data>
  801776:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801778:	83 c4 0c             	add    $0xc,%esp
  80177b:	68 07 04 00 00       	push   $0x407
  801780:	50                   	push   %eax
  801781:	6a 00                	push   $0x0
  801783:	e8 71 f3 ff ff       	call   800af9 <sys_page_alloc>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	85 c0                	test   %eax,%eax
  80178f:	0f 88 89 00 00 00    	js     80181e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801795:	83 ec 0c             	sub    $0xc,%esp
  801798:	ff 75 f0             	pushl  -0x10(%ebp)
  80179b:	e8 79 f5 ff ff       	call   800d19 <fd2data>
  8017a0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017a7:	50                   	push   %eax
  8017a8:	6a 00                	push   $0x0
  8017aa:	56                   	push   %esi
  8017ab:	6a 00                	push   $0x0
  8017ad:	e8 8a f3 ff ff       	call   800b3c <sys_page_map>
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	83 c4 20             	add    $0x20,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 55                	js     801810 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017bb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017d0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017de:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017e5:	83 ec 0c             	sub    $0xc,%esp
  8017e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017eb:	e8 19 f5 ff ff       	call   800d09 <fd2num>
  8017f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017f5:	83 c4 04             	add    $0x4,%esp
  8017f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017fb:	e8 09 f5 ff ff       	call   800d09 <fd2num>
  801800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801803:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	eb 30                	jmp    801840 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	56                   	push   %esi
  801814:	6a 00                	push   $0x0
  801816:	e8 63 f3 ff ff       	call   800b7e <sys_page_unmap>
  80181b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	ff 75 f0             	pushl  -0x10(%ebp)
  801824:	6a 00                	push   $0x0
  801826:	e8 53 f3 ff ff       	call   800b7e <sys_page_unmap>
  80182b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	ff 75 f4             	pushl  -0xc(%ebp)
  801834:	6a 00                	push   $0x0
  801836:	e8 43 f3 ff ff       	call   800b7e <sys_page_unmap>
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801840:	89 d0                	mov    %edx,%eax
  801842:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80184f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801852:	50                   	push   %eax
  801853:	ff 75 08             	pushl  0x8(%ebp)
  801856:	e8 24 f5 ff ff       	call   800d7f <fd_lookup>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 18                	js     80187a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801862:	83 ec 0c             	sub    $0xc,%esp
  801865:	ff 75 f4             	pushl  -0xc(%ebp)
  801868:	e8 ac f4 ff ff       	call   800d19 <fd2data>
	return _pipeisclosed(fd, p);
  80186d:	89 c2                	mov    %eax,%edx
  80186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801872:	e8 21 fd ff ff       	call   801598 <_pipeisclosed>
  801877:	83 c4 10             	add    $0x10,%esp
}
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801882:	68 ce 26 80 00       	push   $0x8026ce
  801887:	ff 75 0c             	pushl  0xc(%ebp)
  80188a:	e8 67 ee ff ff       	call   8006f6 <strcpy>
	return 0;
}
  80188f:	b8 00 00 00 00       	mov    $0x0,%eax
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	53                   	push   %ebx
  80189a:	83 ec 10             	sub    $0x10,%esp
  80189d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018a0:	53                   	push   %ebx
  8018a1:	e8 04 07 00 00       	call   801faa <pageref>
  8018a6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018a9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018ae:	83 f8 01             	cmp    $0x1,%eax
  8018b1:	75 10                	jne    8018c3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018b3:	83 ec 0c             	sub    $0xc,%esp
  8018b6:	ff 73 0c             	pushl  0xc(%ebx)
  8018b9:	e8 c0 02 00 00       	call   801b7e <nsipc_close>
  8018be:	89 c2                	mov    %eax,%edx
  8018c0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018c3:	89 d0                	mov    %edx,%eax
  8018c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018d0:	6a 00                	push   $0x0
  8018d2:	ff 75 10             	pushl  0x10(%ebp)
  8018d5:	ff 75 0c             	pushl  0xc(%ebp)
  8018d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018db:	ff 70 0c             	pushl  0xc(%eax)
  8018de:	e8 78 03 00 00       	call   801c5b <nsipc_send>
}
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018eb:	6a 00                	push   $0x0
  8018ed:	ff 75 10             	pushl  0x10(%ebp)
  8018f0:	ff 75 0c             	pushl  0xc(%ebp)
  8018f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f6:	ff 70 0c             	pushl  0xc(%eax)
  8018f9:	e8 f1 02 00 00       	call   801bef <nsipc_recv>
}
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801906:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801909:	52                   	push   %edx
  80190a:	50                   	push   %eax
  80190b:	e8 6f f4 ff ff       	call   800d7f <fd_lookup>
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	78 17                	js     80192e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801917:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191a:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801920:	39 08                	cmp    %ecx,(%eax)
  801922:	75 05                	jne    801929 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801924:	8b 40 0c             	mov    0xc(%eax),%eax
  801927:	eb 05                	jmp    80192e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801929:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
  801935:	83 ec 1c             	sub    $0x1c,%esp
  801938:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80193a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193d:	50                   	push   %eax
  80193e:	e8 ed f3 ff ff       	call   800d30 <fd_alloc>
  801943:	89 c3                	mov    %eax,%ebx
  801945:	83 c4 10             	add    $0x10,%esp
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 1b                	js     801967 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80194c:	83 ec 04             	sub    $0x4,%esp
  80194f:	68 07 04 00 00       	push   $0x407
  801954:	ff 75 f4             	pushl  -0xc(%ebp)
  801957:	6a 00                	push   $0x0
  801959:	e8 9b f1 ff ff       	call   800af9 <sys_page_alloc>
  80195e:	89 c3                	mov    %eax,%ebx
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	79 10                	jns    801977 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	56                   	push   %esi
  80196b:	e8 0e 02 00 00       	call   801b7e <nsipc_close>
		return r;
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	89 d8                	mov    %ebx,%eax
  801975:	eb 24                	jmp    80199b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801977:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80197d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801980:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801985:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80198c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	50                   	push   %eax
  801993:	e8 71 f3 ff ff       	call   800d09 <fd2num>
  801998:	83 c4 10             	add    $0x10,%esp
}
  80199b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199e:	5b                   	pop    %ebx
  80199f:	5e                   	pop    %esi
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ab:	e8 50 ff ff ff       	call   801900 <fd2sockid>
		return r;
  8019b0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 1f                	js     8019d5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019b6:	83 ec 04             	sub    $0x4,%esp
  8019b9:	ff 75 10             	pushl  0x10(%ebp)
  8019bc:	ff 75 0c             	pushl  0xc(%ebp)
  8019bf:	50                   	push   %eax
  8019c0:	e8 12 01 00 00       	call   801ad7 <nsipc_accept>
  8019c5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 07                	js     8019d5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019ce:	e8 5d ff ff ff       	call   801930 <alloc_sockfd>
  8019d3:	89 c1                	mov    %eax,%ecx
}
  8019d5:	89 c8                	mov    %ecx,%eax
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	e8 19 ff ff ff       	call   801900 <fd2sockid>
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	78 12                	js     8019fd <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019eb:	83 ec 04             	sub    $0x4,%esp
  8019ee:	ff 75 10             	pushl  0x10(%ebp)
  8019f1:	ff 75 0c             	pushl  0xc(%ebp)
  8019f4:	50                   	push   %eax
  8019f5:	e8 2d 01 00 00       	call   801b27 <nsipc_bind>
  8019fa:	83 c4 10             	add    $0x10,%esp
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <shutdown>:

int
shutdown(int s, int how)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a05:	8b 45 08             	mov    0x8(%ebp),%eax
  801a08:	e8 f3 fe ff ff       	call   801900 <fd2sockid>
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	78 0f                	js     801a20 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	ff 75 0c             	pushl  0xc(%ebp)
  801a17:	50                   	push   %eax
  801a18:	e8 3f 01 00 00       	call   801b5c <nsipc_shutdown>
  801a1d:	83 c4 10             	add    $0x10,%esp
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	e8 d0 fe ff ff       	call   801900 <fd2sockid>
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 12                	js     801a46 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a34:	83 ec 04             	sub    $0x4,%esp
  801a37:	ff 75 10             	pushl  0x10(%ebp)
  801a3a:	ff 75 0c             	pushl  0xc(%ebp)
  801a3d:	50                   	push   %eax
  801a3e:	e8 55 01 00 00       	call   801b98 <nsipc_connect>
  801a43:	83 c4 10             	add    $0x10,%esp
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <listen>:

int
listen(int s, int backlog)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a51:	e8 aa fe ff ff       	call   801900 <fd2sockid>
  801a56:	85 c0                	test   %eax,%eax
  801a58:	78 0f                	js     801a69 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	ff 75 0c             	pushl  0xc(%ebp)
  801a60:	50                   	push   %eax
  801a61:	e8 67 01 00 00       	call   801bcd <nsipc_listen>
  801a66:	83 c4 10             	add    $0x10,%esp
}
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a71:	ff 75 10             	pushl  0x10(%ebp)
  801a74:	ff 75 0c             	pushl  0xc(%ebp)
  801a77:	ff 75 08             	pushl  0x8(%ebp)
  801a7a:	e8 3a 02 00 00       	call   801cb9 <nsipc_socket>
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 05                	js     801a8b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a86:	e8 a5 fe ff ff       	call   801930 <alloc_sockfd>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	53                   	push   %ebx
  801a91:	83 ec 04             	sub    $0x4,%esp
  801a94:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a96:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a9d:	75 12                	jne    801ab1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	6a 02                	push   $0x2
  801aa4:	e8 c8 04 00 00       	call   801f71 <ipc_find_env>
  801aa9:	a3 04 40 80 00       	mov    %eax,0x804004
  801aae:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ab1:	6a 07                	push   $0x7
  801ab3:	68 00 60 80 00       	push   $0x806000
  801ab8:	53                   	push   %ebx
  801ab9:	ff 35 04 40 80 00    	pushl  0x804004
  801abf:	e8 5e 04 00 00       	call   801f22 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ac4:	83 c4 0c             	add    $0xc,%esp
  801ac7:	6a 00                	push   $0x0
  801ac9:	6a 00                	push   $0x0
  801acb:	6a 00                	push   $0x0
  801acd:	e8 da 03 00 00       	call   801eac <ipc_recv>
}
  801ad2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad5:	c9                   	leave  
  801ad6:	c3                   	ret    

00801ad7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801adf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ae7:	8b 06                	mov    (%esi),%eax
  801ae9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801aee:	b8 01 00 00 00       	mov    $0x1,%eax
  801af3:	e8 95 ff ff ff       	call   801a8d <nsipc>
  801af8:	89 c3                	mov    %eax,%ebx
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 20                	js     801b1e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801afe:	83 ec 04             	sub    $0x4,%esp
  801b01:	ff 35 10 60 80 00    	pushl  0x806010
  801b07:	68 00 60 80 00       	push   $0x806000
  801b0c:	ff 75 0c             	pushl  0xc(%ebp)
  801b0f:	e8 74 ed ff ff       	call   800888 <memmove>
		*addrlen = ret->ret_addrlen;
  801b14:	a1 10 60 80 00       	mov    0x806010,%eax
  801b19:	89 06                	mov    %eax,(%esi)
  801b1b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5e                   	pop    %esi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 08             	sub    $0x8,%esp
  801b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b39:	53                   	push   %ebx
  801b3a:	ff 75 0c             	pushl  0xc(%ebp)
  801b3d:	68 04 60 80 00       	push   $0x806004
  801b42:	e8 41 ed ff ff       	call   800888 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b47:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b4d:	b8 02 00 00 00       	mov    $0x2,%eax
  801b52:	e8 36 ff ff ff       	call   801a8d <nsipc>
}
  801b57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b62:	8b 45 08             	mov    0x8(%ebp),%eax
  801b65:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b72:	b8 03 00 00 00       	mov    $0x3,%eax
  801b77:	e8 11 ff ff ff       	call   801a8d <nsipc>
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <nsipc_close>:

int
nsipc_close(int s)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b84:	8b 45 08             	mov    0x8(%ebp),%eax
  801b87:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b8c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b91:	e8 f7 fe ff ff       	call   801a8d <nsipc>
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 08             	sub    $0x8,%esp
  801b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801baa:	53                   	push   %ebx
  801bab:	ff 75 0c             	pushl  0xc(%ebp)
  801bae:	68 04 60 80 00       	push   $0x806004
  801bb3:	e8 d0 ec ff ff       	call   800888 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bb8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bbe:	b8 05 00 00 00       	mov    $0x5,%eax
  801bc3:	e8 c5 fe ff ff       	call   801a8d <nsipc>
}
  801bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bde:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801be3:	b8 06 00 00 00       	mov    $0x6,%eax
  801be8:	e8 a0 fe ff ff       	call   801a8d <nsipc>
}
  801bed:	c9                   	leave  
  801bee:	c3                   	ret    

00801bef <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bef:	55                   	push   %ebp
  801bf0:	89 e5                	mov    %esp,%ebp
  801bf2:	56                   	push   %esi
  801bf3:	53                   	push   %ebx
  801bf4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bff:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c05:	8b 45 14             	mov    0x14(%ebp),%eax
  801c08:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c0d:	b8 07 00 00 00       	mov    $0x7,%eax
  801c12:	e8 76 fe ff ff       	call   801a8d <nsipc>
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	78 35                	js     801c52 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c1d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c22:	7f 04                	jg     801c28 <nsipc_recv+0x39>
  801c24:	39 c6                	cmp    %eax,%esi
  801c26:	7d 16                	jge    801c3e <nsipc_recv+0x4f>
  801c28:	68 da 26 80 00       	push   $0x8026da
  801c2d:	68 83 26 80 00       	push   $0x802683
  801c32:	6a 62                	push   $0x62
  801c34:	68 ef 26 80 00       	push   $0x8026ef
  801c39:	e8 28 02 00 00       	call   801e66 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c3e:	83 ec 04             	sub    $0x4,%esp
  801c41:	50                   	push   %eax
  801c42:	68 00 60 80 00       	push   $0x806000
  801c47:	ff 75 0c             	pushl  0xc(%ebp)
  801c4a:	e8 39 ec ff ff       	call   800888 <memmove>
  801c4f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c52:	89 d8                	mov    %ebx,%eax
  801c54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c6d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c73:	7e 16                	jle    801c8b <nsipc_send+0x30>
  801c75:	68 fb 26 80 00       	push   $0x8026fb
  801c7a:	68 83 26 80 00       	push   $0x802683
  801c7f:	6a 6d                	push   $0x6d
  801c81:	68 ef 26 80 00       	push   $0x8026ef
  801c86:	e8 db 01 00 00       	call   801e66 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c8b:	83 ec 04             	sub    $0x4,%esp
  801c8e:	53                   	push   %ebx
  801c8f:	ff 75 0c             	pushl  0xc(%ebp)
  801c92:	68 0c 60 80 00       	push   $0x80600c
  801c97:	e8 ec eb ff ff       	call   800888 <memmove>
	nsipcbuf.send.req_size = size;
  801c9c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ca2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801caa:	b8 08 00 00 00       	mov    $0x8,%eax
  801caf:	e8 d9 fd ff ff       	call   801a8d <nsipc>
}
  801cb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    

00801cb9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cca:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cd7:	b8 09 00 00 00       	mov    $0x9,%eax
  801cdc:	e8 ac fd ff ff       	call   801a8d <nsipc>
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    

00801ced <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf3:	68 07 27 80 00       	push   $0x802707
  801cf8:	ff 75 0c             	pushl  0xc(%ebp)
  801cfb:	e8 f6 e9 ff ff       	call   8006f6 <strcpy>
	return 0;
}
  801d00:	b8 00 00 00 00       	mov    $0x0,%eax
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	57                   	push   %edi
  801d0b:	56                   	push   %esi
  801d0c:	53                   	push   %ebx
  801d0d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d13:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d18:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d1e:	eb 2d                	jmp    801d4d <devcons_write+0x46>
		m = n - tot;
  801d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d23:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d25:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d28:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d2d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d30:	83 ec 04             	sub    $0x4,%esp
  801d33:	53                   	push   %ebx
  801d34:	03 45 0c             	add    0xc(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	57                   	push   %edi
  801d39:	e8 4a eb ff ff       	call   800888 <memmove>
		sys_cputs(buf, m);
  801d3e:	83 c4 08             	add    $0x8,%esp
  801d41:	53                   	push   %ebx
  801d42:	57                   	push   %edi
  801d43:	e8 f5 ec ff ff       	call   800a3d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d48:	01 de                	add    %ebx,%esi
  801d4a:	83 c4 10             	add    $0x10,%esp
  801d4d:	89 f0                	mov    %esi,%eax
  801d4f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d52:	72 cc                	jb     801d20 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    

00801d5c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 08             	sub    $0x8,%esp
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d67:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6b:	74 2a                	je     801d97 <devcons_read+0x3b>
  801d6d:	eb 05                	jmp    801d74 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d6f:	e8 66 ed ff ff       	call   800ada <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d74:	e8 e2 ec ff ff       	call   800a5b <sys_cgetc>
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	74 f2                	je     801d6f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	78 16                	js     801d97 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d81:	83 f8 04             	cmp    $0x4,%eax
  801d84:	74 0c                	je     801d92 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d86:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d89:	88 02                	mov    %al,(%edx)
	return 1;
  801d8b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d90:	eb 05                	jmp    801d97 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d92:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da5:	6a 01                	push   $0x1
  801da7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	e8 8d ec ff ff       	call   800a3d <sys_cputs>
}
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <getchar>:

int
getchar(void)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbb:	6a 01                	push   $0x1
  801dbd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc0:	50                   	push   %eax
  801dc1:	6a 00                	push   $0x0
  801dc3:	e8 1d f2 ff ff       	call   800fe5 <read>
	if (r < 0)
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 0f                	js     801dde <getchar+0x29>
		return r;
	if (r < 1)
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	7e 06                	jle    801dd9 <getchar+0x24>
		return -E_EOF;
	return c;
  801dd3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dd7:	eb 05                	jmp    801dde <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dd9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de9:	50                   	push   %eax
  801dea:	ff 75 08             	pushl  0x8(%ebp)
  801ded:	e8 8d ef ff ff       	call   800d7f <fd_lookup>
  801df2:	83 c4 10             	add    $0x10,%esp
  801df5:	85 c0                	test   %eax,%eax
  801df7:	78 11                	js     801e0a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e02:	39 10                	cmp    %edx,(%eax)
  801e04:	0f 94 c0             	sete   %al
  801e07:	0f b6 c0             	movzbl %al,%eax
}
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <opencons>:

int
opencons(void)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e15:	50                   	push   %eax
  801e16:	e8 15 ef ff ff       	call   800d30 <fd_alloc>
  801e1b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e20:	85 c0                	test   %eax,%eax
  801e22:	78 3e                	js     801e62 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e24:	83 ec 04             	sub    $0x4,%esp
  801e27:	68 07 04 00 00       	push   $0x407
  801e2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e2f:	6a 00                	push   $0x0
  801e31:	e8 c3 ec ff ff       	call   800af9 <sys_page_alloc>
  801e36:	83 c4 10             	add    $0x10,%esp
		return r;
  801e39:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 23                	js     801e62 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e3f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e48:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e54:	83 ec 0c             	sub    $0xc,%esp
  801e57:	50                   	push   %eax
  801e58:	e8 ac ee ff ff       	call   800d09 <fd2num>
  801e5d:	89 c2                	mov    %eax,%edx
  801e5f:	83 c4 10             	add    $0x10,%esp
}
  801e62:	89 d0                	mov    %edx,%eax
  801e64:	c9                   	leave  
  801e65:	c3                   	ret    

00801e66 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	56                   	push   %esi
  801e6a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e6b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e6e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e74:	e8 42 ec ff ff       	call   800abb <sys_getenvid>
  801e79:	83 ec 0c             	sub    $0xc,%esp
  801e7c:	ff 75 0c             	pushl  0xc(%ebp)
  801e7f:	ff 75 08             	pushl  0x8(%ebp)
  801e82:	56                   	push   %esi
  801e83:	50                   	push   %eax
  801e84:	68 14 27 80 00       	push   $0x802714
  801e89:	e8 c3 e2 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e8e:	83 c4 18             	add    $0x18,%esp
  801e91:	53                   	push   %ebx
  801e92:	ff 75 10             	pushl  0x10(%ebp)
  801e95:	e8 66 e2 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801e9a:	c7 04 24 c7 26 80 00 	movl   $0x8026c7,(%esp)
  801ea1:	e8 ab e2 ff ff       	call   800151 <cprintf>
  801ea6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ea9:	cc                   	int3   
  801eaa:	eb fd                	jmp    801ea9 <_panic+0x43>

00801eac <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	56                   	push   %esi
  801eb0:	53                   	push   %ebx
  801eb1:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	74 0e                	je     801ecc <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801ebe:	83 ec 0c             	sub    $0xc,%esp
  801ec1:	50                   	push   %eax
  801ec2:	e8 e2 ed ff ff       	call   800ca9 <sys_ipc_recv>
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	eb 10                	jmp    801edc <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	68 00 00 c0 ee       	push   $0xeec00000
  801ed4:	e8 d0 ed ff ff       	call   800ca9 <sys_ipc_recv>
  801ed9:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801edc:	85 c0                	test   %eax,%eax
  801ede:	79 17                	jns    801ef7 <ipc_recv+0x4b>
		if(*from_env_store)
  801ee0:	83 3e 00             	cmpl   $0x0,(%esi)
  801ee3:	74 06                	je     801eeb <ipc_recv+0x3f>
			*from_env_store = 0;
  801ee5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801eeb:	85 db                	test   %ebx,%ebx
  801eed:	74 2c                	je     801f1b <ipc_recv+0x6f>
			*perm_store = 0;
  801eef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ef5:	eb 24                	jmp    801f1b <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	74 0a                	je     801f05 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801efb:	a1 08 40 80 00       	mov    0x804008,%eax
  801f00:	8b 40 74             	mov    0x74(%eax),%eax
  801f03:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801f05:	85 db                	test   %ebx,%ebx
  801f07:	74 0a                	je     801f13 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801f09:	a1 08 40 80 00       	mov    0x804008,%eax
  801f0e:	8b 40 78             	mov    0x78(%eax),%eax
  801f11:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f13:	a1 08 40 80 00       	mov    0x804008,%eax
  801f18:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5e                   	pop    %esi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	57                   	push   %edi
  801f26:	56                   	push   %esi
  801f27:	53                   	push   %ebx
  801f28:	83 ec 0c             	sub    $0xc,%esp
  801f2b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f34:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f36:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f3b:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f3e:	e8 97 eb ff ff       	call   800ada <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f43:	ff 75 14             	pushl  0x14(%ebp)
  801f46:	53                   	push   %ebx
  801f47:	56                   	push   %esi
  801f48:	57                   	push   %edi
  801f49:	e8 38 ed ff ff       	call   800c86 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f4e:	89 c2                	mov    %eax,%edx
  801f50:	f7 d2                	not    %edx
  801f52:	c1 ea 1f             	shr    $0x1f,%edx
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5b:	0f 94 c1             	sete   %cl
  801f5e:	09 ca                	or     %ecx,%edx
  801f60:	85 c0                	test   %eax,%eax
  801f62:	0f 94 c0             	sete   %al
  801f65:	38 c2                	cmp    %al,%dl
  801f67:	77 d5                	ja     801f3e <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6c:	5b                   	pop    %ebx
  801f6d:	5e                   	pop    %esi
  801f6e:	5f                   	pop    %edi
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    

00801f71 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f77:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f7f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f85:	8b 52 50             	mov    0x50(%edx),%edx
  801f88:	39 ca                	cmp    %ecx,%edx
  801f8a:	75 0d                	jne    801f99 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f8c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f8f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f94:	8b 40 48             	mov    0x48(%eax),%eax
  801f97:	eb 0f                	jmp    801fa8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f99:	83 c0 01             	add    $0x1,%eax
  801f9c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa1:	75 d9                	jne    801f7c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb0:	89 d0                	mov    %edx,%eax
  801fb2:	c1 e8 16             	shr    $0x16,%eax
  801fb5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc1:	f6 c1 01             	test   $0x1,%cl
  801fc4:	74 1d                	je     801fe3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc6:	c1 ea 0c             	shr    $0xc,%edx
  801fc9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd0:	f6 c2 01             	test   $0x1,%dl
  801fd3:	74 0e                	je     801fe3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd5:	c1 ea 0c             	shr    $0xc,%edx
  801fd8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fdf:	ef 
  801fe0:	0f b7 c0             	movzwl %ax,%eax
}
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    
  801fe5:	66 90                	xchg   %ax,%ax
  801fe7:	66 90                	xchg   %ax,%ax
  801fe9:	66 90                	xchg   %ax,%ax
  801feb:	66 90                	xchg   %ax,%ax
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
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
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
