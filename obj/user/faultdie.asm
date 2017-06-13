
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 40 23 80 00       	push   $0x802340
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 89 0a 00 00       	call   800add <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 40 0a 00 00       	call   800a9c <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 ba 0c 00 00       	call   800d2b <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  80008b:	e8 4d 0a 00 00       	call   800add <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 bb 0e 00 00       	call   800f8c <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 c1 09 00 00       	call   800a9c <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 4f 09 00 00       	call   800a5f <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 54 01 00 00       	call   8002aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 f4 08 00 00       	call   800a5f <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 c5 1e 00 00       	call   8020a0 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 b2 1f 00 00       	call   8021d0 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 66 23 80 00 	movsbl 0x802366(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800239:	83 fa 01             	cmp    $0x1,%edx
  80023c:	7e 0e                	jle    80024c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 08             	lea    0x8(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	8b 52 04             	mov    0x4(%edx),%edx
  80024a:	eb 22                	jmp    80026e <getuint+0x38>
	else if (lflag)
  80024c:	85 d2                	test   %edx,%edx
  80024e:	74 10                	je     800260 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 04             	lea    0x4(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	ba 00 00 00 00       	mov    $0x0,%edx
  80025e:	eb 0e                	jmp    80026e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800260:	8b 10                	mov    (%eax),%edx
  800262:	8d 4a 04             	lea    0x4(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 02                	mov    (%edx),%eax
  800269:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800276:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	3b 50 04             	cmp    0x4(%eax),%edx
  80027f:	73 0a                	jae    80028b <sprintputch+0x1b>
		*b->buf++ = ch;
  800281:	8d 4a 01             	lea    0x1(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	88 02                	mov    %al,(%edx)
}
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800293:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800296:	50                   	push   %eax
  800297:	ff 75 10             	pushl  0x10(%ebp)
  80029a:	ff 75 0c             	pushl  0xc(%ebp)
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 05 00 00 00       	call   8002aa <vprintfmt>
	va_end(ap);
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	57                   	push   %edi
  8002ae:	56                   	push   %esi
  8002af:	53                   	push   %ebx
  8002b0:	83 ec 2c             	sub    $0x2c,%esp
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002bc:	eb 12                	jmp    8002d0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	0f 84 a9 03 00 00    	je     80066f <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	53                   	push   %ebx
  8002ca:	50                   	push   %eax
  8002cb:	ff d6                	call   *%esi
  8002cd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d0:	83 c7 01             	add    $0x1,%edi
  8002d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d7:	83 f8 25             	cmp    $0x25,%eax
  8002da:	75 e2                	jne    8002be <vprintfmt+0x14>
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fa:	eb 07                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002ff:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8d 47 01             	lea    0x1(%edi),%eax
  800306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800309:	0f b6 07             	movzbl (%edi),%eax
  80030c:	0f b6 c8             	movzbl %al,%ecx
  80030f:	83 e8 23             	sub    $0x23,%eax
  800312:	3c 55                	cmp    $0x55,%al
  800314:	0f 87 3a 03 00 00    	ja     800654 <vprintfmt+0x3aa>
  80031a:	0f b6 c0             	movzbl %al,%eax
  80031d:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800327:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032b:	eb d6                	jmp    800303 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80033f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800342:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800345:	83 fa 09             	cmp    $0x9,%edx
  800348:	77 39                	ja     800383 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80034d:	eb e9                	jmp    800338 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034f:	8b 45 14             	mov    0x14(%ebp),%eax
  800352:	8d 48 04             	lea    0x4(%eax),%ecx
  800355:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800358:	8b 00                	mov    (%eax),%eax
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800360:	eb 27                	jmp    800389 <vprintfmt+0xdf>
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	85 c0                	test   %eax,%eax
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	0f 49 c8             	cmovns %eax,%ecx
  80036f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800375:	eb 8c                	jmp    800303 <vprintfmt+0x59>
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800381:	eb 80                	jmp    800303 <vprintfmt+0x59>
  800383:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800386:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038d:	0f 89 70 ff ff ff    	jns    800303 <vprintfmt+0x59>
				width = precision, precision = -1;
  800393:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a0:	e9 5e ff ff ff       	jmp    800303 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ab:	e9 53 ff ff ff       	jmp    800303 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	53                   	push   %ebx
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff d6                	call   *%esi
			break;
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c7:	e9 04 ff ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 50 04             	lea    0x4(%eax),%edx
  8003d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	99                   	cltd   
  8003d8:	31 d0                	xor    %edx,%eax
  8003da:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003dc:	83 f8 0f             	cmp    $0xf,%eax
  8003df:	7f 0b                	jg     8003ec <vprintfmt+0x142>
  8003e1:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	75 18                	jne    800404 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ec:	50                   	push   %eax
  8003ed:	68 7e 23 80 00       	push   $0x80237e
  8003f2:	53                   	push   %ebx
  8003f3:	56                   	push   %esi
  8003f4:	e8 94 fe ff ff       	call   80028d <printfmt>
  8003f9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ff:	e9 cc fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800404:	52                   	push   %edx
  800405:	68 6d 27 80 00       	push   $0x80276d
  80040a:	53                   	push   %ebx
  80040b:	56                   	push   %esi
  80040c:	e8 7c fe ff ff       	call   80028d <printfmt>
  800411:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	e9 b4 fe ff ff       	jmp    8002d0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 50 04             	lea    0x4(%eax),%edx
  800422:	89 55 14             	mov    %edx,0x14(%ebp)
  800425:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800427:	85 ff                	test   %edi,%edi
  800429:	b8 77 23 80 00       	mov    $0x802377,%eax
  80042e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 8e 94 00 00 00    	jle    8004cf <vprintfmt+0x225>
  80043b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80043f:	0f 84 98 00 00 00    	je     8004dd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	ff 75 d0             	pushl  -0x30(%ebp)
  80044b:	57                   	push   %edi
  80044c:	e8 a6 02 00 00       	call   8006f7 <strnlen>
  800451:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800454:	29 c1                	sub    %eax,%ecx
  800456:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800459:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80045c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800466:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	eb 0f                	jmp    800479 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	53                   	push   %ebx
  80046e:	ff 75 e0             	pushl  -0x20(%ebp)
  800471:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800473:	83 ef 01             	sub    $0x1,%edi
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	85 ff                	test   %edi,%edi
  80047b:	7f ed                	jg     80046a <vprintfmt+0x1c0>
  80047d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800480:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800483:	85 c9                	test   %ecx,%ecx
  800485:	b8 00 00 00 00       	mov    $0x0,%eax
  80048a:	0f 49 c1             	cmovns %ecx,%eax
  80048d:	29 c1                	sub    %eax,%ecx
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	89 cb                	mov    %ecx,%ebx
  80049a:	eb 4d                	jmp    8004e9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	74 1b                	je     8004bd <vprintfmt+0x213>
  8004a2:	0f be c0             	movsbl %al,%eax
  8004a5:	83 e8 20             	sub    $0x20,%eax
  8004a8:	83 f8 5e             	cmp    $0x5e,%eax
  8004ab:	76 10                	jbe    8004bd <vprintfmt+0x213>
					putch('?', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	6a 3f                	push   $0x3f
  8004b5:	ff 55 08             	call   *0x8(%ebp)
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	eb 0d                	jmp    8004ca <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	52                   	push   %edx
  8004c4:	ff 55 08             	call   *0x8(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ca:	83 eb 01             	sub    $0x1,%ebx
  8004cd:	eb 1a                	jmp    8004e9 <vprintfmt+0x23f>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	eb 0c                	jmp    8004e9 <vprintfmt+0x23f>
  8004dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 23                	je     80051a <vprintfmt+0x270>
  8004f7:	85 f6                	test   %esi,%esi
  8004f9:	78 a1                	js     80049c <vprintfmt+0x1f2>
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	79 9c                	jns    80049c <vprintfmt+0x1f2>
  800500:	89 df                	mov    %ebx,%edi
  800502:	8b 75 08             	mov    0x8(%ebp),%esi
  800505:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800508:	eb 18                	jmp    800522 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	53                   	push   %ebx
  80050e:	6a 20                	push   $0x20
  800510:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800512:	83 ef 01             	sub    $0x1,%edi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	eb 08                	jmp    800522 <vprintfmt+0x278>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	85 ff                	test   %edi,%edi
  800524:	7f e4                	jg     80050a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800529:	e9 a2 fd ff ff       	jmp    8002d0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052e:	83 fa 01             	cmp    $0x1,%edx
  800531:	7e 16                	jle    800549 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 08             	lea    0x8(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 50 04             	mov    0x4(%eax),%edx
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800544:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800547:	eb 32                	jmp    80057b <vprintfmt+0x2d1>
	else if (lflag)
  800549:	85 d2                	test   %edx,%edx
  80054b:	74 18                	je     800565 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 04             	lea    0x4(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 00                	mov    (%eax),%eax
  800558:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055b:	89 c1                	mov    %eax,%ecx
  80055d:	c1 f9 1f             	sar    $0x1f,%ecx
  800560:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800563:	eb 16                	jmp    80057b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	89 c1                	mov    %eax,%ecx
  800575:	c1 f9 1f             	sar    $0x1f,%ecx
  800578:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800581:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	0f 89 90 00 00 00    	jns    800620 <vprintfmt+0x376>
				putch('-', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	53                   	push   %ebx
  800594:	6a 2d                	push   $0x2d
  800596:	ff d6                	call   *%esi
				num = -(long long) num;
  800598:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80059b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059e:	f7 d8                	neg    %eax
  8005a0:	83 d2 00             	adc    $0x0,%edx
  8005a3:	f7 da                	neg    %edx
  8005a5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005ad:	eb 71                	jmp    800620 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005af:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b2:	e8 7f fc ff ff       	call   800236 <getuint>
			base = 10;
  8005b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005bc:	eb 62                	jmp    800620 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005be:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c1:	e8 70 fc ff ff       	call   800236 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8005c6:	83 ec 0c             	sub    $0xc,%esp
  8005c9:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8005cd:	51                   	push   %ecx
  8005ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d1:	6a 08                	push   $0x8
  8005d3:	52                   	push   %edx
  8005d4:	50                   	push   %eax
  8005d5:	89 da                	mov    %ebx,%edx
  8005d7:	89 f0                	mov    %esi,%eax
  8005d9:	e8 a9 fb ff ff       	call   800187 <printnum>
			break;
  8005de:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8005e4:	e9 e7 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	6a 30                	push   $0x30
  8005ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f1:	83 c4 08             	add    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 78                	push   $0x78
  8005f7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800609:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800611:	eb 0d                	jmp    800620 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 1b fc ff ff       	call   800236 <getuint>
			base = 16;
  80061b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800620:	83 ec 0c             	sub    $0xc,%esp
  800623:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800627:	57                   	push   %edi
  800628:	ff 75 e0             	pushl  -0x20(%ebp)
  80062b:	51                   	push   %ecx
  80062c:	52                   	push   %edx
  80062d:	50                   	push   %eax
  80062e:	89 da                	mov    %ebx,%edx
  800630:	89 f0                	mov    %esi,%eax
  800632:	e8 50 fb ff ff       	call   800187 <printnum>
			break;
  800637:	83 c4 20             	add    $0x20,%esp
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063d:	e9 8e fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	51                   	push   %ecx
  800647:	ff d6                	call   *%esi
			break;
  800649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064f:	e9 7c fc ff ff       	jmp    8002d0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 25                	push   $0x25
  80065a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb 03                	jmp    800664 <vprintfmt+0x3ba>
  800661:	83 ef 01             	sub    $0x1,%edi
  800664:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800668:	75 f7                	jne    800661 <vprintfmt+0x3b7>
  80066a:	e9 61 fc ff ff       	jmp    8002d0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800672:	5b                   	pop    %ebx
  800673:	5e                   	pop    %esi
  800674:	5f                   	pop    %edi
  800675:	5d                   	pop    %ebp
  800676:	c3                   	ret    

00800677 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 18             	sub    $0x18,%esp
  80067d:	8b 45 08             	mov    0x8(%ebp),%eax
  800680:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800686:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800694:	85 c0                	test   %eax,%eax
  800696:	74 26                	je     8006be <vsnprintf+0x47>
  800698:	85 d2                	test   %edx,%edx
  80069a:	7e 22                	jle    8006be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069c:	ff 75 14             	pushl  0x14(%ebp)
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	68 70 02 80 00       	push   $0x800270
  8006ab:	e8 fa fb ff ff       	call   8002aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 05                	jmp    8006c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ce:	50                   	push   %eax
  8006cf:	ff 75 10             	pushl  0x10(%ebp)
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	ff 75 08             	pushl  0x8(%ebp)
  8006d8:	e8 9a ff ff ff       	call   800677 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	eb 03                	jmp    8006ef <strlen+0x10>
		n++;
  8006ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f3:	75 f7                	jne    8006ec <strlen+0xd>
		n++;
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800700:	ba 00 00 00 00       	mov    $0x0,%edx
  800705:	eb 03                	jmp    80070a <strnlen+0x13>
		n++;
  800707:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070a:	39 c2                	cmp    %eax,%edx
  80070c:	74 08                	je     800716 <strnlen+0x1f>
  80070e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800712:	75 f3                	jne    800707 <strnlen+0x10>
  800714:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800722:	89 c2                	mov    %eax,%edx
  800724:	83 c2 01             	add    $0x1,%edx
  800727:	83 c1 01             	add    $0x1,%ecx
  80072a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800731:	84 db                	test   %bl,%bl
  800733:	75 ef                	jne    800724 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800735:	5b                   	pop    %ebx
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073f:	53                   	push   %ebx
  800740:	e8 9a ff ff ff       	call   8006df <strlen>
  800745:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	01 d8                	add    %ebx,%eax
  80074d:	50                   	push   %eax
  80074e:	e8 c5 ff ff ff       	call   800718 <strcpy>
	return dst;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	56                   	push   %esi
  80075e:	53                   	push   %ebx
  80075f:	8b 75 08             	mov    0x8(%ebp),%esi
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800765:	89 f3                	mov    %esi,%ebx
  800767:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076a:	89 f2                	mov    %esi,%edx
  80076c:	eb 0f                	jmp    80077d <strncpy+0x23>
		*dst++ = *src;
  80076e:	83 c2 01             	add    $0x1,%edx
  800771:	0f b6 01             	movzbl (%ecx),%eax
  800774:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800777:	80 39 01             	cmpb   $0x1,(%ecx)
  80077a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077d:	39 da                	cmp    %ebx,%edx
  80077f:	75 ed                	jne    80076e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800781:	89 f0                	mov    %esi,%eax
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	8b 55 10             	mov    0x10(%ebp),%edx
  800795:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800797:	85 d2                	test   %edx,%edx
  800799:	74 21                	je     8007bc <strlcpy+0x35>
  80079b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079f:	89 f2                	mov    %esi,%edx
  8007a1:	eb 09                	jmp    8007ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ac:	39 c2                	cmp    %eax,%edx
  8007ae:	74 09                	je     8007b9 <strlcpy+0x32>
  8007b0:	0f b6 19             	movzbl (%ecx),%ebx
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ec                	jne    8007a3 <strlcpy+0x1c>
  8007b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bc:	29 f0                	sub    %esi,%eax
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cb:	eb 06                	jmp    8007d3 <strcmp+0x11>
		p++, q++;
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d3:	0f b6 01             	movzbl (%ecx),%eax
  8007d6:	84 c0                	test   %al,%al
  8007d8:	74 04                	je     8007de <strcmp+0x1c>
  8007da:	3a 02                	cmp    (%edx),%al
  8007dc:	74 ef                	je     8007cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007de:	0f b6 c0             	movzbl %al,%eax
  8007e1:	0f b6 12             	movzbl (%edx),%edx
  8007e4:	29 d0                	sub    %edx,%eax
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 c3                	mov    %eax,%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f7:	eb 06                	jmp    8007ff <strncmp+0x17>
		n--, p++, q++;
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ff:	39 d8                	cmp    %ebx,%eax
  800801:	74 15                	je     800818 <strncmp+0x30>
  800803:	0f b6 08             	movzbl (%eax),%ecx
  800806:	84 c9                	test   %cl,%cl
  800808:	74 04                	je     80080e <strncmp+0x26>
  80080a:	3a 0a                	cmp    (%edx),%cl
  80080c:	74 eb                	je     8007f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080e:	0f b6 00             	movzbl (%eax),%eax
  800811:	0f b6 12             	movzbl (%edx),%edx
  800814:	29 d0                	sub    %edx,%eax
  800816:	eb 05                	jmp    80081d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082a:	eb 07                	jmp    800833 <strchr+0x13>
		if (*s == c)
  80082c:	38 ca                	cmp    %cl,%dl
  80082e:	74 0f                	je     80083f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800830:	83 c0 01             	add    $0x1,%eax
  800833:	0f b6 10             	movzbl (%eax),%edx
  800836:	84 d2                	test   %dl,%dl
  800838:	75 f2                	jne    80082c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 03                	jmp    800850 <strfind+0xf>
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800853:	38 ca                	cmp    %cl,%dl
  800855:	74 04                	je     80085b <strfind+0x1a>
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strfind+0xc>
			break;
	return (char *) s;
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	57                   	push   %edi
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 7d 08             	mov    0x8(%ebp),%edi
  800866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 36                	je     8008a3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800873:	75 28                	jne    80089d <memset+0x40>
  800875:	f6 c1 03             	test   $0x3,%cl
  800878:	75 23                	jne    80089d <memset+0x40>
		c &= 0xFF;
  80087a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087e:	89 d3                	mov    %edx,%ebx
  800880:	c1 e3 08             	shl    $0x8,%ebx
  800883:	89 d6                	mov    %edx,%esi
  800885:	c1 e6 18             	shl    $0x18,%esi
  800888:	89 d0                	mov    %edx,%eax
  80088a:	c1 e0 10             	shl    $0x10,%eax
  80088d:	09 f0                	or     %esi,%eax
  80088f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800891:	89 d8                	mov    %ebx,%eax
  800893:	09 d0                	or     %edx,%eax
  800895:	c1 e9 02             	shr    $0x2,%ecx
  800898:	fc                   	cld    
  800899:	f3 ab                	rep stos %eax,%es:(%edi)
  80089b:	eb 06                	jmp    8008a3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	fc                   	cld    
  8008a1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a3:	89 f8                	mov    %edi,%eax
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5f                   	pop    %edi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	57                   	push   %edi
  8008ae:	56                   	push   %esi
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b8:	39 c6                	cmp    %eax,%esi
  8008ba:	73 35                	jae    8008f1 <memmove+0x47>
  8008bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bf:	39 d0                	cmp    %edx,%eax
  8008c1:	73 2e                	jae    8008f1 <memmove+0x47>
		s += n;
		d += n;
  8008c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	89 d6                	mov    %edx,%esi
  8008c8:	09 fe                	or     %edi,%esi
  8008ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d0:	75 13                	jne    8008e5 <memmove+0x3b>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 0e                	jne    8008e5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d7:	83 ef 04             	sub    $0x4,%edi
  8008da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
  8008e0:	fd                   	std    
  8008e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e3:	eb 09                	jmp    8008ee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e5:	83 ef 01             	sub    $0x1,%edi
  8008e8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008eb:	fd                   	std    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ee:	fc                   	cld    
  8008ef:	eb 1d                	jmp    80090e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f1:	89 f2                	mov    %esi,%edx
  8008f3:	09 c2                	or     %eax,%edx
  8008f5:	f6 c2 03             	test   $0x3,%dl
  8008f8:	75 0f                	jne    800909 <memmove+0x5f>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 0a                	jne    800909 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 05                	jmp    80090e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800915:	ff 75 10             	pushl  0x10(%ebp)
  800918:	ff 75 0c             	pushl  0xc(%ebp)
  80091b:	ff 75 08             	pushl  0x8(%ebp)
  80091e:	e8 87 ff ff ff       	call   8008aa <memmove>
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 c6                	mov    %eax,%esi
  800932:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800935:	eb 1a                	jmp    800951 <memcmp+0x2c>
		if (*s1 != *s2)
  800937:	0f b6 08             	movzbl (%eax),%ecx
  80093a:	0f b6 1a             	movzbl (%edx),%ebx
  80093d:	38 d9                	cmp    %bl,%cl
  80093f:	74 0a                	je     80094b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800941:	0f b6 c1             	movzbl %cl,%eax
  800944:	0f b6 db             	movzbl %bl,%ebx
  800947:	29 d8                	sub    %ebx,%eax
  800949:	eb 0f                	jmp    80095a <memcmp+0x35>
		s1++, s2++;
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800951:	39 f0                	cmp    %esi,%eax
  800953:	75 e2                	jne    800937 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	53                   	push   %ebx
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800965:	89 c1                	mov    %eax,%ecx
  800967:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096e:	eb 0a                	jmp    80097a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800970:	0f b6 10             	movzbl (%eax),%edx
  800973:	39 da                	cmp    %ebx,%edx
  800975:	74 07                	je     80097e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	39 c8                	cmp    %ecx,%eax
  80097c:	72 f2                	jb     800970 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098d:	eb 03                	jmp    800992 <strtol+0x11>
		s++;
  80098f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800992:	0f b6 01             	movzbl (%ecx),%eax
  800995:	3c 20                	cmp    $0x20,%al
  800997:	74 f6                	je     80098f <strtol+0xe>
  800999:	3c 09                	cmp    $0x9,%al
  80099b:	74 f2                	je     80098f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099d:	3c 2b                	cmp    $0x2b,%al
  80099f:	75 0a                	jne    8009ab <strtol+0x2a>
		s++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a9:	eb 11                	jmp    8009bc <strtol+0x3b>
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b0:	3c 2d                	cmp    $0x2d,%al
  8009b2:	75 08                	jne    8009bc <strtol+0x3b>
		s++, neg = 1;
  8009b4:	83 c1 01             	add    $0x1,%ecx
  8009b7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c2:	75 15                	jne    8009d9 <strtol+0x58>
  8009c4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c7:	75 10                	jne    8009d9 <strtol+0x58>
  8009c9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cd:	75 7c                	jne    800a4b <strtol+0xca>
		s += 2, base = 16;
  8009cf:	83 c1 02             	add    $0x2,%ecx
  8009d2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d7:	eb 16                	jmp    8009ef <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d9:	85 db                	test   %ebx,%ebx
  8009db:	75 12                	jne    8009ef <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009dd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 08                	jne    8009ef <strtol+0x6e>
		s++, base = 8;
  8009e7:	83 c1 01             	add    $0x1,%ecx
  8009ea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f7:	0f b6 11             	movzbl (%ecx),%edx
  8009fa:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fd:	89 f3                	mov    %esi,%ebx
  8009ff:	80 fb 09             	cmp    $0x9,%bl
  800a02:	77 08                	ja     800a0c <strtol+0x8b>
			dig = *s - '0';
  800a04:	0f be d2             	movsbl %dl,%edx
  800a07:	83 ea 30             	sub    $0x30,%edx
  800a0a:	eb 22                	jmp    800a2e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0f:	89 f3                	mov    %esi,%ebx
  800a11:	80 fb 19             	cmp    $0x19,%bl
  800a14:	77 08                	ja     800a1e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a16:	0f be d2             	movsbl %dl,%edx
  800a19:	83 ea 57             	sub    $0x57,%edx
  800a1c:	eb 10                	jmp    800a2e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a21:	89 f3                	mov    %esi,%ebx
  800a23:	80 fb 19             	cmp    $0x19,%bl
  800a26:	77 16                	ja     800a3e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a28:	0f be d2             	movsbl %dl,%edx
  800a2b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a31:	7d 0b                	jge    800a3e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3c:	eb b9                	jmp    8009f7 <strtol+0x76>

	if (endptr)
  800a3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a42:	74 0d                	je     800a51 <strtol+0xd0>
		*endptr = (char *) s;
  800a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a47:	89 0e                	mov    %ecx,(%esi)
  800a49:	eb 06                	jmp    800a51 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4b:	85 db                	test   %ebx,%ebx
  800a4d:	74 98                	je     8009e7 <strtol+0x66>
  800a4f:	eb 9e                	jmp    8009ef <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	f7 da                	neg    %edx
  800a55:	85 ff                	test   %edi,%edi
  800a57:	0f 45 c2             	cmovne %edx,%eax
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	89 c3                	mov    %eax,%ebx
  800a72:	89 c7                	mov    %eax,%edi
  800a74:	89 c6                	mov    %eax,%esi
  800a76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8d:	89 d1                	mov    %edx,%ecx
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	89 d7                	mov    %edx,%edi
  800a93:	89 d6                	mov    %edx,%esi
  800a95:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaa:	b8 03 00 00 00       	mov    $0x3,%eax
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	89 cb                	mov    %ecx,%ebx
  800ab4:	89 cf                	mov    %ecx,%edi
  800ab6:	89 ce                	mov    %ecx,%esi
  800ab8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	7e 17                	jle    800ad5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abe:	83 ec 0c             	sub    $0xc,%esp
  800ac1:	50                   	push   %eax
  800ac2:	6a 03                	push   $0x3
  800ac4:	68 5f 26 80 00       	push   $0x80265f
  800ac9:	6a 23                	push   $0x23
  800acb:	68 7c 26 80 00       	push   $0x80267c
  800ad0:	e8 49 14 00 00       	call   801f1e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 02 00 00 00       	mov    $0x2,%eax
  800aed:	89 d1                	mov    %edx,%ecx
  800aef:	89 d3                	mov    %edx,%ebx
  800af1:	89 d7                	mov    %edx,%edi
  800af3:	89 d6                	mov    %edx,%esi
  800af5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_yield>:

void
sys_yield(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	be 00 00 00 00       	mov    $0x0,%esi
  800b29:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b37:	89 f7                	mov    %esi,%edi
  800b39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 04                	push   $0x4
  800b45:	68 5f 26 80 00       	push   $0x80265f
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 7c 26 80 00       	push   $0x80267c
  800b51:	e8 c8 13 00 00       	call   801f1e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b67:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b78:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 05                	push   $0x5
  800b87:	68 5f 26 80 00       	push   $0x80265f
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 7c 26 80 00       	push   $0x80267c
  800b93:	e8 86 13 00 00       	call   801f1e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 06                	push   $0x6
  800bc9:	68 5f 26 80 00       	push   $0x80265f
  800bce:	6a 23                	push   $0x23
  800bd0:	68 7c 26 80 00       	push   $0x80267c
  800bd5:	e8 44 13 00 00       	call   801f1e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 08                	push   $0x8
  800c0b:	68 5f 26 80 00       	push   $0x80265f
  800c10:	6a 23                	push   $0x23
  800c12:	68 7c 26 80 00       	push   $0x80267c
  800c17:	e8 02 13 00 00       	call   801f1e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 09 00 00 00       	mov    $0x9,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 09                	push   $0x9
  800c4d:	68 5f 26 80 00       	push   $0x80265f
  800c52:	6a 23                	push   $0x23
  800c54:	68 7c 26 80 00       	push   $0x80267c
  800c59:	e8 c0 12 00 00       	call   801f1e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c74:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	89 df                	mov    %ebx,%edi
  800c81:	89 de                	mov    %ebx,%esi
  800c83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 17                	jle    800ca0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	50                   	push   %eax
  800c8d:	6a 0a                	push   $0xa
  800c8f:	68 5f 26 80 00       	push   $0x80265f
  800c94:	6a 23                	push   $0x23
  800c96:	68 7c 26 80 00       	push   $0x80267c
  800c9b:	e8 7e 12 00 00       	call   801f1e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca3:	5b                   	pop    %ebx
  800ca4:	5e                   	pop    %esi
  800ca5:	5f                   	pop    %edi
  800ca6:	5d                   	pop    %ebp
  800ca7:	c3                   	ret    

00800ca8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cde:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce1:	89 cb                	mov    %ecx,%ebx
  800ce3:	89 cf                	mov    %ecx,%edi
  800ce5:	89 ce                	mov    %ecx,%esi
  800ce7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7e 17                	jle    800d04 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 0d                	push   $0xd
  800cf3:	68 5f 26 80 00       	push   $0x80265f
  800cf8:	6a 23                	push   $0x23
  800cfa:	68 7c 26 80 00       	push   $0x80267c
  800cff:	e8 1a 12 00 00       	call   801f1e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	57                   	push   %edi
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	ba 00 00 00 00       	mov    $0x0,%edx
  800d17:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d1c:	89 d1                	mov    %edx,%ecx
  800d1e:	89 d3                	mov    %edx,%ebx
  800d20:	89 d7                	mov    %edx,%edi
  800d22:	89 d6                	mov    %edx,%esi
  800d24:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  800d31:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800d38:	75 56                	jne    800d90 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  800d3a:	83 ec 04             	sub    $0x4,%esp
  800d3d:	6a 07                	push   $0x7
  800d3f:	68 00 f0 bf ee       	push   $0xeebff000
  800d44:	6a 00                	push   $0x0
  800d46:	e8 d0 fd ff ff       	call   800b1b <sys_page_alloc>
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	74 14                	je     800d66 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	68 8a 26 80 00       	push   $0x80268a
  800d5a:	6a 21                	push   $0x21
  800d5c:	68 9f 26 80 00       	push   $0x80269f
  800d61:	e8 b8 11 00 00       	call   801f1e <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	68 9a 0d 80 00       	push   $0x800d9a
  800d6e:	6a 00                	push   $0x0
  800d70:	e8 f1 fe ff ff       	call   800c66 <sys_env_set_pgfault_upcall>
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	74 14                	je     800d90 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  800d7c:	83 ec 04             	sub    $0x4,%esp
  800d7f:	68 ad 26 80 00       	push   $0x8026ad
  800d84:	6a 23                	push   $0x23
  800d86:	68 9f 26 80 00       	push   $0x80269f
  800d8b:	e8 8e 11 00 00       	call   801f1e <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  800d98:	c9                   	leave  
  800d99:	c3                   	ret    

00800d9a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d9a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d9b:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800da0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800da2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  800da5:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  800da7:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  800dab:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800daf:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  800db0:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  800db2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  800db7:	83 c4 08             	add    $0x8,%esp
	popal
  800dba:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800dbb:	83 c4 04             	add    $0x4,%esp
	popfl
  800dbe:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800dbf:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dc0:	c3                   	ret    

00800dc1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	05 00 00 00 30       	add    $0x30000000,%eax
  800dcc:	c1 e8 0c             	shr    $0xc,%eax
}
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	05 00 00 00 30       	add    $0x30000000,%eax
  800ddc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800de1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	c1 ea 16             	shr    $0x16,%edx
  800df8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dff:	f6 c2 01             	test   $0x1,%dl
  800e02:	74 11                	je     800e15 <fd_alloc+0x2d>
  800e04:	89 c2                	mov    %eax,%edx
  800e06:	c1 ea 0c             	shr    $0xc,%edx
  800e09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e10:	f6 c2 01             	test   $0x1,%dl
  800e13:	75 09                	jne    800e1e <fd_alloc+0x36>
			*fd_store = fd;
  800e15:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1c:	eb 17                	jmp    800e35 <fd_alloc+0x4d>
  800e1e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e23:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e28:	75 c9                	jne    800df3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e2a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e30:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e3d:	83 f8 1f             	cmp    $0x1f,%eax
  800e40:	77 36                	ja     800e78 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e42:	c1 e0 0c             	shl    $0xc,%eax
  800e45:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e4a:	89 c2                	mov    %eax,%edx
  800e4c:	c1 ea 16             	shr    $0x16,%edx
  800e4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e56:	f6 c2 01             	test   $0x1,%dl
  800e59:	74 24                	je     800e7f <fd_lookup+0x48>
  800e5b:	89 c2                	mov    %eax,%edx
  800e5d:	c1 ea 0c             	shr    $0xc,%edx
  800e60:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e67:	f6 c2 01             	test   $0x1,%dl
  800e6a:	74 1a                	je     800e86 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6f:	89 02                	mov    %eax,(%edx)
	return 0;
  800e71:	b8 00 00 00 00       	mov    $0x0,%eax
  800e76:	eb 13                	jmp    800e8b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e7d:	eb 0c                	jmp    800e8b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e84:	eb 05                	jmp    800e8b <fd_lookup+0x54>
  800e86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 08             	sub    $0x8,%esp
  800e93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e96:	ba 40 27 80 00       	mov    $0x802740,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e9b:	eb 13                	jmp    800eb0 <dev_lookup+0x23>
  800e9d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ea0:	39 08                	cmp    %ecx,(%eax)
  800ea2:	75 0c                	jne    800eb0 <dev_lookup+0x23>
			*dev = devtab[i];
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	eb 2e                	jmp    800ede <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eb0:	8b 02                	mov    (%edx),%eax
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	75 e7                	jne    800e9d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eb6:	a1 08 40 80 00       	mov    0x804008,%eax
  800ebb:	8b 40 48             	mov    0x48(%eax),%eax
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	51                   	push   %ecx
  800ec2:	50                   	push   %eax
  800ec3:	68 c4 26 80 00       	push   $0x8026c4
  800ec8:	e8 a6 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 10             	sub    $0x10,%esp
  800ee8:	8b 75 08             	mov    0x8(%ebp),%esi
  800eeb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef1:	50                   	push   %eax
  800ef2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ef8:	c1 e8 0c             	shr    $0xc,%eax
  800efb:	50                   	push   %eax
  800efc:	e8 36 ff ff ff       	call   800e37 <fd_lookup>
  800f01:	83 c4 08             	add    $0x8,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	78 05                	js     800f0d <fd_close+0x2d>
	    || fd != fd2)
  800f08:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f0b:	74 0c                	je     800f19 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f0d:	84 db                	test   %bl,%bl
  800f0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f14:	0f 44 c2             	cmove  %edx,%eax
  800f17:	eb 41                	jmp    800f5a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f19:	83 ec 08             	sub    $0x8,%esp
  800f1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f1f:	50                   	push   %eax
  800f20:	ff 36                	pushl  (%esi)
  800f22:	e8 66 ff ff ff       	call   800e8d <dev_lookup>
  800f27:	89 c3                	mov    %eax,%ebx
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 1a                	js     800f4a <fd_close+0x6a>
		if (dev->dev_close)
  800f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f33:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f36:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	74 0b                	je     800f4a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f3f:	83 ec 0c             	sub    $0xc,%esp
  800f42:	56                   	push   %esi
  800f43:	ff d0                	call   *%eax
  800f45:	89 c3                	mov    %eax,%ebx
  800f47:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	56                   	push   %esi
  800f4e:	6a 00                	push   $0x0
  800f50:	e8 4b fc ff ff       	call   800ba0 <sys_page_unmap>
	return r;
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	89 d8                	mov    %ebx,%eax
}
  800f5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6a:	50                   	push   %eax
  800f6b:	ff 75 08             	pushl  0x8(%ebp)
  800f6e:	e8 c4 fe ff ff       	call   800e37 <fd_lookup>
  800f73:	83 c4 08             	add    $0x8,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	78 10                	js     800f8a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	6a 01                	push   $0x1
  800f7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800f82:	e8 59 ff ff ff       	call   800ee0 <fd_close>
  800f87:	83 c4 10             	add    $0x10,%esp
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <close_all>:

void
close_all(void)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f93:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f98:	83 ec 0c             	sub    $0xc,%esp
  800f9b:	53                   	push   %ebx
  800f9c:	e8 c0 ff ff ff       	call   800f61 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa1:	83 c3 01             	add    $0x1,%ebx
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	83 fb 20             	cmp    $0x20,%ebx
  800faa:	75 ec                	jne    800f98 <close_all+0xc>
		close(i);
}
  800fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 2c             	sub    $0x2c,%esp
  800fba:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fbd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 75 08             	pushl  0x8(%ebp)
  800fc4:	e8 6e fe ff ff       	call   800e37 <fd_lookup>
  800fc9:	83 c4 08             	add    $0x8,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	0f 88 c1 00 00 00    	js     801095 <dup+0xe4>
		return r;
	close(newfdnum);
  800fd4:	83 ec 0c             	sub    $0xc,%esp
  800fd7:	56                   	push   %esi
  800fd8:	e8 84 ff ff ff       	call   800f61 <close>

	newfd = INDEX2FD(newfdnum);
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	c1 e3 0c             	shl    $0xc,%ebx
  800fe2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fe8:	83 c4 04             	add    $0x4,%esp
  800feb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fee:	e8 de fd ff ff       	call   800dd1 <fd2data>
  800ff3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800ff5:	89 1c 24             	mov    %ebx,(%esp)
  800ff8:	e8 d4 fd ff ff       	call   800dd1 <fd2data>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801003:	89 f8                	mov    %edi,%eax
  801005:	c1 e8 16             	shr    $0x16,%eax
  801008:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80100f:	a8 01                	test   $0x1,%al
  801011:	74 37                	je     80104a <dup+0x99>
  801013:	89 f8                	mov    %edi,%eax
  801015:	c1 e8 0c             	shr    $0xc,%eax
  801018:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80101f:	f6 c2 01             	test   $0x1,%dl
  801022:	74 26                	je     80104a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801024:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	25 07 0e 00 00       	and    $0xe07,%eax
  801033:	50                   	push   %eax
  801034:	ff 75 d4             	pushl  -0x2c(%ebp)
  801037:	6a 00                	push   $0x0
  801039:	57                   	push   %edi
  80103a:	6a 00                	push   $0x0
  80103c:	e8 1d fb ff ff       	call   800b5e <sys_page_map>
  801041:	89 c7                	mov    %eax,%edi
  801043:	83 c4 20             	add    $0x20,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 2e                	js     801078 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80104d:	89 d0                	mov    %edx,%eax
  80104f:	c1 e8 0c             	shr    $0xc,%eax
  801052:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	25 07 0e 00 00       	and    $0xe07,%eax
  801061:	50                   	push   %eax
  801062:	53                   	push   %ebx
  801063:	6a 00                	push   $0x0
  801065:	52                   	push   %edx
  801066:	6a 00                	push   $0x0
  801068:	e8 f1 fa ff ff       	call   800b5e <sys_page_map>
  80106d:	89 c7                	mov    %eax,%edi
  80106f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801072:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801074:	85 ff                	test   %edi,%edi
  801076:	79 1d                	jns    801095 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801078:	83 ec 08             	sub    $0x8,%esp
  80107b:	53                   	push   %ebx
  80107c:	6a 00                	push   $0x0
  80107e:	e8 1d fb ff ff       	call   800ba0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801083:	83 c4 08             	add    $0x8,%esp
  801086:	ff 75 d4             	pushl  -0x2c(%ebp)
  801089:	6a 00                	push   $0x0
  80108b:	e8 10 fb ff ff       	call   800ba0 <sys_page_unmap>
	return r;
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	89 f8                	mov    %edi,%eax
}
  801095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 14             	sub    $0x14,%esp
  8010a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	53                   	push   %ebx
  8010ac:	e8 86 fd ff ff       	call   800e37 <fd_lookup>
  8010b1:	83 c4 08             	add    $0x8,%esp
  8010b4:	89 c2                	mov    %eax,%edx
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 6d                	js     801127 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c4:	ff 30                	pushl  (%eax)
  8010c6:	e8 c2 fd ff ff       	call   800e8d <dev_lookup>
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	78 4c                	js     80111e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010d5:	8b 42 08             	mov    0x8(%edx),%eax
  8010d8:	83 e0 03             	and    $0x3,%eax
  8010db:	83 f8 01             	cmp    $0x1,%eax
  8010de:	75 21                	jne    801101 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e5:	8b 40 48             	mov    0x48(%eax),%eax
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	53                   	push   %ebx
  8010ec:	50                   	push   %eax
  8010ed:	68 05 27 80 00       	push   $0x802705
  8010f2:	e8 7c f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ff:	eb 26                	jmp    801127 <read+0x8a>
	}
	if (!dev->dev_read)
  801101:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801104:	8b 40 08             	mov    0x8(%eax),%eax
  801107:	85 c0                	test   %eax,%eax
  801109:	74 17                	je     801122 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80110b:	83 ec 04             	sub    $0x4,%esp
  80110e:	ff 75 10             	pushl  0x10(%ebp)
  801111:	ff 75 0c             	pushl  0xc(%ebp)
  801114:	52                   	push   %edx
  801115:	ff d0                	call   *%eax
  801117:	89 c2                	mov    %eax,%edx
  801119:	83 c4 10             	add    $0x10,%esp
  80111c:	eb 09                	jmp    801127 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111e:	89 c2                	mov    %eax,%edx
  801120:	eb 05                	jmp    801127 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801122:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801127:	89 d0                	mov    %edx,%eax
  801129:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    

0080112e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 0c             	sub    $0xc,%esp
  801137:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80113d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801142:	eb 21                	jmp    801165 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801144:	83 ec 04             	sub    $0x4,%esp
  801147:	89 f0                	mov    %esi,%eax
  801149:	29 d8                	sub    %ebx,%eax
  80114b:	50                   	push   %eax
  80114c:	89 d8                	mov    %ebx,%eax
  80114e:	03 45 0c             	add    0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	57                   	push   %edi
  801153:	e8 45 ff ff ff       	call   80109d <read>
		if (m < 0)
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 10                	js     80116f <readn+0x41>
			return m;
		if (m == 0)
  80115f:	85 c0                	test   %eax,%eax
  801161:	74 0a                	je     80116d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801163:	01 c3                	add    %eax,%ebx
  801165:	39 f3                	cmp    %esi,%ebx
  801167:	72 db                	jb     801144 <readn+0x16>
  801169:	89 d8                	mov    %ebx,%eax
  80116b:	eb 02                	jmp    80116f <readn+0x41>
  80116d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	53                   	push   %ebx
  80117b:	83 ec 14             	sub    $0x14,%esp
  80117e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801181:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	53                   	push   %ebx
  801186:	e8 ac fc ff ff       	call   800e37 <fd_lookup>
  80118b:	83 c4 08             	add    $0x8,%esp
  80118e:	89 c2                	mov    %eax,%edx
  801190:	85 c0                	test   %eax,%eax
  801192:	78 68                	js     8011fc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801194:	83 ec 08             	sub    $0x8,%esp
  801197:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119a:	50                   	push   %eax
  80119b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119e:	ff 30                	pushl  (%eax)
  8011a0:	e8 e8 fc ff ff       	call   800e8d <dev_lookup>
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 47                	js     8011f3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b3:	75 21                	jne    8011d6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ba:	8b 40 48             	mov    0x48(%eax),%eax
  8011bd:	83 ec 04             	sub    $0x4,%esp
  8011c0:	53                   	push   %ebx
  8011c1:	50                   	push   %eax
  8011c2:	68 21 27 80 00       	push   $0x802721
  8011c7:	e8 a7 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d4:	eb 26                	jmp    8011fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8011dc:	85 d2                	test   %edx,%edx
  8011de:	74 17                	je     8011f7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e0:	83 ec 04             	sub    $0x4,%esp
  8011e3:	ff 75 10             	pushl  0x10(%ebp)
  8011e6:	ff 75 0c             	pushl  0xc(%ebp)
  8011e9:	50                   	push   %eax
  8011ea:	ff d2                	call   *%edx
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	eb 09                	jmp    8011fc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	eb 05                	jmp    8011fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011fc:	89 d0                	mov    %edx,%eax
  8011fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <seek>:

int
seek(int fdnum, off_t offset)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801209:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80120c:	50                   	push   %eax
  80120d:	ff 75 08             	pushl  0x8(%ebp)
  801210:	e8 22 fc ff ff       	call   800e37 <fd_lookup>
  801215:	83 c4 08             	add    $0x8,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 0e                	js     80122a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80121c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80121f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801222:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122a:	c9                   	leave  
  80122b:	c3                   	ret    

0080122c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
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
  80123b:	e8 f7 fb ff ff       	call   800e37 <fd_lookup>
  801240:	83 c4 08             	add    $0x8,%esp
  801243:	89 c2                	mov    %eax,%edx
  801245:	85 c0                	test   %eax,%eax
  801247:	78 65                	js     8012ae <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801249:	83 ec 08             	sub    $0x8,%esp
  80124c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801253:	ff 30                	pushl  (%eax)
  801255:	e8 33 fc ff ff       	call   800e8d <dev_lookup>
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	78 44                	js     8012a5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801268:	75 21                	jne    80128b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80126a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80126f:	8b 40 48             	mov    0x48(%eax),%eax
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	53                   	push   %ebx
  801276:	50                   	push   %eax
  801277:	68 e4 26 80 00       	push   $0x8026e4
  80127c:	e8 f2 ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801289:	eb 23                	jmp    8012ae <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80128b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128e:	8b 52 18             	mov    0x18(%edx),%edx
  801291:	85 d2                	test   %edx,%edx
  801293:	74 14                	je     8012a9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801295:	83 ec 08             	sub    $0x8,%esp
  801298:	ff 75 0c             	pushl  0xc(%ebp)
  80129b:	50                   	push   %eax
  80129c:	ff d2                	call   *%edx
  80129e:	89 c2                	mov    %eax,%edx
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	eb 09                	jmp    8012ae <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012a5:	89 c2                	mov    %eax,%edx
  8012a7:	eb 05                	jmp    8012ae <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ae:	89 d0                	mov    %edx,%eax
  8012b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 14             	sub    $0x14,%esp
  8012bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c2:	50                   	push   %eax
  8012c3:	ff 75 08             	pushl  0x8(%ebp)
  8012c6:	e8 6c fb ff ff       	call   800e37 <fd_lookup>
  8012cb:	83 c4 08             	add    $0x8,%esp
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	78 58                	js     80132c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012da:	50                   	push   %eax
  8012db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012de:	ff 30                	pushl  (%eax)
  8012e0:	e8 a8 fb ff ff       	call   800e8d <dev_lookup>
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 37                	js     801323 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012f3:	74 32                	je     801327 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012ff:	00 00 00 
	stat->st_isdir = 0;
  801302:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801309:	00 00 00 
	stat->st_dev = dev;
  80130c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	53                   	push   %ebx
  801316:	ff 75 f0             	pushl  -0x10(%ebp)
  801319:	ff 50 14             	call   *0x14(%eax)
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	eb 09                	jmp    80132c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801323:	89 c2                	mov    %eax,%edx
  801325:	eb 05                	jmp    80132c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801327:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801331:	c9                   	leave  
  801332:	c3                   	ret    

00801333 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	6a 00                	push   $0x0
  80133d:	ff 75 08             	pushl  0x8(%ebp)
  801340:	e8 ef 01 00 00       	call   801534 <open>
  801345:	89 c3                	mov    %eax,%ebx
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 1b                	js     801369 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	ff 75 0c             	pushl  0xc(%ebp)
  801354:	50                   	push   %eax
  801355:	e8 5b ff ff ff       	call   8012b5 <fstat>
  80135a:	89 c6                	mov    %eax,%esi
	close(fd);
  80135c:	89 1c 24             	mov    %ebx,(%esp)
  80135f:	e8 fd fb ff ff       	call   800f61 <close>
	return r;
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	89 f0                	mov    %esi,%eax
}
  801369:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136c:	5b                   	pop    %ebx
  80136d:	5e                   	pop    %esi
  80136e:	5d                   	pop    %ebp
  80136f:	c3                   	ret    

00801370 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	89 c6                	mov    %eax,%esi
  801377:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801379:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801380:	75 12                	jne    801394 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801382:	83 ec 0c             	sub    $0xc,%esp
  801385:	6a 01                	push   $0x1
  801387:	e8 9d 0c 00 00       	call   802029 <ipc_find_env>
  80138c:	a3 00 40 80 00       	mov    %eax,0x804000
  801391:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801394:	6a 07                	push   $0x7
  801396:	68 00 50 80 00       	push   $0x805000
  80139b:	56                   	push   %esi
  80139c:	ff 35 00 40 80 00    	pushl  0x804000
  8013a2:	e8 33 0c 00 00       	call   801fda <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013a7:	83 c4 0c             	add    $0xc,%esp
  8013aa:	6a 00                	push   $0x0
  8013ac:	53                   	push   %ebx
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 b0 0b 00 00       	call   801f64 <ipc_recv>
}
  8013b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8013de:	e8 8d ff ff ff       	call   801370 <fsipc>
}
  8013e3:	c9                   	leave  
  8013e4:	c3                   	ret    

008013e5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801400:	e8 6b ff ff ff       	call   801370 <fsipc>
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 04             	sub    $0x4,%esp
  80140e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	8b 40 0c             	mov    0xc(%eax),%eax
  801417:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80141c:	ba 00 00 00 00       	mov    $0x0,%edx
  801421:	b8 05 00 00 00       	mov    $0x5,%eax
  801426:	e8 45 ff ff ff       	call   801370 <fsipc>
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 2c                	js     80145b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	68 00 50 80 00       	push   $0x805000
  801437:	53                   	push   %ebx
  801438:	e8 db f2 ff ff       	call   800718 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80143d:	a1 80 50 80 00       	mov    0x805080,%eax
  801442:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801448:	a1 84 50 80 00       	mov    0x805084,%eax
  80144d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80145b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	53                   	push   %ebx
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80146a:	8b 55 08             	mov    0x8(%ebp),%edx
  80146d:	8b 52 0c             	mov    0xc(%edx),%edx
  801470:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801476:	a3 04 50 80 00       	mov    %eax,0x805004
  80147b:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801480:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801485:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801488:	53                   	push   %ebx
  801489:	ff 75 0c             	pushl  0xc(%ebp)
  80148c:	68 08 50 80 00       	push   $0x805008
  801491:	e8 14 f4 ff ff       	call   8008aa <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801496:	ba 00 00 00 00       	mov    $0x0,%edx
  80149b:	b8 04 00 00 00       	mov    $0x4,%eax
  8014a0:	e8 cb fe ff ff       	call   801370 <fsipc>
  8014a5:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8014ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	56                   	push   %esi
  8014b6:	53                   	push   %ebx
  8014b7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8014bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014c5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d0:	b8 03 00 00 00       	mov    $0x3,%eax
  8014d5:	e8 96 fe ff ff       	call   801370 <fsipc>
  8014da:	89 c3                	mov    %eax,%ebx
  8014dc:	85 c0                	test   %eax,%eax
  8014de:	78 4b                	js     80152b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014e0:	39 c6                	cmp    %eax,%esi
  8014e2:	73 16                	jae    8014fa <devfile_read+0x48>
  8014e4:	68 54 27 80 00       	push   $0x802754
  8014e9:	68 5b 27 80 00       	push   $0x80275b
  8014ee:	6a 7c                	push   $0x7c
  8014f0:	68 70 27 80 00       	push   $0x802770
  8014f5:	e8 24 0a 00 00       	call   801f1e <_panic>
	assert(r <= PGSIZE);
  8014fa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ff:	7e 16                	jle    801517 <devfile_read+0x65>
  801501:	68 7b 27 80 00       	push   $0x80277b
  801506:	68 5b 27 80 00       	push   $0x80275b
  80150b:	6a 7d                	push   $0x7d
  80150d:	68 70 27 80 00       	push   $0x802770
  801512:	e8 07 0a 00 00       	call   801f1e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801517:	83 ec 04             	sub    $0x4,%esp
  80151a:	50                   	push   %eax
  80151b:	68 00 50 80 00       	push   $0x805000
  801520:	ff 75 0c             	pushl  0xc(%ebp)
  801523:	e8 82 f3 ff ff       	call   8008aa <memmove>
	return r;
  801528:	83 c4 10             	add    $0x10,%esp
}
  80152b:	89 d8                	mov    %ebx,%eax
  80152d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    

