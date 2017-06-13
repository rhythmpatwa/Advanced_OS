
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 80 22 80 00       	push   $0x802280
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80006b:	e8 4d 0a 00 00       	call   800abd <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 25 0e 00 00       	call   800ed6 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 c1 09 00 00       	call   800a7c <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 4f 09 00 00       	call   800a3f <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 54 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 f4 08 00 00       	call   800a3f <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 45                	ja     8001dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 35 1e 00 00       	call   801ff0 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 18                	jmp    8001e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb 03                	jmp    8001df <printnum+0x78>
  8001dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	85 db                	test   %ebx,%ebx
  8001e4:	7f e8                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 22 1f 00 00       	call   802120 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 98 22 80 00 	movsbl 0x802298(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff d7                	call   *%edi
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800219:	83 fa 01             	cmp    $0x1,%edx
  80021c:	7e 0e                	jle    80022c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 08             	lea    0x8(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	8b 52 04             	mov    0x4(%edx),%edx
  80022a:	eb 22                	jmp    80024e <getuint+0x38>
	else if (lflag)
  80022c:	85 d2                	test   %edx,%edx
  80022e:	74 10                	je     800240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	eb 0e                	jmp    80024e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 a9 03 00 00    	je     80064f <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	eb 07                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	0f b6 07             	movzbl (%edi),%eax
  8002ec:	0f b6 c8             	movzbl %al,%ecx
  8002ef:	83 e8 23             	sub    $0x23,%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 3a 03 00 00    	ja     800634 <vprintfmt+0x3aa>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030b:	eb d6                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800322:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800325:	83 fa 09             	cmp    $0x9,%edx
  800328:	77 39                	ja     800363 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8d 48 04             	lea    0x4(%eax),%ecx
  800335:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800338:	8b 00                	mov    (%eax),%eax
  80033a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800340:	eb 27                	jmp    800369 <vprintfmt+0xdf>
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	85 c0                	test   %eax,%eax
  800347:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034c:	0f 49 c8             	cmovns %eax,%ecx
  80034f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800355:	eb 8c                	jmp    8002e3 <vprintfmt+0x59>
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800361:	eb 80                	jmp    8002e3 <vprintfmt+0x59>
  800363:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800366:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036d:	0f 89 70 ff ff ff    	jns    8002e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800373:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800379:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800380:	e9 5e ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800385:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038b:	e9 53 ff ff ff       	jmp    8002e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 50 04             	lea    0x4(%eax),%edx
  800396:	89 55 14             	mov    %edx,0x14(%ebp)
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	53                   	push   %ebx
  80039d:	ff 30                	pushl  (%eax)
  80039f:	ff d6                	call   *%esi
			break;
  8003a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a7:	e9 04 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	99                   	cltd   
  8003b8:	31 d0                	xor    %edx,%eax
  8003ba:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bc:	83 f8 0f             	cmp    $0xf,%eax
  8003bf:	7f 0b                	jg     8003cc <vprintfmt+0x142>
  8003c1:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	75 18                	jne    8003e4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003cc:	50                   	push   %eax
  8003cd:	68 b0 22 80 00       	push   $0x8022b0
  8003d2:	53                   	push   %ebx
  8003d3:	56                   	push   %esi
  8003d4:	e8 94 fe ff ff       	call   80026d <printfmt>
  8003d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003df:	e9 cc fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e4:	52                   	push   %edx
  8003e5:	68 75 26 80 00       	push   $0x802675
  8003ea:	53                   	push   %ebx
  8003eb:	56                   	push   %esi
  8003ec:	e8 7c fe ff ff       	call   80026d <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f7:	e9 b4 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800407:	85 ff                	test   %edi,%edi
  800409:	b8 a9 22 80 00       	mov    $0x8022a9,%eax
  80040e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	0f 8e 94 00 00 00    	jle    8004af <vprintfmt+0x225>
  80041b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041f:	0f 84 98 00 00 00    	je     8004bd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	ff 75 d0             	pushl  -0x30(%ebp)
  80042b:	57                   	push   %edi
  80042c:	e8 a6 02 00 00       	call   8006d7 <strnlen>
  800431:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800434:	29 c1                	sub    %eax,%ecx
  800436:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800439:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800446:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	eb 0f                	jmp    800459 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 e0             	pushl  -0x20(%ebp)
  800451:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	83 ef 01             	sub    $0x1,%edi
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 ff                	test   %edi,%edi
  80045b:	7f ed                	jg     80044a <vprintfmt+0x1c0>
  80045d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800460:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800463:	85 c9                	test   %ecx,%ecx
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	0f 49 c1             	cmovns %ecx,%eax
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 75 08             	mov    %esi,0x8(%ebp)
  800472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	89 cb                	mov    %ecx,%ebx
  80047a:	eb 4d                	jmp    8004c9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800480:	74 1b                	je     80049d <vprintfmt+0x213>
  800482:	0f be c0             	movsbl %al,%eax
  800485:	83 e8 20             	sub    $0x20,%eax
  800488:	83 f8 5e             	cmp    $0x5e,%eax
  80048b:	76 10                	jbe    80049d <vprintfmt+0x213>
					putch('?', putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	6a 3f                	push   $0x3f
  800495:	ff 55 08             	call   *0x8(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	eb 0d                	jmp    8004aa <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	52                   	push   %edx
  8004a4:	ff 55 08             	call   *0x8(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	eb 1a                	jmp    8004c9 <vprintfmt+0x23f>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	eb 0c                	jmp    8004c9 <vprintfmt+0x23f>
  8004bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c9:	83 c7 01             	add    $0x1,%edi
  8004cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d0:	0f be d0             	movsbl %al,%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 23                	je     8004fa <vprintfmt+0x270>
  8004d7:	85 f6                	test   %esi,%esi
  8004d9:	78 a1                	js     80047c <vprintfmt+0x1f2>
  8004db:	83 ee 01             	sub    $0x1,%esi
  8004de:	79 9c                	jns    80047c <vprintfmt+0x1f2>
  8004e0:	89 df                	mov    %ebx,%edi
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e8:	eb 18                	jmp    800502 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	6a 20                	push   $0x20
  8004f0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb 08                	jmp    800502 <vprintfmt+0x278>
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	85 ff                	test   %edi,%edi
  800504:	7f e4                	jg     8004ea <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 a2 fd ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050e:	83 fa 01             	cmp    $0x1,%edx
  800511:	7e 16                	jle    800529 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 50 08             	lea    0x8(%eax),%edx
  800519:	89 55 14             	mov    %edx,0x14(%ebp)
  80051c:	8b 50 04             	mov    0x4(%eax),%edx
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800524:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800527:	eb 32                	jmp    80055b <vprintfmt+0x2d1>
	else if (lflag)
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 18                	je     800545 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053b:	89 c1                	mov    %eax,%ecx
  80053d:	c1 f9 1f             	sar    $0x1f,%ecx
  800540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800543:	eb 16                	jmp    80055b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800553:	89 c1                	mov    %eax,%ecx
  800555:	c1 f9 1f             	sar    $0x1f,%ecx
  800558:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800561:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800566:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056a:	0f 89 90 00 00 00    	jns    800600 <vprintfmt+0x376>
				putch('-', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	6a 2d                	push   $0x2d
  800576:	ff d6                	call   *%esi
				num = -(long long) num;
  800578:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057e:	f7 d8                	neg    %eax
  800580:	83 d2 00             	adc    $0x0,%edx
  800583:	f7 da                	neg    %edx
  800585:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800588:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058d:	eb 71                	jmp    800600 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058f:	8d 45 14             	lea    0x14(%ebp),%eax
  800592:	e8 7f fc ff ff       	call   800216 <getuint>
			base = 10;
  800597:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80059c:	eb 62                	jmp    800600 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80059e:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a1:	e8 70 fc ff ff       	call   800216 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005ad:	51                   	push   %ecx
  8005ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b1:	6a 08                	push   $0x8
  8005b3:	52                   	push   %edx
  8005b4:	50                   	push   %eax
  8005b5:	89 da                	mov    %ebx,%edx
  8005b7:	89 f0                	mov    %esi,%eax
  8005b9:	e8 a9 fb ff ff       	call   800167 <printnum>
			break;
  8005be:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8005c4:	e9 e7 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ec:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005f1:	eb 0d                	jmp    800600 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 1b fc ff ff       	call   800216 <getuint>
			base = 16;
  8005fb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800607:	57                   	push   %edi
  800608:	ff 75 e0             	pushl  -0x20(%ebp)
  80060b:	51                   	push   %ecx
  80060c:	52                   	push   %edx
  80060d:	50                   	push   %eax
  80060e:	89 da                	mov    %ebx,%edx
  800610:	89 f0                	mov    %esi,%eax
  800612:	e8 50 fb ff ff       	call   800167 <printnum>
			break;
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061d:	e9 8e fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	51                   	push   %ecx
  800627:	ff d6                	call   *%esi
			break;
  800629:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80062f:	e9 7c fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 25                	push   $0x25
  80063a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	eb 03                	jmp    800644 <vprintfmt+0x3ba>
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800648:	75 f7                	jne    800641 <vprintfmt+0x3b7>
  80064a:	e9 61 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80064f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800652:	5b                   	pop    %ebx
  800653:	5e                   	pop    %esi
  800654:	5f                   	pop    %edi
  800655:	5d                   	pop    %ebp
  800656:	c3                   	ret    

00800657 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800657:	55                   	push   %ebp
  800658:	89 e5                	mov    %esp,%ebp
  80065a:	83 ec 18             	sub    $0x18,%esp
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800663:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800666:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80066a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80066d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800674:	85 c0                	test   %eax,%eax
  800676:	74 26                	je     80069e <vsnprintf+0x47>
  800678:	85 d2                	test   %edx,%edx
  80067a:	7e 22                	jle    80069e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80067c:	ff 75 14             	pushl  0x14(%ebp)
  80067f:	ff 75 10             	pushl  0x10(%ebp)
  800682:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	68 50 02 80 00       	push   $0x800250
  80068b:	e8 fa fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800690:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800693:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 05                	jmp    8006a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80069e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    

008006a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ae:	50                   	push   %eax
  8006af:	ff 75 10             	pushl  0x10(%ebp)
  8006b2:	ff 75 0c             	pushl  0xc(%ebp)
  8006b5:	ff 75 08             	pushl  0x8(%ebp)
  8006b8:	e8 9a ff ff ff       	call   800657 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006bd:	c9                   	leave  
  8006be:	c3                   	ret    

008006bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ca:	eb 03                	jmp    8006cf <strlen+0x10>
		n++;
  8006cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006d3:	75 f7                	jne    8006cc <strlen+0xd>
		n++;
	return n;
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	eb 03                	jmp    8006ea <strnlen+0x13>
		n++;
  8006e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	39 c2                	cmp    %eax,%edx
  8006ec:	74 08                	je     8006f6 <strnlen+0x1f>
  8006ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006f2:	75 f3                	jne    8006e7 <strnlen+0x10>
  8006f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800702:	89 c2                	mov    %eax,%edx
  800704:	83 c2 01             	add    $0x1,%edx
  800707:	83 c1 01             	add    $0x1,%ecx
  80070a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80070e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800711:	84 db                	test   %bl,%bl
  800713:	75 ef                	jne    800704 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80071f:	53                   	push   %ebx
  800720:	e8 9a ff ff ff       	call   8006bf <strlen>
  800725:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	01 d8                	add    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	e8 c5 ff ff ff       	call   8006f8 <strcpy>
	return dst;
}
  800733:	89 d8                	mov    %ebx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	56                   	push   %esi
  80073e:	53                   	push   %ebx
  80073f:	8b 75 08             	mov    0x8(%ebp),%esi
  800742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800745:	89 f3                	mov    %esi,%ebx
  800747:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80074a:	89 f2                	mov    %esi,%edx
  80074c:	eb 0f                	jmp    80075d <strncpy+0x23>
		*dst++ = *src;
  80074e:	83 c2 01             	add    $0x1,%edx
  800751:	0f b6 01             	movzbl (%ecx),%eax
  800754:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800757:	80 39 01             	cmpb   $0x1,(%ecx)
  80075a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075d:	39 da                	cmp    %ebx,%edx
  80075f:	75 ed                	jne    80074e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800761:	89 f0                	mov    %esi,%eax
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	8b 55 10             	mov    0x10(%ebp),%edx
  800775:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800777:	85 d2                	test   %edx,%edx
  800779:	74 21                	je     80079c <strlcpy+0x35>
  80077b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80077f:	89 f2                	mov    %esi,%edx
  800781:	eb 09                	jmp    80078c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80078c:	39 c2                	cmp    %eax,%edx
  80078e:	74 09                	je     800799 <strlcpy+0x32>
  800790:	0f b6 19             	movzbl (%ecx),%ebx
  800793:	84 db                	test   %bl,%bl
  800795:	75 ec                	jne    800783 <strlcpy+0x1c>
  800797:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80079c:	29 f0                	sub    %esi,%eax
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ab:	eb 06                	jmp    8007b3 <strcmp+0x11>
		p++, q++;
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	84 c0                	test   %al,%al
  8007b8:	74 04                	je     8007be <strcmp+0x1c>
  8007ba:	3a 02                	cmp    (%edx),%al
  8007bc:	74 ef                	je     8007ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007be:	0f b6 c0             	movzbl %al,%eax
  8007c1:	0f b6 12             	movzbl (%edx),%edx
  8007c4:	29 d0                	sub    %edx,%eax
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d2:	89 c3                	mov    %eax,%ebx
  8007d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007d7:	eb 06                	jmp    8007df <strncmp+0x17>
		n--, p++, q++;
  8007d9:	83 c0 01             	add    $0x1,%eax
  8007dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 15                	je     8007f8 <strncmp+0x30>
  8007e3:	0f b6 08             	movzbl (%eax),%ecx
  8007e6:	84 c9                	test   %cl,%cl
  8007e8:	74 04                	je     8007ee <strncmp+0x26>
  8007ea:	3a 0a                	cmp    (%edx),%cl
  8007ec:	74 eb                	je     8007d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ee:	0f b6 00             	movzbl (%eax),%eax
  8007f1:	0f b6 12             	movzbl (%edx),%edx
  8007f4:	29 d0                	sub    %edx,%eax
  8007f6:	eb 05                	jmp    8007fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80080a:	eb 07                	jmp    800813 <strchr+0x13>
		if (*s == c)
  80080c:	38 ca                	cmp    %cl,%dl
  80080e:	74 0f                	je     80081f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	0f b6 10             	movzbl (%eax),%edx
  800816:	84 d2                	test   %dl,%dl
  800818:	75 f2                	jne    80080c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	eb 03                	jmp    800830 <strfind+0xf>
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 04                	je     80083b <strfind+0x1a>
  800837:	84 d2                	test   %dl,%dl
  800839:	75 f2                	jne    80082d <strfind+0xc>
			break;
	return (char *) s;
}
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	57                   	push   %edi
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 7d 08             	mov    0x8(%ebp),%edi
  800846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800849:	85 c9                	test   %ecx,%ecx
  80084b:	74 36                	je     800883 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80084d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800853:	75 28                	jne    80087d <memset+0x40>
  800855:	f6 c1 03             	test   $0x3,%cl
  800858:	75 23                	jne    80087d <memset+0x40>
		c &= 0xFF;
  80085a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80085e:	89 d3                	mov    %edx,%ebx
  800860:	c1 e3 08             	shl    $0x8,%ebx
  800863:	89 d6                	mov    %edx,%esi
  800865:	c1 e6 18             	shl    $0x18,%esi
  800868:	89 d0                	mov    %edx,%eax
  80086a:	c1 e0 10             	shl    $0x10,%eax
  80086d:	09 f0                	or     %esi,%eax
  80086f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800871:	89 d8                	mov    %ebx,%eax
  800873:	09 d0                	or     %edx,%eax
  800875:	c1 e9 02             	shr    $0x2,%ecx
  800878:	fc                   	cld    
  800879:	f3 ab                	rep stos %eax,%es:(%edi)
  80087b:	eb 06                	jmp    800883 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80087d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800880:	fc                   	cld    
  800881:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800883:	89 f8                	mov    %edi,%eax
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 75 0c             	mov    0xc(%ebp),%esi
  800895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800898:	39 c6                	cmp    %eax,%esi
  80089a:	73 35                	jae    8008d1 <memmove+0x47>
  80089c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80089f:	39 d0                	cmp    %edx,%eax
  8008a1:	73 2e                	jae    8008d1 <memmove+0x47>
		s += n;
		d += n;
  8008a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a6:	89 d6                	mov    %edx,%esi
  8008a8:	09 fe                	or     %edi,%esi
  8008aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b0:	75 13                	jne    8008c5 <memmove+0x3b>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0e                	jne    8008c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008b7:	83 ef 04             	sub    $0x4,%edi
  8008ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008bd:	c1 e9 02             	shr    $0x2,%ecx
  8008c0:	fd                   	std    
  8008c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008c3:	eb 09                	jmp    8008ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008c5:	83 ef 01             	sub    $0x1,%edi
  8008c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008cb:	fd                   	std    
  8008cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ce:	fc                   	cld    
  8008cf:	eb 1d                	jmp    8008ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d1:	89 f2                	mov    %esi,%edx
  8008d3:	09 c2                	or     %eax,%edx
  8008d5:	f6 c2 03             	test   $0x3,%dl
  8008d8:	75 0f                	jne    8008e9 <memmove+0x5f>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0a                	jne    8008e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	89 c7                	mov    %eax,%edi
  8008e4:	fc                   	cld    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 05                	jmp    8008ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e9:	89 c7                	mov    %eax,%edi
  8008eb:	fc                   	cld    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 87 ff ff ff       	call   80088a <memmove>
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c6                	mov    %eax,%esi
  800912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800915:	eb 1a                	jmp    800931 <memcmp+0x2c>
		if (*s1 != *s2)
  800917:	0f b6 08             	movzbl (%eax),%ecx
  80091a:	0f b6 1a             	movzbl (%edx),%ebx
  80091d:	38 d9                	cmp    %bl,%cl
  80091f:	74 0a                	je     80092b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800921:	0f b6 c1             	movzbl %cl,%eax
  800924:	0f b6 db             	movzbl %bl,%ebx
  800927:	29 d8                	sub    %ebx,%eax
  800929:	eb 0f                	jmp    80093a <memcmp+0x35>
		s1++, s2++;
  80092b:	83 c0 01             	add    $0x1,%eax
  80092e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800931:	39 f0                	cmp    %esi,%eax
  800933:	75 e2                	jne    800917 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800945:	89 c1                	mov    %eax,%ecx
  800947:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80094a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094e:	eb 0a                	jmp    80095a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	39 da                	cmp    %ebx,%edx
  800955:	74 07                	je     80095e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800957:	83 c0 01             	add    $0x1,%eax
  80095a:	39 c8                	cmp    %ecx,%eax
  80095c:	72 f2                	jb     800950 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096d:	eb 03                	jmp    800972 <strtol+0x11>
		s++;
  80096f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800972:	0f b6 01             	movzbl (%ecx),%eax
  800975:	3c 20                	cmp    $0x20,%al
  800977:	74 f6                	je     80096f <strtol+0xe>
  800979:	3c 09                	cmp    $0x9,%al
  80097b:	74 f2                	je     80096f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80097d:	3c 2b                	cmp    $0x2b,%al
  80097f:	75 0a                	jne    80098b <strtol+0x2a>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800984:	bf 00 00 00 00       	mov    $0x0,%edi
  800989:	eb 11                	jmp    80099c <strtol+0x3b>
  80098b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800990:	3c 2d                	cmp    $0x2d,%al
  800992:	75 08                	jne    80099c <strtol+0x3b>
		s++, neg = 1;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80099c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009a2:	75 15                	jne    8009b9 <strtol+0x58>
  8009a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009a7:	75 10                	jne    8009b9 <strtol+0x58>
  8009a9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ad:	75 7c                	jne    800a2b <strtol+0xca>
		s += 2, base = 16;
  8009af:	83 c1 02             	add    $0x2,%ecx
  8009b2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009b7:	eb 16                	jmp    8009cf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b9:	85 db                	test   %ebx,%ebx
  8009bb:	75 12                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009bd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c5:	75 08                	jne    8009cf <strtol+0x6e>
		s++, base = 8;
  8009c7:	83 c1 01             	add    $0x1,%ecx
  8009ca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009d7:	0f b6 11             	movzbl (%ecx),%edx
  8009da:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009dd:	89 f3                	mov    %esi,%ebx
  8009df:	80 fb 09             	cmp    $0x9,%bl
  8009e2:	77 08                	ja     8009ec <strtol+0x8b>
			dig = *s - '0';
  8009e4:	0f be d2             	movsbl %dl,%edx
  8009e7:	83 ea 30             	sub    $0x30,%edx
  8009ea:	eb 22                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009ec:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 19             	cmp    $0x19,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 57             	sub    $0x57,%edx
  8009fc:	eb 10                	jmp    800a0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009fe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 16                	ja     800a1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a11:	7d 0b                	jge    800a1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a1c:	eb b9                	jmp    8009d7 <strtol+0x76>

	if (endptr)
  800a1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a22:	74 0d                	je     800a31 <strtol+0xd0>
		*endptr = (char *) s;
  800a24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a27:	89 0e                	mov    %ecx,(%esi)
  800a29:	eb 06                	jmp    800a31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2b:	85 db                	test   %ebx,%ebx
  800a2d:	74 98                	je     8009c7 <strtol+0x66>
  800a2f:	eb 9e                	jmp    8009cf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a31:	89 c2                	mov    %eax,%edx
  800a33:	f7 da                	neg    %edx
  800a35:	85 ff                	test   %edi,%edi
  800a37:	0f 45 c2             	cmovne %edx,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5f                   	pop    %edi
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	57                   	push   %edi
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 c7                	mov    %eax,%edi
  800a54:	89 c6                	mov    %eax,%esi
  800a56:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 01 00 00 00       	mov    $0x1,%eax
  800a6d:	89 d1                	mov    %edx,%ecx
  800a6f:	89 d3                	mov    %edx,%ebx
  800a71:	89 d7                	mov    %edx,%edi
  800a73:	89 d6                	mov    %edx,%esi
  800a75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 cb                	mov    %ecx,%ebx
  800a94:	89 cf                	mov    %ecx,%edi
  800a96:	89 ce                	mov    %ecx,%esi
  800a98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a9a:	85 c0                	test   %eax,%eax
  800a9c:	7e 17                	jle    800ab5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	50                   	push   %eax
  800aa2:	6a 03                	push   $0x3
  800aa4:	68 9f 25 80 00       	push   $0x80259f
  800aa9:	6a 23                	push   $0x23
  800aab:	68 bc 25 80 00       	push   $0x8025bc
  800ab0:	e8 b3 13 00 00       	call   801e68 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	89 d1                	mov    %edx,%ecx
  800acf:	89 d3                	mov    %edx,%ebx
  800ad1:	89 d7                	mov    %edx,%edi
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_yield>:

void
sys_yield(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	be 00 00 00 00       	mov    $0x0,%esi
  800b09:	b8 04 00 00 00       	mov    $0x4,%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b17:	89 f7                	mov    %esi,%edi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 04                	push   $0x4
  800b25:	68 9f 25 80 00       	push   $0x80259f
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 bc 25 80 00       	push   $0x8025bc
  800b31:	e8 32 13 00 00       	call   801e68 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b58:	8b 75 18             	mov    0x18(%ebp),%esi
  800b5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 05                	push   $0x5
  800b67:	68 9f 25 80 00       	push   $0x80259f
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 bc 25 80 00       	push   $0x8025bc
  800b73:	e8 f0 12 00 00       	call   801e68 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800b93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b96:	8b 55 08             	mov    0x8(%ebp),%edx
  800b99:	89 df                	mov    %ebx,%edi
  800b9b:	89 de                	mov    %ebx,%esi
  800b9d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 06                	push   $0x6
  800ba9:	68 9f 25 80 00       	push   $0x80259f
  800bae:	6a 23                	push   $0x23
  800bb0:	68 bc 25 80 00       	push   $0x8025bc
  800bb5:	e8 ae 12 00 00       	call   801e68 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 08                	push   $0x8
  800beb:	68 9f 25 80 00       	push   $0x80259f
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 bc 25 80 00       	push   $0x8025bc
  800bf7:	e8 6c 12 00 00       	call   801e68 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 09 00 00 00       	mov    $0x9,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 09                	push   $0x9
  800c2d:	68 9f 25 80 00       	push   $0x80259f
  800c32:	6a 23                	push   $0x23
  800c34:	68 bc 25 80 00       	push   $0x8025bc
  800c39:	e8 2a 12 00 00       	call   801e68 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 0a                	push   $0xa
  800c6f:	68 9f 25 80 00       	push   $0x80259f
  800c74:	6a 23                	push   $0x23
  800c76:	68 bc 25 80 00       	push   $0x8025bc
  800c7b:	e8 e8 11 00 00       	call   801e68 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0d                	push   $0xd
  800cd3:	68 9f 25 80 00       	push   $0x80259f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 bc 25 80 00       	push   $0x8025bc
  800cdf:	e8 84 11 00 00       	call   801e68 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	05 00 00 00 30       	add    $0x30000000,%eax
  800d16:	c1 e8 0c             	shr    $0xc,%eax
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	05 00 00 00 30       	add    $0x30000000,%eax
  800d26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d2b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d38:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d3d:	89 c2                	mov    %eax,%edx
  800d3f:	c1 ea 16             	shr    $0x16,%edx
  800d42:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d49:	f6 c2 01             	test   $0x1,%dl
  800d4c:	74 11                	je     800d5f <fd_alloc+0x2d>
  800d4e:	89 c2                	mov    %eax,%edx
  800d50:	c1 ea 0c             	shr    $0xc,%edx
  800d53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d5a:	f6 c2 01             	test   $0x1,%dl
  800d5d:	75 09                	jne    800d68 <fd_alloc+0x36>
			*fd_store = fd;
  800d5f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
  800d66:	eb 17                	jmp    800d7f <fd_alloc+0x4d>
  800d68:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d6d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d72:	75 c9                	jne    800d3d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d74:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d7a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d87:	83 f8 1f             	cmp    $0x1f,%eax
  800d8a:	77 36                	ja     800dc2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d8c:	c1 e0 0c             	shl    $0xc,%eax
  800d8f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d94:	89 c2                	mov    %eax,%edx
  800d96:	c1 ea 16             	shr    $0x16,%edx
  800d99:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da0:	f6 c2 01             	test   $0x1,%dl
  800da3:	74 24                	je     800dc9 <fd_lookup+0x48>
  800da5:	89 c2                	mov    %eax,%edx
  800da7:	c1 ea 0c             	shr    $0xc,%edx
  800daa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db1:	f6 c2 01             	test   $0x1,%dl
  800db4:	74 1a                	je     800dd0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db9:	89 02                	mov    %eax,(%edx)
	return 0;
  800dbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc0:	eb 13                	jmp    800dd5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc7:	eb 0c                	jmp    800dd5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dce:	eb 05                	jmp    800dd5 <fd_lookup+0x54>
  800dd0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	83 ec 08             	sub    $0x8,%esp
  800ddd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de0:	ba 48 26 80 00       	mov    $0x802648,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800de5:	eb 13                	jmp    800dfa <dev_lookup+0x23>
  800de7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800dea:	39 08                	cmp    %ecx,(%eax)
  800dec:	75 0c                	jne    800dfa <dev_lookup+0x23>
			*dev = devtab[i];
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
  800df8:	eb 2e                	jmp    800e28 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800dfa:	8b 02                	mov    (%edx),%eax
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	75 e7                	jne    800de7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e00:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800e05:	8b 40 48             	mov    0x48(%eax),%eax
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	51                   	push   %ecx
  800e0c:	50                   	push   %eax
  800e0d:	68 cc 25 80 00       	push   $0x8025cc
  800e12:	e8 3c f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 10             	sub    $0x10,%esp
  800e32:	8b 75 08             	mov    0x8(%ebp),%esi
  800e35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e3b:	50                   	push   %eax
  800e3c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e42:	c1 e8 0c             	shr    $0xc,%eax
  800e45:	50                   	push   %eax
  800e46:	e8 36 ff ff ff       	call   800d81 <fd_lookup>
  800e4b:	83 c4 08             	add    $0x8,%esp
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	78 05                	js     800e57 <fd_close+0x2d>
	    || fd != fd2)
  800e52:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e55:	74 0c                	je     800e63 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e57:	84 db                	test   %bl,%bl
  800e59:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5e:	0f 44 c2             	cmove  %edx,%eax
  800e61:	eb 41                	jmp    800ea4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e69:	50                   	push   %eax
  800e6a:	ff 36                	pushl  (%esi)
  800e6c:	e8 66 ff ff ff       	call   800dd7 <dev_lookup>
  800e71:	89 c3                	mov    %eax,%ebx
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	78 1a                	js     800e94 <fd_close+0x6a>
		if (dev->dev_close)
  800e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	74 0b                	je     800e94 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	56                   	push   %esi
  800e8d:	ff d0                	call   *%eax
  800e8f:	89 c3                	mov    %eax,%ebx
  800e91:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e94:	83 ec 08             	sub    $0x8,%esp
  800e97:	56                   	push   %esi
  800e98:	6a 00                	push   $0x0
  800e9a:	e8 e1 fc ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	89 d8                	mov    %ebx,%eax
}
  800ea4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb4:	50                   	push   %eax
  800eb5:	ff 75 08             	pushl  0x8(%ebp)
  800eb8:	e8 c4 fe ff ff       	call   800d81 <fd_lookup>
  800ebd:	83 c4 08             	add    $0x8,%esp
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 10                	js     800ed4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	6a 01                	push   $0x1
  800ec9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecc:	e8 59 ff ff ff       	call   800e2a <fd_close>
  800ed1:	83 c4 10             	add    $0x10,%esp
}
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    

00800ed6 <close_all>:

void
close_all(void)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	53                   	push   %ebx
  800ee6:	e8 c0 ff ff ff       	call   800eab <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800eeb:	83 c3 01             	add    $0x1,%ebx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	83 fb 20             	cmp    $0x20,%ebx
  800ef4:	75 ec                	jne    800ee2 <close_all+0xc>
		close(i);
}
  800ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 2c             	sub    $0x2c,%esp
  800f04:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f07:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 75 08             	pushl  0x8(%ebp)
  800f0e:	e8 6e fe ff ff       	call   800d81 <fd_lookup>
  800f13:	83 c4 08             	add    $0x8,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	0f 88 c1 00 00 00    	js     800fdf <dup+0xe4>
		return r;
	close(newfdnum);
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	56                   	push   %esi
  800f22:	e8 84 ff ff ff       	call   800eab <close>

	newfd = INDEX2FD(newfdnum);
  800f27:	89 f3                	mov    %esi,%ebx
  800f29:	c1 e3 0c             	shl    $0xc,%ebx
  800f2c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f32:	83 c4 04             	add    $0x4,%esp
  800f35:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f38:	e8 de fd ff ff       	call   800d1b <fd2data>
  800f3d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f3f:	89 1c 24             	mov    %ebx,(%esp)
  800f42:	e8 d4 fd ff ff       	call   800d1b <fd2data>
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f4d:	89 f8                	mov    %edi,%eax
  800f4f:	c1 e8 16             	shr    $0x16,%eax
  800f52:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f59:	a8 01                	test   $0x1,%al
  800f5b:	74 37                	je     800f94 <dup+0x99>
  800f5d:	89 f8                	mov    %edi,%eax
  800f5f:	c1 e8 0c             	shr    $0xc,%eax
  800f62:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	74 26                	je     800f94 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f6e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	25 07 0e 00 00       	and    $0xe07,%eax
  800f7d:	50                   	push   %eax
  800f7e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f81:	6a 00                	push   $0x0
  800f83:	57                   	push   %edi
  800f84:	6a 00                	push   $0x0
  800f86:	e8 b3 fb ff ff       	call   800b3e <sys_page_map>
  800f8b:	89 c7                	mov    %eax,%edi
  800f8d:	83 c4 20             	add    $0x20,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 2e                	js     800fc2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f97:	89 d0                	mov    %edx,%eax
  800f99:	c1 e8 0c             	shr    $0xc,%eax
  800f9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fab:	50                   	push   %eax
  800fac:	53                   	push   %ebx
  800fad:	6a 00                	push   $0x0
  800faf:	52                   	push   %edx
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 87 fb ff ff       	call   800b3e <sys_page_map>
  800fb7:	89 c7                	mov    %eax,%edi
  800fb9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fbc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fbe:	85 ff                	test   %edi,%edi
  800fc0:	79 1d                	jns    800fdf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fc2:	83 ec 08             	sub    $0x8,%esp
  800fc5:	53                   	push   %ebx
  800fc6:	6a 00                	push   $0x0
  800fc8:	e8 b3 fb ff ff       	call   800b80 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fcd:	83 c4 08             	add    $0x8,%esp
  800fd0:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 a6 fb ff ff       	call   800b80 <sys_page_unmap>
	return r;
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	89 f8                	mov    %edi,%eax
}
  800fdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	53                   	push   %ebx
  800feb:	83 ec 14             	sub    $0x14,%esp
  800fee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ff1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	53                   	push   %ebx
  800ff6:	e8 86 fd ff ff       	call   800d81 <fd_lookup>
  800ffb:	83 c4 08             	add    $0x8,%esp
  800ffe:	89 c2                	mov    %eax,%edx
  801000:	85 c0                	test   %eax,%eax
  801002:	78 6d                	js     801071 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801004:	83 ec 08             	sub    $0x8,%esp
  801007:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80100e:	ff 30                	pushl  (%eax)
  801010:	e8 c2 fd ff ff       	call   800dd7 <dev_lookup>
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 4c                	js     801068 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80101c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101f:	8b 42 08             	mov    0x8(%edx),%eax
  801022:	83 e0 03             	and    $0x3,%eax
  801025:	83 f8 01             	cmp    $0x1,%eax
  801028:	75 21                	jne    80104b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80102a:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80102f:	8b 40 48             	mov    0x48(%eax),%eax
  801032:	83 ec 04             	sub    $0x4,%esp
  801035:	53                   	push   %ebx
  801036:	50                   	push   %eax
  801037:	68 0d 26 80 00       	push   $0x80260d
  80103c:	e8 12 f1 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801049:	eb 26                	jmp    801071 <read+0x8a>
	}
	if (!dev->dev_read)
  80104b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104e:	8b 40 08             	mov    0x8(%eax),%eax
  801051:	85 c0                	test   %eax,%eax
  801053:	74 17                	je     80106c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801055:	83 ec 04             	sub    $0x4,%esp
  801058:	ff 75 10             	pushl  0x10(%ebp)
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	52                   	push   %edx
  80105f:	ff d0                	call   *%eax
  801061:	89 c2                	mov    %eax,%edx
  801063:	83 c4 10             	add    $0x10,%esp
  801066:	eb 09                	jmp    801071 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801068:	89 c2                	mov    %eax,%edx
  80106a:	eb 05                	jmp    801071 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80106c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801071:	89 d0                	mov    %edx,%eax
  801073:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	8b 7d 08             	mov    0x8(%ebp),%edi
  801084:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801087:	bb 00 00 00 00       	mov    $0x0,%ebx
  80108c:	eb 21                	jmp    8010af <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80108e:	83 ec 04             	sub    $0x4,%esp
  801091:	89 f0                	mov    %esi,%eax
  801093:	29 d8                	sub    %ebx,%eax
  801095:	50                   	push   %eax
  801096:	89 d8                	mov    %ebx,%eax
  801098:	03 45 0c             	add    0xc(%ebp),%eax
  80109b:	50                   	push   %eax
  80109c:	57                   	push   %edi
  80109d:	e8 45 ff ff ff       	call   800fe7 <read>
		if (m < 0)
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	85 c0                	test   %eax,%eax
  8010a7:	78 10                	js     8010b9 <readn+0x41>
			return m;
		if (m == 0)
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	74 0a                	je     8010b7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ad:	01 c3                	add    %eax,%ebx
  8010af:	39 f3                	cmp    %esi,%ebx
  8010b1:	72 db                	jb     80108e <readn+0x16>
  8010b3:	89 d8                	mov    %ebx,%eax
  8010b5:	eb 02                	jmp    8010b9 <readn+0x41>
  8010b7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 14             	sub    $0x14,%esp
  8010c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ce:	50                   	push   %eax
  8010cf:	53                   	push   %ebx
  8010d0:	e8 ac fc ff ff       	call   800d81 <fd_lookup>
  8010d5:	83 c4 08             	add    $0x8,%esp
  8010d8:	89 c2                	mov    %eax,%edx
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 68                	js     801146 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010de:	83 ec 08             	sub    $0x8,%esp
  8010e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e8:	ff 30                	pushl  (%eax)
  8010ea:	e8 e8 fc ff ff       	call   800dd7 <dev_lookup>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 47                	js     80113d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010fd:	75 21                	jne    801120 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ff:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801104:	8b 40 48             	mov    0x48(%eax),%eax
  801107:	83 ec 04             	sub    $0x4,%esp
  80110a:	53                   	push   %ebx
  80110b:	50                   	push   %eax
  80110c:	68 29 26 80 00       	push   $0x802629
  801111:	e8 3d f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80111e:	eb 26                	jmp    801146 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801120:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801123:	8b 52 0c             	mov    0xc(%edx),%edx
  801126:	85 d2                	test   %edx,%edx
  801128:	74 17                	je     801141 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80112a:	83 ec 04             	sub    $0x4,%esp
  80112d:	ff 75 10             	pushl  0x10(%ebp)
  801130:	ff 75 0c             	pushl  0xc(%ebp)
  801133:	50                   	push   %eax
  801134:	ff d2                	call   *%edx
  801136:	89 c2                	mov    %eax,%edx
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	eb 09                	jmp    801146 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	eb 05                	jmp    801146 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801141:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801146:	89 d0                	mov    %edx,%eax
  801148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <seek>:

int
seek(int fdnum, off_t offset)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801153:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801156:	50                   	push   %eax
  801157:	ff 75 08             	pushl  0x8(%ebp)
  80115a:	e8 22 fc ff ff       	call   800d81 <fd_lookup>
  80115f:	83 c4 08             	add    $0x8,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	78 0e                	js     801174 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801166:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801169:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80116f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	53                   	push   %ebx
  80117a:	83 ec 14             	sub    $0x14,%esp
  80117d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801180:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801183:	50                   	push   %eax
  801184:	53                   	push   %ebx
  801185:	e8 f7 fb ff ff       	call   800d81 <fd_lookup>
  80118a:	83 c4 08             	add    $0x8,%esp
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 65                	js     8011f8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801193:	83 ec 08             	sub    $0x8,%esp
  801196:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119d:	ff 30                	pushl  (%eax)
  80119f:	e8 33 fc ff ff       	call   800dd7 <dev_lookup>
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 44                	js     8011ef <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b2:	75 21                	jne    8011d5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011b4:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b9:	8b 40 48             	mov    0x48(%eax),%eax
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	53                   	push   %ebx
  8011c0:	50                   	push   %eax
  8011c1:	68 ec 25 80 00       	push   $0x8025ec
  8011c6:	e8 88 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d3:	eb 23                	jmp    8011f8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d8:	8b 52 18             	mov    0x18(%edx),%edx
  8011db:	85 d2                	test   %edx,%edx
  8011dd:	74 14                	je     8011f3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011df:	83 ec 08             	sub    $0x8,%esp
  8011e2:	ff 75 0c             	pushl  0xc(%ebp)
  8011e5:	50                   	push   %eax
  8011e6:	ff d2                	call   *%edx
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	eb 09                	jmp    8011f8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	eb 05                	jmp    8011f8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011f8:	89 d0                	mov    %edx,%eax
  8011fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    

