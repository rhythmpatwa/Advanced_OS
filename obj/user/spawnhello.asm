
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 60 28 80 00       	push   $0x802860
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 7e 28 80 00       	push   $0x80287e
  800056:	68 7e 28 80 00       	push   $0x80287e
  80005b:	e8 7a 1a 00 00       	call   801ada <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 84 28 80 00       	push   $0x802884
  80006d:	6a 09                	push   $0x9
  80006f:	68 9c 28 80 00       	push   $0x80289c
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800086:	e8 93 0a 00 00       	call   800b1e <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 6b 0e 00 00       	call   800f37 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 07 0a 00 00       	call   800add <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 30 0a 00 00       	call   800b1e <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 b8 28 80 00       	push   $0x8028b8
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 9c 2d 80 00 	movl   $0x802d9c,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 4f 09 00 00       	call   800aa0 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 f4 08 00 00       	call   800aa0 <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 b4 23 00 00       	call   8025d0 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 a1 24 00 00       	call   802700 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 db 28 80 00 	movsbl 0x8028db(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 a9 03 00 00    	je     8006b0 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 3a 03 00 00    	ja     800695 <vprintfmt+0x3aa>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 20 2a 80 00 	jmp    *0x802a20(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xdf>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x59>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x59>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x142>
  800422:	8b 14 85 80 2b 80 00 	mov    0x802b80(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 f3 28 80 00       	push   $0x8028f3
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 94 fe ff ff       	call   8002ce <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 b5 2c 80 00       	push   $0x802cb5
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 7c fe ff ff       	call   8002ce <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 ec 28 80 00       	mov    $0x8028ec,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x225>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 d0             	pushl  -0x30(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 a6 02 00 00       	call   800738 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c0>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x213>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x213>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x23f>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x23f>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x270>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f2>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f2>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x278>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2d1>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cb:	0f 89 90 00 00 00    	jns    800661 <vprintfmt+0x376>
				putch('-', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 2d                	push   $0x2d
  8005d7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005df:	f7 d8                	neg    %eax
  8005e1:	83 d2 00             	adc    $0x0,%edx
  8005e4:	f7 da                	neg    %edx
  8005e6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ee:	eb 71                	jmp    800661 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f3:	e8 7f fc ff ff       	call   800277 <getuint>
			base = 10;
  8005f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005fd:	eb 62                	jmp    800661 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 70 fc ff ff       	call   800277 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80060e:	51                   	push   %ecx
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	6a 08                	push   $0x8
  800614:	52                   	push   %edx
  800615:	50                   	push   %eax
  800616:	89 da                	mov    %ebx,%edx
  800618:	89 f0                	mov    %esi,%eax
  80061a:	e8 a9 fb ff ff       	call   8001c8 <printnum>
			break;
  80061f:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800625:	e9 e7 fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 30                	push   $0x30
  800630:	ff d6                	call   *%esi
			putch('x', putdat);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 78                	push   $0x78
  800638:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800643:	8b 00                	mov    (%eax),%eax
  800645:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80064d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800652:	eb 0d                	jmp    800661 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800654:	8d 45 14             	lea    0x14(%ebp),%eax
  800657:	e8 1b fc ff ff       	call   800277 <getuint>
			base = 16;
  80065c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800668:	57                   	push   %edi
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	51                   	push   %ecx
  80066d:	52                   	push   %edx
  80066e:	50                   	push   %eax
  80066f:	89 da                	mov    %ebx,%edx
  800671:	89 f0                	mov    %esi,%eax
  800673:	e8 50 fb ff ff       	call   8001c8 <printnum>
			break;
  800678:	83 c4 20             	add    $0x20,%esp
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	e9 8e fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	51                   	push   %ecx
  800688:	ff d6                	call   *%esi
			break;
  80068a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800690:	e9 7c fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 25                	push   $0x25
  80069b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	eb 03                	jmp    8006a5 <vprintfmt+0x3ba>
  8006a2:	83 ef 01             	sub    $0x1,%edi
  8006a5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a9:	75 f7                	jne    8006a2 <vprintfmt+0x3b7>
  8006ab:	e9 61 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b3:	5b                   	pop    %ebx
  8006b4:	5e                   	pop    %esi
  8006b5:	5f                   	pop    %edi
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	83 ec 18             	sub    $0x18,%esp
  8006be:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 26                	je     8006ff <vsnprintf+0x47>
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	7e 22                	jle    8006ff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006dd:	ff 75 14             	pushl  0x14(%ebp)
  8006e0:	ff 75 10             	pushl  0x10(%ebp)
  8006e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e6:	50                   	push   %eax
  8006e7:	68 b1 02 80 00       	push   $0x8002b1
  8006ec:	e8 fa fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb 05                	jmp    800704 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    

00800706 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800706:	55                   	push   %ebp
  800707:	89 e5                	mov    %esp,%ebp
  800709:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070f:	50                   	push   %eax
  800710:	ff 75 10             	pushl  0x10(%ebp)
  800713:	ff 75 0c             	pushl  0xc(%ebp)
  800716:	ff 75 08             	pushl  0x8(%ebp)
  800719:	e8 9a ff ff ff       	call   8006b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071e:	c9                   	leave  
  80071f:	c3                   	ret    

00800720 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
  80072b:	eb 03                	jmp    800730 <strlen+0x10>
		n++;
  80072d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800730:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800734:	75 f7                	jne    80072d <strlen+0xd>
		n++;
	return n;
}
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	eb 03                	jmp    80074b <strnlen+0x13>
		n++;
  800748:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074b:	39 c2                	cmp    %eax,%edx
  80074d:	74 08                	je     800757 <strnlen+0x1f>
  80074f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800753:	75 f3                	jne    800748 <strnlen+0x10>
  800755:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	53                   	push   %ebx
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800763:	89 c2                	mov    %eax,%edx
  800765:	83 c2 01             	add    $0x1,%edx
  800768:	83 c1 01             	add    $0x1,%ecx
  80076b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800772:	84 db                	test   %bl,%bl
  800774:	75 ef                	jne    800765 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800776:	5b                   	pop    %ebx
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800780:	53                   	push   %ebx
  800781:	e8 9a ff ff ff       	call   800720 <strlen>
  800786:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	01 d8                	add    %ebx,%eax
  80078e:	50                   	push   %eax
  80078f:	e8 c5 ff ff ff       	call   800759 <strcpy>
	return dst;
}
  800794:	89 d8                	mov    %ebx,%eax
  800796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800799:	c9                   	leave  
  80079a:	c3                   	ret    

0080079b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	56                   	push   %esi
  80079f:	53                   	push   %ebx
  8007a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a6:	89 f3                	mov    %esi,%ebx
  8007a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	89 f2                	mov    %esi,%edx
  8007ad:	eb 0f                	jmp    8007be <strncpy+0x23>
		*dst++ = *src;
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	0f b6 01             	movzbl (%ecx),%eax
  8007b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007be:	39 da                	cmp    %ebx,%edx
  8007c0:	75 ed                	jne    8007af <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c2:	89 f0                	mov    %esi,%eax
  8007c4:	5b                   	pop    %ebx
  8007c5:	5e                   	pop    %esi
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	56                   	push   %esi
  8007cc:	53                   	push   %ebx
  8007cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d8:	85 d2                	test   %edx,%edx
  8007da:	74 21                	je     8007fd <strlcpy+0x35>
  8007dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e0:	89 f2                	mov    %esi,%edx
  8007e2:	eb 09                	jmp    8007ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	74 09                	je     8007fa <strlcpy+0x32>
  8007f1:	0f b6 19             	movzbl (%ecx),%ebx
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ec                	jne    8007e4 <strlcpy+0x1c>
  8007f8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fd:	29 f0                	sub    %esi,%eax
}
  8007ff:	5b                   	pop    %ebx
  800800:	5e                   	pop    %esi
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080c:	eb 06                	jmp    800814 <strcmp+0x11>
		p++, q++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800814:	0f b6 01             	movzbl (%ecx),%eax
  800817:	84 c0                	test   %al,%al
  800819:	74 04                	je     80081f <strcmp+0x1c>
  80081b:	3a 02                	cmp    (%edx),%al
  80081d:	74 ef                	je     80080e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081f:	0f b6 c0             	movzbl %al,%eax
  800822:	0f b6 12             	movzbl (%edx),%edx
  800825:	29 d0                	sub    %edx,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
  800833:	89 c3                	mov    %eax,%ebx
  800835:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800838:	eb 06                	jmp    800840 <strncmp+0x17>
		n--, p++, q++;
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800840:	39 d8                	cmp    %ebx,%eax
  800842:	74 15                	je     800859 <strncmp+0x30>
  800844:	0f b6 08             	movzbl (%eax),%ecx
  800847:	84 c9                	test   %cl,%cl
  800849:	74 04                	je     80084f <strncmp+0x26>
  80084b:	3a 0a                	cmp    (%edx),%cl
  80084d:	74 eb                	je     80083a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084f:	0f b6 00             	movzbl (%eax),%eax
  800852:	0f b6 12             	movzbl (%edx),%edx
  800855:	29 d0                	sub    %edx,%eax
  800857:	eb 05                	jmp    80085e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085e:	5b                   	pop    %ebx
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086b:	eb 07                	jmp    800874 <strchr+0x13>
		if (*s == c)
  80086d:	38 ca                	cmp    %cl,%dl
  80086f:	74 0f                	je     800880 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800871:	83 c0 01             	add    $0x1,%eax
  800874:	0f b6 10             	movzbl (%eax),%edx
  800877:	84 d2                	test   %dl,%dl
  800879:	75 f2                	jne    80086d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088c:	eb 03                	jmp    800891 <strfind+0xf>
  80088e:	83 c0 01             	add    $0x1,%eax
  800891:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 04                	je     80089c <strfind+0x1a>
  800898:	84 d2                	test   %dl,%dl
  80089a:	75 f2                	jne    80088e <strfind+0xc>
			break;
	return (char *) s;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	57                   	push   %edi
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008aa:	85 c9                	test   %ecx,%ecx
  8008ac:	74 36                	je     8008e4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b4:	75 28                	jne    8008de <memset+0x40>
  8008b6:	f6 c1 03             	test   $0x3,%cl
  8008b9:	75 23                	jne    8008de <memset+0x40>
		c &= 0xFF;
  8008bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bf:	89 d3                	mov    %edx,%ebx
  8008c1:	c1 e3 08             	shl    $0x8,%ebx
  8008c4:	89 d6                	mov    %edx,%esi
  8008c6:	c1 e6 18             	shl    $0x18,%esi
  8008c9:	89 d0                	mov    %edx,%eax
  8008cb:	c1 e0 10             	shl    $0x10,%eax
  8008ce:	09 f0                	or     %esi,%eax
  8008d0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d2:	89 d8                	mov    %ebx,%eax
  8008d4:	09 d0                	or     %edx,%eax
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
  8008d9:	fc                   	cld    
  8008da:	f3 ab                	rep stos %eax,%es:(%edi)
  8008dc:	eb 06                	jmp    8008e4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e1:	fc                   	cld    
  8008e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e4:	89 f8                	mov    %edi,%eax
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5f                   	pop    %edi
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	57                   	push   %edi
  8008ef:	56                   	push   %esi
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f9:	39 c6                	cmp    %eax,%esi
  8008fb:	73 35                	jae    800932 <memmove+0x47>
  8008fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800900:	39 d0                	cmp    %edx,%eax
  800902:	73 2e                	jae    800932 <memmove+0x47>
		s += n;
		d += n;
  800904:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800907:	89 d6                	mov    %edx,%esi
  800909:	09 fe                	or     %edi,%esi
  80090b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800911:	75 13                	jne    800926 <memmove+0x3b>
  800913:	f6 c1 03             	test   $0x3,%cl
  800916:	75 0e                	jne    800926 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800918:	83 ef 04             	sub    $0x4,%edi
  80091b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091e:	c1 e9 02             	shr    $0x2,%ecx
  800921:	fd                   	std    
  800922:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800924:	eb 09                	jmp    80092f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800926:	83 ef 01             	sub    $0x1,%edi
  800929:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092c:	fd                   	std    
  80092d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092f:	fc                   	cld    
  800930:	eb 1d                	jmp    80094f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800932:	89 f2                	mov    %esi,%edx
  800934:	09 c2                	or     %eax,%edx
  800936:	f6 c2 03             	test   $0x3,%dl
  800939:	75 0f                	jne    80094a <memmove+0x5f>
  80093b:	f6 c1 03             	test   $0x3,%cl
  80093e:	75 0a                	jne    80094a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	89 c7                	mov    %eax,%edi
  800945:	fc                   	cld    
  800946:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800948:	eb 05                	jmp    80094f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800956:	ff 75 10             	pushl  0x10(%ebp)
  800959:	ff 75 0c             	pushl  0xc(%ebp)
  80095c:	ff 75 08             	pushl  0x8(%ebp)
  80095f:	e8 87 ff ff ff       	call   8008eb <memmove>
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	56                   	push   %esi
  80096a:	53                   	push   %ebx
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800971:	89 c6                	mov    %eax,%esi
  800973:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800976:	eb 1a                	jmp    800992 <memcmp+0x2c>
		if (*s1 != *s2)
  800978:	0f b6 08             	movzbl (%eax),%ecx
  80097b:	0f b6 1a             	movzbl (%edx),%ebx
  80097e:	38 d9                	cmp    %bl,%cl
  800980:	74 0a                	je     80098c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800982:	0f b6 c1             	movzbl %cl,%eax
  800985:	0f b6 db             	movzbl %bl,%ebx
  800988:	29 d8                	sub    %ebx,%eax
  80098a:	eb 0f                	jmp    80099b <memcmp+0x35>
		s1++, s2++;
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800992:	39 f0                	cmp    %esi,%eax
  800994:	75 e2                	jne    800978 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a6:	89 c1                	mov    %eax,%ecx
  8009a8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009af:	eb 0a                	jmp    8009bb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b1:	0f b6 10             	movzbl (%eax),%edx
  8009b4:	39 da                	cmp    %ebx,%edx
  8009b6:	74 07                	je     8009bf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	39 c8                	cmp    %ecx,%eax
  8009bd:	72 f2                	jb     8009b1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	57                   	push   %edi
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	eb 03                	jmp    8009d3 <strtol+0x11>
		s++;
  8009d0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	3c 20                	cmp    $0x20,%al
  8009d8:	74 f6                	je     8009d0 <strtol+0xe>
  8009da:	3c 09                	cmp    $0x9,%al
  8009dc:	74 f2                	je     8009d0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009de:	3c 2b                	cmp    $0x2b,%al
  8009e0:	75 0a                	jne    8009ec <strtol+0x2a>
		s++;
  8009e2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ea:	eb 11                	jmp    8009fd <strtol+0x3b>
  8009ec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f1:	3c 2d                	cmp    $0x2d,%al
  8009f3:	75 08                	jne    8009fd <strtol+0x3b>
		s++, neg = 1;
  8009f5:	83 c1 01             	add    $0x1,%ecx
  8009f8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a03:	75 15                	jne    800a1a <strtol+0x58>
  800a05:	80 39 30             	cmpb   $0x30,(%ecx)
  800a08:	75 10                	jne    800a1a <strtol+0x58>
  800a0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0e:	75 7c                	jne    800a8c <strtol+0xca>
		s += 2, base = 16;
  800a10:	83 c1 02             	add    $0x2,%ecx
  800a13:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a18:	eb 16                	jmp    800a30 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1a:	85 db                	test   %ebx,%ebx
  800a1c:	75 12                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 08                	jne    800a30 <strtol+0x6e>
		s++, base = 8;
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
  800a35:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a38:	0f b6 11             	movzbl (%ecx),%edx
  800a3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3e:	89 f3                	mov    %esi,%ebx
  800a40:	80 fb 09             	cmp    $0x9,%bl
  800a43:	77 08                	ja     800a4d <strtol+0x8b>
			dig = *s - '0';
  800a45:	0f be d2             	movsbl %dl,%edx
  800a48:	83 ea 30             	sub    $0x30,%edx
  800a4b:	eb 22                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a50:	89 f3                	mov    %esi,%ebx
  800a52:	80 fb 19             	cmp    $0x19,%bl
  800a55:	77 08                	ja     800a5f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a57:	0f be d2             	movsbl %dl,%edx
  800a5a:	83 ea 57             	sub    $0x57,%edx
  800a5d:	eb 10                	jmp    800a6f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 19             	cmp    $0x19,%bl
  800a67:	77 16                	ja     800a7f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a72:	7d 0b                	jge    800a7f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7d:	eb b9                	jmp    800a38 <strtol+0x76>

	if (endptr)
  800a7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a83:	74 0d                	je     800a92 <strtol+0xd0>
		*endptr = (char *) s;
  800a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a88:	89 0e                	mov    %ecx,(%esi)
  800a8a:	eb 06                	jmp    800a92 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8c:	85 db                	test   %ebx,%ebx
  800a8e:	74 98                	je     800a28 <strtol+0x66>
  800a90:	eb 9e                	jmp    800a30 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a92:	89 c2                	mov    %eax,%edx
  800a94:	f7 da                	neg    %edx
  800a96:	85 ff                	test   %edi,%edi
  800a98:	0f 45 c2             	cmovne %edx,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	89 c7                	mov    %eax,%edi
  800ab5:	89 c6                	mov    %eax,%esi
  800ab7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cgetc>:

int
sys_cgetc(void)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	89 d1                	mov    %edx,%ecx
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	89 d7                	mov    %edx,%edi
  800ad4:	89 d6                	mov    %edx,%esi
  800ad6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
  800ae3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aeb:	b8 03 00 00 00       	mov    $0x3,%eax
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
  800af3:	89 cb                	mov    %ecx,%ebx
  800af5:	89 cf                	mov    %ecx,%edi
  800af7:	89 ce                	mov    %ecx,%esi
  800af9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	7e 17                	jle    800b16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aff:	83 ec 0c             	sub    $0xc,%esp
  800b02:	50                   	push   %eax
  800b03:	6a 03                	push   $0x3
  800b05:	68 df 2b 80 00       	push   $0x802bdf
  800b0a:	6a 23                	push   $0x23
  800b0c:	68 fc 2b 80 00       	push   $0x802bfc
  800b11:	e8 c5 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_yield>:

void
sys_yield(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	be 00 00 00 00       	mov    $0x0,%esi
  800b6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b78:	89 f7                	mov    %esi,%edi
  800b7a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7c:	85 c0                	test   %eax,%eax
  800b7e:	7e 17                	jle    800b97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	50                   	push   %eax
  800b84:	6a 04                	push   $0x4
  800b86:	68 df 2b 80 00       	push   $0x802bdf
  800b8b:	6a 23                	push   $0x23
  800b8d:	68 fc 2b 80 00       	push   $0x802bfc
  800b92:	e8 44 f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	7e 17                	jle    800bd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 05                	push   $0x5
  800bc8:	68 df 2b 80 00       	push   $0x802bdf
  800bcd:	6a 23                	push   $0x23
  800bcf:	68 fc 2b 80 00       	push   $0x802bfc
  800bd4:	e8 02 f5 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bef:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 df                	mov    %ebx,%edi
  800bfc:	89 de                	mov    %ebx,%esi
  800bfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c00:	85 c0                	test   %eax,%eax
  800c02:	7e 17                	jle    800c1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 06                	push   $0x6
  800c0a:	68 df 2b 80 00       	push   $0x802bdf
  800c0f:	6a 23                	push   $0x23
  800c11:	68 fc 2b 80 00       	push   $0x802bfc
  800c16:	e8 c0 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c31:	b8 08 00 00 00       	mov    $0x8,%eax
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 df                	mov    %ebx,%edi
  800c3e:	89 de                	mov    %ebx,%esi
  800c40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c42:	85 c0                	test   %eax,%eax
  800c44:	7e 17                	jle    800c5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c46:	83 ec 0c             	sub    $0xc,%esp
  800c49:	50                   	push   %eax
  800c4a:	6a 08                	push   $0x8
  800c4c:	68 df 2b 80 00       	push   $0x802bdf
  800c51:	6a 23                	push   $0x23
  800c53:	68 fc 2b 80 00       	push   $0x802bfc
  800c58:	e8 7e f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	b8 09 00 00 00       	mov    $0x9,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7e 17                	jle    800c9f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c88:	83 ec 0c             	sub    $0xc,%esp
  800c8b:	50                   	push   %eax
  800c8c:	6a 09                	push   $0x9
  800c8e:	68 df 2b 80 00       	push   $0x802bdf
  800c93:	6a 23                	push   $0x23
  800c95:	68 fc 2b 80 00       	push   $0x802bfc
  800c9a:	e8 3c f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc0:	89 df                	mov    %ebx,%edi
  800cc2:	89 de                	mov    %ebx,%esi
  800cc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	7e 17                	jle    800ce1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cca:	83 ec 0c             	sub    $0xc,%esp
  800ccd:	50                   	push   %eax
  800cce:	6a 0a                	push   $0xa
  800cd0:	68 df 2b 80 00       	push   $0x802bdf
  800cd5:	6a 23                	push   $0x23
  800cd7:	68 fc 2b 80 00       	push   $0x802bfc
  800cdc:	e8 fa f3 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	be 00 00 00 00       	mov    $0x0,%esi
  800cf4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 cb                	mov    %ecx,%ebx
  800d24:	89 cf                	mov    %ecx,%edi
  800d26:	89 ce                	mov    %ecx,%esi
  800d28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	7e 17                	jle    800d45 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2e:	83 ec 0c             	sub    $0xc,%esp
  800d31:	50                   	push   %eax
  800d32:	6a 0d                	push   $0xd
  800d34:	68 df 2b 80 00       	push   $0x802bdf
  800d39:	6a 23                	push   $0x23
  800d3b:	68 fc 2b 80 00       	push   $0x802bfc
  800d40:	e8 96 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	ba 00 00 00 00       	mov    $0x0,%edx
  800d58:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5d:	89 d1                	mov    %edx,%ecx
  800d5f:	89 d3                	mov    %edx,%ebx
  800d61:	89 d7                	mov    %edx,%edi
  800d63:	89 d6                	mov    %edx,%esi
  800d65:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	05 00 00 00 30       	add    $0x30000000,%eax
  800d77:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    

00800d7c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	05 00 00 00 30       	add    $0x30000000,%eax
  800d87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d99:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9e:	89 c2                	mov    %eax,%edx
  800da0:	c1 ea 16             	shr    $0x16,%edx
  800da3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800daa:	f6 c2 01             	test   $0x1,%dl
  800dad:	74 11                	je     800dc0 <fd_alloc+0x2d>
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	c1 ea 0c             	shr    $0xc,%edx
  800db4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbb:	f6 c2 01             	test   $0x1,%dl
  800dbe:	75 09                	jne    800dc9 <fd_alloc+0x36>
			*fd_store = fd;
  800dc0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc7:	eb 17                	jmp    800de0 <fd_alloc+0x4d>
  800dc9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dd3:	75 c9                	jne    800d9e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dd5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ddb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de8:	83 f8 1f             	cmp    $0x1f,%eax
  800deb:	77 36                	ja     800e23 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ded:	c1 e0 0c             	shl    $0xc,%eax
  800df0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df5:	89 c2                	mov    %eax,%edx
  800df7:	c1 ea 16             	shr    $0x16,%edx
  800dfa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e01:	f6 c2 01             	test   $0x1,%dl
  800e04:	74 24                	je     800e2a <fd_lookup+0x48>
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	c1 ea 0c             	shr    $0xc,%edx
  800e0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e12:	f6 c2 01             	test   $0x1,%dl
  800e15:	74 1a                	je     800e31 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1a:	89 02                	mov    %eax,(%edx)
	return 0;
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e21:	eb 13                	jmp    800e36 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e28:	eb 0c                	jmp    800e36 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e2f:	eb 05                	jmp    800e36 <fd_lookup+0x54>
  800e31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    

00800e38 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e38:	55                   	push   %ebp
  800e39:	89 e5                	mov    %esp,%ebp
  800e3b:	83 ec 08             	sub    $0x8,%esp
  800e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e41:	ba 88 2c 80 00       	mov    $0x802c88,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e46:	eb 13                	jmp    800e5b <dev_lookup+0x23>
  800e48:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e4b:	39 08                	cmp    %ecx,(%eax)
  800e4d:	75 0c                	jne    800e5b <dev_lookup+0x23>
			*dev = devtab[i];
  800e4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e52:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e54:	b8 00 00 00 00       	mov    $0x0,%eax
  800e59:	eb 2e                	jmp    800e89 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e5b:	8b 02                	mov    (%edx),%eax
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	75 e7                	jne    800e48 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e61:	a1 08 40 80 00       	mov    0x804008,%eax
  800e66:	8b 40 48             	mov    0x48(%eax),%eax
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	51                   	push   %ecx
  800e6d:	50                   	push   %eax
  800e6e:	68 0c 2c 80 00       	push   $0x802c0c
  800e73:	e8 3c f3 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	56                   	push   %esi
  800e8f:	53                   	push   %ebx
  800e90:	83 ec 10             	sub    $0x10,%esp
  800e93:	8b 75 08             	mov    0x8(%ebp),%esi
  800e96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9c:	50                   	push   %eax
  800e9d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea3:	c1 e8 0c             	shr    $0xc,%eax
  800ea6:	50                   	push   %eax
  800ea7:	e8 36 ff ff ff       	call   800de2 <fd_lookup>
  800eac:	83 c4 08             	add    $0x8,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	78 05                	js     800eb8 <fd_close+0x2d>
	    || fd != fd2)
  800eb3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800eb6:	74 0c                	je     800ec4 <fd_close+0x39>
		return (must_exist ? r : 0);
  800eb8:	84 db                	test   %bl,%bl
  800eba:	ba 00 00 00 00       	mov    $0x0,%edx
  800ebf:	0f 44 c2             	cmove  %edx,%eax
  800ec2:	eb 41                	jmp    800f05 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eca:	50                   	push   %eax
  800ecb:	ff 36                	pushl  (%esi)
  800ecd:	e8 66 ff ff ff       	call   800e38 <dev_lookup>
  800ed2:	89 c3                	mov    %eax,%ebx
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 1a                	js     800ef5 <fd_close+0x6a>
		if (dev->dev_close)
  800edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ede:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	74 0b                	je     800ef5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eea:	83 ec 0c             	sub    $0xc,%esp
  800eed:	56                   	push   %esi
  800eee:	ff d0                	call   *%eax
  800ef0:	89 c3                	mov    %eax,%ebx
  800ef2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	56                   	push   %esi
  800ef9:	6a 00                	push   $0x0
  800efb:	e8 e1 fc ff ff       	call   800be1 <sys_page_unmap>
	return r;
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	89 d8                	mov    %ebx,%eax
}
  800f05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f15:	50                   	push   %eax
  800f16:	ff 75 08             	pushl  0x8(%ebp)
  800f19:	e8 c4 fe ff ff       	call   800de2 <fd_lookup>
  800f1e:	83 c4 08             	add    $0x8,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 10                	js     800f35 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	6a 01                	push   $0x1
  800f2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f2d:	e8 59 ff ff ff       	call   800e8b <fd_close>
  800f32:	83 c4 10             	add    $0x10,%esp
}
  800f35:	c9                   	leave  
  800f36:	c3                   	ret    

