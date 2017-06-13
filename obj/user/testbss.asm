
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 00 23 80 00       	push   $0x802300
  80003e:	e8 d2 01 00 00       	call   800215 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 40 80 00 	cmpl   $0x0,0x804020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 7b 23 80 00       	push   $0x80237b
  80005b:	6a 11                	push   $0x11
  80005d:	68 98 23 80 00       	push   $0x802398
  800062:	e8 d5 00 00 00       	call   80013c <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 40 80 00 	mov    %eax,0x804020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 40 80 00 	cmp    0x804020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 20 23 80 00       	push   $0x802320
  80009b:	6a 16                	push   $0x16
  80009d:	68 98 23 80 00       	push   $0x802398
  8000a2:	e8 95 00 00 00       	call   80013c <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 48 23 80 00       	push   $0x802348
  8000b9:	e8 57 01 00 00       	call   800215 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 a7 23 80 00       	push   $0x8023a7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 98 23 80 00       	push   $0x802398
  8000d7:	e8 60 00 00 00       	call   80013c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000e7:	e8 93 0a 00 00       	call   800b7f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 40 c0 00       	mov    %eax,0xc04020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800128:	e8 6b 0e 00 00       	call   800f98 <close_all>
	sys_env_destroy(0);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	6a 00                	push   $0x0
  800132:	e8 07 0a 00 00       	call   800b3e <sys_env_destroy>
}
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80014a:	e8 30 0a 00 00       	call   800b7f <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 c8 23 80 00       	push   $0x8023c8
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 4f 09 00 00       	call   800b01 <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 f4 08 00 00       	call   800b01 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 f3 1d 00 00       	call   802070 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 e0 1e 00 00       	call   8021a0 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 eb 23 80 00 	movsbl 0x8023eb(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 a9 03 00 00    	je     800711 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 07                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 47 01             	lea    0x1(%edi),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	0f b6 c8             	movzbl %al,%ecx
  8003b1:	83 e8 23             	sub    $0x23,%eax
  8003b4:	3c 55                	cmp    $0x55,%al
  8003b6:	0f 87 3a 03 00 00    	ja     8006f6 <vprintfmt+0x3aa>
  8003bc:	0f b6 c0             	movzbl %al,%eax
  8003bf:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	77 39                	ja     800425 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ef:	eb e9                	jmp    8003da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 27                	jmp    80042b <vprintfmt+0xdf>
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	0f 49 c8             	cmovns %eax,%ecx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	eb 8c                	jmp    8003a5 <vprintfmt+0x59>
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800423:	eb 80                	jmp    8003a5 <vprintfmt+0x59>
  800425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800428:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80042b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042f:	0f 89 70 ff ff ff    	jns    8003a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800435:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800442:	e9 5e ff ff ff       	jmp    8003a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044d:	e9 53 ff ff ff       	jmp    8003a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	ff 30                	pushl  (%eax)
  800461:	ff d6                	call   *%esi
			break;
  800463:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800469:	e9 04 ff ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	99                   	cltd   
  80047a:	31 d0                	xor    %edx,%eax
  80047c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	83 f8 0f             	cmp    $0xf,%eax
  800481:	7f 0b                	jg     80048e <vprintfmt+0x142>
  800483:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 18                	jne    8004a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 03 24 80 00       	push   $0x802403
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 94 fe ff ff       	call   80032f <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 cc fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	52                   	push   %edx
  8004a7:	68 b9 27 80 00       	push   $0x8027b9
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 7c fe ff ff       	call   80032f <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b9:	e9 b4 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	b8 fc 23 80 00       	mov    $0x8023fc,%eax
  8004d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 8e 94 00 00 00    	jle    800571 <vprintfmt+0x225>
  8004dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e1:	0f 84 98 00 00 00    	je     80057f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ed:	57                   	push   %edi
  8004ee:	e8 a6 02 00 00       	call   800799 <strnlen>
  8004f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c0>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	89 cb                	mov    %ecx,%ebx
  80053c:	eb 4d                	jmp    80058b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	74 1b                	je     80055f <vprintfmt+0x213>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 10                	jbe    80055f <vprintfmt+0x213>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	6a 3f                	push   $0x3f
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	52                   	push   %edx
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x23f>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	eb 0c                	jmp    80058b <vprintfmt+0x23f>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800592:	0f be d0             	movsbl %al,%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	74 23                	je     8005bc <vprintfmt+0x270>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 a1                	js     80053e <vprintfmt+0x1f2>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 9c                	jns    80053e <vprintfmt+0x1f2>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	eb 18                	jmp    8005c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x278>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e4                	jg     8005ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 a2 fd ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 50 04             	mov    0x4(%eax),%edx
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x2d1>
	else if (lflag)
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800620:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800623:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800628:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062c:	0f 89 90 00 00 00    	jns    8006c2 <vprintfmt+0x376>
				putch('-', putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 2d                	push   $0x2d
  800638:	ff d6                	call   *%esi
				num = -(long long) num;
  80063a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800640:	f7 d8                	neg    %eax
  800642:	83 d2 00             	adc    $0x0,%edx
  800645:	f7 da                	neg    %edx
  800647:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80064f:	eb 71                	jmp    8006c2 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
  800654:	e8 7f fc ff ff       	call   8002d8 <getuint>
			base = 10;
  800659:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80065e:	eb 62                	jmp    8006c2 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 70 fc ff ff       	call   8002d8 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800668:	83 ec 0c             	sub    $0xc,%esp
  80066b:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80066f:	51                   	push   %ecx
  800670:	ff 75 e0             	pushl  -0x20(%ebp)
  800673:	6a 08                	push   $0x8
  800675:	52                   	push   %edx
  800676:	50                   	push   %eax
  800677:	89 da                	mov    %ebx,%edx
  800679:	89 f0                	mov    %esi,%eax
  80067b:	e8 a9 fb ff ff       	call   800229 <printnum>
			break;
  800680:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800686:	e9 e7 fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 30                	push   $0x30
  800691:	ff d6                	call   *%esi
			putch('x', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 78                	push   $0x78
  800699:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8d 50 04             	lea    0x4(%eax),%edx
  8006a1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a4:	8b 00                	mov    (%eax),%eax
  8006a6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ab:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b3:	eb 0d                	jmp    8006c2 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 1b fc ff ff       	call   8002d8 <getuint>
			base = 16;
  8006bd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c9:	57                   	push   %edi
  8006ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cd:	51                   	push   %ecx
  8006ce:	52                   	push   %edx
  8006cf:	50                   	push   %eax
  8006d0:	89 da                	mov    %ebx,%edx
  8006d2:	89 f0                	mov    %esi,%eax
  8006d4:	e8 50 fb ff ff       	call   800229 <printnum>
			break;
  8006d9:	83 c4 20             	add    $0x20,%esp
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006df:	e9 8e fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	51                   	push   %ecx
  8006e9:	ff d6                	call   *%esi
			break;
  8006eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f1:	e9 7c fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 25                	push   $0x25
  8006fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 03                	jmp    800706 <vprintfmt+0x3ba>
  800703:	83 ef 01             	sub    $0x1,%edi
  800706:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070a:	75 f7                	jne    800703 <vprintfmt+0x3b7>
  80070c:	e9 61 fc ff ff       	jmp    800372 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800711:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800714:	5b                   	pop    %ebx
  800715:	5e                   	pop    %esi
  800716:	5f                   	pop    %edi
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 18             	sub    $0x18,%esp
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800728:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800736:	85 c0                	test   %eax,%eax
  800738:	74 26                	je     800760 <vsnprintf+0x47>
  80073a:	85 d2                	test   %edx,%edx
  80073c:	7e 22                	jle    800760 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073e:	ff 75 14             	pushl  0x14(%ebp)
  800741:	ff 75 10             	pushl  0x10(%ebp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	50                   	push   %eax
  800748:	68 12 03 80 00       	push   $0x800312
  80074d:	e8 fa fb ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800752:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800755:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 05                	jmp    800765 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800760:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800770:	50                   	push   %eax
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	ff 75 08             	pushl  0x8(%ebp)
  80077a:	e8 9a ff ff ff       	call   800719 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800787:	b8 00 00 00 00       	mov    $0x0,%eax
  80078c:	eb 03                	jmp    800791 <strlen+0x10>
		n++;
  80078e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800791:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800795:	75 f7                	jne    80078e <strlen+0xd>
		n++;
	return n;
}
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a7:	eb 03                	jmp    8007ac <strnlen+0x13>
		n++;
  8007a9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ac:	39 c2                	cmp    %eax,%edx
  8007ae:	74 08                	je     8007b8 <strnlen+0x1f>
  8007b0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b4:	75 f3                	jne    8007a9 <strnlen+0x10>
  8007b6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c4:	89 c2                	mov    %eax,%edx
  8007c6:	83 c2 01             	add    $0x1,%edx
  8007c9:	83 c1 01             	add    $0x1,%ecx
  8007cc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ef                	jne    8007c6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d7:	5b                   	pop    %ebx
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e1:	53                   	push   %ebx
  8007e2:	e8 9a ff ff ff       	call   800781 <strlen>
  8007e7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	01 d8                	add    %ebx,%eax
  8007ef:	50                   	push   %eax
  8007f0:	e8 c5 ff ff ff       	call   8007ba <strcpy>
	return dst;
}
  8007f5:	89 d8                	mov    %ebx,%eax
  8007f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 75 08             	mov    0x8(%ebp),%esi
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	89 f3                	mov    %esi,%ebx
  800809:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	89 f2                	mov    %esi,%edx
  80080e:	eb 0f                	jmp    80081f <strncpy+0x23>
		*dst++ = *src;
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	0f b6 01             	movzbl (%ecx),%eax
  800816:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800819:	80 39 01             	cmpb   $0x1,(%ecx)
  80081c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081f:	39 da                	cmp    %ebx,%edx
  800821:	75 ed                	jne    800810 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800823:	89 f0                	mov    %esi,%eax
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	56                   	push   %esi
  80082d:	53                   	push   %ebx
  80082e:	8b 75 08             	mov    0x8(%ebp),%esi
  800831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800834:	8b 55 10             	mov    0x10(%ebp),%edx
  800837:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800839:	85 d2                	test   %edx,%edx
  80083b:	74 21                	je     80085e <strlcpy+0x35>
  80083d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800841:	89 f2                	mov    %esi,%edx
  800843:	eb 09                	jmp    80084e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084e:	39 c2                	cmp    %eax,%edx
  800850:	74 09                	je     80085b <strlcpy+0x32>
  800852:	0f b6 19             	movzbl (%ecx),%ebx
  800855:	84 db                	test   %bl,%bl
  800857:	75 ec                	jne    800845 <strlcpy+0x1c>
  800859:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085e:	29 f0                	sub    %esi,%eax
}
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086d:	eb 06                	jmp    800875 <strcmp+0x11>
		p++, q++;
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800875:	0f b6 01             	movzbl (%ecx),%eax
  800878:	84 c0                	test   %al,%al
  80087a:	74 04                	je     800880 <strcmp+0x1c>
  80087c:	3a 02                	cmp    (%edx),%al
  80087e:	74 ef                	je     80086f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800880:	0f b6 c0             	movzbl %al,%eax
  800883:	0f b6 12             	movzbl (%edx),%edx
  800886:	29 d0                	sub    %edx,%eax
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
  800894:	89 c3                	mov    %eax,%ebx
  800896:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800899:	eb 06                	jmp    8008a1 <strncmp+0x17>
		n--, p++, q++;
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a1:	39 d8                	cmp    %ebx,%eax
  8008a3:	74 15                	je     8008ba <strncmp+0x30>
  8008a5:	0f b6 08             	movzbl (%eax),%ecx
  8008a8:	84 c9                	test   %cl,%cl
  8008aa:	74 04                	je     8008b0 <strncmp+0x26>
  8008ac:	3a 0a                	cmp    (%edx),%cl
  8008ae:	74 eb                	je     80089b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 00             	movzbl (%eax),%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
  8008b8:	eb 05                	jmp    8008bf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	eb 07                	jmp    8008d5 <strchr+0x13>
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	74 0f                	je     8008e1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	0f b6 10             	movzbl (%eax),%edx
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f2                	jne    8008ce <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ed:	eb 03                	jmp    8008f2 <strfind+0xf>
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f5:	38 ca                	cmp    %cl,%dl
  8008f7:	74 04                	je     8008fd <strfind+0x1a>
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f2                	jne    8008ef <strfind+0xc>
			break;
	return (char *) s;
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 7d 08             	mov    0x8(%ebp),%edi
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	74 36                	je     800945 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800915:	75 28                	jne    80093f <memset+0x40>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 23                	jne    80093f <memset+0x40>
		c &= 0xFF;
  80091c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800920:	89 d3                	mov    %edx,%ebx
  800922:	c1 e3 08             	shl    $0x8,%ebx
  800925:	89 d6                	mov    %edx,%esi
  800927:	c1 e6 18             	shl    $0x18,%esi
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	c1 e0 10             	shl    $0x10,%eax
  80092f:	09 f0                	or     %esi,%eax
  800931:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800933:	89 d8                	mov    %ebx,%eax
  800935:	09 d0                	or     %edx,%eax
  800937:	c1 e9 02             	shr    $0x2,%ecx
  80093a:	fc                   	cld    
  80093b:	f3 ab                	rep stos %eax,%es:(%edi)
  80093d:	eb 06                	jmp    800945 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	fc                   	cld    
  800943:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800945:	89 f8                	mov    %edi,%eax
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5f                   	pop    %edi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 75 0c             	mov    0xc(%ebp),%esi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095a:	39 c6                	cmp    %eax,%esi
  80095c:	73 35                	jae    800993 <memmove+0x47>
  80095e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800961:	39 d0                	cmp    %edx,%eax
  800963:	73 2e                	jae    800993 <memmove+0x47>
		s += n;
		d += n;
  800965:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 d6                	mov    %edx,%esi
  80096a:	09 fe                	or     %edi,%esi
  80096c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800972:	75 13                	jne    800987 <memmove+0x3b>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 0e                	jne    800987 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800979:	83 ef 04             	sub    $0x4,%edi
  80097c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	fd                   	std    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 09                	jmp    800990 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800987:	83 ef 01             	sub    $0x1,%edi
  80098a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098d:	fd                   	std    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800990:	fc                   	cld    
  800991:	eb 1d                	jmp    8009b0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 f2                	mov    %esi,%edx
  800995:	09 c2                	or     %eax,%edx
  800997:	f6 c2 03             	test   $0x3,%dl
  80099a:	75 0f                	jne    8009ab <memmove+0x5f>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0a                	jne    8009ab <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 05                	jmp    8009b0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	ff 75 0c             	pushl  0xc(%ebp)
  8009bd:	ff 75 08             	pushl  0x8(%ebp)
  8009c0:	e8 87 ff ff ff       	call   80094c <memmove>
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d2:	89 c6                	mov    %eax,%esi
  8009d4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	eb 1a                	jmp    8009f3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d9:	0f b6 08             	movzbl (%eax),%ecx
  8009dc:	0f b6 1a             	movzbl (%edx),%ebx
  8009df:	38 d9                	cmp    %bl,%cl
  8009e1:	74 0a                	je     8009ed <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e3:	0f b6 c1             	movzbl %cl,%eax
  8009e6:	0f b6 db             	movzbl %bl,%ebx
  8009e9:	29 d8                	sub    %ebx,%eax
  8009eb:	eb 0f                	jmp    8009fc <memcmp+0x35>
		s1++, s2++;
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f3:	39 f0                	cmp    %esi,%eax
  8009f5:	75 e2                	jne    8009d9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a07:	89 c1                	mov    %eax,%ecx
  800a09:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a10:	eb 0a                	jmp    800a1c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	0f b6 10             	movzbl (%eax),%edx
  800a15:	39 da                	cmp    %ebx,%edx
  800a17:	74 07                	je     800a20 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	39 c8                	cmp    %ecx,%eax
  800a1e:	72 f2                	jb     800a12 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	eb 03                	jmp    800a34 <strtol+0x11>
		s++;
  800a31:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	0f b6 01             	movzbl (%ecx),%eax
  800a37:	3c 20                	cmp    $0x20,%al
  800a39:	74 f6                	je     800a31 <strtol+0xe>
  800a3b:	3c 09                	cmp    $0x9,%al
  800a3d:	74 f2                	je     800a31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3f:	3c 2b                	cmp    $0x2b,%al
  800a41:	75 0a                	jne    800a4d <strtol+0x2a>
		s++;
  800a43:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4b:	eb 11                	jmp    800a5e <strtol+0x3b>
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a52:	3c 2d                	cmp    $0x2d,%al
  800a54:	75 08                	jne    800a5e <strtol+0x3b>
		s++, neg = 1;
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a64:	75 15                	jne    800a7b <strtol+0x58>
  800a66:	80 39 30             	cmpb   $0x30,(%ecx)
  800a69:	75 10                	jne    800a7b <strtol+0x58>
  800a6b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6f:	75 7c                	jne    800aed <strtol+0xca>
		s += 2, base = 16;
  800a71:	83 c1 02             	add    $0x2,%ecx
  800a74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a79:	eb 16                	jmp    800a91 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	75 12                	jne    800a91 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 08                	jne    800a91 <strtol+0x6e>
		s++, base = 8;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a99:	0f b6 11             	movzbl (%ecx),%edx
  800a9c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 09             	cmp    $0x9,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x8b>
			dig = *s - '0';
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 30             	sub    $0x30,%edx
  800aac:	eb 22                	jmp    800ad0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 57             	sub    $0x57,%edx
  800abe:	eb 10                	jmp    800ad0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 16                	ja     800ae0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad3:	7d 0b                	jge    800ae0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad5:	83 c1 01             	add    $0x1,%ecx
  800ad8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ade:	eb b9                	jmp    800a99 <strtol+0x76>

	if (endptr)
  800ae0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae4:	74 0d                	je     800af3 <strtol+0xd0>
		*endptr = (char *) s;
  800ae6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae9:	89 0e                	mov    %ecx,(%esi)
  800aeb:	eb 06                	jmp    800af3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	74 98                	je     800a89 <strtol+0x66>
  800af1:	eb 9e                	jmp    800a91 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	f7 da                	neg    %edx
  800af7:	85 ff                	test   %edi,%edi
  800af9:	0f 45 c2             	cmovne %edx,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	89 c7                	mov    %eax,%edi
  800b16:	89 c6                	mov    %eax,%esi
  800b18:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800b47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	89 cb                	mov    %ecx,%ebx
  800b56:	89 cf                	mov    %ecx,%edi
  800b58:	89 ce                	mov    %ecx,%esi
  800b5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 03                	push   $0x3
  800b66:	68 df 26 80 00       	push   $0x8026df
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 fc 26 80 00       	push   $0x8026fc
  800b72:	e8 c5 f5 ff ff       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_yield>:

void
sys_yield(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	be 00 00 00 00       	mov    $0x0,%esi
  800bcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd9:	89 f7                	mov    %esi,%edi
  800bdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 04                	push   $0x4
  800be7:	68 df 26 80 00       	push   $0x8026df
  800bec:	6a 23                	push   $0x23
  800bee:	68 fc 26 80 00       	push   $0x8026fc
  800bf3:	e8 44 f5 ff ff       	call   80013c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 05                	push   $0x5
  800c29:	68 df 26 80 00       	push   $0x8026df
  800c2e:	6a 23                	push   $0x23
  800c30:	68 fc 26 80 00       	push   $0x8026fc
  800c35:	e8 02 f5 ff ff       	call   80013c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 06 00 00 00       	mov    $0x6,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 06                	push   $0x6
  800c6b:	68 df 26 80 00       	push   $0x8026df
  800c70:	6a 23                	push   $0x23
  800c72:	68 fc 26 80 00       	push   $0x8026fc
  800c77:	e8 c0 f4 ff ff       	call   80013c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 08 00 00 00       	mov    $0x8,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 08                	push   $0x8
  800cad:	68 df 26 80 00       	push   $0x8026df
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 fc 26 80 00       	push   $0x8026fc
  800cb9:	e8 7e f4 ff ff       	call   80013c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 09                	push   $0x9
  800cef:	68 df 26 80 00       	push   $0x8026df
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 fc 26 80 00       	push   $0x8026fc
  800cfb:	e8 3c f4 ff ff       	call   80013c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 df                	mov    %ebx,%edi
  800d23:	89 de                	mov    %ebx,%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 17                	jle    800d42 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	50                   	push   %eax
  800d2f:	6a 0a                	push   $0xa
  800d31:	68 df 26 80 00       	push   $0x8026df
  800d36:	6a 23                	push   $0x23
  800d38:	68 fc 26 80 00       	push   $0x8026fc
  800d3d:	e8 fa f3 ff ff       	call   80013c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800d50:	be 00 00 00 00       	mov    $0x0,%esi
  800d55:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d63:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d66:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 cb                	mov    %ecx,%ebx
  800d85:	89 cf                	mov    %ecx,%edi
  800d87:	89 ce                	mov    %ecx,%esi
  800d89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 0d                	push   $0xd
  800d95:	68 df 26 80 00       	push   $0x8026df
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 fc 26 80 00       	push   $0x8026fc
  800da1:	e8 96 f3 ff ff       	call   80013c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	ba 00 00 00 00       	mov    $0x0,%edx
  800db9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dbe:	89 d1                	mov    %edx,%ecx
  800dc0:	89 d3                	mov    %edx,%ebx
  800dc2:	89 d7                	mov    %edx,%edi
  800dc4:	89 d6                	mov    %edx,%esi
  800dc6:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd8:	c1 e8 0c             	shr    $0xc,%eax
}
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	05 00 00 00 30       	add    $0x30000000,%eax
  800de8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ded:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dff:	89 c2                	mov    %eax,%edx
  800e01:	c1 ea 16             	shr    $0x16,%edx
  800e04:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0b:	f6 c2 01             	test   $0x1,%dl
  800e0e:	74 11                	je     800e21 <fd_alloc+0x2d>
  800e10:	89 c2                	mov    %eax,%edx
  800e12:	c1 ea 0c             	shr    $0xc,%edx
  800e15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1c:	f6 c2 01             	test   $0x1,%dl
  800e1f:	75 09                	jne    800e2a <fd_alloc+0x36>
			*fd_store = fd;
  800e21:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
  800e28:	eb 17                	jmp    800e41 <fd_alloc+0x4d>
  800e2a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e2f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e34:	75 c9                	jne    800dff <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e36:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e3c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e49:	83 f8 1f             	cmp    $0x1f,%eax
  800e4c:	77 36                	ja     800e84 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e4e:	c1 e0 0c             	shl    $0xc,%eax
  800e51:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	c1 ea 16             	shr    $0x16,%edx
  800e5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e62:	f6 c2 01             	test   $0x1,%dl
  800e65:	74 24                	je     800e8b <fd_lookup+0x48>
  800e67:	89 c2                	mov    %eax,%edx
  800e69:	c1 ea 0c             	shr    $0xc,%edx
  800e6c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e73:	f6 c2 01             	test   $0x1,%dl
  800e76:	74 1a                	je     800e92 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e82:	eb 13                	jmp    800e97 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e84:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e89:	eb 0c                	jmp    800e97 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e90:	eb 05                	jmp    800e97 <fd_lookup+0x54>
  800e92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 08             	sub    $0x8,%esp
  800e9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea2:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea7:	eb 13                	jmp    800ebc <dev_lookup+0x23>
  800ea9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eac:	39 08                	cmp    %ecx,(%eax)
  800eae:	75 0c                	jne    800ebc <dev_lookup+0x23>
			*dev = devtab[i];
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eba:	eb 2e                	jmp    800eea <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ebc:	8b 02                	mov    (%edx),%eax
  800ebe:	85 c0                	test   %eax,%eax
  800ec0:	75 e7                	jne    800ea9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec2:	a1 20 40 c0 00       	mov    0xc04020,%eax
  800ec7:	8b 40 48             	mov    0x48(%eax),%eax
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	51                   	push   %ecx
  800ece:	50                   	push   %eax
  800ecf:	68 0c 27 80 00       	push   $0x80270c
  800ed4:	e8 3c f3 ff ff       	call   800215 <cprintf>
	*dev = 0;
  800ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 10             	sub    $0x10,%esp
  800ef4:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800efa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efd:	50                   	push   %eax
  800efe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f04:	c1 e8 0c             	shr    $0xc,%eax
  800f07:	50                   	push   %eax
  800f08:	e8 36 ff ff ff       	call   800e43 <fd_lookup>
  800f0d:	83 c4 08             	add    $0x8,%esp
  800f10:	85 c0                	test   %eax,%eax
  800f12:	78 05                	js     800f19 <fd_close+0x2d>
	    || fd != fd2)
  800f14:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f17:	74 0c                	je     800f25 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f19:	84 db                	test   %bl,%bl
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	0f 44 c2             	cmove  %edx,%eax
  800f23:	eb 41                	jmp    800f66 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f25:	83 ec 08             	sub    $0x8,%esp
  800f28:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	ff 36                	pushl  (%esi)
  800f2e:	e8 66 ff ff ff       	call   800e99 <dev_lookup>
  800f33:	89 c3                	mov    %eax,%ebx
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	78 1a                	js     800f56 <fd_close+0x6a>
		if (dev->dev_close)
  800f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f42:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f47:	85 c0                	test   %eax,%eax
  800f49:	74 0b                	je     800f56 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f4b:	83 ec 0c             	sub    $0xc,%esp
  800f4e:	56                   	push   %esi
  800f4f:	ff d0                	call   *%eax
  800f51:	89 c3                	mov    %eax,%ebx
  800f53:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	56                   	push   %esi
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 e1 fc ff ff       	call   800c42 <sys_page_unmap>
	return r;
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	89 d8                	mov    %ebx,%eax
}
  800f66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    