008011ff <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	53                   	push   %ebx
  801203:	83 ec 14             	sub    $0x14,%esp
  801206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801209:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	ff 75 08             	pushl  0x8(%ebp)
  801210:	e8 6c fb ff ff       	call   800d81 <fd_lookup>
  801215:	83 c4 08             	add    $0x8,%esp
  801218:	89 c2                	mov    %eax,%edx
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 58                	js     801276 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121e:	83 ec 08             	sub    $0x8,%esp
  801221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801228:	ff 30                	pushl  (%eax)
  80122a:	e8 a8 fb ff ff       	call   800dd7 <dev_lookup>
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	78 37                	js     80126d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801239:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80123d:	74 32                	je     801271 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80123f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801242:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801249:	00 00 00 
	stat->st_isdir = 0;
  80124c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801253:	00 00 00 
	stat->st_dev = dev;
  801256:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	53                   	push   %ebx
  801260:	ff 75 f0             	pushl  -0x10(%ebp)
  801263:	ff 50 14             	call   *0x14(%eax)
  801266:	89 c2                	mov    %eax,%edx
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	eb 09                	jmp    801276 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	eb 05                	jmp    801276 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801271:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801276:	89 d0                	mov    %edx,%eax
  801278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127b:	c9                   	leave  
  80127c:	c3                   	ret    

