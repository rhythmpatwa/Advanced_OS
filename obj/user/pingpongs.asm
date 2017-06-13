
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 7a 10 00 00       	call   8010bb <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  80004e:	e8 08 0b 00 00       	call   800b5b <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 e0 26 80 00       	push   $0x8026e0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 f1 0a 00 00       	call   800b5b <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 fa 26 80 00       	push   $0x8026fa
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 c4 10 00 00       	call   80114b <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 3b 10 00 00       	call   8010d5 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 0c 40 80 00    	mov    0x80400c,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 a8 0a 00 00       	call   800b5b <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 10 27 80 00       	push   $0x802710
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 08 40 80 00       	mov    0x804008,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 08 40 80 00       	mov    %eax,0x804008
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 61 10 00 00       	call   80114b <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 08 40 80 00 0a 	cmpl   $0xa,0x804008
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800109:	e8 4d 0a 00 00       	call   800b5b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 0c 40 80 00       	mov    %eax,0x80400c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 4f 12 00 00       	call   80139e <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 c1 09 00 00       	call   800b1a <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 4f 09 00 00       	call   800add <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 f4 08 00 00       	call   800add <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 f7 21 00 00       	call   802450 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 e4 22 00 00       	call   802580 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 40 27 80 00 	movsbl 0x802740(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 a9 03 00 00    	je     8006ed <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 3a 03 00 00    	ja     8006d2 <vprintfmt+0x3aa>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 39                	ja     800401 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 27                	jmp    800407 <vprintfmt+0xdf>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	eb 8c                	jmp    800381 <vprintfmt+0x59>
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ff:	eb 80                	jmp    800381 <vprintfmt+0x59>
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 89 70 ff ff ff    	jns    800381 <vprintfmt+0x59>
				width = precision, precision = -1;
  800411:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800417:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041e:	e9 5e ff ff ff       	jmp    800381 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 53 ff ff ff       	jmp    800381 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 04 ff ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x142>
  80045f:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 58 27 80 00       	push   $0x802758
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 94 fe ff ff       	call   80030b <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 cc fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 e9 2b 80 00       	push   $0x802be9
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7c fe ff ff       	call   80030b <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b4 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 51 27 80 00       	mov    $0x802751,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x225>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 a6 02 00 00       	call   800775 <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c0>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x213>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x213>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x23f>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x23f>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x270>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1f2>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1f2>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x278>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 a2 fd ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 fa 01             	cmp    $0x1,%edx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x2d1>
	else if (lflag)
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ff:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	0f 89 90 00 00 00    	jns    80069e <vprintfmt+0x376>
				putch('-', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 2d                	push   $0x2d
  800614:	ff d6                	call   *%esi
				num = -(long long) num;
  800616:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800619:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80061c:	f7 d8                	neg    %eax
  80061e:	83 d2 00             	adc    $0x0,%edx
  800621:	f7 da                	neg    %edx
  800623:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800626:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062b:	eb 71                	jmp    80069e <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 7f fc ff ff       	call   8002b4 <getuint>
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80063a:	eb 62                	jmp    80069e <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
  80063f:	e8 70 fc ff ff       	call   8002b4 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800644:	83 ec 0c             	sub    $0xc,%esp
  800647:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80064b:	51                   	push   %ecx
  80064c:	ff 75 e0             	pushl  -0x20(%ebp)
  80064f:	6a 08                	push   $0x8
  800651:	52                   	push   %edx
  800652:	50                   	push   %eax
  800653:	89 da                	mov    %ebx,%edx
  800655:	89 f0                	mov    %esi,%eax
  800657:	e8 a9 fb ff ff       	call   800205 <printnum>
			break;
  80065c:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800662:	e9 e7 fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 50 04             	lea    0x4(%eax),%edx
  80067d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800680:	8b 00                	mov    (%eax),%eax
  800682:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800687:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80068a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80068f:	eb 0d                	jmp    80069e <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800691:	8d 45 14             	lea    0x14(%ebp),%eax
  800694:	e8 1b fc ff ff       	call   8002b4 <getuint>
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069e:	83 ec 0c             	sub    $0xc,%esp
  8006a1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a5:	57                   	push   %edi
  8006a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a9:	51                   	push   %ecx
  8006aa:	52                   	push   %edx
  8006ab:	50                   	push   %eax
  8006ac:	89 da                	mov    %ebx,%edx
  8006ae:	89 f0                	mov    %esi,%eax
  8006b0:	e8 50 fb ff ff       	call   800205 <printnum>
			break;
  8006b5:	83 c4 20             	add    $0x20,%esp
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 8e fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c0:	83 ec 08             	sub    $0x8,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	51                   	push   %ecx
  8006c5:	ff d6                	call   *%esi
			break;
  8006c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cd:	e9 7c fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 25                	push   $0x25
  8006d8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	eb 03                	jmp    8006e2 <vprintfmt+0x3ba>
  8006df:	83 ef 01             	sub    $0x1,%edi
  8006e2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e6:	75 f7                	jne    8006df <vprintfmt+0x3b7>
  8006e8:	e9 61 fc ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x47>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 ee 02 80 00       	push   $0x8002ee
  800729:	e8 fa fb ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 05                	jmp    800741 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800741:	c9                   	leave  
  800742:	c3                   	ret    

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800749:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074c:	50                   	push   %eax
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	ff 75 08             	pushl  0x8(%ebp)
  800756:	e8 9a ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075b:	c9                   	leave  
  80075c:	c3                   	ret    

0080075d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	b8 00 00 00 00       	mov    $0x0,%eax
  800768:	eb 03                	jmp    80076d <strlen+0x10>
		n++;
  80076a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800771:	75 f7                	jne    80076a <strlen+0xd>
		n++;
	return n;
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	ba 00 00 00 00       	mov    $0x0,%edx
  800783:	eb 03                	jmp    800788 <strnlen+0x13>
		n++;
  800785:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800788:	39 c2                	cmp    %eax,%edx
  80078a:	74 08                	je     800794 <strnlen+0x1f>
  80078c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800790:	75 f3                	jne    800785 <strnlen+0x10>
  800792:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	83 c2 01             	add    $0x1,%edx
  8007a5:	83 c1 01             	add    $0x1,%ecx
  8007a8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ac:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007af:	84 db                	test   %bl,%bl
  8007b1:	75 ef                	jne    8007a2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b3:	5b                   	pop    %ebx
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bd:	53                   	push   %ebx
  8007be:	e8 9a ff ff ff       	call   80075d <strlen>
  8007c3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	01 d8                	add    %ebx,%eax
  8007cb:	50                   	push   %eax
  8007cc:	e8 c5 ff ff ff       	call   800796 <strcpy>
	return dst;
}
  8007d1:	89 d8                	mov    %ebx,%eax
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	56                   	push   %esi
  8007dc:	53                   	push   %ebx
  8007dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e3:	89 f3                	mov    %esi,%ebx
  8007e5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	89 f2                	mov    %esi,%edx
  8007ea:	eb 0f                	jmp    8007fb <strncpy+0x23>
		*dst++ = *src;
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	0f b6 01             	movzbl (%ecx),%eax
  8007f2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fb:	39 da                	cmp    %ebx,%edx
  8007fd:	75 ed                	jne    8007ec <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ff:	89 f0                	mov    %esi,%eax
  800801:	5b                   	pop    %ebx
  800802:	5e                   	pop    %esi
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800810:	8b 55 10             	mov    0x10(%ebp),%edx
  800813:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800815:	85 d2                	test   %edx,%edx
  800817:	74 21                	je     80083a <strlcpy+0x35>
  800819:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081d:	89 f2                	mov    %esi,%edx
  80081f:	eb 09                	jmp    80082a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800821:	83 c2 01             	add    $0x1,%edx
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082a:	39 c2                	cmp    %eax,%edx
  80082c:	74 09                	je     800837 <strlcpy+0x32>
  80082e:	0f b6 19             	movzbl (%ecx),%ebx
  800831:	84 db                	test   %bl,%bl
  800833:	75 ec                	jne    800821 <strlcpy+0x1c>
  800835:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800837:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083a:	29 f0                	sub    %esi,%eax
}
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800849:	eb 06                	jmp    800851 <strcmp+0x11>
		p++, q++;
  80084b:	83 c1 01             	add    $0x1,%ecx
  80084e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	84 c0                	test   %al,%al
  800856:	74 04                	je     80085c <strcmp+0x1c>
  800858:	3a 02                	cmp    (%edx),%al
  80085a:	74 ef                	je     80084b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085c:	0f b6 c0             	movzbl %al,%eax
  80085f:	0f b6 12             	movzbl (%edx),%edx
  800862:	29 d0                	sub    %edx,%eax
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800870:	89 c3                	mov    %eax,%ebx
  800872:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800875:	eb 06                	jmp    80087d <strncmp+0x17>
		n--, p++, q++;
  800877:	83 c0 01             	add    $0x1,%eax
  80087a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087d:	39 d8                	cmp    %ebx,%eax
  80087f:	74 15                	je     800896 <strncmp+0x30>
  800881:	0f b6 08             	movzbl (%eax),%ecx
  800884:	84 c9                	test   %cl,%cl
  800886:	74 04                	je     80088c <strncmp+0x26>
  800888:	3a 0a                	cmp    (%edx),%cl
  80088a:	74 eb                	je     800877 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088c:	0f b6 00             	movzbl (%eax),%eax
  80088f:	0f b6 12             	movzbl (%edx),%edx
  800892:	29 d0                	sub    %edx,%eax
  800894:	eb 05                	jmp    80089b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089b:	5b                   	pop    %ebx
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a8:	eb 07                	jmp    8008b1 <strchr+0x13>
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 0f                	je     8008bd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 10             	movzbl (%eax),%edx
  8008b4:	84 d2                	test   %dl,%dl
  8008b6:	75 f2                	jne    8008aa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 03                	jmp    8008ce <strfind+0xf>
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d1:	38 ca                	cmp    %cl,%dl
  8008d3:	74 04                	je     8008d9 <strfind+0x1a>
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f2                	jne    8008cb <strfind+0xc>
			break;
	return (char *) s;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	57                   	push   %edi
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
  8008e1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e7:	85 c9                	test   %ecx,%ecx
  8008e9:	74 36                	je     800921 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008eb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f1:	75 28                	jne    80091b <memset+0x40>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 23                	jne    80091b <memset+0x40>
		c &= 0xFF;
  8008f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fc:	89 d3                	mov    %edx,%ebx
  8008fe:	c1 e3 08             	shl    $0x8,%ebx
  800901:	89 d6                	mov    %edx,%esi
  800903:	c1 e6 18             	shl    $0x18,%esi
  800906:	89 d0                	mov    %edx,%eax
  800908:	c1 e0 10             	shl    $0x10,%eax
  80090b:	09 f0                	or     %esi,%eax
  80090d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	09 d0                	or     %edx,%eax
  800913:	c1 e9 02             	shr    $0x2,%ecx
  800916:	fc                   	cld    
  800917:	f3 ab                	rep stos %eax,%es:(%edi)
  800919:	eb 06                	jmp    800921 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	fc                   	cld    
  80091f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800921:	89 f8                	mov    %edi,%eax
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 35                	jae    80096f <memmove+0x47>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 d0                	cmp    %edx,%eax
  80093f:	73 2e                	jae    80096f <memmove+0x47>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	89 d6                	mov    %edx,%esi
  800946:	09 fe                	or     %edi,%esi
  800948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094e:	75 13                	jne    800963 <memmove+0x3b>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 0e                	jne    800963 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800955:	83 ef 04             	sub    $0x4,%edi
  800958:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095b:	c1 e9 02             	shr    $0x2,%ecx
  80095e:	fd                   	std    
  80095f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800961:	eb 09                	jmp    80096c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800963:	83 ef 01             	sub    $0x1,%edi
  800966:	8d 72 ff             	lea    -0x1(%edx),%esi
  800969:	fd                   	std    
  80096a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096c:	fc                   	cld    
  80096d:	eb 1d                	jmp    80098c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096f:	89 f2                	mov    %esi,%edx
  800971:	09 c2                	or     %eax,%edx
  800973:	f6 c2 03             	test   $0x3,%dl
  800976:	75 0f                	jne    800987 <memmove+0x5f>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0a                	jne    800987 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	89 c7                	mov    %eax,%edi
  800982:	fc                   	cld    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 05                	jmp    80098c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800993:	ff 75 10             	pushl  0x10(%ebp)
  800996:	ff 75 0c             	pushl  0xc(%ebp)
  800999:	ff 75 08             	pushl  0x8(%ebp)
  80099c:	e8 87 ff ff ff       	call   800928 <memmove>
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	89 c6                	mov    %eax,%esi
  8009b0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	eb 1a                	jmp    8009cf <memcmp+0x2c>
		if (*s1 != *s2)
  8009b5:	0f b6 08             	movzbl (%eax),%ecx
  8009b8:	0f b6 1a             	movzbl (%edx),%ebx
  8009bb:	38 d9                	cmp    %bl,%cl
  8009bd:	74 0a                	je     8009c9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bf:	0f b6 c1             	movzbl %cl,%eax
  8009c2:	0f b6 db             	movzbl %bl,%ebx
  8009c5:	29 d8                	sub    %ebx,%eax
  8009c7:	eb 0f                	jmp    8009d8 <memcmp+0x35>
		s1++, s2++;
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cf:	39 f0                	cmp    %esi,%eax
  8009d1:	75 e2                	jne    8009b5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5e                   	pop    %esi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	53                   	push   %ebx
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e3:	89 c1                	mov    %eax,%ecx
  8009e5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ec:	eb 0a                	jmp    8009f8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ee:	0f b6 10             	movzbl (%eax),%edx
  8009f1:	39 da                	cmp    %ebx,%edx
  8009f3:	74 07                	je     8009fc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	39 c8                	cmp    %ecx,%eax
  8009fa:	72 f2                	jb     8009ee <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	57                   	push   %edi
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0b:	eb 03                	jmp    800a10 <strtol+0x11>
		s++;
  800a0d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	0f b6 01             	movzbl (%ecx),%eax
  800a13:	3c 20                	cmp    $0x20,%al
  800a15:	74 f6                	je     800a0d <strtol+0xe>
  800a17:	3c 09                	cmp    $0x9,%al
  800a19:	74 f2                	je     800a0d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1b:	3c 2b                	cmp    $0x2b,%al
  800a1d:	75 0a                	jne    800a29 <strtol+0x2a>
		s++;
  800a1f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a22:	bf 00 00 00 00       	mov    $0x0,%edi
  800a27:	eb 11                	jmp    800a3a <strtol+0x3b>
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2e:	3c 2d                	cmp    $0x2d,%al
  800a30:	75 08                	jne    800a3a <strtol+0x3b>
		s++, neg = 1;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a40:	75 15                	jne    800a57 <strtol+0x58>
  800a42:	80 39 30             	cmpb   $0x30,(%ecx)
  800a45:	75 10                	jne    800a57 <strtol+0x58>
  800a47:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4b:	75 7c                	jne    800ac9 <strtol+0xca>
		s += 2, base = 16;
  800a4d:	83 c1 02             	add    $0x2,%ecx
  800a50:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a55:	eb 16                	jmp    800a6d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a57:	85 db                	test   %ebx,%ebx
  800a59:	75 12                	jne    800a6d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a60:	80 39 30             	cmpb   $0x30,(%ecx)
  800a63:	75 08                	jne    800a6d <strtol+0x6e>
		s++, base = 8;
  800a65:	83 c1 01             	add    $0x1,%ecx
  800a68:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a75:	0f b6 11             	movzbl (%ecx),%edx
  800a78:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7b:	89 f3                	mov    %esi,%ebx
  800a7d:	80 fb 09             	cmp    $0x9,%bl
  800a80:	77 08                	ja     800a8a <strtol+0x8b>
			dig = *s - '0';
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 30             	sub    $0x30,%edx
  800a88:	eb 22                	jmp    800aac <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	80 fb 19             	cmp    $0x19,%bl
  800a92:	77 08                	ja     800a9c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a94:	0f be d2             	movsbl %dl,%edx
  800a97:	83 ea 57             	sub    $0x57,%edx
  800a9a:	eb 10                	jmp    800aac <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 19             	cmp    $0x19,%bl
  800aa4:	77 16                	ja     800abc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaf:	7d 0b                	jge    800abc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aba:	eb b9                	jmp    800a75 <strtol+0x76>

	if (endptr)
  800abc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac0:	74 0d                	je     800acf <strtol+0xd0>
		*endptr = (char *) s;
  800ac2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac5:	89 0e                	mov    %ecx,(%esi)
  800ac7:	eb 06                	jmp    800acf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	74 98                	je     800a65 <strtol+0x66>
  800acd:	eb 9e                	jmp    800a6d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	f7 da                	neg    %edx
  800ad3:	85 ff                	test   %edi,%edi
  800ad5:	0f 45 c2             	cmovne %edx,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	89 c3                	mov    %eax,%ebx
  800af0:	89 c7                	mov    %eax,%edi
  800af2:	89 c6                	mov    %eax,%esi
  800af4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_cgetc>:

int
sys_cgetc(void)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b01:	ba 00 00 00 00       	mov    $0x0,%edx
  800b06:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0b:	89 d1                	mov    %edx,%ecx
  800b0d:	89 d3                	mov    %edx,%ebx
  800b0f:	89 d7                	mov    %edx,%edi
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b28:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	89 cb                	mov    %ecx,%ebx
  800b32:	89 cf                	mov    %ecx,%edi
  800b34:	89 ce                	mov    %ecx,%esi
  800b36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	7e 17                	jle    800b53 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	50                   	push   %eax
  800b40:	6a 03                	push   $0x3
  800b42:	68 3f 2a 80 00       	push   $0x802a3f
  800b47:	6a 23                	push   $0x23
  800b49:	68 5c 2a 80 00       	push   $0x802a5c
  800b4e:	e8 dd 17 00 00       	call   802330 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_yield>:

void
sys_yield(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	be 00 00 00 00       	mov    $0x0,%esi
  800ba7:	b8 04 00 00 00       	mov    $0x4,%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb5:	89 f7                	mov    %esi,%edi
  800bb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 04                	push   $0x4
  800bc3:	68 3f 2a 80 00       	push   $0x802a3f
  800bc8:	6a 23                	push   $0x23
  800bca:	68 5c 2a 80 00       	push   $0x802a5c
  800bcf:	e8 5c 17 00 00       	call   802330 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf6:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 05                	push   $0x5
  800c05:	68 3f 2a 80 00       	push   $0x802a3f
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 5c 2a 80 00       	push   $0x802a5c
  800c11:	e8 1a 17 00 00       	call   802330 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 06                	push   $0x6
  800c47:	68 3f 2a 80 00       	push   $0x802a3f
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 5c 2a 80 00       	push   $0x802a5c
  800c53:	e8 d8 16 00 00       	call   802330 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 08                	push   $0x8
  800c89:	68 3f 2a 80 00       	push   $0x802a3f
  800c8e:	6a 23                	push   $0x23
  800c90:	68 5c 2a 80 00       	push   $0x802a5c
  800c95:	e8 96 16 00 00       	call   802330 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 09                	push   $0x9
  800ccb:	68 3f 2a 80 00       	push   $0x802a3f
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 5c 2a 80 00       	push   $0x802a5c
  800cd7:	e8 54 16 00 00       	call   802330 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 0a                	push   $0xa
  800d0d:	68 3f 2a 80 00       	push   $0x802a3f
  800d12:	6a 23                	push   $0x23
  800d14:	68 5c 2a 80 00       	push   $0x802a5c
  800d19:	e8 12 16 00 00       	call   802330 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d2c:	be 00 00 00 00       	mov    $0x0,%esi
  800d31:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d42:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
  800d4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 cb                	mov    %ecx,%ebx
  800d61:	89 cf                	mov    %ecx,%edi
  800d63:	89 ce                	mov    %ecx,%esi
  800d65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 0d                	push   $0xd
  800d71:	68 3f 2a 80 00       	push   $0x802a3f
  800d76:	6a 23                	push   $0x23
  800d78:	68 5c 2a 80 00       	push   $0x802a5c
  800d7d:	e8 ae 15 00 00       	call   802330 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9a:	89 d1                	mov    %edx,%ecx
  800d9c:	89 d3                	mov    %edx,%ebx
  800d9e:	89 d7                	mov    %edx,%edi
  800da0:	89 d6                	mov    %edx,%esi
  800da2:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	53                   	push   %ebx
  800dad:	83 ec 04             	sub    $0x4,%esp
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800db3:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800db5:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800db8:	f6 c1 02             	test   $0x2,%cl
  800dbb:	74 2e                	je     800deb <pgfault+0x42>
  800dbd:	89 c2                	mov    %eax,%edx
  800dbf:	c1 ea 16             	shr    $0x16,%edx
  800dc2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc9:	f6 c2 01             	test   $0x1,%dl
  800dcc:	74 1d                	je     800deb <pgfault+0x42>
  800dce:	89 c2                	mov    %eax,%edx
  800dd0:	c1 ea 0c             	shr    $0xc,%edx
  800dd3:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800dda:	f6 c3 01             	test   $0x1,%bl
  800ddd:	74 0c                	je     800deb <pgfault+0x42>
  800ddf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de6:	f6 c6 08             	test   $0x8,%dh
  800de9:	75 12                	jne    800dfd <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800deb:	51                   	push   %ecx
  800dec:	68 6a 2a 80 00       	push   $0x802a6a
  800df1:	6a 1e                	push   $0x1e
  800df3:	68 83 2a 80 00       	push   $0x802a83
  800df8:	e8 33 15 00 00       	call   802330 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800dfd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e02:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	6a 07                	push   $0x7
  800e09:	68 00 f0 7f 00       	push   $0x7ff000
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 84 fd ff ff       	call   800b99 <sys_page_alloc>
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	79 12                	jns    800e2e <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800e1c:	50                   	push   %eax
  800e1d:	68 8e 2a 80 00       	push   $0x802a8e
  800e22:	6a 29                	push   $0x29
  800e24:	68 83 2a 80 00       	push   $0x802a83
  800e29:	e8 02 15 00 00       	call   802330 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	68 00 10 00 00       	push   $0x1000
  800e36:	53                   	push   %ebx
  800e37:	68 00 f0 7f 00       	push   $0x7ff000
  800e3c:	e8 4f fb ff ff       	call   800990 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e41:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e48:	53                   	push   %ebx
  800e49:	6a 00                	push   $0x0
  800e4b:	68 00 f0 7f 00       	push   $0x7ff000
  800e50:	6a 00                	push   $0x0
  800e52:	e8 85 fd ff ff       	call   800bdc <sys_page_map>
  800e57:	83 c4 20             	add    $0x20,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	79 12                	jns    800e70 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800e5e:	50                   	push   %eax
  800e5f:	68 a9 2a 80 00       	push   $0x802aa9
  800e64:	6a 2e                	push   $0x2e
  800e66:	68 83 2a 80 00       	push   $0x802a83
  800e6b:	e8 c0 14 00 00       	call   802330 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	68 00 f0 7f 00       	push   $0x7ff000
  800e78:	6a 00                	push   $0x0
  800e7a:	e8 9f fd ff ff       	call   800c1e <sys_page_unmap>
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	79 12                	jns    800e98 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800e86:	50                   	push   %eax
  800e87:	68 c2 2a 80 00       	push   $0x802ac2
  800e8c:	6a 31                	push   $0x31
  800e8e:	68 83 2a 80 00       	push   $0x802a83
  800e93:	e8 98 14 00 00       	call   802330 <_panic>

}
  800e98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9b:	c9                   	leave  
  800e9c:	c3                   	ret    