00800f6d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	ff 75 08             	pushl  0x8(%ebp)
  800f7a:	e8 c4 fe ff ff       	call   800e43 <fd_lookup>
  800f7f:	83 c4 08             	add    $0x8,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	78 10                	js     800f96 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	6a 01                	push   $0x1
  800f8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8e:	e8 59 ff ff ff       	call   800eec <fd_close>
  800f93:	83 c4 10             	add    $0x10,%esp
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    

00800f98 <close_all>:

void
close_all(void)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	53                   	push   %ebx
  800fa8:	e8 c0 ff ff ff       	call   800f6d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fad:	83 c3 01             	add    $0x1,%ebx
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	83 fb 20             	cmp    $0x20,%ebx
  800fb6:	75 ec                	jne    800fa4 <close_all+0xc>
		close(i);
}
  800fb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	57                   	push   %edi
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	83 ec 2c             	sub    $0x2c,%esp
  800fc6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fcc:	50                   	push   %eax
  800fcd:	ff 75 08             	pushl  0x8(%ebp)
  800fd0:	e8 6e fe ff ff       	call   800e43 <fd_lookup>
  800fd5:	83 c4 08             	add    $0x8,%esp
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	0f 88 c1 00 00 00    	js     8010a1 <dup+0xe4>
		return r;
	close(newfdnum);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	56                   	push   %esi
  800fe4:	e8 84 ff ff ff       	call   800f6d <close>

	newfd = INDEX2FD(newfdnum);
  800fe9:	89 f3                	mov    %esi,%ebx
  800feb:	c1 e3 0c             	shl    $0xc,%ebx
  800fee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff4:	83 c4 04             	add    $0x4,%esp
  800ff7:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ffa:	e8 de fd ff ff       	call   800ddd <fd2data>
  800fff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801001:	89 1c 24             	mov    %ebx,(%esp)
  801004:	e8 d4 fd ff ff       	call   800ddd <fd2data>
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100f:	89 f8                	mov    %edi,%eax
  801011:	c1 e8 16             	shr    $0x16,%eax
  801014:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80101b:	a8 01                	test   $0x1,%al
  80101d:	74 37                	je     801056 <dup+0x99>
  80101f:	89 f8                	mov    %edi,%eax
  801021:	c1 e8 0c             	shr    $0xc,%eax
  801024:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80102b:	f6 c2 01             	test   $0x1,%dl
  80102e:	74 26                	je     801056 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801030:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801037:	83 ec 0c             	sub    $0xc,%esp
  80103a:	25 07 0e 00 00       	and    $0xe07,%eax
  80103f:	50                   	push   %eax
  801040:	ff 75 d4             	pushl  -0x2c(%ebp)
  801043:	6a 00                	push   $0x0
  801045:	57                   	push   %edi
  801046:	6a 00                	push   $0x0
  801048:	e8 b3 fb ff ff       	call   800c00 <sys_page_map>
  80104d:	89 c7                	mov    %eax,%edi
  80104f:	83 c4 20             	add    $0x20,%esp
  801052:	85 c0                	test   %eax,%eax
  801054:	78 2e                	js     801084 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801056:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801059:	89 d0                	mov    %edx,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
  80105e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	25 07 0e 00 00       	and    $0xe07,%eax
  80106d:	50                   	push   %eax
  80106e:	53                   	push   %ebx
  80106f:	6a 00                	push   $0x0
  801071:	52                   	push   %edx
  801072:	6a 00                	push   $0x0
  801074:	e8 87 fb ff ff       	call   800c00 <sys_page_map>
  801079:	89 c7                	mov    %eax,%edi
  80107b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80107e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801080:	85 ff                	test   %edi,%edi
  801082:	79 1d                	jns    8010a1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801084:	83 ec 08             	sub    $0x8,%esp
  801087:	53                   	push   %ebx
  801088:	6a 00                	push   $0x0
  80108a:	e8 b3 fb ff ff       	call   800c42 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80108f:	83 c4 08             	add    $0x8,%esp
  801092:	ff 75 d4             	pushl  -0x2c(%ebp)
  801095:	6a 00                	push   $0x0
  801097:	e8 a6 fb ff ff       	call   800c42 <sys_page_unmap>
	return r;
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	89 f8                	mov    %edi,%eax
}
  8010a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5e                   	pop    %esi
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 14             	sub    $0x14,%esp
  8010b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b6:	50                   	push   %eax
  8010b7:	53                   	push   %ebx
  8010b8:	e8 86 fd ff ff       	call   800e43 <fd_lookup>
  8010bd:	83 c4 08             	add    $0x8,%esp
  8010c0:	89 c2                	mov    %eax,%edx
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 6d                	js     801133 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c6:	83 ec 08             	sub    $0x8,%esp
  8010c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010cc:	50                   	push   %eax
  8010cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d0:	ff 30                	pushl  (%eax)
  8010d2:	e8 c2 fd ff ff       	call   800e99 <dev_lookup>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 4c                	js     80112a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010e1:	8b 42 08             	mov    0x8(%edx),%eax
  8010e4:	83 e0 03             	and    $0x3,%eax
  8010e7:	83 f8 01             	cmp    $0x1,%eax
  8010ea:	75 21                	jne    80110d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ec:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8010f1:	8b 40 48             	mov    0x48(%eax),%eax
  8010f4:	83 ec 04             	sub    $0x4,%esp
  8010f7:	53                   	push   %ebx
  8010f8:	50                   	push   %eax
  8010f9:	68 50 27 80 00       	push   $0x802750
  8010fe:	e8 12 f1 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80110b:	eb 26                	jmp    801133 <read+0x8a>
	}
	if (!dev->dev_read)
  80110d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801110:	8b 40 08             	mov    0x8(%eax),%eax
  801113:	85 c0                	test   %eax,%eax
  801115:	74 17                	je     80112e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801117:	83 ec 04             	sub    $0x4,%esp
  80111a:	ff 75 10             	pushl  0x10(%ebp)
  80111d:	ff 75 0c             	pushl  0xc(%ebp)
  801120:	52                   	push   %edx
  801121:	ff d0                	call   *%eax
  801123:	89 c2                	mov    %eax,%edx
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	eb 09                	jmp    801133 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	eb 05                	jmp    801133 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80112e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801133:	89 d0                	mov    %edx,%eax
  801135:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801138:	c9                   	leave  
  801139:	c3                   	ret    