0080127d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	56                   	push   %esi
  801281:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	6a 00                	push   $0x0
  801287:	ff 75 08             	pushl  0x8(%ebp)
  80128a:	e8 ef 01 00 00       	call   80147e <open>
  80128f:	89 c3                	mov    %eax,%ebx
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	78 1b                	js     8012b3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	50                   	push   %eax
  80129f:	e8 5b ff ff ff       	call   8011ff <fstat>
  8012a4:	89 c6                	mov    %eax,%esi
	close(fd);
  8012a6:	89 1c 24             	mov    %ebx,(%esp)
  8012a9:	e8 fd fb ff ff       	call   800eab <close>
	return r;
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	89 f0                	mov    %esi,%eax
}
  8012b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	89 c6                	mov    %eax,%esi
  8012c1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012c3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012ca:	75 12                	jne    8012de <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012cc:	83 ec 0c             	sub    $0xc,%esp
  8012cf:	6a 01                	push   $0x1
  8012d1:	e8 9d 0c 00 00       	call   801f73 <ipc_find_env>
  8012d6:	a3 00 40 80 00       	mov    %eax,0x804000
  8012db:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012de:	6a 07                	push   $0x7
  8012e0:	68 00 50 80 00       	push   $0x805000
  8012e5:	56                   	push   %esi
  8012e6:	ff 35 00 40 80 00    	pushl  0x804000
  8012ec:	e8 33 0c 00 00       	call   801f24 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012f1:	83 c4 0c             	add    $0xc,%esp
  8012f4:	6a 00                	push   $0x0
  8012f6:	53                   	push   %ebx
  8012f7:	6a 00                	push   $0x0
  8012f9:	e8 b0 0b 00 00       	call   801eae <ipc_recv>
}
  8012fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80130b:	8b 45 08             	mov    0x8(%ebp),%eax
  80130e:	8b 40 0c             	mov    0xc(%eax),%eax
  801311:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801316:	8b 45 0c             	mov    0xc(%ebp),%eax
  801319:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80131e:	ba 00 00 00 00       	mov    $0x0,%edx
  801323:	b8 02 00 00 00       	mov    $0x2,%eax
  801328:	e8 8d ff ff ff       	call   8012ba <fsipc>
}
  80132d:	c9                   	leave  
  80132e:	c3                   	ret    

