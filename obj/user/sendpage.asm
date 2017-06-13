
obj/user/sendpage.debug:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 fa 0e 00 00       	call   800f38 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 14 11 00 00       	call   801170 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 80 27 80 00       	push   $0x802780
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 79 07 00 00       	call   8007f8 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 6e 08 00 00       	call   800901 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 94 27 80 00       	push   $0x802794
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 40 07 00 00       	call   8007f8 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 5c 09 00 00       	call   800a2b <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 06 11 00 00       	call   8011e6 <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 34 0b 00 00       	call   800c34 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 ea 06 00 00       	call   8007f8 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 06 09 00 00       	call   800a2b <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 b0 10 00 00       	call   8011e6 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 27 10 00 00       	call   801170 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 80 27 80 00       	push   $0x802780
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 8c 06 00 00       	call   8007f8 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 81 07 00 00       	call   800901 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 b4 27 80 00       	push   $0x8027b4
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = 0;
	envid_t envid = sys_getenvid();
  8001a4:	e8 4d 0a 00 00       	call   800bf6 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 4f 12 00 00       	call   801439 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 c1 09 00 00       	call   800bb5 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 4f 09 00 00       	call   800b78 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 54 01 00 00       	call   8003c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 f4 08 00 00       	call   800b78 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 fc 21 00 00       	call   8024f0 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 e9 22 00 00       	call   802620 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 2c 28 80 00 	movsbl 0x80282c(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800352:	83 fa 01             	cmp    $0x1,%edx
  800355:	7e 0e                	jle    800365 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800357:	8b 10                	mov    (%eax),%edx
  800359:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035c:	89 08                	mov    %ecx,(%eax)
  80035e:	8b 02                	mov    (%edx),%eax
  800360:	8b 52 04             	mov    0x4(%edx),%edx
  800363:	eb 22                	jmp    800387 <getuint+0x38>
	else if (lflag)
  800365:	85 d2                	test   %edx,%edx
  800367:	74 10                	je     800379 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 02                	mov    (%edx),%eax
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 0e                	jmp    800387 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800379:	8b 10                	mov    (%eax),%edx
  80037b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80037e:	89 08                	mov    %ecx,(%eax)
  800380:	8b 02                	mov    (%edx),%eax
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80038f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800393:	8b 10                	mov    (%eax),%edx
  800395:	3b 50 04             	cmp    0x4(%eax),%edx
  800398:	73 0a                	jae    8003a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039d:	89 08                	mov    %ecx,(%eax)
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	88 02                	mov    %al,(%edx)
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 10             	pushl  0x10(%ebp)
  8003b3:	ff 75 0c             	pushl  0xc(%ebp)
  8003b6:	ff 75 08             	pushl  0x8(%ebp)
  8003b9:	e8 05 00 00 00       	call   8003c3 <vprintfmt>
	va_end(ap);
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	57                   	push   %edi
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	83 ec 2c             	sub    $0x2c,%esp
  8003cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d5:	eb 12                	jmp    8003e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d7:	85 c0                	test   %eax,%eax
  8003d9:	0f 84 a9 03 00 00    	je     800788 <vprintfmt+0x3c5>
				return;
			putch(ch, putdat);
  8003df:	83 ec 08             	sub    $0x8,%esp
  8003e2:	53                   	push   %ebx
  8003e3:	50                   	push   %eax
  8003e4:	ff d6                	call   *%esi
  8003e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	83 c7 01             	add    $0x1,%edi
  8003ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f0:	83 f8 25             	cmp    $0x25,%eax
  8003f3:	75 e2                	jne    8003d7 <vprintfmt+0x14>
  8003f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800400:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800407:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80040e:	ba 00 00 00 00       	mov    $0x0,%edx
  800413:	eb 07                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800418:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8d 47 01             	lea    0x1(%edi),%eax
  80041f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800422:	0f b6 07             	movzbl (%edi),%eax
  800425:	0f b6 c8             	movzbl %al,%ecx
  800428:	83 e8 23             	sub    $0x23,%eax
  80042b:	3c 55                	cmp    $0x55,%al
  80042d:	0f 87 3a 03 00 00    	ja     80076d <vprintfmt+0x3aa>
  800433:	0f b6 c0             	movzbl %al,%eax
  800436:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800440:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800444:	eb d6                	jmp    80041c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800449:	b8 00 00 00 00       	mov    $0x0,%eax
  80044e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800451:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800454:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800458:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80045e:	83 fa 09             	cmp    $0x9,%edx
  800461:	77 39                	ja     80049c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800463:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800466:	eb e9                	jmp    800451 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 48 04             	lea    0x4(%eax),%ecx
  80046e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800471:	8b 00                	mov    (%eax),%eax
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800479:	eb 27                	jmp    8004a2 <vprintfmt+0xdf>
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	b9 00 00 00 00       	mov    $0x0,%ecx
  800485:	0f 49 c8             	cmovns %eax,%ecx
  800488:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048e:	eb 8c                	jmp    80041c <vprintfmt+0x59>
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800493:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049a:	eb 80                	jmp    80041c <vprintfmt+0x59>
  80049c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a6:	0f 89 70 ff ff ff    	jns    80041c <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b9:	e9 5e ff ff ff       	jmp    80041c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c4:	e9 53 ff ff ff       	jmp    80041c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8d 50 04             	lea    0x4(%eax),%edx
  8004cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	ff 30                	pushl  (%eax)
  8004d8:	ff d6                	call   *%esi
			break;
  8004da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e0:	e9 04 ff ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	8d 50 04             	lea    0x4(%eax),%edx
  8004eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	99                   	cltd   
  8004f1:	31 d0                	xor    %edx,%eax
  8004f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f5:	83 f8 0f             	cmp    $0xf,%eax
  8004f8:	7f 0b                	jg     800505 <vprintfmt+0x142>
  8004fa:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800501:	85 d2                	test   %edx,%edx
  800503:	75 18                	jne    80051d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800505:	50                   	push   %eax
  800506:	68 44 28 80 00       	push   $0x802844
  80050b:	53                   	push   %ebx
  80050c:	56                   	push   %esi
  80050d:	e8 94 fe ff ff       	call   8003a6 <printfmt>
  800512:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800518:	e9 cc fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051d:	52                   	push   %edx
  80051e:	68 c9 2c 80 00       	push   $0x802cc9
  800523:	53                   	push   %ebx
  800524:	56                   	push   %esi
  800525:	e8 7c fe ff ff       	call   8003a6 <printfmt>
  80052a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800530:	e9 b4 fe ff ff       	jmp    8003e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800540:	85 ff                	test   %edi,%edi
  800542:	b8 3d 28 80 00       	mov    $0x80283d,%eax
  800547:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80054e:	0f 8e 94 00 00 00    	jle    8005e8 <vprintfmt+0x225>
  800554:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800558:	0f 84 98 00 00 00    	je     8005f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 d0             	pushl  -0x30(%ebp)
  800564:	57                   	push   %edi
  800565:	e8 a6 02 00 00       	call   800810 <strnlen>
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 c1                	sub    %eax,%ecx
  80056f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800575:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800579:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	eb 0f                	jmp    800592 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	ff 75 e0             	pushl  -0x20(%ebp)
  80058a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	83 ef 01             	sub    $0x1,%edi
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 ff                	test   %edi,%edi
  800594:	7f ed                	jg     800583 <vprintfmt+0x1c0>
  800596:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059c:	85 c9                	test   %ecx,%ecx
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	0f 49 c1             	cmovns %ecx,%eax
  8005a6:	29 c1                	sub    %eax,%ecx
  8005a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b1:	89 cb                	mov    %ecx,%ebx
  8005b3:	eb 4d                	jmp    800602 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b9:	74 1b                	je     8005d6 <vprintfmt+0x213>
  8005bb:	0f be c0             	movsbl %al,%eax
  8005be:	83 e8 20             	sub    $0x20,%eax
  8005c1:	83 f8 5e             	cmp    $0x5e,%eax
  8005c4:	76 10                	jbe    8005d6 <vprintfmt+0x213>
					putch('?', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	6a 3f                	push   $0x3f
  8005ce:	ff 55 08             	call   *0x8(%ebp)
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb 0d                	jmp    8005e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	52                   	push   %edx
  8005dd:	ff 55 08             	call   *0x8(%ebp)
  8005e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e3:	83 eb 01             	sub    $0x1,%ebx
  8005e6:	eb 1a                	jmp    800602 <vprintfmt+0x23f>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 0c                	jmp    800602 <vprintfmt+0x23f>
  8005f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800602:	83 c7 01             	add    $0x1,%edi
  800605:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800609:	0f be d0             	movsbl %al,%edx
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 23                	je     800633 <vprintfmt+0x270>
  800610:	85 f6                	test   %esi,%esi
  800612:	78 a1                	js     8005b5 <vprintfmt+0x1f2>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 9c                	jns    8005b5 <vprintfmt+0x1f2>
  800619:	89 df                	mov    %ebx,%edi
  80061b:	8b 75 08             	mov    0x8(%ebp),%esi
  80061e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800621:	eb 18                	jmp    80063b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 20                	push   $0x20
  800629:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 ef 01             	sub    $0x1,%edi
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb 08                	jmp    80063b <vprintfmt+0x278>
  800633:	89 df                	mov    %ebx,%edi
  800635:	8b 75 08             	mov    0x8(%ebp),%esi
  800638:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063b:	85 ff                	test   %edi,%edi
  80063d:	7f e4                	jg     800623 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 a2 fd ff ff       	jmp    8003e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800647:	83 fa 01             	cmp    $0x1,%edx
  80064a:	7e 16                	jle    800662 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 08             	lea    0x8(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	eb 32                	jmp    800694 <vprintfmt+0x2d1>
	else if (lflag)
  800662:	85 d2                	test   %edx,%edx
  800664:	74 18                	je     80067e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 50 04             	lea    0x4(%eax),%edx
  80066c:	89 55 14             	mov    %edx,0x14(%ebp)
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 c1                	mov    %eax,%ecx
  800676:	c1 f9 1f             	sar    $0x1f,%ecx
  800679:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80067c:	eb 16                	jmp    800694 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 c1                	mov    %eax,%ecx
  80068e:	c1 f9 1f             	sar    $0x1f,%ecx
  800691:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800694:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800697:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80069a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80069f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a3:	0f 89 90 00 00 00    	jns    800739 <vprintfmt+0x376>
				putch('-', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 2d                	push   $0x2d
  8006af:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006b7:	f7 d8                	neg    %eax
  8006b9:	83 d2 00             	adc    $0x0,%edx
  8006bc:	f7 da                	neg    %edx
  8006be:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8006c6:	eb 71                	jmp    800739 <vprintfmt+0x376>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cb:	e8 7f fc ff ff       	call   80034f <getuint>
			base = 10;
  8006d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8006d5:	eb 62                	jmp    800739 <vprintfmt+0x376>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 70 fc ff ff       	call   80034f <getuint>
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
  8006df:	83 ec 0c             	sub    $0xc,%esp
  8006e2:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
  8006e6:	51                   	push   %ecx
  8006e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ea:	6a 08                	push   $0x8
  8006ec:	52                   	push   %edx
  8006ed:	50                   	push   %eax
  8006ee:	89 da                	mov    %ebx,%edx
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	e8 a9 fb ff ff       	call   8002a0 <printnum>
			break;
  8006f7:	83 c4 20             	add    $0x20,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
			printnum(putch, putdat, num, base, width, padc);
			break;
  8006fd:	e9 e7 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	6a 30                	push   $0x30
  800708:	ff d6                	call   *%esi
			putch('x', putdat);
  80070a:	83 c4 08             	add    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 78                	push   $0x78
  800710:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800722:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800725:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80072a:	eb 0d                	jmp    800739 <vprintfmt+0x376>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80072c:	8d 45 14             	lea    0x14(%ebp),%eax
  80072f:	e8 1b fc ff ff       	call   80034f <getuint>
			base = 16;
  800734:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800739:	83 ec 0c             	sub    $0xc,%esp
  80073c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800740:	57                   	push   %edi
  800741:	ff 75 e0             	pushl  -0x20(%ebp)
  800744:	51                   	push   %ecx
  800745:	52                   	push   %edx
  800746:	50                   	push   %eax
  800747:	89 da                	mov    %ebx,%edx
  800749:	89 f0                	mov    %esi,%eax
  80074b:	e8 50 fb ff ff       	call   8002a0 <printnum>
			break;
  800750:	83 c4 20             	add    $0x20,%esp
  800753:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800756:	e9 8e fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	53                   	push   %ebx
  80075f:	51                   	push   %ecx
  800760:	ff d6                	call   *%esi
			break;
  800762:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800768:	e9 7c fc ff ff       	jmp    8003e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 25                	push   $0x25
  800773:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	eb 03                	jmp    80077d <vprintfmt+0x3ba>
  80077a:	83 ef 01             	sub    $0x1,%edi
  80077d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800781:	75 f7                	jne    80077a <vprintfmt+0x3b7>
  800783:	e9 61 fc ff ff       	jmp    8003e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5f                   	pop    %edi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 18             	sub    $0x18,%esp
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ad:	85 c0                	test   %eax,%eax
  8007af:	74 26                	je     8007d7 <vsnprintf+0x47>
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	7e 22                	jle    8007d7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b5:	ff 75 14             	pushl  0x14(%ebp)
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	68 89 03 80 00       	push   $0x800389
  8007c4:	e8 fa fb ff ff       	call   8003c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	eb 05                	jmp    8007dc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e7:	50                   	push   %eax
  8007e8:	ff 75 10             	pushl  0x10(%ebp)
  8007eb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ee:	ff 75 08             	pushl  0x8(%ebp)
  8007f1:	e8 9a ff ff ff       	call   800790 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800803:	eb 03                	jmp    800808 <strlen+0x10>
		n++;
  800805:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800808:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080c:	75 f7                	jne    800805 <strlen+0xd>
		n++;
	return n;
}
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800819:	ba 00 00 00 00       	mov    $0x0,%edx
  80081e:	eb 03                	jmp    800823 <strnlen+0x13>
		n++;
  800820:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800823:	39 c2                	cmp    %eax,%edx
  800825:	74 08                	je     80082f <strnlen+0x1f>
  800827:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80082b:	75 f3                	jne    800820 <strnlen+0x10>
  80082d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	83 c2 01             	add    $0x1,%edx
  800840:	83 c1 01             	add    $0x1,%ecx
  800843:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800847:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084a:	84 db                	test   %bl,%bl
  80084c:	75 ef                	jne    80083d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084e:	5b                   	pop    %ebx
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800858:	53                   	push   %ebx
  800859:	e8 9a ff ff ff       	call   8007f8 <strlen>
  80085e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800861:	ff 75 0c             	pushl  0xc(%ebp)
  800864:	01 d8                	add    %ebx,%eax
  800866:	50                   	push   %eax
  800867:	e8 c5 ff ff ff       	call   800831 <strcpy>
	return dst;
}
  80086c:	89 d8                	mov    %ebx,%eax
  80086e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800871:	c9                   	leave  
  800872:	c3                   	ret    

00800873 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 75 08             	mov    0x8(%ebp),%esi
  80087b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087e:	89 f3                	mov    %esi,%ebx
  800880:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800883:	89 f2                	mov    %esi,%edx
  800885:	eb 0f                	jmp    800896 <strncpy+0x23>
		*dst++ = *src;
  800887:	83 c2 01             	add    $0x1,%edx
  80088a:	0f b6 01             	movzbl (%ecx),%eax
  80088d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800890:	80 39 01             	cmpb   $0x1,(%ecx)
  800893:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800896:	39 da                	cmp    %ebx,%edx
  800898:	75 ed                	jne    800887 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	5b                   	pop    %ebx
  80089d:	5e                   	pop    %esi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	56                   	push   %esi
  8008a4:	53                   	push   %ebx
  8008a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ab:	8b 55 10             	mov    0x10(%ebp),%edx
  8008ae:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b0:	85 d2                	test   %edx,%edx
  8008b2:	74 21                	je     8008d5 <strlcpy+0x35>
  8008b4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b8:	89 f2                	mov    %esi,%edx
  8008ba:	eb 09                	jmp    8008c5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008bc:	83 c2 01             	add    $0x1,%edx
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c5:	39 c2                	cmp    %eax,%edx
  8008c7:	74 09                	je     8008d2 <strlcpy+0x32>
  8008c9:	0f b6 19             	movzbl (%ecx),%ebx
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	75 ec                	jne    8008bc <strlcpy+0x1c>
  8008d0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d5:	29 f0                	sub    %esi,%eax
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e4:	eb 06                	jmp    8008ec <strcmp+0x11>
		p++, q++;
  8008e6:	83 c1 01             	add    $0x1,%ecx
  8008e9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ec:	0f b6 01             	movzbl (%ecx),%eax
  8008ef:	84 c0                	test   %al,%al
  8008f1:	74 04                	je     8008f7 <strcmp+0x1c>
  8008f3:	3a 02                	cmp    (%edx),%al
  8008f5:	74 ef                	je     8008e6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f7:	0f b6 c0             	movzbl %al,%eax
  8008fa:	0f b6 12             	movzbl (%edx),%edx
  8008fd:	29 d0                	sub    %edx,%eax
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090b:	89 c3                	mov    %eax,%ebx
  80090d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800910:	eb 06                	jmp    800918 <strncmp+0x17>
		n--, p++, q++;
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800918:	39 d8                	cmp    %ebx,%eax
  80091a:	74 15                	je     800931 <strncmp+0x30>
  80091c:	0f b6 08             	movzbl (%eax),%ecx
  80091f:	84 c9                	test   %cl,%cl
  800921:	74 04                	je     800927 <strncmp+0x26>
  800923:	3a 0a                	cmp    (%edx),%cl
  800925:	74 eb                	je     800912 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800927:	0f b6 00             	movzbl (%eax),%eax
  80092a:	0f b6 12             	movzbl (%edx),%edx
  80092d:	29 d0                	sub    %edx,%eax
  80092f:	eb 05                	jmp    800936 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800931:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800943:	eb 07                	jmp    80094c <strchr+0x13>
		if (*s == c)
  800945:	38 ca                	cmp    %cl,%dl
  800947:	74 0f                	je     800958 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800949:	83 c0 01             	add    $0x1,%eax
  80094c:	0f b6 10             	movzbl (%eax),%edx
  80094f:	84 d2                	test   %dl,%dl
  800951:	75 f2                	jne    800945 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800964:	eb 03                	jmp    800969 <strfind+0xf>
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	74 04                	je     800974 <strfind+0x1a>
  800970:	84 d2                	test   %dl,%dl
  800972:	75 f2                	jne    800966 <strfind+0xc>
			break;
	return (char *) s;
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80097f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800982:	85 c9                	test   %ecx,%ecx
  800984:	74 36                	je     8009bc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800986:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098c:	75 28                	jne    8009b6 <memset+0x40>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 23                	jne    8009b6 <memset+0x40>
		c &= 0xFF;
  800993:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800997:	89 d3                	mov    %edx,%ebx
  800999:	c1 e3 08             	shl    $0x8,%ebx
  80099c:	89 d6                	mov    %edx,%esi
  80099e:	c1 e6 18             	shl    $0x18,%esi
  8009a1:	89 d0                	mov    %edx,%eax
  8009a3:	c1 e0 10             	shl    $0x10,%eax
  8009a6:	09 f0                	or     %esi,%eax
  8009a8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009aa:	89 d8                	mov    %ebx,%eax
  8009ac:	09 d0                	or     %edx,%eax
  8009ae:	c1 e9 02             	shr    $0x2,%ecx
  8009b1:	fc                   	cld    
  8009b2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b4:	eb 06                	jmp    8009bc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b9:	fc                   	cld    
  8009ba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bc:	89 f8                	mov    %edi,%eax
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d1:	39 c6                	cmp    %eax,%esi
  8009d3:	73 35                	jae    800a0a <memmove+0x47>
  8009d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d8:	39 d0                	cmp    %edx,%eax
  8009da:	73 2e                	jae    800a0a <memmove+0x47>
		s += n;
		d += n;
  8009dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009df:	89 d6                	mov    %edx,%esi
  8009e1:	09 fe                	or     %edi,%esi
  8009e3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e9:	75 13                	jne    8009fe <memmove+0x3b>
  8009eb:	f6 c1 03             	test   $0x3,%cl
  8009ee:	75 0e                	jne    8009fe <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f0:	83 ef 04             	sub    $0x4,%edi
  8009f3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f6:	c1 e9 02             	shr    $0x2,%ecx
  8009f9:	fd                   	std    
  8009fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fc:	eb 09                	jmp    800a07 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009fe:	83 ef 01             	sub    $0x1,%edi
  800a01:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a04:	fd                   	std    
  800a05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a07:	fc                   	cld    
  800a08:	eb 1d                	jmp    800a27 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0a:	89 f2                	mov    %esi,%edx
  800a0c:	09 c2                	or     %eax,%edx
  800a0e:	f6 c2 03             	test   $0x3,%dl
  800a11:	75 0f                	jne    800a22 <memmove+0x5f>
  800a13:	f6 c1 03             	test   $0x3,%cl
  800a16:	75 0a                	jne    800a22 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a18:	c1 e9 02             	shr    $0x2,%ecx
  800a1b:	89 c7                	mov    %eax,%edi
  800a1d:	fc                   	cld    
  800a1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a20:	eb 05                	jmp    800a27 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a22:	89 c7                	mov    %eax,%edi
  800a24:	fc                   	cld    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a2e:	ff 75 10             	pushl  0x10(%ebp)
  800a31:	ff 75 0c             	pushl  0xc(%ebp)
  800a34:	ff 75 08             	pushl  0x8(%ebp)
  800a37:	e8 87 ff ff ff       	call   8009c3 <memmove>
}
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a49:	89 c6                	mov    %eax,%esi
  800a4b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4e:	eb 1a                	jmp    800a6a <memcmp+0x2c>
		if (*s1 != *s2)
  800a50:	0f b6 08             	movzbl (%eax),%ecx
  800a53:	0f b6 1a             	movzbl (%edx),%ebx
  800a56:	38 d9                	cmp    %bl,%cl
  800a58:	74 0a                	je     800a64 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5a:	0f b6 c1             	movzbl %cl,%eax
  800a5d:	0f b6 db             	movzbl %bl,%ebx
  800a60:	29 d8                	sub    %ebx,%eax
  800a62:	eb 0f                	jmp    800a73 <memcmp+0x35>
		s1++, s2++;
  800a64:	83 c0 01             	add    $0x1,%eax
  800a67:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6a:	39 f0                	cmp    %esi,%eax
  800a6c:	75 e2                	jne    800a50 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a73:	5b                   	pop    %ebx
  800a74:	5e                   	pop    %esi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	53                   	push   %ebx
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a7e:	89 c1                	mov    %eax,%ecx
  800a80:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a83:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a87:	eb 0a                	jmp    800a93 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a89:	0f b6 10             	movzbl (%eax),%edx
  800a8c:	39 da                	cmp    %ebx,%edx
  800a8e:	74 07                	je     800a97 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	39 c8                	cmp    %ecx,%eax
  800a95:	72 f2                	jb     800a89 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a97:	5b                   	pop    %ebx
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa6:	eb 03                	jmp    800aab <strtol+0x11>
		s++;
  800aa8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aab:	0f b6 01             	movzbl (%ecx),%eax
  800aae:	3c 20                	cmp    $0x20,%al
  800ab0:	74 f6                	je     800aa8 <strtol+0xe>
  800ab2:	3c 09                	cmp    $0x9,%al
  800ab4:	74 f2                	je     800aa8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab6:	3c 2b                	cmp    $0x2b,%al
  800ab8:	75 0a                	jne    800ac4 <strtol+0x2a>
		s++;
  800aba:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac2:	eb 11                	jmp    800ad5 <strtol+0x3b>
  800ac4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac9:	3c 2d                	cmp    $0x2d,%al
  800acb:	75 08                	jne    800ad5 <strtol+0x3b>
		s++, neg = 1;
  800acd:	83 c1 01             	add    $0x1,%ecx
  800ad0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800adb:	75 15                	jne    800af2 <strtol+0x58>
  800add:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae0:	75 10                	jne    800af2 <strtol+0x58>
  800ae2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae6:	75 7c                	jne    800b64 <strtol+0xca>
		s += 2, base = 16;
  800ae8:	83 c1 02             	add    $0x2,%ecx
  800aeb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af0:	eb 16                	jmp    800b08 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af2:	85 db                	test   %ebx,%ebx
  800af4:	75 12                	jne    800b08 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afb:	80 39 30             	cmpb   $0x30,(%ecx)
  800afe:	75 08                	jne    800b08 <strtol+0x6e>
		s++, base = 8;
  800b00:	83 c1 01             	add    $0x1,%ecx
  800b03:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b10:	0f b6 11             	movzbl (%ecx),%edx
  800b13:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b16:	89 f3                	mov    %esi,%ebx
  800b18:	80 fb 09             	cmp    $0x9,%bl
  800b1b:	77 08                	ja     800b25 <strtol+0x8b>
			dig = *s - '0';
  800b1d:	0f be d2             	movsbl %dl,%edx
  800b20:	83 ea 30             	sub    $0x30,%edx
  800b23:	eb 22                	jmp    800b47 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b25:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 19             	cmp    $0x19,%bl
  800b2d:	77 08                	ja     800b37 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b2f:	0f be d2             	movsbl %dl,%edx
  800b32:	83 ea 57             	sub    $0x57,%edx
  800b35:	eb 10                	jmp    800b47 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b37:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 19             	cmp    $0x19,%bl
  800b3f:	77 16                	ja     800b57 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b47:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4a:	7d 0b                	jge    800b57 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b4c:	83 c1 01             	add    $0x1,%ecx
  800b4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b53:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b55:	eb b9                	jmp    800b10 <strtol+0x76>

	if (endptr)
  800b57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5b:	74 0d                	je     800b6a <strtol+0xd0>
		*endptr = (char *) s;
  800b5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b60:	89 0e                	mov    %ecx,(%esi)
  800b62:	eb 06                	jmp    800b6a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b64:	85 db                	test   %ebx,%ebx
  800b66:	74 98                	je     800b00 <strtol+0x66>
  800b68:	eb 9e                	jmp    800b08 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6a:	89 c2                	mov    %eax,%edx
  800b6c:	f7 da                	neg    %edx
  800b6e:	85 ff                	test   %edi,%edi
  800b70:	0f 45 c2             	cmovne %edx,%eax
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
  800b89:	89 c3                	mov    %eax,%ebx
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	89 c6                	mov    %eax,%esi
  800b8f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba6:	89 d1                	mov    %edx,%ecx
  800ba8:	89 d3                	mov    %edx,%ebx
  800baa:	89 d7                	mov    %edx,%edi
  800bac:	89 d6                	mov    %edx,%esi
  800bae:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc3:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	89 cb                	mov    %ecx,%ebx
  800bcd:	89 cf                	mov    %ecx,%edi
  800bcf:	89 ce                	mov    %ecx,%esi
  800bd1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	7e 17                	jle    800bee <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd7:	83 ec 0c             	sub    $0xc,%esp
  800bda:	50                   	push   %eax
  800bdb:	6a 03                	push   $0x3
  800bdd:	68 1f 2b 80 00       	push   $0x802b1f
  800be2:	6a 23                	push   $0x23
  800be4:	68 3c 2b 80 00       	push   $0x802b3c
  800be9:	e8 dd 17 00 00       	call   8023cb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 02 00 00 00       	mov    $0x2,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_yield>:

void
sys_yield(void)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c20:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c25:	89 d1                	mov    %edx,%ecx
  800c27:	89 d3                	mov    %edx,%ebx
  800c29:	89 d7                	mov    %edx,%edi
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	be 00 00 00 00       	mov    $0x0,%esi
  800c42:	b8 04 00 00 00       	mov    $0x4,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c50:	89 f7                	mov    %esi,%edi
  800c52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 17                	jle    800c6f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 04                	push   $0x4
  800c5e:	68 1f 2b 80 00       	push   $0x802b1f
  800c63:	6a 23                	push   $0x23
  800c65:	68 3c 2b 80 00       	push   $0x802b3c
  800c6a:	e8 5c 17 00 00       	call   8023cb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	b8 05 00 00 00       	mov    $0x5,%eax
  800c85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c91:	8b 75 18             	mov    0x18(%ebp),%esi
  800c94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 17                	jle    800cb1 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	50                   	push   %eax
  800c9e:	6a 05                	push   $0x5
  800ca0:	68 1f 2b 80 00       	push   $0x802b1f
  800ca5:	6a 23                	push   $0x23
  800ca7:	68 3c 2b 80 00       	push   $0x802b3c
  800cac:	e8 1a 17 00 00       	call   8023cb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc7:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	89 df                	mov    %ebx,%edi
  800cd4:	89 de                	mov    %ebx,%esi
  800cd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 17                	jle    800cf3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 06                	push   $0x6
  800ce2:	68 1f 2b 80 00       	push   $0x802b1f
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 3c 2b 80 00       	push   $0x802b3c
  800cee:	e8 d8 16 00 00       	call   8023cb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d09:	b8 08 00 00 00       	mov    $0x8,%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	8b 55 08             	mov    0x8(%ebp),%edx
  800d14:	89 df                	mov    %ebx,%edi
  800d16:	89 de                	mov    %ebx,%esi
  800d18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 17                	jle    800d35 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	50                   	push   %eax
  800d22:	6a 08                	push   $0x8
  800d24:	68 1f 2b 80 00       	push   $0x802b1f
  800d29:	6a 23                	push   $0x23
  800d2b:	68 3c 2b 80 00       	push   $0x802b3c
  800d30:	e8 96 16 00 00       	call   8023cb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 17                	jle    800d77 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 09                	push   $0x9
  800d66:	68 1f 2b 80 00       	push   $0x802b1f
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 3c 2b 80 00       	push   $0x802b3c
  800d72:	e8 54 16 00 00       	call   8023cb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 17                	jle    800db9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	50                   	push   %eax
  800da6:	6a 0a                	push   $0xa
  800da8:	68 1f 2b 80 00       	push   $0x802b1f
  800dad:	6a 23                	push   $0x23
  800daf:	68 3c 2b 80 00       	push   $0x802b3c
  800db4:	e8 12 16 00 00       	call   8023cb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc7:	be 00 00 00 00       	mov    $0x0,%esi
  800dcc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dda:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ddf:	5b                   	pop    %ebx
  800de0:	5e                   	pop    %esi
  800de1:	5f                   	pop    %edi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	57                   	push   %edi
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ded:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df2:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	89 cb                	mov    %ecx,%ebx
  800dfc:	89 cf                	mov    %ecx,%edi
  800dfe:	89 ce                	mov    %ecx,%esi
  800e00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7e 17                	jle    800e1d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	50                   	push   %eax
  800e0a:	6a 0d                	push   $0xd
  800e0c:	68 1f 2b 80 00       	push   $0x802b1f
  800e11:	6a 23                	push   $0x23
  800e13:	68 3c 2b 80 00       	push   $0x802b3c
  800e18:	e8 ae 15 00 00       	call   8023cb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e30:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e35:	89 d1                	mov    %edx,%ecx
  800e37:	89 d3                	mov    %edx,%ebx
  800e39:	89 d7                	mov    %edx,%edi
  800e3b:	89 d6                	mov    %edx,%esi
  800e3d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e4e:	8b 02                	mov    (%edx),%eax
	uint32_t err = utf->utf_err;
  800e50:	8b 4a 04             	mov    0x4(%edx),%ecx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800e53:	f6 c1 02             	test   $0x2,%cl
  800e56:	74 2e                	je     800e86 <pgfault+0x42>
  800e58:	89 c2                	mov    %eax,%edx
  800e5a:	c1 ea 16             	shr    $0x16,%edx
  800e5d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e64:	f6 c2 01             	test   $0x1,%dl
  800e67:	74 1d                	je     800e86 <pgfault+0x42>
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	c1 ea 0c             	shr    $0xc,%edx
  800e6e:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
  800e75:	f6 c3 01             	test   $0x1,%bl
  800e78:	74 0c                	je     800e86 <pgfault+0x42>
  800e7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e81:	f6 c6 08             	test   $0x8,%dh
  800e84:	75 12                	jne    800e98 <pgfault+0x54>
		panic("pgfault write and COW %e",err);	
  800e86:	51                   	push   %ecx
  800e87:	68 4a 2b 80 00       	push   $0x802b4a
  800e8c:	6a 1e                	push   $0x1e
  800e8e:	68 63 2b 80 00       	push   $0x802b63
  800e93:	e8 33 15 00 00       	call   8023cb <_panic>
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	addr = ROUNDDOWN(addr, PGSIZE);
  800e98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e9d:	89 c3                	mov    %eax,%ebx
	
	if((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_W|PTE_U))<0)
  800e9f:	83 ec 04             	sub    $0x4,%esp
  800ea2:	6a 07                	push   $0x7
  800ea4:	68 00 f0 7f 00       	push   $0x7ff000
  800ea9:	6a 00                	push   $0x0
  800eab:	e8 84 fd ff ff       	call   800c34 <sys_page_alloc>
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	79 12                	jns    800ec9 <pgfault+0x85>
		panic("pgfault sys_page_alloc: %e",r);
  800eb7:	50                   	push   %eax
  800eb8:	68 6e 2b 80 00       	push   $0x802b6e
  800ebd:	6a 29                	push   $0x29
  800ebf:	68 63 2b 80 00       	push   $0x802b63
  800ec4:	e8 02 15 00 00       	call   8023cb <_panic>
		
	memcpy(PFTEMP, addr, PGSIZE);
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	68 00 10 00 00       	push   $0x1000
  800ed1:	53                   	push   %ebx
  800ed2:	68 00 f0 7f 00       	push   $0x7ff000
  800ed7:	e8 4f fb ff ff       	call   800a2b <memcpy>
	
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800edc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ee3:	53                   	push   %ebx
  800ee4:	6a 00                	push   $0x0
  800ee6:	68 00 f0 7f 00       	push   $0x7ff000
  800eeb:	6a 00                	push   $0x0
  800eed:	e8 85 fd ff ff       	call   800c77 <sys_page_map>
  800ef2:	83 c4 20             	add    $0x20,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	79 12                	jns    800f0b <pgfault+0xc7>
		panic("pgfault sys_page_map: %e", r);
  800ef9:	50                   	push   %eax
  800efa:	68 89 2b 80 00       	push   $0x802b89
  800eff:	6a 2e                	push   $0x2e
  800f01:	68 63 2b 80 00       	push   $0x802b63
  800f06:	e8 c0 14 00 00       	call   8023cb <_panic>
		
	if((r = sys_page_unmap(0, PFTEMP))<0)
  800f0b:	83 ec 08             	sub    $0x8,%esp
  800f0e:	68 00 f0 7f 00       	push   $0x7ff000
  800f13:	6a 00                	push   $0x0
  800f15:	e8 9f fd ff ff       	call   800cb9 <sys_page_unmap>
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 12                	jns    800f33 <pgfault+0xef>
		panic("pgfault sys_page_unmap: %e", r);
  800f21:	50                   	push   %eax
  800f22:	68 a2 2b 80 00       	push   $0x802ba2
  800f27:	6a 31                	push   $0x31
  800f29:	68 63 2b 80 00       	push   $0x802b63
  800f2e:	e8 98 14 00 00       	call   8023cb <_panic>

}
  800f33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{	
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	83 ec 28             	sub    $0x28,%esp
	set_pgfault_handler(pgfault);
  800f41:	68 44 0e 80 00       	push   $0x800e44
  800f46:	e8 c6 14 00 00       	call   802411 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f4b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f50:	cd 30                	int    $0x30
  800f52:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid;
	// LAB 4: Your code here.
	envid = sys_exofork();
	uint32_t addr;
	
	if (envid == 0) {
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f60:	85 c0                	test   %eax,%eax
  800f62:	75 21                	jne    800f85 <fork+0x4d>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f64:	e8 8d fc ff ff       	call   800bf6 <sys_getenvid>
  800f69:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f6e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f71:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f76:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f80:	e9 c9 01 00 00       	jmp    80114e <fork+0x216>
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
		if (((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U))){
  800f85:	89 d8                	mov    %ebx,%eax
  800f87:	c1 e8 16             	shr    $0x16,%eax
  800f8a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f91:	a8 01                	test   $0x1,%al
  800f93:	0f 84 1b 01 00 00    	je     8010b4 <fork+0x17c>
  800f99:	89 de                	mov    %ebx,%esi
  800f9b:	c1 ee 0c             	shr    $0xc,%esi
  800f9e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fa5:	a8 01                	test   $0x1,%al
  800fa7:	0f 84 07 01 00 00    	je     8010b4 <fork+0x17c>
  800fad:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fb4:	a8 04                	test   $0x4,%al
  800fb6:	0f 84 f8 00 00 00    	je     8010b4 <fork+0x17c>
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	// LAB 4: Your code here.
	if((uvpt[pn] & (PTE_SHARE))){
  800fbc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc3:	f6 c4 04             	test   $0x4,%ah
  800fc6:	74 3c                	je     801004 <fork+0xcc>
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE),uvpt[pn] & PTE_SYSCALL))<0)
  800fc8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fcf:	c1 e6 0c             	shl    $0xc,%esi
  800fd2:	83 ec 0c             	sub    $0xc,%esp
  800fd5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fda:	50                   	push   %eax
  800fdb:	56                   	push   %esi
  800fdc:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fdf:	56                   	push   %esi
  800fe0:	6a 00                	push   $0x0
  800fe2:	e8 90 fc ff ff       	call   800c77 <sys_page_map>
  800fe7:	83 c4 20             	add    $0x20,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	0f 89 c2 00 00 00    	jns    8010b4 <fork+0x17c>
			panic("duppage: %e", r);
  800ff2:	50                   	push   %eax
  800ff3:	68 bd 2b 80 00       	push   $0x802bbd
  800ff8:	6a 48                	push   $0x48
  800ffa:	68 63 2b 80 00       	push   $0x802b63
  800fff:	e8 c7 13 00 00       	call   8023cb <_panic>
	}
	
	else if((uvpt[pn] & (PTE_COW))||(uvpt[pn] & (PTE_W))){
  801004:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100b:	f6 c4 08             	test   $0x8,%ah
  80100e:	75 0b                	jne    80101b <fork+0xe3>
  801010:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801017:	a8 02                	test   $0x2,%al
  801019:	74 6c                	je     801087 <fork+0x14f>
		if(uvpt[pn] & PTE_U)
  80101b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801022:	83 e0 04             	and    $0x4,%eax
			perm |= PTE_U;
  801025:	83 f8 01             	cmp    $0x1,%eax
  801028:	19 ff                	sbb    %edi,%edi
  80102a:	83 e7 fc             	and    $0xfffffffc,%edi
  80102d:	81 c7 05 08 00 00    	add    $0x805,%edi
	
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), envid, (void *)(pn*PGSIZE), perm))<0)
  801033:	c1 e6 0c             	shl    $0xc,%esi
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103e:	56                   	push   %esi
  80103f:	6a 00                	push   $0x0
  801041:	e8 31 fc ff ff       	call   800c77 <sys_page_map>
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 12                	jns    80105f <fork+0x127>
			panic("duppage: %e", r);
  80104d:	50                   	push   %eax
  80104e:	68 bd 2b 80 00       	push   $0x802bbd
  801053:	6a 50                	push   $0x50
  801055:	68 63 2b 80 00       	push   $0x802b63
  80105a:	e8 6c 13 00 00       	call   8023cb <_panic>
			
		if((r=sys_page_map(0, (void *)(pn*PGSIZE), 0, (void*)(pn*PGSIZE), perm))<0)
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	57                   	push   %edi
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	56                   	push   %esi
  801067:	6a 00                	push   $0x0
  801069:	e8 09 fc ff ff       	call   800c77 <sys_page_map>
  80106e:	83 c4 20             	add    $0x20,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	79 3f                	jns    8010b4 <fork+0x17c>
			panic("duppage: %e", r);
  801075:	50                   	push   %eax
  801076:	68 bd 2b 80 00       	push   $0x802bbd
  80107b:	6a 53                	push   $0x53
  80107d:	68 63 2b 80 00       	push   $0x802b63
  801082:	e8 44 13 00 00       	call   8023cb <_panic>
	}
	else{
		if ((r = sys_page_map(0, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), PTE_U|PTE_P)) < 0)
  801087:	c1 e6 0c             	shl    $0xc,%esi
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	6a 05                	push   $0x5
  80108f:	56                   	push   %esi
  801090:	ff 75 e4             	pushl  -0x1c(%ebp)
  801093:	56                   	push   %esi
  801094:	6a 00                	push   $0x0
  801096:	e8 dc fb ff ff       	call   800c77 <sys_page_map>
  80109b:	83 c4 20             	add    $0x20,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 12                	jns    8010b4 <fork+0x17c>
			panic("duppage: %e", r);
  8010a2:	50                   	push   %eax
  8010a3:	68 bd 2b 80 00       	push   $0x802bbd
  8010a8:	6a 57                	push   $0x57
  8010aa:	68 63 2b 80 00       	push   $0x802b63
  8010af:	e8 17 13 00 00       	call   8023cb <_panic>
	if (envid == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	for(addr = 0; addr < USTACKTOP; addr = addr + PGSIZE){
  8010b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ba:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010c0:	0f 85 bf fe ff ff    	jne    800f85 <fork+0x4d>
			duppage(envid, PGNUM(addr));
		}
	}
	extern void _pgfault_upcall();
	
	if(sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  8010c6:	83 ec 04             	sub    $0x4,%esp
  8010c9:	6a 07                	push   $0x7
  8010cb:	68 00 f0 bf ee       	push   $0xeebff000
  8010d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8010d3:	e8 5c fb ff ff       	call   800c34 <sys_page_alloc>
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	85 c0                	test   %eax,%eax
  8010dd:	74 17                	je     8010f6 <fork+0x1be>
		panic("sys_page_alloc Error");
  8010df:	83 ec 04             	sub    $0x4,%esp
  8010e2:	68 c9 2b 80 00       	push   $0x802bc9
  8010e7:	68 83 00 00 00       	push   $0x83
  8010ec:	68 63 2b 80 00       	push   $0x802b63
  8010f1:	e8 d5 12 00 00       	call   8023cb <_panic>
			
	if((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall))<0)
  8010f6:	83 ec 08             	sub    $0x8,%esp
  8010f9:	68 80 24 80 00       	push   $0x802480
  8010fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801101:	e8 79 fc ff ff       	call   800d7f <sys_env_set_pgfault_upcall>
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	85 c0                	test   %eax,%eax
  80110b:	79 15                	jns    801122 <fork+0x1ea>
		panic("fork pgfault upcall: %e", r);
  80110d:	50                   	push   %eax
  80110e:	68 de 2b 80 00       	push   $0x802bde
  801113:	68 86 00 00 00       	push   $0x86
  801118:	68 63 2b 80 00       	push   $0x802b63
  80111d:	e8 a9 12 00 00       	call   8023cb <_panic>
	
	if((r=sys_env_set_status(envid, ENV_RUNNABLE))<0)
  801122:	83 ec 08             	sub    $0x8,%esp
  801125:	6a 02                	push   $0x2
  801127:	ff 75 e0             	pushl  -0x20(%ebp)
  80112a:	e8 cc fb ff ff       	call   800cfb <sys_env_set_status>
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	79 15                	jns    80114b <fork+0x213>
		panic("fork set status: %e", r);
  801136:	50                   	push   %eax
  801137:	68 f6 2b 80 00       	push   $0x802bf6
  80113c:	68 89 00 00 00       	push   $0x89
  801141:	68 63 2b 80 00       	push   $0x802b63
  801146:	e8 80 12 00 00       	call   8023cb <_panic>
	
	return envid;
  80114b:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    

