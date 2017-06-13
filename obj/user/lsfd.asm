
obj/user/lsfd.debug:     file format elf32-i386


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
  80002c:	e8 dc 00 00 00       	call   80010d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 a0 25 80 00       	push   $0x8025a0
  80003e:	e8 bd 01 00 00       	call   800200 <cprintf>
	exit();
  800043:	e8 0b 01 00 00       	call   800153 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 4c 0d 00 00       	call   800db8 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
}

void
umain(int argc, char **argv)
{
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
  80007a:	eb 11                	jmp    80008d <umain+0x40>
		if (i == '1')
  80007c:	83 f8 31             	cmp    $0x31,%eax
  80007f:	74 07                	je     800088 <umain+0x3b>
			usefprint = 1;
		else
			usage();
  800081:	e8 ad ff ff ff       	call   800033 <usage>
  800086:	eb 05                	jmp    80008d <umain+0x40>
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
		if (i == '1')
			usefprint = 1;
  800088:	be 01 00 00 00       	mov    $0x1,%esi
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	53                   	push   %ebx
  800091:	e8 52 0d 00 00       	call   800de8 <argnext>
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 df                	jns    80007c <umain+0x2f>
  80009d:	bb 00 00 00 00       	mov    $0x0,%ebx
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
		if (fstat(i, &st) >= 0) {
  8000a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	57                   	push   %edi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 4e 13 00 00       	call   801400 <fstat>
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	78 44                	js     8000fd <umain+0xb0>
			if (usefprint)
  8000b9:	85 f6                	test   %esi,%esi
  8000bb:	74 22                	je     8000df <umain+0x92>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c3:	ff 70 04             	pushl  0x4(%eax)
  8000c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8000c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8000cc:	57                   	push   %edi
  8000cd:	53                   	push   %ebx
  8000ce:	68 b4 25 80 00       	push   $0x8025b4
  8000d3:	6a 01                	push   $0x1
  8000d5:	e8 2c 17 00 00       	call   801806 <fprintf>
  8000da:	83 c4 20             	add    $0x20,%esp
  8000dd:	eb 1e                	jmp    8000fd <umain+0xb0>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e5:	ff 70 04             	pushl  0x4(%eax)
  8000e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ee:	57                   	push   %edi
  8000ef:	53                   	push   %ebx
  8000f0:	68 b4 25 80 00       	push   $0x8025b4
  8000f5:	e8 06 01 00 00       	call   800200 <cprintf>
  8000fa:	83 c4 20             	add    $0x20,%esp
		if (i == '1')
			usefprint = 1;
		else
			usage();

	for (i = 0; i < 32; i++)
  8000fd:	83 c3 01             	add    $0x1,%ebx
  800100:	83 fb 20             	cmp    $0x20,%ebx
  800103:	75 a3                	jne    8000a8 <umain+0x5b>
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
  800112:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800115:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  800118:	e8 4d 0a 00 00       	call   800b6a <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80011d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800122:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800125:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012f:	85 db                	test   %ebx,%ebx
  800131:	7e 07                	jle    80013a <libmain+0x2d>
		binaryname = argv[0];
  800133:	8b 06                	mov    (%esi),%eax
  800135:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013a:	83 ec 08             	sub    $0x8,%esp
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	e8 09 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800144:	e8 0a 00 00 00       	call   800153 <exit>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800159:	e8 79 0f 00 00       	call   8010d7 <close_all>
	sys_env_destroy(0);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	6a 00                	push   $0x0
  800163:	e8 c1 09 00 00       	call   800b29 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	53                   	push   %ebx
  800171:	83 ec 04             	sub    $0x4,%esp
  800174:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800177:	8b 13                	mov    (%ebx),%edx
  800179:	8d 42 01             	lea    0x1(%edx),%eax
  80017c:	89 03                	mov    %eax,(%ebx)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800185:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018a:	75 1a                	jne    8001a6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	68 ff 00 00 00       	push   $0xff
  800194:	8d 43 08             	lea    0x8(%ebx),%eax
  800197:	50                   	push   %eax
  800198:	e8 4f 09 00 00       	call   800aec <sys_cputs>
		b->idx = 0;
  80019d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bf:	00 00 00 
	b.cnt = 0;
  8001c2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cc:	ff 75 0c             	pushl  0xc(%ebp)
  8001cf:	ff 75 08             	pushl  0x8(%ebp)
  8001d2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	68 6d 01 80 00       	push   $0x80016d
  8001de:	e8 54 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e3:	83 c4 08             	add    $0x8,%esp
  8001e6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ec:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 f4 08 00 00       	call   800aec <sys_cputs>

	return b.cnt;
}
  8001f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800206:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800209:	50                   	push   %eax
  80020a:	ff 75 08             	pushl  0x8(%ebp)
  80020d:	e8 9d ff ff ff       	call   8001af <vcprintf>
	va_end(ap);

	return cnt;
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 1c             	sub    $0x1c,%esp
  80021d:	89 c7                	mov    %eax,%edi
  80021f:	89 d6                	mov    %edx,%esi
  800221:	8b 45 08             	mov    0x8(%ebp),%eax
  800224:	8b 55 0c             	mov    0xc(%ebp),%edx
  800227:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800238:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023b:	39 d3                	cmp    %edx,%ebx
  80023d:	72 05                	jb     800244 <printnum+0x30>
  80023f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800242:	77 45                	ja     800289 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 18             	pushl  0x18(%ebp)
  80024a:	8b 45 14             	mov    0x14(%ebp),%eax
  80024d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800250:	53                   	push   %ebx
  800251:	ff 75 10             	pushl  0x10(%ebp)
  800254:	83 ec 08             	sub    $0x8,%esp
  800257:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025a:	ff 75 e0             	pushl  -0x20(%ebp)
  80025d:	ff 75 dc             	pushl  -0x24(%ebp)
  800260:	ff 75 d8             	pushl  -0x28(%ebp)
  800263:	e8 98 20 00 00       	call   802300 <__udivdi3>
  800268:	83 c4 18             	add    $0x18,%esp
  80026b:	52                   	push   %edx
  80026c:	50                   	push   %eax
  80026d:	89 f2                	mov    %esi,%edx
  80026f:	89 f8                	mov    %edi,%eax
  800271:	e8 9e ff ff ff       	call   800214 <printnum>
  800276:	83 c4 20             	add    $0x20,%esp
  800279:	eb 18                	jmp    800293 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027b:	83 ec 08             	sub    $0x8,%esp
  80027e:	56                   	push   %esi
  80027f:	ff 75 18             	pushl  0x18(%ebp)
  800282:	ff d7                	call   *%edi
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	eb 03                	jmp    80028c <printnum+0x78>
  800289:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f e8                	jg     80027b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 85 21 00 00       	call   802430 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 e6 25 80 00 	movsbl 0x8025e6(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
	va_end(ap);
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 2c             	sub    $0x2c,%esp
  800340:	8b 75 08             	mov    0x8(%ebp),%esi
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 7d 10             	mov    0x10(%ebp),%edi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 a9 03 00 00    	je     8006fc <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	ff d6                	call   *%esi
  80035a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035d:	83 c7 01             	add    $0x1,%edi
  800360:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 e2                	jne    80034b <vprintfmt+0x14>
  800369:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800374:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 07                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80038c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	0f b6 c8             	movzbl %al,%ecx
  80039c:	83 e8 23             	sub    $0x23,%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 3a 03 00 00    	ja     8006e1 <vprintfmt+0x3aa>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b8:	eb d6                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003cc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d2:	83 fa 09             	cmp    $0x9,%edx
  8003d5:	77 39                	ja     800410 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003da:	eb e9                	jmp    8003c5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ed:	eb 27                	jmp    800416 <vprintfmt+0xdf>
  8003ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	0f 49 c8             	cmovns %eax,%ecx
  8003fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800402:	eb 8c                	jmp    800390 <vprintfmt+0x59>
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800407:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040e:	eb 80                	jmp    800390 <vprintfmt+0x59>
  800410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800416:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041a:	0f 89 70 ff ff ff    	jns    800390 <vprintfmt+0x59>
				width = precision, precision = -1;
  800420:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042d:	e9 5e ff ff ff       	jmp    800390 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800432:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800438:	e9 53 ff ff ff       	jmp    800390 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	ff 30                	pushl  (%eax)
  80044c:	ff d6                	call   *%esi
			break;
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800454:	e9 04 ff ff ff       	jmp    80035d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	99                   	cltd   
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 0f             	cmp    $0xf,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x142>
  80046e:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 fe 25 80 00       	push   $0x8025fe
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 94 fe ff ff       	call   80031a <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80048c:	e9 cc fe ff ff       	jmp    80035d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800491:	52                   	push   %edx
  800492:	68 b5 29 80 00       	push   $0x8029b5
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 7c fe ff ff       	call   80031a <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 b4 fe ff ff       	jmp    80035d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8d 50 04             	lea    0x4(%eax),%edx
  8004af:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b4:	85 ff                	test   %edi,%edi
  8004b6:	b8 f7 25 80 00       	mov    $0x8025f7,%eax
  8004bb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c2:	0f 8e 94 00 00 00    	jle    80055c <vprintfmt+0x225>
  8004c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cc:	0f 84 98 00 00 00    	je     80056a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d8:	57                   	push   %edi
  8004d9:	e8 a6 02 00 00       	call   800784 <strnlen>
  8004de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e1:	29 c1                	sub    %eax,%ecx
  8004e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f5:	eb 0f                	jmp    800506 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	53                   	push   %ebx
  8004fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 ef 01             	sub    $0x1,%edi
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	85 ff                	test   %edi,%edi
  800508:	7f ed                	jg     8004f7 <vprintfmt+0x1c0>
  80050a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800510:	85 c9                	test   %ecx,%ecx
  800512:	b8 00 00 00 00       	mov    $0x0,%eax
  800517:	0f 49 c1             	cmovns %ecx,%eax
  80051a:	29 c1                	sub    %eax,%ecx
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	89 cb                	mov    %ecx,%ebx
  800527:	eb 4d                	jmp    800576 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052d:	74 1b                	je     80054a <vprintfmt+0x213>
  80052f:	0f be c0             	movsbl %al,%eax
  800532:	83 e8 20             	sub    $0x20,%eax
  800535:	83 f8 5e             	cmp    $0x5e,%eax
  800538:	76 10                	jbe    80054a <vprintfmt+0x213>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	6a 3f                	push   $0x3f
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb 0d                	jmp    800557 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	ff 75 0c             	pushl  0xc(%ebp)
  800550:	52                   	push   %edx
  800551:	ff 55 08             	call   *0x8(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800557:	83 eb 01             	sub    $0x1,%ebx
  80055a:	eb 1a                	jmp    800576 <vprintfmt+0x23f>
  80055c:	89 75 08             	mov    %esi,0x8(%ebp)
  80055f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800562:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800565:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800568:	eb 0c                	jmp    800576 <vprintfmt+0x23f>
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800573:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800576:	83 c7 01             	add    $0x1,%edi
  800579:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057d:	0f be d0             	movsbl %al,%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	74 23                	je     8005a7 <vprintfmt+0x270>
  800584:	85 f6                	test   %esi,%esi
  800586:	78 a1                	js     800529 <vprintfmt+0x1f2>
  800588:	83 ee 01             	sub    $0x1,%esi
  80058b:	79 9c                	jns    800529 <vprintfmt+0x1f2>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	eb 18                	jmp    8005af <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 20                	push   $0x20
  80059d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059f:	83 ef 01             	sub    $0x1,%edi
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb 08                	jmp    8005af <vprintfmt+0x278>
  8005a7:	89 df                	mov    %ebx,%edi
  8005a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005af:	85 ff                	test   %edi,%edi
  8005b1:	7f e4                	jg     800597 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	e9 a2 fd ff ff       	jmp    80035d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bb:	83 fa 01             	cmp    $0x1,%edx
  8005be:	7e 16                	jle    8005d6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 08             	lea    0x8(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 50 04             	mov    0x4(%eax),%edx
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	eb 32                	jmp    800608 <vprintfmt+0x2d1>
	else if (lflag)
  8005d6:	85 d2                	test   %edx,%edx
  8005d8:	74 18                	je     8005f2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 04             	lea    0x4(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	89 c1                	mov    %eax,%ecx
  8005ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f0:	eb 16                	jmp    800608 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 c1                	mov    %eax,%ecx
  800602:	c1 f9 1f             	sar    $0x1f,%ecx
  800605:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800608:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800613:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800617:	0f 89 90 00 00 00    	jns    8006ad <vprintfmt+0x376>
				putch('-', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 2d                	push   $0x2d
  800623:	ff d6                	call   *%esi
				num = -(long long) num;
  800625:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800628:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062b:	f7 d8                	neg    %eax
  80062d:	83 d2 00             	adc    $0x0,%edx
  800630:	f7 da                	neg    %edx
  800632:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800635:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063a:	eb 71                	jmp    8006ad <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
  80063f:	e8 7f fc ff ff       	call   8002c3 <getuint>
			base = 10;
  800644:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800649:	eb 62                	jmp    8006ad <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80064b:	8d 45 14             	lea    0x14(%ebp),%eax
  80064e:	e8 70 fc ff ff       	call   8002c3 <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  80065a:	51                   	push   %ecx
  80065b:	ff 75 e0             	pushl  -0x20(%ebp)
  80065e:	6a 08                	push   $0x8
  800660:	52                   	push   %edx
  800661:	50                   	push   %eax
  800662:	89 da                	mov    %ebx,%edx
  800664:	89 f0                	mov    %esi,%eax
  800666:	e8 a9 fb ff ff       	call   800214 <printnum>
			break;
  80066b:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  800671:	e9 e7 fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 30                	push   $0x30
  80067c:	ff d6                	call   *%esi
			putch('x', putdat);
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	6a 78                	push   $0x78
  800684:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800696:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800699:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069e:	eb 0d                	jmp    8006ad <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a3:	e8 1b fc ff ff       	call   8002c3 <getuint>
			base = 16;
  8006a8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ad:	83 ec 0c             	sub    $0xc,%esp
  8006b0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b4:	57                   	push   %edi
  8006b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b8:	51                   	push   %ecx
  8006b9:	52                   	push   %edx
  8006ba:	50                   	push   %eax
  8006bb:	89 da                	mov    %ebx,%edx
  8006bd:	89 f0                	mov    %esi,%eax
  8006bf:	e8 50 fb ff ff       	call   800214 <printnum>
			break;
  8006c4:	83 c4 20             	add    $0x20,%esp
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	e9 8e fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	51                   	push   %ecx
  8006d4:	ff d6                	call   *%esi
			break;
  8006d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006dc:	e9 7c fc ff ff       	jmp    80035d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	6a 25                	push   $0x25
  8006e7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb 03                	jmp    8006f1 <vprintfmt+0x3ba>
  8006ee:	83 ef 01             	sub    $0x1,%edi
  8006f1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f5:	75 f7                	jne    8006ee <vprintfmt+0x3b7>
  8006f7:	e9 61 fc ff ff       	jmp    80035d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 18             	sub    $0x18,%esp
  80070a:	8b 45 08             	mov    0x8(%ebp),%eax
  80070d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800710:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800713:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800717:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800721:	85 c0                	test   %eax,%eax
  800723:	74 26                	je     80074b <vsnprintf+0x47>
  800725:	85 d2                	test   %edx,%edx
  800727:	7e 22                	jle    80074b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800729:	ff 75 14             	pushl  0x14(%ebp)
  80072c:	ff 75 10             	pushl  0x10(%ebp)
  80072f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800732:	50                   	push   %eax
  800733:	68 fd 02 80 00       	push   $0x8002fd
  800738:	e8 fa fb ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800740:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800743:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb 05                	jmp    800750 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80074b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075b:	50                   	push   %eax
  80075c:	ff 75 10             	pushl  0x10(%ebp)
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	ff 75 08             	pushl  0x8(%ebp)
  800765:	e8 9a ff ff ff       	call   800704 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
  800777:	eb 03                	jmp    80077c <strlen+0x10>
		n++;
  800779:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800780:	75 f7                	jne    800779 <strlen+0xd>
		n++;
	return n;
}
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
  800792:	eb 03                	jmp    800797 <strnlen+0x13>
		n++;
  800794:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800797:	39 c2                	cmp    %eax,%edx
  800799:	74 08                	je     8007a3 <strnlen+0x1f>
  80079b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80079f:	75 f3                	jne    800794 <strnlen+0x10>
  8007a1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a3:	5d                   	pop    %ebp
  8007a4:	c3                   	ret    

008007a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	53                   	push   %ebx
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007af:	89 c2                	mov    %eax,%edx
  8007b1:	83 c2 01             	add    $0x1,%edx
  8007b4:	83 c1 01             	add    $0x1,%ecx
  8007b7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007be:	84 db                	test   %bl,%bl
  8007c0:	75 ef                	jne    8007b1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	53                   	push   %ebx
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cc:	53                   	push   %ebx
  8007cd:	e8 9a ff ff ff       	call   80076c <strlen>
  8007d2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	01 d8                	add    %ebx,%eax
  8007da:	50                   	push   %eax
  8007db:	e8 c5 ff ff ff       	call   8007a5 <strcpy>
	return dst;
}
  8007e0:	89 d8                	mov    %ebx,%eax
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f2:	89 f3                	mov    %esi,%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f7:	89 f2                	mov    %esi,%edx
  8007f9:	eb 0f                	jmp    80080a <strncpy+0x23>
		*dst++ = *src;
  8007fb:	83 c2 01             	add    $0x1,%edx
  8007fe:	0f b6 01             	movzbl (%ecx),%eax
  800801:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800804:	80 39 01             	cmpb   $0x1,(%ecx)
  800807:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080a:	39 da                	cmp    %ebx,%edx
  80080c:	75 ed                	jne    8007fb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080e:	89 f0                	mov    %esi,%eax
  800810:	5b                   	pop    %ebx
  800811:	5e                   	pop    %esi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	56                   	push   %esi
  800818:	53                   	push   %ebx
  800819:	8b 75 08             	mov    0x8(%ebp),%esi
  80081c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081f:	8b 55 10             	mov    0x10(%ebp),%edx
  800822:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800824:	85 d2                	test   %edx,%edx
  800826:	74 21                	je     800849 <strlcpy+0x35>
  800828:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082c:	89 f2                	mov    %esi,%edx
  80082e:	eb 09                	jmp    800839 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800830:	83 c2 01             	add    $0x1,%edx
  800833:	83 c1 01             	add    $0x1,%ecx
  800836:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800839:	39 c2                	cmp    %eax,%edx
  80083b:	74 09                	je     800846 <strlcpy+0x32>
  80083d:	0f b6 19             	movzbl (%ecx),%ebx
  800840:	84 db                	test   %bl,%bl
  800842:	75 ec                	jne    800830 <strlcpy+0x1c>
  800844:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800846:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800849:	29 f0                	sub    %esi,%eax
}
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800858:	eb 06                	jmp    800860 <strcmp+0x11>
		p++, q++;
  80085a:	83 c1 01             	add    $0x1,%ecx
  80085d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	84 c0                	test   %al,%al
  800865:	74 04                	je     80086b <strcmp+0x1c>
  800867:	3a 02                	cmp    (%edx),%al
  800869:	74 ef                	je     80085a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086b:	0f b6 c0             	movzbl %al,%eax
  80086e:	0f b6 12             	movzbl (%edx),%edx
  800871:	29 d0                	sub    %edx,%eax
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	53                   	push   %ebx
  800879:	8b 45 08             	mov    0x8(%ebp),%eax
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	89 c3                	mov    %eax,%ebx
  800881:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800884:	eb 06                	jmp    80088c <strncmp+0x17>
		n--, p++, q++;
  800886:	83 c0 01             	add    $0x1,%eax
  800889:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088c:	39 d8                	cmp    %ebx,%eax
  80088e:	74 15                	je     8008a5 <strncmp+0x30>
  800890:	0f b6 08             	movzbl (%eax),%ecx
  800893:	84 c9                	test   %cl,%cl
  800895:	74 04                	je     80089b <strncmp+0x26>
  800897:	3a 0a                	cmp    (%edx),%cl
  800899:	74 eb                	je     800886 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80089b:	0f b6 00             	movzbl (%eax),%eax
  80089e:	0f b6 12             	movzbl (%edx),%edx
  8008a1:	29 d0                	sub    %edx,%eax
  8008a3:	eb 05                	jmp    8008aa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b7:	eb 07                	jmp    8008c0 <strchr+0x13>
		if (*s == c)
  8008b9:	38 ca                	cmp    %cl,%dl
  8008bb:	74 0f                	je     8008cc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	0f b6 10             	movzbl (%eax),%edx
  8008c3:	84 d2                	test   %dl,%dl
  8008c5:	75 f2                	jne    8008b9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d8:	eb 03                	jmp    8008dd <strfind+0xf>
  8008da:	83 c0 01             	add    $0x1,%eax
  8008dd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	74 04                	je     8008e8 <strfind+0x1a>
  8008e4:	84 d2                	test   %dl,%dl
  8008e6:	75 f2                	jne    8008da <strfind+0xc>
			break;
	return (char *) s;
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f6:	85 c9                	test   %ecx,%ecx
  8008f8:	74 36                	je     800930 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008fa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800900:	75 28                	jne    80092a <memset+0x40>
  800902:	f6 c1 03             	test   $0x3,%cl
  800905:	75 23                	jne    80092a <memset+0x40>
		c &= 0xFF;
  800907:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090b:	89 d3                	mov    %edx,%ebx
  80090d:	c1 e3 08             	shl    $0x8,%ebx
  800910:	89 d6                	mov    %edx,%esi
  800912:	c1 e6 18             	shl    $0x18,%esi
  800915:	89 d0                	mov    %edx,%eax
  800917:	c1 e0 10             	shl    $0x10,%eax
  80091a:	09 f0                	or     %esi,%eax
  80091c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80091e:	89 d8                	mov    %ebx,%eax
  800920:	09 d0                	or     %edx,%eax
  800922:	c1 e9 02             	shr    $0x2,%ecx
  800925:	fc                   	cld    
  800926:	f3 ab                	rep stos %eax,%es:(%edi)
  800928:	eb 06                	jmp    800930 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092d:	fc                   	cld    
  80092e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800930:	89 f8                	mov    %edi,%eax
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800945:	39 c6                	cmp    %eax,%esi
  800947:	73 35                	jae    80097e <memmove+0x47>
  800949:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094c:	39 d0                	cmp    %edx,%eax
  80094e:	73 2e                	jae    80097e <memmove+0x47>
		s += n;
		d += n;
  800950:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800953:	89 d6                	mov    %edx,%esi
  800955:	09 fe                	or     %edi,%esi
  800957:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095d:	75 13                	jne    800972 <memmove+0x3b>
  80095f:	f6 c1 03             	test   $0x3,%cl
  800962:	75 0e                	jne    800972 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800964:	83 ef 04             	sub    $0x4,%edi
  800967:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096a:	c1 e9 02             	shr    $0x2,%ecx
  80096d:	fd                   	std    
  80096e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800970:	eb 09                	jmp    80097b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800972:	83 ef 01             	sub    $0x1,%edi
  800975:	8d 72 ff             	lea    -0x1(%edx),%esi
  800978:	fd                   	std    
  800979:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097b:	fc                   	cld    
  80097c:	eb 1d                	jmp    80099b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	89 f2                	mov    %esi,%edx
  800980:	09 c2                	or     %eax,%edx
  800982:	f6 c2 03             	test   $0x3,%dl
  800985:	75 0f                	jne    800996 <memmove+0x5f>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 0a                	jne    800996 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098c:	c1 e9 02             	shr    $0x2,%ecx
  80098f:	89 c7                	mov    %eax,%edi
  800991:	fc                   	cld    
  800992:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800994:	eb 05                	jmp    80099b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80099b:	5e                   	pop    %esi
  80099c:	5f                   	pop    %edi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	ff 75 08             	pushl  0x8(%ebp)
  8009ab:	e8 87 ff ff ff       	call   800937 <memmove>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bd:	89 c6                	mov    %eax,%esi
  8009bf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c2:	eb 1a                	jmp    8009de <memcmp+0x2c>
		if (*s1 != *s2)
  8009c4:	0f b6 08             	movzbl (%eax),%ecx
  8009c7:	0f b6 1a             	movzbl (%edx),%ebx
  8009ca:	38 d9                	cmp    %bl,%cl
  8009cc:	74 0a                	je     8009d8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ce:	0f b6 c1             	movzbl %cl,%eax
  8009d1:	0f b6 db             	movzbl %bl,%ebx
  8009d4:	29 d8                	sub    %ebx,%eax
  8009d6:	eb 0f                	jmp    8009e7 <memcmp+0x35>
		s1++, s2++;
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009de:	39 f0                	cmp    %esi,%eax
  8009e0:	75 e2                	jne    8009c4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f2:	89 c1                	mov    %eax,%ecx
  8009f4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fb:	eb 0a                	jmp    800a07 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	39 da                	cmp    %ebx,%edx
  800a02:	74 07                	je     800a0b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a04:	83 c0 01             	add    $0x1,%eax
  800a07:	39 c8                	cmp    %ecx,%eax
  800a09:	72 f2                	jb     8009fd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a0b:	5b                   	pop    %ebx
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1a:	eb 03                	jmp    800a1f <strtol+0x11>
		s++;
  800a1c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1f:	0f b6 01             	movzbl (%ecx),%eax
  800a22:	3c 20                	cmp    $0x20,%al
  800a24:	74 f6                	je     800a1c <strtol+0xe>
  800a26:	3c 09                	cmp    $0x9,%al
  800a28:	74 f2                	je     800a1c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a2a:	3c 2b                	cmp    $0x2b,%al
  800a2c:	75 0a                	jne    800a38 <strtol+0x2a>
		s++;
  800a2e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a31:	bf 00 00 00 00       	mov    $0x0,%edi
  800a36:	eb 11                	jmp    800a49 <strtol+0x3b>
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3d:	3c 2d                	cmp    $0x2d,%al
  800a3f:	75 08                	jne    800a49 <strtol+0x3b>
		s++, neg = 1;
  800a41:	83 c1 01             	add    $0x1,%ecx
  800a44:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a49:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4f:	75 15                	jne    800a66 <strtol+0x58>
  800a51:	80 39 30             	cmpb   $0x30,(%ecx)
  800a54:	75 10                	jne    800a66 <strtol+0x58>
  800a56:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a5a:	75 7c                	jne    800ad8 <strtol+0xca>
		s += 2, base = 16;
  800a5c:	83 c1 02             	add    $0x2,%ecx
  800a5f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a64:	eb 16                	jmp    800a7c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a66:	85 db                	test   %ebx,%ebx
  800a68:	75 12                	jne    800a7c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a72:	75 08                	jne    800a7c <strtol+0x6e>
		s++, base = 8;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a81:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a84:	0f b6 11             	movzbl (%ecx),%edx
  800a87:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	80 fb 09             	cmp    $0x9,%bl
  800a8f:	77 08                	ja     800a99 <strtol+0x8b>
			dig = *s - '0';
  800a91:	0f be d2             	movsbl %dl,%edx
  800a94:	83 ea 30             	sub    $0x30,%edx
  800a97:	eb 22                	jmp    800abb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a99:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 19             	cmp    $0x19,%bl
  800aa1:	77 08                	ja     800aab <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 57             	sub    $0x57,%edx
  800aa9:	eb 10                	jmp    800abb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aab:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 16                	ja     800acb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800abb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abe:	7d 0b                	jge    800acb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac9:	eb b9                	jmp    800a84 <strtol+0x76>

	if (endptr)
  800acb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acf:	74 0d                	je     800ade <strtol+0xd0>
		*endptr = (char *) s;
  800ad1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad4:	89 0e                	mov    %ecx,(%esi)
  800ad6:	eb 06                	jmp    800ade <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad8:	85 db                	test   %ebx,%ebx
  800ada:	74 98                	je     800a74 <strtol+0x66>
  800adc:	eb 9e                	jmp    800a7c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ade:	89 c2                	mov    %eax,%edx
  800ae0:	f7 da                	neg    %edx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	0f 45 c2             	cmovne %edx,%eax
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
  800af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afa:	8b 55 08             	mov    0x8(%ebp),%edx
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	89 c7                	mov    %eax,%edi
  800b01:	89 c6                	mov    %eax,%esi
  800b03:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b37:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3f:	89 cb                	mov    %ecx,%ebx
  800b41:	89 cf                	mov    %ecx,%edi
  800b43:	89 ce                	mov    %ecx,%esi
  800b45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b47:	85 c0                	test   %eax,%eax
  800b49:	7e 17                	jle    800b62 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	50                   	push   %eax
  800b4f:	6a 03                	push   $0x3
  800b51:	68 df 28 80 00       	push   $0x8028df
  800b56:	6a 23                	push   $0x23
  800b58:	68 fc 28 80 00       	push   $0x8028fc
  800b5d:	e8 17 16 00 00       	call   802179 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_yield>:

void
sys_yield(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b99:	89 d1                	mov    %edx,%ecx
  800b9b:	89 d3                	mov    %edx,%ebx
  800b9d:	89 d7                	mov    %edx,%edi
  800b9f:	89 d6                	mov    %edx,%esi
  800ba1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb1:	be 00 00 00 00       	mov    $0x0,%esi
  800bb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc4:	89 f7                	mov    %esi,%edi
  800bc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	7e 17                	jle    800be3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	6a 04                	push   $0x4
  800bd2:	68 df 28 80 00       	push   $0x8028df
  800bd7:	6a 23                	push   $0x23
  800bd9:	68 fc 28 80 00       	push   $0x8028fc
  800bde:	e8 96 15 00 00       	call   802179 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf4:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c02:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c05:	8b 75 18             	mov    0x18(%ebp),%esi
  800c08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	7e 17                	jle    800c25 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	50                   	push   %eax
  800c12:	6a 05                	push   $0x5
  800c14:	68 df 28 80 00       	push   $0x8028df
  800c19:	6a 23                	push   $0x23
  800c1b:	68 fc 28 80 00       	push   $0x8028fc
  800c20:	e8 54 15 00 00       	call   802179 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 df                	mov    %ebx,%edi
  800c48:	89 de                	mov    %ebx,%esi
  800c4a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	7e 17                	jle    800c67 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c50:	83 ec 0c             	sub    $0xc,%esp
  800c53:	50                   	push   %eax
  800c54:	6a 06                	push   $0x6
  800c56:	68 df 28 80 00       	push   $0x8028df
  800c5b:	6a 23                	push   $0x23
  800c5d:	68 fc 28 80 00       	push   $0x8028fc
  800c62:	e8 12 15 00 00       	call   802179 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	8b 55 08             	mov    0x8(%ebp),%edx
  800c88:	89 df                	mov    %ebx,%edi
  800c8a:	89 de                	mov    %ebx,%esi
  800c8c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	7e 17                	jle    800ca9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	50                   	push   %eax
  800c96:	6a 08                	push   $0x8
  800c98:	68 df 28 80 00       	push   $0x8028df
  800c9d:	6a 23                	push   $0x23
  800c9f:	68 fc 28 80 00       	push   $0x8028fc
  800ca4:	e8 d0 14 00 00       	call   802179 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	89 df                	mov    %ebx,%edi
  800ccc:	89 de                	mov    %ebx,%esi
  800cce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	7e 17                	jle    800ceb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	50                   	push   %eax
  800cd8:	6a 09                	push   $0x9
  800cda:	68 df 28 80 00       	push   $0x8028df
  800cdf:	6a 23                	push   $0x23
  800ce1:	68 fc 28 80 00       	push   $0x8028fc
  800ce6:	e8 8e 14 00 00       	call   802179 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0c:	89 df                	mov    %ebx,%edi
  800d0e:	89 de                	mov    %ebx,%esi
  800d10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d12:	85 c0                	test   %eax,%eax
  800d14:	7e 17                	jle    800d2d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d16:	83 ec 0c             	sub    $0xc,%esp
  800d19:	50                   	push   %eax
  800d1a:	6a 0a                	push   $0xa
  800d1c:	68 df 28 80 00       	push   $0x8028df
  800d21:	6a 23                	push   $0x23
  800d23:	68 fc 28 80 00       	push   $0x8028fc
  800d28:	e8 4c 14 00 00       	call   802179 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	be 00 00 00 00       	mov    $0x0,%esi
  800d40:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d51:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d66:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 cb                	mov    %ecx,%ebx
  800d70:	89 cf                	mov    %ecx,%edi
  800d72:	89 ce                	mov    %ecx,%esi
  800d74:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7e 17                	jle    800d91 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7a:	83 ec 0c             	sub    $0xc,%esp
  800d7d:	50                   	push   %eax
  800d7e:	6a 0d                	push   $0xd
  800d80:	68 df 28 80 00       	push   $0x8028df
  800d85:	6a 23                	push   $0x23
  800d87:	68 fc 28 80 00       	push   $0x8028fc
  800d8c:	e8 e8 13 00 00       	call   802179 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    

00800d99 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800da4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da9:	89 d1                	mov    %edx,%ecx
  800dab:	89 d3                	mov    %edx,%ebx
  800dad:	89 d7                	mov    %edx,%edi
  800daf:	89 d6                	mov    %edx,%esi
  800db1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800dc4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800dc6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800dc9:	83 3a 01             	cmpl   $0x1,(%edx)
  800dcc:	7e 09                	jle    800dd7 <argstart+0x1f>
  800dce:	ba b1 25 80 00       	mov    $0x8025b1,%edx
  800dd3:	85 c9                	test   %ecx,%ecx
  800dd5:	75 05                	jne    800ddc <argstart+0x24>
  800dd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddc:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800ddf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <argnext>:

int
argnext(struct Argstate *args)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	53                   	push   %ebx
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800df2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800df9:	8b 43 08             	mov    0x8(%ebx),%eax
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	74 6f                	je     800e6f <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800e00:	80 38 00             	cmpb   $0x0,(%eax)
  800e03:	75 4e                	jne    800e53 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e05:	8b 0b                	mov    (%ebx),%ecx
  800e07:	83 39 01             	cmpl   $0x1,(%ecx)
  800e0a:	74 55                	je     800e61 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800e0c:	8b 53 04             	mov    0x4(%ebx),%edx
  800e0f:	8b 42 04             	mov    0x4(%edx),%eax
  800e12:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e15:	75 4a                	jne    800e61 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800e17:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e1b:	74 44                	je     800e61 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e1d:	83 c0 01             	add    $0x1,%eax
  800e20:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	8b 01                	mov    (%ecx),%eax
  800e28:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e2f:	50                   	push   %eax
  800e30:	8d 42 08             	lea    0x8(%edx),%eax
  800e33:	50                   	push   %eax
  800e34:	83 c2 04             	add    $0x4,%edx
  800e37:	52                   	push   %edx
  800e38:	e8 fa fa ff ff       	call   800937 <memmove>
		(*args->argc)--;
  800e3d:	8b 03                	mov    (%ebx),%eax
  800e3f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e42:	8b 43 08             	mov    0x8(%ebx),%eax
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e4b:	75 06                	jne    800e53 <argnext+0x6b>
  800e4d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e51:	74 0e                	je     800e61 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e53:	8b 53 08             	mov    0x8(%ebx),%edx
  800e56:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800e59:	83 c2 01             	add    $0x1,%edx
  800e5c:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  800e5f:	eb 13                	jmp    800e74 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  800e61:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e6d:	eb 05                	jmp    800e74 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  800e6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 04             	sub    $0x4,%esp
  800e80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e83:	8b 43 08             	mov    0x8(%ebx),%eax
  800e86:	85 c0                	test   %eax,%eax
  800e88:	74 58                	je     800ee2 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  800e8a:	80 38 00             	cmpb   $0x0,(%eax)
  800e8d:	74 0c                	je     800e9b <argnextvalue+0x22>
		args->argvalue = args->curarg;
  800e8f:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800e92:	c7 43 08 b1 25 80 00 	movl   $0x8025b1,0x8(%ebx)
  800e99:	eb 42                	jmp    800edd <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  800e9b:	8b 13                	mov    (%ebx),%edx
  800e9d:	83 3a 01             	cmpl   $0x1,(%edx)
  800ea0:	7e 2d                	jle    800ecf <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  800ea2:	8b 43 04             	mov    0x4(%ebx),%eax
  800ea5:	8b 48 04             	mov    0x4(%eax),%ecx
  800ea8:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800eab:	83 ec 04             	sub    $0x4,%esp
  800eae:	8b 12                	mov    (%edx),%edx
  800eb0:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800eb7:	52                   	push   %edx
  800eb8:	8d 50 08             	lea    0x8(%eax),%edx
  800ebb:	52                   	push   %edx
  800ebc:	83 c0 04             	add    $0x4,%eax
  800ebf:	50                   	push   %eax
  800ec0:	e8 72 fa ff ff       	call   800937 <memmove>
		(*args->argc)--;
  800ec5:	8b 03                	mov    (%ebx),%eax
  800ec7:	83 28 01             	subl   $0x1,(%eax)
  800eca:	83 c4 10             	add    $0x10,%esp
  800ecd:	eb 0e                	jmp    800edd <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  800ecf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ed6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  800edd:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ee0:	eb 05                	jmp    800ee7 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  800ee7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800ef5:	8b 51 0c             	mov    0xc(%ecx),%edx
  800ef8:	89 d0                	mov    %edx,%eax
  800efa:	85 d2                	test   %edx,%edx
  800efc:	75 0c                	jne    800f0a <argvalue+0x1e>
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	51                   	push   %ecx
  800f02:	e8 72 ff ff ff       	call   800e79 <argnextvalue>
  800f07:	83 c4 10             	add    $0x10,%esp
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	05 00 00 00 30       	add    $0x30000000,%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	05 00 00 00 30       	add    $0x30000000,%eax
  800f27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 16             	shr    $0x16,%edx
  800f43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	74 11                	je     800f60 <fd_alloc+0x2d>
  800f4f:	89 c2                	mov    %eax,%edx
  800f51:	c1 ea 0c             	shr    $0xc,%edx
  800f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5b:	f6 c2 01             	test   $0x1,%dl
  800f5e:	75 09                	jne    800f69 <fd_alloc+0x36>
			*fd_store = fd;
  800f60:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	eb 17                	jmp    800f80 <fd_alloc+0x4d>
  800f69:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f6e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f73:	75 c9                	jne    800f3e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f75:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f7b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f88:	83 f8 1f             	cmp    $0x1f,%eax
  800f8b:	77 36                	ja     800fc3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f8d:	c1 e0 0c             	shl    $0xc,%eax
  800f90:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f95:	89 c2                	mov    %eax,%edx
  800f97:	c1 ea 16             	shr    $0x16,%edx
  800f9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa1:	f6 c2 01             	test   $0x1,%dl
  800fa4:	74 24                	je     800fca <fd_lookup+0x48>
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	c1 ea 0c             	shr    $0xc,%edx
  800fab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb2:	f6 c2 01             	test   $0x1,%dl
  800fb5:	74 1a                	je     800fd1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fba:	89 02                	mov    %eax,(%edx)
	return 0;
  800fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc1:	eb 13                	jmp    800fd6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc8:	eb 0c                	jmp    800fd6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fcf:	eb 05                	jmp    800fd6 <fd_lookup+0x54>
  800fd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe1:	ba 88 29 80 00       	mov    $0x802988,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fe6:	eb 13                	jmp    800ffb <dev_lookup+0x23>
  800fe8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800feb:	39 08                	cmp    %ecx,(%eax)
  800fed:	75 0c                	jne    800ffb <dev_lookup+0x23>
			*dev = devtab[i];
  800fef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff9:	eb 2e                	jmp    801029 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ffb:	8b 02                	mov    (%edx),%eax
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	75 e7                	jne    800fe8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801001:	a1 08 40 80 00       	mov    0x804008,%eax
  801006:	8b 40 48             	mov    0x48(%eax),%eax
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	51                   	push   %ecx
  80100d:	50                   	push   %eax
  80100e:	68 0c 29 80 00       	push   $0x80290c
  801013:	e8 e8 f1 ff ff       	call   800200 <cprintf>
	*dev = 0;
  801018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 10             	sub    $0x10,%esp
  801033:	8b 75 08             	mov    0x8(%ebp),%esi
  801036:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801043:	c1 e8 0c             	shr    $0xc,%eax
  801046:	50                   	push   %eax
  801047:	e8 36 ff ff ff       	call   800f82 <fd_lookup>
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 05                	js     801058 <fd_close+0x2d>
	    || fd != fd2)
  801053:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801056:	74 0c                	je     801064 <fd_close+0x39>
		return (must_exist ? r : 0);
  801058:	84 db                	test   %bl,%bl
  80105a:	ba 00 00 00 00       	mov    $0x0,%edx
  80105f:	0f 44 c2             	cmove  %edx,%eax
  801062:	eb 41                	jmp    8010a5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 36                	pushl  (%esi)
  80106d:	e8 66 ff ff ff       	call   800fd8 <dev_lookup>
  801072:	89 c3                	mov    %eax,%ebx
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 1a                	js     801095 <fd_close+0x6a>
		if (dev->dev_close)
  80107b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801086:	85 c0                	test   %eax,%eax
  801088:	74 0b                	je     801095 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	56                   	push   %esi
  80108e:	ff d0                	call   *%eax
  801090:	89 c3                	mov    %eax,%ebx
  801092:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	56                   	push   %esi
  801099:	6a 00                	push   $0x0
  80109b:	e8 8d fb ff ff       	call   800c2d <sys_page_unmap>
	return r;
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	89 d8                	mov    %ebx,%eax
}
  8010a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	ff 75 08             	pushl  0x8(%ebp)
  8010b9:	e8 c4 fe ff ff       	call   800f82 <fd_lookup>
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 10                	js     8010d5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	6a 01                	push   $0x1
  8010ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8010cd:	e8 59 ff ff ff       	call   80102b <fd_close>
  8010d2:	83 c4 10             	add    $0x10,%esp
}
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <close_all>:

void
close_all(void)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	53                   	push   %ebx
  8010db:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	53                   	push   %ebx
  8010e7:	e8 c0 ff ff ff       	call   8010ac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ec:	83 c3 01             	add    $0x1,%ebx
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	83 fb 20             	cmp    $0x20,%ebx
  8010f5:	75 ec                	jne    8010e3 <close_all+0xc>
		close(i);
}
  8010f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 2c             	sub    $0x2c,%esp
  801105:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801108:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	ff 75 08             	pushl  0x8(%ebp)
  80110f:	e8 6e fe ff ff       	call   800f82 <fd_lookup>
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	0f 88 c1 00 00 00    	js     8011e0 <dup+0xe4>
		return r;
	close(newfdnum);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	56                   	push   %esi
  801123:	e8 84 ff ff ff       	call   8010ac <close>

	newfd = INDEX2FD(newfdnum);
  801128:	89 f3                	mov    %esi,%ebx
  80112a:	c1 e3 0c             	shl    $0xc,%ebx
  80112d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801133:	83 c4 04             	add    $0x4,%esp
  801136:	ff 75 e4             	pushl  -0x1c(%ebp)
  801139:	e8 de fd ff ff       	call   800f1c <fd2data>
  80113e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801140:	89 1c 24             	mov    %ebx,(%esp)
  801143:	e8 d4 fd ff ff       	call   800f1c <fd2data>
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80114e:	89 f8                	mov    %edi,%eax
  801150:	c1 e8 16             	shr    $0x16,%eax
  801153:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115a:	a8 01                	test   $0x1,%al
  80115c:	74 37                	je     801195 <dup+0x99>
  80115e:	89 f8                	mov    %edi,%eax
  801160:	c1 e8 0c             	shr    $0xc,%eax
  801163:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	74 26                	je     801195 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80116f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	25 07 0e 00 00       	and    $0xe07,%eax
  80117e:	50                   	push   %eax
  80117f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801182:	6a 00                	push   $0x0
  801184:	57                   	push   %edi
  801185:	6a 00                	push   $0x0
  801187:	e8 5f fa ff ff       	call   800beb <sys_page_map>
  80118c:	89 c7                	mov    %eax,%edi
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 2e                	js     8011c3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801195:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801198:	89 d0                	mov    %edx,%eax
  80119a:	c1 e8 0c             	shr    $0xc,%eax
  80119d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ac:	50                   	push   %eax
  8011ad:	53                   	push   %ebx
  8011ae:	6a 00                	push   $0x0
  8011b0:	52                   	push   %edx
  8011b1:	6a 00                	push   $0x0
  8011b3:	e8 33 fa ff ff       	call   800beb <sys_page_map>
  8011b8:	89 c7                	mov    %eax,%edi
  8011ba:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011bd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011bf:	85 ff                	test   %edi,%edi
  8011c1:	79 1d                	jns    8011e0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	53                   	push   %ebx
  8011c7:	6a 00                	push   $0x0
  8011c9:	e8 5f fa ff ff       	call   800c2d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011d4:	6a 00                	push   $0x0
  8011d6:	e8 52 fa ff ff       	call   800c2d <sys_page_unmap>
	return r;
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	89 f8                	mov    %edi,%eax
}
  8011e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 14             	sub    $0x14,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	53                   	push   %ebx
  8011f7:	e8 86 fd ff ff       	call   800f82 <fd_lookup>
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 c0                	test   %eax,%eax
  801203:	78 6d                	js     801272 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120f:	ff 30                	pushl  (%eax)
  801211:	e8 c2 fd ff ff       	call   800fd8 <dev_lookup>
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 4c                	js     801269 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80121d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801220:	8b 42 08             	mov    0x8(%edx),%eax
  801223:	83 e0 03             	and    $0x3,%eax
  801226:	83 f8 01             	cmp    $0x1,%eax
  801229:	75 21                	jne    80124c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80122b:	a1 08 40 80 00       	mov    0x804008,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	53                   	push   %ebx
  801237:	50                   	push   %eax
  801238:	68 4d 29 80 00       	push   $0x80294d
  80123d:	e8 be ef ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124a:	eb 26                	jmp    801272 <read+0x8a>
	}
	if (!dev->dev_read)
  80124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124f:	8b 40 08             	mov    0x8(%eax),%eax
  801252:	85 c0                	test   %eax,%eax
  801254:	74 17                	je     80126d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	52                   	push   %edx
  801260:	ff d0                	call   *%eax
  801262:	89 c2                	mov    %eax,%edx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	eb 09                	jmp    801272 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	89 c2                	mov    %eax,%edx
  80126b:	eb 05                	jmp    801272 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80126d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801272:	89 d0                	mov    %edx,%eax
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	57                   	push   %edi
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	8b 7d 08             	mov    0x8(%ebp),%edi
  801285:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128d:	eb 21                	jmp    8012b0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	89 f0                	mov    %esi,%eax
  801294:	29 d8                	sub    %ebx,%eax
  801296:	50                   	push   %eax
  801297:	89 d8                	mov    %ebx,%eax
  801299:	03 45 0c             	add    0xc(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	57                   	push   %edi
  80129e:	e8 45 ff ff ff       	call   8011e8 <read>
		if (m < 0)
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 10                	js     8012ba <readn+0x41>
			return m;
		if (m == 0)
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	74 0a                	je     8012b8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ae:	01 c3                	add    %eax,%ebx
  8012b0:	39 f3                	cmp    %esi,%ebx
  8012b2:	72 db                	jb     80128f <readn+0x16>
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	eb 02                	jmp    8012ba <readn+0x41>
  8012b8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 14             	sub    $0x14,%esp
  8012c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	53                   	push   %ebx
  8012d1:	e8 ac fc ff ff       	call   800f82 <fd_lookup>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 68                	js     801347 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	ff 30                	pushl  (%eax)
  8012eb:	e8 e8 fc ff ff       	call   800fd8 <dev_lookup>
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 47                	js     80133e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fe:	75 21                	jne    801321 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801300:	a1 08 40 80 00       	mov    0x804008,%eax
  801305:	8b 40 48             	mov    0x48(%eax),%eax
  801308:	83 ec 04             	sub    $0x4,%esp
  80130b:	53                   	push   %ebx
  80130c:	50                   	push   %eax
  80130d:	68 69 29 80 00       	push   $0x802969
  801312:	e8 e9 ee ff ff       	call   800200 <cprintf>
		return -E_INVAL;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131f:	eb 26                	jmp    801347 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801321:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801324:	8b 52 0c             	mov    0xc(%edx),%edx
  801327:	85 d2                	test   %edx,%edx
  801329:	74 17                	je     801342 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80132b:	83 ec 04             	sub    $0x4,%esp
  80132e:	ff 75 10             	pushl  0x10(%ebp)
  801331:	ff 75 0c             	pushl  0xc(%ebp)
  801334:	50                   	push   %eax
  801335:	ff d2                	call   *%edx
  801337:	89 c2                	mov    %eax,%edx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	eb 09                	jmp    801347 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133e:	89 c2                	mov    %eax,%edx
  801340:	eb 05                	jmp    801347 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801342:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801347:	89 d0                	mov    %edx,%eax
  801349:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <seek>:

int
seek(int fdnum, off_t offset)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801354:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 22 fc ff ff       	call   800f82 <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 0e                	js     801375 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801367:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80136a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 14             	sub    $0x14,%esp
  80137e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801381:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	53                   	push   %ebx
  801386:	e8 f7 fb ff ff       	call   800f82 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	89 c2                	mov    %eax,%edx
  801390:	85 c0                	test   %eax,%eax
  801392:	78 65                	js     8013f9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	ff 30                	pushl  (%eax)
  8013a0:	e8 33 fc ff ff       	call   800fd8 <dev_lookup>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 44                	js     8013f0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b3:	75 21                	jne    8013d6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b5:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ba:	8b 40 48             	mov    0x48(%eax),%eax
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	50                   	push   %eax
  8013c2:	68 2c 29 80 00       	push   $0x80292c
  8013c7:	e8 34 ee ff ff       	call   800200 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d4:	eb 23                	jmp    8013f9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d9:	8b 52 18             	mov    0x18(%edx),%edx
  8013dc:	85 d2                	test   %edx,%edx
  8013de:	74 14                	je     8013f4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	ff 75 0c             	pushl  0xc(%ebp)
  8013e6:	50                   	push   %eax
  8013e7:	ff d2                	call   *%edx
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	eb 09                	jmp    8013f9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	eb 05                	jmp    8013f9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f9:	89 d0                	mov    %edx,%eax
  8013fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 14             	sub    $0x14,%esp
  801407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	ff 75 08             	pushl  0x8(%ebp)
  801411:	e8 6c fb ff ff       	call   800f82 <fd_lookup>
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	89 c2                	mov    %eax,%edx
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 58                	js     801477 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801429:	ff 30                	pushl  (%eax)
  80142b:	e8 a8 fb ff ff       	call   800fd8 <dev_lookup>
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 37                	js     80146e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801437:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143e:	74 32                	je     801472 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801440:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801443:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80144a:	00 00 00 
	stat->st_isdir = 0;
  80144d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801454:	00 00 00 
	stat->st_dev = dev;
  801457:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	53                   	push   %ebx
  801461:	ff 75 f0             	pushl  -0x10(%ebp)
  801464:	ff 50 14             	call   *0x14(%eax)
  801467:	89 c2                	mov    %eax,%edx
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	eb 09                	jmp    801477 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146e:	89 c2                	mov    %eax,%edx
  801470:	eb 05                	jmp    801477 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801472:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801477:	89 d0                	mov    %edx,%eax
  801479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	6a 00                	push   $0x0
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 ef 01 00 00       	call   80167f <open>
  801490:	89 c3                	mov    %eax,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 1b                	js     8014b4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	50                   	push   %eax
  8014a0:	e8 5b ff ff ff       	call   801400 <fstat>
  8014a5:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a7:	89 1c 24             	mov    %ebx,(%esp)
  8014aa:	e8 fd fb ff ff       	call   8010ac <close>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	89 f0                	mov    %esi,%eax
}
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	89 c6                	mov    %eax,%esi
  8014c2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014c4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014cb:	75 12                	jne    8014df <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	6a 01                	push   $0x1
  8014d2:	e8 ad 0d 00 00       	call   802284 <ipc_find_env>
  8014d7:	a3 00 40 80 00       	mov    %eax,0x804000
  8014dc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014df:	6a 07                	push   $0x7
  8014e1:	68 00 50 80 00       	push   $0x805000
  8014e6:	56                   	push   %esi
  8014e7:	ff 35 00 40 80 00    	pushl  0x804000
  8014ed:	e8 43 0d 00 00       	call   802235 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014f2:	83 c4 0c             	add    $0xc,%esp
  8014f5:	6a 00                	push   $0x0
  8014f7:	53                   	push   %ebx
  8014f8:	6a 00                	push   $0x0
  8014fa:	e8 c0 0c 00 00       	call   8021bf <ipc_recv>
}
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80150c:	8b 45 08             	mov    0x8(%ebp),%eax
  80150f:	8b 40 0c             	mov    0xc(%eax),%eax
  801512:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801517:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 02 00 00 00       	mov    $0x2,%eax
  801529:	e8 8d ff ff ff       	call   8014bb <fsipc>
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	8b 40 0c             	mov    0xc(%eax),%eax
  80153c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 06 00 00 00       	mov    $0x6,%eax
  80154b:	e8 6b ff ff ff       	call   8014bb <fsipc>
}
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	53                   	push   %ebx
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	8b 40 0c             	mov    0xc(%eax),%eax
  801562:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801567:	ba 00 00 00 00       	mov    $0x0,%edx
  80156c:	b8 05 00 00 00       	mov    $0x5,%eax
  801571:	e8 45 ff ff ff       	call   8014bb <fsipc>
  801576:	85 c0                	test   %eax,%eax
  801578:	78 2c                	js     8015a6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	68 00 50 80 00       	push   $0x805000
  801582:	53                   	push   %ebx
  801583:	e8 1d f2 ff ff       	call   8007a5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801588:	a1 80 50 80 00       	mov    0x805080,%eax
  80158d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801593:	a1 84 50 80 00       	mov    0x805084,%eax
  801598:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015bb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015c1:	a3 04 50 80 00       	mov    %eax,0x805004
  8015c6:	3d 08 50 80 00       	cmp    $0x805008,%eax
  8015cb:	bb 08 50 80 00       	mov    $0x805008,%ebx
  8015d0:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d3:	53                   	push   %ebx
  8015d4:	ff 75 0c             	pushl  0xc(%ebp)
  8015d7:	68 08 50 80 00       	push   $0x805008
  8015dc:	e8 56 f3 ff ff       	call   800937 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8015eb:	e8 cb fe ff ff       	call   8014bb <fsipc>
  8015f0:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	56                   	push   %esi
  801601:	53                   	push   %ebx
  801602:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
  801608:	8b 40 0c             	mov    0xc(%eax),%eax
  80160b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801610:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801616:	ba 00 00 00 00       	mov    $0x0,%edx
  80161b:	b8 03 00 00 00       	mov    $0x3,%eax
  801620:	e8 96 fe ff ff       	call   8014bb <fsipc>
  801625:	89 c3                	mov    %eax,%ebx
  801627:	85 c0                	test   %eax,%eax
  801629:	78 4b                	js     801676 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80162b:	39 c6                	cmp    %eax,%esi
  80162d:	73 16                	jae    801645 <devfile_read+0x48>
  80162f:	68 9c 29 80 00       	push   $0x80299c
  801634:	68 a3 29 80 00       	push   $0x8029a3
  801639:	6a 7c                	push   $0x7c
  80163b:	68 b8 29 80 00       	push   $0x8029b8
  801640:	e8 34 0b 00 00       	call   802179 <_panic>
	assert(r <= PGSIZE);
  801645:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80164a:	7e 16                	jle    801662 <devfile_read+0x65>
  80164c:	68 c3 29 80 00       	push   $0x8029c3
  801651:	68 a3 29 80 00       	push   $0x8029a3
  801656:	6a 7d                	push   $0x7d
  801658:	68 b8 29 80 00       	push   $0x8029b8
  80165d:	e8 17 0b 00 00       	call   802179 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	50                   	push   %eax
  801666:	68 00 50 80 00       	push   $0x805000
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	e8 c4 f2 ff ff       	call   800937 <memmove>
	return r;
  801673:	83 c4 10             	add    $0x10,%esp
}
  801676:	89 d8                	mov    %ebx,%eax
  801678:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	53                   	push   %ebx
  801683:	83 ec 20             	sub    $0x20,%esp
  801686:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801689:	53                   	push   %ebx
  80168a:	e8 dd f0 ff ff       	call   80076c <strlen>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801697:	7f 67                	jg     801700 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	e8 8e f8 ff ff       	call   800f33 <fd_alloc>
  8016a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016aa:	85 c0                	test   %eax,%eax
  8016ac:	78 57                	js     801705 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	53                   	push   %ebx
  8016b2:	68 00 50 80 00       	push   $0x805000
  8016b7:	e8 e9 f0 ff ff       	call   8007a5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016bf:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8016cc:	e8 ea fd ff ff       	call   8014bb <fsipc>
  8016d1:	89 c3                	mov    %eax,%ebx
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	79 14                	jns    8016ee <open+0x6f>
		fd_close(fd, 0);
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	6a 00                	push   $0x0
  8016df:	ff 75 f4             	pushl  -0xc(%ebp)
  8016e2:	e8 44 f9 ff ff       	call   80102b <fd_close>
		return r;
  8016e7:	83 c4 10             	add    $0x10,%esp
  8016ea:	89 da                	mov    %ebx,%edx
  8016ec:	eb 17                	jmp    801705 <open+0x86>
	}

	return fd2num(fd);
  8016ee:	83 ec 0c             	sub    $0xc,%esp
  8016f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8016f4:	e8 13 f8 ff ff       	call   800f0c <fd2num>
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	eb 05                	jmp    801705 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801700:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801705:	89 d0                	mov    %edx,%eax
  801707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801712:	ba 00 00 00 00       	mov    $0x0,%edx
  801717:	b8 08 00 00 00       	mov    $0x8,%eax
  80171c:	e8 9a fd ff ff       	call   8014bb <fsipc>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    