0080113a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
  801140:	83 ec 0c             	sub    $0xc,%esp
  801143:	8b 7d 08             	mov    0x8(%ebp),%edi
  801146:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801149:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114e:	eb 21                	jmp    801171 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801150:	83 ec 04             	sub    $0x4,%esp
  801153:	89 f0                	mov    %esi,%eax
  801155:	29 d8                	sub    %ebx,%eax
  801157:	50                   	push   %eax
  801158:	89 d8                	mov    %ebx,%eax
  80115a:	03 45 0c             	add    0xc(%ebp),%eax
  80115d:	50                   	push   %eax
  80115e:	57                   	push   %edi
  80115f:	e8 45 ff ff ff       	call   8010a9 <read>
		if (m < 0)
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	85 c0                	test   %eax,%eax
  801169:	78 10                	js     80117b <readn+0x41>
			return m;
		if (m == 0)
  80116b:	85 c0                	test   %eax,%eax
  80116d:	74 0a                	je     801179 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116f:	01 c3                	add    %eax,%ebx
  801171:	39 f3                	cmp    %esi,%ebx
  801173:	72 db                	jb     801150 <readn+0x16>
  801175:	89 d8                	mov    %ebx,%eax
  801177:	eb 02                	jmp    80117b <readn+0x41>
  801179:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80117b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    