00801156 <sfork>:


// Challenge!
int
sfork(void)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80115c:	68 0a 2c 80 00       	push   $0x802c0a
  801161:	68 93 00 00 00       	push   $0x93
  801166:	68 63 2b 80 00       	push   $0x802b63
  80116b:	e8 5b 12 00 00       	call   8023cb <_panic>

00801170 <ipc_recv>:
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)

int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	8b 75 08             	mov    0x8(%ebp),%esi
  801178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int a;
	// LAB 4: Your code here.
	if(pg)
  80117e:	85 c0                	test   %eax,%eax
  801180:	74 0e                	je     801190 <ipc_recv+0x20>
		a = sys_ipc_recv(pg);
  801182:	83 ec 0c             	sub    $0xc,%esp
  801185:	50                   	push   %eax
  801186:	e8 59 fc ff ff       	call   800de4 <sys_ipc_recv>
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	eb 10                	jmp    8011a0 <ipc_recv+0x30>
	else
		a = sys_ipc_recv((void *)UTOP);
  801190:	83 ec 0c             	sub    $0xc,%esp
  801193:	68 00 00 c0 ee       	push   $0xeec00000
  801198:	e8 47 fc ff ff       	call   800de4 <sys_ipc_recv>
  80119d:	83 c4 10             	add    $0x10,%esp
	if(a < 0){
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	79 17                	jns    8011bb <ipc_recv+0x4b>
		if(*from_env_store)
  8011a4:	83 3e 00             	cmpl   $0x0,(%esi)
  8011a7:	74 06                	je     8011af <ipc_recv+0x3f>
			*from_env_store = 0;
  8011a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store)
  8011af:	85 db                	test   %ebx,%ebx
  8011b1:	74 2c                	je     8011df <ipc_recv+0x6f>
			*perm_store = 0;
  8011b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011b9:	eb 24                	jmp    8011df <ipc_recv+0x6f>
		return a;
	}
	
	if(from_env_store)
  8011bb:	85 f6                	test   %esi,%esi
  8011bd:	74 0a                	je     8011c9 <ipc_recv+0x59>
		*from_env_store = thisenv->env_ipc_from;
  8011bf:	a1 08 40 80 00       	mov    0x804008,%eax
  8011c4:	8b 40 74             	mov    0x74(%eax),%eax
  8011c7:	89 06                	mov    %eax,(%esi)
	if(perm_store)
  8011c9:	85 db                	test   %ebx,%ebx
  8011cb:	74 0a                	je     8011d7 <ipc_recv+0x67>
		*perm_store = thisenv->env_ipc_perm;
  8011cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8011d2:	8b 40 78             	mov    0x78(%eax),%eax
  8011d5:	89 03                	mov    %eax,(%ebx)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8011dc:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	57                   	push   %edi
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 0c             	sub    $0xc,%esp
  8011ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if(pg == NULL)
  8011f8:	85 db                	test   %ebx,%ebx
		pg = (void *)(UTOP + PGSIZE);
  8011fa:	b8 00 10 c0 ee       	mov    $0xeec01000,%eax
  8011ff:	0f 44 d8             	cmove  %eax,%ebx
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
			return;
		sys_yield();
  801202:	e8 0e fa ff ff       	call   800c15 <sys_yield>
		check = sys_ipc_try_send(to_env, val, pg, perm);
  801207:	ff 75 14             	pushl  0x14(%ebp)
  80120a:	53                   	push   %ebx
  80120b:	56                   	push   %esi
  80120c:	57                   	push   %edi
  80120d:	e8 af fb ff ff       	call   800dc1 <sys_ipc_try_send>
	// LAB 4: Your code here.
	if(pg == NULL)
		pg = (void *)(UTOP + PGSIZE);
	int check =1;
	while((check >= 0) || (check == -E_IPC_NOT_RECV)){
		if(check == 0)
  801212:	89 c2                	mov    %eax,%edx
  801214:	f7 d2                	not    %edx
  801216:	c1 ea 1f             	shr    $0x1f,%edx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80121f:	0f 94 c1             	sete   %cl
  801222:	09 ca                	or     %ecx,%edx
  801224:	85 c0                	test   %eax,%eax
  801226:	0f 94 c0             	sete   %al
  801229:	38 c2                	cmp    %al,%dl
  80122b:	77 d5                	ja     801202 <ipc_send+0x1c>
			return;
		sys_yield();
		check = sys_ipc_try_send(to_env, val, pg, perm);
	}	
	//panic("ipc_send not implemented");
}
  80122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801240:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801243:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801249:	8b 52 50             	mov    0x50(%edx),%edx
  80124c:	39 ca                	cmp    %ecx,%edx
  80124e:	75 0d                	jne    80125d <ipc_find_env+0x28>
			return envs[i].env_id;
  801250:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801253:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801258:	8b 40 48             	mov    0x48(%eax),%eax
  80125b:	eb 0f                	jmp    80126c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80125d:	83 c0 01             	add    $0x1,%eax
  801260:	3d 00 04 00 00       	cmp    $0x400,%eax
  801265:	75 d9                	jne    801240 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801271:	8b 45 08             	mov    0x8(%ebp),%eax
  801274:	05 00 00 00 30       	add    $0x30000000,%eax
  801279:	c1 e8 0c             	shr    $0xc,%eax
}
  80127c:	5d                   	pop    %ebp
  80127d:	c3                   	ret    

