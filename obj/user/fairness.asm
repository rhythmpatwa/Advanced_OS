
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
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
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 be 0a 00 00       	call   800afe <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 ee 0c 00 00       	call   800d4c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 22 80 00       	push   $0x8022c0
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 22 80 00       	push   $0x8022d1
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 26 0d 00 00       	call   800dc2 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000ac:	e8 4d 0a 00 00       	call   800afe <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 23 0f 00 00       	call   801015 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 c1 09 00 00       	call   800abd <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 4f 09 00 00       	call   800a80 <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 54 01 00 00       	call   8002cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 f4 08 00 00       	call   800a80 <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 34 1e 00 00       	call   802030 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 21 1f 00 00       	call   802160 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 f2 22 80 00 	movsbl 0x8022f2(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025a:	83 fa 01             	cmp    $0x1,%edx
  80025d:	7e 0e                	jle    80026d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	8d 4a 08             	lea    0x8(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 02                	mov    (%edx),%eax
  800268:	8b 52 04             	mov    0x4(%edx),%edx
  80026b:	eb 22                	jmp    80028f <getuint+0x38>
	else if (lflag)
  80026d:	85 d2                	test   %edx,%edx
  80026f:	74 10                	je     800281 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800271:	8b 10                	mov    (%eax),%edx
  800273:	8d 4a 04             	lea    0x4(%edx),%ecx
  800276:	89 08                	mov    %ecx,(%eax)
  800278:	8b 02                	mov    (%edx),%eax
  80027a:	ba 00 00 00 00       	mov    $0x0,%edx
  80027f:	eb 0e                	jmp    80028f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800281:	8b 10                	mov    (%eax),%edx
  800283:	8d 4a 04             	lea    0x4(%edx),%ecx
  800286:	89 08                	mov    %ecx,(%eax)
  800288:	8b 02                	mov    (%edx),%eax
  80028a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800297:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029b:	8b 10                	mov    (%eax),%edx
  80029d:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a0:	73 0a                	jae    8002ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	88 02                	mov    %al,(%edx)
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b7:	50                   	push   %eax
  8002b8:	ff 75 10             	pushl  0x10(%ebp)
  8002bb:	ff 75 0c             	pushl  0xc(%ebp)
  8002be:	ff 75 08             	pushl  0x8(%ebp)
  8002c1:	e8 05 00 00 00       	call   8002cb <vprintfmt>
	va_end(ap);
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	c9                   	leave  
  8002ca:	c3                   	ret    

008002cb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 2c             	sub    $0x2c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	eb 12                	jmp    8002f1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	0f 84 a9 03 00 00    	je     800690 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8002e7:	83 ec 08             	sub    $0x8,%esp
  8002ea:	53                   	push   %ebx
  8002eb:	50                   	push   %eax
  8002ec:	ff d6                	call   *%esi
  8002ee:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f1:	83 c7 01             	add    $0x1,%edi
  8002f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f8:	83 f8 25             	cmp    $0x25,%eax
  8002fb:	75 e2                	jne    8002df <vprintfmt+0x14>
  8002fd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800301:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800308:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 07                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800320:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8d 47 01             	lea    0x1(%edi),%eax
  800327:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032a:	0f b6 07             	movzbl (%edi),%eax
  80032d:	0f b6 c8             	movzbl %al,%ecx
  800330:	83 e8 23             	sub    $0x23,%eax
  800333:	3c 55                	cmp    $0x55,%al
  800335:	0f 87 3a 03 00 00    	ja     800675 <vprintfmt+0x3aa>
  80033b:	0f b6 c0             	movzbl %al,%eax
  80033e:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800348:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034c:	eb d6                	jmp    800324 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800351:	b8 00 00 00 00       	mov    $0x0,%eax
  800356:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800359:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800360:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800363:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800366:	83 fa 09             	cmp    $0x9,%edx
  800369:	77 39                	ja     8003a4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80036e:	eb e9                	jmp    800359 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 48 04             	lea    0x4(%eax),%ecx
  800376:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800381:	eb 27                	jmp    8003aa <vprintfmt+0xdf>
  800383:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800386:	85 c0                	test   %eax,%eax
  800388:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038d:	0f 49 c8             	cmovns %eax,%ecx
  800390:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800396:	eb 8c                	jmp    800324 <vprintfmt+0x59>
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a2:	eb 80                	jmp    800324 <vprintfmt+0x59>
  8003a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	0f 89 70 ff ff ff    	jns    800324 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ba:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c1:	e9 5e ff ff ff       	jmp    800324 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003cc:	e9 53 ff ff ff       	jmp    800324 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	8d 50 04             	lea    0x4(%eax),%edx
  8003d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	53                   	push   %ebx
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d6                	call   *%esi
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e8:	e9 04 ff ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 50 04             	lea    0x4(%eax),%edx
  8003f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f6:	8b 00                	mov    (%eax),%eax
  8003f8:	99                   	cltd   
  8003f9:	31 d0                	xor    %edx,%eax
  8003fb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fd:	83 f8 0f             	cmp    $0xf,%eax
  800400:	7f 0b                	jg     80040d <vprintfmt+0x142>
  800402:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800409:	85 d2                	test   %edx,%edx
  80040b:	75 18                	jne    800425 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040d:	50                   	push   %eax
  80040e:	68 0a 23 80 00       	push   $0x80230a
  800413:	53                   	push   %ebx
  800414:	56                   	push   %esi
  800415:	e8 94 fe ff ff       	call   8002ae <printfmt>
  80041a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800420:	e9 cc fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800425:	52                   	push   %edx
  800426:	68 d5 26 80 00       	push   $0x8026d5
  80042b:	53                   	push   %ebx
  80042c:	56                   	push   %esi
  80042d:	e8 7c fe ff ff       	call   8002ae <printfmt>
  800432:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	e9 b4 fe ff ff       	jmp    8002f1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800448:	85 ff                	test   %edi,%edi
  80044a:	b8 03 23 80 00       	mov    $0x802303,%eax
  80044f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	0f 8e 94 00 00 00    	jle    8004f0 <vprintfmt+0x225>
  80045c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800460:	0f 84 98 00 00 00    	je     8004fe <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 d0             	pushl  -0x30(%ebp)
  80046c:	57                   	push   %edi
  80046d:	e8 a6 02 00 00       	call   800718 <strnlen>
  800472:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800481:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800484:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800487:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	eb 0f                	jmp    80049a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	53                   	push   %ebx
  80048f:	ff 75 e0             	pushl  -0x20(%ebp)
  800492:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800494:	83 ef 01             	sub    $0x1,%edi
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 ff                	test   %edi,%edi
  80049c:	7f ed                	jg     80048b <vprintfmt+0x1c0>
  80049e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004a4:	85 c9                	test   %ecx,%ecx
  8004a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ab:	0f 49 c1             	cmovns %ecx,%eax
  8004ae:	29 c1                	sub    %eax,%ecx
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	89 cb                	mov    %ecx,%ebx
  8004bb:	eb 4d                	jmp    80050a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c1:	74 1b                	je     8004de <vprintfmt+0x213>
  8004c3:	0f be c0             	movsbl %al,%eax
  8004c6:	83 e8 20             	sub    $0x20,%eax
  8004c9:	83 f8 5e             	cmp    $0x5e,%eax
  8004cc:	76 10                	jbe    8004de <vprintfmt+0x213>
					putch('?', putdat);
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 0c             	pushl  0xc(%ebp)
  8004d4:	6a 3f                	push   $0x3f
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb 0d                	jmp    8004eb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 0c             	pushl  0xc(%ebp)
  8004e4:	52                   	push   %edx
  8004e5:	ff 55 08             	call   *0x8(%ebp)
  8004e8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	eb 1a                	jmp    80050a <vprintfmt+0x23f>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	eb 0c                	jmp    80050a <vprintfmt+0x23f>
  8004fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800501:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800504:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800507:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050a:	83 c7 01             	add    $0x1,%edi
  80050d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800511:	0f be d0             	movsbl %al,%edx
  800514:	85 d2                	test   %edx,%edx
  800516:	74 23                	je     80053b <vprintfmt+0x270>
  800518:	85 f6                	test   %esi,%esi
  80051a:	78 a1                	js     8004bd <vprintfmt+0x1f2>
  80051c:	83 ee 01             	sub    $0x1,%esi
  80051f:	79 9c                	jns    8004bd <vprintfmt+0x1f2>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	eb 18                	jmp    800543 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	53                   	push   %ebx
  80052f:	6a 20                	push   $0x20
  800531:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 08                	jmp    800543 <vprintfmt+0x278>
  80053b:	89 df                	mov    %ebx,%edi
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	85 ff                	test   %edi,%edi
  800545:	7f e4                	jg     80052b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054a:	e9 a2 fd ff ff       	jmp    8002f1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80054f:	83 fa 01             	cmp    $0x1,%edx
  800552:	7e 16                	jle    80056a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8d 50 08             	lea    0x8(%eax),%edx
  80055a:	89 55 14             	mov    %edx,0x14(%ebp)
  80055d:	8b 50 04             	mov    0x4(%eax),%edx
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800568:	eb 32                	jmp    80059c <vprintfmt+0x2d1>
	else if (lflag)
  80056a:	85 d2                	test   %edx,%edx
  80056c:	74 18                	je     800586 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8d 50 04             	lea    0x4(%eax),%edx
  800574:	89 55 14             	mov    %edx,0x14(%ebp)
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 c1                	mov    %eax,%ecx
  80057e:	c1 f9 1f             	sar    $0x1f,%ecx
  800581:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800584:	eb 16                	jmp    80059c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 50 04             	lea    0x4(%eax),%edx
  80058c:	89 55 14             	mov    %edx,0x14(%ebp)
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 c1                	mov    %eax,%ecx
  800596:	c1 f9 1f             	sar    $0x1f,%ecx
  800599:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ab:	0f 89 90 00 00 00    	jns    800641 <vprintfmt+0x376>
				putch('-', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 2d                	push   $0x2d
  8005b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005bf:	f7 d8                	neg    %eax
  8005c1:	83 d2 00             	adc    $0x0,%edx
  8005c4:	f7 da                	neg    %edx
  8005c6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ce:	eb 71                	jmp    800641 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	e8 7f fc ff ff       	call   800257 <getuint>
			base = 10;
  8005d8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005dd:	eb 62                	jmp    800641 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 70 fc ff ff       	call   800257 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005ee:	51                   	push   %ecx
  8005ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8005f2:	6a 08                	push   $0x8
  8005f4:	52                   	push   %edx
  8005f5:	50                   	push   %eax
  8005f6:	89 da                	mov    %ebx,%edx
  8005f8:	89 f0                	mov    %esi,%eax
  8005fa:	e8 a9 fb ff ff       	call   8001a8 <printnum>
			break;
  8005ff:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800605:	e9 e7 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 30                	push   $0x30
  800610:	ff d6                	call   *%esi
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 78                	push   $0x78
  800618:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800623:	8b 00                	mov    (%eax),%eax
  800625:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80062d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800632:	eb 0d                	jmp    800641 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 1b fc ff ff       	call   800257 <getuint>
			base = 16;
  80063c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800641:	83 ec 0c             	sub    $0xc,%esp
  800644:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800648:	57                   	push   %edi
  800649:	ff 75 e0             	pushl  -0x20(%ebp)
  80064c:	51                   	push   %ecx
  80064d:	52                   	push   %edx
  80064e:	50                   	push   %eax
  80064f:	89 da                	mov    %ebx,%edx
  800651:	89 f0                	mov    %esi,%eax
  800653:	e8 50 fb ff ff       	call   8001a8 <printnum>
			break;
  800658:	83 c4 20             	add    $0x20,%esp
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 8e fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	51                   	push   %ecx
  800668:	ff d6                	call   *%esi
			break;
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800670:	e9 7c fc ff ff       	jmp    8002f1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	83 ec 08             	sub    $0x8,%esp
  800678:	53                   	push   %ebx
  800679:	6a 25                	push   $0x25
  80067b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	eb 03                	jmp    800685 <vprintfmt+0x3ba>
  800682:	83 ef 01             	sub    $0x1,%edi
  800685:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800689:	75 f7                	jne    800682 <vprintfmt+0x3b7>
  80068b:	e9 61 fc ff ff       	jmp    8002f1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	83 ec 18             	sub    $0x18,%esp
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	74 26                	je     8006df <vsnprintf+0x47>
  8006b9:	85 d2                	test   %edx,%edx
  8006bb:	7e 22                	jle    8006df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006bd:	ff 75 14             	pushl  0x14(%ebp)
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c6:	50                   	push   %eax
  8006c7:	68 91 02 80 00       	push   $0x800291
  8006cc:	e8 fa fb ff ff       	call   8002cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 05                	jmp    8006e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ef:	50                   	push   %eax
  8006f0:	ff 75 10             	pushl  0x10(%ebp)
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	ff 75 08             	pushl  0x8(%ebp)
  8006f9:	e8 9a ff ff ff       	call   800698 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	eb 03                	jmp    800710 <strlen+0x10>
		n++;
  80070d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800710:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800714:	75 f7                	jne    80070d <strlen+0xd>
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	eb 03                	jmp    80072b <strnlen+0x13>
		n++;
  800728:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072b:	39 c2                	cmp    %eax,%edx
  80072d:	74 08                	je     800737 <strnlen+0x1f>
  80072f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800733:	75 f3                	jne    800728 <strnlen+0x10>
  800735:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800737:	5d                   	pop    %ebp
  800738:	c3                   	ret    

00800739 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	53                   	push   %ebx
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800743:	89 c2                	mov    %eax,%edx
  800745:	83 c2 01             	add    $0x1,%edx
  800748:	83 c1 01             	add    $0x1,%ecx
  80074b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80074f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800752:	84 db                	test   %bl,%bl
  800754:	75 ef                	jne    800745 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800756:	5b                   	pop    %ebx
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800760:	53                   	push   %ebx
  800761:	e8 9a ff ff ff       	call   800700 <strlen>
  800766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800769:	ff 75 0c             	pushl  0xc(%ebp)
  80076c:	01 d8                	add    %ebx,%eax
  80076e:	50                   	push   %eax
  80076f:	e8 c5 ff ff ff       	call   800739 <strcpy>
	return dst;
}
  800774:	89 d8                	mov    %ebx,%eax
  800776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800779:	c9                   	leave  
  80077a:	c3                   	ret    

0080077b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	56                   	push   %esi
  80077f:	53                   	push   %ebx
  800780:	8b 75 08             	mov    0x8(%ebp),%esi
  800783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800786:	89 f3                	mov    %esi,%ebx
  800788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	eb 0f                	jmp    80079e <strncpy+0x23>
		*dst++ = *src;
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	0f b6 01             	movzbl (%ecx),%eax
  800795:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800798:	80 39 01             	cmpb   $0x1,(%ecx)
  80079b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079e:	39 da                	cmp    %ebx,%edx
  8007a0:	75 ed                	jne    80078f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a2:	89 f0                	mov    %esi,%eax
  8007a4:	5b                   	pop    %ebx
  8007a5:	5e                   	pop    %esi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b8:	85 d2                	test   %edx,%edx
  8007ba:	74 21                	je     8007dd <strlcpy+0x35>
  8007bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c0:	89 f2                	mov    %esi,%edx
  8007c2:	eb 09                	jmp    8007cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 09                	je     8007da <strlcpy+0x32>
  8007d1:	0f b6 19             	movzbl (%ecx),%ebx
  8007d4:	84 db                	test   %bl,%bl
  8007d6:	75 ec                	jne    8007c4 <strlcpy+0x1c>
  8007d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007dd:	29 f0                	sub    %esi,%eax
}
  8007df:	5b                   	pop    %ebx
  8007e0:	5e                   	pop    %esi
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ec:	eb 06                	jmp    8007f4 <strcmp+0x11>
		p++, q++;
  8007ee:	83 c1 01             	add    $0x1,%ecx
  8007f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f4:	0f b6 01             	movzbl (%ecx),%eax
  8007f7:	84 c0                	test   %al,%al
  8007f9:	74 04                	je     8007ff <strcmp+0x1c>
  8007fb:	3a 02                	cmp    (%edx),%al
  8007fd:	74 ef                	je     8007ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ff:	0f b6 c0             	movzbl %al,%eax
  800802:	0f b6 12             	movzbl (%edx),%edx
  800805:	29 d0                	sub    %edx,%eax
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 c3                	mov    %eax,%ebx
  800815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800818:	eb 06                	jmp    800820 <strncmp+0x17>
		n--, p++, q++;
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800820:	39 d8                	cmp    %ebx,%eax
  800822:	74 15                	je     800839 <strncmp+0x30>
  800824:	0f b6 08             	movzbl (%eax),%ecx
  800827:	84 c9                	test   %cl,%cl
  800829:	74 04                	je     80082f <strncmp+0x26>
  80082b:	3a 0a                	cmp    (%edx),%cl
  80082d:	74 eb                	je     80081a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80082f:	0f b6 00             	movzbl (%eax),%eax
  800832:	0f b6 12             	movzbl (%edx),%edx
  800835:	29 d0                	sub    %edx,%eax
  800837:	eb 05                	jmp    80083e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 07                	jmp    800854 <strchr+0x13>
		if (*s == c)
  80084d:	38 ca                	cmp    %cl,%dl
  80084f:	74 0f                	je     800860 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086c:	eb 03                	jmp    800871 <strfind+0xf>
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800874:	38 ca                	cmp    %cl,%dl
  800876:	74 04                	je     80087c <strfind+0x1a>
  800878:	84 d2                	test   %dl,%dl
  80087a:	75 f2                	jne    80086e <strfind+0xc>
			break;
	return (char *) s;
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	57                   	push   %edi
  800882:	56                   	push   %esi
  800883:	53                   	push   %ebx
  800884:	8b 7d 08             	mov    0x8(%ebp),%edi
  800887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	74 36                	je     8008c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800894:	75 28                	jne    8008be <memset+0x40>
  800896:	f6 c1 03             	test   $0x3,%cl
  800899:	75 23                	jne    8008be <memset+0x40>
		c &= 0xFF;
  80089b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80089f:	89 d3                	mov    %edx,%ebx
  8008a1:	c1 e3 08             	shl    $0x8,%ebx
  8008a4:	89 d6                	mov    %edx,%esi
  8008a6:	c1 e6 18             	shl    $0x18,%esi
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	c1 e0 10             	shl    $0x10,%eax
  8008ae:	09 f0                	or     %esi,%eax
  8008b0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b2:	89 d8                	mov    %ebx,%eax
  8008b4:	09 d0                	or     %edx,%eax
  8008b6:	c1 e9 02             	shr    $0x2,%ecx
  8008b9:	fc                   	cld    
  8008ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bc:	eb 06                	jmp    8008c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	fc                   	cld    
  8008c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c4:	89 f8                	mov    %edi,%eax
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5f                   	pop    %edi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	57                   	push   %edi
  8008cf:	56                   	push   %esi
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008d9:	39 c6                	cmp    %eax,%esi
  8008db:	73 35                	jae    800912 <memmove+0x47>
  8008dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e0:	39 d0                	cmp    %edx,%eax
  8008e2:	73 2e                	jae    800912 <memmove+0x47>
		s += n;
		d += n;
  8008e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e7:	89 d6                	mov    %edx,%esi
  8008e9:	09 fe                	or     %edi,%esi
  8008eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f1:	75 13                	jne    800906 <memmove+0x3b>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0e                	jne    800906 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f8:	83 ef 04             	sub    $0x4,%edi
  8008fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
  800901:	fd                   	std    
  800902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800904:	eb 09                	jmp    80090f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800906:	83 ef 01             	sub    $0x1,%edi
  800909:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090c:	fd                   	std    
  80090d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80090f:	fc                   	cld    
  800910:	eb 1d                	jmp    80092f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	89 f2                	mov    %esi,%edx
  800914:	09 c2                	or     %eax,%edx
  800916:	f6 c2 03             	test   $0x3,%dl
  800919:	75 0f                	jne    80092a <memmove+0x5f>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 0a                	jne    80092a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	89 c7                	mov    %eax,%edi
  800925:	fc                   	cld    
  800926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800928:	eb 05                	jmp    80092f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092a:	89 c7                	mov    %eax,%edi
  80092c:	fc                   	cld    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	ff 75 0c             	pushl  0xc(%ebp)
  80093c:	ff 75 08             	pushl  0x8(%ebp)
  80093f:	e8 87 ff ff ff       	call   8008cb <memmove>
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800951:	89 c6                	mov    %eax,%esi
  800953:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	eb 1a                	jmp    800972 <memcmp+0x2c>
		if (*s1 != *s2)
  800958:	0f b6 08             	movzbl (%eax),%ecx
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	38 d9                	cmp    %bl,%cl
  800960:	74 0a                	je     80096c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800962:	0f b6 c1             	movzbl %cl,%eax
  800965:	0f b6 db             	movzbl %bl,%ebx
  800968:	29 d8                	sub    %ebx,%eax
  80096a:	eb 0f                	jmp    80097b <memcmp+0x35>
		s1++, s2++;
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	39 f0                	cmp    %esi,%eax
  800974:	75 e2                	jne    800958 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800986:	89 c1                	mov    %eax,%ecx
  800988:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098f:	eb 0a                	jmp    80099b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800991:	0f b6 10             	movzbl (%eax),%edx
  800994:	39 da                	cmp    %ebx,%edx
  800996:	74 07                	je     80099f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	39 c8                	cmp    %ecx,%eax
  80099d:	72 f2                	jb     800991 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ae:	eb 03                	jmp    8009b3 <strtol+0x11>
		s++;
  8009b0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	3c 20                	cmp    $0x20,%al
  8009b8:	74 f6                	je     8009b0 <strtol+0xe>
  8009ba:	3c 09                	cmp    $0x9,%al
  8009bc:	74 f2                	je     8009b0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009be:	3c 2b                	cmp    $0x2b,%al
  8009c0:	75 0a                	jne    8009cc <strtol+0x2a>
		s++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ca:	eb 11                	jmp    8009dd <strtol+0x3b>
  8009cc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d1:	3c 2d                	cmp    $0x2d,%al
  8009d3:	75 08                	jne    8009dd <strtol+0x3b>
		s++, neg = 1;
  8009d5:	83 c1 01             	add    $0x1,%ecx
  8009d8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e3:	75 15                	jne    8009fa <strtol+0x58>
  8009e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e8:	75 10                	jne    8009fa <strtol+0x58>
  8009ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ee:	75 7c                	jne    800a6c <strtol+0xca>
		s += 2, base = 16;
  8009f0:	83 c1 02             	add    $0x2,%ecx
  8009f3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f8:	eb 16                	jmp    800a10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fa:	85 db                	test   %ebx,%ebx
  8009fc:	75 12                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 08                	jne    800a10 <strtol+0x6e>
		s++, base = 8;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
  800a15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a18:	0f b6 11             	movzbl (%ecx),%edx
  800a1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 09             	cmp    $0x9,%bl
  800a23:	77 08                	ja     800a2d <strtol+0x8b>
			dig = *s - '0';
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 30             	sub    $0x30,%edx
  800a2b:	eb 22                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a30:	89 f3                	mov    %esi,%ebx
  800a32:	80 fb 19             	cmp    $0x19,%bl
  800a35:	77 08                	ja     800a3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a37:	0f be d2             	movsbl %dl,%edx
  800a3a:	83 ea 57             	sub    $0x57,%edx
  800a3d:	eb 10                	jmp    800a4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 19             	cmp    $0x19,%bl
  800a47:	77 16                	ja     800a5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a52:	7d 0b                	jge    800a5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5d:	eb b9                	jmp    800a18 <strtol+0x76>

	if (endptr)
  800a5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a63:	74 0d                	je     800a72 <strtol+0xd0>
		*endptr = (char *) s;
  800a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a68:	89 0e                	mov    %ecx,(%esi)
  800a6a:	eb 06                	jmp    800a72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	74 98                	je     800a08 <strtol+0x66>
  800a70:	eb 9e                	jmp    800a10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	f7 da                	neg    %edx
  800a76:	85 ff                	test   %edi,%edi
  800a78:	0f 45 c2             	cmovne %edx,%eax
}
  800a7b:	5b                   	pop    %ebx
  800a7c:	5e                   	pop    %esi
  800a7d:	5f                   	pop    %edi
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	57                   	push   %edi
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	89 c6                	mov    %eax,%esi
  800a97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aae:	89 d1                	mov    %edx,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	89 d7                	mov    %edx,%edi
  800ab4:	89 d6                	mov    %edx,%esi
  800ab6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5e                   	pop    %esi
  800aba:	5f                   	pop    %edi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad3:	89 cb                	mov    %ecx,%ebx
  800ad5:	89 cf                	mov    %ecx,%edi
  800ad7:	89 ce                	mov    %ecx,%esi
  800ad9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800adb:	85 c0                	test   %eax,%eax
  800add:	7e 17                	jle    800af6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800adf:	83 ec 0c             	sub    $0xc,%esp
  800ae2:	50                   	push   %eax
  800ae3:	6a 03                	push   $0x3
  800ae5:	68 ff 25 80 00       	push   $0x8025ff
  800aea:	6a 23                	push   $0x23
  800aec:	68 1c 26 80 00       	push   $0x80261c
  800af1:	e8 b1 14 00 00       	call   801fa7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_yield>:

void
sys_yield(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b45:	be 00 00 00 00       	mov    $0x0,%esi
  800b4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b58:	89 f7                	mov    %esi,%edi
  800b5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 04                	push   $0x4
  800b66:	68 ff 25 80 00       	push   $0x8025ff
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 1c 26 80 00       	push   $0x80261c
  800b72:	e8 30 14 00 00       	call   801fa7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b88:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b99:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9e:	85 c0                	test   %eax,%eax
  800ba0:	7e 17                	jle    800bb9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba2:	83 ec 0c             	sub    $0xc,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 05                	push   $0x5
  800ba8:	68 ff 25 80 00       	push   $0x8025ff
  800bad:	6a 23                	push   $0x23
  800baf:	68 1c 26 80 00       	push   $0x80261c
  800bb4:	e8 ee 13 00 00       	call   801fa7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bcf:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	89 df                	mov    %ebx,%edi
  800bdc:	89 de                	mov    %ebx,%esi
  800bde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be0:	85 c0                	test   %eax,%eax
  800be2:	7e 17                	jle    800bfb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be4:	83 ec 0c             	sub    $0xc,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 06                	push   $0x6
  800bea:	68 ff 25 80 00       	push   $0x8025ff
  800bef:	6a 23                	push   $0x23
  800bf1:	68 1c 26 80 00       	push   $0x80261c
  800bf6:	e8 ac 13 00 00       	call   801fa7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c11:	b8 08 00 00 00       	mov    $0x8,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 df                	mov    %ebx,%edi
  800c1e:	89 de                	mov    %ebx,%esi
  800c20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c22:	85 c0                	test   %eax,%eax
  800c24:	7e 17                	jle    800c3d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 08                	push   $0x8
  800c2c:	68 ff 25 80 00       	push   $0x8025ff
  800c31:	6a 23                	push   $0x23
  800c33:	68 1c 26 80 00       	push   $0x80261c
  800c38:	e8 6a 13 00 00       	call   801fa7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c53:	b8 09 00 00 00       	mov    $0x9,%eax
  800c58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5e:	89 df                	mov    %ebx,%edi
  800c60:	89 de                	mov    %ebx,%esi
  800c62:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c64:	85 c0                	test   %eax,%eax
  800c66:	7e 17                	jle    800c7f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	50                   	push   %eax
  800c6c:	6a 09                	push   $0x9
  800c6e:	68 ff 25 80 00       	push   $0x8025ff
  800c73:	6a 23                	push   $0x23
  800c75:	68 1c 26 80 00       	push   $0x80261c
  800c7a:	e8 28 13 00 00       	call   801fa7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7e 17                	jle    800cc1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caa:	83 ec 0c             	sub    $0xc,%esp
  800cad:	50                   	push   %eax
  800cae:	6a 0a                	push   $0xa
  800cb0:	68 ff 25 80 00       	push   $0x8025ff
  800cb5:	6a 23                	push   $0x23
  800cb7:	68 1c 26 80 00       	push   $0x80261c
  800cbc:	e8 e6 12 00 00       	call   801fa7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	89 cb                	mov    %ecx,%ebx
  800d04:	89 cf                	mov    %ecx,%edi
  800d06:	89 ce                	mov    %ecx,%esi
  800d08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 17                	jle    800d25 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 0d                	push   $0xd
  800d14:	68 ff 25 80 00       	push   $0x8025ff
  800d19:	6a 23                	push   $0x23
  800d1b:	68 1c 26 80 00       	push   $0x80261c
  800d20:	e8 82 12 00 00       	call   801fa7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	8b 75 08             	mov    0x8(%ebp),%esi
  800d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	74 0e                	je     800d6c <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	e8 85 ff ff ff       	call   800cec <sys_ipc_recv>
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	eb 10                	jmp    800d7c <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  800d6c:	83 ec 0c             	sub    $0xc,%esp
  800d6f:	68 00 00 c0 ee       	push   $0xeec00000
  800d74:	e8 73 ff ff ff       	call   800cec <sys_ipc_recv>
  800d79:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	79 17                	jns    800d97 <ipc_recv+0x4b>
		if(*from_env_store)
  800d80:	83 3e 00             	cmpl   $0x0,(%esi)
  800d83:	74 06                	je     800d8b <ipc_recv+0x3f>
			*from_env_store = 0;
  800d85:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  800d8b:	85 db                	test   %ebx,%ebx
  800d8d:	74 2c                	je     800dbb <ipc_recv+0x6f>
			*perm_store = 0;
  800d8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800d95:	eb 24                	jmp    800dbb <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  800d97:	85 f6                	test   %esi,%esi
  800d99:	74 0a                	je     800da5 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  800d9b:	a1 08 40 80 00       	mov    0x804008,%eax
  800da0:	8b 40 74             	mov    0x74(%eax),%eax
  800da3:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  800da5:	85 db                	test   %ebx,%ebx
  800da7:	74 0a                	je     800db3 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  800da9:	a1 08 40 80 00       	mov    0x804008,%eax
  800dae:	8b 40 78             	mov    0x78(%eax),%eax
  800db1:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  800db3:	a1 08 40 80 00       	mov    0x804008,%eax
  800db8:	8b 40 70             	mov    0x70(%eax),%eax
}
  800dbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  800dd4:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  800dd6:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  800ddb:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  800dde:	e8 3a fd ff ff       	call   800b1d <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  800de3:	ff 75 14             	pushl  0x14(%ebp)
  800de6:	53                   	push   %ebx
  800de7:	56                   	push   %esi
  800de8:	57                   	push   %edi
  800de9:	e8 db fe ff ff       	call   800cc9 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  800dee:	89 c2                	mov    %eax,%edx
  800df0:	f7 d2                	not    %edx
  800df2:	c1 ea 1f             	shr    $0x1f,%edx
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800dfb:	0f 94 c1             	sete   %cl
  800dfe:	09 ca                	or     %ecx,%edx
  800e00:	85 c0                	test   %eax,%eax
  800e02:	0f 94 c0             	sete   %al
  800e05:	38 c2                	cmp    %al,%dl
  800e07:	77 d5                	ja     800dde <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  800e09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e1c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e1f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e25:	8b 52 50             	mov    0x50(%edx),%edx
  800e28:	39 ca                	cmp    %ecx,%edx
  800e2a:	75 0d                	jne    800e39 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e2c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e2f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e34:	8b 40 48             	mov    0x48(%eax),%eax
  800e37:	eb 0f                	jmp    800e48 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e39:	83 c0 01             	add    $0x1,%eax
  800e3c:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e41:	75 d9                	jne    800e1c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e50:	05 00 00 00 30       	add    $0x30000000,%eax
  800e55:	c1 e8 0c             	shr    $0xc,%eax
}
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e60:	05 00 00 00 30       	add    $0x30000000,%eax
  800e65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e6a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e77:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e7c:	89 c2                	mov    %eax,%edx
  800e7e:	c1 ea 16             	shr    $0x16,%edx
  800e81:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e88:	f6 c2 01             	test   $0x1,%dl
  800e8b:	74 11                	je     800e9e <fd_alloc+0x2d>
  800e8d:	89 c2                	mov    %eax,%edx
  800e8f:	c1 ea 0c             	shr    $0xc,%edx
  800e92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e99:	f6 c2 01             	test   $0x1,%dl
  800e9c:	75 09                	jne    800ea7 <fd_alloc+0x36>
			*fd_store = fd;
  800e9e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea5:	eb 17                	jmp    800ebe <fd_alloc+0x4d>
  800ea7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eac:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb1:	75 c9                	jne    800e7c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eb3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800eb9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ec6:	83 f8 1f             	cmp    $0x1f,%eax
  800ec9:	77 36                	ja     800f01 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ecb:	c1 e0 0c             	shl    $0xc,%eax
  800ece:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800ed3:	89 c2                	mov    %eax,%edx
  800ed5:	c1 ea 16             	shr    $0x16,%edx
  800ed8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800edf:	f6 c2 01             	test   $0x1,%dl
  800ee2:	74 24                	je     800f08 <fd_lookup+0x48>
  800ee4:	89 c2                	mov    %eax,%edx
  800ee6:	c1 ea 0c             	shr    $0xc,%edx
  800ee9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef0:	f6 c2 01             	test   $0x1,%dl
  800ef3:	74 1a                	je     800f0f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ef5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef8:	89 02                	mov    %eax,(%edx)
	return 0;
  800efa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eff:	eb 13                	jmp    800f14 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f01:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f06:	eb 0c                	jmp    800f14 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0d:	eb 05                	jmp    800f14 <fd_lookup+0x54>
  800f0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	83 ec 08             	sub    $0x8,%esp
  800f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1f:	ba a8 26 80 00       	mov    $0x8026a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f24:	eb 13                	jmp    800f39 <dev_lookup+0x23>
  800f26:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f29:	39 08                	cmp    %ecx,(%eax)
  800f2b:	75 0c                	jne    800f39 <dev_lookup+0x23>
			*dev = devtab[i];
  800f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f30:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
  800f37:	eb 2e                	jmp    800f67 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f39:	8b 02                	mov    (%edx),%eax
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	75 e7                	jne    800f26 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f3f:	a1 08 40 80 00       	mov    0x804008,%eax
  800f44:	8b 40 48             	mov    0x48(%eax),%eax
  800f47:	83 ec 04             	sub    $0x4,%esp
  800f4a:	51                   	push   %ecx
  800f4b:	50                   	push   %eax
  800f4c:	68 2c 26 80 00       	push   $0x80262c
  800f51:	e8 3e f2 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f67:	c9                   	leave  
  800f68:	c3                   	ret    