00801183 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	53                   	push   %ebx
  801187:	83 ec 14             	sub    $0x14,%esp
  80118a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801190:	50                   	push   %eax
  801191:	53                   	push   %ebx
  801192:	e8 ac fc ff ff       	call   800e43 <fd_lookup>
  801197:	83 c4 08             	add    $0x8,%esp
  80119a:	89 c2                	mov    %eax,%edx
  80119c:	85 c0                	test   %eax,%eax
  80119e:	78 68                	js     801208 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a0:	83 ec 08             	sub    $0x8,%esp
  8011a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a6:	50                   	push   %eax
  8011a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011aa:	ff 30                	pushl  (%eax)
  8011ac:	e8 e8 fc ff ff       	call   800e99 <dev_lookup>
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 47                	js     8011ff <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bf:	75 21                	jne    8011e2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011c1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8011c6:	8b 40 48             	mov    0x48(%eax),%eax
  8011c9:	83 ec 04             	sub    $0x4,%esp
  8011cc:	53                   	push   %ebx
  8011cd:	50                   	push   %eax
  8011ce:	68 6c 27 80 00       	push   $0x80276c
  8011d3:	e8 3d f0 ff ff       	call   800215 <cprintf>
		return -E_INVAL;
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e0:	eb 26                	jmp    801208 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e8:	85 d2                	test   %edx,%edx
  8011ea:	74 17                	je     801203 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	ff 75 10             	pushl  0x10(%ebp)
  8011f2:	ff 75 0c             	pushl  0xc(%ebp)
  8011f5:	50                   	push   %eax
  8011f6:	ff d2                	call   *%edx
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	eb 09                	jmp    801208 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	eb 05                	jmp    801208 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801203:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801208:	89 d0                	mov    %edx,%eax
  80120a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <seek>:

int
seek(int fdnum, off_t offset)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801215:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	ff 75 08             	pushl  0x8(%ebp)
  80121c:	e8 22 fc ff ff       	call   800e43 <fd_lookup>
  801221:	83 c4 08             	add    $0x8,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 0e                	js     801236 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801228:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80122b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801231:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801236:	c9                   	leave  
  801237:	c3                   	ret    

00801238 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 14             	sub    $0x14,%esp
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801242:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	53                   	push   %ebx
  801247:	e8 f7 fb ff ff       	call   800e43 <fd_lookup>
  80124c:	83 c4 08             	add    $0x8,%esp
  80124f:	89 c2                	mov    %eax,%edx
  801251:	85 c0                	test   %eax,%eax
  801253:	78 65                	js     8012ba <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125f:	ff 30                	pushl  (%eax)
  801261:	e8 33 fc ff ff       	call   800e99 <dev_lookup>
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 44                	js     8012b1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801274:	75 21                	jne    801297 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801276:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	53                   	push   %ebx
  801282:	50                   	push   %eax
  801283:	68 2c 27 80 00       	push   $0x80272c
  801288:	e8 88 ef ff ff       	call   800215 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801295:	eb 23                	jmp    8012ba <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801297:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129a:	8b 52 18             	mov    0x18(%edx),%edx
  80129d:	85 d2                	test   %edx,%edx
  80129f:	74 14                	je     8012b5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	ff d2                	call   *%edx
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	eb 09                	jmp    8012ba <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	eb 05                	jmp    8012ba <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012ba:	89 d0                	mov    %edx,%eax
  8012bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 14             	sub    $0x14,%esp
  8012c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ce:	50                   	push   %eax
  8012cf:	ff 75 08             	pushl  0x8(%ebp)
  8012d2:	e8 6c fb ff ff       	call   800e43 <fd_lookup>
  8012d7:	83 c4 08             	add    $0x8,%esp
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	78 58                	js     801338 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e6:	50                   	push   %eax
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	ff 30                	pushl  (%eax)
  8012ec:	e8 a8 fb ff ff       	call   800e99 <dev_lookup>
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 37                	js     80132f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ff:	74 32                	je     801333 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801301:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801304:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80130b:	00 00 00 
	stat->st_isdir = 0;
  80130e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801315:	00 00 00 
	stat->st_dev = dev;
  801318:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	53                   	push   %ebx
  801322:	ff 75 f0             	pushl  -0x10(%ebp)
  801325:	ff 50 14             	call   *0x14(%eax)
  801328:	89 c2                	mov    %eax,%edx
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	eb 09                	jmp    801338 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132f:	89 c2                	mov    %eax,%edx
  801331:	eb 05                	jmp    801338 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801333:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801338:	89 d0                	mov    %edx,%eax
  80133a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133d:	c9                   	leave  
  80133e:	c3                   	ret    

0080133f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	6a 00                	push   $0x0
  801349:	ff 75 08             	pushl  0x8(%ebp)
  80134c:	e8 ef 01 00 00       	call   801540 <open>
  801351:	89 c3                	mov    %eax,%ebx
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 1b                	js     801375 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	ff 75 0c             	pushl  0xc(%ebp)
  801360:	50                   	push   %eax
  801361:	e8 5b ff ff ff       	call   8012c1 <fstat>
  801366:	89 c6                	mov    %eax,%esi
	close(fd);
  801368:	89 1c 24             	mov    %ebx,(%esp)
  80136b:	e8 fd fb ff ff       	call   800f6d <close>
	return r;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	89 f0                	mov    %esi,%eax
}
  801375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	56                   	push   %esi
  801380:	53                   	push   %ebx
  801381:	89 c6                	mov    %eax,%esi
  801383:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801385:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80138c:	75 12                	jne    8013a0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	6a 01                	push   $0x1
  801393:	e8 57 0c 00 00       	call   801fef <ipc_find_env>
  801398:	a3 00 40 80 00       	mov    %eax,0x804000
  80139d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a0:	6a 07                	push   $0x7
  8013a2:	68 00 50 c0 00       	push   $0xc05000
  8013a7:	56                   	push   %esi
  8013a8:	ff 35 00 40 80 00    	pushl  0x804000
  8013ae:	e8 ed 0b 00 00       	call   801fa0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b3:	83 c4 0c             	add    $0xc,%esp
  8013b6:	6a 00                	push   $0x0
  8013b8:	53                   	push   %ebx
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 6a 0b 00 00       	call   801f2a <ipc_recv>
}
  8013c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d3:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8013d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013db:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8013ea:	e8 8d ff ff ff       	call   80137c <fsipc>
}
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fd:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 06 00 00 00       	mov    $0x6,%eax
  80140c:	e8 6b ff ff ff       	call   80137c <fsipc>
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	53                   	push   %ebx
  801417:	83 ec 04             	sub    $0x4,%esp
  80141a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80141d:	8b 45 08             	mov    0x8(%ebp),%eax
  801420:	8b 40 0c             	mov    0xc(%eax),%eax
  801423:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801428:	ba 00 00 00 00       	mov    $0x0,%edx
  80142d:	b8 05 00 00 00       	mov    $0x5,%eax
  801432:	e8 45 ff ff ff       	call   80137c <fsipc>
  801437:	85 c0                	test   %eax,%eax
  801439:	78 2c                	js     801467 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	68 00 50 c0 00       	push   $0xc05000
  801443:	53                   	push   %ebx
  801444:	e8 71 f3 ff ff       	call   8007ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801449:	a1 80 50 c0 00       	mov    0xc05080,%eax
  80144e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801454:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801459:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146a:	c9                   	leave  
  80146b:	c3                   	ret    

0080146c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	53                   	push   %ebx
  801470:	83 ec 08             	sub    $0x8,%esp
  801473:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801476:	8b 55 08             	mov    0x8(%ebp),%edx
  801479:	8b 52 0c             	mov    0xc(%edx),%edx
  80147c:	89 15 00 50 c0 00    	mov    %edx,0xc05000
	fsipcbuf.write.req_n = n;
  801482:	a3 04 50 c0 00       	mov    %eax,0xc05004
  801487:	3d 08 50 c0 00       	cmp    $0xc05008,%eax
  80148c:	bb 08 50 c0 00       	mov    $0xc05008,%ebx
  801491:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801494:	53                   	push   %ebx
  801495:	ff 75 0c             	pushl  0xc(%ebp)
  801498:	68 08 50 c0 00       	push   $0xc05008
  80149d:	e8 aa f4 ff ff       	call   80094c <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ac:	e8 cb fe ff ff       	call   80137c <fsipc>
  8014b1:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8014b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014bc:	c9                   	leave  
  8014bd:	c3                   	ret    

008014be <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014be:	55                   	push   %ebp
  8014bf:	89 e5                	mov    %esp,%ebp
  8014c1:	56                   	push   %esi
  8014c2:	53                   	push   %ebx
  8014c3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014cc:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.read.req_n = n;
  8014d1:	89 35 04 50 c0 00    	mov    %esi,0xc05004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8014e1:	e8 96 fe ff ff       	call   80137c <fsipc>
  8014e6:	89 c3                	mov    %eax,%ebx
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 4b                	js     801537 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014ec:	39 c6                	cmp    %eax,%esi
  8014ee:	73 16                	jae    801506 <devfile_read+0x48>
  8014f0:	68 a0 27 80 00       	push   $0x8027a0
  8014f5:	68 a7 27 80 00       	push   $0x8027a7
  8014fa:	6a 7c                	push   $0x7c
  8014fc:	68 bc 27 80 00       	push   $0x8027bc
  801501:	e8 36 ec ff ff       	call   80013c <_panic>
	assert(r <= PGSIZE);
  801506:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150b:	7e 16                	jle    801523 <devfile_read+0x65>
  80150d:	68 c7 27 80 00       	push   $0x8027c7
  801512:	68 a7 27 80 00       	push   $0x8027a7
  801517:	6a 7d                	push   $0x7d
  801519:	68 bc 27 80 00       	push   $0x8027bc
  80151e:	e8 19 ec ff ff       	call   80013c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801523:	83 ec 04             	sub    $0x4,%esp
  801526:	50                   	push   %eax
  801527:	68 00 50 c0 00       	push   $0xc05000
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	e8 18 f4 ff ff       	call   80094c <memmove>
	return r;
  801534:	83 c4 10             	add    $0x10,%esp
}
  801537:	89 d8                	mov    %ebx,%eax
  801539:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153c:	5b                   	pop    %ebx
  80153d:	5e                   	pop    %esi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	53                   	push   %ebx
  801544:	83 ec 20             	sub    $0x20,%esp
  801547:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80154a:	53                   	push   %ebx
  80154b:	e8 31 f2 ff ff       	call   800781 <strlen>
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801558:	7f 67                	jg     8015c1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	e8 8e f8 ff ff       	call   800df4 <fd_alloc>
  801566:	83 c4 10             	add    $0x10,%esp
		return r;
  801569:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80156b:	85 c0                	test   %eax,%eax
  80156d:	78 57                	js     8015c6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80156f:	83 ec 08             	sub    $0x8,%esp
  801572:	53                   	push   %ebx
  801573:	68 00 50 c0 00       	push   $0xc05000
  801578:	e8 3d f2 ff ff       	call   8007ba <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801580:	a3 00 54 c0 00       	mov    %eax,0xc05400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801585:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801588:	b8 01 00 00 00       	mov    $0x1,%eax
  80158d:	e8 ea fd ff ff       	call   80137c <fsipc>
  801592:	89 c3                	mov    %eax,%ebx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	79 14                	jns    8015af <open+0x6f>
		fd_close(fd, 0);
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	6a 00                	push   $0x0
  8015a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a3:	e8 44 f9 ff ff       	call   800eec <fd_close>
		return r;
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	89 da                	mov    %ebx,%edx
  8015ad:	eb 17                	jmp    8015c6 <open+0x86>
	}

	return fd2num(fd);
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b5:	e8 13 f8 ff ff       	call   800dcd <fd2num>
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	eb 05                	jmp    8015c6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015c1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c6:	89 d0                	mov    %edx,%eax
  8015c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d8:	b8 08 00 00 00       	mov    $0x8,%eax
  8015dd:	e8 9a fd ff ff       	call   80137c <fsipc>
}
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    

