
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 80 22 80 00       	push   $0x802280
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800059:	e8 4d 0a 00 00       	call   800aab <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 25 0e 00 00       	call   800ec4 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 c1 09 00 00       	call   800a6a <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 4f 09 00 00       	call   800a2d <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 54 01 00 00       	call   800278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 f4 08 00 00       	call   800a2d <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 37 1e 00 00       	call   801fe0 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 24 1f 00 00       	call   802110 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 b1 22 80 00 	movsbl 0x8022b1(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800207:	83 fa 01             	cmp    $0x1,%edx
  80020a:	7e 0e                	jle    80021a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020c:	8b 10                	mov    (%eax),%edx
  80020e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800211:	89 08                	mov    %ecx,(%eax)
  800213:	8b 02                	mov    (%edx),%eax
  800215:	8b 52 04             	mov    0x4(%edx),%edx
  800218:	eb 22                	jmp    80023c <getuint+0x38>
	else if (lflag)
  80021a:	85 d2                	test   %edx,%edx
  80021c:	74 10                	je     80022e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 04             	lea    0x4(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	ba 00 00 00 00       	mov    $0x0,%edx
  80022c:	eb 0e                	jmp    80023c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800244:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	3b 50 04             	cmp    0x4(%eax),%edx
  80024d:	73 0a                	jae    800259 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	88 02                	mov    %al,(%edx)
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800261:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800264:	50                   	push   %eax
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	e8 05 00 00 00       	call   800278 <vprintfmt>
	va_end(ap);
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028a:	eb 12                	jmp    80029e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028c:	85 c0                	test   %eax,%eax
  80028e:	0f 84 a9 03 00 00    	je     80063d <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	53                   	push   %ebx
  800298:	50                   	push   %eax
  800299:	ff d6                	call   *%esi
  80029b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029e:	83 c7 01             	add    $0x1,%edi
  8002a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a5:	83 f8 25             	cmp    $0x25,%eax
  8002a8:	75 e2                	jne    80028c <vprintfmt+0x14>
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c8:	eb 07                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002cd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8d 47 01             	lea    0x1(%edi),%eax
  8002d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d7:	0f b6 07             	movzbl (%edi),%eax
  8002da:	0f b6 c8             	movzbl %al,%ecx
  8002dd:	83 e8 23             	sub    $0x23,%eax
  8002e0:	3c 55                	cmp    $0x55,%al
  8002e2:	0f 87 3a 03 00 00    	ja     800622 <vprintfmt+0x3aa>
  8002e8:	0f b6 c0             	movzbl %al,%eax
  8002eb:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f9:	eb d6                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800309:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80030d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800310:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800313:	83 fa 09             	cmp    $0x9,%edx
  800316:	77 39                	ja     800351 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031b:	eb e9                	jmp    800306 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 48 04             	lea    0x4(%eax),%ecx
  800323:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800326:	8b 00                	mov    (%eax),%eax
  800328:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80032e:	eb 27                	jmp    800357 <vprintfmt+0xdf>
  800330:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800333:	85 c0                	test   %eax,%eax
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	0f 49 c8             	cmovns %eax,%ecx
  80033d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800343:	eb 8c                	jmp    8002d1 <vprintfmt+0x59>
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800348:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034f:	eb 80                	jmp    8002d1 <vprintfmt+0x59>
  800351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800354:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035b:	0f 89 70 ff ff ff    	jns    8002d1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800361:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800364:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800367:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036e:	e9 5e ff ff ff       	jmp    8002d1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800373:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800379:	e9 53 ff ff ff       	jmp    8002d1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 50 04             	lea    0x4(%eax),%edx
  800384:	89 55 14             	mov    %edx,0x14(%ebp)
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	ff 30                	pushl  (%eax)
  80038d:	ff d6                	call   *%esi
			break;
  80038f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800395:	e9 04 ff ff ff       	jmp    80029e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 50 04             	lea    0x4(%eax),%edx
  8003a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	99                   	cltd   
  8003a6:	31 d0                	xor    %edx,%eax
  8003a8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003aa:	83 f8 0f             	cmp    $0xf,%eax
  8003ad:	7f 0b                	jg     8003ba <vprintfmt+0x142>
  8003af:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	75 18                	jne    8003d2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ba:	50                   	push   %eax
  8003bb:	68 c9 22 80 00       	push   $0x8022c9
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	e8 94 fe ff ff       	call   80025b <printfmt>
  8003c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cd:	e9 cc fe ff ff       	jmp    80029e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d2:	52                   	push   %edx
  8003d3:	68 95 26 80 00       	push   $0x802695
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	e8 7c fe ff ff       	call   80025b <printfmt>
  8003df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e5:	e9 b4 fe ff ff       	jmp    80029e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 50 04             	lea    0x4(%eax),%edx
  8003f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f5:	85 ff                	test   %edi,%edi
  8003f7:	b8 c2 22 80 00       	mov    $0x8022c2,%eax
  8003fc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	0f 8e 94 00 00 00    	jle    80049d <vprintfmt+0x225>
  800409:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040d:	0f 84 98 00 00 00    	je     8004ab <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	ff 75 d0             	pushl  -0x30(%ebp)
  800419:	57                   	push   %edi
  80041a:	e8 a6 02 00 00       	call   8006c5 <strnlen>
  80041f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800422:	29 c1                	sub    %eax,%ecx
  800424:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800427:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800431:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800434:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	eb 0f                	jmp    800447 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 75 e0             	pushl  -0x20(%ebp)
  80043f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ef 01             	sub    $0x1,%edi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 ff                	test   %edi,%edi
  800449:	7f ed                	jg     800438 <vprintfmt+0x1c0>
  80044b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800451:	85 c9                	test   %ecx,%ecx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c1             	cmovns %ecx,%eax
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 75 08             	mov    %esi,0x8(%ebp)
  800460:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800463:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800466:	89 cb                	mov    %ecx,%ebx
  800468:	eb 4d                	jmp    8004b7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046e:	74 1b                	je     80048b <vprintfmt+0x213>
  800470:	0f be c0             	movsbl %al,%eax
  800473:	83 e8 20             	sub    $0x20,%eax
  800476:	83 f8 5e             	cmp    $0x5e,%eax
  800479:	76 10                	jbe    80048b <vprintfmt+0x213>
					putch('?', putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 0c             	pushl  0xc(%ebp)
  800481:	6a 3f                	push   $0x3f
  800483:	ff 55 08             	call   *0x8(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	eb 0d                	jmp    800498 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	52                   	push   %edx
  800492:	ff 55 08             	call   *0x8(%ebp)
  800495:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	eb 1a                	jmp    8004b7 <vprintfmt+0x23f>
  80049d:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a9:	eb 0c                	jmp    8004b7 <vprintfmt+0x23f>
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b7:	83 c7 01             	add    $0x1,%edi
  8004ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004be:	0f be d0             	movsbl %al,%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 23                	je     8004e8 <vprintfmt+0x270>
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	78 a1                	js     80046a <vprintfmt+0x1f2>
  8004c9:	83 ee 01             	sub    $0x1,%esi
  8004cc:	79 9c                	jns    80046a <vprintfmt+0x1f2>
  8004ce:	89 df                	mov    %ebx,%edi
  8004d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d6:	eb 18                	jmp    8004f0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	6a 20                	push   $0x20
  8004de:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e0:	83 ef 01             	sub    $0x1,%edi
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb 08                	jmp    8004f0 <vprintfmt+0x278>
  8004e8:	89 df                	mov    %ebx,%edi
  8004ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f e4                	jg     8004d8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f7:	e9 a2 fd ff ff       	jmp    80029e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fc:	83 fa 01             	cmp    $0x1,%edx
  8004ff:	7e 16                	jle    800517 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 08             	lea    0x8(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	8b 50 04             	mov    0x4(%eax),%edx
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800512:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800515:	eb 32                	jmp    800549 <vprintfmt+0x2d1>
	else if (lflag)
  800517:	85 d2                	test   %edx,%edx
  800519:	74 18                	je     800533 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	eb 16                	jmp    800549 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800541:	89 c1                	mov    %eax,%ecx
  800543:	c1 f9 1f             	sar    $0x1f,%ecx
  800546:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800549:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800554:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800558:	0f 89 90 00 00 00    	jns    8005ee <vprintfmt+0x376>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800569:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056c:	f7 d8                	neg    %eax
  80056e:	83 d2 00             	adc    $0x0,%edx
  800571:	f7 da                	neg    %edx
  800573:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800576:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80057b:	eb 71                	jmp    8005ee <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057d:	8d 45 14             	lea    0x14(%ebp),%eax
  800580:	e8 7f fc ff ff       	call   800204 <getuint>
			base = 10;
  800585:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80058a:	eb 62                	jmp    8005ee <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
  80058f:	e8 70 fc ff ff       	call   800204 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800594:	83 ec 0c             	sub    $0xc,%esp
  800597:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80059b:	51                   	push   %ecx
  80059c:	ff 75 e0             	pushl  -0x20(%ebp)
  80059f:	6a 08                	push   $0x8
  8005a1:	52                   	push   %edx
  8005a2:	50                   	push   %eax
  8005a3:	89 da                	mov    %ebx,%edx
  8005a5:	89 f0                	mov    %esi,%eax
  8005a7:	e8 a9 fb ff ff       	call   800155 <printnum>
			break;
  8005ac:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8005b2:	e9 e7 fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 30                	push   $0x30
  8005bd:	ff d6                	call   *%esi
			putch('x', putdat);
  8005bf:	83 c4 08             	add    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	6a 78                	push   $0x78
  8005c5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 04             	lea    0x4(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005da:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005df:	eb 0d                	jmp    8005ee <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 1b fc ff ff       	call   800204 <getuint>
			base = 16;
  8005e9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005ee:	83 ec 0c             	sub    $0xc,%esp
  8005f1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005f5:	57                   	push   %edi
  8005f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f9:	51                   	push   %ecx
  8005fa:	52                   	push   %edx
  8005fb:	50                   	push   %eax
  8005fc:	89 da                	mov    %ebx,%edx
  8005fe:	89 f0                	mov    %esi,%eax
  800600:	e8 50 fb ff ff       	call   800155 <printnum>
			break;
  800605:	83 c4 20             	add    $0x20,%esp
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060b:	e9 8e fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	51                   	push   %ecx
  800615:	ff d6                	call   *%esi
			break;
  800617:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80061d:	e9 7c fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 25                	push   $0x25
  800628:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	eb 03                	jmp    800632 <vprintfmt+0x3ba>
  80062f:	83 ef 01             	sub    $0x1,%edi
  800632:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800636:	75 f7                	jne    80062f <vprintfmt+0x3b7>
  800638:	e9 61 fc ff ff       	jmp    80029e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80063d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800640:	5b                   	pop    %ebx
  800641:	5e                   	pop    %esi
  800642:	5f                   	pop    %edi
  800643:	5d                   	pop    %ebp
  800644:	c3                   	ret    

00800645 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800645:	55                   	push   %ebp
  800646:	89 e5                	mov    %esp,%ebp
  800648:	83 ec 18             	sub    $0x18,%esp
  80064b:	8b 45 08             	mov    0x8(%ebp),%eax
  80064e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800651:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800654:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800658:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800662:	85 c0                	test   %eax,%eax
  800664:	74 26                	je     80068c <vsnprintf+0x47>
  800666:	85 d2                	test   %edx,%edx
  800668:	7e 22                	jle    80068c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066a:	ff 75 14             	pushl  0x14(%ebp)
  80066d:	ff 75 10             	pushl  0x10(%ebp)
  800670:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800673:	50                   	push   %eax
  800674:	68 3e 02 80 00       	push   $0x80023e
  800679:	e8 fa fb ff ff       	call   800278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80067e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800681:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800684:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	eb 05                	jmp    800691 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80068c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800691:	c9                   	leave  
  800692:	c3                   	ret    

00800693 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800699:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80069c:	50                   	push   %eax
  80069d:	ff 75 10             	pushl  0x10(%ebp)
  8006a0:	ff 75 0c             	pushl  0xc(%ebp)
  8006a3:	ff 75 08             	pushl  0x8(%ebp)
  8006a6:	e8 9a ff ff ff       	call   800645 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    

008006ad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b8:	eb 03                	jmp    8006bd <strlen+0x10>
		n++;
  8006ba:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c1:	75 f7                	jne    8006ba <strlen+0xd>
		n++;
	return n;
}
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d3:	eb 03                	jmp    8006d8 <strnlen+0x13>
		n++;
  8006d5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d8:	39 c2                	cmp    %eax,%edx
  8006da:	74 08                	je     8006e4 <strnlen+0x1f>
  8006dc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006e0:	75 f3                	jne    8006d5 <strnlen+0x10>
  8006e2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	53                   	push   %ebx
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006f0:	89 c2                	mov    %eax,%edx
  8006f2:	83 c2 01             	add    $0x1,%edx
  8006f5:	83 c1 01             	add    $0x1,%ecx
  8006f8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006fc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006ff:	84 db                	test   %bl,%bl
  800701:	75 ef                	jne    8006f2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800703:	5b                   	pop    %ebx
  800704:	5d                   	pop    %ebp
  800705:	c3                   	ret    

00800706 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	53                   	push   %ebx
  80070a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80070d:	53                   	push   %ebx
  80070e:	e8 9a ff ff ff       	call   8006ad <strlen>
  800713:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800716:	ff 75 0c             	pushl  0xc(%ebp)
  800719:	01 d8                	add    %ebx,%eax
  80071b:	50                   	push   %eax
  80071c:	e8 c5 ff ff ff       	call   8006e6 <strcpy>
	return dst;
}
  800721:	89 d8                	mov    %ebx,%eax
  800723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	56                   	push   %esi
  80072c:	53                   	push   %ebx
  80072d:	8b 75 08             	mov    0x8(%ebp),%esi
  800730:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800733:	89 f3                	mov    %esi,%ebx
  800735:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800738:	89 f2                	mov    %esi,%edx
  80073a:	eb 0f                	jmp    80074b <strncpy+0x23>
		*dst++ = *src;
  80073c:	83 c2 01             	add    $0x1,%edx
  80073f:	0f b6 01             	movzbl (%ecx),%eax
  800742:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800745:	80 39 01             	cmpb   $0x1,(%ecx)
  800748:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074b:	39 da                	cmp    %ebx,%edx
  80074d:	75 ed                	jne    80073c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80074f:	89 f0                	mov    %esi,%eax
  800751:	5b                   	pop    %ebx
  800752:	5e                   	pop    %esi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	56                   	push   %esi
  800759:	53                   	push   %ebx
  80075a:	8b 75 08             	mov    0x8(%ebp),%esi
  80075d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800760:	8b 55 10             	mov    0x10(%ebp),%edx
  800763:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800765:	85 d2                	test   %edx,%edx
  800767:	74 21                	je     80078a <strlcpy+0x35>
  800769:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80076d:	89 f2                	mov    %esi,%edx
  80076f:	eb 09                	jmp    80077a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800771:	83 c2 01             	add    $0x1,%edx
  800774:	83 c1 01             	add    $0x1,%ecx
  800777:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80077a:	39 c2                	cmp    %eax,%edx
  80077c:	74 09                	je     800787 <strlcpy+0x32>
  80077e:	0f b6 19             	movzbl (%ecx),%ebx
  800781:	84 db                	test   %bl,%bl
  800783:	75 ec                	jne    800771 <strlcpy+0x1c>
  800785:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800787:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80078a:	29 f0                	sub    %esi,%eax
}
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800799:	eb 06                	jmp    8007a1 <strcmp+0x11>
		p++, q++;
  80079b:	83 c1 01             	add    $0x1,%ecx
  80079e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007a1:	0f b6 01             	movzbl (%ecx),%eax
  8007a4:	84 c0                	test   %al,%al
  8007a6:	74 04                	je     8007ac <strcmp+0x1c>
  8007a8:	3a 02                	cmp    (%edx),%al
  8007aa:	74 ef                	je     80079b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ac:	0f b6 c0             	movzbl %al,%eax
  8007af:	0f b6 12             	movzbl (%edx),%edx
  8007b2:	29 d0                	sub    %edx,%eax
}
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c0:	89 c3                	mov    %eax,%ebx
  8007c2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007c5:	eb 06                	jmp    8007cd <strncmp+0x17>
		n--, p++, q++;
  8007c7:	83 c0 01             	add    $0x1,%eax
  8007ca:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007cd:	39 d8                	cmp    %ebx,%eax
  8007cf:	74 15                	je     8007e6 <strncmp+0x30>
  8007d1:	0f b6 08             	movzbl (%eax),%ecx
  8007d4:	84 c9                	test   %cl,%cl
  8007d6:	74 04                	je     8007dc <strncmp+0x26>
  8007d8:	3a 0a                	cmp    (%edx),%cl
  8007da:	74 eb                	je     8007c7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dc:	0f b6 00             	movzbl (%eax),%eax
  8007df:	0f b6 12             	movzbl (%edx),%edx
  8007e2:	29 d0                	sub    %edx,%eax
  8007e4:	eb 05                	jmp    8007eb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007e6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f8:	eb 07                	jmp    800801 <strchr+0x13>
		if (*s == c)
  8007fa:	38 ca                	cmp    %cl,%dl
  8007fc:	74 0f                	je     80080d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007fe:	83 c0 01             	add    $0x1,%eax
  800801:	0f b6 10             	movzbl (%eax),%edx
  800804:	84 d2                	test   %dl,%dl
  800806:	75 f2                	jne    8007fa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800819:	eb 03                	jmp    80081e <strfind+0xf>
  80081b:	83 c0 01             	add    $0x1,%eax
  80081e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800821:	38 ca                	cmp    %cl,%dl
  800823:	74 04                	je     800829 <strfind+0x1a>
  800825:	84 d2                	test   %dl,%dl
  800827:	75 f2                	jne    80081b <strfind+0xc>
			break;
	return (char *) s;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	57                   	push   %edi
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 7d 08             	mov    0x8(%ebp),%edi
  800834:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800837:	85 c9                	test   %ecx,%ecx
  800839:	74 36                	je     800871 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80083b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800841:	75 28                	jne    80086b <memset+0x40>
  800843:	f6 c1 03             	test   $0x3,%cl
  800846:	75 23                	jne    80086b <memset+0x40>
		c &= 0xFF;
  800848:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80084c:	89 d3                	mov    %edx,%ebx
  80084e:	c1 e3 08             	shl    $0x8,%ebx
  800851:	89 d6                	mov    %edx,%esi
  800853:	c1 e6 18             	shl    $0x18,%esi
  800856:	89 d0                	mov    %edx,%eax
  800858:	c1 e0 10             	shl    $0x10,%eax
  80085b:	09 f0                	or     %esi,%eax
  80085d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80085f:	89 d8                	mov    %ebx,%eax
  800861:	09 d0                	or     %edx,%eax
  800863:	c1 e9 02             	shr    $0x2,%ecx
  800866:	fc                   	cld    
  800867:	f3 ab                	rep stos %eax,%es:(%edi)
  800869:	eb 06                	jmp    800871 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80086b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086e:	fc                   	cld    
  80086f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800871:	89 f8                	mov    %edi,%eax
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5f                   	pop    %edi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	57                   	push   %edi
  80087c:	56                   	push   %esi
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 75 0c             	mov    0xc(%ebp),%esi
  800883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800886:	39 c6                	cmp    %eax,%esi
  800888:	73 35                	jae    8008bf <memmove+0x47>
  80088a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80088d:	39 d0                	cmp    %edx,%eax
  80088f:	73 2e                	jae    8008bf <memmove+0x47>
		s += n;
		d += n;
  800891:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800894:	89 d6                	mov    %edx,%esi
  800896:	09 fe                	or     %edi,%esi
  800898:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80089e:	75 13                	jne    8008b3 <memmove+0x3b>
  8008a0:	f6 c1 03             	test   $0x3,%cl
  8008a3:	75 0e                	jne    8008b3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008a5:	83 ef 04             	sub    $0x4,%edi
  8008a8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ab:	c1 e9 02             	shr    $0x2,%ecx
  8008ae:	fd                   	std    
  8008af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b1:	eb 09                	jmp    8008bc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008b3:	83 ef 01             	sub    $0x1,%edi
  8008b6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008b9:	fd                   	std    
  8008ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008bc:	fc                   	cld    
  8008bd:	eb 1d                	jmp    8008dc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bf:	89 f2                	mov    %esi,%edx
  8008c1:	09 c2                	or     %eax,%edx
  8008c3:	f6 c2 03             	test   $0x3,%dl
  8008c6:	75 0f                	jne    8008d7 <memmove+0x5f>
  8008c8:	f6 c1 03             	test   $0x3,%cl
  8008cb:	75 0a                	jne    8008d7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008cd:	c1 e9 02             	shr    $0x2,%ecx
  8008d0:	89 c7                	mov    %eax,%edi
  8008d2:	fc                   	cld    
  8008d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d5:	eb 05                	jmp    8008dc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008d7:	89 c7                	mov    %eax,%edi
  8008d9:	fc                   	cld    
  8008da:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008dc:	5e                   	pop    %esi
  8008dd:	5f                   	pop    %edi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008e3:	ff 75 10             	pushl  0x10(%ebp)
  8008e6:	ff 75 0c             	pushl  0xc(%ebp)
  8008e9:	ff 75 08             	pushl  0x8(%ebp)
  8008ec:	e8 87 ff ff ff       	call   800878 <memmove>
}
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	56                   	push   %esi
  8008f7:	53                   	push   %ebx
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fe:	89 c6                	mov    %eax,%esi
  800900:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800903:	eb 1a                	jmp    80091f <memcmp+0x2c>
		if (*s1 != *s2)
  800905:	0f b6 08             	movzbl (%eax),%ecx
  800908:	0f b6 1a             	movzbl (%edx),%ebx
  80090b:	38 d9                	cmp    %bl,%cl
  80090d:	74 0a                	je     800919 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80090f:	0f b6 c1             	movzbl %cl,%eax
  800912:	0f b6 db             	movzbl %bl,%ebx
  800915:	29 d8                	sub    %ebx,%eax
  800917:	eb 0f                	jmp    800928 <memcmp+0x35>
		s1++, s2++;
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091f:	39 f0                	cmp    %esi,%eax
  800921:	75 e2                	jne    800905 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800933:	89 c1                	mov    %eax,%ecx
  800935:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800938:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80093c:	eb 0a                	jmp    800948 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80093e:	0f b6 10             	movzbl (%eax),%edx
  800941:	39 da                	cmp    %ebx,%edx
  800943:	74 07                	je     80094c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	39 c8                	cmp    %ecx,%eax
  80094a:	72 f2                	jb     80093e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80094c:	5b                   	pop    %ebx
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	57                   	push   %edi
  800953:	56                   	push   %esi
  800954:	53                   	push   %ebx
  800955:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800958:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80095b:	eb 03                	jmp    800960 <strtol+0x11>
		s++;
  80095d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800960:	0f b6 01             	movzbl (%ecx),%eax
  800963:	3c 20                	cmp    $0x20,%al
  800965:	74 f6                	je     80095d <strtol+0xe>
  800967:	3c 09                	cmp    $0x9,%al
  800969:	74 f2                	je     80095d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80096b:	3c 2b                	cmp    $0x2b,%al
  80096d:	75 0a                	jne    800979 <strtol+0x2a>
		s++;
  80096f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800972:	bf 00 00 00 00       	mov    $0x0,%edi
  800977:	eb 11                	jmp    80098a <strtol+0x3b>
  800979:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80097e:	3c 2d                	cmp    $0x2d,%al
  800980:	75 08                	jne    80098a <strtol+0x3b>
		s++, neg = 1;
  800982:	83 c1 01             	add    $0x1,%ecx
  800985:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80098a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800990:	75 15                	jne    8009a7 <strtol+0x58>
  800992:	80 39 30             	cmpb   $0x30,(%ecx)
  800995:	75 10                	jne    8009a7 <strtol+0x58>
  800997:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80099b:	75 7c                	jne    800a19 <strtol+0xca>
		s += 2, base = 16;
  80099d:	83 c1 02             	add    $0x2,%ecx
  8009a0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009a5:	eb 16                	jmp    8009bd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009a7:	85 db                	test   %ebx,%ebx
  8009a9:	75 12                	jne    8009bd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ab:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009b0:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b3:	75 08                	jne    8009bd <strtol+0x6e>
		s++, base = 8;
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009c5:	0f b6 11             	movzbl (%ecx),%edx
  8009c8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	80 fb 09             	cmp    $0x9,%bl
  8009d0:	77 08                	ja     8009da <strtol+0x8b>
			dig = *s - '0';
  8009d2:	0f be d2             	movsbl %dl,%edx
  8009d5:	83 ea 30             	sub    $0x30,%edx
  8009d8:	eb 22                	jmp    8009fc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009da:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 19             	cmp    $0x19,%bl
  8009e2:	77 08                	ja     8009ec <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 57             	sub    $0x57,%edx
  8009ea:	eb 10                	jmp    8009fc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009ec:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 16                	ja     800a0c <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009fc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009ff:	7d 0b                	jge    800a0c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a01:	83 c1 01             	add    $0x1,%ecx
  800a04:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a08:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a0a:	eb b9                	jmp    8009c5 <strtol+0x76>

	if (endptr)
  800a0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a10:	74 0d                	je     800a1f <strtol+0xd0>
		*endptr = (char *) s;
  800a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a15:	89 0e                	mov    %ecx,(%esi)
  800a17:	eb 06                	jmp    800a1f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a19:	85 db                	test   %ebx,%ebx
  800a1b:	74 98                	je     8009b5 <strtol+0x66>
  800a1d:	eb 9e                	jmp    8009bd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a1f:	89 c2                	mov    %eax,%edx
  800a21:	f7 da                	neg    %edx
  800a23:	85 ff                	test   %edi,%edi
  800a25:	0f 45 c2             	cmovne %edx,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
  800a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3e:	89 c3                	mov    %eax,%ebx
  800a40:	89 c7                	mov    %eax,%edi
  800a42:	89 c6                	mov    %eax,%esi
  800a44:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a46:	5b                   	pop    %ebx
  800a47:	5e                   	pop    %esi
  800a48:	5f                   	pop    %edi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	57                   	push   %edi
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a51:	ba 00 00 00 00       	mov    $0x0,%edx
  800a56:	b8 01 00 00 00       	mov    $0x1,%eax
  800a5b:	89 d1                	mov    %edx,%ecx
  800a5d:	89 d3                	mov    %edx,%ebx
  800a5f:	89 d7                	mov    %edx,%edi
  800a61:	89 d6                	mov    %edx,%esi
  800a63:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a78:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a80:	89 cb                	mov    %ecx,%ebx
  800a82:	89 cf                	mov    %ecx,%edi
  800a84:	89 ce                	mov    %ecx,%esi
  800a86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	7e 17                	jle    800aa3 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a8c:	83 ec 0c             	sub    $0xc,%esp
  800a8f:	50                   	push   %eax
  800a90:	6a 03                	push   $0x3
  800a92:	68 bf 25 80 00       	push   $0x8025bf
  800a97:	6a 23                	push   $0x23
  800a99:	68 dc 25 80 00       	push   $0x8025dc
  800a9e:	e8 b3 13 00 00       	call   801e56 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	b8 02 00 00 00       	mov    $0x2,%eax
  800abb:	89 d1                	mov    %edx,%ecx
  800abd:	89 d3                	mov    %edx,%ebx
  800abf:	89 d7                	mov    %edx,%edi
  800ac1:	89 d6                	mov    %edx,%esi
  800ac3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <sys_yield>:

void
sys_yield(void)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ada:	89 d1                	mov    %edx,%ecx
  800adc:	89 d3                	mov    %edx,%ebx
  800ade:	89 d7                	mov    %edx,%edi
  800ae0:	89 d6                	mov    %edx,%esi
  800ae2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5f                   	pop    %edi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	57                   	push   %edi
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	be 00 00 00 00       	mov    $0x0,%esi
  800af7:	b8 04 00 00 00       	mov    $0x4,%eax
  800afc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aff:	8b 55 08             	mov    0x8(%ebp),%edx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b05:	89 f7                	mov    %esi,%edi
  800b07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	7e 17                	jle    800b24 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0d:	83 ec 0c             	sub    $0xc,%esp
  800b10:	50                   	push   %eax
  800b11:	6a 04                	push   $0x4
  800b13:	68 bf 25 80 00       	push   $0x8025bf
  800b18:	6a 23                	push   $0x23
  800b1a:	68 dc 25 80 00       	push   $0x8025dc
  800b1f:	e8 32 13 00 00       	call   801e56 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b35:	b8 05 00 00 00       	mov    $0x5,%eax
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b46:	8b 75 18             	mov    0x18(%ebp),%esi
  800b49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	7e 17                	jle    800b66 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	50                   	push   %eax
  800b53:	6a 05                	push   $0x5
  800b55:	68 bf 25 80 00       	push   $0x8025bf
  800b5a:	6a 23                	push   $0x23
  800b5c:	68 dc 25 80 00       	push   $0x8025dc
  800b61:	e8 f0 12 00 00       	call   801e56 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b7c:	b8 06 00 00 00       	mov    $0x6,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	89 df                	mov    %ebx,%edi
  800b89:	89 de                	mov    %ebx,%esi
  800b8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	7e 17                	jle    800ba8 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	50                   	push   %eax
  800b95:	6a 06                	push   $0x6
  800b97:	68 bf 25 80 00       	push   $0x8025bf
  800b9c:	6a 23                	push   $0x23
  800b9e:	68 dc 25 80 00       	push   $0x8025dc
  800ba3:	e8 ae 12 00 00       	call   801e56 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ba8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbe:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	89 df                	mov    %ebx,%edi
  800bcb:	89 de                	mov    %ebx,%esi
  800bcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 17                	jle    800bea <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 08                	push   $0x8
  800bd9:	68 bf 25 80 00       	push   $0x8025bf
  800bde:	6a 23                	push   $0x23
  800be0:	68 dc 25 80 00       	push   $0x8025dc
  800be5:	e8 6c 12 00 00       	call   801e56 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c00:	b8 09 00 00 00       	mov    $0x9,%eax
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0b:	89 df                	mov    %ebx,%edi
  800c0d:	89 de                	mov    %ebx,%esi
  800c0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 09                	push   $0x9
  800c1b:	68 bf 25 80 00       	push   $0x8025bf
  800c20:	6a 23                	push   $0x23
  800c22:	68 dc 25 80 00       	push   $0x8025dc
  800c27:	e8 2a 12 00 00       	call   801e56 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 17                	jle    800c6e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 0a                	push   $0xa
  800c5d:	68 bf 25 80 00       	push   $0x8025bf
  800c62:	6a 23                	push   $0x23
  800c64:	68 dc 25 80 00       	push   $0x8025dc
  800c69:	e8 e8 11 00 00       	call   801e56 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7c:	be 00 00 00 00       	mov    $0x0,%esi
  800c81:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c92:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800ca2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	89 cb                	mov    %ecx,%ebx
  800cb1:	89 cf                	mov    %ecx,%edi
  800cb3:	89 ce                	mov    %ecx,%esi
  800cb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 0d                	push   $0xd
  800cc1:	68 bf 25 80 00       	push   $0x8025bf
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 dc 25 80 00       	push   $0x8025dc
  800ccd:	e8 84 11 00 00       	call   801e56 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	05 00 00 00 30       	add    $0x30000000,%eax
  800d04:	c1 e8 0c             	shr    $0xc,%eax
}
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d14:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d19:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d26:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d2b:	89 c2                	mov    %eax,%edx
  800d2d:	c1 ea 16             	shr    $0x16,%edx
  800d30:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d37:	f6 c2 01             	test   $0x1,%dl
  800d3a:	74 11                	je     800d4d <fd_alloc+0x2d>
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	c1 ea 0c             	shr    $0xc,%edx
  800d41:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d48:	f6 c2 01             	test   $0x1,%dl
  800d4b:	75 09                	jne    800d56 <fd_alloc+0x36>
			*fd_store = fd;
  800d4d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d54:	eb 17                	jmp    800d6d <fd_alloc+0x4d>
  800d56:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d5b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d60:	75 c9                	jne    800d2b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d62:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d68:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d75:	83 f8 1f             	cmp    $0x1f,%eax
  800d78:	77 36                	ja     800db0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d7a:	c1 e0 0c             	shl    $0xc,%eax
  800d7d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	c1 ea 16             	shr    $0x16,%edx
  800d87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8e:	f6 c2 01             	test   $0x1,%dl
  800d91:	74 24                	je     800db7 <fd_lookup+0x48>
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	c1 ea 0c             	shr    $0xc,%edx
  800d98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9f:	f6 c2 01             	test   $0x1,%dl
  800da2:	74 1a                	je     800dbe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800da4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da7:	89 02                	mov    %eax,(%edx)
	return 0;
  800da9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dae:	eb 13                	jmp    800dc3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800db0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800db5:	eb 0c                	jmp    800dc3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800db7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dbc:	eb 05                	jmp    800dc3 <fd_lookup+0x54>
  800dbe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	83 ec 08             	sub    $0x8,%esp
  800dcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dce:	ba 68 26 80 00       	mov    $0x802668,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dd3:	eb 13                	jmp    800de8 <dev_lookup+0x23>
  800dd5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dd8:	39 08                	cmp    %ecx,(%eax)
  800dda:	75 0c                	jne    800de8 <dev_lookup+0x23>
			*dev = devtab[i];
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800de1:	b8 00 00 00 00       	mov    $0x0,%eax
  800de6:	eb 2e                	jmp    800e16 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800de8:	8b 02                	mov    (%edx),%eax
  800dea:	85 c0                	test   %eax,%eax
  800dec:	75 e7                	jne    800dd5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dee:	a1 08 40 80 00       	mov    0x804008,%eax
  800df3:	8b 40 48             	mov    0x48(%eax),%eax
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	51                   	push   %ecx
  800dfa:	50                   	push   %eax
  800dfb:	68 ec 25 80 00       	push   $0x8025ec
  800e00:	e8 3c f3 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e0e:	83 c4 10             	add    $0x10,%esp
  800e11:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e16:	c9                   	leave  
  800e17:	c3                   	ret    