0080132f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801335:	8b 45 08             	mov    0x8(%ebp),%eax
  801338:	8b 40 0c             	mov    0xc(%eax),%eax
  80133b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801340:	ba 00 00 00 00       	mov    $0x0,%edx
  801345:	b8 06 00 00 00       	mov    $0x6,%eax
  80134a:	e8 6b ff ff ff       	call   8012ba <fsipc>
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    

00801351 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801351:	55                   	push   %ebp
  801352:	89 e5                	mov    %esp,%ebp
  801354:	53                   	push   %ebx
  801355:	83 ec 04             	sub    $0x4,%esp
  801358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80135b:	8b 45 08             	mov    0x8(%ebp),%eax
  80135e:	8b 40 0c             	mov    0xc(%eax),%eax
  801361:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801366:	ba 00 00 00 00       	mov    $0x0,%edx
  80136b:	b8 05 00 00 00       	mov    $0x5,%eax
  801370:	e8 45 ff ff ff       	call   8012ba <fsipc>
  801375:	85 c0                	test   %eax,%eax
  801377:	78 2c                	js     8013a5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	68 00 50 80 00       	push   $0x805000
  801381:	53                   	push   %ebx
  801382:	e8 71 f3 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801387:	a1 80 50 80 00       	mov    0x805080,%eax
  80138c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801392:	a1 84 50 80 00       	mov    0x805084,%eax
  801397:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a8:	c9                   	leave  
  8013a9:	c3                   	ret    

008013aa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8013ba:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013c0:	a3 04 50 80 00       	mov    %eax,0x805004
  8013c5:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8013ca:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8013cf:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013d2:	53                   	push   %ebx
  8013d3:	ff 75 0c             	pushl  0xc(%ebp)
  8013d6:	68 08 50 80 00       	push   $0x805008
  8013db:	e8 aa f4 ff ff       	call   80088a <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8013e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e5:	b8 04 00 00 00       	mov    $0x4,%eax
  8013ea:	e8 cb fe ff ff       	call   8012ba <fsipc>
  8013ef:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8013f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	56                   	push   %esi
  801400:	53                   	push   %ebx
  801401:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	8b 40 0c             	mov    0xc(%eax),%eax
  80140a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80140f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801415:	ba 00 00 00 00       	mov    $0x0,%edx
  80141a:	b8 03 00 00 00       	mov    $0x3,%eax
  80141f:	e8 96 fe ff ff       	call   8012ba <fsipc>
  801424:	89 c3                	mov    %eax,%ebx
  801426:	85 c0                	test   %eax,%eax
  801428:	78 4b                	js     801475 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80142a:	39 c6                	cmp    %eax,%esi
  80142c:	73 16                	jae    801444 <devfile_read+0x48>
  80142e:	68 5c 26 80 00       	push   $0x80265c
  801433:	68 63 26 80 00       	push   $0x802663
  801438:	6a 7c                	push   $0x7c
  80143a:	68 78 26 80 00       	push   $0x802678
  80143f:	e8 24 0a 00 00       	call   801e68 <_panic>
	assert(r <= PGSIZE);
  801444:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801449:	7e 16                	jle    801461 <devfile_read+0x65>
  80144b:	68 83 26 80 00       	push   $0x802683
  801450:	68 63 26 80 00       	push   $0x802663
  801455:	6a 7d                	push   $0x7d
  801457:	68 78 26 80 00       	push   $0x802678
  80145c:	e8 07 0a 00 00       	call   801e68 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801461:	83 ec 04             	sub    $0x4,%esp
  801464:	50                   	push   %eax
  801465:	68 00 50 80 00       	push   $0x805000
  80146a:	ff 75 0c             	pushl  0xc(%ebp)
  80146d:	e8 18 f4 ff ff       	call   80088a <memmove>
	return r;
  801472:	83 c4 10             	add    $0x10,%esp
}
  801475:	89 d8                	mov    %ebx,%eax
  801477:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147a:	5b                   	pop    %ebx
  80147b:	5e                   	pop    %esi
  80147c:	5d                   	pop    %ebp
  80147d:	c3                   	ret    

0080147e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	53                   	push   %ebx
  801482:	83 ec 20             	sub    $0x20,%esp
  801485:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801488:	53                   	push   %ebx
  801489:	e8 31 f2 ff ff       	call   8006bf <strlen>
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801496:	7f 67                	jg     8014ff <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801498:	83 ec 0c             	sub    $0xc,%esp
  80149b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149e:	50                   	push   %eax
  80149f:	e8 8e f8 ff ff       	call   800d32 <fd_alloc>
  8014a4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 57                	js     801504 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	53                   	push   %ebx
  8014b1:	68 00 50 80 00       	push   $0x805000
  8014b6:	e8 3d f2 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014be:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cb:	e8 ea fd ff ff       	call   8012ba <fsipc>
  8014d0:	89 c3                	mov    %eax,%ebx
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	79 14                	jns    8014ed <open+0x6f>
		fd_close(fd, 0);
  8014d9:	83 ec 08             	sub    $0x8,%esp
  8014dc:	6a 00                	push   $0x0
  8014de:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e1:	e8 44 f9 ff ff       	call   800e2a <fd_close>
		return r;
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	89 da                	mov    %ebx,%edx
  8014eb:	eb 17                	jmp    801504 <open+0x86>
	}

	return fd2num(fd);
  8014ed:	83 ec 0c             	sub    $0xc,%esp
  8014f0:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f3:	e8 13 f8 ff ff       	call   800d0b <fd2num>
  8014f8:	89 c2                	mov    %eax,%edx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	eb 05                	jmp    801504 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014ff:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801504:	89 d0                	mov    %edx,%eax
  801506:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801511:	ba 00 00 00 00       	mov    $0x0,%edx
  801516:	b8 08 00 00 00       	mov    $0x8,%eax
  80151b:	e8 9a fd ff ff       	call   8012ba <fsipc>
}
  801520:	c9                   	leave  
  801521:	c3                   	ret    

00801522 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
  801525:	56                   	push   %esi
  801526:	53                   	push   %ebx
  801527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80152a:	83 ec 0c             	sub    $0xc,%esp
  80152d:	ff 75 08             	pushl  0x8(%ebp)
  801530:	e8 e6 f7 ff ff       	call   800d1b <fd2data>
  801535:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	68 8f 26 80 00       	push   $0x80268f
  80153f:	53                   	push   %ebx
  801540:	e8 b3 f1 ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801545:	8b 46 04             	mov    0x4(%esi),%eax
  801548:	2b 06                	sub    (%esi),%eax
  80154a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801550:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801557:	00 00 00 
	stat->st_dev = &devpipe;
  80155a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801561:	30 80 00 
	return 0;
}
  801564:	b8 00 00 00 00       	mov    $0x0,%eax
  801569:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5e                   	pop    %esi
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	53                   	push   %ebx
  801574:	83 ec 0c             	sub    $0xc,%esp
  801577:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80157a:	53                   	push   %ebx
  80157b:	6a 00                	push   $0x0
  80157d:	e8 fe f5 ff ff       	call   800b80 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801582:	89 1c 24             	mov    %ebx,(%esp)
  801585:	e8 91 f7 ff ff       	call   800d1b <fd2data>
  80158a:	83 c4 08             	add    $0x8,%esp
  80158d:	50                   	push   %eax
  80158e:	6a 00                	push   $0x0
  801590:	e8 eb f5 ff ff       	call   800b80 <sys_page_unmap>
}
  801595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801598:	c9                   	leave  
  801599:	c3                   	ret    