008015e4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	56                   	push   %esi
  8015e8:	53                   	push   %ebx
  8015e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015ec:	83 ec 0c             	sub    $0xc,%esp
  8015ef:	ff 75 08             	pushl  0x8(%ebp)
  8015f2:	e8 e6 f7 ff ff       	call   800ddd <fd2data>
  8015f7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015f9:	83 c4 08             	add    $0x8,%esp
  8015fc:	68 d3 27 80 00       	push   $0x8027d3
  801601:	53                   	push   %ebx
  801602:	e8 b3 f1 ff ff       	call   8007ba <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801607:	8b 46 04             	mov    0x4(%esi),%eax
  80160a:	2b 06                	sub    (%esi),%eax
  80160c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801612:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801619:	00 00 00 
	stat->st_dev = &devpipe;
  80161c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801623:	30 80 00 
	return 0;
}
  801626:	b8 00 00 00 00       	mov    $0x0,%eax
  80162b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	53                   	push   %ebx
  801636:	83 ec 0c             	sub    $0xc,%esp
  801639:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80163c:	53                   	push   %ebx
  80163d:	6a 00                	push   $0x0
  80163f:	e8 fe f5 ff ff       	call   800c42 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801644:	89 1c 24             	mov    %ebx,(%esp)
  801647:	e8 91 f7 ff ff       	call   800ddd <fd2data>
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	50                   	push   %eax
  801650:	6a 00                	push   $0x0
  801652:	e8 eb f5 ff ff       	call   800c42 <sys_page_unmap>
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	57                   	push   %edi
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	83 ec 1c             	sub    $0x1c,%esp
  801665:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801668:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80166a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80166f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	ff 75 e0             	pushl  -0x20(%ebp)
  801678:	e8 ab 09 00 00       	call   802028 <pageref>
  80167d:	89 c3                	mov    %eax,%ebx
  80167f:	89 3c 24             	mov    %edi,(%esp)
  801682:	e8 a1 09 00 00       	call   802028 <pageref>
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	39 c3                	cmp    %eax,%ebx
  80168c:	0f 94 c1             	sete   %cl
  80168f:	0f b6 c9             	movzbl %cl,%ecx
  801692:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801695:	8b 15 20 40 c0 00    	mov    0xc04020,%edx
  80169b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80169e:	39 ce                	cmp    %ecx,%esi
  8016a0:	74 1b                	je     8016bd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016a2:	39 c3                	cmp    %eax,%ebx
  8016a4:	75 c4                	jne    80166a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016a6:	8b 42 58             	mov    0x58(%edx),%eax
  8016a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016ac:	50                   	push   %eax
  8016ad:	56                   	push   %esi
  8016ae:	68 da 27 80 00       	push   $0x8027da
  8016b3:	e8 5d eb ff ff       	call   800215 <cprintf>
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb ad                	jmp    80166a <_pipeisclosed+0xe>
	}
}
  8016bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5f                   	pop    %edi
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	57                   	push   %edi
  8016cc:	56                   	push   %esi
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 28             	sub    $0x28,%esp
  8016d1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016d4:	56                   	push   %esi
  8016d5:	e8 03 f7 ff ff       	call   800ddd <fd2data>
  8016da:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e4:	eb 4b                	jmp    801731 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016e6:	89 da                	mov    %ebx,%edx
  8016e8:	89 f0                	mov    %esi,%eax
  8016ea:	e8 6d ff ff ff       	call   80165c <_pipeisclosed>
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	75 48                	jne    80173b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016f3:	e8 a6 f4 ff ff       	call   800b9e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8016fb:	8b 0b                	mov    (%ebx),%ecx
  8016fd:	8d 51 20             	lea    0x20(%ecx),%edx
  801700:	39 d0                	cmp    %edx,%eax
  801702:	73 e2                	jae    8016e6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801707:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80170b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80170e:	89 c2                	mov    %eax,%edx
  801710:	c1 fa 1f             	sar    $0x1f,%edx
  801713:	89 d1                	mov    %edx,%ecx
  801715:	c1 e9 1b             	shr    $0x1b,%ecx
  801718:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80171b:	83 e2 1f             	and    $0x1f,%edx
  80171e:	29 ca                	sub    %ecx,%edx
  801720:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801724:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801728:	83 c0 01             	add    $0x1,%eax
  80172b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172e:	83 c7 01             	add    $0x1,%edi
  801731:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801734:	75 c2                	jne    8016f8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801736:	8b 45 10             	mov    0x10(%ebp),%eax
  801739:	eb 05                	jmp    801740 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80173b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801743:	5b                   	pop    %ebx
  801744:	5e                   	pop    %esi
  801745:	5f                   	pop    %edi
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    

00801748 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	57                   	push   %edi
  80174c:	56                   	push   %esi
  80174d:	53                   	push   %ebx
  80174e:	83 ec 18             	sub    $0x18,%esp
  801751:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801754:	57                   	push   %edi
  801755:	e8 83 f6 ff ff       	call   800ddd <fd2data>
  80175a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801764:	eb 3d                	jmp    8017a3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801766:	85 db                	test   %ebx,%ebx
  801768:	74 04                	je     80176e <devpipe_read+0x26>
				return i;
  80176a:	89 d8                	mov    %ebx,%eax
  80176c:	eb 44                	jmp    8017b2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80176e:	89 f2                	mov    %esi,%edx
  801770:	89 f8                	mov    %edi,%eax
  801772:	e8 e5 fe ff ff       	call   80165c <_pipeisclosed>
  801777:	85 c0                	test   %eax,%eax
  801779:	75 32                	jne    8017ad <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80177b:	e8 1e f4 ff ff       	call   800b9e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801780:	8b 06                	mov    (%esi),%eax
  801782:	3b 46 04             	cmp    0x4(%esi),%eax
  801785:	74 df                	je     801766 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801787:	99                   	cltd   
  801788:	c1 ea 1b             	shr    $0x1b,%edx
  80178b:	01 d0                	add    %edx,%eax
  80178d:	83 e0 1f             	and    $0x1f,%eax
  801790:	29 d0                	sub    %edx,%eax
  801792:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80179d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a0:	83 c3 01             	add    $0x1,%ebx
  8017a3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017a6:	75 d8                	jne    801780 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ab:	eb 05                	jmp    8017b2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b5:	5b                   	pop    %ebx
  8017b6:	5e                   	pop    %esi
  8017b7:	5f                   	pop    %edi
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	50                   	push   %eax
  8017c6:	e8 29 f6 ff ff       	call   800df4 <fd_alloc>
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	89 c2                	mov    %eax,%edx
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	0f 88 2c 01 00 00    	js     801904 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d8:	83 ec 04             	sub    $0x4,%esp
  8017db:	68 07 04 00 00       	push   $0x407
  8017e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e3:	6a 00                	push   $0x0
  8017e5:	e8 d3 f3 ff ff       	call   800bbd <sys_page_alloc>
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	89 c2                	mov    %eax,%edx
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	0f 88 0d 01 00 00    	js     801904 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017f7:	83 ec 0c             	sub    $0xc,%esp
  8017fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fd:	50                   	push   %eax
  8017fe:	e8 f1 f5 ff ff       	call   800df4 <fd_alloc>
  801803:	89 c3                	mov    %eax,%ebx
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	85 c0                	test   %eax,%eax
  80180a:	0f 88 e2 00 00 00    	js     8018f2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801810:	83 ec 04             	sub    $0x4,%esp
  801813:	68 07 04 00 00       	push   $0x407
  801818:	ff 75 f0             	pushl  -0x10(%ebp)
  80181b:	6a 00                	push   $0x0
  80181d:	e8 9b f3 ff ff       	call   800bbd <sys_page_alloc>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	85 c0                	test   %eax,%eax
  801829:	0f 88 c3 00 00 00    	js     8018f2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	ff 75 f4             	pushl  -0xc(%ebp)
  801835:	e8 a3 f5 ff ff       	call   800ddd <fd2data>
  80183a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80183c:	83 c4 0c             	add    $0xc,%esp
  80183f:	68 07 04 00 00       	push   $0x407
  801844:	50                   	push   %eax
  801845:	6a 00                	push   $0x0
  801847:	e8 71 f3 ff ff       	call   800bbd <sys_page_alloc>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	0f 88 89 00 00 00    	js     8018e2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801859:	83 ec 0c             	sub    $0xc,%esp
  80185c:	ff 75 f0             	pushl  -0x10(%ebp)
  80185f:	e8 79 f5 ff ff       	call   800ddd <fd2data>
  801864:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80186b:	50                   	push   %eax
  80186c:	6a 00                	push   $0x0
  80186e:	56                   	push   %esi
  80186f:	6a 00                	push   $0x0
  801871:	e8 8a f3 ff ff       	call   800c00 <sys_page_map>
  801876:	89 c3                	mov    %eax,%ebx
  801878:	83 c4 20             	add    $0x20,%esp
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 55                	js     8018d4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80187f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801888:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80188a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801894:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80189f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8018af:	e8 19 f5 ff ff       	call   800dcd <fd2num>
  8018b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018b9:	83 c4 04             	add    $0x4,%esp
  8018bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bf:	e8 09 f5 ff ff       	call   800dcd <fd2num>
  8018c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018ca:	83 c4 10             	add    $0x10,%esp
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	eb 30                	jmp    801904 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	56                   	push   %esi
  8018d8:	6a 00                	push   $0x0
  8018da:	e8 63 f3 ff ff       	call   800c42 <sys_page_unmap>
  8018df:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e8:	6a 00                	push   $0x0
  8018ea:	e8 53 f3 ff ff       	call   800c42 <sys_page_unmap>
  8018ef:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f8:	6a 00                	push   $0x0
  8018fa:	e8 43 f3 ff ff       	call   800c42 <sys_page_unmap>
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801904:	89 d0                	mov    %edx,%eax
  801906:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801909:	5b                   	pop    %ebx
  80190a:	5e                   	pop    %esi
  80190b:	5d                   	pop    %ebp
  80190c:	c3                   	ret    