00800e18 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
  800e1d:	83 ec 10             	sub    $0x10,%esp
  800e20:	8b 75 08             	mov    0x8(%ebp),%esi
  800e23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e26:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e29:	50                   	push   %eax
  800e2a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e30:	c1 e8 0c             	shr    $0xc,%eax
  800e33:	50                   	push   %eax
  800e34:	e8 36 ff ff ff       	call   800d6f <fd_lookup>
  800e39:	83 c4 08             	add    $0x8,%esp
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	78 05                	js     800e45 <fd_close+0x2d>
	    || fd != fd2)
  800e40:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e43:	74 0c                	je     800e51 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e45:	84 db                	test   %bl,%bl
  800e47:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4c:	0f 44 c2             	cmove  %edx,%eax
  800e4f:	eb 41                	jmp    800e92 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e57:	50                   	push   %eax
  800e58:	ff 36                	pushl  (%esi)
  800e5a:	e8 66 ff ff ff       	call   800dc5 <dev_lookup>
  800e5f:	89 c3                	mov    %eax,%ebx
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 1a                	js     800e82 <fd_close+0x6a>
		if (dev->dev_close)
  800e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e6e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	74 0b                	je     800e82 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	56                   	push   %esi
  800e7b:	ff d0                	call   *%eax
  800e7d:	89 c3                	mov    %eax,%ebx
  800e7f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	56                   	push   %esi
  800e86:	6a 00                	push   $0x0
  800e88:	e8 e1 fc ff ff       	call   800b6e <sys_page_unmap>
	return r;
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	89 d8                	mov    %ebx,%eax
}
  800e92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea2:	50                   	push   %eax
  800ea3:	ff 75 08             	pushl  0x8(%ebp)
  800ea6:	e8 c4 fe ff ff       	call   800d6f <fd_lookup>
  800eab:	83 c4 08             	add    $0x8,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	78 10                	js     800ec2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800eb2:	83 ec 08             	sub    $0x8,%esp
  800eb5:	6a 01                	push   $0x1
  800eb7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eba:	e8 59 ff ff ff       	call   800e18 <fd_close>
  800ebf:	83 c4 10             	add    $0x10,%esp
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <close_all>:

void
close_all(void)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ecb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	53                   	push   %ebx
  800ed4:	e8 c0 ff ff ff       	call   800e99 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed9:	83 c3 01             	add    $0x1,%ebx
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	83 fb 20             	cmp    $0x20,%ebx
  800ee2:	75 ec                	jne    800ed0 <close_all+0xc>
		close(i);
}
  800ee4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    

00800ee9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 2c             	sub    $0x2c,%esp
  800ef2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ef5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ef8:	50                   	push   %eax
  800ef9:	ff 75 08             	pushl  0x8(%ebp)
  800efc:	e8 6e fe ff ff       	call   800d6f <fd_lookup>
  800f01:	83 c4 08             	add    $0x8,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	0f 88 c1 00 00 00    	js     800fcd <dup+0xe4>
		return r;
	close(newfdnum);
  800f0c:	83 ec 0c             	sub    $0xc,%esp
  800f0f:	56                   	push   %esi
  800f10:	e8 84 ff ff ff       	call   800e99 <close>

	newfd = INDEX2FD(newfdnum);
  800f15:	89 f3                	mov    %esi,%ebx
  800f17:	c1 e3 0c             	shl    $0xc,%ebx
  800f1a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f20:	83 c4 04             	add    $0x4,%esp
  800f23:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f26:	e8 de fd ff ff       	call   800d09 <fd2data>
  800f2b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f2d:	89 1c 24             	mov    %ebx,(%esp)
  800f30:	e8 d4 fd ff ff       	call   800d09 <fd2data>
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f3b:	89 f8                	mov    %edi,%eax
  800f3d:	c1 e8 16             	shr    $0x16,%eax
  800f40:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f47:	a8 01                	test   $0x1,%al
  800f49:	74 37                	je     800f82 <dup+0x99>
  800f4b:	89 f8                	mov    %edi,%eax
  800f4d:	c1 e8 0c             	shr    $0xc,%eax
  800f50:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f57:	f6 c2 01             	test   $0x1,%dl
  800f5a:	74 26                	je     800f82 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f5c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	25 07 0e 00 00       	and    $0xe07,%eax
  800f6b:	50                   	push   %eax
  800f6c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f6f:	6a 00                	push   $0x0
  800f71:	57                   	push   %edi
  800f72:	6a 00                	push   $0x0
  800f74:	e8 b3 fb ff ff       	call   800b2c <sys_page_map>
  800f79:	89 c7                	mov    %eax,%edi
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 2e                	js     800fb0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f85:	89 d0                	mov    %edx,%eax
  800f87:	c1 e8 0c             	shr    $0xc,%eax
  800f8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	25 07 0e 00 00       	and    $0xe07,%eax
  800f99:	50                   	push   %eax
  800f9a:	53                   	push   %ebx
  800f9b:	6a 00                	push   $0x0
  800f9d:	52                   	push   %edx
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 87 fb ff ff       	call   800b2c <sys_page_map>
  800fa5:	89 c7                	mov    %eax,%edi
  800fa7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800faa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fac:	85 ff                	test   %edi,%edi
  800fae:	79 1d                	jns    800fcd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	53                   	push   %ebx
  800fb4:	6a 00                	push   $0x0
  800fb6:	e8 b3 fb ff ff       	call   800b6e <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fbb:	83 c4 08             	add    $0x8,%esp
  800fbe:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc1:	6a 00                	push   $0x0
  800fc3:	e8 a6 fb ff ff       	call   800b6e <sys_page_unmap>
	return r;
  800fc8:	83 c4 10             	add    $0x10,%esp
  800fcb:	89 f8                	mov    %edi,%eax
}
  800fcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    