00800f37 <close_all>:

void
close_all(void)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f3e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f43:	83 ec 0c             	sub    $0xc,%esp
  800f46:	53                   	push   %ebx
  800f47:	e8 c0 ff ff ff       	call   800f0c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4c:	83 c3 01             	add    $0x1,%ebx
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	83 fb 20             	cmp    $0x20,%ebx
  800f55:	75 ec                	jne    800f43 <close_all+0xc>
		close(i);
}
  800f57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    

00800f5c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	57                   	push   %edi
  800f60:	56                   	push   %esi
  800f61:	53                   	push   %ebx
  800f62:	83 ec 2c             	sub    $0x2c,%esp
  800f65:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f68:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f6b:	50                   	push   %eax
  800f6c:	ff 75 08             	pushl  0x8(%ebp)
  800f6f:	e8 6e fe ff ff       	call   800de2 <fd_lookup>
  800f74:	83 c4 08             	add    $0x8,%esp
  800f77:	85 c0                	test   %eax,%eax
  800f79:	0f 88 c1 00 00 00    	js     801040 <dup+0xe4>
		return r;
	close(newfdnum);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	56                   	push   %esi
  800f83:	e8 84 ff ff ff       	call   800f0c <close>

	newfd = INDEX2FD(newfdnum);
  800f88:	89 f3                	mov    %esi,%ebx
  800f8a:	c1 e3 0c             	shl    $0xc,%ebx
  800f8d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f93:	83 c4 04             	add    $0x4,%esp
  800f96:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f99:	e8 de fd ff ff       	call   800d7c <fd2data>
  800f9e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fa0:	89 1c 24             	mov    %ebx,(%esp)
  800fa3:	e8 d4 fd ff ff       	call   800d7c <fd2data>
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fae:	89 f8                	mov    %edi,%eax
  800fb0:	c1 e8 16             	shr    $0x16,%eax
  800fb3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fba:	a8 01                	test   $0x1,%al
  800fbc:	74 37                	je     800ff5 <dup+0x99>
  800fbe:	89 f8                	mov    %edi,%eax
  800fc0:	c1 e8 0c             	shr    $0xc,%eax
  800fc3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fca:	f6 c2 01             	test   $0x1,%dl
  800fcd:	74 26                	je     800ff5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fcf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	25 07 0e 00 00       	and    $0xe07,%eax
  800fde:	50                   	push   %eax
  800fdf:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fe2:	6a 00                	push   $0x0
  800fe4:	57                   	push   %edi
  800fe5:	6a 00                	push   $0x0
  800fe7:	e8 b3 fb ff ff       	call   800b9f <sys_page_map>
  800fec:	89 c7                	mov    %eax,%edi
  800fee:	83 c4 20             	add    $0x20,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 2e                	js     801023 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ff5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ff8:	89 d0                	mov    %edx,%eax
  800ffa:	c1 e8 0c             	shr    $0xc,%eax
  800ffd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	25 07 0e 00 00       	and    $0xe07,%eax
  80100c:	50                   	push   %eax
  80100d:	53                   	push   %ebx
  80100e:	6a 00                	push   $0x0
  801010:	52                   	push   %edx
  801011:	6a 00                	push   $0x0
  801013:	e8 87 fb ff ff       	call   800b9f <sys_page_map>
  801018:	89 c7                	mov    %eax,%edi
  80101a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80101d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80101f:	85 ff                	test   %edi,%edi
  801021:	79 1d                	jns    801040 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801023:	83 ec 08             	sub    $0x8,%esp
  801026:	53                   	push   %ebx
  801027:	6a 00                	push   $0x0
  801029:	e8 b3 fb ff ff       	call   800be1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80102e:	83 c4 08             	add    $0x8,%esp
  801031:	ff 75 d4             	pushl  -0x2c(%ebp)
  801034:	6a 00                	push   $0x0
  801036:	e8 a6 fb ff ff       	call   800be1 <sys_page_unmap>
	return r;
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	89 f8                	mov    %edi,%eax
}
  801040:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	53                   	push   %ebx
  80104c:	83 ec 14             	sub    $0x14,%esp
  80104f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801052:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801055:	50                   	push   %eax
  801056:	53                   	push   %ebx
  801057:	e8 86 fd ff ff       	call   800de2 <fd_lookup>
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	89 c2                	mov    %eax,%edx
  801061:	85 c0                	test   %eax,%eax
  801063:	78 6d                	js     8010d2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106b:	50                   	push   %eax
  80106c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80106f:	ff 30                	pushl  (%eax)
  801071:	e8 c2 fd ff ff       	call   800e38 <dev_lookup>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 4c                	js     8010c9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80107d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801080:	8b 42 08             	mov    0x8(%edx),%eax
  801083:	83 e0 03             	and    $0x3,%eax
  801086:	83 f8 01             	cmp    $0x1,%eax
  801089:	75 21                	jne    8010ac <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80108b:	a1 08 40 80 00       	mov    0x804008,%eax
  801090:	8b 40 48             	mov    0x48(%eax),%eax
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	53                   	push   %ebx
  801097:	50                   	push   %eax
  801098:	68 4d 2c 80 00       	push   $0x802c4d
  80109d:	e8 12 f1 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010aa:	eb 26                	jmp    8010d2 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010af:	8b 40 08             	mov    0x8(%eax),%eax
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	74 17                	je     8010cd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	ff 75 0c             	pushl  0xc(%ebp)
  8010bf:	52                   	push   %edx
  8010c0:	ff d0                	call   *%eax
  8010c2:	89 c2                	mov    %eax,%edx
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	eb 09                	jmp    8010d2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	eb 05                	jmp    8010d2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010d2:	89 d0                	mov    %edx,%eax
  8010d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d7:	c9                   	leave  
  8010d8:	c3                   	ret    