00801723 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801723:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801727:	7e 37                	jle    801760 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	53                   	push   %ebx
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801732:	ff 70 04             	pushl  0x4(%eax)
  801735:	8d 40 10             	lea    0x10(%eax),%eax
  801738:	50                   	push   %eax
  801739:	ff 33                	pushl  (%ebx)
  80173b:	e8 82 fb ff ff       	call   8012c2 <write>
		if (result > 0)
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	85 c0                	test   %eax,%eax
  801745:	7e 03                	jle    80174a <writebuf+0x27>
			b->result += result;
  801747:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80174a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80174d:	74 0d                	je     80175c <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  80174f:	85 c0                	test   %eax,%eax
  801751:	ba 00 00 00 00       	mov    $0x0,%edx
  801756:	0f 4f c2             	cmovg  %edx,%eax
  801759:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80175c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175f:	c9                   	leave  
  801760:	f3 c3                	repz ret 

00801762 <putch>:

static void
putch(int ch, void *thunk)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	83 ec 04             	sub    $0x4,%esp
  801769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80176c:	8b 53 04             	mov    0x4(%ebx),%edx
  80176f:	8d 42 01             	lea    0x1(%edx),%eax
  801772:	89 43 04             	mov    %eax,0x4(%ebx)
  801775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801778:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80177c:	3d 00 01 00 00       	cmp    $0x100,%eax
  801781:	75 0e                	jne    801791 <putch+0x2f>
		writebuf(b);
  801783:	89 d8                	mov    %ebx,%eax
  801785:	e8 99 ff ff ff       	call   801723 <writebuf>
		b->idx = 0;
  80178a:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801791:	83 c4 04             	add    $0x4,%esp
  801794:	5b                   	pop    %ebx
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017a9:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017b0:	00 00 00 
	b.result = 0;
  8017b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017ba:	00 00 00 
	b.error = 1;
  8017bd:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017c4:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017c7:	ff 75 10             	pushl  0x10(%ebp)
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017d3:	50                   	push   %eax
  8017d4:	68 62 17 80 00       	push   $0x801762
  8017d9:	e8 59 eb ff ff       	call   800337 <vprintfmt>
	if (b.idx > 0)
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017e8:	7e 0b                	jle    8017f5 <vfprintf+0x5e>
		writebuf(&b);
  8017ea:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017f0:	e8 2e ff ff ff       	call   801723 <writebuf>

	return (b.result ? b.result : b.error);
  8017f5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801804:	c9                   	leave  
  801805:	c3                   	ret    