0080159a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	57                   	push   %edi
  80159e:	56                   	push   %esi
  80159f:	53                   	push   %ebx
  8015a0:	83 ec 1c             	sub    $0x1c,%esp
  8015a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015a6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015a8:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015ad:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015b6:	e8 f1 09 00 00       	call   801fac <pageref>
  8015bb:	89 c3                	mov    %eax,%ebx
  8015bd:	89 3c 24             	mov    %edi,(%esp)
  8015c0:	e8 e7 09 00 00       	call   801fac <pageref>
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	39 c3                	cmp    %eax,%ebx
  8015ca:	0f 94 c1             	sete   %cl
  8015cd:	0f b6 c9             	movzbl %cl,%ecx
  8015d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015d3:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  8015d9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015dc:	39 ce                	cmp    %ecx,%esi
  8015de:	74 1b                	je     8015fb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015e0:	39 c3                	cmp    %eax,%ebx
  8015e2:	75 c4                	jne    8015a8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015e4:	8b 42 58             	mov    0x58(%edx),%eax
  8015e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ea:	50                   	push   %eax
  8015eb:	56                   	push   %esi
  8015ec:	68 96 26 80 00       	push   $0x802696
  8015f1:	e8 5d eb ff ff       	call   800153 <cprintf>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	eb ad                	jmp    8015a8 <_pipeisclosed+0xe>
	}
}
  8015fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5f                   	pop    %edi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	57                   	push   %edi
  80160a:	56                   	push   %esi
  80160b:	53                   	push   %ebx
  80160c:	83 ec 28             	sub    $0x28,%esp
  80160f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801612:	56                   	push   %esi
  801613:	e8 03 f7 ff ff       	call   800d1b <fd2data>
  801618:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	bf 00 00 00 00       	mov    $0x0,%edi
  801622:	eb 4b                	jmp    80166f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801624:	89 da                	mov    %ebx,%edx
  801626:	89 f0                	mov    %esi,%eax
  801628:	e8 6d ff ff ff       	call   80159a <_pipeisclosed>
  80162d:	85 c0                	test   %eax,%eax
  80162f:	75 48                	jne    801679 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801631:	e8 a6 f4 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801636:	8b 43 04             	mov    0x4(%ebx),%eax
  801639:	8b 0b                	mov    (%ebx),%ecx
  80163b:	8d 51 20             	lea    0x20(%ecx),%edx
  80163e:	39 d0                	cmp    %edx,%eax
  801640:	73 e2                	jae    801624 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801642:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801645:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801649:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80164c:	89 c2                	mov    %eax,%edx
  80164e:	c1 fa 1f             	sar    $0x1f,%edx
  801651:	89 d1                	mov    %edx,%ecx
  801653:	c1 e9 1b             	shr    $0x1b,%ecx
  801656:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801659:	83 e2 1f             	and    $0x1f,%edx
  80165c:	29 ca                	sub    %ecx,%edx
  80165e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801662:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801666:	83 c0 01             	add    $0x1,%eax
  801669:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80166c:	83 c7 01             	add    $0x1,%edi
  80166f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801672:	75 c2                	jne    801636 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801674:	8b 45 10             	mov    0x10(%ebp),%eax
  801677:	eb 05                	jmp    80167e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80167e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801681:	5b                   	pop    %ebx
  801682:	5e                   	pop    %esi
  801683:	5f                   	pop    %edi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	57                   	push   %edi
  80168a:	56                   	push   %esi
  80168b:	53                   	push   %ebx
  80168c:	83 ec 18             	sub    $0x18,%esp
  80168f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801692:	57                   	push   %edi
  801693:	e8 83 f6 ff ff       	call   800d1b <fd2data>
  801698:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a2:	eb 3d                	jmp    8016e1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016a4:	85 db                	test   %ebx,%ebx
  8016a6:	74 04                	je     8016ac <devpipe_read+0x26>
				return i;
  8016a8:	89 d8                	mov    %ebx,%eax
  8016aa:	eb 44                	jmp    8016f0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016ac:	89 f2                	mov    %esi,%edx
  8016ae:	89 f8                	mov    %edi,%eax
  8016b0:	e8 e5 fe ff ff       	call   80159a <_pipeisclosed>
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	75 32                	jne    8016eb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016b9:	e8 1e f4 ff ff       	call   800adc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016be:	8b 06                	mov    (%esi),%eax
  8016c0:	3b 46 04             	cmp    0x4(%esi),%eax
  8016c3:	74 df                	je     8016a4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016c5:	99                   	cltd   
  8016c6:	c1 ea 1b             	shr    $0x1b,%edx
  8016c9:	01 d0                	add    %edx,%eax
  8016cb:	83 e0 1f             	and    $0x1f,%eax
  8016ce:	29 d0                	sub    %edx,%eax
  8016d0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016db:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016de:	83 c3 01             	add    $0x1,%ebx
  8016e1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016e4:	75 d8                	jne    8016be <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e9:	eb 05                	jmp    8016f0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016eb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f3:	5b                   	pop    %ebx
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    

008016f8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801700:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801703:	50                   	push   %eax
  801704:	e8 29 f6 ff ff       	call   800d32 <fd_alloc>
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	85 c0                	test   %eax,%eax
  801710:	0f 88 2c 01 00 00    	js     801842 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801716:	83 ec 04             	sub    $0x4,%esp
  801719:	68 07 04 00 00       	push   $0x407
  80171e:	ff 75 f4             	pushl  -0xc(%ebp)
  801721:	6a 00                	push   $0x0
  801723:	e8 d3 f3 ff ff       	call   800afb <sys_page_alloc>
  801728:	83 c4 10             	add    $0x10,%esp
  80172b:	89 c2                	mov    %eax,%edx
  80172d:	85 c0                	test   %eax,%eax
  80172f:	0f 88 0d 01 00 00    	js     801842 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801735:	83 ec 0c             	sub    $0xc,%esp
  801738:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	e8 f1 f5 ff ff       	call   800d32 <fd_alloc>
  801741:	89 c3                	mov    %eax,%ebx
  801743:	83 c4 10             	add    $0x10,%esp
  801746:	85 c0                	test   %eax,%eax
  801748:	0f 88 e2 00 00 00    	js     801830 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174e:	83 ec 04             	sub    $0x4,%esp
  801751:	68 07 04 00 00       	push   $0x407
  801756:	ff 75 f0             	pushl  -0x10(%ebp)
  801759:	6a 00                	push   $0x0
  80175b:	e8 9b f3 ff ff       	call   800afb <sys_page_alloc>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	0f 88 c3 00 00 00    	js     801830 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	ff 75 f4             	pushl  -0xc(%ebp)
  801773:	e8 a3 f5 ff ff       	call   800d1b <fd2data>
  801778:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177a:	83 c4 0c             	add    $0xc,%esp
  80177d:	68 07 04 00 00       	push   $0x407
  801782:	50                   	push   %eax
  801783:	6a 00                	push   $0x0
  801785:	e8 71 f3 ff ff       	call   800afb <sys_page_alloc>
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	0f 88 89 00 00 00    	js     801820 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801797:	83 ec 0c             	sub    $0xc,%esp
  80179a:	ff 75 f0             	pushl  -0x10(%ebp)
  80179d:	e8 79 f5 ff ff       	call   800d1b <fd2data>
  8017a2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017a9:	50                   	push   %eax
  8017aa:	6a 00                	push   $0x0
  8017ac:	56                   	push   %esi
  8017ad:	6a 00                	push   $0x0
  8017af:	e8 8a f3 ff ff       	call   800b3e <sys_page_map>
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	83 c4 20             	add    $0x20,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 55                	js     801812 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017bd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017d2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017e0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ed:	e8 19 f5 ff ff       	call   800d0b <fd2num>
  8017f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017f7:	83 c4 04             	add    $0x4,%esp
  8017fa:	ff 75 f0             	pushl  -0x10(%ebp)
  8017fd:	e8 09 f5 ff ff       	call   800d0b <fd2num>
  801802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801805:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	ba 00 00 00 00       	mov    $0x0,%edx
  801810:	eb 30                	jmp    801842 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	56                   	push   %esi
  801816:	6a 00                	push   $0x0
  801818:	e8 63 f3 ff ff       	call   800b80 <sys_page_unmap>
  80181d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801820:	83 ec 08             	sub    $0x8,%esp
  801823:	ff 75 f0             	pushl  -0x10(%ebp)
  801826:	6a 00                	push   $0x0
  801828:	e8 53 f3 ff ff       	call   800b80 <sys_page_unmap>
  80182d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	ff 75 f4             	pushl  -0xc(%ebp)
  801836:	6a 00                	push   $0x0
  801838:	e8 43 f3 ff ff       	call   800b80 <sys_page_unmap>
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801842:	89 d0                	mov    %edx,%eax
  801844:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801847:	5b                   	pop    %ebx
  801848:	5e                   	pop    %esi
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801854:	50                   	push   %eax
  801855:	ff 75 08             	pushl  0x8(%ebp)
  801858:	e8 24 f5 ff ff       	call   800d81 <fd_lookup>
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	85 c0                	test   %eax,%eax
  801862:	78 18                	js     80187c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	ff 75 f4             	pushl  -0xc(%ebp)
  80186a:	e8 ac f4 ff ff       	call   800d1b <fd2data>
	return _pipeisclosed(fd, p);
  80186f:	89 c2                	mov    %eax,%edx
  801871:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801874:	e8 21 fd ff ff       	call   80159a <_pipeisclosed>
  801879:	83 c4 10             	add    $0x10,%esp
}
  80187c:	c9                   	leave  
  80187d:	c3                   	ret    

0080187e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801884:	68 ae 26 80 00       	push   $0x8026ae
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	e8 67 ee ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801891:	b8 00 00 00 00       	mov    $0x0,%eax
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 10             	sub    $0x10,%esp
  80189f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018a2:	53                   	push   %ebx
  8018a3:	e8 04 07 00 00       	call   801fac <pageref>
  8018a8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018b0:	83 f8 01             	cmp    $0x1,%eax
  8018b3:	75 10                	jne    8018c5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018b5:	83 ec 0c             	sub    $0xc,%esp
  8018b8:	ff 73 0c             	pushl  0xc(%ebx)
  8018bb:	e8 c0 02 00 00       	call   801b80 <nsipc_close>
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018c5:	89 d0                	mov    %edx,%eax
  8018c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    