008010d9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ed:	eb 21                	jmp    801110 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	89 f0                	mov    %esi,%eax
  8010f4:	29 d8                	sub    %ebx,%eax
  8010f6:	50                   	push   %eax
  8010f7:	89 d8                	mov    %ebx,%eax
  8010f9:	03 45 0c             	add    0xc(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	57                   	push   %edi
  8010fe:	e8 45 ff ff ff       	call   801048 <read>
		if (m < 0)
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	85 c0                	test   %eax,%eax
  801108:	78 10                	js     80111a <readn+0x41>
			return m;
		if (m == 0)
  80110a:	85 c0                	test   %eax,%eax
  80110c:	74 0a                	je     801118 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80110e:	01 c3                	add    %eax,%ebx
  801110:	39 f3                	cmp    %esi,%ebx
  801112:	72 db                	jb     8010ef <readn+0x16>
  801114:	89 d8                	mov    %ebx,%eax
  801116:	eb 02                	jmp    80111a <readn+0x41>
  801118:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	53                   	push   %ebx
  801126:	83 ec 14             	sub    $0x14,%esp
  801129:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	53                   	push   %ebx
  801131:	e8 ac fc ff ff       	call   800de2 <fd_lookup>
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	89 c2                	mov    %eax,%edx
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 68                	js     8011a7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801145:	50                   	push   %eax
  801146:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801149:	ff 30                	pushl  (%eax)
  80114b:	e8 e8 fc ff ff       	call   800e38 <dev_lookup>
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 47                	js     80119e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801157:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80115a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80115e:	75 21                	jne    801181 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801160:	a1 08 40 80 00       	mov    0x804008,%eax
  801165:	8b 40 48             	mov    0x48(%eax),%eax
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	53                   	push   %ebx
  80116c:	50                   	push   %eax
  80116d:	68 69 2c 80 00       	push   $0x802c69
  801172:	e8 3d f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80117f:	eb 26                	jmp    8011a7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801181:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801184:	8b 52 0c             	mov    0xc(%edx),%edx
  801187:	85 d2                	test   %edx,%edx
  801189:	74 17                	je     8011a2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80118b:	83 ec 04             	sub    $0x4,%esp
  80118e:	ff 75 10             	pushl  0x10(%ebp)
  801191:	ff 75 0c             	pushl  0xc(%ebp)
  801194:	50                   	push   %eax
  801195:	ff d2                	call   *%edx
  801197:	89 c2                	mov    %eax,%edx
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	eb 09                	jmp    8011a7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	eb 05                	jmp    8011a7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011a7:	89 d0                	mov    %edx,%eax
  8011a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    

008011ae <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011b4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 75 08             	pushl  0x8(%ebp)
  8011bb:	e8 22 fc ff ff       	call   800de2 <fd_lookup>
  8011c0:	83 c4 08             	add    $0x8,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 0e                	js     8011d5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011cd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	53                   	push   %ebx
  8011db:	83 ec 14             	sub    $0x14,%esp
  8011de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	53                   	push   %ebx
  8011e6:	e8 f7 fb ff ff       	call   800de2 <fd_lookup>
  8011eb:	83 c4 08             	add    $0x8,%esp
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 65                	js     801259 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f4:	83 ec 08             	sub    $0x8,%esp
  8011f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fa:	50                   	push   %eax
  8011fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fe:	ff 30                	pushl  (%eax)
  801200:	e8 33 fc ff ff       	call   800e38 <dev_lookup>
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 44                	js     801250 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801213:	75 21                	jne    801236 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801215:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80121a:	8b 40 48             	mov    0x48(%eax),%eax
  80121d:	83 ec 04             	sub    $0x4,%esp
  801220:	53                   	push   %ebx
  801221:	50                   	push   %eax
  801222:	68 2c 2c 80 00       	push   $0x802c2c
  801227:	e8 88 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801234:	eb 23                	jmp    801259 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801236:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801239:	8b 52 18             	mov    0x18(%edx),%edx
  80123c:	85 d2                	test   %edx,%edx
  80123e:	74 14                	je     801254 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	ff 75 0c             	pushl  0xc(%ebp)
  801246:	50                   	push   %eax
  801247:	ff d2                	call   *%edx
  801249:	89 c2                	mov    %eax,%edx
  80124b:	83 c4 10             	add    $0x10,%esp
  80124e:	eb 09                	jmp    801259 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801250:	89 c2                	mov    %eax,%edx
  801252:	eb 05                	jmp    801259 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801254:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801259:	89 d0                	mov    %edx,%eax
  80125b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	53                   	push   %ebx
  801264:	83 ec 14             	sub    $0x14,%esp
  801267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126d:	50                   	push   %eax
  80126e:	ff 75 08             	pushl  0x8(%ebp)
  801271:	e8 6c fb ff ff       	call   800de2 <fd_lookup>
  801276:	83 c4 08             	add    $0x8,%esp
  801279:	89 c2                	mov    %eax,%edx
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 58                	js     8012d7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	ff 30                	pushl  (%eax)
  80128b:	e8 a8 fb ff ff       	call   800e38 <dev_lookup>
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	85 c0                	test   %eax,%eax
  801295:	78 37                	js     8012ce <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801297:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80129e:	74 32                	je     8012d2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012aa:	00 00 00 
	stat->st_isdir = 0;
  8012ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012b4:	00 00 00 
	stat->st_dev = dev;
  8012b7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012bd:	83 ec 08             	sub    $0x8,%esp
  8012c0:	53                   	push   %ebx
  8012c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c4:	ff 50 14             	call   *0x14(%eax)
  8012c7:	89 c2                	mov    %eax,%edx
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	eb 09                	jmp    8012d7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	eb 05                	jmp    8012d7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012d7:	89 d0                	mov    %edx,%eax
  8012d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    

008012de <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	6a 00                	push   $0x0
  8012e8:	ff 75 08             	pushl  0x8(%ebp)
  8012eb:	e8 ef 01 00 00       	call   8014df <open>
  8012f0:	89 c3                	mov    %eax,%ebx
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 1b                	js     801314 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	ff 75 0c             	pushl  0xc(%ebp)
  8012ff:	50                   	push   %eax
  801300:	e8 5b ff ff ff       	call   801260 <fstat>
  801305:	89 c6                	mov    %eax,%esi
	close(fd);
  801307:	89 1c 24             	mov    %ebx,(%esp)
  80130a:	e8 fd fb ff ff       	call   800f0c <close>
	return r;
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	89 f0                	mov    %esi,%eax
}
  801314:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	56                   	push   %esi
  80131f:	53                   	push   %ebx
  801320:	89 c6                	mov    %eax,%esi
  801322:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801324:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80132b:	75 12                	jne    80133f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80132d:	83 ec 0c             	sub    $0xc,%esp
  801330:	6a 01                	push   $0x1
  801332:	e8 21 12 00 00       	call   802558 <ipc_find_env>
  801337:	a3 00 40 80 00       	mov    %eax,0x804000
  80133c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80133f:	6a 07                	push   $0x7
  801341:	68 00 50 80 00       	push   $0x805000
  801346:	56                   	push   %esi
  801347:	ff 35 00 40 80 00    	pushl  0x804000
  80134d:	e8 b7 11 00 00       	call   802509 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801352:	83 c4 0c             	add    $0xc,%esp
  801355:	6a 00                	push   $0x0
  801357:	53                   	push   %ebx
  801358:	6a 00                	push   $0x0
  80135a:	e8 34 11 00 00       	call   802493 <ipc_recv>
}
  80135f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80136c:	8b 45 08             	mov    0x8(%ebp),%eax
  80136f:	8b 40 0c             	mov    0xc(%eax),%eax
  801372:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801377:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80137f:	ba 00 00 00 00       	mov    $0x0,%edx
  801384:	b8 02 00 00 00       	mov    $0x2,%eax
  801389:	e8 8d ff ff ff       	call   80131b <fsipc>
}
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801396:	8b 45 08             	mov    0x8(%ebp),%eax
  801399:	8b 40 0c             	mov    0xc(%eax),%eax
  80139c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8013ab:	e8 6b ff ff ff       	call   80131b <fsipc>
}
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 04             	sub    $0x4,%esp
  8013b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d1:	e8 45 ff ff ff       	call   80131b <fsipc>
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	78 2c                	js     801406 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	68 00 50 80 00       	push   $0x805000
  8013e2:	53                   	push   %ebx
  8013e3:	e8 71 f3 ff ff       	call   800759 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013e8:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013f3:	a1 84 50 80 00       	mov    0x805084,%eax
  8013f8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	53                   	push   %ebx
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801415:	8b 55 08             	mov    0x8(%ebp),%edx
  801418:	8b 52 0c             	mov    0xc(%edx),%edx
  80141b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801421:	a3 04 50 80 00       	mov    %eax,0x805004
  801426:	3d 08 50 80 00       	cmp    $0x805008,%eax
  80142b:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801430:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801433:	53                   	push   %ebx
  801434:	ff 75 0c             	pushl  0xc(%ebp)
  801437:	68 08 50 80 00       	push   $0x805008
  80143c:	e8 aa f4 ff ff       	call   8008eb <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 04 00 00 00       	mov    $0x4,%eax
  80144b:	e8 cb fe ff ff       	call   80131b <fsipc>
  801450:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801453:	85 c0                	test   %eax,%eax
  801455:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  801458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
  801462:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801465:	8b 45 08             	mov    0x8(%ebp),%eax
  801468:	8b 40 0c             	mov    0xc(%eax),%eax
  80146b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801470:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801476:	ba 00 00 00 00       	mov    $0x0,%edx
  80147b:	b8 03 00 00 00       	mov    $0x3,%eax
  801480:	e8 96 fe ff ff       	call   80131b <fsipc>
  801485:	89 c3                	mov    %eax,%ebx
  801487:	85 c0                	test   %eax,%eax
  801489:	78 4b                	js     8014d6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80148b:	39 c6                	cmp    %eax,%esi
  80148d:	73 16                	jae    8014a5 <devfile_read+0x48>
  80148f:	68 9c 2c 80 00       	push   $0x802c9c
  801494:	68 a3 2c 80 00       	push   $0x802ca3
  801499:	6a 7c                	push   $0x7c
  80149b:	68 b8 2c 80 00       	push   $0x802cb8
  8014a0:	e8 36 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014aa:	7e 16                	jle    8014c2 <devfile_read+0x65>
  8014ac:	68 c3 2c 80 00       	push   $0x802cc3
  8014b1:	68 a3 2c 80 00       	push   $0x802ca3
  8014b6:	6a 7d                	push   $0x7d
  8014b8:	68 b8 2c 80 00       	push   $0x802cb8
  8014bd:	e8 19 ec ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	50                   	push   %eax
  8014c6:	68 00 50 80 00       	push   $0x805000
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	e8 18 f4 ff ff       	call   8008eb <memmove>
	return r;
  8014d3:	83 c4 10             	add    $0x10,%esp
}
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 20             	sub    $0x20,%esp
  8014e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e9:	53                   	push   %ebx
  8014ea:	e8 31 f2 ff ff       	call   800720 <strlen>
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f7:	7f 67                	jg     801560 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	e8 8e f8 ff ff       	call   800d93 <fd_alloc>
  801505:	83 c4 10             	add    $0x10,%esp
		return r;
  801508:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 57                	js     801565 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	53                   	push   %ebx
  801512:	68 00 50 80 00       	push   $0x805000
  801517:	e8 3d f2 ff ff       	call   800759 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80151c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801524:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801527:	b8 01 00 00 00       	mov    $0x1,%eax
  80152c:	e8 ea fd ff ff       	call   80131b <fsipc>
  801531:	89 c3                	mov    %eax,%ebx
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	79 14                	jns    80154e <open+0x6f>
		fd_close(fd, 0);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	6a 00                	push   $0x0
  80153f:	ff 75 f4             	pushl  -0xc(%ebp)
  801542:	e8 44 f9 ff ff       	call   800e8b <fd_close>
		return r;
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	89 da                	mov    %ebx,%edx
  80154c:	eb 17                	jmp    801565 <open+0x86>
	}

	return fd2num(fd);
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	ff 75 f4             	pushl  -0xc(%ebp)
  801554:	e8 13 f8 ff ff       	call   800d6c <fd2num>
  801559:	89 c2                	mov    %eax,%edx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb 05                	jmp    801565 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801560:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801565:	89 d0                	mov    %edx,%eax
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 08 00 00 00       	mov    $0x8,%eax
  80157c:	e8 9a fd ff ff       	call   80131b <fsipc>
}
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	57                   	push   %edi
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80158f:	6a 00                	push   $0x0
  801591:	ff 75 08             	pushl  0x8(%ebp)
  801594:	e8 46 ff ff ff       	call   8014df <open>
  801599:	89 c7                	mov    %eax,%edi
  80159b:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	85 c0                	test   %eax,%eax
  8015a6:	0f 88 81 04 00 00    	js     801a2d <spawn+0x4aa>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	68 00 02 00 00       	push   $0x200
  8015b4:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	57                   	push   %edi
  8015bc:	e8 18 fb ff ff       	call   8010d9 <readn>
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015c9:	75 0c                	jne    8015d7 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015cb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015d2:	45 4c 46 
  8015d5:	74 33                	je     80160a <spawn+0x87>
		close(fd);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8015e0:	e8 27 f9 ff ff       	call   800f0c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015e5:	83 c4 0c             	add    $0xc,%esp
  8015e8:	68 7f 45 4c 46       	push   $0x464c457f
  8015ed:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015f3:	68 cf 2c 80 00       	push   $0x802ccf
  8015f8:	e8 b7 eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801605:	e9 c6 04 00 00       	jmp    801ad0 <spawn+0x54d>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80160a:	b8 07 00 00 00       	mov    $0x7,%eax
  80160f:	cd 30                	int    $0x30
  801611:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801617:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	0f 88 13 04 00 00    	js     801a38 <spawn+0x4b5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801625:	89 c6                	mov    %eax,%esi
  801627:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80162d:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801630:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801636:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80163c:	b9 11 00 00 00       	mov    $0x11,%ecx
  801641:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801643:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801649:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80164f:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801654:	be 00 00 00 00       	mov    $0x0,%esi
  801659:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80165c:	eb 13                	jmp    801671 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	50                   	push   %eax
  801662:	e8 b9 f0 ff ff       	call   800720 <strlen>
  801667:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80166b:	83 c3 01             	add    $0x1,%ebx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801678:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80167b:	85 c0                	test   %eax,%eax
  80167d:	75 df                	jne    80165e <spawn+0xdb>
  80167f:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801685:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80168b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801690:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801692:	89 fa                	mov    %edi,%edx
  801694:	83 e2 fc             	and    $0xfffffffc,%edx
  801697:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80169e:	29 c2                	sub    %eax,%edx
  8016a0:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016a6:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016a9:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016ae:	0f 86 9a 03 00 00    	jbe    801a4e <spawn+0x4cb>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016b4:	83 ec 04             	sub    $0x4,%esp
  8016b7:	6a 07                	push   $0x7
  8016b9:	68 00 00 40 00       	push   $0x400000
  8016be:	6a 00                	push   $0x0
  8016c0:	e8 97 f4 ff ff       	call   800b5c <sys_page_alloc>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	0f 88 85 03 00 00    	js     801a55 <spawn+0x4d2>
  8016d0:	be 00 00 00 00       	mov    $0x0,%esi
  8016d5:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016de:	eb 30                	jmp    801710 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8016e0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016e6:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016ec:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016f5:	57                   	push   %edi
  8016f6:	e8 5e f0 ff ff       	call   800759 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016fb:	83 c4 04             	add    $0x4,%esp
  8016fe:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801701:	e8 1a f0 ff ff       	call   800720 <strlen>
  801706:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80170a:	83 c6 01             	add    $0x1,%esi
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801716:	7f c8                	jg     8016e0 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801718:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80171e:	8b b5 80 fd ff ff    	mov    -0x280(%ebp),%esi
  801724:	c7 04 30 00 00 00 00 	movl   $0x0,(%eax,%esi,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80172b:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801731:	74 19                	je     80174c <spawn+0x1c9>
  801733:	68 5c 2d 80 00       	push   $0x802d5c
  801738:	68 a3 2c 80 00       	push   $0x802ca3
  80173d:	68 f1 00 00 00       	push   $0xf1
  801742:	68 e9 2c 80 00       	push   $0x802ce9
  801747:	e8 8f e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80174c:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801752:	89 f8                	mov    %edi,%eax
  801754:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801759:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  80175c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801762:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801765:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80176b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801771:	83 ec 0c             	sub    $0xc,%esp
  801774:	6a 07                	push   $0x7
  801776:	68 00 d0 bf ee       	push   $0xeebfd000
  80177b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801781:	68 00 00 40 00       	push   $0x400000
  801786:	6a 00                	push   $0x0
  801788:	e8 12 f4 ff ff       	call   800b9f <sys_page_map>
  80178d:	89 c3                	mov    %eax,%ebx
  80178f:	83 c4 20             	add    $0x20,%esp
  801792:	85 c0                	test   %eax,%eax
  801794:	0f 88 24 03 00 00    	js     801abe <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	68 00 00 40 00       	push   $0x400000
  8017a2:	6a 00                	push   $0x0
  8017a4:	e8 38 f4 ff ff       	call   800be1 <sys_page_unmap>
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 c0                	test   %eax,%eax
  8017b0:	0f 88 08 03 00 00    	js     801abe <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017b6:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017bc:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017c3:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017c9:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017d0:	00 00 00 
  8017d3:	e9 8a 01 00 00       	jmp    801962 <spawn+0x3df>
		if (ph->p_type != ELF_PROG_LOAD)
  8017d8:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017de:	83 38 01             	cmpl   $0x1,(%eax)
  8017e1:	0f 85 6d 01 00 00    	jne    801954 <spawn+0x3d1>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017e7:	89 c7                	mov    %eax,%edi
  8017e9:	8b 40 18             	mov    0x18(%eax),%eax
  8017ec:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017f2:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8017f5:	83 f8 01             	cmp    $0x1,%eax
  8017f8:	19 c0                	sbb    %eax,%eax
  8017fa:	83 e0 fe             	and    $0xfffffffe,%eax
  8017fd:	83 c0 07             	add    $0x7,%eax
  801800:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801806:	89 f8                	mov    %edi,%eax
  801808:	8b 7f 04             	mov    0x4(%edi),%edi
  80180b:	89 f9                	mov    %edi,%ecx
  80180d:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801813:	8b 78 10             	mov    0x10(%eax),%edi
  801816:	8b 70 14             	mov    0x14(%eax),%esi
  801819:	89 f2                	mov    %esi,%edx
  80181b:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  801821:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801824:	89 f0                	mov    %esi,%eax
  801826:	25 ff 0f 00 00       	and    $0xfff,%eax
  80182b:	74 14                	je     801841 <spawn+0x2be>
		va -= i;
  80182d:	29 c6                	sub    %eax,%esi
		memsz += i;
  80182f:	01 c2                	add    %eax,%edx
  801831:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  801837:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801839:	29 c1                	sub    %eax,%ecx
  80183b:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801841:	bb 00 00 00 00       	mov    $0x0,%ebx
  801846:	e9 f7 00 00 00       	jmp    801942 <spawn+0x3bf>
		if (i >= filesz) {
  80184b:	39 df                	cmp    %ebx,%edi
  80184d:	77 27                	ja     801876 <spawn+0x2f3>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80184f:	83 ec 04             	sub    $0x4,%esp
  801852:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801858:	56                   	push   %esi
  801859:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80185f:	e8 f8 f2 ff ff       	call   800b5c <sys_page_alloc>
  801864:	83 c4 10             	add    $0x10,%esp
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 89 c7 00 00 00    	jns    801936 <spawn+0x3b3>
  80186f:	89 c3                	mov    %eax,%ebx
  801871:	e9 ed 01 00 00       	jmp    801a63 <spawn+0x4e0>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	6a 07                	push   $0x7
  80187b:	68 00 00 40 00       	push   $0x400000
  801880:	6a 00                	push   $0x0
  801882:	e8 d5 f2 ff ff       	call   800b5c <sys_page_alloc>
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	0f 88 c7 01 00 00    	js     801a59 <spawn+0x4d6>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80189b:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018a1:	50                   	push   %eax
  8018a2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018a8:	e8 01 f9 ff ff       	call   8011ae <seek>
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	0f 88 a5 01 00 00    	js     801a5d <spawn+0x4da>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	89 f8                	mov    %edi,%eax
  8018bd:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018c3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c8:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8018cd:	0f 47 c1             	cmova  %ecx,%eax
  8018d0:	50                   	push   %eax
  8018d1:	68 00 00 40 00       	push   $0x400000
  8018d6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018dc:	e8 f8 f7 ff ff       	call   8010d9 <readn>
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	0f 88 75 01 00 00    	js     801a61 <spawn+0x4de>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018f5:	56                   	push   %esi
  8018f6:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018fc:	68 00 00 40 00       	push   $0x400000
  801901:	6a 00                	push   $0x0
  801903:	e8 97 f2 ff ff       	call   800b9f <sys_page_map>
  801908:	83 c4 20             	add    $0x20,%esp
  80190b:	85 c0                	test   %eax,%eax
  80190d:	79 15                	jns    801924 <spawn+0x3a1>
				panic("spawn: sys_page_map data: %e", r);
  80190f:	50                   	push   %eax
  801910:	68 f5 2c 80 00       	push   $0x802cf5
  801915:	68 24 01 00 00       	push   $0x124
  80191a:	68 e9 2c 80 00       	push   $0x802ce9
  80191f:	e8 b7 e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	68 00 00 40 00       	push   $0x400000
  80192c:	6a 00                	push   $0x0
  80192e:	e8 ae f2 ff ff       	call   800be1 <sys_page_unmap>
  801933:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801936:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80193c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801942:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801948:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  80194e:	0f 87 f7 fe ff ff    	ja     80184b <spawn+0x2c8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801954:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80195b:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801962:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801969:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  80196f:	0f 8c 63 fe ff ff    	jl     8017d8 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801975:	83 ec 0c             	sub    $0xc,%esp
  801978:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80197e:	e8 89 f5 ff ff       	call   800f0c <close>
  801983:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  801986:	bb 00 00 00 00       	mov    $0x0,%ebx
  80198b:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801991:	89 d8                	mov    %ebx,%eax
  801993:	c1 e0 0c             	shl    $0xc,%eax
		if (((uvpd[PDX(pgnum*PGSIZE)] & PTE_P) && (uvpt[pgnum] & PTE_P) && (uvpt[pgnum] & PTE_SHARE))){
  801996:	89 c2                	mov    %eax,%edx
  801998:	c1 ea 16             	shr    $0x16,%edx
  80199b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019a2:	f6 c2 01             	test   $0x1,%dl
  8019a5:	74 35                	je     8019dc <spawn+0x459>
  8019a7:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  8019ae:	f6 c2 01             	test   $0x1,%dl
  8019b1:	74 29                	je     8019dc <spawn+0x459>
  8019b3:	8b 14 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%edx
  8019ba:	f6 c6 04             	test   $0x4,%dh
  8019bd:	74 1d                	je     8019dc <spawn+0x459>
			if((r=sys_page_map(0, (void *)(pgnum*PGSIZE), child, (void *)(pgnum*PGSIZE), PTE_SYSCALL))<0)
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	68 07 0e 00 00       	push   $0xe07
  8019c7:	50                   	push   %eax
  8019c8:	56                   	push   %esi
  8019c9:	50                   	push   %eax
  8019ca:	6a 00                	push   $0x0
  8019cc:	e8 ce f1 ff ff       	call   800b9f <sys_page_map>
  8019d1:	83 c4 20             	add    $0x20,%esp
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	0f 88 a8 00 00 00    	js     801a84 <spawn+0x501>
{
	// LAB 5: Your code here.
	int r;
	uint32_t pgnum;
		
	for(pgnum = 0; pgnum < PGNUM(UTOP); pgnum++){
  8019dc:	83 c3 01             	add    $0x1,%ebx
  8019df:	81 fb 00 ec 0e 00    	cmp    $0xeec00,%ebx
  8019e5:	75 aa                	jne    801991 <spawn+0x40e>
  8019e7:	e9 ad 00 00 00       	jmp    801a99 <spawn+0x516>
	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  8019ec:	50                   	push   %eax
  8019ed:	68 12 2d 80 00       	push   $0x802d12
  8019f2:	68 85 00 00 00       	push   $0x85
  8019f7:	68 e9 2c 80 00       	push   $0x802ce9
  8019fc:	e8 da e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a01:	83 ec 08             	sub    $0x8,%esp
  801a04:	6a 02                	push   $0x2
  801a06:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a0c:	e8 12 f2 ff ff       	call   800c23 <sys_env_set_status>
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	79 2b                	jns    801a43 <spawn+0x4c0>
		panic("sys_env_set_status: %e", r);
  801a18:	50                   	push   %eax
  801a19:	68 2c 2d 80 00       	push   $0x802d2c
  801a1e:	68 88 00 00 00       	push   $0x88
  801a23:	68 e9 2c 80 00       	push   $0x802ce9
  801a28:	e8 ae e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a2d:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a33:	e9 98 00 00 00       	jmp    801ad0 <spawn+0x54d>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a38:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a3e:	e9 8d 00 00 00       	jmp    801ad0 <spawn+0x54d>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a43:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a49:	e9 82 00 00 00       	jmp    801ad0 <spawn+0x54d>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a4e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a53:	eb 7b                	jmp    801ad0 <spawn+0x54d>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a55:	89 c3                	mov    %eax,%ebx
  801a57:	eb 77                	jmp    801ad0 <spawn+0x54d>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	eb 06                	jmp    801a63 <spawn+0x4e0>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a5d:	89 c3                	mov    %eax,%ebx
  801a5f:	eb 02                	jmp    801a63 <spawn+0x4e0>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a61:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a6c:	e8 6c f0 ff ff       	call   800add <sys_env_destroy>
	close(fd);
  801a71:	83 c4 04             	add    $0x4,%esp
  801a74:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a7a:	e8 8d f4 ff ff       	call   800f0c <close>
	return r;
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	eb 4c                	jmp    801ad0 <spawn+0x54d>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801a84:	50                   	push   %eax
  801a85:	68 43 2d 80 00       	push   $0x802d43
  801a8a:	68 82 00 00 00       	push   $0x82
  801a8f:	68 e9 2c 80 00       	push   $0x802ce9
  801a94:	e8 42 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a99:	83 ec 08             	sub    $0x8,%esp
  801a9c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aa9:	e8 b7 f1 ff ff       	call   800c65 <sys_env_set_trapframe>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	0f 89 48 ff ff ff    	jns    801a01 <spawn+0x47e>
  801ab9:	e9 2e ff ff ff       	jmp    8019ec <spawn+0x469>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	68 00 00 40 00       	push   $0x400000
  801ac6:	6a 00                	push   $0x0
  801ac8:	e8 14 f1 ff ff       	call   800be1 <sys_page_unmap>
  801acd:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ad0:	89 d8                	mov    %ebx,%eax
  801ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	56                   	push   %esi
  801ade:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801adf:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ae7:	eb 03                	jmp    801aec <spawnl+0x12>
		argc++;
  801ae9:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801aec:	83 c2 04             	add    $0x4,%edx
  801aef:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801af3:	75 f4                	jne    801ae9 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801af5:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801afc:	83 e2 f0             	and    $0xfffffff0,%edx
  801aff:	29 d4                	sub    %edx,%esp
  801b01:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b05:	c1 ea 02             	shr    $0x2,%edx
  801b08:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b0f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b14:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b1b:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b22:	00 
  801b23:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2a:	eb 0a                	jmp    801b36 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b2c:	83 c0 01             	add    $0x1,%eax
  801b2f:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b33:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b36:	39 d0                	cmp    %edx,%eax
  801b38:	75 f2                	jne    801b2c <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b3a:	83 ec 08             	sub    $0x8,%esp
  801b3d:	56                   	push   %esi
  801b3e:	ff 75 08             	pushl  0x8(%ebp)
  801b41:	e8 3d fa ff ff       	call   801583 <spawn>
}
  801b46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b49:	5b                   	pop    %ebx
  801b4a:	5e                   	pop    %esi
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    

00801b4d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b4d:	55                   	push   %ebp
  801b4e:	89 e5                	mov    %esp,%ebp
  801b50:	56                   	push   %esi
  801b51:	53                   	push   %ebx
  801b52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b55:	83 ec 0c             	sub    $0xc,%esp
  801b58:	ff 75 08             	pushl  0x8(%ebp)
  801b5b:	e8 1c f2 ff ff       	call   800d7c <fd2data>
  801b60:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b62:	83 c4 08             	add    $0x8,%esp
  801b65:	68 84 2d 80 00       	push   $0x802d84
  801b6a:	53                   	push   %ebx
  801b6b:	e8 e9 eb ff ff       	call   800759 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b70:	8b 46 04             	mov    0x4(%esi),%eax
  801b73:	2b 06                	sub    (%esi),%eax
  801b75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b7b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b82:	00 00 00 
	stat->st_dev = &devpipe;
  801b85:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b8c:	30 80 00 
	return 0;
}
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5e                   	pop    %esi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	53                   	push   %ebx
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ba5:	53                   	push   %ebx
  801ba6:	6a 00                	push   $0x0
  801ba8:	e8 34 f0 ff ff       	call   800be1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bad:	89 1c 24             	mov    %ebx,(%esp)
  801bb0:	e8 c7 f1 ff ff       	call   800d7c <fd2data>
  801bb5:	83 c4 08             	add    $0x8,%esp
  801bb8:	50                   	push   %eax
  801bb9:	6a 00                	push   $0x0
  801bbb:	e8 21 f0 ff ff       	call   800be1 <sys_page_unmap>
}
  801bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc3:	c9                   	leave  
  801bc4:	c3                   	ret    

00801bc5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	57                   	push   %edi
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 1c             	sub    $0x1c,%esp
  801bce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bd3:	a1 08 40 80 00       	mov    0x804008,%eax
  801bd8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	ff 75 e0             	pushl  -0x20(%ebp)
  801be1:	e8 ab 09 00 00       	call   802591 <pageref>
  801be6:	89 c3                	mov    %eax,%ebx
  801be8:	89 3c 24             	mov    %edi,(%esp)
  801beb:	e8 a1 09 00 00       	call   802591 <pageref>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	39 c3                	cmp    %eax,%ebx
  801bf5:	0f 94 c1             	sete   %cl
  801bf8:	0f b6 c9             	movzbl %cl,%ecx
  801bfb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801bfe:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c07:	39 ce                	cmp    %ecx,%esi
  801c09:	74 1b                	je     801c26 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c0b:	39 c3                	cmp    %eax,%ebx
  801c0d:	75 c4                	jne    801bd3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c0f:	8b 42 58             	mov    0x58(%edx),%eax
  801c12:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c15:	50                   	push   %eax
  801c16:	56                   	push   %esi
  801c17:	68 8b 2d 80 00       	push   $0x802d8b
  801c1c:	e8 93 e5 ff ff       	call   8001b4 <cprintf>
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	eb ad                	jmp    801bd3 <_pipeisclosed+0xe>
	}
}
  801c26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    

