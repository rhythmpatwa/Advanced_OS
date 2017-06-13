
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 a0 26 80 00       	push   $0x8026a0
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 0b 0e 00 00       	call   800e54 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 18 27 80 00       	push   $0x802718
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 c8 26 80 00       	push   $0x8026c8
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 bb 0a 00 00       	call   800b31 <sys_yield>
	sys_yield();
  800076:	e8 b6 0a 00 00       	call   800b31 <sys_yield>
	sys_yield();
  80007b:	e8 b1 0a 00 00       	call   800b31 <sys_yield>
	sys_yield();
  800080:	e8 ac 0a 00 00       	call   800b31 <sys_yield>
	sys_yield();
  800085:	e8 a7 0a 00 00       	call   800b31 <sys_yield>
	sys_yield();
  80008a:	e8 a2 0a 00 00       	call   800b31 <sys_yield>
	sys_yield();
  80008f:	e8 9d 0a 00 00       	call   800b31 <sys_yield>
	sys_yield();
  800094:	e8 98 0a 00 00       	call   800b31 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 f0 26 80 00 	movl   $0x8026f0,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 24 0a 00 00       	call   800ad1 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000c0:	e8 4d 0a 00 00       	call   800b12 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 51 11 00 00       	call   801257 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 c1 09 00 00       	call   800ad1 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 4f 09 00 00       	call   800a94 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 54 01 00 00       	call   8002df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 f4 08 00 00       	call   800a94 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 f0 21 00 00       	call   802400 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 dd 22 00 00       	call   802530 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 40 27 80 00 	movsbl 0x802740(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026e:	83 fa 01             	cmp    $0x1,%edx
  800271:	7e 0e                	jle    800281 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 08             	lea    0x8(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	8b 52 04             	mov    0x4(%edx),%edx
  80027f:	eb 22                	jmp    8002a3 <getuint+0x38>
	else if (lflag)
  800281:	85 d2                	test   %edx,%edx
  800283:	74 10                	je     800295 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800285:	8b 10                	mov    (%eax),%edx
  800287:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028a:	89 08                	mov    %ecx,(%eax)
  80028c:	8b 02                	mov    (%edx),%eax
  80028e:	ba 00 00 00 00       	mov    $0x0,%edx
  800293:	eb 0e                	jmp    8002a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800295:	8b 10                	mov    (%eax),%edx
  800297:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 02                	mov    (%edx),%eax
  80029e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002af:	8b 10                	mov    (%eax),%edx
  8002b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b4:	73 0a                	jae    8002c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002be:	88 02                	mov    %al,(%edx)
}
  8002c0:	5d                   	pop    %ebp
  8002c1:	c3                   	ret    

008002c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c2:	55                   	push   %ebp
  8002c3:	89 e5                	mov    %esp,%ebp
  8002c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 10             	pushl  0x10(%ebp)
  8002cf:	ff 75 0c             	pushl  0xc(%ebp)
  8002d2:	ff 75 08             	pushl  0x8(%ebp)
  8002d5:	e8 05 00 00 00       	call   8002df <vprintfmt>
	va_end(ap);
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	c9                   	leave  
  8002de:	c3                   	ret    

008002df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 2c             	sub    $0x2c,%esp
  8002e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f1:	eb 12                	jmp    800305 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f3:	85 c0                	test   %eax,%eax
  8002f5:	0f 84 a9 03 00 00    	je     8006a4 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	75 e2                	jne    8002f3 <vprintfmt+0x14>
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
  80032f:	eb 07                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800334:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033e:	0f b6 07             	movzbl (%edi),%eax
  800341:	0f b6 c8             	movzbl %al,%ecx
  800344:	83 e8 23             	sub    $0x23,%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 3a 03 00 00    	ja     800689 <vprintfmt+0x3aa>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
  80036a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800370:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800374:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800377:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037a:	83 fa 09             	cmp    $0x9,%edx
  80037d:	77 39                	ja     8003b8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800382:	eb e9                	jmp    80036d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 48 04             	lea    0x4(%eax),%ecx
  80038a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038d:	8b 00                	mov    (%eax),%eax
  80038f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800395:	eb 27                	jmp    8003be <vprintfmt+0xdf>
  800397:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039a:	85 c0                	test   %eax,%eax
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	0f 49 c8             	cmovns %eax,%ecx
  8003a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003aa:	eb 8c                	jmp    800338 <vprintfmt+0x59>
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b6:	eb 80                	jmp    800338 <vprintfmt+0x59>
  8003b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c2:	0f 89 70 ff ff ff    	jns    800338 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d5:	e9 5e ff ff ff       	jmp    800338 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003da:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	83 ec 08             	sub    $0x8,%esp
  8003f1:	53                   	push   %ebx
  8003f2:	ff 30                	pushl  (%eax)
  8003f4:	ff d6                	call   *%esi
			break;
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fc:	e9 04 ff ff ff       	jmp    800305 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	99                   	cltd   
  80040d:	31 d0                	xor    %edx,%eax
  80040f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	83 f8 0f             	cmp    $0xf,%eax
  800414:	7f 0b                	jg     800421 <vprintfmt+0x142>
  800416:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  80041d:	85 d2                	test   %edx,%edx
  80041f:	75 18                	jne    800439 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800421:	50                   	push   %eax
  800422:	68 58 27 80 00       	push   $0x802758
  800427:	53                   	push   %ebx
  800428:	56                   	push   %esi
  800429:	e8 94 fe ff ff       	call   8002c2 <printfmt>
  80042e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800434:	e9 cc fe ff ff       	jmp    800305 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800439:	52                   	push   %edx
  80043a:	68 e9 2b 80 00       	push   $0x802be9
  80043f:	53                   	push   %ebx
  800440:	56                   	push   %esi
  800441:	e8 7c fe ff ff       	call   8002c2 <printfmt>
  800446:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044c:	e9 b4 fe ff ff       	jmp    800305 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045c:	85 ff                	test   %edi,%edi
  80045e:	b8 51 27 80 00       	mov    $0x802751,%eax
  800463:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046a:	0f 8e 94 00 00 00    	jle    800504 <vprintfmt+0x225>
  800470:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800474:	0f 84 98 00 00 00    	je     800512 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 d0             	pushl  -0x30(%ebp)
  800480:	57                   	push   %edi
  800481:	e8 a6 02 00 00       	call   80072c <strnlen>
  800486:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800489:	29 c1                	sub    %eax,%ecx
  80048b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800491:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800498:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	eb 0f                	jmp    8004ae <vprintfmt+0x1cf>
					putch(padc, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	53                   	push   %ebx
  8004a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ef 01             	sub    $0x1,%edi
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	7f ed                	jg     80049f <vprintfmt+0x1c0>
  8004b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b8:	85 c9                	test   %ecx,%ecx
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	0f 49 c1             	cmovns %ecx,%eax
  8004c2:	29 c1                	sub    %eax,%ecx
  8004c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cd:	89 cb                	mov    %ecx,%ebx
  8004cf:	eb 4d                	jmp    80051e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d5:	74 1b                	je     8004f2 <vprintfmt+0x213>
  8004d7:	0f be c0             	movsbl %al,%eax
  8004da:	83 e8 20             	sub    $0x20,%eax
  8004dd:	83 f8 5e             	cmp    $0x5e,%eax
  8004e0:	76 10                	jbe    8004f2 <vprintfmt+0x213>
					putch('?', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	ff 75 0c             	pushl  0xc(%ebp)
  8004e8:	6a 3f                	push   $0x3f
  8004ea:	ff 55 08             	call   *0x8(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 0d                	jmp    8004ff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	52                   	push   %edx
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	eb 1a                	jmp    80051e <vprintfmt+0x23f>
  800504:	89 75 08             	mov    %esi,0x8(%ebp)
  800507:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800510:	eb 0c                	jmp    80051e <vprintfmt+0x23f>
  800512:	89 75 08             	mov    %esi,0x8(%ebp)
  800515:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800518:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051e:	83 c7 01             	add    $0x1,%edi
  800521:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800525:	0f be d0             	movsbl %al,%edx
  800528:	85 d2                	test   %edx,%edx
  80052a:	74 23                	je     80054f <vprintfmt+0x270>
  80052c:	85 f6                	test   %esi,%esi
  80052e:	78 a1                	js     8004d1 <vprintfmt+0x1f2>
  800530:	83 ee 01             	sub    $0x1,%esi
  800533:	79 9c                	jns    8004d1 <vprintfmt+0x1f2>
  800535:	89 df                	mov    %ebx,%edi
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	eb 18                	jmp    800557 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 20                	push   $0x20
  800545:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800547:	83 ef 01             	sub    $0x1,%edi
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 08                	jmp    800557 <vprintfmt+0x278>
  80054f:	89 df                	mov    %ebx,%edi
  800551:	8b 75 08             	mov    0x8(%ebp),%esi
  800554:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800557:	85 ff                	test   %edi,%edi
  800559:	7f e4                	jg     80053f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055e:	e9 a2 fd ff ff       	jmp    800305 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800563:	83 fa 01             	cmp    $0x1,%edx
  800566:	7e 16                	jle    80057e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 08             	lea    0x8(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	eb 32                	jmp    8005b0 <vprintfmt+0x2d1>
	else if (lflag)
  80057e:	85 d2                	test   %edx,%edx
  800580:	74 18                	je     80059a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 04             	lea    0x4(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 c1                	mov    %eax,%ecx
  800592:	c1 f9 1f             	sar    $0x1f,%ecx
  800595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800598:	eb 16                	jmp    8005b0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 c1                	mov    %eax,%ecx
  8005aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005bf:	0f 89 90 00 00 00    	jns    800655 <vprintfmt+0x376>
				putch('-', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	6a 2d                	push   $0x2d
  8005cb:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d3:	f7 d8                	neg    %eax
  8005d5:	83 d2 00             	adc    $0x0,%edx
  8005d8:	f7 da                	neg    %edx
  8005da:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005e2:	eb 71                	jmp    800655 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e7:	e8 7f fc ff ff       	call   80026b <getuint>
			base = 10;
  8005ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005f1:	eb 62                	jmp    800655 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 70 fc ff ff       	call   80026b <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  800602:	51                   	push   %ecx
  800603:	ff 75 e0             	pushl  -0x20(%ebp)
  800606:	6a 08                	push   $0x8
  800608:	52                   	push   %edx
  800609:	50                   	push   %eax
  80060a:	89 da                	mov    %ebx,%edx
  80060c:	89 f0                	mov    %esi,%eax
  80060e:	e8 a9 fb ff ff       	call   8001bc <printnum>
			break;
  800613:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800619:	e9 e7 fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 30                	push   $0x30
  800624:	ff d6                	call   *%esi
			putch('x', putdat);
  800626:	83 c4 08             	add    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 78                	push   $0x78
  80062c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80063e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800641:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800646:	eb 0d                	jmp    800655 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800648:	8d 45 14             	lea    0x14(%ebp),%eax
  80064b:	e8 1b fc ff ff       	call   80026b <getuint>
			base = 16;
  800650:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800655:	83 ec 0c             	sub    $0xc,%esp
  800658:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80065c:	57                   	push   %edi
  80065d:	ff 75 e0             	pushl  -0x20(%ebp)
  800660:	51                   	push   %ecx
  800661:	52                   	push   %edx
  800662:	50                   	push   %eax
  800663:	89 da                	mov    %ebx,%edx
  800665:	89 f0                	mov    %esi,%eax
  800667:	e8 50 fb ff ff       	call   8001bc <printnum>
			break;
  80066c:	83 c4 20             	add    $0x20,%esp
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800672:	e9 8e fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	51                   	push   %ecx
  80067c:	ff d6                	call   *%esi
			break;
  80067e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800684:	e9 7c fc ff ff       	jmp    800305 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 25                	push   $0x25
  80068f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 03                	jmp    800699 <vprintfmt+0x3ba>
  800696:	83 ef 01             	sub    $0x1,%edi
  800699:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80069d:	75 f7                	jne    800696 <vprintfmt+0x3b7>
  80069f:	e9 61 fc ff ff       	jmp    800305 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a7:	5b                   	pop    %ebx
  8006a8:	5e                   	pop    %esi
  8006a9:	5f                   	pop    %edi
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    

008006ac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
  8006af:	83 ec 18             	sub    $0x18,%esp
  8006b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006bf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	74 26                	je     8006f3 <vsnprintf+0x47>
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	7e 22                	jle    8006f3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d1:	ff 75 14             	pushl  0x14(%ebp)
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	68 a5 02 80 00       	push   $0x8002a5
  8006e0:	e8 fa fb ff ff       	call   8002df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	eb 05                	jmp    8006f8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f8:	c9                   	leave  
  8006f9:	c3                   	ret    

008006fa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800700:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800703:	50                   	push   %eax
  800704:	ff 75 10             	pushl  0x10(%ebp)
  800707:	ff 75 0c             	pushl  0xc(%ebp)
  80070a:	ff 75 08             	pushl  0x8(%ebp)
  80070d:	e8 9a ff ff ff       	call   8006ac <vsnprintf>
	va_end(ap);

	return rc;
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071a:	b8 00 00 00 00       	mov    $0x0,%eax
  80071f:	eb 03                	jmp    800724 <strlen+0x10>
		n++;
  800721:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800724:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800728:	75 f7                	jne    800721 <strlen+0xd>
		n++;
	return n;
}
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800732:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800735:	ba 00 00 00 00       	mov    $0x0,%edx
  80073a:	eb 03                	jmp    80073f <strnlen+0x13>
		n++;
  80073c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	39 c2                	cmp    %eax,%edx
  800741:	74 08                	je     80074b <strnlen+0x1f>
  800743:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800747:	75 f3                	jne    80073c <strnlen+0x10>
  800749:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	53                   	push   %ebx
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800757:	89 c2                	mov    %eax,%edx
  800759:	83 c2 01             	add    $0x1,%edx
  80075c:	83 c1 01             	add    $0x1,%ecx
  80075f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800763:	88 5a ff             	mov    %bl,-0x1(%edx)
  800766:	84 db                	test   %bl,%bl
  800768:	75 ef                	jne    800759 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80076a:	5b                   	pop    %ebx
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	53                   	push   %ebx
  800771:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800774:	53                   	push   %ebx
  800775:	e8 9a ff ff ff       	call   800714 <strlen>
  80077a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80077d:	ff 75 0c             	pushl  0xc(%ebp)
  800780:	01 d8                	add    %ebx,%eax
  800782:	50                   	push   %eax
  800783:	e8 c5 ff ff ff       	call   80074d <strcpy>
	return dst;
}
  800788:	89 d8                	mov    %ebx,%eax
  80078a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079a:	89 f3                	mov    %esi,%ebx
  80079c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079f:	89 f2                	mov    %esi,%edx
  8007a1:	eb 0f                	jmp    8007b2 <strncpy+0x23>
		*dst++ = *src;
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	0f b6 01             	movzbl (%ecx),%eax
  8007a9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ac:	80 39 01             	cmpb   $0x1,(%ecx)
  8007af:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b2:	39 da                	cmp    %ebx,%edx
  8007b4:	75 ed                	jne    8007a3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b6:	89 f0                	mov    %esi,%eax
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ca:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 21                	je     8007f1 <strlcpy+0x35>
  8007d0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d4:	89 f2                	mov    %esi,%edx
  8007d6:	eb 09                	jmp    8007e1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	83 c1 01             	add    $0x1,%ecx
  8007de:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e1:	39 c2                	cmp    %eax,%edx
  8007e3:	74 09                	je     8007ee <strlcpy+0x32>
  8007e5:	0f b6 19             	movzbl (%ecx),%ebx
  8007e8:	84 db                	test   %bl,%bl
  8007ea:	75 ec                	jne    8007d8 <strlcpy+0x1c>
  8007ec:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ee:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f1:	29 f0                	sub    %esi,%eax
}
  8007f3:	5b                   	pop    %ebx
  8007f4:	5e                   	pop    %esi
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800800:	eb 06                	jmp    800808 <strcmp+0x11>
		p++, q++;
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800808:	0f b6 01             	movzbl (%ecx),%eax
  80080b:	84 c0                	test   %al,%al
  80080d:	74 04                	je     800813 <strcmp+0x1c>
  80080f:	3a 02                	cmp    (%edx),%al
  800811:	74 ef                	je     800802 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800813:	0f b6 c0             	movzbl %al,%eax
  800816:	0f b6 12             	movzbl (%edx),%edx
  800819:	29 d0                	sub    %edx,%eax
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	8b 45 08             	mov    0x8(%ebp),%eax
  800824:	8b 55 0c             	mov    0xc(%ebp),%edx
  800827:	89 c3                	mov    %eax,%ebx
  800829:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082c:	eb 06                	jmp    800834 <strncmp+0x17>
		n--, p++, q++;
  80082e:	83 c0 01             	add    $0x1,%eax
  800831:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800834:	39 d8                	cmp    %ebx,%eax
  800836:	74 15                	je     80084d <strncmp+0x30>
  800838:	0f b6 08             	movzbl (%eax),%ecx
  80083b:	84 c9                	test   %cl,%cl
  80083d:	74 04                	je     800843 <strncmp+0x26>
  80083f:	3a 0a                	cmp    (%edx),%cl
  800841:	74 eb                	je     80082e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800843:	0f b6 00             	movzbl (%eax),%eax
  800846:	0f b6 12             	movzbl (%edx),%edx
  800849:	29 d0                	sub    %edx,%eax
  80084b:	eb 05                	jmp    800852 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80085f:	eb 07                	jmp    800868 <strchr+0x13>
		if (*s == c)
  800861:	38 ca                	cmp    %cl,%dl
  800863:	74 0f                	je     800874 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800865:	83 c0 01             	add    $0x1,%eax
  800868:	0f b6 10             	movzbl (%eax),%edx
  80086b:	84 d2                	test   %dl,%dl
  80086d:	75 f2                	jne    800861 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800880:	eb 03                	jmp    800885 <strfind+0xf>
  800882:	83 c0 01             	add    $0x1,%eax
  800885:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800888:	38 ca                	cmp    %cl,%dl
  80088a:	74 04                	je     800890 <strfind+0x1a>
  80088c:	84 d2                	test   %dl,%dl
  80088e:	75 f2                	jne    800882 <strfind+0xc>
			break;
	return (char *) s;
}
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089e:	85 c9                	test   %ecx,%ecx
  8008a0:	74 36                	je     8008d8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a8:	75 28                	jne    8008d2 <memset+0x40>
  8008aa:	f6 c1 03             	test   $0x3,%cl
  8008ad:	75 23                	jne    8008d2 <memset+0x40>
		c &= 0xFF;
  8008af:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b3:	89 d3                	mov    %edx,%ebx
  8008b5:	c1 e3 08             	shl    $0x8,%ebx
  8008b8:	89 d6                	mov    %edx,%esi
  8008ba:	c1 e6 18             	shl    $0x18,%esi
  8008bd:	89 d0                	mov    %edx,%eax
  8008bf:	c1 e0 10             	shl    $0x10,%eax
  8008c2:	09 f0                	or     %esi,%eax
  8008c4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008c6:	89 d8                	mov    %ebx,%eax
  8008c8:	09 d0                	or     %edx,%eax
  8008ca:	c1 e9 02             	shr    $0x2,%ecx
  8008cd:	fc                   	cld    
  8008ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d0:	eb 06                	jmp    8008d8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d5:	fc                   	cld    
  8008d6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d8:	89 f8                	mov    %edi,%eax
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	57                   	push   %edi
  8008e3:	56                   	push   %esi
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ed:	39 c6                	cmp    %eax,%esi
  8008ef:	73 35                	jae    800926 <memmove+0x47>
  8008f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f4:	39 d0                	cmp    %edx,%eax
  8008f6:	73 2e                	jae    800926 <memmove+0x47>
		s += n;
		d += n;
  8008f8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fb:	89 d6                	mov    %edx,%esi
  8008fd:	09 fe                	or     %edi,%esi
  8008ff:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800905:	75 13                	jne    80091a <memmove+0x3b>
  800907:	f6 c1 03             	test   $0x3,%cl
  80090a:	75 0e                	jne    80091a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80090c:	83 ef 04             	sub    $0x4,%edi
  80090f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800912:	c1 e9 02             	shr    $0x2,%ecx
  800915:	fd                   	std    
  800916:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800918:	eb 09                	jmp    800923 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091a:	83 ef 01             	sub    $0x1,%edi
  80091d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800920:	fd                   	std    
  800921:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800923:	fc                   	cld    
  800924:	eb 1d                	jmp    800943 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800926:	89 f2                	mov    %esi,%edx
  800928:	09 c2                	or     %eax,%edx
  80092a:	f6 c2 03             	test   $0x3,%dl
  80092d:	75 0f                	jne    80093e <memmove+0x5f>
  80092f:	f6 c1 03             	test   $0x3,%cl
  800932:	75 0a                	jne    80093e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800934:	c1 e9 02             	shr    $0x2,%ecx
  800937:	89 c7                	mov    %eax,%edi
  800939:	fc                   	cld    
  80093a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093c:	eb 05                	jmp    800943 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80094a:	ff 75 10             	pushl  0x10(%ebp)
  80094d:	ff 75 0c             	pushl  0xc(%ebp)
  800950:	ff 75 08             	pushl  0x8(%ebp)
  800953:	e8 87 ff ff ff       	call   8008df <memmove>
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
  800965:	89 c6                	mov    %eax,%esi
  800967:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096a:	eb 1a                	jmp    800986 <memcmp+0x2c>
		if (*s1 != *s2)
  80096c:	0f b6 08             	movzbl (%eax),%ecx
  80096f:	0f b6 1a             	movzbl (%edx),%ebx
  800972:	38 d9                	cmp    %bl,%cl
  800974:	74 0a                	je     800980 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800976:	0f b6 c1             	movzbl %cl,%eax
  800979:	0f b6 db             	movzbl %bl,%ebx
  80097c:	29 d8                	sub    %ebx,%eax
  80097e:	eb 0f                	jmp    80098f <memcmp+0x35>
		s1++, s2++;
  800980:	83 c0 01             	add    $0x1,%eax
  800983:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800986:	39 f0                	cmp    %esi,%eax
  800988:	75 e2                	jne    80096c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098f:	5b                   	pop    %ebx
  800990:	5e                   	pop    %esi
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80099a:	89 c1                	mov    %eax,%ecx
  80099c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80099f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a3:	eb 0a                	jmp    8009af <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	39 da                	cmp    %ebx,%edx
  8009aa:	74 07                	je     8009b3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	39 c8                	cmp    %ecx,%eax
  8009b1:	72 f2                	jb     8009a5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b3:	5b                   	pop    %ebx
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c2:	eb 03                	jmp    8009c7 <strtol+0x11>
		s++;
  8009c4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c7:	0f b6 01             	movzbl (%ecx),%eax
  8009ca:	3c 20                	cmp    $0x20,%al
  8009cc:	74 f6                	je     8009c4 <strtol+0xe>
  8009ce:	3c 09                	cmp    $0x9,%al
  8009d0:	74 f2                	je     8009c4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d2:	3c 2b                	cmp    $0x2b,%al
  8009d4:	75 0a                	jne    8009e0 <strtol+0x2a>
		s++;
  8009d6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009de:	eb 11                	jmp    8009f1 <strtol+0x3b>
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e5:	3c 2d                	cmp    $0x2d,%al
  8009e7:	75 08                	jne    8009f1 <strtol+0x3b>
		s++, neg = 1;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f7:	75 15                	jne    800a0e <strtol+0x58>
  8009f9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fc:	75 10                	jne    800a0e <strtol+0x58>
  8009fe:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a02:	75 7c                	jne    800a80 <strtol+0xca>
		s += 2, base = 16;
  800a04:	83 c1 02             	add    $0x2,%ecx
  800a07:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0c:	eb 16                	jmp    800a24 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a0e:	85 db                	test   %ebx,%ebx
  800a10:	75 12                	jne    800a24 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a12:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a17:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1a:	75 08                	jne    800a24 <strtol+0x6e>
		s++, base = 8;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
  800a29:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2c:	0f b6 11             	movzbl (%ecx),%edx
  800a2f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a32:	89 f3                	mov    %esi,%ebx
  800a34:	80 fb 09             	cmp    $0x9,%bl
  800a37:	77 08                	ja     800a41 <strtol+0x8b>
			dig = *s - '0';
  800a39:	0f be d2             	movsbl %dl,%edx
  800a3c:	83 ea 30             	sub    $0x30,%edx
  800a3f:	eb 22                	jmp    800a63 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a41:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a44:	89 f3                	mov    %esi,%ebx
  800a46:	80 fb 19             	cmp    $0x19,%bl
  800a49:	77 08                	ja     800a53 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a4b:	0f be d2             	movsbl %dl,%edx
  800a4e:	83 ea 57             	sub    $0x57,%edx
  800a51:	eb 10                	jmp    800a63 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a53:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a56:	89 f3                	mov    %esi,%ebx
  800a58:	80 fb 19             	cmp    $0x19,%bl
  800a5b:	77 16                	ja     800a73 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a5d:	0f be d2             	movsbl %dl,%edx
  800a60:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a63:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a66:	7d 0b                	jge    800a73 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a6f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a71:	eb b9                	jmp    800a2c <strtol+0x76>

	if (endptr)
  800a73:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a77:	74 0d                	je     800a86 <strtol+0xd0>
		*endptr = (char *) s;
  800a79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7c:	89 0e                	mov    %ecx,(%esi)
  800a7e:	eb 06                	jmp    800a86 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	74 98                	je     800a1c <strtol+0x66>
  800a84:	eb 9e                	jmp    800a24 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a86:	89 c2                	mov    %eax,%edx
  800a88:	f7 da                	neg    %edx
  800a8a:	85 ff                	test   %edi,%edi
  800a8c:	0f 45 c2             	cmovne %edx,%eax
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	89 c3                	mov    %eax,%ebx
  800aa7:	89 c7                	mov    %eax,%edi
  800aa9:	89 c6                	mov    %eax,%esi
  800aab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac2:	89 d1                	mov    %edx,%ecx
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	89 d7                	mov    %edx,%edi
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	b9 00 00 00 00       	mov    $0x0,%ecx
  800adf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae7:	89 cb                	mov    %ecx,%ebx
  800ae9:	89 cf                	mov    %ecx,%edi
  800aeb:	89 ce                	mov    %ecx,%esi
  800aed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aef:	85 c0                	test   %eax,%eax
  800af1:	7e 17                	jle    800b0a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af3:	83 ec 0c             	sub    $0xc,%esp
  800af6:	50                   	push   %eax
  800af7:	6a 03                	push   $0x3
  800af9:	68 3f 2a 80 00       	push   $0x802a3f
  800afe:	6a 23                	push   $0x23
  800b00:	68 5c 2a 80 00       	push   $0x802a5c
  800b05:	e8 df 16 00 00       	call   8021e9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b22:	89 d1                	mov    %edx,%ecx
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_yield>:

void
sys_yield(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b41:	89 d1                	mov    %edx,%ecx
  800b43:	89 d3                	mov    %edx,%ebx
  800b45:	89 d7                	mov    %edx,%edi
  800b47:	89 d6                	mov    %edx,%esi
  800b49:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	be 00 00 00 00       	mov    $0x0,%esi
  800b5e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b66:	8b 55 08             	mov    0x8(%ebp),%edx
  800b69:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6c:	89 f7                	mov    %esi,%edi
  800b6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b70:	85 c0                	test   %eax,%eax
  800b72:	7e 17                	jle    800b8b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b74:	83 ec 0c             	sub    $0xc,%esp
  800b77:	50                   	push   %eax
  800b78:	6a 04                	push   $0x4
  800b7a:	68 3f 2a 80 00       	push   $0x802a3f
  800b7f:	6a 23                	push   $0x23
  800b81:	68 5c 2a 80 00       	push   $0x802a5c
  800b86:	e8 5e 16 00 00       	call   8021e9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8e:	5b                   	pop    %ebx
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
  800b99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800baa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bad:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	7e 17                	jle    800bcd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	50                   	push   %eax
  800bba:	6a 05                	push   $0x5
  800bbc:	68 3f 2a 80 00       	push   $0x802a3f
  800bc1:	6a 23                	push   $0x23
  800bc3:	68 5c 2a 80 00       	push   $0x802a5c
  800bc8:	e8 1c 16 00 00       	call   8021e9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	57                   	push   %edi
  800bd9:	56                   	push   %esi
  800bda:	53                   	push   %ebx
  800bdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be3:	b8 06 00 00 00       	mov    $0x6,%eax
  800be8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	89 df                	mov    %ebx,%edi
  800bf0:	89 de                	mov    %ebx,%esi
  800bf2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	7e 17                	jle    800c0f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	50                   	push   %eax
  800bfc:	6a 06                	push   $0x6
  800bfe:	68 3f 2a 80 00       	push   $0x802a3f
  800c03:	6a 23                	push   $0x23
  800c05:	68 5c 2a 80 00       	push   $0x802a5c
  800c0a:	e8 da 15 00 00       	call   8021e9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c25:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c30:	89 df                	mov    %ebx,%edi
  800c32:	89 de                	mov    %ebx,%esi
  800c34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 08                	push   $0x8
  800c40:	68 3f 2a 80 00       	push   $0x802a3f
  800c45:	6a 23                	push   $0x23
  800c47:	68 5c 2a 80 00       	push   $0x802a5c
  800c4c:	e8 98 15 00 00       	call   8021e9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800c62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c67:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	89 df                	mov    %ebx,%edi
  800c74:	89 de                	mov    %ebx,%esi
  800c76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 17                	jle    800c93 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	83 ec 0c             	sub    $0xc,%esp
  800c7f:	50                   	push   %eax
  800c80:	6a 09                	push   $0x9
  800c82:	68 3f 2a 80 00       	push   $0x802a3f
  800c87:	6a 23                	push   $0x23
  800c89:	68 5c 2a 80 00       	push   $0x802a5c
  800c8e:	e8 56 15 00 00       	call   8021e9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	89 df                	mov    %ebx,%edi
  800cb6:	89 de                	mov    %ebx,%esi
  800cb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 0a                	push   $0xa
  800cc4:	68 3f 2a 80 00       	push   $0x802a3f
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 5c 2a 80 00       	push   $0x802a5c
  800cd0:	e8 14 15 00 00       	call   8021e9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	be 00 00 00 00       	mov    $0x0,%esi
  800ce8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	57                   	push   %edi
  800d04:	56                   	push   %esi
  800d05:	53                   	push   %ebx
  800d06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	89 cb                	mov    %ecx,%ebx
  800d18:	89 cf                	mov    %ecx,%edi
  800d1a:	89 ce                	mov    %ecx,%esi
  800d1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 17                	jle    800d39 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 0d                	push   $0xd
  800d28:	68 3f 2a 80 00       	push   $0x802a3f
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 5c 2a 80 00       	push   $0x802a5c
  800d34:	e8 b0 14 00 00       	call   8021e9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d47:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d51:	89 d1                	mov    %edx,%ecx
  800d53:	89 d3                	mov    %edx,%ebx
  800d55:	89 d7                	mov    %edx,%edi
  800d57:	89 d6                	mov    %edx,%esi
  800d59:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d5b:	5b                   	pop    %ebx
  800d5c:	5e                   	pop    %esi
  800d5d:	5f                   	pop    %edi
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	53                   	push   %ebx
  800d64:	83 ec 04             	sub    $0x4,%esp
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d6a:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800d6c:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800d6f:	f6 c1 02             	test   $0x2,%cl
  800d72:	74 2e                	je     800da2 <pgfault+0x42>
  800d74:	89 c2                	mov    %eax,%edx
  800d76:	c1 ea 16             	shr    $0x16,%edx
  800d79:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d80:	f6 c2 01             	test   $0x1,%dl
  800d83:	74 1d                	je     800da2 <pgfault+0x42>
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	c1 ea 0c             	shr    $0xc,%edx
  800d8a:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800d91:	f6 c3 01             	test   $0x1,%bl
  800d94:	74 0c                	je     800da2 <pgfault+0x42>
  800d96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9d:	f6 c6 08             	test   $0x8,%dh
  800da0:	75 12                	jne    800db4 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800da2:	51                   	push   %ecx
  800da3:	68 6a 2a 80 00       	push   $0x802a6a
  800da8:	6a 1e                	push   $0x1e
  800daa:	68 83 2a 80 00       	push   $0x802a83
  800daf:	e8 35 14 00 00       	call   8021e9 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800db4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800db9:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	6a 07                	push   $0x7
  800dc0:	68 00 f0 7f 00       	push   $0x7ff000
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 84 fd ff ff       	call   800b50 <sys_page_alloc>
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	79 12                	jns    800de5 <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800dd3:	50                   	push   %eax
  800dd4:	68 8e 2a 80 00       	push   $0x802a8e
  800dd9:	6a 29                	push   $0x29
  800ddb:	68 83 2a 80 00       	push   $0x802a83
  800de0:	e8 04 14 00 00       	call   8021e9 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	68 00 10 00 00       	push   $0x1000
  800ded:	53                   	push   %ebx
  800dee:	68 00 f0 7f 00       	push   $0x7ff000
  800df3:	e8 4f fb ff ff       	call   800947 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800df8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dff:	53                   	push   %ebx
  800e00:	6a 00                	push   $0x0
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	6a 00                	push   $0x0
  800e09:	e8 85 fd ff ff       	call   800b93 <sys_page_map>
  800e0e:	83 c4 20             	add    $0x20,%esp
  800e11:	85 c0                	test   %eax,%eax
  800e13:	79 12                	jns    800e27 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800e15:	50                   	push   %eax
  800e16:	68 a9 2a 80 00       	push   $0x802aa9
  800e1b:	6a 2e                	push   $0x2e
  800e1d:	68 83 2a 80 00       	push   $0x802a83
  800e22:	e8 c2 13 00 00       	call   8021e9 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	68 00 f0 7f 00       	push   $0x7ff000
  800e2f:	6a 00                	push   $0x0
  800e31:	e8 9f fd ff ff       	call   800bd5 <sys_page_unmap>
  800e36:	83 c4 10             	add    $0x10,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	79 12                	jns    800e4f <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800e3d:	50                   	push   %eax
  800e3e:	68 c2 2a 80 00       	push   $0x802ac2
  800e43:	6a 31                	push   $0x31
  800e45:	68 83 2a 80 00       	push   $0x802a83
  800e4a:	e8 9a 13 00 00       	call   8021e9 <_panic>

}
  800e4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800e5d:	68 60 0d 80 00       	push   $0x800d60
  800e62:	e8 c8 13 00 00       	call   80222f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e67:	b8 07 00 00 00       	mov    $0x7,%eax
  800e6c:	cd 30                	int    $0x30
  800e6e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	75 21                	jne    800ea1 <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e80:	e8 8d fc ff ff       	call   800b12 <sys_getenvid>
  800e85:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e8a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e8d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e92:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800e97:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9c:	e9 c9 01 00 00       	jmp    80106a <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800ea1:	89 d8                	mov    %ebx,%eax
  800ea3:	c1 e8 16             	shr    $0x16,%eax
  800ea6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ead:	a8 01                	test   $0x1,%al
  800eaf:	0f 84 1b 01 00 00    	je     800fd0 <fork+0x17c>
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	c1 ee 0c             	shr    $0xc,%esi
  800eba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ec1:	a8 01                	test   $0x1,%al
  800ec3:	0f 84 07 01 00 00    	je     800fd0 <fork+0x17c>
  800ec9:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ed0:	a8 04                	test   $0x4,%al
  800ed2:	0f 84 f8 00 00 00    	je     800fd0 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800ed8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800edf:	f6 c4 04             	test   $0x4,%ah
  800ee2:	74 3c                	je     800f20 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800ee4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eeb:	c1 e6 0c             	shl    $0xc,%esi
  800eee:	83 ec 0c             	sub    $0xc,%esp
  800ef1:	25 07 0e 00 00       	and    $0xe07,%eax
  800ef6:	50                   	push   %eax
  800ef7:	56                   	push   %esi
  800ef8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800efb:	56                   	push   %esi
  800efc:	6a 00                	push   $0x0
  800efe:	e8 90 fc ff ff       	call   800b93 <sys_page_map>
  800f03:	83 c4 20             	add    $0x20,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	0f 89 c2 00 00 00    	jns    800fd0 <fork+0x17c>
			panic("duppage: %e", r);
  800f0e:	50                   	push   %eax
  800f0f:	68 dd 2a 80 00       	push   $0x802add
  800f14:	6a 48                	push   $0x48
  800f16:	68 83 2a 80 00       	push   $0x802a83
  800f1b:	e8 c9 12 00 00       	call   8021e9 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  800f20:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f27:	f6 c4 08             	test   $0x8,%ah
  800f2a:	75 0b                	jne    800f37 <fork+0xe3>
  800f2c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f33:	a8 02                	test   $0x2,%al
  800f35:	74 6c                	je     800fa3 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  800f37:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3e:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  800f41:	83 f8 01             	cmp    $0x1,%eax
  800f44:	19 ff                	sbb    %edi,%edi
  800f46:	83 e7 fc             	and    $0xfffffffc,%edi
  800f49:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  800f4f:	c1 e6 0c             	shl    $0xc,%esi
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5a:	56                   	push   %esi
  800f5b:	6a 00                	push   $0x0
  800f5d:	e8 31 fc ff ff       	call   800b93 <sys_page_map>
  800f62:	83 c4 20             	add    $0x20,%esp
  800f65:	85 c0                	test   %eax,%eax
  800f67:	79 12                	jns    800f7b <fork+0x127>
			panic("duppage: %e", r);
  800f69:	50                   	push   %eax
  800f6a:	68 dd 2a 80 00       	push   $0x802add
  800f6f:	6a 50                	push   $0x50
  800f71:	68 83 2a 80 00       	push   $0x802a83
  800f76:	e8 6e 12 00 00       	call   8021e9 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	6a 00                	push   $0x0
  800f82:	56                   	push   %esi
  800f83:	6a 00                	push   $0x0
  800f85:	e8 09 fc ff ff       	call   800b93 <sys_page_map>
  800f8a:	83 c4 20             	add    $0x20,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	79 3f                	jns    800fd0 <fork+0x17c>
			panic("duppage: %e", r);
  800f91:	50                   	push   %eax
  800f92:	68 dd 2a 80 00       	push   $0x802add
  800f97:	6a 53                	push   $0x53
  800f99:	68 83 2a 80 00       	push   $0x802a83
  800f9e:	e8 46 12 00 00       	call   8021e9 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  800fa3:	c1 e6 0c             	shl    $0xc,%esi
  800fa6:	83 ec 0c             	sub    $0xc,%esp
  800fa9:	6a 05                	push   $0x5
  800fab:	56                   	push   %esi
  800fac:	ff 75 e4             	pushl  -0x1c(%ebp)
  800faf:	56                   	push   %esi
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 dc fb ff ff       	call   800b93 <sys_page_map>
  800fb7:	83 c4 20             	add    $0x20,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	79 12                	jns    800fd0 <fork+0x17c>
			panic("duppage: %e", r);
  800fbe:	50                   	push   %eax
  800fbf:	68 dd 2a 80 00       	push   $0x802add
  800fc4:	6a 57                	push   $0x57
  800fc6:	68 83 2a 80 00       	push   $0x802a83
  800fcb:	e8 19 12 00 00       	call   8021e9 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  800fd0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fd6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fdc:	0f 85 bf fe ff ff    	jne    800ea1 <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	6a 07                	push   $0x7
  800fe7:	68 00 f0 bf ee       	push   $0xeebff000
  800fec:	ff 75 e0             	pushl  -0x20(%ebp)
  800fef:	e8 5c fb ff ff       	call   800b50 <sys_page_alloc>
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	74 17                	je     801012 <fork+0x1be>
		panic("sys_page_alloc Error");
  800ffb:	83 ec 04             	sub    $0x4,%esp
  800ffe:	68 e9 2a 80 00       	push   $0x802ae9
  801003:	68 83 00 00 00       	push   $0x83
  801008:	68 83 2a 80 00       	push   $0x802a83
  80100d:	e8 d7 11 00 00       	call   8021e9 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  801012:	83 ec 08             	sub    $0x8,%esp
  801015:	68 9e 22 80 00       	push   $0x80229e
  80101a:	ff 75 e0             	pushl  -0x20(%ebp)
  80101d:	e8 79 fc ff ff       	call   800c9b <sys_env_set_pgfault_upcall>
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	85 c0                	test   %eax,%eax
  801027:	79 15                	jns    80103e <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801029:	50                   	push   %eax
  80102a:	68 fe 2a 80 00       	push   $0x802afe
  80102f:	68 86 00 00 00       	push   $0x86
  801034:	68 83 2a 80 00       	push   $0x802a83
  801039:	e8 ab 11 00 00       	call   8021e9 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	6a 02                	push   $0x2
  801043:	ff 75 e0             	pushl  -0x20(%ebp)
  801046:	e8 cc fb ff ff       	call   800c17 <sys_env_set_status>
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	85 c0                	test   %eax,%eax
  801050:	79 15                	jns    801067 <fork+0x213>
		panic("fork set status: %e", r);
  801052:	50                   	push   %eax
  801053:	68 16 2b 80 00       	push   $0x802b16
  801058:	68 89 00 00 00       	push   $0x89
  80105d:	68 83 2a 80 00       	push   $0x802a83
  801062:	e8 82 11 00 00       	call   8021e9 <_panic>
	
	return envid;
  801067:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  80106a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5f                   	pop    %edi
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <sfork>:


// Challenge!
int
sfork(void)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801078:	68 2a 2b 80 00       	push   $0x802b2a
  80107d:	68 93 00 00 00       	push   $0x93
  801082:	68 83 2a 80 00       	push   $0x802a83
  801087:	e8 5d 11 00 00       	call   8021e9 <_panic>

0080108c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80108f:	8b 45 08             	mov    0x8(%ebp),%eax
  801092:	05 00 00 00 30       	add    $0x30000000,%eax
  801097:	c1 e8 0c             	shr    $0xc,%eax
}
  80109a:	5d                   	pop    %ebp
  80109b:	c3                   	ret    

0080109c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80109f:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010ac:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	c1 ea 16             	shr    $0x16,%edx
  8010c3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ca:	f6 c2 01             	test   $0x1,%dl
  8010cd:	74 11                	je     8010e0 <fd_alloc+0x2d>
  8010cf:	89 c2                	mov    %eax,%edx
  8010d1:	c1 ea 0c             	shr    $0xc,%edx
  8010d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010db:	f6 c2 01             	test   $0x1,%dl
  8010de:	75 09                	jne    8010e9 <fd_alloc+0x36>
			*fd_store = fd;
  8010e0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e7:	eb 17                	jmp    801100 <fd_alloc+0x4d>
  8010e9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010ee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010f3:	75 c9                	jne    8010be <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010f5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010fb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801100:	5d                   	pop    %ebp
  801101:	c3                   	ret    

00801102 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801108:	83 f8 1f             	cmp    $0x1f,%eax
  80110b:	77 36                	ja     801143 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80110d:	c1 e0 0c             	shl    $0xc,%eax
  801110:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801115:	89 c2                	mov    %eax,%edx
  801117:	c1 ea 16             	shr    $0x16,%edx
  80111a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801121:	f6 c2 01             	test   $0x1,%dl
  801124:	74 24                	je     80114a <fd_lookup+0x48>
  801126:	89 c2                	mov    %eax,%edx
  801128:	c1 ea 0c             	shr    $0xc,%edx
  80112b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801132:	f6 c2 01             	test   $0x1,%dl
  801135:	74 1a                	je     801151 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801137:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113a:	89 02                	mov    %eax,(%edx)
	return 0;
  80113c:	b8 00 00 00 00       	mov    $0x0,%eax
  801141:	eb 13                	jmp    801156 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801143:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801148:	eb 0c                	jmp    801156 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80114f:	eb 05                	jmp    801156 <fd_lookup+0x54>
  801151:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801161:	ba bc 2b 80 00       	mov    $0x802bbc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801166:	eb 13                	jmp    80117b <dev_lookup+0x23>
  801168:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80116b:	39 08                	cmp    %ecx,(%eax)
  80116d:	75 0c                	jne    80117b <dev_lookup+0x23>
			*dev = devtab[i];
  80116f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801172:	89 01                	mov    %eax,(%ecx)
			return 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
  801179:	eb 2e                	jmp    8011a9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80117b:	8b 02                	mov    (%edx),%eax
  80117d:	85 c0                	test   %eax,%eax
  80117f:	75 e7                	jne    801168 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801181:	a1 08 40 80 00       	mov    0x804008,%eax
  801186:	8b 40 48             	mov    0x48(%eax),%eax
  801189:	83 ec 04             	sub    $0x4,%esp
  80118c:	51                   	push   %ecx
  80118d:	50                   	push   %eax
  80118e:	68 40 2b 80 00       	push   $0x802b40
  801193:	e8 10 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  801198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	56                   	push   %esi
  8011af:	53                   	push   %ebx
  8011b0:	83 ec 10             	sub    $0x10,%esp
  8011b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011bc:	50                   	push   %eax
  8011bd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011c3:	c1 e8 0c             	shr    $0xc,%eax
  8011c6:	50                   	push   %eax
  8011c7:	e8 36 ff ff ff       	call   801102 <fd_lookup>
  8011cc:	83 c4 08             	add    $0x8,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 05                	js     8011d8 <fd_close+0x2d>
	    || fd != fd2)
  8011d3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011d6:	74 0c                	je     8011e4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011d8:	84 db                	test   %bl,%bl
  8011da:	ba 00 00 00 00       	mov    $0x0,%edx
  8011df:	0f 44 c2             	cmove  %edx,%eax
  8011e2:	eb 41                	jmp    801225 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	ff 36                	pushl  (%esi)
  8011ed:	e8 66 ff ff ff       	call   801158 <dev_lookup>
  8011f2:	89 c3                	mov    %eax,%ebx
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 1a                	js     801215 <fd_close+0x6a>
		if (dev->dev_close)
  8011fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fe:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801201:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801206:	85 c0                	test   %eax,%eax
  801208:	74 0b                	je     801215 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	56                   	push   %esi
  80120e:	ff d0                	call   *%eax
  801210:	89 c3                	mov    %eax,%ebx
  801212:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	56                   	push   %esi
  801219:	6a 00                	push   $0x0
  80121b:	e8 b5 f9 ff ff       	call   800bd5 <sys_page_unmap>
	return r;
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	89 d8                	mov    %ebx,%eax
}
  801225:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	ff 75 08             	pushl  0x8(%ebp)
  801239:	e8 c4 fe ff ff       	call   801102 <fd_lookup>
  80123e:	83 c4 08             	add    $0x8,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 10                	js     801255 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	6a 01                	push   $0x1
  80124a:	ff 75 f4             	pushl  -0xc(%ebp)
  80124d:	e8 59 ff ff ff       	call   8011ab <fd_close>
  801252:	83 c4 10             	add    $0x10,%esp
}
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <close_all>:

void
close_all(void)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	53                   	push   %ebx
  80125b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80125e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	53                   	push   %ebx
  801267:	e8 c0 ff ff ff       	call   80122c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80126c:	83 c3 01             	add    $0x1,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	83 fb 20             	cmp    $0x20,%ebx
  801275:	75 ec                	jne    801263 <close_all+0xc>
		close(i);
}
  801277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	57                   	push   %edi
  801280:	56                   	push   %esi
  801281:	53                   	push   %ebx
  801282:	83 ec 2c             	sub    $0x2c,%esp
  801285:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801288:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	ff 75 08             	pushl  0x8(%ebp)
  80128f:	e8 6e fe ff ff       	call   801102 <fd_lookup>
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	0f 88 c1 00 00 00    	js     801360 <dup+0xe4>
		return r;
	close(newfdnum);
  80129f:	83 ec 0c             	sub    $0xc,%esp
  8012a2:	56                   	push   %esi
  8012a3:	e8 84 ff ff ff       	call   80122c <close>

	newfd = INDEX2FD(newfdnum);
  8012a8:	89 f3                	mov    %esi,%ebx
  8012aa:	c1 e3 0c             	shl    $0xc,%ebx
  8012ad:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012b3:	83 c4 04             	add    $0x4,%esp
  8012b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012b9:	e8 de fd ff ff       	call   80109c <fd2data>
  8012be:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012c0:	89 1c 24             	mov    %ebx,(%esp)
  8012c3:	e8 d4 fd ff ff       	call   80109c <fd2data>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ce:	89 f8                	mov    %edi,%eax
  8012d0:	c1 e8 16             	shr    $0x16,%eax
  8012d3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012da:	a8 01                	test   $0x1,%al
  8012dc:	74 37                	je     801315 <dup+0x99>
  8012de:	89 f8                	mov    %edi,%eax
  8012e0:	c1 e8 0c             	shr    $0xc,%eax
  8012e3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ea:	f6 c2 01             	test   $0x1,%dl
  8012ed:	74 26                	je     801315 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f6:	83 ec 0c             	sub    $0xc,%esp
  8012f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8012fe:	50                   	push   %eax
  8012ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801302:	6a 00                	push   $0x0
  801304:	57                   	push   %edi
  801305:	6a 00                	push   $0x0
  801307:	e8 87 f8 ff ff       	call   800b93 <sys_page_map>
  80130c:	89 c7                	mov    %eax,%edi
  80130e:	83 c4 20             	add    $0x20,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 2e                	js     801343 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801315:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801318:	89 d0                	mov    %edx,%eax
  80131a:	c1 e8 0c             	shr    $0xc,%eax
  80131d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	25 07 0e 00 00       	and    $0xe07,%eax
  80132c:	50                   	push   %eax
  80132d:	53                   	push   %ebx
  80132e:	6a 00                	push   $0x0
  801330:	52                   	push   %edx
  801331:	6a 00                	push   $0x0
  801333:	e8 5b f8 ff ff       	call   800b93 <sys_page_map>
  801338:	89 c7                	mov    %eax,%edi
  80133a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80133d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80133f:	85 ff                	test   %edi,%edi
  801341:	79 1d                	jns    801360 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	53                   	push   %ebx
  801347:	6a 00                	push   $0x0
  801349:	e8 87 f8 ff ff       	call   800bd5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80134e:	83 c4 08             	add    $0x8,%esp
  801351:	ff 75 d4             	pushl  -0x2c(%ebp)
  801354:	6a 00                	push   $0x0
  801356:	e8 7a f8 ff ff       	call   800bd5 <sys_page_unmap>
	return r;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	89 f8                	mov    %edi,%eax
}
  801360:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5f                   	pop    %edi
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    