008018cc <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018d2:	6a 00                	push   $0x0
  8018d4:	ff 75 10             	pushl  0x10(%ebp)
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	ff 70 0c             	pushl  0xc(%eax)
  8018e0:	e8 78 03 00 00       	call   801c5d <nsipc_send>
}
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018ed:	6a 00                	push   $0x0
  8018ef:	ff 75 10             	pushl  0x10(%ebp)
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	ff 70 0c             	pushl  0xc(%eax)
  8018fb:	e8 f1 02 00 00       	call   801bf1 <nsipc_recv>
}
  801900:	c9                   	leave  
  801901:	c3                   	ret    

00801902 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801908:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80190b:	52                   	push   %edx
  80190c:	50                   	push   %eax
  80190d:	e8 6f f4 ff ff       	call   800d81 <fd_lookup>
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	85 c0                	test   %eax,%eax
  801917:	78 17                	js     801930 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801919:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191c:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801922:	39 08                	cmp    %ecx,(%eax)
  801924:	75 05                	jne    80192b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801926:	8b 40 0c             	mov    0xc(%eax),%eax
  801929:	eb 05                	jmp    801930 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80192b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
  801937:	83 ec 1c             	sub    $0x1c,%esp
  80193a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80193c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193f:	50                   	push   %eax
  801940:	e8 ed f3 ff ff       	call   800d32 <fd_alloc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 1b                	js     801969 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	68 07 04 00 00       	push   $0x407
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	6a 00                	push   $0x0
  80195b:	e8 9b f1 ff ff       	call   800afb <sys_page_alloc>
  801960:	89 c3                	mov    %eax,%ebx
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	79 10                	jns    801979 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	56                   	push   %esi
  80196d:	e8 0e 02 00 00       	call   801b80 <nsipc_close>
		return r;
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	89 d8                	mov    %ebx,%eax
  801977:	eb 24                	jmp    80199d <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801979:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801982:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801987:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80198e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801991:	83 ec 0c             	sub    $0xc,%esp
  801994:	50                   	push   %eax
  801995:	e8 71 f3 ff ff       	call   800d0b <fd2num>
  80199a:	83 c4 10             	add    $0x10,%esp
}
  80199d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ad:	e8 50 ff ff ff       	call   801902 <fd2sockid>
		return r;
  8019b2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 1f                	js     8019d7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	ff 75 10             	pushl  0x10(%ebp)
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	50                   	push   %eax
  8019c2:	e8 12 01 00 00       	call   801ad9 <nsipc_accept>
  8019c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ca:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 07                	js     8019d7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019d0:	e8 5d ff ff ff       	call   801932 <alloc_sockfd>
  8019d5:	89 c1                	mov    %eax,%ecx
}
  8019d7:	89 c8                	mov    %ecx,%eax
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	e8 19 ff ff ff       	call   801902 <fd2sockid>
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	78 12                	js     8019ff <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019ed:	83 ec 04             	sub    $0x4,%esp
  8019f0:	ff 75 10             	pushl  0x10(%ebp)
  8019f3:	ff 75 0c             	pushl  0xc(%ebp)
  8019f6:	50                   	push   %eax
  8019f7:	e8 2d 01 00 00       	call   801b29 <nsipc_bind>
  8019fc:	83 c4 10             	add    $0x10,%esp
}
  8019ff:	c9                   	leave  
  801a00:	c3                   	ret    

00801a01 <shutdown>:

int
shutdown(int s, int how)
{
  801a01:	55                   	push   %ebp
  801a02:	89 e5                	mov    %esp,%ebp
  801a04:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	e8 f3 fe ff ff       	call   801902 <fd2sockid>
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	78 0f                	js     801a22 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	ff 75 0c             	pushl  0xc(%ebp)
  801a19:	50                   	push   %eax
  801a1a:	e8 3f 01 00 00       	call   801b5e <nsipc_shutdown>
  801a1f:	83 c4 10             	add    $0x10,%esp
}
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    

00801a24 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2d:	e8 d0 fe ff ff       	call   801902 <fd2sockid>
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 12                	js     801a48 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	ff 75 10             	pushl  0x10(%ebp)
  801a3c:	ff 75 0c             	pushl  0xc(%ebp)
  801a3f:	50                   	push   %eax
  801a40:	e8 55 01 00 00       	call   801b9a <nsipc_connect>
  801a45:	83 c4 10             	add    $0x10,%esp
}
  801a48:	c9                   	leave  
  801a49:	c3                   	ret    

00801a4a <listen>:

int
listen(int s, int backlog)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	e8 aa fe ff ff       	call   801902 <fd2sockid>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 0f                	js     801a6b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	ff 75 0c             	pushl  0xc(%ebp)
  801a62:	50                   	push   %eax
  801a63:	e8 67 01 00 00       	call   801bcf <nsipc_listen>
  801a68:	83 c4 10             	add    $0x10,%esp
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a73:	ff 75 10             	pushl  0x10(%ebp)
  801a76:	ff 75 0c             	pushl  0xc(%ebp)
  801a79:	ff 75 08             	pushl  0x8(%ebp)
  801a7c:	e8 3a 02 00 00       	call   801cbb <nsipc_socket>
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 05                	js     801a8d <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a88:	e8 a5 fe ff ff       	call   801932 <alloc_sockfd>
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 04             	sub    $0x4,%esp
  801a96:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a98:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801a9f:	75 12                	jne    801ab3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	6a 02                	push   $0x2
  801aa6:	e8 c8 04 00 00       	call   801f73 <ipc_find_env>
  801aab:	a3 04 40 80 00       	mov    %eax,0x804004
  801ab0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ab3:	6a 07                	push   $0x7
  801ab5:	68 00 60 80 00       	push   $0x806000
  801aba:	53                   	push   %ebx
  801abb:	ff 35 04 40 80 00    	pushl  0x804004
  801ac1:	e8 5e 04 00 00       	call   801f24 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ac6:	83 c4 0c             	add    $0xc,%esp
  801ac9:	6a 00                	push   $0x0
  801acb:	6a 00                	push   $0x0
  801acd:	6a 00                	push   $0x0
  801acf:	e8 da 03 00 00       	call   801eae <ipc_recv>
}
  801ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    

00801ad9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	56                   	push   %esi
  801add:	53                   	push   %ebx
  801ade:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ae9:	8b 06                	mov    (%esi),%eax
  801aeb:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801af0:	b8 01 00 00 00       	mov    $0x1,%eax
  801af5:	e8 95 ff ff ff       	call   801a8f <nsipc>
  801afa:	89 c3                	mov    %eax,%ebx
  801afc:	85 c0                	test   %eax,%eax
  801afe:	78 20                	js     801b20 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	ff 35 10 60 80 00    	pushl  0x806010
  801b09:	68 00 60 80 00       	push   $0x806000
  801b0e:	ff 75 0c             	pushl  0xc(%ebp)
  801b11:	e8 74 ed ff ff       	call   80088a <memmove>
		*addrlen = ret->ret_addrlen;
  801b16:	a1 10 60 80 00       	mov    0x806010,%eax
  801b1b:	89 06                	mov    %eax,(%esi)
  801b1d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b20:	89 d8                	mov    %ebx,%eax
  801b22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	53                   	push   %ebx
  801b2d:	83 ec 08             	sub    $0x8,%esp
  801b30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b33:	8b 45 08             	mov    0x8(%ebp),%eax
  801b36:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b3b:	53                   	push   %ebx
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	68 04 60 80 00       	push   $0x806004
  801b44:	e8 41 ed ff ff       	call   80088a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b49:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b4f:	b8 02 00 00 00       	mov    $0x2,%eax
  801b54:	e8 36 ff ff ff       	call   801a8f <nsipc>
}
  801b59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b64:	8b 45 08             	mov    0x8(%ebp),%eax
  801b67:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b74:	b8 03 00 00 00       	mov    $0x3,%eax
  801b79:	e8 11 ff ff ff       	call   801a8f <nsipc>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <nsipc_close>:

int
nsipc_close(int s)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b8e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b93:	e8 f7 fe ff ff       	call   801a8f <nsipc>
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 08             	sub    $0x8,%esp
  801ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bac:	53                   	push   %ebx
  801bad:	ff 75 0c             	pushl  0xc(%ebp)
  801bb0:	68 04 60 80 00       	push   $0x806004
  801bb5:	e8 d0 ec ff ff       	call   80088a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bc0:	b8 05 00 00 00       	mov    $0x5,%eax
  801bc5:	e8 c5 fe ff ff       	call   801a8f <nsipc>
}
  801bca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801bdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801be5:	b8 06 00 00 00       	mov    $0x6,%eax
  801bea:	e8 a0 fe ff ff       	call   801a8f <nsipc>
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c01:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c07:	8b 45 14             	mov    0x14(%ebp),%eax
  801c0a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c0f:	b8 07 00 00 00       	mov    $0x7,%eax
  801c14:	e8 76 fe ff ff       	call   801a8f <nsipc>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	78 35                	js     801c54 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c1f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c24:	7f 04                	jg     801c2a <nsipc_recv+0x39>
  801c26:	39 c6                	cmp    %eax,%esi
  801c28:	7d 16                	jge    801c40 <nsipc_recv+0x4f>
  801c2a:	68 ba 26 80 00       	push   $0x8026ba
  801c2f:	68 63 26 80 00       	push   $0x802663
  801c34:	6a 62                	push   $0x62
  801c36:	68 cf 26 80 00       	push   $0x8026cf
  801c3b:	e8 28 02 00 00       	call   801e68 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	50                   	push   %eax
  801c44:	68 00 60 80 00       	push   $0x806000
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	e8 39 ec ff ff       	call   80088a <memmove>
  801c51:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	53                   	push   %ebx
  801c61:	83 ec 04             	sub    $0x4,%esp
  801c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c6f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c75:	7e 16                	jle    801c8d <nsipc_send+0x30>
  801c77:	68 db 26 80 00       	push   $0x8026db
  801c7c:	68 63 26 80 00       	push   $0x802663
  801c81:	6a 6d                	push   $0x6d
  801c83:	68 cf 26 80 00       	push   $0x8026cf
  801c88:	e8 db 01 00 00       	call   801e68 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c8d:	83 ec 04             	sub    $0x4,%esp
  801c90:	53                   	push   %ebx
  801c91:	ff 75 0c             	pushl  0xc(%ebp)
  801c94:	68 0c 60 80 00       	push   $0x80600c
  801c99:	e8 ec eb ff ff       	call   80088a <memmove>
	nsipcbuf.send.req_size = size;
  801c9e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ca4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cac:	b8 08 00 00 00       	mov    $0x8,%eax
  801cb1:	e8 d9 fd ff ff       	call   801a8f <nsipc>
}
  801cb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cd1:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cd9:	b8 09 00 00 00       	mov    $0x9,%eax
  801cde:	e8 ac fd ff ff       	call   801a8f <nsipc>
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ce8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cf5:	68 e7 26 80 00       	push   $0x8026e7
  801cfa:	ff 75 0c             	pushl  0xc(%ebp)
  801cfd:	e8 f6 e9 ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801d02:	b8 00 00 00 00       	mov    $0x0,%eax
  801d07:	c9                   	leave  
  801d08:	c3                   	ret    