00801c31 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	57                   	push   %edi
  801c35:	56                   	push   %esi
  801c36:	53                   	push   %ebx
  801c37:	83 ec 28             	sub    $0x28,%esp
  801c3a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c3d:	56                   	push   %esi
  801c3e:	e8 39 f1 ff ff       	call   800d7c <fd2data>
  801c43:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	bf 00 00 00 00       	mov    $0x0,%edi
  801c4d:	eb 4b                	jmp    801c9a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c4f:	89 da                	mov    %ebx,%edx
  801c51:	89 f0                	mov    %esi,%eax
  801c53:	e8 6d ff ff ff       	call   801bc5 <_pipeisclosed>
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	75 48                	jne    801ca4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c5c:	e8 dc ee ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c61:	8b 43 04             	mov    0x4(%ebx),%eax
  801c64:	8b 0b                	mov    (%ebx),%ecx
  801c66:	8d 51 20             	lea    0x20(%ecx),%edx
  801c69:	39 d0                	cmp    %edx,%eax
  801c6b:	73 e2                	jae    801c4f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c77:	89 c2                	mov    %eax,%edx
  801c79:	c1 fa 1f             	sar    $0x1f,%edx
  801c7c:	89 d1                	mov    %edx,%ecx
  801c7e:	c1 e9 1b             	shr    $0x1b,%ecx
  801c81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c84:	83 e2 1f             	and    $0x1f,%edx
  801c87:	29 ca                	sub    %ecx,%edx
  801c89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c91:	83 c0 01             	add    $0x1,%eax
  801c94:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c97:	83 c7 01             	add    $0x1,%edi
  801c9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c9d:	75 c2                	jne    801c61 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca2:	eb 05                	jmp    801ca9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	57                   	push   %edi
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 18             	sub    $0x18,%esp
  801cba:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cbd:	57                   	push   %edi
  801cbe:	e8 b9 f0 ff ff       	call   800d7c <fd2data>
  801cc3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ccd:	eb 3d                	jmp    801d0c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ccf:	85 db                	test   %ebx,%ebx
  801cd1:	74 04                	je     801cd7 <devpipe_read+0x26>
				return i;
  801cd3:	89 d8                	mov    %ebx,%eax
  801cd5:	eb 44                	jmp    801d1b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cd7:	89 f2                	mov    %esi,%edx
  801cd9:	89 f8                	mov    %edi,%eax
  801cdb:	e8 e5 fe ff ff       	call   801bc5 <_pipeisclosed>
  801ce0:	85 c0                	test   %eax,%eax
  801ce2:	75 32                	jne    801d16 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ce4:	e8 54 ee ff ff       	call   800b3d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ce9:	8b 06                	mov    (%esi),%eax
  801ceb:	3b 46 04             	cmp    0x4(%esi),%eax
  801cee:	74 df                	je     801ccf <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf0:	99                   	cltd   
  801cf1:	c1 ea 1b             	shr    $0x1b,%edx
  801cf4:	01 d0                	add    %edx,%eax
  801cf6:	83 e0 1f             	and    $0x1f,%eax
  801cf9:	29 d0                	sub    %edx,%eax
  801cfb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d03:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d06:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d09:	83 c3 01             	add    $0x1,%ebx
  801d0c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d0f:	75 d8                	jne    801ce9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d11:	8b 45 10             	mov    0x10(%ebp),%eax
  801d14:	eb 05                	jmp    801d1b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	e8 5f f0 ff ff       	call   800d93 <fd_alloc>
  801d34:	83 c4 10             	add    $0x10,%esp
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	0f 88 2c 01 00 00    	js     801e6d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d41:	83 ec 04             	sub    $0x4,%esp
  801d44:	68 07 04 00 00       	push   $0x407
  801d49:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4c:	6a 00                	push   $0x0
  801d4e:	e8 09 ee ff ff       	call   800b5c <sys_page_alloc>
  801d53:	83 c4 10             	add    $0x10,%esp
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	0f 88 0d 01 00 00    	js     801e6d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d60:	83 ec 0c             	sub    $0xc,%esp
  801d63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d66:	50                   	push   %eax
  801d67:	e8 27 f0 ff ff       	call   800d93 <fd_alloc>
  801d6c:	89 c3                	mov    %eax,%ebx
  801d6e:	83 c4 10             	add    $0x10,%esp
  801d71:	85 c0                	test   %eax,%eax
  801d73:	0f 88 e2 00 00 00    	js     801e5b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d79:	83 ec 04             	sub    $0x4,%esp
  801d7c:	68 07 04 00 00       	push   $0x407
  801d81:	ff 75 f0             	pushl  -0x10(%ebp)
  801d84:	6a 00                	push   $0x0
  801d86:	e8 d1 ed ff ff       	call   800b5c <sys_page_alloc>
  801d8b:	89 c3                	mov    %eax,%ebx
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	0f 88 c3 00 00 00    	js     801e5b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d9e:	e8 d9 ef ff ff       	call   800d7c <fd2data>
  801da3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da5:	83 c4 0c             	add    $0xc,%esp
  801da8:	68 07 04 00 00       	push   $0x407
  801dad:	50                   	push   %eax
  801dae:	6a 00                	push   $0x0
  801db0:	e8 a7 ed ff ff       	call   800b5c <sys_page_alloc>
  801db5:	89 c3                	mov    %eax,%ebx
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	0f 88 89 00 00 00    	js     801e4b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc2:	83 ec 0c             	sub    $0xc,%esp
  801dc5:	ff 75 f0             	pushl  -0x10(%ebp)
  801dc8:	e8 af ef ff ff       	call   800d7c <fd2data>
  801dcd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dd4:	50                   	push   %eax
  801dd5:	6a 00                	push   $0x0
  801dd7:	56                   	push   %esi
  801dd8:	6a 00                	push   $0x0
  801dda:	e8 c0 ed ff ff       	call   800b9f <sys_page_map>
  801ddf:	89 c3                	mov    %eax,%ebx
  801de1:	83 c4 20             	add    $0x20,%esp
  801de4:	85 c0                	test   %eax,%eax
  801de6:	78 55                	js     801e3d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801de8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801dfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e06:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e12:	83 ec 0c             	sub    $0xc,%esp
  801e15:	ff 75 f4             	pushl  -0xc(%ebp)
  801e18:	e8 4f ef ff ff       	call   800d6c <fd2num>
  801e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e22:	83 c4 04             	add    $0x4,%esp
  801e25:	ff 75 f0             	pushl  -0x10(%ebp)
  801e28:	e8 3f ef ff ff       	call   800d6c <fd2num>
  801e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e33:	83 c4 10             	add    $0x10,%esp
  801e36:	ba 00 00 00 00       	mov    $0x0,%edx
  801e3b:	eb 30                	jmp    801e6d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	56                   	push   %esi
  801e41:	6a 00                	push   $0x0
  801e43:	e8 99 ed ff ff       	call   800be1 <sys_page_unmap>
  801e48:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e4b:	83 ec 08             	sub    $0x8,%esp
  801e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  801e51:	6a 00                	push   $0x0
  801e53:	e8 89 ed ff ff       	call   800be1 <sys_page_unmap>
  801e58:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e5b:	83 ec 08             	sub    $0x8,%esp
  801e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e61:	6a 00                	push   $0x0
  801e63:	e8 79 ed ff ff       	call   800be1 <sys_page_unmap>
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e6d:	89 d0                	mov    %edx,%eax
  801e6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e72:	5b                   	pop    %ebx
  801e73:	5e                   	pop    %esi
  801e74:	5d                   	pop    %ebp
  801e75:	c3                   	ret    