00801534 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	53                   	push   %ebx
  801538:	83 ec 20             	sub    $0x20,%esp
  80153b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80153e:	53                   	push   %ebx
  80153f:	e8 9b f1 ff ff       	call   8006df <strlen>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80154c:	7f 67                	jg     8015b5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	e8 8e f8 ff ff       	call   800de8 <fd_alloc>
  80155a:	83 c4 10             	add    $0x10,%esp
		return r;
  80155d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 57                	js     8015ba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801563:	83 ec 08             	sub    $0x8,%esp
  801566:	53                   	push   %ebx
  801567:	68 00 50 80 00       	push   $0x805000
  80156c:	e8 a7 f1 ff ff       	call   800718 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801571:	8b 45 0c             	mov    0xc(%ebp),%eax
  801574:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801579:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80157c:	b8 01 00 00 00       	mov    $0x1,%eax
  801581:	e8 ea fd ff ff       	call   801370 <fsipc>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	79 14                	jns    8015a3 <open+0x6f>
		fd_close(fd, 0);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	6a 00                	push   $0x0
  801594:	ff 75 f4             	pushl  -0xc(%ebp)
  801597:	e8 44 f9 ff ff       	call   800ee0 <fd_close>
		return r;
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	89 da                	mov    %ebx,%edx
  8015a1:	eb 17                	jmp    8015ba <open+0x86>
	}

	return fd2num(fd);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a9:	e8 13 f8 ff ff       	call   800dc1 <fd2num>
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	83 c4 10             	add    $0x10,%esp
  8015b3:	eb 05                	jmp    8015ba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015b5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015ba:	89 d0                	mov    %edx,%eax
  8015bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8015d1:	e8 9a fd ff ff       	call   801370 <fsipc>
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	ff 75 08             	pushl  0x8(%ebp)
  8015e6:	e8 e6 f7 ff ff       	call   800dd1 <fd2data>
  8015eb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015ed:	83 c4 08             	add    $0x8,%esp
  8015f0:	68 87 27 80 00       	push   $0x802787
  8015f5:	53                   	push   %ebx
  8015f6:	e8 1d f1 ff ff       	call   800718 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015fb:	8b 46 04             	mov    0x4(%esi),%eax
  8015fe:	2b 06                	sub    (%esi),%eax
  801600:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801606:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80160d:	00 00 00 
	stat->st_dev = &devpipe;
  801610:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801617:	30 80 00 
	return 0;
}
  80161a:	b8 00 00 00 00       	mov    $0x0,%eax
  80161f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5d                   	pop    %ebp
  801625:	c3                   	ret    