00801368 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	53                   	push   %ebx
  80136c:	83 ec 14             	sub    $0x14,%esp
  80136f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801372:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801375:	50                   	push   %eax
  801376:	53                   	push   %ebx
  801377:	e8 86 fd ff ff       	call   801102 <fd_lookup>
  80137c:	83 c4 08             	add    $0x8,%esp
  80137f:	89 c2                	mov    %eax,%edx
  801381:	85 c0                	test   %eax,%eax
  801383:	78 6d                	js     8013f2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801385:	83 ec 08             	sub    $0x8,%esp
  801388:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138b:	50                   	push   %eax
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	ff 30                	pushl  (%eax)
  801391:	e8 c2 fd ff ff       	call   801158 <dev_lookup>
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 4c                	js     8013e9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80139d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a0:	8b 42 08             	mov    0x8(%edx),%eax
  8013a3:	83 e0 03             	and    $0x3,%eax
  8013a6:	83 f8 01             	cmp    $0x1,%eax
  8013a9:	75 21                	jne    8013cc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8013b0:	8b 40 48             	mov    0x48(%eax),%eax
  8013b3:	83 ec 04             	sub    $0x4,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	50                   	push   %eax
  8013b8:	68 81 2b 80 00       	push   $0x802b81
  8013bd:	e8 e6 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013ca:	eb 26                	jmp    8013f2 <read+0x8a>
	}
	if (!dev->dev_read)
  8013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cf:	8b 40 08             	mov    0x8(%eax),%eax
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	74 17                	je     8013ed <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d6:	83 ec 04             	sub    $0x4,%esp
  8013d9:	ff 75 10             	pushl  0x10(%ebp)
  8013dc:	ff 75 0c             	pushl  0xc(%ebp)
  8013df:	52                   	push   %edx
  8013e0:	ff d0                	call   *%eax
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	eb 09                	jmp    8013f2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	eb 05                	jmp    8013f2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013f2:	89 d0                	mov    %edx,%eax
  8013f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f7:	c9                   	leave  
  8013f8:	c3                   	ret    