00801e76 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	ff 75 08             	pushl  0x8(%ebp)
  801e83:	e8 5a ef ff ff       	call   800de2 <fd_lookup>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 18                	js     801ea7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e8f:	83 ec 0c             	sub    $0xc,%esp
  801e92:	ff 75 f4             	pushl  -0xc(%ebp)
  801e95:	e8 e2 ee ff ff       	call   800d7c <fd2data>
	return _pipeisclosed(fd, p);
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9f:	e8 21 fd ff ff       	call   801bc5 <_pipeisclosed>
  801ea4:	83 c4 10             	add    $0x10,%esp
}
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801eaf:	68 a3 2d 80 00       	push   $0x802da3
  801eb4:	ff 75 0c             	pushl  0xc(%ebp)
  801eb7:	e8 9d e8 ff ff       	call   800759 <strcpy>
	return 0;
}
  801ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	53                   	push   %ebx
  801ec7:	83 ec 10             	sub    $0x10,%esp
  801eca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ecd:	53                   	push   %ebx
  801ece:	e8 be 06 00 00       	call   802591 <pageref>
  801ed3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ed6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801edb:	83 f8 01             	cmp    $0x1,%eax
  801ede:	75 10                	jne    801ef0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801ee0:	83 ec 0c             	sub    $0xc,%esp
  801ee3:	ff 73 0c             	pushl  0xc(%ebx)
  801ee6:	e8 c0 02 00 00       	call   8021ab <nsipc_close>
  801eeb:	89 c2                	mov    %eax,%edx
  801eed:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ef0:	89 d0                	mov    %edx,%eax
  801ef2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef5:	c9                   	leave  
  801ef6:	c3                   	ret    

