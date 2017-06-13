
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 1c 0e 00 00       	call   800e5d <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 cc 0a 00 00       	call   800b1b <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 a0 26 80 00       	push   $0x8026a0
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 9f 10 00 00       	call   80110b <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 16 10 00 00       	call   801095 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 92 0a 00 00       	call   800b1b <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 b6 26 80 00       	push   $0x8026b6
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 5d 10 00 00       	call   80110b <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000c9:	e8 4d 0a 00 00       	call   800b1b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 4f 12 00 00       	call   80135e <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 c1 09 00 00       	call   800ada <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 4f 09 00 00       	call   800a9d <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 f4 08 00 00       	call   800a9d <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 f7 21 00 00       	call   802410 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 e4 22 00 00       	call   802540 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 d3 26 80 00 	movsbl 0x8026d3(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 a9 03 00 00    	je     8006ad <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 3a 03 00 00    	ja     800692 <vprintfmt+0x3aa>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 20 28 80 00 	jmp    *0x802820(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800380:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 39                	ja     8003c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 27                	jmp    8003c7 <vprintfmt+0xdf>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	0f 49 c8             	cmovns %eax,%ecx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	eb 8c                	jmp    800341 <vprintfmt+0x59>
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bf:	eb 80                	jmp    800341 <vprintfmt+0x59>
  8003c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	0f 89 70 ff ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003de:	e9 5e ff ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 53 ff ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 04 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x142>
  80041f:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 eb 26 80 00       	push   $0x8026eb
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 94 fe ff ff       	call   8002cb <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cc fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	52                   	push   %edx
  800443:	68 89 2b 80 00       	push   $0x802b89
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 7c fe ff ff       	call   8002cb <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 b4 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 e4 26 80 00       	mov    $0x8026e4,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e 94 00 00 00    	jle    80050d <vprintfmt+0x225>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	0f 84 98 00 00 00    	je     80051b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d0             	pushl  -0x30(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 a6 02 00 00       	call   800735 <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c0>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 4d                	jmp    800527 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	74 1b                	je     8004fb <vprintfmt+0x213>
  8004e0:	0f be c0             	movsbl %al,%eax
  8004e3:	83 e8 20             	sub    $0x20,%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 10                	jbe    8004fb <vprintfmt+0x213>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 0d                	jmp    800508 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	52                   	push   %edx
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	eb 1a                	jmp    800527 <vprintfmt+0x23f>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	eb 0c                	jmp    800527 <vprintfmt+0x23f>
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800527:	83 c7 01             	add    $0x1,%edi
  80052a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052e:	0f be d0             	movsbl %al,%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	74 23                	je     800558 <vprintfmt+0x270>
  800535:	85 f6                	test   %esi,%esi
  800537:	78 a1                	js     8004da <vprintfmt+0x1f2>
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	79 9c                	jns    8004da <vprintfmt+0x1f2>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	eb 18                	jmp    800560 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 08                	jmp    800560 <vprintfmt+0x278>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	85 ff                	test   %edi,%edi
  800562:	7f e4                	jg     800548 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 a2 fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 16                	jle    800587 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 08             	lea    0x8(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x2d1>
	else if (lflag)
  800587:	85 d2                	test   %edx,%edx
  800589:	74 18                	je     8005a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c8:	0f 89 90 00 00 00    	jns    80065e <vprintfmt+0x376>
				putch('-', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	6a 2d                	push   $0x2d
  8005d4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005dc:	f7 d8                	neg    %eax
  8005de:	83 d2 00             	adc    $0x0,%edx
  8005e1:	f7 da                	neg    %edx
  8005e3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005eb:	eb 71                	jmp    80065e <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f0:	e8 7f fc ff ff       	call   800274 <getuint>
			base = 10;
  8005f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fa:	eb 62                	jmp    80065e <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ff:	e8 70 fc ff ff       	call   800274 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80060b:	51                   	push   %ecx
  80060c:	ff 75 e0             	pushl  -0x20(%ebp)
  80060f:	6a 08                	push   $0x8
  800611:	52                   	push   %edx
  800612:	50                   	push   %eax
  800613:	89 da                	mov    %ebx,%edx
  800615:	89 f0                	mov    %esi,%eax
  800617:	e8 a9 fb ff ff       	call   8001c5 <printnum>
			break;
  80061c:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800622:	e9 e7 fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 30                	push   $0x30
  80062d:	ff d6                	call   *%esi
			putch('x', putdat);
  80062f:	83 c4 08             	add    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 78                	push   $0x78
  800635:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800640:	8b 00                	mov    (%eax),%eax
  800642:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800647:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80064f:	eb 0d                	jmp    80065e <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
  800654:	e8 1b fc ff ff       	call   800274 <getuint>
			base = 16;
  800659:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065e:	83 ec 0c             	sub    $0xc,%esp
  800661:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800665:	57                   	push   %edi
  800666:	ff 75 e0             	pushl  -0x20(%ebp)
  800669:	51                   	push   %ecx
  80066a:	52                   	push   %edx
  80066b:	50                   	push   %eax
  80066c:	89 da                	mov    %ebx,%edx
  80066e:	89 f0                	mov    %esi,%eax
  800670:	e8 50 fb ff ff       	call   8001c5 <printnum>
			break;
  800675:	83 c4 20             	add    $0x20,%esp
  800678:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067b:	e9 8e fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	51                   	push   %ecx
  800685:	ff d6                	call   *%esi
			break;
  800687:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068d:	e9 7c fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	53                   	push   %ebx
  800696:	6a 25                	push   $0x25
  800698:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	eb 03                	jmp    8006a2 <vprintfmt+0x3ba>
  80069f:	83 ef 01             	sub    $0x1,%edi
  8006a2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a6:	75 f7                	jne    80069f <vprintfmt+0x3b7>
  8006a8:	e9 61 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b0:	5b                   	pop    %ebx
  8006b1:	5e                   	pop    %esi
  8006b2:	5f                   	pop    %edi
  8006b3:	5d                   	pop    %ebp
  8006b4:	c3                   	ret    

008006b5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	83 ec 18             	sub    $0x18,%esp
  8006bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006be:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d2:	85 c0                	test   %eax,%eax
  8006d4:	74 26                	je     8006fc <vsnprintf+0x47>
  8006d6:	85 d2                	test   %edx,%edx
  8006d8:	7e 22                	jle    8006fc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006da:	ff 75 14             	pushl  0x14(%ebp)
  8006dd:	ff 75 10             	pushl  0x10(%ebp)
  8006e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e3:	50                   	push   %eax
  8006e4:	68 ae 02 80 00       	push   $0x8002ae
  8006e9:	e8 fa fb ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	eb 05                	jmp    800701 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070c:	50                   	push   %eax
  80070d:	ff 75 10             	pushl  0x10(%ebp)
  800710:	ff 75 0c             	pushl  0xc(%ebp)
  800713:	ff 75 08             	pushl  0x8(%ebp)
  800716:	e8 9a ff ff ff       	call   8006b5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071b:	c9                   	leave  
  80071c:	c3                   	ret    

0080071d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	eb 03                	jmp    80072d <strlen+0x10>
		n++;
  80072a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800731:	75 f7                	jne    80072a <strlen+0xd>
		n++;
	return n;
}
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073e:	ba 00 00 00 00       	mov    $0x0,%edx
  800743:	eb 03                	jmp    800748 <strnlen+0x13>
		n++;
  800745:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800748:	39 c2                	cmp    %eax,%edx
  80074a:	74 08                	je     800754 <strnlen+0x1f>
  80074c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800750:	75 f3                	jne    800745 <strnlen+0x10>
  800752:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	53                   	push   %ebx
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800760:	89 c2                	mov    %eax,%edx
  800762:	83 c2 01             	add    $0x1,%edx
  800765:	83 c1 01             	add    $0x1,%ecx
  800768:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076f:	84 db                	test   %bl,%bl
  800771:	75 ef                	jne    800762 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800773:	5b                   	pop    %ebx
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	53                   	push   %ebx
  80077a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077d:	53                   	push   %ebx
  80077e:	e8 9a ff ff ff       	call   80071d <strlen>
  800783:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800786:	ff 75 0c             	pushl  0xc(%ebp)
  800789:	01 d8                	add    %ebx,%eax
  80078b:	50                   	push   %eax
  80078c:	e8 c5 ff ff ff       	call   800756 <strcpy>
	return dst;
}
  800791:	89 d8                	mov    %ebx,%eax
  800793:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	56                   	push   %esi
  80079c:	53                   	push   %ebx
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a3:	89 f3                	mov    %esi,%ebx
  8007a5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a8:	89 f2                	mov    %esi,%edx
  8007aa:	eb 0f                	jmp    8007bb <strncpy+0x23>
		*dst++ = *src;
  8007ac:	83 c2 01             	add    $0x1,%edx
  8007af:	0f b6 01             	movzbl (%ecx),%eax
  8007b2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bb:	39 da                	cmp    %ebx,%edx
  8007bd:	75 ed                	jne    8007ac <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bf:	89 f0                	mov    %esi,%eax
  8007c1:	5b                   	pop    %ebx
  8007c2:	5e                   	pop    %esi
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 21                	je     8007fa <strlcpy+0x35>
  8007d9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007dd:	89 f2                	mov    %esi,%edx
  8007df:	eb 09                	jmp    8007ea <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e1:	83 c2 01             	add    $0x1,%edx
  8007e4:	83 c1 01             	add    $0x1,%ecx
  8007e7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ea:	39 c2                	cmp    %eax,%edx
  8007ec:	74 09                	je     8007f7 <strlcpy+0x32>
  8007ee:	0f b6 19             	movzbl (%ecx),%ebx
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	75 ec                	jne    8007e1 <strlcpy+0x1c>
  8007f5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fa:	29 f0                	sub    %esi,%eax
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800809:	eb 06                	jmp    800811 <strcmp+0x11>
		p++, q++;
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	84 c0                	test   %al,%al
  800816:	74 04                	je     80081c <strcmp+0x1c>
  800818:	3a 02                	cmp    (%edx),%al
  80081a:	74 ef                	je     80080b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081c:	0f b6 c0             	movzbl %al,%eax
  80081f:	0f b6 12             	movzbl (%edx),%edx
  800822:	29 d0                	sub    %edx,%eax
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 c3                	mov    %eax,%ebx
  800832:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800835:	eb 06                	jmp    80083d <strncmp+0x17>
		n--, p++, q++;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083d:	39 d8                	cmp    %ebx,%eax
  80083f:	74 15                	je     800856 <strncmp+0x30>
  800841:	0f b6 08             	movzbl (%eax),%ecx
  800844:	84 c9                	test   %cl,%cl
  800846:	74 04                	je     80084c <strncmp+0x26>
  800848:	3a 0a                	cmp    (%edx),%cl
  80084a:	74 eb                	je     800837 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084c:	0f b6 00             	movzbl (%eax),%eax
  80084f:	0f b6 12             	movzbl (%edx),%edx
  800852:	29 d0                	sub    %edx,%eax
  800854:	eb 05                	jmp    80085b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085b:	5b                   	pop    %ebx
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800868:	eb 07                	jmp    800871 <strchr+0x13>
		if (*s == c)
  80086a:	38 ca                	cmp    %cl,%dl
  80086c:	74 0f                	je     80087d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086e:	83 c0 01             	add    $0x1,%eax
  800871:	0f b6 10             	movzbl (%eax),%edx
  800874:	84 d2                	test   %dl,%dl
  800876:	75 f2                	jne    80086a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800889:	eb 03                	jmp    80088e <strfind+0xf>
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800891:	38 ca                	cmp    %cl,%dl
  800893:	74 04                	je     800899 <strfind+0x1a>
  800895:	84 d2                	test   %dl,%dl
  800897:	75 f2                	jne    80088b <strfind+0xc>
			break;
	return (char *) s;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	57                   	push   %edi
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a7:	85 c9                	test   %ecx,%ecx
  8008a9:	74 36                	je     8008e1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b1:	75 28                	jne    8008db <memset+0x40>
  8008b3:	f6 c1 03             	test   $0x3,%cl
  8008b6:	75 23                	jne    8008db <memset+0x40>
		c &= 0xFF;
  8008b8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bc:	89 d3                	mov    %edx,%ebx
  8008be:	c1 e3 08             	shl    $0x8,%ebx
  8008c1:	89 d6                	mov    %edx,%esi
  8008c3:	c1 e6 18             	shl    $0x18,%esi
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	c1 e0 10             	shl    $0x10,%eax
  8008cb:	09 f0                	or     %esi,%eax
  8008cd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	09 d0                	or     %edx,%eax
  8008d3:	c1 e9 02             	shr    $0x2,%ecx
  8008d6:	fc                   	cld    
  8008d7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d9:	eb 06                	jmp    8008e1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008de:	fc                   	cld    
  8008df:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e1:	89 f8                	mov    %edi,%eax
  8008e3:	5b                   	pop    %ebx
  8008e4:	5e                   	pop    %esi
  8008e5:	5f                   	pop    %edi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f6:	39 c6                	cmp    %eax,%esi
  8008f8:	73 35                	jae    80092f <memmove+0x47>
  8008fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fd:	39 d0                	cmp    %edx,%eax
  8008ff:	73 2e                	jae    80092f <memmove+0x47>
		s += n;
		d += n;
  800901:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	89 d6                	mov    %edx,%esi
  800906:	09 fe                	or     %edi,%esi
  800908:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090e:	75 13                	jne    800923 <memmove+0x3b>
  800910:	f6 c1 03             	test   $0x3,%cl
  800913:	75 0e                	jne    800923 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800915:	83 ef 04             	sub    $0x4,%edi
  800918:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091b:	c1 e9 02             	shr    $0x2,%ecx
  80091e:	fd                   	std    
  80091f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800921:	eb 09                	jmp    80092c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800923:	83 ef 01             	sub    $0x1,%edi
  800926:	8d 72 ff             	lea    -0x1(%edx),%esi
  800929:	fd                   	std    
  80092a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092c:	fc                   	cld    
  80092d:	eb 1d                	jmp    80094c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092f:	89 f2                	mov    %esi,%edx
  800931:	09 c2                	or     %eax,%edx
  800933:	f6 c2 03             	test   $0x3,%dl
  800936:	75 0f                	jne    800947 <memmove+0x5f>
  800938:	f6 c1 03             	test   $0x3,%cl
  80093b:	75 0a                	jne    800947 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093d:	c1 e9 02             	shr    $0x2,%ecx
  800940:	89 c7                	mov    %eax,%edi
  800942:	fc                   	cld    
  800943:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800945:	eb 05                	jmp    80094c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800947:	89 c7                	mov    %eax,%edi
  800949:	fc                   	cld    
  80094a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094c:	5e                   	pop    %esi
  80094d:	5f                   	pop    %edi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800953:	ff 75 10             	pushl  0x10(%ebp)
  800956:	ff 75 0c             	pushl  0xc(%ebp)
  800959:	ff 75 08             	pushl  0x8(%ebp)
  80095c:	e8 87 ff ff ff       	call   8008e8 <memmove>
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c6                	mov    %eax,%esi
  800970:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800973:	eb 1a                	jmp    80098f <memcmp+0x2c>
		if (*s1 != *s2)
  800975:	0f b6 08             	movzbl (%eax),%ecx
  800978:	0f b6 1a             	movzbl (%edx),%ebx
  80097b:	38 d9                	cmp    %bl,%cl
  80097d:	74 0a                	je     800989 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097f:	0f b6 c1             	movzbl %cl,%eax
  800982:	0f b6 db             	movzbl %bl,%ebx
  800985:	29 d8                	sub    %ebx,%eax
  800987:	eb 0f                	jmp    800998 <memcmp+0x35>
		s1++, s2++;
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098f:	39 f0                	cmp    %esi,%eax
  800991:	75 e2                	jne    800975 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	53                   	push   %ebx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a3:	89 c1                	mov    %eax,%ecx
  8009a5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ac:	eb 0a                	jmp    8009b8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ae:	0f b6 10             	movzbl (%eax),%edx
  8009b1:	39 da                	cmp    %ebx,%edx
  8009b3:	74 07                	je     8009bc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	39 c8                	cmp    %ecx,%eax
  8009ba:	72 f2                	jb     8009ae <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	57                   	push   %edi
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cb:	eb 03                	jmp    8009d0 <strtol+0x11>
		s++;
  8009cd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d0:	0f b6 01             	movzbl (%ecx),%eax
  8009d3:	3c 20                	cmp    $0x20,%al
  8009d5:	74 f6                	je     8009cd <strtol+0xe>
  8009d7:	3c 09                	cmp    $0x9,%al
  8009d9:	74 f2                	je     8009cd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009db:	3c 2b                	cmp    $0x2b,%al
  8009dd:	75 0a                	jne    8009e9 <strtol+0x2a>
		s++;
  8009df:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e7:	eb 11                	jmp    8009fa <strtol+0x3b>
  8009e9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ee:	3c 2d                	cmp    $0x2d,%al
  8009f0:	75 08                	jne    8009fa <strtol+0x3b>
		s++, neg = 1;
  8009f2:	83 c1 01             	add    $0x1,%ecx
  8009f5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a00:	75 15                	jne    800a17 <strtol+0x58>
  800a02:	80 39 30             	cmpb   $0x30,(%ecx)
  800a05:	75 10                	jne    800a17 <strtol+0x58>
  800a07:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0b:	75 7c                	jne    800a89 <strtol+0xca>
		s += 2, base = 16;
  800a0d:	83 c1 02             	add    $0x2,%ecx
  800a10:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a15:	eb 16                	jmp    800a2d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a17:	85 db                	test   %ebx,%ebx
  800a19:	75 12                	jne    800a2d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a20:	80 39 30             	cmpb   $0x30,(%ecx)
  800a23:	75 08                	jne    800a2d <strtol+0x6e>
		s++, base = 8;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a35:	0f b6 11             	movzbl (%ecx),%edx
  800a38:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	80 fb 09             	cmp    $0x9,%bl
  800a40:	77 08                	ja     800a4a <strtol+0x8b>
			dig = *s - '0';
  800a42:	0f be d2             	movsbl %dl,%edx
  800a45:	83 ea 30             	sub    $0x30,%edx
  800a48:	eb 22                	jmp    800a6c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4d:	89 f3                	mov    %esi,%ebx
  800a4f:	80 fb 19             	cmp    $0x19,%bl
  800a52:	77 08                	ja     800a5c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a54:	0f be d2             	movsbl %dl,%edx
  800a57:	83 ea 57             	sub    $0x57,%edx
  800a5a:	eb 10                	jmp    800a6c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5f:	89 f3                	mov    %esi,%ebx
  800a61:	80 fb 19             	cmp    $0x19,%bl
  800a64:	77 16                	ja     800a7c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a66:	0f be d2             	movsbl %dl,%edx
  800a69:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6f:	7d 0b                	jge    800a7c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a71:	83 c1 01             	add    $0x1,%ecx
  800a74:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a78:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7a:	eb b9                	jmp    800a35 <strtol+0x76>

	if (endptr)
  800a7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a80:	74 0d                	je     800a8f <strtol+0xd0>
		*endptr = (char *) s;
  800a82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a85:	89 0e                	mov    %ecx,(%esi)
  800a87:	eb 06                	jmp    800a8f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a89:	85 db                	test   %ebx,%ebx
  800a8b:	74 98                	je     800a25 <strtol+0x66>
  800a8d:	eb 9e                	jmp    800a2d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8f:	89 c2                	mov    %eax,%edx
  800a91:	f7 da                	neg    %edx
  800a93:	85 ff                	test   %edi,%edi
  800a95:	0f 45 c2             	cmovne %edx,%eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	57                   	push   %edi
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aab:	8b 55 08             	mov    0x8(%ebp),%edx
  800aae:	89 c3                	mov    %eax,%ebx
  800ab0:	89 c7                	mov    %eax,%edi
  800ab2:	89 c6                	mov    %eax,%esi
  800ab4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5f                   	pop    %edi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <sys_cgetc>:

int
sys_cgetc(void)
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
  800ac6:	b8 01 00 00 00       	mov    $0x1,%eax
  800acb:	89 d1                	mov    %edx,%ecx
  800acd:	89 d3                	mov    %edx,%ebx
  800acf:	89 d7                	mov    %edx,%edi
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae8:	b8 03 00 00 00       	mov    $0x3,%eax
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	89 cb                	mov    %ecx,%ebx
  800af2:	89 cf                	mov    %ecx,%edi
  800af4:	89 ce                	mov    %ecx,%esi
  800af6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800af8:	85 c0                	test   %eax,%eax
  800afa:	7e 17                	jle    800b13 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afc:	83 ec 0c             	sub    $0xc,%esp
  800aff:	50                   	push   %eax
  800b00:	6a 03                	push   $0x3
  800b02:	68 df 29 80 00       	push   $0x8029df
  800b07:	6a 23                	push   $0x23
  800b09:	68 fc 29 80 00       	push   $0x8029fc
  800b0e:	e8 dd 17 00 00       	call   8022f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	ba 00 00 00 00       	mov    $0x0,%edx
  800b26:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2b:	89 d1                	mov    %edx,%ecx
  800b2d:	89 d3                	mov    %edx,%ebx
  800b2f:	89 d7                	mov    %edx,%edi
  800b31:	89 d6                	mov    %edx,%esi
  800b33:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <sys_yield>:

void
sys_yield(void)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b40:	ba 00 00 00 00       	mov    $0x0,%edx
  800b45:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4a:	89 d1                	mov    %edx,%ecx
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 d6                	mov    %edx,%esi
  800b52:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	be 00 00 00 00       	mov    $0x0,%esi
  800b67:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b75:	89 f7                	mov    %esi,%edi
  800b77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b79:	85 c0                	test   %eax,%eax
  800b7b:	7e 17                	jle    800b94 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	50                   	push   %eax
  800b81:	6a 04                	push   $0x4
  800b83:	68 df 29 80 00       	push   $0x8029df
  800b88:	6a 23                	push   $0x23
  800b8a:	68 fc 29 80 00       	push   $0x8029fc
  800b8f:	e8 5c 17 00 00       	call   8022f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba5:	b8 05 00 00 00       	mov    $0x5,%eax
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 17                	jle    800bd6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 05                	push   $0x5
  800bc5:	68 df 29 80 00       	push   $0x8029df
  800bca:	6a 23                	push   $0x23
  800bcc:	68 fc 29 80 00       	push   $0x8029fc
  800bd1:	e8 1a 17 00 00       	call   8022f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bec:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	89 df                	mov    %ebx,%edi
  800bf9:	89 de                	mov    %ebx,%esi
  800bfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 06                	push   $0x6
  800c07:	68 df 29 80 00       	push   $0x8029df
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 fc 29 80 00       	push   $0x8029fc
  800c13:	e8 d8 16 00 00       	call   8022f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 df                	mov    %ebx,%edi
  800c3b:	89 de                	mov    %ebx,%esi
  800c3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 17                	jle    800c5a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 08                	push   $0x8
  800c49:	68 df 29 80 00       	push   $0x8029df
  800c4e:	6a 23                	push   $0x23
  800c50:	68 fc 29 80 00       	push   $0x8029fc
  800c55:	e8 96 16 00 00       	call   8022f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	b8 09 00 00 00       	mov    $0x9,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 17                	jle    800c9c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	50                   	push   %eax
  800c89:	6a 09                	push   $0x9
  800c8b:	68 df 29 80 00       	push   $0x8029df
  800c90:	6a 23                	push   $0x23
  800c92:	68 fc 29 80 00       	push   $0x8029fc
  800c97:	e8 54 16 00 00       	call   8022f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 0a                	push   $0xa
  800ccd:	68 df 29 80 00       	push   $0x8029df
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 fc 29 80 00       	push   $0x8029fc
  800cd9:	e8 12 16 00 00       	call   8022f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cec:	be 00 00 00 00       	mov    $0x0,%esi
  800cf1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d02:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d17:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 cb                	mov    %ecx,%ebx
  800d21:	89 cf                	mov    %ecx,%edi
  800d23:	89 ce                	mov    %ecx,%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 0d                	push   $0xd
  800d31:	68 df 29 80 00       	push   $0x8029df
  800d36:	6a 23                	push   $0x23
  800d38:	68 fc 29 80 00       	push   $0x8029fc
  800d3d:	e8 ae 15 00 00       	call   8022f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	ba 00 00 00 00       	mov    $0x0,%edx
  800d55:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5a:	89 d1                	mov    %edx,%ecx
  800d5c:	89 d3                	mov    %edx,%ebx
  800d5e:	89 d7                	mov    %edx,%edi
  800d60:	89 d6                	mov    %edx,%esi
  800d62:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d73:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800d75:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800d78:	f6 c1 02             	test   $0x2,%cl
  800d7b:	74 2e                	je     800dab <pgfault+0x42>
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	c1 ea 16             	shr    $0x16,%edx
  800d82:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d89:	f6 c2 01             	test   $0x1,%dl
  800d8c:	74 1d                	je     800dab <pgfault+0x42>
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	c1 ea 0c             	shr    $0xc,%edx
  800d93:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800d9a:	f6 c3 01             	test   $0x1,%bl
  800d9d:	74 0c                	je     800dab <pgfault+0x42>
  800d9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da6:	f6 c6 08             	test   $0x8,%dh
  800da9:	75 12                	jne    800dbd <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800dab:	51                   	push   %ecx
  800dac:	68 0a 2a 80 00       	push   $0x802a0a
  800db1:	6a 1e                	push   $0x1e
  800db3:	68 23 2a 80 00       	push   $0x802a23
  800db8:	e8 33 15 00 00       	call   8022f0 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800dbd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dc2:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800dc4:	83 ec 04             	sub    $0x4,%esp
  800dc7:	6a 07                	push   $0x7
  800dc9:	68 00 f0 7f 00       	push   $0x7ff000
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 84 fd ff ff       	call   800b59 <sys_page_alloc>
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	79 12                	jns    800dee <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800ddc:	50                   	push   %eax
  800ddd:	68 2e 2a 80 00       	push   $0x802a2e
  800de2:	6a 29                	push   $0x29
  800de4:	68 23 2a 80 00       	push   $0x802a23
  800de9:	e8 02 15 00 00       	call   8022f0 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	68 00 10 00 00       	push   $0x1000
  800df6:	53                   	push   %ebx
  800df7:	68 00 f0 7f 00       	push   $0x7ff000
  800dfc:	e8 4f fb ff ff       	call   800950 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e01:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e08:	53                   	push   %ebx
  800e09:	6a 00                	push   $0x0
  800e0b:	68 00 f0 7f 00       	push   $0x7ff000
  800e10:	6a 00                	push   $0x0
  800e12:	e8 85 fd ff ff       	call   800b9c <sys_page_map>
  800e17:	83 c4 20             	add    $0x20,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 12                	jns    800e30 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800e1e:	50                   	push   %eax
  800e1f:	68 49 2a 80 00       	push   $0x802a49
  800e24:	6a 2e                	push   $0x2e
  800e26:	68 23 2a 80 00       	push   $0x802a23
  800e2b:	e8 c0 14 00 00       	call   8022f0 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800e30:	83 ec 08             	sub    $0x8,%esp
  800e33:	68 00 f0 7f 00       	push   $0x7ff000
  800e38:	6a 00                	push   $0x0
  800e3a:	e8 9f fd ff ff       	call   800bde <sys_page_unmap>
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	79 12                	jns    800e58 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800e46:	50                   	push   %eax
  800e47:	68 62 2a 80 00       	push   $0x802a62
  800e4c:	6a 31                	push   $0x31
  800e4e:	68 23 2a 80 00       	push   $0x802a23
  800e53:	e8 98 14 00 00       	call   8022f0 <_panic>

}
  800e58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e5b:	c9                   	leave  
  800e5c:	c3                   	ret    

00800e5d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800e5d:	55                   	push   %ebp
  800e5e:	89 e5                	mov    %esp,%ebp
  800e60:	57                   	push   %edi
  800e61:	56                   	push   %esi
  800e62:	53                   	push   %ebx
  800e63:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800e66:	68 69 0d 80 00       	push   $0x800d69
  800e6b:	e8 c6 14 00 00       	call   802336 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e70:	b8 07 00 00 00       	mov    $0x7,%eax
  800e75:	cd 30                	int    $0x30
  800e77:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	85 c0                	test   %eax,%eax
  800e87:	75 21                	jne    800eaa <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800e89:	e8 8d fc ff ff       	call   800b1b <sys_getenvid>
  800e8e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e93:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e96:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e9b:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea5:	e9 c9 01 00 00       	jmp    801073 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800eaa:	89 d8                	mov    %ebx,%eax
  800eac:	c1 e8 16             	shr    $0x16,%eax
  800eaf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb6:	a8 01                	test   $0x1,%al
  800eb8:	0f 84 1b 01 00 00    	je     800fd9 <fork+0x17c>
  800ebe:	89 de                	mov    %ebx,%esi
  800ec0:	c1 ee 0c             	shr    $0xc,%esi
  800ec3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eca:	a8 01                	test   $0x1,%al
  800ecc:	0f 84 07 01 00 00    	je     800fd9 <fork+0x17c>
  800ed2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ed9:	a8 04                	test   $0x4,%al
  800edb:	0f 84 f8 00 00 00    	je     800fd9 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800ee1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ee8:	f6 c4 04             	test   $0x4,%ah
  800eeb:	74 3c                	je     800f29 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800eed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ef4:	c1 e6 0c             	shl    $0xc,%esi
  800ef7:	83 ec 0c             	sub    $0xc,%esp
  800efa:	25 07 0e 00 00       	and    $0xe07,%eax
  800eff:	50                   	push   %eax
  800f00:	56                   	push   %esi
  800f01:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f04:	56                   	push   %esi
  800f05:	6a 00                	push   $0x0
  800f07:	e8 90 fc ff ff       	call   800b9c <sys_page_map>
  800f0c:	83 c4 20             	add    $0x20,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	0f 89 c2 00 00 00    	jns    800fd9 <fork+0x17c>
			panic("duppage: %e", r);
  800f17:	50                   	push   %eax
  800f18:	68 7d 2a 80 00       	push   $0x802a7d
  800f1d:	6a 48                	push   $0x48
  800f1f:	68 23 2a 80 00       	push   $0x802a23
  800f24:	e8 c7 13 00 00       	call   8022f0 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  800f29:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f30:	f6 c4 08             	test   $0x8,%ah
  800f33:	75 0b                	jne    800f40 <fork+0xe3>
  800f35:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f3c:	a8 02                	test   $0x2,%al
  800f3e:	74 6c                	je     800fac <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  800f40:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f47:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  800f4a:	83 f8 01             	cmp    $0x1,%eax
  800f4d:	19 ff                	sbb    %edi,%edi
  800f4f:	83 e7 fc             	and    $0xfffffffc,%edi
  800f52:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  800f58:	c1 e6 0c             	shl    $0xc,%esi
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f63:	56                   	push   %esi
  800f64:	6a 00                	push   $0x0
  800f66:	e8 31 fc ff ff       	call   800b9c <sys_page_map>
  800f6b:	83 c4 20             	add    $0x20,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	79 12                	jns    800f84 <fork+0x127>
			panic("duppage: %e", r);
  800f72:	50                   	push   %eax
  800f73:	68 7d 2a 80 00       	push   $0x802a7d
  800f78:	6a 50                	push   $0x50
  800f7a:	68 23 2a 80 00       	push   $0x802a23
  800f7f:	e8 6c 13 00 00       	call   8022f0 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  800f84:	83 ec 0c             	sub    $0xc,%esp
  800f87:	57                   	push   %edi
  800f88:	56                   	push   %esi
  800f89:	6a 00                	push   $0x0
  800f8b:	56                   	push   %esi
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 09 fc ff ff       	call   800b9c <sys_page_map>
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	79 3f                	jns    800fd9 <fork+0x17c>
			panic("duppage: %e", r);
  800f9a:	50                   	push   %eax
  800f9b:	68 7d 2a 80 00       	push   $0x802a7d
  800fa0:	6a 53                	push   $0x53
  800fa2:	68 23 2a 80 00       	push   $0x802a23
  800fa7:	e8 44 13 00 00       	call   8022f0 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  800fac:	c1 e6 0c             	shl    $0xc,%esi
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	6a 05                	push   $0x5
  800fb4:	56                   	push   %esi
  800fb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb8:	56                   	push   %esi
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 dc fb ff ff       	call   800b9c <sys_page_map>
  800fc0:	83 c4 20             	add    $0x20,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	79 12                	jns    800fd9 <fork+0x17c>
			panic("duppage: %e", r);
  800fc7:	50                   	push   %eax
  800fc8:	68 7d 2a 80 00       	push   $0x802a7d
  800fcd:	6a 57                	push   $0x57
  800fcf:	68 23 2a 80 00       	push   $0x802a23
  800fd4:	e8 17 13 00 00       	call   8022f0 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  800fd9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fdf:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fe5:	0f 85 bf fe ff ff    	jne    800eaa <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	6a 07                	push   $0x7
  800ff0:	68 00 f0 bf ee       	push   $0xeebff000
  800ff5:	ff 75 e0             	pushl  -0x20(%ebp)
  800ff8:	e8 5c fb ff ff       	call   800b59 <sys_page_alloc>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	74 17                	je     80101b <fork+0x1be>
		panic("sys_page_alloc Error");
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	68 89 2a 80 00       	push   $0x802a89
  80100c:	68 83 00 00 00       	push   $0x83
  801011:	68 23 2a 80 00       	push   $0x802a23
  801016:	e8 d5 12 00 00       	call   8022f0 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  80101b:	83 ec 08             	sub    $0x8,%esp
  80101e:	68 a5 23 80 00       	push   $0x8023a5
  801023:	ff 75 e0             	pushl  -0x20(%ebp)
  801026:	e8 79 fc ff ff       	call   800ca4 <sys_env_set_pgfault_upcall>
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	85 c0                	test   %eax,%eax
  801030:	79 15                	jns    801047 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801032:	50                   	push   %eax
  801033:	68 9e 2a 80 00       	push   $0x802a9e
  801038:	68 86 00 00 00       	push   $0x86
  80103d:	68 23 2a 80 00       	push   $0x802a23
  801042:	e8 a9 12 00 00       	call   8022f0 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801047:	83 ec 08             	sub    $0x8,%esp
  80104a:	6a 02                	push   $0x2
  80104c:	ff 75 e0             	pushl  -0x20(%ebp)
  80104f:	e8 cc fb ff ff       	call   800c20 <sys_env_set_status>
  801054:	83 c4 10             	add    $0x10,%esp
  801057:	85 c0                	test   %eax,%eax
  801059:	79 15                	jns    801070 <fork+0x213>
		panic("fork set status: %e", r);
  80105b:	50                   	push   %eax
  80105c:	68 b6 2a 80 00       	push   $0x802ab6
  801061:	68 89 00 00 00       	push   $0x89
  801066:	68 23 2a 80 00       	push   $0x802a23
  80106b:	e8 80 12 00 00       	call   8022f0 <_panic>
	
	return envid;
  801070:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801073:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5f                   	pop    %edi
  801079:	5d                   	pop    %ebp
  80107a:	c3                   	ret    

0080107b <sfork>:


// Challenge!
int
sfork(void)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801081:	68 ca 2a 80 00       	push   $0x802aca
  801086:	68 93 00 00 00       	push   $0x93
  80108b:	68 23 2a 80 00       	push   $0x802a23
  801090:	e8 5b 12 00 00       	call   8022f0 <_panic>

00801095 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
  80109a:	8b 75 08             	mov    0x8(%ebp),%esi
  80109d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8010a3:	85 c0                	test   %eax,%eax
  8010a5:	74 0e                	je     8010b5 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	50                   	push   %eax
  8010ab:	e8 59 fc ff ff       	call   800d09 <sys_ipc_recv>
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	eb 10                	jmp    8010c5 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8010b5:	83 ec 0c             	sub    $0xc,%esp
  8010b8:	68 00 00 c0 ee       	push   $0xeec00000
  8010bd:	e8 47 fc ff ff       	call   800d09 <sys_ipc_recv>
  8010c2:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	79 17                	jns    8010e0 <ipc_recv+0x4b>
		if(*from_env_store)
  8010c9:	83 3e 00             	cmpl   $0x0,(%esi)
  8010cc:	74 06                	je     8010d4 <ipc_recv+0x3f>
			*from_env_store = 0;
  8010ce:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8010d4:	85 db                	test   %ebx,%ebx
  8010d6:	74 2c                	je     801104 <ipc_recv+0x6f>
			*perm_store = 0;
  8010d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010de:	eb 24                	jmp    801104 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8010e0:	85 f6                	test   %esi,%esi
  8010e2:	74 0a                	je     8010ee <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8010e4:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e9:	8b 40 74             	mov    0x74(%eax),%eax
  8010ec:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8010ee:	85 db                	test   %ebx,%ebx
  8010f0:	74 0a                	je     8010fc <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8010f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010f7:	8b 40 78             	mov    0x78(%eax),%eax
  8010fa:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8010fc:	a1 08 40 80 00       	mov    0x804008,%eax
  801101:	8b 40 70             	mov    0x70(%eax),%eax
}
  801104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	8b 7d 08             	mov    0x8(%ebp),%edi
  801117:	8b 75 0c             	mov    0xc(%ebp),%esi
  80111a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80111d:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80111f:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801124:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801127:	e8 0e fa ff ff       	call   800b3a <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80112c:	ff 75 14             	pushl  0x14(%ebp)
  80112f:	53                   	push   %ebx
  801130:	56                   	push   %esi
  801131:	57                   	push   %edi
  801132:	e8 af fb ff ff       	call   800ce6 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801137:	89 c2                	mov    %eax,%edx
  801139:	f7 d2                	not    %edx
  80113b:	c1 ea 1f             	shr    $0x1f,%edx
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801144:	0f 94 c1             	sete   %cl
  801147:	09 ca                	or     %ecx,%edx
  801149:	85 c0                	test   %eax,%eax
  80114b:	0f 94 c0             	sete   %al
  80114e:	38 c2                	cmp    %al,%dl
  801150:	77 d5                	ja     801127 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801152:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801155:	5b                   	pop    %ebx
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    

0080115a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801165:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801168:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80116e:	8b 52 50             	mov    0x50(%edx),%edx
  801171:	39 ca                	cmp    %ecx,%edx
  801173:	75 0d                	jne    801182 <ipc_find_env+0x28>
			return envs[i].env_id;
  801175:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801178:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80117d:	8b 40 48             	mov    0x48(%eax),%eax
  801180:	eb 0f                	jmp    801191 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801182:	83 c0 01             	add    $0x1,%eax
  801185:	3d 00 04 00 00       	cmp    $0x400,%eax
  80118a:	75 d9                	jne    801165 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80118c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	05 00 00 00 30       	add    $0x30000000,%eax
  80119e:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c5:	89 c2                	mov    %eax,%edx
  8011c7:	c1 ea 16             	shr    $0x16,%edx
  8011ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d1:	f6 c2 01             	test   $0x1,%dl
  8011d4:	74 11                	je     8011e7 <fd_alloc+0x2d>
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 0c             	shr    $0xc,%edx
  8011db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	75 09                	jne    8011f0 <fd_alloc+0x36>
			*fd_store = fd;
  8011e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	eb 17                	jmp    801207 <fd_alloc+0x4d>
  8011f0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011fa:	75 c9                	jne    8011c5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011fc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801202:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120f:	83 f8 1f             	cmp    $0x1f,%eax
  801212:	77 36                	ja     80124a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801214:	c1 e0 0c             	shl    $0xc,%eax
  801217:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121c:	89 c2                	mov    %eax,%edx
  80121e:	c1 ea 16             	shr    $0x16,%edx
  801221:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801228:	f6 c2 01             	test   $0x1,%dl
  80122b:	74 24                	je     801251 <fd_lookup+0x48>
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	c1 ea 0c             	shr    $0xc,%edx
  801232:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	74 1a                	je     801258 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80123e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801241:	89 02                	mov    %eax,(%edx)
	return 0;
  801243:	b8 00 00 00 00       	mov    $0x0,%eax
  801248:	eb 13                	jmp    80125d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80124a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80124f:	eb 0c                	jmp    80125d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801251:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801256:	eb 05                	jmp    80125d <fd_lookup+0x54>
  801258:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801268:	ba 5c 2b 80 00       	mov    $0x802b5c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80126d:	eb 13                	jmp    801282 <dev_lookup+0x23>
  80126f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801272:	39 08                	cmp    %ecx,(%eax)
  801274:	75 0c                	jne    801282 <dev_lookup+0x23>
			*dev = devtab[i];
  801276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801279:	89 01                	mov    %eax,(%ecx)
			return 0;
  80127b:	b8 00 00 00 00       	mov    $0x0,%eax
  801280:	eb 2e                	jmp    8012b0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801282:	8b 02                	mov    (%edx),%eax
  801284:	85 c0                	test   %eax,%eax
  801286:	75 e7                	jne    80126f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801288:	a1 08 40 80 00       	mov    0x804008,%eax
  80128d:	8b 40 48             	mov    0x48(%eax),%eax
  801290:	83 ec 04             	sub    $0x4,%esp
  801293:	51                   	push   %ecx
  801294:	50                   	push   %eax
  801295:	68 e0 2a 80 00       	push   $0x802ae0
  80129a:	e8 12 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  80129f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    

008012b2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 10             	sub    $0x10,%esp
  8012ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c3:	50                   	push   %eax
  8012c4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ca:	c1 e8 0c             	shr    $0xc,%eax
  8012cd:	50                   	push   %eax
  8012ce:	e8 36 ff ff ff       	call   801209 <fd_lookup>
  8012d3:	83 c4 08             	add    $0x8,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 05                	js     8012df <fd_close+0x2d>
	    || fd != fd2)
  8012da:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012dd:	74 0c                	je     8012eb <fd_close+0x39>
		return (must_exist ? r : 0);
  8012df:	84 db                	test   %bl,%bl
  8012e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e6:	0f 44 c2             	cmove  %edx,%eax
  8012e9:	eb 41                	jmp    80132c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f1:	50                   	push   %eax
  8012f2:	ff 36                	pushl  (%esi)
  8012f4:	e8 66 ff ff ff       	call   80125f <dev_lookup>
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 1a                	js     80131c <fd_close+0x6a>
		if (dev->dev_close)
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801308:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80130d:	85 c0                	test   %eax,%eax
  80130f:	74 0b                	je     80131c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	56                   	push   %esi
  801315:	ff d0                	call   *%eax
  801317:	89 c3                	mov    %eax,%ebx
  801319:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	56                   	push   %esi
  801320:	6a 00                	push   $0x0
  801322:	e8 b7 f8 ff ff       	call   800bde <sys_page_unmap>
	return r;
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	89 d8                	mov    %ebx,%eax
}
  80132c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801339:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133c:	50                   	push   %eax
  80133d:	ff 75 08             	pushl  0x8(%ebp)
  801340:	e8 c4 fe ff ff       	call   801209 <fd_lookup>
  801345:	83 c4 08             	add    $0x8,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 10                	js     80135c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80134c:	83 ec 08             	sub    $0x8,%esp
  80134f:	6a 01                	push   $0x1
  801351:	ff 75 f4             	pushl  -0xc(%ebp)
  801354:	e8 59 ff ff ff       	call   8012b2 <fd_close>
  801359:	83 c4 10             	add    $0x10,%esp
}
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    