008013f9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f9:	55                   	push   %ebp
  8013fa:	89 e5                	mov    %esp,%ebp
  8013fc:	57                   	push   %edi
  8013fd:	56                   	push   %esi
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	8b 7d 08             	mov    0x8(%ebp),%edi
  801405:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801408:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140d:	eb 21                	jmp    801430 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80140f:	83 ec 04             	sub    $0x4,%esp
  801412:	89 f0                	mov    %esi,%eax
  801414:	29 d8                	sub    %ebx,%eax
  801416:	50                   	push   %eax
  801417:	89 d8                	mov    %ebx,%eax
  801419:	03 45 0c             	add    0xc(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	57                   	push   %edi
  80141e:	e8 45 ff ff ff       	call   801368 <read>
		if (m < 0)
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 10                	js     80143a <readn+0x41>
			return m;
		if (m == 0)
  80142a:	85 c0                	test   %eax,%eax
  80142c:	74 0a                	je     801438 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80142e:	01 c3                	add    %eax,%ebx
  801430:	39 f3                	cmp    %esi,%ebx
  801432:	72 db                	jb     80140f <readn+0x16>
  801434:	89 d8                	mov    %ebx,%eax
  801436:	eb 02                	jmp    80143a <readn+0x41>
  801438:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80143a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143d:	5b                   	pop    %ebx
  80143e:	5e                   	pop    %esi
  80143f:	5f                   	pop    %edi
  801440:	5d                   	pop    %ebp
  801441:	c3                   	ret    

00801442 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 14             	sub    $0x14,%esp
  801449:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	53                   	push   %ebx
  801451:	e8 ac fc ff ff       	call   801102 <fd_lookup>
  801456:	83 c4 08             	add    $0x8,%esp
  801459:	89 c2                	mov    %eax,%edx
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 68                	js     8014c7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801469:	ff 30                	pushl  (%eax)
  80146b:	e8 e8 fc ff ff       	call   801158 <dev_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 47                	js     8014be <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801477:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80147e:	75 21                	jne    8014a1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801480:	a1 08 40 80 00       	mov    0x804008,%eax
  801485:	8b 40 48             	mov    0x48(%eax),%eax
  801488:	83 ec 04             	sub    $0x4,%esp
  80148b:	53                   	push   %ebx
  80148c:	50                   	push   %eax
  80148d:	68 9d 2b 80 00       	push   $0x802b9d
  801492:	e8 11 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149f:	eb 26                	jmp    8014c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a7:	85 d2                	test   %edx,%edx
  8014a9:	74 17                	je     8014c2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	ff 75 10             	pushl  0x10(%ebp)
  8014b1:	ff 75 0c             	pushl  0xc(%ebp)
  8014b4:	50                   	push   %eax
  8014b5:	ff d2                	call   *%edx
  8014b7:	89 c2                	mov    %eax,%edx
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	eb 09                	jmp    8014c7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014be:	89 c2                	mov    %eax,%edx
  8014c0:	eb 05                	jmp    8014c7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014c7:	89 d0                	mov    %edx,%eax
  8014c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ce:	55                   	push   %ebp
  8014cf:	89 e5                	mov    %esp,%ebp
  8014d1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	ff 75 08             	pushl  0x8(%ebp)
  8014db:	e8 22 fc ff ff       	call   801102 <fd_lookup>
  8014e0:	83 c4 08             	add    $0x8,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 0e                	js     8014f5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ed:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014f5:	c9                   	leave  
  8014f6:	c3                   	ret    

008014f7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	53                   	push   %ebx
  8014fb:	83 ec 14             	sub    $0x14,%esp
  8014fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801501:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	53                   	push   %ebx
  801506:	e8 f7 fb ff ff       	call   801102 <fd_lookup>
  80150b:	83 c4 08             	add    $0x8,%esp
  80150e:	89 c2                	mov    %eax,%edx
  801510:	85 c0                	test   %eax,%eax
  801512:	78 65                	js     801579 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	ff 30                	pushl  (%eax)
  801520:	e8 33 fc ff ff       	call   801158 <dev_lookup>
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 44                	js     801570 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801533:	75 21                	jne    801556 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801535:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80153a:	8b 40 48             	mov    0x48(%eax),%eax
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	53                   	push   %ebx
  801541:	50                   	push   %eax
  801542:	68 60 2b 80 00       	push   $0x802b60
  801547:	e8 5c ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801554:	eb 23                	jmp    801579 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801556:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801559:	8b 52 18             	mov    0x18(%edx),%edx
  80155c:	85 d2                	test   %edx,%edx
  80155e:	74 14                	je     801574 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	ff 75 0c             	pushl  0xc(%ebp)
  801566:	50                   	push   %eax
  801567:	ff d2                	call   *%edx
  801569:	89 c2                	mov    %eax,%edx
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	eb 09                	jmp    801579 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801570:	89 c2                	mov    %eax,%edx
  801572:	eb 05                	jmp    801579 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801574:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801579:	89 d0                	mov    %edx,%eax
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	53                   	push   %ebx
  801584:	83 ec 14             	sub    $0x14,%esp
  801587:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	e8 6c fb ff ff       	call   801102 <fd_lookup>
  801596:	83 c4 08             	add    $0x8,%esp
  801599:	89 c2                	mov    %eax,%edx
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 58                	js     8015f7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a9:	ff 30                	pushl  (%eax)
  8015ab:	e8 a8 fb ff ff       	call   801158 <dev_lookup>
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 37                	js     8015ee <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ba:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015be:	74 32                	je     8015f2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015c0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015c3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015ca:	00 00 00 
	stat->st_isdir = 0;
  8015cd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015d4:	00 00 00 
	stat->st_dev = dev;
  8015d7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8015e4:	ff 50 14             	call   *0x14(%eax)
  8015e7:	89 c2                	mov    %eax,%edx
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	eb 09                	jmp    8015f7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ee:	89 c2                	mov    %eax,%edx
  8015f0:	eb 05                	jmp    8015f7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015f7:	89 d0                	mov    %edx,%eax
  8015f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	56                   	push   %esi
  801602:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	6a 00                	push   $0x0
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 ef 01 00 00       	call   8017ff <open>
  801610:	89 c3                	mov    %eax,%ebx
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 1b                	js     801634 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	ff 75 0c             	pushl  0xc(%ebp)
  80161f:	50                   	push   %eax
  801620:	e8 5b ff ff ff       	call   801580 <fstat>
  801625:	89 c6                	mov    %eax,%esi
	close(fd);
  801627:	89 1c 24             	mov    %ebx,(%esp)
  80162a:	e8 fd fb ff ff       	call   80122c <close>
	return r;
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	89 f0                	mov    %esi,%eax
}
  801634:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801637:	5b                   	pop    %ebx
  801638:	5e                   	pop    %esi
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
  801640:	89 c6                	mov    %eax,%esi
  801642:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801644:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80164b:	75 12                	jne    80165f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	6a 01                	push   $0x1
  801652:	e8 33 0d 00 00       	call   80238a <ipc_find_env>
  801657:	a3 00 40 80 00       	mov    %eax,0x804000
  80165c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80165f:	6a 07                	push   $0x7
  801661:	68 00 50 80 00       	push   $0x805000
  801666:	56                   	push   %esi
  801667:	ff 35 00 40 80 00    	pushl  0x804000
  80166d:	e8 c9 0c 00 00       	call   80233b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801672:	83 c4 0c             	add    $0xc,%esp
  801675:	6a 00                	push   $0x0
  801677:	53                   	push   %ebx
  801678:	6a 00                	push   $0x0
  80167a:	e8 46 0c 00 00       	call   8022c5 <ipc_recv>
}
  80167f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	8b 40 0c             	mov    0xc(%eax),%eax
  801692:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801697:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a9:	e8 8d ff ff ff       	call   80163b <fsipc>
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8016cb:	e8 6b ff ff ff       	call   80163b <fsipc>
}
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	53                   	push   %ebx
  8016d6:	83 ec 04             	sub    $0x4,%esp
  8016d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ec:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f1:	e8 45 ff ff ff       	call   80163b <fsipc>
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 2c                	js     801726 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	68 00 50 80 00       	push   $0x805000
  801702:	53                   	push   %ebx
  801703:	e8 45 f0 ff ff       	call   80074d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801708:	a1 80 50 80 00       	mov    0x805080,%eax
  80170d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801713:	a1 84 50 80 00       	mov    0x805084,%eax
  801718:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801726:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	53                   	push   %ebx
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801735:	8b 55 08             	mov    0x8(%ebp),%edx
  801738:	8b 52 0c             	mov    0xc(%edx),%edx
  80173b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801741:	a3 04 50 80 00       	mov    %eax,0x805004
  801746:	3d 08 50 80 00       	cmp    $0x805008,%eax
  80174b:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801750:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801753:	53                   	push   %ebx
  801754:	ff 75 0c             	pushl  0xc(%ebp)
  801757:	68 08 50 80 00       	push   $0x805008
  80175c:	e8 7e f1 ff ff       	call   8008df <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801761:	ba 00 00 00 00       	mov    $0x0,%edx
  801766:	b8 04 00 00 00       	mov    $0x4,%eax
  80176b:	e8 cb fe ff ff       	call   80163b <fsipc>
  801770:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801773:	85 c0                	test   %eax,%eax
  801775:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801778:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    