00801806 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80180c:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80180f:	50                   	push   %eax
  801810:	ff 75 0c             	pushl  0xc(%ebp)
  801813:	ff 75 08             	pushl  0x8(%ebp)
  801816:	e8 7c ff ff ff       	call   801797 <vfprintf>
	va_end(ap);

	return cnt;
}
  80181b:	c9                   	leave  
  80181c:	c3                   	ret    

0080181d <printf>:

int
printf(const char *fmt, ...)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801823:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801826:	50                   	push   %eax
  801827:	ff 75 08             	pushl  0x8(%ebp)
  80182a:	6a 01                	push   $0x1
  80182c:	e8 66 ff ff ff       	call   801797 <vfprintf>
	va_end(ap);

	return cnt;
}
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	56                   	push   %esi
  801837:	53                   	push   %ebx
  801838:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80183b:	83 ec 0c             	sub    $0xc,%esp
  80183e:	ff 75 08             	pushl  0x8(%ebp)
  801841:	e8 d6 f6 ff ff       	call   800f1c <fd2data>
  801846:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801848:	83 c4 08             	add    $0x8,%esp
  80184b:	68 cf 29 80 00       	push   $0x8029cf
  801850:	53                   	push   %ebx
  801851:	e8 4f ef ff ff       	call   8007a5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801856:	8b 46 04             	mov    0x4(%esi),%eax
  801859:	2b 06                	sub    (%esi),%eax
  80185b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801861:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801868:	00 00 00 
	stat->st_dev = &devpipe;
  80186b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801872:	30 80 00 
	return 0;
}
  801875:	b8 00 00 00 00       	mov    $0x0,%eax
  80187a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187d:	5b                   	pop    %ebx
  80187e:	5e                   	pop    %esi
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    