00801626 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	53                   	push   %ebx
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801630:	53                   	push   %ebx
  801631:	6a 00                	push   $0x0
  801633:	e8 68 f5 ff ff       	call   800ba0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801638:	89 1c 24             	mov    %ebx,(%esp)
  80163b:	e8 91 f7 ff ff       	call   800dd1 <fd2data>
  801640:	83 c4 08             	add    $0x8,%esp
  801643:	50                   	push   %eax
  801644:	6a 00                	push   $0x0
  801646:	e8 55 f5 ff ff       	call   800ba0 <sys_page_unmap>
}
  80164b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	57                   	push   %edi
  801654:	56                   	push   %esi
  801655:	53                   	push   %ebx
  801656:	83 ec 1c             	sub    $0x1c,%esp
  801659:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80165c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80165e:	a1 08 40 80 00       	mov    0x804008,%eax
  801663:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	ff 75 e0             	pushl  -0x20(%ebp)
  80166c:	e8 f1 09 00 00       	call   802062 <pageref>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	89 3c 24             	mov    %edi,(%esp)
  801676:	e8 e7 09 00 00       	call   802062 <pageref>
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	39 c3                	cmp    %eax,%ebx
  801680:	0f 94 c1             	sete   %cl
  801683:	0f b6 c9             	movzbl %cl,%ecx
  801686:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801689:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80168f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801692:	39 ce                	cmp    %ecx,%esi
  801694:	74 1b                	je     8016b1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801696:	39 c3                	cmp    %eax,%ebx
  801698:	75 c4                	jne    80165e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80169a:	8b 42 58             	mov    0x58(%edx),%eax
  80169d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a0:	50                   	push   %eax
  8016a1:	56                   	push   %esi
  8016a2:	68 8e 27 80 00       	push   $0x80278e
  8016a7:	e8 c7 ea ff ff       	call   800173 <cprintf>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	eb ad                	jmp    80165e <_pipeisclosed+0xe>
	}
}
  8016b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5f                   	pop    %edi
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	57                   	push   %edi
  8016c0:	56                   	push   %esi
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 28             	sub    $0x28,%esp
  8016c5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016c8:	56                   	push   %esi
  8016c9:	e8 03 f7 ff ff       	call   800dd1 <fd2data>
  8016ce:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	bf 00 00 00 00       	mov    $0x0,%edi
  8016d8:	eb 4b                	jmp    801725 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016da:	89 da                	mov    %ebx,%edx
  8016dc:	89 f0                	mov    %esi,%eax
  8016de:	e8 6d ff ff ff       	call   801650 <_pipeisclosed>
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	75 48                	jne    80172f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016e7:	e8 10 f4 ff ff       	call   800afc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016ec:	8b 43 04             	mov    0x4(%ebx),%eax
  8016ef:	8b 0b                	mov    (%ebx),%ecx
  8016f1:	8d 51 20             	lea    0x20(%ecx),%edx
  8016f4:	39 d0                	cmp    %edx,%eax
  8016f6:	73 e2                	jae    8016da <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016ff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801702:	89 c2                	mov    %eax,%edx
  801704:	c1 fa 1f             	sar    $0x1f,%edx
  801707:	89 d1                	mov    %edx,%ecx
  801709:	c1 e9 1b             	shr    $0x1b,%ecx
  80170c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80170f:	83 e2 1f             	and    $0x1f,%edx
  801712:	29 ca                	sub    %ecx,%edx
  801714:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801718:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80171c:	83 c0 01             	add    $0x1,%eax
  80171f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801722:	83 c7 01             	add    $0x1,%edi
  801725:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801728:	75 c2                	jne    8016ec <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80172a:	8b 45 10             	mov    0x10(%ebp),%eax
  80172d:	eb 05                	jmp    801734 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80172f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	5f                   	pop    %edi
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    

