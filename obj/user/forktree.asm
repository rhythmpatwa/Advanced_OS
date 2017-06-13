
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 fc 0a 00 00       	call   800b3e <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 c0 26 80 00       	push   $0x8026c0
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 bd 06 00 00       	call   800740 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 d1 26 80 00       	push   $0x8026d1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 81 06 00 00       	call   800726 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 d3 0d 00 00       	call   800e80 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 d0 26 80 00       	push   $0x8026d0
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8000ec:	e8 4d 0a 00 00       	call   800b3e <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 51 11 00 00       	call   801283 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 c1 09 00 00       	call   800afd <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 4f 09 00 00       	call   800ac0 <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 54 01 00 00       	call   80030b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 f4 08 00 00       	call   800ac0 <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 f4 21 00 00       	call   802430 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 e1 22 00 00       	call   802560 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 e0 26 80 00 	movsbl 0x8026e0(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029a:	83 fa 01             	cmp    $0x1,%edx
  80029d:	7e 0e                	jle    8002ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a4:	89 08                	mov    %ecx,(%eax)
  8002a6:	8b 02                	mov    (%edx),%eax
  8002a8:	8b 52 04             	mov    0x4(%edx),%edx
  8002ab:	eb 22                	jmp    8002cf <getuint+0x38>
	else if (lflag)
  8002ad:	85 d2                	test   %edx,%edx
  8002af:	74 10                	je     8002c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bf:	eb 0e                	jmp    8002cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c1:	8b 10                	mov    (%eax),%edx
  8002c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c6:	89 08                	mov    %ecx,(%eax)
  8002c8:	8b 02                	mov    (%edx),%eax
  8002ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e0:	73 0a                	jae    8002ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	88 02                	mov    %al,(%edx)
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f7:	50                   	push   %eax
  8002f8:	ff 75 10             	pushl  0x10(%ebp)
  8002fb:	ff 75 0c             	pushl  0xc(%ebp)
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 05 00 00 00       	call   80030b <vprintfmt>
	va_end(ap);
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
  800314:	8b 75 08             	mov    0x8(%ebp),%esi
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031d:	eb 12                	jmp    800331 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 a9 03 00 00    	je     8006d0 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800327:	83 ec 08             	sub    $0x8,%esp
  80032a:	53                   	push   %ebx
  80032b:	50                   	push   %eax
  80032c:	ff d6                	call   *%esi
  80032e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800331:	83 c7 01             	add    $0x1,%edi
  800334:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800338:	83 f8 25             	cmp    $0x25,%eax
  80033b:	75 e2                	jne    80031f <vprintfmt+0x14>
  80033d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800341:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	ba 00 00 00 00       	mov    $0x0,%edx
  80035b:	eb 07                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800360:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036a:	0f b6 07             	movzbl (%edi),%eax
  80036d:	0f b6 c8             	movzbl %al,%ecx
  800370:	83 e8 23             	sub    $0x23,%eax
  800373:	3c 55                	cmp    $0x55,%al
  800375:	0f 87 3a 03 00 00    	ja     8006b5 <vprintfmt+0x3aa>
  80037b:	0f b6 c0             	movzbl %al,%eax
  80037e:	ff 24 85 20 28 80 00 	jmp    *0x802820(,%eax,4)
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800388:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038c:	eb d6                	jmp    800364 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
  800396:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800399:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a6:	83 fa 09             	cmp    $0x9,%edx
  8003a9:	77 39                	ja     8003e4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ae:	eb e9                	jmp    800399 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c1:	eb 27                	jmp    8003ea <vprintfmt+0xdf>
  8003c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cd:	0f 49 c8             	cmovns %eax,%ecx
  8003d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	eb 8c                	jmp    800364 <vprintfmt+0x59>
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e2:	eb 80                	jmp    800364 <vprintfmt+0x59>
  8003e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003ea:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ee:	0f 89 70 ff ff ff    	jns    800364 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800401:	e9 5e ff ff ff       	jmp    800364 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800406:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040c:	e9 53 ff ff ff       	jmp    800364 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 30                	pushl  (%eax)
  800420:	ff d6                	call   *%esi
			break;
  800422:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800428:	e9 04 ff ff ff       	jmp    800331 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	8b 00                	mov    (%eax),%eax
  800438:	99                   	cltd   
  800439:	31 d0                	xor    %edx,%eax
  80043b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043d:	83 f8 0f             	cmp    $0xf,%eax
  800440:	7f 0b                	jg     80044d <vprintfmt+0x142>
  800442:	8b 14 85 80 29 80 00 	mov    0x802980(,%eax,4),%edx
  800449:	85 d2                	test   %edx,%edx
  80044b:	75 18                	jne    800465 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044d:	50                   	push   %eax
  80044e:	68 f8 26 80 00       	push   $0x8026f8
  800453:	53                   	push   %ebx
  800454:	56                   	push   %esi
  800455:	e8 94 fe ff ff       	call   8002ee <printfmt>
  80045a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800460:	e9 cc fe ff ff       	jmp    800331 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800465:	52                   	push   %edx
  800466:	68 89 2b 80 00       	push   $0x802b89
  80046b:	53                   	push   %ebx
  80046c:	56                   	push   %esi
  80046d:	e8 7c fe ff ff       	call   8002ee <printfmt>
  800472:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800478:	e9 b4 fe ff ff       	jmp    800331 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800488:	85 ff                	test   %edi,%edi
  80048a:	b8 f1 26 80 00       	mov    $0x8026f1,%eax
  80048f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800492:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800496:	0f 8e 94 00 00 00    	jle    800530 <vprintfmt+0x225>
  80049c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a0:	0f 84 98 00 00 00    	je     80053e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ac:	57                   	push   %edi
  8004ad:	e8 a6 02 00 00       	call   800758 <strnlen>
  8004b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b5:	29 c1                	sub    %eax,%ecx
  8004b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	eb 0f                	jmp    8004da <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	53                   	push   %ebx
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d4:	83 ef 01             	sub    $0x1,%edi
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f ed                	jg     8004cb <vprintfmt+0x1c0>
  8004de:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e4:	85 c9                	test   %ecx,%ecx
  8004e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004eb:	0f 49 c1             	cmovns %ecx,%eax
  8004ee:	29 c1                	sub    %eax,%ecx
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	89 cb                	mov    %ecx,%ebx
  8004fb:	eb 4d                	jmp    80054a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800501:	74 1b                	je     80051e <vprintfmt+0x213>
  800503:	0f be c0             	movsbl %al,%eax
  800506:	83 e8 20             	sub    $0x20,%eax
  800509:	83 f8 5e             	cmp    $0x5e,%eax
  80050c:	76 10                	jbe    80051e <vprintfmt+0x213>
					putch('?', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	6a 3f                	push   $0x3f
  800516:	ff 55 08             	call   *0x8(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb 0d                	jmp    80052b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 0c             	pushl  0xc(%ebp)
  800524:	52                   	push   %edx
  800525:	ff 55 08             	call   *0x8(%ebp)
  800528:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052b:	83 eb 01             	sub    $0x1,%ebx
  80052e:	eb 1a                	jmp    80054a <vprintfmt+0x23f>
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053c:	eb 0c                	jmp    80054a <vprintfmt+0x23f>
  80053e:	89 75 08             	mov    %esi,0x8(%ebp)
  800541:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800547:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054a:	83 c7 01             	add    $0x1,%edi
  80054d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800551:	0f be d0             	movsbl %al,%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	74 23                	je     80057b <vprintfmt+0x270>
  800558:	85 f6                	test   %esi,%esi
  80055a:	78 a1                	js     8004fd <vprintfmt+0x1f2>
  80055c:	83 ee 01             	sub    $0x1,%esi
  80055f:	79 9c                	jns    8004fd <vprintfmt+0x1f2>
  800561:	89 df                	mov    %ebx,%edi
  800563:	8b 75 08             	mov    0x8(%ebp),%esi
  800566:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800569:	eb 18                	jmp    800583 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	53                   	push   %ebx
  80056f:	6a 20                	push   $0x20
  800571:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800573:	83 ef 01             	sub    $0x1,%edi
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	eb 08                	jmp    800583 <vprintfmt+0x278>
  80057b:	89 df                	mov    %ebx,%edi
  80057d:	8b 75 08             	mov    0x8(%ebp),%esi
  800580:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800583:	85 ff                	test   %edi,%edi
  800585:	7f e4                	jg     80056b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058a:	e9 a2 fd ff ff       	jmp    800331 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058f:	83 fa 01             	cmp    $0x1,%edx
  800592:	7e 16                	jle    8005aa <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 50 08             	lea    0x8(%eax),%edx
  80059a:	89 55 14             	mov    %edx,0x14(%ebp)
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	eb 32                	jmp    8005dc <vprintfmt+0x2d1>
	else if (lflag)
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	74 18                	je     8005c6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 c1                	mov    %eax,%ecx
  8005be:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c4:	eb 16                	jmp    8005dc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 c1                	mov    %eax,%ecx
  8005d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005df:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005eb:	0f 89 90 00 00 00    	jns    800681 <vprintfmt+0x376>
				putch('-', putdat);
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 2d                	push   $0x2d
  8005f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ff:	f7 d8                	neg    %eax
  800601:	83 d2 00             	adc    $0x0,%edx
  800604:	f7 da                	neg    %edx
  800606:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800609:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80060e:	eb 71                	jmp    800681 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 7f fc ff ff       	call   800297 <getuint>
			base = 10;
  800618:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80061d:	eb 62                	jmp    800681 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 70 fc ff ff       	call   800297 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800627:	83 ec 0c             	sub    $0xc,%esp
  80062a:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80062e:	51                   	push   %ecx
  80062f:	ff 75 e0             	pushl  -0x20(%ebp)
  800632:	6a 08                	push   $0x8
  800634:	52                   	push   %edx
  800635:	50                   	push   %eax
  800636:	89 da                	mov    %ebx,%edx
  800638:	89 f0                	mov    %esi,%eax
  80063a:	e8 a9 fb ff ff       	call   8001e8 <printnum>
			break;
  80063f:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800645:	e9 e7 fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 30                	push   $0x30
  800650:	ff d6                	call   *%esi
			putch('x', putdat);
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 78                	push   $0x78
  800658:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 50 04             	lea    0x4(%eax),%edx
  800660:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800663:	8b 00                	mov    (%eax),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800672:	eb 0d                	jmp    800681 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 1b fc ff ff       	call   800297 <getuint>
			base = 16;
  80067c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800681:	83 ec 0c             	sub    $0xc,%esp
  800684:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800688:	57                   	push   %edi
  800689:	ff 75 e0             	pushl  -0x20(%ebp)
  80068c:	51                   	push   %ecx
  80068d:	52                   	push   %edx
  80068e:	50                   	push   %eax
  80068f:	89 da                	mov    %ebx,%edx
  800691:	89 f0                	mov    %esi,%eax
  800693:	e8 50 fb ff ff       	call   8001e8 <printnum>
			break;
  800698:	83 c4 20             	add    $0x20,%esp
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069e:	e9 8e fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	51                   	push   %ecx
  8006a8:	ff d6                	call   *%esi
			break;
  8006aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b0:	e9 7c fc ff ff       	jmp    800331 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 25                	push   $0x25
  8006bb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 03                	jmp    8006c5 <vprintfmt+0x3ba>
  8006c2:	83 ef 01             	sub    $0x1,%edi
  8006c5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c9:	75 f7                	jne    8006c2 <vprintfmt+0x3b7>
  8006cb:	e9 61 fc ff ff       	jmp    800331 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5f                   	pop    %edi
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	83 ec 18             	sub    $0x18,%esp
  8006de:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006eb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 26                	je     80071f <vsnprintf+0x47>
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	7e 22                	jle    80071f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fd:	ff 75 14             	pushl  0x14(%ebp)
  800700:	ff 75 10             	pushl  0x10(%ebp)
  800703:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	68 d1 02 80 00       	push   $0x8002d1
  80070c:	e8 fa fb ff ff       	call   80030b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800711:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800714:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 05                	jmp    800724 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072f:	50                   	push   %eax
  800730:	ff 75 10             	pushl  0x10(%ebp)
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	ff 75 08             	pushl  0x8(%ebp)
  800739:	e8 9a ff ff ff       	call   8006d8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	b8 00 00 00 00       	mov    $0x0,%eax
  80074b:	eb 03                	jmp    800750 <strlen+0x10>
		n++;
  80074d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800754:	75 f7                	jne    80074d <strlen+0xd>
		n++;
	return n;
}
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    

00800758 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800758:	55                   	push   %ebp
  800759:	89 e5                	mov    %esp,%ebp
  80075b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	ba 00 00 00 00       	mov    $0x0,%edx
  800766:	eb 03                	jmp    80076b <strnlen+0x13>
		n++;
  800768:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	39 c2                	cmp    %eax,%edx
  80076d:	74 08                	je     800777 <strnlen+0x1f>
  80076f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800773:	75 f3                	jne    800768 <strnlen+0x10>
  800775:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	53                   	push   %ebx
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800783:	89 c2                	mov    %eax,%edx
  800785:	83 c2 01             	add    $0x1,%edx
  800788:	83 c1 01             	add    $0x1,%ecx
  80078b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800792:	84 db                	test   %bl,%bl
  800794:	75 ef                	jne    800785 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800796:	5b                   	pop    %ebx
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a0:	53                   	push   %ebx
  8007a1:	e8 9a ff ff ff       	call   800740 <strlen>
  8007a6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	01 d8                	add    %ebx,%eax
  8007ae:	50                   	push   %eax
  8007af:	e8 c5 ff ff ff       	call   800779 <strcpy>
	return dst;
}
  8007b4:	89 d8                	mov    %ebx,%eax
  8007b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c6:	89 f3                	mov    %esi,%ebx
  8007c8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cb:	89 f2                	mov    %esi,%edx
  8007cd:	eb 0f                	jmp    8007de <strncpy+0x23>
		*dst++ = *src;
  8007cf:	83 c2 01             	add    $0x1,%edx
  8007d2:	0f b6 01             	movzbl (%ecx),%eax
  8007d5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d8:	80 39 01             	cmpb   $0x1,(%ecx)
  8007db:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007de:	39 da                	cmp    %ebx,%edx
  8007e0:	75 ed                	jne    8007cf <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e2:	89 f0                	mov    %esi,%eax
  8007e4:	5b                   	pop    %ebx
  8007e5:	5e                   	pop    %esi
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f8:	85 d2                	test   %edx,%edx
  8007fa:	74 21                	je     80081d <strlcpy+0x35>
  8007fc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800800:	89 f2                	mov    %esi,%edx
  800802:	eb 09                	jmp    80080d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	83 c1 01             	add    $0x1,%ecx
  80080a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080d:	39 c2                	cmp    %eax,%edx
  80080f:	74 09                	je     80081a <strlcpy+0x32>
  800811:	0f b6 19             	movzbl (%ecx),%ebx
  800814:	84 db                	test   %bl,%bl
  800816:	75 ec                	jne    800804 <strlcpy+0x1c>
  800818:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081d:	29 f0                	sub    %esi,%eax
}
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082c:	eb 06                	jmp    800834 <strcmp+0x11>
		p++, q++;
  80082e:	83 c1 01             	add    $0x1,%ecx
  800831:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800834:	0f b6 01             	movzbl (%ecx),%eax
  800837:	84 c0                	test   %al,%al
  800839:	74 04                	je     80083f <strcmp+0x1c>
  80083b:	3a 02                	cmp    (%edx),%al
  80083d:	74 ef                	je     80082e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083f:	0f b6 c0             	movzbl %al,%eax
  800842:	0f b6 12             	movzbl (%edx),%edx
  800845:	29 d0                	sub    %edx,%eax
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 c3                	mov    %eax,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800858:	eb 06                	jmp    800860 <strncmp+0x17>
		n--, p++, q++;
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800860:	39 d8                	cmp    %ebx,%eax
  800862:	74 15                	je     800879 <strncmp+0x30>
  800864:	0f b6 08             	movzbl (%eax),%ecx
  800867:	84 c9                	test   %cl,%cl
  800869:	74 04                	je     80086f <strncmp+0x26>
  80086b:	3a 0a                	cmp    (%edx),%cl
  80086d:	74 eb                	je     80085a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 00             	movzbl (%eax),%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
  800877:	eb 05                	jmp    80087e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088b:	eb 07                	jmp    800894 <strchr+0x13>
		if (*s == c)
  80088d:	38 ca                	cmp    %cl,%dl
  80088f:	74 0f                	je     8008a0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	0f b6 10             	movzbl (%eax),%edx
  800897:	84 d2                	test   %dl,%dl
  800899:	75 f2                	jne    80088d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ac:	eb 03                	jmp    8008b1 <strfind+0xf>
  8008ae:	83 c0 01             	add    $0x1,%eax
  8008b1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 04                	je     8008bc <strfind+0x1a>
  8008b8:	84 d2                	test   %dl,%dl
  8008ba:	75 f2                	jne    8008ae <strfind+0xc>
			break;
	return (char *) s;
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	57                   	push   %edi
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 36                	je     800904 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d4:	75 28                	jne    8008fe <memset+0x40>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 23                	jne    8008fe <memset+0x40>
		c &= 0xFF;
  8008db:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008df:	89 d3                	mov    %edx,%ebx
  8008e1:	c1 e3 08             	shl    $0x8,%ebx
  8008e4:	89 d6                	mov    %edx,%esi
  8008e6:	c1 e6 18             	shl    $0x18,%esi
  8008e9:	89 d0                	mov    %edx,%eax
  8008eb:	c1 e0 10             	shl    $0x10,%eax
  8008ee:	09 f0                	or     %esi,%eax
  8008f0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f2:	89 d8                	mov    %ebx,%eax
  8008f4:	09 d0                	or     %edx,%eax
  8008f6:	c1 e9 02             	shr    $0x2,%ecx
  8008f9:	fc                   	cld    
  8008fa:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fc:	eb 06                	jmp    800904 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800901:	fc                   	cld    
  800902:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800904:	89 f8                	mov    %edi,%eax
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	57                   	push   %edi
  80090f:	56                   	push   %esi
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 75 0c             	mov    0xc(%ebp),%esi
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800919:	39 c6                	cmp    %eax,%esi
  80091b:	73 35                	jae    800952 <memmove+0x47>
  80091d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800920:	39 d0                	cmp    %edx,%eax
  800922:	73 2e                	jae    800952 <memmove+0x47>
		s += n;
		d += n;
  800924:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	89 d6                	mov    %edx,%esi
  800929:	09 fe                	or     %edi,%esi
  80092b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800931:	75 13                	jne    800946 <memmove+0x3b>
  800933:	f6 c1 03             	test   $0x3,%cl
  800936:	75 0e                	jne    800946 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800938:	83 ef 04             	sub    $0x4,%edi
  80093b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	fd                   	std    
  800942:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800944:	eb 09                	jmp    80094f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800946:	83 ef 01             	sub    $0x1,%edi
  800949:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094c:	fd                   	std    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094f:	fc                   	cld    
  800950:	eb 1d                	jmp    80096f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 f2                	mov    %esi,%edx
  800954:	09 c2                	or     %eax,%edx
  800956:	f6 c2 03             	test   $0x3,%dl
  800959:	75 0f                	jne    80096a <memmove+0x5f>
  80095b:	f6 c1 03             	test   $0x3,%cl
  80095e:	75 0a                	jne    80096a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800960:	c1 e9 02             	shr    $0x2,%ecx
  800963:	89 c7                	mov    %eax,%edi
  800965:	fc                   	cld    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 05                	jmp    80096f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	ff 75 08             	pushl  0x8(%ebp)
  80097f:	e8 87 ff ff ff       	call   80090b <memmove>
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	89 c6                	mov    %eax,%esi
  800993:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800996:	eb 1a                	jmp    8009b2 <memcmp+0x2c>
		if (*s1 != *s2)
  800998:	0f b6 08             	movzbl (%eax),%ecx
  80099b:	0f b6 1a             	movzbl (%edx),%ebx
  80099e:	38 d9                	cmp    %bl,%cl
  8009a0:	74 0a                	je     8009ac <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a2:	0f b6 c1             	movzbl %cl,%eax
  8009a5:	0f b6 db             	movzbl %bl,%ebx
  8009a8:	29 d8                	sub    %ebx,%eax
  8009aa:	eb 0f                	jmp    8009bb <memcmp+0x35>
		s1++, s2++;
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	39 f0                	cmp    %esi,%eax
  8009b4:	75 e2                	jne    800998 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c6:	89 c1                	mov    %eax,%ecx
  8009c8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cf:	eb 0a                	jmp    8009db <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d1:	0f b6 10             	movzbl (%eax),%edx
  8009d4:	39 da                	cmp    %ebx,%edx
  8009d6:	74 07                	je     8009df <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	39 c8                	cmp    %ecx,%eax
  8009dd:	72 f2                	jb     8009d1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	eb 03                	jmp    8009f3 <strtol+0x11>
		s++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	3c 20                	cmp    $0x20,%al
  8009f8:	74 f6                	je     8009f0 <strtol+0xe>
  8009fa:	3c 09                	cmp    $0x9,%al
  8009fc:	74 f2                	je     8009f0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fe:	3c 2b                	cmp    $0x2b,%al
  800a00:	75 0a                	jne    800a0c <strtol+0x2a>
		s++;
  800a02:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a05:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0a:	eb 11                	jmp    800a1d <strtol+0x3b>
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a11:	3c 2d                	cmp    $0x2d,%al
  800a13:	75 08                	jne    800a1d <strtol+0x3b>
		s++, neg = 1;
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a23:	75 15                	jne    800a3a <strtol+0x58>
  800a25:	80 39 30             	cmpb   $0x30,(%ecx)
  800a28:	75 10                	jne    800a3a <strtol+0x58>
  800a2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2e:	75 7c                	jne    800aac <strtol+0xca>
		s += 2, base = 16;
  800a30:	83 c1 02             	add    $0x2,%ecx
  800a33:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a38:	eb 16                	jmp    800a50 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	75 12                	jne    800a50 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 08                	jne    800a50 <strtol+0x6e>
		s++, base = 8;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a58:	0f b6 11             	movzbl (%ecx),%edx
  800a5b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5e:	89 f3                	mov    %esi,%ebx
  800a60:	80 fb 09             	cmp    $0x9,%bl
  800a63:	77 08                	ja     800a6d <strtol+0x8b>
			dig = *s - '0';
  800a65:	0f be d2             	movsbl %dl,%edx
  800a68:	83 ea 30             	sub    $0x30,%edx
  800a6b:	eb 22                	jmp    800a8f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a70:	89 f3                	mov    %esi,%ebx
  800a72:	80 fb 19             	cmp    $0x19,%bl
  800a75:	77 08                	ja     800a7f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a77:	0f be d2             	movsbl %dl,%edx
  800a7a:	83 ea 57             	sub    $0x57,%edx
  800a7d:	eb 10                	jmp    800a8f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a82:	89 f3                	mov    %esi,%ebx
  800a84:	80 fb 19             	cmp    $0x19,%bl
  800a87:	77 16                	ja     800a9f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a89:	0f be d2             	movsbl %dl,%edx
  800a8c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a92:	7d 0b                	jge    800a9f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9d:	eb b9                	jmp    800a58 <strtol+0x76>

	if (endptr)
  800a9f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa3:	74 0d                	je     800ab2 <strtol+0xd0>
		*endptr = (char *) s;
  800aa5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa8:	89 0e                	mov    %ecx,(%esi)
  800aaa:	eb 06                	jmp    800ab2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	74 98                	je     800a48 <strtol+0x66>
  800ab0:	eb 9e                	jmp    800a50 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	f7 da                	neg    %edx
  800ab6:	85 ff                	test   %edi,%edi
  800ab8:	0f 45 c2             	cmovne %edx,%eax
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ace:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	89 c6                	mov    %eax,%esi
  800ad7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cgetc>:

int
sys_cgetc(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b10:	8b 55 08             	mov    0x8(%ebp),%edx
  800b13:	89 cb                	mov    %ecx,%ebx
  800b15:	89 cf                	mov    %ecx,%edi
  800b17:	89 ce                	mov    %ecx,%esi
  800b19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7e 17                	jle    800b36 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	6a 03                	push   $0x3
  800b25:	68 df 29 80 00       	push   $0x8029df
  800b2a:	6a 23                	push   $0x23
  800b2c:	68 fc 29 80 00       	push   $0x8029fc
  800b31:	e8 df 16 00 00       	call   802215 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_yield>:

void
sys_yield(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	be 00 00 00 00       	mov    $0x0,%esi
  800b8a:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	89 f7                	mov    %esi,%edi
  800b9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 04                	push   $0x4
  800ba6:	68 df 29 80 00       	push   $0x8029df
  800bab:	6a 23                	push   $0x23
  800bad:	68 fc 29 80 00       	push   $0x8029fc
  800bb2:	e8 5e 16 00 00       	call   802215 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7e 17                	jle    800bf9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 05                	push   $0x5
  800be8:	68 df 29 80 00       	push   $0x8029df
  800bed:	6a 23                	push   $0x23
  800bef:	68 fc 29 80 00       	push   $0x8029fc
  800bf4:	e8 1c 16 00 00       	call   802215 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 06                	push   $0x6
  800c2a:	68 df 29 80 00       	push   $0x8029df
  800c2f:	6a 23                	push   $0x23
  800c31:	68 fc 29 80 00       	push   $0x8029fc
  800c36:	e8 da 15 00 00       	call   802215 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	b8 08 00 00 00       	mov    $0x8,%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 08                	push   $0x8
  800c6c:	68 df 29 80 00       	push   $0x8029df
  800c71:	6a 23                	push   $0x23
  800c73:	68 fc 29 80 00       	push   $0x8029fc
  800c78:	e8 98 15 00 00       	call   802215 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 09 00 00 00       	mov    $0x9,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 09                	push   $0x9
  800cae:	68 df 29 80 00       	push   $0x8029df
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 fc 29 80 00       	push   $0x8029fc
  800cba:	e8 56 15 00 00       	call   802215 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 17                	jle    800d01 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 0a                	push   $0xa
  800cf0:	68 df 29 80 00       	push   $0x8029df
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 fc 29 80 00       	push   $0x8029fc
  800cfc:	e8 14 15 00 00       	call   802215 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	be 00 00 00 00       	mov    $0x0,%esi
  800d14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d25:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7e 17                	jle    800d65 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4e:	83 ec 0c             	sub    $0xc,%esp
  800d51:	50                   	push   %eax
  800d52:	6a 0d                	push   $0xd
  800d54:	68 df 29 80 00       	push   $0x8029df
  800d59:	6a 23                	push   $0x23
  800d5b:	68 fc 29 80 00       	push   $0x8029fc
  800d60:	e8 b0 14 00 00       	call   802215 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	ba 00 00 00 00       	mov    $0x0,%edx
  800d78:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7d:	89 d1                	mov    %edx,%ecx
  800d7f:	89 d3                	mov    %edx,%ebx
  800d81:	89 d7                	mov    %edx,%edi
  800d83:	89 d6                	mov    %edx,%esi
  800d85:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 04             	sub    $0x4,%esp
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d96:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800d98:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800d9b:	f6 c1 02             	test   $0x2,%cl
  800d9e:	74 2e                	je     800dce <pgfault+0x42>
  800da0:	89 c2                	mov    %eax,%edx
  800da2:	c1 ea 16             	shr    $0x16,%edx
  800da5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dac:	f6 c2 01             	test   $0x1,%dl
  800daf:	74 1d                	je     800dce <pgfault+0x42>
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	c1 ea 0c             	shr    $0xc,%edx
  800db6:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800dbd:	f6 c3 01             	test   $0x1,%bl
  800dc0:	74 0c                	je     800dce <pgfault+0x42>
  800dc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc9:	f6 c6 08             	test   $0x8,%dh
  800dcc:	75 12                	jne    800de0 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800dce:	51                   	push   %ecx
  800dcf:	68 0a 2a 80 00       	push   $0x802a0a
  800dd4:	6a 1e                	push   $0x1e
  800dd6:	68 23 2a 80 00       	push   $0x802a23
  800ddb:	e8 35 14 00 00       	call   802215 <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800de0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800de5:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	6a 07                	push   $0x7
  800dec:	68 00 f0 7f 00       	push   $0x7ff000
  800df1:	6a 00                	push   $0x0
  800df3:	e8 84 fd ff ff       	call   800b7c <sys_page_alloc>
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	79 12                	jns    800e11 <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800dff:	50                   	push   %eax
  800e00:	68 2e 2a 80 00       	push   $0x802a2e
  800e05:	6a 29                	push   $0x29
  800e07:	68 23 2a 80 00       	push   $0x802a23
  800e0c:	e8 04 14 00 00       	call   802215 <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	68 00 10 00 00       	push   $0x1000
  800e19:	53                   	push   %ebx
  800e1a:	68 00 f0 7f 00       	push   $0x7ff000
  800e1f:	e8 4f fb ff ff       	call   800973 <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e24:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e2b:	53                   	push   %ebx
  800e2c:	6a 00                	push   $0x0
  800e2e:	68 00 f0 7f 00       	push   $0x7ff000
  800e33:	6a 00                	push   $0x0
  800e35:	e8 85 fd ff ff       	call   800bbf <sys_page_map>
  800e3a:	83 c4 20             	add    $0x20,%esp
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	79 12                	jns    800e53 <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800e41:	50                   	push   %eax
  800e42:	68 49 2a 80 00       	push   $0x802a49
  800e47:	6a 2e                	push   $0x2e
  800e49:	68 23 2a 80 00       	push   $0x802a23
  800e4e:	e8 c2 13 00 00       	call   802215 <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	68 00 f0 7f 00       	push   $0x7ff000
  800e5b:	6a 00                	push   $0x0
  800e5d:	e8 9f fd ff ff       	call   800c01 <sys_page_unmap>
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	85 c0                	test   %eax,%eax
  800e67:	79 12                	jns    800e7b <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800e69:	50                   	push   %eax
  800e6a:	68 62 2a 80 00       	push   $0x802a62
  800e6f:	6a 31                	push   $0x31
  800e71:	68 23 2a 80 00       	push   $0x802a23
  800e76:	e8 9a 13 00 00       	call   802215 <_panic>

}
  800e7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
  800e86:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800e89:	68 8c 0d 80 00       	push   $0x800d8c
  800e8e:	e8 c8 13 00 00       	call   80225b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e93:	b8 07 00 00 00       	mov    $0x7,%eax
  800e98:	cd 30                	int    $0x30
  800e9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e9d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	75 21                	jne    800ecd <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eac:	e8 8d fc ff ff       	call   800b3e <sys_getenvid>
  800eb1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800eb6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eb9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebe:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	e9 c9 01 00 00       	jmp    801096 <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800ecd:	89 d8                	mov    %ebx,%eax
  800ecf:	c1 e8 16             	shr    $0x16,%eax
  800ed2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ed9:	a8 01                	test   $0x1,%al
  800edb:	0f 84 1b 01 00 00    	je     800ffc <fork+0x17c>
  800ee1:	89 de                	mov    %ebx,%esi
  800ee3:	c1 ee 0c             	shr    $0xc,%esi
  800ee6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800eed:	a8 01                	test   $0x1,%al
  800eef:	0f 84 07 01 00 00    	je     800ffc <fork+0x17c>
  800ef5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800efc:	a8 04                	test   $0x4,%al
  800efe:	0f 84 f8 00 00 00    	je     800ffc <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800f04:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f0b:	f6 c4 04             	test   $0x4,%ah
  800f0e:	74 3c                	je     800f4c <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800f10:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f17:	c1 e6 0c             	shl    $0xc,%esi
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	25 07 0e 00 00       	and    $0xe07,%eax
  800f22:	50                   	push   %eax
  800f23:	56                   	push   %esi
  800f24:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f27:	56                   	push   %esi
  800f28:	6a 00                	push   $0x0
  800f2a:	e8 90 fc ff ff       	call   800bbf <sys_page_map>
  800f2f:	83 c4 20             	add    $0x20,%esp
  800f32:	85 c0                	test   %eax,%eax
  800f34:	0f 89 c2 00 00 00    	jns    800ffc <fork+0x17c>
			panic("duppage: %e", r);
  800f3a:	50                   	push   %eax
  800f3b:	68 7d 2a 80 00       	push   $0x802a7d
  800f40:	6a 48                	push   $0x48
  800f42:	68 23 2a 80 00       	push   $0x802a23
  800f47:	e8 c9 12 00 00       	call   802215 <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  800f4c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f53:	f6 c4 08             	test   $0x8,%ah
  800f56:	75 0b                	jne    800f63 <fork+0xe3>
  800f58:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5f:	a8 02                	test   $0x2,%al
  800f61:	74 6c                	je     800fcf <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  800f63:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f6a:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  800f6d:	83 f8 01             	cmp    $0x1,%eax
  800f70:	19 ff                	sbb    %edi,%edi
  800f72:	83 e7 fc             	and    $0xfffffffc,%edi
  800f75:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  800f7b:	c1 e6 0c             	shl    $0xc,%esi
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f86:	56                   	push   %esi
  800f87:	6a 00                	push   $0x0
  800f89:	e8 31 fc ff ff       	call   800bbf <sys_page_map>
  800f8e:	83 c4 20             	add    $0x20,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	79 12                	jns    800fa7 <fork+0x127>
			panic("duppage: %e", r);
  800f95:	50                   	push   %eax
  800f96:	68 7d 2a 80 00       	push   $0x802a7d
  800f9b:	6a 50                	push   $0x50
  800f9d:	68 23 2a 80 00       	push   $0x802a23
  800fa2:	e8 6e 12 00 00       	call   802215 <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	6a 00                	push   $0x0
  800fae:	56                   	push   %esi
  800faf:	6a 00                	push   $0x0
  800fb1:	e8 09 fc ff ff       	call   800bbf <sys_page_map>
  800fb6:	83 c4 20             	add    $0x20,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	79 3f                	jns    800ffc <fork+0x17c>
			panic("duppage: %e", r);
  800fbd:	50                   	push   %eax
  800fbe:	68 7d 2a 80 00       	push   $0x802a7d
  800fc3:	6a 53                	push   $0x53
  800fc5:	68 23 2a 80 00       	push   $0x802a23
  800fca:	e8 46 12 00 00       	call   802215 <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  800fcf:	c1 e6 0c             	shl    $0xc,%esi
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	6a 05                	push   $0x5
  800fd7:	56                   	push   %esi
  800fd8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdb:	56                   	push   %esi
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 dc fb ff ff       	call   800bbf <sys_page_map>
  800fe3:	83 c4 20             	add    $0x20,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	79 12                	jns    800ffc <fork+0x17c>
			panic("duppage: %e", r);
  800fea:	50                   	push   %eax
  800feb:	68 7d 2a 80 00       	push   $0x802a7d
  800ff0:	6a 57                	push   $0x57
  800ff2:	68 23 2a 80 00       	push   $0x802a23
  800ff7:	e8 19 12 00 00       	call   802215 <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  800ffc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801002:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801008:	0f 85 bf fe ff ff    	jne    800ecd <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	6a 07                	push   $0x7
  801013:	68 00 f0 bf ee       	push   $0xeebff000
  801018:	ff 75 e0             	pushl  -0x20(%ebp)
  80101b:	e8 5c fb ff ff       	call   800b7c <sys_page_alloc>
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	74 17                	je     80103e <fork+0x1be>
		panic("sys_page_alloc Error");
  801027:	83 ec 04             	sub    $0x4,%esp
  80102a:	68 89 2a 80 00       	push   $0x802a89
  80102f:	68 83 00 00 00       	push   $0x83
  801034:	68 23 2a 80 00       	push   $0x802a23
  801039:	e8 d7 11 00 00       	call   802215 <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  80103e:	83 ec 08             	sub    $0x8,%esp
  801041:	68 ca 22 80 00       	push   $0x8022ca
  801046:	ff 75 e0             	pushl  -0x20(%ebp)
  801049:	e8 79 fc ff ff       	call   800cc7 <sys_env_set_pgfault_upcall>
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	79 15                	jns    80106a <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  801055:	50                   	push   %eax
  801056:	68 9e 2a 80 00       	push   $0x802a9e
  80105b:	68 86 00 00 00       	push   $0x86
  801060:	68 23 2a 80 00       	push   $0x802a23
  801065:	e8 ab 11 00 00       	call   802215 <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	6a 02                	push   $0x2
  80106f:	ff 75 e0             	pushl  -0x20(%ebp)
  801072:	e8 cc fb ff ff       	call   800c43 <sys_env_set_status>
  801077:	83 c4 10             	add    $0x10,%esp
  80107a:	85 c0                	test   %eax,%eax
  80107c:	79 15                	jns    801093 <fork+0x213>
		panic("fork set status: %e", r);
  80107e:	50                   	push   %eax
  80107f:	68 b6 2a 80 00       	push   $0x802ab6
  801084:	68 89 00 00 00       	push   $0x89
  801089:	68 23 2a 80 00       	push   $0x802a23
  80108e:	e8 82 11 00 00       	call   802215 <_panic>
	
	return envid;
  801093:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  801096:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801099:	5b                   	pop    %ebx
  80109a:	5e                   	pop    %esi
  80109b:	5f                   	pop    %edi
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <sfork>:


// Challenge!
int
sfork(void)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010a4:	68 ca 2a 80 00       	push   $0x802aca
  8010a9:	68 93 00 00 00       	push   $0x93
  8010ae:	68 23 2a 80 00       	push   $0x802a23
  8010b3:	e8 5d 11 00 00       	call   802215 <_panic>

008010b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	05 00 00 00 30       	add    $0x30000000,%eax
  8010c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8010d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    

008010df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 ea 16             	shr    $0x16,%edx
  8010ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010f6:	f6 c2 01             	test   $0x1,%dl
  8010f9:	74 11                	je     80110c <fd_alloc+0x2d>
  8010fb:	89 c2                	mov    %eax,%edx
  8010fd:	c1 ea 0c             	shr    $0xc,%edx
  801100:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801107:	f6 c2 01             	test   $0x1,%dl
  80110a:	75 09                	jne    801115 <fd_alloc+0x36>
			*fd_store = fd;
  80110c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
  801113:	eb 17                	jmp    80112c <fd_alloc+0x4d>
  801115:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80111a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80111f:	75 c9                	jne    8010ea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801121:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801127:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801134:	83 f8 1f             	cmp    $0x1f,%eax
  801137:	77 36                	ja     80116f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801139:	c1 e0 0c             	shl    $0xc,%eax
  80113c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801141:	89 c2                	mov    %eax,%edx
  801143:	c1 ea 16             	shr    $0x16,%edx
  801146:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80114d:	f6 c2 01             	test   $0x1,%dl
  801150:	74 24                	je     801176 <fd_lookup+0x48>
  801152:	89 c2                	mov    %eax,%edx
  801154:	c1 ea 0c             	shr    $0xc,%edx
  801157:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80115e:	f6 c2 01             	test   $0x1,%dl
  801161:	74 1a                	je     80117d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801163:	8b 55 0c             	mov    0xc(%ebp),%edx
  801166:	89 02                	mov    %eax,(%edx)
	return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
  80116d:	eb 13                	jmp    801182 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80116f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801174:	eb 0c                	jmp    801182 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80117b:	eb 05                	jmp    801182 <fd_lookup+0x54>
  80117d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118d:	ba 5c 2b 80 00       	mov    $0x802b5c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801192:	eb 13                	jmp    8011a7 <dev_lookup+0x23>
  801194:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801197:	39 08                	cmp    %ecx,(%eax)
  801199:	75 0c                	jne    8011a7 <dev_lookup+0x23>
			*dev = devtab[i];
  80119b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119e:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a5:	eb 2e                	jmp    8011d5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a7:	8b 02                	mov    (%edx),%eax
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	75 e7                	jne    801194 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b2:	8b 40 48             	mov    0x48(%eax),%eax
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	51                   	push   %ecx
  8011b9:	50                   	push   %eax
  8011ba:	68 e0 2a 80 00       	push   $0x802ae0
  8011bf:	e8 10 f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  8011c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    

008011d7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 10             	sub    $0x10,%esp
  8011df:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ef:	c1 e8 0c             	shr    $0xc,%eax
  8011f2:	50                   	push   %eax
  8011f3:	e8 36 ff ff ff       	call   80112e <fd_lookup>
  8011f8:	83 c4 08             	add    $0x8,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 05                	js     801204 <fd_close+0x2d>
	    || fd != fd2)
  8011ff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801202:	74 0c                	je     801210 <fd_close+0x39>
		return (must_exist ? r : 0);
  801204:	84 db                	test   %bl,%bl
  801206:	ba 00 00 00 00       	mov    $0x0,%edx
  80120b:	0f 44 c2             	cmove  %edx,%eax
  80120e:	eb 41                	jmp    801251 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	ff 36                	pushl  (%esi)
  801219:	e8 66 ff ff ff       	call   801184 <dev_lookup>
  80121e:	89 c3                	mov    %eax,%ebx
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	78 1a                	js     801241 <fd_close+0x6a>
		if (dev->dev_close)
  801227:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80122d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801232:	85 c0                	test   %eax,%eax
  801234:	74 0b                	je     801241 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	56                   	push   %esi
  80123a:	ff d0                	call   *%eax
  80123c:	89 c3                	mov    %eax,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	56                   	push   %esi
  801245:	6a 00                	push   $0x0
  801247:	e8 b5 f9 ff ff       	call   800c01 <sys_page_unmap>
	return r;
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	89 d8                	mov    %ebx,%eax
}
  801251:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	ff 75 08             	pushl  0x8(%ebp)
  801265:	e8 c4 fe ff ff       	call   80112e <fd_lookup>
  80126a:	83 c4 08             	add    $0x8,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 10                	js     801281 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	6a 01                	push   $0x1
  801276:	ff 75 f4             	pushl  -0xc(%ebp)
  801279:	e8 59 ff ff ff       	call   8011d7 <fd_close>
  80127e:	83 c4 10             	add    $0x10,%esp
}
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <close_all>:

void
close_all(void)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	53                   	push   %ebx
  801287:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80128a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	53                   	push   %ebx
  801293:	e8 c0 ff ff ff       	call   801258 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801298:	83 c3 01             	add    $0x1,%ebx
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	83 fb 20             	cmp    $0x20,%ebx
  8012a1:	75 ec                	jne    80128f <close_all+0xc>
		close(i);
}
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	57                   	push   %edi
  8012ac:	56                   	push   %esi
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 2c             	sub    $0x2c,%esp
  8012b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012b7:	50                   	push   %eax
  8012b8:	ff 75 08             	pushl  0x8(%ebp)
  8012bb:	e8 6e fe ff ff       	call   80112e <fd_lookup>
  8012c0:	83 c4 08             	add    $0x8,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	0f 88 c1 00 00 00    	js     80138c <dup+0xe4>
		return r;
	close(newfdnum);
  8012cb:	83 ec 0c             	sub    $0xc,%esp
  8012ce:	56                   	push   %esi
  8012cf:	e8 84 ff ff ff       	call   801258 <close>

	newfd = INDEX2FD(newfdnum);
  8012d4:	89 f3                	mov    %esi,%ebx
  8012d6:	c1 e3 0c             	shl    $0xc,%ebx
  8012d9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012df:	83 c4 04             	add    $0x4,%esp
  8012e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012e5:	e8 de fd ff ff       	call   8010c8 <fd2data>
  8012ea:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ec:	89 1c 24             	mov    %ebx,(%esp)
  8012ef:	e8 d4 fd ff ff       	call   8010c8 <fd2data>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012fa:	89 f8                	mov    %edi,%eax
  8012fc:	c1 e8 16             	shr    $0x16,%eax
  8012ff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801306:	a8 01                	test   $0x1,%al
  801308:	74 37                	je     801341 <dup+0x99>
  80130a:	89 f8                	mov    %edi,%eax
  80130c:	c1 e8 0c             	shr    $0xc,%eax
  80130f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	74 26                	je     801341 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80131b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	25 07 0e 00 00       	and    $0xe07,%eax
  80132a:	50                   	push   %eax
  80132b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80132e:	6a 00                	push   $0x0
  801330:	57                   	push   %edi
  801331:	6a 00                	push   $0x0
  801333:	e8 87 f8 ff ff       	call   800bbf <sys_page_map>
  801338:	89 c7                	mov    %eax,%edi
  80133a:	83 c4 20             	add    $0x20,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 2e                	js     80136f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801341:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801344:	89 d0                	mov    %edx,%eax
  801346:	c1 e8 0c             	shr    $0xc,%eax
  801349:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	25 07 0e 00 00       	and    $0xe07,%eax
  801358:	50                   	push   %eax
  801359:	53                   	push   %ebx
  80135a:	6a 00                	push   $0x0
  80135c:	52                   	push   %edx
  80135d:	6a 00                	push   $0x0
  80135f:	e8 5b f8 ff ff       	call   800bbf <sys_page_map>
  801364:	89 c7                	mov    %eax,%edi
  801366:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801369:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136b:	85 ff                	test   %edi,%edi
  80136d:	79 1d                	jns    80138c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80136f:	83 ec 08             	sub    $0x8,%esp
  801372:	53                   	push   %ebx
  801373:	6a 00                	push   $0x0
  801375:	e8 87 f8 ff ff       	call   800c01 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801380:	6a 00                	push   $0x0
  801382:	e8 7a f8 ff ff       	call   800c01 <sys_page_unmap>
	return r;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	89 f8                	mov    %edi,%eax
}
  80138c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138f:	5b                   	pop    %ebx
  801390:	5e                   	pop    %esi
  801391:	5f                   	pop    %edi
  801392:	5d                   	pop    %ebp
  801393:	c3                   	ret    