0080190d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801916:	50                   	push   %eax
  801917:	ff 75 08             	pushl  0x8(%ebp)
  80191a:	e8 24 f5 ff ff       	call   800e43 <fd_lookup>
  80191f:	83 c4 10             	add    $0x10,%esp
  801922:	85 c0                	test   %eax,%eax
  801924:	78 18                	js     80193e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	e8 ac f4 ff ff       	call   800ddd <fd2data>
	return _pipeisclosed(fd, p);
  801931:	89 c2                	mov    %eax,%edx
  801933:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801936:	e8 21 fd ff ff       	call   80165c <_pipeisclosed>
  80193b:	83 c4 10             	add    $0x10,%esp
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801946:	68 f2 27 80 00       	push   $0x8027f2
  80194b:	ff 75 0c             	pushl  0xc(%ebp)
  80194e:	e8 67 ee ff ff       	call   8007ba <strcpy>
	return 0;
}
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	83 ec 10             	sub    $0x10,%esp
  801961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801964:	53                   	push   %ebx
  801965:	e8 be 06 00 00       	call   802028 <pageref>
  80196a:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801972:	83 f8 01             	cmp    $0x1,%eax
  801975:	75 10                	jne    801987 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801977:	83 ec 0c             	sub    $0xc,%esp
  80197a:	ff 73 0c             	pushl  0xc(%ebx)
  80197d:	e8 c0 02 00 00       	call   801c42 <nsipc_close>
  801982:	89 c2                	mov    %eax,%edx
  801984:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801987:	89 d0                	mov    %edx,%eax
  801989:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198c:	c9                   	leave  
  80198d:	c3                   	ret    

0080198e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801994:	6a 00                	push   $0x0
  801996:	ff 75 10             	pushl  0x10(%ebp)
  801999:	ff 75 0c             	pushl  0xc(%ebp)
  80199c:	8b 45 08             	mov    0x8(%ebp),%eax
  80199f:	ff 70 0c             	pushl  0xc(%eax)
  8019a2:	e8 78 03 00 00       	call   801d1f <nsipc_send>
}
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019af:	6a 00                	push   $0x0
  8019b1:	ff 75 10             	pushl  0x10(%ebp)
  8019b4:	ff 75 0c             	pushl  0xc(%ebp)
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	ff 70 0c             	pushl  0xc(%eax)
  8019bd:	e8 f1 02 00 00       	call   801cb3 <nsipc_recv>
}
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019ca:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019cd:	52                   	push   %edx
  8019ce:	50                   	push   %eax
  8019cf:	e8 6f f4 ff ff       	call   800e43 <fd_lookup>
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 17                	js     8019f2 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  8019e4:	39 08                	cmp    %ecx,(%eax)
  8019e6:	75 05                	jne    8019ed <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8019eb:	eb 05                	jmp    8019f2 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
  8019f9:	83 ec 1c             	sub    $0x1c,%esp
  8019fc:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a01:	50                   	push   %eax
  801a02:	e8 ed f3 ff ff       	call   800df4 <fd_alloc>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	83 c4 10             	add    $0x10,%esp
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 1b                	js     801a2b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	68 07 04 00 00       	push   $0x407
  801a18:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 9b f1 ff ff       	call   800bbd <sys_page_alloc>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	79 10                	jns    801a3b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	56                   	push   %esi
  801a2f:	e8 0e 02 00 00       	call   801c42 <nsipc_close>
		return r;
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	89 d8                	mov    %ebx,%eax
  801a39:	eb 24                	jmp    801a5f <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a3b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a44:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a49:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a50:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	50                   	push   %eax
  801a57:	e8 71 f3 ff ff       	call   800dcd <fd2num>
  801a5c:	83 c4 10             	add    $0x10,%esp
}
  801a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a62:	5b                   	pop    %ebx
  801a63:	5e                   	pop    %esi
  801a64:	5d                   	pop    %ebp
  801a65:	c3                   	ret    

00801a66 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6f:	e8 50 ff ff ff       	call   8019c4 <fd2sockid>
		return r;
  801a74:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 1f                	js     801a99 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	ff 75 10             	pushl  0x10(%ebp)
  801a80:	ff 75 0c             	pushl  0xc(%ebp)
  801a83:	50                   	push   %eax
  801a84:	e8 12 01 00 00       	call   801b9b <nsipc_accept>
  801a89:	83 c4 10             	add    $0x10,%esp
		return r;
  801a8c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 07                	js     801a99 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801a92:	e8 5d ff ff ff       	call   8019f4 <alloc_sockfd>
  801a97:	89 c1                	mov    %eax,%ecx
}
  801a99:	89 c8                	mov    %ecx,%eax
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	e8 19 ff ff ff       	call   8019c4 <fd2sockid>
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 12                	js     801ac1 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801aaf:	83 ec 04             	sub    $0x4,%esp
  801ab2:	ff 75 10             	pushl  0x10(%ebp)
  801ab5:	ff 75 0c             	pushl  0xc(%ebp)
  801ab8:	50                   	push   %eax
  801ab9:	e8 2d 01 00 00       	call   801beb <nsipc_bind>
  801abe:	83 c4 10             	add    $0x10,%esp
}
  801ac1:	c9                   	leave  
  801ac2:	c3                   	ret    

00801ac3 <shutdown>:

int
shutdown(int s, int how)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	e8 f3 fe ff ff       	call   8019c4 <fd2sockid>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 0f                	js     801ae4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ad5:	83 ec 08             	sub    $0x8,%esp
  801ad8:	ff 75 0c             	pushl  0xc(%ebp)
  801adb:	50                   	push   %eax
  801adc:	e8 3f 01 00 00       	call   801c20 <nsipc_shutdown>
  801ae1:	83 c4 10             	add    $0x10,%esp
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	e8 d0 fe ff ff       	call   8019c4 <fd2sockid>
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 12                	js     801b0a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	ff 75 10             	pushl  0x10(%ebp)
  801afe:	ff 75 0c             	pushl  0xc(%ebp)
  801b01:	50                   	push   %eax
  801b02:	e8 55 01 00 00       	call   801c5c <nsipc_connect>
  801b07:	83 c4 10             	add    $0x10,%esp
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <listen>:

int
listen(int s, int backlog)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	e8 aa fe ff ff       	call   8019c4 <fd2sockid>
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 0f                	js     801b2d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	ff 75 0c             	pushl  0xc(%ebp)
  801b24:	50                   	push   %eax
  801b25:	e8 67 01 00 00       	call   801c91 <nsipc_listen>
  801b2a:	83 c4 10             	add    $0x10,%esp
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b35:	ff 75 10             	pushl  0x10(%ebp)
  801b38:	ff 75 0c             	pushl  0xc(%ebp)
  801b3b:	ff 75 08             	pushl  0x8(%ebp)
  801b3e:	e8 3a 02 00 00       	call   801d7d <nsipc_socket>
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 05                	js     801b4f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b4a:	e8 a5 fe ff ff       	call   8019f4 <alloc_sockfd>
}
  801b4f:	c9                   	leave  
  801b50:	c3                   	ret    

00801b51 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	53                   	push   %ebx
  801b55:	83 ec 04             	sub    $0x4,%esp
  801b58:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b5a:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801b61:	75 12                	jne    801b75 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b63:	83 ec 0c             	sub    $0xc,%esp
  801b66:	6a 02                	push   $0x2
  801b68:	e8 82 04 00 00       	call   801fef <ipc_find_env>
  801b6d:	a3 04 40 80 00       	mov    %eax,0x804004
  801b72:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b75:	6a 07                	push   $0x7
  801b77:	68 00 60 c0 00       	push   $0xc06000
  801b7c:	53                   	push   %ebx
  801b7d:	ff 35 04 40 80 00    	pushl  0x804004
  801b83:	e8 18 04 00 00       	call   801fa0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b88:	83 c4 0c             	add    $0xc,%esp
  801b8b:	6a 00                	push   $0x0
  801b8d:	6a 00                	push   $0x0
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 94 03 00 00       	call   801f2a <ipc_recv>
}
  801b96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bab:	8b 06                	mov    (%esi),%eax
  801bad:	a3 04 60 c0 00       	mov    %eax,0xc06004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb7:	e8 95 ff ff ff       	call   801b51 <nsipc>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 20                	js     801be2 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801bc2:	83 ec 04             	sub    $0x4,%esp
  801bc5:	ff 35 10 60 c0 00    	pushl  0xc06010
  801bcb:	68 00 60 c0 00       	push   $0xc06000
  801bd0:	ff 75 0c             	pushl  0xc(%ebp)
  801bd3:	e8 74 ed ff ff       	call   80094c <memmove>
		*addrlen = ret->ret_addrlen;
  801bd8:	a1 10 60 c0 00       	mov    0xc06010,%eax
  801bdd:	89 06                	mov    %eax,(%esi)
  801bdf:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801be2:	89 d8                	mov    %ebx,%eax
  801be4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be7:	5b                   	pop    %ebx
  801be8:	5e                   	pop    %esi
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	53                   	push   %ebx
  801bef:	83 ec 08             	sub    $0x8,%esp
  801bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf8:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bfd:	53                   	push   %ebx
  801bfe:	ff 75 0c             	pushl  0xc(%ebp)
  801c01:	68 04 60 c0 00       	push   $0xc06004
  801c06:	e8 41 ed ff ff       	call   80094c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c0b:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  801c11:	b8 02 00 00 00       	mov    $0x2,%eax
  801c16:	e8 36 ff ff ff       	call   801b51 <nsipc>
}
  801c1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  801c36:	b8 03 00 00 00       	mov    $0x3,%eax
  801c3b:	e8 11 ff ff ff       	call   801b51 <nsipc>
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <nsipc_close>:

int
nsipc_close(int s)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  801c50:	b8 04 00 00 00       	mov    $0x4,%eax
  801c55:	e8 f7 fe ff ff       	call   801b51 <nsipc>
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	53                   	push   %ebx
  801c60:	83 ec 08             	sub    $0x8,%esp
  801c63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c66:	8b 45 08             	mov    0x8(%ebp),%eax
  801c69:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c6e:	53                   	push   %ebx
  801c6f:	ff 75 0c             	pushl  0xc(%ebp)
  801c72:	68 04 60 c0 00       	push   $0xc06004
  801c77:	e8 d0 ec ff ff       	call   80094c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c7c:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801c82:	b8 05 00 00 00       	mov    $0x5,%eax
  801c87:	e8 c5 fe ff ff       	call   801b51 <nsipc>
}
  801c8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8f:	c9                   	leave  
  801c90:	c3                   	ret    