0080135e <close_all>:

void
close_all(void)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	53                   	push   %ebx
  801362:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801365:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	53                   	push   %ebx
  80136e:	e8 c0 ff ff ff       	call   801333 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801373:	83 c3 01             	add    $0x1,%ebx
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	83 fb 20             	cmp    $0x20,%ebx
  80137c:	75 ec                	jne    80136a <close_all+0xc>
		close(i);
}
  80137e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801381:	c9                   	leave  
  801382:	c3                   	ret    

00801383 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801383:	55                   	push   %ebp
  801384:	89 e5                	mov    %esp,%ebp
  801386:	57                   	push   %edi
  801387:	56                   	push   %esi
  801388:	53                   	push   %ebx
  801389:	83 ec 2c             	sub    $0x2c,%esp
  80138c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80138f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801392:	50                   	push   %eax
  801393:	ff 75 08             	pushl  0x8(%ebp)
  801396:	e8 6e fe ff ff       	call   801209 <fd_lookup>
  80139b:	83 c4 08             	add    $0x8,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	0f 88 c1 00 00 00    	js     801467 <dup+0xe4>
		return r;
	close(newfdnum);
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	56                   	push   %esi
  8013aa:	e8 84 ff ff ff       	call   801333 <close>

	newfd = INDEX2FD(newfdnum);
  8013af:	89 f3                	mov    %esi,%ebx
  8013b1:	c1 e3 0c             	shl    $0xc,%ebx
  8013b4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013ba:	83 c4 04             	add    $0x4,%esp
  8013bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013c0:	e8 de fd ff ff       	call   8011a3 <fd2data>
  8013c5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013c7:	89 1c 24             	mov    %ebx,(%esp)
  8013ca:	e8 d4 fd ff ff       	call   8011a3 <fd2data>
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	c1 e8 16             	shr    $0x16,%eax
  8013da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e1:	a8 01                	test   $0x1,%al
  8013e3:	74 37                	je     80141c <dup+0x99>
  8013e5:	89 f8                	mov    %edi,%eax
  8013e7:	c1 e8 0c             	shr    $0xc,%eax
  8013ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f1:	f6 c2 01             	test   $0x1,%dl
  8013f4:	74 26                	je     80141c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013fd:	83 ec 0c             	sub    $0xc,%esp
  801400:	25 07 0e 00 00       	and    $0xe07,%eax
  801405:	50                   	push   %eax
  801406:	ff 75 d4             	pushl  -0x2c(%ebp)
  801409:	6a 00                	push   $0x0
  80140b:	57                   	push   %edi
  80140c:	6a 00                	push   $0x0
  80140e:	e8 89 f7 ff ff       	call   800b9c <sys_page_map>
  801413:	89 c7                	mov    %eax,%edi
  801415:	83 c4 20             	add    $0x20,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 2e                	js     80144a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80141f:	89 d0                	mov    %edx,%eax
  801421:	c1 e8 0c             	shr    $0xc,%eax
  801424:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	25 07 0e 00 00       	and    $0xe07,%eax
  801433:	50                   	push   %eax
  801434:	53                   	push   %ebx
  801435:	6a 00                	push   $0x0
  801437:	52                   	push   %edx
  801438:	6a 00                	push   $0x0
  80143a:	e8 5d f7 ff ff       	call   800b9c <sys_page_map>
  80143f:	89 c7                	mov    %eax,%edi
  801441:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801444:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801446:	85 ff                	test   %edi,%edi
  801448:	79 1d                	jns    801467 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	53                   	push   %ebx
  80144e:	6a 00                	push   $0x0
  801450:	e8 89 f7 ff ff       	call   800bde <sys_page_unmap>
	sys_page_unmap(0, nva);
  801455:	83 c4 08             	add    $0x8,%esp
  801458:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145b:	6a 00                	push   $0x0
  80145d:	e8 7c f7 ff ff       	call   800bde <sys_page_unmap>
	return r;
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	89 f8                	mov    %edi,%eax
}
  801467:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5f                   	pop    %edi
  80146d:	5d                   	pop    %ebp
  80146e:	c3                   	ret    