00800e9d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800ea6:	68 a9 0d 80 00       	push   $0x800da9
  800eab:	e8 c6 14 00 00       	call   802376 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800eb0:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb5:	cd 30                	int    $0x30
  800eb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800eba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	75 21                	jne    800eea <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ec9:	e8 8d fc ff ff       	call   800b5b <sys_getenvid>
  800ece:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ed6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edb:	a3 0c 40 80 00       	mov    %eax,0x80400c
		return 0;
  800ee0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee5:	e9 c9 01 00 00       	jmp    8010b3 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800eea:	89 d8                	mov    %ebx,%eax
  800eec:	c1 e8 16             	shr    $0x16,%eax
  800eef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ef6:	a8 01                	test   $0x1,%al
  800ef8:	0f 84 1b 01 00 00    	je     801019 <fork+0x17c>
  800efe:	89 de                	mov    %ebx,%esi
  800f00:	c1 ee 0c             	shr    $0xc,%esi
  800f03:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f0a:	a8 01                	test   $0x1,%al
  800f0c:	0f 84 07 01 00 00    	je     801019 <fork+0x17c>
  800f12:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f19:	a8 04                	test   $0x4,%al
  800f1b:	0f 84 f8 00 00 00    	je     801019 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800f21:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f28:	f6 c4 04             	test   $0x4,%ah
  800f2b:	74 3c                	je     800f69 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800f2d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f34:	c1 e6 0c             	shl    $0xc,%esi
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	25 07 0e 00 00       	and    $0xe07,%eax
  800f3f:	50                   	push   %eax
  800f40:	56                   	push   %esi
  800f41:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f44:	56                   	push   %esi
  800f45:	6a 00                	push   $0x0
  800f47:	e8 90 fc ff ff       	call   800bdc <sys_page_map>
  800f4c:	83 c4 20             	add    $0x20,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	0f 89 c2 00 00 00    	jns    801019 <fork+0x17c>
			panic("duppage: %e", r);
  800f57:	50                   	push   %eax
  800f58:	68 dd 2a 80 00       	push   $0x802add
  800f5d:	6a 48                	push   $0x48
  800f5f:	68 83 2a 80 00       	push   $0x802a83
  800f64:	e8 c7 13 00 00       	call   802330 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  800f69:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f70:	f6 c4 08             	test   $0x8,%ah
  800f73:	75 0b                	jne    800f80 <fork+0xe3>
  800f75:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f7c:	a8 02                	test   $0x2,%al
  800f7e:	74 6c                	je     800fec <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  800f80:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f87:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  800f8a:	83 f8 01             	cmp    $0x1,%eax
  800f8d:	19 ff                	sbb    %edi,%edi
  800f8f:	83 e7 fc             	and    $0xfffffffc,%edi
  800f92:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  800f98:	c1 e6 0c             	shl    $0xc,%esi
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa3:	56                   	push   %esi
  800fa4:	6a 00                	push   $0x0
  800fa6:	e8 31 fc ff ff       	call   800bdc <sys_page_map>
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	79 12                	jns    800fc4 <fork+0x127>
			panic("duppage: %e", r);
  800fb2:	50                   	push   %eax
  800fb3:	68 dd 2a 80 00       	push   $0x802add
  800fb8:	6a 50                	push   $0x50
  800fba:	68 83 2a 80 00       	push   $0x802a83
  800fbf:	e8 6c 13 00 00       	call   802330 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	6a 00                	push   $0x0
  800fcb:	56                   	push   %esi
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 09 fc ff ff       	call   800bdc <sys_page_map>
  800fd3:	83 c4 20             	add    $0x20,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	79 3f                	jns    801019 <fork+0x17c>
			panic("duppage: %e", r);
  800fda:	50                   	push   %eax
  800fdb:	68 dd 2a 80 00       	push   $0x802add
  800fe0:	6a 53                	push   $0x53
  800fe2:	68 83 2a 80 00       	push   $0x802a83
  800fe7:	e8 44 13 00 00       	call   802330 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  800fec:	c1 e6 0c             	shl    $0xc,%esi
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	6a 05                	push   $0x5
  800ff4:	56                   	push   %esi
  800ff5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff8:	56                   	push   %esi
  800ff9:	6a 00                	push   $0x0
  800ffb:	e8 dc fb ff ff       	call   800bdc <sys_page_map>
  801000:	83 c4 20             	add    $0x20,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	79 12                	jns    801019 <fork+0x17c>
			panic("duppage: %e", r);
  801007:	50                   	push   %eax
  801008:	68 dd 2a 80 00       	push   $0x802add
  80100d:	6a 57                	push   $0x57
  80100f:	68 83 2a 80 00       	push   $0x802a83
  801014:	e8 17 13 00 00       	call   802330 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  801019:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80101f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801025:	0f 85 bf fe ff ff    	jne    800eea <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	6a 07                	push   $0x7
  801030:	68 00 f0 bf ee       	push   $0xeebff000
  801035:	ff 75 e0             	pushl  -0x20(%ebp)
  801038:	e8 5c fb ff ff       	call   800b99 <sys_page_alloc>
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	74 17                	je     80105b <fork+0x1be>
		panic("sys_page_alloc Error");
  801044:	83 ec 04             	sub    $0x4,%esp
  801047:	68 e9 2a 80 00       	push   $0x802ae9
  80104c:	68 83 00 00 00       	push   $0x83
  801051:	68 83 2a 80 00       	push   $0x802a83
  801056:	e8 d5 12 00 00       	call   802330 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  80105b:	83 ec 08             	sub    $0x8,%esp
  80105e:	68 e5 23 80 00       	push   $0x8023e5
  801063:	ff 75 e0             	pushl  -0x20(%ebp)
  801066:	e8 79 fc ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	79 15                	jns    801087 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801072:	50                   	push   %eax
  801073:	68 fe 2a 80 00       	push   $0x802afe
  801078:	68 86 00 00 00       	push   $0x86
  80107d:	68 83 2a 80 00       	push   $0x802a83
  801082:	e8 a9 12 00 00       	call   802330 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	6a 02                	push   $0x2
  80108c:	ff 75 e0             	pushl  -0x20(%ebp)
  80108f:	e8 cc fb ff ff       	call   800c60 <sys_env_set_status>
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	79 15                	jns    8010b0 <fork+0x213>
		panic("fork set status: %e", r);
  80109b:	50                   	push   %eax
  80109c:	68 16 2b 80 00       	push   $0x802b16
  8010a1:	68 89 00 00 00       	push   $0x89
  8010a6:	68 83 2a 80 00       	push   $0x802a83
  8010ab:	e8 80 12 00 00       	call   802330 <_panic>
	
	return envid;
  8010b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  8010b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b6:	5b                   	pop    %ebx
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <sfork>:


// Challenge!
int
sfork(void)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c1:	68 2a 2b 80 00       	push   $0x802b2a
  8010c6:	68 93 00 00 00       	push   $0x93
  8010cb:	68 83 2a 80 00       	push   $0x802a83
  8010d0:	e8 5b 12 00 00       	call   802330 <_panic>

008010d5 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	56                   	push   %esi
  8010d9:	53                   	push   %ebx
  8010da:	8b 75 08             	mov    0x8(%ebp),%esi
  8010dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	74 0e                	je     8010f5 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	50                   	push   %eax
  8010eb:	e8 59 fc ff ff       	call   800d49 <sys_ipc_recv>
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	eb 10                	jmp    801105 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	68 00 00 c0 ee       	push   $0xeec00000
  8010fd:	e8 47 fc ff ff       	call   800d49 <sys_ipc_recv>
  801102:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801105:	85 c0                	test   %eax,%eax
  801107:	79 17                	jns    801120 <ipc_recv+0x4b>
		if(*from_env_store)
  801109:	83 3e 00             	cmpl   $0x0,(%esi)
  80110c:	74 06                	je     801114 <ipc_recv+0x3f>
			*from_env_store = 0;
  80110e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801114:	85 db                	test   %ebx,%ebx
  801116:	74 2c                	je     801144 <ipc_recv+0x6f>
			*perm_store = 0;
  801118:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80111e:	eb 24                	jmp    801144 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801120:	85 f6                	test   %esi,%esi
  801122:	74 0a                	je     80112e <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801124:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801129:	8b 40 74             	mov    0x74(%eax),%eax
  80112c:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80112e:	85 db                	test   %ebx,%ebx
  801130:	74 0a                	je     80113c <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801132:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801137:	8b 40 78             	mov    0x78(%eax),%eax
  80113a:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80113c:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801141:	8b 40 70             	mov    0x70(%eax),%eax
}
  801144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801147:	5b                   	pop    %ebx
  801148:	5e                   	pop    %esi
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	57                   	push   %edi
  80114f:	56                   	push   %esi
  801150:	53                   	push   %ebx
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	8b 7d 08             	mov    0x8(%ebp),%edi
  801157:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80115d:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80115f:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801164:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801167:	e8 0e fa ff ff       	call   800b7a <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80116c:	ff 75 14             	pushl  0x14(%ebp)
  80116f:	53                   	push   %ebx
  801170:	56                   	push   %esi
  801171:	57                   	push   %edi
  801172:	e8 af fb ff ff       	call   800d26 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801177:	89 c2                	mov    %eax,%edx
  801179:	f7 d2                	not    %edx
  80117b:	c1 ea 1f             	shr    $0x1f,%edx
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801184:	0f 94 c1             	sete   %cl
  801187:	09 ca                	or     %ecx,%edx
  801189:	85 c0                	test   %eax,%eax
  80118b:	0f 94 c0             	sete   %al
  80118e:	38 c2                	cmp    %al,%dl
  801190:	77 d5                	ja     801167 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011a5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011a8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011ae:	8b 52 50             	mov    0x50(%edx),%edx
  8011b1:	39 ca                	cmp    %ecx,%edx
  8011b3:	75 0d                	jne    8011c2 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011b5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011bd:	8b 40 48             	mov    0x48(%eax),%eax
  8011c0:	eb 0f                	jmp    8011d1 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011c2:	83 c0 01             	add    $0x1,%eax
  8011c5:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ca:	75 d9                	jne    8011a5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011de:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801200:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 16             	shr    $0x16,%edx
  80120a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	74 11                	je     801227 <fd_alloc+0x2d>
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 0c             	shr    $0xc,%edx
  80121b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	75 09                	jne    801230 <fd_alloc+0x36>
			*fd_store = fd;
  801227:	89 01                	mov    %eax,(%ecx)
			return 0;
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
  80122e:	eb 17                	jmp    801247 <fd_alloc+0x4d>
  801230:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801235:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123a:	75 c9                	jne    801205 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801242:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80124f:	83 f8 1f             	cmp    $0x1f,%eax
  801252:	77 36                	ja     80128a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801254:	c1 e0 0c             	shl    $0xc,%eax
  801257:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	c1 ea 16             	shr    $0x16,%edx
  801261:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801268:	f6 c2 01             	test   $0x1,%dl
  80126b:	74 24                	je     801291 <fd_lookup+0x48>
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	c1 ea 0c             	shr    $0xc,%edx
  801272:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	74 1a                	je     801298 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801281:	89 02                	mov    %eax,(%edx)
	return 0;
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
  801288:	eb 13                	jmp    80129d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128f:	eb 0c                	jmp    80129d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801296:	eb 05                	jmp    80129d <fd_lookup+0x54>
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a8:	ba bc 2b 80 00       	mov    $0x802bbc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ad:	eb 13                	jmp    8012c2 <dev_lookup+0x23>
  8012af:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b2:	39 08                	cmp    %ecx,(%eax)
  8012b4:	75 0c                	jne    8012c2 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c0:	eb 2e                	jmp    8012f0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c2:	8b 02                	mov    (%edx),%eax
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	75 e7                	jne    8012af <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c8:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8012cd:	8b 40 48             	mov    0x48(%eax),%eax
  8012d0:	83 ec 04             	sub    $0x4,%esp
  8012d3:	51                   	push   %ecx
  8012d4:	50                   	push   %eax
  8012d5:	68 40 2b 80 00       	push   $0x802b40
  8012da:	e8 12 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8012df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	56                   	push   %esi
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 10             	sub    $0x10,%esp
  8012fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130a:	c1 e8 0c             	shr    $0xc,%eax
  80130d:	50                   	push   %eax
  80130e:	e8 36 ff ff ff       	call   801249 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 05                	js     80131f <fd_close+0x2d>
	    || fd != fd2)
  80131a:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131d:	74 0c                	je     80132b <fd_close+0x39>
		return (must_exist ? r : 0);
  80131f:	84 db                	test   %bl,%bl
  801321:	ba 00 00 00 00       	mov    $0x0,%edx
  801326:	0f 44 c2             	cmove  %edx,%eax
  801329:	eb 41                	jmp    80136c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132b:	83 ec 08             	sub    $0x8,%esp
  80132e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801331:	50                   	push   %eax
  801332:	ff 36                	pushl  (%esi)
  801334:	e8 66 ff ff ff       	call   80129f <dev_lookup>
  801339:	89 c3                	mov    %eax,%ebx
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 1a                	js     80135c <fd_close+0x6a>
		if (dev->dev_close)
  801342:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801345:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801348:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134d:	85 c0                	test   %eax,%eax
  80134f:	74 0b                	je     80135c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801351:	83 ec 0c             	sub    $0xc,%esp
  801354:	56                   	push   %esi
  801355:	ff d0                	call   *%eax
  801357:	89 c3                	mov    %eax,%ebx
  801359:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135c:	83 ec 08             	sub    $0x8,%esp
  80135f:	56                   	push   %esi
  801360:	6a 00                	push   $0x0
  801362:	e8 b7 f8 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	89 d8                	mov    %ebx,%eax
}
  80136c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801379:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 c4 fe ff ff       	call   801249 <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 10                	js     80139c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	6a 01                	push   $0x1
  801391:	ff 75 f4             	pushl  -0xc(%ebp)
  801394:	e8 59 ff ff ff       	call   8012f2 <fd_close>
  801399:	83 c4 10             	add    $0x10,%esp
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <close_all>:

void
close_all(void)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	e8 c0 ff ff ff       	call   801373 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	83 c3 01             	add    $0x1,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	83 fb 20             	cmp    $0x20,%ebx
  8013bc:	75 ec                	jne    8013aa <close_all+0xc>
		close(i);
}
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	57                   	push   %edi
  8013c7:	56                   	push   %esi
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 2c             	sub    $0x2c,%esp
  8013cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 75 08             	pushl  0x8(%ebp)
  8013d6:	e8 6e fe ff ff       	call   801249 <fd_lookup>
  8013db:	83 c4 08             	add    $0x8,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	0f 88 c1 00 00 00    	js     8014a7 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	56                   	push   %esi
  8013ea:	e8 84 ff ff ff       	call   801373 <close>

	newfd = INDEX2FD(newfdnum);
  8013ef:	89 f3                	mov    %esi,%ebx
  8013f1:	c1 e3 0c             	shl    $0xc,%ebx
  8013f4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013fa:	83 c4 04             	add    $0x4,%esp
  8013fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801400:	e8 de fd ff ff       	call   8011e3 <fd2data>
  801405:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801407:	89 1c 24             	mov    %ebx,(%esp)
  80140a:	e8 d4 fd ff ff       	call   8011e3 <fd2data>
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801415:	89 f8                	mov    %edi,%eax
  801417:	c1 e8 16             	shr    $0x16,%eax
  80141a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801421:	a8 01                	test   $0x1,%al
  801423:	74 37                	je     80145c <dup+0x99>
  801425:	89 f8                	mov    %edi,%eax
  801427:	c1 e8 0c             	shr    $0xc,%eax
  80142a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801431:	f6 c2 01             	test   $0x1,%dl
  801434:	74 26                	je     80145c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801436:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143d:	83 ec 0c             	sub    $0xc,%esp
  801440:	25 07 0e 00 00       	and    $0xe07,%eax
  801445:	50                   	push   %eax
  801446:	ff 75 d4             	pushl  -0x2c(%ebp)
  801449:	6a 00                	push   $0x0
  80144b:	57                   	push   %edi
  80144c:	6a 00                	push   $0x0
  80144e:	e8 89 f7 ff ff       	call   800bdc <sys_page_map>
  801453:	89 c7                	mov    %eax,%edi
  801455:	83 c4 20             	add    $0x20,%esp
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 2e                	js     80148a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80145f:	89 d0                	mov    %edx,%eax
  801461:	c1 e8 0c             	shr    $0xc,%eax
  801464:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146b:	83 ec 0c             	sub    $0xc,%esp
  80146e:	25 07 0e 00 00       	and    $0xe07,%eax
  801473:	50                   	push   %eax
  801474:	53                   	push   %ebx
  801475:	6a 00                	push   $0x0
  801477:	52                   	push   %edx
  801478:	6a 00                	push   $0x0
  80147a:	e8 5d f7 ff ff       	call   800bdc <sys_page_map>
  80147f:	89 c7                	mov    %eax,%edi
  801481:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801484:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801486:	85 ff                	test   %edi,%edi
  801488:	79 1d                	jns    8014a7 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148a:	83 ec 08             	sub    $0x8,%esp
  80148d:	53                   	push   %ebx
  80148e:	6a 00                	push   $0x0
  801490:	e8 89 f7 ff ff       	call   800c1e <sys_page_unmap>
	sys_page_unmap(0, nva);
  801495:	83 c4 08             	add    $0x8,%esp
  801498:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149b:	6a 00                	push   $0x0
  80149d:	e8 7c f7 ff ff       	call   800c1e <sys_page_unmap>
	return r;
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	89 f8                	mov    %edi,%eax
}
  8014a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014aa:	5b                   	pop    %ebx
  8014ab:	5e                   	pop    %esi
  8014ac:	5f                   	pop    %edi
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 14             	sub    $0x14,%esp
  8014b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	53                   	push   %ebx
  8014be:	e8 86 fd ff ff       	call   801249 <fd_lookup>
  8014c3:	83 c4 08             	add    $0x8,%esp
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 6d                	js     801539 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d6:	ff 30                	pushl  (%eax)
  8014d8:	e8 c2 fd ff ff       	call   80129f <dev_lookup>
  8014dd:	83 c4 10             	add    $0x10,%esp
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 4c                	js     801530 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e7:	8b 42 08             	mov    0x8(%edx),%eax
  8014ea:	83 e0 03             	and    $0x3,%eax
  8014ed:	83 f8 01             	cmp    $0x1,%eax
  8014f0:	75 21                	jne    801513 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8014f7:	8b 40 48             	mov    0x48(%eax),%eax
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	53                   	push   %ebx
  8014fe:	50                   	push   %eax
  8014ff:	68 81 2b 80 00       	push   $0x802b81
  801504:	e8 e8 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801511:	eb 26                	jmp    801539 <read+0x8a>
	}
	if (!dev->dev_read)
  801513:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801516:	8b 40 08             	mov    0x8(%eax),%eax
  801519:	85 c0                	test   %eax,%eax
  80151b:	74 17                	je     801534 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151d:	83 ec 04             	sub    $0x4,%esp
  801520:	ff 75 10             	pushl  0x10(%ebp)
  801523:	ff 75 0c             	pushl  0xc(%ebp)
  801526:	52                   	push   %edx
  801527:	ff d0                	call   *%eax
  801529:	89 c2                	mov    %eax,%edx
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	eb 09                	jmp    801539 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	89 c2                	mov    %eax,%edx
  801532:	eb 05                	jmp    801539 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801534:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801539:	89 d0                	mov    %edx,%eax
  80153b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	57                   	push   %edi
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801554:	eb 21                	jmp    801577 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	89 f0                	mov    %esi,%eax
  80155b:	29 d8                	sub    %ebx,%eax
  80155d:	50                   	push   %eax
  80155e:	89 d8                	mov    %ebx,%eax
  801560:	03 45 0c             	add    0xc(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	57                   	push   %edi
  801565:	e8 45 ff ff ff       	call   8014af <read>
		if (m < 0)
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 10                	js     801581 <readn+0x41>
			return m;
		if (m == 0)
  801571:	85 c0                	test   %eax,%eax
  801573:	74 0a                	je     80157f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801575:	01 c3                	add    %eax,%ebx
  801577:	39 f3                	cmp    %esi,%ebx
  801579:	72 db                	jb     801556 <readn+0x16>
  80157b:	89 d8                	mov    %ebx,%eax
  80157d:	eb 02                	jmp    801581 <readn+0x41>
  80157f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801581:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801584:	5b                   	pop    %ebx
  801585:	5e                   	pop    %esi
  801586:	5f                   	pop    %edi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    

00801589 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	53                   	push   %ebx
  80158d:	83 ec 14             	sub    $0x14,%esp
  801590:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801593:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801596:	50                   	push   %eax
  801597:	53                   	push   %ebx
  801598:	e8 ac fc ff ff       	call   801249 <fd_lookup>
  80159d:	83 c4 08             	add    $0x8,%esp
  8015a0:	89 c2                	mov    %eax,%edx
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 68                	js     80160e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b0:	ff 30                	pushl  (%eax)
  8015b2:	e8 e8 fc ff ff       	call   80129f <dev_lookup>
  8015b7:	83 c4 10             	add    $0x10,%esp
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 47                	js     801605 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c5:	75 21                	jne    8015e8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c7:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8015cc:	8b 40 48             	mov    0x48(%eax),%eax
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	50                   	push   %eax
  8015d4:	68 9d 2b 80 00       	push   $0x802b9d
  8015d9:	e8 13 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e6:	eb 26                	jmp    80160e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ee:	85 d2                	test   %edx,%edx
  8015f0:	74 17                	je     801609 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	ff 75 10             	pushl  0x10(%ebp)
  8015f8:	ff 75 0c             	pushl  0xc(%ebp)
  8015fb:	50                   	push   %eax
  8015fc:	ff d2                	call   *%edx
  8015fe:	89 c2                	mov    %eax,%edx
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb 09                	jmp    80160e <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	89 c2                	mov    %eax,%edx
  801607:	eb 05                	jmp    80160e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801609:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160e:	89 d0                	mov    %edx,%eax
  801610:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801613:	c9                   	leave  
  801614:	c3                   	ret    

00801615 <seek>:

int
seek(int fdnum, off_t offset)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161e:	50                   	push   %eax
  80161f:	ff 75 08             	pushl  0x8(%ebp)
  801622:	e8 22 fc ff ff       	call   801249 <fd_lookup>
  801627:	83 c4 08             	add    $0x8,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 0e                	js     80163c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801631:	8b 55 0c             	mov    0xc(%ebp),%edx
  801634:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801637:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	53                   	push   %ebx
  801642:	83 ec 14             	sub    $0x14,%esp
  801645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164b:	50                   	push   %eax
  80164c:	53                   	push   %ebx
  80164d:	e8 f7 fb ff ff       	call   801249 <fd_lookup>
  801652:	83 c4 08             	add    $0x8,%esp
  801655:	89 c2                	mov    %eax,%edx
  801657:	85 c0                	test   %eax,%eax
  801659:	78 65                	js     8016c0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165b:	83 ec 08             	sub    $0x8,%esp
  80165e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	ff 30                	pushl  (%eax)
  801667:	e8 33 fc ff ff       	call   80129f <dev_lookup>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 44                	js     8016b7 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167a:	75 21                	jne    80169d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167c:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801681:	8b 40 48             	mov    0x48(%eax),%eax
  801684:	83 ec 04             	sub    $0x4,%esp
  801687:	53                   	push   %ebx
  801688:	50                   	push   %eax
  801689:	68 60 2b 80 00       	push   $0x802b60
  80168e:	e8 5e eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169b:	eb 23                	jmp    8016c0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a0:	8b 52 18             	mov    0x18(%edx),%edx
  8016a3:	85 d2                	test   %edx,%edx
  8016a5:	74 14                	je     8016bb <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	50                   	push   %eax
  8016ae:	ff d2                	call   *%edx
  8016b0:	89 c2                	mov    %eax,%edx
  8016b2:	83 c4 10             	add    $0x10,%esp
  8016b5:	eb 09                	jmp    8016c0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b7:	89 c2                	mov    %eax,%edx
  8016b9:	eb 05                	jmp    8016c0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c0:	89 d0                	mov    %edx,%eax
  8016c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 14             	sub    $0x14,%esp
  8016ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	ff 75 08             	pushl  0x8(%ebp)
  8016d8:	e8 6c fb ff ff       	call   801249 <fd_lookup>
  8016dd:	83 c4 08             	add    $0x8,%esp
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 58                	js     80173e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	ff 30                	pushl  (%eax)
  8016f2:	e8 a8 fb ff ff       	call   80129f <dev_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 37                	js     801735 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801701:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801705:	74 32                	je     801739 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801707:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801711:	00 00 00 
	stat->st_isdir = 0;
  801714:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171b:	00 00 00 
	stat->st_dev = dev;
  80171e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	53                   	push   %ebx
  801728:	ff 75 f0             	pushl  -0x10(%ebp)
  80172b:	ff 50 14             	call   *0x14(%eax)
  80172e:	89 c2                	mov    %eax,%edx
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	eb 09                	jmp    80173e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801735:	89 c2                	mov    %eax,%edx
  801737:	eb 05                	jmp    80173e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801739:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173e:	89 d0                	mov    %edx,%eax
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174a:	83 ec 08             	sub    $0x8,%esp
  80174d:	6a 00                	push   $0x0
  80174f:	ff 75 08             	pushl  0x8(%ebp)
  801752:	e8 ef 01 00 00       	call   801946 <open>
  801757:	89 c3                	mov    %eax,%ebx
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 1b                	js     80177b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	ff 75 0c             	pushl  0xc(%ebp)
  801766:	50                   	push   %eax
  801767:	e8 5b ff ff ff       	call   8016c7 <fstat>
  80176c:	89 c6                	mov    %eax,%esi
	close(fd);
  80176e:	89 1c 24             	mov    %ebx,(%esp)
  801771:	e8 fd fb ff ff       	call   801373 <close>
	return r;
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	89 f0                	mov    %esi,%eax
}
  80177b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	56                   	push   %esi
  801786:	53                   	push   %ebx
  801787:	89 c6                	mov    %eax,%esi
  801789:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80178b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801792:	75 12                	jne    8017a6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801794:	83 ec 0c             	sub    $0xc,%esp
  801797:	6a 01                	push   $0x1
  801799:	e8 fc f9 ff ff       	call   80119a <ipc_find_env>
  80179e:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a6:	6a 07                	push   $0x7
  8017a8:	68 00 50 80 00       	push   $0x805000
  8017ad:	56                   	push   %esi
  8017ae:	ff 35 00 40 80 00    	pushl  0x804000
  8017b4:	e8 92 f9 ff ff       	call   80114b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b9:	83 c4 0c             	add    $0xc,%esp
  8017bc:	6a 00                	push   $0x0
  8017be:	53                   	push   %ebx
  8017bf:	6a 00                	push   $0x0
  8017c1:	e8 0f f9 ff ff       	call   8010d5 <ipc_recv>
}
  8017c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017c9:	5b                   	pop    %ebx
  8017ca:	5e                   	pop    %esi
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f0:	e8 8d ff ff ff       	call   801782 <fsipc>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	8b 40 0c             	mov    0xc(%eax),%eax
  801803:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801808:	ba 00 00 00 00       	mov    $0x0,%edx
  80180d:	b8 06 00 00 00       	mov    $0x6,%eax
  801812:	e8 6b ff ff ff       	call   801782 <fsipc>
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	53                   	push   %ebx
  80181d:	83 ec 04             	sub    $0x4,%esp
  801820:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801823:	8b 45 08             	mov    0x8(%ebp),%eax
  801826:	8b 40 0c             	mov    0xc(%eax),%eax
  801829:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	b8 05 00 00 00       	mov    $0x5,%eax
  801838:	e8 45 ff ff ff       	call   801782 <fsipc>
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 2c                	js     80186d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801841:	83 ec 08             	sub    $0x8,%esp
  801844:	68 00 50 80 00       	push   $0x805000
  801849:	53                   	push   %ebx
  80184a:	e8 47 ef ff ff       	call   800796 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80184f:	a1 80 50 80 00       	mov    0x805080,%eax
  801854:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185a:	a1 84 50 80 00       	mov    0x805084,%eax
  80185f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80187c:	8b 55 08             	mov    0x8(%ebp),%edx
  80187f:	8b 52 0c             	mov    0xc(%edx),%edx
  801882:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801888:	a3 04 50 80 00       	mov    %eax,0x805004
  80188d:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801892:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801897:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80189a:	53                   	push   %ebx
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	68 08 50 80 00       	push   $0x805008
  8018a3:	e8 80 f0 ff ff       	call   800928 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b2:	e8 cb fe ff ff       	call   801782 <fsipc>
  8018b7:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8018bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c2:	c9                   	leave  
  8018c3:	c3                   	ret    