00800fd5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 14             	sub    $0x14,%esp
  800fdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fdf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe2:	50                   	push   %eax
  800fe3:	53                   	push   %ebx
  800fe4:	e8 86 fd ff ff       	call   800d6f <fd_lookup>
  800fe9:	83 c4 08             	add    $0x8,%esp
  800fec:	89 c2                	mov    %eax,%edx
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 6d                	js     80105f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff8:	50                   	push   %eax
  800ff9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffc:	ff 30                	pushl  (%eax)
  800ffe:	e8 c2 fd ff ff       	call   800dc5 <dev_lookup>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 4c                	js     801056 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80100a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80100d:	8b 42 08             	mov    0x8(%edx),%eax
  801010:	83 e0 03             	and    $0x3,%eax
  801013:	83 f8 01             	cmp    $0x1,%eax
  801016:	75 21                	jne    801039 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801018:	a1 08 40 80 00       	mov    0x804008,%eax
  80101d:	8b 40 48             	mov    0x48(%eax),%eax
  801020:	83 ec 04             	sub    $0x4,%esp
  801023:	53                   	push   %ebx
  801024:	50                   	push   %eax
  801025:	68 2d 26 80 00       	push   $0x80262d
  80102a:	e8 12 f1 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801037:	eb 26                	jmp    80105f <read+0x8a>
	}
	if (!dev->dev_read)
  801039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103c:	8b 40 08             	mov    0x8(%eax),%eax
  80103f:	85 c0                	test   %eax,%eax
  801041:	74 17                	je     80105a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	ff 75 10             	pushl  0x10(%ebp)
  801049:	ff 75 0c             	pushl  0xc(%ebp)
  80104c:	52                   	push   %edx
  80104d:	ff d0                	call   *%eax
  80104f:	89 c2                	mov    %eax,%edx
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	eb 09                	jmp    80105f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801056:	89 c2                	mov    %eax,%edx
  801058:	eb 05                	jmp    80105f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80105a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80105f:	89 d0                	mov    %edx,%eax
  801061:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801064:	c9                   	leave  
  801065:	c3                   	ret    

00801066 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	57                   	push   %edi
  80106a:	56                   	push   %esi
  80106b:	53                   	push   %ebx
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801072:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801075:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107a:	eb 21                	jmp    80109d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80107c:	83 ec 04             	sub    $0x4,%esp
  80107f:	89 f0                	mov    %esi,%eax
  801081:	29 d8                	sub    %ebx,%eax
  801083:	50                   	push   %eax
  801084:	89 d8                	mov    %ebx,%eax
  801086:	03 45 0c             	add    0xc(%ebp),%eax
  801089:	50                   	push   %eax
  80108a:	57                   	push   %edi
  80108b:	e8 45 ff ff ff       	call   800fd5 <read>
		if (m < 0)
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 10                	js     8010a7 <readn+0x41>
			return m;
		if (m == 0)
  801097:	85 c0                	test   %eax,%eax
  801099:	74 0a                	je     8010a5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80109b:	01 c3                	add    %eax,%ebx
  80109d:	39 f3                	cmp    %esi,%ebx
  80109f:	72 db                	jb     80107c <readn+0x16>
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	eb 02                	jmp    8010a7 <readn+0x41>
  8010a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 14             	sub    $0x14,%esp
  8010b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bc:	50                   	push   %eax
  8010bd:	53                   	push   %ebx
  8010be:	e8 ac fc ff ff       	call   800d6f <fd_lookup>
  8010c3:	83 c4 08             	add    $0x8,%esp
  8010c6:	89 c2                	mov    %eax,%edx
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	78 68                	js     801134 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d2:	50                   	push   %eax
  8010d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d6:	ff 30                	pushl  (%eax)
  8010d8:	e8 e8 fc ff ff       	call   800dc5 <dev_lookup>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 47                	js     80112b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010eb:	75 21                	jne    80110e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ed:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f2:	8b 40 48             	mov    0x48(%eax),%eax
  8010f5:	83 ec 04             	sub    $0x4,%esp
  8010f8:	53                   	push   %ebx
  8010f9:	50                   	push   %eax
  8010fa:	68 49 26 80 00       	push   $0x802649
  8010ff:	e8 3d f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80110c:	eb 26                	jmp    801134 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80110e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801111:	8b 52 0c             	mov    0xc(%edx),%edx
  801114:	85 d2                	test   %edx,%edx
  801116:	74 17                	je     80112f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801118:	83 ec 04             	sub    $0x4,%esp
  80111b:	ff 75 10             	pushl  0x10(%ebp)
  80111e:	ff 75 0c             	pushl  0xc(%ebp)
  801121:	50                   	push   %eax
  801122:	ff d2                	call   *%edx
  801124:	89 c2                	mov    %eax,%edx
  801126:	83 c4 10             	add    $0x10,%esp
  801129:	eb 09                	jmp    801134 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	eb 05                	jmp    801134 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80112f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801134:	89 d0                	mov    %edx,%eax
  801136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <seek>:

int
seek(int fdnum, off_t offset)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801141:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801144:	50                   	push   %eax
  801145:	ff 75 08             	pushl  0x8(%ebp)
  801148:	e8 22 fc ff ff       	call   800d6f <fd_lookup>
  80114d:	83 c4 08             	add    $0x8,%esp
  801150:	85 c0                	test   %eax,%eax
  801152:	78 0e                	js     801162 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801154:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801162:	c9                   	leave  
  801163:	c3                   	ret    

00801164 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	53                   	push   %ebx
  801168:	83 ec 14             	sub    $0x14,%esp
  80116b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801171:	50                   	push   %eax
  801172:	53                   	push   %ebx
  801173:	e8 f7 fb ff ff       	call   800d6f <fd_lookup>
  801178:	83 c4 08             	add    $0x8,%esp
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	85 c0                	test   %eax,%eax
  80117f:	78 65                	js     8011e6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801181:	83 ec 08             	sub    $0x8,%esp
  801184:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801187:	50                   	push   %eax
  801188:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118b:	ff 30                	pushl  (%eax)
  80118d:	e8 33 fc ff ff       	call   800dc5 <dev_lookup>
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	85 c0                	test   %eax,%eax
  801197:	78 44                	js     8011dd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801199:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011a0:	75 21                	jne    8011c3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011a2:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011a7:	8b 40 48             	mov    0x48(%eax),%eax
  8011aa:	83 ec 04             	sub    $0x4,%esp
  8011ad:	53                   	push   %ebx
  8011ae:	50                   	push   %eax
  8011af:	68 0c 26 80 00       	push   $0x80260c
  8011b4:	e8 88 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c1:	eb 23                	jmp    8011e6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c6:	8b 52 18             	mov    0x18(%edx),%edx
  8011c9:	85 d2                	test   %edx,%edx
  8011cb:	74 14                	je     8011e1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	ff 75 0c             	pushl  0xc(%ebp)
  8011d3:	50                   	push   %eax
  8011d4:	ff d2                	call   *%edx
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	eb 09                	jmp    8011e6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011dd:	89 c2                	mov    %eax,%edx
  8011df:	eb 05                	jmp    8011e6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011e6:	89 d0                	mov    %edx,%eax
  8011e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011eb:	c9                   	leave  
  8011ec:	c3                   	ret    

008011ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	53                   	push   %ebx
  8011f1:	83 ec 14             	sub    $0x14,%esp
  8011f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	ff 75 08             	pushl  0x8(%ebp)
  8011fe:	e8 6c fb ff ff       	call   800d6f <fd_lookup>
  801203:	83 c4 08             	add    $0x8,%esp
  801206:	89 c2                	mov    %eax,%edx
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 58                	js     801264 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120c:	83 ec 08             	sub    $0x8,%esp
  80120f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801216:	ff 30                	pushl  (%eax)
  801218:	e8 a8 fb ff ff       	call   800dc5 <dev_lookup>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	78 37                	js     80125b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801224:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801227:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80122b:	74 32                	je     80125f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80122d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801230:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801237:	00 00 00 
	stat->st_isdir = 0;
  80123a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801241:	00 00 00 
	stat->st_dev = dev;
  801244:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80124a:	83 ec 08             	sub    $0x8,%esp
  80124d:	53                   	push   %ebx
  80124e:	ff 75 f0             	pushl  -0x10(%ebp)
  801251:	ff 50 14             	call   *0x14(%eax)
  801254:	89 c2                	mov    %eax,%edx
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	eb 09                	jmp    801264 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	eb 05                	jmp    801264 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80125f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801264:	89 d0                	mov    %edx,%eax
  801266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	56                   	push   %esi
  80126f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801270:	83 ec 08             	sub    $0x8,%esp
  801273:	6a 00                	push   $0x0
  801275:	ff 75 08             	pushl  0x8(%ebp)
  801278:	e8 ef 01 00 00       	call   80146c <open>
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 1b                	js     8012a1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	ff 75 0c             	pushl  0xc(%ebp)
  80128c:	50                   	push   %eax
  80128d:	e8 5b ff ff ff       	call   8011ed <fstat>
  801292:	89 c6                	mov    %eax,%esi
	close(fd);
  801294:	89 1c 24             	mov    %ebx,(%esp)
  801297:	e8 fd fb ff ff       	call   800e99 <close>
	return r;
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	89 f0                	mov    %esi,%eax
}
  8012a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a4:	5b                   	pop    %ebx
  8012a5:	5e                   	pop    %esi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	56                   	push   %esi
  8012ac:	53                   	push   %ebx
  8012ad:	89 c6                	mov    %eax,%esi
  8012af:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012b1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012b8:	75 12                	jne    8012cc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012ba:	83 ec 0c             	sub    $0xc,%esp
  8012bd:	6a 01                	push   $0x1
  8012bf:	e8 9d 0c 00 00       	call   801f61 <ipc_find_env>
  8012c4:	a3 00 40 80 00       	mov    %eax,0x804000
  8012c9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012cc:	6a 07                	push   $0x7
  8012ce:	68 00 50 80 00       	push   $0x805000
  8012d3:	56                   	push   %esi
  8012d4:	ff 35 00 40 80 00    	pushl  0x804000
  8012da:	e8 33 0c 00 00       	call   801f12 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012df:	83 c4 0c             	add    $0xc,%esp
  8012e2:	6a 00                	push   $0x0
  8012e4:	53                   	push   %ebx
  8012e5:	6a 00                	push   $0x0
  8012e7:	e8 b0 0b 00 00       	call   801e9c <ipc_recv>
}
  8012ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ef:	5b                   	pop    %ebx
  8012f0:	5e                   	pop    %esi
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ff:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801304:	8b 45 0c             	mov    0xc(%ebp),%eax
  801307:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80130c:	ba 00 00 00 00       	mov    $0x0,%edx
  801311:	b8 02 00 00 00       	mov    $0x2,%eax
  801316:	e8 8d ff ff ff       	call   8012a8 <fsipc>
}
  80131b:	c9                   	leave  
  80131c:	c3                   	ret    