00801c91 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c97:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9a:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  801c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca2:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  801ca7:	b8 06 00 00 00       	mov    $0x6,%eax
  801cac:	e8 a0 fe ff ff       	call   801b51 <nsipc>
}
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbe:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  801cc3:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801cc9:	8b 45 14             	mov    0x14(%ebp),%eax
  801ccc:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801cd1:	b8 07 00 00 00       	mov    $0x7,%eax
  801cd6:	e8 76 fe ff ff       	call   801b51 <nsipc>
  801cdb:	89 c3                	mov    %eax,%ebx
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 35                	js     801d16 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ce1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ce6:	7f 04                	jg     801cec <nsipc_recv+0x39>
  801ce8:	39 c6                	cmp    %eax,%esi
  801cea:	7d 16                	jge    801d02 <nsipc_recv+0x4f>
  801cec:	68 fe 27 80 00       	push   $0x8027fe
  801cf1:	68 a7 27 80 00       	push   $0x8027a7
  801cf6:	6a 62                	push   $0x62
  801cf8:	68 13 28 80 00       	push   $0x802813
  801cfd:	e8 3a e4 ff ff       	call   80013c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d02:	83 ec 04             	sub    $0x4,%esp
  801d05:	50                   	push   %eax
  801d06:	68 00 60 c0 00       	push   $0xc06000
  801d0b:	ff 75 0c             	pushl  0xc(%ebp)
  801d0e:	e8 39 ec ff ff       	call   80094c <memmove>
  801d13:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d16:	89 d8                	mov    %ebx,%eax
  801d18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1b:	5b                   	pop    %ebx
  801d1c:	5e                   	pop    %esi
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    

00801d1f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	53                   	push   %ebx
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801d31:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d37:	7e 16                	jle    801d4f <nsipc_send+0x30>
  801d39:	68 1f 28 80 00       	push   $0x80281f
  801d3e:	68 a7 27 80 00       	push   $0x8027a7
  801d43:	6a 6d                	push   $0x6d
  801d45:	68 13 28 80 00       	push   $0x802813
  801d4a:	e8 ed e3 ff ff       	call   80013c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d4f:	83 ec 04             	sub    $0x4,%esp
  801d52:	53                   	push   %ebx
  801d53:	ff 75 0c             	pushl  0xc(%ebp)
  801d56:	68 0c 60 c0 00       	push   $0xc0600c
  801d5b:	e8 ec eb ff ff       	call   80094c <memmove>
	nsipcbuf.send.req_size = size;
  801d60:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801d66:	8b 45 14             	mov    0x14(%ebp),%eax
  801d69:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801d6e:	b8 08 00 00 00       	mov    $0x8,%eax
  801d73:	e8 d9 fd ff ff       	call   801b51 <nsipc>
}
  801d78:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8e:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801d93:	8b 45 10             	mov    0x10(%ebp),%eax
  801d96:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801d9b:	b8 09 00 00 00       	mov    $0x9,%eax
  801da0:	e8 ac fd ff ff       	call   801b51 <nsipc>
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801db7:	68 2b 28 80 00       	push   $0x80282b
  801dbc:	ff 75 0c             	pushl  0xc(%ebp)
  801dbf:	e8 f6 e9 ff ff       	call   8007ba <strcpy>
	return 0;
}
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	57                   	push   %edi
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ddc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801de2:	eb 2d                	jmp    801e11 <devcons_write+0x46>
		m = n - tot;
  801de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801de7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801de9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dec:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801df1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801df4:	83 ec 04             	sub    $0x4,%esp
  801df7:	53                   	push   %ebx
  801df8:	03 45 0c             	add    0xc(%ebp),%eax
  801dfb:	50                   	push   %eax
  801dfc:	57                   	push   %edi
  801dfd:	e8 4a eb ff ff       	call   80094c <memmove>
		sys_cputs(buf, m);
  801e02:	83 c4 08             	add    $0x8,%esp
  801e05:	53                   	push   %ebx
  801e06:	57                   	push   %edi
  801e07:	e8 f5 ec ff ff       	call   800b01 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e0c:	01 de                	add    %ebx,%esi
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	89 f0                	mov    %esi,%eax
  801e13:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e16:	72 cc                	jb     801de4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e1b:	5b                   	pop    %ebx
  801e1c:	5e                   	pop    %esi
  801e1d:	5f                   	pop    %edi
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e2b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e2f:	74 2a                	je     801e5b <devcons_read+0x3b>
  801e31:	eb 05                	jmp    801e38 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e33:	e8 66 ed ff ff       	call   800b9e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e38:	e8 e2 ec ff ff       	call   800b1f <sys_cgetc>
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	74 f2                	je     801e33 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e41:	85 c0                	test   %eax,%eax
  801e43:	78 16                	js     801e5b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e45:	83 f8 04             	cmp    $0x4,%eax
  801e48:	74 0c                	je     801e56 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4d:	88 02                	mov    %al,(%edx)
	return 1;
  801e4f:	b8 01 00 00 00       	mov    $0x1,%eax
  801e54:	eb 05                	jmp    801e5b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e56:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e69:	6a 01                	push   $0x1
  801e6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e6e:	50                   	push   %eax
  801e6f:	e8 8d ec ff ff       	call   800b01 <sys_cputs>
}
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <getchar>:

int
getchar(void)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e7f:	6a 01                	push   $0x1
  801e81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e84:	50                   	push   %eax
  801e85:	6a 00                	push   $0x0
  801e87:	e8 1d f2 ff ff       	call   8010a9 <read>
	if (r < 0)
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	85 c0                	test   %eax,%eax
  801e91:	78 0f                	js     801ea2 <getchar+0x29>
		return r;
	if (r < 1)
  801e93:	85 c0                	test   %eax,%eax
  801e95:	7e 06                	jle    801e9d <getchar+0x24>
		return -E_EOF;
	return c;
  801e97:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e9b:	eb 05                	jmp    801ea2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e9d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ead:	50                   	push   %eax
  801eae:	ff 75 08             	pushl  0x8(%ebp)
  801eb1:	e8 8d ef ff ff       	call   800e43 <fd_lookup>
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	78 11                	js     801ece <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ec6:	39 10                	cmp    %edx,(%eax)
  801ec8:	0f 94 c0             	sete   %al
  801ecb:	0f b6 c0             	movzbl %al,%eax
}
  801ece:	c9                   	leave  
  801ecf:	c3                   	ret    

00801ed0 <opencons>:

int
opencons(void)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed9:	50                   	push   %eax
  801eda:	e8 15 ef ff ff       	call   800df4 <fd_alloc>
  801edf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ee2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 3e                	js     801f26 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee8:	83 ec 04             	sub    $0x4,%esp
  801eeb:	68 07 04 00 00       	push   $0x407
  801ef0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef3:	6a 00                	push   $0x0
  801ef5:	e8 c3 ec ff ff       	call   800bbd <sys_page_alloc>
  801efa:	83 c4 10             	add    $0x10,%esp
		return r;
  801efd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 23                	js     801f26 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f03:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f11:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	50                   	push   %eax
  801f1c:	e8 ac ee ff ff       	call   800dcd <fd2num>
  801f21:	89 c2                	mov    %eax,%edx
  801f23:	83 c4 10             	add    $0x10,%esp
}
  801f26:	89 d0                	mov    %edx,%eax
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    

00801f2a <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	56                   	push   %esi
  801f2e:	53                   	push   %ebx
  801f2f:	8b 75 08             	mov    0x8(%ebp),%esi
  801f32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	74 0e                	je     801f4a <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801f3c:	83 ec 0c             	sub    $0xc,%esp
  801f3f:	50                   	push   %eax
  801f40:	e8 28 ee ff ff       	call   800d6d <sys_ipc_recv>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	eb 10                	jmp    801f5a <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801f4a:	83 ec 0c             	sub    $0xc,%esp
  801f4d:	68 00 00 c0 ee       	push   $0xeec00000
  801f52:	e8 16 ee ff ff       	call   800d6d <sys_ipc_recv>
  801f57:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	79 17                	jns    801f75 <ipc_recv+0x4b>
		if(*from_env_store)
  801f5e:	83 3e 00             	cmpl   $0x0,(%esi)
  801f61:	74 06                	je     801f69 <ipc_recv+0x3f>
			*from_env_store = 0;
  801f63:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  801f69:	85 db                	test   %ebx,%ebx
  801f6b:	74 2c                	je     801f99 <ipc_recv+0x6f>
			*perm_store = 0;
  801f6d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f73:	eb 24                	jmp    801f99 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  801f75:	85 f6                	test   %esi,%esi
  801f77:	74 0a                	je     801f83 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  801f79:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f7e:	8b 40 74             	mov    0x74(%eax),%eax
  801f81:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  801f83:	85 db                	test   %ebx,%ebx
  801f85:	74 0a                	je     801f91 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  801f87:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f8c:	8b 40 78             	mov    0x78(%eax),%eax
  801f8f:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f91:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801f96:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	57                   	push   %edi
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
  801fa6:	83 ec 0c             	sub    $0xc,%esp
  801fa9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  801fb2:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  801fb4:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  801fb9:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801fbc:	e8 dd eb ff ff       	call   800b9e <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801fc1:	ff 75 14             	pushl  0x14(%ebp)
  801fc4:	53                   	push   %ebx
  801fc5:	56                   	push   %esi
  801fc6:	57                   	push   %edi
  801fc7:	e8 7e ed ff ff       	call   800d4a <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801fcc:	89 c2                	mov    %eax,%edx
  801fce:	f7 d2                	not    %edx
  801fd0:	c1 ea 1f             	shr    $0x1f,%edx
  801fd3:	83 c4 10             	add    $0x10,%esp
  801fd6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fd9:	0f 94 c1             	sete   %cl
  801fdc:	09 ca                	or     %ecx,%edx
  801fde:	85 c0                	test   %eax,%eax
  801fe0:	0f 94 c0             	sete   %al
  801fe3:	38 c2                	cmp    %al,%dl
  801fe5:	77 d5                	ja     801fbc <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  801fe7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fea:	5b                   	pop    %ebx
  801feb:	5e                   	pop    %esi
  801fec:	5f                   	pop    %edi
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    

00801fef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ffa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ffd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802003:	8b 52 50             	mov    0x50(%edx),%edx
  802006:	39 ca                	cmp    %ecx,%edx
  802008:	75 0d                	jne    802017 <ipc_find_env+0x28>
			return envs[i].env_id;
  80200a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80200d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802012:	8b 40 48             	mov    0x48(%eax),%eax
  802015:	eb 0f                	jmp    802026 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802017:	83 c0 01             	add    $0x1,%eax
  80201a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80201f:	75 d9                	jne    801ffa <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802021:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    