00801394 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801394:	55                   	push   %ebp
  801395:	89 e5                	mov    %esp,%ebp
  801397:	53                   	push   %ebx
  801398:	83 ec 14             	sub    $0x14,%esp
  80139b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80139e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013a1:	50                   	push   %eax
  8013a2:	53                   	push   %ebx
  8013a3:	e8 86 fd ff ff       	call   80112e <fd_lookup>
  8013a8:	83 c4 08             	add    $0x8,%esp
  8013ab:	89 c2                	mov    %eax,%edx
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	78 6d                	js     80141e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b7:	50                   	push   %eax
  8013b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013bb:	ff 30                	pushl  (%eax)
  8013bd:	e8 c2 fd ff ff       	call   801184 <dev_lookup>
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 4c                	js     801415 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013cc:	8b 42 08             	mov    0x8(%edx),%eax
  8013cf:	83 e0 03             	and    $0x3,%eax
  8013d2:	83 f8 01             	cmp    $0x1,%eax
  8013d5:	75 21                	jne    8013f8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8013dc:	8b 40 48             	mov    0x48(%eax),%eax
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	50                   	push   %eax
  8013e4:	68 21 2b 80 00       	push   $0x802b21
  8013e9:	e8 e6 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013f6:	eb 26                	jmp    80141e <read+0x8a>
	}
	if (!dev->dev_read)
  8013f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fb:	8b 40 08             	mov    0x8(%eax),%eax
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 17                	je     801419 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801402:	83 ec 04             	sub    $0x4,%esp
  801405:	ff 75 10             	pushl  0x10(%ebp)
  801408:	ff 75 0c             	pushl  0xc(%ebp)
  80140b:	52                   	push   %edx
  80140c:	ff d0                	call   *%eax
  80140e:	89 c2                	mov    %eax,%edx
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	eb 09                	jmp    80141e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801415:	89 c2                	mov    %eax,%edx
  801417:	eb 05                	jmp    80141e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801419:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80141e:	89 d0                	mov    %edx,%eax
  801420:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	57                   	push   %edi
  801429:	56                   	push   %esi
  80142a:	53                   	push   %ebx
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801431:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801434:	bb 00 00 00 00       	mov    $0x0,%ebx
  801439:	eb 21                	jmp    80145c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	89 f0                	mov    %esi,%eax
  801440:	29 d8                	sub    %ebx,%eax
  801442:	50                   	push   %eax
  801443:	89 d8                	mov    %ebx,%eax
  801445:	03 45 0c             	add    0xc(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	57                   	push   %edi
  80144a:	e8 45 ff ff ff       	call   801394 <read>
		if (m < 0)
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 10                	js     801466 <readn+0x41>
			return m;
		if (m == 0)
  801456:	85 c0                	test   %eax,%eax
  801458:	74 0a                	je     801464 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145a:	01 c3                	add    %eax,%ebx
  80145c:	39 f3                	cmp    %esi,%ebx
  80145e:	72 db                	jb     80143b <readn+0x16>
  801460:	89 d8                	mov    %ebx,%eax
  801462:	eb 02                	jmp    801466 <readn+0x41>
  801464:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801466:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801469:	5b                   	pop    %ebx
  80146a:	5e                   	pop    %esi
  80146b:	5f                   	pop    %edi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 14             	sub    $0x14,%esp
  801475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801478:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	53                   	push   %ebx
  80147d:	e8 ac fc ff ff       	call   80112e <fd_lookup>
  801482:	83 c4 08             	add    $0x8,%esp
  801485:	89 c2                	mov    %eax,%edx
  801487:	85 c0                	test   %eax,%eax
  801489:	78 68                	js     8014f3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801495:	ff 30                	pushl  (%eax)
  801497:	e8 e8 fc ff ff       	call   801184 <dev_lookup>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 47                	js     8014ea <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014aa:	75 21                	jne    8014cd <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8014b1:	8b 40 48             	mov    0x48(%eax),%eax
  8014b4:	83 ec 04             	sub    $0x4,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	50                   	push   %eax
  8014b9:	68 3d 2b 80 00       	push   $0x802b3d
  8014be:	e8 11 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014cb:	eb 26                	jmp    8014f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014d0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014d3:	85 d2                	test   %edx,%edx
  8014d5:	74 17                	je     8014ee <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	ff 75 10             	pushl  0x10(%ebp)
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	50                   	push   %eax
  8014e1:	ff d2                	call   *%edx
  8014e3:	89 c2                	mov    %eax,%edx
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	eb 09                	jmp    8014f3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	eb 05                	jmp    8014f3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014f3:	89 d0                	mov    %edx,%eax
  8014f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801500:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	e8 22 fc ff ff       	call   80112e <fd_lookup>
  80150c:	83 c4 08             	add    $0x8,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 0e                	js     801521 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801513:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801516:	8b 55 0c             	mov    0xc(%ebp),%edx
  801519:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80151c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801521:	c9                   	leave  
  801522:	c3                   	ret    

00801523 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 14             	sub    $0x14,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	50                   	push   %eax
  801531:	53                   	push   %ebx
  801532:	e8 f7 fb ff ff       	call   80112e <fd_lookup>
  801537:	83 c4 08             	add    $0x8,%esp
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 65                	js     8015a5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	ff 30                	pushl  (%eax)
  80154c:	e8 33 fc ff ff       	call   801184 <dev_lookup>
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	85 c0                	test   %eax,%eax
  801556:	78 44                	js     80159c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801558:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80155f:	75 21                	jne    801582 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801561:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801566:	8b 40 48             	mov    0x48(%eax),%eax
  801569:	83 ec 04             	sub    $0x4,%esp
  80156c:	53                   	push   %ebx
  80156d:	50                   	push   %eax
  80156e:	68 00 2b 80 00       	push   $0x802b00
  801573:	e8 5c ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801580:	eb 23                	jmp    8015a5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	8b 52 18             	mov    0x18(%edx),%edx
  801588:	85 d2                	test   %edx,%edx
  80158a:	74 14                	je     8015a0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	ff 75 0c             	pushl  0xc(%ebp)
  801592:	50                   	push   %eax
  801593:	ff d2                	call   *%edx
  801595:	89 c2                	mov    %eax,%edx
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	eb 09                	jmp    8015a5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	89 c2                	mov    %eax,%edx
  80159e:	eb 05                	jmp    8015a5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015a5:	89 d0                	mov    %edx,%eax
  8015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	e8 6c fb ff ff       	call   80112e <fd_lookup>
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 58                	js     801623 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d5:	ff 30                	pushl  (%eax)
  8015d7:	e8 a8 fb ff ff       	call   801184 <dev_lookup>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 37                	js     80161a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ea:	74 32                	je     80161e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015f6:	00 00 00 
	stat->st_isdir = 0;
  8015f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801600:	00 00 00 
	stat->st_dev = dev;
  801603:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	53                   	push   %ebx
  80160d:	ff 75 f0             	pushl  -0x10(%ebp)
  801610:	ff 50 14             	call   *0x14(%eax)
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	56                   	push   %esi
  80162e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	6a 00                	push   $0x0
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 ef 01 00 00       	call   80182b <open>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 1b                	js     801660 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	ff 75 0c             	pushl  0xc(%ebp)
  80164b:	50                   	push   %eax
  80164c:	e8 5b ff ff ff       	call   8015ac <fstat>
  801651:	89 c6                	mov    %eax,%esi
	close(fd);
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 fd fb ff ff       	call   801258 <close>
	return r;
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	89 f0                	mov    %esi,%eax
}
  801660:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801663:	5b                   	pop    %ebx
  801664:	5e                   	pop    %esi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	89 c6                	mov    %eax,%esi
  80166e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801670:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801677:	75 12                	jne    80168b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	6a 01                	push   $0x1
  80167e:	e8 33 0d 00 00       	call   8023b6 <ipc_find_env>
  801683:	a3 00 40 80 00       	mov    %eax,0x804000
  801688:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80168b:	6a 07                	push   $0x7
  80168d:	68 00 50 80 00       	push   $0x805000
  801692:	56                   	push   %esi
  801693:	ff 35 00 40 80 00    	pushl  0x804000
  801699:	e8 c9 0c 00 00       	call   802367 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80169e:	83 c4 0c             	add    $0xc,%esp
  8016a1:	6a 00                	push   $0x0
  8016a3:	53                   	push   %ebx
  8016a4:	6a 00                	push   $0x0
  8016a6:	e8 46 0c 00 00       	call   8022f1 <ipc_recv>
}
  8016ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016be:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016d5:	e8 8d ff ff ff       	call   801667 <fsipc>
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016f7:	e8 6b ff ff ff       	call   801667 <fsipc>
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801708:	8b 45 08             	mov    0x8(%ebp),%eax
  80170b:	8b 40 0c             	mov    0xc(%eax),%eax
  80170e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801713:	ba 00 00 00 00       	mov    $0x0,%edx
  801718:	b8 05 00 00 00       	mov    $0x5,%eax
  80171d:	e8 45 ff ff ff       	call   801667 <fsipc>
  801722:	85 c0                	test   %eax,%eax
  801724:	78 2c                	js     801752 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801726:	83 ec 08             	sub    $0x8,%esp
  801729:	68 00 50 80 00       	push   $0x805000
  80172e:	53                   	push   %ebx
  80172f:	e8 45 f0 ff ff       	call   800779 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801734:	a1 80 50 80 00       	mov    0x805080,%eax
  801739:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173f:	a1 84 50 80 00       	mov    0x805084,%eax
  801744:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	53                   	push   %ebx
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801761:	8b 55 08             	mov    0x8(%ebp),%edx
  801764:	8b 52 0c             	mov    0xc(%edx),%edx
  801767:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80176d:	a3 04 50 80 00       	mov    %eax,0x805004
  801772:	3d 08 50 80 00       	cmp    $0x805008,%eax
  801777:	bb 08 50 80 00       	mov    $0x805008,%ebx
  80177c:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  80177f:	53                   	push   %ebx
  801780:	ff 75 0c             	pushl  0xc(%ebp)
  801783:	68 08 50 80 00       	push   $0x805008
  801788:	e8 7e f1 ff ff       	call   80090b <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80178d:	ba 00 00 00 00       	mov    $0x0,%edx
  801792:	b8 04 00 00 00       	mov    $0x4,%eax
  801797:	e8 cb fe ff ff       	call   801667 <fsipc>
  80179c:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017bc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 03 00 00 00       	mov    $0x3,%eax
  8017cc:	e8 96 fe ff ff       	call   801667 <fsipc>
  8017d1:	89 c3                	mov    %eax,%ebx
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 4b                	js     801822 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017d7:	39 c6                	cmp    %eax,%esi
  8017d9:	73 16                	jae    8017f1 <devfile_read+0x48>
  8017db:	68 70 2b 80 00       	push   $0x802b70
  8017e0:	68 77 2b 80 00       	push   $0x802b77
  8017e5:	6a 7c                	push   $0x7c
  8017e7:	68 8c 2b 80 00       	push   $0x802b8c
  8017ec:	e8 24 0a 00 00       	call   802215 <_panic>
	assert(r <= PGSIZE);
  8017f1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017f6:	7e 16                	jle    80180e <devfile_read+0x65>
  8017f8:	68 97 2b 80 00       	push   $0x802b97
  8017fd:	68 77 2b 80 00       	push   $0x802b77
  801802:	6a 7d                	push   $0x7d
  801804:	68 8c 2b 80 00       	push   $0x802b8c
  801809:	e8 07 0a 00 00       	call   802215 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80180e:	83 ec 04             	sub    $0x4,%esp
  801811:	50                   	push   %eax
  801812:	68 00 50 80 00       	push   $0x805000
  801817:	ff 75 0c             	pushl  0xc(%ebp)
  80181a:	e8 ec f0 ff ff       	call   80090b <memmove>
	return r;
  80181f:	83 c4 10             	add    $0x10,%esp
}
  801822:	89 d8                	mov    %ebx,%eax
  801824:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801827:	5b                   	pop    %ebx
  801828:	5e                   	pop    %esi
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	53                   	push   %ebx
  80182f:	83 ec 20             	sub    $0x20,%esp
  801832:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801835:	53                   	push   %ebx
  801836:	e8 05 ef ff ff       	call   800740 <strlen>
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801843:	7f 67                	jg     8018ac <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801845:	83 ec 0c             	sub    $0xc,%esp
  801848:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184b:	50                   	push   %eax
  80184c:	e8 8e f8 ff ff       	call   8010df <fd_alloc>
  801851:	83 c4 10             	add    $0x10,%esp
		return r;
  801854:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801856:	85 c0                	test   %eax,%eax
  801858:	78 57                	js     8018b1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	53                   	push   %ebx
  80185e:	68 00 50 80 00       	push   $0x805000
  801863:	e8 11 ef ff ff       	call   800779 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801870:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801873:	b8 01 00 00 00       	mov    $0x1,%eax
  801878:	e8 ea fd ff ff       	call   801667 <fsipc>
  80187d:	89 c3                	mov    %eax,%ebx
  80187f:	83 c4 10             	add    $0x10,%esp
  801882:	85 c0                	test   %eax,%eax
  801884:	79 14                	jns    80189a <open+0x6f>
		fd_close(fd, 0);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	6a 00                	push   $0x0
  80188b:	ff 75 f4             	pushl  -0xc(%ebp)
  80188e:	e8 44 f9 ff ff       	call   8011d7 <fd_close>
		return r;
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	89 da                	mov    %ebx,%edx
  801898:	eb 17                	jmp    8018b1 <open+0x86>
	}

	return fd2num(fd);
  80189a:	83 ec 0c             	sub    $0xc,%esp
  80189d:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a0:	e8 13 f8 ff ff       	call   8010b8 <fd2num>
  8018a5:	89 c2                	mov    %eax,%edx
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	eb 05                	jmp    8018b1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ac:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018b1:	89 d0                	mov    %edx,%eax
  8018b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b6:	c9                   	leave  
  8018b7:	c3                   	ret    