00801ef7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801efd:	6a 00                	push   $0x0
  801eff:	ff 75 10             	pushl  0x10(%ebp)
  801f02:	ff 75 0c             	pushl  0xc(%ebp)
  801f05:	8b 45 08             	mov    0x8(%ebp),%eax
  801f08:	ff 70 0c             	pushl  0xc(%eax)
  801f0b:	e8 78 03 00 00       	call   802288 <nsipc_send>
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f18:	6a 00                	push   $0x0
  801f1a:	ff 75 10             	pushl  0x10(%ebp)
  801f1d:	ff 75 0c             	pushl  0xc(%ebp)
  801f20:	8b 45 08             	mov    0x8(%ebp),%eax
  801f23:	ff 70 0c             	pushl  0xc(%eax)
  801f26:	e8 f1 02 00 00       	call   80221c <nsipc_recv>
}
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f33:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f36:	52                   	push   %edx
  801f37:	50                   	push   %eax
  801f38:	e8 a5 ee ff ff       	call   800de2 <fd_lookup>
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 17                	js     801f5b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f47:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801f4d:	39 08                	cmp    %ecx,(%eax)
  801f4f:	75 05                	jne    801f56 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f51:	8b 40 0c             	mov    0xc(%eax),%eax
  801f54:	eb 05                	jmp    801f5b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801f56:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	56                   	push   %esi
  801f61:	53                   	push   %ebx
  801f62:	83 ec 1c             	sub    $0x1c,%esp
  801f65:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6a:	50                   	push   %eax
  801f6b:	e8 23 ee ff ff       	call   800d93 <fd_alloc>
  801f70:	89 c3                	mov    %eax,%ebx
  801f72:	83 c4 10             	add    $0x10,%esp
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 1b                	js     801f94 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f79:	83 ec 04             	sub    $0x4,%esp
  801f7c:	68 07 04 00 00       	push   $0x407
  801f81:	ff 75 f4             	pushl  -0xc(%ebp)
  801f84:	6a 00                	push   $0x0
  801f86:	e8 d1 eb ff ff       	call   800b5c <sys_page_alloc>
  801f8b:	89 c3                	mov    %eax,%ebx
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	85 c0                	test   %eax,%eax
  801f92:	79 10                	jns    801fa4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801f94:	83 ec 0c             	sub    $0xc,%esp
  801f97:	56                   	push   %esi
  801f98:	e8 0e 02 00 00       	call   8021ab <nsipc_close>
		return r;
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	89 d8                	mov    %ebx,%eax
  801fa2:	eb 24                	jmp    801fc8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fa4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fad:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fb9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	50                   	push   %eax
  801fc0:	e8 a7 ed ff ff       	call   800d6c <fd2num>
  801fc5:	83 c4 10             	add    $0x10,%esp
}
  801fc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fcb:	5b                   	pop    %ebx
  801fcc:	5e                   	pop    %esi
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    

00801fcf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd8:	e8 50 ff ff ff       	call   801f2d <fd2sockid>
		return r;
  801fdd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 1f                	js     802002 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801fe3:	83 ec 04             	sub    $0x4,%esp
  801fe6:	ff 75 10             	pushl  0x10(%ebp)
  801fe9:	ff 75 0c             	pushl  0xc(%ebp)
  801fec:	50                   	push   %eax
  801fed:	e8 12 01 00 00       	call   802104 <nsipc_accept>
  801ff2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ff5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	78 07                	js     802002 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ffb:	e8 5d ff ff ff       	call   801f5d <alloc_sockfd>
  802000:	89 c1                	mov    %eax,%ecx
}
  802002:	89 c8                	mov    %ecx,%eax
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80200c:	8b 45 08             	mov    0x8(%ebp),%eax
  80200f:	e8 19 ff ff ff       	call   801f2d <fd2sockid>
  802014:	85 c0                	test   %eax,%eax
  802016:	78 12                	js     80202a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  802018:	83 ec 04             	sub    $0x4,%esp
  80201b:	ff 75 10             	pushl  0x10(%ebp)
  80201e:	ff 75 0c             	pushl  0xc(%ebp)
  802021:	50                   	push   %eax
  802022:	e8 2d 01 00 00       	call   802154 <nsipc_bind>
  802027:	83 c4 10             	add    $0x10,%esp
}
  80202a:	c9                   	leave  
  80202b:	c3                   	ret    

0080202c <shutdown>:

int
shutdown(int s, int how)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802032:	8b 45 08             	mov    0x8(%ebp),%eax
  802035:	e8 f3 fe ff ff       	call   801f2d <fd2sockid>
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 0f                	js     80204d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80203e:	83 ec 08             	sub    $0x8,%esp
  802041:	ff 75 0c             	pushl  0xc(%ebp)
  802044:	50                   	push   %eax
  802045:	e8 3f 01 00 00       	call   802189 <nsipc_shutdown>
  80204a:	83 c4 10             	add    $0x10,%esp
}
  80204d:	c9                   	leave  
  80204e:	c3                   	ret    

0080204f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802055:	8b 45 08             	mov    0x8(%ebp),%eax
  802058:	e8 d0 fe ff ff       	call   801f2d <fd2sockid>
  80205d:	85 c0                	test   %eax,%eax
  80205f:	78 12                	js     802073 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802061:	83 ec 04             	sub    $0x4,%esp
  802064:	ff 75 10             	pushl  0x10(%ebp)
  802067:	ff 75 0c             	pushl  0xc(%ebp)
  80206a:	50                   	push   %eax
  80206b:	e8 55 01 00 00       	call   8021c5 <nsipc_connect>
  802070:	83 c4 10             	add    $0x10,%esp
}
  802073:	c9                   	leave  
  802074:	c3                   	ret    

00802075 <listen>:

int
listen(int s, int backlog)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80207b:	8b 45 08             	mov    0x8(%ebp),%eax
  80207e:	e8 aa fe ff ff       	call   801f2d <fd2sockid>
  802083:	85 c0                	test   %eax,%eax
  802085:	78 0f                	js     802096 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802087:	83 ec 08             	sub    $0x8,%esp
  80208a:	ff 75 0c             	pushl  0xc(%ebp)
  80208d:	50                   	push   %eax
  80208e:	e8 67 01 00 00       	call   8021fa <nsipc_listen>
  802093:	83 c4 10             	add    $0x10,%esp
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80209e:	ff 75 10             	pushl  0x10(%ebp)
  8020a1:	ff 75 0c             	pushl  0xc(%ebp)
  8020a4:	ff 75 08             	pushl  0x8(%ebp)
  8020a7:	e8 3a 02 00 00       	call   8022e6 <nsipc_socket>
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	78 05                	js     8020b8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8020b3:	e8 a5 fe ff ff       	call   801f5d <alloc_sockfd>
}
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    

008020ba <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	53                   	push   %ebx
  8020be:	83 ec 04             	sub    $0x4,%esp
  8020c1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020c3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8020ca:	75 12                	jne    8020de <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020cc:	83 ec 0c             	sub    $0xc,%esp
  8020cf:	6a 02                	push   $0x2
  8020d1:	e8 82 04 00 00       	call   802558 <ipc_find_env>
  8020d6:	a3 04 40 80 00       	mov    %eax,0x804004
  8020db:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020de:	6a 07                	push   $0x7
  8020e0:	68 00 60 80 00       	push   $0x806000
  8020e5:	53                   	push   %ebx
  8020e6:	ff 35 04 40 80 00    	pushl  0x804004
  8020ec:	e8 18 04 00 00       	call   802509 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020f1:	83 c4 0c             	add    $0xc,%esp
  8020f4:	6a 00                	push   $0x0
  8020f6:	6a 00                	push   $0x0
  8020f8:	6a 00                	push   $0x0
  8020fa:	e8 94 03 00 00       	call   802493 <ipc_recv>
}
  8020ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802102:	c9                   	leave  
  802103:	c3                   	ret    

00802104 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802104:	55                   	push   %ebp
  802105:	89 e5                	mov    %esp,%ebp
  802107:	56                   	push   %esi
  802108:	53                   	push   %ebx
  802109:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80210c:	8b 45 08             	mov    0x8(%ebp),%eax
  80210f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802114:	8b 06                	mov    (%esi),%eax
  802116:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80211b:	b8 01 00 00 00       	mov    $0x1,%eax
  802120:	e8 95 ff ff ff       	call   8020ba <nsipc>
  802125:	89 c3                	mov    %eax,%ebx
  802127:	85 c0                	test   %eax,%eax
  802129:	78 20                	js     80214b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80212b:	83 ec 04             	sub    $0x4,%esp
  80212e:	ff 35 10 60 80 00    	pushl  0x806010
  802134:	68 00 60 80 00       	push   $0x806000
  802139:	ff 75 0c             	pushl  0xc(%ebp)
  80213c:	e8 aa e7 ff ff       	call   8008eb <memmove>
		*addrlen = ret->ret_addrlen;
  802141:	a1 10 60 80 00       	mov    0x806010,%eax
  802146:	89 06                	mov    %eax,(%esi)
  802148:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80214b:	89 d8                	mov    %ebx,%eax
  80214d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	53                   	push   %ebx
  802158:	83 ec 08             	sub    $0x8,%esp
  80215b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80215e:	8b 45 08             	mov    0x8(%ebp),%eax
  802161:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802166:	53                   	push   %ebx
  802167:	ff 75 0c             	pushl  0xc(%ebp)
  80216a:	68 04 60 80 00       	push   $0x806004
  80216f:	e8 77 e7 ff ff       	call   8008eb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802174:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80217a:	b8 02 00 00 00       	mov    $0x2,%eax
  80217f:	e8 36 ff ff ff       	call   8020ba <nsipc>
}
  802184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802187:	c9                   	leave  
  802188:	c3                   	ret    

00802189 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802189:	55                   	push   %ebp
  80218a:	89 e5                	mov    %esp,%ebp
  80218c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80218f:	8b 45 08             	mov    0x8(%ebp),%eax
  802192:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  802197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80219f:	b8 03 00 00 00       	mov    $0x3,%eax
  8021a4:	e8 11 ff ff ff       	call   8020ba <nsipc>
}
  8021a9:	c9                   	leave  
  8021aa:	c3                   	ret    

008021ab <nsipc_close>:

int
nsipc_close(int s)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8021b9:	b8 04 00 00 00       	mov    $0x4,%eax
  8021be:	e8 f7 fe ff ff       	call   8020ba <nsipc>
}
  8021c3:	c9                   	leave  
  8021c4:	c3                   	ret    

008021c5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021c5:	55                   	push   %ebp
  8021c6:	89 e5                	mov    %esp,%ebp
  8021c8:	53                   	push   %ebx
  8021c9:	83 ec 08             	sub    $0x8,%esp
  8021cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8021d7:	53                   	push   %ebx
  8021d8:	ff 75 0c             	pushl  0xc(%ebp)
  8021db:	68 04 60 80 00       	push   $0x806004
  8021e0:	e8 06 e7 ff ff       	call   8008eb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8021e5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8021eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8021f0:	e8 c5 fe ff ff       	call   8020ba <nsipc>
}
  8021f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021f8:	c9                   	leave  
  8021f9:	c3                   	ret    