0080146f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	53                   	push   %ebx
  801473:	83 ec 14             	sub    $0x14,%esp
  801476:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801479:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	53                   	push   %ebx
  80147e:	e8 86 fd ff ff       	call   801209 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	89 c2                	mov    %eax,%edx
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 6d                	js     8014f9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148c:	83 ec 08             	sub    $0x8,%esp
  80148f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801496:	ff 30                	pushl  (%eax)
  801498:	e8 c2 fd ff ff       	call   80125f <dev_lookup>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	78 4c                	js     8014f0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a7:	8b 42 08             	mov    0x8(%edx),%eax
  8014aa:	83 e0 03             	and    $0x3,%eax
  8014ad:	83 f8 01             	cmp    $0x1,%eax
  8014b0:	75 21                	jne    8014d3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	53                   	push   %ebx
  8014be:	50                   	push   %eax
  8014bf:	68 21 2b 80 00       	push   $0x802b21
  8014c4:	e8 e8 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014d1:	eb 26                	jmp    8014f9 <read+0x8a>
	}
	if (!dev->dev_read)
  8014d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d6:	8b 40 08             	mov    0x8(%eax),%eax
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	74 17                	je     8014f4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014dd:	83 ec 04             	sub    $0x4,%esp
  8014e0:	ff 75 10             	pushl  0x10(%ebp)
  8014e3:	ff 75 0c             	pushl  0xc(%ebp)
  8014e6:	52                   	push   %edx
  8014e7:	ff d0                	call   *%eax
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	eb 09                	jmp    8014f9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	eb 05                	jmp    8014f9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014f9:	89 d0                	mov    %edx,%eax
  8014fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	53                   	push   %ebx
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80150f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801514:	eb 21                	jmp    801537 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801516:	83 ec 04             	sub    $0x4,%esp
  801519:	89 f0                	mov    %esi,%eax
  80151b:	29 d8                	sub    %ebx,%eax
  80151d:	50                   	push   %eax
  80151e:	89 d8                	mov    %ebx,%eax
  801520:	03 45 0c             	add    0xc(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	57                   	push   %edi
  801525:	e8 45 ff ff ff       	call   80146f <read>
		if (m < 0)
  80152a:	83 c4 10             	add    $0x10,%esp
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 10                	js     801541 <readn+0x41>
			return m;
		if (m == 0)
  801531:	85 c0                	test   %eax,%eax
  801533:	74 0a                	je     80153f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801535:	01 c3                	add    %eax,%ebx
  801537:	39 f3                	cmp    %esi,%ebx
  801539:	72 db                	jb     801516 <readn+0x16>
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	eb 02                	jmp    801541 <readn+0x41>
  80153f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801541:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801544:	5b                   	pop    %ebx
  801545:	5e                   	pop    %esi
  801546:	5f                   	pop    %edi
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 14             	sub    $0x14,%esp
  801550:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801553:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	53                   	push   %ebx
  801558:	e8 ac fc ff ff       	call   801209 <fd_lookup>
  80155d:	83 c4 08             	add    $0x8,%esp
  801560:	89 c2                	mov    %eax,%edx
  801562:	85 c0                	test   %eax,%eax
  801564:	78 68                	js     8015ce <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801566:	83 ec 08             	sub    $0x8,%esp
  801569:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801570:	ff 30                	pushl  (%eax)
  801572:	e8 e8 fc ff ff       	call   80125f <dev_lookup>
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 47                	js     8015c5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80157e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801581:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801585:	75 21                	jne    8015a8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801587:	a1 08 40 80 00       	mov    0x804008,%eax
  80158c:	8b 40 48             	mov    0x48(%eax),%eax
  80158f:	83 ec 04             	sub    $0x4,%esp
  801592:	53                   	push   %ebx
  801593:	50                   	push   %eax
  801594:	68 3d 2b 80 00       	push   $0x802b3d
  801599:	e8 13 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015a6:	eb 26                	jmp    8015ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ae:	85 d2                	test   %edx,%edx
  8015b0:	74 17                	je     8015c9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	ff 75 10             	pushl  0x10(%ebp)
  8015b8:	ff 75 0c             	pushl  0xc(%ebp)
  8015bb:	50                   	push   %eax
  8015bc:	ff d2                	call   *%edx
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	eb 09                	jmp    8015ce <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	eb 05                	jmp    8015ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015ce:	89 d0                	mov    %edx,%eax
  8015d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    

008015d5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015de:	50                   	push   %eax
  8015df:	ff 75 08             	pushl  0x8(%ebp)
  8015e2:	e8 22 fc ff ff       	call   801209 <fd_lookup>
  8015e7:	83 c4 08             	add    $0x8,%esp
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 0e                	js     8015fc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	53                   	push   %ebx
  801602:	83 ec 14             	sub    $0x14,%esp
  801605:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801608:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	53                   	push   %ebx
  80160d:	e8 f7 fb ff ff       	call   801209 <fd_lookup>
  801612:	83 c4 08             	add    $0x8,%esp
  801615:	89 c2                	mov    %eax,%edx
  801617:	85 c0                	test   %eax,%eax
  801619:	78 65                	js     801680 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801625:	ff 30                	pushl  (%eax)
  801627:	e8 33 fc ff ff       	call   80125f <dev_lookup>
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 44                	js     801677 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801633:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801636:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80163a:	75 21                	jne    80165d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80163c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801641:	8b 40 48             	mov    0x48(%eax),%eax
  801644:	83 ec 04             	sub    $0x4,%esp
  801647:	53                   	push   %ebx
  801648:	50                   	push   %eax
  801649:	68 00 2b 80 00       	push   $0x802b00
  80164e:	e8 5e eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80165b:	eb 23                	jmp    801680 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80165d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801660:	8b 52 18             	mov    0x18(%edx),%edx
  801663:	85 d2                	test   %edx,%edx
  801665:	74 14                	je     80167b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	ff 75 0c             	pushl  0xc(%ebp)
  80166d:	50                   	push   %eax
  80166e:	ff d2                	call   *%edx
  801670:	89 c2                	mov    %eax,%edx
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	eb 09                	jmp    801680 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801677:	89 c2                	mov    %eax,%edx
  801679:	eb 05                	jmp    801680 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80167b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801680:	89 d0                	mov    %edx,%eax
  801682:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 14             	sub    $0x14,%esp
  80168e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801694:	50                   	push   %eax
  801695:	ff 75 08             	pushl  0x8(%ebp)
  801698:	e8 6c fb ff ff       	call   801209 <fd_lookup>
  80169d:	83 c4 08             	add    $0x8,%esp
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 58                	js     8016fe <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b0:	ff 30                	pushl  (%eax)
  8016b2:	e8 a8 fb ff ff       	call   80125f <dev_lookup>
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 37                	js     8016f5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c5:	74 32                	je     8016f9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d1:	00 00 00 
	stat->st_isdir = 0;
  8016d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016db:	00 00 00 
	stat->st_dev = dev;
  8016de:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	53                   	push   %ebx
  8016e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8016eb:	ff 50 14             	call   *0x14(%eax)
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	eb 09                	jmp    8016fe <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f5:	89 c2                	mov    %eax,%edx
  8016f7:	eb 05                	jmp    8016fe <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016fe:	89 d0                	mov    %edx,%eax
  801700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801703:	c9                   	leave  
  801704:	c3                   	ret    

00801705 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	6a 00                	push   $0x0
  80170f:	ff 75 08             	pushl  0x8(%ebp)
  801712:	e8 ef 01 00 00       	call   801906 <open>
  801717:	89 c3                	mov    %eax,%ebx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 1b                	js     80173b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	50                   	push   %eax
  801727:	e8 5b ff ff ff       	call   801687 <fstat>
  80172c:	89 c6                	mov    %eax,%esi
	close(fd);
  80172e:	89 1c 24             	mov    %ebx,(%esp)
  801731:	e8 fd fb ff ff       	call   801333 <close>
	return r;
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	89 f0                	mov    %esi,%eax
}
  80173b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173e:	5b                   	pop    %ebx
  80173f:	5e                   	pop    %esi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	89 c6                	mov    %eax,%esi
  801749:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80174b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801752:	75 12                	jne    801766 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801754:	83 ec 0c             	sub    $0xc,%esp
  801757:	6a 01                	push   $0x1
  801759:	e8 fc f9 ff ff       	call   80115a <ipc_find_env>
  80175e:	a3 00 40 80 00       	mov    %eax,0x804000
  801763:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801766:	6a 07                	push   $0x7
  801768:	68 00 50 80 00       	push   $0x805000
  80176d:	56                   	push   %esi
  80176e:	ff 35 00 40 80 00    	pushl  0x804000
  801774:	e8 92 f9 ff ff       	call   80110b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801779:	83 c4 0c             	add    $0xc,%esp
  80177c:	6a 00                	push   $0x0
  80177e:	53                   	push   %ebx
  80177f:	6a 00                	push   $0x0
  801781:	e8 0f f9 ff ff       	call   801095 <ipc_recv>
}
  801786:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	8b 40 0c             	mov    0xc(%eax),%eax
  801799:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80179e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b0:	e8 8d ff ff ff       	call   801742 <fsipc>
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8017d2:	e8 6b ff ff ff       	call   801742 <fsipc>
}
  8017d7:	c9                   	leave  
  8017d8:	c3                   	ret    