00801d09 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	57                   	push   %edi
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d15:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d1a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d20:	eb 2d                	jmp    801d4f <devcons_write+0x46>
		m = n - tot;
  801d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d25:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d27:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d2a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d2f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d32:	83 ec 04             	sub    $0x4,%esp
  801d35:	53                   	push   %ebx
  801d36:	03 45 0c             	add    0xc(%ebp),%eax
  801d39:	50                   	push   %eax
  801d3a:	57                   	push   %edi
  801d3b:	e8 4a eb ff ff       	call   80088a <memmove>
		sys_cputs(buf, m);
  801d40:	83 c4 08             	add    $0x8,%esp
  801d43:	53                   	push   %ebx
  801d44:	57                   	push   %edi
  801d45:	e8 f5 ec ff ff       	call   800a3f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4a:	01 de                	add    %ebx,%esi
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d54:	72 cc                	jb     801d22 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d59:	5b                   	pop    %ebx
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 08             	sub    $0x8,%esp
  801d64:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d6d:	74 2a                	je     801d99 <devcons_read+0x3b>
  801d6f:	eb 05                	jmp    801d76 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d71:	e8 66 ed ff ff       	call   800adc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d76:	e8 e2 ec ff ff       	call   800a5d <sys_cgetc>
  801d7b:	85 c0                	test   %eax,%eax
  801d7d:	74 f2                	je     801d71 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 16                	js     801d99 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d83:	83 f8 04             	cmp    $0x4,%eax
  801d86:	74 0c                	je     801d94 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d88:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d8b:	88 02                	mov    %al,(%edx)
	return 1;
  801d8d:	b8 01 00 00 00       	mov    $0x1,%eax
  801d92:	eb 05                	jmp    801d99 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d94:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801da1:	8b 45 08             	mov    0x8(%ebp),%eax
  801da4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801da7:	6a 01                	push   $0x1
  801da9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	e8 8d ec ff ff       	call   800a3f <sys_cputs>
}
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    

00801db7 <getchar>:

int
getchar(void)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801dbd:	6a 01                	push   $0x1
  801dbf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dc2:	50                   	push   %eax
  801dc3:	6a 00                	push   $0x0
  801dc5:	e8 1d f2 ff ff       	call   800fe7 <read>
	if (r < 0)
  801dca:	83 c4 10             	add    $0x10,%esp
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 0f                	js     801de0 <getchar+0x29>
		return r;
	if (r < 1)
  801dd1:	85 c0                	test   %eax,%eax
  801dd3:	7e 06                	jle    801ddb <getchar+0x24>
		return -E_EOF;
	return c;
  801dd5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dd9:	eb 05                	jmp    801de0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ddb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801de8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801deb:	50                   	push   %eax
  801dec:	ff 75 08             	pushl  0x8(%ebp)
  801def:	e8 8d ef ff ff       	call   800d81 <fd_lookup>
  801df4:	83 c4 10             	add    $0x10,%esp
  801df7:	85 c0                	test   %eax,%eax
  801df9:	78 11                	js     801e0c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfe:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e04:	39 10                	cmp    %edx,(%eax)
  801e06:	0f 94 c0             	sete   %al
  801e09:	0f b6 c0             	movzbl %al,%eax
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <opencons>:

int
opencons(void)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e17:	50                   	push   %eax
  801e18:	e8 15 ef ff ff       	call   800d32 <fd_alloc>
  801e1d:	83 c4 10             	add    $0x10,%esp
		return r;
  801e20:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e22:	85 c0                	test   %eax,%eax
  801e24:	78 3e                	js     801e64 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e26:	83 ec 04             	sub    $0x4,%esp
  801e29:	68 07 04 00 00       	push   $0x407
  801e2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e31:	6a 00                	push   $0x0
  801e33:	e8 c3 ec ff ff       	call   800afb <sys_page_alloc>
  801e38:	83 c4 10             	add    $0x10,%esp
		return r;
  801e3b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 23                	js     801e64 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e41:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e56:	83 ec 0c             	sub    $0xc,%esp
  801e59:	50                   	push   %eax
  801e5a:	e8 ac ee ff ff       	call   800d0b <fd2num>
  801e5f:	89 c2                	mov    %eax,%edx
  801e61:	83 c4 10             	add    $0x10,%esp
}
  801e64:	89 d0                	mov    %edx,%eax
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e6d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e70:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e76:	e8 42 ec ff ff       	call   800abd <sys_getenvid>
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	ff 75 0c             	pushl  0xc(%ebp)
  801e81:	ff 75 08             	pushl  0x8(%ebp)
  801e84:	56                   	push   %esi
  801e85:	50                   	push   %eax
  801e86:	68 f4 26 80 00       	push   $0x8026f4
  801e8b:	e8 c3 e2 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e90:	83 c4 18             	add    $0x18,%esp
  801e93:	53                   	push   %ebx
  801e94:	ff 75 10             	pushl  0x10(%ebp)
  801e97:	e8 66 e2 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801e9c:	c7 04 24 8c 22 80 00 	movl   $0x80228c,(%esp)
  801ea3:	e8 ab e2 ff ff       	call   800153 <cprintf>
  801ea8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eab:	cc                   	int3   
  801eac:	eb fd                	jmp    801eab <_panic+0x43>

00801eae <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	56                   	push   %esi
  801eb2:	53                   	push   %ebx
  801eb3:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	74 0e                	je     801ece <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801ec0:	83 ec 0c             	sub    $0xc,%esp
  801ec3:	50                   	push   %eax
  801ec4:	e8 e2 ed ff ff       	call   800cab <sys_ipc_recv>
  801ec9:	83 c4 10             	add    $0x10,%esp
  801ecc:	eb 10                	jmp    801ede <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801ece:	83 ec 0c             	sub    $0xc,%esp
  801ed1:	68 00 00 c0 ee       	push   $0xeec00000
  801ed6:	e8 d0 ed ff ff       	call   800cab <sys_ipc_recv>
  801edb:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	79 17                	jns    801ef9 <ipc_recv+0x4b>
		if(*from_env_store)
  801ee2:	83 3e 00             	cmpl   $0x0,(%esi)
  801ee5:	74 06                	je     801eed <ipc_recv+0x3f>
			*from_env_store = 0;
  801ee7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801eed:	85 db                	test   %ebx,%ebx
  801eef:	74 2c                	je     801f1d <ipc_recv+0x6f>
			*perm_store = 0;
  801ef1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ef7:	eb 24                	jmp    801f1d <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801ef9:	85 f6                	test   %esi,%esi
  801efb:	74 0a                	je     801f07 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801efd:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f02:	8b 40 74             	mov    0x74(%eax),%eax
  801f05:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801f07:	85 db                	test   %ebx,%ebx
  801f09:	74 0a                	je     801f15 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801f0b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f10:	8b 40 78             	mov    0x78(%eax),%eax
  801f13:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f15:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f1a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	57                   	push   %edi
  801f28:	56                   	push   %esi
  801f29:	53                   	push   %ebx
  801f2a:	83 ec 0c             	sub    $0xc,%esp
  801f2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f30:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801f36:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801f38:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801f3d:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801f40:	e8 97 eb ff ff       	call   800adc <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801f45:	ff 75 14             	pushl  0x14(%ebp)
  801f48:	53                   	push   %ebx
  801f49:	56                   	push   %esi
  801f4a:	57                   	push   %edi
  801f4b:	e8 38 ed ff ff       	call   800c88 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801f50:	89 c2                	mov    %eax,%edx
  801f52:	f7 d2                	not    %edx
  801f54:	c1 ea 1f             	shr    $0x1f,%edx
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5d:	0f 94 c1             	sete   %cl
  801f60:	09 ca                	or     %ecx,%edx
  801f62:	85 c0                	test   %eax,%eax
  801f64:	0f 94 c0             	sete   %al
  801f67:	38 c2                	cmp    %al,%dl
  801f69:	77 d5                	ja     801f40 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6e:	5b                   	pop    %ebx
  801f6f:	5e                   	pop    %esi
  801f70:	5f                   	pop    %edi
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    

00801f73 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f81:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f87:	8b 52 50             	mov    0x50(%edx),%edx
  801f8a:	39 ca                	cmp    %ecx,%edx
  801f8c:	75 0d                	jne    801f9b <ipc_find_env+0x28>
			return envs[i].env_id;
  801f8e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f96:	8b 40 48             	mov    0x48(%eax),%eax
  801f99:	eb 0f                	jmp    801faa <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9b:	83 c0 01             	add    $0x1,%eax
  801f9e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa3:	75 d9                	jne    801f7e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	c1 e8 16             	shr    $0x16,%eax
  801fb7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc3:	f6 c1 01             	test   $0x1,%cl
  801fc6:	74 1d                	je     801fe5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc8:	c1 ea 0c             	shr    $0xc,%edx
  801fcb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd2:	f6 c2 01             	test   $0x1,%dl
  801fd5:	74 0e                	je     801fe5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd7:	c1 ea 0c             	shr    $0xc,%edx
  801fda:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe1:	ef 
  801fe2:	0f b7 c0             	movzwl %ax,%eax
}
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    
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