008021fa <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802200:	8b 45 08             	mov    0x8(%ebp),%eax
  802203:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80220b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802210:	b8 06 00 00 00       	mov    $0x6,%eax
  802215:	e8 a0 fe ff ff       	call   8020ba <nsipc>
}
  80221a:	c9                   	leave  
  80221b:	c3                   	ret    

0080221c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80221c:	55                   	push   %ebp
  80221d:	89 e5                	mov    %esp,%ebp
  80221f:	56                   	push   %esi
  802220:	53                   	push   %ebx
  802221:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802224:	8b 45 08             	mov    0x8(%ebp),%eax
  802227:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80222c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802232:	8b 45 14             	mov    0x14(%ebp),%eax
  802235:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80223a:	b8 07 00 00 00       	mov    $0x7,%eax
  80223f:	e8 76 fe ff ff       	call   8020ba <nsipc>
  802244:	89 c3                	mov    %eax,%ebx
  802246:	85 c0                	test   %eax,%eax
  802248:	78 35                	js     80227f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80224a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80224f:	7f 04                	jg     802255 <nsipc_recv+0x39>
  802251:	39 c6                	cmp    %eax,%esi
  802253:	7d 16                	jge    80226b <nsipc_recv+0x4f>
  802255:	68 af 2d 80 00       	push   $0x802daf
  80225a:	68 a3 2c 80 00       	push   $0x802ca3
  80225f:	6a 62                	push   $0x62
  802261:	68 c4 2d 80 00       	push   $0x802dc4
  802266:	e8 70 de ff ff       	call   8000db <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80226b:	83 ec 04             	sub    $0x4,%esp
  80226e:	50                   	push   %eax
  80226f:	68 00 60 80 00       	push   $0x806000
  802274:	ff 75 0c             	pushl  0xc(%ebp)
  802277:	e8 6f e6 ff ff       	call   8008eb <memmove>
  80227c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80227f:	89 d8                	mov    %ebx,%eax
  802281:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    

00802288 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	53                   	push   %ebx
  80228c:	83 ec 04             	sub    $0x4,%esp
  80228f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802292:	8b 45 08             	mov    0x8(%ebp),%eax
  802295:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80229a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022a0:	7e 16                	jle    8022b8 <nsipc_send+0x30>
  8022a2:	68 d0 2d 80 00       	push   $0x802dd0
  8022a7:	68 a3 2c 80 00       	push   $0x802ca3
  8022ac:	6a 6d                	push   $0x6d
  8022ae:	68 c4 2d 80 00       	push   $0x802dc4
  8022b3:	e8 23 de ff ff       	call   8000db <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022b8:	83 ec 04             	sub    $0x4,%esp
  8022bb:	53                   	push   %ebx
  8022bc:	ff 75 0c             	pushl  0xc(%ebp)
  8022bf:	68 0c 60 80 00       	push   $0x80600c
  8022c4:	e8 22 e6 ff ff       	call   8008eb <memmove>
	nsipcbuf.send.req_size = size;
  8022c9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8022cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8022d2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8022d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8022dc:	e8 d9 fd ff ff       	call   8020ba <nsipc>
}
  8022e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022e4:	c9                   	leave  
  8022e5:	c3                   	ret    

008022e6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8022f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8022fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ff:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802304:	b8 09 00 00 00       	mov    $0x9,%eax
  802309:	e8 ac fd ff ff       	call   8020ba <nsipc>
}
  80230e:	c9                   	leave  
  80230f:	c3                   	ret    

00802310 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802313:	b8 00 00 00 00       	mov    $0x0,%eax
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    

0080231a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
  80231d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802320:	68 dc 2d 80 00       	push   $0x802ddc
  802325:	ff 75 0c             	pushl  0xc(%ebp)
  802328:	e8 2c e4 ff ff       	call   800759 <strcpy>
	return 0;
}
  80232d:	b8 00 00 00 00       	mov    $0x0,%eax
  802332:	c9                   	leave  
  802333:	c3                   	ret    

00802334 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	57                   	push   %edi
  802338:	56                   	push   %esi
  802339:	53                   	push   %ebx
  80233a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802340:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802345:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80234b:	eb 2d                	jmp    80237a <devcons_write+0x46>
		m = n - tot;
  80234d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802350:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802352:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802355:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80235a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80235d:	83 ec 04             	sub    $0x4,%esp
  802360:	53                   	push   %ebx
  802361:	03 45 0c             	add    0xc(%ebp),%eax
  802364:	50                   	push   %eax
  802365:	57                   	push   %edi
  802366:	e8 80 e5 ff ff       	call   8008eb <memmove>
		sys_cputs(buf, m);
  80236b:	83 c4 08             	add    $0x8,%esp
  80236e:	53                   	push   %ebx
  80236f:	57                   	push   %edi
  802370:	e8 2b e7 ff ff       	call   800aa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802375:	01 de                	add    %ebx,%esi
  802377:	83 c4 10             	add    $0x10,%esp
  80237a:	89 f0                	mov    %esi,%eax
  80237c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80237f:	72 cc                	jb     80234d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802381:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    

00802389 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802389:	55                   	push   %ebp
  80238a:	89 e5                	mov    %esp,%ebp
  80238c:	83 ec 08             	sub    $0x8,%esp
  80238f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802394:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802398:	74 2a                	je     8023c4 <devcons_read+0x3b>
  80239a:	eb 05                	jmp    8023a1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80239c:	e8 9c e7 ff ff       	call   800b3d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023a1:	e8 18 e7 ff ff       	call   800abe <sys_cgetc>
  8023a6:	85 c0                	test   %eax,%eax
  8023a8:	74 f2                	je     80239c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	78 16                	js     8023c4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023ae:	83 f8 04             	cmp    $0x4,%eax
  8023b1:	74 0c                	je     8023bf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023b6:	88 02                	mov    %al,(%edx)
	return 1;
  8023b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8023bd:	eb 05                	jmp    8023c4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023bf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023c4:	c9                   	leave  
  8023c5:	c3                   	ret    

008023c6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023c6:	55                   	push   %ebp
  8023c7:	89 e5                	mov    %esp,%ebp
  8023c9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023cf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023d2:	6a 01                	push   $0x1
  8023d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023d7:	50                   	push   %eax
  8023d8:	e8 c3 e6 ff ff       	call   800aa0 <sys_cputs>
}
  8023dd:	83 c4 10             	add    $0x10,%esp
  8023e0:	c9                   	leave  
  8023e1:	c3                   	ret    

008023e2 <getchar>:

int
getchar(void)
{
  8023e2:	55                   	push   %ebp
  8023e3:	89 e5                	mov    %esp,%ebp
  8023e5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023e8:	6a 01                	push   $0x1
  8023ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ed:	50                   	push   %eax
  8023ee:	6a 00                	push   $0x0
  8023f0:	e8 53 ec ff ff       	call   801048 <read>
	if (r < 0)
  8023f5:	83 c4 10             	add    $0x10,%esp
  8023f8:	85 c0                	test   %eax,%eax
  8023fa:	78 0f                	js     80240b <getchar+0x29>
		return r;
	if (r < 1)
  8023fc:	85 c0                	test   %eax,%eax
  8023fe:	7e 06                	jle    802406 <getchar+0x24>
		return -E_EOF;
	return c;
  802400:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802404:	eb 05                	jmp    80240b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802406:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80240b:	c9                   	leave  
  80240c:	c3                   	ret    

0080240d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802416:	50                   	push   %eax
  802417:	ff 75 08             	pushl  0x8(%ebp)
  80241a:	e8 c3 e9 ff ff       	call   800de2 <fd_lookup>
  80241f:	83 c4 10             	add    $0x10,%esp
  802422:	85 c0                	test   %eax,%eax
  802424:	78 11                	js     802437 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802426:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802429:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80242f:	39 10                	cmp    %edx,(%eax)
  802431:	0f 94 c0             	sete   %al
  802434:	0f b6 c0             	movzbl %al,%eax
}
  802437:	c9                   	leave  
  802438:	c3                   	ret    

00802439 <opencons>:

int
opencons(void)
{
  802439:	55                   	push   %ebp
  80243a:	89 e5                	mov    %esp,%ebp
  80243c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80243f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802442:	50                   	push   %eax
  802443:	e8 4b e9 ff ff       	call   800d93 <fd_alloc>
  802448:	83 c4 10             	add    $0x10,%esp
		return r;
  80244b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80244d:	85 c0                	test   %eax,%eax
  80244f:	78 3e                	js     80248f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802451:	83 ec 04             	sub    $0x4,%esp
  802454:	68 07 04 00 00       	push   $0x407
  802459:	ff 75 f4             	pushl  -0xc(%ebp)
  80245c:	6a 00                	push   $0x0
  80245e:	e8 f9 e6 ff ff       	call   800b5c <sys_page_alloc>
  802463:	83 c4 10             	add    $0x10,%esp
		return r;
  802466:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802468:	85 c0                	test   %eax,%eax
  80246a:	78 23                	js     80248f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80246c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802475:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802481:	83 ec 0c             	sub    $0xc,%esp
  802484:	50                   	push   %eax
  802485:	e8 e2 e8 ff ff       	call   800d6c <fd2num>
  80248a:	89 c2                	mov    %eax,%edx
  80248c:	83 c4 10             	add    $0x10,%esp
}
  80248f:	89 d0                	mov    %edx,%eax
  802491:	c9                   	leave  
  802492:	c3                   	ret    

00802493 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802493:	55                   	push   %ebp
  802494:	89 e5                	mov    %esp,%ebp
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	8b 75 08             	mov    0x8(%ebp),%esi
  80249b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80249e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8024a1:	85 c0                	test   %eax,%eax
  8024a3:	74 0e                	je     8024b3 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8024a5:	83 ec 0c             	sub    $0xc,%esp
  8024a8:	50                   	push   %eax
  8024a9:	e8 5e e8 ff ff       	call   800d0c <sys_ipc_recv>
  8024ae:	83 c4 10             	add    $0x10,%esp
  8024b1:	eb 10                	jmp    8024c3 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8024b3:	83 ec 0c             	sub    $0xc,%esp
  8024b6:	68 00 00 c0 ee       	push   $0xeec00000
  8024bb:	e8 4c e8 ff ff       	call   800d0c <sys_ipc_recv>
  8024c0:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8024c3:	85 c0                	test   %eax,%eax
  8024c5:	79 17                	jns    8024de <ipc_recv+0x4b>
		if(*from_env_store)
  8024c7:	83 3e 00             	cmpl   $0x0,(%esi)
  8024ca:	74 06                	je     8024d2 <ipc_recv+0x3f>
			*from_env_store = 0;
  8024cc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8024d2:	85 db                	test   %ebx,%ebx
  8024d4:	74 2c                	je     802502 <ipc_recv+0x6f>
			*perm_store = 0;
  8024d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8024dc:	eb 24                	jmp    802502 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8024de:	85 f6                	test   %esi,%esi
  8024e0:	74 0a                	je     8024ec <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8024e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8024e7:	8b 40 74             	mov    0x74(%eax),%eax
  8024ea:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8024ec:	85 db                	test   %ebx,%ebx
  8024ee:	74 0a                	je     8024fa <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8024f0:	a1 08 40 80 00       	mov    0x804008,%eax
  8024f5:	8b 40 78             	mov    0x78(%eax),%eax
  8024f8:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8024fa:	a1 08 40 80 00       	mov    0x804008,%eax
  8024ff:	8b 40 70             	mov    0x70(%eax),%eax
}
  802502:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802505:	5b                   	pop    %ebx
  802506:	5e                   	pop    %esi
  802507:	5d                   	pop    %ebp
  802508:	c3                   	ret    

00802509 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	57                   	push   %edi
  80250d:	56                   	push   %esi
  80250e:	53                   	push   %ebx
  80250f:	83 ec 0c             	sub    $0xc,%esp
  802512:	8b 7d 08             	mov    0x8(%ebp),%edi
  802515:	8b 75 0c             	mov    0xc(%ebp),%esi
  802518:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  80251b:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80251d:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802522:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802525:	e8 13 e6 ff ff       	call   800b3d <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  80252a:	ff 75 14             	pushl  0x14(%ebp)
  80252d:	53                   	push   %ebx
  80252e:	56                   	push   %esi
  80252f:	57                   	push   %edi
  802530:	e8 b4 e7 ff ff       	call   800ce9 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802535:	89 c2                	mov    %eax,%edx
  802537:	f7 d2                	not    %edx
  802539:	c1 ea 1f             	shr    $0x1f,%edx
  80253c:	83 c4 10             	add    $0x10,%esp
  80253f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802542:	0f 94 c1             	sete   %cl
  802545:	09 ca                	or     %ecx,%edx
  802547:	85 c0                	test   %eax,%eax
  802549:	0f 94 c0             	sete   %al
  80254c:	38 c2                	cmp    %al,%dl
  80254e:	77 d5                	ja     802525 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802550:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    

00802558 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802558:	55                   	push   %ebp
  802559:	89 e5                	mov    %esp,%ebp
  80255b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80255e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802563:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802566:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80256c:	8b 52 50             	mov    0x50(%edx),%edx
  80256f:	39 ca                	cmp    %ecx,%edx
  802571:	75 0d                	jne    802580 <ipc_find_env+0x28>
			return envs[i].env_id;
  802573:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802576:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80257b:	8b 40 48             	mov    0x48(%eax),%eax
  80257e:	eb 0f                	jmp    80258f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802580:	83 c0 01             	add    $0x1,%eax
  802583:	3d 00 04 00 00       	cmp    $0x400,%eax
  802588:	75 d9                	jne    802563 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80258a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80258f:	5d                   	pop    %ebp
  802590:	c3                   	ret    