0080127e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801281:	8b 45 08             	mov    0x8(%ebp),%eax
  801284:	05 00 00 00 30       	add    $0x30000000,%eax
  801289:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 16             	shr    $0x16,%edx
  8012a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 11                	je     8012c2 <fd_alloc+0x2d>
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 ea 0c             	shr    $0xc,%edx
  8012b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bd:	f6 c2 01             	test   $0x1,%dl
  8012c0:	75 09                	jne    8012cb <fd_alloc+0x36>
			*fd_store = fd;
  8012c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c9:	eb 17                	jmp    8012e2 <fd_alloc+0x4d>
  8012cb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012d0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012d5:	75 c9                	jne    8012a0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012dd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ea:	83 f8 1f             	cmp    $0x1f,%eax
  8012ed:	77 36                	ja     801325 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ef:	c1 e0 0c             	shl    $0xc,%eax
  8012f2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	c1 ea 16             	shr    $0x16,%edx
  8012fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801303:	f6 c2 01             	test   $0x1,%dl
  801306:	74 24                	je     80132c <fd_lookup+0x48>
  801308:	89 c2                	mov    %eax,%edx
  80130a:	c1 ea 0c             	shr    $0xc,%edx
  80130d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801314:	f6 c2 01             	test   $0x1,%dl
  801317:	74 1a                	je     801333 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801319:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131c:	89 02                	mov    %eax,(%edx)
	return 0;
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
  801323:	eb 13                	jmp    801338 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801325:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132a:	eb 0c                	jmp    801338 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80132c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801331:	eb 05                	jmp    801338 <fd_lookup+0x54>
  801333:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 08             	sub    $0x8,%esp
  801340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801343:	ba 9c 2c 80 00       	mov    $0x802c9c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801348:	eb 13                	jmp    80135d <dev_lookup+0x23>
  80134a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80134d:	39 08                	cmp    %ecx,(%eax)
  80134f:	75 0c                	jne    80135d <dev_lookup+0x23>
			*dev = devtab[i];
  801351:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801354:	89 01                	mov    %eax,(%ecx)
			return 0;
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	eb 2e                	jmp    80138b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80135d:	8b 02                	mov    (%edx),%eax
  80135f:	85 c0                	test   %eax,%eax
  801361:	75 e7                	jne    80134a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801363:	a1 08 40 80 00       	mov    0x804008,%eax
  801368:	8b 40 48             	mov    0x48(%eax),%eax
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	51                   	push   %ecx
  80136f:	50                   	push   %eax
  801370:	68 20 2c 80 00       	push   $0x802c20
  801375:	e8 12 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  80137a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	56                   	push   %esi
  801391:	53                   	push   %ebx
  801392:	83 ec 10             	sub    $0x10,%esp
  801395:	8b 75 08             	mov    0x8(%ebp),%esi
  801398:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139e:	50                   	push   %eax
  80139f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a5:	c1 e8 0c             	shr    $0xc,%eax
  8013a8:	50                   	push   %eax
  8013a9:	e8 36 ff ff ff       	call   8012e4 <fd_lookup>
  8013ae:	83 c4 08             	add    $0x8,%esp
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 05                	js     8013ba <fd_close+0x2d>
	    || fd != fd2)
  8013b5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013b8:	74 0c                	je     8013c6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013ba:	84 db                	test   %bl,%bl
  8013bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c1:	0f 44 c2             	cmove  %edx,%eax
  8013c4:	eb 41                	jmp    801407 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cc:	50                   	push   %eax
  8013cd:	ff 36                	pushl  (%esi)
  8013cf:	e8 66 ff ff ff       	call   80133a <dev_lookup>
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 1a                	js     8013f7 <fd_close+0x6a>
		if (dev->dev_close)
  8013dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	74 0b                	je     8013f7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ec:	83 ec 0c             	sub    $0xc,%esp
  8013ef:	56                   	push   %esi
  8013f0:	ff d0                	call   *%eax
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	56                   	push   %esi
  8013fb:	6a 00                	push   $0x0
  8013fd:	e8 b7 f8 ff ff       	call   800cb9 <sys_page_unmap>
	return r;
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	89 d8                	mov    %ebx,%eax
}
  801407:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    