0080173c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80173c:	55                   	push   %ebp
  80173d:	89 e5                	mov    %esp,%ebp
  80173f:	57                   	push   %edi
  801740:	56                   	push   %esi
  801741:	53                   	push   %ebx
  801742:	83 ec 18             	sub    $0x18,%esp
  801745:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801748:	57                   	push   %edi
  801749:	e8 83 f6 ff ff       	call   800dd1 <fd2data>
  80174e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	bb 00 00 00 00       	mov    $0x0,%ebx
  801758:	eb 3d                	jmp    801797 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80175a:	85 db                	test   %ebx,%ebx
  80175c:	74 04                	je     801762 <devpipe_read+0x26>
				return i;
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	eb 44                	jmp    8017a6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801762:	89 f2                	mov    %esi,%edx
  801764:	89 f8                	mov    %edi,%eax
  801766:	e8 e5 fe ff ff       	call   801650 <_pipeisclosed>
  80176b:	85 c0                	test   %eax,%eax
  80176d:	75 32                	jne    8017a1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80176f:	e8 88 f3 ff ff       	call   800afc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801774:	8b 06                	mov    (%esi),%eax
  801776:	3b 46 04             	cmp    0x4(%esi),%eax
  801779:	74 df                	je     80175a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80177b:	99                   	cltd   
  80177c:	c1 ea 1b             	shr    $0x1b,%edx
  80177f:	01 d0                	add    %edx,%eax
  801781:	83 e0 1f             	and    $0x1f,%eax
  801784:	29 d0                	sub    %edx,%eax
  801786:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80178b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801791:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801794:	83 c3 01             	add    $0x1,%ebx
  801797:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80179a:	75 d8                	jne    801774 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80179c:	8b 45 10             	mov    0x10(%ebp),%eax
  80179f:	eb 05                	jmp    8017a6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017a1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a9:	5b                   	pop    %ebx
  8017aa:	5e                   	pop    %esi
  8017ab:	5f                   	pop    %edi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b9:	50                   	push   %eax
  8017ba:	e8 29 f6 ff ff       	call   800de8 <fd_alloc>
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	89 c2                	mov    %eax,%edx
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	0f 88 2c 01 00 00    	js     8018f8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017cc:	83 ec 04             	sub    $0x4,%esp
  8017cf:	68 07 04 00 00       	push   $0x407
  8017d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d7:	6a 00                	push   $0x0
  8017d9:	e8 3d f3 ff ff       	call   800b1b <sys_page_alloc>
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	89 c2                	mov    %eax,%edx
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	0f 88 0d 01 00 00    	js     8018f8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017eb:	83 ec 0c             	sub    $0xc,%esp
  8017ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f1:	50                   	push   %eax
  8017f2:	e8 f1 f5 ff ff       	call   800de8 <fd_alloc>
  8017f7:	89 c3                	mov    %eax,%ebx
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	85 c0                	test   %eax,%eax
  8017fe:	0f 88 e2 00 00 00    	js     8018e6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801804:	83 ec 04             	sub    $0x4,%esp
  801807:	68 07 04 00 00       	push   $0x407
  80180c:	ff 75 f0             	pushl  -0x10(%ebp)
  80180f:	6a 00                	push   $0x0
  801811:	e8 05 f3 ff ff       	call   800b1b <sys_page_alloc>
  801816:	89 c3                	mov    %eax,%ebx
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	85 c0                	test   %eax,%eax
  80181d:	0f 88 c3 00 00 00    	js     8018e6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	ff 75 f4             	pushl  -0xc(%ebp)
  801829:	e8 a3 f5 ff ff       	call   800dd1 <fd2data>
  80182e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801830:	83 c4 0c             	add    $0xc,%esp
  801833:	68 07 04 00 00       	push   $0x407
  801838:	50                   	push   %eax
  801839:	6a 00                	push   $0x0
  80183b:	e8 db f2 ff ff       	call   800b1b <sys_page_alloc>
  801840:	89 c3                	mov    %eax,%ebx
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	85 c0                	test   %eax,%eax
  801847:	0f 88 89 00 00 00    	js     8018d6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	ff 75 f0             	pushl  -0x10(%ebp)
  801853:	e8 79 f5 ff ff       	call   800dd1 <fd2data>
  801858:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80185f:	50                   	push   %eax
  801860:	6a 00                	push   $0x0
  801862:	56                   	push   %esi
  801863:	6a 00                	push   $0x0
  801865:	e8 f4 f2 ff ff       	call   800b5e <sys_page_map>
  80186a:	89 c3                	mov    %eax,%ebx
  80186c:	83 c4 20             	add    $0x20,%esp
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 55                	js     8018c8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801873:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80187e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801881:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801888:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80188e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801891:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801893:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801896:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a3:	e8 19 f5 ff ff       	call   800dc1 <fd2num>
  8018a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018ab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018ad:	83 c4 04             	add    $0x4,%esp
  8018b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018b3:	e8 09 f5 ff ff       	call   800dc1 <fd2num>
  8018b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018bb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c6:	eb 30                	jmp    8018f8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018c8:	83 ec 08             	sub    $0x8,%esp
  8018cb:	56                   	push   %esi
  8018cc:	6a 00                	push   $0x0
  8018ce:	e8 cd f2 ff ff       	call   800ba0 <sys_page_unmap>
  8018d3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018dc:	6a 00                	push   $0x0
  8018de:	e8 bd f2 ff ff       	call   800ba0 <sys_page_unmap>
  8018e3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ec:	6a 00                	push   $0x0
  8018ee:	e8 ad f2 ff ff       	call   800ba0 <sys_page_unmap>
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018f8:	89 d0                	mov    %edx,%eax
  8018fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018fd:	5b                   	pop    %ebx
  8018fe:	5e                   	pop    %esi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801907:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	ff 75 08             	pushl  0x8(%ebp)
  80190e:	e8 24 f5 ff ff       	call   800e37 <fd_lookup>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 18                	js     801932 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	ff 75 f4             	pushl  -0xc(%ebp)
  801920:	e8 ac f4 ff ff       	call   800dd1 <fd2data>
	return _pipeisclosed(fd, p);
  801925:	89 c2                	mov    %eax,%edx
  801927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192a:	e8 21 fd ff ff       	call   801650 <_pipeisclosed>
  80192f:	83 c4 10             	add    $0x10,%esp
}
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80193a:	68 a6 27 80 00       	push   $0x8027a6
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	e8 d1 ed ff ff       	call   800718 <strcpy>
	return 0;
}
  801947:	b8 00 00 00 00       	mov    $0x0,%eax
  80194c:	c9                   	leave  
  80194d:	c3                   	ret    