00800f69 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 10             	sub    $0x10,%esp
  800f71:	8b 75 08             	mov    0x8(%ebp),%esi
  800f74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7a:	50                   	push   %eax
  800f7b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f81:	c1 e8 0c             	shr    $0xc,%eax
  800f84:	50                   	push   %eax
  800f85:	e8 36 ff ff ff       	call   800ec0 <fd_lookup>
  800f8a:	83 c4 08             	add    $0x8,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 05                	js     800f96 <fd_close+0x2d>
	    || fd != fd2)
  800f91:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f94:	74 0c                	je     800fa2 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f96:	84 db                	test   %bl,%bl
  800f98:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9d:	0f 44 c2             	cmove  %edx,%eax
  800fa0:	eb 41                	jmp    800fe3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa2:	83 ec 08             	sub    $0x8,%esp
  800fa5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fa8:	50                   	push   %eax
  800fa9:	ff 36                	pushl  (%esi)
  800fab:	e8 66 ff ff ff       	call   800f16 <dev_lookup>
  800fb0:	89 c3                	mov    %eax,%ebx
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 1a                	js     800fd3 <fd_close+0x6a>
		if (dev->dev_close)
  800fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fbc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fbf:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	74 0b                	je     800fd3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	56                   	push   %esi
  800fcc:	ff d0                	call   *%eax
  800fce:	89 c3                	mov    %eax,%ebx
  800fd0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	56                   	push   %esi
  800fd7:	6a 00                	push   $0x0
  800fd9:	e8 e3 fb ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  800fde:	83 c4 10             	add    $0x10,%esp
  800fe1:	89 d8                	mov    %ebx,%eax
}
  800fe3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5e                   	pop    %esi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff3:	50                   	push   %eax
  800ff4:	ff 75 08             	pushl  0x8(%ebp)
  800ff7:	e8 c4 fe ff ff       	call   800ec0 <fd_lookup>
  800ffc:	83 c4 08             	add    $0x8,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 10                	js     801013 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801003:	83 ec 08             	sub    $0x8,%esp
  801006:	6a 01                	push   $0x1
  801008:	ff 75 f4             	pushl  -0xc(%ebp)
  80100b:	e8 59 ff ff ff       	call   800f69 <fd_close>
  801010:	83 c4 10             	add    $0x10,%esp
}
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <close_all>:

void
close_all(void)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	53                   	push   %ebx
  801019:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80101c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801021:	83 ec 0c             	sub    $0xc,%esp
  801024:	53                   	push   %ebx
  801025:	e8 c0 ff ff ff       	call   800fea <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80102a:	83 c3 01             	add    $0x1,%ebx
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	83 fb 20             	cmp    $0x20,%ebx
  801033:	75 ec                	jne    801021 <close_all+0xc>
		close(i);
}
  801035:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	83 ec 2c             	sub    $0x2c,%esp
  801043:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801046:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801049:	50                   	push   %eax
  80104a:	ff 75 08             	pushl  0x8(%ebp)
  80104d:	e8 6e fe ff ff       	call   800ec0 <fd_lookup>
  801052:	83 c4 08             	add    $0x8,%esp
  801055:	85 c0                	test   %eax,%eax
  801057:	0f 88 c1 00 00 00    	js     80111e <dup+0xe4>
		return r;
	close(newfdnum);
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	56                   	push   %esi
  801061:	e8 84 ff ff ff       	call   800fea <close>

	newfd = INDEX2FD(newfdnum);
  801066:	89 f3                	mov    %esi,%ebx
  801068:	c1 e3 0c             	shl    $0xc,%ebx
  80106b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801071:	83 c4 04             	add    $0x4,%esp
  801074:	ff 75 e4             	pushl  -0x1c(%ebp)
  801077:	e8 de fd ff ff       	call   800e5a <fd2data>
  80107c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80107e:	89 1c 24             	mov    %ebx,(%esp)
  801081:	e8 d4 fd ff ff       	call   800e5a <fd2data>
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80108c:	89 f8                	mov    %edi,%eax
  80108e:	c1 e8 16             	shr    $0x16,%eax
  801091:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801098:	a8 01                	test   $0x1,%al
  80109a:	74 37                	je     8010d3 <dup+0x99>
  80109c:	89 f8                	mov    %edi,%eax
  80109e:	c1 e8 0c             	shr    $0xc,%eax
  8010a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a8:	f6 c2 01             	test   $0x1,%dl
  8010ab:	74 26                	je     8010d3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010b4:	83 ec 0c             	sub    $0xc,%esp
  8010b7:	25 07 0e 00 00       	and    $0xe07,%eax
  8010bc:	50                   	push   %eax
  8010bd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c0:	6a 00                	push   $0x0
  8010c2:	57                   	push   %edi
  8010c3:	6a 00                	push   $0x0
  8010c5:	e8 b5 fa ff ff       	call   800b7f <sys_page_map>
  8010ca:	89 c7                	mov    %eax,%edi
  8010cc:	83 c4 20             	add    $0x20,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 2e                	js     801101 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010d6:	89 d0                	mov    %edx,%eax
  8010d8:	c1 e8 0c             	shr    $0xc,%eax
  8010db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ea:	50                   	push   %eax
  8010eb:	53                   	push   %ebx
  8010ec:	6a 00                	push   $0x0
  8010ee:	52                   	push   %edx
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 89 fa ff ff       	call   800b7f <sys_page_map>
  8010f6:	89 c7                	mov    %eax,%edi
  8010f8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010fb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010fd:	85 ff                	test   %edi,%edi
  8010ff:	79 1d                	jns    80111e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801101:	83 ec 08             	sub    $0x8,%esp
  801104:	53                   	push   %ebx
  801105:	6a 00                	push   $0x0
  801107:	e8 b5 fa ff ff       	call   800bc1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80110c:	83 c4 08             	add    $0x8,%esp
  80110f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801112:	6a 00                	push   $0x0
  801114:	e8 a8 fa ff ff       	call   800bc1 <sys_page_unmap>
	return r;
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	89 f8                	mov    %edi,%eax
}
  80111e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    