008017d9 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 04             	sub    $0x4,%esp
  8017e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f8:	e8 45 ff ff ff       	call   801742 <fsipc>
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 2c                	js     80182d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	68 00 50 80 00       	push   $0x805000
  801809:	53                   	push   %ebx
  80180a:	e8 47 ef ff ff       	call   800756 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180f:	a1 80 50 80 00       	mov    0x805080,%eax
  801814:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80181a:	a1 84 50 80 00       	mov    0x805084,%eax
  80181f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80182d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	53                   	push   %ebx
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80183c:	8b 55 08             	mov    0x8(%ebp),%edx
  80183f:	8b 52 0c             	mov    0xc(%edx),%edx
  801842:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801848:	a3 04 50 80 00       	mov    %eax,0x805004
  80184d:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801852:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801857:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80185a:	53                   	push   %ebx
  80185b:	ff 75 0c             	pushl  0xc(%ebp)
  80185e:	68 08 50 80 00       	push   $0x805008
  801863:	e8 80 f0 ff ff       	call   8008e8 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801868:	ba 00 00 00 00       	mov    $0x0,%edx
  80186d:	b8 04 00 00 00       	mov    $0x4,%eax
  801872:	e8 cb fe ff ff       	call   801742 <fsipc>
  801877:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80187a:	85 c0                	test   %eax,%eax
  80187c:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  80187f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	56                   	push   %esi
  801888:	53                   	push   %ebx
  801889:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	8b 40 0c             	mov    0xc(%eax),%eax
  801892:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801897:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a7:	e8 96 fe ff ff       	call   801742 <fsipc>
  8018ac:	89 c3                	mov    %eax,%ebx
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 4b                	js     8018fd <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018b2:	39 c6                	cmp    %eax,%esi
  8018b4:	73 16                	jae    8018cc <devfile_read+0x48>
  8018b6:	68 70 2b 80 00       	push   $0x802b70
  8018bb:	68 77 2b 80 00       	push   $0x802b77
  8018c0:	6a 7c                	push   $0x7c
  8018c2:	68 8c 2b 80 00       	push   $0x802b8c
  8018c7:	e8 24 0a 00 00       	call   8022f0 <_panic>
	assert(r <= PGSIZE);
  8018cc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d1:	7e 16                	jle    8018e9 <devfile_read+0x65>
  8018d3:	68 97 2b 80 00       	push   $0x802b97
  8018d8:	68 77 2b 80 00       	push   $0x802b77
  8018dd:	6a 7d                	push   $0x7d
  8018df:	68 8c 2b 80 00       	push   $0x802b8c
  8018e4:	e8 07 0a 00 00       	call   8022f0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018e9:	83 ec 04             	sub    $0x4,%esp
  8018ec:	50                   	push   %eax
  8018ed:	68 00 50 80 00       	push   $0x805000
  8018f2:	ff 75 0c             	pushl  0xc(%ebp)
  8018f5:	e8 ee ef ff ff       	call   8008e8 <memmove>
	return r;
  8018fa:	83 c4 10             	add    $0x10,%esp
}
  8018fd:	89 d8                	mov    %ebx,%eax
  8018ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	53                   	push   %ebx
  80190a:	83 ec 20             	sub    $0x20,%esp
  80190d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801910:	53                   	push   %ebx
  801911:	e8 07 ee ff ff       	call   80071d <strlen>
  801916:	83 c4 10             	add    $0x10,%esp
  801919:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80191e:	7f 67                	jg     801987 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801920:	83 ec 0c             	sub    $0xc,%esp
  801923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801926:	50                   	push   %eax
  801927:	e8 8e f8 ff ff       	call   8011ba <fd_alloc>
  80192c:	83 c4 10             	add    $0x10,%esp
		return r;
  80192f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801931:	85 c0                	test   %eax,%eax
  801933:	78 57                	js     80198c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	53                   	push   %ebx
  801939:	68 00 50 80 00       	push   $0x805000
  80193e:	e8 13 ee ff ff       	call   800756 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801943:	8b 45 0c             	mov    0xc(%ebp),%eax
  801946:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80194b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194e:	b8 01 00 00 00       	mov    $0x1,%eax
  801953:	e8 ea fd ff ff       	call   801742 <fsipc>
  801958:	89 c3                	mov    %eax,%ebx
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	85 c0                	test   %eax,%eax
  80195f:	79 14                	jns    801975 <open+0x6f>
		fd_close(fd, 0);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	6a 00                	push   $0x0
  801966:	ff 75 f4             	pushl  -0xc(%ebp)
  801969:	e8 44 f9 ff ff       	call   8012b2 <fd_close>
		return r;
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	89 da                	mov    %ebx,%edx
  801973:	eb 17                	jmp    80198c <open+0x86>
	}

	return fd2num(fd);
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	ff 75 f4             	pushl  -0xc(%ebp)
  80197b:	e8 13 f8 ff ff       	call   801193 <fd2num>
  801980:	89 c2                	mov    %eax,%edx
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	eb 05                	jmp    80198c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801987:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80198c:	89 d0                	mov    %edx,%eax
  80198e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801991:	c9                   	leave  
  801992:	c3                   	ret    