0080140e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801414:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	ff 75 08             	pushl  0x8(%ebp)
  80141b:	e8 c4 fe ff ff       	call   8012e4 <fd_lookup>
  801420:	83 c4 08             	add    $0x8,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 10                	js     801437 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	6a 01                	push   $0x1
  80142c:	ff 75 f4             	pushl  -0xc(%ebp)
  80142f:	e8 59 ff ff ff       	call   80138d <fd_close>
  801434:	83 c4 10             	add    $0x10,%esp
}
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <close_all>:

void
close_all(void)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	53                   	push   %ebx
  80143d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801440:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	53                   	push   %ebx
  801449:	e8 c0 ff ff ff       	call   80140e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144e:	83 c3 01             	add    $0x1,%ebx
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	83 fb 20             	cmp    $0x20,%ebx
  801457:	75 ec                	jne    801445 <close_all+0xc>
		close(i);
}
  801459:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	53                   	push   %ebx
  801464:	83 ec 2c             	sub    $0x2c,%esp
  801467:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80146a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	ff 75 08             	pushl  0x8(%ebp)
  801471:	e8 6e fe ff ff       	call   8012e4 <fd_lookup>
  801476:	83 c4 08             	add    $0x8,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	0f 88 c1 00 00 00    	js     801542 <dup+0xe4>
		return r;
	close(newfdnum);
  801481:	83 ec 0c             	sub    $0xc,%esp
  801484:	56                   	push   %esi
  801485:	e8 84 ff ff ff       	call   80140e <close>

	newfd = INDEX2FD(newfdnum);
  80148a:	89 f3                	mov    %esi,%ebx
  80148c:	c1 e3 0c             	shl    $0xc,%ebx
  80148f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801495:	83 c4 04             	add    $0x4,%esp
  801498:	ff 75 e4             	pushl  -0x1c(%ebp)
  80149b:	e8 de fd ff ff       	call   80127e <fd2data>
  8014a0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014a2:	89 1c 24             	mov    %ebx,(%esp)
  8014a5:	e8 d4 fd ff ff       	call   80127e <fd2data>
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b0:	89 f8                	mov    %edi,%eax
  8014b2:	c1 e8 16             	shr    $0x16,%eax
  8014b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014bc:	a8 01                	test   $0x1,%al
  8014be:	74 37                	je     8014f7 <dup+0x99>
  8014c0:	89 f8                	mov    %edi,%eax
  8014c2:	c1 e8 0c             	shr    $0xc,%eax
  8014c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014cc:	f6 c2 01             	test   $0x1,%dl
  8014cf:	74 26                	je     8014f7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e0:	50                   	push   %eax
  8014e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014e4:	6a 00                	push   $0x0
  8014e6:	57                   	push   %edi
  8014e7:	6a 00                	push   $0x0
  8014e9:	e8 89 f7 ff ff       	call   800c77 <sys_page_map>
  8014ee:	89 c7                	mov    %eax,%edi
  8014f0:	83 c4 20             	add    $0x20,%esp
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 2e                	js     801525 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014fa:	89 d0                	mov    %edx,%eax
  8014fc:	c1 e8 0c             	shr    $0xc,%eax
  8014ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801506:	83 ec 0c             	sub    $0xc,%esp
  801509:	25 07 0e 00 00       	and    $0xe07,%eax
  80150e:	50                   	push   %eax
  80150f:	53                   	push   %ebx
  801510:	6a 00                	push   $0x0
  801512:	52                   	push   %edx
  801513:	6a 00                	push   $0x0
  801515:	e8 5d f7 ff ff       	call   800c77 <sys_page_map>
  80151a:	89 c7                	mov    %eax,%edi
  80151c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80151f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801521:	85 ff                	test   %edi,%edi
  801523:	79 1d                	jns    801542 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801525:	83 ec 08             	sub    $0x8,%esp
  801528:	53                   	push   %ebx
  801529:	6a 00                	push   $0x0
  80152b:	e8 89 f7 ff ff       	call   800cb9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801530:	83 c4 08             	add    $0x8,%esp
  801533:	ff 75 d4             	pushl  -0x2c(%ebp)
  801536:	6a 00                	push   $0x0
  801538:	e8 7c f7 ff ff       	call   800cb9 <sys_page_unmap>
	return r;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	89 f8                	mov    %edi,%eax
}
  801542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 14             	sub    $0x14,%esp
  801551:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801554:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801557:	50                   	push   %eax
  801558:	53                   	push   %ebx
  801559:	e8 86 fd ff ff       	call   8012e4 <fd_lookup>
  80155e:	83 c4 08             	add    $0x8,%esp
  801561:	89 c2                	mov    %eax,%edx
  801563:	85 c0                	test   %eax,%eax
  801565:	78 6d                	js     8015d4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801571:	ff 30                	pushl  (%eax)
  801573:	e8 c2 fd ff ff       	call   80133a <dev_lookup>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 4c                	js     8015cb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80157f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801582:	8b 42 08             	mov    0x8(%edx),%eax
  801585:	83 e0 03             	and    $0x3,%eax
  801588:	83 f8 01             	cmp    $0x1,%eax
  80158b:	75 21                	jne    8015ae <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158d:	a1 08 40 80 00       	mov    0x804008,%eax
  801592:	8b 40 48             	mov    0x48(%eax),%eax
  801595:	83 ec 04             	sub    $0x4,%esp
  801598:	53                   	push   %ebx
  801599:	50                   	push   %eax
  80159a:	68 61 2c 80 00       	push   $0x802c61
  80159f:	e8 e8 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015a4:	83 c4 10             	add    $0x10,%esp
  8015a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ac:	eb 26                	jmp    8015d4 <read+0x8a>
	}
	if (!dev->dev_read)
  8015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b1:	8b 40 08             	mov    0x8(%eax),%eax
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	74 17                	je     8015cf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b8:	83 ec 04             	sub    $0x4,%esp
  8015bb:	ff 75 10             	pushl  0x10(%ebp)
  8015be:	ff 75 0c             	pushl  0xc(%ebp)
  8015c1:	52                   	push   %edx
  8015c2:	ff d0                	call   *%eax
  8015c4:	89 c2                	mov    %eax,%edx
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	eb 09                	jmp    8015d4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	eb 05                	jmp    8015d4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015d4:	89 d0                	mov    %edx,%eax
  8015d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	57                   	push   %edi
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ef:	eb 21                	jmp    801612 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f1:	83 ec 04             	sub    $0x4,%esp
  8015f4:	89 f0                	mov    %esi,%eax
  8015f6:	29 d8                	sub    %ebx,%eax
  8015f8:	50                   	push   %eax
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	03 45 0c             	add    0xc(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	57                   	push   %edi
  801600:	e8 45 ff ff ff       	call   80154a <read>
		if (m < 0)
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 10                	js     80161c <readn+0x41>
			return m;
		if (m == 0)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	74 0a                	je     80161a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801610:	01 c3                	add    %eax,%ebx
  801612:	39 f3                	cmp    %esi,%ebx
  801614:	72 db                	jb     8015f1 <readn+0x16>
  801616:	89 d8                	mov    %ebx,%eax
  801618:	eb 02                	jmp    80161c <readn+0x41>
  80161a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80161c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5f                   	pop    %edi
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    

00801624 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	53                   	push   %ebx
  801628:	83 ec 14             	sub    $0x14,%esp
  80162b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801631:	50                   	push   %eax
  801632:	53                   	push   %ebx
  801633:	e8 ac fc ff ff       	call   8012e4 <fd_lookup>
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	89 c2                	mov    %eax,%edx
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 68                	js     8016a9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164b:	ff 30                	pushl  (%eax)
  80164d:	e8 e8 fc ff ff       	call   80133a <dev_lookup>
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	78 47                	js     8016a0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801659:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801660:	75 21                	jne    801683 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801662:	a1 08 40 80 00       	mov    0x804008,%eax
  801667:	8b 40 48             	mov    0x48(%eax),%eax
  80166a:	83 ec 04             	sub    $0x4,%esp
  80166d:	53                   	push   %ebx
  80166e:	50                   	push   %eax
  80166f:	68 7d 2c 80 00       	push   $0x802c7d
  801674:	e8 13 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801681:	eb 26                	jmp    8016a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801683:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801686:	8b 52 0c             	mov    0xc(%edx),%edx
  801689:	85 d2                	test   %edx,%edx
  80168b:	74 17                	je     8016a4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80168d:	83 ec 04             	sub    $0x4,%esp
  801690:	ff 75 10             	pushl  0x10(%ebp)
  801693:	ff 75 0c             	pushl  0xc(%ebp)
  801696:	50                   	push   %eax
  801697:	ff d2                	call   *%edx
  801699:	89 c2                	mov    %eax,%edx
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	eb 09                	jmp    8016a9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	eb 05                	jmp    8016a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016a9:	89 d0                	mov    %edx,%eax
  8016ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	ff 75 08             	pushl  0x8(%ebp)
  8016bd:	e8 22 fc ff ff       	call   8012e4 <fd_lookup>
  8016c2:	83 c4 08             	add    $0x8,%esp
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 0e                	js     8016d7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016cf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 14             	sub    $0x14,%esp
  8016e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e6:	50                   	push   %eax
  8016e7:	53                   	push   %ebx
  8016e8:	e8 f7 fb ff ff       	call   8012e4 <fd_lookup>
  8016ed:	83 c4 08             	add    $0x8,%esp
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 65                	js     80175b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f6:	83 ec 08             	sub    $0x8,%esp
  8016f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fc:	50                   	push   %eax
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	ff 30                	pushl  (%eax)
  801702:	e8 33 fc ff ff       	call   80133a <dev_lookup>
  801707:	83 c4 10             	add    $0x10,%esp
  80170a:	85 c0                	test   %eax,%eax
  80170c:	78 44                	js     801752 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80170e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801711:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801715:	75 21                	jne    801738 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801717:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80171c:	8b 40 48             	mov    0x48(%eax),%eax
  80171f:	83 ec 04             	sub    $0x4,%esp
  801722:	53                   	push   %ebx
  801723:	50                   	push   %eax
  801724:	68 40 2c 80 00       	push   $0x802c40
  801729:	e8 5e eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80172e:	83 c4 10             	add    $0x10,%esp
  801731:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801736:	eb 23                	jmp    80175b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801738:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80173b:	8b 52 18             	mov    0x18(%edx),%edx
  80173e:	85 d2                	test   %edx,%edx
  801740:	74 14                	je     801756 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	50                   	push   %eax
  801749:	ff d2                	call   *%edx
  80174b:	89 c2                	mov    %eax,%edx
  80174d:	83 c4 10             	add    $0x10,%esp
  801750:	eb 09                	jmp    80175b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801752:	89 c2                	mov    %eax,%edx
  801754:	eb 05                	jmp    80175b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801756:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80175b:	89 d0                	mov    %edx,%eax
  80175d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	83 ec 14             	sub    $0x14,%esp
  801769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176f:	50                   	push   %eax
  801770:	ff 75 08             	pushl  0x8(%ebp)
  801773:	e8 6c fb ff ff       	call   8012e4 <fd_lookup>
  801778:	83 c4 08             	add    $0x8,%esp
  80177b:	89 c2                	mov    %eax,%edx
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 58                	js     8017d9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801781:	83 ec 08             	sub    $0x8,%esp
  801784:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801787:	50                   	push   %eax
  801788:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178b:	ff 30                	pushl  (%eax)
  80178d:	e8 a8 fb ff ff       	call   80133a <dev_lookup>
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	85 c0                	test   %eax,%eax
  801797:	78 37                	js     8017d0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017a0:	74 32                	je     8017d4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ac:	00 00 00 
	stat->st_isdir = 0;
  8017af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b6:	00 00 00 
	stat->st_dev = dev;
  8017b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017bf:	83 ec 08             	sub    $0x8,%esp
  8017c2:	53                   	push   %ebx
  8017c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c6:	ff 50 14             	call   *0x14(%eax)
  8017c9:	89 c2                	mov    %eax,%edx
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	eb 09                	jmp    8017d9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d0:	89 c2                	mov    %eax,%edx
  8017d2:	eb 05                	jmp    8017d9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017d9:	89 d0                	mov    %edx,%eax
  8017db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	6a 00                	push   $0x0
  8017ea:	ff 75 08             	pushl  0x8(%ebp)
  8017ed:	e8 ef 01 00 00       	call   8019e1 <open>
  8017f2:	89 c3                	mov    %eax,%ebx
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	78 1b                	js     801816 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	ff 75 0c             	pushl  0xc(%ebp)
  801801:	50                   	push   %eax
  801802:	e8 5b ff ff ff       	call   801762 <fstat>
  801807:	89 c6                	mov    %eax,%esi
	close(fd);
  801809:	89 1c 24             	mov    %ebx,(%esp)
  80180c:	e8 fd fb ff ff       	call   80140e <close>
	return r;
  801811:	83 c4 10             	add    $0x10,%esp
  801814:	89 f0                	mov    %esi,%eax
}
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	56                   	push   %esi
  801821:	53                   	push   %ebx
  801822:	89 c6                	mov    %eax,%esi
  801824:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801826:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182d:	75 12                	jne    801841 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	6a 01                	push   $0x1
  801834:	e8 fc f9 ff ff       	call   801235 <ipc_find_env>
  801839:	a3 00 40 80 00       	mov    %eax,0x804000
  80183e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801841:	6a 07                	push   $0x7
  801843:	68 00 50 80 00       	push   $0x805000
  801848:	56                   	push   %esi
  801849:	ff 35 00 40 80 00    	pushl  0x804000
  80184f:	e8 92 f9 ff ff       	call   8011e6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801854:	83 c4 0c             	add    $0xc,%esp
  801857:	6a 00                	push   $0x0
  801859:	53                   	push   %ebx
  80185a:	6a 00                	push   $0x0
  80185c:	e8 0f f9 ff ff       	call   801170 <ipc_recv>
}
  801861:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	8b 40 0c             	mov    0xc(%eax),%eax
  801874:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 02 00 00 00       	mov    $0x2,%eax
  80188b:	e8 8d ff ff ff       	call   80181d <fsipc>
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 40 0c             	mov    0xc(%eax),%eax
  80189e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ad:	e8 6b ff ff ff       	call   80181d <fsipc>
}
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <devfile_stat>:
	return n;
	//panic("devfile_write not implemented");
}
static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8018d3:	e8 45 ff ff ff       	call   80181d <fsipc>
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	78 2c                	js     801908 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	68 00 50 80 00       	push   $0x805000
  8018e4:	53                   	push   %ebx
  8018e5:	e8 47 ef ff ff       	call   800831 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8018fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801908:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	53                   	push   %ebx
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	size_t a;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801917:	8b 55 08             	mov    0x8(%ebp),%edx
  80191a:	8b 52 0c             	mov    0xc(%edx),%edx
  80191d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801923:	a3 04 50 80 00       	mov    %eax,0x805004
  801928:	3d 08 50 80 00       	cmp    $0x805008,%eax
  80192d:	bb 08 50 80 00       	mov    $0x805008,%ebx
  801932:	0f 46 d8             	cmovbe %eax,%ebx
	
	a = (size_t) fsipcbuf.write.req_buf;
	if(n > a)
		n = a; 
	memmove(fsipcbuf.write.req_buf, buf, n);
  801935:	53                   	push   %ebx
  801936:	ff 75 0c             	pushl  0xc(%ebp)
  801939:	68 08 50 80 00       	push   $0x805008
  80193e:	e8 80 f0 ff ff       	call   8009c3 <memmove>
	
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801943:	ba 00 00 00 00       	mov    $0x0,%edx
  801948:	b8 04 00 00 00       	mov    $0x4,%eax
  80194d:	e8 cb fe ff ff       	call   80181d <fsipc>
  801952:	83 c4 10             	add    $0x10,%esp
		return r;
	
	return n;
  801955:	85 c0                	test   %eax,%eax
  801957:	0f 49 c3             	cmovns %ebx,%eax
	//panic("devfile_write not implemented");
}
  80195a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801967:	8b 45 08             	mov    0x8(%ebp),%eax
  80196a:	8b 40 0c             	mov    0xc(%eax),%eax
  80196d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801972:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801978:	ba 00 00 00 00       	mov    $0x0,%edx
  80197d:	b8 03 00 00 00       	mov    $0x3,%eax
  801982:	e8 96 fe ff ff       	call   80181d <fsipc>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	85 c0                	test   %eax,%eax
  80198b:	78 4b                	js     8019d8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80198d:	39 c6                	cmp    %eax,%esi
  80198f:	73 16                	jae    8019a7 <devfile_read+0x48>
  801991:	68 b0 2c 80 00       	push   $0x802cb0
  801996:	68 b7 2c 80 00       	push   $0x802cb7
  80199b:	6a 7c                	push   $0x7c
  80199d:	68 cc 2c 80 00       	push   $0x802ccc
  8019a2:	e8 24 0a 00 00       	call   8023cb <_panic>
	assert(r <= PGSIZE);
  8019a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ac:	7e 16                	jle    8019c4 <devfile_read+0x65>
  8019ae:	68 d7 2c 80 00       	push   $0x802cd7
  8019b3:	68 b7 2c 80 00       	push   $0x802cb7
  8019b8:	6a 7d                	push   $0x7d
  8019ba:	68 cc 2c 80 00       	push   $0x802ccc
  8019bf:	e8 07 0a 00 00       	call   8023cb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019c4:	83 ec 04             	sub    $0x4,%esp
  8019c7:	50                   	push   %eax
  8019c8:	68 00 50 80 00       	push   $0x805000
  8019cd:	ff 75 0c             	pushl  0xc(%ebp)
  8019d0:	e8 ee ef ff ff       	call   8009c3 <memmove>
	return r;
  8019d5:	83 c4 10             	add    $0x10,%esp
}
  8019d8:	89 d8                	mov    %ebx,%eax
  8019da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5e                   	pop    %esi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 20             	sub    $0x20,%esp
  8019e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019eb:	53                   	push   %ebx
  8019ec:	e8 07 ee ff ff       	call   8007f8 <strlen>
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019f9:	7f 67                	jg     801a62 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a01:	50                   	push   %eax
  801a02:	e8 8e f8 ff ff       	call   801295 <fd_alloc>
  801a07:	83 c4 10             	add    $0x10,%esp
		return r;
  801a0a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 57                	js     801a67 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	53                   	push   %ebx
  801a14:	68 00 50 80 00       	push   $0x805000
  801a19:	e8 13 ee ff ff       	call   800831 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a21:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a29:	b8 01 00 00 00       	mov    $0x1,%eax
  801a2e:	e8 ea fd ff ff       	call   80181d <fsipc>
  801a33:	89 c3                	mov    %eax,%ebx
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	85 c0                	test   %eax,%eax
  801a3a:	79 14                	jns    801a50 <open+0x6f>
		fd_close(fd, 0);
  801a3c:	83 ec 08             	sub    $0x8,%esp
  801a3f:	6a 00                	push   $0x0
  801a41:	ff 75 f4             	pushl  -0xc(%ebp)
  801a44:	e8 44 f9 ff ff       	call   80138d <fd_close>
		return r;
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	89 da                	mov    %ebx,%edx
  801a4e:	eb 17                	jmp    801a67 <open+0x86>
	}

	return fd2num(fd);
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	ff 75 f4             	pushl  -0xc(%ebp)
  801a56:	e8 13 f8 ff ff       	call   80126e <fd2num>
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	83 c4 10             	add    $0x10,%esp
  801a60:	eb 05                	jmp    801a67 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a62:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a67:	89 d0                	mov    %edx,%eax
  801a69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a74:	ba 00 00 00 00       	mov    $0x0,%edx
  801a79:	b8 08 00 00 00       	mov    $0x8,%eax
  801a7e:	e8 9a fd ff ff       	call   80181d <fsipc>
}
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	56                   	push   %esi
  801a89:	53                   	push   %ebx
  801a8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	ff 75 08             	pushl  0x8(%ebp)
  801a93:	e8 e6 f7 ff ff       	call   80127e <fd2data>
  801a98:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a9a:	83 c4 08             	add    $0x8,%esp
  801a9d:	68 e3 2c 80 00       	push   $0x802ce3
  801aa2:	53                   	push   %ebx
  801aa3:	e8 89 ed ff ff       	call   800831 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa8:	8b 46 04             	mov    0x4(%esi),%eax
  801aab:	2b 06                	sub    (%esi),%eax
  801aad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ab3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801aba:	00 00 00 
	stat->st_dev = &devpipe;
  801abd:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ac4:	30 80 00 
	return 0;
}
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  801acc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acf:	5b                   	pop    %ebx
  801ad0:	5e                   	pop    %esi
  801ad1:	5d                   	pop    %ebp
  801ad2:	c3                   	ret    