008018c4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e7:	e8 96 fe ff ff       	call   801782 <fsipc>
  8018ec:	89 c3                	mov    %eax,%ebx
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	78 4b                	js     80193d <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018f2:	39 c6                	cmp    %eax,%esi
  8018f4:	73 16                	jae    80190c <devfile_read+0x48>
  8018f6:	68 d0 2b 80 00       	push   $0x802bd0
  8018fb:	68 d7 2b 80 00       	push   $0x802bd7
  801900:	6a 7c                	push   $0x7c
  801902:	68 ec 2b 80 00       	push   $0x802bec
  801907:	e8 24 0a 00 00       	call   802330 <_panic>
	assert(r <= PGSIZE);
  80190c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801911:	7e 16                	jle    801929 <devfile_read+0x65>
  801913:	68 f7 2b 80 00       	push   $0x802bf7
  801918:	68 d7 2b 80 00       	push   $0x802bd7
  80191d:	6a 7d                	push   $0x7d
  80191f:	68 ec 2b 80 00       	push   $0x802bec
  801924:	e8 07 0a 00 00       	call   802330 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801929:	83 ec 04             	sub    $0x4,%esp
  80192c:	50                   	push   %eax
  80192d:	68 00 50 80 00       	push   $0x805000
  801932:	ff 75 0c             	pushl  0xc(%ebp)
  801935:	e8 ee ef ff ff       	call   800928 <memmove>
	return r;
  80193a:	83 c4 10             	add    $0x10,%esp
}
  80193d:	89 d8                	mov    %ebx,%eax
  80193f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	53                   	push   %ebx
  80194a:	83 ec 20             	sub    $0x20,%esp
  80194d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801950:	53                   	push   %ebx
  801951:	e8 07 ee ff ff       	call   80075d <strlen>
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195e:	7f 67                	jg     8019c7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801960:	83 ec 0c             	sub    $0xc,%esp
  801963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801966:	50                   	push   %eax
  801967:	e8 8e f8 ff ff       	call   8011fa <fd_alloc>
  80196c:	83 c4 10             	add    $0x10,%esp
		return r;
  80196f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801971:	85 c0                	test   %eax,%eax
  801973:	78 57                	js     8019cc <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801975:	83 ec 08             	sub    $0x8,%esp
  801978:	53                   	push   %ebx
  801979:	68 00 50 80 00       	push   $0x805000
  80197e:	e8 13 ee ff ff       	call   800796 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801983:	8b 45 0c             	mov    0xc(%ebp),%eax
  801986:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80198b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198e:	b8 01 00 00 00       	mov    $0x1,%eax
  801993:	e8 ea fd ff ff       	call   801782 <fsipc>
  801998:	89 c3                	mov    %eax,%ebx
  80199a:	83 c4 10             	add    $0x10,%esp
  80199d:	85 c0                	test   %eax,%eax
  80199f:	79 14                	jns    8019b5 <open+0x6f>
		fd_close(fd, 0);
  8019a1:	83 ec 08             	sub    $0x8,%esp
  8019a4:	6a 00                	push   $0x0
  8019a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a9:	e8 44 f9 ff ff       	call   8012f2 <fd_close>
		return r;
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	89 da                	mov    %ebx,%edx
  8019b3:	eb 17                	jmp    8019cc <open+0x86>
	}

	return fd2num(fd);
  8019b5:	83 ec 0c             	sub    $0xc,%esp
  8019b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bb:	e8 13 f8 ff ff       	call   8011d3 <fd2num>
  8019c0:	89 c2                	mov    %eax,%edx
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	eb 05                	jmp    8019cc <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019cc:	89 d0                	mov    %edx,%eax
  8019ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019de:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e3:	e8 9a fd ff ff       	call   801782 <fsipc>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	ff 75 08             	pushl  0x8(%ebp)
  8019f8:	e8 e6 f7 ff ff       	call   8011e3 <fd2data>
  8019fd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ff:	83 c4 08             	add    $0x8,%esp
  801a02:	68 03 2c 80 00       	push   $0x802c03
  801a07:	53                   	push   %ebx
  801a08:	e8 89 ed ff ff       	call   800796 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0d:	8b 46 04             	mov    0x4(%esi),%eax
  801a10:	2b 06                	sub    (%esi),%eax
  801a12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a18:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1f:	00 00 00 
	stat->st_dev = &devpipe;
  801a22:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a29:	30 80 00 
	return 0;
}
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a42:	53                   	push   %ebx
  801a43:	6a 00                	push   $0x0
  801a45:	e8 d4 f1 ff ff       	call   800c1e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a4a:	89 1c 24             	mov    %ebx,(%esp)
  801a4d:	e8 91 f7 ff ff       	call   8011e3 <fd2data>
  801a52:	83 c4 08             	add    $0x8,%esp
  801a55:	50                   	push   %eax
  801a56:	6a 00                	push   $0x0
  801a58:	e8 c1 f1 ff ff       	call   800c1e <sys_page_unmap>
}
  801a5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	57                   	push   %edi
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	83 ec 1c             	sub    $0x1c,%esp
  801a6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a6e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a70:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801a75:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7e:	e8 89 09 00 00       	call   80240c <pageref>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	89 3c 24             	mov    %edi,(%esp)
  801a88:	e8 7f 09 00 00       	call   80240c <pageref>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	39 c3                	cmp    %eax,%ebx
  801a92:	0f 94 c1             	sete   %cl
  801a95:	0f b6 c9             	movzbl %cl,%ecx
  801a98:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a9b:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801aa1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aa4:	39 ce                	cmp    %ecx,%esi
  801aa6:	74 1b                	je     801ac3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aa8:	39 c3                	cmp    %eax,%ebx
  801aaa:	75 c4                	jne    801a70 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aac:	8b 42 58             	mov    0x58(%edx),%eax
  801aaf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab2:	50                   	push   %eax
  801ab3:	56                   	push   %esi
  801ab4:	68 0a 2c 80 00       	push   $0x802c0a
  801ab9:	e8 33 e7 ff ff       	call   8001f1 <cprintf>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	eb ad                	jmp    801a70 <_pipeisclosed+0xe>
	}
}
  801ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5f                   	pop    %edi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	57                   	push   %edi
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 28             	sub    $0x28,%esp
  801ad7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ada:	56                   	push   %esi
  801adb:	e8 03 f7 ff ff       	call   8011e3 <fd2data>
  801ae0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	bf 00 00 00 00       	mov    $0x0,%edi
  801aea:	eb 4b                	jmp    801b37 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aec:	89 da                	mov    %ebx,%edx
  801aee:	89 f0                	mov    %esi,%eax
  801af0:	e8 6d ff ff ff       	call   801a62 <_pipeisclosed>
  801af5:	85 c0                	test   %eax,%eax
  801af7:	75 48                	jne    801b41 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801af9:	e8 7c f0 ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801afe:	8b 43 04             	mov    0x4(%ebx),%eax
  801b01:	8b 0b                	mov    (%ebx),%ecx
  801b03:	8d 51 20             	lea    0x20(%ecx),%edx
  801b06:	39 d0                	cmp    %edx,%eax
  801b08:	73 e2                	jae    801aec <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b11:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b14:	89 c2                	mov    %eax,%edx
  801b16:	c1 fa 1f             	sar    $0x1f,%edx
  801b19:	89 d1                	mov    %edx,%ecx
  801b1b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b1e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b21:	83 e2 1f             	and    $0x1f,%edx
  801b24:	29 ca                	sub    %ecx,%edx
  801b26:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b2a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b2e:	83 c0 01             	add    $0x1,%eax
  801b31:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b34:	83 c7 01             	add    $0x1,%edi
  801b37:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b3a:	75 c2                	jne    801afe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b3c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3f:	eb 05                	jmp    801b46 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b49:	5b                   	pop    %ebx
  801b4a:	5e                   	pop    %esi
  801b4b:	5f                   	pop    %edi
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 18             	sub    $0x18,%esp
  801b57:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b5a:	57                   	push   %edi
  801b5b:	e8 83 f6 ff ff       	call   8011e3 <fd2data>
  801b60:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6a:	eb 3d                	jmp    801ba9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b6c:	85 db                	test   %ebx,%ebx
  801b6e:	74 04                	je     801b74 <devpipe_read+0x26>
				return i;
  801b70:	89 d8                	mov    %ebx,%eax
  801b72:	eb 44                	jmp    801bb8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b74:	89 f2                	mov    %esi,%edx
  801b76:	89 f8                	mov    %edi,%eax
  801b78:	e8 e5 fe ff ff       	call   801a62 <_pipeisclosed>
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	75 32                	jne    801bb3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b81:	e8 f4 ef ff ff       	call   800b7a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b86:	8b 06                	mov    (%esi),%eax
  801b88:	3b 46 04             	cmp    0x4(%esi),%eax
  801b8b:	74 df                	je     801b6c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8d:	99                   	cltd   
  801b8e:	c1 ea 1b             	shr    $0x1b,%edx
  801b91:	01 d0                	add    %edx,%eax
  801b93:	83 e0 1f             	and    $0x1f,%eax
  801b96:	29 d0                	sub    %edx,%eax
  801b98:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ba3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba6:	83 c3 01             	add    $0x1,%ebx
  801ba9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bac:	75 d8                	jne    801b86 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bae:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb1:	eb 05                	jmp    801bb8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5f                   	pop    %edi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcb:	50                   	push   %eax
  801bcc:	e8 29 f6 ff ff       	call   8011fa <fd_alloc>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	0f 88 2c 01 00 00    	js     801d0a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bde:	83 ec 04             	sub    $0x4,%esp
  801be1:	68 07 04 00 00       	push   $0x407
  801be6:	ff 75 f4             	pushl  -0xc(%ebp)
  801be9:	6a 00                	push   $0x0
  801beb:	e8 a9 ef ff ff       	call   800b99 <sys_page_alloc>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 0d 01 00 00    	js     801d0a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bfd:	83 ec 0c             	sub    $0xc,%esp
  801c00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c03:	50                   	push   %eax
  801c04:	e8 f1 f5 ff ff       	call   8011fa <fd_alloc>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	0f 88 e2 00 00 00    	js     801cf8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	68 07 04 00 00       	push   $0x407
  801c1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c21:	6a 00                	push   $0x0
  801c23:	e8 71 ef ff ff       	call   800b99 <sys_page_alloc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 c3 00 00 00    	js     801cf8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3b:	e8 a3 f5 ff ff       	call   8011e3 <fd2data>
  801c40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c42:	83 c4 0c             	add    $0xc,%esp
  801c45:	68 07 04 00 00       	push   $0x407
  801c4a:	50                   	push   %eax
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 47 ef ff ff       	call   800b99 <sys_page_alloc>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	0f 88 89 00 00 00    	js     801ce8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5f:	83 ec 0c             	sub    $0xc,%esp
  801c62:	ff 75 f0             	pushl  -0x10(%ebp)
  801c65:	e8 79 f5 ff ff       	call   8011e3 <fd2data>
  801c6a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c71:	50                   	push   %eax
  801c72:	6a 00                	push   $0x0
  801c74:	56                   	push   %esi
  801c75:	6a 00                	push   $0x0
  801c77:	e8 60 ef ff ff       	call   800bdc <sys_page_map>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	83 c4 20             	add    $0x20,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 55                	js     801cda <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c85:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c93:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c9a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb5:	e8 19 f5 ff ff       	call   8011d3 <fd2num>
  801cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cbf:	83 c4 04             	add    $0x4,%esp
  801cc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc5:	e8 09 f5 ff ff       	call   8011d3 <fd2num>
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd8:	eb 30                	jmp    801d0a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	56                   	push   %esi
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 39 ef ff ff       	call   800c1e <sys_page_unmap>
  801ce5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce8:	83 ec 08             	sub    $0x8,%esp
  801ceb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 29 ef ff ff       	call   800c1e <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 19 ef ff ff       	call   800c1e <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1c:	50                   	push   %eax
  801d1d:	ff 75 08             	pushl  0x8(%ebp)
  801d20:	e8 24 f5 ff ff       	call   801249 <fd_lookup>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	78 18                	js     801d44 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d2c:	83 ec 0c             	sub    $0xc,%esp
  801d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d32:	e8 ac f4 ff ff       	call   8011e3 <fd2data>
	return _pipeisclosed(fd, p);
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3c:	e8 21 fd ff ff       	call   801a62 <_pipeisclosed>
  801d41:	83 c4 10             	add    $0x10,%esp
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801d4c:	68 22 2c 80 00       	push   $0x802c22
  801d51:	ff 75 0c             	pushl  0xc(%ebp)
  801d54:	e8 3d ea ff ff       	call   800796 <strcpy>
	return 0;
}
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	c9                   	leave  
  801d5f:	c3                   	ret    