0080194e <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 10             	sub    $0x10,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801958:	53                   	push   %ebx
  801959:	e8 04 07 00 00       	call   802062 <pageref>
  80195e:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801961:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801966:	83 f8 01             	cmp    $0x1,%eax
  801969:	75 10                	jne    80197b <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80196b:	83 ec 0c             	sub    $0xc,%esp
  80196e:	ff 73 0c             	pushl  0xc(%ebx)
  801971:	e8 c0 02 00 00       	call   801c36 <nsipc_close>
  801976:	89 c2                	mov    %eax,%edx
  801978:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80197b:	89 d0                	mov    %edx,%eax
  80197d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801988:	6a 00                	push   $0x0
  80198a:	ff 75 10             	pushl  0x10(%ebp)
  80198d:	ff 75 0c             	pushl  0xc(%ebp)
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	ff 70 0c             	pushl  0xc(%eax)
  801996:	e8 78 03 00 00       	call   801d13 <nsipc_send>
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019a3:	6a 00                	push   $0x0
  8019a5:	ff 75 10             	pushl  0x10(%ebp)
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	ff 70 0c             	pushl  0xc(%eax)
  8019b1:	e8 f1 02 00 00       	call   801ca7 <nsipc_recv>
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
  8019bb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019be:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019c1:	52                   	push   %edx
  8019c2:	50                   	push   %eax
  8019c3:	e8 6f f4 ff ff       	call   800e37 <fd_lookup>
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 17                	js     8019e6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d2:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  8019d8:	39 08                	cmp    %ecx,(%eax)
  8019da:	75 05                	jne    8019e1 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8019df:	eb 05                	jmp    8019e6 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	56                   	push   %esi
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 1c             	sub    $0x1c,%esp
  8019f0:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	e8 ed f3 ff ff       	call   800de8 <fd_alloc>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 1b                	js     801a1f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	68 07 04 00 00       	push   $0x407
  801a0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0f:	6a 00                	push   $0x0
  801a11:	e8 05 f1 ff ff       	call   800b1b <sys_page_alloc>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	79 10                	jns    801a2f <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	56                   	push   %esi
  801a23:	e8 0e 02 00 00       	call   801c36 <nsipc_close>
		return r;
  801a28:	83 c4 10             	add    $0x10,%esp
  801a2b:	89 d8                	mov    %ebx,%eax
  801a2d:	eb 24                	jmp    801a53 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a2f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a38:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a44:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a47:	83 ec 0c             	sub    $0xc,%esp
  801a4a:	50                   	push   %eax
  801a4b:	e8 71 f3 ff ff       	call   800dc1 <fd2num>
  801a50:	83 c4 10             	add    $0x10,%esp
}
  801a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	e8 50 ff ff ff       	call   8019b8 <fd2sockid>
		return r;
  801a68:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 1f                	js     801a8d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a6e:	83 ec 04             	sub    $0x4,%esp
  801a71:	ff 75 10             	pushl  0x10(%ebp)
  801a74:	ff 75 0c             	pushl  0xc(%ebp)
  801a77:	50                   	push   %eax
  801a78:	e8 12 01 00 00       	call   801b8f <nsipc_accept>
  801a7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a80:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a82:	85 c0                	test   %eax,%eax
  801a84:	78 07                	js     801a8d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a86:	e8 5d ff ff ff       	call   8019e8 <alloc_sockfd>
  801a8b:	89 c1                	mov    %eax,%ecx
}
  801a8d:	89 c8                	mov    %ecx,%eax
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	e8 19 ff ff ff       	call   8019b8 <fd2sockid>
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	78 12                	js     801ab5 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801aa3:	83 ec 04             	sub    $0x4,%esp
  801aa6:	ff 75 10             	pushl  0x10(%ebp)
  801aa9:	ff 75 0c             	pushl  0xc(%ebp)
  801aac:	50                   	push   %eax
  801aad:	e8 2d 01 00 00       	call   801bdf <nsipc_bind>
  801ab2:	83 c4 10             	add    $0x10,%esp
}
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <shutdown>:

int
shutdown(int s, int how)
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	e8 f3 fe ff ff       	call   8019b8 <fd2sockid>
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 0f                	js     801ad8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ac9:	83 ec 08             	sub    $0x8,%esp
  801acc:	ff 75 0c             	pushl  0xc(%ebp)
  801acf:	50                   	push   %eax
  801ad0:	e8 3f 01 00 00       	call   801c14 <nsipc_shutdown>
  801ad5:	83 c4 10             	add    $0x10,%esp
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae3:	e8 d0 fe ff ff       	call   8019b8 <fd2sockid>
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	78 12                	js     801afe <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	ff 75 10             	pushl  0x10(%ebp)
  801af2:	ff 75 0c             	pushl  0xc(%ebp)
  801af5:	50                   	push   %eax
  801af6:	e8 55 01 00 00       	call   801c50 <nsipc_connect>
  801afb:	83 c4 10             	add    $0x10,%esp
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <listen>:

int
listen(int s, int backlog)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b06:	8b 45 08             	mov    0x8(%ebp),%eax
  801b09:	e8 aa fe ff ff       	call   8019b8 <fd2sockid>
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 0f                	js     801b21 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b12:	83 ec 08             	sub    $0x8,%esp
  801b15:	ff 75 0c             	pushl  0xc(%ebp)
  801b18:	50                   	push   %eax
  801b19:	e8 67 01 00 00       	call   801c85 <nsipc_listen>
  801b1e:	83 c4 10             	add    $0x10,%esp
}
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    