00801ad3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801add:	53                   	push   %ebx
  801ade:	6a 00                	push   $0x0
  801ae0:	e8 d4 f1 ff ff       	call   800cb9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae5:	89 1c 24             	mov    %ebx,(%esp)
  801ae8:	e8 91 f7 ff ff       	call   80127e <fd2data>
  801aed:	83 c4 08             	add    $0x8,%esp
  801af0:	50                   	push   %eax
  801af1:	6a 00                	push   $0x0
  801af3:	e8 c1 f1 ff ff       	call   800cb9 <sys_page_unmap>
}
  801af8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801afb:	c9                   	leave  
  801afc:	c3                   	ret    

00801afd <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	57                   	push   %edi
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	83 ec 1c             	sub    $0x1c,%esp
  801b06:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b09:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b0b:	a1 08 40 80 00       	mov    0x804008,%eax
  801b10:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	ff 75 e0             	pushl  -0x20(%ebp)
  801b19:	e8 89 09 00 00       	call   8024a7 <pageref>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	89 3c 24             	mov    %edi,(%esp)
  801b23:	e8 7f 09 00 00       	call   8024a7 <pageref>
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	39 c3                	cmp    %eax,%ebx
  801b2d:	0f 94 c1             	sete   %cl
  801b30:	0f b6 c9             	movzbl %cl,%ecx
  801b33:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b36:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b3c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b3f:	39 ce                	cmp    %ecx,%esi
  801b41:	74 1b                	je     801b5e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b43:	39 c3                	cmp    %eax,%ebx
  801b45:	75 c4                	jne    801b0b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b47:	8b 42 58             	mov    0x58(%edx),%eax
  801b4a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b4d:	50                   	push   %eax
  801b4e:	56                   	push   %esi
  801b4f:	68 ea 2c 80 00       	push   $0x802cea
  801b54:	e8 33 e7 ff ff       	call   80028c <cprintf>
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	eb ad                	jmp    801b0b <_pipeisclosed+0xe>
	}
}
  801b5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5f                   	pop    %edi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	57                   	push   %edi
  801b6d:	56                   	push   %esi
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 28             	sub    $0x28,%esp
  801b72:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b75:	56                   	push   %esi
  801b76:	e8 03 f7 ff ff       	call   80127e <fd2data>
  801b7b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	bf 00 00 00 00       	mov    $0x0,%edi
  801b85:	eb 4b                	jmp    801bd2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b87:	89 da                	mov    %ebx,%edx
  801b89:	89 f0                	mov    %esi,%eax
  801b8b:	e8 6d ff ff ff       	call   801afd <_pipeisclosed>
  801b90:	85 c0                	test   %eax,%eax
  801b92:	75 48                	jne    801bdc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b94:	e8 7c f0 ff ff       	call   800c15 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b99:	8b 43 04             	mov    0x4(%ebx),%eax
  801b9c:	8b 0b                	mov    (%ebx),%ecx
  801b9e:	8d 51 20             	lea    0x20(%ecx),%edx
  801ba1:	39 d0                	cmp    %edx,%eax
  801ba3:	73 e2                	jae    801b87 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bac:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801baf:	89 c2                	mov    %eax,%edx
  801bb1:	c1 fa 1f             	sar    $0x1f,%edx
  801bb4:	89 d1                	mov    %edx,%ecx
  801bb6:	c1 e9 1b             	shr    $0x1b,%ecx
  801bb9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bbc:	83 e2 1f             	and    $0x1f,%edx
  801bbf:	29 ca                	sub    %ecx,%edx
  801bc1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bc5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bc9:	83 c0 01             	add    $0x1,%eax
  801bcc:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcf:	83 c7 01             	add    $0x1,%edi
  801bd2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bd5:	75 c2                	jne    801b99 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bd7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bda:	eb 05                	jmp    801be1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	57                   	push   %edi
  801bed:	56                   	push   %esi
  801bee:	53                   	push   %ebx
  801bef:	83 ec 18             	sub    $0x18,%esp
  801bf2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bf5:	57                   	push   %edi
  801bf6:	e8 83 f6 ff ff       	call   80127e <fd2data>
  801bfb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfd:	83 c4 10             	add    $0x10,%esp
  801c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c05:	eb 3d                	jmp    801c44 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c07:	85 db                	test   %ebx,%ebx
  801c09:	74 04                	je     801c0f <devpipe_read+0x26>
				return i;
  801c0b:	89 d8                	mov    %ebx,%eax
  801c0d:	eb 44                	jmp    801c53 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c0f:	89 f2                	mov    %esi,%edx
  801c11:	89 f8                	mov    %edi,%eax
  801c13:	e8 e5 fe ff ff       	call   801afd <_pipeisclosed>
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	75 32                	jne    801c4e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c1c:	e8 f4 ef ff ff       	call   800c15 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c21:	8b 06                	mov    (%esi),%eax
  801c23:	3b 46 04             	cmp    0x4(%esi),%eax
  801c26:	74 df                	je     801c07 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c28:	99                   	cltd   
  801c29:	c1 ea 1b             	shr    $0x1b,%edx
  801c2c:	01 d0                	add    %edx,%eax
  801c2e:	83 e0 1f             	and    $0x1f,%eax
  801c31:	29 d0                	sub    %edx,%eax
  801c33:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c3e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c41:	83 c3 01             	add    $0x1,%ebx
  801c44:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c47:	75 d8                	jne    801c21 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c49:	8b 45 10             	mov    0x10(%ebp),%eax
  801c4c:	eb 05                	jmp    801c53 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	56                   	push   %esi
  801c5f:	53                   	push   %ebx
  801c60:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	e8 29 f6 ff ff       	call   801295 <fd_alloc>
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	89 c2                	mov    %eax,%edx
  801c71:	85 c0                	test   %eax,%eax
  801c73:	0f 88 2c 01 00 00    	js     801da5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	68 07 04 00 00       	push   $0x407
  801c81:	ff 75 f4             	pushl  -0xc(%ebp)
  801c84:	6a 00                	push   $0x0
  801c86:	e8 a9 ef ff ff       	call   800c34 <sys_page_alloc>
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	89 c2                	mov    %eax,%edx
  801c90:	85 c0                	test   %eax,%eax
  801c92:	0f 88 0d 01 00 00    	js     801da5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c98:	83 ec 0c             	sub    $0xc,%esp
  801c9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9e:	50                   	push   %eax
  801c9f:	e8 f1 f5 ff ff       	call   801295 <fd_alloc>
  801ca4:	89 c3                	mov    %eax,%ebx
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	0f 88 e2 00 00 00    	js     801d93 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb1:	83 ec 04             	sub    $0x4,%esp
  801cb4:	68 07 04 00 00       	push   $0x407
  801cb9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 71 ef ff ff       	call   800c34 <sys_page_alloc>
  801cc3:	89 c3                	mov    %eax,%ebx
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	85 c0                	test   %eax,%eax
  801cca:	0f 88 c3 00 00 00    	js     801d93 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd6:	e8 a3 f5 ff ff       	call   80127e <fd2data>
  801cdb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdd:	83 c4 0c             	add    $0xc,%esp
  801ce0:	68 07 04 00 00       	push   $0x407
  801ce5:	50                   	push   %eax
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 47 ef ff ff       	call   800c34 <sys_page_alloc>
  801ced:	89 c3                	mov    %eax,%ebx
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	0f 88 89 00 00 00    	js     801d83 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfa:	83 ec 0c             	sub    $0xc,%esp
  801cfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801d00:	e8 79 f5 ff ff       	call   80127e <fd2data>
  801d05:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d0c:	50                   	push   %eax
  801d0d:	6a 00                	push   $0x0
  801d0f:	56                   	push   %esi
  801d10:	6a 00                	push   $0x0
  801d12:	e8 60 ef ff ff       	call   800c77 <sys_page_map>
  801d17:	89 c3                	mov    %eax,%ebx
  801d19:	83 c4 20             	add    $0x20,%esp
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	78 55                	js     801d75 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d20:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d29:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d35:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d3e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d43:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d4a:	83 ec 0c             	sub    $0xc,%esp
  801d4d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d50:	e8 19 f5 ff ff       	call   80126e <fd2num>
  801d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d58:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d5a:	83 c4 04             	add    $0x4,%esp
  801d5d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d60:	e8 09 f5 ff ff       	call   80126e <fd2num>
  801d65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d68:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d6b:	83 c4 10             	add    $0x10,%esp
  801d6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d73:	eb 30                	jmp    801da5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d75:	83 ec 08             	sub    $0x8,%esp
  801d78:	56                   	push   %esi
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 39 ef ff ff       	call   800cb9 <sys_page_unmap>
  801d80:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d83:	83 ec 08             	sub    $0x8,%esp
  801d86:	ff 75 f0             	pushl  -0x10(%ebp)
  801d89:	6a 00                	push   $0x0
  801d8b:	e8 29 ef ff ff       	call   800cb9 <sys_page_unmap>
  801d90:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	ff 75 f4             	pushl  -0xc(%ebp)
  801d99:	6a 00                	push   $0x0
  801d9b:	e8 19 ef ff ff       	call   800cb9 <sys_page_unmap>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801db4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db7:	50                   	push   %eax
  801db8:	ff 75 08             	pushl  0x8(%ebp)
  801dbb:	e8 24 f5 ff ff       	call   8012e4 <fd_lookup>
  801dc0:	83 c4 10             	add    $0x10,%esp
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	78 18                	js     801ddf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcd:	e8 ac f4 ff ff       	call   80127e <fd2data>
	return _pipeisclosed(fd, p);
  801dd2:	89 c2                	mov    %eax,%edx
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	e8 21 fd ff ff       	call   801afd <_pipeisclosed>
  801ddc:	83 c4 10             	add    $0x10,%esp
}
  801ddf:	c9                   	leave  
  801de0:	c3                   	ret    