0080177d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801790:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a0:	e8 96 fe ff ff       	call   80163b <fsipc>
  8017a5:	89 c3                	mov    %eax,%ebx
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 4b                	js     8017f6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017ab:	39 c6                	cmp    %eax,%esi
  8017ad:	73 16                	jae    8017c5 <devfile_read+0x48>
  8017af:	68 d0 2b 80 00       	push   $0x802bd0
  8017b4:	68 d7 2b 80 00       	push   $0x802bd7
  8017b9:	6a 7c                	push   $0x7c
  8017bb:	68 ec 2b 80 00       	push   $0x802bec
  8017c0:	e8 24 0a 00 00       	call   8021e9 <_panic>
	assert(r <= PGSIZE);
  8017c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ca:	7e 16                	jle    8017e2 <devfile_read+0x65>
  8017cc:	68 f7 2b 80 00       	push   $0x802bf7
  8017d1:	68 d7 2b 80 00       	push   $0x802bd7
  8017d6:	6a 7d                	push   $0x7d
  8017d8:	68 ec 2b 80 00       	push   $0x802bec
  8017dd:	e8 07 0a 00 00       	call   8021e9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e2:	83 ec 04             	sub    $0x4,%esp
  8017e5:	50                   	push   %eax
  8017e6:	68 00 50 80 00       	push   $0x805000
  8017eb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ee:	e8 ec f0 ff ff       	call   8008df <memmove>
	return r;
  8017f3:	83 c4 10             	add    $0x10,%esp
}
  8017f6:	89 d8                	mov    %ebx,%eax
  8017f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	53                   	push   %ebx
  801803:	83 ec 20             	sub    $0x20,%esp
  801806:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801809:	53                   	push   %ebx
  80180a:	e8 05 ef ff ff       	call   800714 <strlen>
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801817:	7f 67                	jg     801880 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181f:	50                   	push   %eax
  801820:	e8 8e f8 ff ff       	call   8010b3 <fd_alloc>
  801825:	83 c4 10             	add    $0x10,%esp
		return r;
  801828:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 57                	js     801885 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	53                   	push   %ebx
  801832:	68 00 50 80 00       	push   $0x805000
  801837:	e8 11 ef ff ff       	call   80074d <strcpy>
	fsipcbuf.open.req_omode = mode;
  80183c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801847:	b8 01 00 00 00       	mov    $0x1,%eax
  80184c:	e8 ea fd ff ff       	call   80163b <fsipc>
  801851:	89 c3                	mov    %eax,%ebx
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	85 c0                	test   %eax,%eax
  801858:	79 14                	jns    80186e <open+0x6f>
		fd_close(fd, 0);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	6a 00                	push   $0x0
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 44 f9 ff ff       	call   8011ab <fd_close>
		return r;
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	89 da                	mov    %ebx,%edx
  80186c:	eb 17                	jmp    801885 <open+0x86>
	}

	return fd2num(fd);
  80186e:	83 ec 0c             	sub    $0xc,%esp
  801871:	ff 75 f4             	pushl  -0xc(%ebp)
  801874:	e8 13 f8 ff ff       	call   80108c <fd2num>
  801879:	89 c2                	mov    %eax,%edx
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	eb 05                	jmp    801885 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801880:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801885:	89 d0                	mov    %edx,%eax
  801887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801892:	ba 00 00 00 00       	mov    $0x0,%edx
  801897:	b8 08 00 00 00       	mov    $0x8,%eax
  80189c:	e8 9a fd ff ff       	call   80163b <fsipc>
}
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	56                   	push   %esi
  8018a7:	53                   	push   %ebx
  8018a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	ff 75 08             	pushl  0x8(%ebp)
  8018b1:	e8 e6 f7 ff ff       	call   80109c <fd2data>
  8018b6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018b8:	83 c4 08             	add    $0x8,%esp
  8018bb:	68 03 2c 80 00       	push   $0x802c03
  8018c0:	53                   	push   %ebx
  8018c1:	e8 87 ee ff ff       	call   80074d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018c6:	8b 46 04             	mov    0x4(%esi),%eax
  8018c9:	2b 06                	sub    (%esi),%eax
  8018cb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d8:	00 00 00 
	stat->st_dev = &devpipe;
  8018db:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018e2:	30 80 00 
	return 0;
}
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ed:	5b                   	pop    %ebx
  8018ee:	5e                   	pop    %esi
  8018ef:	5d                   	pop    %ebp
  8018f0:	c3                   	ret    

008018f1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 0c             	sub    $0xc,%esp
  8018f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018fb:	53                   	push   %ebx
  8018fc:	6a 00                	push   $0x0
  8018fe:	e8 d2 f2 ff ff       	call   800bd5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801903:	89 1c 24             	mov    %ebx,(%esp)
  801906:	e8 91 f7 ff ff       	call   80109c <fd2data>
  80190b:	83 c4 08             	add    $0x8,%esp
  80190e:	50                   	push   %eax
  80190f:	6a 00                	push   $0x0
  801911:	e8 bf f2 ff ff       	call   800bd5 <sys_page_unmap>
}
  801916:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	57                   	push   %edi
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	83 ec 1c             	sub    $0x1c,%esp
  801924:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801927:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801929:	a1 08 40 80 00       	mov    0x804008,%eax
  80192e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	ff 75 e0             	pushl  -0x20(%ebp)
  801937:	e8 87 0a 00 00       	call   8023c3 <pageref>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	89 3c 24             	mov    %edi,(%esp)
  801941:	e8 7d 0a 00 00       	call   8023c3 <pageref>
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	39 c3                	cmp    %eax,%ebx
  80194b:	0f 94 c1             	sete   %cl
  80194e:	0f b6 c9             	movzbl %cl,%ecx
  801951:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801954:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80195a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80195d:	39 ce                	cmp    %ecx,%esi
  80195f:	74 1b                	je     80197c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801961:	39 c3                	cmp    %eax,%ebx
  801963:	75 c4                	jne    801929 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801965:	8b 42 58             	mov    0x58(%edx),%eax
  801968:	ff 75 e4             	pushl  -0x1c(%ebp)
  80196b:	50                   	push   %eax
  80196c:	56                   	push   %esi
  80196d:	68 0a 2c 80 00       	push   $0x802c0a
  801972:	e8 31 e8 ff ff       	call   8001a8 <cprintf>
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	eb ad                	jmp    801929 <_pipeisclosed+0xe>
	}
}
  80197c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80197f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5f                   	pop    %edi
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	57                   	push   %edi
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	83 ec 28             	sub    $0x28,%esp
  801990:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801993:	56                   	push   %esi
  801994:	e8 03 f7 ff ff       	call   80109c <fd2data>
  801999:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a3:	eb 4b                	jmp    8019f0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019a5:	89 da                	mov    %ebx,%edx
  8019a7:	89 f0                	mov    %esi,%eax
  8019a9:	e8 6d ff ff ff       	call   80191b <_pipeisclosed>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	75 48                	jne    8019fa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019b2:	e8 7a f1 ff ff       	call   800b31 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019b7:	8b 43 04             	mov    0x4(%ebx),%eax
  8019ba:	8b 0b                	mov    (%ebx),%ecx
  8019bc:	8d 51 20             	lea    0x20(%ecx),%edx
  8019bf:	39 d0                	cmp    %edx,%eax
  8019c1:	73 e2                	jae    8019a5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019ca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019cd:	89 c2                	mov    %eax,%edx
  8019cf:	c1 fa 1f             	sar    $0x1f,%edx
  8019d2:	89 d1                	mov    %edx,%ecx
  8019d4:	c1 e9 1b             	shr    $0x1b,%ecx
  8019d7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019da:	83 e2 1f             	and    $0x1f,%edx
  8019dd:	29 ca                	sub    %ecx,%edx
  8019df:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019e7:	83 c0 01             	add    $0x1,%eax
  8019ea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ed:	83 c7 01             	add    $0x1,%edi
  8019f0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019f3:	75 c2                	jne    8019b7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f8:	eb 05                	jmp    8019ff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a02:	5b                   	pop    %ebx
  801a03:	5e                   	pop    %esi
  801a04:	5f                   	pop    %edi
  801a05:	5d                   	pop    %ebp
  801a06:	c3                   	ret    

00801a07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	57                   	push   %edi
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 18             	sub    $0x18,%esp
  801a10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a13:	57                   	push   %edi
  801a14:	e8 83 f6 ff ff       	call   80109c <fd2data>
  801a19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a1b:	83 c4 10             	add    $0x10,%esp
  801a1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a23:	eb 3d                	jmp    801a62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a25:	85 db                	test   %ebx,%ebx
  801a27:	74 04                	je     801a2d <devpipe_read+0x26>
				return i;
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	eb 44                	jmp    801a71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a2d:	89 f2                	mov    %esi,%edx
  801a2f:	89 f8                	mov    %edi,%eax
  801a31:	e8 e5 fe ff ff       	call   80191b <_pipeisclosed>
  801a36:	85 c0                	test   %eax,%eax
  801a38:	75 32                	jne    801a6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a3a:	e8 f2 f0 ff ff       	call   800b31 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a3f:	8b 06                	mov    (%esi),%eax
  801a41:	3b 46 04             	cmp    0x4(%esi),%eax
  801a44:	74 df                	je     801a25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a46:	99                   	cltd   
  801a47:	c1 ea 1b             	shr    $0x1b,%edx
  801a4a:	01 d0                	add    %edx,%eax
  801a4c:	83 e0 1f             	and    $0x1f,%eax
  801a4f:	29 d0                	sub    %edx,%eax
  801a51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a5f:	83 c3 01             	add    $0x1,%ebx
  801a62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a65:	75 d8                	jne    801a3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a67:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6a:	eb 05                	jmp    801a71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a74:	5b                   	pop    %ebx
  801a75:	5e                   	pop    %esi
  801a76:	5f                   	pop    %edi
  801a77:	5d                   	pop    %ebp
  801a78:	c3                   	ret    