00801b23 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b29:	ff 75 10             	pushl  0x10(%ebp)
  801b2c:	ff 75 0c             	pushl  0xc(%ebp)
  801b2f:	ff 75 08             	pushl  0x8(%ebp)
  801b32:	e8 3a 02 00 00       	call   801d71 <nsipc_socket>
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 05                	js     801b43 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b3e:	e8 a5 fe ff ff       	call   8019e8 <alloc_sockfd>
}
  801b43:	c9                   	leave  
  801b44:	c3                   	ret    

00801b45 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	53                   	push   %ebx
  801b49:	83 ec 04             	sub    $0x4,%esp
  801b4c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b4e:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b55:	75 12                	jne    801b69 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	6a 02                	push   $0x2
  801b5c:	e8 c8 04 00 00       	call   802029 <ipc_find_env>
  801b61:	a3 04 40 80 00       	mov    %eax,0x804004
  801b66:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b69:	6a 07                	push   $0x7
  801b6b:	68 00 60 80 00       	push   $0x806000
  801b70:	53                   	push   %ebx
  801b71:	ff 35 04 40 80 00    	pushl  0x804004
  801b77:	e8 5e 04 00 00       	call   801fda <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b7c:	83 c4 0c             	add    $0xc,%esp
  801b7f:	6a 00                	push   $0x0
  801b81:	6a 00                	push   $0x0
  801b83:	6a 00                	push   $0x0
  801b85:	e8 da 03 00 00       	call   801f64 <ipc_recv>
}
  801b8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b9f:	8b 06                	mov    (%esi),%eax
  801ba1:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	e8 95 ff ff ff       	call   801b45 <nsipc>
  801bb0:	89 c3                	mov    %eax,%ebx
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	78 20                	js     801bd6 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	ff 35 10 60 80 00    	pushl  0x806010
  801bbf:	68 00 60 80 00       	push   $0x806000
  801bc4:	ff 75 0c             	pushl  0xc(%ebp)
  801bc7:	e8 de ec ff ff       	call   8008aa <memmove>
		*addrlen = ret->ret_addrlen;
  801bcc:	a1 10 60 80 00       	mov    0x806010,%eax
  801bd1:	89 06                	mov    %eax,(%esi)
  801bd3:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801bd6:	89 d8                	mov    %ebx,%eax
  801bd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	83 ec 08             	sub    $0x8,%esp
  801be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801be9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bec:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bf1:	53                   	push   %ebx
  801bf2:	ff 75 0c             	pushl  0xc(%ebp)
  801bf5:	68 04 60 80 00       	push   $0x806004
  801bfa:	e8 ab ec ff ff       	call   8008aa <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bff:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c05:	b8 02 00 00 00       	mov    $0x2,%eax
  801c0a:	e8 36 ff ff ff       	call   801b45 <nsipc>
}
  801c0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c25:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c2a:	b8 03 00 00 00       	mov    $0x3,%eax
  801c2f:	e8 11 ff ff ff       	call   801b45 <nsipc>
}
  801c34:	c9                   	leave  
  801c35:	c3                   	ret    

00801c36 <nsipc_close>:

int
nsipc_close(int s)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3f:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c44:	b8 04 00 00 00       	mov    $0x4,%eax
  801c49:	e8 f7 fe ff ff       	call   801b45 <nsipc>
}
  801c4e:	c9                   	leave  
  801c4f:	c3                   	ret    

00801c50 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	53                   	push   %ebx
  801c54:	83 ec 08             	sub    $0x8,%esp
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c62:	53                   	push   %ebx
  801c63:	ff 75 0c             	pushl  0xc(%ebp)
  801c66:	68 04 60 80 00       	push   $0x806004
  801c6b:	e8 3a ec ff ff       	call   8008aa <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c70:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c76:	b8 05 00 00 00       	mov    $0x5,%eax
  801c7b:	e8 c5 fe ff ff       	call   801b45 <nsipc>
}
  801c80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    

00801c85 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c96:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c9b:	b8 06 00 00 00       	mov    $0x6,%eax
  801ca0:	e8 a0 fe ff ff       	call   801b45 <nsipc>
}
  801ca5:	c9                   	leave  
  801ca6:	c3                   	ret    

00801ca7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	56                   	push   %esi
  801cab:	53                   	push   %ebx
  801cac:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801cb7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801cbd:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cc5:	b8 07 00 00 00       	mov    $0x7,%eax
  801cca:	e8 76 fe ff ff       	call   801b45 <nsipc>
  801ccf:	89 c3                	mov    %eax,%ebx
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	78 35                	js     801d0a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801cd5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cda:	7f 04                	jg     801ce0 <nsipc_recv+0x39>
  801cdc:	39 c6                	cmp    %eax,%esi
  801cde:	7d 16                	jge    801cf6 <nsipc_recv+0x4f>
  801ce0:	68 b2 27 80 00       	push   $0x8027b2
  801ce5:	68 5b 27 80 00       	push   $0x80275b
  801cea:	6a 62                	push   $0x62
  801cec:	68 c7 27 80 00       	push   $0x8027c7
  801cf1:	e8 28 02 00 00       	call   801f1e <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	50                   	push   %eax
  801cfa:	68 00 60 80 00       	push   $0x806000
  801cff:	ff 75 0c             	pushl  0xc(%ebp)
  801d02:	e8 a3 eb ff ff       	call   8008aa <memmove>
  801d07:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d0a:	89 d8                	mov    %ebx,%eax
  801d0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 04             	sub    $0x4,%esp
  801d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d25:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d2b:	7e 16                	jle    801d43 <nsipc_send+0x30>
  801d2d:	68 d3 27 80 00       	push   $0x8027d3
  801d32:	68 5b 27 80 00       	push   $0x80275b
  801d37:	6a 6d                	push   $0x6d
  801d39:	68 c7 27 80 00       	push   $0x8027c7
  801d3e:	e8 db 01 00 00       	call   801f1e <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d43:	83 ec 04             	sub    $0x4,%esp
  801d46:	53                   	push   %ebx
  801d47:	ff 75 0c             	pushl  0xc(%ebp)
  801d4a:	68 0c 60 80 00       	push   $0x80600c
  801d4f:	e8 56 eb ff ff       	call   8008aa <memmove>
	nsipcbuf.send.req_size = size;
  801d54:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d5d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d62:	b8 08 00 00 00       	mov    $0x8,%eax
  801d67:	e8 d9 fd ff ff       	call   801b45 <nsipc>
}
  801d6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d77:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d82:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d87:	8b 45 10             	mov    0x10(%ebp),%eax
  801d8a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d8f:	b8 09 00 00 00       	mov    $0x9,%eax
  801d94:	e8 ac fd ff ff       	call   801b45 <nsipc>
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    

00801da5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dab:	68 df 27 80 00       	push   $0x8027df
  801db0:	ff 75 0c             	pushl  0xc(%ebp)
  801db3:	e8 60 e9 ff ff       	call   800718 <strcpy>
	return 0;
}
  801db8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    

00801dbf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	57                   	push   %edi
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd6:	eb 2d                	jmp    801e05 <devcons_write+0x46>
		m = n - tot;
  801dd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ddb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ddd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801de0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801de5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de8:	83 ec 04             	sub    $0x4,%esp
  801deb:	53                   	push   %ebx
  801dec:	03 45 0c             	add    0xc(%ebp),%eax
  801def:	50                   	push   %eax
  801df0:	57                   	push   %edi
  801df1:	e8 b4 ea ff ff       	call   8008aa <memmove>
		sys_cputs(buf, m);
  801df6:	83 c4 08             	add    $0x8,%esp
  801df9:	53                   	push   %ebx
  801dfa:	57                   	push   %edi
  801dfb:	e8 5f ec ff ff       	call   800a5f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e00:	01 de                	add    %ebx,%esi
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0a:	72 cc                	jb     801dd8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0f:	5b                   	pop    %ebx
  801e10:	5e                   	pop    %esi
  801e11:	5f                   	pop    %edi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 08             	sub    $0x8,%esp
  801e1a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e23:	74 2a                	je     801e4f <devcons_read+0x3b>
  801e25:	eb 05                	jmp    801e2c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e27:	e8 d0 ec ff ff       	call   800afc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2c:	e8 4c ec ff ff       	call   800a7d <sys_cgetc>
  801e31:	85 c0                	test   %eax,%eax
  801e33:	74 f2                	je     801e27 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e35:	85 c0                	test   %eax,%eax
  801e37:	78 16                	js     801e4f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e39:	83 f8 04             	cmp    $0x4,%eax
  801e3c:	74 0c                	je     801e4a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e41:	88 02                	mov    %al,(%edx)
	return 1;
  801e43:	b8 01 00 00 00       	mov    $0x1,%eax
  801e48:	eb 05                	jmp    801e4f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e4a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e5d:	6a 01                	push   $0x1
  801e5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e62:	50                   	push   %eax
  801e63:	e8 f7 eb ff ff       	call   800a5f <sys_cputs>
}
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	c9                   	leave  
  801e6c:	c3                   	ret    

00801e6d <getchar>:

int
getchar(void)
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e73:	6a 01                	push   $0x1
  801e75:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	6a 00                	push   $0x0
  801e7b:	e8 1d f2 ff ff       	call   80109d <read>
	if (r < 0)
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 0f                	js     801e96 <getchar+0x29>
		return r;
	if (r < 1)
  801e87:	85 c0                	test   %eax,%eax
  801e89:	7e 06                	jle    801e91 <getchar+0x24>
		return -E_EOF;
	return c;
  801e8b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e8f:	eb 05                	jmp    801e96 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e91:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea1:	50                   	push   %eax
  801ea2:	ff 75 08             	pushl  0x8(%ebp)
  801ea5:	e8 8d ef ff ff       	call   800e37 <fd_lookup>
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 11                	js     801ec2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eba:	39 10                	cmp    %edx,(%eax)
  801ebc:	0f 94 c0             	sete   %al
  801ebf:	0f b6 c0             	movzbl %al,%eax
}
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <opencons>:

int
opencons(void)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecd:	50                   	push   %eax
  801ece:	e8 15 ef ff ff       	call   800de8 <fd_alloc>
  801ed3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed8:	85 c0                	test   %eax,%eax
  801eda:	78 3e                	js     801f1a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	68 07 04 00 00       	push   $0x407
  801ee4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee7:	6a 00                	push   $0x0
  801ee9:	e8 2d ec ff ff       	call   800b1b <sys_page_alloc>
  801eee:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef3:	85 c0                	test   %eax,%eax
  801ef5:	78 23                	js     801f1a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ef7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f00:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	50                   	push   %eax
  801f10:	e8 ac ee ff ff       	call   800dc1 <fd2num>
  801f15:	89 c2                	mov    %eax,%edx
  801f17:	83 c4 10             	add    $0x10,%esp
}
  801f1a:	89 d0                	mov    %edx,%eax
  801f1c:	c9                   	leave  
  801f1d:	c3                   	ret    