00801de1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801de7:	68 02 2d 80 00       	push   $0x802d02
  801dec:	ff 75 0c             	pushl  0xc(%ebp)
  801def:	e8 3d ea ff ff       	call   800831 <strcpy>
	return 0;
}
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	53                   	push   %ebx
  801dff:	83 ec 10             	sub    $0x10,%esp
  801e02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e05:	53                   	push   %ebx
  801e06:	e8 9c 06 00 00       	call   8024a7 <pageref>
  801e0b:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801e0e:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801e13:	83 f8 01             	cmp    $0x1,%eax
  801e16:	75 10                	jne    801e28 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801e18:	83 ec 0c             	sub    $0xc,%esp
  801e1b:	ff 73 0c             	pushl  0xc(%ebx)
  801e1e:	e8 c0 02 00 00       	call   8020e3 <nsipc_close>
  801e23:	89 c2                	mov    %eax,%edx
  801e25:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801e28:	89 d0                	mov    %edx,%eax
  801e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e35:	6a 00                	push   $0x0
  801e37:	ff 75 10             	pushl  0x10(%ebp)
  801e3a:	ff 75 0c             	pushl  0xc(%ebp)
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	ff 70 0c             	pushl  0xc(%eax)
  801e43:	e8 78 03 00 00       	call   8021c0 <nsipc_send>
}
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e50:	6a 00                	push   $0x0
  801e52:	ff 75 10             	pushl  0x10(%ebp)
  801e55:	ff 75 0c             	pushl  0xc(%ebp)
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5b:	ff 70 0c             	pushl  0xc(%eax)
  801e5e:	e8 f1 02 00 00       	call   802154 <nsipc_recv>
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801e6b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801e6e:	52                   	push   %edx
  801e6f:	50                   	push   %eax
  801e70:	e8 6f f4 ff ff       	call   8012e4 <fd_lookup>
  801e75:	83 c4 10             	add    $0x10,%esp
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	78 17                	js     801e93 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7f:	8b 0d 44 30 80 00    	mov    0x803044,%ecx
  801e85:	39 08                	cmp    %ecx,(%eax)
  801e87:	75 05                	jne    801e8e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e89:	8b 40 0c             	mov    0xc(%eax),%eax
  801e8c:	eb 05                	jmp    801e93 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801e8e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    

00801e95 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	56                   	push   %esi
  801e99:	53                   	push   %ebx
  801e9a:	83 ec 1c             	sub    $0x1c,%esp
  801e9d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801e9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea2:	50                   	push   %eax
  801ea3:	e8 ed f3 ff ff       	call   801295 <fd_alloc>
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	78 1b                	js     801ecc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801eb1:	83 ec 04             	sub    $0x4,%esp
  801eb4:	68 07 04 00 00       	push   $0x407
  801eb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebc:	6a 00                	push   $0x0
  801ebe:	e8 71 ed ff ff       	call   800c34 <sys_page_alloc>
  801ec3:	89 c3                	mov    %eax,%ebx
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	79 10                	jns    801edc <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ecc:	83 ec 0c             	sub    $0xc,%esp
  801ecf:	56                   	push   %esi
  801ed0:	e8 0e 02 00 00       	call   8020e3 <nsipc_close>
		return r;
  801ed5:	83 c4 10             	add    $0x10,%esp
  801ed8:	89 d8                	mov    %ebx,%eax
  801eda:	eb 24                	jmp    801f00 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801edc:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ef1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ef4:	83 ec 0c             	sub    $0xc,%esp
  801ef7:	50                   	push   %eax
  801ef8:	e8 71 f3 ff ff       	call   80126e <fd2num>
  801efd:	83 c4 10             	add    $0x10,%esp
}
  801f00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    

00801f07 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	e8 50 ff ff ff       	call   801e65 <fd2sockid>
		return r;
  801f15:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 1f                	js     801f3a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f1b:	83 ec 04             	sub    $0x4,%esp
  801f1e:	ff 75 10             	pushl  0x10(%ebp)
  801f21:	ff 75 0c             	pushl  0xc(%ebp)
  801f24:	50                   	push   %eax
  801f25:	e8 12 01 00 00       	call   80203c <nsipc_accept>
  801f2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f2d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 07                	js     801f3a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801f33:	e8 5d ff ff ff       	call   801e95 <alloc_sockfd>
  801f38:	89 c1                	mov    %eax,%ecx
}
  801f3a:	89 c8                	mov    %ecx,%eax
  801f3c:	c9                   	leave  
  801f3d:	c3                   	ret    

00801f3e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	e8 19 ff ff ff       	call   801e65 <fd2sockid>
  801f4c:	85 c0                	test   %eax,%eax
  801f4e:	78 12                	js     801f62 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801f50:	83 ec 04             	sub    $0x4,%esp
  801f53:	ff 75 10             	pushl  0x10(%ebp)
  801f56:	ff 75 0c             	pushl  0xc(%ebp)
  801f59:	50                   	push   %eax
  801f5a:	e8 2d 01 00 00       	call   80208c <nsipc_bind>
  801f5f:	83 c4 10             	add    $0x10,%esp
}
  801f62:	c9                   	leave  
  801f63:	c3                   	ret    

00801f64 <shutdown>:

int
shutdown(int s, int how)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6d:	e8 f3 fe ff ff       	call   801e65 <fd2sockid>
  801f72:	85 c0                	test   %eax,%eax
  801f74:	78 0f                	js     801f85 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801f76:	83 ec 08             	sub    $0x8,%esp
  801f79:	ff 75 0c             	pushl  0xc(%ebp)
  801f7c:	50                   	push   %eax
  801f7d:	e8 3f 01 00 00       	call   8020c1 <nsipc_shutdown>
  801f82:	83 c4 10             	add    $0x10,%esp
}
  801f85:	c9                   	leave  
  801f86:	c3                   	ret    

00801f87 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f87:	55                   	push   %ebp
  801f88:	89 e5                	mov    %esp,%ebp
  801f8a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f90:	e8 d0 fe ff ff       	call   801e65 <fd2sockid>
  801f95:	85 c0                	test   %eax,%eax
  801f97:	78 12                	js     801fab <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801f99:	83 ec 04             	sub    $0x4,%esp
  801f9c:	ff 75 10             	pushl  0x10(%ebp)
  801f9f:	ff 75 0c             	pushl  0xc(%ebp)
  801fa2:	50                   	push   %eax
  801fa3:	e8 55 01 00 00       	call   8020fd <nsipc_connect>
  801fa8:	83 c4 10             	add    $0x10,%esp
}
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <listen>:

int
listen(int s, int backlog)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb6:	e8 aa fe ff ff       	call   801e65 <fd2sockid>
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	78 0f                	js     801fce <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fbf:	83 ec 08             	sub    $0x8,%esp
  801fc2:	ff 75 0c             	pushl  0xc(%ebp)
  801fc5:	50                   	push   %eax
  801fc6:	e8 67 01 00 00       	call   802132 <nsipc_listen>
  801fcb:	83 c4 10             	add    $0x10,%esp
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fd6:	ff 75 10             	pushl  0x10(%ebp)
  801fd9:	ff 75 0c             	pushl  0xc(%ebp)
  801fdc:	ff 75 08             	pushl  0x8(%ebp)
  801fdf:	e8 3a 02 00 00       	call   80221e <nsipc_socket>
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	78 05                	js     801ff0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801feb:	e8 a5 fe ff ff       	call   801e95 <alloc_sockfd>
}
  801ff0:	c9                   	leave  
  801ff1:	c3                   	ret    

00801ff2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	53                   	push   %ebx
  801ff6:	83 ec 04             	sub    $0x4,%esp
  801ff9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ffb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  802002:	75 12                	jne    802016 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802004:	83 ec 0c             	sub    $0xc,%esp
  802007:	6a 02                	push   $0x2
  802009:	e8 27 f2 ff ff       	call   801235 <ipc_find_env>
  80200e:	a3 04 40 80 00       	mov    %eax,0x804004
  802013:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802016:	6a 07                	push   $0x7
  802018:	68 00 60 80 00       	push   $0x806000
  80201d:	53                   	push   %ebx
  80201e:	ff 35 04 40 80 00    	pushl  0x804004
  802024:	e8 bd f1 ff ff       	call   8011e6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802029:	83 c4 0c             	add    $0xc,%esp
  80202c:	6a 00                	push   $0x0
  80202e:	6a 00                	push   $0x0
  802030:	6a 00                	push   $0x0
  802032:	e8 39 f1 ff ff       	call   801170 <ipc_recv>
}
  802037:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80203a:	c9                   	leave  
  80203b:	c3                   	ret    

0080203c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802044:	8b 45 08             	mov    0x8(%ebp),%eax
  802047:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80204c:	8b 06                	mov    (%esi),%eax
  80204e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802053:	b8 01 00 00 00       	mov    $0x1,%eax
  802058:	e8 95 ff ff ff       	call   801ff2 <nsipc>
  80205d:	89 c3                	mov    %eax,%ebx
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 20                	js     802083 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802063:	83 ec 04             	sub    $0x4,%esp
  802066:	ff 35 10 60 80 00    	pushl  0x806010
  80206c:	68 00 60 80 00       	push   $0x806000
  802071:	ff 75 0c             	pushl  0xc(%ebp)
  802074:	e8 4a e9 ff ff       	call   8009c3 <memmove>
		*addrlen = ret->ret_addrlen;
  802079:	a1 10 60 80 00       	mov    0x806010,%eax
  80207e:	89 06                	mov    %eax,(%esi)
  802080:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802083:	89 d8                	mov    %ebx,%eax
  802085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802088:	5b                   	pop    %ebx
  802089:	5e                   	pop    %esi
  80208a:	5d                   	pop    %ebp
  80208b:	c3                   	ret    