0080131d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801323:	8b 45 08             	mov    0x8(%ebp),%eax
  801326:	8b 40 0c             	mov    0xc(%eax),%eax
  801329:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80132e:	ba 00 00 00 00       	mov    $0x0,%edx
  801333:	b8 06 00 00 00       	mov    $0x6,%eax
  801338:	e8 6b ff ff ff       	call   8012a8 <fsipc>
}
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	53                   	push   %ebx
  801343:	83 ec 04             	sub    $0x4,%esp
  801346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801349:	8b 45 08             	mov    0x8(%ebp),%eax
  80134c:	8b 40 0c             	mov    0xc(%eax),%eax
  80134f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801354:	ba 00 00 00 00       	mov    $0x0,%edx
  801359:	b8 05 00 00 00       	mov    $0x5,%eax
  80135e:	e8 45 ff ff ff       	call   8012a8 <fsipc>
  801363:	85 c0                	test   %eax,%eax
  801365:	78 2c                	js     801393 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	68 00 50 80 00       	push   $0x805000
  80136f:	53                   	push   %ebx
  801370:	e8 71 f3 ff ff       	call   8006e6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801375:	a1 80 50 80 00       	mov    0x805080,%eax
  80137a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801380:	a1 84 50 80 00       	mov    0x805084,%eax
  801385:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801393:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 08             	sub    $0x8,%esp
  80139f:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013ae:	a3 04 50 80 00       	mov    %eax,0x805004
  8013b3:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8013b8:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8013bd:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013c0:	53                   	push   %ebx
  8013c1:	ff 75 0c             	pushl  0xc(%ebp)
  8013c4:	68 08 50 80 00       	push   $0x805008
  8013c9:	e8 aa f4 ff ff       	call   800878 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8013ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d3:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d8:	e8 cb fe ff ff       	call   8012a8 <fsipc>
  8013dd:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8013e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	56                   	push   %esi
  8013ee:	53                   	push   %ebx
  8013ef:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013fd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801403:	ba 00 00 00 00       	mov    $0x0,%edx
  801408:	b8 03 00 00 00       	mov    $0x3,%eax
  80140d:	e8 96 fe ff ff       	call   8012a8 <fsipc>
  801412:	89 c3                	mov    %eax,%ebx
  801414:	85 c0                	test   %eax,%eax
  801416:	78 4b                	js     801463 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801418:	39 c6                	cmp    %eax,%esi
  80141a:	73 16                	jae    801432 <devfile_read+0x48>
  80141c:	68 7c 26 80 00       	push   $0x80267c
  801421:	68 83 26 80 00       	push   $0x802683
  801426:	6a 7c                	push   $0x7c
  801428:	68 98 26 80 00       	push   $0x802698
  80142d:	e8 24 0a 00 00       	call   801e56 <_panic>
	assert(r <= PGSIZE);
  801432:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801437:	7e 16                	jle    80144f <devfile_read+0x65>
  801439:	68 a3 26 80 00       	push   $0x8026a3
  80143e:	68 83 26 80 00       	push   $0x802683
  801443:	6a 7d                	push   $0x7d
  801445:	68 98 26 80 00       	push   $0x802698
  80144a:	e8 07 0a 00 00       	call   801e56 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	50                   	push   %eax
  801453:	68 00 50 80 00       	push   $0x805000
  801458:	ff 75 0c             	pushl  0xc(%ebp)
  80145b:	e8 18 f4 ff ff       	call   800878 <memmove>
	return r;
  801460:	83 c4 10             	add    $0x10,%esp
}
  801463:	89 d8                	mov    %ebx,%eax
  801465:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 20             	sub    $0x20,%esp
  801473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801476:	53                   	push   %ebx
  801477:	e8 31 f2 ff ff       	call   8006ad <strlen>
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801484:	7f 67                	jg     8014ed <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801486:	83 ec 0c             	sub    $0xc,%esp
  801489:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	e8 8e f8 ff ff       	call   800d20 <fd_alloc>
  801492:	83 c4 10             	add    $0x10,%esp
		return r;
  801495:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801497:	85 c0                	test   %eax,%eax
  801499:	78 57                	js     8014f2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	53                   	push   %ebx
  80149f:	68 00 50 80 00       	push   $0x805000
  8014a4:	e8 3d f2 ff ff       	call   8006e6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ac:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b9:	e8 ea fd ff ff       	call   8012a8 <fsipc>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	79 14                	jns    8014db <open+0x6f>
		fd_close(fd, 0);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	6a 00                	push   $0x0
  8014cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cf:	e8 44 f9 ff ff       	call   800e18 <fd_close>
		return r;
  8014d4:	83 c4 10             	add    $0x10,%esp
  8014d7:	89 da                	mov    %ebx,%edx
  8014d9:	eb 17                	jmp    8014f2 <open+0x86>
	}

	return fd2num(fd);
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e1:	e8 13 f8 ff ff       	call   800cf9 <fd2num>
  8014e6:	89 c2                	mov    %eax,%edx
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	eb 05                	jmp    8014f2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014ed:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8014f2:	89 d0                	mov    %edx,%eax
  8014f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801504:	b8 08 00 00 00       	mov    $0x8,%eax
  801509:	e8 9a fd ff ff       	call   8012a8 <fsipc>
}
  80150e:	c9                   	leave  
  80150f:	c3                   	ret    

00801510 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	56                   	push   %esi
  801514:	53                   	push   %ebx
  801515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	ff 75 08             	pushl  0x8(%ebp)
  80151e:	e8 e6 f7 ff ff       	call   800d09 <fd2data>
  801523:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801525:	83 c4 08             	add    $0x8,%esp
  801528:	68 af 26 80 00       	push   $0x8026af
  80152d:	53                   	push   %ebx
  80152e:	e8 b3 f1 ff ff       	call   8006e6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801533:	8b 46 04             	mov    0x4(%esi),%eax
  801536:	2b 06                	sub    (%esi),%eax
  801538:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80153e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801545:	00 00 00 
	stat->st_dev = &devpipe;
  801548:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80154f:	30 80 00 
	return 0;
}
  801552:	b8 00 00 00 00       	mov    $0x0,%eax
  801557:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	53                   	push   %ebx
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801568:	53                   	push   %ebx
  801569:	6a 00                	push   $0x0
  80156b:	e8 fe f5 ff ff       	call   800b6e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801570:	89 1c 24             	mov    %ebx,(%esp)
  801573:	e8 91 f7 ff ff       	call   800d09 <fd2data>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	50                   	push   %eax
  80157c:	6a 00                	push   $0x0
  80157e:	e8 eb f5 ff ff       	call   800b6e <sys_page_unmap>
}
  801583:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801586:	c9                   	leave  
  801587:	c3                   	ret    