00801d60 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	53                   	push   %ebx
  801d64:	83 ec 10             	sub    $0x10,%esp
  801d67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801d6a:	53                   	push   %ebx
  801d6b:	e8 9c 06 00 00       	call   80240c <pageref>
  801d70:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801d73:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801d78:	83 f8 01             	cmp    $0x1,%eax
  801d7b:	75 10                	jne    801d8d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801d7d:	83 ec 0c             	sub    $0xc,%esp
  801d80:	ff 73 0c             	pushl  0xc(%ebx)
  801d83:	e8 c0 02 00 00       	call   802048 <nsipc_close>
  801d88:	89 c2                	mov    %eax,%edx
  801d8a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801d8d:	89 d0                	mov    %edx,%eax
  801d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801d9a:	6a 00                	push   $0x0
  801d9c:	ff 75 10             	pushl  0x10(%ebp)
  801d9f:	ff 75 0c             	pushl  0xc(%ebp)
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	ff 70 0c             	pushl  0xc(%eax)
  801da8:	e8 78 03 00 00       	call   802125 <nsipc_send>
}
  801dad:	c9                   	leave  
  801dae:	c3                   	ret    

00801daf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801db5:	6a 00                	push   $0x0
  801db7:	ff 75 10             	pushl  0x10(%ebp)
  801dba:	ff 75 0c             	pushl  0xc(%ebp)
  801dbd:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc0:	ff 70 0c             	pushl  0xc(%eax)
  801dc3:	e8 f1 02 00 00       	call   8020b9 <nsipc_recv>
}
  801dc8:	c9                   	leave  
  801dc9:	c3                   	ret    

00801dca <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dd0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801dd3:	52                   	push   %edx
  801dd4:	50                   	push   %eax
  801dd5:	e8 6f f4 ff ff       	call   801249 <fd_lookup>
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 17                	js     801df8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801de1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de4:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801dea:	39 08                	cmp    %ecx,(%eax)
  801dec:	75 05                	jne    801df3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801dee:	8b 40 0c             	mov    0xc(%eax),%eax
  801df1:	eb 05                	jmp    801df8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801df3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801df8:	c9                   	leave  
  801df9:	c3                   	ret    

00801dfa <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	56                   	push   %esi
  801dfe:	53                   	push   %ebx
  801dff:	83 ec 1c             	sub    $0x1c,%esp
  801e02:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e07:	50                   	push   %eax
  801e08:	e8 ed f3 ff ff       	call   8011fa <fd_alloc>
  801e0d:	89 c3                	mov    %eax,%ebx
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 1b                	js     801e31 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	68 07 04 00 00       	push   $0x407
  801e1e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e21:	6a 00                	push   $0x0
  801e23:	e8 71 ed ff ff       	call   800b99 <sys_page_alloc>
  801e28:	89 c3                	mov    %eax,%ebx
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	79 10                	jns    801e41 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801e31:	83 ec 0c             	sub    $0xc,%esp
  801e34:	56                   	push   %esi
  801e35:	e8 0e 02 00 00       	call   802048 <nsipc_close>
		return r;
  801e3a:	83 c4 10             	add    $0x10,%esp
  801e3d:	89 d8                	mov    %ebx,%eax
  801e3f:	eb 24                	jmp    801e65 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801e41:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e4f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801e56:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801e59:	83 ec 0c             	sub    $0xc,%esp
  801e5c:	50                   	push   %eax
  801e5d:	e8 71 f3 ff ff       	call   8011d3 <fd2num>
  801e62:	83 c4 10             	add    $0x10,%esp
}
  801e65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    

00801e6c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e72:	8b 45 08             	mov    0x8(%ebp),%eax
  801e75:	e8 50 ff ff ff       	call   801dca <fd2sockid>
		return r;
  801e7a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e7c:	85 c0                	test   %eax,%eax
  801e7e:	78 1f                	js     801e9f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e80:	83 ec 04             	sub    $0x4,%esp
  801e83:	ff 75 10             	pushl  0x10(%ebp)
  801e86:	ff 75 0c             	pushl  0xc(%ebp)
  801e89:	50                   	push   %eax
  801e8a:	e8 12 01 00 00       	call   801fa1 <nsipc_accept>
  801e8f:	83 c4 10             	add    $0x10,%esp
		return r;
  801e92:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801e94:	85 c0                	test   %eax,%eax
  801e96:	78 07                	js     801e9f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801e98:	e8 5d ff ff ff       	call   801dfa <alloc_sockfd>
  801e9d:	89 c1                	mov    %eax,%ecx
}
  801e9f:	89 c8                	mov    %ecx,%eax
  801ea1:	c9                   	leave  
  801ea2:	c3                   	ret    

00801ea3 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ea3:	55                   	push   %ebp
  801ea4:	89 e5                	mov    %esp,%ebp
  801ea6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eac:	e8 19 ff ff ff       	call   801dca <fd2sockid>
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 12                	js     801ec7 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	ff 75 10             	pushl  0x10(%ebp)
  801ebb:	ff 75 0c             	pushl  0xc(%ebp)
  801ebe:	50                   	push   %eax
  801ebf:	e8 2d 01 00 00       	call   801ff1 <nsipc_bind>
  801ec4:	83 c4 10             	add    $0x10,%esp
}
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <shutdown>:

int
shutdown(int s, int how)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed2:	e8 f3 fe ff ff       	call   801dca <fd2sockid>
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 0f                	js     801eea <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801edb:	83 ec 08             	sub    $0x8,%esp
  801ede:	ff 75 0c             	pushl  0xc(%ebp)
  801ee1:	50                   	push   %eax
  801ee2:	e8 3f 01 00 00       	call   802026 <nsipc_shutdown>
  801ee7:	83 c4 10             	add    $0x10,%esp
}
  801eea:	c9                   	leave  
  801eeb:	c3                   	ret    

00801eec <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef5:	e8 d0 fe ff ff       	call   801dca <fd2sockid>
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 12                	js     801f10 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801efe:	83 ec 04             	sub    $0x4,%esp
  801f01:	ff 75 10             	pushl  0x10(%ebp)
  801f04:	ff 75 0c             	pushl  0xc(%ebp)
  801f07:	50                   	push   %eax
  801f08:	e8 55 01 00 00       	call   802062 <nsipc_connect>
  801f0d:	83 c4 10             	add    $0x10,%esp
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <listen>:

int
listen(int s, int backlog)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f18:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1b:	e8 aa fe ff ff       	call   801dca <fd2sockid>
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 0f                	js     801f33 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f24:	83 ec 08             	sub    $0x8,%esp
  801f27:	ff 75 0c             	pushl  0xc(%ebp)
  801f2a:	50                   	push   %eax
  801f2b:	e8 67 01 00 00       	call   802097 <nsipc_listen>
  801f30:	83 c4 10             	add    $0x10,%esp
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f3b:	ff 75 10             	pushl  0x10(%ebp)
  801f3e:	ff 75 0c             	pushl  0xc(%ebp)
  801f41:	ff 75 08             	pushl  0x8(%ebp)
  801f44:	e8 3a 02 00 00       	call   802183 <nsipc_socket>
  801f49:	83 c4 10             	add    $0x10,%esp
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 05                	js     801f55 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801f50:	e8 a5 fe ff ff       	call   801dfa <alloc_sockfd>
}
  801f55:	c9                   	leave  
  801f56:	c3                   	ret    

00801f57 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 04             	sub    $0x4,%esp
  801f5e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801f60:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801f67:	75 12                	jne    801f7b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f69:	83 ec 0c             	sub    $0xc,%esp
  801f6c:	6a 02                	push   $0x2
  801f6e:	e8 27 f2 ff ff       	call   80119a <ipc_find_env>
  801f73:	a3 04 40 80 00       	mov    %eax,0x804004
  801f78:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f7b:	6a 07                	push   $0x7
  801f7d:	68 00 60 80 00       	push   $0x806000
  801f82:	53                   	push   %ebx
  801f83:	ff 35 04 40 80 00    	pushl  0x804004
  801f89:	e8 bd f1 ff ff       	call   80114b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f8e:	83 c4 0c             	add    $0xc,%esp
  801f91:	6a 00                	push   $0x0
  801f93:	6a 00                	push   $0x0
  801f95:	6a 00                	push   $0x0
  801f97:	e8 39 f1 ff ff       	call   8010d5 <ipc_recv>
}
  801f9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
  801fa6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801fb1:	8b 06                	mov    (%esi),%eax
  801fb3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fb8:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbd:	e8 95 ff ff ff       	call   801f57 <nsipc>
  801fc2:	89 c3                	mov    %eax,%ebx
  801fc4:	85 c0                	test   %eax,%eax
  801fc6:	78 20                	js     801fe8 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fc8:	83 ec 04             	sub    $0x4,%esp
  801fcb:	ff 35 10 60 80 00    	pushl  0x806010
  801fd1:	68 00 60 80 00       	push   $0x806000
  801fd6:	ff 75 0c             	pushl  0xc(%ebp)
  801fd9:	e8 4a e9 ff ff       	call   800928 <memmove>
		*addrlen = ret->ret_addrlen;
  801fde:	a1 10 60 80 00       	mov    0x806010,%eax
  801fe3:	89 06                	mov    %eax,(%esi)
  801fe5:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801fe8:	89 d8                	mov    %ebx,%eax
  801fea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    

00801ff1 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	53                   	push   %ebx
  801ff5:	83 ec 08             	sub    $0x8,%esp
  801ff8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802003:	53                   	push   %ebx
  802004:	ff 75 0c             	pushl  0xc(%ebp)
  802007:	68 04 60 80 00       	push   $0x806004
  80200c:	e8 17 e9 ff ff       	call   800928 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802011:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  802017:	b8 02 00 00 00       	mov    $0x2,%eax
  80201c:	e8 36 ff ff ff       	call   801f57 <nsipc>
}
  802021:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802024:	c9                   	leave  
  802025:	c3                   	ret    

00802026 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802034:	8b 45 0c             	mov    0xc(%ebp),%eax
  802037:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80203c:	b8 03 00 00 00       	mov    $0x3,%eax
  802041:	e8 11 ff ff ff       	call   801f57 <nsipc>
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <nsipc_close>:

int
nsipc_close(int s)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802056:	b8 04 00 00 00       	mov    $0x4,%eax
  80205b:	e8 f7 fe ff ff       	call   801f57 <nsipc>
}
  802060:	c9                   	leave  
  802061:	c3                   	ret    

00802062 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	53                   	push   %ebx
  802066:	83 ec 08             	sub    $0x8,%esp
  802069:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80206c:	8b 45 08             	mov    0x8(%ebp),%eax
  80206f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802074:	53                   	push   %ebx
  802075:	ff 75 0c             	pushl  0xc(%ebp)
  802078:	68 04 60 80 00       	push   $0x806004
  80207d:	e8 a6 e8 ff ff       	call   800928 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802082:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802088:	b8 05 00 00 00       	mov    $0x5,%eax
  80208d:	e8 c5 fe ff ff       	call   801f57 <nsipc>
}
  802092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802095:	c9                   	leave  
  802096:	c3                   	ret    

00802097 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802097:	55                   	push   %ebp
  802098:	89 e5                	mov    %esp,%ebp
  80209a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80209d:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8020a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8020ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8020b2:	e8 a0 fe ff ff       	call   801f57 <nsipc>
}
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    