00801881 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	53                   	push   %ebx
  801885:	83 ec 0c             	sub    $0xc,%esp
  801888:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80188b:	53                   	push   %ebx
  80188c:	6a 00                	push   $0x0
  80188e:	e8 9a f3 ff ff       	call   800c2d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801893:	89 1c 24             	mov    %ebx,(%esp)
  801896:	e8 81 f6 ff ff       	call   800f1c <fd2data>
  80189b:	83 c4 08             	add    $0x8,%esp
  80189e:	50                   	push   %eax
  80189f:	6a 00                	push   $0x0
  8018a1:	e8 87 f3 ff ff       	call   800c2d <sys_page_unmap>
}
  8018a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	57                   	push   %edi
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	83 ec 1c             	sub    $0x1c,%esp
  8018b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b9:	a1 08 40 80 00       	mov    0x804008,%eax
  8018be:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018c1:	83 ec 0c             	sub    $0xc,%esp
  8018c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c7:	e8 f1 09 00 00       	call   8022bd <pageref>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	89 3c 24             	mov    %edi,(%esp)
  8018d1:	e8 e7 09 00 00       	call   8022bd <pageref>
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	39 c3                	cmp    %eax,%ebx
  8018db:	0f 94 c1             	sete   %cl
  8018de:	0f b6 c9             	movzbl %cl,%ecx
  8018e1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018e4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8018ea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018ed:	39 ce                	cmp    %ecx,%esi
  8018ef:	74 1b                	je     80190c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018f1:	39 c3                	cmp    %eax,%ebx
  8018f3:	75 c4                	jne    8018b9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f5:	8b 42 58             	mov    0x58(%edx),%eax
  8018f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018fb:	50                   	push   %eax
  8018fc:	56                   	push   %esi
  8018fd:	68 d6 29 80 00       	push   $0x8029d6
  801902:	e8 f9 e8 ff ff       	call   800200 <cprintf>
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	eb ad                	jmp    8018b9 <_pipeisclosed+0xe>
	}
}
  80190c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5f                   	pop    %edi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801917:	55                   	push   %ebp
  801918:	89 e5                	mov    %esp,%ebp
  80191a:	57                   	push   %edi
  80191b:	56                   	push   %esi
  80191c:	53                   	push   %ebx
  80191d:	83 ec 28             	sub    $0x28,%esp
  801920:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801923:	56                   	push   %esi
  801924:	e8 f3 f5 ff ff       	call   800f1c <fd2data>
  801929:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	bf 00 00 00 00       	mov    $0x0,%edi
  801933:	eb 4b                	jmp    801980 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801935:	89 da                	mov    %ebx,%edx
  801937:	89 f0                	mov    %esi,%eax
  801939:	e8 6d ff ff ff       	call   8018ab <_pipeisclosed>
  80193e:	85 c0                	test   %eax,%eax
  801940:	75 48                	jne    80198a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801942:	e8 42 f2 ff ff       	call   800b89 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801947:	8b 43 04             	mov    0x4(%ebx),%eax
  80194a:	8b 0b                	mov    (%ebx),%ecx
  80194c:	8d 51 20             	lea    0x20(%ecx),%edx
  80194f:	39 d0                	cmp    %edx,%eax
  801951:	73 e2                	jae    801935 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801953:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801956:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80195a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80195d:	89 c2                	mov    %eax,%edx
  80195f:	c1 fa 1f             	sar    $0x1f,%edx
  801962:	89 d1                	mov    %edx,%ecx
  801964:	c1 e9 1b             	shr    $0x1b,%ecx
  801967:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80196a:	83 e2 1f             	and    $0x1f,%edx
  80196d:	29 ca                	sub    %ecx,%edx
  80196f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801973:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801977:	83 c0 01             	add    $0x1,%eax
  80197a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197d:	83 c7 01             	add    $0x1,%edi
  801980:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801983:	75 c2                	jne    801947 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801985:	8b 45 10             	mov    0x10(%ebp),%eax
  801988:	eb 05                	jmp    80198f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80198f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5f                   	pop    %edi
  801995:	5d                   	pop    %ebp
  801996:	c3                   	ret    