00801588 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	57                   	push   %edi
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	83 ec 1c             	sub    $0x1c,%esp
  801591:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801594:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801596:	a1 08 40 80 00       	mov    0x804008,%eax
  80159b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80159e:	83 ec 0c             	sub    $0xc,%esp
  8015a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a4:	e8 f1 09 00 00       	call   801f9a <pageref>
  8015a9:	89 c3                	mov    %eax,%ebx
  8015ab:	89 3c 24             	mov    %edi,(%esp)
  8015ae:	e8 e7 09 00 00       	call   801f9a <pageref>
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	39 c3                	cmp    %eax,%ebx
  8015b8:	0f 94 c1             	sete   %cl
  8015bb:	0f b6 c9             	movzbl %cl,%ecx
  8015be:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015c1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015c7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015ca:	39 ce                	cmp    %ecx,%esi
  8015cc:	74 1b                	je     8015e9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015ce:	39 c3                	cmp    %eax,%ebx
  8015d0:	75 c4                	jne    801596 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015d2:	8b 42 58             	mov    0x58(%edx),%eax
  8015d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d8:	50                   	push   %eax
  8015d9:	56                   	push   %esi
  8015da:	68 b6 26 80 00       	push   $0x8026b6
  8015df:	e8 5d eb ff ff       	call   800141 <cprintf>
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	eb ad                	jmp    801596 <_pipeisclosed+0xe>
	}
}
  8015e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	57                   	push   %edi
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 28             	sub    $0x28,%esp
  8015fd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801600:	56                   	push   %esi
  801601:	e8 03 f7 ff ff       	call   800d09 <fd2data>
  801606:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	bf 00 00 00 00       	mov    $0x0,%edi
  801610:	eb 4b                	jmp    80165d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801612:	89 da                	mov    %ebx,%edx
  801614:	89 f0                	mov    %esi,%eax
  801616:	e8 6d ff ff ff       	call   801588 <_pipeisclosed>
  80161b:	85 c0                	test   %eax,%eax
  80161d:	75 48                	jne    801667 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80161f:	e8 a6 f4 ff ff       	call   800aca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801624:	8b 43 04             	mov    0x4(%ebx),%eax
  801627:	8b 0b                	mov    (%ebx),%ecx
  801629:	8d 51 20             	lea    0x20(%ecx),%edx
  80162c:	39 d0                	cmp    %edx,%eax
  80162e:	73 e2                	jae    801612 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801630:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801633:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801637:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	c1 fa 1f             	sar    $0x1f,%edx
  80163f:	89 d1                	mov    %edx,%ecx
  801641:	c1 e9 1b             	shr    $0x1b,%ecx
  801644:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801647:	83 e2 1f             	and    $0x1f,%edx
  80164a:	29 ca                	sub    %ecx,%edx
  80164c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801650:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801654:	83 c0 01             	add    $0x1,%eax
  801657:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165a:	83 c7 01             	add    $0x1,%edi
  80165d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801660:	75 c2                	jne    801624 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801662:	8b 45 10             	mov    0x10(%ebp),%eax
  801665:	eb 05                	jmp    80166c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801667:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80166c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5f                   	pop    %edi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	57                   	push   %edi
  801678:	56                   	push   %esi
  801679:	53                   	push   %ebx
  80167a:	83 ec 18             	sub    $0x18,%esp
  80167d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801680:	57                   	push   %edi
  801681:	e8 83 f6 ff ff       	call   800d09 <fd2data>
  801686:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801690:	eb 3d                	jmp    8016cf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801692:	85 db                	test   %ebx,%ebx
  801694:	74 04                	je     80169a <devpipe_read+0x26>
				return i;
  801696:	89 d8                	mov    %ebx,%eax
  801698:	eb 44                	jmp    8016de <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80169a:	89 f2                	mov    %esi,%edx
  80169c:	89 f8                	mov    %edi,%eax
  80169e:	e8 e5 fe ff ff       	call   801588 <_pipeisclosed>
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	75 32                	jne    8016d9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016a7:	e8 1e f4 ff ff       	call   800aca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016ac:	8b 06                	mov    (%esi),%eax
  8016ae:	3b 46 04             	cmp    0x4(%esi),%eax
  8016b1:	74 df                	je     801692 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016b3:	99                   	cltd   
  8016b4:	c1 ea 1b             	shr    $0x1b,%edx
  8016b7:	01 d0                	add    %edx,%eax
  8016b9:	83 e0 1f             	and    $0x1f,%eax
  8016bc:	29 d0                	sub    %edx,%eax
  8016be:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016c9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016cc:	83 c3 01             	add    $0x1,%ebx
  8016cf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016d2:	75 d8                	jne    8016ac <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016d7:	eb 05                	jmp    8016de <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e1:	5b                   	pop    %ebx
  8016e2:	5e                   	pop    %esi
  8016e3:	5f                   	pop    %edi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	56                   	push   %esi
  8016ea:	53                   	push   %ebx
  8016eb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f1:	50                   	push   %eax
  8016f2:	e8 29 f6 ff ff       	call   800d20 <fd_alloc>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	0f 88 2c 01 00 00    	js     801830 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801704:	83 ec 04             	sub    $0x4,%esp
  801707:	68 07 04 00 00       	push   $0x407
  80170c:	ff 75 f4             	pushl  -0xc(%ebp)
  80170f:	6a 00                	push   $0x0
  801711:	e8 d3 f3 ff ff       	call   800ae9 <sys_page_alloc>
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	89 c2                	mov    %eax,%edx
  80171b:	85 c0                	test   %eax,%eax
  80171d:	0f 88 0d 01 00 00    	js     801830 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801729:	50                   	push   %eax
  80172a:	e8 f1 f5 ff ff       	call   800d20 <fd_alloc>
  80172f:	89 c3                	mov    %eax,%ebx
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	85 c0                	test   %eax,%eax
  801736:	0f 88 e2 00 00 00    	js     80181e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173c:	83 ec 04             	sub    $0x4,%esp
  80173f:	68 07 04 00 00       	push   $0x407
  801744:	ff 75 f0             	pushl  -0x10(%ebp)
  801747:	6a 00                	push   $0x0
  801749:	e8 9b f3 ff ff       	call   800ae9 <sys_page_alloc>
  80174e:	89 c3                	mov    %eax,%ebx
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	0f 88 c3 00 00 00    	js     80181e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80175b:	83 ec 0c             	sub    $0xc,%esp
  80175e:	ff 75 f4             	pushl  -0xc(%ebp)
  801761:	e8 a3 f5 ff ff       	call   800d09 <fd2data>
  801766:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801768:	83 c4 0c             	add    $0xc,%esp
  80176b:	68 07 04 00 00       	push   $0x407
  801770:	50                   	push   %eax
  801771:	6a 00                	push   $0x0
  801773:	e8 71 f3 ff ff       	call   800ae9 <sys_page_alloc>
  801778:	89 c3                	mov    %eax,%ebx
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	0f 88 89 00 00 00    	js     80180e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801785:	83 ec 0c             	sub    $0xc,%esp
  801788:	ff 75 f0             	pushl  -0x10(%ebp)
  80178b:	e8 79 f5 ff ff       	call   800d09 <fd2data>
  801790:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801797:	50                   	push   %eax
  801798:	6a 00                	push   $0x0
  80179a:	56                   	push   %esi
  80179b:	6a 00                	push   $0x0
  80179d:	e8 8a f3 ff ff       	call   800b2c <sys_page_map>
  8017a2:	89 c3                	mov    %eax,%ebx
  8017a4:	83 c4 20             	add    $0x20,%esp
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 55                	js     801800 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017ab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017c0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017d5:	83 ec 0c             	sub    $0xc,%esp
  8017d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017db:	e8 19 f5 ff ff       	call   800cf9 <fd2num>
  8017e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017e5:	83 c4 04             	add    $0x4,%esp
  8017e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8017eb:	e8 09 f5 ff ff       	call   800cf9 <fd2num>
  8017f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fe:	eb 30                	jmp    801830 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	56                   	push   %esi
  801804:	6a 00                	push   $0x0
  801806:	e8 63 f3 ff ff       	call   800b6e <sys_page_unmap>
  80180b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	ff 75 f0             	pushl  -0x10(%ebp)
  801814:	6a 00                	push   $0x0
  801816:	e8 53 f3 ff ff       	call   800b6e <sys_page_unmap>
  80181b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	ff 75 f4             	pushl  -0xc(%ebp)
  801824:	6a 00                	push   $0x0
  801826:	e8 43 f3 ff ff       	call   800b6e <sys_page_unmap>
  80182b:	83 c4 10             	add    $0x10,%esp
  80182e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801830:	89 d0                	mov    %edx,%eax
  801832:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801835:	5b                   	pop    %ebx
  801836:	5e                   	pop    %esi
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	50                   	push   %eax
  801843:	ff 75 08             	pushl  0x8(%ebp)
  801846:	e8 24 f5 ff ff       	call   800d6f <fd_lookup>
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 18                	js     80186a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	ff 75 f4             	pushl  -0xc(%ebp)
  801858:	e8 ac f4 ff ff       	call   800d09 <fd2data>
	return _pipeisclosed(fd, p);
  80185d:	89 c2                	mov    %eax,%edx
  80185f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801862:	e8 21 fd ff ff       	call   801588 <_pipeisclosed>
  801867:	83 c4 10             	add    $0x10,%esp
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801872:	68 ce 26 80 00       	push   $0x8026ce
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	e8 67 ee ff ff       	call   8006e6 <strcpy>
	return 0;
}
  80187f:	b8 00 00 00 00       	mov    $0x0,%eax
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	53                   	push   %ebx
  80188a:	83 ec 10             	sub    $0x10,%esp
  80188d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801890:	53                   	push   %ebx
  801891:	e8 04 07 00 00       	call   801f9a <pageref>
  801896:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80189e:	83 f8 01             	cmp    $0x1,%eax
  8018a1:	75 10                	jne    8018b3 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	ff 73 0c             	pushl  0xc(%ebx)
  8018a9:	e8 c0 02 00 00       	call   801b6e <nsipc_close>
  8018ae:	89 c2                	mov    %eax,%edx
  8018b0:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018b3:	89 d0                	mov    %edx,%eax
  8018b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b8:	c9                   	leave  
  8018b9:	c3                   	ret    

008018ba <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018c0:	6a 00                	push   $0x0
  8018c2:	ff 75 10             	pushl  0x10(%ebp)
  8018c5:	ff 75 0c             	pushl  0xc(%ebp)
  8018c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cb:	ff 70 0c             	pushl  0xc(%eax)
  8018ce:	e8 78 03 00 00       	call   801c4b <nsipc_send>
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018db:	6a 00                	push   $0x0
  8018dd:	ff 75 10             	pushl  0x10(%ebp)
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	ff 70 0c             	pushl  0xc(%eax)
  8018e9:	e8 f1 02 00 00       	call   801bdf <nsipc_recv>
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018f6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018f9:	52                   	push   %edx
  8018fa:	50                   	push   %eax
  8018fb:	e8 6f f4 ff ff       	call   800d6f <fd_lookup>
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	78 17                	js     80191e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801907:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190a:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801910:	39 08                	cmp    %ecx,(%eax)
  801912:	75 05                	jne    801919 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801914:	8b 40 0c             	mov    0xc(%eax),%eax
  801917:	eb 05                	jmp    80191e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 1c             	sub    $0x1c,%esp
  801928:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80192a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192d:	50                   	push   %eax
  80192e:	e8 ed f3 ff ff       	call   800d20 <fd_alloc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 1b                	js     801957 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80193c:	83 ec 04             	sub    $0x4,%esp
  80193f:	68 07 04 00 00       	push   $0x407
  801944:	ff 75 f4             	pushl  -0xc(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 9b f1 ff ff       	call   800ae9 <sys_page_alloc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	85 c0                	test   %eax,%eax
  801955:	79 10                	jns    801967 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801957:	83 ec 0c             	sub    $0xc,%esp
  80195a:	56                   	push   %esi
  80195b:	e8 0e 02 00 00       	call   801b6e <nsipc_close>
		return r;
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	89 d8                	mov    %ebx,%eax
  801965:	eb 24                	jmp    80198b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801967:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801970:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801972:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801975:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80197c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	50                   	push   %eax
  801983:	e8 71 f3 ff ff       	call   800cf9 <fd2num>
  801988:	83 c4 10             	add    $0x10,%esp
}
  80198b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198e:	5b                   	pop    %ebx
  80198f:	5e                   	pop    %esi
  801990:	5d                   	pop    %ebp
  801991:	c3                   	ret    

00801992 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801998:	8b 45 08             	mov    0x8(%ebp),%eax
  80199b:	e8 50 ff ff ff       	call   8018f0 <fd2sockid>
		return r;
  8019a0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 1f                	js     8019c5 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	ff 75 10             	pushl  0x10(%ebp)
  8019ac:	ff 75 0c             	pushl  0xc(%ebp)
  8019af:	50                   	push   %eax
  8019b0:	e8 12 01 00 00       	call   801ac7 <nsipc_accept>
  8019b5:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b8:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019ba:	85 c0                	test   %eax,%eax
  8019bc:	78 07                	js     8019c5 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019be:	e8 5d ff ff ff       	call   801920 <alloc_sockfd>
  8019c3:	89 c1                	mov    %eax,%ecx
}
  8019c5:	89 c8                	mov    %ecx,%eax
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d2:	e8 19 ff ff ff       	call   8018f0 <fd2sockid>
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 12                	js     8019ed <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	ff 75 10             	pushl  0x10(%ebp)
  8019e1:	ff 75 0c             	pushl  0xc(%ebp)
  8019e4:	50                   	push   %eax
  8019e5:	e8 2d 01 00 00       	call   801b17 <nsipc_bind>
  8019ea:	83 c4 10             	add    $0x10,%esp
}
  8019ed:	c9                   	leave  
  8019ee:	c3                   	ret    

008019ef <shutdown>:

int
shutdown(int s, int how)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f8:	e8 f3 fe ff ff       	call   8018f0 <fd2sockid>
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 0f                	js     801a10 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a01:	83 ec 08             	sub    $0x8,%esp
  801a04:	ff 75 0c             	pushl  0xc(%ebp)
  801a07:	50                   	push   %eax
  801a08:	e8 3f 01 00 00       	call   801b4c <nsipc_shutdown>
  801a0d:	83 c4 10             	add    $0x10,%esp
}
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    

00801a12 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a18:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1b:	e8 d0 fe ff ff       	call   8018f0 <fd2sockid>
  801a20:	85 c0                	test   %eax,%eax
  801a22:	78 12                	js     801a36 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	ff 75 10             	pushl  0x10(%ebp)
  801a2a:	ff 75 0c             	pushl  0xc(%ebp)
  801a2d:	50                   	push   %eax
  801a2e:	e8 55 01 00 00       	call   801b88 <nsipc_connect>
  801a33:	83 c4 10             	add    $0x10,%esp
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <listen>:

int
listen(int s, int backlog)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a41:	e8 aa fe ff ff       	call   8018f0 <fd2sockid>
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 0f                	js     801a59 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	50                   	push   %eax
  801a51:	e8 67 01 00 00       	call   801bbd <nsipc_listen>
  801a56:	83 c4 10             	add    $0x10,%esp
}
  801a59:	c9                   	leave  
  801a5a:	c3                   	ret    

00801a5b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a61:	ff 75 10             	pushl  0x10(%ebp)
  801a64:	ff 75 0c             	pushl  0xc(%ebp)
  801a67:	ff 75 08             	pushl  0x8(%ebp)
  801a6a:	e8 3a 02 00 00       	call   801ca9 <nsipc_socket>
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 05                	js     801a7b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a76:	e8 a5 fe ff ff       	call   801920 <alloc_sockfd>
}
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	53                   	push   %ebx
  801a81:	83 ec 04             	sub    $0x4,%esp
  801a84:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a86:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a8d:	75 12                	jne    801aa1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801a8f:	83 ec 0c             	sub    $0xc,%esp
  801a92:	6a 02                	push   $0x2
  801a94:	e8 c8 04 00 00       	call   801f61 <ipc_find_env>
  801a99:	a3 04 40 80 00       	mov    %eax,0x804004
  801a9e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801aa1:	6a 07                	push   $0x7
  801aa3:	68 00 60 80 00       	push   $0x806000
  801aa8:	53                   	push   %ebx
  801aa9:	ff 35 04 40 80 00    	pushl  0x804004
  801aaf:	e8 5e 04 00 00       	call   801f12 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ab4:	83 c4 0c             	add    $0xc,%esp
  801ab7:	6a 00                	push   $0x0
  801ab9:	6a 00                	push   $0x0
  801abb:	6a 00                	push   $0x0
  801abd:	e8 da 03 00 00       	call   801e9c <ipc_recv>
}
  801ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ad7:	8b 06                	mov    (%esi),%eax
  801ad9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ade:	b8 01 00 00 00       	mov    $0x1,%eax
  801ae3:	e8 95 ff ff ff       	call   801a7d <nsipc>
  801ae8:	89 c3                	mov    %eax,%ebx
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 20                	js     801b0e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801aee:	83 ec 04             	sub    $0x4,%esp
  801af1:	ff 35 10 60 80 00    	pushl  0x806010
  801af7:	68 00 60 80 00       	push   $0x806000
  801afc:	ff 75 0c             	pushl  0xc(%ebp)
  801aff:	e8 74 ed ff ff       	call   800878 <memmove>
		*addrlen = ret->ret_addrlen;
  801b04:	a1 10 60 80 00       	mov    0x806010,%eax
  801b09:	89 06                	mov    %eax,(%esi)
  801b0b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b0e:	89 d8                	mov    %ebx,%eax
  801b10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	53                   	push   %ebx
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b21:	8b 45 08             	mov    0x8(%ebp),%eax
  801b24:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b29:	53                   	push   %ebx
  801b2a:	ff 75 0c             	pushl  0xc(%ebp)
  801b2d:	68 04 60 80 00       	push   $0x806004
  801b32:	e8 41 ed ff ff       	call   800878 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b37:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b3d:	b8 02 00 00 00       	mov    $0x2,%eax
  801b42:	e8 36 ff ff ff       	call   801a7d <nsipc>
}
  801b47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b4a:	c9                   	leave  
  801b4b:	c3                   	ret    