008020b9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	56                   	push   %esi
  8020bd:	53                   	push   %ebx
  8020be:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8020c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8020c9:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8020cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d2:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8020d7:	b8 07 00 00 00       	mov    $0x7,%eax
  8020dc:	e8 76 fe ff ff       	call   801f57 <nsipc>
  8020e1:	89 c3                	mov    %eax,%ebx
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	78 35                	js     80211c <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8020e7:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8020ec:	7f 04                	jg     8020f2 <nsipc_recv+0x39>
  8020ee:	39 c6                	cmp    %eax,%esi
  8020f0:	7d 16                	jge    802108 <nsipc_recv+0x4f>
  8020f2:	68 2e 2c 80 00       	push   $0x802c2e
  8020f7:	68 d7 2b 80 00       	push   $0x802bd7
  8020fc:	6a 62                	push   $0x62
  8020fe:	68 43 2c 80 00       	push   $0x802c43
  802103:	e8 28 02 00 00       	call   802330 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802108:	83 ec 04             	sub    $0x4,%esp
  80210b:	50                   	push   %eax
  80210c:	68 00 60 80 00       	push   $0x806000
  802111:	ff 75 0c             	pushl  0xc(%ebp)
  802114:	e8 0f e8 ff ff       	call   800928 <memmove>
  802119:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802121:	5b                   	pop    %ebx
  802122:	5e                   	pop    %esi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802125:	55                   	push   %ebp
  802126:	89 e5                	mov    %esp,%ebp
  802128:	53                   	push   %ebx
  802129:	83 ec 04             	sub    $0x4,%esp
  80212c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80212f:	8b 45 08             	mov    0x8(%ebp),%eax
  802132:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802137:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80213d:	7e 16                	jle    802155 <nsipc_send+0x30>
  80213f:	68 4f 2c 80 00       	push   $0x802c4f
  802144:	68 d7 2b 80 00       	push   $0x802bd7
  802149:	6a 6d                	push   $0x6d
  80214b:	68 43 2c 80 00       	push   $0x802c43
  802150:	e8 db 01 00 00       	call   802330 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802155:	83 ec 04             	sub    $0x4,%esp
  802158:	53                   	push   %ebx
  802159:	ff 75 0c             	pushl  0xc(%ebp)
  80215c:	68 0c 60 80 00       	push   $0x80600c
  802161:	e8 c2 e7 ff ff       	call   800928 <memmove>
	nsipcbuf.send.req_size = size;
  802166:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80216c:	8b 45 14             	mov    0x14(%ebp),%eax
  80216f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802174:	b8 08 00 00 00       	mov    $0x8,%eax
  802179:	e8 d9 fd ff ff       	call   801f57 <nsipc>
}
  80217e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802181:	c9                   	leave  
  802182:	c3                   	ret    

00802183 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802183:	55                   	push   %ebp
  802184:	89 e5                	mov    %esp,%ebp
  802186:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802189:	8b 45 08             	mov    0x8(%ebp),%eax
  80218c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802191:	8b 45 0c             	mov    0xc(%ebp),%eax
  802194:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802199:	8b 45 10             	mov    0x10(%ebp),%eax
  80219c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8021a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8021a6:	e8 ac fd ff ff       	call   801f57 <nsipc>
}
  8021ab:	c9                   	leave  
  8021ac:	c3                   	ret    

008021ad <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ad:	55                   	push   %ebp
  8021ae:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    

008021b7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021b7:	55                   	push   %ebp
  8021b8:	89 e5                	mov    %esp,%ebp
  8021ba:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021bd:	68 5b 2c 80 00       	push   $0x802c5b
  8021c2:	ff 75 0c             	pushl  0xc(%ebp)
  8021c5:	e8 cc e5 ff ff       	call   800796 <strcpy>
	return 0;
}
  8021ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cf:	c9                   	leave  
  8021d0:	c3                   	ret    

008021d1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021d1:	55                   	push   %ebp
  8021d2:	89 e5                	mov    %esp,%ebp
  8021d4:	57                   	push   %edi
  8021d5:	56                   	push   %esi
  8021d6:	53                   	push   %ebx
  8021d7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021dd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021e2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021e8:	eb 2d                	jmp    802217 <devcons_write+0x46>
		m = n - tot;
  8021ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021ed:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021ef:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021f2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021f7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021fa:	83 ec 04             	sub    $0x4,%esp
  8021fd:	53                   	push   %ebx
  8021fe:	03 45 0c             	add    0xc(%ebp),%eax
  802201:	50                   	push   %eax
  802202:	57                   	push   %edi
  802203:	e8 20 e7 ff ff       	call   800928 <memmove>
		sys_cputs(buf, m);
  802208:	83 c4 08             	add    $0x8,%esp
  80220b:	53                   	push   %ebx
  80220c:	57                   	push   %edi
  80220d:	e8 cb e8 ff ff       	call   800add <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802212:	01 de                	add    %ebx,%esi
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	89 f0                	mov    %esi,%eax
  802219:	3b 75 10             	cmp    0x10(%ebp),%esi
  80221c:	72 cc                	jb     8021ea <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80221e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5f                   	pop    %edi
  802224:	5d                   	pop    %ebp
  802225:	c3                   	ret    

00802226 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802226:	55                   	push   %ebp
  802227:	89 e5                	mov    %esp,%ebp
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802231:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802235:	74 2a                	je     802261 <devcons_read+0x3b>
  802237:	eb 05                	jmp    80223e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802239:	e8 3c e9 ff ff       	call   800b7a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80223e:	e8 b8 e8 ff ff       	call   800afb <sys_cgetc>
  802243:	85 c0                	test   %eax,%eax
  802245:	74 f2                	je     802239 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802247:	85 c0                	test   %eax,%eax
  802249:	78 16                	js     802261 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80224b:	83 f8 04             	cmp    $0x4,%eax
  80224e:	74 0c                	je     80225c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802250:	8b 55 0c             	mov    0xc(%ebp),%edx
  802253:	88 02                	mov    %al,(%edx)
	return 1;
  802255:	b8 01 00 00 00       	mov    $0x1,%eax
  80225a:	eb 05                	jmp    802261 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80225c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802269:	8b 45 08             	mov    0x8(%ebp),%eax
  80226c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80226f:	6a 01                	push   $0x1
  802271:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802274:	50                   	push   %eax
  802275:	e8 63 e8 ff ff       	call   800add <sys_cputs>
}
  80227a:	83 c4 10             	add    $0x10,%esp
  80227d:	c9                   	leave  
  80227e:	c3                   	ret    

0080227f <getchar>:

int
getchar(void)
{
  80227f:	55                   	push   %ebp
  802280:	89 e5                	mov    %esp,%ebp
  802282:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802285:	6a 01                	push   $0x1
  802287:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80228a:	50                   	push   %eax
  80228b:	6a 00                	push   $0x0
  80228d:	e8 1d f2 ff ff       	call   8014af <read>
	if (r < 0)
  802292:	83 c4 10             	add    $0x10,%esp
  802295:	85 c0                	test   %eax,%eax
  802297:	78 0f                	js     8022a8 <getchar+0x29>
		return r;
	if (r < 1)
  802299:	85 c0                	test   %eax,%eax
  80229b:	7e 06                	jle    8022a3 <getchar+0x24>
		return -E_EOF;
	return c;
  80229d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022a1:	eb 05                	jmp    8022a8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022a3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022a8:	c9                   	leave  
  8022a9:	c3                   	ret    

008022aa <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022aa:	55                   	push   %ebp
  8022ab:	89 e5                	mov    %esp,%ebp
  8022ad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b3:	50                   	push   %eax
  8022b4:	ff 75 08             	pushl  0x8(%ebp)
  8022b7:	e8 8d ef ff ff       	call   801249 <fd_lookup>
  8022bc:	83 c4 10             	add    $0x10,%esp
  8022bf:	85 c0                	test   %eax,%eax
  8022c1:	78 11                	js     8022d4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022cc:	39 10                	cmp    %edx,(%eax)
  8022ce:	0f 94 c0             	sete   %al
  8022d1:	0f b6 c0             	movzbl %al,%eax
}
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    

008022d6 <opencons>:

int
opencons(void)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022df:	50                   	push   %eax
  8022e0:	e8 15 ef ff ff       	call   8011fa <fd_alloc>
  8022e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8022e8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	78 3e                	js     80232c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ee:	83 ec 04             	sub    $0x4,%esp
  8022f1:	68 07 04 00 00       	push   $0x407
  8022f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8022f9:	6a 00                	push   $0x0
  8022fb:	e8 99 e8 ff ff       	call   800b99 <sys_page_alloc>
  802300:	83 c4 10             	add    $0x10,%esp
		return r;
  802303:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802305:	85 c0                	test   %eax,%eax
  802307:	78 23                	js     80232c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802309:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80230f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802312:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802314:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802317:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80231e:	83 ec 0c             	sub    $0xc,%esp
  802321:	50                   	push   %eax
  802322:	e8 ac ee ff ff       	call   8011d3 <fd2num>
  802327:	89 c2                	mov    %eax,%edx
  802329:	83 c4 10             	add    $0x10,%esp
}
  80232c:	89 d0                	mov    %edx,%eax
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	56                   	push   %esi
  802334:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802335:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802338:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80233e:	e8 18 e8 ff ff       	call   800b5b <sys_getenvid>
  802343:	83 ec 0c             	sub    $0xc,%esp
  802346:	ff 75 0c             	pushl  0xc(%ebp)
  802349:	ff 75 08             	pushl  0x8(%ebp)
  80234c:	56                   	push   %esi
  80234d:	50                   	push   %eax
  80234e:	68 68 2c 80 00       	push   $0x802c68
  802353:	e8 99 de ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802358:	83 c4 18             	add    $0x18,%esp
  80235b:	53                   	push   %ebx
  80235c:	ff 75 10             	pushl  0x10(%ebp)
  80235f:	e8 3c de ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  802364:	c7 04 24 1b 2c 80 00 	movl   $0x802c1b,(%esp)
  80236b:	e8 81 de ff ff       	call   8001f1 <cprintf>
  802370:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802373:	cc                   	int3   
  802374:	eb fd                	jmp    802373 <_panic+0x43>

00802376 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802376:	55                   	push   %ebp
  802377:	89 e5                	mov    %esp,%ebp
  802379:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  80237c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802383:	75 56                	jne    8023db <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802385:	83 ec 04             	sub    $0x4,%esp
  802388:	6a 07                	push   $0x7
  80238a:	68 00 f0 bf ee       	push   $0xeebff000
  80238f:	6a 00                	push   $0x0
  802391:	e8 03 e8 ff ff       	call   800b99 <sys_page_alloc>
  802396:	83 c4 10             	add    $0x10,%esp
  802399:	85 c0                	test   %eax,%eax
  80239b:	74 14                	je     8023b1 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  80239d:	83 ec 04             	sub    $0x4,%esp
  8023a0:	68 e9 2a 80 00       	push   $0x802ae9
  8023a5:	6a 21                	push   $0x21
  8023a7:	68 8c 2c 80 00       	push   $0x802c8c
  8023ac:	e8 7f ff ff ff       	call   802330 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  8023b1:	83 ec 08             	sub    $0x8,%esp
  8023b4:	68 e5 23 80 00       	push   $0x8023e5
  8023b9:	6a 00                	push   $0x0
  8023bb:	e8 24 e9 ff ff       	call   800ce4 <sys_env_set_pgfault_upcall>
  8023c0:	83 c4 10             	add    $0x10,%esp
  8023c3:	85 c0                	test   %eax,%eax
  8023c5:	74 14                	je     8023db <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8023c7:	83 ec 04             	sub    $0x4,%esp
  8023ca:	68 9a 2c 80 00       	push   $0x802c9a
  8023cf:	6a 23                	push   $0x23
  8023d1:	68 8c 2c 80 00       	push   $0x802c8c
  8023d6:	e8 55 ff ff ff       	call   802330 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023db:	8b 45 08             	mov    0x8(%ebp),%eax
  8023de:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023e3:	c9                   	leave  
  8023e4:	c3                   	ret    

008023e5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023e5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023e6:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8023eb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023ed:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8023f0:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8023f2:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8023f6:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8023fa:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8023fb:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8023fd:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  802402:	83 c4 08             	add    $0x8,%esp
	popal
  802405:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802406:	83 c4 04             	add    $0x4,%esp
	popfl
  802409:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80240a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80240b:	c3                   	ret    

0080240c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802412:	89 d0                	mov    %edx,%eax
  802414:	c1 e8 16             	shr    $0x16,%eax
  802417:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80241e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802423:	f6 c1 01             	test   $0x1,%cl
  802426:	74 1d                	je     802445 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802428:	c1 ea 0c             	shr    $0xc,%edx
  80242b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802432:	f6 c2 01             	test   $0x1,%dl
  802435:	74 0e                	je     802445 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802437:	c1 ea 0c             	shr    $0xc,%edx
  80243a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802441:	ef 
  802442:	0f b7 c0             	movzwl %ax,%eax
}
  802445:	5d                   	pop    %ebp
  802446:	c3                   	ret    
  802447:	66 90                	xchg   %ax,%ax
  802449:	66 90                	xchg   %ax,%ax
  80244b:	66 90                	xchg   %ax,%ax
  80244d:	66 90                	xchg   %ax,%ax
  80244f:	90                   	nop