00801126 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	53                   	push   %ebx
  80112a:	83 ec 14             	sub    $0x14,%esp
  80112d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801130:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801133:	50                   	push   %eax
  801134:	53                   	push   %ebx
  801135:	e8 86 fd ff ff       	call   800ec0 <fd_lookup>
  80113a:	83 c4 08             	add    $0x8,%esp
  80113d:	89 c2                	mov    %eax,%edx
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 6d                	js     8011b0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801149:	50                   	push   %eax
  80114a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80114d:	ff 30                	pushl  (%eax)
  80114f:	e8 c2 fd ff ff       	call   800f16 <dev_lookup>
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	85 c0                	test   %eax,%eax
  801159:	78 4c                	js     8011a7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80115b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80115e:	8b 42 08             	mov    0x8(%edx),%eax
  801161:	83 e0 03             	and    $0x3,%eax
  801164:	83 f8 01             	cmp    $0x1,%eax
  801167:	75 21                	jne    80118a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801169:	a1 08 40 80 00       	mov    0x804008,%eax
  80116e:	8b 40 48             	mov    0x48(%eax),%eax
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	53                   	push   %ebx
  801175:	50                   	push   %eax
  801176:	68 6d 26 80 00       	push   $0x80266d
  80117b:	e8 14 f0 ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801188:	eb 26                	jmp    8011b0 <read+0x8a>
	}
	if (!dev->dev_read)
  80118a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118d:	8b 40 08             	mov    0x8(%eax),%eax
  801190:	85 c0                	test   %eax,%eax
  801192:	74 17                	je     8011ab <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	ff 75 10             	pushl  0x10(%ebp)
  80119a:	ff 75 0c             	pushl  0xc(%ebp)
  80119d:	52                   	push   %edx
  80119e:	ff d0                	call   *%eax
  8011a0:	89 c2                	mov    %eax,%edx
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	eb 09                	jmp    8011b0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	eb 05                	jmp    8011b0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011b0:	89 d0                	mov    %edx,%eax
  8011b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	57                   	push   %edi
  8011bb:	56                   	push   %esi
  8011bc:	53                   	push   %ebx
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cb:	eb 21                	jmp    8011ee <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011cd:	83 ec 04             	sub    $0x4,%esp
  8011d0:	89 f0                	mov    %esi,%eax
  8011d2:	29 d8                	sub    %ebx,%eax
  8011d4:	50                   	push   %eax
  8011d5:	89 d8                	mov    %ebx,%eax
  8011d7:	03 45 0c             	add    0xc(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	57                   	push   %edi
  8011dc:	e8 45 ff ff ff       	call   801126 <read>
		if (m < 0)
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 10                	js     8011f8 <readn+0x41>
			return m;
		if (m == 0)
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	74 0a                	je     8011f6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ec:	01 c3                	add    %eax,%ebx
  8011ee:	39 f3                	cmp    %esi,%ebx
  8011f0:	72 db                	jb     8011cd <readn+0x16>
  8011f2:	89 d8                	mov    %ebx,%eax
  8011f4:	eb 02                	jmp    8011f8 <readn+0x41>
  8011f6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	53                   	push   %ebx
  801204:	83 ec 14             	sub    $0x14,%esp
  801207:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120d:	50                   	push   %eax
  80120e:	53                   	push   %ebx
  80120f:	e8 ac fc ff ff       	call   800ec0 <fd_lookup>
  801214:	83 c4 08             	add    $0x8,%esp
  801217:	89 c2                	mov    %eax,%edx
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 68                	js     801285 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121d:	83 ec 08             	sub    $0x8,%esp
  801220:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801223:	50                   	push   %eax
  801224:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801227:	ff 30                	pushl  (%eax)
  801229:	e8 e8 fc ff ff       	call   800f16 <dev_lookup>
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	78 47                	js     80127c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801235:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801238:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80123c:	75 21                	jne    80125f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80123e:	a1 08 40 80 00       	mov    0x804008,%eax
  801243:	8b 40 48             	mov    0x48(%eax),%eax
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	53                   	push   %ebx
  80124a:	50                   	push   %eax
  80124b:	68 89 26 80 00       	push   $0x802689
  801250:	e8 3f ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125d:	eb 26                	jmp    801285 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80125f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801262:	8b 52 0c             	mov    0xc(%edx),%edx
  801265:	85 d2                	test   %edx,%edx
  801267:	74 17                	je     801280 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801269:	83 ec 04             	sub    $0x4,%esp
  80126c:	ff 75 10             	pushl  0x10(%ebp)
  80126f:	ff 75 0c             	pushl  0xc(%ebp)
  801272:	50                   	push   %eax
  801273:	ff d2                	call   *%edx
  801275:	89 c2                	mov    %eax,%edx
  801277:	83 c4 10             	add    $0x10,%esp
  80127a:	eb 09                	jmp    801285 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	eb 05                	jmp    801285 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801280:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801285:	89 d0                	mov    %edx,%eax
  801287:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128a:	c9                   	leave  
  80128b:	c3                   	ret    

0080128c <seek>:

int
seek(int fdnum, off_t offset)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801292:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801295:	50                   	push   %eax
  801296:	ff 75 08             	pushl  0x8(%ebp)
  801299:	e8 22 fc ff ff       	call   800ec0 <fd_lookup>
  80129e:	83 c4 08             	add    $0x8,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 0e                	js     8012b3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ab:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 14             	sub    $0x14,%esp
  8012bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c2:	50                   	push   %eax
  8012c3:	53                   	push   %ebx
  8012c4:	e8 f7 fb ff ff       	call   800ec0 <fd_lookup>
  8012c9:	83 c4 08             	add    $0x8,%esp
  8012cc:	89 c2                	mov    %eax,%edx
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 65                	js     801337 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d2:	83 ec 08             	sub    $0x8,%esp
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	50                   	push   %eax
  8012d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dc:	ff 30                	pushl  (%eax)
  8012de:	e8 33 fc ff ff       	call   800f16 <dev_lookup>
  8012e3:	83 c4 10             	add    $0x10,%esp
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 44                	js     80132e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f1:	75 21                	jne    801314 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012f3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012f8:	8b 40 48             	mov    0x48(%eax),%eax
  8012fb:	83 ec 04             	sub    $0x4,%esp
  8012fe:	53                   	push   %ebx
  8012ff:	50                   	push   %eax
  801300:	68 4c 26 80 00       	push   $0x80264c
  801305:	e8 8a ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801312:	eb 23                	jmp    801337 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801314:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801317:	8b 52 18             	mov    0x18(%edx),%edx
  80131a:	85 d2                	test   %edx,%edx
  80131c:	74 14                	je     801332 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	ff 75 0c             	pushl  0xc(%ebp)
  801324:	50                   	push   %eax
  801325:	ff d2                	call   *%edx
  801327:	89 c2                	mov    %eax,%edx
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	eb 09                	jmp    801337 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132e:	89 c2                	mov    %eax,%edx
  801330:	eb 05                	jmp    801337 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801332:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801337:	89 d0                	mov    %edx,%eax
  801339:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	53                   	push   %ebx
  801342:	83 ec 14             	sub    $0x14,%esp
  801345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801348:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134b:	50                   	push   %eax
  80134c:	ff 75 08             	pushl  0x8(%ebp)
  80134f:	e8 6c fb ff ff       	call   800ec0 <fd_lookup>
  801354:	83 c4 08             	add    $0x8,%esp
  801357:	89 c2                	mov    %eax,%edx
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 58                	js     8013b5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801367:	ff 30                	pushl  (%eax)
  801369:	e8 a8 fb ff ff       	call   800f16 <dev_lookup>
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 37                	js     8013ac <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801378:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80137c:	74 32                	je     8013b0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80137e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801381:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801388:	00 00 00 
	stat->st_isdir = 0;
  80138b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801392:	00 00 00 
	stat->st_dev = dev;
  801395:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80139b:	83 ec 08             	sub    $0x8,%esp
  80139e:	53                   	push   %ebx
  80139f:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a2:	ff 50 14             	call   *0x14(%eax)
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	eb 09                	jmp    8013b5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	eb 05                	jmp    8013b5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013b5:	89 d0                	mov    %edx,%eax
  8013b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	6a 00                	push   $0x0
  8013c6:	ff 75 08             	pushl  0x8(%ebp)
  8013c9:	e8 ef 01 00 00       	call   8015bd <open>
  8013ce:	89 c3                	mov    %eax,%ebx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 1b                	js     8013f2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	ff 75 0c             	pushl  0xc(%ebp)
  8013dd:	50                   	push   %eax
  8013de:	e8 5b ff ff ff       	call   80133e <fstat>
  8013e3:	89 c6                	mov    %eax,%esi
	close(fd);
  8013e5:	89 1c 24             	mov    %ebx,(%esp)
  8013e8:	e8 fd fb ff ff       	call   800fea <close>
	return r;
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	89 f0                	mov    %esi,%eax
}
  8013f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    

008013f9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	56                   	push   %esi
  8013fd:	53                   	push   %ebx
  8013fe:	89 c6                	mov    %eax,%esi
  801400:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801402:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801409:	75 12                	jne    80141d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80140b:	83 ec 0c             	sub    $0xc,%esp
  80140e:	6a 01                	push   $0x1
  801410:	e8 fc f9 ff ff       	call   800e11 <ipc_find_env>
  801415:	a3 00 40 80 00       	mov    %eax,0x804000
  80141a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80141d:	6a 07                	push   $0x7
  80141f:	68 00 50 80 00       	push   $0x805000
  801424:	56                   	push   %esi
  801425:	ff 35 00 40 80 00    	pushl  0x804000
  80142b:	e8 92 f9 ff ff       	call   800dc2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801430:	83 c4 0c             	add    $0xc,%esp
  801433:	6a 00                	push   $0x0
  801435:	53                   	push   %ebx
  801436:	6a 00                	push   $0x0
  801438:	e8 0f f9 ff ff       	call   800d4c <ipc_recv>
}
  80143d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801440:	5b                   	pop    %ebx
  801441:	5e                   	pop    %esi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	8b 40 0c             	mov    0xc(%eax),%eax
  801450:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801455:	8b 45 0c             	mov    0xc(%ebp),%eax
  801458:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80145d:	ba 00 00 00 00       	mov    $0x0,%edx
  801462:	b8 02 00 00 00       	mov    $0x2,%eax
  801467:	e8 8d ff ff ff       	call   8013f9 <fsipc>
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801474:	8b 45 08             	mov    0x8(%ebp),%eax
  801477:	8b 40 0c             	mov    0xc(%eax),%eax
  80147a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80147f:	ba 00 00 00 00       	mov    $0x0,%edx
  801484:	b8 06 00 00 00       	mov    $0x6,%eax
  801489:	e8 6b ff ff ff       	call   8013f9 <fsipc>
}
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	53                   	push   %ebx
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80149a:	8b 45 08             	mov    0x8(%ebp),%eax
  80149d:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8014af:	e8 45 ff ff ff       	call   8013f9 <fsipc>
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 2c                	js     8014e4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	68 00 50 80 00       	push   $0x805000
  8014c0:	53                   	push   %ebx
  8014c1:	e8 73 f2 ff ff       	call   800739 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014c6:	a1 80 50 80 00       	mov    0x805080,%eax
  8014cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d1:	a1 84 50 80 00       	mov    0x805084,%eax
  8014d6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8014f9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014ff:	a3 04 50 80 00       	mov    %eax,0x805004
  801504:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801509:	bb 08 50 80 00       	mov    $0x805008,%ebx
  80150e:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801511:	53                   	push   %ebx
  801512:	ff 75 0c             	pushl  0xc(%ebp)
  801515:	68 08 50 80 00       	push   $0x805008
  80151a:	e8 ac f3 ff ff       	call   8008cb <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 04 00 00 00       	mov    $0x4,%eax
  801529:	e8 cb fe ff ff       	call   8013f9 <fsipc>
  80152e:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801531:	85 c0                	test   %eax,%eax
  801533:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
  801540:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801543:	8b 45 08             	mov    0x8(%ebp),%eax
  801546:	8b 40 0c             	mov    0xc(%eax),%eax
  801549:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80154e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801554:	ba 00 00 00 00       	mov    $0x0,%edx
  801559:	b8 03 00 00 00       	mov    $0x3,%eax
  80155e:	e8 96 fe ff ff       	call   8013f9 <fsipc>
  801563:	89 c3                	mov    %eax,%ebx
  801565:	85 c0                	test   %eax,%eax
  801567:	78 4b                	js     8015b4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801569:	39 c6                	cmp    %eax,%esi
  80156b:	73 16                	jae    801583 <devfile_read+0x48>
  80156d:	68 bc 26 80 00       	push   $0x8026bc
  801572:	68 c3 26 80 00       	push   $0x8026c3
  801577:	6a 7c                	push   $0x7c
  801579:	68 d8 26 80 00       	push   $0x8026d8
  80157e:	e8 24 0a 00 00       	call   801fa7 <_panic>
	assert(r <= PGSIZE);
  801583:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801588:	7e 16                	jle    8015a0 <devfile_read+0x65>
  80158a:	68 e3 26 80 00       	push   $0x8026e3
  80158f:	68 c3 26 80 00       	push   $0x8026c3
  801594:	6a 7d                	push   $0x7d
  801596:	68 d8 26 80 00       	push   $0x8026d8
  80159b:	e8 07 0a 00 00       	call   801fa7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015a0:	83 ec 04             	sub    $0x4,%esp
  8015a3:	50                   	push   %eax
  8015a4:	68 00 50 80 00       	push   $0x805000
  8015a9:	ff 75 0c             	pushl  0xc(%ebp)
  8015ac:	e8 1a f3 ff ff       	call   8008cb <memmove>
	return r;
  8015b1:	83 c4 10             	add    $0x10,%esp
}
  8015b4:	89 d8                	mov    %ebx,%eax
  8015b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b9:	5b                   	pop    %ebx
  8015ba:	5e                   	pop    %esi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	53                   	push   %ebx
  8015c1:	83 ec 20             	sub    $0x20,%esp
  8015c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c7:	53                   	push   %ebx
  8015c8:	e8 33 f1 ff ff       	call   800700 <strlen>
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d5:	7f 67                	jg     80163e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	e8 8e f8 ff ff       	call   800e71 <fd_alloc>
  8015e3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 57                	js     801643 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	68 00 50 80 00       	push   $0x805000
  8015f5:	e8 3f f1 ff ff       	call   800739 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801602:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801605:	b8 01 00 00 00       	mov    $0x1,%eax
  80160a:	e8 ea fd ff ff       	call   8013f9 <fsipc>
  80160f:	89 c3                	mov    %eax,%ebx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	79 14                	jns    80162c <open+0x6f>
		fd_close(fd, 0);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	6a 00                	push   $0x0
  80161d:	ff 75 f4             	pushl  -0xc(%ebp)
  801620:	e8 44 f9 ff ff       	call   800f69 <fd_close>
		return r;
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	89 da                	mov    %ebx,%edx
  80162a:	eb 17                	jmp    801643 <open+0x86>
	}

	return fd2num(fd);
  80162c:	83 ec 0c             	sub    $0xc,%esp
  80162f:	ff 75 f4             	pushl  -0xc(%ebp)
  801632:	e8 13 f8 ff ff       	call   800e4a <fd2num>
  801637:	89 c2                	mov    %eax,%edx
  801639:	83 c4 10             	add    $0x10,%esp
  80163c:	eb 05                	jmp    801643 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80163e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801643:	89 d0                	mov    %edx,%eax
  801645:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801650:	ba 00 00 00 00       	mov    $0x0,%edx
  801655:	b8 08 00 00 00       	mov    $0x8,%eax
  80165a:	e8 9a fd ff ff       	call   8013f9 <fsipc>
}
  80165f:	c9                   	leave  
  801660:	c3                   	ret    