00801b4c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b62:	b8 03 00 00 00       	mov    $0x3,%eax
  801b67:	e8 11 ff ff ff       	call   801a7d <nsipc>
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <nsipc_close>:

int
nsipc_close(int s)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b74:	8b 45 08             	mov    0x8(%ebp),%eax
  801b77:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b7c:	b8 04 00 00 00       	mov    $0x4,%eax
  801b81:	e8 f7 fe ff ff       	call   801a7d <nsipc>
}
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b9a:	53                   	push   %ebx
  801b9b:	ff 75 0c             	pushl  0xc(%ebp)
  801b9e:	68 04 60 80 00       	push   $0x806004
  801ba3:	e8 d0 ec ff ff       	call   800878 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ba8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bae:	b8 05 00 00 00       	mov    $0x5,%eax
  801bb3:	e8 c5 fe ff ff       	call   801a7d <nsipc>
}
  801bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bce:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bd3:	b8 06 00 00 00       	mov    $0x6,%eax
  801bd8:	e8 a0 fe ff ff       	call   801a7d <nsipc>
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801be7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801bef:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801bf5:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bfd:	b8 07 00 00 00       	mov    $0x7,%eax
  801c02:	e8 76 fe ff ff       	call   801a7d <nsipc>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 35                	js     801c42 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c0d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c12:	7f 04                	jg     801c18 <nsipc_recv+0x39>
  801c14:	39 c6                	cmp    %eax,%esi
  801c16:	7d 16                	jge    801c2e <nsipc_recv+0x4f>
  801c18:	68 da 26 80 00       	push   $0x8026da
  801c1d:	68 83 26 80 00       	push   $0x802683
  801c22:	6a 62                	push   $0x62
  801c24:	68 ef 26 80 00       	push   $0x8026ef
  801c29:	e8 28 02 00 00       	call   801e56 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c2e:	83 ec 04             	sub    $0x4,%esp
  801c31:	50                   	push   %eax
  801c32:	68 00 60 80 00       	push   $0x806000
  801c37:	ff 75 0c             	pushl  0xc(%ebp)
  801c3a:	e8 39 ec ff ff       	call   800878 <memmove>
  801c3f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c42:	89 d8                	mov    %ebx,%eax
  801c44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 04             	sub    $0x4,%esp
  801c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c55:	8b 45 08             	mov    0x8(%ebp),%eax
  801c58:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c5d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c63:	7e 16                	jle    801c7b <nsipc_send+0x30>
  801c65:	68 fb 26 80 00       	push   $0x8026fb
  801c6a:	68 83 26 80 00       	push   $0x802683
  801c6f:	6a 6d                	push   $0x6d
  801c71:	68 ef 26 80 00       	push   $0x8026ef
  801c76:	e8 db 01 00 00       	call   801e56 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c7b:	83 ec 04             	sub    $0x4,%esp
  801c7e:	53                   	push   %ebx
  801c7f:	ff 75 0c             	pushl  0xc(%ebp)
  801c82:	68 0c 60 80 00       	push   $0x80600c
  801c87:	e8 ec eb ff ff       	call   800878 <memmove>
	nsipcbuf.send.req_size = size;
  801c8c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801c92:	8b 45 14             	mov    0x14(%ebp),%eax
  801c95:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801c9a:	b8 08 00 00 00       	mov    $0x8,%eax
  801c9f:	e8 d9 fd ff ff       	call   801a7d <nsipc>
}
  801ca4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cba:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cbf:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cc7:	b8 09 00 00 00       	mov    $0x9,%eax
  801ccc:	e8 ac fd ff ff       	call   801a7d <nsipc>
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cdb:	5d                   	pop    %ebp
  801cdc:	c3                   	ret    

00801cdd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ce3:	68 07 27 80 00       	push   $0x802707
  801ce8:	ff 75 0c             	pushl  0xc(%ebp)
  801ceb:	e8 f6 e9 ff ff       	call   8006e6 <strcpy>
	return 0;
}
  801cf0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf5:	c9                   	leave  
  801cf6:	c3                   	ret    

00801cf7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	57                   	push   %edi
  801cfb:	56                   	push   %esi
  801cfc:	53                   	push   %ebx
  801cfd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d03:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d08:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d0e:	eb 2d                	jmp    801d3d <devcons_write+0x46>
		m = n - tot;
  801d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d13:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d15:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d18:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d1d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d20:	83 ec 04             	sub    $0x4,%esp
  801d23:	53                   	push   %ebx
  801d24:	03 45 0c             	add    0xc(%ebp),%eax
  801d27:	50                   	push   %eax
  801d28:	57                   	push   %edi
  801d29:	e8 4a eb ff ff       	call   800878 <memmove>
		sys_cputs(buf, m);
  801d2e:	83 c4 08             	add    $0x8,%esp
  801d31:	53                   	push   %ebx
  801d32:	57                   	push   %edi
  801d33:	e8 f5 ec ff ff       	call   800a2d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d38:	01 de                	add    %ebx,%esi
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	89 f0                	mov    %esi,%eax
  801d3f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d42:	72 cc                	jb     801d10 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d5b:	74 2a                	je     801d87 <devcons_read+0x3b>
  801d5d:	eb 05                	jmp    801d64 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d5f:	e8 66 ed ff ff       	call   800aca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d64:	e8 e2 ec ff ff       	call   800a4b <sys_cgetc>
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	74 f2                	je     801d5f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d6d:	85 c0                	test   %eax,%eax
  801d6f:	78 16                	js     801d87 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d71:	83 f8 04             	cmp    $0x4,%eax
  801d74:	74 0c                	je     801d82 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d76:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d79:	88 02                	mov    %al,(%edx)
	return 1;
  801d7b:	b8 01 00 00 00       	mov    $0x1,%eax
  801d80:	eb 05                	jmp    801d87 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    

00801d89 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d95:	6a 01                	push   $0x1
  801d97:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d9a:	50                   	push   %eax
  801d9b:	e8 8d ec ff ff       	call   800a2d <sys_cputs>
}
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <getchar>:

int
getchar(void)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dab:	6a 01                	push   $0x1
  801dad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db0:	50                   	push   %eax
  801db1:	6a 00                	push   $0x0
  801db3:	e8 1d f2 ff ff       	call   800fd5 <read>
	if (r < 0)
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	85 c0                	test   %eax,%eax
  801dbd:	78 0f                	js     801dce <getchar+0x29>
		return r;
	if (r < 1)
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	7e 06                	jle    801dc9 <getchar+0x24>
		return -E_EOF;
	return c;
  801dc3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dc7:	eb 05                	jmp    801dce <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dc9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd9:	50                   	push   %eax
  801dda:	ff 75 08             	pushl  0x8(%ebp)
  801ddd:	e8 8d ef ff ff       	call   800d6f <fd_lookup>
  801de2:	83 c4 10             	add    $0x10,%esp
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 11                	js     801dfa <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801df2:	39 10                	cmp    %edx,(%eax)
  801df4:	0f 94 c0             	sete   %al
  801df7:	0f b6 c0             	movzbl %al,%eax
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <opencons>:

int
opencons(void)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e05:	50                   	push   %eax
  801e06:	e8 15 ef ff ff       	call   800d20 <fd_alloc>
  801e0b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e0e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 3e                	js     801e52 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e14:	83 ec 04             	sub    $0x4,%esp
  801e17:	68 07 04 00 00       	push   $0x407
  801e1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1f:	6a 00                	push   $0x0
  801e21:	e8 c3 ec ff ff       	call   800ae9 <sys_page_alloc>
  801e26:	83 c4 10             	add    $0x10,%esp
		return r;
  801e29:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 23                	js     801e52 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e2f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e38:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e3d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	50                   	push   %eax
  801e48:	e8 ac ee ff ff       	call   800cf9 <fd2num>
  801e4d:	89 c2                	mov    %eax,%edx
  801e4f:	83 c4 10             	add    $0x10,%esp
}
  801e52:	89 d0                	mov    %edx,%eax
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	56                   	push   %esi
  801e5a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e5b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e5e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e64:	e8 42 ec ff ff       	call   800aab <sys_getenvid>
  801e69:	83 ec 0c             	sub    $0xc,%esp
  801e6c:	ff 75 0c             	pushl  0xc(%ebp)
  801e6f:	ff 75 08             	pushl  0x8(%ebp)
  801e72:	56                   	push   %esi
  801e73:	50                   	push   %eax
  801e74:	68 14 27 80 00       	push   $0x802714
  801e79:	e8 c3 e2 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e7e:	83 c4 18             	add    $0x18,%esp
  801e81:	53                   	push   %ebx
  801e82:	ff 75 10             	pushl  0x10(%ebp)
  801e85:	e8 66 e2 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801e8a:	c7 04 24 c7 26 80 00 	movl   $0x8026c7,(%esp)
  801e91:	e8 ab e2 ff ff       	call   800141 <cprintf>
  801e96:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e99:	cc                   	int3   
  801e9a:	eb fd                	jmp    801e99 <_panic+0x43>

00801e9c <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	74 0e                	je     801ebc <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	50                   	push   %eax
  801eb2:	e8 e2 ed ff ff       	call   800c99 <sys_ipc_recv>
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	eb 10                	jmp    801ecc <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	68 00 00 c0 ee       	push   $0xeec00000
  801ec4:	e8 d0 ed ff ff       	call   800c99 <sys_ipc_recv>
  801ec9:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	79 17                	jns    801ee7 <ipc_recv+0x4b>
		if(*from_env_store)
  801ed0:	83 3e 00             	cmpl   $0x0,(%esi)
  801ed3:	74 06                	je     801edb <ipc_recv+0x3f>
			*from_env_store = 0;
  801ed5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801edb:	85 db                	test   %ebx,%ebx
  801edd:	74 2c                	je     801f0b <ipc_recv+0x6f>
			*perm_store = 0;
  801edf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ee5:	eb 24                	jmp    801f0b <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ee7:	85 f6                	test   %esi,%esi
  801ee9:	74 0a                	je     801ef5 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801eeb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef0:	8b 40 74             	mov    0x74(%eax),%eax
  801ef3:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801ef5:	85 db                	test   %ebx,%ebx
  801ef7:	74 0a                	je     801f03 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801ef9:	a1 08 40 80 00       	mov    0x804008,%eax
  801efe:	8b 40 78             	mov    0x78(%eax),%eax
  801f01:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f03:	a1 08 40 80 00       	mov    0x804008,%eax
  801f08:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0e:	5b                   	pop    %ebx
  801f0f:	5e                   	pop    %esi
  801f10:	5d                   	pop    %ebp
  801f11:	c3                   	ret    