00801f1e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	56                   	push   %esi
  801f22:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f23:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f26:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f2c:	e8 ac eb ff ff       	call   800add <sys_getenvid>
  801f31:	83 ec 0c             	sub    $0xc,%esp
  801f34:	ff 75 0c             	pushl  0xc(%ebp)
  801f37:	ff 75 08             	pushl  0x8(%ebp)
  801f3a:	56                   	push   %esi
  801f3b:	50                   	push   %eax
  801f3c:	68 ec 27 80 00       	push   $0x8027ec
  801f41:	e8 2d e2 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f46:	83 c4 18             	add    $0x18,%esp
  801f49:	53                   	push   %ebx
  801f4a:	ff 75 10             	pushl  0x10(%ebp)
  801f4d:	e8 d0 e1 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801f52:	c7 04 24 9f 27 80 00 	movl   $0x80279f,(%esp)
  801f59:	e8 15 e2 ff ff       	call   800173 <cprintf>
  801f5e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f61:	cc                   	int3   
  801f62:	eb fd                	jmp    801f61 <_panic+0x43>

00801f64 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	56                   	push   %esi
  801f68:	53                   	push   %ebx
  801f69:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801f72:	85 c0                	test   %eax,%eax
  801f74:	74 0e                	je     801f84 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801f76:	83 ec 0c             	sub    $0xc,%esp
  801f79:	50                   	push   %eax
  801f7a:	e8 4c ed ff ff       	call   800ccb <sys_ipc_recv>
  801f7f:	83 c4 10             	add    $0x10,%esp
  801f82:	eb 10                	jmp    801f94 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	68 00 00 c0 ee       	push   $0xeec00000
  801f8c:	e8 3a ed ff ff       	call   800ccb <sys_ipc_recv>
  801f91:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801f94:	85 c0                	test   %eax,%eax
  801f96:	79 17                	jns    801faf <ipc_recv+0x4b>
		if(*from_env_store)
  801f98:	83 3e 00             	cmpl   $0x0,(%esi)
  801f9b:	74 06                	je     801fa3 <ipc_recv+0x3f>
			*from_env_store = 0;
  801f9d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801fa3:	85 db                	test   %ebx,%ebx
  801fa5:	74 2c                	je     801fd3 <ipc_recv+0x6f>
			*perm_store = 0;
  801fa7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fad:	eb 24                	jmp    801fd3 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801faf:	85 f6                	test   %esi,%esi
  801fb1:	74 0a                	je     801fbd <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801fb3:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb8:	8b 40 74             	mov    0x74(%eax),%eax
  801fbb:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801fbd:	85 db                	test   %ebx,%ebx
  801fbf:	74 0a                	je     801fcb <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801fc1:	a1 08 40 80 00       	mov    0x804008,%eax
  801fc6:	8b 40 78             	mov    0x78(%eax),%eax
  801fc9:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fcb:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd6:	5b                   	pop    %ebx
  801fd7:	5e                   	pop    %esi
  801fd8:	5d                   	pop    %ebp
  801fd9:	c3                   	ret    

00801fda <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fda:	55                   	push   %ebp
  801fdb:	89 e5                	mov    %esp,%ebp
  801fdd:	57                   	push   %edi
  801fde:	56                   	push   %esi
  801fdf:	53                   	push   %ebx
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801fec:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801fee:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801ff3:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801ff6:	e8 01 eb ff ff       	call   800afc <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801ffb:	ff 75 14             	pushl  0x14(%ebp)
  801ffe:	53                   	push   %ebx
  801fff:	56                   	push   %esi
  802000:	57                   	push   %edi
  802001:	e8 a2 ec ff ff       	call   800ca8 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802006:	89 c2                	mov    %eax,%edx
  802008:	f7 d2                	not    %edx
  80200a:	c1 ea 1f             	shr    $0x1f,%edx
  80200d:	83 c4 10             	add    $0x10,%esp
  802010:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802013:	0f 94 c1             	sete   %cl
  802016:	09 ca                	or     %ecx,%edx
  802018:	85 c0                	test   %eax,%eax
  80201a:	0f 94 c0             	sete   %al
  80201d:	38 c2                	cmp    %al,%dl
  80201f:	77 d5                	ja     801ff6 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  802021:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802024:	5b                   	pop    %ebx
  802025:	5e                   	pop    %esi
  802026:	5f                   	pop    %edi
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80202f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802034:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802037:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80203d:	8b 52 50             	mov    0x50(%edx),%edx
  802040:	39 ca                	cmp    %ecx,%edx
  802042:	75 0d                	jne    802051 <ipc_find_env+0x28>
			return envs[i].env_id;
  802044:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802047:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80204c:	8b 40 48             	mov    0x48(%eax),%eax
  80204f:	eb 0f                	jmp    802060 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802051:	83 c0 01             	add    $0x1,%eax
  802054:	3d 00 04 00 00       	cmp    $0x400,%eax
  802059:	75 d9                	jne    802034 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80205b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    

00802062 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802062:	55                   	push   %ebp
  802063:	89 e5                	mov    %esp,%ebp
  802065:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802068:	89 d0                	mov    %edx,%eax
  80206a:	c1 e8 16             	shr    $0x16,%eax
  80206d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802079:	f6 c1 01             	test   $0x1,%cl
  80207c:	74 1d                	je     80209b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80207e:	c1 ea 0c             	shr    $0xc,%edx
  802081:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802088:	f6 c2 01             	test   $0x1,%dl
  80208b:	74 0e                	je     80209b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80208d:	c1 ea 0c             	shr    $0xc,%edx
  802090:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802097:	ef 
  802098:	0f b7 c0             	movzwl %ax,%eax
}
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 f6                	test   %esi,%esi
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 ca                	mov    %ecx,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	75 3d                	jne    802100 <__udivdi3+0x60>
  8020c3:	39 cf                	cmp    %ecx,%edi
  8020c5:	0f 87 c5 00 00 00    	ja     802190 <__udivdi3+0xf0>
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	89 fd                	mov    %edi,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f7                	div    %edi
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 c8                	mov    %ecx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c1                	mov    %eax,%ecx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	89 cf                	mov    %ecx,%edi
  8020e8:	f7 f5                	div    %ebp
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	39 ce                	cmp    %ecx,%esi
  802102:	77 74                	ja     802178 <__udivdi3+0xd8>
  802104:	0f bd fe             	bsr    %esi,%edi
  802107:	83 f7 1f             	xor    $0x1f,%edi
  80210a:	0f 84 98 00 00 00    	je     8021a8 <__udivdi3+0x108>
  802110:	bb 20 00 00 00       	mov    $0x20,%ebx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	89 c5                	mov    %eax,%ebp
  802119:	29 fb                	sub    %edi,%ebx
  80211b:	d3 e6                	shl    %cl,%esi
  80211d:	89 d9                	mov    %ebx,%ecx
  80211f:	d3 ed                	shr    %cl,%ebp
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e0                	shl    %cl,%eax
  802125:	09 ee                	or     %ebp,%esi
  802127:	89 d9                	mov    %ebx,%ecx
  802129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212d:	89 d5                	mov    %edx,%ebp
  80212f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802133:	d3 ed                	shr    %cl,%ebp
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e2                	shl    %cl,%edx
  802139:	89 d9                	mov    %ebx,%ecx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	09 c2                	or     %eax,%edx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	89 ea                	mov    %ebp,%edx
  802143:	f7 f6                	div    %esi
  802145:	89 d5                	mov    %edx,%ebp
  802147:	89 c3                	mov    %eax,%ebx
  802149:	f7 64 24 0c          	mull   0xc(%esp)
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	72 10                	jb     802161 <__udivdi3+0xc1>
  802151:	8b 74 24 08          	mov    0x8(%esp),%esi
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e6                	shl    %cl,%esi
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	73 07                	jae    802164 <__udivdi3+0xc4>
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	75 03                	jne    802164 <__udivdi3+0xc4>
  802161:	83 eb 01             	sub    $0x1,%ebx
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 d8                	mov    %ebx,%eax
  802168:	89 fa                	mov    %edi,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	31 db                	xor    %ebx,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d8                	mov    %ebx,%eax
  802192:	f7 f7                	div    %edi
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 c3                	mov    %eax,%ebx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 fa                	mov    %edi,%edx
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 ce                	cmp    %ecx,%esi
  8021aa:	72 0c                	jb     8021b8 <__udivdi3+0x118>
  8021ac:	31 db                	xor    %ebx,%ebx
  8021ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021b2:	0f 87 34 ff ff ff    	ja     8020ec <__udivdi3+0x4c>
  8021b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021bd:	e9 2a ff ff ff       	jmp    8020ec <__udivdi3+0x4c>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 f3                	mov    %esi,%ebx
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fa:	75 1c                	jne    802218 <__umoddi3+0x48>
  8021fc:	39 f7                	cmp    %esi,%edi
  8021fe:	76 50                	jbe    802250 <__umoddi3+0x80>
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	f7 f7                	div    %edi
  802206:	89 d0                	mov    %edx,%eax
  802208:	31 d2                	xor    %edx,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	77 52                	ja     802270 <__umoddi3+0xa0>
  80221e:	0f bd ea             	bsr    %edx,%ebp
  802221:	83 f5 1f             	xor    $0x1f,%ebp
  802224:	75 5a                	jne    802280 <__umoddi3+0xb0>
  802226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80222a:	0f 82 e0 00 00 00    	jb     802310 <__umoddi3+0x140>
  802230:	39 0c 24             	cmp    %ecx,(%esp)
  802233:	0f 86 d7 00 00 00    	jbe    802310 <__umoddi3+0x140>
  802239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80223d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	85 ff                	test   %edi,%edi
  802252:	89 fd                	mov    %edi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f7                	div    %edi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	89 f0                	mov    %esi,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f5                	div    %ebp
  802267:	89 c8                	mov    %ecx,%eax
  802269:	f7 f5                	div    %ebp
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	eb 99                	jmp    802208 <__umoddi3+0x38>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 34 24             	mov    (%esp),%esi
  802283:	bf 20 00 00 00       	mov    $0x20,%edi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ef                	sub    %ebp,%edi
  80228c:	d3 e0                	shl    %cl,%eax
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	89 f2                	mov    %esi,%edx
  802292:	d3 ea                	shr    %cl,%edx
  802294:	89 e9                	mov    %ebp,%ecx
  802296:	09 c2                	or     %eax,%edx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 14 24             	mov    %edx,(%esp)
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	89 c6                	mov    %eax,%esi
  8022b1:	d3 e3                	shl    %cl,%ebx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 d0                	mov    %edx,%eax
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	09 d8                	or     %ebx,%eax
  8022bd:	89 d3                	mov    %edx,%ebx
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	f7 34 24             	divl   (%esp)
  8022c4:	89 d6                	mov    %edx,%esi
  8022c6:	d3 e3                	shl    %cl,%ebx
  8022c8:	f7 64 24 04          	mull   0x4(%esp)
  8022cc:	39 d6                	cmp    %edx,%esi
  8022ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d2:	89 d1                	mov    %edx,%ecx
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	72 08                	jb     8022e0 <__umoddi3+0x110>
  8022d8:	75 11                	jne    8022eb <__umoddi3+0x11b>
  8022da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022de:	73 0b                	jae    8022eb <__umoddi3+0x11b>
  8022e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022e4:	1b 14 24             	sbb    (%esp),%edx
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ef:	29 da                	sub    %ebx,%edx
  8022f1:	19 ce                	sbb    %ecx,%esi
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e0                	shl    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	d3 ee                	shr    %cl,%esi
  802301:	09 d0                	or     %edx,%eax
  802303:	89 f2                	mov    %esi,%edx
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	29 f9                	sub    %edi,%ecx
  802312:	19 d6                	sbb    %edx,%esi
  802314:	89 74 24 04          	mov    %esi,0x4(%esp)
  802318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231c:	e9 18 ff ff ff       	jmp    802239 <__umoddi3+0x69>