0080208c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80208c:	55                   	push   %ebp
  80208d:	89 e5                	mov    %esp,%ebp
  80208f:	53                   	push   %ebx
  802090:	83 ec 08             	sub    $0x8,%esp
  802093:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802096:	8b 45 08             	mov    0x8(%ebp),%eax
  802099:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80209e:	53                   	push   %ebx
  80209f:	ff 75 0c             	pushl  0xc(%ebp)
  8020a2:	68 04 60 80 00       	push   $0x806004
  8020a7:	e8 17 e9 ff ff       	call   8009c3 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8020ac:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8020b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8020b7:	e8 36 ff ff ff       	call   801ff2 <nsipc>
}
  8020bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020bf:	c9                   	leave  
  8020c0:	c3                   	ret    

008020c1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
  8020c4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8020cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8020d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8020dc:	e8 11 ff ff ff       	call   801ff2 <nsipc>
}
  8020e1:	c9                   	leave  
  8020e2:	c3                   	ret    

008020e3 <nsipc_close>:

int
nsipc_close(int s)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8020e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ec:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8020f1:	b8 04 00 00 00       	mov    $0x4,%eax
  8020f6:	e8 f7 fe ff ff       	call   801ff2 <nsipc>
}
  8020fb:	c9                   	leave  
  8020fc:	c3                   	ret    

008020fd <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020fd:	55                   	push   %ebp
  8020fe:	89 e5                	mov    %esp,%ebp
  802100:	53                   	push   %ebx
  802101:	83 ec 08             	sub    $0x8,%esp
  802104:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802107:	8b 45 08             	mov    0x8(%ebp),%eax
  80210a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80210f:	53                   	push   %ebx
  802110:	ff 75 0c             	pushl  0xc(%ebp)
  802113:	68 04 60 80 00       	push   $0x806004
  802118:	e8 a6 e8 ff ff       	call   8009c3 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80211d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  802123:	b8 05 00 00 00       	mov    $0x5,%eax
  802128:	e8 c5 fe ff ff       	call   801ff2 <nsipc>
}
  80212d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802138:	8b 45 08             	mov    0x8(%ebp),%eax
  80213b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802140:	8b 45 0c             	mov    0xc(%ebp),%eax
  802143:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802148:	b8 06 00 00 00       	mov    $0x6,%eax
  80214d:	e8 a0 fe ff ff       	call   801ff2 <nsipc>
}
  802152:	c9                   	leave  
  802153:	c3                   	ret    

00802154 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	56                   	push   %esi
  802158:	53                   	push   %ebx
  802159:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
  80215f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802164:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80216a:	8b 45 14             	mov    0x14(%ebp),%eax
  80216d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802172:	b8 07 00 00 00       	mov    $0x7,%eax
  802177:	e8 76 fe ff ff       	call   801ff2 <nsipc>
  80217c:	89 c3                	mov    %eax,%ebx
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 35                	js     8021b7 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802182:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802187:	7f 04                	jg     80218d <nsipc_recv+0x39>
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	7d 16                	jge    8021a3 <nsipc_recv+0x4f>
  80218d:	68 0e 2d 80 00       	push   $0x802d0e
  802192:	68 b7 2c 80 00       	push   $0x802cb7
  802197:	6a 62                	push   $0x62
  802199:	68 23 2d 80 00       	push   $0x802d23
  80219e:	e8 28 02 00 00       	call   8023cb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8021a3:	83 ec 04             	sub    $0x4,%esp
  8021a6:	50                   	push   %eax
  8021a7:	68 00 60 80 00       	push   $0x806000
  8021ac:	ff 75 0c             	pushl  0xc(%ebp)
  8021af:	e8 0f e8 ff ff       	call   8009c3 <memmove>
  8021b4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8021b7:	89 d8                	mov    %ebx,%eax
  8021b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5e                   	pop    %esi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    

008021c0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 04             	sub    $0x4,%esp
  8021c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8021d2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021d8:	7e 16                	jle    8021f0 <nsipc_send+0x30>
  8021da:	68 2f 2d 80 00       	push   $0x802d2f
  8021df:	68 b7 2c 80 00       	push   $0x802cb7
  8021e4:	6a 6d                	push   $0x6d
  8021e6:	68 23 2d 80 00       	push   $0x802d23
  8021eb:	e8 db 01 00 00       	call   8023cb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021f0:	83 ec 04             	sub    $0x4,%esp
  8021f3:	53                   	push   %ebx
  8021f4:	ff 75 0c             	pushl  0xc(%ebp)
  8021f7:	68 0c 60 80 00       	push   $0x80600c
  8021fc:	e8 c2 e7 ff ff       	call   8009c3 <memmove>
	nsipcbuf.send.req_size = size;
  802201:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802207:	8b 45 14             	mov    0x14(%ebp),%eax
  80220a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80220f:	b8 08 00 00 00       	mov    $0x8,%eax
  802214:	e8 d9 fd ff ff       	call   801ff2 <nsipc>
}
  802219:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80221c:	c9                   	leave  
  80221d:	c3                   	ret    

0080221e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80221e:	55                   	push   %ebp
  80221f:	89 e5                	mov    %esp,%ebp
  802221:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802224:	8b 45 08             	mov    0x8(%ebp),%eax
  802227:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80222c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80222f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802234:	8b 45 10             	mov    0x10(%ebp),%eax
  802237:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80223c:	b8 09 00 00 00       	mov    $0x9,%eax
  802241:	e8 ac fd ff ff       	call   801ff2 <nsipc>
}
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80224b:	b8 00 00 00 00       	mov    $0x0,%eax
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    

00802252 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802258:	68 3b 2d 80 00       	push   $0x802d3b
  80225d:	ff 75 0c             	pushl  0xc(%ebp)
  802260:	e8 cc e5 ff ff       	call   800831 <strcpy>
	return 0;
}
  802265:	b8 00 00 00 00       	mov    $0x0,%eax
  80226a:	c9                   	leave  
  80226b:	c3                   	ret    

0080226c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80226c:	55                   	push   %ebp
  80226d:	89 e5                	mov    %esp,%ebp
  80226f:	57                   	push   %edi
  802270:	56                   	push   %esi
  802271:	53                   	push   %ebx
  802272:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802278:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80227d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802283:	eb 2d                	jmp    8022b2 <devcons_write+0x46>
		m = n - tot;
  802285:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802288:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80228a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80228d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802292:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802295:	83 ec 04             	sub    $0x4,%esp
  802298:	53                   	push   %ebx
  802299:	03 45 0c             	add    0xc(%ebp),%eax
  80229c:	50                   	push   %eax
  80229d:	57                   	push   %edi
  80229e:	e8 20 e7 ff ff       	call   8009c3 <memmove>
		sys_cputs(buf, m);
  8022a3:	83 c4 08             	add    $0x8,%esp
  8022a6:	53                   	push   %ebx
  8022a7:	57                   	push   %edi
  8022a8:	e8 cb e8 ff ff       	call   800b78 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ad:	01 de                	add    %ebx,%esi
  8022af:	83 c4 10             	add    $0x10,%esp
  8022b2:	89 f0                	mov    %esi,%eax
  8022b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022b7:	72 cc                	jb     802285 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5e                   	pop    %esi
  8022be:	5f                   	pop    %edi
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    

008022c1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022c1:	55                   	push   %ebp
  8022c2:	89 e5                	mov    %esp,%ebp
  8022c4:	83 ec 08             	sub    $0x8,%esp
  8022c7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022d0:	74 2a                	je     8022fc <devcons_read+0x3b>
  8022d2:	eb 05                	jmp    8022d9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022d4:	e8 3c e9 ff ff       	call   800c15 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022d9:	e8 b8 e8 ff ff       	call   800b96 <sys_cgetc>
  8022de:	85 c0                	test   %eax,%eax
  8022e0:	74 f2                	je     8022d4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	78 16                	js     8022fc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022e6:	83 f8 04             	cmp    $0x4,%eax
  8022e9:	74 0c                	je     8022f7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ee:	88 02                	mov    %al,(%edx)
	return 1;
  8022f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f5:	eb 05                	jmp    8022fc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022f7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022fc:	c9                   	leave  
  8022fd:	c3                   	ret    

008022fe <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022fe:	55                   	push   %ebp
  8022ff:	89 e5                	mov    %esp,%ebp
  802301:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802304:	8b 45 08             	mov    0x8(%ebp),%eax
  802307:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80230a:	6a 01                	push   $0x1
  80230c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80230f:	50                   	push   %eax
  802310:	e8 63 e8 ff ff       	call   800b78 <sys_cputs>
}
  802315:	83 c4 10             	add    $0x10,%esp
  802318:	c9                   	leave  
  802319:	c3                   	ret    

0080231a <getchar>:

int
getchar(void)
{
  80231a:	55                   	push   %ebp
  80231b:	89 e5                	mov    %esp,%ebp
  80231d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802320:	6a 01                	push   $0x1
  802322:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802325:	50                   	push   %eax
  802326:	6a 00                	push   $0x0
  802328:	e8 1d f2 ff ff       	call   80154a <read>
	if (r < 0)
  80232d:	83 c4 10             	add    $0x10,%esp
  802330:	85 c0                	test   %eax,%eax
  802332:	78 0f                	js     802343 <getchar+0x29>
		return r;
	if (r < 1)
  802334:	85 c0                	test   %eax,%eax
  802336:	7e 06                	jle    80233e <getchar+0x24>
		return -E_EOF;
	return c;
  802338:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80233c:	eb 05                	jmp    802343 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80233e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802343:	c9                   	leave  
  802344:	c3                   	ret    

00802345 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802345:	55                   	push   %ebp
  802346:	89 e5                	mov    %esp,%ebp
  802348:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80234b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80234e:	50                   	push   %eax
  80234f:	ff 75 08             	pushl  0x8(%ebp)
  802352:	e8 8d ef ff ff       	call   8012e4 <fd_lookup>
  802357:	83 c4 10             	add    $0x10,%esp
  80235a:	85 c0                	test   %eax,%eax
  80235c:	78 11                	js     80236f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80235e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802361:	8b 15 60 30 80 00    	mov    0x803060,%edx
  802367:	39 10                	cmp    %edx,(%eax)
  802369:	0f 94 c0             	sete   %al
  80236c:	0f b6 c0             	movzbl %al,%eax
}
  80236f:	c9                   	leave  
  802370:	c3                   	ret    

00802371 <opencons>:

int
opencons(void)
{
  802371:	55                   	push   %ebp
  802372:	89 e5                	mov    %esp,%ebp
  802374:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237a:	50                   	push   %eax
  80237b:	e8 15 ef ff ff       	call   801295 <fd_alloc>
  802380:	83 c4 10             	add    $0x10,%esp
		return r;
  802383:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802385:	85 c0                	test   %eax,%eax
  802387:	78 3e                	js     8023c7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802389:	83 ec 04             	sub    $0x4,%esp
  80238c:	68 07 04 00 00       	push   $0x407
  802391:	ff 75 f4             	pushl  -0xc(%ebp)
  802394:	6a 00                	push   $0x0
  802396:	e8 99 e8 ff ff       	call   800c34 <sys_page_alloc>
  80239b:	83 c4 10             	add    $0x10,%esp
		return r;
  80239e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023a0:	85 c0                	test   %eax,%eax
  8023a2:	78 23                	js     8023c7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023a4:	8b 15 60 30 80 00    	mov    0x803060,%edx
  8023aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ad:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023b9:	83 ec 0c             	sub    $0xc,%esp
  8023bc:	50                   	push   %eax
  8023bd:	e8 ac ee ff ff       	call   80126e <fd2num>
  8023c2:	89 c2                	mov    %eax,%edx
  8023c4:	83 c4 10             	add    $0x10,%esp
}
  8023c7:	89 d0                	mov    %edx,%eax
  8023c9:	c9                   	leave  
  8023ca:	c3                   	ret    

008023cb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8023cb:	55                   	push   %ebp
  8023cc:	89 e5                	mov    %esp,%ebp
  8023ce:	56                   	push   %esi
  8023cf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8023d0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8023d3:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8023d9:	e8 18 e8 ff ff       	call   800bf6 <sys_getenvid>
  8023de:	83 ec 0c             	sub    $0xc,%esp
  8023e1:	ff 75 0c             	pushl  0xc(%ebp)
  8023e4:	ff 75 08             	pushl  0x8(%ebp)
  8023e7:	56                   	push   %esi
  8023e8:	50                   	push   %eax
  8023e9:	68 48 2d 80 00       	push   $0x802d48
  8023ee:	e8 99 de ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8023f3:	83 c4 18             	add    $0x18,%esp
  8023f6:	53                   	push   %ebx
  8023f7:	ff 75 10             	pushl  0x10(%ebp)
  8023fa:	e8 3c de ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  8023ff:	c7 04 24 fb 2c 80 00 	movl   $0x802cfb,(%esp)
  802406:	e8 81 de ff ff       	call   80028c <cprintf>
  80240b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80240e:	cc                   	int3   
  80240f:	eb fd                	jmp    80240e <_panic+0x43>

00802411 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802411:	55                   	push   %ebp
  802412:	89 e5                	mov    %esp,%ebp
  802414:	83 ec 08             	sub    $0x8,%esp
	int r;
	//cprintf("check7");
	if (_pgfault_handler == 0) {
  802417:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80241e:	75 56                	jne    802476 <set_pgfault_handler+0x65>
		// First time through!
		// LAB 4: Your code here.
		if(sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_W|PTE_U))
  802420:	83 ec 04             	sub    $0x4,%esp
  802423:	6a 07                	push   $0x7
  802425:	68 00 f0 bf ee       	push   $0xeebff000
  80242a:	6a 00                	push   $0x0
  80242c:	e8 03 e8 ff ff       	call   800c34 <sys_page_alloc>
  802431:	83 c4 10             	add    $0x10,%esp
  802434:	85 c0                	test   %eax,%eax
  802436:	74 14                	je     80244c <set_pgfault_handler+0x3b>
			panic("sys_page_alloc Error");
  802438:	83 ec 04             	sub    $0x4,%esp
  80243b:	68 c9 2b 80 00       	push   $0x802bc9
  802440:	6a 21                	push   $0x21
  802442:	68 6c 2d 80 00       	push   $0x802d6c
  802447:	e8 7f ff ff ff       	call   8023cb <_panic>
		if(sys_env_set_pgfault_upcall(0, _pgfault_upcall))
  80244c:	83 ec 08             	sub    $0x8,%esp
  80244f:	68 80 24 80 00       	push   $0x802480
  802454:	6a 00                	push   $0x0
  802456:	e8 24 e9 ff ff       	call   800d7f <sys_env_set_pgfault_upcall>
  80245b:	83 c4 10             	add    $0x10,%esp
  80245e:	85 c0                	test   %eax,%eax
  802460:	74 14                	je     802476 <set_pgfault_handler+0x65>
			panic("pgfault_upcall error");
  802462:	83 ec 04             	sub    $0x4,%esp
  802465:	68 7a 2d 80 00       	push   $0x802d7a
  80246a:	6a 23                	push   $0x23
  80246c:	68 6c 2d 80 00       	push   $0x802d6c
  802471:	e8 55 ff ff ff       	call   8023cb <_panic>
	}
	//cprintf("check8");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802476:	8b 45 08             	mov    0x8(%ebp),%eax
  802479:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80247e:	c9                   	leave  
  80247f:	c3                   	ret    