00801993 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801999:	ba 00 00 00 00       	mov    $0x0,%edx
  80199e:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a3:	e8 9a fd ff ff       	call   801742 <fsipc>
}
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	56                   	push   %esi
  8019ae:	53                   	push   %ebx
  8019af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	ff 75 08             	pushl  0x8(%ebp)
  8019b8:	e8 e6 f7 ff ff       	call   8011a3 <fd2data>
  8019bd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019bf:	83 c4 08             	add    $0x8,%esp
  8019c2:	68 a3 2b 80 00       	push   $0x802ba3
  8019c7:	53                   	push   %ebx
  8019c8:	e8 89 ed ff ff       	call   800756 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019cd:	8b 46 04             	mov    0x4(%esi),%eax
  8019d0:	2b 06                	sub    (%esi),%eax
  8019d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019df:	00 00 00 
	stat->st_dev = &devpipe;
  8019e2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019e9:	30 80 00 
	return 0;
}
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	53                   	push   %ebx
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a02:	53                   	push   %ebx
  801a03:	6a 00                	push   $0x0
  801a05:	e8 d4 f1 ff ff       	call   800bde <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a0a:	89 1c 24             	mov    %ebx,(%esp)
  801a0d:	e8 91 f7 ff ff       	call   8011a3 <fd2data>
  801a12:	83 c4 08             	add    $0x8,%esp
  801a15:	50                   	push   %eax
  801a16:	6a 00                	push   $0x0
  801a18:	e8 c1 f1 ff ff       	call   800bde <sys_page_unmap>
}
  801a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	57                   	push   %edi
  801a26:	56                   	push   %esi
  801a27:	53                   	push   %ebx
  801a28:	83 ec 1c             	sub    $0x1c,%esp
  801a2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a2e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a30:	a1 08 40 80 00       	mov    0x804008,%eax
  801a35:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a3e:	e8 89 09 00 00       	call   8023cc <pageref>
  801a43:	89 c3                	mov    %eax,%ebx
  801a45:	89 3c 24             	mov    %edi,(%esp)
  801a48:	e8 7f 09 00 00       	call   8023cc <pageref>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	39 c3                	cmp    %eax,%ebx
  801a52:	0f 94 c1             	sete   %cl
  801a55:	0f b6 c9             	movzbl %cl,%ecx
  801a58:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a5b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a61:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a64:	39 ce                	cmp    %ecx,%esi
  801a66:	74 1b                	je     801a83 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a68:	39 c3                	cmp    %eax,%ebx
  801a6a:	75 c4                	jne    801a30 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a6c:	8b 42 58             	mov    0x58(%edx),%eax
  801a6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a72:	50                   	push   %eax
  801a73:	56                   	push   %esi
  801a74:	68 aa 2b 80 00       	push   $0x802baa
  801a79:	e8 33 e7 ff ff       	call   8001b1 <cprintf>
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	eb ad                	jmp    801a30 <_pipeisclosed+0xe>
	}
}
  801a83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a89:	5b                   	pop    %ebx
  801a8a:	5e                   	pop    %esi
  801a8b:	5f                   	pop    %edi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	57                   	push   %edi
  801a92:	56                   	push   %esi
  801a93:	53                   	push   %ebx
  801a94:	83 ec 28             	sub    $0x28,%esp
  801a97:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a9a:	56                   	push   %esi
  801a9b:	e8 03 f7 ff ff       	call   8011a3 <fd2data>
  801aa0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	bf 00 00 00 00       	mov    $0x0,%edi
  801aaa:	eb 4b                	jmp    801af7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aac:	89 da                	mov    %ebx,%edx
  801aae:	89 f0                	mov    %esi,%eax
  801ab0:	e8 6d ff ff ff       	call   801a22 <_pipeisclosed>
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	75 48                	jne    801b01 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ab9:	e8 7c f0 ff ff       	call   800b3a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801abe:	8b 43 04             	mov    0x4(%ebx),%eax
  801ac1:	8b 0b                	mov    (%ebx),%ecx
  801ac3:	8d 51 20             	lea    0x20(%ecx),%edx
  801ac6:	39 d0                	cmp    %edx,%eax
  801ac8:	73 e2                	jae    801aac <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ad1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ad4:	89 c2                	mov    %eax,%edx
  801ad6:	c1 fa 1f             	sar    $0x1f,%edx
  801ad9:	89 d1                	mov    %edx,%ecx
  801adb:	c1 e9 1b             	shr    $0x1b,%ecx
  801ade:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ae1:	83 e2 1f             	and    $0x1f,%edx
  801ae4:	29 ca                	sub    %ecx,%edx
  801ae6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aee:	83 c0 01             	add    $0x1,%eax
  801af1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af4:	83 c7 01             	add    $0x1,%edi
  801af7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801afa:	75 c2                	jne    801abe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801afc:	8b 45 10             	mov    0x10(%ebp),%eax
  801aff:	eb 05                	jmp    801b06 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b01:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5e                   	pop    %esi
  801b0b:	5f                   	pop    %edi
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	57                   	push   %edi
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	83 ec 18             	sub    $0x18,%esp
  801b17:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b1a:	57                   	push   %edi
  801b1b:	e8 83 f6 ff ff       	call   8011a3 <fd2data>
  801b20:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b22:	83 c4 10             	add    $0x10,%esp
  801b25:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b2a:	eb 3d                	jmp    801b69 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b2c:	85 db                	test   %ebx,%ebx
  801b2e:	74 04                	je     801b34 <devpipe_read+0x26>
				return i;
  801b30:	89 d8                	mov    %ebx,%eax
  801b32:	eb 44                	jmp    801b78 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b34:	89 f2                	mov    %esi,%edx
  801b36:	89 f8                	mov    %edi,%eax
  801b38:	e8 e5 fe ff ff       	call   801a22 <_pipeisclosed>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	75 32                	jne    801b73 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b41:	e8 f4 ef ff ff       	call   800b3a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b46:	8b 06                	mov    (%esi),%eax
  801b48:	3b 46 04             	cmp    0x4(%esi),%eax
  801b4b:	74 df                	je     801b2c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b4d:	99                   	cltd   
  801b4e:	c1 ea 1b             	shr    $0x1b,%edx
  801b51:	01 d0                	add    %edx,%eax
  801b53:	83 e0 1f             	and    $0x1f,%eax
  801b56:	29 d0                	sub    %edx,%eax
  801b58:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b60:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b63:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b66:	83 c3 01             	add    $0x1,%ebx
  801b69:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b6c:	75 d8                	jne    801b46 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b71:	eb 05                	jmp    801b78 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b8b:	50                   	push   %eax
  801b8c:	e8 29 f6 ff ff       	call   8011ba <fd_alloc>
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	89 c2                	mov    %eax,%edx
  801b96:	85 c0                	test   %eax,%eax
  801b98:	0f 88 2c 01 00 00    	js     801cca <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	68 07 04 00 00       	push   $0x407
  801ba6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ba9:	6a 00                	push   $0x0
  801bab:	e8 a9 ef ff ff       	call   800b59 <sys_page_alloc>
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	89 c2                	mov    %eax,%edx
  801bb5:	85 c0                	test   %eax,%eax
  801bb7:	0f 88 0d 01 00 00    	js     801cca <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bc3:	50                   	push   %eax
  801bc4:	e8 f1 f5 ff ff       	call   8011ba <fd_alloc>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	0f 88 e2 00 00 00    	js     801cb8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bd6:	83 ec 04             	sub    $0x4,%esp
  801bd9:	68 07 04 00 00       	push   $0x407
  801bde:	ff 75 f0             	pushl  -0x10(%ebp)
  801be1:	6a 00                	push   $0x0
  801be3:	e8 71 ef ff ff       	call   800b59 <sys_page_alloc>
  801be8:	89 c3                	mov    %eax,%ebx
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	0f 88 c3 00 00 00    	js     801cb8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bf5:	83 ec 0c             	sub    $0xc,%esp
  801bf8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfb:	e8 a3 f5 ff ff       	call   8011a3 <fd2data>
  801c00:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c02:	83 c4 0c             	add    $0xc,%esp
  801c05:	68 07 04 00 00       	push   $0x407
  801c0a:	50                   	push   %eax
  801c0b:	6a 00                	push   $0x0
  801c0d:	e8 47 ef ff ff       	call   800b59 <sys_page_alloc>
  801c12:	89 c3                	mov    %eax,%ebx
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	85 c0                	test   %eax,%eax
  801c19:	0f 88 89 00 00 00    	js     801ca8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1f:	83 ec 0c             	sub    $0xc,%esp
  801c22:	ff 75 f0             	pushl  -0x10(%ebp)
  801c25:	e8 79 f5 ff ff       	call   8011a3 <fd2data>
  801c2a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c31:	50                   	push   %eax
  801c32:	6a 00                	push   $0x0
  801c34:	56                   	push   %esi
  801c35:	6a 00                	push   $0x0
  801c37:	e8 60 ef ff ff       	call   800b9c <sys_page_map>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	83 c4 20             	add    $0x20,%esp
  801c41:	85 c0                	test   %eax,%eax
  801c43:	78 55                	js     801c9a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c5a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c63:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	ff 75 f4             	pushl  -0xc(%ebp)
  801c75:	e8 19 f5 ff ff       	call   801193 <fd2num>
  801c7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c7f:	83 c4 04             	add    $0x4,%esp
  801c82:	ff 75 f0             	pushl  -0x10(%ebp)
  801c85:	e8 09 f5 ff ff       	call   801193 <fd2num>
  801c8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	ba 00 00 00 00       	mov    $0x0,%edx
  801c98:	eb 30                	jmp    801cca <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c9a:	83 ec 08             	sub    $0x8,%esp
  801c9d:	56                   	push   %esi
  801c9e:	6a 00                	push   $0x0
  801ca0:	e8 39 ef ff ff       	call   800bde <sys_page_unmap>
  801ca5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ca8:	83 ec 08             	sub    $0x8,%esp
  801cab:	ff 75 f0             	pushl  -0x10(%ebp)
  801cae:	6a 00                	push   $0x0
  801cb0:	e8 29 ef ff ff       	call   800bde <sys_page_unmap>
  801cb5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cb8:	83 ec 08             	sub    $0x8,%esp
  801cbb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbe:	6a 00                	push   $0x0
  801cc0:	e8 19 ef ff ff       	call   800bde <sys_page_unmap>
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    