00801997 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	57                   	push   %edi
  80199b:	56                   	push   %esi
  80199c:	53                   	push   %ebx
  80199d:	83 ec 18             	sub    $0x18,%esp
  8019a0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019a3:	57                   	push   %edi
  8019a4:	e8 73 f5 ff ff       	call   800f1c <fd2data>
  8019a9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b3:	eb 3d                	jmp    8019f2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019b5:	85 db                	test   %ebx,%ebx
  8019b7:	74 04                	je     8019bd <devpipe_read+0x26>
				return i;
  8019b9:	89 d8                	mov    %ebx,%eax
  8019bb:	eb 44                	jmp    801a01 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019bd:	89 f2                	mov    %esi,%edx
  8019bf:	89 f8                	mov    %edi,%eax
  8019c1:	e8 e5 fe ff ff       	call   8018ab <_pipeisclosed>
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	75 32                	jne    8019fc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019ca:	e8 ba f1 ff ff       	call   800b89 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019cf:	8b 06                	mov    (%esi),%eax
  8019d1:	3b 46 04             	cmp    0x4(%esi),%eax
  8019d4:	74 df                	je     8019b5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019d6:	99                   	cltd   
  8019d7:	c1 ea 1b             	shr    $0x1b,%edx
  8019da:	01 d0                	add    %edx,%eax
  8019dc:	83 e0 1f             	and    $0x1f,%eax
  8019df:	29 d0                	sub    %edx,%eax
  8019e1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019ec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ef:	83 c3 01             	add    $0x1,%ebx
  8019f2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f5:	75 d8                	jne    8019cf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fa:	eb 05                	jmp    801a01 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019fc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a04:	5b                   	pop    %ebx
  801a05:	5e                   	pop    %esi
  801a06:	5f                   	pop    %edi
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a14:	50                   	push   %eax
  801a15:	e8 19 f5 ff ff       	call   800f33 <fd_alloc>
  801a1a:	83 c4 10             	add    $0x10,%esp
  801a1d:	89 c2                	mov    %eax,%edx
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	0f 88 2c 01 00 00    	js     801b53 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a27:	83 ec 04             	sub    $0x4,%esp
  801a2a:	68 07 04 00 00       	push   $0x407
  801a2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a32:	6a 00                	push   $0x0
  801a34:	e8 6f f1 ff ff       	call   800ba8 <sys_page_alloc>
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	89 c2                	mov    %eax,%edx
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	0f 88 0d 01 00 00    	js     801b53 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4c:	50                   	push   %eax
  801a4d:	e8 e1 f4 ff ff       	call   800f33 <fd_alloc>
  801a52:	89 c3                	mov    %eax,%ebx
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	85 c0                	test   %eax,%eax
  801a59:	0f 88 e2 00 00 00    	js     801b41 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5f:	83 ec 04             	sub    $0x4,%esp
  801a62:	68 07 04 00 00       	push   $0x407
  801a67:	ff 75 f0             	pushl  -0x10(%ebp)
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 37 f1 ff ff       	call   800ba8 <sys_page_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	0f 88 c3 00 00 00    	js     801b41 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	ff 75 f4             	pushl  -0xc(%ebp)
  801a84:	e8 93 f4 ff ff       	call   800f1c <fd2data>
  801a89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a8b:	83 c4 0c             	add    $0xc,%esp
  801a8e:	68 07 04 00 00       	push   $0x407
  801a93:	50                   	push   %eax
  801a94:	6a 00                	push   $0x0
  801a96:	e8 0d f1 ff ff       	call   800ba8 <sys_page_alloc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	0f 88 89 00 00 00    	js     801b31 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa8:	83 ec 0c             	sub    $0xc,%esp
  801aab:	ff 75 f0             	pushl  -0x10(%ebp)
  801aae:	e8 69 f4 ff ff       	call   800f1c <fd2data>
  801ab3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aba:	50                   	push   %eax
  801abb:	6a 00                	push   $0x0
  801abd:	56                   	push   %esi
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 26 f1 ff ff       	call   800beb <sys_page_map>
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	83 c4 20             	add    $0x20,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 55                	js     801b23 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ace:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801af1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	ff 75 f4             	pushl  -0xc(%ebp)
  801afe:	e8 09 f4 ff ff       	call   800f0c <fd2num>
  801b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b08:	83 c4 04             	add    $0x4,%esp
  801b0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0e:	e8 f9 f3 ff ff       	call   800f0c <fd2num>
  801b13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b19:	83 c4 10             	add    $0x10,%esp
  801b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b21:	eb 30                	jmp    801b53 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b23:	83 ec 08             	sub    $0x8,%esp
  801b26:	56                   	push   %esi
  801b27:	6a 00                	push   $0x0
  801b29:	e8 ff f0 ff ff       	call   800c2d <sys_page_unmap>
  801b2e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b31:	83 ec 08             	sub    $0x8,%esp
  801b34:	ff 75 f0             	pushl  -0x10(%ebp)
  801b37:	6a 00                	push   $0x0
  801b39:	e8 ef f0 ff ff       	call   800c2d <sys_page_unmap>
  801b3e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b41:	83 ec 08             	sub    $0x8,%esp
  801b44:	ff 75 f4             	pushl  -0xc(%ebp)
  801b47:	6a 00                	push   $0x0
  801b49:	e8 df f0 ff ff       	call   800c2d <sys_page_unmap>
  801b4e:	83 c4 10             	add    $0x10,%esp
  801b51:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b53:	89 d0                	mov    %edx,%eax
  801b55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5e                   	pop    %esi
  801b5a:	5d                   	pop    %ebp
  801b5b:	c3                   	ret    