00802480 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802480:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802481:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802486:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802488:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx
  80248b:	89 e3                	mov    %esp,%ebx
	movl 0x28(%esp), %eax
  80248d:	8b 44 24 28          	mov    0x28(%esp),%eax
	//movl %eax, -4(%esp)
	movl 0x30(%esp), %esp
  802491:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  802495:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp
  802496:	89 dc                	mov    %ebx,%esp
	subl $4, 0x30(%esp)
  802498:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	addl $8, %esp
  80249d:	83 c4 08             	add    $0x8,%esp
	popal
  8024a0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8024a1:	83 c4 04             	add    $0x4,%esp
	popfl
  8024a4:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8024a5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8024a6:	c3                   	ret    

008024a7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024a7:	55                   	push   %ebp
  8024a8:	89 e5                	mov    %esp,%ebp
  8024aa:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024ad:	89 d0                	mov    %edx,%eax
  8024af:	c1 e8 16             	shr    $0x16,%eax
  8024b2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024b9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024be:	f6 c1 01             	test   $0x1,%cl
  8024c1:	74 1d                	je     8024e0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024c3:	c1 ea 0c             	shr    $0xc,%edx
  8024c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8024cd:	f6 c2 01             	test   $0x1,%dl
  8024d0:	74 0e                	je     8024e0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024d2:	c1 ea 0c             	shr    $0xc,%edx
  8024d5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024dc:	ef 
  8024dd:	0f b7 c0             	movzwl %ax,%eax
}
  8024e0:	5d                   	pop    %ebp
  8024e1:	c3                   	ret    
  8024e2:	66 90                	xchg   %ax,%ax
  8024e4:	66 90                	xchg   %ax,%ax
  8024e6:	66 90                	xchg   %ax,%ax
  8024e8:	66 90                	xchg   %ax,%ax
  8024ea:	66 90                	xchg   %ax,%ax
  8024ec:	66 90                	xchg   %ax,%ax
  8024ee:	66 90                	xchg   %ax,%ax

008024f0 <__udivdi3>:
  8024f0:	55                   	push   %ebp
  8024f1:	57                   	push   %edi
  8024f2:	56                   	push   %esi
  8024f3:	53                   	push   %ebx
  8024f4:	83 ec 1c             	sub    $0x1c,%esp
  8024f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802503:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802507:	85 f6                	test   %esi,%esi
  802509:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80250d:	89 ca                	mov    %ecx,%edx
  80250f:	89 f8                	mov    %edi,%eax
  802511:	75 3d                	jne    802550 <__udivdi3+0x60>
  802513:	39 cf                	cmp    %ecx,%edi
  802515:	0f 87 c5 00 00 00    	ja     8025e0 <__udivdi3+0xf0>
  80251b:	85 ff                	test   %edi,%edi
  80251d:	89 fd                	mov    %edi,%ebp
  80251f:	75 0b                	jne    80252c <__udivdi3+0x3c>
  802521:	b8 01 00 00 00       	mov    $0x1,%eax
  802526:	31 d2                	xor    %edx,%edx
  802528:	f7 f7                	div    %edi
  80252a:	89 c5                	mov    %eax,%ebp
  80252c:	89 c8                	mov    %ecx,%eax
  80252e:	31 d2                	xor    %edx,%edx
  802530:	f7 f5                	div    %ebp
  802532:	89 c1                	mov    %eax,%ecx
  802534:	89 d8                	mov    %ebx,%eax
  802536:	89 cf                	mov    %ecx,%edi
  802538:	f7 f5                	div    %ebp
  80253a:	89 c3                	mov    %eax,%ebx
  80253c:	89 d8                	mov    %ebx,%eax
  80253e:	89 fa                	mov    %edi,%edx
  802540:	83 c4 1c             	add    $0x1c,%esp
  802543:	5b                   	pop    %ebx
  802544:	5e                   	pop    %esi
  802545:	5f                   	pop    %edi
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    
  802548:	90                   	nop
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	39 ce                	cmp    %ecx,%esi
  802552:	77 74                	ja     8025c8 <__udivdi3+0xd8>
  802554:	0f bd fe             	bsr    %esi,%edi
  802557:	83 f7 1f             	xor    $0x1f,%edi
  80255a:	0f 84 98 00 00 00    	je     8025f8 <__udivdi3+0x108>
  802560:	bb 20 00 00 00       	mov    $0x20,%ebx
  802565:	89 f9                	mov    %edi,%ecx
  802567:	89 c5                	mov    %eax,%ebp
  802569:	29 fb                	sub    %edi,%ebx
  80256b:	d3 e6                	shl    %cl,%esi
  80256d:	89 d9                	mov    %ebx,%ecx
  80256f:	d3 ed                	shr    %cl,%ebp
  802571:	89 f9                	mov    %edi,%ecx
  802573:	d3 e0                	shl    %cl,%eax
  802575:	09 ee                	or     %ebp,%esi
  802577:	89 d9                	mov    %ebx,%ecx
  802579:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80257d:	89 d5                	mov    %edx,%ebp
  80257f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802583:	d3 ed                	shr    %cl,%ebp
  802585:	89 f9                	mov    %edi,%ecx
  802587:	d3 e2                	shl    %cl,%edx
  802589:	89 d9                	mov    %ebx,%ecx
  80258b:	d3 e8                	shr    %cl,%eax
  80258d:	09 c2                	or     %eax,%edx
  80258f:	89 d0                	mov    %edx,%eax
  802591:	89 ea                	mov    %ebp,%edx
  802593:	f7 f6                	div    %esi
  802595:	89 d5                	mov    %edx,%ebp
  802597:	89 c3                	mov    %eax,%ebx
  802599:	f7 64 24 0c          	mull   0xc(%esp)
  80259d:	39 d5                	cmp    %edx,%ebp
  80259f:	72 10                	jb     8025b1 <__udivdi3+0xc1>
  8025a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8025a5:	89 f9                	mov    %edi,%ecx
  8025a7:	d3 e6                	shl    %cl,%esi
  8025a9:	39 c6                	cmp    %eax,%esi
  8025ab:	73 07                	jae    8025b4 <__udivdi3+0xc4>
  8025ad:	39 d5                	cmp    %edx,%ebp
  8025af:	75 03                	jne    8025b4 <__udivdi3+0xc4>
  8025b1:	83 eb 01             	sub    $0x1,%ebx
  8025b4:	31 ff                	xor    %edi,%edi
  8025b6:	89 d8                	mov    %ebx,%eax
  8025b8:	89 fa                	mov    %edi,%edx
  8025ba:	83 c4 1c             	add    $0x1c,%esp
  8025bd:	5b                   	pop    %ebx
  8025be:	5e                   	pop    %esi
  8025bf:	5f                   	pop    %edi
  8025c0:	5d                   	pop    %ebp
  8025c1:	c3                   	ret    
  8025c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025c8:	31 ff                	xor    %edi,%edi
  8025ca:	31 db                	xor    %ebx,%ebx
  8025cc:	89 d8                	mov    %ebx,%eax
  8025ce:	89 fa                	mov    %edi,%edx
  8025d0:	83 c4 1c             	add    $0x1c,%esp
  8025d3:	5b                   	pop    %ebx
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    
  8025d8:	90                   	nop
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	89 d8                	mov    %ebx,%eax
  8025e2:	f7 f7                	div    %edi
  8025e4:	31 ff                	xor    %edi,%edi
  8025e6:	89 c3                	mov    %eax,%ebx
  8025e8:	89 d8                	mov    %ebx,%eax
  8025ea:	89 fa                	mov    %edi,%edx
  8025ec:	83 c4 1c             	add    $0x1c,%esp
  8025ef:	5b                   	pop    %ebx
  8025f0:	5e                   	pop    %esi
  8025f1:	5f                   	pop    %edi
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    
  8025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025f8:	39 ce                	cmp    %ecx,%esi
  8025fa:	72 0c                	jb     802608 <__udivdi3+0x118>
  8025fc:	31 db                	xor    %ebx,%ebx
  8025fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802602:	0f 87 34 ff ff ff    	ja     80253c <__udivdi3+0x4c>
  802608:	bb 01 00 00 00       	mov    $0x1,%ebx
  80260d:	e9 2a ff ff ff       	jmp    80253c <__udivdi3+0x4c>
  802612:	66 90                	xchg   %ax,%ax
  802614:	66 90                	xchg   %ax,%ax
  802616:	66 90                	xchg   %ax,%ax
  802618:	66 90                	xchg   %ax,%ax
  80261a:	66 90                	xchg   %ax,%ax
  80261c:	66 90                	xchg   %ax,%ax
  80261e:	66 90                	xchg   %ax,%ax

00802620 <__umoddi3>:
  802620:	55                   	push   %ebp
  802621:	57                   	push   %edi
  802622:	56                   	push   %esi
  802623:	53                   	push   %ebx
  802624:	83 ec 1c             	sub    $0x1c,%esp
  802627:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80262b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80262f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802637:	85 d2                	test   %edx,%edx
  802639:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80263d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802641:	89 f3                	mov    %esi,%ebx
  802643:	89 3c 24             	mov    %edi,(%esp)
  802646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80264a:	75 1c                	jne    802668 <__umoddi3+0x48>
  80264c:	39 f7                	cmp    %esi,%edi
  80264e:	76 50                	jbe    8026a0 <__umoddi3+0x80>
  802650:	89 c8                	mov    %ecx,%eax
  802652:	89 f2                	mov    %esi,%edx
  802654:	f7 f7                	div    %edi
  802656:	89 d0                	mov    %edx,%eax
  802658:	31 d2                	xor    %edx,%edx
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	5b                   	pop    %ebx
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
  802662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802668:	39 f2                	cmp    %esi,%edx
  80266a:	89 d0                	mov    %edx,%eax
  80266c:	77 52                	ja     8026c0 <__umoddi3+0xa0>
  80266e:	0f bd ea             	bsr    %edx,%ebp
  802671:	83 f5 1f             	xor    $0x1f,%ebp
  802674:	75 5a                	jne    8026d0 <__umoddi3+0xb0>
  802676:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80267a:	0f 82 e0 00 00 00    	jb     802760 <__umoddi3+0x140>
  802680:	39 0c 24             	cmp    %ecx,(%esp)
  802683:	0f 86 d7 00 00 00    	jbe    802760 <__umoddi3+0x140>
  802689:	8b 44 24 08          	mov    0x8(%esp),%eax
  80268d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802691:	83 c4 1c             	add    $0x1c,%esp
  802694:	5b                   	pop    %ebx
  802695:	5e                   	pop    %esi
  802696:	5f                   	pop    %edi
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	85 ff                	test   %edi,%edi
  8026a2:	89 fd                	mov    %edi,%ebp
  8026a4:	75 0b                	jne    8026b1 <__umoddi3+0x91>
  8026a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	f7 f7                	div    %edi
  8026af:	89 c5                	mov    %eax,%ebp
  8026b1:	89 f0                	mov    %esi,%eax
  8026b3:	31 d2                	xor    %edx,%edx
  8026b5:	f7 f5                	div    %ebp
  8026b7:	89 c8                	mov    %ecx,%eax
  8026b9:	f7 f5                	div    %ebp
  8026bb:	89 d0                	mov    %edx,%eax
  8026bd:	eb 99                	jmp    802658 <__umoddi3+0x38>
  8026bf:	90                   	nop
  8026c0:	89 c8                	mov    %ecx,%eax
  8026c2:	89 f2                	mov    %esi,%edx
  8026c4:	83 c4 1c             	add    $0x1c,%esp
  8026c7:	5b                   	pop    %ebx
  8026c8:	5e                   	pop    %esi
  8026c9:	5f                   	pop    %edi
  8026ca:	5d                   	pop    %ebp
  8026cb:	c3                   	ret    
  8026cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	8b 34 24             	mov    (%esp),%esi
  8026d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026d8:	89 e9                	mov    %ebp,%ecx
  8026da:	29 ef                	sub    %ebp,%edi
  8026dc:	d3 e0                	shl    %cl,%eax
  8026de:	89 f9                	mov    %edi,%ecx
  8026e0:	89 f2                	mov    %esi,%edx
  8026e2:	d3 ea                	shr    %cl,%edx
  8026e4:	89 e9                	mov    %ebp,%ecx
  8026e6:	09 c2                	or     %eax,%edx
  8026e8:	89 d8                	mov    %ebx,%eax
  8026ea:	89 14 24             	mov    %edx,(%esp)
  8026ed:	89 f2                	mov    %esi,%edx
  8026ef:	d3 e2                	shl    %cl,%edx
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026fb:	d3 e8                	shr    %cl,%eax
  8026fd:	89 e9                	mov    %ebp,%ecx
  8026ff:	89 c6                	mov    %eax,%esi
  802701:	d3 e3                	shl    %cl,%ebx
  802703:	89 f9                	mov    %edi,%ecx
  802705:	89 d0                	mov    %edx,%eax
  802707:	d3 e8                	shr    %cl,%eax
  802709:	89 e9                	mov    %ebp,%ecx
  80270b:	09 d8                	or     %ebx,%eax
  80270d:	89 d3                	mov    %edx,%ebx
  80270f:	89 f2                	mov    %esi,%edx
  802711:	f7 34 24             	divl   (%esp)
  802714:	89 d6                	mov    %edx,%esi
  802716:	d3 e3                	shl    %cl,%ebx
  802718:	f7 64 24 04          	mull   0x4(%esp)
  80271c:	39 d6                	cmp    %edx,%esi
  80271e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802722:	89 d1                	mov    %edx,%ecx
  802724:	89 c3                	mov    %eax,%ebx
  802726:	72 08                	jb     802730 <__umoddi3+0x110>
  802728:	75 11                	jne    80273b <__umoddi3+0x11b>
  80272a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80272e:	73 0b                	jae    80273b <__umoddi3+0x11b>
  802730:	2b 44 24 04          	sub    0x4(%esp),%eax
  802734:	1b 14 24             	sbb    (%esp),%edx
  802737:	89 d1                	mov    %edx,%ecx
  802739:	89 c3                	mov    %eax,%ebx
  80273b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80273f:	29 da                	sub    %ebx,%edx
  802741:	19 ce                	sbb    %ecx,%esi
  802743:	89 f9                	mov    %edi,%ecx
  802745:	89 f0                	mov    %esi,%eax
  802747:	d3 e0                	shl    %cl,%eax
  802749:	89 e9                	mov    %ebp,%ecx
  80274b:	d3 ea                	shr    %cl,%edx
  80274d:	89 e9                	mov    %ebp,%ecx
  80274f:	d3 ee                	shr    %cl,%esi
  802751:	09 d0                	or     %edx,%eax
  802753:	89 f2                	mov    %esi,%edx
  802755:	83 c4 1c             	add    $0x1c,%esp
  802758:	5b                   	pop    %ebx
  802759:	5e                   	pop    %esi
  80275a:	5f                   	pop    %edi
  80275b:	5d                   	pop    %ebp
  80275c:	c3                   	ret    
  80275d:	8d 76 00             	lea    0x0(%esi),%esi
  802760:	29 f9                	sub    %edi,%ecx
  802762:	19 d6                	sbb    %edx,%esi
  802764:	89 74 24 04          	mov    %esi,0x4(%esp)
  802768:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80276c:	e9 18 ff ff ff       	jmp    802689 <__umoddi3+0x69>