00801f12 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	57                   	push   %edi
  801f16:	56                   	push   %esi
  801f17:	53                   	push   %ebx
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f24:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f26:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f2b:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f2e:	e8 97 eb ff ff       	call   800aca <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f33:	ff 75 14             	pushl  0x14(%ebp)
  801f36:	53                   	push   %ebx
  801f37:	56                   	push   %esi
  801f38:	57                   	push   %edi
  801f39:	e8 38 ed ff ff       	call   800c76 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	f7 d2                	not    %edx
  801f42:	c1 ea 1f             	shr    $0x1f,%edx
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4b:	0f 94 c1             	sete   %cl
  801f4e:	09 ca                	or     %ecx,%edx
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 94 c0             	sete   %al
  801f55:	38 c2                	cmp    %al,%dl
  801f57:	77 d5                	ja     801f2e <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5c:	5b                   	pop    %ebx
  801f5d:	5e                   	pop    %esi
  801f5e:	5f                   	pop    %edi
  801f5f:	5d                   	pop    %ebp
  801f60:	c3                   	ret    

00801f61 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f75:	8b 52 50             	mov    0x50(%edx),%edx
  801f78:	39 ca                	cmp    %ecx,%edx
  801f7a:	75 0d                	jne    801f89 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f7c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f7f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f84:	8b 40 48             	mov    0x48(%eax),%eax
  801f87:	eb 0f                	jmp    801f98 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f89:	83 c0 01             	add    $0x1,%eax
  801f8c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f91:	75 d9                	jne    801f6c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa0:	89 d0                	mov    %edx,%eax
  801fa2:	c1 e8 16             	shr    $0x16,%eax
  801fa5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb1:	f6 c1 01             	test   $0x1,%cl
  801fb4:	74 1d                	je     801fd3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fb6:	c1 ea 0c             	shr    $0xc,%edx
  801fb9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fc0:	f6 c2 01             	test   $0x1,%dl
  801fc3:	74 0e                	je     801fd3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc5:	c1 ea 0c             	shr    $0xc,%edx
  801fc8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fcf:	ef 
  801fd0:	0f b7 c0             	movzwl %ax,%eax
}
  801fd3:	5d                   	pop    %ebp
  801fd4:	c3                   	ret    
  801fd5:	66 90                	xchg   %ax,%ax
  801fd7:	66 90                	xchg   %ax,%ax
  801fd9:	66 90                	xchg   %ax,%ax
  801fdb:	66 90                	xchg   %ax,%ax
  801fdd:	66 90                	xchg   %ax,%ax
  801fdf:	90                   	nop

00801fe0 <__udivdi3>:
  801fe0:	55                   	push   %ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	83 ec 1c             	sub    $0x1c,%esp
  801fe7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801feb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ff3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ffd:	89 ca                	mov    %ecx,%edx
  801fff:	89 f8                	mov    %edi,%eax
  802001:	75 3d                	jne    802040 <__udivdi3+0x60>
  802003:	39 cf                	cmp    %ecx,%edi
  802005:	0f 87 c5 00 00 00    	ja     8020d0 <__udivdi3+0xf0>
  80200b:	85 ff                	test   %edi,%edi
  80200d:	89 fd                	mov    %edi,%ebp
  80200f:	75 0b                	jne    80201c <__udivdi3+0x3c>
  802011:	b8 01 00 00 00       	mov    $0x1,%eax
  802016:	31 d2                	xor    %edx,%edx
  802018:	f7 f7                	div    %edi
  80201a:	89 c5                	mov    %eax,%ebp
  80201c:	89 c8                	mov    %ecx,%eax
  80201e:	31 d2                	xor    %edx,%edx
  802020:	f7 f5                	div    %ebp
  802022:	89 c1                	mov    %eax,%ecx
  802024:	89 d8                	mov    %ebx,%eax
  802026:	89 cf                	mov    %ecx,%edi
  802028:	f7 f5                	div    %ebp
  80202a:	89 c3                	mov    %eax,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	39 ce                	cmp    %ecx,%esi
  802042:	77 74                	ja     8020b8 <__udivdi3+0xd8>
  802044:	0f bd fe             	bsr    %esi,%edi
  802047:	83 f7 1f             	xor    $0x1f,%edi
  80204a:	0f 84 98 00 00 00    	je     8020e8 <__udivdi3+0x108>
  802050:	bb 20 00 00 00       	mov    $0x20,%ebx
  802055:	89 f9                	mov    %edi,%ecx
  802057:	89 c5                	mov    %eax,%ebp
  802059:	29 fb                	sub    %edi,%ebx
  80205b:	d3 e6                	shl    %cl,%esi
  80205d:	89 d9                	mov    %ebx,%ecx
  80205f:	d3 ed                	shr    %cl,%ebp
  802061:	89 f9                	mov    %edi,%ecx
  802063:	d3 e0                	shl    %cl,%eax
  802065:	09 ee                	or     %ebp,%esi
  802067:	89 d9                	mov    %ebx,%ecx
  802069:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80206d:	89 d5                	mov    %edx,%ebp
  80206f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802073:	d3 ed                	shr    %cl,%ebp
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e2                	shl    %cl,%edx
  802079:	89 d9                	mov    %ebx,%ecx
  80207b:	d3 e8                	shr    %cl,%eax
  80207d:	09 c2                	or     %eax,%edx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	89 ea                	mov    %ebp,%edx
  802083:	f7 f6                	div    %esi
  802085:	89 d5                	mov    %edx,%ebp
  802087:	89 c3                	mov    %eax,%ebx
  802089:	f7 64 24 0c          	mull   0xc(%esp)
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	72 10                	jb     8020a1 <__udivdi3+0xc1>
  802091:	8b 74 24 08          	mov    0x8(%esp),%esi
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e6                	shl    %cl,%esi
  802099:	39 c6                	cmp    %eax,%esi
  80209b:	73 07                	jae    8020a4 <__udivdi3+0xc4>
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	75 03                	jne    8020a4 <__udivdi3+0xc4>
  8020a1:	83 eb 01             	sub    $0x1,%ebx
  8020a4:	31 ff                	xor    %edi,%edi
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	89 fa                	mov    %edi,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	31 ff                	xor    %edi,%edi
  8020ba:	31 db                	xor    %ebx,%ebx
  8020bc:	89 d8                	mov    %ebx,%eax
  8020be:	89 fa                	mov    %edi,%edx
  8020c0:	83 c4 1c             	add    $0x1c,%esp
  8020c3:	5b                   	pop    %ebx
  8020c4:	5e                   	pop    %esi
  8020c5:	5f                   	pop    %edi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    
  8020c8:	90                   	nop
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 d8                	mov    %ebx,%eax
  8020d2:	f7 f7                	div    %edi
  8020d4:	31 ff                	xor    %edi,%edi
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 fa                	mov    %edi,%edx
  8020dc:	83 c4 1c             	add    $0x1c,%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	39 ce                	cmp    %ecx,%esi
  8020ea:	72 0c                	jb     8020f8 <__udivdi3+0x118>
  8020ec:	31 db                	xor    %ebx,%ebx
  8020ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020f2:	0f 87 34 ff ff ff    	ja     80202c <__udivdi3+0x4c>
  8020f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020fd:	e9 2a ff ff ff       	jmp    80202c <__udivdi3+0x4c>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80211b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80211f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 d2                	test   %edx,%edx
  802129:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80212d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802131:	89 f3                	mov    %esi,%ebx
  802133:	89 3c 24             	mov    %edi,(%esp)
  802136:	89 74 24 04          	mov    %esi,0x4(%esp)
  80213a:	75 1c                	jne    802158 <__umoddi3+0x48>
  80213c:	39 f7                	cmp    %esi,%edi
  80213e:	76 50                	jbe    802190 <__umoddi3+0x80>
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	f7 f7                	div    %edi
  802146:	89 d0                	mov    %edx,%eax
  802148:	31 d2                	xor    %edx,%edx
  80214a:	83 c4 1c             	add    $0x1c,%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5f                   	pop    %edi
  802150:	5d                   	pop    %ebp
  802151:	c3                   	ret    
  802152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802158:	39 f2                	cmp    %esi,%edx
  80215a:	89 d0                	mov    %edx,%eax
  80215c:	77 52                	ja     8021b0 <__umoddi3+0xa0>
  80215e:	0f bd ea             	bsr    %edx,%ebp
  802161:	83 f5 1f             	xor    $0x1f,%ebp
  802164:	75 5a                	jne    8021c0 <__umoddi3+0xb0>
  802166:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80216a:	0f 82 e0 00 00 00    	jb     802250 <__umoddi3+0x140>
  802170:	39 0c 24             	cmp    %ecx,(%esp)
  802173:	0f 86 d7 00 00 00    	jbe    802250 <__umoddi3+0x140>
  802179:	8b 44 24 08          	mov    0x8(%esp),%eax
  80217d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802181:	83 c4 1c             	add    $0x1c,%esp
  802184:	5b                   	pop    %ebx
  802185:	5e                   	pop    %esi
  802186:	5f                   	pop    %edi
  802187:	5d                   	pop    %ebp
  802188:	c3                   	ret    
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	85 ff                	test   %edi,%edi
  802192:	89 fd                	mov    %edi,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x91>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f7                	div    %edi
  80219f:	89 c5                	mov    %eax,%ebp
  8021a1:	89 f0                	mov    %esi,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f5                	div    %ebp
  8021a7:	89 c8                	mov    %ecx,%eax
  8021a9:	f7 f5                	div    %ebp
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	eb 99                	jmp    802148 <__umoddi3+0x38>
  8021af:	90                   	nop
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	83 c4 1c             	add    $0x1c,%esp
  8021b7:	5b                   	pop    %ebx
  8021b8:	5e                   	pop    %esi
  8021b9:	5f                   	pop    %edi
  8021ba:	5d                   	pop    %ebp
  8021bb:	c3                   	ret    
  8021bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	8b 34 24             	mov    (%esp),%esi
  8021c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021c8:	89 e9                	mov    %ebp,%ecx
  8021ca:	29 ef                	sub    %ebp,%edi
  8021cc:	d3 e0                	shl    %cl,%eax
  8021ce:	89 f9                	mov    %edi,%ecx
  8021d0:	89 f2                	mov    %esi,%edx
  8021d2:	d3 ea                	shr    %cl,%edx
  8021d4:	89 e9                	mov    %ebp,%ecx
  8021d6:	09 c2                	or     %eax,%edx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 14 24             	mov    %edx,(%esp)
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	d3 e2                	shl    %cl,%edx
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021eb:	d3 e8                	shr    %cl,%eax
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	89 c6                	mov    %eax,%esi
  8021f1:	d3 e3                	shl    %cl,%ebx
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	d3 e8                	shr    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	09 d8                	or     %ebx,%eax
  8021fd:	89 d3                	mov    %edx,%ebx
  8021ff:	89 f2                	mov    %esi,%edx
  802201:	f7 34 24             	divl   (%esp)
  802204:	89 d6                	mov    %edx,%esi
  802206:	d3 e3                	shl    %cl,%ebx
  802208:	f7 64 24 04          	mull   0x4(%esp)
  80220c:	39 d6                	cmp    %edx,%esi
  80220e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802212:	89 d1                	mov    %edx,%ecx
  802214:	89 c3                	mov    %eax,%ebx
  802216:	72 08                	jb     802220 <__umoddi3+0x110>
  802218:	75 11                	jne    80222b <__umoddi3+0x11b>
  80221a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80221e:	73 0b                	jae    80222b <__umoddi3+0x11b>
  802220:	2b 44 24 04          	sub    0x4(%esp),%eax
  802224:	1b 14 24             	sbb    (%esp),%edx
  802227:	89 d1                	mov    %edx,%ecx
  802229:	89 c3                	mov    %eax,%ebx
  80222b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80222f:	29 da                	sub    %ebx,%edx
  802231:	19 ce                	sbb    %ecx,%esi
  802233:	89 f9                	mov    %edi,%ecx
  802235:	89 f0                	mov    %esi,%eax
  802237:	d3 e0                	shl    %cl,%eax
  802239:	89 e9                	mov    %ebp,%ecx
  80223b:	d3 ea                	shr    %cl,%edx
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	09 d0                	or     %edx,%eax
  802243:	89 f2                	mov    %esi,%edx
  802245:	83 c4 1c             	add    $0x1c,%esp
  802248:	5b                   	pop    %ebx
  802249:	5e                   	pop    %esi
  80224a:	5f                   	pop    %edi
  80224b:	5d                   	pop    %ebp
  80224c:	c3                   	ret    
  80224d:	8d 76 00             	lea    0x0(%esi),%esi
  802250:	29 f9                	sub    %edi,%ecx
  802252:	19 d6                	sbb    %edx,%esi
  802254:	89 74 24 04          	mov    %esi,0x4(%esp)
  802258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225c:	e9 18 ff ff ff       	jmp    802179 <__umoddi3+0x69>