00801a79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a84:	50                   	push   %eax
  801a85:	e8 29 f6 ff ff       	call   8010b3 <fd_alloc>
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	89 c2                	mov    %eax,%edx
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	0f 88 2c 01 00 00    	js     801bc3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a97:	83 ec 04             	sub    $0x4,%esp
  801a9a:	68 07 04 00 00       	push   $0x407
  801a9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa2:	6a 00                	push   $0x0
  801aa4:	e8 a7 f0 ff ff       	call   800b50 <sys_page_alloc>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	89 c2                	mov    %eax,%edx
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	0f 88 0d 01 00 00    	js     801bc3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ab6:	83 ec 0c             	sub    $0xc,%esp
  801ab9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801abc:	50                   	push   %eax
  801abd:	e8 f1 f5 ff ff       	call   8010b3 <fd_alloc>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	0f 88 e2 00 00 00    	js     801bb1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801acf:	83 ec 04             	sub    $0x4,%esp
  801ad2:	68 07 04 00 00       	push   $0x407
  801ad7:	ff 75 f0             	pushl  -0x10(%ebp)
  801ada:	6a 00                	push   $0x0
  801adc:	e8 6f f0 ff ff       	call   800b50 <sys_page_alloc>
  801ae1:	89 c3                	mov    %eax,%ebx
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	0f 88 c3 00 00 00    	js     801bb1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801aee:	83 ec 0c             	sub    $0xc,%esp
  801af1:	ff 75 f4             	pushl  -0xc(%ebp)
  801af4:	e8 a3 f5 ff ff       	call   80109c <fd2data>
  801af9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afb:	83 c4 0c             	add    $0xc,%esp
  801afe:	68 07 04 00 00       	push   $0x407
  801b03:	50                   	push   %eax
  801b04:	6a 00                	push   $0x0
  801b06:	e8 45 f0 ff ff       	call   800b50 <sys_page_alloc>
  801b0b:	89 c3                	mov    %eax,%ebx
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	85 c0                	test   %eax,%eax
  801b12:	0f 88 89 00 00 00    	js     801ba1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b18:	83 ec 0c             	sub    $0xc,%esp
  801b1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b1e:	e8 79 f5 ff ff       	call   80109c <fd2data>
  801b23:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b2a:	50                   	push   %eax
  801b2b:	6a 00                	push   $0x0
  801b2d:	56                   	push   %esi
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 5e f0 ff ff       	call   800b93 <sys_page_map>
  801b35:	89 c3                	mov    %eax,%ebx
  801b37:	83 c4 20             	add    $0x20,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 55                	js     801b93 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b3e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b53:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b68:	83 ec 0c             	sub    $0xc,%esp
  801b6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6e:	e8 19 f5 ff ff       	call   80108c <fd2num>
  801b73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b76:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b78:	83 c4 04             	add    $0x4,%esp
  801b7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b7e:	e8 09 f5 ff ff       	call   80108c <fd2num>
  801b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b86:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b89:	83 c4 10             	add    $0x10,%esp
  801b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b91:	eb 30                	jmp    801bc3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b93:	83 ec 08             	sub    $0x8,%esp
  801b96:	56                   	push   %esi
  801b97:	6a 00                	push   $0x0
  801b99:	e8 37 f0 ff ff       	call   800bd5 <sys_page_unmap>
  801b9e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ba1:	83 ec 08             	sub    $0x8,%esp
  801ba4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba7:	6a 00                	push   $0x0
  801ba9:	e8 27 f0 ff ff       	call   800bd5 <sys_page_unmap>
  801bae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb7:	6a 00                	push   $0x0
  801bb9:	e8 17 f0 ff ff       	call   800bd5 <sys_page_unmap>
  801bbe:	83 c4 10             	add    $0x10,%esp
  801bc1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bc3:	89 d0                	mov    %edx,%eax
  801bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	ff 75 08             	pushl  0x8(%ebp)
  801bd9:	e8 24 f5 ff ff       	call   801102 <fd_lookup>
  801bde:	83 c4 10             	add    $0x10,%esp
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 18                	js     801bfd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801be5:	83 ec 0c             	sub    $0xc,%esp
  801be8:	ff 75 f4             	pushl  -0xc(%ebp)
  801beb:	e8 ac f4 ff ff       	call   80109c <fd2data>
	return _pipeisclosed(fd, p);
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	e8 21 fd ff ff       	call   80191b <_pipeisclosed>
  801bfa:	83 c4 10             	add    $0x10,%esp
}
  801bfd:	c9                   	leave  
  801bfe:	c3                   	ret    

00801bff <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c05:	68 22 2c 80 00       	push   $0x802c22
  801c0a:	ff 75 0c             	pushl  0xc(%ebp)
  801c0d:	e8 3b eb ff ff       	call   80074d <strcpy>
	return 0;
}
  801c12:	b8 00 00 00 00       	mov    $0x0,%eax
  801c17:	c9                   	leave  
  801c18:	c3                   	ret    

00801c19 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 10             	sub    $0x10,%esp
  801c20:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c23:	53                   	push   %ebx
  801c24:	e8 9a 07 00 00       	call   8023c3 <pageref>
  801c29:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c2c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c31:	83 f8 01             	cmp    $0x1,%eax
  801c34:	75 10                	jne    801c46 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c36:	83 ec 0c             	sub    $0xc,%esp
  801c39:	ff 73 0c             	pushl  0xc(%ebx)
  801c3c:	e8 c0 02 00 00       	call   801f01 <nsipc_close>
  801c41:	89 c2                	mov    %eax,%edx
  801c43:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c46:	89 d0                	mov    %edx,%eax
  801c48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c53:	6a 00                	push   $0x0
  801c55:	ff 75 10             	pushl  0x10(%ebp)
  801c58:	ff 75 0c             	pushl  0xc(%ebp)
  801c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5e:	ff 70 0c             	pushl  0xc(%eax)
  801c61:	e8 78 03 00 00       	call   801fde <nsipc_send>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c6e:	6a 00                	push   $0x0
  801c70:	ff 75 10             	pushl  0x10(%ebp)
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	ff 70 0c             	pushl  0xc(%eax)
  801c7c:	e8 f1 02 00 00       	call   801f72 <nsipc_recv>
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c89:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c8c:	52                   	push   %edx
  801c8d:	50                   	push   %eax
  801c8e:	e8 6f f4 ff ff       	call   801102 <fd_lookup>
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	85 c0                	test   %eax,%eax
  801c98:	78 17                	js     801cb1 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9d:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801ca3:	39 08                	cmp    %ecx,(%eax)
  801ca5:	75 05                	jne    801cac <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ca7:	8b 40 0c             	mov    0xc(%eax),%eax
  801caa:	eb 05                	jmp    801cb1 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 1c             	sub    $0x1c,%esp
  801cbb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cc0:	50                   	push   %eax
  801cc1:	e8 ed f3 ff ff       	call   8010b3 <fd_alloc>
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	78 1b                	js     801cea <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ccf:	83 ec 04             	sub    $0x4,%esp
  801cd2:	68 07 04 00 00       	push   $0x407
  801cd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 6f ee ff ff       	call   800b50 <sys_page_alloc>
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	79 10                	jns    801cfa <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801cea:	83 ec 0c             	sub    $0xc,%esp
  801ced:	56                   	push   %esi
  801cee:	e8 0e 02 00 00       	call   801f01 <nsipc_close>
		return r;
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	eb 24                	jmp    801d1e <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801cfa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d03:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d08:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d0f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d12:	83 ec 0c             	sub    $0xc,%esp
  801d15:	50                   	push   %eax
  801d16:	e8 71 f3 ff ff       	call   80108c <fd2num>
  801d1b:	83 c4 10             	add    $0x10,%esp
}
  801d1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	e8 50 ff ff ff       	call   801c83 <fd2sockid>
		return r;
  801d33:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d35:	85 c0                	test   %eax,%eax
  801d37:	78 1f                	js     801d58 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d39:	83 ec 04             	sub    $0x4,%esp
  801d3c:	ff 75 10             	pushl  0x10(%ebp)
  801d3f:	ff 75 0c             	pushl  0xc(%ebp)
  801d42:	50                   	push   %eax
  801d43:	e8 12 01 00 00       	call   801e5a <nsipc_accept>
  801d48:	83 c4 10             	add    $0x10,%esp
		return r;
  801d4b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	78 07                	js     801d58 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d51:	e8 5d ff ff ff       	call   801cb3 <alloc_sockfd>
  801d56:	89 c1                	mov    %eax,%ecx
}
  801d58:	89 c8                	mov    %ecx,%eax
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	e8 19 ff ff ff       	call   801c83 <fd2sockid>
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 12                	js     801d80 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d6e:	83 ec 04             	sub    $0x4,%esp
  801d71:	ff 75 10             	pushl  0x10(%ebp)
  801d74:	ff 75 0c             	pushl  0xc(%ebp)
  801d77:	50                   	push   %eax
  801d78:	e8 2d 01 00 00       	call   801eaa <nsipc_bind>
  801d7d:	83 c4 10             	add    $0x10,%esp
}
  801d80:	c9                   	leave  
  801d81:	c3                   	ret    

00801d82 <shutdown>:

int
shutdown(int s, int how)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d88:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8b:	e8 f3 fe ff ff       	call   801c83 <fd2sockid>
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 0f                	js     801da3 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d94:	83 ec 08             	sub    $0x8,%esp
  801d97:	ff 75 0c             	pushl  0xc(%ebp)
  801d9a:	50                   	push   %eax
  801d9b:	e8 3f 01 00 00       	call   801edf <nsipc_shutdown>
  801da0:	83 c4 10             	add    $0x10,%esp
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	e8 d0 fe ff ff       	call   801c83 <fd2sockid>
  801db3:	85 c0                	test   %eax,%eax
  801db5:	78 12                	js     801dc9 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801db7:	83 ec 04             	sub    $0x4,%esp
  801dba:	ff 75 10             	pushl  0x10(%ebp)
  801dbd:	ff 75 0c             	pushl  0xc(%ebp)
  801dc0:	50                   	push   %eax
  801dc1:	e8 55 01 00 00       	call   801f1b <nsipc_connect>
  801dc6:	83 c4 10             	add    $0x10,%esp
}
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <listen>:

int
listen(int s, int backlog)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	e8 aa fe ff ff       	call   801c83 <fd2sockid>
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 0f                	js     801dec <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ddd:	83 ec 08             	sub    $0x8,%esp
  801de0:	ff 75 0c             	pushl  0xc(%ebp)
  801de3:	50                   	push   %eax
  801de4:	e8 67 01 00 00       	call   801f50 <nsipc_listen>
  801de9:	83 c4 10             	add    $0x10,%esp
}
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801df4:	ff 75 10             	pushl  0x10(%ebp)
  801df7:	ff 75 0c             	pushl  0xc(%ebp)
  801dfa:	ff 75 08             	pushl  0x8(%ebp)
  801dfd:	e8 3a 02 00 00       	call   80203c <nsipc_socket>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 05                	js     801e0e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e09:	e8 a5 fe ff ff       	call   801cb3 <alloc_sockfd>
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	53                   	push   %ebx
  801e14:	83 ec 04             	sub    $0x4,%esp
  801e17:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e19:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e20:	75 12                	jne    801e34 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e22:	83 ec 0c             	sub    $0xc,%esp
  801e25:	6a 02                	push   $0x2
  801e27:	e8 5e 05 00 00       	call   80238a <ipc_find_env>
  801e2c:	a3 04 40 80 00       	mov    %eax,0x804004
  801e31:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e34:	6a 07                	push   $0x7
  801e36:	68 00 60 80 00       	push   $0x806000
  801e3b:	53                   	push   %ebx
  801e3c:	ff 35 04 40 80 00    	pushl  0x804004
  801e42:	e8 f4 04 00 00       	call   80233b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e47:	83 c4 0c             	add    $0xc,%esp
  801e4a:	6a 00                	push   $0x0
  801e4c:	6a 00                	push   $0x0
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 70 04 00 00       	call   8022c5 <ipc_recv>
}
  801e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	56                   	push   %esi
  801e5e:	53                   	push   %ebx
  801e5f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e62:	8b 45 08             	mov    0x8(%ebp),%eax
  801e65:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e6a:	8b 06                	mov    (%esi),%eax
  801e6c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e71:	b8 01 00 00 00       	mov    $0x1,%eax
  801e76:	e8 95 ff ff ff       	call   801e10 <nsipc>
  801e7b:	89 c3                	mov    %eax,%ebx
  801e7d:	85 c0                	test   %eax,%eax
  801e7f:	78 20                	js     801ea1 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e81:	83 ec 04             	sub    $0x4,%esp
  801e84:	ff 35 10 60 80 00    	pushl  0x806010
  801e8a:	68 00 60 80 00       	push   $0x806000
  801e8f:	ff 75 0c             	pushl  0xc(%ebp)
  801e92:	e8 48 ea ff ff       	call   8008df <memmove>
		*addrlen = ret->ret_addrlen;
  801e97:	a1 10 60 80 00       	mov    0x806010,%eax
  801e9c:	89 06                	mov    %eax,(%esi)
  801e9e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ea1:	89 d8                	mov    %ebx,%eax
  801ea3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea6:	5b                   	pop    %ebx
  801ea7:	5e                   	pop    %esi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	53                   	push   %ebx
  801eae:	83 ec 08             	sub    $0x8,%esp
  801eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ebc:	53                   	push   %ebx
  801ebd:	ff 75 0c             	pushl  0xc(%ebp)
  801ec0:	68 04 60 80 00       	push   $0x806004
  801ec5:	e8 15 ea ff ff       	call   8008df <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801eca:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ed0:	b8 02 00 00 00       	mov    $0x2,%eax
  801ed5:	e8 36 ff ff ff       	call   801e10 <nsipc>
}
  801eda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ef5:	b8 03 00 00 00       	mov    $0x3,%eax
  801efa:	e8 11 ff ff ff       	call   801e10 <nsipc>
}
  801eff:	c9                   	leave  
  801f00:	c3                   	ret    

00801f01 <nsipc_close>:

int
nsipc_close(int s)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f0f:	b8 04 00 00 00       	mov    $0x4,%eax
  801f14:	e8 f7 fe ff ff       	call   801e10 <nsipc>
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	53                   	push   %ebx
  801f1f:	83 ec 08             	sub    $0x8,%esp
  801f22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f25:	8b 45 08             	mov    0x8(%ebp),%eax
  801f28:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f2d:	53                   	push   %ebx
  801f2e:	ff 75 0c             	pushl  0xc(%ebp)
  801f31:	68 04 60 80 00       	push   $0x806004
  801f36:	e8 a4 e9 ff ff       	call   8008df <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f3b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f41:	b8 05 00 00 00       	mov    $0x5,%eax
  801f46:	e8 c5 fe ff ff       	call   801e10 <nsipc>
}
  801f4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f4e:	c9                   	leave  
  801f4f:	c3                   	ret    