00801cd3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdc:	50                   	push   %eax
  801cdd:	ff 75 08             	pushl  0x8(%ebp)
  801ce0:	e8 24 f5 ff ff       	call   801209 <fd_lookup>
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	85 c0                	test   %eax,%eax
  801cea:	78 18                	js     801d04 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cec:	83 ec 0c             	sub    $0xc,%esp
  801cef:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf2:	e8 ac f4 ff ff       	call   8011a3 <fd2data>
	return _pipeisclosed(fd, p);
  801cf7:	89 c2                	mov    %eax,%edx
  801cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfc:	e8 21 fd ff ff       	call   801a22 <_pipeisclosed>
  801d01:	83 c4 10             	add    $0x10,%esp
}
  801d04:	c9                   	leave  
  801d05:	c3                   	ret    

00801d06 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d0c:	68 c2 2b 80 00       	push   $0x802bc2
  801d11:	ff 75 0c             	pushl  0xc(%ebp)
  801d14:	e8 3d ea ff ff       	call   800756 <strcpy>
	return 0;
}
  801d19:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1e:	c9                   	leave  
  801d1f:	c3                   	ret    

00801d20 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	53                   	push   %ebx
  801d24:	83 ec 10             	sub    $0x10,%esp
  801d27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d2a:	53                   	push   %ebx
  801d2b:	e8 9c 06 00 00       	call   8023cc <pageref>
  801d30:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d33:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d38:	83 f8 01             	cmp    $0x1,%eax
  801d3b:	75 10                	jne    801d4d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d3d:	83 ec 0c             	sub    $0xc,%esp
  801d40:	ff 73 0c             	pushl  0xc(%ebx)
  801d43:	e8 c0 02 00 00       	call   802008 <nsipc_close>
  801d48:	89 c2                	mov    %eax,%edx
  801d4a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d4d:	89 d0                	mov    %edx,%eax
  801d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d5a:	6a 00                	push   $0x0
  801d5c:	ff 75 10             	pushl  0x10(%ebp)
  801d5f:	ff 75 0c             	pushl  0xc(%ebp)
  801d62:	8b 45 08             	mov    0x8(%ebp),%eax
  801d65:	ff 70 0c             	pushl  0xc(%eax)
  801d68:	e8 78 03 00 00       	call   8020e5 <nsipc_send>
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d75:	6a 00                	push   $0x0
  801d77:	ff 75 10             	pushl  0x10(%ebp)
  801d7a:	ff 75 0c             	pushl  0xc(%ebp)
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	ff 70 0c             	pushl  0xc(%eax)
  801d83:	e8 f1 02 00 00       	call   802079 <nsipc_recv>
}
  801d88:	c9                   	leave  
  801d89:	c3                   	ret    

00801d8a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d8a:	55                   	push   %ebp
  801d8b:	89 e5                	mov    %esp,%ebp
  801d8d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d90:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d93:	52                   	push   %edx
  801d94:	50                   	push   %eax
  801d95:	e8 6f f4 ff ff       	call   801209 <fd_lookup>
  801d9a:	83 c4 10             	add    $0x10,%esp
  801d9d:	85 c0                	test   %eax,%eax
  801d9f:	78 17                	js     801db8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da4:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801daa:	39 08                	cmp    %ecx,(%eax)
  801dac:	75 05                	jne    801db3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801dae:	8b 40 0c             	mov    0xc(%eax),%eax
  801db1:	eb 05                	jmp    801db8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801db3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801db8:	c9                   	leave  
  801db9:	c3                   	ret    

00801dba <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	56                   	push   %esi
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 1c             	sub    $0x1c,%esp
  801dc2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801dc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dc7:	50                   	push   %eax
  801dc8:	e8 ed f3 ff ff       	call   8011ba <fd_alloc>
  801dcd:	89 c3                	mov    %eax,%ebx
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	78 1b                	js     801df1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801dd6:	83 ec 04             	sub    $0x4,%esp
  801dd9:	68 07 04 00 00       	push   $0x407
  801dde:	ff 75 f4             	pushl  -0xc(%ebp)
  801de1:	6a 00                	push   $0x0
  801de3:	e8 71 ed ff ff       	call   800b59 <sys_page_alloc>
  801de8:	89 c3                	mov    %eax,%ebx
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	85 c0                	test   %eax,%eax
  801def:	79 10                	jns    801e01 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	56                   	push   %esi
  801df5:	e8 0e 02 00 00       	call   802008 <nsipc_close>
		return r;
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	89 d8                	mov    %ebx,%eax
  801dff:	eb 24                	jmp    801e25 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e01:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e16:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	50                   	push   %eax
  801e1d:	e8 71 f3 ff ff       	call   801193 <fd2num>
  801e22:	83 c4 10             	add    $0x10,%esp
}
  801e25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    

00801e2c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	e8 50 ff ff ff       	call   801d8a <fd2sockid>
		return r;
  801e3a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 1f                	js     801e5f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	ff 75 10             	pushl  0x10(%ebp)
  801e46:	ff 75 0c             	pushl  0xc(%ebp)
  801e49:	50                   	push   %eax
  801e4a:	e8 12 01 00 00       	call   801f61 <nsipc_accept>
  801e4f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e52:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 07                	js     801e5f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e58:	e8 5d ff ff ff       	call   801dba <alloc_sockfd>
  801e5d:	89 c1                	mov    %eax,%ecx
}
  801e5f:	89 c8                	mov    %ecx,%eax
  801e61:	c9                   	leave  
  801e62:	c3                   	ret    

00801e63 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e69:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6c:	e8 19 ff ff ff       	call   801d8a <fd2sockid>
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 12                	js     801e87 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e75:	83 ec 04             	sub    $0x4,%esp
  801e78:	ff 75 10             	pushl  0x10(%ebp)
  801e7b:	ff 75 0c             	pushl  0xc(%ebp)
  801e7e:	50                   	push   %eax
  801e7f:	e8 2d 01 00 00       	call   801fb1 <nsipc_bind>
  801e84:	83 c4 10             	add    $0x10,%esp
}
  801e87:	c9                   	leave  
  801e88:	c3                   	ret    

00801e89 <shutdown>:

int
shutdown(int s, int how)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e92:	e8 f3 fe ff ff       	call   801d8a <fd2sockid>
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 0f                	js     801eaa <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e9b:	83 ec 08             	sub    $0x8,%esp
  801e9e:	ff 75 0c             	pushl  0xc(%ebp)
  801ea1:	50                   	push   %eax
  801ea2:	e8 3f 01 00 00       	call   801fe6 <nsipc_shutdown>
  801ea7:	83 c4 10             	add    $0x10,%esp
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb5:	e8 d0 fe ff ff       	call   801d8a <fd2sockid>
  801eba:	85 c0                	test   %eax,%eax
  801ebc:	78 12                	js     801ed0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801ebe:	83 ec 04             	sub    $0x4,%esp
  801ec1:	ff 75 10             	pushl  0x10(%ebp)
  801ec4:	ff 75 0c             	pushl  0xc(%ebp)
  801ec7:	50                   	push   %eax
  801ec8:	e8 55 01 00 00       	call   802022 <nsipc_connect>
  801ecd:	83 c4 10             	add    $0x10,%esp
}
  801ed0:	c9                   	leave  
  801ed1:	c3                   	ret    

00801ed2 <listen>:

int
listen(int s, int backlog)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	e8 aa fe ff ff       	call   801d8a <fd2sockid>
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	78 0f                	js     801ef3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ee4:	83 ec 08             	sub    $0x8,%esp
  801ee7:	ff 75 0c             	pushl  0xc(%ebp)
  801eea:	50                   	push   %eax
  801eeb:	e8 67 01 00 00       	call   802057 <nsipc_listen>
  801ef0:	83 c4 10             	add    $0x10,%esp
}
  801ef3:	c9                   	leave  
  801ef4:	c3                   	ret    

00801ef5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ef5:	55                   	push   %ebp
  801ef6:	89 e5                	mov    %esp,%ebp
  801ef8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801efb:	ff 75 10             	pushl  0x10(%ebp)
  801efe:	ff 75 0c             	pushl  0xc(%ebp)
  801f01:	ff 75 08             	pushl  0x8(%ebp)
  801f04:	e8 3a 02 00 00       	call   802143 <nsipc_socket>
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 05                	js     801f15 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f10:	e8 a5 fe ff ff       	call   801dba <alloc_sockfd>
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	53                   	push   %ebx
  801f1b:	83 ec 04             	sub    $0x4,%esp
  801f1e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f20:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801f27:	75 12                	jne    801f3b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	6a 02                	push   $0x2
  801f2e:	e8 27 f2 ff ff       	call   80115a <ipc_find_env>
  801f33:	a3 04 40 80 00       	mov    %eax,0x804004
  801f38:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f3b:	6a 07                	push   $0x7
  801f3d:	68 00 60 80 00       	push   $0x806000
  801f42:	53                   	push   %ebx
  801f43:	ff 35 04 40 80 00    	pushl  0x804004
  801f49:	e8 bd f1 ff ff       	call   80110b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f4e:	83 c4 0c             	add    $0xc,%esp
  801f51:	6a 00                	push   $0x0
  801f53:	6a 00                	push   $0x0
  801f55:	6a 00                	push   $0x0
  801f57:	e8 39 f1 ff ff       	call   801095 <ipc_recv>
}
  801f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
  801f66:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801f69:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f71:	8b 06                	mov    (%esi),%eax
  801f73:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f78:	b8 01 00 00 00       	mov    $0x1,%eax
  801f7d:	e8 95 ff ff ff       	call   801f17 <nsipc>
  801f82:	89 c3                	mov    %eax,%ebx
  801f84:	85 c0                	test   %eax,%eax
  801f86:	78 20                	js     801fa8 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f88:	83 ec 04             	sub    $0x4,%esp
  801f8b:	ff 35 10 60 80 00    	pushl  0x806010
  801f91:	68 00 60 80 00       	push   $0x806000
  801f96:	ff 75 0c             	pushl  0xc(%ebp)
  801f99:	e8 4a e9 ff ff       	call   8008e8 <memmove>
		*addrlen = ret->ret_addrlen;
  801f9e:	a1 10 60 80 00       	mov    0x806010,%eax
  801fa3:	89 06                	mov    %eax,(%esi)
  801fa5:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801fa8:	89 d8                	mov    %ebx,%eax
  801faa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	53                   	push   %ebx
  801fb5:	83 ec 08             	sub    $0x8,%esp
  801fb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801fc3:	53                   	push   %ebx
  801fc4:	ff 75 0c             	pushl  0xc(%ebp)
  801fc7:	68 04 60 80 00       	push   $0x806004
  801fcc:	e8 17 e9 ff ff       	call   8008e8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fd1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801fd7:	b8 02 00 00 00       	mov    $0x2,%eax
  801fdc:	e8 36 ff ff ff       	call   801f17 <nsipc>
}
  801fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe4:	c9                   	leave  
  801fe5:	c3                   	ret    