00801661 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801669:	83 ec 0c             	sub    $0xc,%esp
  80166c:	ff 75 08             	pushl  0x8(%ebp)
  80166f:	e8 e6 f7 ff ff       	call   800e5a <fd2data>
  801674:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801676:	83 c4 08             	add    $0x8,%esp
  801679:	68 ef 26 80 00       	push   $0x8026ef
  80167e:	53                   	push   %ebx
  80167f:	e8 b5 f0 ff ff       	call   800739 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801684:	8b 46 04             	mov    0x4(%esi),%eax
  801687:	2b 06                	sub    (%esi),%eax
  801689:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80168f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801696:	00 00 00 
	stat->st_dev = &devpipe;
  801699:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016a0:	30 80 00 
	return 0;
}
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 0c             	sub    $0xc,%esp
  8016b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016b9:	53                   	push   %ebx
  8016ba:	6a 00                	push   $0x0
  8016bc:	e8 00 f5 ff ff       	call   800bc1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016c1:	89 1c 24             	mov    %ebx,(%esp)
  8016c4:	e8 91 f7 ff ff       	call   800e5a <fd2data>
  8016c9:	83 c4 08             	add    $0x8,%esp
  8016cc:	50                   	push   %eax
  8016cd:	6a 00                	push   $0x0
  8016cf:	e8 ed f4 ff ff       	call   800bc1 <sys_page_unmap>
}
  8016d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	57                   	push   %edi
  8016dd:	56                   	push   %esi
  8016de:	53                   	push   %ebx
  8016df:	83 ec 1c             	sub    $0x1c,%esp
  8016e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016e7:	a1 08 40 80 00       	mov    0x804008,%eax
  8016ec:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f5:	e8 f3 08 00 00       	call   801fed <pageref>
  8016fa:	89 c3                	mov    %eax,%ebx
  8016fc:	89 3c 24             	mov    %edi,(%esp)
  8016ff:	e8 e9 08 00 00       	call   801fed <pageref>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	39 c3                	cmp    %eax,%ebx
  801709:	0f 94 c1             	sete   %cl
  80170c:	0f b6 c9             	movzbl %cl,%ecx
  80170f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801712:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801718:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80171b:	39 ce                	cmp    %ecx,%esi
  80171d:	74 1b                	je     80173a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80171f:	39 c3                	cmp    %eax,%ebx
  801721:	75 c4                	jne    8016e7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801723:	8b 42 58             	mov    0x58(%edx),%eax
  801726:	ff 75 e4             	pushl  -0x1c(%ebp)
  801729:	50                   	push   %eax
  80172a:	56                   	push   %esi
  80172b:	68 f6 26 80 00       	push   $0x8026f6
  801730:	e8 5f ea ff ff       	call   800194 <cprintf>
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	eb ad                	jmp    8016e7 <_pipeisclosed+0xe>
	}
}
  80173a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	57                   	push   %edi
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	83 ec 28             	sub    $0x28,%esp
  80174e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801751:	56                   	push   %esi
  801752:	e8 03 f7 ff ff       	call   800e5a <fd2data>
  801757:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	bf 00 00 00 00       	mov    $0x0,%edi
  801761:	eb 4b                	jmp    8017ae <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801763:	89 da                	mov    %ebx,%edx
  801765:	89 f0                	mov    %esi,%eax
  801767:	e8 6d ff ff ff       	call   8016d9 <_pipeisclosed>
  80176c:	85 c0                	test   %eax,%eax
  80176e:	75 48                	jne    8017b8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801770:	e8 a8 f3 ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801775:	8b 43 04             	mov    0x4(%ebx),%eax
  801778:	8b 0b                	mov    (%ebx),%ecx
  80177a:	8d 51 20             	lea    0x20(%ecx),%edx
  80177d:	39 d0                	cmp    %edx,%eax
  80177f:	73 e2                	jae    801763 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801784:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801788:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	c1 fa 1f             	sar    $0x1f,%edx
  801790:	89 d1                	mov    %edx,%ecx
  801792:	c1 e9 1b             	shr    $0x1b,%ecx
  801795:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801798:	83 e2 1f             	and    $0x1f,%edx
  80179b:	29 ca                	sub    %ecx,%edx
  80179d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017a5:	83 c0 01             	add    $0x1,%eax
  8017a8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017ab:	83 c7 01             	add    $0x1,%edi
  8017ae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017b1:	75 c2                	jne    801775 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b6:	eb 05                	jmp    8017bd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5e                   	pop    %esi
  8017c2:	5f                   	pop    %edi
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	57                   	push   %edi
  8017c9:	56                   	push   %esi
  8017ca:	53                   	push   %ebx
  8017cb:	83 ec 18             	sub    $0x18,%esp
  8017ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017d1:	57                   	push   %edi
  8017d2:	e8 83 f6 ff ff       	call   800e5a <fd2data>
  8017d7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e1:	eb 3d                	jmp    801820 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017e3:	85 db                	test   %ebx,%ebx
  8017e5:	74 04                	je     8017eb <devpipe_read+0x26>
				return i;
  8017e7:	89 d8                	mov    %ebx,%eax
  8017e9:	eb 44                	jmp    80182f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017eb:	89 f2                	mov    %esi,%edx
  8017ed:	89 f8                	mov    %edi,%eax
  8017ef:	e8 e5 fe ff ff       	call   8016d9 <_pipeisclosed>
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	75 32                	jne    80182a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017f8:	e8 20 f3 ff ff       	call   800b1d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017fd:	8b 06                	mov    (%esi),%eax
  8017ff:	3b 46 04             	cmp    0x4(%esi),%eax
  801802:	74 df                	je     8017e3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801804:	99                   	cltd   
  801805:	c1 ea 1b             	shr    $0x1b,%edx
  801808:	01 d0                	add    %edx,%eax
  80180a:	83 e0 1f             	and    $0x1f,%eax
  80180d:	29 d0                	sub    %edx,%eax
  80180f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801817:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80181a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80181d:	83 c3 01             	add    $0x1,%ebx
  801820:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801823:	75 d8                	jne    8017fd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801825:	8b 45 10             	mov    0x10(%ebp),%eax
  801828:	eb 05                	jmp    80182f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80182a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80182f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5f                   	pop    %edi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	50                   	push   %eax
  801843:	e8 29 f6 ff ff       	call   800e71 <fd_alloc>
  801848:	83 c4 10             	add    $0x10,%esp
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	85 c0                	test   %eax,%eax
  80184f:	0f 88 2c 01 00 00    	js     801981 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801855:	83 ec 04             	sub    $0x4,%esp
  801858:	68 07 04 00 00       	push   $0x407
  80185d:	ff 75 f4             	pushl  -0xc(%ebp)
  801860:	6a 00                	push   $0x0
  801862:	e8 d5 f2 ff ff       	call   800b3c <sys_page_alloc>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	89 c2                	mov    %eax,%edx
  80186c:	85 c0                	test   %eax,%eax
  80186e:	0f 88 0d 01 00 00    	js     801981 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801874:	83 ec 0c             	sub    $0xc,%esp
  801877:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187a:	50                   	push   %eax
  80187b:	e8 f1 f5 ff ff       	call   800e71 <fd_alloc>
  801880:	89 c3                	mov    %eax,%ebx
  801882:	83 c4 10             	add    $0x10,%esp
  801885:	85 c0                	test   %eax,%eax
  801887:	0f 88 e2 00 00 00    	js     80196f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188d:	83 ec 04             	sub    $0x4,%esp
  801890:	68 07 04 00 00       	push   $0x407
  801895:	ff 75 f0             	pushl  -0x10(%ebp)
  801898:	6a 00                	push   $0x0
  80189a:	e8 9d f2 ff ff       	call   800b3c <sys_page_alloc>
  80189f:	89 c3                	mov    %eax,%ebx
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	0f 88 c3 00 00 00    	js     80196f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018ac:	83 ec 0c             	sub    $0xc,%esp
  8018af:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b2:	e8 a3 f5 ff ff       	call   800e5a <fd2data>
  8018b7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b9:	83 c4 0c             	add    $0xc,%esp
  8018bc:	68 07 04 00 00       	push   $0x407
  8018c1:	50                   	push   %eax
  8018c2:	6a 00                	push   $0x0
  8018c4:	e8 73 f2 ff ff       	call   800b3c <sys_page_alloc>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	0f 88 89 00 00 00    	js     80195f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018dc:	e8 79 f5 ff ff       	call   800e5a <fd2data>
  8018e1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018e8:	50                   	push   %eax
  8018e9:	6a 00                	push   $0x0
  8018eb:	56                   	push   %esi
  8018ec:	6a 00                	push   $0x0
  8018ee:	e8 8c f2 ff ff       	call   800b7f <sys_page_map>
  8018f3:	89 c3                	mov    %eax,%ebx
  8018f5:	83 c4 20             	add    $0x20,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 55                	js     801951 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018fc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801905:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801907:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801911:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80191c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	e8 19 f5 ff ff       	call   800e4a <fd2num>
  801931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801934:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801936:	83 c4 04             	add    $0x4,%esp
  801939:	ff 75 f0             	pushl  -0x10(%ebp)
  80193c:	e8 09 f5 ff ff       	call   800e4a <fd2num>
  801941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801944:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	ba 00 00 00 00       	mov    $0x0,%edx
  80194f:	eb 30                	jmp    801981 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801951:	83 ec 08             	sub    $0x8,%esp
  801954:	56                   	push   %esi
  801955:	6a 00                	push   $0x0
  801957:	e8 65 f2 ff ff       	call   800bc1 <sys_page_unmap>
  80195c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	ff 75 f0             	pushl  -0x10(%ebp)
  801965:	6a 00                	push   $0x0
  801967:	e8 55 f2 ff ff       	call   800bc1 <sys_page_unmap>
  80196c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	ff 75 f4             	pushl  -0xc(%ebp)
  801975:	6a 00                	push   $0x0
  801977:	e8 45 f2 ff ff       	call   800bc1 <sys_page_unmap>
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801981:	89 d0                	mov    %edx,%eax
  801983:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5d                   	pop    %ebp
  801989:	c3                   	ret    