00801f50 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f56:	8b 45 08             	mov    0x8(%ebp),%eax
  801f59:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f61:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f66:	b8 06 00 00 00       	mov    $0x6,%eax
  801f6b:	e8 a0 fe ff ff       	call   801e10 <nsipc>
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	56                   	push   %esi
  801f76:	53                   	push   %ebx
  801f77:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f82:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f88:	8b 45 14             	mov    0x14(%ebp),%eax
  801f8b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f90:	b8 07 00 00 00       	mov    $0x7,%eax
  801f95:	e8 76 fe ff ff       	call   801e10 <nsipc>
  801f9a:	89 c3                	mov    %eax,%ebx
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	78 35                	js     801fd5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801fa0:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fa5:	7f 04                	jg     801fab <nsipc_recv+0x39>
  801fa7:	39 c6                	cmp    %eax,%esi
  801fa9:	7d 16                	jge    801fc1 <nsipc_recv+0x4f>
  801fab:	68 2e 2c 80 00       	push   $0x802c2e
  801fb0:	68 d7 2b 80 00       	push   $0x802bd7
  801fb5:	6a 62                	push   $0x62
  801fb7:	68 43 2c 80 00       	push   $0x802c43
  801fbc:	e8 28 02 00 00       	call   8021e9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fc1:	83 ec 04             	sub    $0x4,%esp
  801fc4:	50                   	push   %eax
  801fc5:	68 00 60 80 00       	push   $0x806000
  801fca:	ff 75 0c             	pushl  0xc(%ebp)
  801fcd:	e8 0d e9 ff ff       	call   8008df <memmove>
  801fd2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801fd5:	89 d8                	mov    %ebx,%eax
  801fd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fda:	5b                   	pop    %ebx
  801fdb:	5e                   	pop    %esi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 04             	sub    $0x4,%esp
  801fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ff0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ff6:	7e 16                	jle    80200e <nsipc_send+0x30>
  801ff8:	68 4f 2c 80 00       	push   $0x802c4f
  801ffd:	68 d7 2b 80 00       	push   $0x802bd7
  802002:	6a 6d                	push   $0x6d
  802004:	68 43 2c 80 00       	push   $0x802c43
  802009:	e8 db 01 00 00       	call   8021e9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80200e:	83 ec 04             	sub    $0x4,%esp
  802011:	53                   	push   %ebx
  802012:	ff 75 0c             	pushl  0xc(%ebp)
  802015:	68 0c 60 80 00       	push   $0x80600c
  80201a:	e8 c0 e8 ff ff       	call   8008df <memmove>
	nsipcbuf.send.req_size = size;
  80201f:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802025:	8b 45 14             	mov    0x14(%ebp),%eax
  802028:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80202d:	b8 08 00 00 00       	mov    $0x8,%eax
  802032:	e8 d9 fd ff ff       	call   801e10 <nsipc>
}
  802037:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80203a:	c9                   	leave  
  80203b:	c3                   	ret    

0080203c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802042:	8b 45 08             	mov    0x8(%ebp),%eax
  802045:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80204a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802052:	8b 45 10             	mov    0x10(%ebp),%eax
  802055:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80205a:	b8 09 00 00 00       	mov    $0x9,%eax
  80205f:	e8 ac fd ff ff       	call   801e10 <nsipc>
}
  802064:	c9                   	leave  
  802065:	c3                   	ret    

00802066 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802066:	55                   	push   %ebp
  802067:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
  80206e:	5d                   	pop    %ebp
  80206f:	c3                   	ret    

00802070 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802076:	68 5b 2c 80 00       	push   $0x802c5b
  80207b:	ff 75 0c             	pushl  0xc(%ebp)
  80207e:	e8 ca e6 ff ff       	call   80074d <strcpy>
	return 0;
}
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
  802088:	c9                   	leave  
  802089:	c3                   	ret    

0080208a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80208a:	55                   	push   %ebp
  80208b:	89 e5                	mov    %esp,%ebp
  80208d:	57                   	push   %edi
  80208e:	56                   	push   %esi
  80208f:	53                   	push   %ebx
  802090:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802096:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80209b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020a1:	eb 2d                	jmp    8020d0 <devcons_write+0x46>
		m = n - tot;
  8020a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020a6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020a8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020ab:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020b0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020b3:	83 ec 04             	sub    $0x4,%esp
  8020b6:	53                   	push   %ebx
  8020b7:	03 45 0c             	add    0xc(%ebp),%eax
  8020ba:	50                   	push   %eax
  8020bb:	57                   	push   %edi
  8020bc:	e8 1e e8 ff ff       	call   8008df <memmove>
		sys_cputs(buf, m);
  8020c1:	83 c4 08             	add    $0x8,%esp
  8020c4:	53                   	push   %ebx
  8020c5:	57                   	push   %edi
  8020c6:	e8 c9 e9 ff ff       	call   800a94 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020cb:	01 de                	add    %ebx,%esi
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	89 f0                	mov    %esi,%eax
  8020d2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020d5:	72 cc                	jb     8020a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020da:	5b                   	pop    %ebx
  8020db:	5e                   	pop    %esi
  8020dc:	5f                   	pop    %edi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    

008020df <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	83 ec 08             	sub    $0x8,%esp
  8020e5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020ee:	74 2a                	je     80211a <devcons_read+0x3b>
  8020f0:	eb 05                	jmp    8020f7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020f2:	e8 3a ea ff ff       	call   800b31 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020f7:	e8 b6 e9 ff ff       	call   800ab2 <sys_cgetc>
  8020fc:	85 c0                	test   %eax,%eax
  8020fe:	74 f2                	je     8020f2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802100:	85 c0                	test   %eax,%eax
  802102:	78 16                	js     80211a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802104:	83 f8 04             	cmp    $0x4,%eax
  802107:	74 0c                	je     802115 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802109:	8b 55 0c             	mov    0xc(%ebp),%edx
  80210c:	88 02                	mov    %al,(%edx)
	return 1;
  80210e:	b8 01 00 00 00       	mov    $0x1,%eax
  802113:	eb 05                	jmp    80211a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802115:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802122:	8b 45 08             	mov    0x8(%ebp),%eax
  802125:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802128:	6a 01                	push   $0x1
  80212a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80212d:	50                   	push   %eax
  80212e:	e8 61 e9 ff ff       	call   800a94 <sys_cputs>
}
  802133:	83 c4 10             	add    $0x10,%esp
  802136:	c9                   	leave  
  802137:	c3                   	ret    

00802138 <getchar>:

int
getchar(void)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80213e:	6a 01                	push   $0x1
  802140:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802143:	50                   	push   %eax
  802144:	6a 00                	push   $0x0
  802146:	e8 1d f2 ff ff       	call   801368 <read>
	if (r < 0)
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	85 c0                	test   %eax,%eax
  802150:	78 0f                	js     802161 <getchar+0x29>
		return r;
	if (r < 1)
  802152:	85 c0                	test   %eax,%eax
  802154:	7e 06                	jle    80215c <getchar+0x24>
		return -E_EOF;
	return c;
  802156:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80215a:	eb 05                	jmp    802161 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80215c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    

00802163 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802163:	55                   	push   %ebp
  802164:	89 e5                	mov    %esp,%ebp
  802166:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802169:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80216c:	50                   	push   %eax
  80216d:	ff 75 08             	pushl  0x8(%ebp)
  802170:	e8 8d ef ff ff       	call   801102 <fd_lookup>
  802175:	83 c4 10             	add    $0x10,%esp
  802178:	85 c0                	test   %eax,%eax
  80217a:	78 11                	js     80218d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80217c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802185:	39 10                	cmp    %edx,(%eax)
  802187:	0f 94 c0             	sete   %al
  80218a:	0f b6 c0             	movzbl %al,%eax
}
  80218d:	c9                   	leave  
  80218e:	c3                   	ret    

0080218f <opencons>:

int
opencons(void)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802198:	50                   	push   %eax
  802199:	e8 15 ef ff ff       	call   8010b3 <fd_alloc>
  80219e:	83 c4 10             	add    $0x10,%esp
		return r;
  8021a1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	78 3e                	js     8021e5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a7:	83 ec 04             	sub    $0x4,%esp
  8021aa:	68 07 04 00 00       	push   $0x407
  8021af:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b2:	6a 00                	push   $0x0
  8021b4:	e8 97 e9 ff ff       	call   800b50 <sys_page_alloc>
  8021b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8021bc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021be:	85 c0                	test   %eax,%eax
  8021c0:	78 23                	js     8021e5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021c2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021d7:	83 ec 0c             	sub    $0xc,%esp
  8021da:	50                   	push   %eax
  8021db:	e8 ac ee ff ff       	call   80108c <fd2num>
  8021e0:	89 c2                	mov    %eax,%edx
  8021e2:	83 c4 10             	add    $0x10,%esp
}
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	c9                   	leave  
  8021e8:	c3                   	ret    

008021e9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021e9:	55                   	push   %ebp
  8021ea:	89 e5                	mov    %esp,%ebp
  8021ec:	56                   	push   %esi
  8021ed:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021ee:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021f1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021f7:	e8 16 e9 ff ff       	call   800b12 <sys_getenvid>
  8021fc:	83 ec 0c             	sub    $0xc,%esp
  8021ff:	ff 75 0c             	pushl  0xc(%ebp)
  802202:	ff 75 08             	pushl  0x8(%ebp)
  802205:	56                   	push   %esi
  802206:	50                   	push   %eax
  802207:	68 68 2c 80 00       	push   $0x802c68
  80220c:	e8 97 df ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802211:	83 c4 18             	add    $0x18,%esp
  802214:	53                   	push   %ebx
  802215:	ff 75 10             	pushl  0x10(%ebp)
  802218:	e8 3a df ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  80221d:	c7 04 24 34 27 80 00 	movl   $0x802734,(%esp)
  802224:	e8 7f df ff ff       	call   8001a8 <cprintf>
  802229:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80222c:	cc                   	int3   
  80222d:	eb fd                	jmp    80222c <_panic+0x43>

0080222f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80222f:	55                   	push   %ebp
  802230:	89 e5                	mov    %esp,%ebp
  802232:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802235:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80223c:	75 56                	jne    802294 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80223e:	83 ec 04             	sub    $0x4,%esp
  802241:	6a 07                	push   $0x7
  802243:	68 00 f0 bf ee       	push   $0xeebff000
  802248:	6a 00                	push   $0x0
  80224a:	e8 01 e9 ff ff       	call   800b50 <sys_page_alloc>
  80224f:	83 c4 10             	add    $0x10,%esp
  802252:	85 c0                	test   %eax,%eax
  802254:	74 14                	je     80226a <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  802256:	83 ec 04             	sub    $0x4,%esp
  802259:	68 e9 2a 80 00       	push   $0x802ae9
  80225e:	6a 21                	push   $0x21
  802260:	68 8c 2c 80 00       	push   $0x802c8c
  802265:	e8 7f ff ff ff       	call   8021e9 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  80226a:	83 ec 08             	sub    $0x8,%esp
  80226d:	68 9e 22 80 00       	push   $0x80229e
  802272:	6a 00                	push   $0x0
  802274:	e8 22 ea ff ff       	call   800c9b <sys_env_set_pgfault_upcall>
  802279:	83 c4 10             	add    $0x10,%esp
  80227c:	85 c0                	test   %eax,%eax
  80227e:	74 14                	je     802294 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  802280:	83 ec 04             	sub    $0x4,%esp
  802283:	68 9a 2c 80 00       	push   $0x802c9a
  802288:	6a 23                	push   $0x23
  80228a:	68 8c 2c 80 00       	push   $0x802c8c
  80228f:	e8 55 ff ff ff       	call   8021e9 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802294:	8b 45 08             	mov    0x8(%ebp),%eax
  802297:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80229e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80229f:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022a4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022a6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8022a9:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8022ab:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8022af:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8022b3:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8022b4:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8022b6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8022bb:	83 c4 08             	add    $0x8,%esp
	popal
  8022be:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8022bf:	83 c4 04             	add    $0x4,%esp
	popfl
  8022c2:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022c3:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022c4:	c3                   	ret    

008022c5 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	56                   	push   %esi
  8022c9:	53                   	push   %ebx
  8022ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8022cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8022d3:	85 c0                	test   %eax,%eax
  8022d5:	74 0e                	je     8022e5 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8022d7:	83 ec 0c             	sub    $0xc,%esp
  8022da:	50                   	push   %eax
  8022db:	e8 20 ea ff ff       	call   800d00 <sys_ipc_recv>
  8022e0:	83 c4 10             	add    $0x10,%esp
  8022e3:	eb 10                	jmp    8022f5 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8022e5:	83 ec 0c             	sub    $0xc,%esp
  8022e8:	68 00 00 c0 ee       	push   $0xeec00000
  8022ed:	e8 0e ea ff ff       	call   800d00 <sys_ipc_recv>
  8022f2:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8022f5:	85 c0                	test   %eax,%eax
  8022f7:	79 17                	jns    802310 <ipc_recv+0x4b>
		if(*from_env_store)
  8022f9:	83 3e 00             	cmpl   $0x0,(%esi)
  8022fc:	74 06                	je     802304 <ipc_recv+0x3f>
			*from_env_store = 0;
  8022fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802304:	85 db                	test   %ebx,%ebx
  802306:	74 2c                	je     802334 <ipc_recv+0x6f>
			*perm_store = 0;
  802308:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80230e:	eb 24                	jmp    802334 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  802310:	85 f6                	test   %esi,%esi
  802312:	74 0a                	je     80231e <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802314:	a1 08 40 80 00       	mov    0x804008,%eax
  802319:	8b 40 74             	mov    0x74(%eax),%eax
  80231c:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80231e:	85 db                	test   %ebx,%ebx
  802320:	74 0a                	je     80232c <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  802322:	a1 08 40 80 00       	mov    0x804008,%eax
  802327:	8b 40 78             	mov    0x78(%eax),%eax
  80232a:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80232c:	a1 08 40 80 00       	mov    0x804008,%eax
  802331:	8b 40 70             	mov    0x70(%eax),%eax
}
  802334:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    

0080233b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
  80233e:	57                   	push   %edi
  80233f:	56                   	push   %esi
  802340:	53                   	push   %ebx
  802341:	83 ec 0c             	sub    $0xc,%esp
  802344:	8b 7d 08             	mov    0x8(%ebp),%edi
  802347:	8b 75 0c             	mov    0xc(%ebp),%esi
  80234a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80234d:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80234f:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802354:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802357:	e8 d5 e7 ff ff       	call   800b31 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80235c:	ff 75 14             	pushl  0x14(%ebp)
  80235f:	53                   	push   %ebx
  802360:	56                   	push   %esi
  802361:	57                   	push   %edi
  802362:	e8 76 e9 ff ff       	call   800cdd <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802367:	89 c2                	mov    %eax,%edx
  802369:	f7 d2                	not    %edx
  80236b:	c1 ea 1f             	shr    $0x1f,%edx
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802374:	0f 94 c1             	sete   %cl
  802377:	09 ca                	or     %ecx,%edx
  802379:	85 c0                	test   %eax,%eax
  80237b:	0f 94 c0             	sete   %al
  80237e:	38 c2                	cmp    %al,%dl
  802380:	77 d5                	ja     802357 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802382:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802385:	5b                   	pop    %ebx
  802386:	5e                   	pop    %esi
  802387:	5f                   	pop    %edi
  802388:	5d                   	pop    %ebp
  802389:	c3                   	ret    