00801fe6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fec:	8b 45 08             	mov    0x8(%ebp),%eax
  801fef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ffc:	b8 03 00 00 00       	mov    $0x3,%eax
  802001:	e8 11 ff ff ff       	call   801f17 <nsipc>
}
  802006:	c9                   	leave  
  802007:	c3                   	ret    

00802008 <nsipc_close>:

int
nsipc_close(int s)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80200e:	8b 45 08             	mov    0x8(%ebp),%eax
  802011:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802016:	b8 04 00 00 00       	mov    $0x4,%eax
  80201b:	e8 f7 fe ff ff       	call   801f17 <nsipc>
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	53                   	push   %ebx
  802026:	83 ec 08             	sub    $0x8,%esp
  802029:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802034:	53                   	push   %ebx
  802035:	ff 75 0c             	pushl  0xc(%ebp)
  802038:	68 04 60 80 00       	push   $0x806004
  80203d:	e8 a6 e8 ff ff       	call   8008e8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802042:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802048:	b8 05 00 00 00       	mov    $0x5,%eax
  80204d:	e8 c5 fe ff ff       	call   801f17 <nsipc>
}
  802052:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802055:	c9                   	leave  
  802056:	c3                   	ret    

00802057 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80205d:	8b 45 08             	mov    0x8(%ebp),%eax
  802060:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802065:	8b 45 0c             	mov    0xc(%ebp),%eax
  802068:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80206d:	b8 06 00 00 00       	mov    $0x6,%eax
  802072:	e8 a0 fe ff ff       	call   801f17 <nsipc>
}
  802077:	c9                   	leave  
  802078:	c3                   	ret    

00802079 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
  80207e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802081:	8b 45 08             	mov    0x8(%ebp),%eax
  802084:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802089:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80208f:	8b 45 14             	mov    0x14(%ebp),%eax
  802092:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802097:	b8 07 00 00 00       	mov    $0x7,%eax
  80209c:	e8 76 fe ff ff       	call   801f17 <nsipc>
  8020a1:	89 c3                	mov    %eax,%ebx
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 35                	js     8020dc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8020a7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020ac:	7f 04                	jg     8020b2 <nsipc_recv+0x39>
  8020ae:	39 c6                	cmp    %eax,%esi
  8020b0:	7d 16                	jge    8020c8 <nsipc_recv+0x4f>
  8020b2:	68 ce 2b 80 00       	push   $0x802bce
  8020b7:	68 77 2b 80 00       	push   $0x802b77
  8020bc:	6a 62                	push   $0x62
  8020be:	68 e3 2b 80 00       	push   $0x802be3
  8020c3:	e8 28 02 00 00       	call   8022f0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020c8:	83 ec 04             	sub    $0x4,%esp
  8020cb:	50                   	push   %eax
  8020cc:	68 00 60 80 00       	push   $0x806000
  8020d1:	ff 75 0c             	pushl  0xc(%ebp)
  8020d4:	e8 0f e8 ff ff       	call   8008e8 <memmove>
  8020d9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e1:	5b                   	pop    %ebx
  8020e2:	5e                   	pop    %esi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    

008020e5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	53                   	push   %ebx
  8020e9:	83 ec 04             	sub    $0x4,%esp
  8020ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020f7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020fd:	7e 16                	jle    802115 <nsipc_send+0x30>
  8020ff:	68 ef 2b 80 00       	push   $0x802bef
  802104:	68 77 2b 80 00       	push   $0x802b77
  802109:	6a 6d                	push   $0x6d
  80210b:	68 e3 2b 80 00       	push   $0x802be3
  802110:	e8 db 01 00 00       	call   8022f0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802115:	83 ec 04             	sub    $0x4,%esp
  802118:	53                   	push   %ebx
  802119:	ff 75 0c             	pushl  0xc(%ebp)
  80211c:	68 0c 60 80 00       	push   $0x80600c
  802121:	e8 c2 e7 ff ff       	call   8008e8 <memmove>
	nsipcbuf.send.req_size = size;
  802126:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80212c:	8b 45 14             	mov    0x14(%ebp),%eax
  80212f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802134:	b8 08 00 00 00       	mov    $0x8,%eax
  802139:	e8 d9 fd ff ff       	call   801f17 <nsipc>
}
  80213e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802141:	c9                   	leave  
  802142:	c3                   	ret    

00802143 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802149:	8b 45 08             	mov    0x8(%ebp),%eax
  80214c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802151:	8b 45 0c             	mov    0xc(%ebp),%eax
  802154:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802159:	8b 45 10             	mov    0x10(%ebp),%eax
  80215c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802161:	b8 09 00 00 00       	mov    $0x9,%eax
  802166:	e8 ac fd ff ff       	call   801f17 <nsipc>
}
  80216b:	c9                   	leave  
  80216c:	c3                   	ret    

0080216d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802170:	b8 00 00 00 00       	mov    $0x0,%eax
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    

00802177 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802177:	55                   	push   %ebp
  802178:	89 e5                	mov    %esp,%ebp
  80217a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80217d:	68 fb 2b 80 00       	push   $0x802bfb
  802182:	ff 75 0c             	pushl  0xc(%ebp)
  802185:	e8 cc e5 ff ff       	call   800756 <strcpy>
	return 0;
}
  80218a:	b8 00 00 00 00       	mov    $0x0,%eax
  80218f:	c9                   	leave  
  802190:	c3                   	ret    

00802191 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802191:	55                   	push   %ebp
  802192:	89 e5                	mov    %esp,%ebp
  802194:	57                   	push   %edi
  802195:	56                   	push   %esi
  802196:	53                   	push   %ebx
  802197:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80219d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021a2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021a8:	eb 2d                	jmp    8021d7 <devcons_write+0x46>
		m = n - tot;
  8021aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021ad:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021af:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021b2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021b7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ba:	83 ec 04             	sub    $0x4,%esp
  8021bd:	53                   	push   %ebx
  8021be:	03 45 0c             	add    0xc(%ebp),%eax
  8021c1:	50                   	push   %eax
  8021c2:	57                   	push   %edi
  8021c3:	e8 20 e7 ff ff       	call   8008e8 <memmove>
		sys_cputs(buf, m);
  8021c8:	83 c4 08             	add    $0x8,%esp
  8021cb:	53                   	push   %ebx
  8021cc:	57                   	push   %edi
  8021cd:	e8 cb e8 ff ff       	call   800a9d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d2:	01 de                	add    %ebx,%esi
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	89 f0                	mov    %esi,%eax
  8021d9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021dc:	72 cc                	jb     8021aa <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021e1:	5b                   	pop    %ebx
  8021e2:	5e                   	pop    %esi
  8021e3:	5f                   	pop    %edi
  8021e4:	5d                   	pop    %ebp
  8021e5:	c3                   	ret    

008021e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021e6:	55                   	push   %ebp
  8021e7:	89 e5                	mov    %esp,%ebp
  8021e9:	83 ec 08             	sub    $0x8,%esp
  8021ec:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021f5:	74 2a                	je     802221 <devcons_read+0x3b>
  8021f7:	eb 05                	jmp    8021fe <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021f9:	e8 3c e9 ff ff       	call   800b3a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021fe:	e8 b8 e8 ff ff       	call   800abb <sys_cgetc>
  802203:	85 c0                	test   %eax,%eax
  802205:	74 f2                	je     8021f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802207:	85 c0                	test   %eax,%eax
  802209:	78 16                	js     802221 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80220b:	83 f8 04             	cmp    $0x4,%eax
  80220e:	74 0c                	je     80221c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802210:	8b 55 0c             	mov    0xc(%ebp),%edx
  802213:	88 02                	mov    %al,(%edx)
	return 1;
  802215:	b8 01 00 00 00       	mov    $0x1,%eax
  80221a:	eb 05                	jmp    802221 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80221c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802221:	c9                   	leave  
  802222:	c3                   	ret    

00802223 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802223:	55                   	push   %ebp
  802224:	89 e5                	mov    %esp,%ebp
  802226:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802229:	8b 45 08             	mov    0x8(%ebp),%eax
  80222c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80222f:	6a 01                	push   $0x1
  802231:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802234:	50                   	push   %eax
  802235:	e8 63 e8 ff ff       	call   800a9d <sys_cputs>
}
  80223a:	83 c4 10             	add    $0x10,%esp
  80223d:	c9                   	leave  
  80223e:	c3                   	ret    

0080223f <getchar>:

int
getchar(void)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802245:	6a 01                	push   $0x1
  802247:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80224a:	50                   	push   %eax
  80224b:	6a 00                	push   $0x0
  80224d:	e8 1d f2 ff ff       	call   80146f <read>
	if (r < 0)
  802252:	83 c4 10             	add    $0x10,%esp
  802255:	85 c0                	test   %eax,%eax
  802257:	78 0f                	js     802268 <getchar+0x29>
		return r;
	if (r < 1)
  802259:	85 c0                	test   %eax,%eax
  80225b:	7e 06                	jle    802263 <getchar+0x24>
		return -E_EOF;
	return c;
  80225d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802261:	eb 05                	jmp    802268 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802263:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802268:	c9                   	leave  
  802269:	c3                   	ret    

0080226a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80226a:	55                   	push   %ebp
  80226b:	89 e5                	mov    %esp,%ebp
  80226d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802270:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802273:	50                   	push   %eax
  802274:	ff 75 08             	pushl  0x8(%ebp)
  802277:	e8 8d ef ff ff       	call   801209 <fd_lookup>
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	85 c0                	test   %eax,%eax
  802281:	78 11                	js     802294 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802283:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802286:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80228c:	39 10                	cmp    %edx,(%eax)
  80228e:	0f 94 c0             	sete   %al
  802291:	0f b6 c0             	movzbl %al,%eax
}
  802294:	c9                   	leave  
  802295:	c3                   	ret    

00802296 <opencons>:

int
opencons(void)
{
  802296:	55                   	push   %ebp
  802297:	89 e5                	mov    %esp,%ebp
  802299:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80229c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80229f:	50                   	push   %eax
  8022a0:	e8 15 ef ff ff       	call   8011ba <fd_alloc>
  8022a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	78 3e                	js     8022ec <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ae:	83 ec 04             	sub    $0x4,%esp
  8022b1:	68 07 04 00 00       	push   $0x407
  8022b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8022b9:	6a 00                	push   $0x0
  8022bb:	e8 99 e8 ff ff       	call   800b59 <sys_page_alloc>
  8022c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8022c3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022c5:	85 c0                	test   %eax,%eax
  8022c7:	78 23                	js     8022ec <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022c9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022de:	83 ec 0c             	sub    $0xc,%esp
  8022e1:	50                   	push   %eax
  8022e2:	e8 ac ee ff ff       	call   801193 <fd2num>
  8022e7:	89 c2                	mov    %eax,%edx
  8022e9:	83 c4 10             	add    $0x10,%esp
}
  8022ec:	89 d0                	mov    %edx,%eax
  8022ee:	c9                   	leave  
  8022ef:	c3                   	ret    

008022f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	56                   	push   %esi
  8022f4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022f5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022f8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022fe:	e8 18 e8 ff ff       	call   800b1b <sys_getenvid>
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	ff 75 0c             	pushl  0xc(%ebp)
  802309:	ff 75 08             	pushl  0x8(%ebp)
  80230c:	56                   	push   %esi
  80230d:	50                   	push   %eax
  80230e:	68 08 2c 80 00       	push   $0x802c08
  802313:	e8 99 de ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802318:	83 c4 18             	add    $0x18,%esp
  80231b:	53                   	push   %ebx
  80231c:	ff 75 10             	pushl  0x10(%ebp)
  80231f:	e8 3c de ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  802324:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  80232b:	e8 81 de ff ff       	call   8001b1 <cprintf>
  802330:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802333:	cc                   	int3   
  802334:	eb fd                	jmp    802333 <_panic+0x43>

00802336 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  80233c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802343:	75 56                	jne    80239b <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802345:	83 ec 04             	sub    $0x4,%esp
  802348:	6a 07                	push   $0x7
  80234a:	68 00 f0 bf ee       	push   $0xeebff000
  80234f:	6a 00                	push   $0x0
  802351:	e8 03 e8 ff ff       	call   800b59 <sys_page_alloc>
  802356:	83 c4 10             	add    $0x10,%esp
  802359:	85 c0                	test   %eax,%eax
  80235b:	74 14                	je     802371 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  80235d:	83 ec 04             	sub    $0x4,%esp
  802360:	68 89 2a 80 00       	push   $0x802a89
  802365:	6a 21                	push   $0x21
  802367:	68 2c 2c 80 00       	push   $0x802c2c
  80236c:	e8 7f ff ff ff       	call   8022f0 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  802371:	83 ec 08             	sub    $0x8,%esp
  802374:	68 a5 23 80 00       	push   $0x8023a5
  802379:	6a 00                	push   $0x0
  80237b:	e8 24 e9 ff ff       	call   800ca4 <sys_env_set_pgfault_upcall>
  802380:	83 c4 10             	add    $0x10,%esp
  802383:	85 c0                	test   %eax,%eax
  802385:	74 14                	je     80239b <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  802387:	83 ec 04             	sub    $0x4,%esp
  80238a:	68 3a 2c 80 00       	push   $0x802c3a
  80238f:	6a 23                	push   $0x23
  802391:	68 2c 2c 80 00       	push   $0x802c2c
  802396:	e8 55 ff ff ff       	call   8022f0 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80239b:	8b 45 08             	mov    0x8(%ebp),%eax
  80239e:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023a3:	c9                   	leave  
  8023a4:	c3                   	ret    