0080198a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801990:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801993:	50                   	push   %eax
  801994:	ff 75 08             	pushl  0x8(%ebp)
  801997:	e8 24 f5 ff ff       	call   800ec0 <fd_lookup>
  80199c:	83 c4 10             	add    $0x10,%esp
  80199f:	85 c0                	test   %eax,%eax
  8019a1:	78 18                	js     8019bb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019a3:	83 ec 0c             	sub    $0xc,%esp
  8019a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a9:	e8 ac f4 ff ff       	call   800e5a <fd2data>
	return _pipeisclosed(fd, p);
  8019ae:	89 c2                	mov    %eax,%edx
  8019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b3:	e8 21 fd ff ff       	call   8016d9 <_pipeisclosed>
  8019b8:	83 c4 10             	add    $0x10,%esp
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019c3:	68 0e 27 80 00       	push   $0x80270e
  8019c8:	ff 75 0c             	pushl  0xc(%ebp)
  8019cb:	e8 69 ed ff ff       	call   800739 <strcpy>
	return 0;
}
  8019d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	53                   	push   %ebx
  8019db:	83 ec 10             	sub    $0x10,%esp
  8019de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019e1:	53                   	push   %ebx
  8019e2:	e8 06 06 00 00       	call   801fed <pageref>
  8019e7:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019ea:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019ef:	83 f8 01             	cmp    $0x1,%eax
  8019f2:	75 10                	jne    801a04 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019f4:	83 ec 0c             	sub    $0xc,%esp
  8019f7:	ff 73 0c             	pushl  0xc(%ebx)
  8019fa:	e8 c0 02 00 00       	call   801cbf <nsipc_close>
  8019ff:	89 c2                	mov    %eax,%edx
  801a01:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a04:	89 d0                	mov    %edx,%eax
  801a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a11:	6a 00                	push   $0x0
  801a13:	ff 75 10             	pushl  0x10(%ebp)
  801a16:	ff 75 0c             	pushl  0xc(%ebp)
  801a19:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1c:	ff 70 0c             	pushl  0xc(%eax)
  801a1f:	e8 78 03 00 00       	call   801d9c <nsipc_send>
}
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a2c:	6a 00                	push   $0x0
  801a2e:	ff 75 10             	pushl  0x10(%ebp)
  801a31:	ff 75 0c             	pushl  0xc(%ebp)
  801a34:	8b 45 08             	mov    0x8(%ebp),%eax
  801a37:	ff 70 0c             	pushl  0xc(%eax)
  801a3a:	e8 f1 02 00 00       	call   801d30 <nsipc_recv>
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a47:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a4a:	52                   	push   %edx
  801a4b:	50                   	push   %eax
  801a4c:	e8 6f f4 ff ff       	call   800ec0 <fd_lookup>
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 17                	js     801a6f <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5b:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801a61:	39 08                	cmp    %ecx,(%eax)
  801a63:	75 05                	jne    801a6a <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a65:	8b 40 0c             	mov    0xc(%eax),%eax
  801a68:	eb 05                	jmp    801a6f <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a6a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 1c             	sub    $0x1c,%esp
  801a79:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7e:	50                   	push   %eax
  801a7f:	e8 ed f3 ff ff       	call   800e71 <fd_alloc>
  801a84:	89 c3                	mov    %eax,%ebx
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	78 1b                	js     801aa8 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a8d:	83 ec 04             	sub    $0x4,%esp
  801a90:	68 07 04 00 00       	push   $0x407
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 9d f0 ff ff       	call   800b3c <sys_page_alloc>
  801a9f:	89 c3                	mov    %eax,%ebx
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	79 10                	jns    801ab8 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	56                   	push   %esi
  801aac:	e8 0e 02 00 00       	call   801cbf <nsipc_close>
		return r;
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	89 d8                	mov    %ebx,%eax
  801ab6:	eb 24                	jmp    801adc <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ab8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801acd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	50                   	push   %eax
  801ad4:	e8 71 f3 ff ff       	call   800e4a <fd2num>
  801ad9:	83 c4 10             	add    $0x10,%esp
}
  801adc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    

00801ae3 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	e8 50 ff ff ff       	call   801a41 <fd2sockid>
		return r;
  801af1:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 1f                	js     801b16 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	ff 75 10             	pushl  0x10(%ebp)
  801afd:	ff 75 0c             	pushl  0xc(%ebp)
  801b00:	50                   	push   %eax
  801b01:	e8 12 01 00 00       	call   801c18 <nsipc_accept>
  801b06:	83 c4 10             	add    $0x10,%esp
		return r;
  801b09:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b0b:	85 c0                	test   %eax,%eax
  801b0d:	78 07                	js     801b16 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b0f:	e8 5d ff ff ff       	call   801a71 <alloc_sockfd>
  801b14:	89 c1                	mov    %eax,%ecx
}
  801b16:	89 c8                	mov    %ecx,%eax
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b20:	8b 45 08             	mov    0x8(%ebp),%eax
  801b23:	e8 19 ff ff ff       	call   801a41 <fd2sockid>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 12                	js     801b3e <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b2c:	83 ec 04             	sub    $0x4,%esp
  801b2f:	ff 75 10             	pushl  0x10(%ebp)
  801b32:	ff 75 0c             	pushl  0xc(%ebp)
  801b35:	50                   	push   %eax
  801b36:	e8 2d 01 00 00       	call   801c68 <nsipc_bind>
  801b3b:	83 c4 10             	add    $0x10,%esp
}
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <shutdown>:

int
shutdown(int s, int how)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
  801b49:	e8 f3 fe ff ff       	call   801a41 <fd2sockid>
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 0f                	js     801b61 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	ff 75 0c             	pushl  0xc(%ebp)
  801b58:	50                   	push   %eax
  801b59:	e8 3f 01 00 00       	call   801c9d <nsipc_shutdown>
  801b5e:	83 c4 10             	add    $0x10,%esp
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b69:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6c:	e8 d0 fe ff ff       	call   801a41 <fd2sockid>
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 12                	js     801b87 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b75:	83 ec 04             	sub    $0x4,%esp
  801b78:	ff 75 10             	pushl  0x10(%ebp)
  801b7b:	ff 75 0c             	pushl  0xc(%ebp)
  801b7e:	50                   	push   %eax
  801b7f:	e8 55 01 00 00       	call   801cd9 <nsipc_connect>
  801b84:	83 c4 10             	add    $0x10,%esp
}
  801b87:	c9                   	leave  
  801b88:	c3                   	ret    

00801b89 <listen>:

int
listen(int s, int backlog)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b92:	e8 aa fe ff ff       	call   801a41 <fd2sockid>
  801b97:	85 c0                	test   %eax,%eax
  801b99:	78 0f                	js     801baa <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ba1:	50                   	push   %eax
  801ba2:	e8 67 01 00 00       	call   801d0e <nsipc_listen>
  801ba7:	83 c4 10             	add    $0x10,%esp
}
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bb2:	ff 75 10             	pushl  0x10(%ebp)
  801bb5:	ff 75 0c             	pushl  0xc(%ebp)
  801bb8:	ff 75 08             	pushl  0x8(%ebp)
  801bbb:	e8 3a 02 00 00       	call   801dfa <nsipc_socket>
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	85 c0                	test   %eax,%eax
  801bc5:	78 05                	js     801bcc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bc7:	e8 a5 fe ff ff       	call   801a71 <alloc_sockfd>
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	53                   	push   %ebx
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bd7:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bde:	75 12                	jne    801bf2 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	6a 02                	push   $0x2
  801be5:	e8 27 f2 ff ff       	call   800e11 <ipc_find_env>
  801bea:	a3 04 40 80 00       	mov    %eax,0x804004
  801bef:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bf2:	6a 07                	push   $0x7
  801bf4:	68 00 60 80 00       	push   $0x806000
  801bf9:	53                   	push   %ebx
  801bfa:	ff 35 04 40 80 00    	pushl  0x804004
  801c00:	e8 bd f1 ff ff       	call   800dc2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c05:	83 c4 0c             	add    $0xc,%esp
  801c08:	6a 00                	push   $0x0
  801c0a:	6a 00                	push   $0x0
  801c0c:	6a 00                	push   $0x0
  801c0e:	e8 39 f1 ff ff       	call   800d4c <ipc_recv>
}
  801c13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c20:	8b 45 08             	mov    0x8(%ebp),%eax
  801c23:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c28:	8b 06                	mov    (%esi),%eax
  801c2a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c2f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c34:	e8 95 ff ff ff       	call   801bce <nsipc>
  801c39:	89 c3                	mov    %eax,%ebx
  801c3b:	85 c0                	test   %eax,%eax
  801c3d:	78 20                	js     801c5f <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c3f:	83 ec 04             	sub    $0x4,%esp
  801c42:	ff 35 10 60 80 00    	pushl  0x806010
  801c48:	68 00 60 80 00       	push   $0x806000
  801c4d:	ff 75 0c             	pushl  0xc(%ebp)
  801c50:	e8 76 ec ff ff       	call   8008cb <memmove>
		*addrlen = ret->ret_addrlen;
  801c55:	a1 10 60 80 00       	mov    0x806010,%eax
  801c5a:	89 06                	mov    %eax,(%esi)
  801c5c:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 08             	sub    $0x8,%esp
  801c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c7a:	53                   	push   %ebx
  801c7b:	ff 75 0c             	pushl  0xc(%ebp)
  801c7e:	68 04 60 80 00       	push   $0x806004
  801c83:	e8 43 ec ff ff       	call   8008cb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c88:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c8e:	b8 02 00 00 00       	mov    $0x2,%eax
  801c93:	e8 36 ff ff ff       	call   801bce <nsipc>
}
  801c98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801cab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cae:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cb3:	b8 03 00 00 00       	mov    $0x3,%eax
  801cb8:	e8 11 ff ff ff       	call   801bce <nsipc>
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <nsipc_close>:

int
nsipc_close(int s)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc8:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ccd:	b8 04 00 00 00       	mov    $0x4,%eax
  801cd2:	e8 f7 fe ff ff       	call   801bce <nsipc>
}
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    

00801cd9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 08             	sub    $0x8,%esp
  801ce0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ceb:	53                   	push   %ebx
  801cec:	ff 75 0c             	pushl  0xc(%ebp)
  801cef:	68 04 60 80 00       	push   $0x806004
  801cf4:	e8 d2 eb ff ff       	call   8008cb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cf9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cff:	b8 05 00 00 00       	mov    $0x5,%eax
  801d04:	e8 c5 fe ff ff       	call   801bce <nsipc>
}
  801d09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d24:	b8 06 00 00 00       	mov    $0x6,%eax
  801d29:	e8 a0 fe ff ff       	call   801bce <nsipc>
}
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	56                   	push   %esi
  801d34:	53                   	push   %ebx
  801d35:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d38:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d40:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d46:	8b 45 14             	mov    0x14(%ebp),%eax
  801d49:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d4e:	b8 07 00 00 00       	mov    $0x7,%eax
  801d53:	e8 76 fe ff ff       	call   801bce <nsipc>
  801d58:	89 c3                	mov    %eax,%ebx
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 35                	js     801d93 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d5e:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d63:	7f 04                	jg     801d69 <nsipc_recv+0x39>
  801d65:	39 c6                	cmp    %eax,%esi
  801d67:	7d 16                	jge    801d7f <nsipc_recv+0x4f>
  801d69:	68 1a 27 80 00       	push   $0x80271a
  801d6e:	68 c3 26 80 00       	push   $0x8026c3
  801d73:	6a 62                	push   $0x62
  801d75:	68 2f 27 80 00       	push   $0x80272f
  801d7a:	e8 28 02 00 00       	call   801fa7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d7f:	83 ec 04             	sub    $0x4,%esp
  801d82:	50                   	push   %eax
  801d83:	68 00 60 80 00       	push   $0x806000
  801d88:	ff 75 0c             	pushl  0xc(%ebp)
  801d8b:	e8 3b eb ff ff       	call   8008cb <memmove>
  801d90:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d93:	89 d8                	mov    %ebx,%eax
  801d95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    

00801d9c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
  801d9f:	53                   	push   %ebx
  801da0:	83 ec 04             	sub    $0x4,%esp
  801da3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801da6:	8b 45 08             	mov    0x8(%ebp),%eax
  801da9:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dae:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801db4:	7e 16                	jle    801dcc <nsipc_send+0x30>
  801db6:	68 3b 27 80 00       	push   $0x80273b
  801dbb:	68 c3 26 80 00       	push   $0x8026c3
  801dc0:	6a 6d                	push   $0x6d
  801dc2:	68 2f 27 80 00       	push   $0x80272f
  801dc7:	e8 db 01 00 00       	call   801fa7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dcc:	83 ec 04             	sub    $0x4,%esp
  801dcf:	53                   	push   %ebx
  801dd0:	ff 75 0c             	pushl  0xc(%ebp)
  801dd3:	68 0c 60 80 00       	push   $0x80600c
  801dd8:	e8 ee ea ff ff       	call   8008cb <memmove>
	nsipcbuf.send.req_size = size;
  801ddd:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801de3:	8b 45 14             	mov    0x14(%ebp),%eax
  801de6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801deb:	b8 08 00 00 00       	mov    $0x8,%eax
  801df0:	e8 d9 fd ff ff       	call   801bce <nsipc>
}
  801df5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e00:	8b 45 08             	mov    0x8(%ebp),%eax
  801e03:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e10:	8b 45 10             	mov    0x10(%ebp),%eax
  801e13:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e18:	b8 09 00 00 00       	mov    $0x9,%eax
  801e1d:	e8 ac fd ff ff       	call   801bce <nsipc>
}
  801e22:	c9                   	leave  
  801e23:	c3                   	ret    

00801e24 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e27:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    

00801e2e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e34:	68 47 27 80 00       	push   $0x802747
  801e39:	ff 75 0c             	pushl  0xc(%ebp)
  801e3c:	e8 f8 e8 ff ff       	call   800739 <strcpy>
	return 0;
}
  801e41:	b8 00 00 00 00       	mov    $0x0,%eax
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	57                   	push   %edi
  801e4c:	56                   	push   %esi
  801e4d:	53                   	push   %ebx
  801e4e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e54:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e59:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e5f:	eb 2d                	jmp    801e8e <devcons_write+0x46>
		m = n - tot;
  801e61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e64:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e66:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e69:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e6e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e71:	83 ec 04             	sub    $0x4,%esp
  801e74:	53                   	push   %ebx
  801e75:	03 45 0c             	add    0xc(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	57                   	push   %edi
  801e7a:	e8 4c ea ff ff       	call   8008cb <memmove>
		sys_cputs(buf, m);
  801e7f:	83 c4 08             	add    $0x8,%esp
  801e82:	53                   	push   %ebx
  801e83:	57                   	push   %edi
  801e84:	e8 f7 eb ff ff       	call   800a80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e89:	01 de                	add    %ebx,%esi
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	89 f0                	mov    %esi,%eax
  801e90:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e93:	72 cc                	jb     801e61 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 08             	sub    $0x8,%esp
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ea8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801eac:	74 2a                	je     801ed8 <devcons_read+0x3b>
  801eae:	eb 05                	jmp    801eb5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eb0:	e8 68 ec ff ff       	call   800b1d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801eb5:	e8 e4 eb ff ff       	call   800a9e <sys_cgetc>
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	74 f2                	je     801eb0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 16                	js     801ed8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ec2:	83 f8 04             	cmp    $0x4,%eax
  801ec5:	74 0c                	je     801ed3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ec7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eca:	88 02                	mov    %al,(%edx)
	return 1;
  801ecc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed1:	eb 05                	jmp    801ed8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ee6:	6a 01                	push   $0x1
  801ee8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eeb:	50                   	push   %eax
  801eec:	e8 8f eb ff ff       	call   800a80 <sys_cputs>
}
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <getchar>:

int
getchar(void)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801efc:	6a 01                	push   $0x1
  801efe:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f01:	50                   	push   %eax
  801f02:	6a 00                	push   $0x0
  801f04:	e8 1d f2 ff ff       	call   801126 <read>
	if (r < 0)
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 0f                	js     801f1f <getchar+0x29>
		return r;
	if (r < 1)
  801f10:	85 c0                	test   %eax,%eax
  801f12:	7e 06                	jle    801f1a <getchar+0x24>
		return -E_EOF;
	return c;
  801f14:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f18:	eb 05                	jmp    801f1f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f1a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f2a:	50                   	push   %eax
  801f2b:	ff 75 08             	pushl  0x8(%ebp)
  801f2e:	e8 8d ef ff ff       	call   800ec0 <fd_lookup>
  801f33:	83 c4 10             	add    $0x10,%esp
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 11                	js     801f4b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f43:	39 10                	cmp    %edx,(%eax)
  801f45:	0f 94 c0             	sete   %al
  801f48:	0f b6 c0             	movzbl %al,%eax
}
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    

00801f4d <opencons>:

int
opencons(void)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f56:	50                   	push   %eax
  801f57:	e8 15 ef ff ff       	call   800e71 <fd_alloc>
  801f5c:	83 c4 10             	add    $0x10,%esp
		return r;
  801f5f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 3e                	js     801fa3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f65:	83 ec 04             	sub    $0x4,%esp
  801f68:	68 07 04 00 00       	push   $0x407
  801f6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f70:	6a 00                	push   $0x0
  801f72:	e8 c5 eb ff ff       	call   800b3c <sys_page_alloc>
  801f77:	83 c4 10             	add    $0x10,%esp
		return r;
  801f7a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	78 23                	js     801fa3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f80:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f89:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f95:	83 ec 0c             	sub    $0xc,%esp
  801f98:	50                   	push   %eax
  801f99:	e8 ac ee ff ff       	call   800e4a <fd2num>
  801f9e:	89 c2                	mov    %eax,%edx
  801fa0:	83 c4 10             	add    $0x10,%esp
}
  801fa3:	89 d0                	mov    %edx,%eax
  801fa5:	c9                   	leave  
  801fa6:	c3                   	ret    

00801fa7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	56                   	push   %esi
  801fab:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801fac:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801faf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801fb5:	e8 44 eb ff ff       	call   800afe <sys_getenvid>
  801fba:	83 ec 0c             	sub    $0xc,%esp
  801fbd:	ff 75 0c             	pushl  0xc(%ebp)
  801fc0:	ff 75 08             	pushl  0x8(%ebp)
  801fc3:	56                   	push   %esi
  801fc4:	50                   	push   %eax
  801fc5:	68 54 27 80 00       	push   $0x802754
  801fca:	e8 c5 e1 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fcf:	83 c4 18             	add    $0x18,%esp
  801fd2:	53                   	push   %ebx
  801fd3:	ff 75 10             	pushl  0x10(%ebp)
  801fd6:	e8 68 e1 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801fdb:	c7 04 24 07 27 80 00 	movl   $0x802707,(%esp)
  801fe2:	e8 ad e1 ff ff       	call   800194 <cprintf>
  801fe7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fea:	cc                   	int3   
  801feb:	eb fd                	jmp    801fea <_panic+0x43>

00801fed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fed:	55                   	push   %ebp
  801fee:	89 e5                	mov    %esp,%ebp
  801ff0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff3:	89 d0                	mov    %edx,%eax
  801ff5:	c1 e8 16             	shr    $0x16,%eax
  801ff8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802004:	f6 c1 01             	test   $0x1,%cl
  802007:	74 1d                	je     802026 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802009:	c1 ea 0c             	shr    $0xc,%edx
  80200c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802013:	f6 c2 01             	test   $0x1,%dl
  802016:	74 0e                	je     802026 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802018:	c1 ea 0c             	shr    $0xc,%edx
  80201b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802022:	ef 
  802023:	0f b7 c0             	movzwl %ax,%eax
}
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

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