00802450 <__udivdi3>:
  802450:	55                   	push   %ebp
  802451:	57                   	push   %edi
  802452:	56                   	push   %esi
  802453:	53                   	push   %ebx
  802454:	83 ec 1c             	sub    $0x1c,%esp
  802457:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80245b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80245f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802463:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802467:	85 f6                	test   %esi,%esi
  802469:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80246d:	89 ca                	mov    %ecx,%edx
  80246f:	89 f8                	mov    %edi,%eax
  802471:	75 3d                	jne    8024b0 <__udivdi3+0x60>
  802473:	39 cf                	cmp    %ecx,%edi
  802475:	0f 87 c5 00 00 00    	ja     802540 <__udivdi3+0xf0>
  80247b:	85 ff                	test   %edi,%edi
  80247d:	89 fd                	mov    %edi,%ebp
  80247f:	75 0b                	jne    80248c <__udivdi3+0x3c>
  802481:	b8 01 00 00 00       	mov    $0x1,%eax
  802486:	31 d2                	xor    %edx,%edx
  802488:	f7 f7                	div    %edi
  80248a:	89 c5                	mov    %eax,%ebp
  80248c:	89 c8                	mov    %ecx,%eax
  80248e:	31 d2                	xor    %edx,%edx
  802490:	f7 f5                	div    %ebp
  802492:	89 c1                	mov    %eax,%ecx
  802494:	89 d8                	mov    %ebx,%eax
  802496:	89 cf                	mov    %ecx,%edi
  802498:	f7 f5                	div    %ebp
  80249a:	89 c3                	mov    %eax,%ebx
  80249c:	89 d8                	mov    %ebx,%eax
  80249e:	89 fa                	mov    %edi,%edx
  8024a0:	83 c4 1c             	add    $0x1c,%esp
  8024a3:	5b                   	pop    %ebx
  8024a4:	5e                   	pop    %esi
  8024a5:	5f                   	pop    %edi
  8024a6:	5d                   	pop    %ebp
  8024a7:	c3                   	ret    
  8024a8:	90                   	nop
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	39 ce                	cmp    %ecx,%esi
  8024b2:	77 74                	ja     802528 <__udivdi3+0xd8>
  8024b4:	0f bd fe             	bsr    %esi,%edi
  8024b7:	83 f7 1f             	xor    $0x1f,%edi
  8024ba:	0f 84 98 00 00 00    	je     802558 <__udivdi3+0x108>
  8024c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	89 c5                	mov    %eax,%ebp
  8024c9:	29 fb                	sub    %edi,%ebx
  8024cb:	d3 e6                	shl    %cl,%esi
  8024cd:	89 d9                	mov    %ebx,%ecx
  8024cf:	d3 ed                	shr    %cl,%ebp
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e0                	shl    %cl,%eax
  8024d5:	09 ee                	or     %ebp,%esi
  8024d7:	89 d9                	mov    %ebx,%ecx
  8024d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024dd:	89 d5                	mov    %edx,%ebp
  8024df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024e3:	d3 ed                	shr    %cl,%ebp
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e2                	shl    %cl,%edx
  8024e9:	89 d9                	mov    %ebx,%ecx
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	09 c2                	or     %eax,%edx
  8024ef:	89 d0                	mov    %edx,%eax
  8024f1:	89 ea                	mov    %ebp,%edx
  8024f3:	f7 f6                	div    %esi
  8024f5:	89 d5                	mov    %edx,%ebp
  8024f7:	89 c3                	mov    %eax,%ebx
  8024f9:	f7 64 24 0c          	mull   0xc(%esp)
  8024fd:	39 d5                	cmp    %edx,%ebp
  8024ff:	72 10                	jb     802511 <__udivdi3+0xc1>
  802501:	8b 74 24 08          	mov    0x8(%esp),%esi
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e6                	shl    %cl,%esi
  802509:	39 c6                	cmp    %eax,%esi
  80250b:	73 07                	jae    802514 <__udivdi3+0xc4>
  80250d:	39 d5                	cmp    %edx,%ebp
  80250f:	75 03                	jne    802514 <__udivdi3+0xc4>
  802511:	83 eb 01             	sub    $0x1,%ebx
  802514:	31 ff                	xor    %edi,%edi
  802516:	89 d8                	mov    %ebx,%eax
  802518:	89 fa                	mov    %edi,%edx
  80251a:	83 c4 1c             	add    $0x1c,%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5f                   	pop    %edi
  802520:	5d                   	pop    %ebp
  802521:	c3                   	ret    
  802522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802528:	31 ff                	xor    %edi,%edi
  80252a:	31 db                	xor    %ebx,%ebx
  80252c:	89 d8                	mov    %ebx,%eax
  80252e:	89 fa                	mov    %edi,%edx
  802530:	83 c4 1c             	add    $0x1c,%esp
  802533:	5b                   	pop    %ebx
  802534:	5e                   	pop    %esi
  802535:	5f                   	pop    %edi
  802536:	5d                   	pop    %ebp
  802537:	c3                   	ret    
  802538:	90                   	nop
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d8                	mov    %ebx,%eax
  802542:	f7 f7                	div    %edi
  802544:	31 ff                	xor    %edi,%edi
  802546:	89 c3                	mov    %eax,%ebx
  802548:	89 d8                	mov    %ebx,%eax
  80254a:	89 fa                	mov    %edi,%edx
  80254c:	83 c4 1c             	add    $0x1c,%esp
  80254f:	5b                   	pop    %ebx
  802550:	5e                   	pop    %esi
  802551:	5f                   	pop    %edi
  802552:	5d                   	pop    %ebp
  802553:	c3                   	ret    
  802554:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802558:	39 ce                	cmp    %ecx,%esi
  80255a:	72 0c                	jb     802568 <__udivdi3+0x118>
  80255c:	31 db                	xor    %ebx,%ebx
  80255e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802562:	0f 87 34 ff ff ff    	ja     80249c <__udivdi3+0x4c>
  802568:	bb 01 00 00 00       	mov    $0x1,%ebx
  80256d:	e9 2a ff ff ff       	jmp    80249c <__udivdi3+0x4c>
  802572:	66 90                	xchg   %ax,%ax
  802574:	66 90                	xchg   %ax,%ax
  802576:	66 90                	xchg   %ax,%ax
  802578:	66 90                	xchg   %ax,%ax
  80257a:	66 90                	xchg   %ax,%ax
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__umoddi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80258b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80258f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 d2                	test   %edx,%edx
  802599:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f3                	mov    %esi,%ebx
  8025a3:	89 3c 24             	mov    %edi,(%esp)
  8025a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025aa:	75 1c                	jne    8025c8 <__umoddi3+0x48>
  8025ac:	39 f7                	cmp    %esi,%edi
  8025ae:	76 50                	jbe    802600 <__umoddi3+0x80>
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	f7 f7                	div    %edi
  8025b6:	89 d0                	mov    %edx,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	39 f2                	cmp    %esi,%edx
  8025ca:	89 d0                	mov    %edx,%eax
  8025cc:	77 52                	ja     802620 <__umoddi3+0xa0>
  8025ce:	0f bd ea             	bsr    %edx,%ebp
  8025d1:	83 f5 1f             	xor    $0x1f,%ebp
  8025d4:	75 5a                	jne    802630 <__umoddi3+0xb0>
  8025d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025da:	0f 82 e0 00 00 00    	jb     8026c0 <__umoddi3+0x140>
  8025e0:	39 0c 24             	cmp    %ecx,(%esp)
  8025e3:	0f 86 d7 00 00 00    	jbe    8026c0 <__umoddi3+0x140>
  8025e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025f1:	83 c4 1c             	add    $0x1c,%esp
  8025f4:	5b                   	pop    %ebx
  8025f5:	5e                   	pop    %esi
  8025f6:	5f                   	pop    %edi
  8025f7:	5d                   	pop    %ebp
  8025f8:	c3                   	ret    
  8025f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802600:	85 ff                	test   %edi,%edi
  802602:	89 fd                	mov    %edi,%ebp
  802604:	75 0b                	jne    802611 <__umoddi3+0x91>
  802606:	b8 01 00 00 00       	mov    $0x1,%eax
  80260b:	31 d2                	xor    %edx,%edx
  80260d:	f7 f7                	div    %edi
  80260f:	89 c5                	mov    %eax,%ebp
  802611:	89 f0                	mov    %esi,%eax
  802613:	31 d2                	xor    %edx,%edx
  802615:	f7 f5                	div    %ebp
  802617:	89 c8                	mov    %ecx,%eax
  802619:	f7 f5                	div    %ebp
  80261b:	89 d0                	mov    %edx,%eax
  80261d:	eb 99                	jmp    8025b8 <__umoddi3+0x38>
  80261f:	90                   	nop
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	83 c4 1c             	add    $0x1c,%esp
  802627:	5b                   	pop    %ebx
  802628:	5e                   	pop    %esi
  802629:	5f                   	pop    %edi
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
  80262c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802630:	8b 34 24             	mov    (%esp),%esi
  802633:	bf 20 00 00 00       	mov    $0x20,%edi
  802638:	89 e9                	mov    %ebp,%ecx
  80263a:	29 ef                	sub    %ebp,%edi
  80263c:	d3 e0                	shl    %cl,%eax
  80263e:	89 f9                	mov    %edi,%ecx
  802640:	89 f2                	mov    %esi,%edx
  802642:	d3 ea                	shr    %cl,%edx
  802644:	89 e9                	mov    %ebp,%ecx
  802646:	09 c2                	or     %eax,%edx
  802648:	89 d8                	mov    %ebx,%eax
  80264a:	89 14 24             	mov    %edx,(%esp)
  80264d:	89 f2                	mov    %esi,%edx
  80264f:	d3 e2                	shl    %cl,%edx
  802651:	89 f9                	mov    %edi,%ecx
  802653:	89 54 24 04          	mov    %edx,0x4(%esp)
  802657:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80265b:	d3 e8                	shr    %cl,%eax
  80265d:	89 e9                	mov    %ebp,%ecx
  80265f:	89 c6                	mov    %eax,%esi
  802661:	d3 e3                	shl    %cl,%ebx
  802663:	89 f9                	mov    %edi,%ecx
  802665:	89 d0                	mov    %edx,%eax
  802667:	d3 e8                	shr    %cl,%eax
  802669:	89 e9                	mov    %ebp,%ecx
  80266b:	09 d8                	or     %ebx,%eax
  80266d:	89 d3                	mov    %edx,%ebx
  80266f:	89 f2                	mov    %esi,%edx
  802671:	f7 34 24             	divl   (%esp)
  802674:	89 d6                	mov    %edx,%esi
  802676:	d3 e3                	shl    %cl,%ebx
  802678:	f7 64 24 04          	mull   0x4(%esp)
  80267c:	39 d6                	cmp    %edx,%esi
  80267e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802682:	89 d1                	mov    %edx,%ecx
  802684:	89 c3                	mov    %eax,%ebx
  802686:	72 08                	jb     802690 <__umoddi3+0x110>
  802688:	75 11                	jne    80269b <__umoddi3+0x11b>
  80268a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80268e:	73 0b                	jae    80269b <__umoddi3+0x11b>
  802690:	2b 44 24 04          	sub    0x4(%esp),%eax
  802694:	1b 14 24             	sbb    (%esp),%edx
  802697:	89 d1                	mov    %edx,%ecx
  802699:	89 c3                	mov    %eax,%ebx
  80269b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80269f:	29 da                	sub    %ebx,%edx
  8026a1:	19 ce                	sbb    %ecx,%esi
  8026a3:	89 f9                	mov    %edi,%ecx
  8026a5:	89 f0                	mov    %esi,%eax
  8026a7:	d3 e0                	shl    %cl,%eax
  8026a9:	89 e9                	mov    %ebp,%ecx
  8026ab:	d3 ea                	shr    %cl,%edx
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	d3 ee                	shr    %cl,%esi
  8026b1:	09 d0                	or     %edx,%eax
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	83 c4 1c             	add    $0x1c,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5e                   	pop    %esi
  8026ba:	5f                   	pop    %edi
  8026bb:	5d                   	pop    %ebp
  8026bc:	c3                   	ret    
  8026bd:	8d 76 00             	lea    0x0(%esi),%esi
  8026c0:	29 f9                	sub    %edi,%ecx
  8026c2:	19 d6                	sbb    %edx,%esi
  8026c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cc:	e9 18 ff ff ff       	jmp    8025e9 <__umoddi3+0x69>