00802591 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802591:	55                   	push   %ebp
  802592:	89 e5                	mov    %esp,%ebp
  802594:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802597:	89 d0                	mov    %edx,%eax
  802599:	c1 e8 16             	shr    $0x16,%eax
  80259c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025a3:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025a8:	f6 c1 01             	test   $0x1,%cl
  8025ab:	74 1d                	je     8025ca <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025ad:	c1 ea 0c             	shr    $0xc,%edx
  8025b0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025b7:	f6 c2 01             	test   $0x1,%dl
  8025ba:	74 0e                	je     8025ca <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025bc:	c1 ea 0c             	shr    $0xc,%edx
  8025bf:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8025c6:	ef 
  8025c7:	0f b7 c0             	movzwl %ax,%eax
}
  8025ca:	5d                   	pop    %ebp
  8025cb:	c3                   	ret    
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__udivdi3>:
  8025d0:	55                   	push   %ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	53                   	push   %ebx
  8025d4:	83 ec 1c             	sub    $0x1c,%esp
  8025d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8025db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8025df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025e7:	85 f6                	test   %esi,%esi
  8025e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ed:	89 ca                	mov    %ecx,%edx
  8025ef:	89 f8                	mov    %edi,%eax
  8025f1:	75 3d                	jne    802630 <__udivdi3+0x60>
  8025f3:	39 cf                	cmp    %ecx,%edi
  8025f5:	0f 87 c5 00 00 00    	ja     8026c0 <__udivdi3+0xf0>
  8025fb:	85 ff                	test   %edi,%edi
  8025fd:	89 fd                	mov    %edi,%ebp
  8025ff:	75 0b                	jne    80260c <__udivdi3+0x3c>
  802601:	b8 01 00 00 00       	mov    $0x1,%eax
  802606:	31 d2                	xor    %edx,%edx
  802608:	f7 f7                	div    %edi
  80260a:	89 c5                	mov    %eax,%ebp
  80260c:	89 c8                	mov    %ecx,%eax
  80260e:	31 d2                	xor    %edx,%edx
  802610:	f7 f5                	div    %ebp
  802612:	89 c1                	mov    %eax,%ecx
  802614:	89 d8                	mov    %ebx,%eax
  802616:	89 cf                	mov    %ecx,%edi
  802618:	f7 f5                	div    %ebp
  80261a:	89 c3                	mov    %eax,%ebx
  80261c:	89 d8                	mov    %ebx,%eax
  80261e:	89 fa                	mov    %edi,%edx
  802620:	83 c4 1c             	add    $0x1c,%esp
  802623:	5b                   	pop    %ebx
  802624:	5e                   	pop    %esi
  802625:	5f                   	pop    %edi
  802626:	5d                   	pop    %ebp
  802627:	c3                   	ret    
  802628:	90                   	nop
  802629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802630:	39 ce                	cmp    %ecx,%esi
  802632:	77 74                	ja     8026a8 <__udivdi3+0xd8>
  802634:	0f bd fe             	bsr    %esi,%edi
  802637:	83 f7 1f             	xor    $0x1f,%edi
  80263a:	0f 84 98 00 00 00    	je     8026d8 <__udivdi3+0x108>
  802640:	bb 20 00 00 00       	mov    $0x20,%ebx
  802645:	89 f9                	mov    %edi,%ecx
  802647:	89 c5                	mov    %eax,%ebp
  802649:	29 fb                	sub    %edi,%ebx
  80264b:	d3 e6                	shl    %cl,%esi
  80264d:	89 d9                	mov    %ebx,%ecx
  80264f:	d3 ed                	shr    %cl,%ebp
  802651:	89 f9                	mov    %edi,%ecx
  802653:	d3 e0                	shl    %cl,%eax
  802655:	09 ee                	or     %ebp,%esi
  802657:	89 d9                	mov    %ebx,%ecx
  802659:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80265d:	89 d5                	mov    %edx,%ebp
  80265f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802663:	d3 ed                	shr    %cl,%ebp
  802665:	89 f9                	mov    %edi,%ecx
  802667:	d3 e2                	shl    %cl,%edx
  802669:	89 d9                	mov    %ebx,%ecx
  80266b:	d3 e8                	shr    %cl,%eax
  80266d:	09 c2                	or     %eax,%edx
  80266f:	89 d0                	mov    %edx,%eax
  802671:	89 ea                	mov    %ebp,%edx
  802673:	f7 f6                	div    %esi
  802675:	89 d5                	mov    %edx,%ebp
  802677:	89 c3                	mov    %eax,%ebx
  802679:	f7 64 24 0c          	mull   0xc(%esp)
  80267d:	39 d5                	cmp    %edx,%ebp
  80267f:	72 10                	jb     802691 <__udivdi3+0xc1>
  802681:	8b 74 24 08          	mov    0x8(%esp),%esi
  802685:	89 f9                	mov    %edi,%ecx
  802687:	d3 e6                	shl    %cl,%esi
  802689:	39 c6                	cmp    %eax,%esi
  80268b:	73 07                	jae    802694 <__udivdi3+0xc4>
  80268d:	39 d5                	cmp    %edx,%ebp
  80268f:	75 03                	jne    802694 <__udivdi3+0xc4>
  802691:	83 eb 01             	sub    $0x1,%ebx
  802694:	31 ff                	xor    %edi,%edi
  802696:	89 d8                	mov    %ebx,%eax
  802698:	89 fa                	mov    %edi,%edx
  80269a:	83 c4 1c             	add    $0x1c,%esp
  80269d:	5b                   	pop    %ebx
  80269e:	5e                   	pop    %esi
  80269f:	5f                   	pop    %edi
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    
  8026a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026a8:	31 ff                	xor    %edi,%edi
  8026aa:	31 db                	xor    %ebx,%ebx
  8026ac:	89 d8                	mov    %ebx,%eax
  8026ae:	89 fa                	mov    %edi,%edx
  8026b0:	83 c4 1c             	add    $0x1c,%esp
  8026b3:	5b                   	pop    %ebx
  8026b4:	5e                   	pop    %esi
  8026b5:	5f                   	pop    %edi
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    
  8026b8:	90                   	nop
  8026b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	89 d8                	mov    %ebx,%eax
  8026c2:	f7 f7                	div    %edi
  8026c4:	31 ff                	xor    %edi,%edi
  8026c6:	89 c3                	mov    %eax,%ebx
  8026c8:	89 d8                	mov    %ebx,%eax
  8026ca:	89 fa                	mov    %edi,%edx
  8026cc:	83 c4 1c             	add    $0x1c,%esp
  8026cf:	5b                   	pop    %ebx
  8026d0:	5e                   	pop    %esi
  8026d1:	5f                   	pop    %edi
  8026d2:	5d                   	pop    %ebp
  8026d3:	c3                   	ret    
  8026d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d8:	39 ce                	cmp    %ecx,%esi
  8026da:	72 0c                	jb     8026e8 <__udivdi3+0x118>
  8026dc:	31 db                	xor    %ebx,%ebx
  8026de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026e2:	0f 87 34 ff ff ff    	ja     80261c <__udivdi3+0x4c>
  8026e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026ed:	e9 2a ff ff ff       	jmp    80261c <__udivdi3+0x4c>
  8026f2:	66 90                	xchg   %ax,%ax
  8026f4:	66 90                	xchg   %ax,%ax
  8026f6:	66 90                	xchg   %ax,%ax
  8026f8:	66 90                	xchg   %ax,%ax
  8026fa:	66 90                	xchg   %ax,%ax
  8026fc:	66 90                	xchg   %ax,%ax
  8026fe:	66 90                	xchg   %ax,%ax

00802700 <__umoddi3>:
  802700:	55                   	push   %ebp
  802701:	57                   	push   %edi
  802702:	56                   	push   %esi
  802703:	53                   	push   %ebx
  802704:	83 ec 1c             	sub    $0x1c,%esp
  802707:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80270b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80270f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802713:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802717:	85 d2                	test   %edx,%edx
  802719:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80271d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802721:	89 f3                	mov    %esi,%ebx
  802723:	89 3c 24             	mov    %edi,(%esp)
  802726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80272a:	75 1c                	jne    802748 <__umoddi3+0x48>
  80272c:	39 f7                	cmp    %esi,%edi
  80272e:	76 50                	jbe    802780 <__umoddi3+0x80>
  802730:	89 c8                	mov    %ecx,%eax
  802732:	89 f2                	mov    %esi,%edx
  802734:	f7 f7                	div    %edi
  802736:	89 d0                	mov    %edx,%eax
  802738:	31 d2                	xor    %edx,%edx
  80273a:	83 c4 1c             	add    $0x1c,%esp
  80273d:	5b                   	pop    %ebx
  80273e:	5e                   	pop    %esi
  80273f:	5f                   	pop    %edi
  802740:	5d                   	pop    %ebp
  802741:	c3                   	ret    
  802742:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802748:	39 f2                	cmp    %esi,%edx
  80274a:	89 d0                	mov    %edx,%eax
  80274c:	77 52                	ja     8027a0 <__umoddi3+0xa0>
  80274e:	0f bd ea             	bsr    %edx,%ebp
  802751:	83 f5 1f             	xor    $0x1f,%ebp
  802754:	75 5a                	jne    8027b0 <__umoddi3+0xb0>
  802756:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80275a:	0f 82 e0 00 00 00    	jb     802840 <__umoddi3+0x140>
  802760:	39 0c 24             	cmp    %ecx,(%esp)
  802763:	0f 86 d7 00 00 00    	jbe    802840 <__umoddi3+0x140>
  802769:	8b 44 24 08          	mov    0x8(%esp),%eax
  80276d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802771:	83 c4 1c             	add    $0x1c,%esp
  802774:	5b                   	pop    %ebx
  802775:	5e                   	pop    %esi
  802776:	5f                   	pop    %edi
  802777:	5d                   	pop    %ebp
  802778:	c3                   	ret    
  802779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802780:	85 ff                	test   %edi,%edi
  802782:	89 fd                	mov    %edi,%ebp
  802784:	75 0b                	jne    802791 <__umoddi3+0x91>
  802786:	b8 01 00 00 00       	mov    $0x1,%eax
  80278b:	31 d2                	xor    %edx,%edx
  80278d:	f7 f7                	div    %edi
  80278f:	89 c5                	mov    %eax,%ebp
  802791:	89 f0                	mov    %esi,%eax
  802793:	31 d2                	xor    %edx,%edx
  802795:	f7 f5                	div    %ebp
  802797:	89 c8                	mov    %ecx,%eax
  802799:	f7 f5                	div    %ebp
  80279b:	89 d0                	mov    %edx,%eax
  80279d:	eb 99                	jmp    802738 <__umoddi3+0x38>
  80279f:	90                   	nop
  8027a0:	89 c8                	mov    %ecx,%eax
  8027a2:	89 f2                	mov    %esi,%edx
  8027a4:	83 c4 1c             	add    $0x1c,%esp
  8027a7:	5b                   	pop    %ebx
  8027a8:	5e                   	pop    %esi
  8027a9:	5f                   	pop    %edi
  8027aa:	5d                   	pop    %ebp
  8027ab:	c3                   	ret    
  8027ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	8b 34 24             	mov    (%esp),%esi
  8027b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027b8:	89 e9                	mov    %ebp,%ecx
  8027ba:	29 ef                	sub    %ebp,%edi
  8027bc:	d3 e0                	shl    %cl,%eax
  8027be:	89 f9                	mov    %edi,%ecx
  8027c0:	89 f2                	mov    %esi,%edx
  8027c2:	d3 ea                	shr    %cl,%edx
  8027c4:	89 e9                	mov    %ebp,%ecx
  8027c6:	09 c2                	or     %eax,%edx
  8027c8:	89 d8                	mov    %ebx,%eax
  8027ca:	89 14 24             	mov    %edx,(%esp)
  8027cd:	89 f2                	mov    %esi,%edx
  8027cf:	d3 e2                	shl    %cl,%edx
  8027d1:	89 f9                	mov    %edi,%ecx
  8027d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8027db:	d3 e8                	shr    %cl,%eax
  8027dd:	89 e9                	mov    %ebp,%ecx
  8027df:	89 c6                	mov    %eax,%esi
  8027e1:	d3 e3                	shl    %cl,%ebx
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	89 d0                	mov    %edx,%eax
  8027e7:	d3 e8                	shr    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	09 d8                	or     %ebx,%eax
  8027ed:	89 d3                	mov    %edx,%ebx
  8027ef:	89 f2                	mov    %esi,%edx
  8027f1:	f7 34 24             	divl   (%esp)
  8027f4:	89 d6                	mov    %edx,%esi
  8027f6:	d3 e3                	shl    %cl,%ebx
  8027f8:	f7 64 24 04          	mull   0x4(%esp)
  8027fc:	39 d6                	cmp    %edx,%esi
  8027fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802802:	89 d1                	mov    %edx,%ecx
  802804:	89 c3                	mov    %eax,%ebx
  802806:	72 08                	jb     802810 <__umoddi3+0x110>
  802808:	75 11                	jne    80281b <__umoddi3+0x11b>
  80280a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80280e:	73 0b                	jae    80281b <__umoddi3+0x11b>
  802810:	2b 44 24 04          	sub    0x4(%esp),%eax
  802814:	1b 14 24             	sbb    (%esp),%edx
  802817:	89 d1                	mov    %edx,%ecx
  802819:	89 c3                	mov    %eax,%ebx
  80281b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80281f:	29 da                	sub    %ebx,%edx
  802821:	19 ce                	sbb    %ecx,%esi
  802823:	89 f9                	mov    %edi,%ecx
  802825:	89 f0                	mov    %esi,%eax
  802827:	d3 e0                	shl    %cl,%eax
  802829:	89 e9                	mov    %ebp,%ecx
  80282b:	d3 ea                	shr    %cl,%edx
  80282d:	89 e9                	mov    %ebp,%ecx
  80282f:	d3 ee                	shr    %cl,%esi
  802831:	09 d0                	or     %edx,%eax
  802833:	89 f2                	mov    %esi,%edx
  802835:	83 c4 1c             	add    $0x1c,%esp
  802838:	5b                   	pop    %ebx
  802839:	5e                   	pop    %esi
  80283a:	5f                   	pop    %edi
  80283b:	5d                   	pop    %ebp
  80283c:	c3                   	ret    
  80283d:	8d 76 00             	lea    0x0(%esi),%esi
  802840:	29 f9                	sub    %edi,%ecx
  802842:	19 d6                	sbb    %edx,%esi
  802844:	89 74 24 04          	mov    %esi,0x4(%esp)
  802848:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80284c:	e9 18 ff ff ff       	jmp    802769 <__umoddi3+0x69>