008018b8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8018c8:	e8 9a fd ff ff       	call   801667 <fsipc>
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	56                   	push   %esi
  8018d3:	53                   	push   %ebx
  8018d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	ff 75 08             	pushl  0x8(%ebp)
  8018dd:	e8 e6 f7 ff ff       	call   8010c8 <fd2data>
  8018e2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018e4:	83 c4 08             	add    $0x8,%esp
  8018e7:	68 a3 2b 80 00       	push   $0x802ba3
  8018ec:	53                   	push   %ebx
  8018ed:	e8 87 ee ff ff       	call   800779 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018f2:	8b 46 04             	mov    0x4(%esi),%eax
  8018f5:	2b 06                	sub    (%esi),%eax
  8018f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801904:	00 00 00 
	stat->st_dev = &devpipe;
  801907:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80190e:	30 80 00 
	return 0;
}
  801911:	b8 00 00 00 00       	mov    $0x0,%eax
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801927:	53                   	push   %ebx
  801928:	6a 00                	push   $0x0
  80192a:	e8 d2 f2 ff ff       	call   800c01 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80192f:	89 1c 24             	mov    %ebx,(%esp)
  801932:	e8 91 f7 ff ff       	call   8010c8 <fd2data>
  801937:	83 c4 08             	add    $0x8,%esp
  80193a:	50                   	push   %eax
  80193b:	6a 00                	push   $0x0
  80193d:	e8 bf f2 ff ff       	call   800c01 <sys_page_unmap>
}
  801942:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	57                   	push   %edi
  80194b:	56                   	push   %esi
  80194c:	53                   	push   %ebx
  80194d:	83 ec 1c             	sub    $0x1c,%esp
  801950:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801953:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801955:	a1 08 40 80 00       	mov    0x804008,%eax
  80195a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	ff 75 e0             	pushl  -0x20(%ebp)
  801963:	e8 87 0a 00 00       	call   8023ef <pageref>
  801968:	89 c3                	mov    %eax,%ebx
  80196a:	89 3c 24             	mov    %edi,(%esp)
  80196d:	e8 7d 0a 00 00       	call   8023ef <pageref>
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	39 c3                	cmp    %eax,%ebx
  801977:	0f 94 c1             	sete   %cl
  80197a:	0f b6 c9             	movzbl %cl,%ecx
  80197d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801980:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801986:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801989:	39 ce                	cmp    %ecx,%esi
  80198b:	74 1b                	je     8019a8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80198d:	39 c3                	cmp    %eax,%ebx
  80198f:	75 c4                	jne    801955 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801991:	8b 42 58             	mov    0x58(%edx),%eax
  801994:	ff 75 e4             	pushl  -0x1c(%ebp)
  801997:	50                   	push   %eax
  801998:	56                   	push   %esi
  801999:	68 aa 2b 80 00       	push   $0x802baa
  80199e:	e8 31 e8 ff ff       	call   8001d4 <cprintf>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	eb ad                	jmp    801955 <_pipeisclosed+0xe>
	}
}
  8019a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ae:	5b                   	pop    %ebx
  8019af:	5e                   	pop    %esi
  8019b0:	5f                   	pop    %edi
  8019b1:	5d                   	pop    %ebp
  8019b2:	c3                   	ret    

008019b3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	57                   	push   %edi
  8019b7:	56                   	push   %esi
  8019b8:	53                   	push   %ebx
  8019b9:	83 ec 28             	sub    $0x28,%esp
  8019bc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019bf:	56                   	push   %esi
  8019c0:	e8 03 f7 ff ff       	call   8010c8 <fd2data>
  8019c5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8019cf:	eb 4b                	jmp    801a1c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019d1:	89 da                	mov    %ebx,%edx
  8019d3:	89 f0                	mov    %esi,%eax
  8019d5:	e8 6d ff ff ff       	call   801947 <_pipeisclosed>
  8019da:	85 c0                	test   %eax,%eax
  8019dc:	75 48                	jne    801a26 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019de:	e8 7a f1 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019e3:	8b 43 04             	mov    0x4(%ebx),%eax
  8019e6:	8b 0b                	mov    (%ebx),%ecx
  8019e8:	8d 51 20             	lea    0x20(%ecx),%edx
  8019eb:	39 d0                	cmp    %edx,%eax
  8019ed:	73 e2                	jae    8019d1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019f2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019f6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	c1 fa 1f             	sar    $0x1f,%edx
  8019fe:	89 d1                	mov    %edx,%ecx
  801a00:	c1 e9 1b             	shr    $0x1b,%ecx
  801a03:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a06:	83 e2 1f             	and    $0x1f,%edx
  801a09:	29 ca                	sub    %ecx,%edx
  801a0b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a0f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a13:	83 c0 01             	add    $0x1,%eax
  801a16:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a19:	83 c7 01             	add    $0x1,%edi
  801a1c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a1f:	75 c2                	jne    8019e3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a21:	8b 45 10             	mov    0x10(%ebp),%eax
  801a24:	eb 05                	jmp    801a2b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a26:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	57                   	push   %edi
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	83 ec 18             	sub    $0x18,%esp
  801a3c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a3f:	57                   	push   %edi
  801a40:	e8 83 f6 ff ff       	call   8010c8 <fd2data>
  801a45:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a47:	83 c4 10             	add    $0x10,%esp
  801a4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4f:	eb 3d                	jmp    801a8e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a51:	85 db                	test   %ebx,%ebx
  801a53:	74 04                	je     801a59 <devpipe_read+0x26>
				return i;
  801a55:	89 d8                	mov    %ebx,%eax
  801a57:	eb 44                	jmp    801a9d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a59:	89 f2                	mov    %esi,%edx
  801a5b:	89 f8                	mov    %edi,%eax
  801a5d:	e8 e5 fe ff ff       	call   801947 <_pipeisclosed>
  801a62:	85 c0                	test   %eax,%eax
  801a64:	75 32                	jne    801a98 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a66:	e8 f2 f0 ff ff       	call   800b5d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a6b:	8b 06                	mov    (%esi),%eax
  801a6d:	3b 46 04             	cmp    0x4(%esi),%eax
  801a70:	74 df                	je     801a51 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a72:	99                   	cltd   
  801a73:	c1 ea 1b             	shr    $0x1b,%edx
  801a76:	01 d0                	add    %edx,%eax
  801a78:	83 e0 1f             	and    $0x1f,%eax
  801a7b:	29 d0                	sub    %edx,%eax
  801a7d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a85:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a88:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a8b:	83 c3 01             	add    $0x1,%ebx
  801a8e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a91:	75 d8                	jne    801a6b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a93:	8b 45 10             	mov    0x10(%ebp),%eax
  801a96:	eb 05                	jmp    801a9d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a98:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab0:	50                   	push   %eax
  801ab1:	e8 29 f6 ff ff       	call   8010df <fd_alloc>
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	89 c2                	mov    %eax,%edx
  801abb:	85 c0                	test   %eax,%eax
  801abd:	0f 88 2c 01 00 00    	js     801bef <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ac3:	83 ec 04             	sub    $0x4,%esp
  801ac6:	68 07 04 00 00       	push   $0x407
  801acb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ace:	6a 00                	push   $0x0
  801ad0:	e8 a7 f0 ff ff       	call   800b7c <sys_page_alloc>
  801ad5:	83 c4 10             	add    $0x10,%esp
  801ad8:	89 c2                	mov    %eax,%edx
  801ada:	85 c0                	test   %eax,%eax
  801adc:	0f 88 0d 01 00 00    	js     801bef <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ae8:	50                   	push   %eax
  801ae9:	e8 f1 f5 ff ff       	call   8010df <fd_alloc>
  801aee:	89 c3                	mov    %eax,%ebx
  801af0:	83 c4 10             	add    $0x10,%esp
  801af3:	85 c0                	test   %eax,%eax
  801af5:	0f 88 e2 00 00 00    	js     801bdd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801afb:	83 ec 04             	sub    $0x4,%esp
  801afe:	68 07 04 00 00       	push   $0x407
  801b03:	ff 75 f0             	pushl  -0x10(%ebp)
  801b06:	6a 00                	push   $0x0
  801b08:	e8 6f f0 ff ff       	call   800b7c <sys_page_alloc>
  801b0d:	89 c3                	mov    %eax,%ebx
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	0f 88 c3 00 00 00    	js     801bdd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b1a:	83 ec 0c             	sub    $0xc,%esp
  801b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801b20:	e8 a3 f5 ff ff       	call   8010c8 <fd2data>
  801b25:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b27:	83 c4 0c             	add    $0xc,%esp
  801b2a:	68 07 04 00 00       	push   $0x407
  801b2f:	50                   	push   %eax
  801b30:	6a 00                	push   $0x0
  801b32:	e8 45 f0 ff ff       	call   800b7c <sys_page_alloc>
  801b37:	89 c3                	mov    %eax,%ebx
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	0f 88 89 00 00 00    	js     801bcd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b44:	83 ec 0c             	sub    $0xc,%esp
  801b47:	ff 75 f0             	pushl  -0x10(%ebp)
  801b4a:	e8 79 f5 ff ff       	call   8010c8 <fd2data>
  801b4f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b56:	50                   	push   %eax
  801b57:	6a 00                	push   $0x0
  801b59:	56                   	push   %esi
  801b5a:	6a 00                	push   $0x0
  801b5c:	e8 5e f0 ff ff       	call   800bbf <sys_page_map>
  801b61:	89 c3                	mov    %eax,%ebx
  801b63:	83 c4 20             	add    $0x20,%esp
  801b66:	85 c0                	test   %eax,%eax
  801b68:	78 55                	js     801bbf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b6a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b73:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b78:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b7f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b88:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b94:	83 ec 0c             	sub    $0xc,%esp
  801b97:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9a:	e8 19 f5 ff ff       	call   8010b8 <fd2num>
  801b9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ba4:	83 c4 04             	add    $0x4,%esp
  801ba7:	ff 75 f0             	pushl  -0x10(%ebp)
  801baa:	e8 09 f5 ff ff       	call   8010b8 <fd2num>
  801baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbd:	eb 30                	jmp    801bef <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	56                   	push   %esi
  801bc3:	6a 00                	push   $0x0
  801bc5:	e8 37 f0 ff ff       	call   800c01 <sys_page_unmap>
  801bca:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bcd:	83 ec 08             	sub    $0x8,%esp
  801bd0:	ff 75 f0             	pushl  -0x10(%ebp)
  801bd3:	6a 00                	push   $0x0
  801bd5:	e8 27 f0 ff ff       	call   800c01 <sys_page_unmap>
  801bda:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bdd:	83 ec 08             	sub    $0x8,%esp
  801be0:	ff 75 f4             	pushl  -0xc(%ebp)
  801be3:	6a 00                	push   $0x0
  801be5:	e8 17 f0 ff ff       	call   800c01 <sys_page_unmap>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bfe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c01:	50                   	push   %eax
  801c02:	ff 75 08             	pushl  0x8(%ebp)
  801c05:	e8 24 f5 ff ff       	call   80112e <fd_lookup>
  801c0a:	83 c4 10             	add    $0x10,%esp
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 18                	js     801c29 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	e8 ac f4 ff ff       	call   8010c8 <fd2data>
	return _pipeisclosed(fd, p);
  801c1c:	89 c2                	mov    %eax,%edx
  801c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c21:	e8 21 fd ff ff       	call   801947 <_pipeisclosed>
  801c26:	83 c4 10             	add    $0x10,%esp
}
  801c29:	c9                   	leave  
  801c2a:	c3                   	ret    