00801b5c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	ff 75 08             	pushl  0x8(%ebp)
  801b69:	e8 14 f4 ff ff       	call   800f82 <fd_lookup>
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	85 c0                	test   %eax,%eax
  801b73:	78 18                	js     801b8d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b75:	83 ec 0c             	sub    $0xc,%esp
  801b78:	ff 75 f4             	pushl  -0xc(%ebp)
  801b7b:	e8 9c f3 ff ff       	call   800f1c <fd2data>
	return _pipeisclosed(fd, p);
  801b80:	89 c2                	mov    %eax,%edx
  801b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b85:	e8 21 fd ff ff       	call   8018ab <_pipeisclosed>
  801b8a:	83 c4 10             	add    $0x10,%esp
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b95:	68 ee 29 80 00       	push   $0x8029ee
  801b9a:	ff 75 0c             	pushl  0xc(%ebp)
  801b9d:	e8 03 ec ff ff       	call   8007a5 <strcpy>
	return 0;
}
  801ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	53                   	push   %ebx
  801bad:	83 ec 10             	sub    $0x10,%esp
  801bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bb3:	53                   	push   %ebx
  801bb4:	e8 04 07 00 00       	call   8022bd <pageref>
  801bb9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bbc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bc1:	83 f8 01             	cmp    $0x1,%eax
  801bc4:	75 10                	jne    801bd6 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 73 0c             	pushl  0xc(%ebx)
  801bcc:	e8 c0 02 00 00       	call   801e91 <nsipc_close>
  801bd1:	89 c2                	mov    %eax,%edx
  801bd3:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801bd6:	89 d0                	mov    %edx,%eax
  801bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801be3:	6a 00                	push   $0x0
  801be5:	ff 75 10             	pushl  0x10(%ebp)
  801be8:	ff 75 0c             	pushl  0xc(%ebp)
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	ff 70 0c             	pushl  0xc(%eax)
  801bf1:	e8 78 03 00 00       	call   801f6e <nsipc_send>
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bfe:	6a 00                	push   $0x0
  801c00:	ff 75 10             	pushl  0x10(%ebp)
  801c03:	ff 75 0c             	pushl  0xc(%ebp)
  801c06:	8b 45 08             	mov    0x8(%ebp),%eax
  801c09:	ff 70 0c             	pushl  0xc(%eax)
  801c0c:	e8 f1 02 00 00       	call   801f02 <nsipc_recv>
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c19:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c1c:	52                   	push   %edx
  801c1d:	50                   	push   %eax
  801c1e:	e8 5f f3 ff ff       	call   800f82 <fd_lookup>
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 17                	js     801c41 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2d:	8b 0d 3c 30 80 00    	mov    0x80303c,%ecx
  801c33:	39 08                	cmp    %ecx,(%eax)
  801c35:	75 05                	jne    801c3c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c37:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3a:	eb 05                	jmp    801c41 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c41:	c9                   	leave  
  801c42:	c3                   	ret    

00801c43 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c43:	55                   	push   %ebp
  801c44:	89 e5                	mov    %esp,%ebp
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 1c             	sub    $0x1c,%esp
  801c4b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c50:	50                   	push   %eax
  801c51:	e8 dd f2 ff ff       	call   800f33 <fd_alloc>
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	83 c4 10             	add    $0x10,%esp
  801c5b:	85 c0                	test   %eax,%eax
  801c5d:	78 1b                	js     801c7a <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	68 07 04 00 00       	push   $0x407
  801c67:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 37 ef ff ff       	call   800ba8 <sys_page_alloc>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	79 10                	jns    801c8a <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	56                   	push   %esi
  801c7e:	e8 0e 02 00 00       	call   801e91 <nsipc_close>
		return r;
  801c83:	83 c4 10             	add    $0x10,%esp
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	eb 24                	jmp    801cae <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c93:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c98:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c9f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ca2:	83 ec 0c             	sub    $0xc,%esp
  801ca5:	50                   	push   %eax
  801ca6:	e8 61 f2 ff ff       	call   800f0c <fd2num>
  801cab:	83 c4 10             	add    $0x10,%esp
}
  801cae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    

00801cb5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbe:	e8 50 ff ff ff       	call   801c13 <fd2sockid>
		return r;
  801cc3:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	78 1f                	js     801ce8 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cc9:	83 ec 04             	sub    $0x4,%esp
  801ccc:	ff 75 10             	pushl  0x10(%ebp)
  801ccf:	ff 75 0c             	pushl  0xc(%ebp)
  801cd2:	50                   	push   %eax
  801cd3:	e8 12 01 00 00       	call   801dea <nsipc_accept>
  801cd8:	83 c4 10             	add    $0x10,%esp
		return r;
  801cdb:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	78 07                	js     801ce8 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ce1:	e8 5d ff ff ff       	call   801c43 <alloc_sockfd>
  801ce6:	89 c1                	mov    %eax,%ecx
}
  801ce8:	89 c8                	mov    %ecx,%eax
  801cea:	c9                   	leave  
  801ceb:	c3                   	ret    

00801cec <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf5:	e8 19 ff ff ff       	call   801c13 <fd2sockid>
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 12                	js     801d10 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801cfe:	83 ec 04             	sub    $0x4,%esp
  801d01:	ff 75 10             	pushl  0x10(%ebp)
  801d04:	ff 75 0c             	pushl  0xc(%ebp)
  801d07:	50                   	push   %eax
  801d08:	e8 2d 01 00 00       	call   801e3a <nsipc_bind>
  801d0d:	83 c4 10             	add    $0x10,%esp
}
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <shutdown>:

int
shutdown(int s, int how)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	e8 f3 fe ff ff       	call   801c13 <fd2sockid>
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 0f                	js     801d33 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	ff 75 0c             	pushl  0xc(%ebp)
  801d2a:	50                   	push   %eax
  801d2b:	e8 3f 01 00 00       	call   801e6f <nsipc_shutdown>
  801d30:	83 c4 10             	add    $0x10,%esp
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3e:	e8 d0 fe ff ff       	call   801c13 <fd2sockid>
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 12                	js     801d59 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d47:	83 ec 04             	sub    $0x4,%esp
  801d4a:	ff 75 10             	pushl  0x10(%ebp)
  801d4d:	ff 75 0c             	pushl  0xc(%ebp)
  801d50:	50                   	push   %eax
  801d51:	e8 55 01 00 00       	call   801eab <nsipc_connect>
  801d56:	83 c4 10             	add    $0x10,%esp
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <listen>:

int
listen(int s, int backlog)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	e8 aa fe ff ff       	call   801c13 <fd2sockid>
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 0f                	js     801d7c <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	ff 75 0c             	pushl  0xc(%ebp)
  801d73:	50                   	push   %eax
  801d74:	e8 67 01 00 00       	call   801ee0 <nsipc_listen>
  801d79:	83 c4 10             	add    $0x10,%esp
}
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d84:	ff 75 10             	pushl  0x10(%ebp)
  801d87:	ff 75 0c             	pushl  0xc(%ebp)
  801d8a:	ff 75 08             	pushl  0x8(%ebp)
  801d8d:	e8 3a 02 00 00       	call   801fcc <nsipc_socket>
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	85 c0                	test   %eax,%eax
  801d97:	78 05                	js     801d9e <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d99:	e8 a5 fe ff ff       	call   801c43 <alloc_sockfd>
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	53                   	push   %ebx
  801da4:	83 ec 04             	sub    $0x4,%esp
  801da7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801da9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801db0:	75 12                	jne    801dc4 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801db2:	83 ec 0c             	sub    $0xc,%esp
  801db5:	6a 02                	push   $0x2
  801db7:	e8 c8 04 00 00       	call   802284 <ipc_find_env>
  801dbc:	a3 04 40 80 00       	mov    %eax,0x804004
  801dc1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801dc4:	6a 07                	push   $0x7
  801dc6:	68 00 60 80 00       	push   $0x806000
  801dcb:	53                   	push   %ebx
  801dcc:	ff 35 04 40 80 00    	pushl  0x804004
  801dd2:	e8 5e 04 00 00       	call   802235 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dd7:	83 c4 0c             	add    $0xc,%esp
  801dda:	6a 00                	push   $0x0
  801ddc:	6a 00                	push   $0x0
  801dde:	6a 00                	push   $0x0
  801de0:	e8 da 03 00 00       	call   8021bf <ipc_recv>
}
  801de5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	56                   	push   %esi
  801dee:	53                   	push   %ebx
  801def:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801dfa:	8b 06                	mov    (%esi),%eax
  801dfc:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e01:	b8 01 00 00 00       	mov    $0x1,%eax
  801e06:	e8 95 ff ff ff       	call   801da0 <nsipc>
  801e0b:	89 c3                	mov    %eax,%ebx
  801e0d:	85 c0                	test   %eax,%eax
  801e0f:	78 20                	js     801e31 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e11:	83 ec 04             	sub    $0x4,%esp
  801e14:	ff 35 10 60 80 00    	pushl  0x806010
  801e1a:	68 00 60 80 00       	push   $0x806000
  801e1f:	ff 75 0c             	pushl  0xc(%ebp)
  801e22:	e8 10 eb ff ff       	call   800937 <memmove>
		*addrlen = ret->ret_addrlen;
  801e27:	a1 10 60 80 00       	mov    0x806010,%eax
  801e2c:	89 06                	mov    %eax,(%esi)
  801e2e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e31:	89 d8                	mov    %ebx,%eax
  801e33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e36:	5b                   	pop    %ebx
  801e37:	5e                   	pop    %esi
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    