0080238a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80238a:	55                   	push   %ebp
  80238b:	89 e5                	mov    %esp,%ebp
  80238d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802390:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802395:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802398:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80239e:	8b 52 50             	mov    0x50(%edx),%edx
  8023a1:	39 ca                	cmp    %ecx,%edx
  8023a3:	75 0d                	jne    8023b2 <ipc_find_env+0x28>
			return envs[i].env_id;
  8023a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023ad:	8b 40 48             	mov    0x48(%eax),%eax
  8023b0:	eb 0f                	jmp    8023c1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023b2:	83 c0 01             	add    $0x1,%eax
  8023b5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023ba:	75 d9                	jne    802395 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    

008023c3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023c3:	55                   	push   %ebp
  8023c4:	89 e5                	mov    %esp,%ebp
  8023c6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023c9:	89 d0                	mov    %edx,%eax
  8023cb:	c1 e8 16             	shr    $0x16,%eax
  8023ce:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023d5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023da:	f6 c1 01             	test   $0x1,%cl
  8023dd:	74 1d                	je     8023fc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023df:	c1 ea 0c             	shr    $0xc,%edx
  8023e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023e9:	f6 c2 01             	test   $0x1,%dl
  8023ec:	74 0e                	je     8023fc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023ee:	c1 ea 0c             	shr    $0xc,%edx
  8023f1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023f8:	ef 
  8023f9:	0f b7 c0             	movzwl %ax,%eax
}
  8023fc:	5d                   	pop    %ebp
  8023fd:	c3                   	ret    
  8023fe:	66 90                	xchg   %ax,%ax

00802400 <__udivdi3>:
  802400:	55                   	push   %ebp
  802401:	57                   	push   %edi
  802402:	56                   	push   %esi
  802403:	53                   	push   %ebx
  802404:	83 ec 1c             	sub    $0x1c,%esp
  802407:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80240b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80240f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802413:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802417:	85 f6                	test   %esi,%esi
  802419:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80241d:	89 ca                	mov    %ecx,%edx
  80241f:	89 f8                	mov    %edi,%eax
  802421:	75 3d                	jne    802460 <__udivdi3+0x60>
  802423:	39 cf                	cmp    %ecx,%edi
  802425:	0f 87 c5 00 00 00    	ja     8024f0 <__udivdi3+0xf0>
  80242b:	85 ff                	test   %edi,%edi
  80242d:	89 fd                	mov    %edi,%ebp
  80242f:	75 0b                	jne    80243c <__udivdi3+0x3c>
  802431:	b8 01 00 00 00       	mov    $0x1,%eax
  802436:	31 d2                	xor    %edx,%edx
  802438:	f7 f7                	div    %edi
  80243a:	89 c5                	mov    %eax,%ebp
  80243c:	89 c8                	mov    %ecx,%eax
  80243e:	31 d2                	xor    %edx,%edx
  802440:	f7 f5                	div    %ebp
  802442:	89 c1                	mov    %eax,%ecx
  802444:	89 d8                	mov    %ebx,%eax
  802446:	89 cf                	mov    %ecx,%edi
  802448:	f7 f5                	div    %ebp
  80244a:	89 c3                	mov    %eax,%ebx
  80244c:	89 d8                	mov    %ebx,%eax
  80244e:	89 fa                	mov    %edi,%edx
  802450:	83 c4 1c             	add    $0x1c,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5f                   	pop    %edi
  802456:	5d                   	pop    %ebp
  802457:	c3                   	ret    
  802458:	90                   	nop
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	39 ce                	cmp    %ecx,%esi
  802462:	77 74                	ja     8024d8 <__udivdi3+0xd8>
  802464:	0f bd fe             	bsr    %esi,%edi
  802467:	83 f7 1f             	xor    $0x1f,%edi
  80246a:	0f 84 98 00 00 00    	je     802508 <__udivdi3+0x108>
  802470:	bb 20 00 00 00       	mov    $0x20,%ebx
  802475:	89 f9                	mov    %edi,%ecx
  802477:	89 c5                	mov    %eax,%ebp
  802479:	29 fb                	sub    %edi,%ebx
  80247b:	d3 e6                	shl    %cl,%esi
  80247d:	89 d9                	mov    %ebx,%ecx
  80247f:	d3 ed                	shr    %cl,%ebp
  802481:	89 f9                	mov    %edi,%ecx
  802483:	d3 e0                	shl    %cl,%eax
  802485:	09 ee                	or     %ebp,%esi
  802487:	89 d9                	mov    %ebx,%ecx
  802489:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80248d:	89 d5                	mov    %edx,%ebp
  80248f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802493:	d3 ed                	shr    %cl,%ebp
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e2                	shl    %cl,%edx
  802499:	89 d9                	mov    %ebx,%ecx
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	09 c2                	or     %eax,%edx
  80249f:	89 d0                	mov    %edx,%eax
  8024a1:	89 ea                	mov    %ebp,%edx
  8024a3:	f7 f6                	div    %esi
  8024a5:	89 d5                	mov    %edx,%ebp
  8024a7:	89 c3                	mov    %eax,%ebx
  8024a9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ad:	39 d5                	cmp    %edx,%ebp
  8024af:	72 10                	jb     8024c1 <__udivdi3+0xc1>
  8024b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024b5:	89 f9                	mov    %edi,%ecx
  8024b7:	d3 e6                	shl    %cl,%esi
  8024b9:	39 c6                	cmp    %eax,%esi
  8024bb:	73 07                	jae    8024c4 <__udivdi3+0xc4>
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	75 03                	jne    8024c4 <__udivdi3+0xc4>
  8024c1:	83 eb 01             	sub    $0x1,%ebx
  8024c4:	31 ff                	xor    %edi,%edi
  8024c6:	89 d8                	mov    %ebx,%eax
  8024c8:	89 fa                	mov    %edi,%edx
  8024ca:	83 c4 1c             	add    $0x1c,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5f                   	pop    %edi
  8024d0:	5d                   	pop    %ebp
  8024d1:	c3                   	ret    
  8024d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024d8:	31 ff                	xor    %edi,%edi
  8024da:	31 db                	xor    %ebx,%ebx
  8024dc:	89 d8                	mov    %ebx,%eax
  8024de:	89 fa                	mov    %edi,%edx
  8024e0:	83 c4 1c             	add    $0x1c,%esp
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5f                   	pop    %edi
  8024e6:	5d                   	pop    %ebp
  8024e7:	c3                   	ret    
  8024e8:	90                   	nop
  8024e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024f0:	89 d8                	mov    %ebx,%eax
  8024f2:	f7 f7                	div    %edi
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 c3                	mov    %eax,%ebx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 fa                	mov    %edi,%edx
  8024fc:	83 c4 1c             	add    $0x1c,%esp
  8024ff:	5b                   	pop    %ebx
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802508:	39 ce                	cmp    %ecx,%esi
  80250a:	72 0c                	jb     802518 <__udivdi3+0x118>
  80250c:	31 db                	xor    %ebx,%ebx
  80250e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802512:	0f 87 34 ff ff ff    	ja     80244c <__udivdi3+0x4c>
  802518:	bb 01 00 00 00       	mov    $0x1,%ebx
  80251d:	e9 2a ff ff ff       	jmp    80244c <__udivdi3+0x4c>
  802522:	66 90                	xchg   %ax,%ax
  802524:	66 90                	xchg   %ax,%ax
  802526:	66 90                	xchg   %ax,%ax
  802528:	66 90                	xchg   %ax,%ax
  80252a:	66 90                	xchg   %ax,%ax
  80252c:	66 90                	xchg   %ax,%ax
  80252e:	66 90                	xchg   %ax,%ax

00802530 <__umoddi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	53                   	push   %ebx
  802534:	83 ec 1c             	sub    $0x1c,%esp
  802537:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80253b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80253f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802547:	85 d2                	test   %edx,%edx
  802549:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80254d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802551:	89 f3                	mov    %esi,%ebx
  802553:	89 3c 24             	mov    %edi,(%esp)
  802556:	89 74 24 04          	mov    %esi,0x4(%esp)
  80255a:	75 1c                	jne    802578 <__umoddi3+0x48>
  80255c:	39 f7                	cmp    %esi,%edi
  80255e:	76 50                	jbe    8025b0 <__umoddi3+0x80>
  802560:	89 c8                	mov    %ecx,%eax
  802562:	89 f2                	mov    %esi,%edx
  802564:	f7 f7                	div    %edi
  802566:	89 d0                	mov    %edx,%eax
  802568:	31 d2                	xor    %edx,%edx
  80256a:	83 c4 1c             	add    $0x1c,%esp
  80256d:	5b                   	pop    %ebx
  80256e:	5e                   	pop    %esi
  80256f:	5f                   	pop    %edi
  802570:	5d                   	pop    %ebp
  802571:	c3                   	ret    
  802572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802578:	39 f2                	cmp    %esi,%edx
  80257a:	89 d0                	mov    %edx,%eax
  80257c:	77 52                	ja     8025d0 <__umoddi3+0xa0>
  80257e:	0f bd ea             	bsr    %edx,%ebp
  802581:	83 f5 1f             	xor    $0x1f,%ebp
  802584:	75 5a                	jne    8025e0 <__umoddi3+0xb0>
  802586:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80258a:	0f 82 e0 00 00 00    	jb     802670 <__umoddi3+0x140>
  802590:	39 0c 24             	cmp    %ecx,(%esp)
  802593:	0f 86 d7 00 00 00    	jbe    802670 <__umoddi3+0x140>
  802599:	8b 44 24 08          	mov    0x8(%esp),%eax
  80259d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025a1:	83 c4 1c             	add    $0x1c,%esp
  8025a4:	5b                   	pop    %ebx
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	85 ff                	test   %edi,%edi
  8025b2:	89 fd                	mov    %edi,%ebp
  8025b4:	75 0b                	jne    8025c1 <__umoddi3+0x91>
  8025b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025bb:	31 d2                	xor    %edx,%edx
  8025bd:	f7 f7                	div    %edi
  8025bf:	89 c5                	mov    %eax,%ebp
  8025c1:	89 f0                	mov    %esi,%eax
  8025c3:	31 d2                	xor    %edx,%edx
  8025c5:	f7 f5                	div    %ebp
  8025c7:	89 c8                	mov    %ecx,%eax
  8025c9:	f7 f5                	div    %ebp
  8025cb:	89 d0                	mov    %edx,%eax
  8025cd:	eb 99                	jmp    802568 <__umoddi3+0x38>
  8025cf:	90                   	nop
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	83 c4 1c             	add    $0x1c,%esp
  8025d7:	5b                   	pop    %ebx
  8025d8:	5e                   	pop    %esi
  8025d9:	5f                   	pop    %edi
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    
  8025dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	8b 34 24             	mov    (%esp),%esi
  8025e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025e8:	89 e9                	mov    %ebp,%ecx
  8025ea:	29 ef                	sub    %ebp,%edi
  8025ec:	d3 e0                	shl    %cl,%eax
  8025ee:	89 f9                	mov    %edi,%ecx
  8025f0:	89 f2                	mov    %esi,%edx
  8025f2:	d3 ea                	shr    %cl,%edx
  8025f4:	89 e9                	mov    %ebp,%ecx
  8025f6:	09 c2                	or     %eax,%edx
  8025f8:	89 d8                	mov    %ebx,%eax
  8025fa:	89 14 24             	mov    %edx,(%esp)
  8025fd:	89 f2                	mov    %esi,%edx
  8025ff:	d3 e2                	shl    %cl,%edx
  802601:	89 f9                	mov    %edi,%ecx
  802603:	89 54 24 04          	mov    %edx,0x4(%esp)
  802607:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80260b:	d3 e8                	shr    %cl,%eax
  80260d:	89 e9                	mov    %ebp,%ecx
  80260f:	89 c6                	mov    %eax,%esi
  802611:	d3 e3                	shl    %cl,%ebx
  802613:	89 f9                	mov    %edi,%ecx
  802615:	89 d0                	mov    %edx,%eax
  802617:	d3 e8                	shr    %cl,%eax
  802619:	89 e9                	mov    %ebp,%ecx
  80261b:	09 d8                	or     %ebx,%eax
  80261d:	89 d3                	mov    %edx,%ebx
  80261f:	89 f2                	mov    %esi,%edx
  802621:	f7 34 24             	divl   (%esp)
  802624:	89 d6                	mov    %edx,%esi
  802626:	d3 e3                	shl    %cl,%ebx
  802628:	f7 64 24 04          	mull   0x4(%esp)
  80262c:	39 d6                	cmp    %edx,%esi
  80262e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802632:	89 d1                	mov    %edx,%ecx
  802634:	89 c3                	mov    %eax,%ebx
  802636:	72 08                	jb     802640 <__umoddi3+0x110>
  802638:	75 11                	jne    80264b <__umoddi3+0x11b>
  80263a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80263e:	73 0b                	jae    80264b <__umoddi3+0x11b>
  802640:	2b 44 24 04          	sub    0x4(%esp),%eax
  802644:	1b 14 24             	sbb    (%esp),%edx
  802647:	89 d1                	mov    %edx,%ecx
  802649:	89 c3                	mov    %eax,%ebx
  80264b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80264f:	29 da                	sub    %ebx,%edx
  802651:	19 ce                	sbb    %ecx,%esi
  802653:	89 f9                	mov    %edi,%ecx
  802655:	89 f0                	mov    %esi,%eax
  802657:	d3 e0                	shl    %cl,%eax
  802659:	89 e9                	mov    %ebp,%ecx
  80265b:	d3 ea                	shr    %cl,%edx
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	d3 ee                	shr    %cl,%esi
  802661:	09 d0                	or     %edx,%eax
  802663:	89 f2                	mov    %esi,%edx
  802665:	83 c4 1c             	add    $0x1c,%esp
  802668:	5b                   	pop    %ebx
  802669:	5e                   	pop    %esi
  80266a:	5f                   	pop    %edi
  80266b:	5d                   	pop    %ebp
  80266c:	c3                   	ret    
  80266d:	8d 76 00             	lea    0x0(%esi),%esi
  802670:	29 f9                	sub    %edi,%ecx
  802672:	19 d6                	sbb    %edx,%esi
  802674:	89 74 24 04          	mov    %esi,0x4(%esp)
  802678:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80267c:	e9 18 ff ff ff       	jmp    802599 <__umoddi3+0x69>