00801c2b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c31:	68 c2 2b 80 00       	push   $0x802bc2
  801c36:	ff 75 0c             	pushl  0xc(%ebp)
  801c39:	e8 3b eb ff ff       	call   800779 <strcpy>
	return 0;
}
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    

00801c45 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	53                   	push   %ebx
  801c49:	83 ec 10             	sub    $0x10,%esp
  801c4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c4f:	53                   	push   %ebx
  801c50:	e8 9a 07 00 00       	call   8023ef <pageref>
  801c55:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801c58:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c5d:	83 f8 01             	cmp    $0x1,%eax
  801c60:	75 10                	jne    801c72 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c62:	83 ec 0c             	sub    $0xc,%esp
  801c65:	ff 73 0c             	pushl  0xc(%ebx)
  801c68:	e8 c0 02 00 00       	call   801f2d <nsipc_close>
  801c6d:	89 c2                	mov    %eax,%edx
  801c6f:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c72:	89 d0                	mov    %edx,%eax
  801c74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c7f:	6a 00                	push   $0x0
  801c81:	ff 75 10             	pushl  0x10(%ebp)
  801c84:	ff 75 0c             	pushl  0xc(%ebp)
  801c87:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8a:	ff 70 0c             	pushl  0xc(%eax)
  801c8d:	e8 78 03 00 00       	call   80200a <nsipc_send>
}
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    

00801c94 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c9a:	6a 00                	push   $0x0
  801c9c:	ff 75 10             	pushl  0x10(%ebp)
  801c9f:	ff 75 0c             	pushl  0xc(%ebp)
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	ff 70 0c             	pushl  0xc(%eax)
  801ca8:	e8 f1 02 00 00       	call   801f9e <nsipc_recv>
}
  801cad:	c9                   	leave  
  801cae:	c3                   	ret    

00801caf <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cb5:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cb8:	52                   	push   %edx
  801cb9:	50                   	push   %eax
  801cba:	e8 6f f4 ff ff       	call   80112e <fd_lookup>
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	78 17                	js     801cdd <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc9:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801ccf:	39 08                	cmp    %ecx,(%eax)
  801cd1:	75 05                	jne    801cd8 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801cd3:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd6:	eb 05                	jmp    801cdd <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801cd8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801cdd:	c9                   	leave  
  801cde:	c3                   	ret    

00801cdf <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ce9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cec:	50                   	push   %eax
  801ced:	e8 ed f3 ff ff       	call   8010df <fd_alloc>
  801cf2:	89 c3                	mov    %eax,%ebx
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	78 1b                	js     801d16 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cfb:	83 ec 04             	sub    $0x4,%esp
  801cfe:	68 07 04 00 00       	push   $0x407
  801d03:	ff 75 f4             	pushl  -0xc(%ebp)
  801d06:	6a 00                	push   $0x0
  801d08:	e8 6f ee ff ff       	call   800b7c <sys_page_alloc>
  801d0d:	89 c3                	mov    %eax,%ebx
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	85 c0                	test   %eax,%eax
  801d14:	79 10                	jns    801d26 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d16:	83 ec 0c             	sub    $0xc,%esp
  801d19:	56                   	push   %esi
  801d1a:	e8 0e 02 00 00       	call   801f2d <nsipc_close>
		return r;
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	89 d8                	mov    %ebx,%eax
  801d24:	eb 24                	jmp    801d4a <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d26:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d34:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d3b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	50                   	push   %eax
  801d42:	e8 71 f3 ff ff       	call   8010b8 <fd2num>
  801d47:	83 c4 10             	add    $0x10,%esp
}
  801d4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	e8 50 ff ff ff       	call   801caf <fd2sockid>
		return r;
  801d5f:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 1f                	js     801d84 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d65:	83 ec 04             	sub    $0x4,%esp
  801d68:	ff 75 10             	pushl  0x10(%ebp)
  801d6b:	ff 75 0c             	pushl  0xc(%ebp)
  801d6e:	50                   	push   %eax
  801d6f:	e8 12 01 00 00       	call   801e86 <nsipc_accept>
  801d74:	83 c4 10             	add    $0x10,%esp
		return r;
  801d77:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 07                	js     801d84 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d7d:	e8 5d ff ff ff       	call   801cdf <alloc_sockfd>
  801d82:	89 c1                	mov    %eax,%ecx
}
  801d84:	89 c8                	mov    %ecx,%eax
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	e8 19 ff ff ff       	call   801caf <fd2sockid>
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 12                	js     801dac <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d9a:	83 ec 04             	sub    $0x4,%esp
  801d9d:	ff 75 10             	pushl  0x10(%ebp)
  801da0:	ff 75 0c             	pushl  0xc(%ebp)
  801da3:	50                   	push   %eax
  801da4:	e8 2d 01 00 00       	call   801ed6 <nsipc_bind>
  801da9:	83 c4 10             	add    $0x10,%esp
}
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <shutdown>:

int
shutdown(int s, int how)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	e8 f3 fe ff ff       	call   801caf <fd2sockid>
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 0f                	js     801dcf <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	ff 75 0c             	pushl  0xc(%ebp)
  801dc6:	50                   	push   %eax
  801dc7:	e8 3f 01 00 00       	call   801f0b <nsipc_shutdown>
  801dcc:	83 c4 10             	add    $0x10,%esp
}
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	e8 d0 fe ff ff       	call   801caf <fd2sockid>
  801ddf:	85 c0                	test   %eax,%eax
  801de1:	78 12                	js     801df5 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801de3:	83 ec 04             	sub    $0x4,%esp
  801de6:	ff 75 10             	pushl  0x10(%ebp)
  801de9:	ff 75 0c             	pushl  0xc(%ebp)
  801dec:	50                   	push   %eax
  801ded:	e8 55 01 00 00       	call   801f47 <nsipc_connect>
  801df2:	83 c4 10             	add    $0x10,%esp
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <listen>:

int
listen(int s, int backlog)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801e00:	e8 aa fe ff ff       	call   801caf <fd2sockid>
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 0f                	js     801e18 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e09:	83 ec 08             	sub    $0x8,%esp
  801e0c:	ff 75 0c             	pushl  0xc(%ebp)
  801e0f:	50                   	push   %eax
  801e10:	e8 67 01 00 00       	call   801f7c <nsipc_listen>
  801e15:	83 c4 10             	add    $0x10,%esp
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e20:	ff 75 10             	pushl  0x10(%ebp)
  801e23:	ff 75 0c             	pushl  0xc(%ebp)
  801e26:	ff 75 08             	pushl  0x8(%ebp)
  801e29:	e8 3a 02 00 00       	call   802068 <nsipc_socket>
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	85 c0                	test   %eax,%eax
  801e33:	78 05                	js     801e3a <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801e35:	e8 a5 fe ff ff       	call   801cdf <alloc_sockfd>
}
  801e3a:	c9                   	leave  
  801e3b:	c3                   	ret    

00801e3c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	53                   	push   %ebx
  801e40:	83 ec 04             	sub    $0x4,%esp
  801e43:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e45:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e4c:	75 12                	jne    801e60 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	6a 02                	push   $0x2
  801e53:	e8 5e 05 00 00       	call   8023b6 <ipc_find_env>
  801e58:	a3 04 40 80 00       	mov    %eax,0x804004
  801e5d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e60:	6a 07                	push   $0x7
  801e62:	68 00 60 80 00       	push   $0x806000
  801e67:	53                   	push   %ebx
  801e68:	ff 35 04 40 80 00    	pushl  0x804004
  801e6e:	e8 f4 04 00 00       	call   802367 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e73:	83 c4 0c             	add    $0xc,%esp
  801e76:	6a 00                	push   $0x0
  801e78:	6a 00                	push   $0x0
  801e7a:	6a 00                	push   $0x0
  801e7c:	e8 70 04 00 00       	call   8022f1 <ipc_recv>
}
  801e81:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	56                   	push   %esi
  801e8a:	53                   	push   %ebx
  801e8b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e91:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e96:	8b 06                	mov    (%esi),%eax
  801e98:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e9d:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea2:	e8 95 ff ff ff       	call   801e3c <nsipc>
  801ea7:	89 c3                	mov    %eax,%ebx
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 20                	js     801ecd <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ead:	83 ec 04             	sub    $0x4,%esp
  801eb0:	ff 35 10 60 80 00    	pushl  0x806010
  801eb6:	68 00 60 80 00       	push   $0x806000
  801ebb:	ff 75 0c             	pushl  0xc(%ebp)
  801ebe:	e8 48 ea ff ff       	call   80090b <memmove>
		*addrlen = ret->ret_addrlen;
  801ec3:	a1 10 60 80 00       	mov    0x806010,%eax
  801ec8:	89 06                	mov    %eax,(%esi)
  801eca:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ecd:	89 d8                	mov    %ebx,%eax
  801ecf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed2:	5b                   	pop    %ebx
  801ed3:	5e                   	pop    %esi
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    

00801ed6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 08             	sub    $0x8,%esp
  801edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ee8:	53                   	push   %ebx
  801ee9:	ff 75 0c             	pushl  0xc(%ebp)
  801eec:	68 04 60 80 00       	push   $0x806004
  801ef1:	e8 15 ea ff ff       	call   80090b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ef6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801efc:	b8 02 00 00 00       	mov    $0x2,%eax
  801f01:	e8 36 ff ff ff       	call   801e3c <nsipc>
}
  801f06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f09:	c9                   	leave  
  801f0a:	c3                   	ret    

00801f0b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f11:	8b 45 08             	mov    0x8(%ebp),%eax
  801f14:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f21:	b8 03 00 00 00       	mov    $0x3,%eax
  801f26:	e8 11 ff ff ff       	call   801e3c <nsipc>
}
  801f2b:	c9                   	leave  
  801f2c:	c3                   	ret    

00801f2d <nsipc_close>:

int
nsipc_close(int s)
{
  801f2d:	55                   	push   %ebp
  801f2e:	89 e5                	mov    %esp,%ebp
  801f30:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f33:	8b 45 08             	mov    0x8(%ebp),%eax
  801f36:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f3b:	b8 04 00 00 00       	mov    $0x4,%eax
  801f40:	e8 f7 fe ff ff       	call   801e3c <nsipc>
}
  801f45:	c9                   	leave  
  801f46:	c3                   	ret    