008023a5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023a5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023a6:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023ab:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023ad:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8023b0:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8023b2:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8023b6:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8023ba:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8023bb:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8023bd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8023c2:	83 c4 08             	add    $0x8,%esp
	popal
  8023c5:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8023c6:	83 c4 04             	add    $0x4,%esp
	popfl
  8023c9:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8023ca:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023cb:	c3                   	ret    

008023cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d2:	89 d0                	mov    %edx,%eax
  8023d4:	c1 e8 16             	shr    $0x16,%eax
  8023d7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023de:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023e3:	f6 c1 01             	test   $0x1,%cl
  8023e6:	74 1d                	je     802405 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023e8:	c1 ea 0c             	shr    $0xc,%edx
  8023eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023f2:	f6 c2 01             	test   $0x1,%dl
  8023f5:	74 0e                	je     802405 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023f7:	c1 ea 0c             	shr    $0xc,%edx
  8023fa:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802401:	ef 
  802402:	0f b7 c0             	movzwl %ax,%eax
}
  802405:	5d                   	pop    %ebp
  802406:	c3                   	ret    
  802407:	66 90                	xchg   %ax,%ax
  802409:	66 90                	xchg   %ax,%ax
  80240b:	66 90                	xchg   %ax,%ax
  80240d:	66 90                	xchg   %ax,%ax
  80240f:	90                   	nop

00802410 <__udivdi3>:
  802410:	55                   	push   %ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 1c             	sub    $0x1c,%esp
  802417:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80241b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80241f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802423:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802427:	85 f6                	test   %esi,%esi
  802429:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80242d:	89 ca                	mov    %ecx,%edx
  80242f:	89 f8                	mov    %edi,%eax
  802431:	75 3d                	jne    802470 <__udivdi3+0x60>
  802433:	39 cf                	cmp    %ecx,%edi
  802435:	0f 87 c5 00 00 00    	ja     802500 <__udivdi3+0xf0>
  80243b:	85 ff                	test   %edi,%edi
  80243d:	89 fd                	mov    %edi,%ebp
  80243f:	75 0b                	jne    80244c <__udivdi3+0x3c>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	31 d2                	xor    %edx,%edx
  802448:	f7 f7                	div    %edi
  80244a:	89 c5                	mov    %eax,%ebp
  80244c:	89 c8                	mov    %ecx,%eax
  80244e:	31 d2                	xor    %edx,%edx
  802450:	f7 f5                	div    %ebp
  802452:	89 c1                	mov    %eax,%ecx
  802454:	89 d8                	mov    %ebx,%eax
  802456:	89 cf                	mov    %ecx,%edi
  802458:	f7 f5                	div    %ebp
  80245a:	89 c3                	mov    %eax,%ebx
  80245c:	89 d8                	mov    %ebx,%eax
  80245e:	89 fa                	mov    %edi,%edx
  802460:	83 c4 1c             	add    $0x1c,%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
  802468:	90                   	nop
  802469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802470:	39 ce                	cmp    %ecx,%esi
  802472:	77 74                	ja     8024e8 <__udivdi3+0xd8>
  802474:	0f bd fe             	bsr    %esi,%edi
  802477:	83 f7 1f             	xor    $0x1f,%edi
  80247a:	0f 84 98 00 00 00    	je     802518 <__udivdi3+0x108>
  802480:	bb 20 00 00 00       	mov    $0x20,%ebx
  802485:	89 f9                	mov    %edi,%ecx
  802487:	89 c5                	mov    %eax,%ebp
  802489:	29 fb                	sub    %edi,%ebx
  80248b:	d3 e6                	shl    %cl,%esi
  80248d:	89 d9                	mov    %ebx,%ecx
  80248f:	d3 ed                	shr    %cl,%ebp
  802491:	89 f9                	mov    %edi,%ecx
  802493:	d3 e0                	shl    %cl,%eax
  802495:	09 ee                	or     %ebp,%esi
  802497:	89 d9                	mov    %ebx,%ecx
  802499:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80249d:	89 d5                	mov    %edx,%ebp
  80249f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024a3:	d3 ed                	shr    %cl,%ebp
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	d3 e2                	shl    %cl,%edx
  8024a9:	89 d9                	mov    %ebx,%ecx
  8024ab:	d3 e8                	shr    %cl,%eax
  8024ad:	09 c2                	or     %eax,%edx
  8024af:	89 d0                	mov    %edx,%eax
  8024b1:	89 ea                	mov    %ebp,%edx
  8024b3:	f7 f6                	div    %esi
  8024b5:	89 d5                	mov    %edx,%ebp
  8024b7:	89 c3                	mov    %eax,%ebx
  8024b9:	f7 64 24 0c          	mull   0xc(%esp)
  8024bd:	39 d5                	cmp    %edx,%ebp
  8024bf:	72 10                	jb     8024d1 <__udivdi3+0xc1>
  8024c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e6                	shl    %cl,%esi
  8024c9:	39 c6                	cmp    %eax,%esi
  8024cb:	73 07                	jae    8024d4 <__udivdi3+0xc4>
  8024cd:	39 d5                	cmp    %edx,%ebp
  8024cf:	75 03                	jne    8024d4 <__udivdi3+0xc4>
  8024d1:	83 eb 01             	sub    $0x1,%ebx
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 d8                	mov    %ebx,%eax
  8024d8:	89 fa                	mov    %edi,%edx
  8024da:	83 c4 1c             	add    $0x1c,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5e                   	pop    %esi
  8024df:	5f                   	pop    %edi
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024e8:	31 ff                	xor    %edi,%edi
  8024ea:	31 db                	xor    %ebx,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	89 d8                	mov    %ebx,%eax
  802502:	f7 f7                	div    %edi
  802504:	31 ff                	xor    %edi,%edi
  802506:	89 c3                	mov    %eax,%ebx
  802508:	89 d8                	mov    %ebx,%eax
  80250a:	89 fa                	mov    %edi,%edx
  80250c:	83 c4 1c             	add    $0x1c,%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5f                   	pop    %edi
  802512:	5d                   	pop    %ebp
  802513:	c3                   	ret    
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	39 ce                	cmp    %ecx,%esi
  80251a:	72 0c                	jb     802528 <__udivdi3+0x118>
  80251c:	31 db                	xor    %ebx,%ebx
  80251e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802522:	0f 87 34 ff ff ff    	ja     80245c <__udivdi3+0x4c>
  802528:	bb 01 00 00 00       	mov    $0x1,%ebx
  80252d:	e9 2a ff ff ff       	jmp    80245c <__udivdi3+0x4c>
  802532:	66 90                	xchg   %ax,%ax
  802534:	66 90                	xchg   %ax,%ax
  802536:	66 90                	xchg   %ax,%ax
  802538:	66 90                	xchg   %ax,%ax
  80253a:	66 90                	xchg   %ax,%ax
  80253c:	66 90                	xchg   %ax,%ax
  80253e:	66 90                	xchg   %ax,%ax

00802540 <__umoddi3>:
  802540:	55                   	push   %ebp
  802541:	57                   	push   %edi
  802542:	56                   	push   %esi
  802543:	53                   	push   %ebx
  802544:	83 ec 1c             	sub    $0x1c,%esp
  802547:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80254b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80254f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802553:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802557:	85 d2                	test   %edx,%edx
  802559:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80255d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802561:	89 f3                	mov    %esi,%ebx
  802563:	89 3c 24             	mov    %edi,(%esp)
  802566:	89 74 24 04          	mov    %esi,0x4(%esp)
  80256a:	75 1c                	jne    802588 <__umoddi3+0x48>
  80256c:	39 f7                	cmp    %esi,%edi
  80256e:	76 50                	jbe    8025c0 <__umoddi3+0x80>
  802570:	89 c8                	mov    %ecx,%eax
  802572:	89 f2                	mov    %esi,%edx
  802574:	f7 f7                	div    %edi
  802576:	89 d0                	mov    %edx,%eax
  802578:	31 d2                	xor    %edx,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	39 f2                	cmp    %esi,%edx
  80258a:	89 d0                	mov    %edx,%eax
  80258c:	77 52                	ja     8025e0 <__umoddi3+0xa0>
  80258e:	0f bd ea             	bsr    %edx,%ebp
  802591:	83 f5 1f             	xor    $0x1f,%ebp
  802594:	75 5a                	jne    8025f0 <__umoddi3+0xb0>
  802596:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80259a:	0f 82 e0 00 00 00    	jb     802680 <__umoddi3+0x140>
  8025a0:	39 0c 24             	cmp    %ecx,(%esp)
  8025a3:	0f 86 d7 00 00 00    	jbe    802680 <__umoddi3+0x140>
  8025a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025b1:	83 c4 1c             	add    $0x1c,%esp
  8025b4:	5b                   	pop    %ebx
  8025b5:	5e                   	pop    %esi
  8025b6:	5f                   	pop    %edi
  8025b7:	5d                   	pop    %ebp
  8025b8:	c3                   	ret    
  8025b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	85 ff                	test   %edi,%edi
  8025c2:	89 fd                	mov    %edi,%ebp
  8025c4:	75 0b                	jne    8025d1 <__umoddi3+0x91>
  8025c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025cb:	31 d2                	xor    %edx,%edx
  8025cd:	f7 f7                	div    %edi
  8025cf:	89 c5                	mov    %eax,%ebp
  8025d1:	89 f0                	mov    %esi,%eax
  8025d3:	31 d2                	xor    %edx,%edx
  8025d5:	f7 f5                	div    %ebp
  8025d7:	89 c8                	mov    %ecx,%eax
  8025d9:	f7 f5                	div    %ebp
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	eb 99                	jmp    802578 <__umoddi3+0x38>
  8025df:	90                   	nop
  8025e0:	89 c8                	mov    %ecx,%eax
  8025e2:	89 f2                	mov    %esi,%edx
  8025e4:	83 c4 1c             	add    $0x1c,%esp
  8025e7:	5b                   	pop    %ebx
  8025e8:	5e                   	pop    %esi
  8025e9:	5f                   	pop    %edi
  8025ea:	5d                   	pop    %ebp
  8025eb:	c3                   	ret    
  8025ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	8b 34 24             	mov    (%esp),%esi
  8025f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	29 ef                	sub    %ebp,%edi
  8025fc:	d3 e0                	shl    %cl,%eax
  8025fe:	89 f9                	mov    %edi,%ecx
  802600:	89 f2                	mov    %esi,%edx
  802602:	d3 ea                	shr    %cl,%edx
  802604:	89 e9                	mov    %ebp,%ecx
  802606:	09 c2                	or     %eax,%edx
  802608:	89 d8                	mov    %ebx,%eax
  80260a:	89 14 24             	mov    %edx,(%esp)
  80260d:	89 f2                	mov    %esi,%edx
  80260f:	d3 e2                	shl    %cl,%edx
  802611:	89 f9                	mov    %edi,%ecx
  802613:	89 54 24 04          	mov    %edx,0x4(%esp)
  802617:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	89 e9                	mov    %ebp,%ecx
  80261f:	89 c6                	mov    %eax,%esi
  802621:	d3 e3                	shl    %cl,%ebx
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 d0                	mov    %edx,%eax
  802627:	d3 e8                	shr    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	09 d8                	or     %ebx,%eax
  80262d:	89 d3                	mov    %edx,%ebx
  80262f:	89 f2                	mov    %esi,%edx
  802631:	f7 34 24             	divl   (%esp)
  802634:	89 d6                	mov    %edx,%esi
  802636:	d3 e3                	shl    %cl,%ebx
  802638:	f7 64 24 04          	mull   0x4(%esp)
  80263c:	39 d6                	cmp    %edx,%esi
  80263e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802642:	89 d1                	mov    %edx,%ecx
  802644:	89 c3                	mov    %eax,%ebx
  802646:	72 08                	jb     802650 <__umoddi3+0x110>
  802648:	75 11                	jne    80265b <__umoddi3+0x11b>
  80264a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80264e:	73 0b                	jae    80265b <__umoddi3+0x11b>
  802650:	2b 44 24 04          	sub    0x4(%esp),%eax
  802654:	1b 14 24             	sbb    (%esp),%edx
  802657:	89 d1                	mov    %edx,%ecx
  802659:	89 c3                	mov    %eax,%ebx
  80265b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80265f:	29 da                	sub    %ebx,%edx
  802661:	19 ce                	sbb    %ecx,%esi
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 f0                	mov    %esi,%eax
  802667:	d3 e0                	shl    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	d3 ea                	shr    %cl,%edx
  80266d:	89 e9                	mov    %ebp,%ecx
  80266f:	d3 ee                	shr    %cl,%esi
  802671:	09 d0                	or     %edx,%eax
  802673:	89 f2                	mov    %esi,%edx
  802675:	83 c4 1c             	add    $0x1c,%esp
  802678:	5b                   	pop    %ebx
  802679:	5e                   	pop    %esi
  80267a:	5f                   	pop    %edi
  80267b:	5d                   	pop    %ebp
  80267c:	c3                   	ret    
  80267d:	8d 76 00             	lea    0x0(%esi),%esi
  802680:	29 f9                	sub    %edi,%ecx
  802682:	19 d6                	sbb    %edx,%esi
  802684:	89 74 24 04          	mov    %esi,0x4(%esp)
  802688:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80268c:	e9 18 ff ff ff       	jmp    8025a9 <__umoddi3+0x69>