00801e3a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	53                   	push   %ebx
  801e3e:	83 ec 08             	sub    $0x8,%esp
  801e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e44:	8b 45 08             	mov    0x8(%ebp),%eax
  801e47:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e4c:	53                   	push   %ebx
  801e4d:	ff 75 0c             	pushl  0xc(%ebp)
  801e50:	68 04 60 80 00       	push   $0x806004
  801e55:	e8 dd ea ff ff       	call   800937 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e5a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e60:	b8 02 00 00 00       	mov    $0x2,%eax
  801e65:	e8 36 ff ff ff       	call   801da0 <nsipc>
}
  801e6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e75:	8b 45 08             	mov    0x8(%ebp),%eax
  801e78:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e80:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e85:	b8 03 00 00 00       	mov    $0x3,%eax
  801e8a:	e8 11 ff ff ff       	call   801da0 <nsipc>
}
  801e8f:	c9                   	leave  
  801e90:	c3                   	ret    

00801e91 <nsipc_close>:

int
nsipc_close(int s)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e9f:	b8 04 00 00 00       	mov    $0x4,%eax
  801ea4:	e8 f7 fe ff ff       	call   801da0 <nsipc>
}
  801ea9:	c9                   	leave  
  801eaa:	c3                   	ret    

00801eab <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eab:	55                   	push   %ebp
  801eac:	89 e5                	mov    %esp,%ebp
  801eae:	53                   	push   %ebx
  801eaf:	83 ec 08             	sub    $0x8,%esp
  801eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ebd:	53                   	push   %ebx
  801ebe:	ff 75 0c             	pushl  0xc(%ebp)
  801ec1:	68 04 60 80 00       	push   $0x806004
  801ec6:	e8 6c ea ff ff       	call   800937 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ecb:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ed1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ed6:	e8 c5 fe ff ff       	call   801da0 <nsipc>
}
  801edb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801eee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ef6:	b8 06 00 00 00       	mov    $0x6,%eax
  801efb:	e8 a0 fe ff ff       	call   801da0 <nsipc>
}
  801f00:	c9                   	leave  
  801f01:	c3                   	ret    

00801f02 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	56                   	push   %esi
  801f06:	53                   	push   %ebx
  801f07:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f12:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f18:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f20:	b8 07 00 00 00       	mov    $0x7,%eax
  801f25:	e8 76 fe ff ff       	call   801da0 <nsipc>
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	78 35                	js     801f65 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f30:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f35:	7f 04                	jg     801f3b <nsipc_recv+0x39>
  801f37:	39 c6                	cmp    %eax,%esi
  801f39:	7d 16                	jge    801f51 <nsipc_recv+0x4f>
  801f3b:	68 fa 29 80 00       	push   $0x8029fa
  801f40:	68 a3 29 80 00       	push   $0x8029a3
  801f45:	6a 62                	push   $0x62
  801f47:	68 0f 2a 80 00       	push   $0x802a0f
  801f4c:	e8 28 02 00 00       	call   802179 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f51:	83 ec 04             	sub    $0x4,%esp
  801f54:	50                   	push   %eax
  801f55:	68 00 60 80 00       	push   $0x806000
  801f5a:	ff 75 0c             	pushl  0xc(%ebp)
  801f5d:	e8 d5 e9 ff ff       	call   800937 <memmove>
  801f62:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f65:	89 d8                	mov    %ebx,%eax
  801f67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6a:	5b                   	pop    %ebx
  801f6b:	5e                   	pop    %esi
  801f6c:	5d                   	pop    %ebp
  801f6d:	c3                   	ret    

00801f6e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	53                   	push   %ebx
  801f72:	83 ec 04             	sub    $0x4,%esp
  801f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f78:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f80:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f86:	7e 16                	jle    801f9e <nsipc_send+0x30>
  801f88:	68 1b 2a 80 00       	push   $0x802a1b
  801f8d:	68 a3 29 80 00       	push   $0x8029a3
  801f92:	6a 6d                	push   $0x6d
  801f94:	68 0f 2a 80 00       	push   $0x802a0f
  801f99:	e8 db 01 00 00       	call   802179 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f9e:	83 ec 04             	sub    $0x4,%esp
  801fa1:	53                   	push   %ebx
  801fa2:	ff 75 0c             	pushl  0xc(%ebp)
  801fa5:	68 0c 60 80 00       	push   $0x80600c
  801faa:	e8 88 e9 ff ff       	call   800937 <memmove>
	nsipcbuf.send.req_size = size;
  801faf:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fb5:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fbd:	b8 08 00 00 00       	mov    $0x8,%eax
  801fc2:	e8 d9 fd ff ff       	call   801da0 <nsipc>
}
  801fc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fca:	c9                   	leave  
  801fcb:	c3                   	ret    

00801fcc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fdd:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801fe2:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801fea:	b8 09 00 00 00       	mov    $0x9,%eax
  801fef:	e8 ac fd ff ff       	call   801da0 <nsipc>
}
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    

00801ff6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802006:	68 27 2a 80 00       	push   $0x802a27
  80200b:	ff 75 0c             	pushl  0xc(%ebp)
  80200e:	e8 92 e7 ff ff       	call   8007a5 <strcpy>
	return 0;
}
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
  802018:	c9                   	leave  
  802019:	c3                   	ret    

0080201a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	57                   	push   %edi
  80201e:	56                   	push   %esi
  80201f:	53                   	push   %ebx
  802020:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802026:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80202b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802031:	eb 2d                	jmp    802060 <devcons_write+0x46>
		m = n - tot;
  802033:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802036:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802038:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80203b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802040:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802043:	83 ec 04             	sub    $0x4,%esp
  802046:	53                   	push   %ebx
  802047:	03 45 0c             	add    0xc(%ebp),%eax
  80204a:	50                   	push   %eax
  80204b:	57                   	push   %edi
  80204c:	e8 e6 e8 ff ff       	call   800937 <memmove>
		sys_cputs(buf, m);
  802051:	83 c4 08             	add    $0x8,%esp
  802054:	53                   	push   %ebx
  802055:	57                   	push   %edi
  802056:	e8 91 ea ff ff       	call   800aec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80205b:	01 de                	add    %ebx,%esi
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	89 f0                	mov    %esi,%eax
  802062:	3b 75 10             	cmp    0x10(%ebp),%esi
  802065:	72 cc                	jb     802033 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802067:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206a:	5b                   	pop    %ebx
  80206b:	5e                   	pop    %esi
  80206c:	5f                   	pop    %edi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    

0080206f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	83 ec 08             	sub    $0x8,%esp
  802075:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80207a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80207e:	74 2a                	je     8020aa <devcons_read+0x3b>
  802080:	eb 05                	jmp    802087 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802082:	e8 02 eb ff ff       	call   800b89 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802087:	e8 7e ea ff ff       	call   800b0a <sys_cgetc>
  80208c:	85 c0                	test   %eax,%eax
  80208e:	74 f2                	je     802082 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802090:	85 c0                	test   %eax,%eax
  802092:	78 16                	js     8020aa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802094:	83 f8 04             	cmp    $0x4,%eax
  802097:	74 0c                	je     8020a5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802099:	8b 55 0c             	mov    0xc(%ebp),%edx
  80209c:	88 02                	mov    %al,(%edx)
	return 1;
  80209e:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a3:	eb 05                	jmp    8020aa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020a5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020aa:	c9                   	leave  
  8020ab:	c3                   	ret    

008020ac <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020ac:	55                   	push   %ebp
  8020ad:	89 e5                	mov    %esp,%ebp
  8020af:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020b8:	6a 01                	push   $0x1
  8020ba:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020bd:	50                   	push   %eax
  8020be:	e8 29 ea ff ff       	call   800aec <sys_cputs>
}
  8020c3:	83 c4 10             	add    $0x10,%esp
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    

008020c8 <getchar>:

int
getchar(void)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020ce:	6a 01                	push   $0x1
  8020d0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020d3:	50                   	push   %eax
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 0d f1 ff ff       	call   8011e8 <read>
	if (r < 0)
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 0f                	js     8020f1 <getchar+0x29>
		return r;
	if (r < 1)
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	7e 06                	jle    8020ec <getchar+0x24>
		return -E_EOF;
	return c;
  8020e6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020ea:	eb 05                	jmp    8020f1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020ec:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020f1:	c9                   	leave  
  8020f2:	c3                   	ret    

008020f3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fc:	50                   	push   %eax
  8020fd:	ff 75 08             	pushl  0x8(%ebp)
  802100:	e8 7d ee ff ff       	call   800f82 <fd_lookup>
  802105:	83 c4 10             	add    $0x10,%esp
  802108:	85 c0                	test   %eax,%eax
  80210a:	78 11                	js     80211d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80210c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802115:	39 10                	cmp    %edx,(%eax)
  802117:	0f 94 c0             	sete   %al
  80211a:	0f b6 c0             	movzbl %al,%eax
}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    

0080211f <opencons>:

int
opencons(void)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802125:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802128:	50                   	push   %eax
  802129:	e8 05 ee ff ff       	call   800f33 <fd_alloc>
  80212e:	83 c4 10             	add    $0x10,%esp
		return r;
  802131:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802133:	85 c0                	test   %eax,%eax
  802135:	78 3e                	js     802175 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802137:	83 ec 04             	sub    $0x4,%esp
  80213a:	68 07 04 00 00       	push   $0x407
  80213f:	ff 75 f4             	pushl  -0xc(%ebp)
  802142:	6a 00                	push   $0x0
  802144:	e8 5f ea ff ff       	call   800ba8 <sys_page_alloc>
  802149:	83 c4 10             	add    $0x10,%esp
		return r;
  80214c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214e:	85 c0                	test   %eax,%eax
  802150:	78 23                	js     802175 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802152:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80215d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802160:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802167:	83 ec 0c             	sub    $0xc,%esp
  80216a:	50                   	push   %eax
  80216b:	e8 9c ed ff ff       	call   800f0c <fd2num>
  802170:	89 c2                	mov    %eax,%edx
  802172:	83 c4 10             	add    $0x10,%esp
}
  802175:	89 d0                	mov    %edx,%eax
  802177:	c9                   	leave  
  802178:	c3                   	ret    

00802179 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802179:	55                   	push   %ebp
  80217a:	89 e5                	mov    %esp,%ebp
  80217c:	56                   	push   %esi
  80217d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80217e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802181:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802187:	e8 de e9 ff ff       	call   800b6a <sys_getenvid>
  80218c:	83 ec 0c             	sub    $0xc,%esp
  80218f:	ff 75 0c             	pushl  0xc(%ebp)
  802192:	ff 75 08             	pushl  0x8(%ebp)
  802195:	56                   	push   %esi
  802196:	50                   	push   %eax
  802197:	68 34 2a 80 00       	push   $0x802a34
  80219c:	e8 5f e0 ff ff       	call   800200 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021a1:	83 c4 18             	add    $0x18,%esp
  8021a4:	53                   	push   %ebx
  8021a5:	ff 75 10             	pushl  0x10(%ebp)
  8021a8:	e8 02 e0 ff ff       	call   8001af <vcprintf>
	cprintf("\n");
  8021ad:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  8021b4:	e8 47 e0 ff ff       	call   800200 <cprintf>
  8021b9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021bc:	cc                   	int3   
  8021bd:	eb fd                	jmp    8021bc <_panic+0x43>

008021bf <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8021c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  8021cd:	85 c0                	test   %eax,%eax
  8021cf:	74 0e                	je     8021df <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  8021d1:	83 ec 0c             	sub    $0xc,%esp
  8021d4:	50                   	push   %eax
  8021d5:	e8 7e eb ff ff       	call   800d58 <sys_ipc_recv>
  8021da:	83 c4 10             	add    $0x10,%esp
  8021dd:	eb 10                	jmp    8021ef <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  8021df:	83 ec 0c             	sub    $0xc,%esp
  8021e2:	68 00 00 c0 ee       	push   $0xeec00000
  8021e7:	e8 6c eb ff ff       	call   800d58 <sys_ipc_recv>
  8021ec:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8021ef:	85 c0                	test   %eax,%eax
  8021f1:	79 17                	jns    80220a <ipc_recv+0x4b>
		if(*from_env_store)
  8021f3:	83 3e 00             	cmpl   $0x0,(%esi)
  8021f6:	74 06                	je     8021fe <ipc_recv+0x3f>
			*from_env_store = 0;
  8021f8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8021fe:	85 db                	test   %ebx,%ebx
  802200:	74 2c                	je     80222e <ipc_recv+0x6f>
			*perm_store = 0;
  802202:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802208:	eb 24                	jmp    80222e <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  80220a:	85 f6                	test   %esi,%esi
  80220c:	74 0a                	je     802218 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  80220e:	a1 08 40 80 00       	mov    0x804008,%eax
  802213:	8b 40 74             	mov    0x74(%eax),%eax
  802216:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  802218:	85 db                	test   %ebx,%ebx
  80221a:	74 0a                	je     802226 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  80221c:	a1 08 40 80 00       	mov    0x804008,%eax
  802221:	8b 40 78             	mov    0x78(%eax),%eax
  802224:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802226:	a1 08 40 80 00       	mov    0x804008,%eax
  80222b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80222e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802231:	5b                   	pop    %ebx
  802232:	5e                   	pop    %esi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    