00801f47 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f47:	55                   	push   %ebp
  801f48:	89 e5                	mov    %esp,%ebp
  801f4a:	53                   	push   %ebx
  801f4b:	83 ec 08             	sub    $0x8,%esp
  801f4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f59:	53                   	push   %ebx
  801f5a:	ff 75 0c             	pushl  0xc(%ebp)
  801f5d:	68 04 60 80 00       	push   $0x806004
  801f62:	e8 a4 e9 ff ff       	call   80090b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f67:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f6d:	b8 05 00 00 00       	mov    $0x5,%eax
  801f72:	e8 c5 fe ff ff       	call   801e3c <nsipc>
}
  801f77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7a:	c9                   	leave  
  801f7b:	c3                   	ret    

00801f7c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f82:	8b 45 08             	mov    0x8(%ebp),%eax
  801f85:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f92:	b8 06 00 00 00       	mov    $0x6,%eax
  801f97:	e8 a0 fe ff ff       	call   801e3c <nsipc>
}
  801f9c:	c9                   	leave  
  801f9d:	c3                   	ret    

00801f9e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	56                   	push   %esi
  801fa2:	53                   	push   %ebx
  801fa3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801fae:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801fb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb7:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801fbc:	b8 07 00 00 00       	mov    $0x7,%eax
  801fc1:	e8 76 fe ff ff       	call   801e3c <nsipc>
  801fc6:	89 c3                	mov    %eax,%ebx
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 35                	js     802001 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801fcc:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801fd1:	7f 04                	jg     801fd7 <nsipc_recv+0x39>
  801fd3:	39 c6                	cmp    %eax,%esi
  801fd5:	7d 16                	jge    801fed <nsipc_recv+0x4f>
  801fd7:	68 ce 2b 80 00       	push   $0x802bce
  801fdc:	68 77 2b 80 00       	push   $0x802b77
  801fe1:	6a 62                	push   $0x62
  801fe3:	68 e3 2b 80 00       	push   $0x802be3
  801fe8:	e8 28 02 00 00       	call   802215 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fed:	83 ec 04             	sub    $0x4,%esp
  801ff0:	50                   	push   %eax
  801ff1:	68 00 60 80 00       	push   $0x806000
  801ff6:	ff 75 0c             	pushl  0xc(%ebp)
  801ff9:	e8 0d e9 ff ff       	call   80090b <memmove>
  801ffe:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802001:	89 d8                	mov    %ebx,%eax
  802003:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    

0080200a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80200a:	55                   	push   %ebp
  80200b:	89 e5                	mov    %esp,%ebp
  80200d:	53                   	push   %ebx
  80200e:	83 ec 04             	sub    $0x4,%esp
  802011:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80201c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802022:	7e 16                	jle    80203a <nsipc_send+0x30>
  802024:	68 ef 2b 80 00       	push   $0x802bef
  802029:	68 77 2b 80 00       	push   $0x802b77
  80202e:	6a 6d                	push   $0x6d
  802030:	68 e3 2b 80 00       	push   $0x802be3
  802035:	e8 db 01 00 00       	call   802215 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80203a:	83 ec 04             	sub    $0x4,%esp
  80203d:	53                   	push   %ebx
  80203e:	ff 75 0c             	pushl  0xc(%ebp)
  802041:	68 0c 60 80 00       	push   $0x80600c
  802046:	e8 c0 e8 ff ff       	call   80090b <memmove>
	nsipcbuf.send.req_size = size;
  80204b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802051:	8b 45 14             	mov    0x14(%ebp),%eax
  802054:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802059:	b8 08 00 00 00       	mov    $0x8,%eax
  80205e:	e8 d9 fd ff ff       	call   801e3c <nsipc>
}
  802063:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802066:	c9                   	leave  
  802067:	c3                   	ret    

00802068 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80206e:	8b 45 08             	mov    0x8(%ebp),%eax
  802071:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802076:	8b 45 0c             	mov    0xc(%ebp),%eax
  802079:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80207e:	8b 45 10             	mov    0x10(%ebp),%eax
  802081:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802086:	b8 09 00 00 00       	mov    $0x9,%eax
  80208b:	e8 ac fd ff ff       	call   801e3c <nsipc>
}
  802090:	c9                   	leave  
  802091:	c3                   	ret    

00802092 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802095:	b8 00 00 00 00       	mov    $0x0,%eax
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    

0080209c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020a2:	68 fb 2b 80 00       	push   $0x802bfb
  8020a7:	ff 75 0c             	pushl  0xc(%ebp)
  8020aa:	e8 ca e6 ff ff       	call   800779 <strcpy>
	return 0;
}
  8020af:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b4:	c9                   	leave  
  8020b5:	c3                   	ret    

008020b6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	57                   	push   %edi
  8020ba:	56                   	push   %esi
  8020bb:	53                   	push   %ebx
  8020bc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020c2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020cd:	eb 2d                	jmp    8020fc <devcons_write+0x46>
		m = n - tot;
  8020cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020d2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8020d4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8020d7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8020dc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8020df:	83 ec 04             	sub    $0x4,%esp
  8020e2:	53                   	push   %ebx
  8020e3:	03 45 0c             	add    0xc(%ebp),%eax
  8020e6:	50                   	push   %eax
  8020e7:	57                   	push   %edi
  8020e8:	e8 1e e8 ff ff       	call   80090b <memmove>
		sys_cputs(buf, m);
  8020ed:	83 c4 08             	add    $0x8,%esp
  8020f0:	53                   	push   %ebx
  8020f1:	57                   	push   %edi
  8020f2:	e8 c9 e9 ff ff       	call   800ac0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020f7:	01 de                	add    %ebx,%esi
  8020f9:	83 c4 10             	add    $0x10,%esp
  8020fc:	89 f0                	mov    %esi,%eax
  8020fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  802101:	72 cc                	jb     8020cf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802103:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802106:	5b                   	pop    %ebx
  802107:	5e                   	pop    %esi
  802108:	5f                   	pop    %edi
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    

0080210b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 08             	sub    $0x8,%esp
  802111:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802116:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80211a:	74 2a                	je     802146 <devcons_read+0x3b>
  80211c:	eb 05                	jmp    802123 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80211e:	e8 3a ea ff ff       	call   800b5d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802123:	e8 b6 e9 ff ff       	call   800ade <sys_cgetc>
  802128:	85 c0                	test   %eax,%eax
  80212a:	74 f2                	je     80211e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80212c:	85 c0                	test   %eax,%eax
  80212e:	78 16                	js     802146 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802130:	83 f8 04             	cmp    $0x4,%eax
  802133:	74 0c                	je     802141 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802135:	8b 55 0c             	mov    0xc(%ebp),%edx
  802138:	88 02                	mov    %al,(%edx)
	return 1;
  80213a:	b8 01 00 00 00       	mov    $0x1,%eax
  80213f:	eb 05                	jmp    802146 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802141:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802146:	c9                   	leave  
  802147:	c3                   	ret    

00802148 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80214e:	8b 45 08             	mov    0x8(%ebp),%eax
  802151:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802154:	6a 01                	push   $0x1
  802156:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802159:	50                   	push   %eax
  80215a:	e8 61 e9 ff ff       	call   800ac0 <sys_cputs>
}
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	c9                   	leave  
  802163:	c3                   	ret    

00802164 <getchar>:

int
getchar(void)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80216a:	6a 01                	push   $0x1
  80216c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80216f:	50                   	push   %eax
  802170:	6a 00                	push   $0x0
  802172:	e8 1d f2 ff ff       	call   801394 <read>
	if (r < 0)
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	85 c0                	test   %eax,%eax
  80217c:	78 0f                	js     80218d <getchar+0x29>
		return r;
	if (r < 1)
  80217e:	85 c0                	test   %eax,%eax
  802180:	7e 06                	jle    802188 <getchar+0x24>
		return -E_EOF;
	return c;
  802182:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802186:	eb 05                	jmp    80218d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802188:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80218d:	c9                   	leave  
  80218e:	c3                   	ret    

0080218f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802195:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802198:	50                   	push   %eax
  802199:	ff 75 08             	pushl  0x8(%ebp)
  80219c:	e8 8d ef ff ff       	call   80112e <fd_lookup>
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 11                	js     8021b9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021b1:	39 10                	cmp    %edx,(%eax)
  8021b3:	0f 94 c0             	sete   %al
  8021b6:	0f b6 c0             	movzbl %al,%eax
}
  8021b9:	c9                   	leave  
  8021ba:	c3                   	ret    

008021bb <opencons>:

int
opencons(void)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c4:	50                   	push   %eax
  8021c5:	e8 15 ef ff ff       	call   8010df <fd_alloc>
  8021ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8021cd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8021cf:	85 c0                	test   %eax,%eax
  8021d1:	78 3e                	js     802211 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021d3:	83 ec 04             	sub    $0x4,%esp
  8021d6:	68 07 04 00 00       	push   $0x407
  8021db:	ff 75 f4             	pushl  -0xc(%ebp)
  8021de:	6a 00                	push   $0x0
  8021e0:	e8 97 e9 ff ff       	call   800b7c <sys_page_alloc>
  8021e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8021e8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021ea:	85 c0                	test   %eax,%eax
  8021ec:	78 23                	js     802211 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021ee:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802203:	83 ec 0c             	sub    $0xc,%esp
  802206:	50                   	push   %eax
  802207:	e8 ac ee ff ff       	call   8010b8 <fd2num>
  80220c:	89 c2                	mov    %eax,%edx
  80220e:	83 c4 10             	add    $0x10,%esp
}
  802211:	89 d0                	mov    %edx,%eax
  802213:	c9                   	leave  
  802214:	c3                   	ret    

00802215 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	56                   	push   %esi
  802219:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80221a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80221d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802223:	e8 16 e9 ff ff       	call   800b3e <sys_getenvid>
  802228:	83 ec 0c             	sub    $0xc,%esp
  80222b:	ff 75 0c             	pushl  0xc(%ebp)
  80222e:	ff 75 08             	pushl  0x8(%ebp)
  802231:	56                   	push   %esi
  802232:	50                   	push   %eax
  802233:	68 08 2c 80 00       	push   $0x802c08
  802238:	e8 97 df ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80223d:	83 c4 18             	add    $0x18,%esp
  802240:	53                   	push   %ebx
  802241:	ff 75 10             	pushl  0x10(%ebp)
  802244:	e8 3a df ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  802249:	c7 04 24 cf 26 80 00 	movl   $0x8026cf,(%esp)
  802250:	e8 7f df ff ff       	call   8001d4 <cprintf>
  802255:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802258:	cc                   	int3   
  802259:	eb fd                	jmp    802258 <_panic+0x43>

0080225b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80225b:	55                   	push   %ebp
  80225c:	89 e5                	mov    %esp,%ebp
  80225e:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802261:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802268:	75 56                	jne    8022c0 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  80226a:	83 ec 04             	sub    $0x4,%esp
  80226d:	6a 07                	push   $0x7
  80226f:	68 00 f0 bf ee       	push   $0xeebff000
  802274:	6a 00                	push   $0x0
  802276:	e8 01 e9 ff ff       	call   800b7c <sys_page_alloc>
  80227b:	83 c4 10             	add    $0x10,%esp
  80227e:	85 c0                	test   %eax,%eax
  802280:	74 14                	je     802296 <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  802282:	83 ec 04             	sub    $0x4,%esp
  802285:	68 89 2a 80 00       	push   $0x802a89
  80228a:	6a 21                	push   $0x21
  80228c:	68 2c 2c 80 00       	push   $0x802c2c
  802291:	e8 7f ff ff ff       	call   802215 <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  802296:	83 ec 08             	sub    $0x8,%esp
  802299:	68 ca 22 80 00       	push   $0x8022ca
  80229e:	6a 00                	push   $0x0
  8022a0:	e8 22 ea ff ff       	call   800cc7 <sys_env_set_pgfault_upcall>
  8022a5:	83 c4 10             	add    $0x10,%esp
  8022a8:	85 c0                	test   %eax,%eax
  8022aa:	74 14                	je     8022c0 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  8022ac:	83 ec 04             	sub    $0x4,%esp
  8022af:	68 3a 2c 80 00       	push   $0x802c3a
  8022b4:	6a 23                	push   $0x23
  8022b6:	68 2c 2c 80 00       	push   $0x802c2c
  8022bb:	e8 55 ff ff ff       	call   802215 <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c3:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8022c8:	c9                   	leave  
  8022c9:	c3                   	ret    

008022ca <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022ca:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022cb:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8022d0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022d2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  8022d5:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  8022d7:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  8022db:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  8022df:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  8022e0:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  8022e2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  8022e7:	83 c4 08             	add    $0x8,%esp
	popal
  8022ea:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8022eb:	83 c4 04             	add    $0x4,%esp
	popfl
  8022ee:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022ef:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8022f0:	c3                   	ret    