00802028 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202e:	89 d0                	mov    %edx,%eax
  802030:	c1 e8 16             	shr    $0x16,%eax
  802033:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80203a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203f:	f6 c1 01             	test   $0x1,%cl
  802042:	74 1d                	je     802061 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802044:	c1 ea 0c             	shr    $0xc,%edx
  802047:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204e:	f6 c2 01             	test   $0x1,%dl
  802051:	74 0e                	je     802061 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802053:	c1 ea 0c             	shr    $0xc,%edx
  802056:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80205d:	ef 
  80205e:	0f b7 c0             	movzwl %ax,%eax
}
  802061:	5d                   	pop    %ebp
  802062:	c3                   	ret    
  802063:	66 90                	xchg   %ax,%ax
  802065:	66 90                	xchg   %ax,%ax
  802067:	66 90                	xchg   %ax,%ax
  802069:	66 90                	xchg   %ax,%ax
  80206b:	66 90                	xchg   %ax,%ax
  80206d:	66 90                	xchg   %ax,%ax
  80206f:	90                   	nop

00802070 <__udivdi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80207b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80207f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 f6                	test   %esi,%esi
  802089:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80208d:	89 ca                	mov    %ecx,%edx
  80208f:	89 f8                	mov    %edi,%eax
  802091:	75 3d                	jne    8020d0 <__udivdi3+0x60>
  802093:	39 cf                	cmp    %ecx,%edi
  802095:	0f 87 c5 00 00 00    	ja     802160 <__udivdi3+0xf0>
  80209b:	85 ff                	test   %edi,%edi
  80209d:	89 fd                	mov    %edi,%ebp
  80209f:	75 0b                	jne    8020ac <__udivdi3+0x3c>
  8020a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a6:	31 d2                	xor    %edx,%edx
  8020a8:	f7 f7                	div    %edi
  8020aa:	89 c5                	mov    %eax,%ebp
  8020ac:	89 c8                	mov    %ecx,%eax
  8020ae:	31 d2                	xor    %edx,%edx
  8020b0:	f7 f5                	div    %ebp
  8020b2:	89 c1                	mov    %eax,%ecx
  8020b4:	89 d8                	mov    %ebx,%eax
  8020b6:	89 cf                	mov    %ecx,%edi
  8020b8:	f7 f5                	div    %ebp
  8020ba:	89 c3                	mov    %eax,%ebx
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
  8020d0:	39 ce                	cmp    %ecx,%esi
  8020d2:	77 74                	ja     802148 <__udivdi3+0xd8>
  8020d4:	0f bd fe             	bsr    %esi,%edi
  8020d7:	83 f7 1f             	xor    $0x1f,%edi
  8020da:	0f 84 98 00 00 00    	je     802178 <__udivdi3+0x108>
  8020e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	89 c5                	mov    %eax,%ebp
  8020e9:	29 fb                	sub    %edi,%ebx
  8020eb:	d3 e6                	shl    %cl,%esi
  8020ed:	89 d9                	mov    %ebx,%ecx
  8020ef:	d3 ed                	shr    %cl,%ebp
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e0                	shl    %cl,%eax
  8020f5:	09 ee                	or     %ebp,%esi
  8020f7:	89 d9                	mov    %ebx,%ecx
  8020f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020fd:	89 d5                	mov    %edx,%ebp
  8020ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802103:	d3 ed                	shr    %cl,%ebp
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e2                	shl    %cl,%edx
  802109:	89 d9                	mov    %ebx,%ecx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	09 c2                	or     %eax,%edx
  80210f:	89 d0                	mov    %edx,%eax
  802111:	89 ea                	mov    %ebp,%edx
  802113:	f7 f6                	div    %esi
  802115:	89 d5                	mov    %edx,%ebp
  802117:	89 c3                	mov    %eax,%ebx
  802119:	f7 64 24 0c          	mull   0xc(%esp)
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	72 10                	jb     802131 <__udivdi3+0xc1>
  802121:	8b 74 24 08          	mov    0x8(%esp),%esi
  802125:	89 f9                	mov    %edi,%ecx
  802127:	d3 e6                	shl    %cl,%esi
  802129:	39 c6                	cmp    %eax,%esi
  80212b:	73 07                	jae    802134 <__udivdi3+0xc4>
  80212d:	39 d5                	cmp    %edx,%ebp
  80212f:	75 03                	jne    802134 <__udivdi3+0xc4>
  802131:	83 eb 01             	sub    $0x1,%ebx
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 d8                	mov    %ebx,%eax
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	31 db                	xor    %ebx,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	f7 f7                	div    %edi
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 c3                	mov    %eax,%ebx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 fa                	mov    %edi,%edx
  80216c:	83 c4 1c             	add    $0x1c,%esp
  80216f:	5b                   	pop    %ebx
  802170:	5e                   	pop    %esi
  802171:	5f                   	pop    %edi
  802172:	5d                   	pop    %ebp
  802173:	c3                   	ret    
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	39 ce                	cmp    %ecx,%esi
  80217a:	72 0c                	jb     802188 <__udivdi3+0x118>
  80217c:	31 db                	xor    %ebx,%ebx
  80217e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802182:	0f 87 34 ff ff ff    	ja     8020bc <__udivdi3+0x4c>
  802188:	bb 01 00 00 00       	mov    $0x1,%ebx
  80218d:	e9 2a ff ff ff       	jmp    8020bc <__udivdi3+0x4c>
  802192:	66 90                	xchg   %ax,%ax
  802194:	66 90                	xchg   %ax,%ax
  802196:	66 90                	xchg   %ax,%ax
  802198:	66 90                	xchg   %ax,%ax
  80219a:	66 90                	xchg   %ax,%ax
  80219c:	66 90                	xchg   %ax,%ax
  80219e:	66 90                	xchg   %ax,%ax

008021a0 <__umoddi3>:
  8021a0:	55                   	push   %ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 1c             	sub    $0x1c,%esp
  8021a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021b7:	85 d2                	test   %edx,%edx
  8021b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021c1:	89 f3                	mov    %esi,%ebx
  8021c3:	89 3c 24             	mov    %edi,(%esp)
  8021c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ca:	75 1c                	jne    8021e8 <__umoddi3+0x48>
  8021cc:	39 f7                	cmp    %esi,%edi
  8021ce:	76 50                	jbe    802220 <__umoddi3+0x80>
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	f7 f7                	div    %edi
  8021d6:	89 d0                	mov    %edx,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	89 d0                	mov    %edx,%eax
  8021ec:	77 52                	ja     802240 <__umoddi3+0xa0>
  8021ee:	0f bd ea             	bsr    %edx,%ebp
  8021f1:	83 f5 1f             	xor    $0x1f,%ebp
  8021f4:	75 5a                	jne    802250 <__umoddi3+0xb0>
  8021f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021fa:	0f 82 e0 00 00 00    	jb     8022e0 <__umoddi3+0x140>
  802200:	39 0c 24             	cmp    %ecx,(%esp)
  802203:	0f 86 d7 00 00 00    	jbe    8022e0 <__umoddi3+0x140>
  802209:	8b 44 24 08          	mov    0x8(%esp),%eax
  80220d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802211:	83 c4 1c             	add    $0x1c,%esp
  802214:	5b                   	pop    %ebx
  802215:	5e                   	pop    %esi
  802216:	5f                   	pop    %edi
  802217:	5d                   	pop    %ebp
  802218:	c3                   	ret    
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	85 ff                	test   %edi,%edi
  802222:	89 fd                	mov    %edi,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x91>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f7                	div    %edi
  80222f:	89 c5                	mov    %eax,%ebp
  802231:	89 f0                	mov    %esi,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f5                	div    %ebp
  802237:	89 c8                	mov    %ecx,%eax
  802239:	f7 f5                	div    %ebp
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	eb 99                	jmp    8021d8 <__umoddi3+0x38>
  80223f:	90                   	nop
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 1c             	add    $0x1c,%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5f                   	pop    %edi
  80224a:	5d                   	pop    %ebp
  80224b:	c3                   	ret    
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	8b 34 24             	mov    (%esp),%esi
  802253:	bf 20 00 00 00       	mov    $0x20,%edi
  802258:	89 e9                	mov    %ebp,%ecx
  80225a:	29 ef                	sub    %ebp,%edi
  80225c:	d3 e0                	shl    %cl,%eax
  80225e:	89 f9                	mov    %edi,%ecx
  802260:	89 f2                	mov    %esi,%edx
  802262:	d3 ea                	shr    %cl,%edx
  802264:	89 e9                	mov    %ebp,%ecx
  802266:	09 c2                	or     %eax,%edx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 14 24             	mov    %edx,(%esp)
  80226d:	89 f2                	mov    %esi,%edx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	89 f9                	mov    %edi,%ecx
  802273:	89 54 24 04          	mov    %edx,0x4(%esp)
  802277:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	89 e9                	mov    %ebp,%ecx
  80227f:	89 c6                	mov    %eax,%esi
  802281:	d3 e3                	shl    %cl,%ebx
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 d0                	mov    %edx,%eax
  802287:	d3 e8                	shr    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	09 d8                	or     %ebx,%eax
  80228d:	89 d3                	mov    %edx,%ebx
  80228f:	89 f2                	mov    %esi,%edx
  802291:	f7 34 24             	divl   (%esp)
  802294:	89 d6                	mov    %edx,%esi
  802296:	d3 e3                	shl    %cl,%ebx
  802298:	f7 64 24 04          	mull   0x4(%esp)
  80229c:	39 d6                	cmp    %edx,%esi
  80229e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a2:	89 d1                	mov    %edx,%ecx
  8022a4:	89 c3                	mov    %eax,%ebx
  8022a6:	72 08                	jb     8022b0 <__umoddi3+0x110>
  8022a8:	75 11                	jne    8022bb <__umoddi3+0x11b>
  8022aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022ae:	73 0b                	jae    8022bb <__umoddi3+0x11b>
  8022b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022b4:	1b 14 24             	sbb    (%esp),%edx
  8022b7:	89 d1                	mov    %edx,%ecx
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022bf:	29 da                	sub    %ebx,%edx
  8022c1:	19 ce                	sbb    %ecx,%esi
  8022c3:	89 f9                	mov    %edi,%ecx
  8022c5:	89 f0                	mov    %esi,%eax
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	89 e9                	mov    %ebp,%ecx
  8022cb:	d3 ea                	shr    %cl,%edx
  8022cd:	89 e9                	mov    %ebp,%ecx
  8022cf:	d3 ee                	shr    %cl,%esi
  8022d1:	09 d0                	or     %edx,%eax
  8022d3:	89 f2                	mov    %esi,%edx
  8022d5:	83 c4 1c             	add    $0x1c,%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
  8022e0:	29 f9                	sub    %edi,%ecx
  8022e2:	19 d6                	sbb    %edx,%esi
  8022e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ec:	e9 18 ff ff ff       	jmp    802209 <__umoddi3+0x69>