00802235 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
  802238:	57                   	push   %edi
  802239:	56                   	push   %esi
  80223a:	53                   	push   %ebx
  80223b:	83 ec 0c             	sub    $0xc,%esp
  80223e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802241:	8b 75 0c             	mov    0xc(%ebp),%esi
  802244:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  802247:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  802249:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  80224e:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  802251:	e8 33 e9 ff ff       	call   800b89 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  802256:	ff 75 14             	pushl  0x14(%ebp)
  802259:	53                   	push   %ebx
  80225a:	56                   	push   %esi
  80225b:	57                   	push   %edi
  80225c:	e8 d4 ea ff ff       	call   800d35 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  802261:	89 c2                	mov    %eax,%edx
  802263:	f7 d2                	not    %edx
  802265:	c1 ea 1f             	shr    $0x1f,%edx
  802268:	83 c4 10             	add    $0x10,%esp
  80226b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80226e:	0f 94 c1             	sete   %cl
  802271:	09 ca                	or     %ecx,%edx
  802273:	85 c0                	test   %eax,%eax
  802275:	0f 94 c0             	sete   %al
  802278:	38 c2                	cmp    %al,%dl
  80227a:	77 d5                	ja     802251 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  80227c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    

00802284 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802284:	55                   	push   %ebp
  802285:	89 e5                	mov    %esp,%ebp
  802287:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80228a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80228f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802292:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802298:	8b 52 50             	mov    0x50(%edx),%edx
  80229b:	39 ca                	cmp    %ecx,%edx
  80229d:	75 0d                	jne    8022ac <ipc_find_env+0x28>
			return envs[i].env_id;
  80229f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022a7:	8b 40 48             	mov    0x48(%eax),%eax
  8022aa:	eb 0f                	jmp    8022bb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022ac:	83 c0 01             	add    $0x1,%eax
  8022af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022b4:	75 d9                	jne    80228f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    

008022bd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022bd:	55                   	push   %ebp
  8022be:	89 e5                	mov    %esp,%ebp
  8022c0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022c3:	89 d0                	mov    %edx,%eax
  8022c5:	c1 e8 16             	shr    $0x16,%eax
  8022c8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022cf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d4:	f6 c1 01             	test   $0x1,%cl
  8022d7:	74 1d                	je     8022f6 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022d9:	c1 ea 0c             	shr    $0xc,%edx
  8022dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8022e3:	f6 c2 01             	test   $0x1,%dl
  8022e6:	74 0e                	je     8022f6 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022e8:	c1 ea 0c             	shr    $0xc,%edx
  8022eb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8022f2:	ef 
  8022f3:	0f b7 c0             	movzwl %ax,%eax
}
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	66 90                	xchg   %ax,%ax
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__udivdi3>:
  802300:	55                   	push   %ebp
  802301:	57                   	push   %edi
  802302:	56                   	push   %esi
  802303:	53                   	push   %ebx
  802304:	83 ec 1c             	sub    $0x1c,%esp
  802307:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80230b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80230f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802313:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802317:	85 f6                	test   %esi,%esi
  802319:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	89 f8                	mov    %edi,%eax
  802321:	75 3d                	jne    802360 <__udivdi3+0x60>
  802323:	39 cf                	cmp    %ecx,%edi
  802325:	0f 87 c5 00 00 00    	ja     8023f0 <__udivdi3+0xf0>
  80232b:	85 ff                	test   %edi,%edi
  80232d:	89 fd                	mov    %edi,%ebp
  80232f:	75 0b                	jne    80233c <__udivdi3+0x3c>
  802331:	b8 01 00 00 00       	mov    $0x1,%eax
  802336:	31 d2                	xor    %edx,%edx
  802338:	f7 f7                	div    %edi
  80233a:	89 c5                	mov    %eax,%ebp
  80233c:	89 c8                	mov    %ecx,%eax
  80233e:	31 d2                	xor    %edx,%edx
  802340:	f7 f5                	div    %ebp
  802342:	89 c1                	mov    %eax,%ecx
  802344:	89 d8                	mov    %ebx,%eax
  802346:	89 cf                	mov    %ecx,%edi
  802348:	f7 f5                	div    %ebp
  80234a:	89 c3                	mov    %eax,%ebx
  80234c:	89 d8                	mov    %ebx,%eax
  80234e:	89 fa                	mov    %edi,%edx
  802350:	83 c4 1c             	add    $0x1c,%esp
  802353:	5b                   	pop    %ebx
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	90                   	nop
  802359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802360:	39 ce                	cmp    %ecx,%esi
  802362:	77 74                	ja     8023d8 <__udivdi3+0xd8>
  802364:	0f bd fe             	bsr    %esi,%edi
  802367:	83 f7 1f             	xor    $0x1f,%edi
  80236a:	0f 84 98 00 00 00    	je     802408 <__udivdi3+0x108>
  802370:	bb 20 00 00 00       	mov    $0x20,%ebx
  802375:	89 f9                	mov    %edi,%ecx
  802377:	89 c5                	mov    %eax,%ebp
  802379:	29 fb                	sub    %edi,%ebx
  80237b:	d3 e6                	shl    %cl,%esi
  80237d:	89 d9                	mov    %ebx,%ecx
  80237f:	d3 ed                	shr    %cl,%ebp
  802381:	89 f9                	mov    %edi,%ecx
  802383:	d3 e0                	shl    %cl,%eax
  802385:	09 ee                	or     %ebp,%esi
  802387:	89 d9                	mov    %ebx,%ecx
  802389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238d:	89 d5                	mov    %edx,%ebp
  80238f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 f9                	mov    %edi,%ecx
  802397:	d3 e2                	shl    %cl,%edx
  802399:	89 d9                	mov    %ebx,%ecx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	09 c2                	or     %eax,%edx
  80239f:	89 d0                	mov    %edx,%eax
  8023a1:	89 ea                	mov    %ebp,%edx
  8023a3:	f7 f6                	div    %esi
  8023a5:	89 d5                	mov    %edx,%ebp
  8023a7:	89 c3                	mov    %eax,%ebx
  8023a9:	f7 64 24 0c          	mull   0xc(%esp)
  8023ad:	39 d5                	cmp    %edx,%ebp
  8023af:	72 10                	jb     8023c1 <__udivdi3+0xc1>
  8023b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8023b5:	89 f9                	mov    %edi,%ecx
  8023b7:	d3 e6                	shl    %cl,%esi
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	73 07                	jae    8023c4 <__udivdi3+0xc4>
  8023bd:	39 d5                	cmp    %edx,%ebp
  8023bf:	75 03                	jne    8023c4 <__udivdi3+0xc4>
  8023c1:	83 eb 01             	sub    $0x1,%ebx
  8023c4:	31 ff                	xor    %edi,%edi
  8023c6:	89 d8                	mov    %ebx,%eax
  8023c8:	89 fa                	mov    %edi,%edx
  8023ca:	83 c4 1c             	add    $0x1c,%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5f                   	pop    %edi
  8023d0:	5d                   	pop    %ebp
  8023d1:	c3                   	ret    
  8023d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023d8:	31 ff                	xor    %edi,%edi
  8023da:	31 db                	xor    %ebx,%ebx
  8023dc:	89 d8                	mov    %ebx,%eax
  8023de:	89 fa                	mov    %edi,%edx
  8023e0:	83 c4 1c             	add    $0x1c,%esp
  8023e3:	5b                   	pop    %ebx
  8023e4:	5e                   	pop    %esi
  8023e5:	5f                   	pop    %edi
  8023e6:	5d                   	pop    %ebp
  8023e7:	c3                   	ret    
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	89 d8                	mov    %ebx,%eax
  8023f2:	f7 f7                	div    %edi
  8023f4:	31 ff                	xor    %edi,%edi
  8023f6:	89 c3                	mov    %eax,%ebx
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	89 fa                	mov    %edi,%edx
  8023fc:	83 c4 1c             	add    $0x1c,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5f                   	pop    %edi
  802402:	5d                   	pop    %ebp
  802403:	c3                   	ret    
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 ce                	cmp    %ecx,%esi
  80240a:	72 0c                	jb     802418 <__udivdi3+0x118>
  80240c:	31 db                	xor    %ebx,%ebx
  80240e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802412:	0f 87 34 ff ff ff    	ja     80234c <__udivdi3+0x4c>
  802418:	bb 01 00 00 00       	mov    $0x1,%ebx
  80241d:	e9 2a ff ff ff       	jmp    80234c <__udivdi3+0x4c>
  802422:	66 90                	xchg   %ax,%ax
  802424:	66 90                	xchg   %ax,%ax
  802426:	66 90                	xchg   %ax,%ax
  802428:	66 90                	xchg   %ax,%ax
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80243b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80243f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 d2                	test   %edx,%edx
  802449:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802451:	89 f3                	mov    %esi,%ebx
  802453:	89 3c 24             	mov    %edi,(%esp)
  802456:	89 74 24 04          	mov    %esi,0x4(%esp)
  80245a:	75 1c                	jne    802478 <__umoddi3+0x48>
  80245c:	39 f7                	cmp    %esi,%edi
  80245e:	76 50                	jbe    8024b0 <__umoddi3+0x80>
  802460:	89 c8                	mov    %ecx,%eax
  802462:	89 f2                	mov    %esi,%edx
  802464:	f7 f7                	div    %edi
  802466:	89 d0                	mov    %edx,%eax
  802468:	31 d2                	xor    %edx,%edx
  80246a:	83 c4 1c             	add    $0x1c,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5f                   	pop    %edi
  802470:	5d                   	pop    %ebp
  802471:	c3                   	ret    
  802472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802478:	39 f2                	cmp    %esi,%edx
  80247a:	89 d0                	mov    %edx,%eax
  80247c:	77 52                	ja     8024d0 <__umoddi3+0xa0>
  80247e:	0f bd ea             	bsr    %edx,%ebp
  802481:	83 f5 1f             	xor    $0x1f,%ebp
  802484:	75 5a                	jne    8024e0 <__umoddi3+0xb0>
  802486:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	39 0c 24             	cmp    %ecx,(%esp)
  802493:	0f 86 d7 00 00 00    	jbe    802570 <__umoddi3+0x140>
  802499:	8b 44 24 08          	mov    0x8(%esp),%eax
  80249d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	85 ff                	test   %edi,%edi
  8024b2:	89 fd                	mov    %edi,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 f0                	mov    %esi,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 c8                	mov    %ecx,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	eb 99                	jmp    802468 <__umoddi3+0x38>
  8024cf:	90                   	nop
  8024d0:	89 c8                	mov    %ecx,%eax
  8024d2:	89 f2                	mov    %esi,%edx
  8024d4:	83 c4 1c             	add    $0x1c,%esp
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
  8024dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e0:	8b 34 24             	mov    (%esp),%esi
  8024e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8024e8:	89 e9                	mov    %ebp,%ecx
  8024ea:	29 ef                	sub    %ebp,%edi
  8024ec:	d3 e0                	shl    %cl,%eax
  8024ee:	89 f9                	mov    %edi,%ecx
  8024f0:	89 f2                	mov    %esi,%edx
  8024f2:	d3 ea                	shr    %cl,%edx
  8024f4:	89 e9                	mov    %ebp,%ecx
  8024f6:	09 c2                	or     %eax,%edx
  8024f8:	89 d8                	mov    %ebx,%eax
  8024fa:	89 14 24             	mov    %edx,(%esp)
  8024fd:	89 f2                	mov    %esi,%edx
  8024ff:	d3 e2                	shl    %cl,%edx
  802501:	89 f9                	mov    %edi,%ecx
  802503:	89 54 24 04          	mov    %edx,0x4(%esp)
  802507:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	89 e9                	mov    %ebp,%ecx
  80250f:	89 c6                	mov    %eax,%esi
  802511:	d3 e3                	shl    %cl,%ebx
  802513:	89 f9                	mov    %edi,%ecx
  802515:	89 d0                	mov    %edx,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	09 d8                	or     %ebx,%eax
  80251d:	89 d3                	mov    %edx,%ebx
  80251f:	89 f2                	mov    %esi,%edx
  802521:	f7 34 24             	divl   (%esp)
  802524:	89 d6                	mov    %edx,%esi
  802526:	d3 e3                	shl    %cl,%ebx
  802528:	f7 64 24 04          	mull   0x4(%esp)
  80252c:	39 d6                	cmp    %edx,%esi
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 d1                	mov    %edx,%ecx
  802534:	89 c3                	mov    %eax,%ebx
  802536:	72 08                	jb     802540 <__umoddi3+0x110>
  802538:	75 11                	jne    80254b <__umoddi3+0x11b>
  80253a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80253e:	73 0b                	jae    80254b <__umoddi3+0x11b>
  802540:	2b 44 24 04          	sub    0x4(%esp),%eax
  802544:	1b 14 24             	sbb    (%esp),%edx
  802547:	89 d1                	mov    %edx,%ecx
  802549:	89 c3                	mov    %eax,%ebx
  80254b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80254f:	29 da                	sub    %ebx,%edx
  802551:	19 ce                	sbb    %ecx,%esi
  802553:	89 f9                	mov    %edi,%ecx
  802555:	89 f0                	mov    %esi,%eax
  802557:	d3 e0                	shl    %cl,%eax
  802559:	89 e9                	mov    %ebp,%ecx
  80255b:	d3 ea                	shr    %cl,%edx
  80255d:	89 e9                	mov    %ebp,%ecx
  80255f:	d3 ee                	shr    %cl,%esi
  802561:	09 d0                	or     %edx,%eax
  802563:	89 f2                	mov    %esi,%edx
  802565:	83 c4 1c             	add    $0x1c,%esp
  802568:	5b                   	pop    %ebx
  802569:	5e                   	pop    %esi
  80256a:	5f                   	pop    %edi
  80256b:	5d                   	pop    %ebp
  80256c:	c3                   	ret    
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 f9                	sub    %edi,%ecx
  802572:	19 d6                	sbb    %edx,%esi
  802574:	89 74 24 04          	mov    %esi,0x4(%esp)
  802578:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80257c:	e9 18 ff ff ff       	jmp    802499 <__umoddi3+0x69>