008022f1 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022f1:	55                   	push   %ebp
  8022f2:	89 e5                	mov    %esp,%ebp
  8022f4:	56                   	push   %esi
  8022f5:	53                   	push   %ebx
  8022f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8022f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8022ff:	85 c0                	test   %eax,%eax
  802301:	74 0e                	je     802311 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  802303:	83 ec 0c             	sub    $0xc,%esp
  802306:	50                   	push   %eax
  802307:	e8 20 ea ff ff       	call   800d2c <sys_ipc_recv>
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	eb 10                	jmp    802321 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  802311:	83 ec 0c             	sub    $0xc,%esp
  802314:	68 00 00 c0 ee       	push   $0xeec00000
  802319:	e8 0e ea ff ff       	call   800d2c <sys_ipc_recv>
  80231e:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  802321:	85 c0                	test   %eax,%eax
  802323:	79 17                	jns    80233c <ipc_recv+0x4b>
		if(*from_env_store)
  802325:	83 3e 00             	cmpl   $0x0,(%esi)
  802328:	74 06                	je     802330 <ipc_recv+0x3f>
			*from_env_store = 0;
  80232a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  802330:	85 db                	test   %ebx,%ebx
  802332:	74 2c                	je     802360 <ipc_recv+0x6f>
			*perm_store = 0;
  802334:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80233a:	eb 24                	jmp    802360 <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  80233c:	85 f6                	test   %esi,%esi
  80233e:	74 0a                	je     80234a <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  802340:	a1 08 40 80 00       	mov    0x804008,%eax
  802345:	8b 40 74             	mov    0x74(%eax),%eax
  802348:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  80234a:	85 db                	test   %ebx,%ebx
  80234c:	74 0a                	je     802358 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80234e:	a1 08 40 80 00       	mov    0x804008,%eax
  802353:	8b 40 78             	mov    0x78(%eax),%eax
  802356:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802358:	a1 08 40 80 00       	mov    0x804008,%eax
  80235d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802360:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802363:	5b                   	pop    %ebx
  802364:	5e                   	pop    %esi
  802365:	5d                   	pop    %ebp
  802366:	c3                   	ret    

00802367 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802367:	55                   	push   %ebp
  802368:	89 e5                	mov    %esp,%ebp
  80236a:	57                   	push   %edi
  80236b:	56                   	push   %esi
  80236c:	53                   	push   %ebx
  80236d:	83 ec 0c             	sub    $0xc,%esp
  802370:	8b 7d 08             	mov    0x8(%ebp),%edi
  802373:	8b 75 0c             	mov    0xc(%ebp),%esi
  802376:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802379:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  80237b:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  802380:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802383:	e8 d5 e7 ff ff       	call   800b5d <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802388:	ff 75 14             	pushl  0x14(%ebp)
  80238b:	53                   	push   %ebx
  80238c:	56                   	push   %esi
  80238d:	57                   	push   %edi
  80238e:	e8 76 e9 ff ff       	call   800d09 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802393:	89 c2                	mov    %eax,%edx
  802395:	f7 d2                	not    %edx
  802397:	c1 ea 1f             	shr    $0x1f,%edx
  80239a:	83 c4 10             	add    $0x10,%esp
  80239d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023a0:	0f 94 c1             	sete   %cl
  8023a3:	09 ca                	or     %ecx,%edx
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	0f 94 c0             	sete   %al
  8023aa:	38 c2                	cmp    %al,%dl
  8023ac:	77 d5                	ja     802383 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  8023ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023b1:	5b                   	pop    %ebx
  8023b2:	5e                   	pop    %esi
  8023b3:	5f                   	pop    %edi
  8023b4:	5d                   	pop    %ebp
  8023b5:	c3                   	ret    

008023b6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023b6:	55                   	push   %ebp
  8023b7:	89 e5                	mov    %esp,%ebp
  8023b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8023bc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023c1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8023c4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023ca:	8b 52 50             	mov    0x50(%edx),%edx
  8023cd:	39 ca                	cmp    %ecx,%edx
  8023cf:	75 0d                	jne    8023de <ipc_find_env+0x28>
			return envs[i].env_id;
  8023d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023d9:	8b 40 48             	mov    0x48(%eax),%eax
  8023dc:	eb 0f                	jmp    8023ed <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023de:	83 c0 01             	add    $0x1,%eax
  8023e1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023e6:	75 d9                	jne    8023c1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023ed:	5d                   	pop    %ebp
  8023ee:	c3                   	ret    

008023ef <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	c1 e8 16             	shr    $0x16,%eax
  8023fa:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802401:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802406:	f6 c1 01             	test   $0x1,%cl
  802409:	74 1d                	je     802428 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80240b:	c1 ea 0c             	shr    $0xc,%edx
  80240e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802415:	f6 c2 01             	test   $0x1,%dl
  802418:	74 0e                	je     802428 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80241a:	c1 ea 0c             	shr    $0xc,%edx
  80241d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802424:	ef 
  802425:	0f b7 c0             	movzwl %ax,%eax
}
  802428:	5d                   	pop    %ebp
  802429:	c3                   	ret    
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__udivdi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80243b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80243f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 f6                	test   %esi,%esi
  802449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80244d:	89 ca                	mov    %ecx,%edx
  80244f:	89 f8                	mov    %edi,%eax
  802451:	75 3d                	jne    802490 <__udivdi3+0x60>
  802453:	39 cf                	cmp    %ecx,%edi
  802455:	0f 87 c5 00 00 00    	ja     802520 <__udivdi3+0xf0>
  80245b:	85 ff                	test   %edi,%edi
  80245d:	89 fd                	mov    %edi,%ebp
  80245f:	75 0b                	jne    80246c <__udivdi3+0x3c>
  802461:	b8 01 00 00 00       	mov    $0x1,%eax
  802466:	31 d2                	xor    %edx,%edx
  802468:	f7 f7                	div    %edi
  80246a:	89 c5                	mov    %eax,%ebp
  80246c:	89 c8                	mov    %ecx,%eax
  80246e:	31 d2                	xor    %edx,%edx
  802470:	f7 f5                	div    %ebp
  802472:	89 c1                	mov    %eax,%ecx
  802474:	89 d8                	mov    %ebx,%eax
  802476:	89 cf                	mov    %ecx,%edi
  802478:	f7 f5                	div    %ebp
  80247a:	89 c3                	mov    %eax,%ebx
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	89 fa                	mov    %edi,%edx
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	90                   	nop
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	39 ce                	cmp    %ecx,%esi
  802492:	77 74                	ja     802508 <__udivdi3+0xd8>
  802494:	0f bd fe             	bsr    %esi,%edi
  802497:	83 f7 1f             	xor    $0x1f,%edi
  80249a:	0f 84 98 00 00 00    	je     802538 <__udivdi3+0x108>
  8024a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	89 c5                	mov    %eax,%ebp
  8024a9:	29 fb                	sub    %edi,%ebx
  8024ab:	d3 e6                	shl    %cl,%esi
  8024ad:	89 d9                	mov    %ebx,%ecx
  8024af:	d3 ed                	shr    %cl,%ebp
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	d3 e0                	shl    %cl,%eax
  8024b5:	09 ee                	or     %ebp,%esi
  8024b7:	89 d9                	mov    %ebx,%ecx
  8024b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024bd:	89 d5                	mov    %edx,%ebp
  8024bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c3:	d3 ed                	shr    %cl,%ebp
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e2                	shl    %cl,%edx
  8024c9:	89 d9                	mov    %ebx,%ecx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	09 c2                	or     %eax,%edx
  8024cf:	89 d0                	mov    %edx,%eax
  8024d1:	89 ea                	mov    %ebp,%edx
  8024d3:	f7 f6                	div    %esi
  8024d5:	89 d5                	mov    %edx,%ebp
  8024d7:	89 c3                	mov    %eax,%ebx
  8024d9:	f7 64 24 0c          	mull   0xc(%esp)
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	72 10                	jb     8024f1 <__udivdi3+0xc1>
  8024e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e6                	shl    %cl,%esi
  8024e9:	39 c6                	cmp    %eax,%esi
  8024eb:	73 07                	jae    8024f4 <__udivdi3+0xc4>
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	75 03                	jne    8024f4 <__udivdi3+0xc4>
  8024f1:	83 eb 01             	sub    $0x1,%ebx
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	89 fa                	mov    %edi,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	31 ff                	xor    %edi,%edi
  80250a:	31 db                	xor    %ebx,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d8                	mov    %ebx,%eax
  802522:	f7 f7                	div    %edi
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 c3                	mov    %eax,%ebx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 fa                	mov    %edi,%edx
  80252c:	83 c4 1c             	add    $0x1c,%esp
  80252f:	5b                   	pop    %ebx
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	39 ce                	cmp    %ecx,%esi
  80253a:	72 0c                	jb     802548 <__udivdi3+0x118>
  80253c:	31 db                	xor    %ebx,%ebx
  80253e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802542:	0f 87 34 ff ff ff    	ja     80247c <__udivdi3+0x4c>
  802548:	bb 01 00 00 00       	mov    $0x1,%ebx
  80254d:	e9 2a ff ff ff       	jmp    80247c <__udivdi3+0x4c>
  802552:	66 90                	xchg   %ax,%ax
  802554:	66 90                	xchg   %ax,%ax
  802556:	66 90                	xchg   %ax,%ax
  802558:	66 90                	xchg   %ax,%ax
  80255a:	66 90                	xchg   %ax,%ax
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <__umoddi3>:
  802560:	55                   	push   %ebp
  802561:	57                   	push   %edi
  802562:	56                   	push   %esi
  802563:	53                   	push   %ebx
  802564:	83 ec 1c             	sub    $0x1c,%esp
  802567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80256b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80256f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802577:	85 d2                	test   %edx,%edx
  802579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80257d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802581:	89 f3                	mov    %esi,%ebx
  802583:	89 3c 24             	mov    %edi,(%esp)
  802586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80258a:	75 1c                	jne    8025a8 <__umoddi3+0x48>
  80258c:	39 f7                	cmp    %esi,%edi
  80258e:	76 50                	jbe    8025e0 <__umoddi3+0x80>
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	f7 f7                	div    %edi
  802596:	89 d0                	mov    %edx,%eax
  802598:	31 d2                	xor    %edx,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	89 d0                	mov    %edx,%eax
  8025ac:	77 52                	ja     802600 <__umoddi3+0xa0>
  8025ae:	0f bd ea             	bsr    %edx,%ebp
  8025b1:	83 f5 1f             	xor    $0x1f,%ebp
  8025b4:	75 5a                	jne    802610 <__umoddi3+0xb0>
  8025b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ba:	0f 82 e0 00 00 00    	jb     8026a0 <__umoddi3+0x140>
  8025c0:	39 0c 24             	cmp    %ecx,(%esp)
  8025c3:	0f 86 d7 00 00 00    	jbe    8026a0 <__umoddi3+0x140>
  8025c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	85 ff                	test   %edi,%edi
  8025e2:	89 fd                	mov    %edi,%ebp
  8025e4:	75 0b                	jne    8025f1 <__umoddi3+0x91>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f7                	div    %edi
  8025ef:	89 c5                	mov    %eax,%ebp
  8025f1:	89 f0                	mov    %esi,%eax
  8025f3:	31 d2                	xor    %edx,%edx
  8025f5:	f7 f5                	div    %ebp
  8025f7:	89 c8                	mov    %ecx,%eax
  8025f9:	f7 f5                	div    %ebp
  8025fb:	89 d0                	mov    %edx,%eax
  8025fd:	eb 99                	jmp    802598 <__umoddi3+0x38>
  8025ff:	90                   	nop
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	83 c4 1c             	add    $0x1c,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    
  80260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802610:	8b 34 24             	mov    (%esp),%esi
  802613:	bf 20 00 00 00       	mov    $0x20,%edi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	29 ef                	sub    %ebp,%edi
  80261c:	d3 e0                	shl    %cl,%eax
  80261e:	89 f9                	mov    %edi,%ecx
  802620:	89 f2                	mov    %esi,%edx
  802622:	d3 ea                	shr    %cl,%edx
  802624:	89 e9                	mov    %ebp,%ecx
  802626:	09 c2                	or     %eax,%edx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 14 24             	mov    %edx,(%esp)
  80262d:	89 f2                	mov    %esi,%edx
  80262f:	d3 e2                	shl    %cl,%edx
  802631:	89 f9                	mov    %edi,%ecx
  802633:	89 54 24 04          	mov    %edx,0x4(%esp)
  802637:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	89 c6                	mov    %eax,%esi
  802641:	d3 e3                	shl    %cl,%ebx
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 d0                	mov    %edx,%eax
  802647:	d3 e8                	shr    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	09 d8                	or     %ebx,%eax
  80264d:	89 d3                	mov    %edx,%ebx
  80264f:	89 f2                	mov    %esi,%edx
  802651:	f7 34 24             	divl   (%esp)
  802654:	89 d6                	mov    %edx,%esi
  802656:	d3 e3                	shl    %cl,%ebx
  802658:	f7 64 24 04          	mull   0x4(%esp)
  80265c:	39 d6                	cmp    %edx,%esi
  80265e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802662:	89 d1                	mov    %edx,%ecx
  802664:	89 c3                	mov    %eax,%ebx
  802666:	72 08                	jb     802670 <__umoddi3+0x110>
  802668:	75 11                	jne    80267b <__umoddi3+0x11b>
  80266a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80266e:	73 0b                	jae    80267b <__umoddi3+0x11b>
  802670:	2b 44 24 04          	sub    0x4(%esp),%eax
  802674:	1b 14 24             	sbb    (%esp),%edx
  802677:	89 d1                	mov    %edx,%ecx
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80267f:	29 da                	sub    %ebx,%edx
  802681:	19 ce                	sbb    %ecx,%esi
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 f0                	mov    %esi,%eax
  802687:	d3 e0                	shl    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	d3 ea                	shr    %cl,%edx
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	d3 ee                	shr    %cl,%esi
  802691:	09 d0                	or     %edx,%eax
  802693:	89 f2                	mov    %esi,%edx
  802695:	83 c4 1c             	add    $0x1c,%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5f                   	pop    %edi
  80269b:	5d                   	pop    %ebp
  80269c:	c3                   	ret    
  80269d:	8d 76 00             	lea    0x0(%esi),%esi
  8026a0:	29 f9                	sub    %edi,%ecx
  8026a2:	19 d6                	sbb    %edx,%esi
  8026a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ac:	e9 18 ff ff ff       	jmp    8025c9 <__umoddi3+0x69>
